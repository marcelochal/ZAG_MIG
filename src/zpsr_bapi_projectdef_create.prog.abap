*&---------------------------------------------------------------------*
*& Report  R_BAPI_PROJECTDEF_CREATE                                    *
*&                                                                     *
*&---------------------------------------------------------------------*
*&                                                                     *
*&                                                                     *
*&---------------------------------------------------------------------*

REPORT  zpsr_bapi_projectdef_create.

DATA project_definition_stru
       LIKE  zeps_bapi_project_definition.
DATA return TYPE bapiret2_t.

DATA testrun TYPE testrun.

*--------------------------------------------------------*
*--------------------------------------------------------*
* import from memory ...
IMPORT: project_definition_stru
                  FROM MEMORY ID 'PD_CREA_PROJECT_DEFINITION_STRU'.

IMPORT: testrun FROM MEMORY ID 'TESTRUN'.

CALL FUNCTION 'ZFPS_2001_PROJECTDEF_CREATE'
  EXPORTING
    project_definition_stru = project_definition_stru
    testrun                 = testrun
  TABLES
    return                  = return.

* export to memory ....
EXPORT: return TO MEMORY ID 'PD_CREA_RETURN'.
