==============
Raster loading
==============

Esta sección proporciona una visión general del funcionamiento de la gestión de rásters en Giswater y se describiran los elementos principales 
implicados en la administración de datos ráster, así como los requisitos y componentes necesarios para su correcta integración y uso 
en distintos entornos de servidor ya sea **Linux** o **Windows**.

Las dos tablas que actúan sobre el sistema son:

- ext_raster_dem
- ext_cat_raster

Estas ya están creadas, pero el *ext_raster_dem* viene sin restricciones. En el caso de un esquema de
utils existente, se almacenan allí, pero tienen nombres diferentes:

- raster_dem

- cat_raster

La tabla **raster_dem** se llena desde el exterior de acuerdo con el proceso explicado en ítem 1.
En caso de estar en un esquema corporativo de utils, la tabla de catálogo se llena automáticamente con
un disparador AFTER INSERT en la toma de ráster:

  file name (rastercat_id).

  cur_user.

  tstamp.

Por otro lado, para utilizar esta funcionalidad, existen dos variables:

- **Sistema**: admin_raster_dem (debe ser TRUE).

- **Usuario**:
  
    edit_insert_elevation_from_dem (debe ser TRUE).

    edit_update_elevation_from_dem (debe ser TRUE).


.. note::
  Los triggers de node/connec tanto en Insert cómo en Update en la captura automáticamente el valor de la cota. Por otro lado, la función **gw_fct_update_elevation_from_dem** de la caja de herramientas
  activa automáticamente la captura de todas las dimensiones para la capa seleccionada.

**1. Cargar ráster en BD**

Los conceptos claros a tener en cuenta son:

**1.1. Nombre del fichero**:

Se recomienda que el nombre incluya la mayor cantidad de información posible sobre el ráster ya que
dará información en la metatabla de ext_cat_raster sobre el tipo que es:

  *dg_dem_2019_u48 (proveedor, tipo de ráster, año de datos, hoja de mapa)*

De esta forma, cuando se inserta el ráster, también se llena el catálogo de ráster y lleva información detallada sobre el mismo.


**1.2. Tipología de archivo**:

Si todos los rásteres DEM se insertan en la misma tabla, todos deben ser iguales en términos de 
formato para que las restricciones de la columna de la tabla no se rompan.
En este sentido, al cargar el primer ráster, las restricciones deben crearse como se define en el punto dos de este documento.


**1.3. Ráster almacenado dentro o fuera de BD**:

Dado que hay dos entornos O/S para la máquina donde se aloja PostgreSQL, este proceso se detalla para cada uno de los dos entornos.

Opción muy interesante para no **cargar la base de datos** y recargar archivos automáticamente (solo debes cambiar el archivo)

.. warning::

  Se puede ejecutar el proceso desde el postgres local o desde el postgres del servidor dónde queremos insertar el ráster, siempre que 
  tengamos acceso a él con vpn o otro método. Es más fácil en local. 


*Entorno Windows*


1. Verifique que haya un ejecutable **raster2pgsql** en la carpeta bin de PostgreSQL.

2. Abra el símbolo del sistema (cmd), vaya a la carpeta bin de PostgreSQL **(cd C:\Program Files\
PostgreSQL\ 11\bin\)**.

3. Ejecute el proceso utilizando una sentencia similar a la del ejemplo que se muestra a continuación, poniendo el SRID, la ruta al archivo, el tamaño del mosaico, 
el nombre de la tabla a la que se importa el ráster y la conexión a la base de datos:

  *raster2pgsql.exe -R -s 25831 -C -x raster.txt -t 1500x1500 -a utils.raster_dem -F -n rastercat_id | 
  psql -d giswater -U postgres -p 5432*



*Entorno Linux*



El procedimiento puede variar según la distribución utilizada. No obstante, como regla general, la
configuración del entorno debe cumplir las siguientes condiciones.

Dado que PostgreSQL suele instalarse en la ruta del sistema, la ejecución de la línea de comandos
puede realizarse de forma sencilla:

  *raster2pgsql -s 25831 -C -x raster.txt -t 1500x1500 -a utils.raster_dem -F -n rastercat_id | psql -d giswater -U postgres -p 5432*

Si por alguna razón las variables de entorno están deshabilitadas, deben habilitarse:

**Opción A**: archivo de entorno (con un servicio de recarga postgresql)

POSTGIS_ENABLE_OUTDB_RASTERS=1

POSTGIS_GDAL_ENABLED_DRIVERS=ENABLE_ALL

**Opción B**: a través de la consola (mucho más fácil)

SET postgis.enable_outdb_rasters TO True;
  
SET postgis.enabled_drivers TO enable_all;

.. warning::

  Si se hace con un usuario de PostgreSQL, este debe tener permisos de lectura para el archivo.
  Si se hace con otro usuario (tipo root) este debe estar registrado en pg_hba.conf y en SGDB.

**Anotaciones de sentencias**

