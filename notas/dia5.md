# Instalación MAESTRO / REPLICA

    2 Servidores Postgresql
        Maestro <- INSERT / CONSULTAS
        
        Replica ? para qué?
            - Queries / CONSULTAS (quitar trabajo al maestro)
            - Tener una alternativa de maestro / caso que el maestro muera <- HA
            - Tener una alternativa de maestro / caso que el maestro muera / CONSULTAS
                ESTA ES RARA! -> Si se cae el maestro.. la replica va detrás!
                
Si he montado un servidor especial REPLICA para consultas es porque porque el primario no da a basto.
En este escenario... si se cae el maestro, la replica debe asumir la carga de trabajo que tenía antes el maestro
y la replcia...
Y NO VA A DAR A BASTO.. De hecho si diera a basto... para qué monté una raplica para queries?
La HA es muy jodida.

Yo ya os comenté que en postgres es poco habuitual (cada vez menos) montar replicas para HA. 
    - Es un follón.
    Por un lado los datos los tengo a salvo (cabina con almacenamiento redundante)
    Si se ROMPE el servidor, tardo menos en poner uno nuevo a funcionar:
    - VM: 30 seg. 1 min.
    - Contenedor: < 10s
    
    Promocionar una replica a maestro implica que el maestro está pedido definitivamente.
    Hay que regenerarlo entero y ponerlo como replica. Esto es lo más sencillo en este escenario.
    Regenerar el maestro como maestro < - REPLICA
    Regenerar la replica como replica!
Las montamos mucho para ESCALABILIDAD (Más queries)

En nuestro caso, por falta de recursos (es un curso) Tenemos una máquina.
Para simular 2 máquinas:
    - Instalación HIERRO
    - Instalación Contenedor
    
Esto no tiene mucho sentido en un entorno de producción (NINGUNO).
Es decir, lo que quiero son 2 instalaciones IGUALES para esto... si no, me pongo piedras en el camino.
No tiene por que tener los mismos recursos

Lo ideal es tener un fichero de configuración UNICO para todos los servidores!
Si no es un follón el mnto. En nuestro caso, como tenemos instalaciones MUY DIFERENTES, no podemos trabajar con un fichero único.
    Y CUIDADO! Nada impide que en cada servidor tenga un ficherito adicional con algunas propiedades sobreescritas.
    Servidor de queries: MAS O MENOS RAM
    
Al generar una replica, ya vimos ese fichherito que informa al servidor postgres de que eestá lidiando con una replica!


En un entorno de producción a nivel de los hosts: PRIMARIO / REPLICA:

3 interfaces de red:
- Servicio          3 Vlans
- Replicación
- Administración
 
---

Hemos montado Maestro / Replica
- Tener un nodo en reserva para que entre en maestro si se cae el que hay
    Necesito una VIPA (Keep alived) IP Virtual dada de alta en el maestro
    Todo el mundo trabaja contra esta IP.
  Tengo un programa adicional que va monitorizando el maestro y si en algun momento se cae ->
     Activa la IP Virtual del segundo nodo y lo promociona
     En el momento que esto ocurre (PROMOCION (pg_promote())) ES IRREVERSIBLE

    Voy a conseguir con esto mejor tiempo de Servicio que con lo que os comentaba antes?
        Reiniciar una máquina/contenedor NUEVO con el mismo volumen de datos que el antiguo?
    ESTO OFRECE UN TIEMPO EN LA PRACTICA MUCHO PEOR:
        - El activar la VIPA y el pg_promote () es instantaneao...
        - El problema es CUANDO TOMO LA DECISION DE HACER ESO?
            - Si el servidor no contesta en 3 segundos, lo hago? Y puede ser que solo esté un poco apretado...
            - O quizás tengo la red un poco apretada... o ha fallado un switch... y se ha reiniciado.


- Tener un nodo adicional para CONSULTA (NO INSERTS... NI UPDATES)

