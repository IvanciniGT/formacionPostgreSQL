# Problemas de rendimiento

## QUERIES

Si las queries no están bien planteadas apaga y vamonos!

EVITAR SORT:
    - Minimizando el uso de DISTINCT, GROUP BY, UNION, ORDER BY

Usar apropiadamente las funcionalidades que me da la BBDD:
    - Indices inevrsos (TRIGRAMAS,..)
        NO  unaccent(lower(TITULO)) LIKE unaccent(lower('mi titulo'))

## INDICES

Revisar los índices: LA DEFINICION INICAL NO VALE!!!!
    - MONITORIZACION
        - Eliminar los que no se usan
        - Crear los que puedan ser necesarios

^^^ CON ESO DE ARRIBA lo que mejoro es la forma de ejecutarse la query (ESTRATEGIA QUE PLANTEARA EL PLANIFICADOR y que EJECUTAR EL MOTOR DE EJECUCION DE QUERIES)

## ESTADISTICAS

Influyen también (aunque un poco menos)

---
vvv Una vez tengamos una estregia GUAY !

## LECTURAS A DISCO

Son lentas a no poder más. No es lo mismo leer de RAM que de disco.
USO DE LA CACHE... quiero ver si es eficiente. Si me sale un valor: RATIO DE HIT EN CACHE > 80-85% DPM!

Si veo que eso no se cumple y tengo un ratio de cache más bajo... tengo un problema aquí: PUEDO MEJORARLO

DONDE PUEDE ESTAR EL PROBLEMA:
- Páginas medio vacias debido a:
    - TENGO CONFIGURADO UN FILL_FACTOR MUY GRANDE (EN TABLAS O INDICES) 5%-10% (depende de cada cuanto pueda lanzar VACUUM y cuánto tarden)
- Páginas llenas de MIERDA! (TABLAS O INDICES) (DEAD TUPLES) -> Incrementar la frecuencia de VACUUM... estrategias:
    - Particionados de tablas 
        - quizás algunas las puedo ir cerrando... y al cerrarlas hago vacuum
        - A lo mejor no puedo cerrar tablas. Al menos poder repartir los vacuum (más pequeños, menos tiempos de bloqueo)
- TENGO POCA MEMORIA para la cache:  (25%-40%)... Me toca subirlo... y LA RAM (física) DE LA MAQUINA


--- 

Cuando metemos datos en tablas (INSERT) Las tablas no van teniendo NINGUN TIPO DE FRAGMENTACION.. 
añado cosas al final de una página...
Se llena... pues a otra página.

Cuando vamos haciendo esos INSERTS y se van cargando INDICES, los indices SI SE GENERAN YA CON FRAGMENTACION

---

TODO ESTO DE ARRIBA LO HAGO SI VEO QUE EL RENDIMIENTO DE LA BBDD SE VA DEGRADANDO 
o DE PARTIDA NO ES BUENO... PERO EN GENERAL (da igual la operación)

Otro tema distinto es que VEA QUE DE VEZ EN CUANDO LA BBDD se queda apretada!
SUELE IR "BIEN" (el bien que sea) pero de vez en cuando SE JODE EL RNDO... y luego vuelve.


Qué puede estar pasando por aquí? RAM / CPU / DISCO (Swapping)
- QUERIES PUNTUALES (el flipado de BI)
- Trabajos de mantenimiento
    - CPU (JODIDO VOY)
    - RAM (garantizar la suficiente)
            Garantizar suficiente RAM por conexión (maintenance_work_mem) para evitar swapping
    - ESPACIAR MAS LOS TRABAJOS DE MNTO
- Muchas consultas simultaneas: 
    - RAM:  TENGO LA CONFIGURACION HECHA UN DESMADRE:
            Cuando he configurado el fichero de la BBDD con 
            el número de conexiones y el tamaño de RAM de cada conexión (work_mem / temp_mem)
        # conexiones * (work_mem + 0.1*temp_mem) + shared buffers + maintenance + wal < 60%
            Garantizar suficiente RAM por conexión (work_mem) para evitar swapping
    - Si tengo problema en CACHE ... me falta RAM.
    - CPU: Si me meten muchas ordenaciones... joins... y mierdas... me pulo la CPU
            Establecer un buen ratio CPU/RAM Monitorización       
