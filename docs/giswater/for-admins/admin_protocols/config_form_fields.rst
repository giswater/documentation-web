.. _config_form_fields:

============================
Form fields configuration
=============================

.. only:: html

   .. contents::
      :local:


De forma normal deben existir registros para todos los campos de los elementos que encontramos en la tabla *cat_feature* 
(también deben coincidir con las vistas *child* que tenemos creadas en nuestro esquema).
Entonces, en la tabla **config_form_fields**, tendremos para cada vista child un numero de filas que coincide con todos los 
campos que tenga esta vista, para poder así, configurarlos uno a uno.
De las muchas columnas que hay en config_form_fields, se describen todas y cada una de ellas para lograr el grado de 
configuración que se desee:

Las únicas filas que deben manipularse para personalizar los formularios de los elementos son las que en la columna 
formname tienen el prefijo:

- ve_node_*
- ve_arc_*
- ve_connec_*
- ve_gully_*


**Posición**

- tabname: para administrar los formularios de los diferentes elementos de la red, se gestionan los widgets en función de la pestaña (tab) donde se encuentren.
Existen diferentes tabs, y cada cual va a tener el nombre que le corresponda: data, element, document, etc.


Existen dos tipos de tabs, los diferencia la disposición de los layouts. La mayoría tienen un o dos layouts, pero los de la feature_info tienen todos 3 layouts verticales (excepto el tab data).
Cuando hay valores en *config_form_fields* que hacen referencia a un formulario sin tabs, el valor para esta columna será: **main**.

- layoutname: cada tab contiene tres layouts (1,2,3), el nombre de cada layout sigue la estructura lyt_tabname_(1,2,3). Adicionalmente tenemos los layouts lyt_top_1, lyt_bot_1 (fila de arriba), lyt_bot_2 (fila de abajo).

- layoutorder: es orden del campo dentro de su layout correspondiente.  Se irán ordenando de forma ascendente usando el valor que tengan en este campo. Dos campos con valores de layoutname y layout_order, se solaparan en el formulario.

.. figure:: images/formulario.png

    Posicionamiento de los diferentes widgets.

**Características básicas**


- Datatype: tipo de dato. No aplica para elementos tipo combo. Los posibles valores son: "string", "double", "date", "bytea", "boolean", "text", "integer", "numeric".

- Widgettype: tipo de widget. Los posibles valores son: "datetime", "label", "nowidget", "text", "image", "typeahead", "button", "check", "combo", "hyperlink", "divider", “list”, “spinbox”, “hspacer”, “tableview”, “multiple_checkbox”, “multiple_option”.

- label: etiqueta del campo en el formulario y la tabla de atributos. Totalmente personalizable.

- hidden: true / false se muestra / no se muestra en el formulario y la tabla de atributos.

- tooltip: texto que se muestra en caso de situarte encima de la etiqueta del campo. Totalmente personalizable.

- placeholder: valor de ejemplo a mostrar cuando el campo está vacío.

- iseditable: true / false. Se puede / no se puede editar el campo en el formulario y la tabla de atributos.

- ismandatory: en caso de true, este campo deberá tener valor obligatoriamente.

- isparent: true / false. Cuando un widget es padre de otro, permite recargar combos de los hijos que tienen identifcado a este widget como su padre (dv_parent_id).

- isautoupdate: true / false. Dispara el update del formulario sin esperar al ok del usuario. Valido para campos que se precisa recalcular cosas como profunidades o demás: No es posible esta opción para widgets tipo typeahead.

- isfilter: true / false. Cuando tengamos un widget tipo list, puede ser filtrado por widgets que se encuentran en su mismo tab. Estos widgets pueden ser cualquiera, pero tendrán el atributo isfilter=true. Para ellos son de especial interes los keys 'vdefault' y 'listFilterSign' de widgetcontrols.


**Gestión de dominios de valores (combo y typeahead)**


La gestión de los dominios de valores para widgets combo y typeahead se controla mediante varios campos:

- dv_querytext: contiene la consulta SQL que devuelve dos columnas lógicas, id e idval; en el caso particular de typeahead, ambos deben corresponder al mismo campo.

- dv_orderby_id: se indica si la ordenación debe hacerse por id en lugar de por idval.

- dv_isnullvalue: permite que la lista acepte valores nulos.

- dv_parent_id: indica el widget que actúa como padre.

- dv_querytext_filterc: añade condiciones adicionales de filtrado en función del valor del padre.


**Características Avanzadas**


**stylesheet**: campo tipo json que permite una personalización gráfica de la etiqueta. Ver FAQS para ejemplos de este campo.


