# Consultar a data de atualizacao dos dados

Consultar a data de atualizacao dos dados

## Usage

``` r
obter_data_atualizacao(base_url = .obrasgov_base_url())
```

## Arguments

- base_url:

  URL base HTTPS. Por padrao, usa a opcao `obrasgov.base_url` ou o
  ambiente oficial da API.

## Value

Um valor `POSIXct` no fuso horario UTC.

## See also

Other recursos:
[`obter_contratos()`](https://strategicprojects.github.io/obrasgov/reference/obter_contratos.md),
[`obter_empenhos()`](https://strategicprojects.github.io/obrasgov/reference/obter_empenhos.md),
[`obter_estudos_viabilidade()`](https://strategicprojects.github.io/obrasgov/reference/obter_estudos_viabilidade.md),
[`obter_execucao_fisica()`](https://strategicprojects.github.io/obrasgov/reference/obter_execucao_fisica.md),
[`obter_geometrias()`](https://strategicprojects.github.io/obrasgov/reference/obter_geometrias.md),
[`obter_historico_situacao()`](https://strategicprojects.github.io/obrasgov/reference/obter_historico_situacao.md),
[`obter_projetos()`](https://strategicprojects.github.io/obrasgov/reference/obter_projetos.md)

## Examples

``` r
if (interactive()) {
  obter_data_atualizacao()
}
```
