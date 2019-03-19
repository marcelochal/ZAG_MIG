*--------------------------------------------------------------------*
*               P R O J E T O    A G I R - T A E S A                 *
*--------------------------------------------------------------------*
* Consultoria .....: I N T E C H P R O                               *
* Res. ABAP........: Marcelo Alvares                                 *
* Res. Funcional...: Marcelo Alvares                                 *
* Módulo...........: FI                                              *
* Programa.........: ZRAG_CARGA_ACC_POST                             *
* Transação........: N/A                                             *
* Tipo de Programa.: REPORT                                          *
* Request..........:                                                 *
* Objetivo.........: Carga de lançamentos contabeis faturas e saldos *
*--------------------------------------------------------------------*
* Change Control:                                                    *
* Version | Date      | Who                 |   What                 *
*    1.00 | 21/11/18  | Marcelo Alvares     |   Versão Inicial       *
**********************************************************************
*&---------------------------------------------------------------------*
*& INCLUDE ZRAG_CARGA_ACC_POST_CL
*&---------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*& CLASS DEFINITION LCL_PROGRESS_INDICATOR
*&---------------------------------------------------------------------*
CLASS lcl_progress_indicator DEFINITION.
  PUBLIC SECTION.

* Interface required to serialize the object
    INTERFACES:
      if_serializable_object.

    METHODS:
      constructor
        IMPORTING
          im_v_total TYPE i OPTIONAL
            PREFERRED PARAMETER im_v_total,
      show
        IMPORTING
          VALUE(im_v_text) TYPE any
          im_v_processed   TYPE i OPTIONAL.
  PRIVATE SECTION.

    CONSTANTS:
       ratio_percentage TYPE i VALUE 25.

    DATA:
      total TYPE i,
      ratio TYPE decfloat16,
      rtime TYPE i.

ENDCLASS.

*&---------------------------------------------------------------------*
*& CLASS DEFINITION LCL_BAL_LOG
*&---------------------------------------------------------------------*
"! Class for SLG1
CLASS lcl_bal_log DEFINITION.
  PUBLIC SECTION.

    CONSTANTS:
      c_log_object TYPE bal_s_log-object    VALUE 'ZAG_MIG',
      c_class_str  TYPE c LENGTH 11         VALUE '\CLASS=LCL_'.

* Interface required to serialize the object
    INTERFACES:
      if_serializable_object.

    METHODS:
      constructor
        IMPORTING
          im_o_object    TYPE REF TO object       OPTIONAL
          im_v_subobject TYPE bal_s_log-subobject OPTIONAL
        EXCEPTIONS
          log_header_inconsistent ,
      get_log_handle
        RETURNING VALUE(r_result) TYPE balloghndl,
      get_log_header
        RETURNING VALUE(r_result) TYPE bal_s_log,
      get_log_extnumber
        RETURNING VALUE(r_result) TYPE bal_s_log-extnumber,
      msg_add
        IMPORTING
          im_s_msg      TYPE bal_s_msg OPTIONAL
          im_s_bapiret2 TYPE bapiret2  OPTIONAL
            PREFERRED PARAMETER im_s_bapiret2
        EXCEPTIONS
          log_not_found
          msg_inconsistent
          log_is_full,
      save,
      show.

  PRIVATE SECTION.
    DATA:
      log_handle TYPE balloghndl,
      log_header TYPE bal_s_log.
    METHODS create
      IMPORTING
        im_v_subobject TYPE bal_s_log-subobject OPTIONAL
        im_o_object    TYPE REF TO object       OPTIONAL
          PREFERRED PARAMETER im_o_object
      EXCEPTIONS
        log_header_inconsistent .

ENDCLASS.

*&---------------------------------------------------------------------*
*& CLASS DEFINITION LCL_FILE
*&---------------------------------------------------------------------*
CLASS lcl_file DEFINITION.

  PUBLIC SECTION.
    TYPES:
      BEGIN OF ty_serialize,
        guid    TYPE guid_22,
        objtype TYPE c LENGTH 3,
        xml     TYPE xstring,
      END OF ty_serialize.

    CONSTANTS:
      c_memory_id1   TYPE memoryid      VALUE 'ZRAG_01',
      cc_msg_error   TYPE smesg-msgty   VALUE 'E', "Type of message (E)
      c_currency_brl TYPE c LENGTH 3    VALUE 'BRL',
      c_rb1_id       TYPE memoryid      VALUE 'ZMIG_CARGARB1',
      c_rb2_id       TYPE memoryid      VALUE 'ZMIG_CARGARB2',
      c_rb3_id       TYPE memoryid      VALUE 'ZMIG_CARGARB3'.

* Interface required to serialize the object
    INTERFACES:
      if_serializable_object.

    CLASS-METHODS:
      get_init_filename
        EXPORTING
          ex_v_dirup        TYPE string
          ex_v_dirdown      TYPE string
        RETURNING
          VALUE(r_filename) TYPE string,
      select_file
        RETURNING
          VALUE(r_filename) TYPE file_table-filename,
      set_sscrtexts,
      export_model,
      start_upload
        IMPORTING
          im_b_onli TYPE abap_bool OPTIONAL,
      set_parameter,
      get_parameter,
      get_object_from_memory,
      set_obj_to_memory,
      upload_to_server,
      export_model_zcl_excel
        IMPORTING
          VALUE(im_model)       TYPE any
          VALUE(im_v_file_name) TYPE string,
      set_table_model
        IMPORTING
          im_o_excel     TYPE REF TO zcl_excel
          im_v_plan_name TYPE zexcel_sheet_title
          im_t_table     TYPE ANY TABLE
          p_first        TYPE abap_bool.

    METHODS:
      constructor
        IMPORTING
          im_v_file_path TYPE any,
*      set_parameter_id
*        IMPORTING
*          im_v_file TYPE rlgrap-filename,
      get_file_path
        RETURNING
          VALUE(r_result) TYPE rlgrap-filename,
      set_file_path
        IMPORTING
          im_v_file_path TYPE rlgrap-filename,
      upload
        EXCEPTIONS
          conversion_failed
          upload_date_not_found,
      export_obj_to_memory.

  PROTECTED SECTION.

    DATA:
      t_bukrs_tab    TYPE STANDARD TABLE OF ty_s_bukrs,
      o_progress_ind TYPE REF TO lcl_progress_indicator,
      o_bal_log      TYPE REF TO lcl_bal_log.
    METHODS:
      upload_super
        CHANGING
          ch_tab_converted_data TYPE STANDARD TABLE
        EXCEPTIONS
          conversion_failed
          upload_date_not_found,
      upload_zcl_excel
        CHANGING
          ch_s_converted_data TYPE any
        EXCEPTIONS
          conversion_failed
          upload_date_not_found,
      get_bus_area
        IMPORTING
          im_v_bukrs      TYPE bukrs
        RETURNING
          VALUE(r_result) TYPE bapiacgl09-bus_area,
      call_bapi_acc_document_post
        IMPORTING
          im_v_test              TYPE xtest
        EXPORTING
          ex_t_return            TYPE bapiret2_t
        CHANGING
          ch_t_accountreceivable TYPE bapiacar09_tab OPTIONAL
          ch_t_accountpayable    TYPE bapiacap09_tab OPTIONAL
          ch_s_documentheader    TYPE bapiache09
          ch_t_accountgl         TYPE bapiacgl09_tab OPTIONAL
          ch_t_currencyamount    TYPE bapiaccr09_tab
          ch_t_extension2        TYPE bapiparex_tab  OPTIONAL,
      document_post
        IMPORTING
          im_v_bukrs             TYPE bukrs      OPTIONAL
          im_s_documentheader    TYPE bapiache09 OPTIONAL
        EXPORTING
          ex_t_return            TYPE bapiret2_t
        CHANGING
          ch_t_accountreceivable TYPE bapiacar09_tab OPTIONAL
          ch_t_accountpayable    TYPE bapiacap09_tab OPTIONAL
          ch_t_accountgl         TYPE bapiacgl09_tab OPTIONAL
          ch_t_currencyamount    TYPE bapiaccr09_tab OPTIONAL
          ch_t_extension2        TYPE bapiparex_tab  OPTIONAL,
      return_msg
        IMPORTING
          i_t_return TYPE bapiret2_t OPTIONAL
          im_v_text  TYPE any     OPTIONAL
            PREFERRED PARAMETER i_t_return,
      select_bukrs
        IMPORTING
          im_t_upload_data TYPE ANY TABLE ,
      write_header,
      get_object_type
        RETURNING
          VALUE(r_result) TYPE lcl_file=>ty_serialize-objtype.

  PRIVATE SECTION.
    DATA:
*      upload_data TYPE any TABLE OF,
      file_path   TYPE rlgrap-filename.
    METHODS:
      file_validate_path.



ENDCLASS.           "lcl_file

*&---------------------------------------------------------------------*
*& CLASS DEFINITION LCL_GL_BALANCE
*&---------------------------------------------------------------------*
CLASS lcl_gl_balance DEFINITION INHERITING FROM lcl_file.

  PUBLIC SECTION.
    TYPES:
      ty_t_upload_data TYPE STANDARD TABLE OF ty_s_gl_balance WITH EMPTY KEY.

    CONSTANTS:
      objtype TYPE lcl_file=>ty_serialize-objtype VALUE 'GL'.

    DATA:
      upload_data TYPE ty_t_upload_data.
*      bukrs_tab   TYPE STANDARD TABLE OF ty_s_bukrs.

    METHODS:
      get_upload_data
        RETURNING
          VALUE(r_result) TYPE ty_t_upload_data,
      set_upload_data
        IMPORTING
          im_t_upload_data TYPE ty_t_upload_data,
      upload REDEFINITION,
      handle_data,
      handle_data_single,
      get_housebank
        CHANGING
          ch_s_accountgl TYPE bapiacgl09
        RETURNING
          VALUE(r_t012k) TYPE t012k.

  PROTECTED SECTION.
    METHODS:
      get_object_type REDEFINITION.


  PRIVATE SECTION.
    METHODS:
      fill_accountgl
        IMPORTING
          VALUE(im_s_data) TYPE ty_s_gl_balance
        RETURNING
          VALUE(r_result)  TYPE bapiacgl09.
*          VALUE(im_s_upload_data) TYPE ty_s_gl_balance
*        RETURNING
*          VALUE(r_result)         TYPE bapiacgl09-costcenter.


ENDCLASS.

*&---------------------------------------------------------------------*
*& CLASS DEFINITION LCL_PS_BALANCE
*&---------------------------------------------------------------------*
CLASS lcl_ps_balance DEFINITION INHERITING FROM lcl_file.

  PUBLIC SECTION.
    TYPES:
      BEGIN OF ty_s_ref_doc,
        comp_code  TYPE bapiache09-comp_code,
        ref_doc_no TYPE bapiache09-ref_doc_no,  "Nº documento de referência
        doc_date   TYPE bapiache09-doc_date,    "Data no documento
        shkzg      TYPE shkzg,
      END OF ty_s_ref_doc,
      ty_t_ref_doc     TYPE STANDARD TABLE OF ty_s_ref_doc WITH NON-UNIQUE SORTED KEY key1
                                                           COMPONENTS comp_code doc_date ref_doc_no shkzg,
      ty_t_upload_data TYPE STANDARD TABLE OF ty_s_ps_balance WITH DEFAULT KEY.

    CONSTANTS:
      tcode   TYPE tcode VALUE 'FB50',
      gkont   TYPE gkont VALUE '9100021999',
      objtype TYPE lcl_file=>ty_serialize-objtype VALUE 'PS'.

    DATA:
      upload_data TYPE ty_t_upload_data,
      ref_doc     TYPE ty_t_ref_doc.
*      bukrs_tab   TYPE STANDARD TABLE OF ty_s_bukrs.

    METHODS:
      get_upload_data
        RETURNING
          VALUE(r_result) TYPE ty_t_upload_data,
      set_upload_data
        IMPORTING
          im_t_upload_data TYPE ty_t_upload_data,
      upload REDEFINITION,
      handle_data_ps.

  PROTECTED SECTION.
    METHODS:
      get_object_type REDEFINITION.

  PRIVATE SECTION.
    METHODS:
*      select_bukrs,
      document_post_ps
        EXPORTING
          ex_t_return         TYPE bapiret2_t
        CHANGING
          ch_s_documentheader TYPE bapiache09
          ch_t_accountgl      TYPE bapiacgl09_tab
          ch_t_currencyamount TYPE bapiaccr09_tab,
      convert_data.
*      remove_reversed.


ENDCLASS.

*&---------------------------------------------------------------------*
*& CLASS DEFINITION LCL_ACC_RECEIVABLE
*&---------------------------------------------------------------------*
CLASS lcl_acc_receivable DEFINITION INHERITING 	FROM lcl_file.

  PUBLIC SECTION.
    TYPES:
      ty_t_upload_data TYPE STANDARD TABLE OF ty_s_accounts_receivable WITH EMPTY KEY.

    CONSTANTS:
      tcode TYPE tcode               VALUE 'FB70',
      gkont TYPE gkont               VALUE '9100021004'.

    DATA:
      upload_data TYPE ty_t_upload_data,
      obj_key     TYPE awkey.

    METHODS:
      get_upload_data
        RETURNING
          VALUE(r_result) TYPE ty_t_upload_data,
      set_upload_data
        IMPORTING
          im_t_upload_data TYPE ty_t_upload_data,
      upload REDEFINITION,
      handle_data_ar.
  PROTECTED SECTION.
    METHODS:
      document_post REDEFINITION,
      get_object_type REDEFINITION.


  PRIVATE SECTION.
    METHODS:
      define_debit_credit
        IMPORTING
          im_s_upload_data TYPE ty_s_accounts_receivable
        RETURNING
          VALUE(r_result)  TYPE bapiaccr09-amt_doccur.

ENDCLASS.

*&---------------------------------------------------------------------*
*& CLASS DEFINITION LCL_ACC_PAYABLE
*&---------------------------------------------------------------------*
CLASS lcl_acc_payable DEFINITION INHERITING   FROM lcl_file.

  PUBLIC SECTION.
    TYPES:
      ty_t_upload_data TYPE STANDARD TABLE OF ty_s_accounts_payable WITH EMPTY KEY.

    CONSTANTS:
      tcode   TYPE tcode VALUE 'FB60',
      gkont   TYPE gkont VALUE '9100021003',
      objtype TYPE lcl_file=>ty_serialize-objtype VALUE 'AP'.

    DATA:
      upload_data TYPE ty_t_upload_data,
      obj_key     TYPE awkey.

    METHODS:
      get_upload_data
        RETURNING
          VALUE(r_result) TYPE ty_t_upload_data,
      set_upload_data
        IMPORTING
          im_t_upload_data TYPE ty_t_upload_data,
      upload REDEFINITION,
      handle_data_ap.
  PROTECTED SECTION.
    METHODS:
      document_post REDEFINITION,
      get_object_type REDEFINITION.


  PRIVATE SECTION.
    METHODS:
