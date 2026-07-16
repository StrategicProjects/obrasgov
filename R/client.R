.obrasgovr_default_url <- "https://api-publica.obrasgov.gestao.gov.br/obras"

.obrasgovr_base_url <- function() {
  getOption("obrasgovr.base_url", .obrasgovr_default_url)
}

.obrasgovr_timeout <- function() {
  getOption("obrasgovr.timeout", 30)
}

.obrasgovr_user_agent <- function() {
  getOption(
    "obrasgovr.user_agent",
    paste0(
      "obrasgovr/0.1.0 ",
      "(https://api-publica.obrasgov.gestao.gov.br/obras/docs)"
    )
  )
}

.obrasgovr_request <- function(endpoint, query = list(), base_url) {
  .check_base_url(base_url)

  base_url <- sub("/+$", "", base_url)
  endpoint <- sub("^/+", "", endpoint)

  req <- httr2::request(base_url) |>
    httr2::req_url_path_append(endpoint) |>
    httr2::req_headers(Accept = "application/json") |>
    httr2::req_user_agent(.obrasgovr_user_agent()) |>
    httr2::req_options(http_version = 4L) |>
    httr2::req_timeout(seconds = .obrasgovr_timeout()) |>
    httr2::req_throttle(
      capacity = 60,
      fill_time_s = 60,
      realm = "obrasgovr"
    ) |>
    httr2::req_retry(max_tries = 4, retry_on_failure = TRUE) |>
    httr2::req_error(is_error = function(resp) FALSE)

  if (length(query) > 0L) {
    req <- httr2::req_url_query(req, !!!query)
  }

  req
}

