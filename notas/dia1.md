
# PostgreSQL

Es una BBDD Relacional.

---

# DATOS

Los datos en la mayor parte de escenarios quiero persistirlos para recuperarlos en el futuro.
Los SO nos ayudan con la persistencia de datos: ficheros donde puedo grabar datos para su posterior recuperación.

Los SO ofrecen 2 formas de gestionar ficheros de datos:
- Ficheros de acceso secuencial. Muy sencillos de gestionar
  - LEER: desde el principio hasta el final
  - AÑADIR DATOS: al final del fichero
  - MODIFICAR EL CONTENIDO / ESCRIBIR CONTENIDO: desde el principio hasta el final (reescribir el fichero completo)
  En algunos escenarios esto me sirve. Si tengo archivos de datos GIGANTES y solo quiero cambiar una cosita, tener que reescribir el fichero completo es un problema (Rendimiento)
  Cualquier archivo de texto, código, archivo de configuración, etc. es un fichero de acceso secuencial.
- Ficheros de acceso aleatorio:
  Me permite poner ala aguja del HDD en la posición que yo quiera y leer o escribir en esa posición una cantidad concreta de bytes.
  Para trabajar con ficheros grandes en los que cambian cosas pequeñas, esto es ideal.
  Es tan maravilloso COMO COMPLEJO. No es sencillo de gestionar.
  Y una de las cosas que además implica es un aumento considerable del tamaño del fichero.

  Si 100kbs de datos los puedo guardar ocupando 100kbs en un archivo de acceso secuencial, en un archivo de acceso aleatorio, esos 100kbs de datos ocuparán bastante más de 100kbs. 

Cuando desarrollo software huyo de los archivos de acceso aleatorio. COMO LA PESTE.. por su complejidad. Para nosotros desarrolaldores, lo sencillo es manejar ficheros de acceso secuencial. Y con esos nos atrevemos: A leerlos, a escribirlos, a modificarlos, a añadir datos, etc.

Las BBDD salen para solucionar este problema. Son una forma estandarizada de manejar archivos de acceso aleatorio, quitándome a mi la responsabilidad de gestionarlos.

```json
[
    {
        "nombre": "Juan",
        "edad": 30,
        "ciudad": "Madrid",
        "casado": false
    },
    {
        "nombre": "Ana",
        "edad": 25,
        "ciudad": "Barcelona",
        "casado": true
    }
]
```

```
Nombre    | Edad    | Ciudad     | Casado
-----------------------------------------
Juan      | 30      | Madrid     | false
Ana       | 25      | Barcelona  | true
```

Tengo que cambiar la edad de Ana:
- Si lo tengo guardado en un archivo de acceso secuencial, tengo que reescribir el archivo completo.
- Si lo tengo guardado en un archivo de acceso aleatorio, puedo ir a la posición donde estoy guardando la edad de Ana y cambiar solo su edad. Esto es muy eficiente... el problema es saber cuál es la posición donde está guardada la edad de Ana.
  Si establezco de antemano que:
    - El nombre lo voy a guardar en 20 bytes
    - La edad en 4 bytes
    - La ciudad en 20 bytes
    - El casado en 1 byte
  Y los datos los guardo en ese orden... y sé (que ya es mucho saber... esto será otro problema) que Ana es la segunda fila de datos... puedo calcular que la edad de Ana está en la posición:
   1 fila me ocupa: 20 + 4 + 20 + 1 = 45 bytes
   Ana, si es la segunda fila, su edad estará en la posición 45(de la fila anterior) + 20(del nombre de Ana)= 65 bytes
   Si me llevo la cabeza de lectura del disco a la posición 65bytes del fichero, ahí puedo guardar 4 bytes con la nueva edad de Ana.
   Eso es muy eficiente... Y MUY COMPLEJO.
   Y ADEMÁS CON MUCHO DESPERDICIO DE ESPACIO!

   Cuánto ocupa el nombre "Ana" en RAM? Dependiendo del juego de caracteres: 
    - UTF-8, ASCII, ISO-8859-1: 1 byte por carácter. Ana ocupa 3 bytes.
    - UTF-32: 4 bytes por carácter. Ana ocupa 12 bytes.
   En cualquiera de los casos mucho menos (MUUUCHO MENOS) que los 20 bytes que le estoy reservando en el fichero para guardar su nombre. 

---

Los datos en postgreSQL los guardaremos en TABLAS (Igual que en cualquier otra BBDD Relacional). 
Esas tablas (que estarán guardadas en ficheros) accederé a ellas por acceso aleatorio.

¿Cuanto ocupa cada dato que guarde en la tabla? Depende de la naturaleza del dato.
Los datos los guardamos como secuencias de bytes.
¿Qué es un byte? 8 bit. 
1 bit? La unidad de almacenamiento. Puede ser 0 o 1. Esto es verdad? No. Un bit no es 0 o 1. Un bit es un estado de un sistema físico. 

