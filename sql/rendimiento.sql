SELECT * FROM pg_stat_activity;

SELECT * FROM pg_stat_activity WHERE state ='active';

SELECT * FROM pg_stat_database;

SELECT * FROM pg_stat_database where datname ='db';

SELECT 
datname,
blks_read AS PAGINAS_LEIDAS_DE_DISCO,
blks_hit  AS PAGINAS_SACADAS_DE_CACHE,
blks_hit *100.0 / (blks_read + blks_hit) AS RATIO_EXITO_DE_LA_CACHE
FROM pg_stat_database 
WHERE datname ='db';


SELECT * FROM pgstattuple('usuarios');
VACUUM usuarios;

-- Nos informa de si la cache está funcionando bien... 
-- Es decir, que cuando vamos a buscar un dato ya lo encontramos en cache y no tiene que ir a disco.

-- HACEMOS UN ESTUDIO DETALLADO POR TABLA
SELECT 
relname AS TABLA,
heap_blks_read AS NUMERO_DE_BLOQUES_DE_LA_TABLA_LEIDOS_DE_DISCO,
heap_blks_hit  AS NUMERO_DE_BLOQUES_DE_LA_TABLA_LEIDOS_DE_CACHE,
heap_blks_hit * 100.0 / (heap_blks_read + heap_blks_hit) AS RATIO_CACHE_DATOS_TABLA,
idx_blks_read AS NUMERO_DE_BLOQUES_DE_INDICES_LEIDOS_DE_DISCO,
idx_blks_hit  AS NUMERO_DE_BLOQUES_DE_INDICES_LEIDOS_DE_CACHE,
idx_blks_hit * 100 /(idx_blks_read + idx_blks_hit) AS RATIO_CACHE_INDICES
FROM pg_statio_user_tables
WHERE 
heap_blks_read + heap_blks_hit > 0 AND
idx_blks_read + idx_blks_hit > 0;


-- HACEMOS UN ESTUDIO DETALLADO POR INDICE

SELECT 
relname AS TABLA,
indexrelname AS INDICE,
idx_blks_read AS NUMERO_DE_BLOQUES_DE_INDICES_LEIDOS_DE_DISCO,
idx_blks_hit  AS NUMERO_DE_BLOQUES_DE_INDICES_LEIDOS_DE_CACHE,
idx_blks_hit * 100 /(idx_blks_read + idx_blks_hit) AS RATIO_CACHE_INDICES
FROM pg_statio_user_indexes
WHERE 
idx_blks_read + idx_blks_hit > 0;

SELECT * FROM pgstatindex('usuarios_email_uq');

REINDEX INDEX usuarios_email_uq;