.obrasgovr_perform <- function(endpoint, query = list(), base_url) {
  response <- .obrasgovr_request(endpoint, query, base_url) |>
    httr2::req_perform()

  .abort_for_status(response)

  tryCatch(
    httr2::resp_body_json(response, simplifyVector = FALSE),
    error = function(error) {
      cli::cli_abort(
        "The ObrasGov API returned invalid JSON.",
        class = "obrasgovr_response_error",
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
    class = c("obrasgovr_http_error", paste0("obrasgovr_http_", status))
  )
}

.response_error_detail <- function(response) {
  body <- tryCatch(
    httr2::resp_body_json(response, simplifyVector = FALSE),
    error = function(error) NULL
  )

  # A JSON body need not be an object: `$` on an atomic value would error and
  # mask the HTTP status we are trying to report.
  if (!is.list(body) || is.null(body$detail)) {
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

.obrasgovr_get_paginated <- function(
    resource,
    filters,
    page,
    page_size,
    all_pages,
    page_limit,
    base_url) {
  resource <- .match_resource(resource)
  metadata <- .obrasgovr_resources[[resource]]

  filters <- .validate_filters(filters, metadata$filters)
  .check_pagination(
    page,
    page_size,
    all_pages,
    page_limit
  )

  bodies <- .obrasgovr_collect_pages(
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
  result <- .records_to_tibble(
    records,
    date_fields = names(metadata$filters)[metadata$filters == "Date"]
  )

  .add_result_metadata(
    result,
    resource,
    metadata,
    bodies,
    page,
    page_size
  )
}

.obrasgovr_collect_pages <- function(
    metadata,
    filters,
    page,
    page_size,
    all_pages,
    page_limit,
    base_url) {
  first <- .obrasgovr_fetch_page(
    metadata$endpoint,
    filters,
    page,
    page_size,
    base_url
  )
  total_pages <- .response_total(first, "total_pages")
  .check_totals_consistent(first, total_pages)
  bodies <- list(first)

  if (!isTRUE(all_pages) || total_pages <= page) {
    return(bodies)
  }

  last_page <- total_pages
  if (is.finite(page_limit)) {
    # Kept in double: `page + as.integer(page_limit)` overflows to NA when the
    # limit is near the integer maximum, even though the range that survives
    # `min()` is always small.
    last_page <- min(last_page, page + (as.numeric(page_limit) - 1))
  }

  # `seq.int()` counts backwards when its second argument is the smaller one, so
  # an exhausted budget must return here rather than fetch pages in reverse.
  if (last_page <= page) {
    return(bodies)
  }

  pages <- seq.int(page + 1L, last_page)
  # `lapply()`, not `purrr::map()`: purrr wraps errors in `purrr_error_indexed`,
  # which would strip the documented condition class from any failure on the
  # second page onwards.
  remaining <- lapply(pages, function(page) {
    .obrasgovr_fetch_page(
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
  attr(result, "obrasgovr_metadata") <- list(
    resource = resource,
    endpoint = metadata$endpoint,
    total_pages = .response_total(first, "total_pages"),
    total_items = .response_total(first, "total_items"),
    first_page = as.integer(page),
    pages_retrieved = length(bodies),
    page_size = as.integer(page_size),
    retrieved_at = Sys.time()
  )

  result
}

.obrasgovr_fetch_page <- function(
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
  body <- .obrasgovr_perform(endpoint, query, base_url)

  if (!is.list(body) || is.null(body$data) || !is.list(body$data)) {
    cli::cli_abort(
      "The paginated API response has an unexpected format.",
      class = "obrasgovr_response_error"
    )
  }

  # The response says which page it is. Without checking, a server or proxy that
  # answers page 2 with page 1 would be silently collected as if it were new
  # data, duplicating records under the guise of a complete result.
  # A marker that is present must be usable: accepting only numerics let a
  # string "1" disable the check entirely, and `as.integer()` truncation let
  # 1.9 pass as page 1.
  returned <- body$page_number
  if (!is.null(returned)) {
    if (
      !is.numeric(returned) ||
        length(returned) != 1L ||
        !is.finite(returned) ||
        returned %% 1 != 0 ||
        abs(returned) > .Machine$integer.max
    ) {
      cli::cli_abort(
        "The API reported an unusable {.field page_number}.",
        class = "obrasgovr_response_error"
      )
    }

    if (as.integer(returned) != as.integer(page)) {
      cli::cli_abort(
        c(
          "The API returned page {.val {as.integer(returned)}} when page
           {.val {as.integer(page)}} was requested.",
          "i" = "Collecting it would duplicate records."
        ),
        class = "obrasgovr_response_error"
      )
    }
  }

  body
}

# Pagination totals drive multi-page collection, so a missing one must abort
# rather than default to zero: that would silently stop after the first page and
# report the truncated result as complete.
.response_total <- function(body, field) {
  value <- body[[field]]

  # Fractional, infinite and out-of-range totals must be rejected here too:
  # `as.integer()` would quietly truncate the first and turn the others into
  # `NA`, which then breaks page-range arithmetic with an unclassified error.
  if (
    !is.numeric(value) ||
      length(value) != 1L ||
      !is.finite(value) ||
      value < 0 ||
      value > .Machine$integer.max ||
      value %% 1 != 0
  ) {
    cli::cli_abort(
      c(
        "The API response has no usable {.field {field}}.",
        "i" = "Pagination cannot be verified, so the result may be incomplete."
      ),
      class = "obrasgovr_response_error"
    )
  }

  as.integer(value)
}

# Zero is a legitimate total for an empty result, but a zero that contradicts
# the payload is not: `total_pages = 0` alongside records would stop collection
# on the first page and present the truncated result as complete -- the same
# silent-incompleteness class as a missing total, reached through a bad zero.
.check_totals_consistent <- function(body, total_pages) {
  total_items <- .response_total(body, "total_items")
  records <- length(body$data)

  inconsistent <- (total_pages == 0L && (records > 0L || total_items > 0L)) ||
    (total_items == 0L && records > 0L)

  if (inconsistent) {
    cli::cli_abort(
      c(
        "The API reported pagination totals that contradict the response.",
        "i" = "Got {.val {records}} record{?s} with
               {.field total_pages} = {.val {total_pages}} and
               {.field total_items} = {.val {total_items}}.",
        "i" = "Pagination cannot be verified, so the result may be incomplete."
      ),
      class = "obrasgovr_response_error"
    )
  }

  invisible(NULL)
}

.records_to_tibble <- function(records, date_fields = character()) {
  if (length(records) == 0L) {
    return(tibble::tibble())
  }

  # `lapply()`, not `purrr::map()`: purrr wraps errors in `purrr_error_indexed`,
  # which strips the documented condition class from a malformed record.
  rows <- lapply(records, .record_to_tibble)
  result <- purrr::list_rbind(rows)

  # The `dt_`/`data_` prefixes catch most date fields, but not all: the API
  # also names dates `vigencia_*`. Fields the resource declares as dates are
  # typed too, so the result does not depend on naming luck.
  date_columns <- union(
    names(result)[grepl("^(dt_|data_)", names(result))],
    intersect(date_fields, names(result))
  )

  for (column in date_columns) {
    value <- result[[column]]

    if (inherits(value, "Date")) {
      next
    }

    # A column whose values are all missing carries no evidence of its type, so
    # type it from the resource metadata rather than leaving it logical: the
    # same field must not change class from page to page.
    if (all(is.na(value)) && column %in% date_fields) {
      result[[column]] <- as.Date(rep(NA_character_, nrow(result)))
      next
    }

    if (!is.character(value)) {
      next
    }

    result[[column]] <- .as_iso_date(value) %||% value
  }

  result
}

# Converts a character column to `Date`, or returns NULL to leave it alone.
#
# The shape is checked with an anchored regex *and* parsed with an explicit
# format. Neither alone is enough: `as.Date()` without a format guesses and
# errors on "2026-02-30", while `as.Date(x, format = "%Y-%m-%d")` ignores
# trailing text, so "2026-01-02T03:04:05" would silently become 2026-01-02 and
# lose its time. Conversion happens only when every present value passes both,
# so a column is never partly emptied.
.as_iso_date <- function(value) {
  present <- !is.na(value)
  iso <- grepl("^[0-9]{4}-[0-9]{2}-[0-9]{2}$", value[present])

  if (!any(present) || !all(iso)) {
    return(NULL)
  }

  parsed <- as.Date(value, format = "%Y-%m-%d")

  if (any(is.na(parsed) & present)) {
    return(NULL)
  }

  parsed
}

.record_to_tibble <- function(record) {
  # A JSON `{}` arrives as a zero-length *named* list, so `names()` returns
  # `character(0)` rather than `NULL` and slips past a null-names check. It then
  # becomes a zero-row tibble and vanishes in the row-bind, leaving the result
  # one record short of what the API said it sent, with no error.
  if (!is.list(record) || length(record) == 0L || is.null(names(record))) {
    cli::cli_abort(
      "An API record has an unexpected format.",
      class = "obrasgovr_response_error"
    )
  }

  row <- purrr::map(record, function(value) {
    # An empty JSON array is still a relationship, just an empty one. It must
    # stay a list-column, or it becomes indistinguishable from `null`.
    if (is.list(value)) {
      return(list(value))
    }
    if (is.null(value) || length(value) == 0L) {
      return(NA)
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

  # `Inf` is allowed and means "every page", but a merely huge finite value is
  # not: `as.integer()` would turn it into `NA` when the page range is built.
  if (
    !is.numeric(page_limit) ||
      length(page_limit) != 1L ||
      is.na(page_limit) ||
      page_limit <= 0 ||
      (!is.infinite(page_limit) &&
         (page_limit %% 1 != 0 || page_limit > .Machine$integer.max))
  ) {
    cli::cli_abort(
      "{.arg page_limit} must be a positive integer or `Inf`."
    )
  }

  invisible(NULL)
}

.check_positive_integer <- function(value, argument) {
  maximum <- .Machine$integer.max

  # `is.finite()` must come before `%%`: `Inf %% 1` is `NaN`, which would make
  # the condition itself error instead of reporting the bad argument. The upper
  # bound keeps `as.integer()` from silently turning the value into `NA` later.
  if (
    !is.numeric(value) ||
      length(value) != 1L ||
      !is.finite(value) ||
      value < 1 ||
      value > maximum ||
      value %% 1 != 0
  ) {
    cli::cli_abort(
      "{.arg {argument}} must be a positive integer no greater than
       {.val {maximum}}."
    )
  }
  invisible(NULL)
}

.check_base_url <- function(base_url) {
  if (
    !is.character(base_url) ||
      length(base_url) != 1L ||
      is.na(base_url) ||
      !startsWith(base_url, "https://")
  ) {
    cli::cli_abort(
      "{.arg base_url} must be a single HTTPS URL.",
      class = "obrasgovr_url_error"
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
  attr(x, "obrasgovr_metadata", exact = TRUE)
}

#' @rdname result_metadata
#' @export
obrasgov_metadados <- result_metadata