1 bytes cuántas cosas potencialmente distintas puedo representar? 2^8 = 256 cosas distintas.
Otra cosa es el significado que dé yo a cada una de esas cosas: TIPOS DE DATOS
            NUMERO ENTERO POSITIVO      NUMERO ENTERO CON SIGNO     CARACTER ASCII
00011010        26                          -95                         'Z'

En postgreSQL igual que en todas BBDD Relacionales, tenemos muchos tipos de datos:
- smallint: 2 bytes
- integer, int, int4: 4 bytes
- bigint: 8 bytes
- real, float4: 4 bytes
- double precision, float8: 8 bytes
- numeric, decimal: Decimos nosotros la precisión y escala: numeric(8,2) -> 10 bytes
- smallserial: 2 bytes
- serial: 4 bytes
- bigserial: 8 bytes

- date: 8 bytes
- time: 8 bytes
- timestamp: 8 bytes
- timestampz: 8 bytes
- interval: 16 bytes

- boolean: 1 byte

- bytea: 1 byte por cada byte que tenga el dato ~ On oracle equivalente a un BLOB

- json
- xml
- point
- polygon
- circle
- cidr
- inet
- macaddr

- char(n): n chars
- varchar(n): n chars
- text: n chars

1 char ocupa en función del juego de caracteres que estemos utilizando: UTF-8

## UNICODE

Unicode es un estandar (ISO) que contiene todos los caracteres que usa la humanidad (155.000).. Eso son muchos caracteres.
En 1 byte entran? Ni de coña
En 2 bytes? 65.536 caracteres NOP!!!
En 4 bytes: 4.294.967.296 caracteres. Sí. En 4 bytes entran todos los caracteres que usa la humanidad.

Una cosa es la tabla de caracteres (UNICODE). Otra cosa es cómo los representamos en bytes: UNICODE TRANSFORMATION FORMAT (UTF)

- UTF-8: Es un formato de codificación variable.
     1 bytes por caracter para los 256 primeros caracteres de UNICODE.  (letras básicas del inglés, números, signos de puntuación, etc.)
     2 bytes para los siguientes 2048 caracteres. (Caracteres latinos, griegos, cirílicos, etc.)
     4 bytes para el resto. (chico, japonenes, emojis, etc.)
- UTF-16 (al menos 2 bytes por caracter... algunos 4 bytes)
- UTF-32 (4 bytes por caracter)
 
Al definir una tabla en Postgres (O cualquiero otro SGBD) establecemos los tipos de datos. Y uno de los usos es para establecer cuánto espacio en disco vamos a reservar para cada dato.

---

## Con Postgres, el orden de definición de los campos en la tabla ES MUY IMPORTANTE

Con postgres, necesitamos JUGAR AL TETRIS con las columnas.

```sql
CREATE TABLE miTabla (
    id serial PRIMARY KEY,                  4 bytes
    fecha date,                             8 bytes
    numero smallint,                        2 bytes
    fechahora timestamp,                    8 bytes
    dato boolean,                           1 byte
    texto varchar(10)                       0-10 bytes
);
```

Según os he dicho antes, cuánto ocupan LOS DATOS de la fila en HDD? 23-33 bytes NI DE COÑA !

Y aquí empiezan a entrar las peculiaridades de Postgres:
Postgres requiere que los campos que ocupan más de 8 bytes (numeric, date, timestamp, etc.) se comiencen a guardar en un byte que sea múltiplo de 8 (PADDING de 8 bytes de postgres)

0               8               16              24              32              40              48
| 8 bytes       | 8 bytes       | 8 bytes       | 8 bytes       | 8 bytes       | 8 bytes       |
|---------------|---------------|---------------|---------------|---------------|---------------|
| id(4) |4 free | fecha(8)      | numero(2) - 6 | fechahora     | dato (1) - 7  | texto   (0-10)|
            ^
            Se tiran a la basura!             ^Se tiran a la basura!         ^Se tiran a la basura!


Esa fila de datos ocupará entre 40-50 bytes (de 23-33 que habíamos considerado inicialmente): DOBLE !

```sql
CREATE TABLE miTabla (
    id serial PRIMARY KEY,                  4 bytes
    numero smallint,                        2 bytes
    dato boolean,                           1 byte
    fecha date,                             8 bytes
    fechahora timestamp,                    8 bytes
    texto varchar(10)                       0-10 bytes
);
```
En el primer bloque de 8 bytes: id(4) + numero(2) + dato(1) = 7 bytes - Sobra 1 (que tiro)
En el segundo bloque de 8 bytes: fecha(8) = 8 bytes
En el tercer bloque de 8 bytes: fechahora(8) = 8 bytes
En el cuarto/quinto bloque de 8 bytes: texto(0-10) = 10 bytes
Entre 24 y 34 bytes por fila!!!

