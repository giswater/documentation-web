==============
Raster loading
==============

This section provides an overview of how raster management works in Giswater and describes the main elements 
involved in raster data administration, as well as the requirements and components necessary for its proper integration and use 
in different server environments, whether **Linux** or **Windows**.

The two tables that act on the system are:

- ext_raster_dem
- ext_cat_raster

These are already created, but *ext_raster_dem* comes without restrictions. In the case of an existing utils schema, 
they are stored there, but have different names:

- raster_dem

- cat_raster

The **raster_dem** table is populated externally according to the process explained in item 1.
If in a corporate utils schema, the catalog table is automatically populated with
an AFTER INSERT trigger during raster acquisition:

  file name (rastercat_id).

  cur_user.

  tstamp.

On the other hand, to use this functionality, there are two variables:

- **Sistema**: admin_raster_dem (must be TRUE).

- **Usuario**:
  
    edit_insert_elevation_from_dem (must be TRUE).

    edit_update_elevation_from_dem (must be TRUE).


.. note::
  The triggers of node/connec, both on Insert and Update, automatically capture the elevation value. On the other hand, the function **gw_fct_update_elevation_from_dem** from the toolbox
  automatically activates the capture of all dimensions for the selected layer.

**1. Load raster into DB**

The key concepts to keep in mind are:

**1.1. File name**:

It is recommended that the name includes as much information as possible about the raster since
it will provide information in the ext_cat_raster metatable about its type:

  *dg_dem_2019_u48 (provider, raster type, data year, map sheet)*

In this way, when the raster is inserted, the raster catalog is also populated and contains detailed information about it.


**1.2. File type**:

If all DEM rasters are inserted into the same table, they must all be the same in terms of 
format so that the table column constraints are not broken.
In this regard, when loading the first raster, the constraints must be created as defined in point two of this document.


**1.3. Raster stored inside or outside the DB**:

Since there are two O/S environments for the machine hosting PostgreSQL, this process is detailed for each of the two environments.

A very interesting option to avoid **loading the database** and reload files automatically (you only need to change the file).

.. warning::

  The process can be executed from the local postgres or from the postgres on the server where we want to insert the raster, as long as 
  we have access to it via VPN or another method. It is easier locally. 


*Windows environment*


1. Verify that there is an executable **raster2pgsql** in the PostgreSQL bin folder.

2. Open the command prompt (cmd), go to the PostgreSQL bin folder **(cd C:\Program Files\
PostgreSQL\ 11\bin\)**.

3. Execute the process using a statement similar to the example shown below, specifying the SRID, the file path, the tile size, 
the name of the table to which the raster is imported, and the database connection:

.. code-block:: sql
  
  raster2pgsql.exe -R -s 25831 -C -x raster.txt -t 1500x1500 -a utils.raster_dem -F -n rastercat_id | 
  psql -d giswater -U postgres -p 5432


*Linux environment*


The procedure may vary depending on the distribution used. However, as a general rule, the
environment configuration must meet the following conditions.

Since PostgreSQL is usually installed in the system path, the command line execution
can be done easily:

.. code-block:: sql
  
  raster2pgsql -s 25831 -C -x raster.txt -t 1500x1500 -a utils.raster_dem -F -n rastercat_id | psql -d giswater -U postgres -p 5432

If for some reason the environment variables are disabled, they must be enabled:

**Opción A**: environment file (with a PostgreSQL reload service)

POSTGIS_ENABLE_OUTDB_RASTERS=1

POSTGIS_GDAL_ENABLED_DRIVERS=ENABLE_ALL

**Opción B**: through the console (much easier)

.. code-block:: sql
  
  SET postgis.enable_outdb_rasters TO True;
  
  SET postgis.enabled_drivers TO enable_all;

.. warning::

  If done with a PostgreSQL user, this user must have read permissions for the file.
  If done with another user (e.g., root), this user must be registered in pg_hba.conf and in the DBMS.

**Statement notes**

.. code-block:: sql
  
  [-R] -s 25831 -C -x raster.txt -t 1500x1500 -a utils.raster_dem -F -n rastercat_id | psql -d giswater -U postgres -p 5432


