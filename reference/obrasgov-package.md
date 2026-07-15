# obrasgov: acesso aos dados abertos do ObrasGov

O pacote `obrasgov` fornece uma interface moderna e tipada para a API de
dados abertos do ObrasGov. Cada recurso da API é representado por uma
função que retorna um
[`tibble::tibble()`](https://tibble.tidyverse.org/reference/tibble.html),
preservando relações aninhadas em colunas de lista.

## Details

As requisições usam HTTP/2 sobre TLS quando suportado pelo `libcurl`,
com tentativas automáticas para falhas transitórias e limitação
responsável da taxa de acesso. A API não exige autenticação.

## Opções

- `obrasgov.base_url`: URL base alternativa para a API.

- `obrasgov.timeout`: tempo limite de cada requisição, em segundos.

- `obrasgov.user_agent`: identificador HTTP alternativo.

## See also

[Documentacao oficial da
API](https://api-publica.obrasgov.gestao.gov.br/obras/docs)

## Author

**Maintainer**: Andre Leite <leite@castlab.org>

Authors:

- Andre Leite <leite@castlab.org>

- Felipe Ferreira <felipe.ferreira@semobi.pe.gov.br>

- Hugo Vasconcelos <hugo.vasconcelos@ufpe.br>

- Diogo Bezerra <diogo.bezerra@ufpe.br>

- Roger Azevedo <roger.azevedo@tpfe.com.br>
