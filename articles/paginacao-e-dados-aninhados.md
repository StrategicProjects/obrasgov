# Paginacao e dados aninhados

``` r

library(obrasgov)
```

## Paginacao segura

As funcoes retornam somente uma pagina por padrao. Essa escolha impede
que uma consulta ampla dispare milhares de requisicoes sem intencao do
usuario.

``` r

projetos <- obter_projetos(
  uf_principal = "PE",
  pagina = 1,
  tamanho_da_pagina = 200
)

obrasgov_metadados(projetos)
```

Use `todas_paginas = TRUE` para reunir paginas sucessivas. O argumento
`limite_paginas` torna o custo da coleta explicito e facilita a criacao
de amostras reprodutiveis.

``` r

projetos <- obter_projetos(
  uf_principal = "PE",
  todas_paginas = TRUE,
  limite_paginas = 10,
  tamanho_da_pagina = 200
)
```

Defina `limite_paginas = Inf` somente quando houver necessidade de
coletar todo o resultado. A API e consultada sequencialmente e o limite
de taxa continua ativo.

## Relacoes aninhadas

Um projeto pode possuir varios executores, tomadores, repassadores,
eixos, fontes de recurso e geometrias. Essas relacoes nao sao reduzidas
ao primeiro item: o pacote as preserva em list-columns.

``` r

names(projetos)
projetos$executores[[1]]

executores_primeiro_projeto <- purrr::list_rbind(
  projetos$executores[[1]]
)
```

Essa representacao evita duplicar todas as colunas do projeto e permite
que o usuario escolha quando e como normalizar cada relacao.

## Reprodutibilidade

Registre os filtros, os metadados de paginacao e a data da fonte junto
ao resultado.

``` r

atributos <- list(
  consulta = list(uf_principal = "PE"),
  paginacao = obrasgov_metadados(projetos),
  fonte_atualizada_em = obter_data_atualizacao()
)

saveRDS(list(dados = projetos, atributos = atributos), "projetos-pe.rds")
```
