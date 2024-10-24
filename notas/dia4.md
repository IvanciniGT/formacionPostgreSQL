# Procedimientos de instalación

## Procedimiento más tradicional para instalar

    App 1   + App 2   + App 3       Problemas graves:
    --------------------------          Si App1 se vuelve loca (BUG) y pone CPU(RAM, HDD, RED)-> App1 OFFLINE
        Sistema Operativo                   -> App2 y App3 OFFLINE
    --------------------------          App1 y el resto pueden tener requisitos diferentes :
             HIERRO                             - configuración de SO
                                                - incompatibilidades de dependencias
                                        App1 potencialmente puede acceder a los datos de app2 o 3 : VIRUS

## Procedimiento MAQUINAS VIRTUALES

      App 1  | App 2 y App 3        Resuelve los problemas de las instalaciones tradicionales
    --------------------------          Pero esto viene con nuevos problemas:
      SO 1   | SO 2                         - Perdida de recursos
    --------------------------              - Merma en el rendimiento de las apps
      MV 1   | MV 2                         - Configuración mucho más compleja
    --------------------------
      Hipervisor
      Citrix, VMWare, HyperV
      VirtualBox, KVM
    --------------------------
      Sistema Operativo
    --------------------------
            HIERRO
            
Las MV se crean desde una IMAGEN DE MV (Usualmente una ISO de SO)            
            
## Procedimiento CONTENEDORES (LA alternativa y lo que se usa en lugar de MV)

      App 1  | App 2 y App 3        Resuelve los problemas de las instalaciones tradicionales
    --------------------------      Sin ninguno de los inconvenientes de las máquinas virtuales
      C 1    | C 2 
    --------------------------
      Gestor de contenedores
      Docker, Podman, CRIO
      ContainerD
    --------------------------
      Sistema Operativo LINUX
    --------------------------
            HIERRO

# Contenedor

Es un entorno aislado dentro de un SO (con kernel LINUX) donde ejecuto procesos.
Aislado:
- Tiene su propia IP (En una red virtual que se crea dentro de mi host)
    - Toda máquina tiene una red virtual 127.0.0.0/8 -> El host toma la IP: 127.0.0.1 (localhost)
    - Los gestores de contenedores, al instalarse crean redes cirtuales nuevas (docker crea la rv: 172.17.0.1/16)
- Tiene su propio sistema de archivos (como si fuera su propio HDD)
- Tienen sus propias variables de entorno
- Pueden tener limitaciones de acceso a los recursos del hierro (CPU, RAM,...)

Una cosa muy común al trabajar con contenedores (igual que con MV) es compartir carpetas entre el host y la VM o contenedor.
Mucho más habitual en entornos de producción es compartir carpetas con el contenedor que se encuentren NO EN EL HOST, sino en:
- Cabinas de almacenameinto
- Volumenes NFS/ISCSI en RED
- Volumenes en un cloud
- ...

Los contenedores los creamos desde IMAGENES DE CONTENEDOR.

Los contenedores tienen otra gracia:
Da igual el programa que venga, todos se operan IGUAL (Hay un estandar):
    - docker start contenedor1 (MYSQL, POSTGRES, SQL SERVER, ORACLE, APACHE WEB SERVER)
    - docker stop contenedor1
    - docker restart contenedor1 
    - docker rm contenedor1
    - docker logs contenedor1

Y ese nivel de estandarización, que hace que dé igual operar un MYSQL que un WEB SERVER, es lo que posibilita herramientas como KUBERNETES

## Imágen de contenedor:

Es un triste archivo comprimido (tar) que tiene dentro un programa PREINSTALADO normalmente por el fabricante
(que sabe de instalar ese programa 50 veces más que yo). Listo para su uso 100%

Lo único que hacemos es descomprimir y ejecutar.
Los programas que vienen instalados dentro de una imagen de contendor, permiten cierta parametrización... que suministramos:
- Mediante variables de entorno
- También permiten que yo sobreescriba algunos de los ficheros que vienen: postgres.conf

---

# Comunicación con contenedores


    -+---------------------red de amazon------------------------+----
     |                                                          |
    172.31.38.8:18273 -> 172.17.0.9:5432 (NAT)               MenchuPC
     |                                                      (172.31.38.8:18273)
    IvanPC
     |  |
     | 172.17.0.1
     |  |
     |  |- 172.17.0.9:5432 - Contenedor PG
     |  |
     |  Red de docker
     |
     127.0.0.1
     |
     loopback

---

Quiero instalar postgreSQL(mysql, sql server, IIS, apache web server) en Windows:

1º Descargar el INSTALADOR
2º Ejecutar ese instalador (Hay instaladores de SIGUIENTE SIGUENTE... los hay más complejos.. y las BBDD suelen estar aquí)
3º Instalación de Postgre -> c:\Archivos de programa\Postgres -> ZIP -> EMAIL 


# Kubernetes ( que es un estandar del que hay distros: K8S, K3S, minikube, minishift OKD, Openshift, Karbon)

