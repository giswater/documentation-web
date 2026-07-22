==================
Add fields
==================

This procedure allows the **creation**, **modification** and **deletion of fields** in a specific element of the system or in all elements of the same type (*cat_feature*).

This functionality is useful when it is necessary to store information that is not contemplated in the standard Giswater data model.

It is important to highlight that the additional fields system does not directly add columns to the parent tables (node, arc, connec).
For this reason, these fields cannot be queried directly in those tables, but they will be available:

- In the QGIS forms.

- In the child views.


**General description**


To carry out this process, it is necessary to have **administrator permissions**, since the affected views are automatically modified when an additional field is created, updated, or deleted.

The process consists of two distinct steps:

1. Creation of the field in the database, described in this protocol.

2. Configuration of the field display in the dialog, detailed in the protocol :ref:`config_form_fields`


**Technical considerations**


The information associated with additional fields is stored in the following tables:

  *sys_addfields*

  *config_form_fields*

Since the view of the element to which an additional field is added is automatically recreated each time a field is created, updated, or deleted, there is a specific function designed to perform all necessary operations related to the management of additional fields in an integrated manner.


**Creation of an additional field**

The function call is:


.. code-block:: sql

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

**Function parameters**


**SCHEMA_NAME**: is the name of the schema.

**“catFeature”**: is the feature to which we want to add a new field.

**“action”**: the action we intend to perform, which in this case will be CREATE.

**“multi_create”**: SUPER IMPORTANT, allows the creation of the additional field FOR ALL FEATURES of the same type (nodes, arcs, connec, or gully depending on the one chosen)

**"columnname”**: the name of the additional field. Special characters are strictly prohibited.

**"datatype"**: the data type, consult the available ones in this query:

.. code-block:: sql

   SELECT id
    FROM SCHEMA_NAME.config_typevalue
    WHERE typevalue = 'datatype_typevalue'

**"widgettype"**: the type of widget to be used, consult the available ones in this query:

.. code-block:: sql

   SELECT id 
    FROM SCHEMA_NAME.config_typevalue 
    WHERE typevalue = 'widgettype_typevalue'


**"label"**: "addfield_all", the label to display to the user in the dialog.

**"ismandatory"**: whether the field is mandatory for the user

**"fieldLength"**: length of the field.

**"numDecimals"**: number of decimals.

**"active"**: whether the field is active or we want to leave it for another time.

**"iseditable"**: whether the field is editable by the user.

.. warning::
  
  Be careful with the syntax of JSON requests. It is very easy to make mistakes. 
  We recommend being very careful at this point.
  


**Deletion of an additional field**


If we wanted to delete an additional field, we would proceed as follows:

.. code-block:: sql
   
   SELECT SCHEMA.gw_fct_admin_manage_addfields($${
   "client":{"lang":"ES"},
   "feature":{"catFeature":"PUMP"},
   "data":{"action":"DELETE", "multi_create":"true", "parameters":{"columnname":"pump_test"}}}$$)