ESTO TIENE UN IMPACTO ENORME:
- Necesidades de almacenamiento
- Rendimiento (necesito leer el doble de bytes de HDD para cada fila y/o escribir el doble de bytes de HDD para cada fila)
    - Llamadme loco.. pero eso tardará el DOBLE !

```sql
CREATE TABLE miTabla (
    id serial PRIMARY KEY,                  4 bytes
    numero smallint,                        2 bytes 
    dato boolean,                           1 byte
    dato boolean,                           1 byte

    id serial PRIMARY KEY,                  4 bytes
    numero smallint,                        2 bytes
    numero smallint,                        2 bytes
);
```

ES IMPRESCINDIBLE PARA HACER UN BUEN USO/ADMINISTRACION de un PostgreSQL conocer cómo se guardan los datos.
Si esto lo tenemos claro (y nos falta mucho por ver) podremos hacer un uso eficiente de la BBDD.
Si no conocemos esto, el problema es que acabáis en páginas tipo StackOverflow preguntando por qué vuestro PostgreSQL es tan lento.

---

- Postgres NO ACTUALIZA DATOS EN FILAS EN FICHERO.

La realidad es que cada vez que se toca NI SIQUIERA 1 UNICO CAMPO, postgres guarda una nueva fila en el fichero, con todos los datos otra vez. Y la fila anterior en fichero queda marcada para su borrado (Obsoleta).

Le veis sentido? Qué pasa si tengo conexiones paralelas mirando los mismos datos.

Pero a su vez esto produce 2 efectos NEGATIVOS:
- Espacio de almacenamiento: Necesitamos un huevo en BBDD sujetas a ACTUALIZACIONES
- INDICES

---

En realidad, dentro del fichero de mi BBDD Postgres guardamos PAGINAS DE DATOS (Bloques de datos) de 8kbs.
Los bloques se leen enteros... y se guardan en cache (shared_buffers) para que si alguien vuelve a pedir esos datos, no tenga que ir a disco a leerlos.

Cada fila en postgres lleva una cabecera: 24 bytes.
Ahí se guarda información como: IDENTIFICADOR DE FILA, LONGITUD DE FILA, SI ESTA VIGENTE o NO

---

# Un problema GRANDE que tienen todas las BBDD es a la hora de recuperar información discreta!

Cuál es la operación más básica que una BBDD Relacional puede hacer para recuperar (buscar) un dato? FULLSCAN

## FULLSCAN?

Si le pido a Postgres:
```sql
SELECT * FROM miTabla WHERE edad = 17;
```

Cómo hace eso internamente? Lo más básico es un FULLSCAN

Implica: 
- Leer todas las páginas de datos de la tabla de fichero, 
- de ellas, leer todas las filas (que estén vigentes) 
- voy mirando si la columna edad de la fila es 17.

ESTO ES BASTANTE INEFICIENTE. Cómo lo puedo mejorar este comportamiento? INDICE

Qué es un índice y que me ofrece(cómo mejora la búsqueda)?

### INDICE

Una COPIA ORDENADA de los datos, con información relativa a su ubicación.
Cada vez que abrimos un libro... y miro en el INDICE del libro, veo un índice!

Libro de recetas de cocina:
- Pagina 1: Tortilla de patatas
- Pagina 2: Paella
- Pagina 3: Cocido madrileño
- Pagina 4: Fabada asturiana
- Pagina 5: Gazpacho
- ...
- Pagina 100: Tarta de manzana
- Página 101: INDICE:
    - Cocido madrileño      ->  Pagina 3
    - Fabada asturiana      ->  Pagina 4
    - Gazpacho              ->  Pagina 5
    - Paella                ->  Pagina 2
    - Tortilla de patatas   ->  Pagina 1

Por qué me ayudan en las búsquedas?
- Necesito leer menos información... En una página (o 3) de datos tengo el índice entero del libro
    Necesito leer en más o menos páginas. El índice previblemente tendrá menos páginas que la tabla (el libro) 
- Realmente eso sería hacer un uso muy ineficiente del ÍNDICE: FULLSCAN sobre el índice
    Imaginad que tengo una columna llamada COLOR: con 1M de registros en los que aparecen 20 colores distintos.
    Si hago un fullscan de la tabla, tengo que leer 1M de registros.
    Si hago un fullscan del índice tengo que leer 20 registros.
    EVITA LEER MUCHAS VECES EL MISMO DATO...(el color rojo) solo lo leo 1 vez
- Hay otra cosa que podemos hacer! Aplicar un algoritmo de BUSQUEDA BINARIA! : Cada vez que busco en un diccionario!
- Y esto lo puedo aplicar solo porque hay algo que se cumple: los datos están ordenados de antemano.

PREGUNTA: Qué tal se le dan a los ORDENADORES ordenar datos??? COMO EL PUTO CULO !!! Es de lo peor que puedo pedir a un ORDENADOR.
Prefiero mil veces hacer un fullscan que tener que ORDENAR DATOS.. eso si, si tengo los datos ordenados, puedo aplicar una busqueda binaria y entonces prefiero eso 100 veces a un fullscan.

