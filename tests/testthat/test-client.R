test_that("requests opt in to HTTP/2 over TLS", {
  request <- obrasgovr:::.obrasgovr_request(
    "data-atualizacao",
    base_url = "https://example.test/obras"
  )

  expect_identical(request$url, "https://example.test/obras/data-atualizacao")
  expect_identical(request$options$http_version, 4L)
  expect_match(request$options$useragent, "^obrasgovr/")
  expect_identical(request$policies$throttle_realm, "obrasgovr")
  expect_identical(request$policies$retry_max_tries, 4)
})

test_that("requests are throttled to 60 per minute", {
  obrasgovr:::.obrasgovr_request(
    "data-atualizacao",
    base_url = "https://example.test/obras"
  )

  status <- httr2::throttle_status()
  realm <- status[status$realm == "obrasgovr", , drop = FALSE]

  expect_identical(nrow(realm), 1L)
  # The bucket holds 60 requests per minute. Passing `rate = 60` instead of
  # `capacity = 60` would allow 60 * fill_time_s = 3600 requests per minute.
  expect_lte(realm$tokens, 60)
})

test_that("only HTTPS base URLs are accepted", {
  expect_error(
    get_last_update(base_url = "http://example.test"),
    class = "obrasgovr_url_error"
  )
  expect_error(
    get_last_update(base_url = NA_character_),
    class = "obrasgovr_url_error"
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
  recorded <- local_recorded_requests()

  get_projects(
    dt_cadastro = as.Date("2026-07-15"),
    base_url = "https://example.test/obras"
  )

  expect_match(
    httr2::req_get_url(recorded$requests[[1]]),
    "dt_cadastro=2026-07-15"
  )
})

test_that("non-finite and oversized pagination arguments are rejected", {
  # `Inf %% 1` is NaN, so the check itself errored; and a value above the
  # integer range became NA when coerced, corrupting the query.
  expect_error(get_projects(page = Inf), "positive integer")
  expect_error(get_projects(page = NaN), "positive integer")
  expect_error(get_projects(page = 2147483648), "positive integer")
  expect_error(get_projects(page_size = Inf), "positive integer")
  expect_error(
    get_projects(all_pages = TRUE, page_limit = 2147483648),
    "positive integer"
  )
})
