FUNCTION bapi_zequi_zcreate.
*"----------------------------------------------------------------------
*"*"Interface local:
*"  IMPORTING
*"     VALUE(EXTERNAL_NUMBER) LIKE  BAPI_ITOB_PARMS-EQUIPMENT OPTIONAL
*"     VALUE(DATA_GENERAL) LIKE  BAPI_ITOB STRUCTURE  BAPI_ITOB
*"     VALUE(DATA_SPECIFIC) LIKE  BAPI_ITOB_EQ_ONLY STRUCTURE
*"        BAPI_ITOB_EQ_ONLY
*"     VALUE(DATA_FLEET) LIKE  BAPI_FLEET STRUCTURE  BAPI_FLEET
*"       OPTIONAL
*"     VALUE(VALID_DATE) LIKE  BAPI_ITOB_PARMS-INST_DATE DEFAULT
*"       SY-DATUM
*"     VALUE(DATA_INSTALL) LIKE  BAPI_ITOB_EQ_INSTALL STRUCTURE
*"        BAPI_ITOB_EQ_INSTALL OPTIONAL
*"     VALUE(CAMPOS_ZS) TYPE  ITOBAPI_CREATE_EQ_ONLY OPTIONAL
*"  EXPORTING
*"     VALUE(EQUIPMENT) LIKE  BAPI_ITOB_PARMS-EQUIPMENT
*"     VALUE(DATA_GENERAL_EXP) LIKE  BAPI_ITOB STRUCTURE  BAPI_ITOB
*"     VALUE(DATA_SPECIFIC_EXP) LIKE  BAPI_ITOB_EQ_ONLY STRUCTURE
*"        BAPI_ITOB_EQ_ONLY
*"     VALUE(DATA_FLEET_EXP) LIKE  BAPI_FLEET STRUCTURE  BAPI_FLEET
*"     VALUE(RETURN) LIKE  BAPIRET2 STRUCTURE  BAPIRET2
*"  TABLES
*"      EXTENSIONIN STRUCTURE  BAPIPAREX OPTIONAL
*"      EXTENSIONOUT STRUCTURE  BAPIPAREX OPTIONAL
*"----------------------------------------------------------------------
*ENHANCEMENT-POINT BAPI_EQUI_CREATE_G6 SPOTS ES_SAPLITOB_BAPI_EQ.

* local declarations
  DATA:
*   equipment to be created/installed
    l_itob_rec  LIKE itob,
*   fleet specific equipment data (optional)
    l_fleet_rec LIKE fleet,
*   equipment category data                                " P6BK104089
    l_t370t_rec LIKE t370t.                             " P6BK104089

* iuid data                                                 "EhP4-IUID
  DATA: ls_iuid_data     TYPE iuid_equi.                    "EhP4-IUID
  DATA: ls_iuid_data_old TYPE iuid_equi.                    "EhP4-IUID

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

  CALL METHOD cl_matnr_chk_mapper=>convert_on_input
    EXPORTING
      iv_matnr18               = data_specific-material
      iv_guid                  = data_specific-material_guid
      iv_version               = data_specific-material_version
      iv_matnr40               = data_specific-material_long
      iv_matnr_ext             = data_specific-material_external
    IMPORTING
      ev_matnr40               = data_specific-material_long
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

  CALL METHOD cl_matnr_chk_mapper=>convert_on_input
    EXPORTING
      iv_matnr18               = data_specific-configmat
      iv_guid                  = data_specific-configmat_guid
      iv_version               = data_specific-configmat_version
      iv_matnr40               = data_specific-configmat_long
      iv_matnr_ext             = data_specific-configmat_external
    IMPORTING
      ev_matnr40               = data_specific-configmat_long
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

  cl_eam_usage=>insert('BAPI_EQUI_CREATE').
* refresh buffers after rollback
  CALL FUNCTION 'ITOB_CLEAR_BUFFER'                           "n1600408
    EXCEPTIONS                                              "v n1653052
      not_successful = 1.
  IF sy-subrc = 1.
    CALL FUNCTION 'BALW_BAPIRETURN_GET2'
      EXPORTING
        type   = 'E'
        cl     = 'IE'
        number = '066'
      IMPORTING
        return = return.
    EXIT.
  ENDIF.                                                    "^ n1653052

* initialize export parameters
  CLEAR:
    equipment, data_general_exp, data_specific_exp, data_fleet_exp,
    return.

  IF  NOT data_install-funcloc IS INITIAL
  AND NOT data_install-supequi IS INITIAL.
*   only one installation location is allowed
    CALL FUNCTION 'BALW_BAPIRETURN_GET2'
      EXPORTING
        type   = 'E'
        cl     = 'IE'
        number = '048'
      IMPORTING
        return = return.
    EXIT.
  ENDIF.

* map interface structures into internal ITOB structure
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
    EXIT.
  ENDIF.

  CALL FUNCTION 'MAPXI_BAPI_ITOB_EQ_ONLY_TO_ITO'
    EXPORTING
      bapi_itob_eq_only = data_specific
    CHANGING
      itob              = l_itob_rec.

  IF NOT data_fleet IS INITIAL.
