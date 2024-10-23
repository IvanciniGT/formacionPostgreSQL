--CREATE INDEX usuarios_nombre_Idx ON usuarios USING gin( nombre gin_trgm_ops);

--SELECT
--  pg_size_pretty(pg_relation_size('usuarios')) as tamano_tabla,
--  pg_size_pretty(pg_total_relation_size('usuarios')) as tamano_tabla_con_indices;

BEGIN;
set local pg_trgm.similarity_threshold = 0.5;
SELECT count(*) FROM USUARIOS 
WHERE nombre LIKE 'michael'; -- LIKE HACE BUSQUEDA EXACTA
EXPLAIN SELECT * FROM USUARIOS 
WHERE nombre % 'michael'; -- % QUE SE PAREZCA (FUZZY SEARCH)
                        -- Busca cosas que cambien pocos caracteres

COMMIT;