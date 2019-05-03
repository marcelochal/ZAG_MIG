FUNCTION bapi_zprojectdef_zcreate.
*"----------------------------------------------------------------------
*"*"Interface local:
*"  IMPORTING
*"     VALUE(PROJECT_DEFINITION_STRU) TYPE
*"        ZEPS_BAPI_PROJECT_DEFINITION
*"     VALUE(TESTRUN) TYPE  BAPIE1GLOBAL_DATA-TESTRUN OPTIONAL
*"  TABLES
*"      RETURN STRUCTURE  BAPIRET2
*"----------------------------------------------------------------------

* this function wraps the BAPI call to provide a cleared work area

  EXPORT: project_definition_stru
                      TO MEMORY ID 'PD_CREA_PROJECT_DEFINITION_STRU'.

  EXPORT: testrun TO MEMORY ID 'TESTRUN'.

  SUBMIT zpsr_bapi_projectdef_create AND RETURN.

  IMPORT: return FROM MEMORY ID 'PD_CREA_RETURN'.

ENDFUNCTION.
