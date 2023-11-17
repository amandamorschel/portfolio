DROP TABLE IF EXISTS small.tb_cancelamento_devolucao;

CREATE TABLE small.tb_cancelamento_devolucao ( data_competencia date  ,
 dia_util_total int  ,
 dia_util_indice int  ,
 data_atualizacao timestamp  DEFAULT CONVERT_TIMEZONE('America/Sao_Paulo', GETDATE()),
 tipo varchar(45)  ,
 codigo_motivo_cancelamento_devolucao varchar(30)  ,
 motivo_cancelamento_devolucao varchar(90)  ,
 codigo_setor_atividade varchar(6)  ,
 setor_atividade varchar(120)  ,
 canal varchar(120)  ,
 codigo_gerente varchar(36)  ,
 gerente varchar(150)  ,
 codigo_coordenador varchar(36)  ,
 coordenador varchar(150)  ,
 codigo_representante varchar(30)  ,
 representante varchar(240)  ,
 codigo_cliente_filho varchar(30)  ,
 cliente_filho varchar(90)  ,
 quantidade float ,  
 valor_liquido float  ,
 valor_vma float )
  
 distkey(data_competencia)
 interleaved sortkey(data_competencia, codigo_motivo_cancelamento_devolucao, codigo_setor_atividade, canal, gerente, coordenador, representante, codigo_cliente_filho);
 
INSERT INTO small.tb_cancelamento_devolucao (data_competencia, dia_util_total, dia_util_indice, tipo, codigo_motivo_cancelamento_devolucao, motivo_cancelamento_devolucao , codigo_setor_atividade, setor_atividade, canal, codigo_gerente, gerente, codigo_coordenador, coordenador,codigo_representante, representante,codigo_cliente_filho, cliente_filho,
 quantidade, valor_liquido, valor_vma)

 SELECT 
data_competencia, dia_util_total, dia_util_indice, 'DEVOLUCAO' AS tipo, codigo_motivo_cancelamento_devolucao, motivo_cancelamento_devolucao, codigo_setor_atividade, setor_atividade, canal, codigo_gerente, gerente, codigo_coordenador, coordenador,codigo_representante, representante,codigo_cliente_filho, cliente_filho
,SUM(quantidade) AS quantidade
,SUM(valor_liquido) AS valor_liquido
,SUM(valor_vma) AS valor_vma
FROM large.tb_venda_ordem 
WHERE codigo_motivo_cancelamento_devolucao IS NOT NULL AND data_competencia>= dateadd('month',-24,date_trunc('month',(select max(data_competencia) from large.tb_venda_ordem)))::date AND (tipo='DEVOLUÇÃO') 
GROUP BY data_competencia, dia_util_total, dia_util_indice, tipo, codigo_motivo_cancelamento_devolucao, motivo_cancelamento_devolucao,codigo_setor_atividade,setor_atividade,codigo_tamanho,tamanho,codigo_segmento,segmento,canal, codigo_gerente, gerente, codigo_coordenador, coordenador,codigo_representante, representante,codigo_cliente_filho, cliente_filho
UNION ALL
 SELECT 
data_competencia,dia_util_total, dia_util_indice, 'CANCELAMENTO' AS tipo, codigo_motivo_cancelamento_devolucao, motivo_cancelamento_devolucao, codigo_setor_atividade, setor_atividade, canal, codigo_gerente, gerente, codigo_coordenador, coordenador,codigo_representante, representante,codigo_cliente_filho, cliente_filho
,SUM(quantidade) AS quantidade
,SUM(valor_liquido) AS valor_liquido
,SUM(valor_vma) AS valor_vma
FROM large.tb_venda_ordem 
WHERE codigo_motivo_cancelamento_devolucao IS NOT NULL AND data_competencia>= dateadd('month',-24,date_trunc('month',(select max(data_competencia) from large.tb_venda_ordem)))::date AND (tipo='CANCELAMENTO') 
GROUP BY data_competencia, dia_util_total, dia_util_indice, tipo, codigo_motivo_cancelamento_devolucao, motivo_cancelamento_devolucao,codigo_setor_atividade,setor_atividade,codigo_tamanho,tamanho,codigo_segmento,segmento,canal, codigo_gerente, gerente, codigo_coordenador, coordenador,codigo_representante, representante,codigo_cliente_filho, cliente_filho;


GRANT ALL ON small.tb_cancelamento_devolucao TO "";