*   map interface structure into internal FLEET structure
    CALL FUNCTION 'MAPXI_BAPI_FLEET_TO_FLEET'
      EXPORTING
        bapi_fleet                = data_fleet
      CHANGING
        fleet                     = l_fleet_rec
      EXCEPTIONS
        error_converting_iso_code = 1
        OTHERS                    = 2.

    IF sy-subrc <> 0.
*     error handling
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

*   mapping of fields appearing bot in ITOB and FLEET
    l_fleet_rec-fleet_cat = l_itob_rec-eqart.
    l_fleet_rec-wgt_unit  = l_itob_rec-gewei.
  ENDIF.

* copy equipment number into ITOB structure
  l_itob_rec-equnr = external_number.

* call access level management                              "P9CK186118
  CALL FUNCTION 'OBJECT_SET_ACCESS_LEVEL'                   "P9CK186118
    EXPORTING                                               "P9CK186118
      id_objnr = space                                "P9CK186118
      id_equnr = l_itob_rec-equnr                     "P9CK186118
      id_level = gc_level_equi-bapi.                  "P9CK186118

* read equipment category data                             " P6BK104089
  CALL FUNCTION 'ITOB_CHECK_CATEGORY'                      " P6BK104089
    EXPORTING                                              " P6BK104089
      itobtype_imp      = itob_type-equi             " P6BK104089
      category_imp      = l_itob_rec-eqtyp           " P6BK104089
      dialog_mode       = itob_bool-false            " P6BK104089
      init_message_data = itob_bool-false            " P6BK104089
      read_text_tables  = itob_bool-false            " P6BK104089
    IMPORTING                                              " P6BK104089
      t370t_exp         = l_t370t_rec                " P6BK104089
    EXCEPTIONS                                             " P6BK104089
      OTHERS            = 0.                         " P6BK104089

* installation position to be set via structure DATA_INSTALL"P6DK003643
  CLEAR l_itob_rec-posnr.                                   "P6DK003643

*ENHANCEMENT-POINT EHP_BAPI_EQUI_CREATE_01 SPOTS ES_SAPLITOB_BAPI_EQ.

* Linear Asset Management EhP5
  DATA: lt_return TYPE bapirettab.
  IF cl_ops_switch_check=>eam_sfws_lfe( ) IS NOT INITIAL AND
     l_t370t_rec-lfe_ind IS NOT INITIAL.
*   equipment category is flagged 'linear'

    CALL METHOD cl_eaml_bapi_util=>check_data_bapi
      EXPORTING
        iv_obart          = cl_eaml_util=>gc_obart-equi
        iv_key1           = external_number
        iv_akttyp         = cl_eaml_util=>gc_aktyp_create
        is_bapi_structure = data_general
        iv_equnr          = l_itob_rec-equnr
        iv_category       = l_itob_rec-eqtyp
      IMPORTING
        et_return         = lt_return.

    LOOP AT lt_return INTO return WHERE type CA 'EA'.
      EXIT.
    ENDLOOP.
    IF return-type CA 'EA'.
      EXIT.
    ENDIF.

  ENDIF.

* lock MATNR/SERNR combination before processing             v n1441539
*IF DATA_SPECIFIC-MATERIAL IS NOT INITIAL AND            "MFLE
  IF data_specific-material_long IS NOT INITIAL AND        "MFLE
     data_specific-serialno IS NOT INITIAL.

    CALL FUNCTION 'ITOB_SERIALNO_READ_SINGLE'                 "v n1516791
      EXPORTING
*       i_matnr        = data_specific-material      "MFLE
        i_matnr        = data_specific-material_long  "MFLE
        i_sernr        = data_specific-serialno
      EXCEPTIONS
        not_successful = 1
        OTHERS         = 2.
    IF sy-subrc = 0.
* error handling - MATNR/SERNR is already in write buffer
* do not create duplicates
      MOVE data_specific-serialno TO sy-msgv1.
*    MOVE data_specific-material TO sy-msgv2.      "MFLE
      MOVE data_specific-material_long TO sy-msgv2.  "MFLE
      CALL FUNCTION 'BALW_BAPIRETURN_GET2'
        EXPORTING
          type   = 'E'
          cl     = 'ITOB'
          number = 413
          par1   = sy-msgv1
          par2   = sy-msgv2
          par3   = sy-msgv3
          par4   = sy-msgv4
        IMPORTING
          return = return.
      EXIT.
    ENDIF.                                                  "^ n1516791

    CALL FUNCTION 'ITOB_SERIALNO_LOCK_SINGLE'
      EXPORTING
*       I_MATNR        = DATA_SPECIFIC-MATERIAL       "MFLE
        i_matnr        = data_specific-material_long   "MFLE
        i_sernr        = data_specific-serialno
      EXCEPTIONS
        not_successful = 1
        OTHERS         = 2.
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
  ENDIF.
