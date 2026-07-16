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

test_that("timestamps with trailing junk are rejected", {
  # `strptime()` ignores trailing characters, so a truncated offset or plain
  # junk would parse as a naive UTC timestamp.
  for (value in c(
    "2026-07-15T00:00:00-03",
    "2026-07-15T00:00:00junk",
    "2026-02-30T00:00:00"
  )) {
    httr2::local_mocked_responses(list(httr2::response_json(
      status_code = 200L,
      body = list(data_ultima_atualizacao = value)
    )))

    expect_error(
      get_last_update(base_url = "https://example.test/obras"),
      class = "obrasgovr_response_error"
    )
  }
})

test_that("well-formed timestamp shapes are accepted", {
  expected <- c(
    "2026-07-15T00:00:00" = "2026-07-15 00:00:00",
    "2026-07-15T00:00:00Z" = "2026-07-15 00:00:00",
    "2026-07-15T00:00:00-03:00" = "2026-07-15 03:00:00",
    "2026-07-15T00:00:00-0300" = "2026-07-15 03:00:00"
  )

  for (value in names(expected)) {
    httr2::local_mocked_responses(list(httr2::response_json(
      status_code = 200L,
      body = list(data_ultima_atualizacao = value)
    )))

    result <- get_last_update(base_url = "https://example.test/obras")
    expect_identical(
      format(result, "%Y-%m-%d %H:%M:%S", tz = "UTC"),
      unname(expected[value])
    )
  }
})

test_that("HTTP 400 is the error boundary", {
  # 399 must pass through and 400 must abort: the comparison is `< 400L`.
  httr2::local_mocked_responses(list(httr2::response_json(
    status_code = 400L,
    body = list(detail = "bad request")
  )))
  expect_error(
    get_projects(base_url = "https://example.test/obras"),
    class = "obrasgovr_http_400"
  )
})

test_that("timestamps with leading junk are rejected", {
  httr2::local_mocked_responses(list(httr2::response_json(
    status_code = 200L,
    body = list(data_ultima_atualizacao = "junk2026-07-15T00:00:00")
  )))

  expect_error(
    get_last_update(base_url = "https://example.test/obras"),
    class = "obrasgovr_response_error"
  )
})
