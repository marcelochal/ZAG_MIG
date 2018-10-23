FUNCTION bapi_zfuncloc_zcreate.
*"----------------------------------------------------------------------
*"*"Interface local:
*"  IMPORTING
*"     VALUE(EXTERNAL_NUMBER) LIKE  BAPI_ITOB_PARMS-FUNCLOC
*"     VALUE(LABELING_SYSTEM) LIKE  BAPI_ITOB_PARMS-LABEL_SYST OPTIONAL
*"     VALUE(DATA_GENERAL) LIKE  BAPI_ITOB STRUCTURE  BAPI_ITOB
*"     VALUE(DATA_SPECIFIC) LIKE  BAPI_ITOB_FL_ONLY STRUCTURE
*"        BAPI_ITOB_FL_ONLY
*"     VALUE(AUTOMATIC_INSTALL) TYPE  BAPIFLAG-BAPIFLAG OPTIONAL
*"     VALUE(CAMPOS_ZS) TYPE  ITOBAPI_CREATE_FL_ONLY OPTIONAL
*"  EXPORTING
*"     VALUE(FUNCTLOCATION) LIKE  BAPI_ITOB_PARMS-FUNCLOC_INT
*"     VALUE(DATA_GENERAL_EXP) LIKE  BAPI_ITOB STRUCTURE  BAPI_ITOB
*"     VALUE(DATA_SPECIFIC_EXP) LIKE  BAPI_ITOB_FL_ONLY STRUCTURE
*"        BAPI_ITOB_FL_ONLY
*"     VALUE(RETURN) LIKE  BAPIRET2 STRUCTURE  BAPIRET2
*"  TABLES
*"      EXTENSIONIN STRUCTURE  BAPIPAREX OPTIONAL
*"      EXTENSIONOUT STRUCTURE  BAPIPAREX OPTIONAL
*"----------------------------------------------------------------------
*ENHANCEMENT-POINT BAPI_FUNCLOC_CREATE_G6 SPOTS ES_SAPLITOB_BAPI_FL.
  DATA:
    l_itob_rec  LIKE itob,
*   funcloc category data                                  " P6BK104089
    l_t370f_rec LIKE t370f.                         " P6BK104089

* start MFLE MATNR BAPI Changes
  CALL METHOD cl_matnr_chk_mapper=>convert_on_input
    EXPORTING
      iv_matnr18               = data_general-consttype
      iv_guid                  = data_general-consttype_guid
      iv_version               = data_general-consttype_version
      iv_matnr40               = data_general-consttype_long
      iv_matnr_ext             = data_general-consttype_external
    IMPORTING
      ev_matnr40               = data_general-consttype_long
    EXCEPTIONS
      excp_matnr_ne            = 1
      excp_matnr_invalid_input = 2
      OTHERS                   = 3.

  IF sy-subrc NE 0.
    CALL METHOD cl_matnr_chk_mapper=>bapi_get_last_error
      IMPORTING
        ev_return = return.
    IF return-type NA 'SIW'.
      RETURN.
    ENDIF.
  ENDIF.
* end MFLE MATNR BAPI Changes

  cl_eam_usage=>insert('BAPI_FUNCLOC_CREATE').
* mapping interface structures into internal ITOB structure
  CALL FUNCTION 'MAPXI_BAPI_ITOB_TO_ITOB'
    EXPORTING
      bapi_itob                 = data_general
    CHANGING
      itob                      = l_itob_rec
    EXCEPTIONS
      error_converting_iso_code = 1
      OTHERS                    = 2.

  IF sy-subrc <> 0.
*   error handling
    CALL FUNCTION 'BALW_BAPIRETURN_GET2'
      EXPORTING
        type   = sy-msgty
        cl     = sy-msgid
        number = sy-msgno
        par1   = sy-msgv1
        par2   = sy-msgv2
        par3   = sy-msgv3
        par4   = sy-msgv4
      IMPORTING
        return = return.
  ENDIF.

  CALL FUNCTION 'MAPXI_BAPI_ITOB_FL_ONLY_TO_ITO'
    EXPORTING
      bapi_itob_fl_only = data_specific
    CHANGING
      itob              = l_itob_rec.