Lo que hemos montado es lo que llamamos una replicación FISICA!
PostgreSQL soporta REPLICACION LOGICA... es otra estrategia diferente!
La física va mucho más rápido... La lógica es mucho más flexible

Esto es equivalente a los backups: FISICOS o LOGICOS

REPLICACIONES LOGICAS: 

Con ellas lo que hacemos es tener la posibilidad de sincronizar tablas sueltas, no ya un servidor completo. o BBDD sueltas

CREATE PUBLICATION (a nivel del maestro)

> CREATE PUBLICATION replicacion_bbdd_1 FOR ALL TABLES;
> CREATE PUBLICATION replicacion_bbdd_1 FOR TABLE tabla1, tabla2;

A nivel del replica (que ya no es REPLICA en el sentido de las replicas FISICAS, sino es sol otra BBDD progres independiente;

> CREATE SUBSCRIPTION replicacion_bbdd_1
  CONNECTION 'user=replicator password=password host=172.31.38.8 port=5432 dbname=postgres ... sslmode=prefer sslnegotiation=postgres sslcompression=0 sslcertmode=allow sslsni=1 ssl_min_protocol_version=TLSv1.2 gssencmode=prefer krbsrvname=postgres gssdelegation=0 target_session_attrs=any load_balance_hosts=disable'
  PUBLICATION replicacion_bbdd_1;



primary_conninfo = 'user=replicator password=password channel_binding=prefer host=172.31.38.8 port=5432 sslmode=prefer sslnegotiation=postgres sslcompression=0 sslcertmode=allow sslsni=1 ssl_min_protocol_version=TLSv1.2 gssencmode=prefer krbsrvname=postgres gssdelegation=0 target_session_attrs=any load_balance_hosts=disable'
primary_slot_name = 'replica3'


---

# TENER UNA POLITICA DE DISASTER RECOVERY: Backups & RESTORE

- Backups en FRIO / CALIENTE: BBDD esté prestando servicio o no
- 3 niveles de backup (COMPLETO, INCREMENTAL, WAL)
- Físicos / Lógicos (Trabajo a nivel de ficheros en SO | DATOS)

Si puedo elegir, lo mejor sin diferencia es Backup en FRIO/FISICO/COMPLETO:
- Copiar los ficheros del directorio

El tema es que si puedo hacer eso, en postgres:
- Copiar los archivos
- Si trabajo con almacenamiento externo: En cabina: SNAPSHOT en la cabina del volumen.

El problema es que no siempre podemos: Si tengo una BBDD que debe prestar servicio 24x7...
Aunque en ese caso, quizás postgres... no sería mi BBDD! posiblemente!

Necesidades de almacenamiento: Si tengo una BBDD de 50Gbs... 10Tbs copia completa??? de todo?? en serio?

Cuántas copias quiero? Con 1 me vale? En las políticas de backup, 
- queremos poder restaurar la BBDD a un momento del tiempo concreto que me de la gana de las ultimas N Unidad de tiempo.
   Quiero poder restaurar hasta 3 semanas atrás.   <--- PASTA !!!! Almacenamiento
        Necesito incrementales


En postgres tenemos el comando pg_basebackup -> Copias de seguridad en caliente!
Hasta pg17 SOLO HACIA BACKUPS COMPLETOS = MIERDA !!!!
Desde pg17 YA PERMITE INCREMENTALES = ALELUYA !!!!!!!
    pg_basebackup --incremental ARCHIVO_DE_MANIFIESTO_DEL_BACKUP_ANTERIOR
    pg_basebackup --incremental /var/backups/anterior/backup.manifest
pg_basebackup hace copia a nivel físico.. NO LOGICO.

Hay casos donde los backups FISICOS NO ME SIRVEN y quiero LOGICOS (DATOS):
- Si quiero solo 1 BBDD de mi servidor
- Si quiero solo 1 o n tablas
- Si quiero intentar llevar los datos a un postgres en otra versión diferente
Backup lógico -> SQL (INSERT INTO TABLA () VALUES();)
- Esta forma (BACKUP LOGICO) siemrpe es mas lento que el físico:
    - pg_dump
    - pg_dumpall

Además de todo esto, tenemos los WAL.

pg_basebackup lo que hace es, cuando se solicita un backup deja de escribir a disco todas las operaciones...
SOLAMENTE SE VAN GUARDANDO EN LOS WAL! para poder asegurar la integridad de los datos.
Una vez acaba el backup procesa los WAL (aplica en fichero las operciones que se hayan ejecutado mientras se hacía el backup)
De ahí viene que cuando esta mañana hicimos el backup, le pedimos que incluyera los WAL

        wwwwwww escribe en los wal wwwwwwwwwwww wwwwww sigue escribiendo en wal wwwww
        <------tiempo de backup--------------->
    ------------------------------------------------------------------------> TIEMPO
      ^... no escribe en fichero de bbdd.....^(2)
        HAZ BACKUP                             ^
        (1)                                 Acaba el backup
                                            Los wal los aplica 
                                            Y opcionalmente me los guarda en el backup

Si he guarddo los WAL puedo restaurar al momento (2)
Si no he guardado los wal, puedo restaurar al momento (1)

Los WAL a priori no se van guardando... hemos de solicitar su archivado.
Si los archivo, podre hacer restore a cualquier momento del tiempo... pero VETE PREPARANDO HDD €€€€€€€€€€

Luego está la restauración. 
Si lo que tengo es un backup completo... Recopiar los archivos al so.
Si quiero restaurar con wal... Eso es otra cosa!
Con BBDD parada: Configuro: Archive Recovery + Recovery Target
Reinicio BBDD y a cruzar los datos

Con pd_dump puedo restaurar con psql (cliente de postgres)... son SQL 
psql -f FICHERO.dump

pg_dump tiene varios formatos de exportación: PLAIN... SQL (este es el que puedo restaurar con psql)
Luego tiene otros formatos: directory, custom... Para estos, restauramos con pg_restore
ps_restore -F c FICHERO.dump
              d

Ya, desde pg17: 
pg_basebackup completos: 1 vez en semanas
pg_basebackup incrementales: 1 vez al día
wal.

Me puede interesar guardar esos por separado durante un tiempo (3 semanas... necesito TODO 3 semanas)


 |-----*-----*------*-----|-----*-----*------*-----|-----*-----*------*-----|-----*-----*------*----->AHORA
 
 | = COMPLETO
 * = INCREMENTAL

Las restauraciones son complejas:
- Necesito restaurar el ultimo COMPLETO antes de la fecha a la queiro restaurar
+ Los incrementales desde ese completo hasta la fecha a la quiero restaurar
+ WALs desde es incremental hasta la fecha a la quiero restaurar



---

Hoy en día muchos frameworks de desarrolle me permiten sin esfuerzo ninguno configurar una:
BBDD de consultas y una BBDD de actualizaciones
    ^^^                        ^^^
    ^^^                        No meto indices de búsquedas (SUPERRAPIDA)
    Si meto indices de búsquedas
    
---

MAESTRO
  VV
REPLICACION FISICA (Lo configuro para las busquedas)
  VV
 BACKUPS
 
 
----
 
CITUS (postgres vitaminado para entornos distribuidos...
lo que me da son 500 procedimientos creados PLSQL por la gente de CITUS+ PROXY REVERSO)
 
MEGATABLA VISUALIZACION:
Le hago 2 particiones

        ALGUEN DELANTE QUE DECIDA A QUE SERVIDOR LO MANDA (UNA QUERY)

    SERVER 1                        SERVER 2    
    visualizaciones                 visualizaciones
     visualizacionesA*      ---->       visualizacionesA
     visualizacionesB       <----       visualizacionesB*
     
     NO ES UN CLUSTER ACTIVO ACTIVO REAL... pero casi.
 
 REPLICACION BIDIRECCIONAL AVANZAD con tablas preparticionadas.