*      select_bukrs,
      fill_accountgl
        IMPORTING
          VALUE(im_s_data) TYPE ty_s_gl_balance
        RETURNING
          VALUE(r_result)  TYPE bapiacgl09,
      define_debit_credit
        IMPORTING
          im_s_upload_data TYPE ty_s_accounts_payable
        RETURNING
          VALUE(r_result)  TYPE bapiaccr09-amt_doccur.
ENDCLASS.

*&---------------------------------------------------------------------*
*& CLASS DEFINITION LCL_GLACCOUNT
*&---------------------------------------------------------------------*
CLASS lcl_glaccount DEFINITION INHERITING     FROM lcl_file.

  PUBLIC SECTION.

    TYPES:
      ty_s_upload_data LIKE gs_glaccount.

    METHODS:
      get_upload_data RETURNING VALUE(r_result)  TYPE ty_s_upload_data,
      set_upload_data IMPORTING im_s_upload_data TYPE ty_s_upload_data,
      upload          REDEFINITION,
      handle_data.

  PROTECTED SECTION.

  PRIVATE SECTION.
    DATA:
        upload_data     TYPE ty_s_upload_data.

ENDCLASS.

*&---------------------------------------------------------------------*
*&CLASS DEFINITION MESSAGES
*&---------------------------------------------------------------------*

*&======================================================================
*&
*&  CLASS IMPLEMENTATION
*&
*&======================================================================

*&=====================================================================*
*& CLASS IMPLEMENTATION LCL_PROGRESS_INDICATOR
*&=====================================================================*
CLASS lcl_progress_indicator IMPLEMENTATION.

  METHOD constructor.

    me->total = im_v_total.

    IF me->total IS NOT INITIAL.
      me->ratio = me->total / ratio_percentage.
    ENDIF.
  ENDMETHOD.

*&---------------------------------------------------------------------*
*& METHOD PROGRESS_INDICATOR
*&---------------------------------------------------------------------*
*& --> iv_text      Texto a ser utilizado na mensagem
*& --> iv_processed Valor sendo processado
*& --> iv_total     Total do valores a serem processados
*&---------------------------------------------------------------------*
  METHOD show.

    DATA:
      lv_text     TYPE string,
      lv_output_i TYPE boole_d VALUE IS INITIAL,
      lv_rtime    TYPE i.

    IF im_v_processed IS NOT INITIAL AND im_v_processed EQ 1.
      GET RUN TIME FIELD me->rtime.
    ENDIF.

    IF me->total IS NOT INITIAL.
      lv_text = | { im_v_text } [{ im_v_processed } de { me->total }] |.
    ELSE.
      lv_text = im_v_text .
    ENDIF.

    DATA(lv_result_mod) = im_v_processed MOD me->ratio.

*   Displays the message every 25% OR every 10sec or First times
    IF ( im_v_processed LT 4 )    OR
         lv_result_mod IS INITIAL OR
         ( lv_rtime - me->rtime ) GT 10000. "10 sec
      lv_output_i = abap_true.
    ENDIF.

    CALL METHOD cl_progress_indicator=>progress_indicate
      EXPORTING
        i_text               = lv_text          " Progress Text (If no message transferred in I_MSG*)
        i_processed          = im_v_processed   " Number of Objects Already Processed
        i_total              = me->total        " Total Number of Objects to Be Processed
        i_output_immediately = lv_output_i.     " X = Display Progress Immediately

  ENDMETHOD.

ENDCLASS.

*&=====================================================================*
*& CLASS IMPLEMENTATION lcl_bal_log
*&=====================================================================*
CLASS lcl_bal_log IMPLEMENTATION.

  METHOD constructor.

    CALL METHOD me->create
      EXPORTING
        im_v_subobject          = im_v_subobject
        im_o_object             = im_o_object
      EXCEPTIONS
        log_header_inconsistent = 1
        OTHERS                  = 2.
    IF sy-subrc NE 0.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
        WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 RAISING log_header_inconsistent.
    ENDIF.

  ENDMETHOD.

  METHOD get_log_handle.
    r_result = me->log_handle.
  ENDMETHOD.

  METHOD msg_add.
    DATA:
      ls_msg               TYPE bal_s_msg,
      ls_msg_handle        TYPE balmsghndl,
      lb_msg_was_logged    TYPE boolean,
      lb_msg_was_displayed TYPE boolean.

    MOVE-CORRESPONDING im_s_msg TO ls_msg.

    IF im_s_bapiret2 IS NOT INITIAL.
      ls_msg-msgid =  im_s_bapiret2-id.
      ls_msg-msgno = im_s_bapiret2-number.
      ls_msg-msgty = im_s_bapiret2-type.
      ls_msg-msgv1 = im_s_bapiret2-message_v1.
      ls_msg-msgv2 = im_s_bapiret2-message_v2.
      ls_msg-msgv3 = im_s_bapiret2-message_v3.
      ls_msg-msgv4 = im_s_bapiret2-message_v4.
*      ls_msg-
*      ls_msg- = im_s_bapiret2-id.

    ELSEIF ls_msg IS INITIAL.
      MOVE-CORRESPONDING syst TO ls_msg.
    ENDIF.

    CALL FUNCTION 'BAL_LOG_MSG_ADD'
      EXPORTING
        i_log_handle        = me->log_handle   " Log handle
        i_s_msg             = ls_msg           " Notification data
      IMPORTING
        e_s_msg_handle      = ls_msg_handle         " Message handle
        e_msg_was_logged    = lb_msg_was_logged     " Message collected
        e_msg_was_displayed = lb_msg_was_displayed  " Message output
      EXCEPTIONS
        log_not_found       = 1                " Log not found
        msg_inconsistent    = 2                " Message inconsistent
        log_is_full         = 3                " Message number 999999 reached. Log is full
        OTHERS              = 4.

    CASE sy-subrc.
      WHEN 1.

        CALL METHOD me->create
          EXPORTING
            im_v_subobject          = me->log_header-subobject
          EXCEPTIONS
            log_header_inconsistent = 1
            OTHERS                  = 2.

        IF syst-subrc IS INITIAL.
          CALL FUNCTION 'BAL_LOG_MSG_ADD'
            EXPORTING
              i_log_handle        = me->log_handle   " Log handle
              i_s_msg             = ls_msg           " Notification data
            IMPORTING
              e_s_msg_handle      = ls_msg_handle         " Message handle
              e_msg_was_logged    = lb_msg_was_logged     " Message collected
              e_msg_was_displayed = lb_msg_was_displayed  " Message output
            EXCEPTIONS
              log_not_found       = 1                " Log not found
              msg_inconsistent    = 2                " Message inconsistent
              log_is_full         = 3                " Message number 999999 reached. Log is full
              OTHERS              = 4.
        ENDIF.

        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 RAISING log_not_found.
      WHEN 2 OR 4.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 RAISING msg_inconsistent.
      WHEN 3.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 RAISING log_is_full.

    ENDCASE.


  ENDMETHOD.

  METHOD save.
    DATA:
        lt_log_handle TYPE bal_t_logh.

    APPEND me->get_log_handle( ) TO lt_log_handle.

    CALL FUNCTION 'BAL_DB_SAVE'
      EXPORTING
        i_t_log_handle   = lt_log_handle    " Table of log handles
      EXCEPTIONS
        log_not_found    = 1                " Log not found
        save_not_allowed = 2                " Cannot save
        numbering_error  = 3                " Number assignment error
        OTHERS           = 4.
    IF sy-subrc NE 0.
*     MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
*       WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDIF.


  ENDMETHOD.

  METHOD get_log_header.
    r_result = me->log_header.
  ENDMETHOD.

  METHOD get_log_extnumber.
    r_result = me->log_header-extnumber.
  ENDMETHOD.

  METHOD show.

    DATA:
        lt_log_handle TYPE bal_t_logh.

* Check if active background processing
    CHECK syst-batch IS INITIAL.

    APPEND me->log_handle TO lt_log_handle.

    CALL FUNCTION 'BAL_DSP_LOG_DISPLAY'
      EXPORTING
*       i_s_display_profile  =                  " Display Profile
        i_t_log_handle       = lt_log_handle    " Restrict display by log handle
*       i_t_msg_handle       =                  " Restrict display by message handle
*       i_s_log_filter       =                  " Restrict display by log filter
*       i_s_msg_filter       =                  " Restrict display by message filter
*       i_t_log_context_filter        =                  " Restrict display by log context filter
*       i_t_msg_context_filter        =                  " Restrict display by message context filter
*       i_amodal             = space            " Display amodally in new session
*       i_srt_by_timstmp     = space            " Sort Logs by Timestamp ('X') or Log Number (SPACE)
*       i_msg_context_filter_operator = 'A'              " Operator for message context filter ('A'nd or 'O'r)
*    IMPORTING
*       e_s_exit_command     =                  " Application Log: Key confirmed by user at end
      EXCEPTIONS
        profile_inconsistent = 1                " Inconsistent display profile
        internal_error       = 2                " Internal data formatting error
        no_data_available    = 3                " No data to be displayed found
        no_authority         = 4                " No display authorization
        OTHERS               = 5.
    IF sy-subrc NE 0.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
        WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDIF.

  ENDMETHOD.


  METHOD create.

    DATA: lv_name      TYPE abap_abstypename.

    IF me->log_handle IS NOT INITIAL.
      CALL FUNCTION 'BAL_LOG_EXIST'
        EXPORTING
          i_log_handle  = me->log_handle    " Log handle
        EXCEPTIONS
          log_not_found = 1                " Log not found
          OTHERS        = 2.
      IF sy-subrc EQ 0.
        RETURN.
      ENDIF.
    ENDIF.

    GET TIME STAMP FIELD DATA(ts).

    lv_name = cl_abap_classdescr=>get_class_name( im_o_object ).

    FIND FIRST OCCURRENCE OF me->c_class_str
      IN lv_name IN CHARACTER MODE IGNORING CASE
         RESULTS DATA(result_wa).

    DATA(pos) = result_wa-offset + result_wa-length.

    IF im_v_subobject IS NOT INITIAL.
      me->log_header-subobject = im_v_subobject.
    ELSE.
      me->log_header-subobject = lv_name+pos.
    ENDIF.

    me->log_header-object    = me->c_log_object.
    me->log_header-alprog    = sy-repid.
    me->log_header-extnumber = me->log_header-subobject && ts.

    CALL FUNCTION 'BAL_LOG_CREATE'
      EXPORTING
        i_s_log                 = me->log_header
      IMPORTING
        e_log_handle            = me->log_handle
      EXCEPTIONS
        log_header_inconsistent = 1
        OTHERS                  = 2.

    IF sy-subrc NE 0.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
        WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 RAISING log_header_inconsistent.
    ENDIF.

  ENDMETHOD.

ENDCLASS.

*&=====================================================================*
*& CLASS IMPLEMENTATION LCL_FILE
*&=====================================================================*
CLASS lcl_file IMPLEMENTATION.

  METHOD constructor.

    me->file_path = im_v_file_path.

    CREATE OBJECT me->o_bal_log
      EXPORTING
        im_o_object             = me
      EXCEPTIONS
        log_header_inconsistent = 1
        OTHERS                  = 2.
    IF sy-subrc NE 0.
*     MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
*       WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDIF.

  ENDMETHOD.

  METHOD get_init_filename.

    DATA lv_value TYPE filepath.

    " Get the path parameter set for the user
    GET PARAMETER ID co_parameter_id1 FIELD lv_value.

    CALL METHOD cl_gui_frontend_services=>get_upload_download_path
      CHANGING
        upload_path   = ex_v_dirup
        download_path = ex_v_dirdown.

    " If the parameter is not set / empty
    " takes the definition of the working folder of the sapgui user
    IF lv_value IS INITIAL.
      CONCATENATE ex_v_dirup 'file.xlsx' INTO r_filename.
    ELSE.
      CONCATENATE ex_v_dirup lv_value    INTO r_filename.
    ENDIF.

  ENDMETHOD.                    "get_init_filename

*&---------------------------------------------------------------------*
*&  METHOD SELECT_FILE
*&---------------------------------------------------------------------*
  METHOD select_file.
    DATA:
      lt_filetable TYPE filetable,
      lv_subrc     TYPE sysubrc.

    CONSTANTS cc_file_ext TYPE c LENGTH 26 VALUE '*.xlsx;*.xlsm;*.xlsb;*.xls'.
    TRY.

        CALL METHOD cl_gui_frontend_services=>file_open_dialog
          EXPORTING
            window_title            = |{ 'Selecionar arquivo de carga de clientes ONS' }|
            file_filter             = |{ 'Planilhas do Microsoft Excel' } ({ cc_file_ext })\| { cc_file_ext }\|  { 'Todos os tipos de arquivos' } (*.*)\|*.*|
            multiselection          = abap_false
*           default_extension       =
*           default_filename        =
*           with_encoding           =
            initial_directory       = lcl_file=>get_init_filename( )
          CHANGING
            file_table              = lt_filetable
            rc                      = lv_subrc
          EXCEPTIONS
            file_open_dialog_failed = 1
            cntl_error              = 2
            error_no_gui            = 3
            not_supported_by_gui    = 4
            OTHERS                  = 5.

        IF sy-subrc NE 0.
          RETURN.
        ENDIF.

      CATCH cx_root.
        RETURN.
    ENDTRY.

    READ TABLE lt_filetable INTO r_filename INDEX 1.

  ENDMETHOD.                    "select_file

*&---------------------------------------------------------------------*
*&  METHOD UPLOAD
*&---------------------------------------------------------------------*
  METHOD upload_super.

    DATA:
      it_raw   TYPE truxs_t_text_data,
      go_error TYPE REF TO cx_root.

    TRY.

        CASE abap_true.

          WHEN rb_up1.

            CALL METHOD me->upload_zcl_excel
              CHANGING
                ch_s_converted_data   = ch_tab_converted_data
              EXCEPTIONS
                conversion_failed     = 1
                upload_date_not_found = 2
                OTHERS                = 3.

          WHEN rb_up2.

            CALL FUNCTION 'TEXT_CONVERT_XLS_TO_SAP'
              EXPORTING
                i_line_header        = abap_true                " Character Field Length 1
                i_tab_raw_data       = it_raw                   " WORK TABLE
                i_filename           = me->file_path            " Local file for upload/download
              TABLES
                i_tab_converted_data = ch_tab_converted_data    " Predefined Type
              EXCEPTIONS
                conversion_failed    = 1
                OTHERS               = 2.

        ENDCASE.

        IF sy-subrc NE 0.

          MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno DISPLAY LIKE 'E'
              WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 RAISING conversion_failed.
          " O file excel & não pode ser processado
