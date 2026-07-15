#' Retrieve infrastructure projects
#'
#' Retrieves infrastructure projects and their nested relationships, including
#' executors, recipients, funding sources, policy areas, and point geometries.
#'
#' @param ... Named filters accepted by the resource. See the complete list
#'   with `list_filters("projects")`. Filter names and categorical values are
#'   kept in Portuguese because they are defined by the ObrasGov API.
#' @param page First page to retrieve, starting at 1.
#' @param page_size Number of records per page, between 1 and 200.
#' @param all_pages If `TRUE`, retrieves successive pages starting at `page`.
#' @param page_limit Maximum number of pages to retrieve when `all_pages` is
#'   `TRUE`. Use `Inf` to retrieve every available page.
#' @param base_url HTTPS base URL. By default, uses the `obrasgov.base_url`
#'   option or the official API environment.
#' @param pagina,tamanho_da_pagina,todas_paginas,limite_paginas Portuguese
#'   aliases for `page`, `page_size`, `all_pages`, and `page_limit`,
#'   respectively. These arguments are available only in the Portuguese
#'   function alias.
#'
#' @return A tibble. One-to-many relationships are preserved in list-columns.
#'   Use [result_metadata()] to inspect pagination information.
#' @export
#' @family API resources
#' @examples
#' if (interactive()) {
#'   get_projects(uf_principal = "PE", page_size = 10)
#' }
get_projects <- function(
    ...,
    page = 1L,
    page_size = 50L,
    all_pages = FALSE,
    page_limit = Inf,
    base_url = .obrasgov_base_url()) {
  .endpoint_query(
    "projects",
    rlang::list2(...),
    page,
    page_size,
    all_pages,
    page_limit,
    base_url
  )
}

#' @rdname get_projects
#' @export
obter_projetos <- function(
    ...,
    pagina = 1L,
    tamanho_da_pagina = 50L,
    todas_paginas = FALSE,
    limite_paginas = Inf,
    base_url = .obrasgov_base_url()) {
  get_projects(
    ...,
    page = pagina,
    page_size = tamanho_da_pagina,
    all_pages = todas_paginas,
    page_limit = limite_paginas,
    base_url = base_url
  )
}

#' Retrieve budget commitments
#'
#' @inheritParams get_projects
#' @param ... Named filters. See `list_filters("commitments")`.
#'
#' @return A tibble containing budget commitments and financial execution
#'   amounts.
#' @export
#' @family API resources
#' @examples
#' if (interactive()) {
#'   get_commitments(id_projeto_investimento = "134851.26-07")
#' }
get_commitments <- function(
    ...,
    page = 1L,
    page_size = 50L,
    all_pages = FALSE,
    page_limit = Inf,
    base_url = .obrasgov_base_url()) {
  .endpoint_query(
    "commitments",
    rlang::list2(...),
    page,
    page_size,
    all_pages,
    page_limit,
    base_url
  )
}

#' @rdname get_commitments
#' @export
obter_empenhos <- function(
    ...,
    pagina = 1L,
    tamanho_da_pagina = 50L,
    todas_paginas = FALSE,
    limite_paginas = Inf,
    base_url = .obrasgov_base_url()) {
  get_commitments(
    ...,
    page = pagina,
    page_size = tamanho_da_pagina,
    all_pages = todas_paginas,
    page_limit = limite_paginas,
    base_url = base_url
  )
}

#' Retrieve physical execution data
#'
#' @inheritParams get_projects
#' @param ... Named filters. See `list_filters("physical_execution")`.
#'
#' @return A tibble containing execution percentages, instruments, and dates.
#' @export
#' @family API resources
#' @examples
#' if (interactive()) {
#'   get_physical_execution(id_projeto_investimento = "134851.26-07")
#' }
get_physical_execution <- function(
    ...,
    page = 1L,
    page_size = 50L,
    all_pages = FALSE,
    page_limit = Inf,
    base_url = .obrasgov_base_url()) {
  .endpoint_query(
    "physical_execution",
    rlang::list2(...),
    page,
    page_size,
    all_pages,
    page_limit,
    base_url
  )
}

#' @rdname get_physical_execution
#' @export
obter_execucao_fisica <- function(
    ...,
    pagina = 1L,
    tamanho_da_pagina = 50L,
    todas_paginas = FALSE,
    limite_paginas = Inf,
    base_url = .obrasgov_base_url()) {
  get_physical_execution(
    ...,
    page = pagina,
    page_size = tamanho_da_pagina,
    all_pages = todas_paginas,
    page_limit = limite_paginas,
    base_url = base_url
  )
}

#' Retrieve contracts
#'
#' @inheritParams get_projects
#' @param ... Named filters. See `list_filters("contracts")`.
#'
#' @return A tibble containing contracts linked to infrastructure projects.
#' @export
#' @family API resources
#' @examples
#' if (interactive()) {
#'   get_contracts(id_projeto_investimento = "134851.26-07")
#' }
get_contracts <- function(
    ...,
    page = 1L,
    page_size = 50L,
    all_pages = FALSE,
    page_limit = Inf,
    base_url = .obrasgov_base_url()) {
  .endpoint_query(
    "contracts",
    rlang::list2(...),
    page,
    page_size,
    all_pages,
    page_limit,
    base_url
  )
}