* read funcloc category data                               " P6BK104089
  CALL FUNCTION 'ITOB_CHECK_CATEGORY'                      " P6BK104089
    EXPORTING                                              " P6BK104089
      itobtype_imp      = itob_type-funcloc          " P6BK104089
      category_imp      = l_itob_rec-fltyp           " P6BK104089
      dialog_mode       = itob_bool-false            " P6BK104089
      init_message_data = itob_bool-false            " P6BK104089
      read_text_tables  = itob_bool-false            " P6BK104089
    IMPORTING                                              " P6BK104089
      t370f_exp         = l_t370f_rec                " P6BK104089
    EXCEPTIONS                                             " P6BK104089
      OTHERS            = 0.                         " P6BK104089

  IF automatic_install = abap_true.
*--- functional location should be automatically installed into hierarchy.
    PERFORM determine_tplma USING    external_number
                                     labeling_system
                                     l_itob_rec-tplkz
                            CHANGING l_itob_rec-tplma
                                     return.
    IF return-type CA 'EAX'.
      RETURN.
    ENDIF.
  ENDIF.

* Linear Asset Management EhP5
  DATA: lt_return TYPE bapirettab.
  IF cl_ops_switch_check=>eam_sfws_lfe( ) IS NOT INITIAL AND
     l_t370f_rec-lfe_ind IS NOT INITIAL.
*   func loc category is flagged 'linear'

    CALL METHOD cl_eaml_bapi_util=>check_data_bapi
      EXPORTING
        iv_obart          = cl_eaml_util=>gc_obart-floc
        iv_key1           = external_number
        iv_akttyp         = cl_eaml_util=>gc_aktyp_create
        is_bapi_structure = data_general
        iv_tplnr          = l_itob_rec-tplnr
        iv_category       = l_itob_rec-fltyp
      IMPORTING
        et_return         = lt_return.
    LOOP AT lt_return INTO return WHERE type CA 'EA'.
      EXIT.
    ENDLOOP.
    IF return-type CA 'EA'.
      EXIT.
    ENDIF.

  ENDIF.

***** begin note 2146575 - customer fields
* call BAdI for mapping of EXTENSIONIN to ITOB
  DATA: lr_badi TYPE REF TO badi_eam_itob_bapi_cust_fields.
  TRY.
      GET BADI lr_badi.
      IF lr_badi IS BOUND.
*        CALL BADI lr_badi->extensionin_funcloc_create
*          EXPORTING
*            iv_external_number = external_number
*            iv_labeling_system = labeling_system
*            it_extensionin     = extensionin[]
*          CHANGING
*            cs_object          = l_itob_rec
*            cs_return          = return.
      ENDIF.
    CATCH cx_badi_not_implemented.
  ENDTRY.
  IF return-type CA 'EAX'.
    EXIT.
  ENDIF.
***** end note 2146575 - customer fields

*-------------------------------------------------*
* Trabalhar com os campos Zs (Customer fields)
  MOVE-CORRESPONDING campos_zs TO l_itob_rec.

*-------------------------------------------------*

* calling ITOB RFC module
  CALL FUNCTION 'FUNC_LOCATION_SAVE'                        "P6BK080944
    EXPORTING                                               "P6BK080944
      i_activity_type = itob_activity-insert          "P6BK080944
      i_funcloc_label = external_number               "P6BK080944
      i_label_system  = labeling_system               "P6BK080944
      i_no_data_check = itob_bool-false               "P6BK080944
      i_write_cdocs   = l_t370f_rec-chdoc            " P6BK104089
      i_auth_tcode    = 'IL01'                        "P6BK080944
      i_filter_data   = itob_bool-true                "P6BK080944
      i_data_post     = itob_bool-true                "P6BK080944
      i_data_transfer = itob_bool-false               "P6BK080944
      i_commit_work   = itob_bool-false               "P6BK080944
    CHANGING                                                "P6BK080944
      c_object_rec    = l_itob_rec                    "P6BK080944
    EXCEPTIONS                                              "P6BK080944
      err_data_check  = 1                             "P6BK080944
      error_message   = 2
      OTHERS          = 3.
  IF sy-subrc <> 0.
