test_that("multiple pages are combined into a typed tibble", {
  # Branch on the call index, not the URL: this test sets `page_size = 1`, so
  # matching "pagina=1" also matches "tamanho_da_pagina=1" and served the
  # first page's body for both requests.
  recorded <- local_recorded_requests(function(req, n) {
    if (n == 1L) {
      return(mock_paginated_response(
        data = list(list(
          id_projeto_investimento = "1.00-00",
          dt_cadastro = "2026-01-02",
          executores = list(
            list(nome = "Orgao A"),
            list(nome = "Orgao B")
          )
        )),
        total_pages = 2L,
        page_number = 1L
      ))
    }

    mock_paginated_response(
      data = list(list(
        id_projeto_investimento = "2.00-00",
        dt_cadastro = "2026-02-03",
        executores = list()
      )),
      total_pages = 2L,
      page_number = 2L
    )
  })

  result <- get_projects(
    uf_principal = "PE",
    page_size = 1L,
    all_pages = TRUE,
    base_url = "https://example.test/obras"
  )

  expect_s3_class(result, "tbl_df")
  expect_identical(nrow(result), 2L)
  expect_s3_class(result$dt_cadastro, "Date")
  expect_type(result$executores, "list")
  expect_length(result$executores[[1]], 2L)
  expect_length(recorded$requests, 2L)

  metadata <- result_metadata(result)
  expect_identical(metadata$total_pages, 2L)
  expect_identical(metadata$pages_retrieved, 2L)
  expect_identical(metadata$resource, "projects")
})

test_that("page limits are respected", {
  recorded <- local_recorded_requests(function(req, n) {
    mock_paginated_response(
      data = list(list(id_projeto_investimento = as.character(n))),
      total_pages = 10L,
      page_number = n
    )
  })

  result <- get_projects(
    all_pages = TRUE,
    page_limit = 3L,
    base_url = "https://example.test/obras"
  )

  expect_identical(nrow(result), 3L)
  expect_length(recorded$requests, 3L)
  expect_identical(result_metadata(result)$pages_retrieved, 3L)
})

test_that("empty API pages return an empty tibble", {
  httr2::local_mocked_responses(list(mock_paginated_response()))

  result <- get_contracts(base_url = "https://example.test/obras")

  expect_s3_class(result, "tbl_df")
  expect_identical(nrow(result), 0L)
  expect_identical(result_metadata(result)$total_items, 0L)
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

  expect_identical(result_metadata(result)$page_size, 25L)
})

test_that("a page limit of one retrieves exactly one page", {
  # `seq.int(page + 1, last_page)` counts backwards when the budget is spent,
  # which fetched page 2 and then page 1 again.
  recorded <- local_recorded_requests(function(req, n) {
    mock_paginated_response(
      data = list(list(id_projeto_investimento = as.character(n))),
      total_pages = 10L
    )
  })

  result <- get_projects(
    all_pages = TRUE,
    page_limit = 1,
    base_url = "https://example.test/obras"
  )

  expect_length(recorded$requests, 1L)
  expect_identical(nrow(result), 1L)
  expect_identical(result_metadata(result)$pages_retrieved, 1L)
})

test_that("responses without pagination totals are rejected", {
  # Defaulting a missing total to zero stopped collection after the first page
  # and reported the truncated result as complete.
  httr2::local_mocked_responses(list(httr2::response_json(
    status_code = 200L,
    body = list(data = list(list(id_projeto_investimento = "1.00-00")))
  )))

  expect_error(
    get_projects(all_pages = TRUE, base_url = "https://example.test/obras"),
    class = "obrasgovr_response_error"
  )
})

test_that("empty nested arrays stay list-columns", {
  httr2::local_mocked_responses(list(mock_paginated_response(
    data = list(list(id_projeto_investimento = "1.00-00", executores = list()))
  )))

  result <- get_projects(base_url = "https://example.test/obras")

  expect_type(result$executores, "list")
  expect_length(result$executores[[1]], 0L)
})

test_that("dates declared by the resource are typed regardless of prefix", {
  httr2::local_mocked_responses(list(mock_paginated_response(
    data = list(list(
      vigencia_inicio_contrato = "2026-01-01",
      data_assinatura_contrato = "2026-01-02"
    ))
  )))

  result <- get_contracts(base_url = "https://example.test/obras")

  expect_s3_class(result$vigencia_inicio_contrato, "Date")
  expect_s3_class(result$data_assinatura_contrato, "Date")
})

test_that("JSON null becomes a missing scalar, not a list cell", {
  httr2::local_mocked_responses(list(mock_json_response(
    '{"data":[{"vigencia_fim_contrato":"2026-12-31"},
              {"vigencia_fim_contrato":null}],
      "total_pages":1,"total_items":2}'
  )))

  result <- get_contracts(base_url = "https://example.test/obras")

  expect_s3_class(result$vigencia_fim_contrato, "Date")
  expect_true(is.na(result$vigencia_fim_contrato[2]))
})

test_that("unusable pagination totals are rejected", {
  # `as.integer()` would truncate 1.5 to 1 and turn Inf or an out-of-range
  # total into NA, breaking page arithmetic with an unclassified error.
  for (total in c("1.5", "1e999", "9999999999")) {
    httr2::local_mocked_responses(list(mock_json_response(sprintf(
      '{"data":[{"id":"A"}],"total_pages":%s,"total_items":1}', total
    ))))

    expect_error(
      get_projects(all_pages = TRUE, base_url = "https://example.test/obras"),
      class = "obrasgovr_response_error"
    )
  }
})