**widgetcontrols**: permiten un control avanzado del widget con las siguientes opciones:

    *autoupdateReloadFields*: recarga al momento otros campos en caso de que uno sea modificado. Actua en combinación con isautoupdate.
    
    UPDATE config_form_fields SET widgettype = ‘combo’ , isreload=true, widgetcontrols =
    gw_fct_json_object_set_key(widgetcontrols, 'autoupdateReloadFields' ,'["cat_matcat_id",
    "cat_dnom", "cat_pnom"]'::json) WHERE column_id IN ('arccat_id', 'nodecat_id', 'connecat_id')

    *enableWhenParent*: habilita un combo solo en caso que el campo parent tenga ciertos valores.

    UPDATE config_form_fields SET widgetcontrols = gw_fct_json_object_set_key
    (widgetcontrols,'enableWhenParent','[1, 2]'::json) WHERE column_id IN ('state_type')

    *regexpControl*: control de lo que puede escribir usuario mediante expresion regular en widgets tipo texto libre.
    
    UPDATE config_form_fields SET hidden=false, datatype ='text', widgetcontrols =
    gw_fct_json_object_set_key(widgetcontrols,'regexpControl','[\d]+:[0-5][0-9]:[0-5][0-9]'::text)
    WHERE column_id = 'observ'
    
    .. note::
        Dado que el carácter ‘\’ es reservado de sistema para PostgreSQL deberá hacerse el update con un ‘ \’ para que en la row aparezcan dos, de manera que la sintaxis 
        almacenada y con la que se va a trabajar será [\\d]+:[0-5][0-9]:[0-5][0-9]

    *maxMinValues*: establece un valor máximo para campos numéricos en widgets de texto libre.

    UPDATE config_form_fields SET widgetcontrols = gw_fct_json_object_set_key
    (widgetcontrols,'maxMinValues','{"min":0.001, "max":100}'::json) WHERE column_id = 'descript'

    *setMultiline*: establece la posibilidad de campos multilinea para esctitura con enter
    
    *spinboxDecimals*: establece numero decimales concretos para el widget spinbox (vdef 2)

    UPDATE config_form_fields SET widgetcontrols = gw_fct_json_object_set_key (widgetcontrols, 'spinboxDecimals', '3’) WHERE column_id = 'descript'

    *widgetdim*: dimensiones para el widget.
    
    *vdefault _value*: valor por defecto del widget. Tiene sentido para aquellos widgets que no pertenecen a datos de un feature, puesto que los valores por defecto se definen en los que el 
    usuario ya tiene establecidos en config_param_user. De especial interés para los widgets filtro.

    *vdefault_querytext*: Valor por defecto del widget a partir del resultado de la query. Tiene sentido para aquellos widgets que no pertenecen a datos de un feature, puesto que los valores 
    por defecto se definen en los que el usuario ya tiene establecidos en config_param_user. De especial interés para los widgets filtro.
    
    *listFilterSign*: signo (LIKE, ILIKE, =, >, < ) para los campos tipo filtro. En caso de omisión se
    usará ILIKE para listas tipo tableview e = para listas tipo tab.

    *skipSave Value*: si se define este valor como true, no se guardaran los cambios realizados en
    el widget correspondiente. Por defecto no hace falta poner nada porque se sobreentiende true.
    
    *labelPosition*: si se define este valor [top, left, none], el label ocupará la posición relativa 
    respecto al widget. Por defecto se sobreentiende left. Si el campo label está vacío, labelPosition se omite.

**widgetfunction**: se define el nombre de la función de python que se ejecutará, y si los hubiera las caracteristicas de los parametros adicionales. Se puede definir el fichero a utilizar con la clave 
“module”, por defecto se entiende el fichero core/utils/tools_backend_calls.py. Para utilizar un fichero 
diferente a tools_backend_calls.py se tendrá que importar en tools_gw.py. 
        {"functionName":"add_document","module":"info", "parameters":{"sourcewidget", "targetwidget"}}


**linkedobject**:

    *widgettype list*: nombre de la lista radicada en tabla config_form_list para ser vinculada.
    En esta tabla se configura la query a ser usada (querytext) y el cliente con el que se va a 
    llamar. Hay dos campos en la tabla que no tienen codigo asociado de momento, como son:

        listtype: Hace referencia a como se muetra la lista: tab (elementos en vertical para un tab estrecho) o en attributetable (elementos en tableview para un ancho mayor)

        listclass: Classe de elementos mostrados en la lista (icon, iconos tipo galería o list).
    
    Recomendado que las listas tengan el nombre list_* en la definición de la tabla donde son creados.


    *widgettype image*: Nombre de la imagen radicada en tabla sys_image para ser vinculada.
    Recomendable que las imagenes tengan el nombre img_*
    
    *widgettype [text/check/combo/typeahead]*: action (optativa) vinculada con el widget (getcatalog p.e.) que se encuentre disponible en el dialogo, configurada en config_form_tabs.
    Recomendable que las actions tengan el nombre action_*
    
    *widgettype button*: nombre de un icon (optatitvo) para setear en el button con la imagen asociada que se encuentra en la carpeta de plugin icons/backend/20x20. Recomendable que 
    los nombres de los iconos sean simples numeros.png.