#' @rdname get_contracts
#' @export
obter_contratos <- function(
    ...,
    pagina = 1L,
    tamanho_da_pagina = 50L,
    todas_paginas = FALSE,
    limite_paginas = Inf,
    base_url = .obrasgov_base_url()) {
  get_contracts(
    ...,
    page = pagina,
    page_size = tamanho_da_pagina,
    all_pages = todas_paginas,
    page_limit = limite_paginas,
    base_url = base_url
  )
}

#' Retrieve geometries
#'
#' @inheritParams get_projects
#' @param ... Named filters. See `list_filters("geometries")`.
#'
#' @return A tibble containing geometries and territorial identifiers.
#' @export
#' @family API resources
#' @examples
#' if (interactive()) {
#'   get_geometries(sg_uf = "PE", page_size = 10)
#' }
get_geometries <- function(
    ...,
    page = 1L,
    page_size = 50L,
    all_pages = FALSE,
    page_limit = Inf,
    base_url = .obrasgov_base_url()) {
  .endpoint_query(
    "geometries",
    rlang::list2(...),
    page,
    page_size,
    all_pages,
    page_limit,
    base_url
  )
}

#' @rdname get_geometries
#' @export
obter_geometrias <- function(
    ...,
    pagina = 1L,
    tamanho_da_pagina = 50L,
    todas_paginas = FALSE,
    limite_paginas = Inf,
    base_url = .obrasgov_base_url()) {
  get_geometries(
    ...,
    page = pagina,
    page_size = tamanho_da_pagina,
    all_pages = todas_paginas,
    page_limit = limite_paginas,
    base_url = base_url
  )
}

#' Retrieve project status histories
#'
#' Retrieves the histories of cancelled or suspended projects, including
#' reasons and remedial actions.
#'
#' @inheritParams get_projects
#' @param ... Named filters. See `list_filters("status_history")`.
#'
#' @return A tibble containing project status histories.
#' @export
#' @family API resources
#' @examples
#' if (interactive()) {
#'   get_status_history(id_projeto_investimento = "134851.26-07")
#' }
get_status_history <- function(
    ...,
    page = 1L,
    page_size = 50L,
    all_pages = FALSE,
    page_limit = Inf,
    base_url = .obrasgov_base_url()) {
  .endpoint_query(
    "status_history",
    rlang::list2(...),
    page,
    page_size,
    all_pages,
    page_limit,
    base_url
  )
}

#' @rdname get_status_history
#' @export
obter_historico_situacao <- function(
    ...,
    pagina = 1L,
    tamanho_da_pagina = 50L,
    todas_paginas = FALSE,
    limite_paginas = Inf,
    base_url = .obrasgov_base_url()) {
  get_status_history(
    ...,
    page = pagina,
    page_size = tamanho_da_pagina,
    all_pages = todas_paginas,
    page_limit = limite_paginas,
    base_url = base_url
  )
}

#' Retrieve feasibility studies
#'
#' @inheritParams get_projects
#' @param ... Named filters. See `list_filters("feasibility_studies")`.
#'
#' @return A tibble containing feasibility studies linked to projects.
#' @export
#' @family API resources
#' @examples
#' if (interactive()) {
#'   get_feasibility_studies(id_projeto_investimento = "134851.26-07")
#' }
get_feasibility_studies <- function(
    ...,
    page = 1L,
    page_size = 50L,
    all_pages = FALSE,
    page_limit = Inf,
    base_url = .obrasgov_base_url()) {
  .endpoint_query(
    "feasibility_studies",
    rlang::list2(...),
    page,
    page_size,
    all_pages,
    page_limit,
    base_url
  )
}

#' @rdname get_feasibility_studies
#' @export
obter_estudos_viabilidade <- function(
    ...,
    pagina = 1L,
    tamanho_da_pagina = 50L,
    todas_paginas = FALSE,
    limite_paginas = Inf,
    base_url = .obrasgov_base_url()) {
  get_feasibility_studies(
    ...,
    page = pagina,
    page_size = tamanho_da_pagina,
    all_pages = todas_paginas,
    page_limit = limite_paginas,
    base_url = base_url
  )
}

#' Retrieve the data update timestamp
#'
#' @param base_url HTTPS base URL. By default, uses the `obrasgov.base_url`
#'   option or the official API environment.
#'
#' @return A `POSIXct` value in the UTC time zone.
#' @export
#' @family API resources
#' @examples
#' if (interactive()) {
#'   get_last_update()
#' }
get_last_update <- function(base_url = .obrasgov_base_url()) {
  body <- .obrasgov_perform("data-atualizacao", base_url = base_url)
  value <- body$data_ultima_atualizacao

  if (!is.character(value) || length(value) != 1L) {
    cli::cli_abort(
      "The data update response has an unexpected format.",
      class = "obrasgov_response_error"
    )
  }

  as.POSIXct(value, format = "%Y-%m-%dT%H:%M:%S", tz = "UTC")
}

#' @rdname get_last_update
#' @export
obter_data_atualizacao <- get_last_update

.endpoint_query <- function(
    resource,
    filters,
    page,
    page_size,
    all_pages,
    page_limit,
    base_url) {
  .obrasgov_get_paginated(
    resource = resource,
    filters = filters,
    page = page,
    page_size = page_size,
    all_pages = all_pages,
    page_limit = page_limit,
    base_url = base_url
  )
}