1000000 de registros
500000 de registros
250000 de registros
125000 de registros
62500 de registros
31250 de registros
15625 de registros
7812 de registros
3906 de registros
1953 de registros
976 de registros
488 de registros
244 de registros
122 de registros
61 de registros
30 de registros
15 de registros
7 de registros
3 de registros
1 de registros

Si quiero encontrar algo con FULL SCAN tengo que leer 1M de datos
Con 20 lecturas, aplicando búsqueda binaria, puedo encontrar el dato que busco.

Lo que hacemos con las BBDD es PREORDENAR LOS DATOS (en el momento del INSERT)... Eso implica crear una INDICE donde los datos los guardo ya en su sitio.

Es más... si tengo que buscar ZAPATO en el diccionario, abro por la mitad el primer corte? NI DE COÑA! Empiezo por el final. Por qué?
Conozco la distribución de los datos en el diccionario. La Z sé que es la última, y no solo eso.

Xilofono -> Primer corte: Por el final... y el segundo corte? PRIMER CORTE -> Zapato
SEGUNDO CORTE -> Muy cerquita del primer corte... Sé que X está muy cerca de la Z, pero además se que hay muy poca palabras que empiecen por X en el diccionario.

Las BBDD también hacen esto... GILIPOLLAS NO SON: Para ello usan el concepto de ESTADISTICAS de tabla!
Y una operación TIPICA DE MNTO /ADMIN de BBDD es regenerar de vez en cuando las estadísticas de tabla (o no).

Tengo una tabla con 30000 DNIs... Y me entran otros 200.000 DNIs... Merece la pena regenerar estadísticas? POSIBLEMENTE NADA 
Los DNIS van de 0 al 9... Y si me han ido metiendo a lo largo del usu del sistema en 1 año: 30000 DNIS ya irán siguiendo la misma distribución que los 200.000 que me acaban de meter. 
    10% de DNIs que empiezan por 0, 10% de DNIs que empiezan por 1, etc. y hasta el 9.
    Y carga todos los DNIs que quieras, que esto no cambia.

Tengo una tabla con la columna FECHA DE ALTA... Y tengo 1M de registros... Y meten otros 10.000 registros... Regenero estadísticas? YA VES
Las fechas nuevas NO EXISTIAN ANTES !

Una buena administración de una BBDD implica conocer la NATURALEZA DE LOS DATOS que guardamos en ella. Y programo regeneración de estadísticas de las COLUMNAS que necesito.

PROBLEMA !!!! IMPORTANTE !!!!

Hemos dicho que en los índices guardamos los datos PREORDENADOS.. ya en su ubicación concreta y acertada... DONDE DEBEN IR...
Pero el indice al final es otra secuencia de bytes en un fichero... Va a haber hueco? donde meter el nuevo dato que me acaban de insertar en la BBDD en el fichero del INDICE?

Las BBDD dejan UN HUEVO (o ninguno, depende de cómo lo configure) ESPACIOS EN BLANCO Prereservados en el fichero de índice para poder meter nuevos datos. FILLFACTOR: 
- Puedo ponerlo en un 70% dejando un 30% de hueco en blanco en el fichero de índice para poder meter nuevos datos.
- Puedo ponerlo en un 95% dejando un 5% de hueco en blanco en el fichero de índice para poder meter nuevos datos.
- Puedo ponerlo en un 100% dejando un 0% de hueco en blanco en el fichero de índice para poder meter nuevos datos.

Cuanto menor sea el FILLFACTOR, más hueco en blanco dejo en el fichero de índice para poder meter nuevos datos. Y MAS ESPACIO DE ALMACENAMIENTO NECESITO. Y más necesito leer del HDD para cargar el índice en memoria.
Pero como sea, al final se llenará el fichero. y entonces... problemón. La BBDD va a generar otrá página de datos.. Y posteriormente tendrá que REORDENAR EN RAM todos los datos, cuando se lea los bloques del fichero de índice.
Y si me ocurre esto, el rendimiento se ve comprometido (Ya no es una Búsqueda binaria... son varias en cada trozo de índice que tengo que leer)
Y OTRA TAREA TIPICA DE MNTO / ADMIN de BBDD Es la regeneración de los índices!
Se vuelven a reescribir los ficheros de índices (páginas) rejuntando datos que debían estar juntos pero estaban en bloques distintos...
Y Dejando nuevos espacios en blanco.

LAS BBDD necesitan MNTO y ADMINISTRACION. Y si no se hace, el rendimiento se va a la mierda.

PREGUNTA ADICIONAL: De quién es responsabilidad la creación de INDICES (desarrollo o administración de BBDD)?
- Del que diseña el modelo de datos / Desarrollo
- Ambos

