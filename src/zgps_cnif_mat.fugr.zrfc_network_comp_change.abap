FUNCTION ZRFC_NETWORK_COMP_CHANGE.
*"--------------------------------------------------------------------
*"*"Interface local:
*"  IMPORTING
*"     VALUE(NUMBER) LIKE  BAPI_NETWORK_LIST-NETWORK
*"  EXPORTING
*"     VALUE(RETURN) LIKE  BAPIRET2 STRUCTURE  BAPIRET2
*"     REFERENCE(ET_MESG) TYPE  BAPIRET2_T
*"  TABLES
*"      I_COMPONENTS_CHANGE STRUCTURE  BAPI_NETWORK_COMP_CHANGE
*"      I_COMPONENTS_CHANGE_UPDATE
*"  STRUCTURE  BAPI_NETWORK_COMP_CNG_UPD
*"      E_MESSAGE_TABLE STRUCTURE  BAPI_METH_MESSAGE
*"      EXTENSIONIN STRUCTURE  BAPIPAREX OPTIONAL
*"      EXTENSIONOUT STRUCTURE  BAPIPAREX OPTIONAL
*"      ET_RETURN STRUCTURE  BAPIRET2 OPTIONAL
*"--------------------------------------------------------------------
  DATA: lv_dialog_status_tmp  TYPE flag,
        lv_msghand_num        LIKE sy-uzeit.

  DATA: switch_flag type XFELD.

  CALL METHOD cl_ops_ps_switch_check=>ps_sfws_sc1 "Note: 1481122
  RECEIVING
    rv_active = switch_flag.

  IF  switch_flag = 'X'.
    CALL FUNCTION 'PS_BAPI_INITIALIZE'
      IMPORTING
        e_dialog_status = lv_dialog_status_tmp
        e_msghand_num   = lv_msghand_num
      TABLES
        return          = et_return.
*
    DATA: BEGIN OF it_rsadd OCCURS 0.
            INCLUDE STRUCTURE rsebani.
    DATA: rsnum TYPE rsnum.
    DATA : rspos TYPE rspos.
    DATA: END OF it_rsadd.



    DATA:l_valuepart TYPE valuepart.
    DATA :lv_extension_filled     LIKE bapi_network_comp_cng_upd.
    DATA:  ls_components_change_upd LIKE bapi_network_comp_cng_upd.
    CONSTANTS: con_yes             VALUE 'X'.
    CLEAR flg_error_occured.
    PERFORM init_event_register.

    data: dialog_status.                                "nt_1286070
    perform log_init changing dialog_status.            "nt_1286070

    PERFORM badi_init.
* check and convert interface data into internal data
    PERFORM check_and_convert_comp_change TABLES i_components_change
                                               i_components_change_update.
*                                     using   number.

    IF flg_error_occured IS INITIAL.
* read and lock network
      PERFORM read_lock_network USING      yx     "lock network
                                CHANGING number.

    ENDIF.

    IF flg_error_occured IS INITIAL.
      PERFORM bapi_component_ext_change
                    TABLES
                       extensionin.
* change components
      PERFORM bapi_component_change.

    ENDIF.


    PERFORM read_log TABLES e_message_table
                      USING  return.

    perFORM bapi_dialog_end USING dialog_status.      "nt_1286070

  ELSE.

     data: lv_message type BAPIRET2.
     DATA lv_message_text TYPE bapi_msg.
     MESSAGE e593(CN) with 'PS_SFWS_SC1' INTO lv_message_text .
     lv_message-message = lv_message_text.
    insert lv_message into table et_mesg.
    RETURN.
   ENDIF.

ENDFUNCTION.
