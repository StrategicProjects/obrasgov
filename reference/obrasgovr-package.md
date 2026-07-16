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
([ORCID](https://orcid.org/0000-0002-4718-9766))

Authors:

- Andre Leite <leite@castlab.org>
  ([ORCID](https://orcid.org/0000-0002-4718-9766))

- Marcos Wasiliew <marcos.wasiliew@sepe.pe.gov.br>

- Hugo Vasconcelos <hugo.vasconcelos@ufpe.br>
  ([ORCID](https://orcid.org/0000-0001-6249-0920))

- Carlos Amorim <carlos.agaf@ufpe.br>
  ([ORCID](https://orcid.org/0000-0001-6315-8305))

- Diogo Bezerra <diogo.bezerra@ufpe.br>
  ([ORCID](https://orcid.org/0000-0002-1216-8674))