El desarrollador NO TIENE NI PUTA IDEA de las búsqueda que los USUARIOS HARÁN EN EL SISTEMA.. Ni de la cantidad de datos que realmente habrá en el sistema. Podrán hacer SU CUTRE PREVISION... CUTRE A MAS NO PODER !!! Pero hasta ahí.. Y en base a esa CUTRE PREVISION crear unos CUTRE INDICES que quizás sirvan para algo o no.

WORDPRESS (para montar páginas WEB)
Sé el uso que van a hacer los clientes (usuarios de mi página web)

Da igual de qué hablemos. El punto con independencia de quién lo haga (que será un tema procedimiental de una empresa) es que los datos SALEN DE MONITORIZACION!!! Y es la única fuente de verdad.

Habrá datos en BBDD -> ETL -> DataLake (Datawarehouse)
Se irán cargando datos
Los usuarios a los que se les habrá puesto uin formulario para que busquen por 50 campos distintos... Y los usuarios buscarán por 2 campos distintos.
Luego estarán los enemigos de las BBDD (Los de BI) que tiran los destrozaqueries gigantescos.

Para asegurar que las actualizaciones no impactan gravemente en los índices necesito configurar un FILLFACTOR también a nivel de tabla.
Y le digo: Deja libre el 10% de la página de datos (8Kbs) para cuando vengan actualizaciones, que nos aseguremos (o lo intentemos) que entran en la misma página de datos.

Es imposible (para administradores de BBDD y para desarrolladores) prever el uso que se le va a dar a la BBDD. Y por eso es importante la monitorización.

AQUI HAY 2 estrategias:
- Mnto correctivo: Cuando la BBDD va lenta, investigamos
- Mnto preventivo: Regenerar estadísticas, regenerar índices, los propios ficheros de la BBDD, etc. <- MONITORIZACION
- Mnto predictivo: Monitorización de la BBDD para ver si se está acercando a un límite de rendimiento.

Aquí hay otra opción, que últimamente está muy de moda: FUERZA BRUTA! Mete recursos a la BBDD hasta que vaya rápido y los ADMINISTRADORES DE BBDD A LA PUTA CALLE ! POR DESGRACIA ESA LA TENDENCIA! : CLOUD!
---

## MAS SOBRE ORGANIZACION DE DATOS

A nivel de cada columna de cada tabla podemos elegir entre varias opciones de almacenamiento:
- PLAIN (por defecto)   Esto almacena la columna dentro del propio bloque de datos de la tabla (página de datos).
- EXTERNAL              Almacenar esa columna en un bloque de datos distinto (página de datos distinta)
                            Cuando tenemos campos GRANDES (text, json, bytea, etc.) que pueden:
                            - Ocupar mucho y llenarme la página de datos
                            - Sujetos a actualizaciones frecuentes
- EXTENDED              Igual que el external pero con compresión
                            Igual que el anterior, si ocupan mucho y se consultan poco (la compresión tiene un impacto en rendimiento: CPU) 
- MAIN                  Igual que el PLAIN pero con compresión (siempre que entre, sino a otro bloque de datos)

```sql
CREATE TABLE Tabla1 (
    id serial PRIMARY KEY,
    nombre varchar(100) STORAGE PLAIN,
    biografia text STORAGE EXTERNAL,
    certificadoEstudios bytea STORAGE EXTERNAL
) WITH(FILLFACTOR = 90);

CREATE INDEX idx_tabla1_nombre ON Tabla1(nombre) WITH(FILLFACTOR = 90);
```

---
# Indices en PostgreSQL:

Hay 3 grandes tipos:
- B-Tree (El que hemos hablado antes). Nos permiten hacer búsquedas binarias. Son los más comunes.
  - Tengo que indexar el campo: NOMBRE DE LA RECETA: "Tortilla de patatas"
    Puedo usar estos índices para:
        - IGUALDAD: WHERE nombre = 'Tortilla de patatas'
        - MAYOR QUE: WHERE nombre > 'Tortilla de patatas'
        - MENOR QUE: WHERE nombre < 'Tortilla de patatas'
        - MAYOR O IGUAL QUE: WHERE nombre >= 'Tortilla de patatas'
        - MENOR O IGUAL QUE: WHERE nombre <= 'Tortilla de patatas'
        - RANGO: WHERE nombre BETWEEN 'Tortilla de patatas' AND 'Tortilla de patatas con cebolla' 
        - ESTOS TAMBIÉN SIRVEN PARA LIKES, los LIKES QUE ESTÁN PERMITIDOS:
          - WHERE nombre = 'Tortilla de patatas%'
          - WHERE nombre = '%Tortilla de patatas%' \
          - WHERE nombre = '%Tortilla de patatas'  / No aprovechan mucho el índice
                                    Se hará un fullscan del índice muy probablemente 
