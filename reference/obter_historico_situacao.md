# Consultar historico de situacoes

Recupera historicos de projetos cancelados ou paralisados e suas
justificativas e tratativas.

## Usage

``` r
obter_historico_situacao(
  ...,
  pagina = 1L,
  tamanho_da_pagina = 50L,
  todas_paginas = FALSE,
  limite_paginas = Inf,
  base_url = .obrasgov_base_url()
)
```

## Arguments

- ...:

  Filtros nomeados. Consulte `obrasgov_filtros("historico_situacao")`.

- pagina:

  Pagina inicial, a partir de 1.

- tamanho_da_pagina:

  Numero de registros por pagina, entre 1 e 200.

- todas_paginas:

  Se `TRUE`, coleta paginas sucessivas a partir de `pagina`.

- limite_paginas:

  Limite de paginas coletadas quando `todas_paginas` e `TRUE`. Use `Inf`
  para coletar todas as paginas disponiveis.

- base_url:

  URL base HTTPS. Por padrao, usa a opcao `obrasgov.base_url` ou o
  ambiente oficial da API.

## Value

Um tibble com historicos de situacao.

## See also

Other recursos:
[`obter_contratos()`](https://strategicprojects.github.io/obrasgov/reference/obter_contratos.md),
[`obter_data_atualizacao()`](https://strategicprojects.github.io/obrasgov/reference/obter_data_atualizacao.md),
[`obter_empenhos()`](https://strategicprojects.github.io/obrasgov/reference/obter_empenhos.md),
[`obter_estudos_viabilidade()`](https://strategicprojects.github.io/obrasgov/reference/obter_estudos_viabilidade.md),
[`obter_execucao_fisica()`](https://strategicprojects.github.io/obrasgov/reference/obter_execucao_fisica.md),
[`obter_geometrias()`](https://strategicprojects.github.io/obrasgov/reference/obter_geometrias.md),
[`obter_projetos()`](https://strategicprojects.github.io/obrasgov/reference/obter_projetos.md)

## Examples

``` r
if (interactive()) {
  obter_historico_situacao(
    id_projeto_investimento = "134851.26-07"
  )
}
```
