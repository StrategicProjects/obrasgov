.obrasgov_resources <- list(
  projects = list(
    endpoint = "projeto-investimento",
    function_name = "get_projects",
    filters = c(
      id_projeto_investimento = "character",
      projeto_estruturante = "character",
      desc_nome = "character",
      nr_cep = "character",
      desc_endereco = "character",
      desc_projeto = "character",
      desc_funcao_social = "character",
      desc_meta_global = "character",
      dt_inicial_prevista = "Date",
      dt_final_prevista = "Date",
      dt_cadastro = "Date",
      ano_cadastro = "integer",
      natureza_intervencao = "character",
      id_natureza_intervencao = "integer",
      especie_intervencao = "character",
      id_especie_intervencao = "integer",
      situacao = "character",
      uf_principal = "character",
      organizacao_resp = "character",
      cnpj_organizacao_resp = "character",
      populacao_beneficiada = "integer",
      desc_populacao_beneficiada = "character",
      qtd_empregos_gerados = "integer",
      ind_bim = "integer",
      dt_inicial_efetiva = "Date",
      dt_final_efetiva = "Date",
      obs_pertinentes_intervencao = "character",
      sistema_resp = "character",
      possui_estudo_viabilidade = "character"
    )
  ),
  commitments = list(
    endpoint = "empenho",
    function_name = "get_commitments",
    filters = c(
      ug_emitente = "integer",
      id_projeto_investimento = "character",
      programa_trabalho = "character",
      plano_interno = "character",
      fonte = "character",
      natureza_despesa = "integer",
      valor_empenho = "numeric",
      sistema_origem_empenho = "character",
      bd_origem_empenho = "character",
      id_minuta = "character",
      organizacao_empenho = "character",
      data_emissao = "Date",
      nome_situacao_minuta = "character",
      unidade_orcamentaria = "character",
      programa_trabalho_resumido = "character",
      resultado_primario = "character",
      acao_orcamentaria = "character",
      codigo_autor_emenda = "character",
      nr_empenho = "character",
      credor = "character",
      aliquidar = "numeric",
      liquidado = "numeric",
      pago = "numeric",
      rpinscrito = "numeric",
      rpaliquidar = "numeric",
      rpaliquidado = "numeric",
      rppago = "numeric",
      descricao_empenho = "character"
    )
  ),
  physical_execution = list(
    endpoint = "execucao-fisica",
    function_name = "get_physical_execution",
    filters = c(
      id_projeto_investimento = "character",
      percentual_execucao_fisica = "numeric",
      dt_inicial_execucao = "Date",
      dt_final_execucao = "Date",
      tipo_instrumento = "character",
      tipo_forma_execucao = "character",
      dt_criacao_instrumento = "Date",
      dt_cadastro_execucao = "Date",
      dt_atualizacao_execucao = "Date"
    )
  ),
  contracts = list(
    endpoint = "contrato",
    function_name = "get_contracts",
    filters = c(
      id_projeto_investimento = "character",
      id_contrato = "integer",
      numero_contrato = "character",
      vigencia_inicio_contrato = "Date",
      vigencia_fim_contrato = "Date",
      data_assinatura_contrato = "Date",
      data_publicacao_contrato = "Date",
      modalidade_contrato = "character",
      objeto_contrato = "character",
      processo = "character",
      receita_despesa_contrato = "character",
      orgao_contrato = "character",
      cnpj_fornecedor_contrato = "character",
      fornecedor_contrato = "character",
      categoria_contrato = "character",
      licitacao_numero = "character",
      situacao_contrato = "character",
      link_transparencia = "character",
      valor_global_contrato = "numeric",
      valor_acumulado_contrato = "numeric",
      valor_utilizado_pi_contrato = "numeric",
      valor_incluido_contrato = "numeric"
    )
  ),
  geometries = list(
    endpoint = "geometria",
    function_name = "get_geometries",
    filters = c(
      id_projeto_investimento = "character",
      id_geometria = "integer",
      sg_uf = "character",
      no_municipio = "character",
      cod_ibge = "integer",
      origem_geometria = "character"
    )
  ),
  status_history = list(
    endpoint = "historico-situacao-cancelada-paralisada",
    function_name = "get_status_history",
    filters = c(
      id_historico_situacao_investimento = "integer",
      descricao_historico_situacao_investimento = "character",
      data_historico_situacao_investimento = "Date",
      justificativa_cancelada_paralisada = "character",
      possui_tratativas_situacao_investimento = "character",
      fase_tratativas_situacao_investimento = "character",
      id_projeto_investimento = "character"
    )
  ),
  feasibility_studies = list(
    endpoint = "estudo-viabilidade",
    function_name = "get_feasibility_studies",
    filters = c(
      id_projeto_investimento = "character",
      tipo_estudo_viabilidade = "character",
      especificacao_estudo_viabilidade = "character"
    )
  ),
  last_update = list(
    endpoint = "data-atualizacao",
    function_name = "get_last_update",
    filters = character()
  )
)

