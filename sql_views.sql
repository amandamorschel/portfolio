-- cadastro de clientes
drop view if EXISTS LARGE.tb_estrutura_comercial_v2;

CREATE VIEW LARGE.tb_estrutura_comercial_v2 AS 
WITH cliente_filho AS (
SELECT cd_cliente 
	, dt_inclusao 
	, CASE WHEN no_cliente_1 IS NULL THEN NULL 
  		ELSE UPPER((NVL(no_cliente_1,'') || NVL(no_cliente_2,'') || NVL(no_cliente_3,'') || NVL(no_cliente_4,''))) 
  		END AS cliente_filho
  	, UPPER(no_cidade) AS municipio
  	, CASE WHEN xx_indicador_pessoa_fisica = 'X' THEN 'PF'
      ELSE 'PJ' END AS tipo_pessoa
     , cd_pais
     , sg_estado 
	 , no_bairro AS bairro
	 , no_rua AS rua
	 , nm_numero AS numero
	 , nm_cep AS cep
	 , cd_grupo_conta
FROM SAP.kna1
),
cliente_pai AS (
SELECT cd_cliente 
	, CASE WHEN no_cliente_1 IS NULL THEN NULL 
  		ELSE UPPER(coalesce(no_cliente_1,no_cliente_2,no_cliente_3,no_cliente_4,'')
  		END AS cliente_pai
FROM SAP.kna1 
)
SELECT CONVERT_TIMEZONE('America/Sao_Paulo', GETDATE()) AS data_atualizacao
  , COALESCE(hie.nm_conta_hierarquia_cliente_superior::int,vendas.cd_cliente) AS codigo_cliente_pai
  , COALESCE(clipai.cliente_pai, clifilho.cliente_filho) AS cliente_pai
  , vendas.cd_cliente AS codigo_cliente_filho
  , clifilho.cliente_filho
  , clifilho.dt_inclusao AS data_cadastro
  , clifilho.cd_pais AS pais
  , clifilho.sg_estado AS estado
  , clifilho.municipio
  , clifilho.bairro
  , clifilho.rua
  , clifilho.numero
  , clifilho.cep
  , clifilho.tipo_pessoa
  , clifilho.cd_grupo_conta
  , vendas.zzgrupo_id as grupo_hierarquia
  , CASE WHEN vendas.zzmotivo IS NOT NULL THEN 'ATIVO'
      ELSE 'INATIVO' END AS status_cliente
  , vendas.xx_bloqueio_ordem_centralizado_cliente AS codigo_bloqueio
  , vendas.cd_organizacao_vendas AS codigo_organizacao_venda
  , vendas.cd_canal_distribuicao AS codigo_canal_distribuicao
  , vendas.cd_equipe_vendas AS codigo_equipe_venda
  , UPPER(ev.Name) AS equipe_venda
  , vendas.cd_escritorio_vendas AS codigo_escritorio_venda
  , CASE WHEN parc.cd_funcao_parceiro = 'VE' THEN 'VENDEDOR'
      WHEN parc.cd_funcao_parceiro = 'ZB' THEN 'REPRESENTANTE'
      ELSE NULL END AS funcao_parceiro
FROM sap.knvv vendas
LEFT JOIN cliente_filho clifilho ON 
  vendas.cd_cliente = clifilho.cd_cliente 
LEFT JOIN sap.parc parc ON 
  vendas.cd_cliente = parc.cd_cliente 
  AND vendas.cd_organizacao_vendas = parc.cd_organizacao_vendas 
  AND vendas.cd_canal_distribuicao = parc.cd_canal_distribuicao 
  AND vendas.cd_setor_atividade = parc.cd_setor_atividade 
  AND parc.cd_funcao_parceiro IN ('ZB','VE')
LEFT JOIN sandbox.t_salesforce ev ON 
  vendas.cd_escritorio_vendas = ev."escritoriovendaslkp_r.codigo_c" 
  AND vendas.cd_equipe_vendas = ev.codigo__c 
LEFT JOIN sap.paises pais ON 
  clifilho.cd_pais = pais.cd_pais 
LEFT JOIN sap.t179 hie ON 
  vendas.cd_cliente = hie.cd_cliente::numeric
  AND vendas.cd_setor_atividade = hie.cd_setor_atividade 
  AND vendas.cd_organizacao_vendas = hie.cd_organizacao_vendas 
  AND vendas.cd_canal_distribuicao = hie.cd_canal_distribuicao 
  AND TRUNC(dt_fim_validade_atribuicao) = '9999-01-31'
LEFT JOIN cliente_pai clipai ON 
  hie.nm_conta_hierarquia_cliente_superior::int = clipai.cd_cliente 
LEFT JOIN deca.cliente_jbp jbp ON 
	vendas.cd_cliente = jbp.cd_cliente 
WITH NO SCHEMA BINDING;

-- tb_produto source

drop view if exists tb_produto;

CREATE VIEW tb_produto
AS SELECT DISTINCT convert_timezone('America/Sao_Paulo', getdate()) AS data_atualizacao, 
mara.spart AS codigo_setor_atividade, 
        CASE
            WHEN mara.spart IN ('CS', 'LS') THEN 'LOUÇAS'
            WHEN mara.spart = 'MS' THEN 'METAIS'
            WHEN mara.spart = 'HY' THEN 'HYDRA'
            ELSE NULL
        END AS setor_atividade, 
		mara.matnr AS codigo_produto, 
		upper(makt.maktx) AS produto, 
		hie1.hierarquia_de_produtos AS codigo_tamanho, 
		upper(hie1.denominacao) AS tamanho, 
		hie2.hierarquia_de_produtos AS codigo_segmento, 
		upper(hie2.denominacao) AS segmento, 
		hie3.hierarquia_de_produtos AS codigo_linha, 
		upper(hie3.denominacao) AS linha, 
   FROM SAP.mara mara
   JOIN SAP.makt ON mara.matnr = makt.matnr AND makt.spras = 'P'
   LEFT JOIN SAP.t179 hie1 ON "left"(mara.prdha, 3) = hie1.hierarquia_de_produtos AND hie1.nivel_hierarquia_de_produtos = 1
   LEFT JOIN SAP.t179 hie2 ON "left"(mara.prdha, 8) = hie2.hierarquia_de_produtos AND hie2.nivel_hierarquia_de_produtos = 2
   LEFT JOIN SAP.t179 hie3 ON mara.prdha = hie3.hierarquia_de_produtos AND hie3.nivel_hierarquia_de_produtos = 3
WITH NO SCHEMA BINDING;

