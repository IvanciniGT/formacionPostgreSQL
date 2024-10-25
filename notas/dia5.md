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