*      MESSAGE ID 'UX' TYPE 'E' NUMBER '893'
*         WITH me->file_path RAISING conversion_failed.

        ENDIF.

      CATCH cx_sy_conversion_overflow INTO go_error.
        MESSAGE 'Erro de conversão. Algum dado na planilhia não é possivel converter.' TYPE 'S' DISPLAY LIKE 'E'
            RAISING conversion_failed.

      CATCH cx_root INTO go_error .

        MESSAGE go_error->get_longtext( ) TYPE 'S' DISPLAY LIKE 'E'
            RAISING conversion_failed.

    ENDTRY.
* Checks whether any data has been imported
    IF ch_tab_converted_data IS INITIAL.
      MESSAGE 'Nenhum dado foi importado' TYPE 'S' DISPLAY LIKE 'E'
        RAISING upload_date_not_found.
    ENDIF.

    IF me->o_progress_ind IS NOT BOUND.
      CREATE OBJECT me->o_progress_ind
        EXPORTING
          im_v_total = lines( ch_tab_converted_data ).
    ENDIF.

    IF me->o_bal_log IS NOT BOUND.
      CREATE OBJECT me->o_bal_log
        EXPORTING
          im_o_object             = me
        EXCEPTIONS
          log_header_inconsistent = 1
          OTHERS                  = 2.
    ENDIF.

  ENDMETHOD.

  METHOD get_bus_area.

    CASE im_v_bukrs.
      WHEN 'TB05'.
        r_result = 'D05F'. "'F'

      WHEN 'TB06'.
        r_result = 'D06H'. "H'

      WHEN 'TB14'.
        r_result = 'D14O'. "'O'

      WHEN 'TB16'.
        r_result = 'D16Q'. "'Q'

      WHEN 'TB17'.
        r_result = 'D17R'. "'R'

      WHEN 'TB18'.
        r_result = 'D18T'. "'T'

      WHEN 'TB19'.
        r_result = 'D19U'. "'U'

      WHEN 'TB20'.
        r_result = 'D20V'. "'V'

      WHEN 'TB21'.
        r_result = 'D21W'. "'W'

      WHEN OTHERS.
        r_result = 'D01Z'.

    ENDCASE.

  ENDMETHOD.

  METHOD select_bukrs.
    MOVE-CORRESPONDING im_t_upload_data TO me->t_bukrs_tab.
    SORT me->t_bukrs_tab ASCENDING BY comp_code.
    DELETE ADJACENT DUPLICATES FROM me->t_bukrs_tab COMPARING ALL FIELDS.
  ENDMETHOD.

*&---------------------------------------------------------------------*
*&  METHOD set_sscrtexts
*&---------------------------------------------------------------------*
  METHOD set_sscrtexts.

    DATA l_text TYPE smp_dyntxt.

    MOVE:
      icon_export                   TO l_text-icon_id,
      'Baixar arquivo modelo'(b10)  TO l_text-text,         "#EC *
      'Modelo'(b11)                 TO l_text-icon_text,
      l_text                        TO sscrfields-functxt_01.

    CLEAR: l_text.

    MOVE:
      icon_previous_page        TO l_text-icon_id,
      'Carregar aquivo'(b20)    TO l_text-text,             "#EC *
      'Carregar arq.'(b21)      TO l_text-icon_text,
      l_text                    TO sscrfields-functxt_02.

    CLEAR: l_text.

    CONCATENATE icon_previous_page 'Carregar arq.'(b21)
        INTO b1_text SEPARATED BY space RESPECTING BLANKS.

    WRITE:
      icon_yellow_light AS ICON TO icon_001,
      icon_yellow_light AS ICON TO icon_002.


  ENDMETHOD.

*&---------------------------------------------------------------------*
*&  METHOD EXPORT_MODEL
*&---------------------------------------------------------------------*
  METHOD export_model.

    DATA:
      lo_table          TYPE REF TO cl_salv_table,
      lt_glbal_model    TYPE lcl_gl_balance=>ty_t_upload_data,
      lt_psbal_model    TYPE lcl_ps_balance=>ty_t_upload_data,
      lt_acc_receivable TYPE lcl_acc_receivable=>ty_t_upload_data,
      lt_acc_vendor     TYPE lcl_acc_payable=>ty_t_upload_data,
      lt_account_plan   TYPE TABLE OF lcl_glaccount=>ty_s_upload_data,
      lx_xml            TYPE xstring,
      lv_file_name      TYPE string.

    CONSTANTS:
      c_default_extension TYPE string VALUE 'xlsx',
      c_default_file_name TYPE string VALUE ' modelo.xlsx',
      c_default_mask      TYPE string VALUE 'Excel (*.xlsx)|*.xlsx' ##NO_TEXT.

    FIELD-SYMBOLS <fs_model> TYPE ANY TABLE .

    CASE abap_true.
      WHEN rb_glbal.    "Saldo de contas do razão
        ASSIGN lt_glbal_model       TO <fs_model>.
        lv_file_name = %_rb_glbal_%_app_%-text.

      WHEN rb_psbal.    "Saldo de projetos
        ASSIGN lt_psbal_model       TO <fs_model>.
        lv_file_name = %_rb_psbal_%_app_%-text.

      WHEN rb_kunnr.    "Faturas de Clientes
        ASSIGN lt_acc_receivable    TO <fs_model>.
        lv_file_name = %_rb_kunnr_%_app_%-text.

      WHEN rb_lfn.      "Faturas de Fornecedores
        ASSIGN lt_acc_vendor        TO <fs_model>.
        lv_file_name = %_rb_lfn_%_app_%-text.

      WHEN rb_glact.    "Plano de Contas
        ASSIGN lt_account_plan      TO <fs_model>.
        lv_file_name = %_rb_glact_%_app_%-text.
        CALL METHOD lcl_file=>export_model_zcl_excel
          EXPORTING
            im_model       = <fs_model>
            im_v_file_name = lv_file_name && c_default_file_name.
        RETURN.
    ENDCASE.

    TRY .

        IF <fs_model> IS ASSIGNED.
          cl_salv_table=>factory( IMPORTING r_salv_table = lo_table CHANGING t_table = <fs_model> ).
        ENDIF.
      CATCH cx_root.

    ENDTRY.

    lx_xml = lo_table->to_xml( xml_type = '10' ). "XLSX

    CALL FUNCTION 'XML_EXPORT_DIALOG'
      EXPORTING
        i_xml                      = lx_xml
        i_default_extension        = c_default_extension
        i_initial_directory        = lcl_file=>get_init_filename( )
        i_default_file_name        = lv_file_name && c_default_file_name
        i_mask                     = c_default_mask
      EXCEPTIONS
        application_not_executable = 1
        OTHERS                     = 2.

  ENDMETHOD.

*&---------------------------------------------------------------------*
*&     METHOD FILE_VALIDATE_PATH
*&---------------------------------------------------------------------*
  METHOD file_validate_path. "USING p_file_path.

    DATA :
      lv_dir      TYPE string,
      lv_file     TYPE string,
      lv_filename TYPE string.

    lv_filename = me->file_path.

    CALL FUNCTION 'SO_SPLIT_FILE_AND_PATH'
      EXPORTING
        full_name     = me->file_path
      IMPORTING
        stripped_name = lv_file   "file name
        file_path     = lv_dir    "directory path
      EXCEPTIONS
        x_error       = 1
        OTHERS        = 2.
    IF sy-subrc NE 0.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
              WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDIF.

    IF cl_gui_frontend_services=>directory_exist( directory = lv_dir ) IS INITIAL.
      MESSAGE ID 'C$' TYPE me->cc_msg_error NUMBER '155' "Não foi possível abrir o file &1&3 (&2)
        WITH lv_filename .
    ENDIF.

    " check file existence
    IF cl_gui_frontend_services=>file_exist( file = lv_filename ) IS INITIAL.
      MESSAGE ID 'FES' TYPE me->cc_msg_error NUMBER '000'. "O file não existe
    ENDIF.

  ENDMETHOD.                   "file_validate_path

  METHOD get_file_path.
    r_result = me->file_path.
  ENDMETHOD.

  METHOD set_file_path.
    me->file_path = im_v_file_path.
  ENDMETHOD.

  METHOD call_bapi_acc_document_post.


    sy-tcode = p_tcode.

    IF im_v_test IS NOT INITIAL.

      CALL FUNCTION 'BAPI_ACC_DOCUMENT_CHECK'
        EXPORTING
          documentheader    = ch_s_documentheader
        TABLES
          accountreceivable = ch_t_accountreceivable
          accountpayable    = ch_t_accountpayable
          accountgl         = ch_t_accountgl
          currencyamount    = ch_t_currencyamount
          extension2        = ch_t_extension2
          return            = ex_t_return.

      CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.
    ELSE.

      CALL FUNCTION 'BAPI_ACC_DOCUMENT_POST'
        EXPORTING
          documentheader    = ch_s_documentheader
        TABLES
          accountreceivable = ch_t_accountreceivable
          accountpayable    = ch_t_accountpayable
          accountgl         = ch_t_accountgl
          currencyamount    = ch_t_currencyamount
          extension2        = ch_t_extension2
          return            = ex_t_return.

*      READ TABLE ex_t_return ASSIGNING FIELD-SYMBOL(<fs_return>) WITH KEY type = 'E'.
      READ TABLE ex_t_return TRANSPORTING NO FIELDS WITH KEY type = 'E'.

      IF syst-subrc IS INITIAL.
        CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.
      ELSE.
        CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
          EXPORTING
            wait = abap_true.                  " Use of Command `COMMIT AND WAIT`
      ENDIF.
    ENDIF.

  ENDMETHOD.

  METHOD document_post.

    DATA:
      ls_documentheader    TYPE bapiache09,
      ls_accountgl         TYPE bapiacgl09,
      ls_currencyamount    TYPE bapiaccr09,
      ls_currencyamount_cp TYPE bapiaccr09.

    ls_accountgl-itemno_acc = lines( ch_t_accountgl ) + 1.
*    ls_accountgl-bus_area = me->get_bus_area( im_v_bukrs ).

*    IF p_blart EQ 'LG' OR p_blart EQ 'LS'.
    READ TABLE ch_t_accountgl TRANSPORTING bus_area INTO ls_accountgl INDEX 1.
*    ENDIF.

    MOVE:
          p_gkont                  TO ls_accountgl-gl_account,
          p_xblnr                  TO ls_accountgl-alloc_nmbr,
          p_bktxt                  TO ls_accountgl-item_text,
          p_bewar                  TO ls_accountgl-cs_trans_t.

    APPEND   ls_accountgl         TO ch_t_accountgl.


    LOOP AT ch_t_currencyamount INTO ls_currencyamount.
      AT LAST.
        SUM.
        MOVE-CORRESPONDING ls_currencyamount TO ls_currencyamount_cp.
      ENDAT.
    ENDLOOP.

    MOVE-CORRESPONDING ls_accountgl    TO ls_currencyamount_cp.
    ls_currencyamount_cp-currency       = me->c_currency_brl.
    ls_currencyamount_cp-currency_iso   = me->c_currency_brl.
    ls_currencyamount_cp-curr_type      = '00'.
    MULTIPLY ls_currencyamount_cp-amt_doccur BY '-1'.
    APPEND   ls_currencyamount_cp TO ch_t_currencyamount.


    sy-tcode = 'MIGRA'.

    MOVE:
      p_bktxt             TO ls_documentheader-header_txt,
      p_blart             TO ls_documentheader-doc_type,
      p_xblnr             TO ls_documentheader-ref_doc_no,
      p_bldat             TO ls_documentheader-doc_date,
      p_budat             TO ls_documentheader-pstng_date,
      im_v_bukrs          TO ls_documentheader-comp_code,
      sy-uname            TO ls_documentheader-username,
      'RFBU'              TO ls_documentheader-bus_act.

    CALL METHOD me->call_bapi_acc_document_post
      EXPORTING
        im_v_test           = p_test
      IMPORTING
        ex_t_return         = ex_t_return
      CHANGING
*       ch_t_accountreceivable =
*       ch_t_accountpayable =
        ch_s_documentheader = ls_documentheader
        ch_t_accountgl      = ch_t_accountgl
        ch_t_currencyamount = ch_t_currencyamount
        ch_t_extension2     = ch_t_extension2.

    CALL METHOD me->return_msg
      EXPORTING
        i_t_return = ex_t_return.

  ENDMETHOD.

  METHOD upload.

  ENDMETHOD.


  METHOD return_msg.

    DATA:
         ls_msg      TYPE bal_s_msg.

    ls_msg-msg_count = lines( i_t_return ).

    MESSAGE ID 'ZCMCARGA' TYPE 'I' NUMBER '014' WITH im_v_text INTO DATA(lv_msg_dummy).
    CALL METHOD me->o_bal_log->msg_add( ).
    CALL METHOD me->o_bal_log->save( ).

    LOOP AT i_t_return ASSIGNING FIELD-SYMBOL(<fs_return>).

      IF sy-tabix > 1 AND ls_msg-msg_count > 1.
        ls_msg-detlevel = 2.
      ENDIF.

      FORMAT RESET.

      CASE <fs_return>-type.
        WHEN 'S'.
          WRITE icon_okay AS ICON.
          FORMAT COLOR COL_NORMAL.
          ls_msg-probclass = 1.
        WHEN 'W'.
          WRITE icon_warning AS ICON.
          FORMAT COLOR COL_TOTAL .
          ls_msg-probclass = 2.
        WHEN 'I'.
          WRITE icon_information AS ICON.
          FORMAT COLOR COL_NORMAL.
          ls_msg-probclass = 4.
        WHEN 'E'.
          WRITE icon_cancel AS ICON.
          FORMAT COLOR COL_NORMAL.
          ls_msg-probclass = 1.
      ENDCASE.

      WRITE:
        <fs_return>-id(5),
        <fs_return>-type,
        <fs_return>-number,
        <fs_return>-message(80),
        im_v_text.

      NEW-LINE NO-SCROLLING.

      CALL METHOD me->o_bal_log->msg_add
        EXPORTING
          im_s_msg         = ls_msg
          im_s_bapiret2    = <fs_return>
        EXCEPTIONS
          log_not_found    = 1
          msg_inconsistent = 2
          log_is_full      = 3
          OTHERS           = 4.


      CALL METHOD me->o_bal_log->save( ).

    ENDLOOP.
    ULINE.

  ENDMETHOD.

  METHOD start_upload.

    CASE abap_true.

