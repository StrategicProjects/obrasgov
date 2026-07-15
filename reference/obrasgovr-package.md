# obrasgovr: Access ObrasGov open data

`obrasgovr` provides a modern, typed interface to the ObrasGov open data
API. Each API resource is represented by a function that returns a
[`tibble::tibble()`](https://tibble.tidyverse.org/reference/tibble.html),
preserving nested relationships in list-columns.

## Details

Requests use HTTP/2 over TLS when supported by `libcurl`, with automatic
retries for transient failures and responsible request throttling. The
API does not require authentication.

## Options

- `obrasgovr.base_url`: alternative API base URL.

- `obrasgovr.timeout`: timeout for each request, in seconds.

- `obrasgovr.user_agent`: alternative HTTP user agent.

## See also

[Official API
documentation](https://api-publica.obrasgov.gestao.gov.br/obras/docs)

## Author

**Maintainer**: Andre Leite <leite@castlab.org>

Authors:

- Andre Leite <leite@castlab.org>

- Felipe Ferreira <felipe.ferreira@semobi.pe.gov.br>

- Hugo Vasconcelos <hugo.vasconcelos@ufpe.br>

- Diogo Bezerra <diogo.bezerra@ufpe.br>

- Roger Azevedo <roger.azevedo@tpfe.com.br>
