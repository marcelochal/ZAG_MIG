FUNCTION BAPI_ZNETWORK_ZCOMP_ZADD .
*"----------------------------------------------------------------------
*"*"Interface local:
*"  IMPORTING
*"     VALUE(NUMBER) LIKE  BAPI_NETWORK_LIST-NETWORK
*"  EXPORTING
*"     VALUE(RETURN) LIKE  BAPIRET2 STRUCTURE  BAPIRET2
*"  TABLES
*"      I_COMPONENTS_ADD STRUCTURE  ZEPS_BAPI_NETWORK_COMP_ADD
*"      E_MESSAGE_TABLE STRUCTURE  BAPI_METH_MESSAGE
*"----------------------------------------------------------------------
*ENHANCEMENT-POINT bapi_network_comp_add_g8 SPOTS es_saplcnif_mat STATIC.

*ENHANCEMENT-POINT bapi_network_comp_add_g6 SPOTS es_saplcnif_mat.

* FLE MATNR BAPI Changes
  DATA: ls_fnames TYPE cl_matnr_chk_mapper=>ts_matnr_bapi_fnames,
        lt_fnames TYPE cl_matnr_chk_mapper=>tt_matnr_bapi_fname.

  ls_fnames-int  = 'MATERIAL'.
  ls_fnames-ext  = 'MATERIAL_EXTERNAL'.
  ls_fnames-vers = 'MATERIAL_VERSION'.
  ls_fnames-guid = 'MATERIAL_GUID'.
  ls_fnames-long = 'MATERIAL_LONG'.
  INSERT ls_fnames INTO TABLE lt_fnames.

  CALL METHOD cl_matnr_chk_mapper=>bapi_tables_conv_tab
    EXPORTING
      iv_int_to_external = ' '
      it_fnames          = lt_fnames
    CHANGING
      ct_matnr           = i_components_add[].

  CLEAR flg_error_occured.

  PERFORM init_event_register.

*  CALL FUNCTION 'CO_ZF_DATA_RESET_COMPLETE'.    "NOTE 1290649

  DATA: dialog_status.                                      "nt_1286070
  PERFORM log_init CHANGING dialog_status.                  "nt_1286070

  PERFORM badi_init.

* check and convert external data into internal data

* Adaptada para trabalhar com campos Zs e adicionais
  PERFORM check_and_convert_comp_add_2 TABLES i_components_add.
  " using   number.

  IF flg_error_occured IS INITIAL.
* read and lock network
    PERFORM read_lock_network     USING yx    "lock network
                                  CHANGING number.
  ENDIF.

  IF flg_error_occured IS INITIAL.
    DATA bapi_aufnr LIKE bapi_network_list-network.  "NOTE 1290649
    bapi_aufnr = number.                             "NOTE 1290649
    EXPORT bapi_aufnr TO MEMORY ID 'BAPI_AUFNR'.     "NOTE 1290649
* add components
    PERFORM bapi_components_add.
    DELETE FROM MEMORY ID 'BAPI_AUFNR'.              "NOTE 1290649
  ENDIF.

  PERFORM read_log TABLES e_message_table
                   USING  return.

  PERFORM bapi_dialog_end USING dialog_status.              "nt_1286070


* FLE MATNR BAPI Changes
  CALL METHOD cl_matnr_chk_mapper=>bapi_tables_conv_tab
    EXPORTING
      iv_int_to_external = 'X'
      it_fnames          = lt_fnames
    CHANGING
      ct_matnr           = i_components_add[].


*ENHANCEMENT-POINT bapi_network_comp_add_g7 SPOTS es_saplcnif_mat.
ENDFUNCTION.