- Hash: Es igual a los BTree, pero en lugar de guardarse el valor del campo en el índice lo que se guarda es una huella (HASH del valor)
  Puedo guardar una huella del valor "Tortilla de patatas" en el índice: 1234567890
  Esto me permite: Aunque el valor sea muy grande, su huella es pequeña.: Ocupa menos el índice
  Las comparaciones son más rápidas: Comparo la huella del valor que busco con la huella de los valores del índice
  CUIDADO, también tiene limitaciones:
    SOLO PUEDO USAR INDICES DE TIPO HASH para: IGUALDAD o DIFERENCIA
- Índices INVERSOS/Invertidos: GIN (son los típicos que usamos para búsquedas de texto completo)
  Y qué pasa con estas búsquedas?
          - WHERE nombre = '%Tortilla de patatas%'
          - WHERE nombre = '%Tortilla de patatas'
    Para búsquedas a texto completo REALMENTE POTENTES, una BBDD no me vale. Tendría que usar un motor de búsqueda (ElasticSearch, Solr, etc.)
    Si no necesito tanta potencia:
        - ORACLE: Oracle Text
        - SQL Server: FullText
        - Postgres: GIN
    
    Recetas de cocina:
    - Tortilla de patatas
    - Tortilla de patatas con cebolla
    - Tortilla de patatas con cebolla y pimientos
    - Bacalao con patatas
    - Bacalao con patatas y pimientos
  
    En lugar de indexar los valores, que no me vale para búsquedas a texto completo:
    1º Separar los tokens: Tortilla, de, patatas, con, cebolla, y, pimientos, Bacalao a nivel de cada valor:
        - Tortilla-de-patatas
        - Tortilla-de-patatas-con-cebolla
        - Tortilla-de-patatas-con-cebolla-y-pimientos
        - Bacalao-con-patatas
        - Bacalao-con-patatas-y-pimientos
      * Esto puede ser complejo: (espacios, puntos, comas, etc.) 
    2º Normalizar los tokens: Ignorar mayúsculas, no quiero acentos:
        - tortilla-de-patatas
        - tortilla-de-patatas-con-cebolla
        - tortilla-de-patatas-con-cebolla-y-pimientos
        - bacalao-con-patatas
        - bacalao-con-patatas-y-pimientos
    3º Aplicar un diccionario de palabras VACIAS DE SIGNIFICADO DE CARA A UNA BUSQUEDA (depende del idioma):
        - tortilla-*-patatas
        - tortilla-*-patatas-*-cebolla
        - tortilla-*-patatas-*-cebolla-*-pimientos
        - bacalao-*-patatas
        - bacalao-*-patatas-*-pimientos
    4º Indexo cada token
        - tortilla      1(posición 1) 2(posición 1) 3(posición 1)
        - patatas       1(posición 3) 2(posición 3) 3(posición 3) 4(posición 3) 5(posición 3)
        - cebolla       2(posición 5) 3(posición 5) 
        - pimientos     3(posición 7) 5(posición 5)
        - bacalao       4(posición 1) 5(posición 1)
    ESO ES LO QUE SE INDEXA.
    Cuándo se hace una búsqueda, al término de búsqueda se le aplica el mismo proceso:
        - TORTILLA CON PATATAS -> [tortilla, patatas] Y SOBRE ESO SE HACE BUSQUEDA BINARIA
    
    En función de la herramienta, tenemos más o menos funcionalidad:
        ORACLE: Quiero que quites los plurales, o el género, o las conjugaciones verbales
        ELASTIC va a más: Quiero que te quedes con la raíz etimológica de las palabras
            tortillita -> tort-

    El generar un índice inverso es un proceso muy costoso. Y por eso no se hace en tiempo real. Se suele hacer de forma asíncrona.

    En postgres luego tendremos algunas cosas especiales en este sentido:
        - Trigramas: Tengo códigos de piezas: 1294absj3746:
            extrae trigramas: 129, 294, 946, abs, bsj, sj3, j37, 374, 746
            E indexa cada cosa por separado: LIKE '%294294%' 
---

# Procesos a nivel de SO.

Cuando ejecuto un programa, el SO levanta un proceso asociado a ese programa.
Al proceso se le asociada una:
- cantidad de memoria RAM
- Le permitiremos usar CPU

Mi proceso es el que va pidiendo recursos al SO para hacer su trabajo.

## Para qué usa un proceso la memoria RAM?

- Para el propio código del programa
- Para la pila de ejecución de hilos (STACK de cada hilo) 
- Para guardar los propios datos de trabajo (VARIABLES con sus datos, ORDENACIONES, etc.)
- Para tener un acceso más rápido a ciertos datos : CACHE

Quien lleva la carga de trabajo a la CPU es un hilo de ejecución. Un proceso puede tener varios hilos de ejecución trabajando en paralelo sobre los datos.

## Para qué usa el SO la memoria RAM?