*---------------------GL BALANCE--------------------------------------
      WHEN rb_glbal.

        IF o_file_gl IS NOT BOUND OR o_file_gl->get_upload_data( ) IS INITIAL.
          CREATE OBJECT o_file_gl
            EXPORTING
              im_v_file_path = p_file.

          CALL METHOD o_file_gl->upload(
            EXCEPTIONS
              conversion_failed     = 1
              upload_date_not_found = 2
              OTHERS                = 3 ).
          IF sy-subrc NE 0.
            MESSAGE ID sy-msgid TYPE 'S' NUMBER sy-msgno DISPLAY LIKE o_file_gl->cc_msg_error
              WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
            RETURN.
          ENDIF.

          WRITE icon_green_light AS ICON TO icon_001.

        ENDIF.

        CALL METHOD o_file_gl->export_obj_to_memory.

        IF   im_b_onli IS NOT INITIAL.
          IF p_glbal1  IS NOT INITIAL.
            CALL METHOD o_file_gl->handle_data_single( ).
          ELSE.
            CALL METHOD o_file_gl->handle_data( ).
          ENDIF.
        ENDIF.

*---------------------- VENDOR ---------------------------------------
      WHEN rb_lfn.

        IF o_file_ap IS NOT BOUND.

          CREATE OBJECT o_file_ap
            EXPORTING
              im_v_file_path = p_file.

          CALL METHOD o_file_ap->upload(
            EXCEPTIONS
              conversion_failed     = 1
              upload_date_not_found = 2
              OTHERS                = 3 ).
          IF sy-subrc NE 0.
            MESSAGE ID sy-msgid TYPE 'S' NUMBER sy-msgno DISPLAY LIKE o_file_ap->cc_msg_error
              WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
            RETURN.
          ENDIF.
          WRITE icon_green_light AS ICON TO icon_001.

        ENDIF.

        CALL METHOD o_file_ap->export_obj_to_memory.

        IF im_b_onli IS NOT INITIAL.

          o_file_ap->handle_data_ap( ).

        ENDIF.

*--------------------- PS BALANCES -----------------------------------
      WHEN rb_psbal.

        IF o_file_ps IS NOT BOUND.

          CREATE OBJECT o_file_ps
            EXPORTING
              im_v_file_path = p_file.

          CALL METHOD o_file_ps->upload(
            EXCEPTIONS
              conversion_failed     = 1
              upload_date_not_found = 2
              OTHERS                = 3 ).
          IF sy-subrc NE 0.
            MESSAGE ID sy-msgid TYPE 'S' NUMBER sy-msgno DISPLAY LIKE o_file_ps->cc_msg_error
              WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
            RETURN.
          ENDIF.
          WRITE icon_green_light AS ICON TO icon_001.

        ENDIF.

        CALL METHOD o_file_ps->export_obj_to_memory.

        IF  im_b_onli IS NOT INITIAL.

          o_file_ps->handle_data_ps( ).

        ENDIF.

*--------------------- CUSTUMER --------------------------------------
      WHEN rb_kunnr.

        IF o_file_ar IS NOT BOUND.

          CREATE OBJECT o_file_ar
            EXPORTING
              im_v_file_path = p_file.

          CALL METHOD o_file_ar->upload(
            EXCEPTIONS
              conversion_failed     = 1
              upload_date_not_found = 2
              OTHERS                = 3 ).
          IF sy-subrc NE 0.
            MESSAGE ID sy-msgid TYPE 'S' NUMBER sy-msgno DISPLAY LIKE o_file_ar->cc_msg_error
              WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
            RETURN.
          ENDIF.
          WRITE icon_green_light AS ICON TO icon_001.

        ENDIF.

        CALL METHOD o_file_ar->export_obj_to_memory.

        IF im_b_onli IS NOT INITIAL.

          o_file_ar->handle_data_ar( ).

        ENDIF.
*-----------------------ACCOUNT PLAN ---------------------------------

      WHEN rb_glact.

        IF o_file_glaccount IS NOT BOUND.

          CREATE OBJECT o_file_glaccount
            EXPORTING
              im_v_file_path = p_file.

          CALL METHOD o_file_glaccount->upload(
            EXCEPTIONS
              conversion_failed     = 1
              upload_date_not_found = 2
              OTHERS                = 3 ).
          IF sy-subrc NE 0.
            MESSAGE ID sy-msgid TYPE 'S' NUMBER sy-msgno DISPLAY LIKE o_file_ar->cc_msg_error
              WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
            RETURN.
          ENDIF.

          WRITE icon_green_light AS ICON TO icon_001.

        ENDIF.

        CALL METHOD o_file_glaccount->export_obj_to_memory.

        IF im_b_onli IS NOT INITIAL.

          o_file_glaccount->handle_data( ).

        ENDIF.

    ENDCASE.


  ENDMETHOD.

  METHOD write_header.

    DATA:
      lv_msg1 TYPE string,
      lv_msg2 TYPE string.

    FORMAT COLOR COL_KEY.

    IF p_test IS INITIAL.
      lv_msg1 = 'Execução efetiva para carga de'(022).
    ELSE.
      lv_msg1 = 'Execução de TESTE para carga de'(021).
    ENDIF.

    CASE abap_true.
      WHEN rb_glbal.
        lv_msg2 =  'Saldo de contas do Razão'(023).
      WHEN rb_kunnr.
        lv_msg2 =   'Contas a receber'(024).
      WHEN rb_lfn.
        lv_msg2 =   'Contas a pagar'(025).
      WHEN rb_psbal.
        lv_msg2 =   'Saldo de projetos'(026).
      WHEN rb_glact.
        lv_msg2 =   'Plano de Contas'(033).
    ENDCASE.

    CONCATENATE lv_msg1 lv_msg2 INTO lv_msg1 RESPECTING BLANKS SEPARATED BY space.

    WRITE lv_msg1.
    MESSAGE  lv_msg1 TYPE 'S'.

    CALL METHOD me->o_bal_log->msg_add
      EXCEPTIONS
        OTHERS = 1.
    IF sy-subrc NE 0.
      MESSAGE ID sy-msgid TYPE 'S' NUMBER sy-msgno
        WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 DISPLAY LIKE 'E'.
    ENDIF.

    NEW-LINE NO-SCROLLING.

    WRITE / 'Usuário:'(031) && sy-uname.
    lv_msg1 = 'Transação:'(030) && sy-tcode && '  Programa:'(032) && sy-repid.
    WRITE lv_msg1.
    MESSAGE  lv_msg1 TYPE 'S'.
    CALL METHOD me->o_bal_log->msg_add
      EXCEPTIONS
        OTHERS = 1.

    lv_msg1 = 'Arquivo:' && me->file_path.
    WRITE / lv_msg1.
    MESSAGE  lv_msg1 TYPE 'S'.
    CALL METHOD me->o_bal_log->msg_add
      EXCEPTIONS
        OTHERS = 1.

    NEW-LINE NO-SCROLLING.

    WRITE 'Sistema de LOG inicializado com sucesso!'(027).
    WRITE 'Handle:'(029) && me->o_bal_log->get_log_handle( ).
    WRITE / 'Identificação externa:'(028) && me->o_bal_log->get_log_extnumber( ).

    ULINE.

    CALL METHOD me->o_bal_log->save( ).

  ENDMETHOD.

  METHOD get_parameter.

    DATA:
      lv_radiobutton TYPE screen-name,
      wa_screen      TYPE screen.

    GET PARAMETER ID co_parameter_id1 FIELD p_file.
    GET PARAMETER ID co_parameter_id2 FIELD p_fserv.
    GET PARAMETER ID co_parameter_sak FIELD p_gkont.

*   Clear all radio Button
    LOOP AT SCREEN INTO wa_screen.
      IF (  wa_screen-group1 EQ 'RB1' OR
            wa_screen-group1 EQ 'RB2' OR
            wa_screen-group1 EQ 'RB3' ) AND
         wa_screen-group3 EQ 'PAR'.
        ASSIGN (wa_screen-name) TO FIELD-SYMBOL(<fs_radiobutton>).
        CLEAR: <fs_radiobutton>.

      ENDIF.
    ENDLOOP.

    "Radio Button 1 ZMIG_CARGARD1
    GET PARAMETER ID lcl_file=>c_rb1_id FIELD lv_radiobutton.
    IF sy-subrc IS INITIAL.
      ASSIGN (lv_radiobutton) TO <fs_radiobutton>.
      IF <fs_radiobutton> IS ASSIGNED AND sy-subrc IS INITIAL.
        <fs_radiobutton> = abap_true.
      ENDIF.
    ELSE.
      rb_file1 = abap_true.
    ENDIF.

    "Radio Button 2
    CLEAR lv_radiobutton.
    UNASSIGN <fs_radiobutton>.

    GET PARAMETER ID lcl_file=>c_rb2_id FIELD lv_radiobutton. "'ZMIG_CARGARD2'
    IF sy-subrc IS INITIAL.
      ASSIGN (lv_radiobutton) TO <fs_radiobutton>.
      IF <fs_radiobutton> IS ASSIGNED AND sy-subrc IS INITIAL.
        <fs_radiobutton> = abap_true.
      ENDIF.
    ENDIF.

    "Radio Button 3
    CLEAR lv_radiobutton.
    UNASSIGN <fs_radiobutton>.

    GET PARAMETER ID lcl_file=>c_rb3_id FIELD lv_radiobutton. "'ZMIG_CARGARD3'
    IF sy-subrc IS INITIAL.
      ASSIGN (lv_radiobutton) TO <fs_radiobutton>.
      IF <fs_radiobutton> IS ASSIGNED AND sy-subrc IS INITIAL.
        <fs_radiobutton> = abap_true.
      ENDIF.
    ENDIF.

  ENDMETHOD.

  METHOD set_parameter.

    DATA:
      wa_screen TYPE screen.

    CHECK sy-ucomm EQ 'ONLI'.

    LOOP AT SCREEN INTO wa_screen.
      ASSIGN (wa_screen-name) TO FIELD-SYMBOL(<fs_radiobutton>).
      IF wa_screen-group1 EQ 'RB1' AND
         wa_screen-group3 EQ 'PAR' AND
         <fs_radiobutton> EQ abap_true.

        SET PARAMETER ID lcl_file=>c_rb1_id FIELD wa_screen-name.
      ENDIF.
    ENDLOOP.

    LOOP AT SCREEN INTO wa_screen.
      ASSIGN (wa_screen-name) TO <fs_radiobutton>.
      IF wa_screen-group1 EQ 'RB2' AND
         wa_screen-group3 EQ 'PAR' AND
         <fs_radiobutton> EQ abap_true.

        SET PARAMETER ID lcl_file=>c_rb2_id FIELD wa_screen-name.
      ENDIF.
    ENDLOOP.

    LOOP AT SCREEN INTO wa_screen.
      ASSIGN (wa_screen-name) TO <fs_radiobutton>.
      IF wa_screen-group1 EQ 'RB3' AND
         wa_screen-group3 EQ 'PAR' AND
         <fs_radiobutton> EQ abap_true.

        SET PARAMETER ID lcl_file=>c_rb3_id FIELD wa_screen-name.
      ENDIF.
    ENDLOOP.

    SET PARAMETER ID co_parameter_id1 FIELD p_file.
    SET PARAMETER ID co_parameter_id2 FIELD p_fserv.
    SET PARAMETER ID co_parameter_sak FIELD p_gkont.

  ENDMETHOD.


  METHOD get_object_from_memory.

    DATA:
      ls_serial  TYPE lcl_file=>ty_serialize,
      lo_obj_ref TYPE REF TO object.

    IMPORT serial = ls_serial
      FROM DATABASE demo_indx_blob(sc)
      ID lcl_file=>c_memory_id1.

    CHECK sy-subrc IS INITIAL.
    FREE MEMORY ID lcl_file=>c_memory_id1.
    DELETE FROM DATABASE demo_indx_blob(sc) ID lcl_file=>c_memory_id1.

    TRY.

        CALL TRANSFORMATION id_indent
          SOURCE XML ls_serial-xml
          RESULT obj = lo_obj_ref.


        CASE TYPE OF lo_obj_ref.
          WHEN TYPE lcl_acc_payable.
            CALL TRANSFORMATION id_indent
              SOURCE XML ls_serial-xml
              RESULT obj = o_file_ap.
            IF o_file_ap->upload_data IS NOT INITIAL.
              WRITE icon_green_light AS ICON TO icon_001.
            ENDIF.

          WHEN TYPE  lcl_acc_receivable.
            CALL TRANSFORMATION id_indent
              SOURCE XML ls_serial-xml
              RESULT obj = o_file_ar.
            IF o_file_ar->upload_data IS NOT INITIAL.
              WRITE icon_green_light AS ICON TO icon_001.
            ENDIF.

          WHEN TYPE  lcl_gl_balance.
            CALL TRANSFORMATION id_indent
              SOURCE XML ls_serial-xml
              RESULT obj = o_file_gl.
            IF o_file_gl->upload_data IS NOT INITIAL.
              WRITE icon_green_light AS ICON TO icon_001.
            ENDIF.

          WHEN TYPE  lcl_ps_balance.
            CALL TRANSFORMATION id_indent
              SOURCE XML ls_serial-xml
              RESULT obj = o_file_ps.
            IF o_file_ps->upload_data IS NOT INITIAL.
              WRITE icon_green_light AS ICON TO icon_001.
            ENDIF.
        ENDCASE.
*        Falta o objeto do plano

      CATCH cx_root.
        RETURN. "On error exit method
    ENDTRY.

  ENDMETHOD.


  METHOD export_obj_to_memory.

    DATA:
      ls_serial         TYPE ty_serialize.
*      ls_demo_indx_blob TYPE demo_indx_blob.

*    ls_demo_indx_blob-userid = sy-uname.
*    GET TIME STAMP FIELD ls_demo_indx_blob-timestamp.

*    ls_serial-objtype = me->get_object_type( ).

