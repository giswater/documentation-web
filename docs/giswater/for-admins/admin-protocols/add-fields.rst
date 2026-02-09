==================
Add fields
==================


Este procedimiento permite la **creación**, **modificación** y **borrado de campos** adicionales en un elemento concreto del sistema o en todos los elementos de un mismo tipo (cat_feature).

Esta funcionalidad es útil cuando se necesita almacenar información que no está contemplada en el modelo de datos estándar de Giswater.

Es importante destacar que el sistema de campos adicionales no añade directamente columnas en las tablas madre (node, arc, connec).
Por este motivo, estos campos no pueden consultarse directamente en dichas tablas, pero sí estarán disponibles:

- En los formularios de QGIS.

- En las vistas child.

**Descripción general**


Para llevar a cabo este proceso es necesario disponer de **permisos de administrador**, ya que las vistas afectadas se modifican 
automáticamente cuando se crea, actualiza o elimina un campo adicional.

El proceso consta de dos pasos diferenciados:

1. Creación del campo en la base de datos, descrita en este protocolo.

2. Configuración de la visualización del campo en el diálogo, detallada en el protocolo :ref:`config_form_fields`


**Consideraciones técnicas**


La información asociada a los campos adicionales se almacena en las siguientes tablas:

  *sys_addfields*

  *config_form_fields*

Dado que la vista del elemento al que se añade un campo adicional se recrea automáticamente cada vez que se crea, actualiza o 
elimina un campo, existe una función específica diseñada para realizar de forma integrada todas las operaciones necesarias 
relacionadas con la gestión de campos adicionales.

**Creación de un campo adicional**


La llamada a la función es:

::

   SELECT SCHEMA_NAME.gw_fct_admin_manage_addfields(
     $${"client":{"lang":"ES"},
        "feature":{"catFeature":"PUMP"},
        "data":{
           "action":"CREATE",
           "multi_create":"true",
           "parameters":{
              "columnname":"addfield_all",
              "datatype":"string",
              "widgettype":"text",
              "label":"addfield_all",
              "ismandatory":"False",
              "fieldLength":"50",
              "numDecimals": null,
              "active":"True",
              "iseditable":"True"
           }
        }
     }$$);

**Parámetros de la función**


**SCHEMA_NAME**: es el nombre del esquema.

**“catFeature”**: es el feature al que queremos añadir un campo nuevo.

**“action”**: la acción que pretendemos desarrollar, que para el caso será CREATE.

**“multi_create”**: SUPER IMPORTANTE, permite la creación del campo adicional PARA TODAS LAS FEATURES mismo tipo (nodos, arcos, connec o gully en función de la escogida)

**"columnname”**: el nombre del campo adicional. Totalmente prohibido caracteres especiales.

**"datatype"**: el tipo de dato, consultar en esta query los disponibles:

::

   (SELECT id
    FROM SCHEMA_NAME.config_typevalue
    WHERE typevalue = 'datatype_typevalue')

**"widgettype"**: el tipo de widget a ser usado, consultar en esta query los disponibles:

::

   (SELECT id 
    FROM SCHEMA_NAME.config_typevalue 
    WHERE typevalue = 'widgettype_typevalue')


**"label"**: "addfield_all", la etiqueta a mostrar al usuario en el dialogo.

**"ismandatory"**: si el campo es obligatorio para el usuario.

**"fieldLength"**: longitud del campo.

**"numDecimals"**: numero de decimales.

**"active"**: si el campo está activo o lo queremos dejar para otro momento.

**"iseditable"**: si el campo es editable para usuario.

.. warning::
  
  Cuidado con la sintaxis de las peticiones JSON. Es muy fácil equivocarse. Recomendamos ser 
  muy cuidadosos en este punto.


**Borrado de un campo adicional**


Si quisiéramos borrar un campo adicional, procederíamos de la siguiente manera:

SELECT SCHEMA.gw_fct_admin_manage_addfields($${
"client":{"lang":"ES"},
"feature":{"catFeature":"PUMP"},
"data":{"action":"DELETE", "multi_create":"true", "parameters":{"columnname":"pump_test"}}}$$)

