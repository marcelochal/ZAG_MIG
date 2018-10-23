FUNCTION BAPI_ZNETWORK_ZCOMP_ZGETLIST .
*"--------------------------------------------------------------------
*"*"Interface local:
*"  IMPORTING
*"     VALUE(NUMBER) LIKE  BAPI_NETWORK_LIST-NETWORK
*"     VALUE(MAX_ROWS) LIKE  BAPIF4A-MAX_ROWS DEFAULT 0
*"  EXPORTING
*"     VALUE(RETURN) LIKE  BAPIRET2 STRUCTURE  BAPIRET2
*"  TABLES
*"      I_ACTIVITY_RANGE STRUCTURE  BAPI_NETWORK_COMP_ACT_RNG
*"         OPTIONAL
*"      E_COMPONENTS_LIST STRUCTURE  BAPI_NETWORK_COMP_LIST
*"--------------------------------------------------------------------
*ENHANCEMENT-POINT bapi_network_comp_getlist_g8 SPOTS es_saplcnif_mat STATIC.

*ENHANCEMENT-POINT bapi_network_comp_getlist_g6 SPOTS es_saplcnif_mat.

  DATA: ls_mtcom LIKE mtcom,
        ls_msfcv LIKE msfcv.
*        ls_mtcor LIKE mtcor.
  DATA lv_componentid LIKE bapi_network_comp_list-component.
  DATA lv_rsnum LIKE resb-rsnum.
  DATA lv_rspos LIKE resb-rspos.
  DATA lv_rsart LIKE resb-rsart.
  DATA lv_lines LIKE sy-tfill.
  DATA method_log      LIKE method_log OCCURS 0 WITH HEADER LINE.
  DATA msg_log         LIKE msg_log OCCURS 0 WITH HEADER LINE.
  DATA e_msg_text      LIKE  msg_text OCCURS 0 WITH HEADER LINE.
  DATA e_message_table LIKE
                        bapi_meth_message OCCURS 0 WITH HEADER LINE.
  DATA lv_number LIKE sy-msgno.

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
*      ct_matnr           = E_COMPONENTS_LIST[].

  REFRESH:  e_components_list.

  IF max_rows < 0.
    max_rows = 2147483646.
  ENDIF.

  DATA: dialog_status.                                      "nt_1286070
  PERFORM log_init CHANGING dialog_status.                  "nt_1286070

  SELECT SINGLE * FROM afko WHERE aufnr = number.

  IF NOT sy-subrc IS INITIAL.
* no network found
    MESSAGE e010(cn) WITH number INTO null.
    PERFORM put_sy_message IN PROGRAM saplco2o.
  ELSE.

    SELECT rsnum rspos matnr werks aufnr vornr
*  up to max_rows rows
      INTO
      (lv_rsnum,
        lv_rspos,
        e_components_list-material_long,    "matnr
        e_components_list-plant,            "WERKS
        e_components_list-network,          "Aufnr
        e_components_list-activity)         "VORNR  Vorgangsnummer Netzplan
      FROM resb
      WHERE rsnum = afko-rsnum
      AND vornr IN i_activity_range.

      CONCATENATE lv_rsnum lv_rspos lv_rsart INTO lv_componentid.
      MOVE lv_componentid  TO e_components_list-component.
      APPEND e_components_list.
    ENDSELECT.

* e_components_list-MATL_DESC) "Materialkurztext
    LOOP AT e_components_list.
      CHECK NOT e_components_list-material_long IS INITIAL.
      ls_mtcom-matnr = e_components_list-material_long.
      ls_mtcom-spras = sy-langu.
      ls_mtcom-kenng = 'MSFCV'.

      CALL FUNCTION 'MATERIAL_READ'
        EXPORTING
          schluessel           = ls_mtcom
        IMPORTING
          matdaten             = ls_msfcv
        EXCEPTIONS
          account_not_found    = 1
          batch_not_found      = 2
          forecast_not_found   = 3
          lock_on_account      = 4
          lock_on_material     = 5
          lock_on_plant        = 6
          lock_on_sales        = 7
          lock_on_sloc         = 8
          lock_on_batch        = 9
          lock_system_error    = 10
          material_not_found   = 11
          plant_not_found      = 12
          sales_not_found      = 13
          sloc_not_found       = 14
          slocnumber_not_found = 15
          sloctype_not_found   = 16
          text_not_found       = 17
          unit_not_found       = 18
          invalid_mch1_matnr   = 19
          invalid_mtcom        = 20
          sa_material          = 21
          wv_material          = 22
          waart_error          = 23
          t134m_not_found      = 24
          error_message        = 98
          OTHERS               = 25.
      IF sy-subrc <> 0.
        PERFORM put_sy_message IN PROGRAM saplco2o.
      ELSE.
        e_components_list-matl_desc = ls_msfcv-maktx.
        MODIFY e_components_list FROM e_components_list.
      ENDIF.
    ENDLOOP.

* take max_rows into ccount
    DESCRIBE TABLE e_components_list LINES lv_lines.
    IF lv_lines > max_rows AND max_rows > 0.
      MESSAGE i016(es) WITH max_rows INTO null.
      PERFORM put_sy_message IN PROGRAM saplco2o.
      ADD 1 TO max_rows.
      DELETE e_components_list FROM max_rows TO lv_lines.
    ENDIF.
  ENDIF.

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
    lv_number = e_message_table-message_number.
    CALL FUNCTION 'BALW_BAPIRETURN_GET2'
      EXPORTING
        type   = e_message_table-message_type
        cl     = e_message_table-message_id
        number = lv_number
      IMPORTING
        return = return
      EXCEPTIONS
        OTHERS = 0.
  ENDIF.

  PERFORM bapi_dialog_end USING dialog_status.              "nt_1286070

* FLE MATNR BAPI Changes
  CALL METHOD cl_matnr_chk_mapper=>bapi_tables_conv_tab
    EXPORTING
      iv_int_to_external = 'X'
      it_fnames          = lt_fnames
    CHANGING
      ct_matnr           = e_components_list[].

*ENHANCEMENT-POINT bapi_network_comp_getlist_g7 SPOTS es_saplcnif_mat.
ENDFUNCTION.