*    CALL FUNCTION 'GUID_CREATE'
*      IMPORTING
*        ev_guid_22 = ls_serial-guid.

    CALL TRANSFORMATION id
        SOURCE obj = me
        RESULT XML ls_serial-xml.

    EXPORT serial = ls_serial
        TO DATABASE demo_indx_blob(sc) "FROM ls_demo_indx_blob
        ID lcl_file=>c_memory_id1.

  ENDMETHOD.

  METHOD get_object_type.

  ENDMETHOD.

  METHOD upload_zcl_excel.

    DATA:
      lo_excel     TYPE REF TO zcl_excel,
      lo_reader    TYPE REF TO zif_excel_reader,
      lo_worksheet TYPE REF TO zcl_excel_worksheet,
      go_error     TYPE REF TO cx_root.

    FIELD-SYMBOLS <fs_worksheet> TYPE ANY TABLE.

    CREATE OBJECT lo_reader TYPE zcl_excel_reader_2007.

    TRY.

        lo_excel = lo_reader->load_file(  me->file_path ).
        "Use template for charts
        lo_excel->use_template = abap_true. "?????? Não faço ideia do que é isso

      CATCH zcx_excel INTO go_error .
        " O file excel & não pode ser processado
        MESSAGE ID 'UX' TYPE 'E' NUMBER '893'
           WITH p_file RAISING conversion_failed.

    ENDTRY.

    "'u' (structure) or 'h' (internal table)...
    DESCRIBE FIELD ch_s_converted_data TYPE DATA(lv_type).


    IF lv_type EQ 'h'. " (internal table)

      TRY.
          lo_worksheet =  lo_excel->get_worksheet_by_index( 1 ).


          lo_worksheet->get_table(
             EXPORTING
               iv_skipped_rows = 1
             IMPORTING
               et_table        = ch_s_converted_data ).

        CATCH cx_root INTO go_error .
          MESSAGE go_error->get_longtext( ) TYPE 'E'
*              MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
*                WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4
        RAISING conversion_failed.
      ENDTRY.

    ELSEIF lv_type EQ 'u' OR lv_type EQ 'v'. " 'u' Flat structure 'v' Deep structure

      DO lo_excel->get_worksheets_size( ) TIMES.
        TRY.

            lo_worksheet =  lo_excel->get_worksheet_by_index( iv_index = sy-index ).

            ASSIGN COMPONENT sy-index OF STRUCTURE ch_s_converted_data TO <fs_worksheet>.

            IF sy-subrc NE 0. EXIT. ENDIF.

            lo_worksheet->get_table(
              EXPORTING
                iv_skipped_rows = 1
*              iv_skipped_cols = 0
              IMPORTING
                et_table        = <fs_worksheet> ).

          CATCH cx_root INTO go_error .

            IF ( lines( <fs_worksheet> ) ) EQ lo_worksheet->get_tables_size( )
            OR   lines( <fs_worksheet> ) < 2 .

              MESSAGE go_error->get_longtext( ) TYPE 'E'
*              MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
*                WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4
                  RAISING conversion_failed.
            ENDIF.

        ENDTRY.
      ENDDO.

    ENDIF.

* Checks whether any data has been imported
    IF ch_s_converted_data IS INITIAL.
      MESSAGE ID 'Z_BUPA' TYPE cc_msg_error NUMBER '007'
      RAISING upload_date_not_found.
    ENDIF.

  ENDMETHOD.


  METHOD set_obj_to_memory.

    IF o_file_gl IS BOUND AND
       o_file_gl IS NOT INITIAL.
      CALL METHOD o_file_gl->export_obj_to_memory( ).

    ENDIF.

    IF o_file_ap IS BOUND AND
       o_file_ap IS NOT INITIAL.
      CALL METHOD o_file_ap->export_obj_to_memory( ).

    ENDIF.

    IF o_file_ps IS BOUND AND
       o_file_ps IS NOT INITIAL.
      CALL METHOD o_file_ps->export_obj_to_memory( ).

    ENDIF.

    IF o_file_ar IS BOUND AND
       o_file_ar IS NOT INITIAL.
      CALL METHOD o_file_ar->export_obj_to_memory( ).

    ENDIF.

    IF o_file_glaccount IS BOUND AND
       o_file_glaccount IS NOT INITIAL.
      CALL METHOD o_file_glaccount->export_obj_to_memory( ).

    ENDIF.

  ENDMETHOD.

  METHOD upload_to_server.

    DATA:
      l_flg_continue    TYPE boolean,
      l_flg_open_error  TYPE boolean,
      x_flg_stay        TYPE boolean,
      l_os_message(100) TYPE c,
      l_text1(40)       TYPE c,
      l_text2(40)       TYPE c.

    CALL FUNCTION 'C13Z_FILE_UPLOAD_BINARY'
      EXPORTING
        i_file_front_end   = p_file
        i_file_appl        = p_fserv
        i_file_overwrite   = abap_false
      IMPORTING
        e_flg_open_error   = l_flg_open_error
        e_os_message       = l_os_message
      EXCEPTIONS
        fe_file_not_exists = 1
        fe_file_read_error = 2
        ap_no_authority    = 3
        ap_file_open_error = 4
        ap_file_exists     = 5
        ap_convert_error   = 6
        OTHERS             = 7.

    IF sy-subrc NE 0.
      x_flg_stay = abap_true.
      CASE sy-subrc.
        WHEN 1.
          l_text1 = p_file(40).
          l_text2 = p_file+40.
          MESSAGE ID 'C$' TYPE 'S' NUMBER '155' DISPLAY LIKE 'E'
          WITH l_text1 l_os_message l_text2.
*       Não foi possível abrir o file &1&3 (&2)
        WHEN 2.
          MESSAGE ID 'C$' TYPE 'S' NUMBER '156' WITH p_file.
*       Erro ao ler, escrever ou eliminar o file &1
        WHEN 3.
          MESSAGE ID 'C$' TYPE 'S' NUMBER '157' WITH p_fserv.
*       Falta autorização para escrever ou ler o file &1
        WHEN 4.
          l_text1 = p_fserv(40).
          l_text2 = p_fserv+40.
          MESSAGE ID 'C$' TYPE 'S' NUMBER '155' WITH l_text1 l_os_message l_text2.
*       Não foi possível abrir o file &1&3 (&2)
        WHEN 5.
*       file already exists, ask if file can be overwritten
          CALL FUNCTION 'C14A_POPUP_ASK_FILE_OVERWRITE'
            IMPORTING
              e_flg_continue = l_flg_continue
            EXCEPTIONS
              OTHERS         = 1.
          IF sy-subrc IS INITIAL.
            l_flg_continue = abap_true.
            x_flg_stay     = abap_false.
*            PERFORM l_exec_file_upload
*                        USING
*                           i_ftfront
*                           i_ftappl
*                           true
*                           i_ftftype
*                        CHANGING
*                           x_flg_stay.
          ENDIF.
        WHEN 6.
          MESSAGE ID 'CM_SUB_IMP_EXP' TYPE 'S' NUMBER '004' DISPLAY LIKE 'E'
              WITH 'BIN' p_file.
*       Impossível carregar o file com formato de transferência '&1'
        WHEN OTHERS.
          MESSAGE ID 'C$' TYPE 'S' NUMBER '158' WITH p_file p_fserv.
*       Erro durante a transferência do file &1 para &2
      ENDCASE.
    ELSE.
      IF l_flg_open_error = abap_true.
        x_flg_stay = abap_true.
        l_text1 = p_fserv(40).
        l_text2 = p_fserv+40.
        MESSAGE ID 'C$' TYPE 'S' NUMBER '155' DISPLAY LIKE 'E' WITH l_text1 l_os_message l_text2.
*     Não foi possível abrir o file &1&3 (&2)
      ELSE.
        MESSAGE ID 'C$' TYPE 'S' NUMBER '159' WITH p_file p_fserv.
*     File &1 foi transferido para &2
      ENDIF.
    ENDIF.

  ENDMETHOD.


  METHOD export_model_zcl_excel.

    DATA:
      lo_excel        TYPE REF TO zcl_excel,
      lo_writer       TYPE REF TO zif_excel_writer,
      lx_data         TYPE xstring,
      ti_rawdata      TYPE solix_tab,        " Will be used for downloading or open directly
      lv_bytecount    TYPE i,
      ls_account_plan TYPE lcl_glaccount=>ty_s_upload_data,
      lv_path         TYPE string,
      lv_fullpath     TYPE string,
      lv_user_action  TYPE i.

    " Creates active sheet
    CREATE OBJECT lo_excel.

    CALL METHOD lcl_file=>set_table_model(
      EXPORTING
        im_o_excel     = lo_excel
        im_v_plan_name = 'SKA1'
        im_t_table     = ls_account_plan-ska1
        p_first        = abap_true ).

    CALL METHOD lcl_file=>set_table_model(
      EXPORTING
        im_o_excel     = lo_excel
        im_v_plan_name = 'SKB1'
        im_t_table     = ls_account_plan-skb1
        p_first        = abap_false ).

    " Define a primeira planilha como ativa
    lo_excel->set_active_sheet_index( 1 ).

    CREATE OBJECT lo_writer TYPE zcl_excel_writer_2007.

    lx_data = lo_writer->write_file( lo_excel ).

    ti_rawdata = cl_bcs_convert=>xstring_to_solix( iv_xstring  = lx_data ).

    lv_bytecount = xstrlen( lx_data ).

    cl_gui_frontend_services=>file_save_dialog(
      EXPORTING
        window_title              = 'Salvar Modelo'
        default_file_name         = im_v_file_name
        file_filter               = 'Excel (*.xlsx)|*.xlsx' ##NO_TEXT
        initial_directory         = lcl_file=>get_init_filename( )
        prompt_on_overwrite       = abap_true
      CHANGING
        filename                  = im_v_file_name
        path                      = lv_path
        fullpath                  = lv_fullpath
        user_action               = lv_user_action
      EXCEPTIONS
        OTHERS                    = 1     ).
    IF lv_user_action EQ 0.

      cl_gui_frontend_services=>gui_download(
           EXPORTING
             bin_filesize              = lv_bytecount
             filename                  = lv_fullpath
             filetype                  = 'BIN'
             show_transfer_status      = abap_true
           CHANGING
             data_tab                  = ti_rawdata
           EXCEPTIONS
             OTHERS                    = 1  ).
      IF sy-subrc NE 0.
        MESSAGE ID sy-msgid TYPE 'S' NUMBER sy-msgno DISPLAY LIKE 'E'
                   WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
        RETURN.
      ENDIF.
    ENDIF.

  ENDMETHOD.

  METHOD set_table_model.

    DATA:
      ls_table_settings TYPE zexcel_s_table_settings,
      lo_worksheet      TYPE REF TO zcl_excel_worksheet,
      count             TYPE i VALUE 1.

    ls_table_settings-top_left_column = 'A'.
    ls_table_settings-top_left_row    = 1.
    ls_table_settings-table_name      = im_v_plan_name.
    ls_table_settings-table_style     = zcl_excel_table=>builtinstyle_medium6.

    TRY.

        " Get active sheet
        IF p_first IS NOT INITIAL.
          lo_worksheet = im_o_excel->get_active_worksheet( ).
        ELSE.
          lo_worksheet = im_o_excel->add_new_worksheet( ).
        ENDIF.

        lo_worksheet->set_title( ip_title = im_v_plan_name ).

        lo_worksheet->bind_table(
          EXPORTING
            ip_table          = im_t_table
            is_table_settings = ls_table_settings ).

        DATA(lv_column) = lo_worksheet->get_highest_column( ).

        DO lv_column TIMES.
          lo_worksheet->set_column_width(
            EXPORTING
              ip_column         = count
              ip_width_autosize = abap_true ).
          count = count + 1.
        ENDDO.

      CATCH zcx_excel.
    ENDTRY.

  ENDMETHOD.

ENDCLASS.                       "lcl_file

*&=====================================================================*
*& CLASS IMPLEMENTATION LCL_GL_BALANCE
*&=====================================================================*
CLASS lcl_gl_balance IMPLEMENTATION.

  METHOD get_upload_data.
    r_result = me->upload_data.
  ENDMETHOD.

  METHOD set_upload_data.
    me->upload_data = im_t_upload_data.
  ENDMETHOD.

  METHOD upload.

    CALL METHOD me->upload_super
      CHANGING
        ch_tab_converted_data = me->upload_data
      EXCEPTIONS
        conversion_failed     = 1
        upload_date_not_found = 2
        OTHERS                = 3.

    IF sy-subrc EQ 1 OR sy-subrc EQ 3.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
        WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 RAISING conversion_failed.
    ELSEIF sy-subrc EQ 2.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
        WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 RAISING upload_date_not_found.
    ENDIF.

  ENDMETHOD.

  METHOD handle_data.

    DATA:
      ls_accountgl      TYPE bapiacgl09,
      ls_currencyamount TYPE bapiaccr09,
      lt_accountgl      TYPE STANDARD TABLE OF bapiacgl09,
      lt_return         TYPE STANDARD TABLE OF bapiret2,
      lt_currencyamount TYPE STANDARD TABLE OF bapiaccr09,
      lv_itemno         TYPE posnr_acc VALUE IS INITIAL.

*-----------------------------------------------------------------------
    SORT me->upload_data BY comp_code gl_account bus_area ASCENDING.

    DELETE me->upload_data WHERE amt_doccur IS INITIAL OR bus_area IS INITIAL.

    CALL METHOD me->select_bukrs( me->upload_data ).
    CALL METHOD me->write_header( ).

    LOOP AT me->t_bukrs_tab ASSIGNING FIELD-SYMBOL(<fs_burks>).

      CLEAR:
        lt_return, lt_accountgl, lt_currencyamount, lv_itemno.

      LOOP AT me->upload_data ASSIGNING FIELD-SYMBOL(<fs_upload_data>) WHERE comp_code = <fs_burks>-comp_code.

        CLEAR:
            ls_accountgl, ls_currencyamount.

        CALL METHOD me->o_progress_ind->show
          EXPORTING
            im_v_text      = 'Processando:'
            im_v_processed = sy-tabix.

        ADD 1 TO lv_itemno.

        MOVE-CORRESPONDING: <fs_upload_data> TO ls_accountgl.
        MOVE:
          lv_itemno                     TO ls_accountgl-itemno_acc,
*          <fs_upload_data>-gl_account   TO ls_accountgl-gl_account,
*          <fs_upload_data>-bus_area     TO ls_accountgl-bus_area,
*          <fs_upload_data>-comp_code    TO ls_accountgl-comp_code,
          p_xblnr                       TO ls_accountgl-alloc_nmbr,
          p_bktxt                       TO ls_accountgl-item_text,
          p_bewar                       TO ls_accountgl-cs_trans_t,
          <fs_upload_data>-bus_area     TO ls_accountgl-profit_ctr,     "Profit Center
          p_budat                       TO ls_accountgl-pstng_date,
          p_budat                       TO ls_accountgl-value_date.

*        ls_accountgl-costcenter = me->get_costcenter( <fs_upload_data> ).

        CALL METHOD me->get_housebank(
          CHANGING
            ch_s_accountgl = ls_accountgl ).

        APPEND ls_accountgl TO lt_accountgl.

        MOVE-CORRESPONDING:
            <fs_upload_data>            TO ls_currencyamount.
        MOVE:
          lv_itemno                     TO ls_currencyamount-itemno_acc,
