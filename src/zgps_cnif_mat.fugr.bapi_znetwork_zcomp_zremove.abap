FUNCTION BAPI_ZNETWORK_ZCOMP_ZREMOVE .
*"--------------------------------------------------------------------
*"*"Interface local:
*"  IMPORTING
*"     VALUE(NUMBER) LIKE  BAPI_NETWORK_LIST-NETWORK
*"  EXPORTING
*"     VALUE(RETURN) LIKE  BAPIRET2 STRUCTURE  BAPIRET2
*"  TABLES
*"      I_COMPONENTS_REMOVE STRUCTURE  BAPI_NETWORK_COMP_ID
*"      E_MESSAGE_TABLE STRUCTURE  BAPI_METH_MESSAGE
*"--------------------------------------------------------------------
  clear flg_error_occured.

  PERFORM init_event_register.

  data: dialog_status.                                "nt_1286070
  perform log_init changing dialog_status.            "nt_1286070

  perform badi_init.
  check flg_error_occured is initial.
* read and lock network
  perform read_lock_network     using yx    "lock network
                                changing number.

  if flg_error_occured is initial.
* delete components
  perform bapi_components_remove tables i_components_remove.
  endif.

  perform read_log tables e_message_table
                   using  return.

  perFORM bapi_dialog_end USING dialog_status.      "nt_1286070

ENDFUNCTION.
