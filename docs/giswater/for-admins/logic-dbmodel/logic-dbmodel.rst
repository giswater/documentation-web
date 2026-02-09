===============
Logic Dbmodel
===============


**WS**


La siguiente imagen muestra el modelo de datos conceptual de Giswater, organizado en varios bloques funcionales:
en el centro se encuentra el Núcleo, compuesto por las tablas esenciales que definen los objetos topológicos (node/arc/connec), 
catálogos y zonas del mapa; alrededor de este núcleo se disponen los otros complementos como *Gestor Gerencias*, dispone de las tablas 
para la gestión de accesos y permisos; *Documentos*, para el manejo documental; *O&M*, que integra información de operaciones y 
mantenimiento; *Interoperabilidad*, destinado a conectar Giswater con sistemas externos como SCADA, CRM o GMAO; *Modelización 
matemática*, tablas que almacenan datos necesarios para modelos hidráulicos y resultados de EPANET; *Datos específicos de objetos*, 
que contienen atributos particulares según cada tipo de elemento; y un bloque final de *Otras tablas* para información adicional.


.. figure:: img/model-db-ws.png

    Modelo de datos conceptual de Giswater para WS.

**UD**


El modelo de datos para los proyectos de UD resulta similar que para Ws, en el *Núcleo* se agrupan todas aquellas tablas que
definen los objetos topológicos (node/arc/connec/gully/subcatchment) incorporanso en este caso dos nuevos elementos adicionales: gully y subcatchment.
A diferencia de WS, en los proyectos de UD no se incluye el módulo de interoperabilidad.

.. figure:: img/model-db-ud.png

    Modelo de datos conceptual de Giswater para UD.

