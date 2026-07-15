.obrasgov_default_url <- "https://api-publica.obrasgov.gestao.gov.br/obras"

.obrasgov_base_url <- function() {
  getOption("obrasgov.base_url", .obrasgov_default_url)
}

.obrasgov_timeout <- function() {
  getOption("obrasgov.timeout", 30)
}

.obrasgov_user_agent <- function() {
  getOption(
    "obrasgov.user_agent",
    paste0(
      "obrasgov/0.1.0 ",
      "(https://api-publica.obrasgov.gestao.gov.br/obras/docs)"
    )
  )
}

.obrasgov_request <- function(endpoint, query = list(), base_url) {
  .check_base_url(base_url)

  base_url <- sub("/+$", "", base_url)
  endpoint <- sub("^/+", "", endpoint)

  req <- httr2::request(base_url) |>
    httr2::req_url_path_append(endpoint) |>
    httr2::req_headers(Accept = "application/json") |>
    httr2::req_user_agent(.obrasgov_user_agent()) |>
    httr2::req_options(http_version = 4L) |>
    httr2::req_timeout(seconds = .obrasgov_timeout()) |>
    httr2::req_throttle(
      rate = 60,
      fill_time_s = 60,
      realm = "obrasgov"
    ) |>
    httr2::req_retry(max_tries = 4, retry_on_failure = TRUE) |>
    httr2::req_error(is_error = function(resp) FALSE)

  if (length(query) > 0L) {
    req <- httr2::req_url_query(req, !!!query)
  }

  req
}

.obrasgov_perform <- function(endpoint, query = list(), base_url) {
  response <- .obrasgov_request(endpoint, query, base_url) |>
    httr2::req_perform()

  .abort_for_status(response)

  tryCatch(
    httr2::resp_body_json(response, simplifyVector = FALSE),
    error = function(error) {
      cli::cli_abort(
        "The ObrasGov API returned invalid JSON.",
        class = "obrasgov_response_error",
        parent = error
      )
    }
  )
}

.abort_for_status <- function(response) {
  status <- httr2::resp_status(response)

  if (status < 400L) {
    return(invisible(response))
  }

  detail <- .response_error_detail(response)
  message <- paste0(
    "The ObrasGov API returned HTTP ", status, " (",
    httr2::resp_status_desc(response), ")."
  )

  if (nzchar(detail)) {
    message <- paste(message, detail)
  }

  cli::cli_abort(
    message,
    class = c("obrasgov_http_error", paste0("obrasgov_http_", status))
  )
}

.response_error_detail <- function(response) {
  body <- tryCatch(
    httr2::resp_body_json(response, simplifyVector = FALSE),
    error = function(error) NULL
  )

  if (is.null(body$detail)) {
    return("")
  }

  if (is.character(body$detail)) {
    return(paste(body$detail, collapse = "; "))
  }

  if (is.list(body$detail)) {
    messages <- purrr::map_chr(body$detail, function(item) {
      if (is.list(item) && is.character(item$msg)) {
        return(item$msg[[1]])
      }
      "Validation error"
    })
    return(paste(unique(messages), collapse = "; "))
  }

  ""
}

.obrasgov_get_paginated <- function(
    resource,
    filters,
    page,
    page_size,
    all_pages,
    page_limit,
    base_url) {
  resource <- .match_resource(resource)
  metadata <- .obrasgov_resources[[resource]]

  filters <- .validate_filters(filters, metadata$filters)
  .check_pagination(
    page,
    page_size,
    all_pages,
    page_limit
  )

  bodies <- .obrasgov_collect_pages(
    metadata,
    filters,
    page,
    page_size,
    all_pages,
    page_limit,
    base_url
  )

  records <- purrr::map(bodies, "data") |>
    unlist(recursive = FALSE)
  result <- .records_to_tibble(records)

  .add_result_metadata(
    result,
    resource,
    metadata,
    bodies,
    page,
    page_size
  )
}

.obrasgov_collect_pages <- function(
    metadata,
    filters,
    page,
    page_size,
    all_pages,
    page_limit,
    base_url) {
  first <- .obrasgov_fetch_page(
    metadata$endpoint,
    filters,
    page,
    page_size,
    base_url
  )
  total_pages <- as.integer(.or_default(first$total_pages, 0L))
  bodies <- list(first)

  if (!isTRUE(all_pages) || total_pages <= page) {
    return(bodies)
  }

  last_page <- total_pages
  if (is.finite(page_limit)) {
    last_page <- min(last_page, page + as.integer(page_limit) - 1L)
  }

  pages <- seq.int(page + 1L, last_page)
  remaining <- purrr::map(pages, function(page) {
    .obrasgov_fetch_page(
      metadata$endpoint,
      filters,
      page,
      page_size,
      base_url
    )
  })

  c(bodies, remaining)
}