*          <fs_upload_data>-amt_doccur   TO ls_currencyamount-amt_doccur,
          me->c_currency_brl            TO ls_currencyamount-currency,
          me->c_currency_brl            TO ls_currencyamount-currency_iso,
          '00'                          TO ls_currencyamount-curr_type.

        APPEND ls_currencyamount TO lt_currencyamount.


*        IF lv_itemno GE 500.
*
*          CALL METHOD me->document_post
*            EXPORTING
*              im_v_bukrs          = <fs_burks>-comp_code
*            CHANGING
*              ch_t_accountgl      = lt_accountgl
*              ch_t_currencyamount = lt_currencyamount.
*
*          CLEAR:
*            lt_return, lt_accountgl, lt_currencyamount, lv_itemno.
*
*        ENDIF.

      ENDLOOP.  "WHERE bukrs = <fs_burks>-bukrs.

      CALL METHOD me->document_post
        EXPORTING
          im_v_bukrs          = <fs_burks>-comp_code
        CHANGING
          ch_t_accountgl      = lt_accountgl
          ch_t_currencyamount = lt_currencyamount.

    ENDLOOP.

    IF p_swlog EQ abap_true.
      CALL METHOD me->o_bal_log->show( ).
    ENDIF.

  ENDMETHOD.

  METHOD handle_data_single.

    DATA:
      ls_accountgl      TYPE bapiacgl09,
      ls_currencyamount TYPE bapiaccr09,
      lt_accountgl      TYPE STANDARD TABLE OF bapiacgl09,
      lt_return         TYPE STANDARD TABLE OF bapiret2,
      lt_currencyamount TYPE STANDARD TABLE OF bapiaccr09,
      lv_itemno         TYPE posnr_acc VALUE IS INITIAL.

*-----------------------------------------------------------------------
    SORT me->upload_data BY comp_code gl_account bus_area ASCENDING.

    "Clear all items that are amt is 0 and bus_area is initial.
    DELETE me->upload_data WHERE amt_doccur IS INITIAL OR bus_area IS INITIAL.

    CALL METHOD me->write_header( ).

    " Company/Account/Bus Area
    LOOP AT me->upload_data ASSIGNING FIELD-SYMBOL(<fs_upload_data>).

      CLEAR:
          ls_accountgl, ls_currencyamount, lt_return,
          lt_accountgl, lt_currencyamount, lv_itemno.

      CALL METHOD me->o_progress_ind->show
        EXPORTING
          im_v_text      = 'Processando:'
          im_v_processed = sy-tabix.

      ADD 1 TO lv_itemno.

      MOVE-CORRESPONDING: <fs_upload_data> TO ls_accountgl.
      MOVE:
        lv_itemno                     TO ls_accountgl-itemno_acc,
        p_xblnr                       TO ls_accountgl-alloc_nmbr,
        p_bktxt                       TO ls_accountgl-item_text,
        p_bewar                       TO ls_accountgl-cs_trans_t,
        <fs_upload_data>-bus_area     TO ls_accountgl-profit_ctr,     "Profit Center
        p_budat                       TO ls_accountgl-pstng_date,
        p_budat                       TO ls_accountgl-value_date.


      CALL METHOD me->get_housebank(
        CHANGING
          ch_s_accountgl = ls_accountgl ).

      APPEND ls_accountgl TO lt_accountgl.

      MOVE-CORRESPONDING:
          <fs_upload_data>            TO ls_currencyamount.
      MOVE:
        lv_itemno                     TO ls_currencyamount-itemno_acc,
        me->c_currency_brl            TO ls_currencyamount-currency,
        me->c_currency_brl            TO ls_currencyamount-currency_iso,
        '00'                          TO ls_currencyamount-curr_type.

      APPEND ls_currencyamount TO lt_currencyamount.

      CALL METHOD me->document_post
        EXPORTING
          im_v_bukrs          = <fs_upload_data>-comp_code
        CHANGING
          ch_t_accountgl      = lt_accountgl
          ch_t_currencyamount = lt_currencyamount.

    ENDLOOP.

    IF p_swlog EQ abap_true.
      CALL METHOD me->o_bal_log->show( ).
    ENDIF.

  ENDMETHOD.


  METHOD fill_accountgl.

    MOVE-CORRESPONDING:
        im_s_data TO r_result.

    MOVE:
*      im_s_data-gl_account TO r_result-gl_account,
*      im_s_data-bus_area   TO r_result-bus_area,
*      im_s_data-comp_code  TO r_result-comp_code,
      p_xblnr         TO r_result-alloc_nmbr,
      p_bktxt         TO r_result-item_text,
      p_bewar         TO r_result-cs_trans_t.

  ENDMETHOD.

  METHOD get_object_type.
    r_result = me->objtype.
  ENDMETHOD.

  METHOD get_housebank.

*    DATA:
*        ls_t012k TYPE t012k.

    SELECT SINGLE * FROM t012k
        INTO @r_t012k
        WHERE
            hkont EQ @ch_s_accountgl-gl_account AND
            bukrs EQ @ch_s_accountgl-comp_code.

    IF syst-subrc IS INITIAL.

      MOVE:
          r_t012k-hbkid TO ch_s_accountgl-housebankid,
          r_t012k-hktid TO ch_s_accountgl-housebankacctid.

    ENDIF.


  ENDMETHOD.

ENDCLASS.

*&=====================================================================*
*& CLASS IMPLEMENTATION LCL_PS_BALANCE
*&=====================================================================*
CLASS lcl_ps_balance IMPLEMENTATION.


  METHOD get_upload_data.
    r_result = me->upload_data.
  ENDMETHOD.

  METHOD handle_data_ps.

**********************************************************************
    DATA:
      ls_accountgl      TYPE bapiacgl09,
      ls_currencyamount TYPE bapiaccr09,
      lt_accountgl      TYPE STANDARD TABLE OF bapiacgl09,
      lt_return         TYPE STANDARD TABLE OF bapiret2,
      lt_currencyamount TYPE STANDARD TABLE OF bapiaccr09,
      lv_itemno         TYPE posnr_acc VALUE IS INITIAL,
      ls_documentheader TYPE bapiache09.

*-----------------------------------------------------------------------
    CALL METHOD me->write_header( ).
    CALL METHOD me->select_bukrs( me->upload_data ).
    CALL METHOD me->convert_data( ).
*    CALL METHOD me->remove_reversed( ).

    MOVE-CORRESPONDING me->upload_data TO me->ref_doc.
    DELETE ADJACENT DUPLICATES FROM me->ref_doc USING KEY key1.

    SORT me->upload_data BY comp_code shkzg doc_date ref_doc_no ASCENDING.

    LOOP AT me->ref_doc ASSIGNING FIELD-SYMBOL(<fs_ref_doc>).

      CLEAR:
        lt_return, lt_accountgl, lt_currencyamount, lv_itemno, ls_documentheader.

      LOOP AT me->upload_data ASSIGNING FIELD-SYMBOL(<fs_upload_data>)
        WHERE comp_code  = <fs_ref_doc>-comp_code  AND
              doc_date   = <fs_ref_doc>-doc_date   AND
              ref_doc_no = <fs_ref_doc>-ref_doc_no AND
              shkzg      = <fs_ref_doc>-shkzg.

        CLEAR:
            ls_accountgl,  ls_currencyamount.

        CALL METHOD me->o_progress_ind->show
          EXPORTING
            im_v_text      = 'Processando:'
            im_v_processed = sy-tabix.

        ADD 1 TO lv_itemno.

        MOVE-CORRESPONDING:
          <fs_upload_data> TO ls_accountgl,
          <fs_upload_data> TO ls_currencyamount,
          <fs_upload_data> TO ls_documentheader.

        MOVE:
          lv_itemno TO ls_accountgl-itemno_acc,
          lv_itemno TO ls_currencyamount-itemno_acc,
*          p_bewar   TO ls_accountgl-cs_trans_t,
          '00'      TO ls_currencyamount-curr_type.

        APPEND:
          ls_currencyamount TO lt_currencyamount,
          ls_accountgl      TO lt_accountgl.

      ENDLOOP.  "WHERE bukrs = <fs_burks>-bukrs.

      CALL METHOD me->document_post_ps
        CHANGING
          ch_s_documentheader = ls_documentheader
          ch_t_accountgl      = lt_accountgl
          ch_t_currencyamount = lt_currencyamount.

    ENDLOOP.

    IF p_swlog EQ abap_true.
      CALL METHOD me->o_bal_log->show( ).
    ENDIF.

  ENDMETHOD.

*  METHOD select_bukrs.
*    MOVE-CORRESPONDING me->upload_data TO me->bukrs_tab.
*    SORT me->bukrs_tab ASCENDING BY comp_code.
*    DELETE ADJACENT DUPLICATES FROM me->bukrs_tab COMPARING ALL FIELDS.
*  ENDMETHOD.

  METHOD set_upload_data.
    me->upload_data = im_t_upload_data.
  ENDMETHOD.

  METHOD upload.

    CALL METHOD me->upload_super
      CHANGING
        ch_tab_converted_data = me->upload_data
      EXCEPTIONS
        conversion_failed     = 1
        upload_date_not_found = 2
        OTHERS                = 3.

    IF sy-subrc EQ 1 OR sy-subrc EQ 3.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
        WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 RAISING conversion_failed.
    ELSEIF sy-subrc EQ 2.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
        WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 RAISING upload_date_not_found.
    ENDIF.

  ENDMETHOD.

  METHOD document_post_ps.

    DATA:
      ls_accountgl         TYPE bapiacgl09,
      ls_currencyamount    TYPE bapiaccr09,
      ls_currencyamount_cp TYPE bapiaccr09.

    ls_accountgl-itemno_acc = lines( ch_t_accountgl ) + 1.

    " Todas as divisões são iguais
    READ TABLE ch_t_accountgl ASSIGNING FIELD-SYMBOL(<fs_account>) INDEX 1.
    IF <fs_account> IS ASSIGNED.
      ls_accountgl-bus_area = <fs_account>-bus_area.
    ENDIF.

    MOVE:
          p_gkont                  TO ls_accountgl-gl_account,
          p_xblnr                  TO ls_accountgl-alloc_nmbr,
          p_bktxt                  TO ls_accountgl-item_text,
          p_bewar                  TO ls_accountgl-cs_trans_t.

    APPEND   ls_accountgl         TO ch_t_accountgl.

    LOOP AT ch_t_currencyamount INTO ls_currencyamount.
      AT LAST.
        SUM.
        MOVE-CORRESPONDING ls_currencyamount TO ls_currencyamount_cp.
      ENDAT.
    ENDLOOP.

    MOVE-CORRESPONDING ls_accountgl    TO ls_currencyamount_cp.
    ls_currencyamount_cp-currency       = me->c_currency_brl.
    ls_currencyamount_cp-currency_iso   = me->c_currency_brl.
    ls_currencyamount_cp-curr_type      = '00'.
    MULTIPLY ls_currencyamount_cp-amt_doccur BY '-1'.
    APPEND   ls_currencyamount_cp TO ch_t_currencyamount.

    MOVE:
      sy-uname            TO ch_s_documentheader-username,
      'RFBU'              TO ch_s_documentheader-bus_act.

    CALL METHOD me->call_bapi_acc_document_post
      EXPORTING
        im_v_test           = p_test
      IMPORTING
        ex_t_return         = ex_t_return
      CHANGING
        ch_s_documentheader = ch_s_documentheader
        ch_t_accountgl      = ch_t_accountgl
        ch_t_currencyamount = ch_t_currencyamount.

    CALL METHOD me->return_msg
      EXPORTING
        i_t_return = ex_t_return.


  ENDMETHOD.

  METHOD convert_data.

    LOOP AT me->upload_data ASSIGNING FIELD-SYMBOL(<fs_upload_data_conv>).

      IF <fs_upload_data_conv>-base_uom IS NOT INITIAL.
        CALL FUNCTION 'CONVERSION_EXIT_CUNIT_INPUT'
          EXPORTING
            input  = <fs_upload_data_conv>-base_uom  " external display of unit of measurement
          IMPORTING
            output = <fs_upload_data_conv>-base_uom.  " internal display of unit of measurement
      ENDIF.

      IF <fs_upload_data_conv>-wbs_element IS NOT INITIAL.
        CALL FUNCTION 'CONVERSION_EXIT_ABPSN_INPUT'
          EXPORTING
            input  = <fs_upload_data_conv>-wbs_element
          IMPORTING
            output = <fs_upload_data_conv>-wbs_element.
      ENDIF.

      IF <fs_upload_data_conv>-network IS NOT INITIAL.
        <fs_upload_data_conv>-network  = |{ <fs_upload_data_conv>-network  ALPHA = IN }|.
        <fs_upload_data_conv>-activity = |{ <fs_upload_data_conv>-activity ALPHA = IN }|.
      ENDIF.

      IF <fs_upload_data_conv>-material IS NOT INITIAL.
        <fs_upload_data_conv>-material  = |{ <fs_upload_data_conv>-material  ALPHA = IN }|.
      ENDIF.

    ENDLOOP.

  ENDMETHOD.

*  METHOD remove_reversed.
*
*    "Remove duplicados/estornados
*    DATA:
*      vl_amt_doccur       TYPE bapiaccr09-amt_doccur,
*      lt_up_data_reversal LIKE me->upload_data.
*
*    lt_up_data_reversal = me->upload_data.
*
*    SORT lt_up_data_reversal BY shkzg.
*
*    LOOP AT lt_up_data_reversal ASSIGNING FIELD-SYMBOL(<fs_data_c>) WHERE shkzg = 'C'.
*      IF <fs_data_c>-amt_doccur < 0 .
*        vl_amt_doccur = <fs_data_c>-amt_doccur * '-1'.
**        MULTIPLY <fs_data_c>-amt_doccur BY '-1'.
*      ENDIF.
*      LOOP AT lt_up_data_reversal ASSIGNING FIELD-SYMBOL(<fs_data_d>)
*        WHERE shkzg       = 'D' AND
*              comp_code   = <fs_data_c>-comp_code  AND
*              amt_doccur  = vl_amt_doccur          AND
*            ( wbs_element IS NOT INITIAL OR network IS NOT INITIAL ) AND
*          ( ( network     = <fs_data_c>-network AND  activity = <fs_data_c>-activity ) OR
*              wbs_element = <fs_data_c>-wbs_element ).
*
*        DELETE TABLE me->upload_data FROM <fs_data_d>.
*        DELETE TABLE me->upload_data FROM <fs_data_c>.
*
*        EXIT. "Sai do Loop
*
*      ENDLOOP.
*    ENDLOOP.
*
*  ENDMETHOD.

  METHOD get_object_type.
    r_result = me->objtype.
  ENDMETHOD.
