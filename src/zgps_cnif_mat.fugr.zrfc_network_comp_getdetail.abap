FUNCTION ZRFC_NETWORK_COMP_GETDETAIL .
*"--------------------------------------------------------------------
*"*"Interface local:
*"  IMPORTING
*"     VALUE(NUMBER) LIKE  BAPI_NETWORK_LIST-NETWORK
*"     VALUE(MAX_ROWS) LIKE  BAPIF4A-MAX_ROWS DEFAULT 0
*"  EXPORTING
*"     VALUE(RETURN) LIKE  BAPIRET2 STRUCTURE  BAPIRET2
*"     VALUE(ET_MESG) TYPE  BAPIRET2_T
*"  TABLES
*"      I_ACTIVITY_RANGE STRUCTURE  BAPI_NETWORK_COMP_ACT_RNG
*"         OPTIONAL
*"      I_COMPONENTS_ID STRUCTURE  BAPI_NETWORK_COMP_ID OPTIONAL
*"      E_COMPONENTS_DETAIL STRUCTURE  BAPI_NETWORK_COMP_DETAIL
*"      EXTENSIONIN STRUCTURE  BAPIPAREX OPTIONAL
*"      EXTENSIONOUT STRUCTURE  BAPIPAREX OPTIONAL
*"--------------------------------------------------------------------
*ENHANCEMENT-POINT BAPI_NETWORK_COMP_GETDETAIL_G8 SPOTS ES_SAPLCNIF_MAT STATIC.

*ENHANCEMENT-POINT BAPI_NETWORK_COMP_GETDETAIL_G6 SPOTS ES_SAPLCNIF_MAT.
  DATA: switch_flag type XFELD.

  CALL METHOD cl_ops_ps_switch_check=>ps_sfws_sc1 "Note: 1481122
  RECEIVING
    rv_active = switch_flag.

  IF  switch_flag = 'X'.
    DATA resbd_tab LIKE resbdget OCCURS 0 WITH HEADER LINE.
    DATA lv_index LIKE sy-tabix.
    DATA lv_lines LIKE sy-tfill.
    DATA method_log      LIKE method_log OCCURS 0 WITH HEADER LINE.
    DATA msg_log         LIKE msg_log OCCURS 0 WITH HEADER LINE.
    DATA e_msg_text      LIKE  msg_text OCCURS 0 WITH HEADER LINE.
    DATA e_message_table LIKE
                         bapi_meth_message OCCURS 0 WITH HEADER LINE.
    DATA lv_msgno        LIKE sy-msgno.

* FLE MATNR BAPI Changes
  DATA: ls_fnames TYPE cl_matnr_chk_mapper=>ts_matnr_bapi_fnames,
        lt_fnames TYPE cl_matnr_chk_mapper=>tt_matnr_bapi_fname.

  ls_fnames-int  = 'MATERIAL'.
  ls_fnames-ext  = 'MATERIAL_EXTERNAL'.
  ls_fnames-vers = 'MATERIAL_VERSION'.
  ls_fnames-guid = 'MATERIAL_GUID'.
  ls_fnames-long = 'MATERIAL_LONG'.
  INSERT ls_fnames INTO TABLE lt_fnames.

*  CALL METHOD cl_matnr_chk_mapper=>bapi_tables_conv_tab
*    EXPORTING
*      iv_int_to_external = ' '
*      it_fnames          = lt_fnames
*    CHANGING
*      ct_matnr           = e_components_detail[].

    IF max_rows < 0.
      max_rows = 2147483646.
    ENDIF.
    REFRESH: e_components_detail.
    CLEAR flg_error_occured.    "Note 932636

    data: dialog_status.                                "nt_1286070
    perform log_init changing dialog_status.            "nt_1286070

* delete all data from BT tables
* maybe data has been changed since the last call,
* so reset the complete BTs
    CALL FUNCTION 'CO_ZF_DATA_RESET_COMPLETE'.

* read network
    PERFORM read_lock_network
                              USING space
                              CHANGING number. " do not lock network
    IF flg_error_occured IS INITIAL.
