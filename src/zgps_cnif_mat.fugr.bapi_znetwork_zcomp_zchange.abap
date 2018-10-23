function BAPI_ZNETWORK_ZCOMP_ZCHANGE .
*"--------------------------------------------------------------------
*"*"Interface local:
*"  IMPORTING
*"     VALUE(NUMBER) LIKE  BAPI_NETWORK_LIST-NETWORK
*"  EXPORTING
*"     VALUE(RETURN) LIKE  BAPIRET2 STRUCTURE  BAPIRET2
*"  TABLES
*"      I_COMPONENTS_CHANGE STRUCTURE  BAPI_NETWORK_COMP_CHANGE
*"      I_COMPONENTS_CHANGE_UPDATE
*"  STRUCTURE  BAPI_NETWORK_COMP_CNG_UPD
*"      E_MESSAGE_TABLE STRUCTURE  BAPI_METH_MESSAGE
*"--------------------------------------------------------------------
  clear flg_error_occured.

  PERFORM init_event_register.

  data: dialog_status.                                "nt_1286070
  perform log_init changing dialog_status.            "nt_1286070

  perform badi_init.
* check and convert interface data into internal data
  perform check_and_convert_comp_change tables i_components_change
                                             i_components_change_update.
*                                     using   number.

  if flg_error_occured is initial.
* read and lock network
    perform read_lock_network using      yx     "lock network
                              changing number.

  endif.

  if flg_error_occured is initial.
* change components
    perform bapi_component_change.
  endif.

  perform read_log tables e_message_table
                    using  return.

  perFORM bapi_dialog_end USING dialog_status.      "nt_1286070

endfunction.