ENDCLASS.

*&=====================================================================*
*& CLASS IMPLEMENTATION LCL_ACC_RECEIVABLE
*&=====================================================================*
CLASS lcl_acc_receivable IMPLEMENTATION.

  METHOD get_upload_data.
    r_result = me->upload_data.
  ENDMETHOD.

  METHOD handle_data_ar.

    TYPES:
      BEGIN OF lty_s_doc_ecc,
        comp_code TYPE bapiacap09-comp_code,
        belnr_d   TYPE belnr_d,                 "Nº documento de um documento contábil
        gjahr     TYPE gjahr,
      END OF lty_s_doc_ecc,
      lty_t_doc_ecc TYPE STANDARD TABLE OF lty_s_doc_ecc.

    DATA:

      ls_accountreceivable TYPE bapiacar09,
      ls_currencyamount    TYPE bapiaccr09,
      ls_documentheader    TYPE bapiache09,
      ls_extension2        TYPE bapiparex,
      lt_accountreceivable TYPE bapiacar09_tab,
      lt_currencyamount    TYPE bapiaccr09_tab,
      lt_extension2        TYPE bapiparex_t,
      lt_ref_doc           TYPE lty_t_doc_ecc,
      lv_itemno            TYPE posnr_acc VALUE IS INITIAL,
      lcx_root             TYPE REF TO cx_root.

*-----------------------------------------------------------------------
    TRY.
        CALL METHOD me->write_header( ).

        SORT me->upload_data BY comp_code customer pstng_date.

        MOVE-CORRESPONDING me->upload_data TO lt_ref_doc.
        DELETE ADJACENT DUPLICATES FROM lt_ref_doc.

        LOOP AT lt_ref_doc ASSIGNING FIELD-SYMBOL(<fs_ref_doc>).

          CLEAR:
            ls_accountreceivable, ls_documentheader, ls_currencyamount,
            lt_accountreceivable, lt_currencyamount, lt_extension2,
            lv_itemno.

          CALL METHOD me->o_progress_ind->show
            EXPORTING
              im_v_text      = 'Processando:'
              im_v_processed = sy-tabix.


          LOOP AT me->upload_data ASSIGNING FIELD-SYMBOL(<fs_upload_data>)
            WHERE comp_code EQ <fs_ref_doc>-comp_code   AND
                  belnr_d   EQ <fs_ref_doc>-belnr_d. "    AND
*              gjahr     EQ <fs_ref_doc>-gjahr.

            CLEAR:
              ls_accountreceivable, ls_documentheader,
              ls_currencyamount,    ls_extension2.

            ADD 1 TO lv_itemno.

            MOVE-CORRESPONDING:
              <fs_upload_data> TO ls_accountreceivable,
              <fs_upload_data> TO ls_currencyamount,
              <fs_upload_data> TO ls_documentheader.

            UNPACK <fs_upload_data>-customer TO ls_accountreceivable-customer.

            MOVE:
              '00'      TO ls_currencyamount-curr_type,
              lv_itemno TO ls_accountreceivable-itemno_acc,
              lv_itemno TO ls_currencyamount-itemno_acc.

            ls_currencyamount-amt_doccur = me->define_debit_credit( <fs_upload_data> ).
            ls_currencyamount-amt_base   = ls_currencyamount-amt_doccur.

            APPEND:
                ls_accountreceivable TO lt_accountreceivable,
                ls_currencyamount TO lt_currencyamount.

            CONCATENATE <fs_ref_doc>-belnr_d <fs_ref_doc>-comp_code <fs_ref_doc>-gjahr
                INTO me->obj_key.

            ls_extension2-structure  = 'ACCIT'.
            ls_extension2-valuepart1 = 'XREF1_HD'.
            ls_extension2-valuepart2 = ls_accountreceivable-itemno_acc.
            ls_extension2-valuepart3 = me->obj_key.
            APPEND ls_extension2 TO lt_extension2.

            ls_extension2-valuepart1 = 'XREF2_HD'.
            ls_extension2-valuepart3 = 'MIGRAÇÃO'.
            APPEND ls_extension2 TO lt_extension2.

          ENDLOOP.

          CALL METHOD me->document_post
            EXPORTING
              im_s_documentheader    = ls_documentheader
            CHANGING
              ch_t_accountreceivable = lt_accountreceivable
              ch_t_currencyamount    = lt_currencyamount
              ch_t_extension2        = lt_extension2.
        ENDLOOP.

        IF p_swlog EQ abap_true.
          CALL METHOD me->o_bal_log->show( ).
        ENDIF.

      CATCH cx_root INTO lcx_root.

        MESSAGE lcx_root->get_longtext( ) TYPE 'S' DISPLAY LIKE 'E'.
        RETURN.

    ENDTRY.

  ENDMETHOD.

  METHOD set_upload_data.
    me->upload_data = im_t_upload_data.
  ENDMETHOD.

  METHOD upload.

    CALL METHOD me->upload_super
      CHANGING
        ch_tab_converted_data = me->upload_data
      EXCEPTIONS
        conversion_failed     = 1
        upload_date_not_found = 2
        OTHERS                = 3.

    IF sy-subrc EQ 1 OR sy-subrc EQ 3.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
        WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 RAISING conversion_failed.
    ELSEIF sy-subrc EQ 2.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
        WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 RAISING upload_date_not_found.
    ENDIF.

  ENDMETHOD.

  METHOD document_post.

    DATA:
      ls_documentheader    TYPE bapiache09,
      ls_accountgl         TYPE bapiacgl09,
      ls_currencyamount    TYPE bapiaccr09,
      ls_currencyamount_cp TYPE bapiaccr09.

    ls_accountgl-itemno_acc = lines( ch_t_currencyamount ) + 1.

    READ TABLE ch_t_accountreceivable ASSIGNING FIELD-SYMBOL(<fs_account>) INDEX 1.
    IF <fs_account> IS ASSIGNED.
      ls_accountgl-bus_area = <fs_account>-bus_area.
*      ls_accountgl-bus_area = me->get_bus_area( ls_documentheader-compo_acc ).
    ENDIF.

    ls_accountgl-item_text = me->obj_key.

    MOVE:
      p_gkont   TO ls_accountgl-gl_account,  "Conta do Razão da contabilidade geral
      p_xblnr   TO ls_accountgl-alloc_nmbr,  "Nº atribuição
      p_bewar   TO ls_accountgl-cs_trans_t.  "Tipo de movimento

    APPEND ls_accountgl TO ch_t_accountgl.

    LOOP AT ch_t_currencyamount INTO ls_currencyamount.
      AT LAST.
        SUM.
        MOVE-CORRESPONDING ls_currencyamount TO ls_currencyamount_cp.
      ENDAT.
    ENDLOOP.

    READ TABLE ch_t_currencyamount ASSIGNING FIELD-SYMBOL(<fs_currencyamount>) INDEX 1.

    IF <fs_currencyamount> IS ASSIGNED.
      ls_currencyamount_cp-currency       = <fs_currencyamount>-currency.
      ls_currencyamount_cp-currency_iso   = <fs_currencyamount>-currency_iso.
    ENDIF.

    MOVE-CORRESPONDING ls_accountgl    TO ls_currencyamount_cp.
    ls_currencyamount_cp-curr_type      = '00'.
    MULTIPLY ls_currencyamount_cp-amt_doccur BY '-1'.
    APPEND   ls_currencyamount_cp TO ch_t_currencyamount.

    MOVE-CORRESPONDING:
        im_s_documentheader TO ls_documentheader.
    MOVE:
        sy-uname            TO ls_documentheader-username,
        'RFBU'              TO ls_documentheader-bus_act.

    CALL METHOD me->call_bapi_acc_document_post
      EXPORTING
        im_v_test              = p_test
      IMPORTING
        ex_t_return            = ex_t_return
      CHANGING
        ch_t_accountgl         = ch_t_accountgl
        ch_t_accountreceivable = ch_t_accountreceivable
*       ch_t_accountpayable    = ch_t_accountpayable
        ch_s_documentheader    = ls_documentheader
        ch_t_currencyamount    = ch_t_currencyamount.

    CALL METHOD me->return_msg
      EXPORTING
        i_t_return = ex_t_return
        im_v_text  = me->obj_key.

  ENDMETHOD.

  METHOD define_debit_credit.

    CASE im_s_upload_data-bschl.
      WHEN  '01'    OR "C   D   Fatura
            '02'    OR "C   D   Estorno nota crédito
            '03'    OR "C   D   Despesas
            '04'    OR "C   D   Outros créditos
            '05'    OR "C   D   Saída de pagamento
            '06'    OR "C   D   Diferença pagamento
            '07'    OR "C   D   Outra compensação
            '08'    OR "C   D   Compensação pgtos.
            '09'    OR "C   D   Déb.Razão Especial
            '0A'    OR "C   D   CH doc.fatmto.déb.
            '0B'    OR "C   D   CH CancNotaCrédDéb.
            '0C'    OR "C   D   CH compensação déb.
            '0X'    OR "C   D   CH compensação créd.
            '0Y'    OR "C   D   CH nota créd.crédito
            '0Z'.      "C   D   CH CancDocFatmtoDéb.

        IF im_s_upload_data-amt_doccur > 0.
          r_result = im_s_upload_data-amt_doccur.
        ELSE.
          r_result = im_s_upload_data-amt_doccur * -1.
        ENDIF.
      WHEN OTHERS. "Credito valor negativo -

        IF im_s_upload_data-amt_doccur > 0.
          r_result = im_s_upload_data-amt_doccur * -1.
        ELSE.
          r_result = im_s_upload_data-amt_doccur.
        ENDIF.

    ENDCASE.

  ENDMETHOD.

  METHOD get_object_type.
*    r_result = me->objtype.
  ENDMETHOD.

*  METHOD get_log_subobject.
*    r_result = me->c_log_subobject.
*  ENDMETHOD.

ENDCLASS.

*&=====================================================================*
*& CLASS IMPLEMENTATION LCL_ACC_PAYABLE
*&=====================================================================*
CLASS lcl_acc_payable IMPLEMENTATION.

  METHOD fill_accountgl.

    MOVE-CORRESPONDING:
        im_s_data TO r_result.
    MOVE:
*        im_s_data-gl_account    TO r_result-gl_account,
*        im_s_data-bus_area      TO r_result-bus_area,
*        im_s_data-comp_code     TO r_result-comp_code,
        p_xblnr         TO r_result-alloc_nmbr,
        p_bktxt         TO r_result-item_text,
        p_bewar         TO r_result-cs_trans_t.

  ENDMETHOD.

  METHOD get_upload_data.
    r_result = me->upload_data.
  ENDMETHOD.

  METHOD handle_data_ap.

    TYPES:
      BEGIN OF lty_s_doc_ecc,
        comp_code TYPE bapiacap09-comp_code,
        belnr_d   TYPE belnr_d,                 "Nº documento de um documento contábil
        gjahr     TYPE gjahr,
      END OF lty_s_doc_ecc,
      lty_t_doc_ecc TYPE STANDARD TABLE OF lty_s_doc_ecc.

    DATA:
      ls_accountpayable TYPE bapiacap09,
      ls_currencyamount TYPE bapiaccr09,
      ls_documentheader TYPE bapiache09,
      ls_extension2     TYPE bapiparex,
      lt_accountpayable TYPE bapiacap09_tab,
      lt_currencyamount TYPE STANDARD TABLE OF bapiaccr09,
      lt_extension2     TYPE bapiparex_t,
      lt_ref_doc        TYPE lty_t_doc_ecc,
      lv_itemno         TYPE posnr_acc VALUE IS INITIAL.