Es una herramienta par gestionar gestores de contenedores en entornos de producción:
    
    CLUSTER DE KUBERNETES: Kubernetes le digo yo: Monta un postgres.
        - Nodo1
            CRIO/Containerd
        - Nodo2
            CRIO/Containerd
        - Nodo3
            CRIO/Containerd
    
    Y me controla Balanceadores de carga, proxies reversos, volumenes en red, reglas de firewall... 
    Monitoriza, Reinica, Escala
    
    Kubernetes es quien opera los entornos de producción. Ya no tengo legiones de sysadmins.
    Hoy tengo 3 sysadmins configurando / operando kubernetes. Y Kubernetes operando el entorno de producción.
    
    En este mundo es donde postgres es el rey!
    
    Para la megaBBDD Corporativa de nos que historias: ORACLE/SQLSERVER.. instalaciones a hierro en servidores dedicados.
    Para BBDD pequeñas (o no tango) pero de gestión mucho más sencilla (MICROSERVICIOS), corriendo en clusters de kubernetes: POSTGRESQL
    
    MICROSERVICIOS -> Aquitectura orientada a Dominio:
        Ya no tengo megasistemas
        Monto un sistema compuesto de 100 microservicios..que son miniaplicaciones
        Y cada miniaplciación tiene su propia BBDD con sus tablas... independiente de otras.
        Ya no tengo en estas arquitecturas una mega BBDD con 500 tablas (100 tablas).
        BBDD 20 tablas (como mucho... más habitual 10 tablas)

# Linux?

Un Kernel de SO. 
Un SO no es un programa que monto... es toda una colección de programas!
    - Kernel (los más básicos e importantes: Control del hierro y procesos):
        - Microsoft: 
            - DOS : MS-DOS, Windows 3, Windows 95, 98, Millenium
            - NT  : Windows NT, Windows XP, Server, Windows 7, 8, 10, 11
            - LINUX: Características de Windows: WLS
    - Shells de lineas de comandos: Powershell, simbolo del sistema, sh, bash, fish
    - Interfaces gráficas: FluentDesign, GNome, XFC

Linux (como kernel) se usa para montar muchos SO:
- Android (Kernel Linux + Librerias y utilidades de GOOGLE. no lleva nada de GNU)
- GNU/Linux: RedHat Enterprise Linux (yum), Fedora (snap), Ubuntu (apt-get), Debian(apt), Suse (Son distribuciones de un SO)
  70%  30%

# Qué es UNIX®?

Sistemas operativos que cumplen con estos 2 estándares.
- POSIX
- SUS
El mundo va mucho más allá de Linux(GNU/Linux) y Windows ( y ANDROID).
Los grandes fabricantes de HARDWARE crean sus propios SO:
- IBM: AIX ( y AIX es UNIX® )
- HP: HP-UX (UNIX®)
- Oracle: Solaris (UNIX®)
- Apple: MacOS (UNIX®)

Linux (como kernel) se baso en las especificaciones de UNIX®, pero no está certificado.. ni hay NINGUN INTERES EN QUE LO ESTE.

Univ Berkley (california) : 386-BSD:
    - FreeBSD
    - NetBSD
    - MacOS

GNU (GNU is Not UNIX) + Kernel Linux -> SO GNU/Linux No está certificado UNIX® para ser gratuito.

# Qué era UNIX?

Un SO de los lab Bell de la Americana de telecomunicaciones AT&T. Eso dejó de hacerse a principios de los 2000.
En su evolución llevo a haber más de 400 versiones distintas de UNIX®. Para mantener la coherencia entre ellas, 
salieron 2 estándares:
- POSIX
- SUS


---

HOY vamos a montar 2 postgres nuevos:
- 1 a hierro
- Otro en un contenedor
El del contenedor va a ser una replica del que tenemos a hierro. 

---

Tengo una MV donde he instalado postgres 16.
Y ahora quiero tener postgres 17... que hago?
Entro en la MV donde tengo instalado postgres 16 y actualizo a postgres 17

---

Y si tengo el pg16 en un contenedor y quiero un pg17?
Borro el contenedor de PG16 y Creo uno nuevo con la imagen que me postgres del postgres 17.
Y al nuevo le inyecto los mismos datos que tenñia el 16 (le monto el mismo volumen) Y PUNTO PELOTA!

El propio postgres me actualizalos datos con los nuevos requerimientos que traiga la versión 17.

Y lo mismo con oracle, sql server... 
Evidentemente no puedo pasar de pg8 -> pg 17... hay un roadmap de actualización.

---

# Servicios en Linux

Hoy en día con el demonio de sistema: systemd < - systemctl

Antiguamente eran los initScripts (RCs)


----


En POSIX nos hablan de unas carpetas que deberiamos tener y respectar y conocer en un SO que cumpla con POSIX

/
    etc/    Configuraciones
    lib/
    var/    Ficheros que van generando los programas (Ficheros BBDD, logs)
    tmp/    Temporal... que con reinicio se borra
    usr/
    home/   De usuarios
    
    