test_that("the largest accepted page limit does not overflow", {
  # `page + as.integer(page_limit)` overflowed to NA at the documented maximum.
  page <- 0L
  httr2::local_mocked_responses(function(req) {
    page <<- page + 1L
    mock_json_response(sprintf(
      '{"data":[{"id":"p%d"}],"total_pages":3,"total_items":3,
        "page_number":%d}',
      page, page
    ))
  })

  result <- get_projects(
    all_pages = TRUE,
    page_limit = .Machine$integer.max,
    base_url = "https://example.test/obras"
  )

  expect_identical(nrow(result), 3L)
})

test_that("a page that is not the one requested is rejected", {
  # A server answering page 2 with page 1 would otherwise be collected as new
  # data, duplicating records under the guise of a complete result.
  httr2::local_mocked_responses(function(req) {
    mock_json_response(
      '{"data":[{"id":"always-1"}],"total_pages":3,"total_items":3,
        "page_number":1}'
    )
  })

  expect_error(
    get_projects(all_pages = TRUE, base_url = "https://example.test/obras"),
    class = "obrasgovr_response_error"
  )
})

test_that("impossible calendar dates are kept rather than dropped", {
  # "2026-02-30" matches the ISO shape but is not a real date: `as.Date()`
  # errored on it outright when it was the only value present.
  httr2::local_mocked_responses(list(mock_json_response(
    '{"data":[{"dt_cadastro":"2026-02-30"}],"total_pages":1,"total_items":1}'
  )))

  result <- get_projects(base_url = "https://example.test/obras")

  expect_type(result$dt_cadastro, "character")
  expect_identical(result$dt_cadastro, "2026-02-30")
})

test_that("each collected page is actually requested from the API", {
  # Mutation-tested: hardcoding `pagina = 1L` in the query previously left the
  # whole suite green, because the fixtures branch on call order and nothing
  # asserted the query parameter.
  recorded <- local_recorded_requests(function(req, n) {
    mock_paginated_response(
      data = list(list(id_projeto_investimento = as.character(n))),
      total_pages = 3L,
      page_number = n
    )
  })

  get_projects(all_pages = TRUE, base_url = "https://example.test/obras")

  requested <- vapply(
    recorded$requests,
    function(req) {
      as.integer(httr2::url_parse(httr2::req_get_url(req))$query$pagina)
    },
    integer(1)
  )

  expect_identical(requested, 1:3)
})

test_that("a failure on a later page keeps its condition class", {
  # Mutation-tested: reverting `lapply()` to `purrr::map()` wraps the error in
  # `purrr_error_indexed`, and no test noticed. `expect_error(class=)` follows
  # parent conditions, so the class has to be inspected directly.
  page <- 0L
  httr2::local_mocked_responses(function(req) {
    page <<- page + 1L
    if (page == 1L) {
      return(mock_paginated_response(
        data = list(list(id_projeto_investimento = "1.00-00")),
        total_pages = 2L,
        page_number = 1L
      ))
    }
    mock_json_response('{"detail":"boom"}', status_code = 500L)
  })

  condition <- tryCatch(
    get_projects(all_pages = TRUE, base_url = "https://example.test/obras"),
    error = identity
  )

  expect_true(inherits(condition, "obrasgovr_http_error"))
  expect_false(inherits(condition, "purrr_error_indexed"))
})

test_that("a malformed record keeps its condition class", {
  httr2::local_mocked_responses(list(mock_json_response(
    '{"data":[{"id":"ok"},"bad"],"total_pages":1,"total_items":2,
      "page_number":1}'
  )))

  condition <- tryCatch(
    get_projects(base_url = "https://example.test/obras"),
    error = identity
  )

  expect_true(inherits(condition, "obrasgovr_response_error"))
  expect_false(inherits(condition, "purrr_error_indexed"))
})

test_that("pagination totals that contradict the payload are rejected", {
  httr2::local_mocked_responses(list(mock_json_response(
    '{"data":[{"id":"A"}],"total_pages":0,"total_items":100,"page_number":1}'
  )))

  expect_error(
    get_projects(all_pages = TRUE, base_url = "https://example.test/obras"),
    class = "obrasgovr_response_error"
  )
})

test_that("an unusable page marker is rejected", {
  for (marker in c('"1"', "1.9", "1e999")) {
    httr2::local_mocked_responses(list(mock_json_response(sprintf(
      '{"data":[{"id":"A"}],"total_pages":1,"total_items":1,"page_number":%s}',
      marker
    ))))

    expect_error(
      suppressWarnings(get_projects(base_url = "https://example.test/obras")),
      class = "obrasgovr_response_error"
    )
  }
})

test_that("dates keep their text when the value is not a bare ISO date", {
  # `as.Date(x, format = "%Y-%m-%d")` ignores trailing text, so a timestamp
  # would silently lose its time while appearing successfully typed.
  for (value in c("2026-01-02T03:04:05", "2026-01-02junk", "2026-1-2")) {
    httr2::local_mocked_responses(list(mock_json_response(sprintf(
      '{"data":[{"dt_cadastro":"%s"}],"total_pages":1,"total_items":1,
        "page_number":1}', value
    ))))

    result <- get_projects(base_url = "https://example.test/obras")
    expect_identical(result$dt_cadastro, value)
  }
})

test_that("an all-missing declared date field is still typed", {
  # Otherwise the same documented column is logical, character or Date
  # depending on what a given page happens to contain.
  httr2::local_mocked_responses(list(mock_json_response(
    '{"data":[{"vigencia_fim_contrato":null},{"vigencia_fim_contrato":null}],
      "total_pages":1,"total_items":2,"page_number":1}'
  )))

  result <- get_contracts(base_url = "https://example.test/obras")

  expect_s3_class(result$vigencia_fim_contrato, "Date")
  expect_true(all(is.na(result$vigencia_fim_contrato)))
})