*-----------------------------------------------------------------------
    CALL METHOD me->write_header( ).

    MOVE-CORRESPONDING me->upload_data TO lt_ref_doc.
    DELETE ADJACENT DUPLICATES FROM lt_ref_doc.

    LOOP AT lt_ref_doc ASSIGNING FIELD-SYMBOL(<fs_ref_doc>).

      CLEAR:
        ls_accountpayable, ls_accountpayable,
        ls_documentheader, lt_accountpayable, lt_currencyamount,
        lv_itemno, lt_extension2.

      LOOP AT me->upload_data ASSIGNING FIELD-SYMBOL(<fs_upload_data>)
        WHERE comp_code EQ <fs_ref_doc>-comp_code   AND
              belnr_d   EQ <fs_ref_doc>-belnr_d     AND
              gjahr     EQ <fs_ref_doc>-gjahr.

        CLEAR:
          ls_accountpayable, ls_accountpayable,
          ls_documentheader, ls_extension2.

        CALL METHOD me->o_progress_ind->show
          EXPORTING
            im_v_text      = 'Processando:'
            im_v_processed = sy-tabix.

        ADD 1 TO lv_itemno.

        MOVE-CORRESPONDING:
          <fs_upload_data> TO ls_accountpayable,
          <fs_upload_data> TO ls_currencyamount,
          <fs_upload_data> TO ls_documentheader.

        UNPACK <fs_upload_data>-vendor_no TO ls_accountpayable-vendor_no.

        " Tipo de banco do pagador diferente
        IF ls_accountpayable-alt_payee IS NOT INITIAL.
          ls_accountpayable-alt_payee_bank = ls_accountpayable-partner_bk.
        ENDIF.
        MOVE:
          '00'      TO ls_currencyamount-curr_type,
          lv_itemno TO ls_accountpayable-itemno_acc,
          lv_itemno TO ls_currencyamount-itemno_acc.

        ls_currencyamount-amt_doccur = me->define_debit_credit( <fs_upload_data> ).
        ls_currencyamount-amt_base   = ls_currencyamount-amt_doccur.

        APPEND:
          ls_accountpayable TO lt_accountpayable,
          ls_currencyamount TO lt_currencyamount.

        "Concatenation of the number of the migrated accounting document of the ECC
        CONCATENATE <fs_ref_doc>-belnr_d <fs_ref_doc>-comp_code <fs_ref_doc>-gjahr
            INTO me->obj_key.

        ls_extension2-structure  = 'ACCIT'.
        ls_extension2-valuepart1 = 'XREF1_HD'.
        ls_extension2-valuepart2 = ls_accountpayable-itemno_acc.
        ls_extension2-valuepart3 = me->obj_key.
        APPEND ls_extension2 TO lt_extension2.

        ls_extension2-valuepart1 = 'XREF2_HD'.
        ls_extension2-valuepart3 = 'MIGRAÇÃO'.
        APPEND ls_extension2 TO lt_extension2.

        " Number of order BOLETO
        IF <fs_upload_data>-esrnr IS NOT INITIAL.
          ls_extension2-valuepart1 = 'ESRNR'.
          ls_extension2-valuepart3 = <fs_upload_data>-esrnr.
          APPEND ls_extension2 TO lt_extension2.

          ls_extension2-valuepart1 = 'ESRRE'.
          ls_extension2-valuepart3 = <fs_upload_data>-esrre.
          APPEND ls_extension2 TO lt_extension2.
        ENDIF.

        " Purchase Order
        IF <fs_upload_data>-ebeln IS NOT INITIAL.
          ls_extension2-valuepart1  = 'EBELN'.
          ls_extension2-valuepart3 = <fs_upload_data>-ebeln.
          APPEND ls_extension2 TO lt_extension2.
          ls_extension2-valuepart1  = 'EBELP'.
          ls_extension2-valuepart3 = <fs_upload_data>-ebelp.
          APPEND ls_extension2 TO lt_extension2.
        ENDIF.

      ENDLOOP.

      CALL METHOD me->document_post
        EXPORTING
          im_s_documentheader = ls_documentheader
        CHANGING
          ch_t_accountpayable = lt_accountpayable
          ch_t_currencyamount = lt_currencyamount
          ch_t_extension2     = lt_extension2.
    ENDLOOP.

    IF p_swlog EQ abap_true.
      CALL METHOD me->o_bal_log->show( ).
    ENDIF.

  ENDMETHOD.

  METHOD set_upload_data.
    me->upload_data = im_t_upload_data.
  ENDMETHOD.

  METHOD upload.

    DATA:
      lv_comp_count TYPE i,
      lv_desc_field TYPE c LENGTH 1,
      lv_cell_date  TYPE zexcel_cell_value.

    CALL METHOD me->upload_super
      CHANGING
        ch_tab_converted_data = me->upload_data
      EXCEPTIONS
        conversion_failed     = 1
        upload_date_not_found = 2
        OTHERS                = 3.

    IF sy-subrc EQ 1 OR sy-subrc EQ 3.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
        WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 RAISING conversion_failed.
    ELSEIF sy-subrc EQ 2.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
        WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 RAISING upload_date_not_found.
    ENDIF.

    "Convert date format excel for SAP, only if use ABAPXLSX
    IF rb_up1 IS NOT INITIAL.
      LOOP AT me->upload_data ASSIGNING FIELD-SYMBOL(<fs_t_upload_data>).
        CLEAR lv_comp_count.
        DO.
          ADD 1 TO lv_comp_count.
          ASSIGN COMPONENT lv_comp_count OF STRUCTURE <fs_t_upload_data> TO FIELD-SYMBOL(<fs_comp>).
          IF sy-subrc NE 0 OR <fs_comp> IS NOT ASSIGNED.
            EXIT.
          ELSE.
            DESCRIBE FIELD <fs_comp> TYPE lv_desc_field.
            IF lv_desc_field EQ 'D'.
              lv_cell_date = <fs_comp>.
              CALL METHOD zcl_excel_common=>excel_string_to_date
                EXPORTING
                  ip_value = lv_cell_date
                RECEIVING
                  ep_value = <fs_comp>.
            ENDIF.
          ENDIF.
        ENDDO.
      ENDLOOP.
    ENDIF.

  ENDMETHOD.

  METHOD document_post.

    DATA:
      ls_documentheader    TYPE bapiache09,
      ls_accountgl         TYPE bapiacgl09,
      ls_currencyamount    TYPE bapiaccr09,
      ls_currencyamount_cp TYPE bapiaccr09.

    ls_accountgl-itemno_acc = lines( ch_t_currencyamount ) + 1.

    READ TABLE ch_t_accountpayable ASSIGNING FIELD-SYMBOL(<fs_accountpayable>) INDEX 1.
    IF <fs_accountpayable> IS ASSIGNED.
      ls_accountgl-bus_area = <fs_accountpayable>-bus_area.
*      ls_accountgl-bus_area = me->get_bus_area( ls_documentheader-compo_acc ).
    ENDIF.

    ls_accountgl-item_text = me->obj_key.

    MOVE:
      p_gkont   TO ls_accountgl-gl_account,  "Conta do Razão da contabilidade geral
      p_xblnr   TO ls_accountgl-alloc_nmbr,  "Nº atribuição
      p_bewar   TO ls_accountgl-cs_trans_t.  "Tipo de movimento

    APPEND ls_accountgl TO ch_t_accountgl.

    LOOP AT ch_t_currencyamount INTO ls_currencyamount.
      AT LAST.
        SUM.
        MOVE-CORRESPONDING ls_currencyamount TO ls_currencyamount_cp.
      ENDAT.
    ENDLOOP.

    READ TABLE ch_t_currencyamount ASSIGNING FIELD-SYMBOL(<fs_currencyamount>) INDEX 1.

    IF <fs_currencyamount> IS ASSIGNED.
      ls_currencyamount_cp-currency       = <fs_currencyamount>-currency.
      ls_currencyamount_cp-currency_iso   = <fs_currencyamount>-currency_iso.
    ENDIF.

    MOVE-CORRESPONDING ls_accountgl    TO ls_currencyamount_cp.
    ls_currencyamount_cp-curr_type      = '00'.
    MULTIPLY ls_currencyamount_cp-amt_doccur BY '-1'.
    APPEND   ls_currencyamount_cp TO ch_t_currencyamount.

    MOVE-CORRESPONDING:
        im_s_documentheader TO ls_documentheader.
    MOVE:
        sy-uname            TO ls_documentheader-username,
        'RFBU'              TO ls_documentheader-bus_act.

    CALL METHOD me->call_bapi_acc_document_post
      EXPORTING
        im_v_test           = p_test
      IMPORTING
        ex_t_return         = ex_t_return
      CHANGING
        ch_t_accountgl      = ch_t_accountgl
        ch_t_accountpayable = ch_t_accountpayable
        ch_s_documentheader = ls_documentheader
        ch_t_currencyamount = ch_t_currencyamount
        ch_t_extension2     = ch_t_extension2.

    CALL METHOD me->return_msg
      EXPORTING
        i_t_return = ex_t_return
        im_v_text  = me->obj_key.

  ENDMETHOD.


  METHOD define_debit_credit.

    CASE im_s_upload_data-bschl.
      WHEN  '21' OR "D   Nota de crédito
            '22' OR "D   Estorno fatura          *
            '24' OR "D   Outros créditos         *
            '25' OR "D   Saída de pagamento
            '26' OR "D   Diferença pagamento
            '27' OR "D   Compensação
            '28' OR "D   Compensação pgtos.
            '29'.   "D   Déb.Razão Especial.

        IF im_s_upload_data-amt_doccur > 0.
          r_result = im_s_upload_data-amt_doccur.
        ELSE.
          r_result = im_s_upload_data-amt_doccur * -1.
        ENDIF.
      WHEN OTHERS. "Credito valor negativo -

        IF im_s_upload_data-amt_doccur > 0.
          r_result = im_s_upload_data-amt_doccur * -1.
        ELSE.
          r_result = im_s_upload_data-amt_doccur.
        ENDIF.

    ENDCASE.

  ENDMETHOD.

  METHOD get_object_type.
    r_result = me->objtype.
  ENDMETHOD.

ENDCLASS.


*&=====================================================================*
*& CLASS IMPLEMENTATION LCL_GLACCOUNT
*&=====================================================================*
CLASS lcl_glaccount IMPLEMENTATION.

  METHOD upload.

    CALL METHOD me->upload_zcl_excel
      CHANGING
        ch_s_converted_data   = me->upload_data
      EXCEPTIONS
        conversion_failed     = 1
        upload_date_not_found = 2
        OTHERS                = 3.
    IF sy-subrc NE 0.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno DISPLAY LIKE 'E'
        WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDIF.

  ENDMETHOD.

  METHOD get_upload_data.
    r_result = me->upload_data.
  ENDMETHOD.

  METHOD set_upload_data.
    me->upload_data = im_s_upload_data.
  ENDMETHOD.


  METHOD handle_data.

    DATA:
      lt_account_names    TYPE glaccount_name_table,
      ls_glaccount_name   TYPE glaccount_name,
      lt_account_keywords TYPE glaccount_keyword_table,
      lt_account_ccodes   TYPE glaccount_ccode_table,
      ls_account_ccodes   TYPE glaccount_ccode,
      lt_account_careas   TYPE glaccount_carea_table,
      ls_account_careas   TYPE glaccount_carea,
      ls_account_coa      TYPE glaccount_coa,
      lt_return           TYPE bapiret2_t,
      ls_return           TYPE bapiret2,
      ls_ska1             TYPE ska1,
      ls_skat             TYPE skat,
      ls_skb1             TYPE skb1,
      lv_action           TYPE c LENGTH 1.

    IF me->o_progress_ind IS NOT BOUND.
      CREATE OBJECT me->o_progress_ind
        EXPORTING
          im_v_total = lines( me->upload_data-ska1 ).
    ENDIF.
    CALL METHOD me->write_header( ).

    LOOP AT me->upload_data-ska1 ASSIGNING FIELD-SYMBOL(<fs_ska1>).

      CLEAR: lt_account_names, ls_glaccount_name, lt_account_keywords,
             lt_account_ccodes, ls_account_ccodes, lt_account_careas, ls_account_careas,
             ls_account_coa, lt_return, ls_ska1, ls_skat, ls_skb1, lv_action.

      CALL METHOD me->o_progress_ind->show
        EXPORTING
          im_v_text      = 'Processando:'
          im_v_processed = sy-tabix.

      CALL FUNCTION 'READ_SKA1'
        EXPORTING
          xktopl                = <fs_ska1>-ktopl   " Name of G/L chart of accounts
          xsaknr                = <fs_ska1>-saknr   " G/L account number
          xskip_authority_check = abap_true
        IMPORTING
          xska1                 = ls_ska1           " G/L account information on client
          xskat                 = ls_skat           " G/L account text in logon language
        EXCEPTIONS
          OTHERS                = 1.
      IF sy-subrc EQ 0.
        lv_action = 'U'.
      ELSE.
        lv_action = 'I'.
      ENDIF.

*      IF ( ls_skat-txt20 NE <fs_ska1>-txt20 OR
*           ls_skat-txt50 NE <fs_ska1>-txt50 ) AND
*         <fs_ska1>-txt20 IS NOT INITIAL.

      MOVE-CORRESPONDING:
          <fs_ska1> TO ls_account_coa-keyy,
          <fs_ska1> TO ls_account_coa-data,
          <fs_ska1> TO ls_glaccount_name-keyy,
          <fs_ska1> TO ls_glaccount_name-data.

      ls_glaccount_name-keyy-spras = sy-langu.
      ls_glaccount_name-action     = lv_action.
      ls_account_coa-action        = lv_action.

      APPEND ls_glaccount_name TO lt_account_names.


*      ENDIF.

* --------------  Dados da área de controladoria (CO) --------------
      READ TABLE me->upload_data-skb1  WITH KEY saknr = <fs_ska1>-saknr TRANSPORTING NO FIELDS.
      IF <fs_ska1>-katyp IS NOT INITIAL AND syst-subrc EQ 0.
        MOVE-CORRESPONDING:
          <fs_ska1> TO ls_account_careas-keyy,
          <fs_ska1> TO ls_account_careas-data.

*    A area de contabilidade pode mudar por empresa ajustar
        ls_account_careas-keyy-kokrs   = <fs_ska1>-ktopl.
        ls_account_careas-fromto-datab = '19000101'.
        ls_account_careas-fromto-datbi = '99991231'.
        ls_account_careas-action       = lv_action.

        APPEND ls_account_careas TO lt_account_careas.
      ENDIF.
* --------------  Dados da área de controladoria (CO) --------------

      LOOP AT me->upload_data-skb1 ASSIGNING FIELD-SYMBOL(<fs_skb1>) WHERE saknr EQ <fs_ska1>-saknr.

        CALL FUNCTION 'READ_SKB1'
          EXPORTING
            xbukrs = <fs_skb1>-bukrs  " Company code
            xsaknr = <fs_skb1>-saknr  " G/L account number
          IMPORTING
            xskb1  = ls_skb1          " G/L account information at company code level
          EXCEPTIONS
            OTHERS = 1.
        IF sy-subrc EQ 0.
          lv_action = 'U'.
        ELSE.
          lv_action = 'I'.
        ENDIF.

        MOVE-CORRESPONDING:
         <fs_skb1> TO ls_account_ccodes-keyy,
         <fs_skb1> TO ls_account_ccodes-data.

        ls_account_ccodes-action = lv_action.

        APPEND ls_account_ccodes TO lt_account_ccodes.

      ENDLOOP.

      ls_return-id = 'FH'.
      ls_return-type = 'S'.
      ls_return-number = '999'.
      ls_return-message = 'Conta Nº' && ls_account_coa-keyy-ktopl && ls_account_coa-keyy-saknr.
      ls_return-message_v1 = 'Conta Nº' && ls_account_coa-keyy-ktopl.
      ls_return-message_v2 = ls_account_coa-keyy-saknr.

      APPEND ls_return TO lt_return.

      CALL FUNCTION 'GL_ACCT_MASTER_SAVE'
        EXPORTING
          testmode           = p_test                 " Modo de teste (sem salvar)
*         no_save_at_warning =                        " Não salvar quando ocorrerem mensagens de avisos
          no_authority_check = abap_true              " Não executa a verificação de autorização
*         store_data_only    =                        " Lembre-se apenas dos dados, sem operação de banco de dados (
        TABLES
          account_names      = lt_account_names       " Descrições
          account_keywords   = lt_account_keywords    " Palavras-chave
          account_ccodes     = lt_account_ccodes      " Dados da Empresa
          account_careas     = lt_account_careas      " Dados da área de controladoria (CO)
          return             = lt_return              " Mensagens
        CHANGING
          account_coa        = ls_account_coa.        " Dados de contas

      CALL METHOD me->return_msg( lt_return ).

      READ TABLE lt_return TRANSPORTING NO FIELDS WITH KEY type = 'E'.

      IF syst-subrc IS INITIAL. "OR p_test IS NOT INITIAL. "Problems with perform
        CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.
      ELSE.
        CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
          EXPORTING
            wait = abap_true.                  " Use of Command `COMMIT AND WAIT`
      ENDIF.

    ENDLOOP.

    IF p_swlog EQ abap_true.
      CALL METHOD me->o_bal_log->show( ).
    ENDIF.

  ENDMETHOD.

ENDCLASS.