*   error handling
    CALL FUNCTION 'BALW_BAPIRETURN_GET2'
      EXPORTING
        type   = sy-msgty
        cl     = sy-msgid
        number = sy-msgno
        par1   = sy-msgv1
        par2   = sy-msgv2
        par3   = sy-msgv3
        par4   = sy-msgv4
      IMPORTING
        return = return.
    EXIT.
  ENDIF.

* Linear Asset Management EhP5
  IF cl_ops_switch_check=>eam_sfws_lfe( ) IS NOT INITIAL AND
     l_t370f_rec-lfe_ind IS NOT INITIAL.
*   func loc category is flagged 'linear'

    CLEAR lt_return.
    CALL METHOD cl_eaml_bapi_util=>set_data_bapi
      EXPORTING
        iv_obart          = cl_eaml_util=>gc_obart-floc
        iv_key1           = l_itob_rec-tplnr
        iv_akttyp         = cl_eaml_data_handler=>gc_aktyp_create
        is_bapi_structure = data_general
        iv_tplnr          = l_itob_rec-tplnr
        iv_category       = l_itob_rec-fltyp
      IMPORTING
        et_return         = lt_return
      CHANGING
        cs_bapi_struc_exp = data_general_exp.

    LOOP AT lt_return INTO return WHERE type CA 'EA'.
      EXIT.
    ENDLOOP.
    IF return-type CA 'EA'.
      EXIT.
    ENDIF.

  ENDIF.

  IF l_itob_rec-adrnr IS NOT INITIAL.
*--- if address number is filled (iherited from superior func.loc.)
*--- save adress to DB
    CALL FUNCTION 'ADDR_SINGLE_SAVE'
      EXPORTING
        address_number         = l_itob_rec-adrnr
        execute_in_update_task = itob_bool-true
      EXCEPTIONS
        OTHERS                 = 0.
  ENDIF.

* mapping internal ITOB structure into interface structures
  CALL FUNCTION 'MAP2E_ITOB_TO_BAPI_ITOB_FL_ONL'
    EXPORTING
      itob              = l_itob_rec
    CHANGING
      bapi_itob_fl_only = data_specific_exp.

  CALL FUNCTION 'MAP2E_ITOB_TO_BAPI_ITOB'
    EXPORTING
      itob      = l_itob_rec
    CHANGING
      bapi_itob = data_general_exp.

* provide object instance number as export parameter
  MOVE l_itob_rec-tplnr TO functlocation.

***** begin note 2146575 - customer fields
* call BAdI for mapping of ITOB to EXTENSIONOUT
  TRY.
      GET BADI lr_badi.
      IF lr_badi IS BOUND.
        CALL BADI lr_badi->extensionout_funcloc
          EXPORTING
            is_object       = l_itob_rec
          CHANGING
            ct_extensionout = extensionout[]
            cs_return       = return.
      ENDIF.
    CATCH cx_badi_not_implemented.
  ENDTRY.
  IF return-type CA 'EAX'.
    EXIT.
  ENDIF.
***** end note 2146575 - customer fields

* start MFLE MATNR BAPI Changes
  CALL METHOD cl_matnr_chk_mapper=>convert_on_output
    EXPORTING
      iv_matnr40               = data_general_exp-consttype_long
    IMPORTING
      ev_matnr18               = data_general_exp-consttype
      ev_matnr40               = data_general_exp-consttype_long
      ev_version               = data_general_exp-consttype_version
      ev_guid                  = data_general_exp-consttype_guid
      ev_matnr_ext             = data_general_exp-consttype_external
    EXCEPTIONS
      excp_matnr_invalid_input = 1
      excp_matnr_not_found     = 2
      OTHERS                   = 3.

  IF sy-subrc NE 0.
    CALL METHOD cl_matnr_chk_mapper=>bapi_get_last_error
      IMPORTING
        ev_return = return.
    IF return-type NA 'SIW'.
      RETURN.
    ENDIF.
  ENDIF.
* end MFLE MATNR BAPI Changes

*ENHANCEMENT-POINT BAPI_FUNCLOC_CREATE_G7 SPOTS ES_SAPLITOB_BAPI_FL.
ENDFUNCTION.

INCLUDE litob_bapi_flf02.
