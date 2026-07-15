# Introducao ao obrasgov

O `obrasgov` acessa a API publica do Cadastro Integrado de Projetos de
Investimentos do Governo Federal. O pacote foi desenhado para pesquisas
reprodutiveis: os filtros sao validados localmente, a paginacao e
explicita e os resultados usam tipos previsiveis.

``` r

library(obrasgov)
```

## Recursos

Cada endpoint publico da API possui uma funcao correspondente.

``` r

obrasgov_recursos()
#> # A tibble: 8 × 4
#>   recurso             funcao                    endpoint                paginado
#>   <chr>               <chr>                     <chr>                   <lgl>   
#> 1 projetos            obter_projetos            projeto-investimento    TRUE    
#> 2 empenhos            obter_empenhos            empenho                 TRUE    
#> 3 execucao_fisica     obter_execucao_fisica     execucao-fisica         TRUE    
#> 4 contratos           obter_contratos           contrato                TRUE    
#> 5 geometrias          obter_geometrias          geometria               TRUE    
#> 6 historico_situacao  obter_historico_situacao  historico-situacao-can… TRUE    
#> 7 estudos_viabilidade obter_estudos_viabilidade estudo-viabilidade      TRUE    
#> 8 data_atualizacao    obter_data_atualizacao    data-atualizacao        FALSE
```

Os filtros sao passados por nome em `...`. A funcao
[`obrasgov_filtros()`](https://strategicprojects.github.io/obrasgov/reference/obrasgov_filtros.md)
evita que seja necessario memorizar os parametros de cada endpoint.

``` r

obrasgov_filtros("execucao_fisica")
#> # A tibble: 9 × 3
#>   filtro                     tipo      valores_permitidos
#>   <chr>                      <chr>     <list>            
#> 1 id_projeto_investimento    character <chr [0]>         
#> 2 percentual_execucao_fisica numeric   <chr [0]>         
#> 3 dt_inicial_execucao        Date      <chr [0]>         
#> 4 dt_final_execucao          Date      <chr [0]>         
#> 5 tipo_instrumento           character <chr [0]>         
#> 6 tipo_forma_execucao        character <chr [0]>         
#> 7 dt_criacao_instrumento     Date      <chr [0]>         
#> 8 dt_cadastro_execucao       Date      <chr [0]>         
#> 9 dt_atualizacao_execucao    Date      <chr [0]>
```

## Consultas

A consulta abaixo retorna a primeira pagina de projetos de Pernambuco.
Ela nao e executada durante a construcao da vignette para que a
instalacao do pacote nao dependa da disponibilidade de um servico
externo.

``` r

projetos <- obter_projetos(
  uf_principal = "PE",
  tamanho_da_pagina = 100
)

projetos
```

Os recursos podem ser relacionados pelo campo `id_projeto_investimento`.

``` r

id <- projetos$id_projeto_investimento[[1]]

execucao <- obter_execucao_fisica(id_projeto_investimento = id)
contratos <- obter_contratos(id_projeto_investimento = id)
empenhos <- obter_empenhos(id_projeto_investimento = id)
```

## Atualizacao da fonte

A API publica informa a data da carga mais recente. Isso permite
registrar a versao temporal da fonte em scripts e relatorios.

``` r

obter_data_atualizacao()
```

## Configuracao

O pacote nao exige autenticacao. Tres opcoes permitem adaptar o
transporte sem alterar cada chamada:

``` r

options(
  obrasgov.base_url = "https://api-publica.obrasgov.gestao.gov.br/obras",
  obrasgov.timeout = 30,
  obrasgov.user_agent = "meu-projeto/1.0 (contato@example.org)"
)
```

Por padrao, o cliente solicita HTTP/2 sobre TLS, repete falhas
transitorias e limita o acesso a 60 requisicoes por minuto.