*                                                            ^ n1441539

***** begin note 2146575 - customer fields
* call BAdI for mapping of EXTENSIONIN to ITOB
  DATA: lr_badi TYPE REF TO badi_eam_itob_bapi_cust_fields.
  TRY.
      GET BADI lr_badi.
      IF lr_badi IS BOUND.
*        CALL BADI lr_badi->extensionin_equi_create
*          EXPORTING
*            is_data_install = data_install
*            it_extensionin  = extensionin[]
*          CHANGING
*            cs_object       = l_itob_rec
*            cs_fleet        = l_fleet_rec
*            cs_return       = return.
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

* create equipment master via EQUIPMENT_SAVE                "P6BK080944
  l_itob_rec-datab = valid_date.                            "P6BK080944
  CALL FUNCTION 'EQUIPMENT_SAVE'                            "P6BK080944
    EXPORTING                                               "P6BK080944
      i_activity_type   = itob_activity-insert        "P6BK080944
      i_itob_type       = itob_type-equi              "P6BK080944
      i_install_rec     = data_install                "P6BK080944
      i_no_data_check   = itob_bool-false             "P6BK080944
      i_no_extnum_check = itob_bool-false             " P6BK151475
      i_sync_asset      = itob_bool-true              "P6BK080944
      i_write_cdocs     = l_t370t_rec-aebkz           " P6BK104089
      i_auth_tcode      = gc_transaction-equi_create  "P6BK080944
      i_filter_data     = itob_bool-true              "P6BK080944
      i_data_post       = itob_bool-true              "P6BK080944
      i_data_transfer   = itob_bool-false             "P6BK080944
      i_success_message = itob_bool-false             "P6BK080944
      i_commit_work     = itob_bool-false             "P6BK080944
    CHANGING                                                "P6BK080944
      c_object_rec      = l_itob_rec                  "P6BK080944
      c_fleet_rec       = l_fleet_rec
    EXCEPTIONS                                              "P6BK080944
      err_data_check    = 1                           "P6BK080944
      OTHERS            = 2.                          "P6BK080944

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
     l_t370t_rec-lfe_ind IS NOT INITIAL.
*   equipment category is flagged 'linear'

    CLEAR lt_return.
    CALL METHOD cl_eaml_bapi_util=>set_data_bapi
      EXPORTING
        iv_obart          = cl_eaml_util=>gc_obart-equi
        iv_key1           = l_itob_rec-equnr
        iv_akttyp         = cl_eaml_data_handler=>gc_aktyp_create
        is_bapi_structure = data_general
        iv_equnr          = l_itob_rec-equnr
        iv_category       = l_itob_rec-eqtyp
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

* map internal ITOB structure into interface structures
  CALL FUNCTION 'MAP2E_ITOB_TO_BAPI_ITOB_EQ_ONL'
    EXPORTING
      itob              = l_itob_rec
    CHANGING
      bapi_itob_eq_only = data_specific_exp.

  CALL FUNCTION 'MAP2E_ITOB_TO_BAPI_ITOB'
    EXPORTING
      itob      = l_itob_rec
    CHANGING
      bapi_itob = data_general_exp.

  IF NOT data_fleet IS INITIAL.
*   map internal FLEET structure into interface structure
    CALL FUNCTION 'MAP2E_FLEET_TO_BAPI_FLEET'
      EXPORTING
        fleet      = l_fleet_rec
      CHANGING
        bapi_fleet = data_fleet_exp.
  ENDIF.

* provide object instance number as export parameter
  equipment = l_itob_rec-equnr.

***** begin note 2146575 - customer fields
* call BAdI for mapping of ITOB to EXTENSIONOUT
  TRY.
      GET BADI lr_badi.
      IF lr_badi IS BOUND.
        CALL BADI lr_badi->extensionout_equi
          EXPORTING
            is_object       = l_itob_rec
            is_fleet        = l_fleet_rec
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

  CALL METHOD cl_matnr_chk_mapper=>convert_on_output
    EXPORTING
      iv_matnr40               = data_specific_exp-material_long
    IMPORTING
      ev_matnr18               = data_specific_exp-material
      ev_matnr40               = data_specific_exp-material_long
      ev_version               = data_specific_exp-material_version
      ev_guid                  = data_specific_exp-material_guid
      ev_matnr_ext             = data_specific_exp-material_external
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

  CALL METHOD cl_matnr_chk_mapper=>convert_on_output
    EXPORTING
      iv_matnr40               = data_specific_exp-configmat_long
    IMPORTING
      ev_matnr18               = data_specific_exp-configmat
      ev_matnr40               = data_specific_exp-configmat_long
      ev_version               = data_specific_exp-configmat_version
      ev_guid                  = data_specific_exp-configmat_guid
      ev_matnr_ext             = data_specific_exp-configmat_external
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


*ENHANCEMENT-POINT BAPI_EQUI_CREATE_G7 SPOTS ES_SAPLITOB_BAPI_EQ.

ENDFUNCTION.
