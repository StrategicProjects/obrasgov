test_that("multiple pages are combined into a typed tibble", {
  requests <- list()
  mock <- function(req) {
    requests[[length(requests) + 1L]] <<- req
    url <- httr2::req_get_url(req)

    if (grepl("pagina=1", url, fixed = TRUE)) {
      return(mock_paginated_response(
        data = list(list(
          id_projeto_investimento = "1.00-00",
          dt_cadastro = "2026-01-02",
          executores = list(
            list(nome = "Orgao A"),
            list(nome = "Orgao B")
          )
        )),
        total_pages = 2L
      ))
    }

    mock_paginated_response(
      data = list(list(
        id_projeto_investimento = "2.00-00",
        dt_cadastro = "2026-02-03",
        executores = list()
      )),
      total_pages = 2L
    )
  }
  httr2::local_mocked_responses(mock)

  result <- get_projects(
    uf_principal = "PE",
    page_size = 1L,
    all_pages = TRUE,
    base_url = "https://example.test/obras"
  )

  expect_s3_class(result, "tbl_df")
  expect_equal(nrow(result), 2L)
  expect_s3_class(result$dt_cadastro, "Date")
  expect_type(result$executores, "list")
  expect_length(result$executores[[1]], 2L)
  expect_length(requests, 2L)

  metadata <- result_metadata(result)
  expect_equal(metadata$total_pages, 2L)
  expect_equal(metadata$pages_retrieved, 2L)
  expect_equal(metadata$resource, "projects")
})

test_that("page limits are respected", {
  count <- 0L
  mock <- function(req) {
    count <<- count + 1L
    mock_paginated_response(
      data = list(list(id_projeto_investimento = as.character(count))),
      total_pages = 10L
    )
  }
  httr2::local_mocked_responses(mock)

  result <- get_projects(
    all_pages = TRUE,
    page_limit = 3L,
    base_url = "https://example.test/obras"
  )

  expect_equal(nrow(result), 3L)
  expect_equal(count, 3L)
  expect_equal(result_metadata(result)$pages_retrieved, 3L)
})

test_that("empty API pages return an empty tibble", {
  httr2::local_mocked_responses(list(mock_paginated_response()))

  result <- get_contracts(base_url = "https://example.test/obras")

  expect_s3_class(result, "tbl_df")
  expect_equal(nrow(result), 0L)
  expect_equal(result_metadata(result)$total_items, 0L)
})

test_that("Portuguese pagination arguments remain compatible", {
  httr2::local_mocked_responses(list(mock_paginated_response()))

  result <- obter_projetos(
    pagina = 1L,
    tamanho_da_pagina = 25L,
    todas_paginas = FALSE,
    limite_paginas = 1L,
    base_url = "https://example.test/obras"
  )

  expect_equal(result_metadata(result)$page_size, 25L)
})