- Para sus propios datos/programas (control de los procesos, control de la memoria, control de la red, etc.)
- Para entregar memoria a los procesos que la pidan
- Control de interrupciones de los elementos de hardware
  - Cuando llega un paquete de red, el SO lo recoge y lo mete en la memoria RAM
  - Cuando llega un paquete de disco, el SO lo recoge y lo mete en la memoria RAM
  - Cuando llega un paquete de teclado, el SO lo recoge y lo mete en la memoria RAM
  - Cuando quiero pinta en pantalla, el SO coge los datos de la memoria RAM y los pinta en pantalla
- Para hacer CACHE de operaciones realizadas a nivel de SO:
  - Leo un fichero de disco, lo meto en la memoria RAM

# Tenemos una BBDD Corriendo en un servidor.

Al final, un proceso con su RAM y uso de CPU, controlado por el SO.
Y vamos a querer abrir conexiones contra la BBDD.
Qué implica abrir una conexión contra una BBDD abajo nivel?
- Se va a abrir un proceso nuevo?
- Se va a abrir un hilo de ejecución nuevo?

Se abre un proceso nuevo a nivel de SO, con su propia reserva de RAM.

Desde el punto de vista de desarrollo, en mi app, para conectarme a la BBDD abro una conexión (y en mi app la gestiono mediante un hilo de ejecución). A nivel de BBDD se abre un proceso nuevo: Y ESTO SON PALABRAS MAYORES.

Por eso, abrir una conexión es algo que tarda tiempo... y solemos configurar un POOL DE CONEXIONES PRECREADAS: En lugar de abrir y cerrar conexiones, las abro y las dejo abiertas. Y las reutilizo.

Eso implica que lo primero es meter el código del programa en RAM ... otra vez! Por eso que desde BBDD me limitan mucho el número de conexiones que puedo abrir.

Los procesos que tengo en un SO pueden compartir información. Una de las misiones de los SO es ofrecer mecanismos para que los procesos compartan información:
- Shared Memory (Se comparte una región de memoria RAM directamente entre procesos): RAPIDO (Más rápido que cualquier otra cosa) Pero a su vez peligroso. Esto está muy controlado: Los procesos internos de BBDD: Cada conexión desde el punto de vista de la BBDD es un proceso distinto. Pero los procesos internos de la BBDD comparten información entre ellos a través de la memoria compartida.
- Puertos de comunicación: TCP/IP, UDP, etc. (Más lento que la memoria compartida, pero más seguro, y además incluso permiten a procesos en distintos SOs comunicarse): CONEXION desde un cliente a una BBDD
- Sockets UNIX: Para procesos en el mismo SO
- Portapapeles: Para procesos en el mismo SO
- Pipes: Para procesos en el mismo SO

## En el servidor, habrá un proceso de BBDD corriendo.

Y ese proceso necesitará RAM. Para qué usa el proceso principal de la BBDD la RAM?
- Datos de los procesos de las conexiones
- CACHE (páginas de datos)
- Mnto de la BBDD:
  - Reescribir índices
  - Regenerar estadísticas
  - Reescribir los ficheros de las tablas
- Intercambio de información con BBDD cuando opere en modos HA (espejo)
- Backup/Recovery

Además, ese proceso irá abriendo otros procesos (para cada conexión) y cada uno de esos procesos necesitará RAM. Para qué usan la RAM los procesos asociados a conexiones de la BBDD?
- Trabajos asociados a las consultas que se hagan
- Cache de planes de ejecución de consultas
- Cache de consultas preparadas

Ambas van a compartir una zona de la RAM: CACHE de páginas de datos.

Aquí nos salen las zonas de memoria principales que configuramos en cualquier BBDD y especialmente en Postgres:
- shared_buffers: Zona de memoria compartida entre todos los procesos de la BBDD. 
                  Aquí se guardan las páginas de datos que se leen del fichero de la BBDD de uso frecuente.
                  Lo que quiero que use realmente la BBDD para cache: TABLAS y de ÍNDICES: 
                  Está en el orden de los Gigas
- effective_cache_size:  ESTIMACION de la cantidad de memoria RAM total (incluyendo la del SO) para CACHE de páginas de datos.
                    Esto lo usa el planificador de queries para decidir si un plan de ejecución va a tener mucho impacto en disco o no.
                    Suele estar entre un 50-75% de la RAM del servidor
- work_mem: Zona de memoria que se reserva para cada proceso de conexión para hacer operaciones de ordenación, agrupación, etc.
            Si hago un ORDER BY, un GROUP BY, un DISTINCT, etc. y no tengo índices que me ayuden, necesito ordenar los datos en RAM.
            Si se agota la memoria RAM, se tirará a disco.... e irá lento.
            Esto está en el orden de los Megas
- maintenance_work_mem: Zona de memoria que se reserva para cada proceso de conexión para hacer operaciones de mantenimiento de la BBDD.
                        Si tengo que regenerar un índice, regenerar estadísticas, reescribir un fichero de tabla, etc.
                        VACUUM, ANALYZE, REINDEX, etc.
                        Puede estar en el orden del Giga
