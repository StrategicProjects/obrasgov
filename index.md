# obrasgov

O **obrasgov** fornece uma interface R moderna para a [API de Dados
Abertos do
ObrasGov](https://api-publica.obrasgov.gestao.gov.br/obras/docs),
mantida pelo Governo Federal brasileiro. O pacote permite obter dados de
projetos de infraestrutura, execução física, empenhos, contratos,
geometrias, estudos de viabilidade e históricos de paralisação ou
cancelamento.

## Por que este pacote?

A API oficial é ampla e paginada, mas seu consumo direto exige construir
URLs, tratar erros HTTP, reunir páginas e transformar JSON aninhado. O
**obrasgov** resolve essas tarefas e retorna tibbles prontos para
análise, sem descartar relações um-para-muitos. O público-alvo inclui
pesquisadores, órgãos de controle, gestores públicos, jornalistas de
dados e organizações da sociedade civil.

Principais características:

- interface consistente em `snake_case` para todos os recursos públicos;
- negociação de HTTP/2 sobre TLS, retries e acesso limitado a 60
  requisições por minuto;
- paginação explícita e metadados de coleta;
- datas convertidas para `Date` e horário de atualização em `POSIXct`;
- listas aninhadas preservadas como list-columns;
- testes sem acesso à rede e integração opcional com a API oficial.

## Instalação

O pacote ainda está em desenvolvimento e não está no CRAN. Instale a
versão do GitHub com:

``` r

install.packages("pak")
pak::pak("StrategicProjects/obrasgov")
```

## Uso

``` r

library(obrasgov)

projetos_pe <- obter_projetos(
  uf_principal = "PE",
  situacao = "Em execução",
  tamanho_da_pagina = 100
)

projetos_pe
obrasgov_metadados(projetos_pe)
```

Os nomes e tipos de filtros podem ser consultados sem acessar a
internet:

``` r

obrasgov_recursos()
obrasgov_filtros("projetos")
```

Para coletar várias páginas, a opção deve ser explícita:

``` r

contratos <- obter_contratos(
  id_projeto_investimento = "134851.26-07",
  todas_paginas = TRUE,
  limite_paginas = 20
)
```

Veja
[`vignette("obrasgov")`](https://strategicprojects.github.io/obrasgov/articles/obrasgov.md)
para a introdução completa e
[`vignette("paginacao-e-dados-aninhados")`](https://strategicprojects.github.io/obrasgov/articles/paginacao-e-dados-aninhados.md)
para paginação e list-columns.

## Nova API

Este pacote usa exclusivamente o novo ambiente em
`https://api-publica.obrasgov.gestao.gov.br/obras`. A API anterior tem
descontinuidade anunciada para 31 de agosto de 2026 e não é suportada.

## Contribuição e conduta

Contribuições são bem-vindas. Leia
[CONTRIBUTING.md](https://strategicprojects.github.io/obrasgov/CONTRIBUTING.md)
e o [Código de
Conduta](https://strategicprojects.github.io/obrasgov/CODE_OF_CONDUCT.md)
antes de abrir uma issue ou pull request.

## Licença

MIT © obrasgov authors.
