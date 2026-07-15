test_that("HTTP errors expose API validation messages", {
  response <- httr2::response_json(
    status_code = 422L,
    body = list(detail = list(list(msg = "Valor invalido")))
  )
  httr2::local_mocked_responses(list(response))

  expect_error(
    get_projects(base_url = "https://example.test/obras"),
    "Valor invalido",
    class = "obrasgov_http_error"
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
    class = "obrasgov_response_error"
  )
})

test_that("malformed records fail clearly", {
  response <- mock_paginated_response(data = list("not-a-record"))
  httr2::local_mocked_responses(list(response))

  expect_error(
    get_projects(base_url = "https://example.test/obras"),
    "record.*unexpected format",
    class = "obrasgov_response_error"
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
    class = "obrasgov_response_error"
  )
})