*[-R] -s 25831 -C -x raster.txt -t 1500x1500 -a utils.raster_dem -F -n rastercat_id | psql -d giswater -U postgres -p 5432*


Donde: 

**[-R]** 

Puede ser Opcional. El ráster se almacena fuera de la base de datos. De lo contrario, se almacena en el 
interior.
El problema es que no es fácil trabajar con él. Puede ser el usuario del sistema y el
usuario de Postgres debe ser el mismo y con permisos para leer / escribir en archivos.
Esta opción es opcional, pero puede ser imprescindible según la estrategia de almacenamiento elegida.

.. note::
  
  Para utilizar esta opción deben estar definidas las siguientes variables de entorno:

  - POSTGIS_ENABLE_OUTDB_RASTERS

  - POSTGIS_GDAL_ENABLED_DRIVERS=ENABLE_ALL


**[-s 25831]**

SRID, es **obligatorio**.

**[-C]** 

Agrega restricciones, es requerido solo al cargar el **primer ráster**.
Las restricciones que se crean son:

- Altura del ráster (número de filas): enforce_height_rast

- Anchura del ráster (número de columnas): enforce_width_rast

- Valor no data: enforce_nodata_values_rast

- Número de bandas (para DEM, 1): enforce_num_bands_rast

- Tipo de píxel (1bit, 2bit, 4bit…): enforce_pixel_types_rast

- Escala en X: enforce_scalex_rast

- Escala en Y: enforce_scaley_rast

- SRID: enforce_srid_rast

- out_db (mantenimiento de información fuera de la base de datos)

- Extensión máxima: enforce_max_extent_rast

.. warning::

  Aunque es posible definir restricciones **no se recomiendamos su uso**, ya que pueden afectar al rendimiento 
  y a la flexibilidad en la carga de datos raster.


**[-x]**

Excluye la restricción de la dimensión espacial. **Obligatorio** de usar si el propósito es poner más 
de un ráster en la misma tabla (que será lo habitual).

Extensión máxima: enforce_max_extent_rast

**[raster.txt]**

Nombre del fichero. Sin espaciado, pero con metadatos.

**[-t 1500x1500]**

Tamaño de celda en la base de datos.

**Límites**: 5000x5000.
Superar este tamaño provoca error de memoria (*Failed to allocate memory*).

El tamaño recomendado no debe exceder 2000x2000 por fila.

Se creará una nueva tabla en la base de datos (no se permiten actualizaciones) con la estructura definida.
El proceso divide el ráster en partes según el tamaño indicado; cada fila de la tabla representa una parte del ráster.

El punto clave es que el tamaño de entrada (por ejemplo, 1500x1500) es un divisor del tamaño del ráster. El divisor ideal es 1 a 1, pero 
si el ráster supera los 2000x2000, debe dividirse siempre usando divisores exactos.

Ejemplos:

Ráster 1000x1000 → -t 1001x1001 → 1 fila

Ráster 1000x1000 → -t 1000x1000 → 4 filas

Ráster 2000x2000 → -t 2001x2001 → 1 fila

Ráster 2200x2200 → -t 1100x1100 → 4 filas

Ráster 5555x5555 → -t 1111x1111 → 16 filas


**[-a utils.raster_dem]**

Agrega ráster a la tabla, obligatorio ya que de lo contrario crearía uno nuevo con el conflicto que esto significa.

**[-F]**

Agrega el nombre del archivo, obligatorio e importante para conocer el nombre del archivo.

**[-n rastercat_id]**

Para el nombre de la columna donde insertar el nombre del archivo. Obligatorio

**[-d giswater -U postgres -p 5432]**

Parámetros de conexión: si se hace con un usuario de PostgreSQL, es directo. Si se hace con otro 
usuario, pedirá la contraseña que también se puede hacer.

Queries de ejemplo de cargas de ráster directamente desde la línea de 
comandos en localhost:


- Insertamos en host 000.000.00:5432 con usuario ‘admin’ e insertamos directamente en una tabla existente ‘utils.raster_dem’ (variable -a):

*"C:\Program Files\PostgreSQL\9.6\bin\raster2pgsql.exe" "C:\Users\usuari\Desktop\
raster.tif" -I -C -x -a -s 25831 -t 1500x1500 -F -n rastercat_id utils.raster_dem | "C:\
Program Files\PostgreSQL\9.6\bin\psql.exe" -h 000.000.00 -p 5432 -d gis -U admin*

- Insertamos en host 000.000.00:5432 con usuario ‘admin’ e insertamos en una tabla nueva que se llamará ‘ws.raster’ (variable -c):

*"C:\Program Files\PostgreSQL\11\bin\raster2pgsql.exe" "C:\Users\usuari\Desktop\mde\
mde.tif" -I -C -x -c -s 25831 -t 1500x1500 -F -n rastercat_id ws.raster | "C:\Program Files\
PostgreSQL\11\bin\psql.exe" -h 000.000.00 -p 5432 -d gis -U admin*


