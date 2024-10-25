
CREATE INDEX Inscripciones_Fecha_Idx ON Inscripciones(Fecha);
EXPLAIN SELECT 
*
FROM
Inscripciones
WHERE
Fecha < TO_DATE('10-03-2022','dd-MM-YYYY');
-- En postgres NO SE PUEDEN PARTICIONAR INDICES
-- Lo que si podemos es crear índices con filtros

CREATE INDEX Inscripciones_Fecha_Aprobados_Idx ON Inscripciones(Fecha) WHERE aprobado = true;

-- Esto solo funcionará en búsquedas donde esté esa condición. Si no alvidate!
EXPLAIN SELECT 
*
FROM
Inscripciones
WHERE
Fecha < TO_DATE('10-03-2022','dd-MM-YYYY')
AND aprobado = true;

-- También pueden crearse índices con funciones o expresiones

CREATE INDEX Empresas_nombre_Idx ON Empresas(lower(Nombre));

SELECT *
FROM empresas
WHERE nombre LIKE 'telas%';
-- Aquí no entraría el índice

-- Si entraría es en consultas tipo

SELECT *
FROM empresas
WHERE lower(nombre) LIKE lower('telas%');

-- Indices invertidos

SELECT to_tsvector('spanish','Introducción a Postgres');
SELECT to_tsquery('spanish','Introducción a Postgres');

CREATE INDEX Cursos_Titulo_Idx ON Cursos USING gin(to_tsvector('spanish',Titulo))

SELECT id
FROM Cursos
WHERE to_tsvector('spanish',Titulo) @@ to_tsquery('spanish','postgre');

-- TRIGRAMAS

CREATE EXTENSION IF NOT EXISTS pg_trgm;
CREATE INDEX Empresas_nombre_Idx ON Empresas USING gin( Nombre gin_trgm_ops);

-- 1111111A
-- 111
--  111
--   111
--    111
--     111

SELECT *
FROM empresas
WHERE nombre LIKE '%Manolo%';

EXPLAIN SELECT *
FROM empresas
WHERE nombre % 'Manolo';

-- Vodafone TV: BUSCAR


EXPLAIN SELECT id
FROM Cursos
WHERE to_tsvector('spanish',Titulo) @@ to_tsquery('spanish','postgresql');

SELECT * FROM CURSOS;
SELECT to_tsquery('spanish','postgresql & introduccion');
