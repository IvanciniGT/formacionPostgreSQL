SELECT
  pg_size_pretty(pg_relation_size('cursos')) as tamano_tabla,
  pg_size_pretty(pg_total_relation_size('cursos')) as tamano_tabla_con_indices;

SELECT 
  relname as nombre_tabla,
  n_live_tup as filas
FROM
  pg_stat_all_tables
WHERE
  relname = 'cursos';


SELECT 
  *
FROM
  pg_stat_all_tables
WHERE
  relname = 'cursos';

-- En postgres hay muchas funciones que por defecto vienen deshabilitadas
CREATE EXTENSION IF NOT EXISTS pgstattuple;
SELECT * FROM pgstattuple('cursos');