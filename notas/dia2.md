# Entornos de producción

- HA: Alta disponibilidad:
    Intentar garantizar un determinado tiempo de respuesta firmado contractualmente.
    Garantizar la NO PERDIDA DE INFORMACIÓN:
        - Actual, para poder seguir prestando servicio: REDUNDANCIA: RAID, CABINAS. x3
                1 Tbs de datos (en prod -> 3 Tbs).. y ojo, 3 Tbs de los caros (no de los western blue)

    Partiendo de la premisa que un 100% no es posible garantizarlo, vamos a medirlo en nueves:
    - Te voy a garantizar un 90% de tiempo de disponibilidad: 36,5 días al año el sistema offline: BLOG con mi familia  | €
    - Te voy a garantizar un 99% de tiempo de disponibilidad: 3,65 días al año el sistema offline: Peluquería           | €€€
    - Te voy a garantizar un 99,9% de tiempo de disponibilidad: 8,76 horas al año el sistema offline: Web del mercadona | €€€€€€€€
    - Te voy a garantizar un 99,99% de tiempo de disponibilidad: 52,56 minutos al año el sistema offline: Hospital      | €€€€€€€€€€€€€€€
                                                                                                                        v

    Esas cifras solo son indicadores de lo critico que es un sistema. Y en base a esa criticidad tomaré unas u otras medidas para intentar garantizar ese tiempo de disponibilidad.

- Escalabilidad: Ajustar la infra a las necesidades que voy teniendo en cada momento.
  Las BBDD son programas muy especiales, raro es que de un momento para otro necesiten menos recursos (CPU, RAM, DISCO)
  pero lo que no le pasa nunca es que bajen DISCO (al menos de forma sostenida en el tiempo)

    Los datos no los quiero eternamente en la BBDD de producción.
        BBDD de producción -ETL-> Datalake --> Datawarehouse <-- BI + Machine Learning + Data mining

  En el caso de las BBDD: 
    - Escalabilidad vertical: Más CPU, más RAM, más DISCO [OK]
    - Escalabilidad horizontal: Más máquinas, más nodos [OK] Lo que no voy a ir es a MENOS NUNCA

    App 
        día n ->  100.000 usuarios
        día n+1 -> 10.000.000 usuarios
        día n+2 -> 10 usuarios
        día n+3 -> 100.000.000 usuarios

        Web telepi:
            00:00 -> 0 usuarios
            08:00 -> 0 usuarios
            10:00 -> 4 usuarios
            14:00 -> 1000 usuarios          Queremos políticas de escalado que permitan subir / bajar recursos
            17:30 -> 10 usuarios                ESCALADO HORIZONTAL: MAS MAQUINAS o MENOS MAQUINAS! Eso me ofrecen los CLOUDs
            20:30 -> 100000000 usuarios
            23:00 -> 0 usuarios

- Garantizar la NO PERDIDA DE INFORMACIÓN pasada
  Si alguien mete la pata con los datos, pueda recuperarlos (BACKUP/RECOVERY) x LO QUE QUIERA EL ALMACENAMIENTO

---

# Alta disponibilidad y escalabilidad en entornos de producción para BBDD

Las BBDD en general suelen admitir 3 formas de trabajo (Y digo en general, no todas admiten esas formas de trabajo - ej Postgres -):
- Standalone: Yo tengo mi BBDD en un servidor.. y punto.
  - Esto ofrece HA? Por si solo aparentemente NO. Pero de hecho, por ejemplo en Postgres es la forma más normal de operar en un entorno de producción.
    2 conceptos:
    - HA? No significa que el sistema esté funcionando el 100% del tiempo (De hecho esto es imposible de garantizar)
          Si no tratar de garantizar que el sistema está en funcionamiento una cantidad del tiempo ADECUADA PARA MI NEGOCIO.
    - Si me aseguro (todo lo que pueda) que los datos (ficheros) no se pierden y están disponibles para ser usados en todo momento.
      Si se jode el servidor o se queda corrupto el SO , o el programa de BBDD, puedo levantar otro servidor que tenga
      instalado el programa de BBDD, le enchufo los datos y seguir trabajando.
        Cuánto tardo en esto? 1 minuto - 1 día - 10 segundos
      Y si tardo 5-10 segundo (como tarda un kubernetes), o 1-2 minutos(como tarda un un vmware) quizás me vale: DEPENDE DEL NEGOCIO
      ESO SI: Si mi negocio no puede permitirse que el sistema esté caído ni 10 segundo... mejor vete a Oracle! y prepara BILLETE!