sudo cp ~/environment/curso/instalacion/local/postgresql.conf  /etc/postgresql/17/main


sudo cp /etc/postgresql/17/main/pg_hba.conf ~/environment/curso/instalacion/local

sudo chmod 666 ~/environment/curso/instalacion/local/pg_hba.conf

sudo cp ~/environment/curso/instalacion/local/*.conf  /etc/postgresql/17/main

---

Hay 2 formas de hacer replicacion entre BBDD postgres:
- Replicación física:
    Lo que hace es llevar los ficheros WAL de un maestro a los replicas.. y allí se van aplicando
    Necesitamos asegurar que los WAL no se borren hasta que no hayan sido procesados en las replicas.
        Cada replica, irá a su ritmo... de procesamiento.
        Puede ser que una replica ya esté sincronizada... y otra no
        De forma que el maestro debe saber por donde va cada replica (que le ha mandado ya)
        Para ello usa lo que llamos slots de replicación.
            Cada replica usará un slot de replicación. 
            Asociado a ese slot, el maestro irá mandando cosas.. y anotando qué ha enviado


            MAESTRO
                slot 1 de replicación           <<<.   REPLICA 1
                slot 2 de replicación           <<<.   REPLICA 2
    
    Replicar BBDD entera
- Replicación lógica:
    Replicar tablas sueltas
    Lo que se mandan son los datos de las tablas.

---

# Activar replicación lógica:

## En el maestro

### Editar fichero postgres.conf

wal_level = replica
max_wal_senders = 10    Procesos en SO (en maestro y replicas que se encargan de la replciación)
max_replication_slots = NUMERO  Slots que quiero de replicación (tiene que ver con el número de replicas que tengo tendré)
hot_standby = on                Si quiero que la replica esté disponible para consultas
hot_standby_feedback            Si queremos que las replicas informen al maestro de vuelta cuando acaben de procesar un paquete de datos
synchronous_commit              Si el maestro debe esperar a la confirmacion de las replicas antes de dar el OK a la transacción
    (si tengo una replica con posibilidad de promoción a maestro ^ on)
synchronous_standby_names       Si 
    /si el de arriba está en on, aqui le indico de cuales tiene que esperar confirmación para el commit;
begin;
        
                                    GUARDE LOS DATOS EN SUS FICHEROS
                               ok    ^
                             < --    |
    --> INSERT -->   MAESTRO ---> REPLICA *
               < --     |
                ok      v
                        GUARDA EN SUS FICHEROS
    commit;

### Editar el fichero pg_hba.conf

De forma que para operaqciónes de replciación se puedan conectar desde otras máquinas...
host    replication     all             0.0.0.0/0               scram-sha-256

### Crear un usuario para replicación
CREATE USER replicator WITH REPLICATION ENCRYPTED PASSWORD 'password';

### Crear un slot de replciación
SELECT * FROM pg_create_physical_replication_slot('replica1');

### Reinicio del servidores
systemctl restart postgres

### Backup FISICO de la base de datos... para llevarlo a la máquina de replicación
En este proceso, no hacemos un backup normal... es un backup especial para replicación

    pg_basebackup -h 172.31.38.8 -D /var/lib/postgresql/17/backupReplicacion -S replica1 -X stream -P -U replicator -Fp -R
    
        -h  IP|nombre del maestro (importante que sea el que puede usar el replica para conectarse al maestro)
        -D  Directorio donde dejo el backup
        -S  Slot de replicación
        -X  Incluye los WAL
        -P  Mostrar el progreso
        -U  Usuario que usamos para el backup y la replicación
        -Fp Formato del backup (PLAIN).. Crea una carpeta con los archivos tal cual...
        -R  Genera un archivo de configuración para el nodo replica, de forma que sepa:
                - Que es un nodo de replica
                - Que usa el slot de replicación 1
                - El maestro al que se tiene que conectar

Esto nos genera la carpeta de backup Y dentro tenemos un archivo de configuración de la BBDD

    primary_conninfo = 'user=replicator password=password channel_binding=prefer host=172.31.38.8 port=5432 sslmode=prefer sslnegotiation=postgres sslcompression=0 sslcertmode=allow sslsni=1 ssl_min_protocol_version=TLSv1.2 gssencmode=prefer krbsrvname=postgres gssdelegation=0 target_session_attrs=any load_balance_hosts=disable'
    primary_slot_name = 'replica1'

Arrancar un servidor nuevo, que trabaje contra estos archivos...
Y listo! YA se ponen a hablar entre ellos.


sudo cp -p /etc/postgresql/17/main/postgresql.conf ~/environment/curso/instalaciones/replica

sudo cp -p /etc/postgresql/17/main/pg_ident.conf ~/environment/curso/instalaciones/replica

sudo cp -p /etc/postgresql/17/main/pg_hba.conf ~/environment/curso/instalaciones/replica

