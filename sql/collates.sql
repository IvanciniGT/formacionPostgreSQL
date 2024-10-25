-- Collate
CREATE COLLATION es_insensible (
    PROVIDER = 'icu',                   -- Motor de procesamiento de collates... Siempre icu
    LOCALE   = 'es-ES-u-ks-level1',
    DETERMINISTIC = FALSE               -- Si queremos una comparación en profundidad o no
);
SELECT 'Camión' = 'camion' COLLATE es_insensible;

DROP TABLE Ejemplo ;

CREATE TABLE Ejemplo (
    id serial,
    texto VARCHAR(50) COLLATE es_insensible,
    texto2 VARCHAR(50) COLLATE es_insensible
);

INSERT INTO Ejemplo (texto, texto2) VALUES ('Camión' ,'Camión');
INSERT INTO Ejemplo (texto, texto2) VALUES ('Camión' ,'Camion');
INSERT INTO Ejemplo (texto, texto2) VALUES ('Camión' ,'camión');
INSERT INTO Ejemplo (texto, texto2) VALUES ('Camión' ,'camion');

SELECT texto = texto2 FROM Ejemplo;

--ORDER BY (no lo hacemos sobre 1M de registros)