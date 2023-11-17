DROP TABLE IF EXISTS tb_vendas;

CREATE TABLE tb_vendas ( 
 data_competencia date  ,
 data_atualizacao timestamp  DEFAULT CONVERT_TIMEZONE('America/Sao_Paulo', GETDATE()),
 dia_util_total int ,
 dia_util_indice int ,
 codigo_setor_atividade varchar(6)  ,
 setor_atividade varchar(120)  ,
 codigo_gerente varchar(36)  ,
 gerente varchar(150)  ,
 codigo_coordenador varchar(36)  ,
 coordenador varchar(150)  ,
 codigo_representante varchar(30)  ,
 representante varchar(240)  ,
 codigo_cliente_filho varchar(30)  ,
 cliente_filho varchar(90)  ,
 valor_liquido_mes float ,
 valor_liquido_ano float ,
 valor_liquido_aa float ,
 valor_liquido_mes_1 float  ,
 valor_liquido_mes_2 float  ,
 valor_liquido_mes_3 float  ,
 valor_liquido_mes_4 float  ,
 valor_liquido_mes_5 float  ,
 valor_liquido_mes_6 float  ,
 valor_liquido_trimestre float  ,
 valor_liquido_trimestre_1 float  ,
 valor_liquido_trimestre_2 float  ,
 valor_liquido_trimestre_3 float  ,
 valor_liquido_trimestre_4 float   )

 distkey(data_competencia)
 interleaved sortkey(data_competencia,  codigo_setor_atividade, gerente, coordenador, representante, codigo_cliente_filho, cliente_filho);

--------/

INSERT INTO tb_vendas
(data_competencia, dia_util_total, dia_util_indice, codigo_setor_atividade, setor_atividade, codigo_gerente, gerente, codigo_coordenador, coordenador, codigo_representante, representante, codigo_cliente_filho, cliente_filho, valor_liquido_mes, valor_liquido_ano, valor_liquido_aa, valor_liquido_mes_1, valor_liquido_mes_2, valor_liquido_mes_3, valor_liquido_mes_4, valor_liquido_mes_5, valor_liquido_mes_6, valor_liquido_trimestre, valor_liquido_trimestre_1, valor_liquido_trimestre_2, valor_liquido_trimestre_3, valor_liquido_trimestre_4)
with
cte_total as (
select   
  date_trunc('month',data_competencia)::date as data_competencia
 ,dia_util_total
 ,max(case when data_competencia<date_trunc('month',(select max(data_competencia) from large.tb_venda_meta where valor_liquido>0)) then dia_util_total else dia_util_indice end) as dia_util_indice
 ,codigo_setor_atividade   
 ,setor_atividade  
 ,codigo_gerente  
 ,gerente  
 ,codigo_coordenador   
 ,coordenador  
 ,codigo_representante   
 ,representante  
 ,codigo_cliente_filho 
 ,cliente_filho
 ,sum(valor_liquido) as valor_liquido
 from large.tb_venda_ordem tvo 
 where 
 data_competencia>= dateadd('year',-2,date_trunc('year',(select max(data_competencia) from large.tb_venda_meta)))::date
 and valor_liquido>0
 group by date_trunc('month',data_competencia)
 ,dia_util_total
 ,codigo_setor_atividade   
 ,setor_atividade  
 ,codigo_gerente  
 ,gerente  
 ,codigo_coordenador   
 ,coordenador  
 ,codigo_representante   
 ,representante  
 ,codigo_cliente_filho 
 ,cliente_filho 
 )
select   
  A.data_competencia
 ,A.dia_util_total
 ,A.dia_util_indice
 ,B.codigo_setor_atividade   
 ,B.setor_atividade  
 ,B.codigo_gerente  
 ,B.gerente  
 ,B.codigo_coordenador   
 ,B.coordenador  
 ,B.codigo_representante   
 ,B.representante  
 ,B.codigo_cliente_filho 
 ,B.cliente_filho
 ,ROUND(SUM(CASE WHEN B.data_competencia=A.data_competencia THEN B.valor_liquido END),2) AS valor_liquido_mes
 ,ROUND(SUM(CASE WHEN B.data_competencia<A.data_competencia THEN B.valor_liquido END),2) AS valor_liquido_ano 
 ,ROUND(SUM(CASE WHEN B.data_competencia=DATEADD('year',-1,A.data_competencia) THEN B.valor_liquido END),2) AS valor_liquido_aa 
 ,ROUND(SUM(CASE WHEN B.data_competencia=DATEADD('month',-01,A.data_competencia) THEN B.valor_liquido END),2) AS valor_liquido_m1
 ,ROUND(SUM(CASE WHEN B.data_competencia=DATEADD('month',-02,A.data_competencia) THEN B.valor_liquido END),2) AS valor_liquido_m2 
 ,ROUND(SUM(CASE WHEN B.data_competencia=DATEADD('month',-03,A.data_competencia) THEN B.valor_liquido END),2) AS valor_liquido_m3 
 ,ROUND(SUM(CASE WHEN B.data_competencia=DATEADD('month',-04,A.data_competencia) THEN B.valor_liquido END),2) AS valor_liquido_m4 
 ,ROUND(SUM(CASE WHEN B.data_competencia=DATEADD('month',-05,A.data_competencia) THEN B.valor_liquido END),2) AS valor_liquido_m5
 ,ROUND(SUM(CASE WHEN B.data_competencia=DATEADD('month',-06,A.data_competencia) THEN B.valor_liquido END),2) AS valor_liquido_m6
 ,ROUND(SUM(CASE WHEN B.data_competencia<=A.data_competencia AND B.data_competencia>=DATEADD('month',-2,A.data_competencia) THEN B.valor_liquido END),2) AS valor_liquido_tri
 ,ROUND(SUM(CASE WHEN B.data_competencia<=DATEADD('month',-01,A.data_competencia) AND B.data_competencia>=DATEADD('month',-03,A.data_competencia) THEN B.valor_liquido END),2) AS valor_liquido_t1
 ,ROUND(SUM(CASE WHEN B.data_competencia<=DATEADD('month',-04,A.data_competencia) AND B.data_competencia>=DATEADD('month',-06,A.data_competencia) THEN B.valor_liquido END),2) AS valor_liquido_t2
 ,ROUND(SUM(CASE WHEN B.data_competencia<=DATEADD('month',-07,A.data_competencia) AND B.data_competencia>=DATEADD('month',-09,A.data_competencia) THEN B.valor_liquido END),2) AS valor_liquido_t3
 ,ROUND(SUM(CASE WHEN B.data_competencia<=DATEADD('month',-10,A.data_competencia) AND B.data_competencia>=DATEADD('month',-12,A.data_competencia) THEN B.valor_liquido END),2) AS valor_liquido_t4
FROM (SELECT DISTINCT data_competencia, dia_util_total, dia_util_indice FROM cte_total) as A
INNER JOIN cte_total as B ON B.data_competencia BETWEEN dateadd('year',-1,A.data_competencia) and A.data_competencia 
WHERE A.data_competencia>= dateadd('year',-1,date_trunc('year',(select max(data_competencia) from large.tb_venda_meta)))::date
group by 
  A.data_competencia
 ,A.dia_util_total
 ,A.dia_util_indice
 ,B.codigo_setor_atividade   
 ,B.setor_atividade  
 ,B.codigo_gerente  
 ,B.gerente  
 ,B.codigo_coordenador   
 ,B.coordenador  
 ,B.codigo_representante   
 ,B.representante  
 ,B.codigo_cliente_filho 
 ,B.cliente_filho;


GRANT ALL ON tb_vendas TO "";