.obrasgov_choices <- list(
  projeto_estruturante = c("N\u00c3O", "SIM"),
  situacao = c(
    "Cadastrada", "Cancelada", "Conclu\u00edda", "Em execu\u00e7\u00e3o",
    "Inacabada", "Paralisada"
  ),
  uf_principal = c(
    "AC", "AL", "AM", "AP", "BA", "CE", "DF", "ES", "GO", "MA", "MG",
    "MS", "MT", "PA", "PB", "PE", "PI", "PR", "RJ", "RN", "RO", "RR",
    "RS", "SC", "SE", "SP", "TO"
  ),
  possui_estudo_viabilidade = c("N\u00c3O", "SIM"),
  sistema_origem_empenho = c(
    "PMBDISCRICIONARIAS", "CIPI", "COMPRASNET CONTRATOS"
  ),
  bd_origem_empenho = c("modulo_siafi", "cipiws"),
  nome_situacao_minuta = c("ENVIADO", "EM ALTERA\u00c7\u00c3O", "PENDENTE"),
  receita_despesa_contrato = c("Despesa", "Receita"),
  sg_uf = c(
    "AC", "AL", "AM", "AP", "BA", "CE", "DF", "ES", "GO", "MA", "MG",
    "MS", "MT", "PA", "PB", "PE", "PI", "PR", "RJ", "RN", "RO", "RR",
    "RS", "SC", "SE", "SP", "TO"
  )
)

#' List available ObrasGov API resources
#'
#' @return A tibble containing each resource name, its corresponding function,
#'   API endpoint, and whether it is paginated.
#' @export
#' @examples
#' list_resources()
list_resources <- function() {
  resources <- names(.obrasgov_resources)

  tibble::tibble(
    resource = resources,
    function_name = purrr::map_chr(.obrasgov_resources, "function_name"),
    endpoint = purrr::map_chr(.obrasgov_resources, "endpoint"),
    paginated = resources != "last_update"
  )
}

#' @rdname list_resources
#' @export
obrasgov_recursos <- list_resources

#' List filters accepted by a resource
#'
#' Lists the filters published in the OpenAPI contract supported by this
#' package. Unknown filters are rejected before a request is sent to prevent
#' silently incorrect queries. Filter names and categorical values remain in
#' Portuguese because they are part of the upstream API contract.
#'
#' @param resource A resource name returned by [list_resources()]. Portuguese
#'   resource names used by earlier package versions are also accepted.
#' @param recurso Portuguese alias for `resource`, available only in
#'   [obrasgov_filtros()].
#'
#' @return A tibble containing filter names, expected types, and allowed values
#'   when applicable.
#' @export
#' @examples
#' list_filters("projects")
list_filters <- function(resource) {
  resource <- .match_resource(resource)
  filters <- .obrasgov_resources[[resource]]$filters

  tibble::tibble(
    filter = names(filters),
    type = unname(filters),
    allowed_values = purrr::map(names(filters), function(filter) {
      .obrasgov_choices[[filter]] %||% character()
    })
  )
}

#' @rdname list_filters
#' @export
obrasgov_filtros <- function(recurso) {
  list_filters(recurso)
}

.match_resource <- function(resource) {
  if (!is.character(resource) || length(resource) != 1L || is.na(resource)) {
    cli::cli_abort("{.arg resource} must be a single string.")
  }

  resource <- .portuguese_resources[[resource]] %||% resource
  choices <- names(.obrasgov_resources)

  if (!resource %in% choices) {
    cli::cli_abort(c(
      "Unknown resource: {.val {resource}}.",
      "i" = "Choose one of: {.val {choices}}."
    ))
  }

  resource
}

.portuguese_resources <- list(
  projetos = "projects",
  empenhos = "commitments",
  execucao_fisica = "physical_execution",
  contratos = "contracts",
  geometrias = "geometries",
  historico_situacao = "status_history",
  estudos_viabilidade = "feasibility_studies",
  data_atualizacao = "last_update"
)
