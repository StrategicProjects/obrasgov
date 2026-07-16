test_that("HTTP errors expose API validation messages", {
  response <- httr2::response_json(
    status_code = 422L,
    body = list(detail = list(list(msg = "Valor invalido")))
  )
  httr2::local_mocked_responses(list(response))

  expect_error(
    get_projects(base_url = "https://example.test/obras"),
    "Valor invalido",
    class = "obrasgovr_http_error"
  )
})

test_that("malformed paginated responses fail clearly", {
  response <- httr2::response_json(
    status_code = 200L,
    body = list(total_pages = 1L)
  )
  httr2::local_mocked_responses(list(response))

  expect_error(
    get_projects(base_url = "https://example.test/obras"),
    "unexpected format",
    class = "obrasgovr_response_error"
  )
})

test_that("malformed records fail clearly", {
  response <- mock_paginated_response(data = list("not-a-record"))
  httr2::local_mocked_responses(list(response))

  expect_error(
    get_projects(base_url = "https://example.test/obras"),
    "record.*unexpected format",
    class = "obrasgovr_response_error"
  )
})

test_that("malformed update timestamps fail clearly", {
  response <- httr2::response_json(
    status_code = 200L,
    body = list(updated = "today")
  )
  httr2::local_mocked_responses(list(response))

  expect_error(
    get_last_update(base_url = "https://example.test/obras"),
    "unexpected format",
    class = "obrasgovr_response_error"
  )
})

test_that("unparseable update timestamps are rejected", {
  # `as.POSIXct()` returns NA for junk rather than erroring, so the result was
  # handed back as a missing value.
  httr2::local_mocked_responses(list(httr2::response_json(
    status_code = 200L,
    body = list(data_ultima_atualizacao = "today")
  )))

  expect_error(
    get_last_update(base_url = "https://example.test/obras"),
    class = "obrasgovr_response_error"
  )
})

test_that("update timestamps honour a UTC offset", {
  # `strptime()` ignores trailing characters, so an offset was silently dropped
  # and the timestamp read as if it were UTC.
  httr2::local_mocked_responses(list(httr2::response_json(
    status_code = 200L,
    body = list(data_ultima_atualizacao = "2026-07-15T00:00:00-0300")
  )))

  result <- get_last_update(base_url = "https://example.test/obras")

  expect_identical(format(result, tz = "UTC"), "2026-07-15 03:00:00")
})

test_that("JSON bodies that are not objects still report the HTTP status", {
  # `body$detail` on an atomic value errored, masking the status code.
  httr2::local_mocked_responses(list(
    httr2::response_json(status_code = 500L, body = "maintenance")
  ))

  expect_error(
    get_projects(base_url = "https://example.test/obras"),
    class = "obrasgovr_http_error"
  )
})