Where: 

**[-R]** 

It can be optional. The raster is stored outside the database. Otherwise, it is stored inside.
The problem is that it is not easy to work with it. The system user and the
Postgres user must be the same and have permissions to read/write files.
This option is optional, but it may be essential depending on the chosen storage strategy.

.. note::
  
  To use this option, the following environment variables must be defined:

  - POSTGIS_ENABLE_OUTDB_RASTERS

  - POSTGIS_GDAL_ENABLED_DRIVERS=ENABLE_ALL


**[-s 25831]**

SRID is **mandatory**.

**[-C]** 

Adds constraints, required only when loading the **first raster**.
The constraints that are created are:

- Raster height (number of rows): enforce_height_rast

- Raster width (number of columns): enforce_width_rast

- No-data value: enforce_nodata_values_rast

- Number of bands (for DEM, 1): enforce_num_bands_rast

- Pixel type (1bit, 2bit, 4bit…):  enforce_pixel_types_rast

- X scale: enforce_scalex_rast

- Y scale: enforce_scaley_rast

- SRID: enforce_srid_rast

- out_db (maintenance of information outside the database)

- Maximum extent: enforce_max_extent_rast

.. warning::

  Although it is possible to define constraints, **their use is not recommended**, as they can affect performance 
  and flexibility when loading raster data.


**[-x]**

Excludes the spatial dimension constraint. **Mandatory** to use if the purpose is to put more 
than one raster in the same table (which will be usual).

Maximum extent: enforce_max_extent_rast

**[raster.txt]**

File name. No spaces, but with metadata.

**[-t 1500x1500]**

Cell size in the database.

**Limits**: 5000x5000.
Exceeding this size causes a memory error (*Failed to allocate memory*).

The recommended size should not exceed 2000x2000 per row.

A new table will be created in the database (updates are not allowed) with the defined structure.
The process divides the raster into parts according to the specified size; each row of the table represents a part of the raster.

The key point is that the input size (for example, 1500x1500) is a divisor of the raster size. The ideal divisor is 1 to 1, but 
if the raster exceeds 2000x2000, it must always be divided using exact divisors.

Examples:

Raster 1000x1000 → -t 1001x1001 → 1 row

Raster 1000x1000 → -t 1000x1000 → 4 rows

Raster 2000x2000 → -t 2001x2001 → 1 rows

Raster 2200x2200 → -t 1100x1100 → 4 rows

Raster 5555x5555 → -t 1111x1111 → 16 rows


**[-a utils.raster_dem]**

Adds raster to the table, mandatory; otherwise, it would create a new one, causing a conflict.

**[-F]**

Adds the file name, mandatory and important to know the file name.

**[-n rastercat_id]**

For the name of the column where the file name will be inserted. Mandatory.

**[-d giswater -U postgres -p 5432]**

Connection parameters: if done with a PostgreSQL user, it is direct. If done with another 
user, it will ask for the password, which can also be provided.

Example queries for loading rasters directly from the command line on localhost:


- We insert into host 000.000.00:5432 with user ‘admin’ and insert directly into an existing table ‘utils.raster_dem’ (variable -a):

.. code-block:: sql

  "C:\Program Files\PostgreSQL\9.6\bin\raster2pgsql.exe" "C:\Users\usuari\Desktop\
  raster.tif" -I -C -x -a -s 25831 -t 1500x1500 -F -n rastercat_id utils.raster_dem | "C:\
  Program Files\PostgreSQL\9.6\bin\psql.exe" -h 000.000.00 -p 5432 -d gis -U admin

- We insert into host 000.000.00:5432 with user ‘admin’ and insert into a new table that will be called ‘ws.raster’ (variable -c):

.. code-block:: sql
  
  "C:\Program Files\PostgreSQL\11\bin\raster2pgsql.exe" "C:\Users\usuari\Desktop\mde\
  mde.tif" -I -C -x -c -s 25831 -t 1500x1500 -F -n rastercat_id ws.raster | "C:\Program Files\
  PostgreSQL\11\bin\psql.exe" -h 000.000.00 -p 5432 -d gis -U admin