- Replication:
  Tengo una BBDD PRINCIPAL (que es sobre la que trabaja el entorno de producción)
                vvvv
      Y una BBDD REPLICA (o varias) que se van actualizando con los datos de la principal.

      Esto puedo configurarlo además para que:
      - En caso de caerse la BBDD principal automáticamente se la REPLICA cambie de modo y empiece a aceptar conexiones del sistema de producción (que cambia datos

    BBDD PRINCIPAL Tiene sus ficheros
        vvv
     sincronización
        vvv
    BBDD REPLICA   Tiene sus ficheros independientes de la principal

    Si la replica, aceptara modificaciones (INSERT) quién ofrece el ID del campo generado en automático? Si lo ofrece ella que problema podría tener? Que la BBDD Principal también hubiera recibido un INSERT y hubiera provisionado el mismo ID... Y entran en conflicto!
    Problemón... y no hay solución sencilla (hay soluciones... pero no sencillas)... 
    SI NO ME QUIERO COMPLICAR LA VIDA: NO PERMITO QUE LA REPLICA RECIBA. Como mucho si puedo permitir que reciba selects.
    Eso si... esos selects en un momento dado pueden ir por detrás de la principal... y eso puede ser un problema.
    - Si me supone un problema: Puedo hacer que cada vez que se haga un insert en la principal, no se de commit hasta que el dato no se haya guardado también en la replica. PERO ESTO TIENE OTRO PROBLEMA: 
      - Si uno no contesta, no ofrezco servicio (PUEDO PONER MAS SERVIDORES REPLICA y me vale con que 1 de ellos me de confirmación de escritura)
      - Más lento: Impacto en el rendimiento (QUIZAS PUEDO VIVIR CON ESTO)

    Aquí hay un problemón enorme.
    Si tengo una BBDD PRINCIPAL >>> BBDD REPLICA y la principal se cae y la replica se pone en modo escritura... y la principal vuelve a funcionar... FOLLON DE COJONES... Esto no lo puedo permitir.
    La BBDD principal he de reconfigurarla para que cuando arranque ya no arranque como principal... LA TENGO PERDIDA. La principal ahora es la que era replica. Y podría montar una nueva REPLICA para sustituir a la replica que ahora es MAESTRO = FOLLON GORDISIMO!!!

    Al final... Las BBDD en modo replicación no las usamos para HA (al menos en POSTGRES... y en la mayoría de sistemas)
    Esto sirve para escalabilidad (en consultas... no en actualizaciones):
        - BBDD Principal para actualizaciones.
        - BBDD Secundaria para queries de la aplicación de producción.
            NOTA: Hoy en día MUCHISIMOS FRAMEWORKS de desarrollo admiten trabajar de esta forma TRANSPARENTEMENTE PARA EL DESARROLLADOR.
        - Otra BBDD Secundaria para queries de la BI.
Si necesito escalabilidad en actualizaciones:
    - Sistemas de almacenamiento más rápidos
    - Subir recursos: MAS CPU / RAM : ESCALADO VERTICAL!
Hay otra opción:
- Cluster Activo-Activo donde tenemos varios nodos que pueden recibir actualizaciones y están en continua comunicación para que no haya 
problemas de ID, de nada...

    STANDALONE
        BBDD    dato1   dato2

    CLUSTER
        BBDD1   dato1   dato2   dato4

        BBDD2   dato1   dato3   dato4

        BBDD3   dato1   dato3   dato5

        BBDD4   dato2   dato3   dato5

        BBDD5   dato2   dato4   dato5

Y ahora si he conseguir mejorar el rendimiento. Y es frustrante:
    HE HECHO UN x3 en recursos.. y mejoro el rendimiento (máximo teórico) en un 50% (no en un 300%)
    Con una máquina en 2 ud de tiempo guardo 2 datos: Paso de 1 datos por unidad de tiempo a 1.5 datos por unidad de tiempo

Esto es un ORACLE RAC (Real Application Cluster) o un MariaDB o MySQL con Galera Cluster... esto NO SE PUEDE MONTAR CON POSTGRES

---

# Almacenamiento

Antaño montábamos servidores:
 - Servicio BBDD
 - Almacenamiento local RAID (que ofrezca redundancia)

Esto tenía un problema!
Si se cae el servidor, por ejemplo le falla la fuente de alimentación, pierdo el acceso a los datos.

Si los datos los tengo en un almacenamiento externo, si se cae el servidor (cualquier problema de HW o SW) puedo conectar el almacenamiento a otro servidor y seguir trabajando.

Cuando empezamos a seguir estas formas de trabajo (tener almacenamiento en red o al menos accesible de alguna forma) empezamos a configurar VM.
- VM1: Servidor de BBDD <- Le enchufamos el almacenamiento
    Arranco la BBDD
Si se cae el servidor físico donde está VM1, arranco VM1 en otro servidor y sigo trabajando.
Si hay un problema con la instalación de la VM1, arranco otra VM con una plantilla de la BBDD en otro servidor y sigo trabajando.

Hoy en día llevamos esto al extremo: con los contenedores.
Es el siguiente paso evolutivo en el mundo de la virtualización : CONTENEDORES!

---

CURSO CONTENEDORES, DOCKER, PODMAN <<<<
    Si pone KUBERNETES/OPENSHIFT NO !!!!
    
    
---
Las primeras instalaciones las haremos mediante contenedores.
A efectos prácticos es como una máquina virtual.
Nos vamos a descargar una imagen de contenedor: Imagen ISO de SO
En imagen YA VIENE UN POSTGRES instalador de antemano por la gente de postgres.

---

# Colación / Collates

La colación no es el juego de caracteres.
El juego de caracteres es el JUEGO DE CARACTERES.
El collate es otra cosa MUY DIFERENTE!

El collate es cómo se interpretan TEXTOS en las operaciones que hago en la BBDD. Por ejemplo:

TABLA
| id  |  nombre   |
|  1  |  Felipe   |
|  2  |  federico |
|  3  |  menchu   |

SELECT nombre FROM tabla ORDER BY nombre;
Felipe
federico
menchu

A no ser que use un COLLATE que no distinga entre Mayúsculas y Minúsculas

ACENTOS O SIN ACENTOS



----


Al contratar el servidor hemos cogido uno de 8Gib: 8 gigabytes? 8 Gibibytes

1 Gb = 1024 Mb 
1 Mb = 1024 Kb
1 Kb = 1024 bytes

Esto CAMBIO HACE MAS DE 20 AÑOS. Antes era así! YA NO!
Hoy en día:

1 Gb = 1000 Mb 
1 Mb = 1000 Kb
1 Kb = 1000 bytes

Hace más de 20 años se crearon nuevas unidades de medida:

1 Gibibyte = 1024 Mebibytes
1 MiB = 1024 Kibibytes
1 KiB = 1024 Bytes

