test_that("requests opt in to HTTP/2 over TLS", {
  request <- obrasgov:::.obrasgov_request(
    "data-atualizacao",
    base_url = "https://example.test/obras"
  )

  expect_identical(request$url, "https://example.test/obras/data-atualizacao")
  expect_identical(request$options$http_version, 4L)
  expect_match(request$options$useragent, "^obrasgov/")
  expect_identical(request$policies$throttle_realm, "obrasgov")
  expect_identical(request$policies$retry_max_tries, 4)
})

test_that("only HTTPS base URLs are accepted", {
  expect_error(
    get_last_update(base_url = "http://example.test"),
    class = "obrasgov_url_error"
  )
  expect_error(
    get_last_update(base_url = NA_character_),
    class = "obrasgov_url_error"
  )
})

test_that("pagination arguments are validated locally", {
  expect_error(get_projects(page = 0), "positive integer")
  expect_error(get_projects(page_size = 201), "greater than 200")
  expect_error(get_projects(all_pages = NA), "TRUE.*FALSE")
  expect_error(get_projects(page_limit = 0), "positive integer")
})

test_that("filters are named and known", {
  expect_error(get_projects("PE"), "must be named")
  expect_error(get_projects(uf = "PE"), "Unknown filter")
  expect_error(get_projects(uf_principal = c("PE", "PB")), "one non-missing")
  expect_error(get_projects(uf_principal = NA_character_), "one non-missing")
})

test_that("Date filters are serialized in ISO format", {
  seen <- new.env(parent = emptyenv())
  mock <- function(req) {
    seen$request <- req
    mock_paginated_response()
  }
  httr2::local_mocked_responses(mock)

  get_projects(
    dt_cadastro = as.Date("2026-07-15"),
    base_url = "https://example.test/obras"
  )

  expect_match(httr2::req_get_url(seen$request), "dt_cadastro=2026-07-15")
})
