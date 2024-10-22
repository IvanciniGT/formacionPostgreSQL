Tabla TABLA1: id(4), numero(4), fecha(8), nombre(0-20)

---------------------------------- 8Kbs
TABLA TABLA1 - Bloque 1
 - - - - - - - - - - - - - - - - - 
  A -> Byte 0
  B -> Byte 20
 - - - - - - - - - - - - - - - - - 
Cabecera FILA A | 1 1 01/01/2010 Juan                         --> Cuánto ocupa? 24+20 bytes
Cabecera FILA B INHABILITADO | 2 2 02/01/2010 Federico        --> Cuánto ocupa? 24+24 bytes
---------------------------------- 8Kbs
TABLA TABLA1 - Bloque 2
 - - - - - - - - - - - - - - - - -
Cabecera FILA B | 2 3 02/01/2010 Federico                     --> Cuánto ocupa? 24+24 bytes
  UPS! no entraba la edición en el bloque 1. Lo necesito en otro bloque de datos!
    Necesito reescribir TODOS LOS INDICES Que apuntaban a la fila B ( si tengo 7 campos indexados... LOS 7)

Y otro dato que puedo configurar es el FILLFACTOR DE PAGINA DE TABLA.


Es posible para postgres, saber en que byte dentro de un bloque empieza una determinada fila (a priori)? 
Sabiendo solo el ancho de las columnas


Para recuperar un dato, postgres debe:
1º Averiguar en qué página está el dato
2º Al leer la página de disco (o cache) en la cabecera de la página mira la posición de la fila (en bytes) dentro del bloque
3º De ahí lee la fila (tantos bytes como tenga apuntado que ocupa) y me la devuelve


BTREE
-------------------------------------8Kbs
INDICE  
VALOR     UBICACION
azul      Fila A (bloque 1), Fila J (bloque 2), ....
blanco    Fila B (bloque 2), Fila K (bloque 2), ....
morado    Fila C (bloque 1), Fila L (bloque 2), ....
rojo      Fila D (bloque 1), Fila M (bloque 2), ....
verde     Fila E (bloque 1), Fila N (bloque 2), ....
-------------------------------------8Kbs
azul      Fila AA (bloque 10)
negro     Fila L (bloque 12)