- wal_buffers: Se dedican a los WAL (Write Ahead Log ~ Archive log)

    Cada operación que provoca cambios en los datos, se guarda en el WAL antes de aplicar los cambios en la BBDD:
      - INSERT en la tabla noseque
      - UPDATE en la tabla noseque
      - DELETE en la tabla noseque

    Si hay una catastrofe, puedo restaurar la BBDD a un momento anterior mediante un restore de un backup y después aplicarl los WALs que se han generado desde ese backup hasta el momento que me interese.

    Esto es algo que de serie va en los entornos de producción:
    - PRIMERO: Restores a momentos discretos en el tiempo
    - SEGUNDO: Para sincronizar los datos entre los nodos de un entorno HA
        Postgres MAESTRO  ---> Postgres ESPEJO (mirror)

    Suele estar en poco Mbs
- temp_buffers  Se usa por las conexiones para guardar datos temporales (tablas temporales, ordenaciones temporales, etc.)
                Puede estar en el orden de los pocos Mbs    


UNO DE LOS DATOS IMPORTANTES DE CARA A MONITORIZAR UNA BBDD ES EL HIT RATE DE LA CACHE: Cuántas veces he tenido que ir a disco a leer una página de datos porque no estaba en la CACHE.
Imaginaos una situación donde vea problemas de rendimiento en mi BBDD (las queries van muy lento) y veo que tenemos un problema con el HIT RATE de la cache. Soluciones / Cosas que podemos hacer(o seguir mirando):
- El effective_cache_size está mal configurado (No represente la realidad) pero no es algo que pueda subir (lo puedo ajustar a la realidad). Puedo mirar a nivel de SO, cúanta RAM hay disponible y cúanta se está usando de cache (free)
  Subir el dato implica METER RAM! y puede ser una solución!
- Necesito subir cache: MAS RAM y aumentar:
  - shared_buffers (Quieres permitir a la BBDD que mantenga en cache lo que más usa)
  - effective_cache_size ESTA NO LA GESTIONA LA BBDD (una parte quieres que sea asi)
- Puede ser que las páginas de datos tengan muy pocos datos UTILES (De esos marcados para eliminación) (FRAGMENTACION DE LOS FICHEROS DE BBDD) -> Compactar los ficheros de la BBDD (reescribirlos): VACUUM
   
- Puede ser que faltan índices y cada query tenga que hacer un FULL SCAN y necesite traer la TABLA entera a RAM
- Problema con las queries









---

Los SORT Son muy peligrosos... y el problema es la cantidad de SORT ENCUBIERTOS:
- Order By
- Group By
- Distinct (Sort por todos los campos)
- Union -> Distinct
  - Union ALL: ES GENIAL (No hace distinct)

---

# Algoritmo de huella (HASH)

Habéis usado algoritmos de huella desde que tenéis 10 años. LETRA DEL DNI

    Letra del DNI? 23000012N

    23000012 |  23 
             +--------
          12   1000000
          ^
          RESTO de la división entera: 0-22 Y el ministerio publica una tabla con las letras que corresponden a cada resto.

Un algoritmo de huella: Dado un dato de entrada, genera un valor de salida de forma que:
- Para el mismo dato de entrada, siempre genere el mismo valor de salida
- La probabilidad de colisión (2 datos de entrada distintos que generen el mismo valor de salida) sea "aceptablemente" BAJA.
    1/23 ~ 4% de colisión
    En informática solemos usar algo más grande que 1 entre billones o incluso trillones: SHA-2048
- No pueda regenerar el dato de partida desde el valor de salida (NO REVERSIBLE)
  La huella es un resumen del dato de entrada.


En informática solemos generar números como valores de salida.

---

# Almacenamiento

¿Eso es barato? EN UN ENTORNO DE PRODUCCION ES CARO DE COJONES... DE LO MAS CARO QUE HAY!!!
Por qué? De entrada por que buscamos almacenamientos de calidad distinta a los que usamos en nuestro PCs, portátiles o casa.
Una calidad buena x3 precio MINIMO.

Hay otros problemas gordo: HA, Backups, Índices


---

# Entornos de producción

- HA: Alta disponibilidad:
    Intentar garantizar un determinado tiempo de respuesta firmado contractualmente.
    Garantizar la NO PERDIDA DE INFORMACIÓN:
        - Actual, para poder seguir prestando servicio: REDUNDANCIA: RAID, CABINAS. x3
                1 Tbs de datos (en prod -> 3 Tbs).. y ojo, 3 Tbs de los caros (no de los western blue)
        - Pasada. Si alguien mete la pata con los datos, pueda recuperarlos (BACKUP/RECOVERY) x LO QUE QUIERA EL ALMACENAMIENTO
- Escalabilidad