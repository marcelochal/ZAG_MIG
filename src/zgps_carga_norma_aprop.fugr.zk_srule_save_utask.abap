FUNCTION zk_srule_save_utask.
*"----------------------------------------------------------------------
*"*"Módulo função atualização:
*"
*"*"Interface local:
*"  IMPORTING
*"     VALUE(P_I_TESTRUN) TYPE  BAPIE1GLOBAL_DATA-TESTRUN
*"  TABLES
*"      T_COBRA_INSERT STRUCTURE  COBRA OPTIONAL
*"      T_COBRA_UPDATE STRUCTURE  COBRA OPTIONAL
*"      T_COBRA_DELETE STRUCTURE  COBRA OPTIONAL
*"      T_COBRB_INSERT STRUCTURE  COBRB OPTIONAL
*"      T_COBRB_UPDATE STRUCTURE  COBRB OPTIONAL
*"      T_COBRB_DELETE STRUCTURE  COBRB OPTIONAL
*"  EXCEPTIONS
*"      SRULE_UTASK_ERROR
*"----------------------------------------------------------------------

* Settlement of additional ACDOCA currencies is activated via COBRA-ADDCURR
  cl_fco_abr_util=>set_cobra_insert_addcurr(
    CHANGING
      ct_cobra_insert = t_cobra_insert[]
  ).


  IF p_i_testrun IS INITIAL.

*.DB_ACTION ist Makro, das alles macht
    db_action cobra insert.
    db_action cobra update.
    db_action cobra delete.
    db_action cobrb insert.
    db_action cobrb update.
    db_action cobrb delete.

  ENDIF.

ENDFUNCTION.