* get component data of the given network
      CALL FUNCTION 'CO_BC_RESBD_OF_ORDER_GET'
        EXPORTING
          aufnr_act = number
        TABLES
          resbd_get = resbd_tab.
      MOVE-CORRESPONDING resbd_tab TO it_rsadd_ci.
      APPEND it_rsadd_ci.
* convert int. to ext. interface
      LOOP AT resbd_tab.
        CALL FUNCTION 'MAP2E_RESBDGET_TO_COMP_DETAIL'
          EXPORTING
            resbdget                 = resbd_tab
          CHANGING
            bapi_network_comp_detail = e_components_detail.
        e_components_detail-deletion_flag = resbd_tab-xloek.
        APPEND e_components_detail.
      ENDLOOP.

* check selection criterion:
* a. activitiy range
      IF NOT i_activity_range[] IS INITIAL.
        LOOP AT e_components_detail WHERE NOT activity IN i_activity_range.
          DELETE e_components_detail INDEX sy-tabix.
        ENDLOOP.
      ENDIF.
* b. componenetid
      IF NOT i_components_id[] IS INITIAL.
        LOOP AT e_components_detail.
          lv_index = sy-tabix.
          READ TABLE i_components_id WITH KEY
                      component = e_components_detail-component.
          IF NOT sy-subrc IS INITIAL.
            DELETE e_components_detail INDEX lv_index.
          ENDIF.
        ENDLOOP.
      ENDIF.

* take Max_Row into account
      DESCRIBE TABLE e_components_detail LINES lv_lines.
      IF max_rows > 0 AND max_rows < lv_lines.
        MESSAGE i016(es) WITH max_rows INTO null.
        PERFORM put_sy_message IN PROGRAM saplco2o.
        ADD 1 TO max_rows.
        DELETE e_components_detail FROM max_rows TO lv_lines.
      ENDIF.
    ENDIF.

    PERFORM bapi_component_ext_getdetail
                TABLES
                   e_components_detail
                   extensionout.

    PERFORM fill_status_text TABLES e_components_detail
                                    resbd_tab.
* Read message log and give back to calling program
    CALL FUNCTION 'METHOD_LOG_READ'
      TABLES
        t_method_log_exp = method_log
        t_msg_log_exp    = msg_log
      EXCEPTIONS
        OTHERS           = 0.
    CALL FUNCTION 'MESSAGE_TEXTS_READ'
      TABLES
        t_msg_log_imp   = msg_log
        t_msg_texts_exp = e_msg_text
      EXCEPTIONS
        OTHERS          = 0.

    PERFORM create_msg_table TABLES method_log
                                    msg_log
                                    e_msg_text
                                    e_message_table.

    READ TABLE e_message_table INDEX 1.


    IF sy-subrc IS INITIAL.
* error -> set export parameter RETURN
      lv_msgno = e_message_table-message_number.
      CALL FUNCTION 'BALW_BAPIRETURN_GET2'
        EXPORTING
          type   = e_message_table-message_type
          cl     = e_message_table-message_id
          number = lv_msgno
        IMPORTING
          return = return
        EXCEPTIONS
          OTHERS = 0.
    ENDIF.

    perFORM bapi_dialog_end USING dialog_status.      "nt_1286070

* FLE MATNR BAPI Changes
  CALL METHOD cl_matnr_chk_mapper=>bapi_tables_conv_tab
    EXPORTING
      iv_int_to_external = 'X'
      it_fnames          = lt_fnames
    CHANGING
      ct_matnr           = e_components_detail[].

  ELSE.
    "MESSAGE 'SWITCH NOT ACTIVE' TYPE 'A'.
      data: lv_message type BAPIRET2.
     DATA lv_message_text TYPE bapi_msg.
     MESSAGE e593(CN) with 'PS_SFWS_SC1' INTO lv_message_text .
     lv_message-message = lv_message_text.
    insert lv_message into table et_mesg.
    RETURN.
  ENDIF.
*ENHANCEMENT-POINT BAPI_NETWORK_COMP_GETDETAIL_G7 SPOTS ES_SAPLCNIF_MAT.
ENDFUNCTION.
