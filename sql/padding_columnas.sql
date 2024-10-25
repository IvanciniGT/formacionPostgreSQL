SELECT 
  pg_column_size(row()) as FILA_VACIA,
  pg_column_size(row(0::SMALLINT)) as FILA_SMALL_INT,
  pg_column_size(row(0::INT)) as FILA_INT,
  pg_column_size(row(0::BIGINT)) as FILA_BIG_INT,
  pg_column_size(row(0::BIGINT,0::BIGINT)) as FILA_2_BIG_INT,
  pg_column_size(row(0::INT,0::INT,0::BIGINT)) as FILA_MULTIPLE,
  pg_column_size(row(0::INT,0::BIGINT,0::INT)) as FILA_MULTIPLE_DESTROZADA
;