.add_result_metadata <- function(
    result,
    resource,
    metadata,
    bodies,
    page,
    page_size) {
  first <- bodies[[1L]]
  attr(result, "obrasgov_metadata") <- list(
    resource = resource,
    endpoint = metadata$endpoint,
    total_pages = as.integer(.or_default(first$total_pages, 0L)),
    total_items = as.integer(.or_default(first$total_items, 0L)),
    first_page = as.integer(page),
    pages_retrieved = length(bodies),
    page_size = as.integer(page_size),
    retrieved_at = Sys.time()
  )

  result
}

.obrasgov_fetch_page <- function(
    endpoint,
    filters,
    page,
    page_size,
    base_url) {
  query <- c(
    filters,
    list(
      pagina = as.integer(page),
      tamanho_da_pagina = as.integer(page_size)
    )
  )
  body <- .obrasgov_perform(endpoint, query, base_url)

  if (!is.list(body) || is.null(body$data) || !is.list(body$data)) {
    cli::cli_abort(
      "The paginated API response has an unexpected format.",
      class = "obrasgov_response_error"
    )
  }

  body
}

.records_to_tibble <- function(records) {
  if (length(records) == 0L) {
    return(tibble::tibble())
  }

  rows <- purrr::map(records, .record_to_tibble)
  result <- purrr::list_rbind(rows)

  date_columns <- names(result)[grepl("^(dt_|data_)", names(result))]

  for (column in date_columns) {
    value <- result[[column]]
    present <- !is.na(value)

    if (
      is.character(value) &&
        any(present) &&
        all(grepl("^\\d{4}-\\d{2}-\\d{2}$", value[present]))
    ) {
      result[[column]] <- as.Date(value)
    }
  }

  result
}

.record_to_tibble <- function(record) {
  if (!is.list(record) || is.null(names(record))) {
    cli::cli_abort(
      "An API record has an unexpected format.",
      class = "obrasgov_response_error"
    )
  }

  row <- purrr::map(record, function(value) {
    if (is.null(value) || length(value) == 0L) {
      return(NA)
    }
    if (is.list(value)) {
      return(list(value))
    }
    value
  })

  tibble::as_tibble(row, .name_repair = "minimal")
}

.validate_filters <- function(filters, allowed) {
  if (length(filters) == 0L) {
    return(list())
  }

  filter_names <- names(filters)
  if (is.null(filter_names) || !all(nzchar(filter_names))) {
    cli::cli_abort("Every filter in {.arg ...} must be named.")
  }

  unknown <- setdiff(filter_names, names(allowed))
  if (length(unknown) > 0L) {
    cli::cli_abort(c(
      "Unknown filter{?s}: {.val {unknown}}.",
      "i" = "See the available filters with {.fn list_filters}."
    ))
  }

  filters <- filters[!purrr::map_lgl(filters, is.null)]

  purrr::imap(filters, function(value, name) {
    if (length(value) != 1L || is.list(value) || is.na(value)) {
      cli::cli_abort(
        "Filter {.arg {name}} must contain one non-missing value."
      )
    }
    if (inherits(value, "Date")) {
      return(format(value, "%Y-%m-%d"))
    }
    value
  })
}

.check_pagination <- function(
    page,
    page_size,
    all_pages,
    page_limit) {
  .check_positive_integer(page, "page")
  .check_positive_integer(page_size, "page_size")

  if (page_size > 200L) {
    cli::cli_abort("{.arg page_size} cannot be greater than 200.")
  }

  if (
    !is.logical(all_pages) ||
      length(all_pages) != 1L ||
      is.na(all_pages)
  ) {
    cli::cli_abort("{.arg all_pages} must be `TRUE` or `FALSE`.")
  }

  if (
    !is.numeric(page_limit) ||
      length(page_limit) != 1L ||
      is.na(page_limit) ||
      page_limit <= 0 ||
      (!is.infinite(page_limit) && page_limit %% 1 != 0)
  ) {
    cli::cli_abort(
      "{.arg page_limit} must be a positive integer or `Inf`."
    )
  }

  invisible(NULL)
}

.check_positive_integer <- function(value, argument) {
  if (
    !is.numeric(value) ||
      length(value) != 1L ||
      is.na(value) ||
      value < 1 ||
      value %% 1 != 0
  ) {
    cli::cli_abort("{.arg {argument}} must be a positive integer.")
  }
  invisible(NULL)
}

.check_base_url <- function(base_url) {
  if (
    !is.character(base_url) ||
      length(base_url) != 1L ||
      is.na(base_url) ||
      !grepl("^https://", base_url)
  ) {
    cli::cli_abort(
      "{.arg base_url} must be a single HTTPS URL.",
      class = "obrasgov_url_error"
    )
  }
  invisible(NULL)
}

#' Retrieve pagination metadata
#'
#' @param x A tibble returned by a paginated package function.
#'
#' @return A list containing the resource, totals reported by the API, and
#'   retrieved pages; `NULL` for other objects.
#' @export
#' @examples
#' result_metadata(tibble::tibble())
result_metadata <- function(x) {
  attr(x, "obrasgov_metadata", exact = TRUE)
}

#' @rdname result_metadata
#' @export
obrasgov_metadados <- result_metadata

.or_default <- function(x, y) {
  if (is.null(x)) y else x
}
