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

DELETE FROM inscripciones WHERE CursoId = 6 AND PersonaId = 4;
VACUUM ANALYZE inscripciones;
ANALYZE inscripciones;
VACUUM inscripciones;
--ANALYZE VACUUM inscripciones; NO
-- Carga masiva de datos: NO ME HACE FALTA HACER UN VACUUM... pero puedo querer hacer un analyze de ciertas columnas (FECHAS, ID, ...)


SELECT * FROM pgstattuple('cursos');


SELECT * FROM pg_indexes;
SELECT * FROM pg_stat_user_indexes;
