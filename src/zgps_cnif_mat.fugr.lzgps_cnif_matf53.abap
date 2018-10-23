*----------------------------------------------------------------------*
***INCLUDE LCNIF_MATF53 .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  INIT_EVENT_REGISTER
*&---------------------------------------------------------------------*
* Function module 'CO_ZF_DATA_RESET_COMPLETE' will be executed after
* COMMIT WORK by means of the basis. This function module does clear
* >all< internal tables of COZF.
*----------------------------------------------------------------------*
FORM init_event_register .

  STATICS done TYPE c.

  CHECK done IS INITIAL.

  CALL FUNCTION 'INIT_EVENT_REGISTER'
    EXPORTING
      funcname = 'CO_ZF_DATA_RESET_COMPLETE'.

  done = 'X'.

ENDFORM.                    " INIT_EVENT_REGISTER
