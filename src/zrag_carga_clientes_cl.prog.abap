*--------------------------------------------------------------------*
*               P R O J E T O    A G I R - T A E S A                 *
*--------------------------------------------------------------------*
* Consultoria .....: I N T E C H P R O                               *
* Res. ABAP........: Marcelo Alvares                                 *
* Res. Funcional...: Marcelo Alvares                                 *
* Módulo...........: BUPA Business Partner                           *
* Programa.........: ZRAG_CARGA_CLIENTES                             *
* Transação........:                                                 *
* Tipo de Programa.: REPORT                                          *
* Request     .....: S4DK902827                                      *
* Objetivo.........: Migração carga inicial de clientes migrados     *
*--------------------------------------------------------------------*
* Change Control:                                                    *
* Version | Date      | Who                 |   What                 *
*    1.00 | 27/09/18  | Marcelo Alvares     |   Versão Inicial       *
**********************************************************************
*&---------------------------------------------------------------------*
*& Include          ZBUPA_CARGA_ONS_CLASS
*&---------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*& CLASS DEFINITION CL_FILE
*&---------------------------------------------------------------------*
CLASS lcl_file DEFINITION FINAL.
  PUBLIC SECTION.

    CLASS-METHODS:
      get_init_filename
        EXPORTING
                  ex_v_dirup        TYPE string
                  ex_v_dirdown      TYPE string
        RETURNING VALUE(r_filename) TYPE string,
      select_file       RETURNING VALUE(r_filename) TYPE file_table-filename,
      set_sscrtexts,
*      export_model,
      set_parameter_id
        IMPORTING
          im_v_file TYPE rlgrap-filename.

    METHODS:
      upload
        EXCEPTIONS
          conversion_failed
          upload_date_not_found.

    DATA:
      upload_data LIKE s_upload_data.

ENDCLASS.           "lcl_file
*&---------------------------------------------------------------------*
*&CLASS DEFINITION MESSAGES
*&---------------------------------------------------------------------*
CLASS lcl_messages DEFINITION FINAL.
  PUBLIC SECTION.
    CLASS-METHODS:
      initialize,
      show  IMPORTING VALUE(im_v_line)  TYPE any OPTIONAL,
      store IMPORTING im_v_zeile TYPE any,
      store_validate
        IMPORTING
          im_t_return_map TYPE mdg_bs_bp_msgmap_t
          im_v_index_line TYPE any,
      progress_indicator
        IMPORTING
          VALUE(im_v_text)      TYPE any
          VALUE(im_v_processed) TYPE syst-tabix OPTIONAL
          VALUE(im_v_total)     TYPE syst-tabix OPTIONAL.


ENDCLASS.

*&---------------------------------------------------------------------*
*& Class definition cl_bupa
*&---------------------------------------------------------------------*
CLASS lcl_bupa DEFINITION FINAL FRIENDS lcl_file lcl_messages .
  PUBLIC SECTION.

    CONSTANTS:
        co_exec1 TYPE c LENGTH 6 VALUE '&EXEC1'.

    DATA:
      o_file  TYPE REF TO lcl_file,
      t_alv   TYPE TABLE OF ty_s_alv  WITH NON-UNIQUE SORTED KEY key_kunnr COMPONENTS kunnr,
      t_bukrs TYPE TABLE OF ty_s_t001 WITH UNIQUE SORTED KEY key_bukrs COMPONENTS bukrs.

    CLASS-METHODS:
      set_commit,
      get_guid          RETURNING VALUE(r_result)   TYPE string,

      get_bp_from_kunnr
        IMPORTING
                  im_v_kunnr         TYPE any OPTIONAL
        EXPORTING
                  ex_v_kunnr         TYPE kunnr
                  ex_v_bp_guid       TYPE bu_partner_guid
                  ex_v_bp_number     TYPE bu_partner
        RETURNING VALUE(r_bp_number) TYPE bu_partner.

    METHODS:
      constructor
        EXCEPTIONS upload_error ,
      get_first_name
        IMPORTING i_name_rep          TYPE c
        RETURNING VALUE(r_first_name) TYPE string,
      get_last_name
        IMPORTING i_name_rep         TYPE c
        RETURNING VALUE(r_last_name) TYPE string,
      get_alv_tabix
        IMPORTING im_v_number    TYPE any
        RETURNING VALUE(r_tabix) TYPE i,
      effective_load,
      get_test RETURNING VALUE(r_result) TYPE xtest.

  PRIVATE SECTION.

    CONSTANTS:
      co_bp_category_org    TYPE bus_ei_bupa_central_main-category VALUE '2',
      co_bp_category_person TYPE bus_ei_bupa_central_main-category VALUE '1'.

    DATA:
      it_bp_numbers LIKE STANDARD TABLE OF s_bp_numbers,
      time_ms       TYPE i,
      test          TYPE xtest VALUE abap_true.

    CLASS-METHODS:
      get_bp_numbers
        IMPORTING
          VALUE(im_v_bu_bpext) TYPE any OPTIONAL
        CHANGING
          ch_v_bp_guid         TYPE bu_partner_guid OPTIONAL
          ch_v_bp_number       TYPE bu_partner      OPTIONAL.

    METHODS:
*      remove_agents ,
      change_icon_alv_status
        IMPORTING
          im_v_icon  TYPE tp_icon
          im_v_kunnr TYPE kunnr,
      create_bp,
      create_contact
        CHANGING
          ch_s_bp_numbers LIKE LINE OF it_bp_numbers,
      fill_address
        IMPORTING
          im_s_addresses  TYPE ty_s_central_data
        RETURNING
          VALUE(r_return) TYPE bus_ei_bupa_address_t,
*          VALUE(r_return) TYPE bus_ei_bupa_address,
      fill_organization_name
        IMPORTING
          im_v_razao_social TYPE any
        RETURNING
          VALUE(r_result)   TYPE bus_ei_struc_central_organ,
*      fill_contact_addresses
*        IMPORTING
*          im_s_contactpersons TYPE ty_e_upload_layout
*        RETURNING
*          VALUE(r_result)     TYPE bus_ei_bupa_address_t,
      fill_company_data
        IMPORTING
          im_v_kunnr      TYPE kunnr
        RETURNING
          VALUE(r_result) TYPE cmds_ei_company_t,
      compare_bp_source_fill_datax
        CHANGING
          ch_s_source TYPE cvis_ei_extern,
      call_bp_maintain
        IMPORTING
          im_t_cvis_ei_extern TYPE cvis_ei_extern_t
        CHANGING
          ch_s_bp_numbers     LIKE s_bp_numbers,

      handle_return_messages
        IMPORTING
          VALUE(im_t_bapiretm) TYPE bapiretm
        CHANGING
          ch_s_bp_numbers      LIKE s_bp_numbers,
*      get_bukrs_list,
      get_bp_from_data_base,
      set_rollback,
      set_icon_alv_status
        IMPORTING
          im_v_kunnr    TYPE kunnr
          im_t_msg      TYPE ANY TABLE
        RETURNING
          VALUE(r_icon) TYPE tp_icon,
      get_estimated_time
*        IMPORTING
*          im_v_total       TYPE i
        RETURNING
          VALUE(r_result) TYPE string,
      set_category
        IMPORTING
          im_v_group      TYPE bu_group
        RETURNING
          VALUE(r_result) TYPE bus_ei_bupa_central_main-category,
      set_title_key
        IMPORTING
          VALUE(im_v_anred) TYPE anred
        RETURNING
          VALUE(r_result)   TYPE bus_ei_struc_central-title_key,
      set_rolecategory
        IMPORTING
          im_v_kunnr      TYPE kunnr
        RETURNING
          VALUE(r_result) TYPE bus_ei_bupa_roles_t,
      fill_profile_data
        IMPORTING
          im_s_bp_numbers LIKE s_bp_numbers
        CHANGING
          ch_s_bp_data    TYPE bus_ei_bupa_central_data,
      fill_sales_data
        IMPORTING
          im_v_kunnr      TYPE kunnr
        RETURNING
          VALUE(r_result) TYPE cmds_ei_sales_t,
      set_test IMPORTING i_test TYPE xtest,
      compare_data
        IMPORTING
          im_s_source  TYPE any
          im_s_current TYPE any
        CHANGING
          ch_s_data_x  TYPE any,
      check_customer_iu_successfully
        IMPORTING
          im_s_bp_numbers LIKE s_bp_numbers,
      check_customer_exists
        CHANGING
          ch_s_bp_numbers LIKE s_bp_numbers,
      fill_tax_ind
        IMPORTING
          im_v_kunnr      TYPE kunnr
        RETURNING
          VALUE(r_result) TYPE cmds_ei_tax_ind_t.

ENDCLASS.                       "lcl_bupa

*&---------------------------------------------------------------------*
*& Class ALV
*&---------------------------------------------------------------------*
CLASS lcl_alv DEFINITION FINAL FRIENDS lcl_bupa lcl_file lcl_messages .
  PUBLIC SECTION.

    CLASS-METHODS:
      show
        IMPORTING im_v_test TYPE xtest OPTIONAL
        CHANGING  it_outtab TYPE STANDARD TABLE,

      create_fieldcatalog IMPORTING it_outtab       TYPE ty_s_alv
                          EXPORTING it_fieldcat_alv TYPE slis_t_fieldcat_alv.

  PRIVATE SECTION.

ENDCLASS.

*&---------------------------------------------------------------------*
*& Class ALV IMPLEMENTATION
*&---------------------------------------------------------------------*
CLASS lcl_alv IMPLEMENTATION.

  METHOD create_fieldcatalog.

    DATA:
      lr_tabdescr TYPE REF TO cl_abap_structdescr,
      lr_data     TYPE REF TO data,
      lt_dfies    TYPE ddfields,
      ls_dfies    TYPE dfies,
      ls_fieldcat TYPE slis_fieldcat_alv.

    CREATE DATA lr_data LIKE it_outtab.

    lr_tabdescr ?= cl_abap_structdescr=>describe_by_data_ref( lr_data ).
    lt_dfies = cl_salv_data_descr=>read_structdescr( lr_tabdescr ).

    LOOP AT lt_dfies INTO ls_dfies.

      CLEAR ls_fieldcat.

      MOVE-CORRESPONDING ls_dfies TO ls_fieldcat.

      " Status field set as icon
      IF sy-tabix EQ 1.
        ls_fieldcat-icon = abap_true.
      ENDIF.
      " BP or client field set to one click
      IF sy-tabix EQ 2 OR sy-tabix EQ 3.
        ls_fieldcat-hotspot = abap_true.
        ls_fieldcat-no_zero = abap_true.
      ENDIF.

      IF ls_fieldcat-rollname IS INITIAL.
        ls_fieldcat-seltext_l = ls_fieldcat-fieldname.
        ls_fieldcat-seltext_m = ls_fieldcat-fieldname.
        ls_fieldcat-seltext_s = ls_fieldcat-fieldname.

      ENDIF.

      " Defines the fields as centralized
      ls_fieldcat-just = 'C'.

      APPEND ls_fieldcat TO it_fieldcat_alv.

    ENDLOOP.


  ENDMETHOD.

*&----------------------------------------------------------------------*
*& METHOD SHOW.
*&----------------------------------------------------------------------*
  METHOD show.

    DATA:
      it_fieldcat TYPE slis_t_fieldcat_alv,
      lv_title    TYPE lvc_title,
      ls_alv      TYPE ty_s_alv,
      t_table     TYPE STANDARD TABLE OF ty_s_alv,
      ls_layout   TYPE slis_layout_alv.

    " Required because the imported table does not allow change
    t_table = it_outtab.

    CALL METHOD lcl_alv=>create_fieldcatalog
      EXPORTING
        it_outtab       = ls_alv
      IMPORTING
        it_fieldcat_alv = it_fieldcat.

* Checks the type of result to be displayed
    IF im_v_test IS NOT INITIAL.
      lv_title = 'Dados importados e resultado do processamento de teste'(007).
    ELSE.
      lv_title = 'Resultado do processamento da carga'(008).
    ENDIF.

    ls_layout-colwidth_optimize = abap_true.

    CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
      EXPORTING
        i_callback_program       = syst-cprog       " Name of the calling program
        i_callback_pf_status_set = 'ALV_SET_STATUS'       " Set EXIT routine to status
        i_callback_user_command  = 'USER_COMMAND_ALV'   " EXIT routine for command handling
        i_grid_title             = lv_title         " Control title
        is_layout                = ls_layout        " List layout specifications
        it_fieldcat              = it_fieldcat       " Field catalog with field descriptions
        i_default                = abap_true        " Initial variant active/inactive logic
        i_save                   = abap_true        " Variants can be saved
*       is_variant               =                  " Variant information
*       it_events                =                  " Table of events to perform
*       it_event_exit            =                  " Standard fcode exit requests table
      TABLES
        t_outtab                 = it_outtab         " Table with data to be displayed
      EXCEPTIONS
        program_error            = 1                " Program errors
        OTHERS                   = 2.
    IF sy-subrc NE 0.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
        WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDIF.

  ENDMETHOD.

ENDCLASS.


*&---------------------------------------------------------------------*
*& Class (Implementation) cl_bupa
*&---------------------------------------------------------------------*
CLASS lcl_bupa IMPLEMENTATION .

  METHOD constructor.
    CREATE OBJECT o_file.

    o_file->upload(
      EXCEPTIONS
        conversion_failed     = 1
        upload_date_not_found = 2
        OTHERS                = 3 ).
    IF sy-subrc NE 0.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
        WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4
        RAISING upload_error.
      RETURN.
    ENDIF.

*    MOVE-CORRESPONDING o_file->upload_data TO me->t_alv.

*    CALL METHOD me->get_bukrs_list.

    CALL METHOD me->get_bp_from_data_base( ).

    CALL METHOD me->create_bp( ).

  ENDMETHOD.

*&----------------------------------------------------------------------*
*& METHOD GET_GUID
*&----------------------------------------------------------------------*
  METHOD get_guid.
    TRY.
        CALL METHOD cl_system_uuid=>create_uuid_x16_static
          RECEIVING
            uuid = r_result.
      CATCH cx_uuid_error ##NO_HANDLER.
    ENDTRY.
  ENDMETHOD.


*&----------------------------------------------------------------------*
*& METHOD GET_LAST_NAME
*&----------------------------------------------------------------------*
  METHOD get_last_name.
    CHECK i_name_rep IS NOT INITIAL.

    SPLIT i_name_rep AT space INTO TABLE DATA(lt_names).
    READ TABLE lt_names INTO r_last_name INDEX lines( lt_names ).
  ENDMETHOD.


*&----------------------------------------------------------------------*
*& METHOD GET_FIRST_NAME
*&----------------------------------------------------------------------*
  METHOD get_first_name.
    CHECK i_name_rep IS NOT INITIAL.

    SPLIT i_name_rep AT space INTO TABLE DATA(lt_names).
    DELETE lt_names INDEX lines( lt_names ).
    CONCATENATE LINES OF lt_names INTO r_first_name SEPARATED BY space.
  ENDMETHOD.                  "get_first_name


*&----------------------------------------------------------------------*
*& METHOD SET_COMMIT
*&----------------------------------------------------------------------*
  METHOD set_commit.
    CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
      EXPORTING
        wait = abap_true.
  ENDMETHOD.                  "set_commit

*&----------------------------------------------------------------------*
*& METHOD SET_ROLLBACK
*&----------------------------------------------------------------------*
  METHOD set_rollback.
    CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.
  ENDMETHOD.                  "set_rollback


*&----------------------------------------------------------------------*
*& METHOD GET_BP_FROM_DATA_BASE
*&----------------------------------------------------------------------*
  METHOD get_bp_from_data_base.

    CONSTANTS:
        c_bp_relationship_category TYPE bu_reltyp VALUE 'BUR001'.

    DATA:
      lt_relationship    TYPE STANDARD TABLE OF bapibus1006_relations,
      ls_contact_numbers TYPE ty_s_contact_numbers,
      lv_valid_time      TYPE timestamp,
      ls_bp_numbers      LIKE LINE OF it_bp_numbers,
      ls_alv             LIKE LINE OF me->t_alv,
      lv_tabix           LIKE syst-tabix.

    FIELD-SYMBOLS :
      <fs_relationship> LIKE LINE OF lt_relationship.

    LOOP AT o_file->upload_data-central_data ASSIGNING FIELD-SYMBOL(<fs_customer>).

      lv_tabix = syst-tabix.

      CALL METHOD lcl_messages=>progress_indicator
        EXPORTING
          im_v_text      = |{ TEXT-m02 } { <fs_customer>-kunnr ALPHA = OUT }|
          im_v_processed = lv_tabix
          im_v_total     = lines( o_file->upload_data-central_data ).

      CLEAR ls_bp_numbers.

*   CHECK if the client has already been checked inside the loop
      READ TABLE it_bp_numbers WITH KEY kunnr = <fs_customer>-kunnr TRANSPORTING NO FIELDS BINARY SEARCH.
      CHECK sy-subrc IS NOT INITIAL.

      CALL METHOD lcl_bupa=>get_bp_from_kunnr
        EXPORTING
          im_v_kunnr     = <fs_customer>-kunnr
        IMPORTING
          ex_v_kunnr     = ls_bp_numbers-kunnr
          ex_v_bp_guid   = ls_bp_numbers-bp_guid
          ex_v_bp_number = ls_bp_numbers-bp_number.

      IF ls_bp_numbers-bp_number IS NOT INITIAL.

        ls_bp_numbers-task_bp = cc_object_task_update.

        GET TIME STAMP FIELD lv_valid_time.

*    Get all Contacts for every BP Customer
        CALL FUNCTION 'BUPA_RELATIONSHIPS_READ'
          EXPORTING
            iv_partner_guid       = ls_bp_numbers-bp_guid       " Business Partner GUID
            iv_reltyp             = c_bp_relationship_category " Business partner-Relationship category
            iv_valid_time         = lv_valid_time              " UTC Time Stamp in Short Form (YYYYMMDDhhmmss)
*           iv_reset_buffer       =                            " Data Element for Domain BOOLE: TRUE (="X") and FALSE (=" ")
            iv_req_blk_msg        = space
            iv_req_mask           = 'X'
          TABLES
            et_relationships      = lt_relationship             " Business Partner Relationships
*           et_relation_revers    =
          EXCEPTIONS
            no_partner_specified  = 1
            no_valid_record_found = 2
            not_found             = 3
            blocked_partner       = 4
            OTHERS                = 5.

        IF sy-subrc NE 0.
*        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
*          WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
        ENDIF.

*   Saves the contact numbers in the structure
        LOOP AT lt_relationship  ASSIGNING <fs_relationship>.

          CLEAR ls_contact_numbers.

          MOVE:
*         <fs_relationship>-partner1 TO s_bp_numbers-bp_number, "filled
           <fs_relationship>-partner2 TO ls_contact_numbers-number_bp_contact.

          CALL METHOD lcl_bupa=>get_bp_numbers(
            CHANGING
              ch_v_bp_number = ls_contact_numbers-number_bp_contact
              ch_v_bp_guid   = ls_contact_numbers-guid_bp_contact ).

          APPEND ls_contact_numbers TO ls_bp_numbers-contact.
        ENDLOOP.

      ELSE.
*   The business partner does not exist and needs to be created
        ls_bp_numbers-task_bp   = cc_object_task_insert.
        ls_bp_numbers-bp_guid   = lcl_bupa=>get_guid( ).

      ENDIF. "bp_number IS NOT INITIAL.

*      Check the customer already exists
      CALL METHOD me->check_customer_exists(
        CHANGING
          ch_s_bp_numbers = ls_bp_numbers ).

      IF ls_bp_numbers-create_customer IS INITIAL.
*    cliente &1 já existe
        MESSAGE ID 'CVI_MAPPING' TYPE 'S' NUMBER '042'
          WITH ls_bp_numbers-kunnr INTO DATA(lv_dummy).

        CALL METHOD lcl_messages=>store( ls_bp_numbers-kunnr ).

        CALL METHOD me->change_icon_alv_status
          EXPORTING
            im_v_icon  = icon_led_green
            im_v_kunnr = ls_bp_numbers-kunnr.
      ELSE.

        MESSAGE ID 'F2' TYPE 'W' NUMBER '153'
        WITH ls_bp_numbers-kunnr INTO DATA(lv_dummy2).
        CALL METHOD lcl_messages=>store( ls_bp_numbers-kunnr ).

      ENDIF.

      APPEND ls_bp_numbers TO it_bp_numbers.

    ENDLOOP. "AT o_file->upload_data-central_data ASSIGNING FIELD-SYMBOL(<fs_customer>).

*    Move BP number to ALV
    MOVE-CORRESPONDING it_bp_numbers TO me->t_alv.

  ENDMETHOD.

*&----------------------------------------------------------------------*
*& METHOD GET_BP_NUMBERS
*&----------------------------------------------------------------------*
  METHOD get_bp_numbers.

    DATA lv_bu_bpext TYPE bu_bpext.

    CALL FUNCTION 'BUPA_NUMBERS_GET'
      EXPORTING
        iv_partner      = ch_v_bp_number  " Business Partner Number
        iv_partner_guid = ch_v_bp_guid    " Business Partner GUID
*       iv_partner_external = lv_bu_bpext     " Business Partner Number in External System
      IMPORTING
        ev_partner      = ch_v_bp_number  " Business Partner Number
        ev_partner_guid = ch_v_bp_guid.   " Business Partner GUID

    CHECK ch_v_bp_number IS INITIAL.

    "Get BP from Number External System

    lv_bu_bpext = |{ im_v_bu_bpext ALPHA = OUT }|.

    CALL FUNCTION 'BUPA_NUMBERS_GET'
      EXPORTING
        iv_partner_external = lv_bu_bpext     " Business Partner Number in External System
      IMPORTING
        ev_partner          = ch_v_bp_number  " Business Partner Number
        ev_partner_guid     = ch_v_bp_guid.   " Business Partner GUID

  ENDMETHOD.

*&----------------------------------------------------------------------*
*& METHOD CREATE_BP
*&----------------------------------------------------------------------*
  METHOD create_bp.

    DATA:
      ls_cvis_ei_extern TYPE cvis_ei_extern,
      lt_cvis_ei_extern TYPE cvis_ei_extern_t,
      lt_return_map     TYPE mdg_bs_bp_msgmap_t,
      ls_taxnumber      TYPE LINE OF bus_ei_bupa_taxnumber_t,
      lv_tabix          TYPE syst_tabix,
      lv_text           TYPE string,
      lv_time           TYPE string.

    FIELD-SYMBOLS:
      <fs_bp_numbers> LIKE LINE OF it_bp_numbers,
      <fs_return_map> LIKE LINE OF lt_return_map.


    LOOP AT me->it_bp_numbers ASSIGNING <fs_bp_numbers>. "WHERE bp_number IS INITIAL.

      lv_tabix = syst-tabix.

      CLEAR: ls_cvis_ei_extern, ls_taxnumber, lv_time.

      lv_time = me->get_estimated_time( ).

      READ TABLE me->o_file->upload_data-central_data ASSIGNING FIELD-SYMBOL(<fs_central_data>)
      WITH TABLE KEY key_kunnr COMPONENTS kunnr = <fs_bp_numbers>-kunnr .

*    Verifica se é uma inclusão ou atualização, condição se encontrou o cadastro do BP no sistema
      IF <fs_bp_numbers>-bp_number IS INITIAL.
        IF me->get_test( ) IS INITIAL.
          lv_text = |{ 'Criando PN para o cliente:_'(m03) }{ <fs_bp_numbers>-kunnr ALPHA = OUT }|.
        ELSE.
          lv_text = |{ 'Val. novo PN para o cliente:_'(m04) }{ <fs_bp_numbers>-kunnr ALPHA = OUT }|.
        ENDIF.
      ELSE.
        IF me->get_test( ) IS INITIAL.
          lv_text = |{ 'Atualizando cadastro do PN:_'(m05) }{ <fs_bp_numbers>-bp_number ALPHA = OUT }|.
        ELSE.
          lv_text = |{ 'Verificando atualização do PN:_'(m06) }{ <fs_bp_numbers>-bp_number ALPHA = OUT }|.
        ENDIF.
      ENDIF.

      TRANSLATE lv_text USING '_ '. "ABAP BUGS!

      lv_text = lv_text && lv_time.

      CALL METHOD lcl_messages=>progress_indicator
        EXPORTING
          im_v_text      = lv_text
          im_v_processed = lv_tabix
          im_v_total     = lines( it_bp_numbers ).

*----------------------------------------------------------------------
*    Dados centrais do Parceiro de Negocios
*----------------------------------------------------------------------
      ls_cvis_ei_extern-partner-header-object_task                                      = <fs_bp_numbers>-task_bp.
      ls_cvis_ei_extern-partner-header-object_instance-bpartnerguid                     = <fs_bp_numbers>-bp_guid.
      ls_cvis_ei_extern-partner-header-object_instance-bpartner                         = <fs_bp_numbers>-bp_number.
      ls_cvis_ei_extern-partner-header-object_instance-identificationnumber             = <fs_bp_numbers>-kunnr.
      ls_cvis_ei_extern-partner-central_data-common-data-bp_control-category            = me->set_category( <fs_central_data>-grouping ).
      ls_cvis_ei_extern-partner-central_data-common-data-bp_control-grouping            = <fs_central_data>-grouping.
      ls_cvis_ei_extern-partner-central_data-common-data-bp_centraldata-partnerexternal = |{ <fs_bp_numbers>-kunnr ALPHA = OUT }|.
      ls_cvis_ei_extern-partner-central_data-common-data-bp_centraldata-title_key       = me->set_title_key( <fs_central_data>-anred ).
      MOVE-CORRESPONDING <fs_central_data> TO ls_cvis_ei_extern-partner-central_data-common-data-bp_centraldata.

      "Set BP Roles Category
      ls_cvis_ei_extern-partner-central_data-role-roles = me->set_rolecategory( <fs_bp_numbers>-kunnr ).

*----------------------------------------------------------------------
*    Name data
*----------------------------------------------------------------------
      CALL METHOD me->fill_profile_data
        EXPORTING
          im_s_bp_numbers = <fs_bp_numbers>
        CHANGING
          ch_s_bp_data    = ls_cvis_ei_extern-partner-central_data-common-data.

*----------------------------------------------------------------------
*    Business Partner Tax ID Data
*----------------------------------------------------------------------
      LOOP AT o_file->upload_data-tax_numbers
        ASSIGNING FIELD-SYMBOL(<fs_tax_numbers>)
            WHERE kunnr = <fs_bp_numbers>-kunnr.

        ls_taxnumber-task                 = cc_object_task_insert. "If update, change after
        ls_taxnumber-data_key-taxtype     = <fs_tax_numbers>-taxtype.
        ls_taxnumber-data_key-taxnumber   = <fs_tax_numbers>-taxnum.
        APPEND ls_taxnumber TO ls_cvis_ei_extern-partner-central_data-taxnumber-taxnumbers.

      ENDLOOP.
*----------------------------------------------------------------------
*    Business Partner Address Data
*----------------------------------------------------------------------
      ls_cvis_ei_extern-partner-central_data-address-addresses = me->fill_address( <fs_central_data> ).

*----------------------------------------------------------------------
*    Business Partner Customer role data
*----------------------------------------------------------------------
      ls_cvis_ei_extern-ensure_create-create_customer           = <fs_bp_numbers>-create_customer.
      ls_cvis_ei_extern-customer-header-object_task             = <fs_bp_numbers>-task_customer.
      ls_cvis_ei_extern-customer-header-object_instance-kunnr   = <fs_bp_numbers>-kunnr.
      ls_cvis_ei_extern-customer-company_data-company           = me->fill_company_data( <fs_bp_numbers>-kunnr ).
      ls_cvis_ei_extern-customer-sales_data-sales               = me->fill_sales_data( <fs_bp_numbers>-kunnr ).
      ls_cvis_ei_extern-customer-central_data-tax_ind-tax_ind   = me->fill_tax_ind( <fs_bp_numbers>-kunnr ).

      "Definir logica para cada tipo de cliente
      ls_cvis_ei_extern-customer-central_data-central-data-icmstaxpay = 'NO'. "Contribuinte Normal

*----------------------------------------------------------------------
* Updating the BP registry
*----------------------------------------------------------------------
* If it is an update you must fill in the fields that will be updated
*----------------------------------------------------------------------
      IF  ls_cvis_ei_extern-partner-header-object_task EQ 'U'.

        CALL METHOD me->compare_bp_source_fill_datax
          CHANGING
            ch_s_source = ls_cvis_ei_extern.

      ENDIF.

*----------------------------------------------------------------------
* Method to validate execution, presents possible errors.
*----------------------------------------------------------------------
      CLEAR lt_return_map.

      CALL METHOD cl_md_bp_maintain=>validate_single
        EXPORTING
          i_data        = ls_cvis_ei_extern
        IMPORTING
          et_return_map = lt_return_map.

* Remove standard error message, it is not impeditive.
* Função PN &1 não existe para parceiro &2
      DELETE lt_return_map WHERE
                                id      = 'R11' AND
                                number  = '657' AND
                                type    = 'E'.
      "Indicar um valor para campo NAME1
      DELETE lt_return_map WHERE
                                id          = 'R11' AND
                                number      = '401' AND
                                type        = 'E'   AND
                                message_v1  = 'NAME1'.
      DELETE lt_return_map WHERE
                                id          = 'R11' AND
                                number      = '401' AND
                                type        = 'E'   AND
                                message_v1  = 'SEARCHTERM1'.

*    Check for validate error
      IF lt_return_map IS INITIAL.

        CALL METHOD me->change_icon_alv_status(
          EXPORTING
            im_v_icon  = icon_led_green
            im_v_kunnr = <fs_bp_numbers>-kunnr ).

        "Msg Dados do parceiro de negócios sem erros
        MESSAGE ID 'BUPA_DIALOG_JOEL' TYPE 'S' NUMBER '108' INTO DATA(lv_msgdummy).

        "store messages
        CALL METHOD lcl_messages=>store( <fs_bp_numbers>-kunnr ).

        CLEAR lt_cvis_ei_extern.
        APPEND ls_cvis_ei_extern TO lt_cvis_ei_extern.

        " Maintain BP
        CALL METHOD me->call_bp_maintain(
          EXPORTING
            im_t_cvis_ei_extern = lt_cvis_ei_extern
          CHANGING
            ch_s_bp_numbers     = <fs_bp_numbers> ).

      ELSE.

        LOOP AT lt_return_map ASSIGNING <fs_return_map>.
          <fs_return_map>-row = lv_tabix.
        ENDLOOP.

        "store messages
        CALL METHOD lcl_messages=>store_validate
          EXPORTING
            im_t_return_map = lt_return_map
            im_v_index_line = <fs_bp_numbers>-kunnr.

        "Change status in ALV
        CALL METHOD me->set_icon_alv_status
          EXPORTING
            im_v_kunnr = <fs_bp_numbers>-kunnr
            im_t_msg   = lt_return_map
          RECEIVING
            r_icon     = DATA(lv_icon).

        "Alert message is not impeditive
        IF lv_icon  = icon_led_yellow.
          CLEAR lt_cvis_ei_extern.
          APPEND ls_cvis_ei_extern TO lt_cvis_ei_extern.

          CALL METHOD me->call_bp_maintain(
            EXPORTING
              im_t_cvis_ei_extern = lt_cvis_ei_extern
            CHANGING
              ch_s_bp_numbers     = <fs_bp_numbers> ).

        ENDIF.

      ENDIF.

    ENDLOOP. " LOOP AT it_bp_numbers ASSIGNING <fs_bp_numbers>

    IF me->get_test( ) EQ abap_true.
      CALL METHOD me->set_rollback.
    ENDIF.

    "problemas sérios com performance no ambiente de teste
    "a execução deve acontecer 1:1, 1:n não é possivel.
*    CHECK p_test IS INITIAL.
*    me->call_bp_maintain( lt_cvis_ei_extern ).

  ENDMETHOD.


**********************************************************************
*#
**********************************************************************
  METHOD create_contact.

*    DATA:
*      ls_cvis_ei_extern    TYPE cvis_ei_extern,
*      lt_cvis_ei_extern    TYPE cvis_ei_extern_t,
**      lt_return_map        TYPE mdg_bs_bp_msgmap_t,
**      lt_return            TYPE bapiretm,
*      ls_roles             TYPE bus_ei_bupa_roles,
*      ls_partner_rel       TYPE burs_ei_extern,
*      ls_bp_contact        TYPE mdc_s_bp_contacts,
*      ls_contact           TYPE ty_e_contact_numbers,
*      ls_business_partners TYPE bus_ei_main,
*      ls_bp_current        TYPE bus_ei_main,
*      ls_bus_ei_extern     TYPE bus_ei_extern,
*      ls_error             TYPE mds_ctrls_error,
*      lt_contactpersons    TYPE TABLE OF ty_e_upload_layout WITH NON-UNIQUE SORTED KEY key1 COMPONENTS codigo.
*
*    FIELD-SYMBOLS:
*      <fs_contactpersons> LIKE LINE OF lt_contactpersons,
*      <fs_bp_current>     TYPE bus_ei_extern.
*
*    MOVE-CORRESPONDING me->t_alv TO lt_contactpersons.
*    DELETE lt_contactpersons WHERE codigo NE ch_s_bp_numbers-kunnr.
*
*    LOOP AT lt_contactpersons ASSIGNING <fs_contactpersons>.
*
*      CLEAR:
*        ls_bp_contact, ls_partner_rel, ls_cvis_ei_extern, ls_roles, ls_business_partners.
*
*      LOOP AT ch_s_bp_numbers-contact ASSIGNING FIELD-SYMBOL(<fs_contact>) WHERE number_bp_contact IS NOT INITIAL.
*
*        CLEAR: ls_bus_ei_extern.
*
*        ls_bus_ei_extern-header-object_instance-bpartnerguid = <fs_contact>-guid_bp_contact.
*        ls_bus_ei_extern-header-object_instance-bpartner     = <fs_contact>-number_bp_contact.
*
*        APPEND ls_bus_ei_extern TO ls_business_partners-partners.
*
*      ENDLOOP.
*
*      IF ls_business_partners IS NOT INITIAL.
*        CLEAR: ls_bp_current, ls_error.
*        cl_bupa_current_data=>get_all(
*          EXPORTING
*            is_business_partners = ls_business_partners " Complex External Interface of the Business Partner (Tab.)
*          IMPORTING
*            es_business_partners = ls_bp_current        " Complex External Interface of the Business Partner (Tab.)
*            es_error             = ls_error ).          " Message Structure of the Controller
*      ENDIF.
*
*      LOOP AT ls_bp_current-partners ASSIGNING <fs_bp_current>.
*
*        " Verifica se já existe.
*        IF <fs_contactpersons>-nome_representante_agente EQ <fs_bp_current>-central_data-common-data-bp_person-fullname.
*          DATA(vl_atualizar) = abap_true.
*
*          ls_cvis_ei_extern-partner-header-object_task = cc_object_task_update. "I=Incluir, U=Update, D=Deletar
*          ls_cvis_ei_extern-partner-header-object_instance-bpartnerguid = <fs_bp_current>-header-object_instance-bpartnerguid.
*
*        ELSE. " Não Existe
*          "??????????????????????
*        ENDIF.
*
*      ENDLOOP.
*
*      IF sy-subrc NE 0. "Não encontrou
*
*        ls_cvis_ei_extern-partner-header-object_task = cc_object_task_insert. "I=Incluir, U=Update, D=Deletar
*
**   GUID do BP
*        ls_cvis_ei_extern-partner-header-object_instance-bpartnerguid = lcl_bupa=>get_guid( ).
*
*        ls_contact-guid_bp_contact = ls_cvis_ei_extern-partner-header-object_instance-bpartnerguid.
*        APPEND ls_contact TO ch_s_bp_numbers-contact.
*
*      ENDIF.
*
**----------------------------------------------------------------------
**    Dados centrais do Parceiro de Negocios
**----------------------------------------------------------------------
**    ls_cvis_ei_extern-partner-header-object_task = cc_object_task_insert. "I=Incluir, U=Update, D=Deletar
*
**   GUID do BP
**    ls_cvis_ei_extern-partner-header-object_instance-bpartnerguid = lcl_bupa=>get_guid( ).
*
**    wa_contact-guid_bp_contact = ls_cvis_ei_extern-partner-header-object_instance-bpartnerguid.
**    APPEND wa_contact TO ps_bp_numbers-contact.
*
*      ls_cvis_ei_extern-partner-central_data-common-data-bp_control-category = '1'. "Pessoa
*      ls_cvis_ei_extern-partner-central_data-common-data-bp_control-grouping = 'NACF'.  "NACF Nacional Pessoa Fisica
*
*      ls_roles-data-rolecategory = cc_rolecategory_contact. "'BUP001'.  "Pessoa de contato
*      APPEND ls_roles TO ls_cvis_ei_extern-partner-central_data-role-roles.
*
**----------------------------------------------------------------------
**    Dados do Nome
**----------------------------------------------------------------------
*      ls_cvis_ei_extern-partner-central_data-common-data-bp_person-firstname = me->get_first_name( i_name_rep = <fs_contactpersons>-nome_representante_agente ).
*      ls_cvis_ei_extern-partner-central_data-common-data-bp_person-lastname  = me->get_last_name( i_name_rep = <fs_contactpersons>-nome_representante_agente ).
*
*      ls_cvis_ei_extern-partner-central_data-common-data-bp_person-fullname              = <fs_contactpersons>-nome_representante_agente.
*      ls_cvis_ei_extern-partner-central_data-common-data-bp_person-correspondlanguageiso = cc_languiso_pt.
*      ls_cvis_ei_extern-partner-central_data-common-data-bp_person-nationalityiso        = cc_pais_iso_br.
*
**----------------------------------------------------------------------
**    Dados do Endereço do Parceiro de Negocios
**----------------------------------------------------------------------
**      ls_cvis_ei_extern-partner-central_data-address-addresses = me->fill_contact_addresses( <fs_contactpersons> ).
*      APPEND LINES OF me->fill_contact_addresses( <fs_contactpersons> ) TO ls_cvis_ei_extern-partner-central_data-address-addresses.
*
***----------------------------------------------------------------------
***    Realiza a validação dos dados.
***----------------------------------------------------------------------
**      CALL METHOD cl_md_bp_maintain=>validate_single
**        EXPORTING
**          i_data        = ls_cvis_ei_extern
**        IMPORTING
**          et_return_map = lt_return_map.
**
*      APPEND ls_cvis_ei_extern TO lt_cvis_ei_extern.
*
*    ENDLOOP.

*----------------------------------------------------------------------
*    Grava todas as modificações
*----------------------------------------------------------------------
*  CHECK p_test IS INITIAL.
*  CALL METHOD cl_md_bp_maintain=>maintain
*    EXPORTING
*      i_data   = lt_cvis_ei_extern
*    IMPORTING
*      e_return = lt_return.

*  CALL METHOD lcl_bupa=>set_commit( ).

*CALL FUNCTION 'BAPI_BUPA_GET_NUMBERS'

  ENDMETHOD.

*&----------------------------------------------------------------------*
*& METHOD FILL_ADDRESS
*&----------------------------------------------------------------------*
  METHOD fill_address.

    DATA ls_data TYPE bus_ei_bupa_address.

    MOVE-CORRESPONDING im_s_addresses TO ls_data-data-postal-data.

    ls_data-data-postal-data-countryiso = cc_pais_iso_br.
    ls_data-data-postal-data-languiso   = cc_languiso_pt.
    ls_data-data-postal-data-langu      = cc_languiso_pt(1).

    APPEND ls_data TO r_return .

  ENDMETHOD.

**&----------------------------------------------------------------------*
**& METHOD FILL_ORGANIZATION_NAME
**&----------------------------------------------------------------------*
  METHOD fill_organization_name.

    DATA:
      lt_text_tab TYPE TABLE OF char255,
      lv_text     TYPE string.

    FIELD-SYMBOLS:
      <fs_central_organ> TYPE any,
      <fs_text>          TYPE char255.

    lv_text = im_v_razao_social.

    CALL FUNCTION 'SOTR_SERV_STRING_TO_TABLE'
      EXPORTING
        text        = lv_text
*       flag_no_line_breaks = 'X'
        line_length = 35
*       LANGU       = SY-LANGU
      TABLES
        text_tab    = lt_text_tab.

    LOOP AT lt_text_tab ASSIGNING <fs_text>.

      CHECK sy-tabix < 5.

      ASSIGN COMPONENT sy-tabix OF STRUCTURE r_result TO  <fs_central_organ>.

      <fs_central_organ> = <fs_text>.

    ENDLOOP.

    UNASSIGN <fs_central_organ>.

  ENDMETHOD.

*&----------------------------------------------------------------------*
*& METHOD COMPARE_BP_SOURCE_FILL_DATAX
*&----------------------------------------------------------------------*
  METHOD compare_bp_source_fill_datax.

    DATA:
      ls_business_partners TYPE bus_ei_main,
      ls_bp_current        TYPE bus_ei_main,
      ls_bus_ei_extern     TYPE bus_ei_extern,
      ls_error             TYPE mds_ctrls_error.

    FIELD-SYMBOLS:
      <fs_bp_current>         TYPE bus_ei_extern,
      <fs_adress_current>     TYPE bus_ei_bupa_address,
      <fs_adress_source>      TYPE bus_ei_bupa_address,
      <fs_taxnumbers_source>  TYPE bus_ei_bupa_taxnumber,
      <fs_taxnumbers_current> TYPE bus_ei_bupa_taxnumber.

*----------------------------------------------------------------------
* Get current recorded BP data
*----------------------------------------------------------------------
    MOVE-CORRESPONDING ch_s_source-partner-header-object_instance TO ls_bus_ei_extern-header-object_instance.

    APPEND ls_bus_ei_extern TO ls_business_partners-partners.

    cl_bupa_current_data=>get_all(
      EXPORTING
        is_business_partners = ls_business_partners " Complex External Interface of the Business Partner (Tab.)
      IMPORTING
        es_business_partners = ls_bp_current        " Complex External Interface of the Business Partner (Tab.)
        es_error             = ls_error ).          " Message Structure of the Controller

    CLEAR ls_bus_ei_extern.

    READ TABLE ls_bp_current-partners ASSIGNING <fs_bp_current> INDEX 1.

*----------------------------------------------------------------------
* Check change in central_data
*----------------------------------------------------------------------
    CALL METHOD me->compare_data
      EXPORTING
        im_s_source  = ch_s_source-partner-central_data-common-data-bp_centraldata
        im_s_current = <fs_bp_current>-central_data-common-data-bp_centraldata
      CHANGING
        ch_s_data_x  = ch_s_source-partner-central_data-common-datax-bp_centraldata.

*----------------------------------------------------------------------
* Check for change in bp_organization
*----------------------------------------------------------------------
    CALL METHOD me->compare_data
      EXPORTING
        im_s_source  = ch_s_source-partner-central_data-common-data-bp_organization
        im_s_current = <fs_bp_current>-central_data-common-data-bp_organization
      CHANGING
        ch_s_data_x  = ch_s_source-partner-central_data-common-datax-bp_organization.

*----------------------------------------------------------------------
* Verify CNPJ and State Registration has change
*----------------------------------------------------------------------
    LOOP AT ch_s_source-partner-central_data-taxnumber-taxnumbers ASSIGNING <fs_taxnumbers_source>.

      READ TABLE <fs_bp_current>-central_data-taxnumber-taxnumbers
        ASSIGNING <fs_taxnumbers_current> WITH KEY data_key-taxtype = <fs_taxnumbers_source>-data_key-taxtype.

      " Check if there was a change in the number, if not remove from the update.
      " if in case it gets error in validation and recording a number without change.
      CHECK <fs_taxnumbers_current> IS ASSIGNED.

      IF <fs_taxnumbers_current>-data_key-taxnumber EQ <fs_taxnumbers_source>-data_key-taxnumber.
        DELETE ch_s_source-partner-central_data-taxnumber-taxnumbers WHERE data_key = <fs_taxnumbers_current>-data_key.
      ELSE.
        <fs_taxnumbers_source>-task = cc_object_task_update. "Update
      ENDIF.

    ENDLOOP.

*----------------------------------------------------------------------
* Verify change in mailing address
*----------------------------------------------------------------------
    READ TABLE <fs_bp_current>-central_data-address-addresses   ASSIGNING <fs_adress_current> INDEX 1.
    READ TABLE ch_s_source-partner-central_data-address-addresses ASSIGNING <fs_adress_source>  INDEX 1.

    IF <fs_adress_current> IS ASSIGNED AND <fs_adress_source> IS ASSIGNED.
      CALL METHOD me->compare_data
        EXPORTING
          im_s_source  = <fs_adress_source>-data-postal-data
          im_s_current = <fs_adress_current>-data-postal-data
        CHANGING
          ch_s_data_x  = <fs_adress_source>-data-postal-datax.
    ENDIF.

    " Always update, required field
    ch_s_source-customer-central_data-central-datax-icmstaxpay = abap_true.

*----------------------------------------------------------------------
* Verify company data
*----------------------------------------------------------------------
    DATA it_knb1 TYPE STANDARD TABLE OF knb1.

    SELECT * FROM knb1 INTO TABLE @it_knb1
        WHERE kunnr EQ @ch_s_source-customer-header-object_instance-kunnr.

    LOOP AT it_knb1 ASSIGNING FIELD-SYMBOL(<fs_company_current>).

      READ TABLE ch_s_source-customer-company_data-company
          ASSIGNING FIELD-SYMBOL(<fs_company_source>)
              WITH KEY data_key-bukrs = <fs_company_current>-bukrs.

      CHECK sy-subrc EQ 0.

      CALL METHOD me->compare_data
        EXPORTING
          im_s_source  = <fs_company_source>-data
          im_s_current = <fs_company_current>
        CHANGING
          ch_s_data_x  = <fs_company_source>-datax.

    ENDLOOP.

*----------------------------------------------------------------------
* Verify BUPA ROLES
*----------------------------------------------------------------------
    LOOP AT ch_s_source-partner-central_data-role-roles ASSIGNING FIELD-SYMBOL(<fs_roles_source>).
*      LOOP AT <fs_bp_current>-central_data-role-roles ASSIGNING FIELD-SYMBOL(<fs_roles_current>)
*          WHERE data-rolecategory EQ <fs_roles_source>-data-rolecategory .
*      ENDLOOP.

      READ TABLE <fs_bp_current>-central_data-role-roles
        WITH KEY data-rolecategory = <fs_roles_source>-data-rolecategory TRANSPORTING NO FIELDS.

      IF sy-subrc IS INITIAL.
        <fs_roles_source>-task = cc_object_task_update.
      ELSE.
        <fs_roles_source>-task = cc_object_task_insert.
      ENDIF.

    ENDLOOP.


  ENDMETHOD.

**********************************************************************
*&----------------------------------------------------------------------*
*& METHOD GET_BP_FROM_KUNNR.
*&----------------------------------------------------------------------*
  METHOD get_bp_from_kunnr.

    DATA:
      lv_kunnr          TYPE kunnr,
      lo_bp_customer_xd TYPE REF TO cvi_ka_bp_customer.

    lo_bp_customer_xd = cvi_ka_bp_customer=>get_instance( ).

    ex_v_kunnr = lv_kunnr = |{ im_v_kunnr ALPHA = IN }|.

    " Look for the BP from the Customer number, can not find.
    lo_bp_customer_xd->get_assigned_bp_for_customer(
      EXPORTING
        i_customer       = lv_kunnr         " Customer Number 1
*          i_persisted_only =               " Return Only Assignment That Has Already Been Made Persistent
      RECEIVING
        r_partner        = ex_v_bp_guid ).    " Business Partner GUID

    CALL METHOD lcl_bupa=>get_bp_numbers
      EXPORTING
        im_v_bu_bpext  = lv_kunnr
      CHANGING
        ch_v_bp_guid   = ex_v_bp_guid
        ch_v_bp_number = ex_v_bp_number.

    r_bp_number = ex_v_bp_number.

  ENDMETHOD.

*&----------------------------------------------------------------------*
*& METHOD CALL_BP_MAINTAIN.
*&    CALL cl_md_bp_maintain and write insert or updates
*&----------------------------------------------------------------------*
  METHOD call_bp_maintain.

    DATA:
      lt_return TYPE bapiretm.

    FIELD-SYMBOLS:
      <fs_bp_numbers> LIKE s_bp_numbers,
      <fs_alv>        TYPE ty_s_alv.

    CHECK:
      me->it_bp_numbers     IS NOT INITIAL,
      im_t_cvis_ei_extern   IS NOT INITIAL,
      me->get_test( )       IS INITIAL. "  Execução de teste


    CALL METHOD cl_md_bp_maintain=>maintain
      EXPORTING
        i_data   = im_t_cvis_ei_extern
      IMPORTING
        e_return = lt_return.

    CALL METHOD lcl_bupa=>set_commit( ).

    "Necessario corrigir, individualizar!!
*    PERFORM bp_relationship_create USING me->it_bp_numbers.

* Get number of new BP´s
*    LOOP AT me->it_bp_numbers ASSIGNING <fs_bp_numbers> WHERE bp_number IS INITIAL.
    IF ch_s_bp_numbers-bp_number IS INITIAL.
      me->get_bp_numbers(
        CHANGING
          ch_v_bp_guid   = ch_s_bp_numbers-bp_guid
          ch_v_bp_number = ch_s_bp_numbers-bp_number  ).
    ENDIF.
*    ENDLOOP.

*   Associates business partner number to alv table
    LOOP AT me->t_alv ASSIGNING <fs_alv> USING KEY key_kunnr
        WHERE kunnr = ch_s_bp_numbers-kunnr AND bp_number IS INITIAL.
      <fs_alv>-bp_number = ch_s_bp_numbers-bp_number.
    ENDLOOP.

    CALL METHOD me->handle_return_messages
      EXPORTING
        im_t_bapiretm   = lt_return
      CHANGING
        ch_s_bp_numbers = ch_s_bp_numbers.


  ENDMETHOD.

*&----------------------------------------------------------------------*
*&  METHOD GET_ALV_TABIX
*&    Get tabix from alv table to show message
*&----------------------------------------------------------------------*
  METHOD get_alv_tabix.

    READ TABLE me->it_bp_numbers WITH KEY kunnr = im_v_number TRANSPORTING NO FIELDS.

    r_tabix = sy-tabix.

  ENDMETHOD.

*&----------------------------------------------------------------------*
*&  METHOD handle_return_messages
*&    Handle messages from method cl_md_bp_maintain=>maintain
*&----------------------------------------------------------------------*
  METHOD handle_return_messages.

    DATA:
      lv_msgdummy TYPE string,
      lv_tabix    TYPE syst_tabix.

    FIELD-SYMBOLS:
      <fs_bapiretm>   LIKE LINE OF im_t_bapiretm,
      <fs_object_msg> TYPE bapiretc.
*      <fs_bp_numbers> LIKE LINE OF me->it_bp_numbers.

    lv_tabix = me->get_alv_tabix( ch_s_bp_numbers-kunnr ).


    LOOP AT im_t_bapiretm ASSIGNING <fs_bapiretm>.


* checks if there is any error message on bp or client creation
* It may happen that BP is created but the client role does not.
      CALL METHOD me->set_icon_alv_status
        EXPORTING
          im_v_kunnr = ch_s_bp_numbers-kunnr
          im_t_msg   = <fs_bapiretm>-object_msg.

      LOOP AT <fs_bapiretm>-object_msg ASSIGNING <fs_object_msg>.

        MESSAGE ID  <fs_object_msg>-id
        TYPE        <fs_object_msg>-type
        NUMBER      <fs_object_msg>-number
        WITH        <fs_object_msg>-message_v1
                    <fs_object_msg>-message_v2
                    <fs_object_msg>-message_v3
                    <fs_object_msg>-message_v4
        INTO lv_msgdummy.

        CALL METHOD lcl_messages=>store( ch_s_bp_numbers-kunnr ).

        IF <fs_object_msg>-type CA 'AE'.
          ch_s_bp_numbers-errors_found = abap_true.
        ENDIF.

      ENDLOOP.  "<fs_bapiretm>-object_msg ASSIGNING <fs_object_msg>.

    ENDLOOP. "LOOP AT im_t_bapiretm ASSIGNING <fs_bapiretm>.

    CALL METHOD me->check_customer_iu_successfully( ch_s_bp_numbers ).

  ENDMETHOD.

*&---------------------------------------------------------------------*
*&  METHOD GET_BUKRS_LIST
*&---------------------------------------------------------------------*
*  METHOD get_bukrs_list.

*    SELECT bukrs
*      FROM t001
*      INTO  TABLE me->t_bukrs
*      WHERE bukrs IN s_bukrs.

*  ENDMETHOD.

*&---------------------------------------------------------------------*
*&  METHOD fill_company_data
*&  Verify which company is already associated with the customer and add the rest
*&---------------------------------------------------------------------*
  METHOD fill_company_data.

    DATA:
      ls_cmds_ei_company TYPE cmds_ei_company,
      ls_knb1            TYPE knb1.

*    LOOP AT me->t_bukrs ASSIGNING FIELD-SYMBOL(<fs_bukrs>).
    LOOP AT me->o_file->upload_data-company_data ASSIGNING FIELD-SYMBOL(<fs_company_data>) USING KEY key_kunnr WHERE kunnr =  im_v_kunnr.

      CLEAR: ls_cmds_ei_company.

      CALL FUNCTION 'KNB1_SINGLE_READ'
        EXPORTING
          i_kunnr         = im_v_kunnr       " Customer Number
          i_bukrs         = <fs_company_data>-bukrs " Company Code
        EXCEPTIONS
          not_found       = 1                " No Entry Found
          parameter_error = 2                " Error in parameters
          kunnr_blocked   = 3                " KUNNR blocked
          OTHERS          = 4.

      IF sy-subrc EQ 1. " No Entry Found
        ls_cmds_ei_company-task = cc_object_task_insert. " I Insert
      ELSE.
        ls_cmds_ei_company-task = cc_object_task_update. " U
      ENDIF.

      ls_cmds_ei_company-data_key-bukrs = <fs_company_data>-bukrs.

      MOVE-CORRESPONDING <fs_company_data> TO ls_cmds_ei_company-data.

      APPEND ls_cmds_ei_company TO r_result.

    ENDLOOP.

  ENDMETHOD.

**********************************************************************
*  METHOD fill_contact_addresses.
*    DATA:
*      ls_adress        TYPE bus_ei_bupa_address,
*      ls_bp_telephone  TYPE bus_ei_bupa_telephone,
*      ls_bp_fax        TYPE bus_ei_bupa_fax,
*      ls_bp_email      TYPE bus_ei_bupa_smtp,
*      ls_bp_com_remark TYPE bus_ei_bupa_comrem.
*
*    IF im_s_contactpersons-celular IS NOT INITIAL.
*      ls_bp_telephone-contact-data-telephone  = im_s_contactpersons-celular.
*      ls_bp_telephone-contact-data-country    = cc_pais_iso_br.
*      ls_bp_com_remark-data-comm_notes        = 'Celular'(009).
*      ls_bp_com_remark-data-langu_iso         = cc_languiso_pt.
*      APPEND ls_bp_com_remark TO ls_bp_telephone-remark-remarks.
*      APPEND ls_bp_telephone TO ls_adress-data-communication-phone-phone.
*    ENDIF.
*
*    IF im_s_contactpersons-telefone_1 IS NOT INITIAL.
*      ls_bp_telephone-contact-data-telephone  = im_s_contactpersons-telefone_1.
*      ls_bp_telephone-contact-data-country    = cc_pais_iso_br.
*      ls_bp_com_remark-data-comm_notes        = 'Telefone 1'(010).
*      ls_bp_com_remark-data-langu_iso         = cc_languiso_pt.
*      APPEND ls_bp_com_remark TO ls_bp_telephone-remark-remarks.
*      APPEND ls_bp_telephone TO ls_adress-data-communication-phone-phone.
*    ENDIF.
*
*    IF im_s_contactpersons-telefone_2 IS NOT INITIAL.
*      ls_bp_telephone-contact-data-telephone  = im_s_contactpersons-telefone_2.
*      ls_bp_telephone-contact-data-country    = cc_pais_iso_br.
*      ls_bp_com_remark-data-comm_notes        = 'Telefone 2'(011).
*      ls_bp_com_remark-data-langu_iso         = cc_languiso_pt.
*      APPEND ls_bp_com_remark TO ls_bp_telephone-remark-remarks.
*      APPEND ls_bp_telephone TO ls_adress-data-communication-phone-phone.
*    ENDIF.
*
*    IF im_s_contactpersons-fax IS NOT INITIAL.
*      ls_bp_fax-contact-data-fax        = im_s_contactpersons-fax.
*      ls_bp_fax-contact-data-country    = cc_pais_iso_br.
*      ls_bp_com_remark-data-comm_notes  = 'FAX'.
*      ls_bp_com_remark-data-langu_iso   = cc_languiso_pt.
*      APPEND ls_bp_com_remark TO ls_bp_fax-remark-remarks.
*      APPEND ls_bp_fax TO ls_adress-data-communication-fax-fax.
*    ENDIF.
*
*    IF im_s_contactpersons-email IS NOT INITIAL.
*      ls_bp_email-contact-task = 'I'.
*      ls_bp_email-contact-data-e_mail   = im_s_contactpersons-email.
*      ls_bp_com_remark-data-comm_notes  = 'E-Mail'(012).
*      ls_bp_com_remark-data-langu_iso   = cc_languiso_pt.
*      APPEND ls_bp_com_remark TO ls_bp_email-remark-remarks.
*      APPEND ls_bp_email TO ls_adress-data-communication-smtp-smtp.
*    ENDIF.
*
*    IF im_s_contactpersons-email_alterna IS NOT INITIAL.
*      ls_bp_email-contact-task = 'I'.
*      ls_bp_email-contact-data-e_mail = im_s_contactpersons-email_alterna.
*      ls_bp_com_remark-data-comm_notes  = 'E-Mail Alternativo'(013).
*      ls_bp_com_remark-data-langu_iso   = cc_languiso_pt.
*      APPEND ls_bp_com_remark TO ls_bp_email-remark-remarks.
*      APPEND ls_bp_email TO ls_adress-data-communication-smtp-smtp.
*    ENDIF.
*
*    IF im_s_contactpersons-email_secretaria IS NOT INITIAL.
*      ls_bp_email-contact-task = 'I'.
*      ls_bp_email-contact-data-e_mail = im_s_contactpersons-email_secretaria.
*      ls_bp_com_remark-data-comm_notes  = 'E-Mail Secretaria'(014).
*      ls_bp_com_remark-data-langu_iso   = cc_languiso_pt.
*      APPEND ls_bp_com_remark TO ls_bp_email-remark-remarks.
*      APPEND ls_bp_email TO ls_adress-data-communication-smtp-smtp.
*    ENDIF.
*
*    APPEND ls_adress TO r_result.

*  ENDMETHOD.

*&----------------------------------------------------------------------*
*&  METHOD SET_ICON_ALV_STATUS
*&    Set status icon in ALV
*&----------------------------------------------------------------------*
  METHOD set_icon_alv_status.

    DATA:
*      lv_icon    TYPE tp_icon,
      lt_bapiret TYPE bapiret2_t.

    MOVE-CORRESPONDING im_t_msg TO lt_bapiret.

    "S Success
    READ TABLE lt_bapiret WITH KEY type = 'S' TRANSPORTING NO FIELDS.
    IF sy-subrc IS INITIAL.
      r_icon  = icon_led_green.
    ENDIF.

    "W Warning
    READ TABLE lt_bapiret WITH KEY type = 'W' TRANSPORTING NO FIELDS.
    IF sy-subrc IS INITIAL.
      r_icon  = icon_led_yellow.
    ENDIF.

    "E Error
    READ TABLE lt_bapiret WITH KEY type = 'E' TRANSPORTING NO FIELDS.
    IF sy-subrc IS INITIAL.
      r_icon  = icon_led_red.
*      <fs_bp_numbers>-errors_found = abap_true.
    ENDIF.

    "A Abort cancel.
    READ TABLE lt_bapiret WITH KEY type = 'A' TRANSPORTING NO FIELDS.
    IF sy-subrc IS INITIAL.
      r_icon  = icon_message_critical.
    ENDIF.


    CALL METHOD me->change_icon_alv_status
      EXPORTING
        im_v_icon  = r_icon
        im_v_kunnr = im_v_kunnr.

  ENDMETHOD.

  METHOD change_icon_alv_status.

    CHECK:
        im_v_icon  IS NOT INITIAL,
        im_v_kunnr IS NOT INITIAL.

    LOOP AT me->t_alv ASSIGNING FIELD-SYMBOL(<fs_alv>) USING KEY key_kunnr WHERE kunnr = im_v_kunnr.
      <fs_alv>-status = im_v_icon.
    ENDLOOP.

  ENDMETHOD.

*&----------------------------------------------------------------------*
*&  METHOD GET_ESTIMATED_TIME
*&    GET estimated time of execution
*&----------------------------------------------------------------------*
  METHOD get_estimated_time.

    CONSTANTS:
        c_numeric_characters TYPE c LENGTH 11 VALUE '1234567890 '.

    DATA:
      lv_time  TYPE i,
      lv_micro TYPE int8,
      lv_sec_n TYPE i,
      w_min    TYPE c LENGTH 2,
      w_sec    TYPE c LENGTH 2.


    GET RUN TIME FIELD lv_time.

    IF lv_time > me->time_ms.

      TRY.
          "Difference between start and end time
          lv_micro = lv_time - me->time_ms.

          "Calculates the estimated time for all interactions
          lv_micro = lv_micro * lines( me->it_bp_numbers ).

          "Convert to seconds
          lv_sec_n = abs( lv_micro DIV 1000000 ).

          "Sample data in w_second variable
          w_min =  lv_sec_n DIV 60 .
          w_sec =  lv_sec_n MOD 60 .

          IF w_min CN c_numeric_characters.
            w_min = '99'.
          ENDIF.

          UNPACK w_min TO w_min.
          UNPACK w_sec TO w_sec.

          r_result = |Est. { w_min }m { w_sec }s |.

          " CATCH cx_sy_conversion_no_number.
        CATCH cx_root.

      ENDTRY.

    ENDIF.

    me->time_ms = lv_time.

  ENDMETHOD.

*&----------------------------------------------------------------------*
*&  METHOD SET_CATEGORY
*&    Set category to BP
*&----------------------------------------------------------------------*
  METHOD set_category.

    CASE im_v_group.
      WHEN 'NACF'.
        r_result = '1'. " PF Pessoa
      WHEN OTHERS.
        r_result = '2'. "Company PJ Organização
    ENDCASE.

  ENDMETHOD.

*&----------------------------------------------------------------------*
*&  METHOD SET_CATEGORY
*&    Set category to BP
*&----------------------------------------------------------------------*
  METHOD set_title_key.

    "EMPRESA PREZADO SENHOR SENHOR SENHORA
    TRANSLATE im_v_anred TO UPPER CASE.

    CASE im_v_anred.

      WHEN 'SENHORA'.
        r_result = '0001'.

      WHEN 'PREZADO SENHOR' OR 'SENHOR'.
        r_result = '0002'.

      WHEN 'EMPRESA' .
        r_result = cc_title_key_3.

      WHEN OTHERS.
        CLEAR r_result.

    ENDCASE.

  ENDMETHOD.


*&----------------------------------------------------------------------*
*&  METHOD SET_ROLECATEGORY
*&
*&----------------------------------------------------------------------*
  METHOD set_rolecategory.

    DATA ls_roles TYPE bus_ei_bupa_roles.

    READ TABLE o_file->upload_data-company_data WITH TABLE KEY key_kunnr COMPONENTS kunnr = im_v_kunnr TRANSPORTING NO FIELDS.

    IF  sy-subrc IS INITIAL.
      ls_roles-task = cc_object_task_update.
      ls_roles-data-rolecategory = cc_rolecategory_client. "FLCU00 Cliente (contab.financ.)
      ls_roles-data_key          = cc_rolecategory_client. "FLCU00 Cliente (contab.financ.)
      APPEND ls_roles TO r_result.
    ENDIF.

    READ TABLE o_file->upload_data-sales_data WITH TABLE KEY key_kunnr COMPONENTS kunnr = im_v_kunnr TRANSPORTING NO FIELDS.

    IF  sy-subrc IS INITIAL.
      ls_roles-task = cc_object_task_update.
      ls_roles-data_key          = cc_rolecategory_client2. "FLCU01 Cliente (Org. Vendas)
      ls_roles-data-rolecategory = cc_rolecategory_client2. "FLCU01 Cliente (Org. Vendas)
      APPEND ls_roles TO r_result.
    ENDIF.

  ENDMETHOD.

*&----------------------------------------------------------------------*
*&  METHOD FILL_PROFILE_DATA
*&
*&----------------------------------------------------------------------*
  METHOD fill_profile_data.

    DATA lv_name TYPE string.

    READ TABLE o_file->upload_data-central_data
        ASSIGNING FIELD-SYMBOL(<fs_central_data>) WITH TABLE KEY key_kunnr COMPONENTS
        kunnr = im_s_bp_numbers-kunnr.

    MOVE-CORRESPONDING <fs_central_data> TO ch_s_bp_data-bp_centraldata.

    CASE ch_s_bp_data-bp_control-category.

      WHEN me->co_bp_category_org.

        CONCATENATE
        <fs_central_data>-name1
        <fs_central_data>-name2
        <fs_central_data>-name3
        <fs_central_data>-name4
        INTO lv_name." SEPARATED BY space.

        ch_s_bp_data-bp_organization = me->fill_organization_name( lv_name ).

*          MOVE-CORRESPONDING <fs_central_data> TO ch_s_bp_data-bp_organization.

      WHEN me->co_bp_category_person.

        MOVE-CORRESPONDING <fs_central_data> TO ch_s_bp_data-bp_person.

        CONCATENATE
        <fs_central_data>-firstname
        <fs_central_data>-middlename
        <fs_central_data>-lastname
        INTO  lv_name SEPARATED BY space.

        ch_s_bp_data-bp_person-fullname = lv_name.

    ENDCASE.

  ENDMETHOD.

*&----------------------------------------------------------------------*
*&  METHOD FILL_SALES_DATA
*&
*&----------------------------------------------------------------------*
  METHOD fill_sales_data.

    DATA:
      ls_cmds_ei_sales     TYPE cmds_ei_sales,
      ls_cmds_ei_functions TYPE cmds_ei_functions.

    LOOP AT me->o_file->upload_data-sales_data ASSIGNING FIELD-SYMBOL(<fs_sales_data>)
     USING KEY key_kunnr WHERE kunnr =  im_v_kunnr.

      CLEAR: ls_cmds_ei_sales.

      CALL FUNCTION 'KNVV_SINGLE_READ'
        EXPORTING
          i_kunnr         = <fs_sales_data>-kunnr    " Customer Number
          i_vkorg         = <fs_sales_data>-vkorg    " Sales Organization
          i_vtweg         = <fs_sales_data>-vtweg    " Distribution Channel
          i_spart         = <fs_sales_data>-spart    " Division
        EXCEPTIONS
          not_found       = 1                " No Entry Found
          parameter_error = 2                " Error in parameters
          kunnr_blocked   = 3                " KUNNR Blocked
          OTHERS          = 4.

      IF sy-subrc EQ 1.
        ls_cmds_ei_sales-task       = cc_object_task_insert. " I Insert
        ls_cmds_ei_functions-task   = cc_object_task_insert. " I Insert
      ELSE.
        ls_cmds_ei_sales-task       = cc_object_task_update.  " U Update
        ls_cmds_ei_functions-task   = cc_object_task_update.  " U Update
      ENDIF.

      MOVE-CORRESPONDING:
      <fs_sales_data>       TO ls_cmds_ei_sales-data_key,
      <fs_sales_data>       TO ls_cmds_ei_sales-data.

      ls_cmds_ei_functions-data-partner   = <fs_sales_data>-kunnr.

      ls_cmds_ei_functions-data_key-parvw = 'AG'.   "SP Emissor da ordem
*      ls_cmds_ei_functions-data_key-parza = '001'.
      APPEND ls_cmds_ei_functions TO ls_cmds_ei_sales-functions-functions.

      ls_cmds_ei_functions-data_key-parvw = 'RE'.   "BP Recebedor da fatura
*      ls_cmds_ei_functions-data_key-parza = '002'.
      APPEND ls_cmds_ei_functions TO ls_cmds_ei_sales-functions-functions.

      ls_cmds_ei_functions-data_key-parvw = 'RG'.   "PY Pagador
*      ls_cmds_ei_functions-data_key-parza = '003'.
      APPEND ls_cmds_ei_functions TO ls_cmds_ei_sales-functions-functions.

      ls_cmds_ei_functions-data_key-parvw = 'WE'.   "SH Receb.mercad.
*      ls_cmds_ei_functions-data_key-parza = '004'.
      APPEND ls_cmds_ei_functions TO ls_cmds_ei_sales-functions-functions.

      APPEND ls_cmds_ei_sales TO r_result.

    ENDLOOP."AT me->o_file->upload_data-sales_data ASSIGNING FIELD-SYMBOL(<fs_sales_data>)

  ENDMETHOD.

*&----------------------------------------------------------------------*
*&  METHOD EFFECTIVE_LOAD
*&
*&----------------------------------------------------------------------*
  METHOD effective_load.

    READ TABLE me->t_alv WITH KEY status = icon_led_red TRANSPORTING NO FIELDS.

    IF sy-subrc EQ 0.

      DATA lv_answer TYPE c.

      CALL FUNCTION 'POPUP_TO_CONFIRM'
        EXPORTING
          titlebar              = 'Confirmation'(019)
          text_question         = 'Ocorreram erros Deseja realizar a carga efetiva?'(018)
          text_button_1         = 'Sim'(020)
          text_button_2         = 'Não'(021)
          default_button        = '2'
          display_cancel_button = abap_false
        IMPORTING
          answer                = lv_answer " to hold the FM's return value
        EXCEPTIONS
          text_not_found        = 1
          OTHERS                = 2.
      IF sy-subrc <> 0.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
        WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
      ENDIF.

      IF lv_answer EQ '1'.

        me->set_test( abap_false ).

      ELSE.

        RETURN.

      ENDIF.

    ELSE.

      me->set_test( abap_false ).

    ENDIF.

    CALL METHOD me->create_bp.

  ENDMETHOD.

*&----------------------------------------------------------------------*
*&  METHOD GET_TEST
*&
*&----------------------------------------------------------------------*
  METHOD get_test.
    r_result = me->test.
  ENDMETHOD.

*&----------------------------------------------------------------------*
*&  METHOD SET_TEST
*&
*&----------------------------------------------------------------------*
  METHOD set_test.
    me->test = i_test.
  ENDMETHOD.

*&----------------------------------------------------------------------*
*&  METHOD compare_data
*&----------------------------------------------------------------------*
  METHOD compare_data.

    DATA:
      lo_table_descr  TYPE REF TO cl_abap_tabledescr,
      lo_struct_descr TYPE REF TO cl_abap_structdescr,
      lo_data         TYPE REF TO data,
      it_columns      TYPE abap_compdescr_tab.

    CREATE DATA lo_data LIKE im_s_current.

    lo_struct_descr ?= cl_abap_structdescr=>describe_by_data_ref( lo_data ).
    it_columns = lo_struct_descr->components.

    LOOP AT it_columns ASSIGNING FIELD-SYMBOL(<fs_field>).

      ASSIGN COMPONENT <fs_field>-name OF STRUCTURE im_s_current TO FIELD-SYMBOL(<fs_comp_current>).
      ASSIGN COMPONENT <fs_field>-name OF STRUCTURE im_s_source  TO FIELD-SYMBOL(<fs_comp_source>).
      ASSIGN COMPONENT <fs_field>-name OF STRUCTURE ch_s_data_x  TO FIELD-SYMBOL(<fs_comp_x>).

      CHECK:
          <fs_comp_current>   IS ASSIGNED,
          <fs_comp_source>    IS ASSIGNED,
          <fs_comp_x>         IS ASSIGNED.

      IF <fs_comp_current> NE <fs_comp_source>.
        <fs_comp_x> = abap_true.
      ENDIF.

      UNASSIGN:  <fs_comp_current>, <fs_comp_source>, <fs_comp_x>.

    ENDLOOP.

  ENDMETHOD.

  METHOD check_customer_iu_successfully.

    CONSTANTS:
      cc_msg_num_not_create       TYPE syst-msgno VALUE '153', "Cliente & não foi criado
      cc_msg_num_created          TYPE syst-msgno VALUE '247', "O cliente &1 foi criado.
      cc_msg_num_exists_bukrs     TYPE syst-msgno VALUE '152', "O cliente &1 já existe na empresa &2.
      cc_msg_num_notcreated_bukrs TYPE syst-msgno VALUE '154', "Cliente &1 não foi criado para empresa &2
      cc_msg_num_notcreated_org   TYPE syst-msgno VALUE '156', "Cliente &1 não está criado para área de vendas &2 &3 &4
      cc_msg_num_exists_org       TYPE syst-msgno VALUE '155', "Cliente &1 já foi criado para empresa &2, área de vendas &3
      cc_msg_num_created_bukrs    TYPE syst-msgno VALUE '171', "O cliente &1 foi criado na empresa &2..
      cc_msg_num_created_org      TYPE syst-msgno VALUE '173'. "O cliente &1 foi criado na organização de compras &2.

    DATA:
      vl_msg_num TYPE syst-msgno VALUE IS INITIAL,
      vl_msg_ty  TYPE syst-msgty VALUE 'S'.

    CALL FUNCTION 'KNA1_SINGLE_READ'
      EXPORTING
        kzrfb         = abap_true               " Indicator: Refresh Buffer Entry
        kna1_kunnr    = im_s_bp_numbers-kunnr   " Customer Number
*       cvp_behavior  =                  " Behavior for API
      EXCEPTIONS
        not_found     = 1
        kunnr_blocked = 2
        OTHERS        = 3.

    " Cliente não foi criado!
    IF sy-subrc NE 0.

      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
        WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 INTO DATA(lv_msgdummy).

      CALL METHOD lcl_messages=>store( im_s_bp_numbers-kunnr ).

      "Msg Cliente & não foi criado
      MESSAGE ID  'F2' TYPE 'E' NUMBER cc_msg_num_not_create WITH |{ im_s_bp_numbers-kunnr ALPHA = OUT }|
        INTO lv_msgdummy.

      CALL METHOD lcl_messages=>store( im_s_bp_numbers-kunnr ).

      CALL METHOD me->change_icon_alv_status
        EXPORTING
          im_v_icon  = icon_led_red
          im_v_kunnr = im_s_bp_numbers-kunnr.

      "CLiente foi criado!!!
    ELSE.

      "Msg O cliente &1 foi criado
      MESSAGE ID  'F2' TYPE 'S' NUMBER cc_msg_num_created WITH |{ im_s_bp_numbers-kunnr ALPHA = OUT }|
        INTO lv_msgdummy.
      CALL METHOD lcl_messages=>store( im_s_bp_numbers-kunnr ).

      " Verifica se as extensoes para empresas e org de negocios foram criadas.

      LOOP AT me->o_file->upload_data-company_data ASSIGNING FIELD-SYMBOL(<fs_company_data>)
              USING KEY key_kunnr WHERE kunnr = im_s_bp_numbers-kunnr.

        CALL FUNCTION 'KNB1_SINGLE_READ'
          EXPORTING
            i_kunnr         = im_s_bp_numbers-kunnr      " Customer Number
            i_bukrs         = <fs_company_data>-bukrs    " Company Code
            i_reset_buffer  = abap_true                  " Clear Buffer? (Yes = X)
          EXCEPTIONS
            not_found       = 1                " No Entry Found
            parameter_error = 2                " Error in parameters
            kunnr_blocked   = 3                " KUNNR blocked
            OTHERS          = 4.

        IF sy-subrc NE 0. "Erro

          MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 INTO lv_msgdummy.

          CALL METHOD lcl_messages=>store( im_s_bp_numbers-kunnr ).

          "Msg Cliente &1 não foi criado para empresa &2
          MESSAGE ID  'F2' TYPE 'E' NUMBER cc_msg_num_notcreated_bukrs
          WITH |{ im_s_bp_numbers-kunnr ALPHA = OUT }| <fs_company_data>-bukrs
            INTO lv_msgdummy.

          CALL METHOD lcl_messages=>store( im_s_bp_numbers-kunnr ).

          CALL METHOD me->change_icon_alv_status
            EXPORTING
              im_v_icon  = icon_led_red
              im_v_kunnr = im_s_bp_numbers-kunnr.

        ELSE. "OK

          IF im_s_bp_numbers-task_customer EQ cc_object_task_insert.

            "O cliente &1 foi criado na empresa &2
            vl_msg_num = cc_msg_num_created_bukrs.
            vl_msg_ty  = 'S'.

          ELSE.

            "O cliente &1 já existe na empresa &2.
            vl_msg_num = cc_msg_num_exists_bukrs.
            vl_msg_ty  = 'S'.

          ENDIF.

          MESSAGE ID  'F2' TYPE vl_msg_ty NUMBER vl_msg_num
          WITH |{ im_s_bp_numbers-kunnr ALPHA = OUT }| <fs_company_data>-bukrs
            INTO lv_msgdummy.

          CALL METHOD lcl_messages=>store( im_s_bp_numbers-kunnr ).

        ENDIF.
      ENDLOOP.

      LOOP AT me->o_file->upload_data-sales_data ASSIGNING FIELD-SYMBOL(<fs_sales_data>)
              USING KEY key_kunnr WHERE kunnr = im_s_bp_numbers-kunnr.

        CALL FUNCTION 'KNVV_SINGLE_READ'
          EXPORTING
            i_kunnr         = im_s_bp_numbers-kunnr  " Customer Number
            i_vkorg         = <fs_sales_data>-vkorg  " Sales Organization
            i_vtweg         = <fs_sales_data>-vtweg  " Distribution Channel
            i_spart         = <fs_sales_data>-spart  " Division
            i_reset_buffer  = abap_true              " Clear Buffer? (Yes = X)
*           i_bypassing_buffer =                     " Process Buffer? (No = X)
*           i_cvp_behavior  =
          EXCEPTIONS
            not_found       = 1                " No Entry Found
            parameter_error = 2                " Error in parameters
            kunnr_blocked   = 3                " KUNNR Blocked
            OTHERS          = 4.

        IF sy-subrc NE 0. "Erro

          "Fornecedor &1 não foi criado para organização de compras &2
          vl_msg_num = cc_msg_num_notcreated_org.
          vl_msg_ty  = 'E'.

          CALL METHOD me->change_icon_alv_status
            EXPORTING
              im_v_icon  = icon_led_red
              im_v_kunnr = im_s_bp_numbers-kunnr.

        ELSE. "OK

          "Já existe fornecedor &1 para organização de compras &2
          vl_msg_num = cc_msg_num_exists_org.
          vl_msg_ty  = 'S'.
        ENDIF.

        MESSAGE ID  'F2' TYPE vl_msg_ty NUMBER vl_msg_num
         WITH |{ <fs_sales_data>-kunnr ALPHA = OUT }| <fs_sales_data>-vkorg
            INTO lv_msgdummy.

        CALL METHOD lcl_messages=>store( im_s_bp_numbers-kunnr ).


      ENDLOOP.

    ENDIF.

  ENDMETHOD.

  METHOD check_customer_exists.

    CALL FUNCTION 'KNA1_SINGLE_READ'
      EXPORTING
        kzrfb         = abap_true               " Indicator: Refresh Buffer Entry
        kna1_kunnr    = ch_s_bp_numbers-kunnr   " Customer Number
*       cvp_behavior  =                  " Behavior for API
      EXCEPTIONS
        not_found     = 1
        kunnr_blocked = 2
        OTHERS        = 3.

    IF sy-subrc EQ 1.
*    Customer does not exist
      ch_s_bp_numbers-create_customer = abap_true.
      ch_s_bp_numbers-task_customer   = cc_object_task_insert.


    ELSE.
*    Customer already exists
      ch_s_bp_numbers-create_customer = abap_false.
      ch_s_bp_numbers-task_customer   = cc_object_task_update.
    ENDIF.


  ENDMETHOD.

*=====================================================================
  METHOD fill_tax_ind.
    CONSTANTS:
      c_tatyp_ibrx TYPE knvi-tatyp VALUE 'IBRX' ##NO_TEXT,
      c_aland_br   TYPE knvi-aland VALUE cc_pais_iso_br.

    DATA:
      ls_cmds_ei_tax_ind TYPE cmds_ei_tax_ind.

    LOOP AT me->o_file->upload_data-tax_classf ASSIGNING FIELD-SYMBOL(<fs_tax_classf>)
        WHERE kunnr =  im_v_kunnr.

      CLEAR: ls_cmds_ei_tax_ind.

      CALL FUNCTION 'KNVI_SINGLE_READ'
        EXPORTING
          i_kunnr   = <fs_tax_classf>-kunnr   " Customer Number
          i_aland   = <fs_tax_classf>-aland   " Deliv. Country
          i_tatyp   = <fs_tax_classf>-tatyp   " Tax Category
        EXCEPTIONS
          not_found = 1                " No Entry Found
          OTHERS    = 4.

      IF sy-subrc EQ 1.
        ls_cmds_ei_tax_ind-task = cc_object_task_insert. " I Insert
      ELSE.
        ls_cmds_ei_tax_ind-task        = cc_object_task_update.  " U Update
        ls_cmds_ei_tax_ind-datax-taxkd = abap_true.
      ENDIF.

      MOVE-CORRESPONDING:
      <fs_tax_classf>       TO ls_cmds_ei_tax_ind-data_key,
      <fs_tax_classf>       TO ls_cmds_ei_tax_ind-data.

      APPEND ls_cmds_ei_tax_ind TO r_result.

    ENDLOOP."me->o_file->upload_data-tax_classf ASSIGNING FIELD-SYMBOL(<fs_tax_classf>)

    IF syst-subrc IS NOT INITIAL AND p_taxc EQ abap_true.

      CALL FUNCTION 'KNVI_SINGLE_READ'
        EXPORTING
          i_kunnr   = im_v_kunnr        " Customer Number
          i_aland   = c_aland_br        " Deliv. Country
          i_tatyp   = c_tatyp_ibrx      " Tax Category
        EXCEPTIONS
          not_found = 1                 " No Entry Found
          OTHERS    = 4.

      IF sy-subrc EQ 1.
        ls_cmds_ei_tax_ind-task        = cc_object_task_insert. " I Insert
      ELSE.
        ls_cmds_ei_tax_ind-task        = cc_object_task_update.  " U Update
        ls_cmds_ei_tax_ind-datax-taxkd = abap_true.
      ENDIF.

      ls_cmds_ei_tax_ind-data_key-aland = c_aland_br.
      ls_cmds_ei_tax_ind-data_key-tatyp = c_tatyp_ibrx.
      ls_cmds_ei_tax_ind-data-taxkd     = 1.

      APPEND ls_cmds_ei_tax_ind TO r_result.

    ENDIF.

  ENDMETHOD.

ENDCLASS.                       " lcl_bupa

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
*&---------------------------------------------------------------------*
*& Class (Implementation) cl_file
*&---------------------------------------------------------------------*
CLASS lcl_file IMPLEMENTATION.

  METHOD get_init_filename.

    DATA lv_value TYPE filepath.

    " Get the path parameter set for the user
    GET PARAMETER ID cc_parameter_id FIELD lv_value.

    CALL METHOD cl_gui_frontend_services=>get_upload_download_path
      CHANGING
        upload_path   = ex_v_dirup
        download_path = ex_v_dirdown.

    " If the parameter is not set / empty
    " takes the definition of the working folder of the sapgui user
    IF lv_value IS INITIAL.
      CONCATENATE ex_v_dirup 'extract_FI_87_TBP100.xlsx' INTO r_filename.
    ELSE.
      CONCATENATE ex_v_dirup lv_value   INTO r_filename.
    ENDIF.

  ENDMETHOD.                    "get_init_filename

*&---------------------------------------------------------------------*
*&  METHOD SELECT_FILE
*&---------------------------------------------------------------------*
  METHOD select_file.
    DATA:
      lt_filetable TYPE filetable,
      lv_subrc     TYPE sysubrc.

    CONSTANTS cc_file_ext(26) TYPE c VALUE '*.xlsx;*.xlsm;*.xlsb;*.xls'.

    CALL METHOD cl_gui_frontend_services=>file_open_dialog
      EXPORTING
        window_title            = |{ TEXT-006 }|
        file_filter             = |{ TEXT-004 } ({ cc_file_ext })\| { cc_file_ext }\|  { TEXT-005 } (*.*)\|*.*|
        multiselection          = abap_false
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

    READ TABLE lt_filetable INTO r_filename INDEX 1.

  ENDMETHOD.                    "select_file

*&---------------------------------------------------------------------*
*&  METHOD UPLOAD
*&---------------------------------------------------------------------*
  METHOD upload.

    DATA:
      lo_excel     TYPE REF TO zcl_excel,
      lo_reader    TYPE REF TO zif_excel_reader,
      lo_worksheet TYPE REF TO zcl_excel_worksheet,
*      lo_reader    TYPE REF TO zcl_excel_reader_2007,
      go_error     TYPE REF TO cx_root.

    CALL METHOD lcl_messages=>progress_indicator
      EXPORTING
        im_v_text = 'Carregando dados da planilha'(m01).


    FIELD-SYMBOLS <fs_worksheet> TYPE ANY TABLE.

    CREATE OBJECT lo_reader TYPE zcl_excel_reader_2007.

    TRY.

        lo_excel = lo_reader->load_file(  p_file ).
        "Use template for charts
        lo_excel->use_template = abap_true. "?????? Não faço ideia do que é isso

*        lo_excel->get_worksheets_size( ).

      CATCH zcx_excel INTO go_error .
        " O file excel & não pode ser processado
        MESSAGE ID 'UX' TYPE 'E' NUMBER '893'
           WITH p_file RAISING conversion_failed.

    ENDTRY.

    DO lo_excel->get_worksheets_size( ) TIMES.
      TRY.

          ASSIGN COMPONENT sy-index OF STRUCTURE me->upload_data TO <fs_worksheet>.

          IF sy-subrc NE 0. EXIT. ENDIF.

          lo_worksheet =  lo_excel->get_worksheet_by_index( iv_index = sy-index ).

          lo_worksheet->get_table(
            EXPORTING
              iv_skipped_rows = 1
*              iv_skipped_cols = 0
            IMPORTING
              et_table        = <fs_worksheet> ).

        CATCH cx_root INTO go_error .

          IF ( lines( <fs_worksheet> ) ) EQ lo_worksheet->get_tables_size( ).
            MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
              WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4
              RAISING conversion_failed.
          ENDIF.

      ENDTRY.

      "Add leading zeros to the customer number for all tables.
      LOOP AT <fs_worksheet> ASSIGNING FIELD-SYMBOL(<fs_table>).
        ASSIGN COMPONENT 'KUNNR' OF STRUCTURE <fs_table> TO FIELD-SYMBOL(<fs_kunnr>).
        <fs_kunnr> = |{ <fs_kunnr> ALPHA = IN }|.
      ENDLOOP.

    ENDDO.

* Checks whether any data has been imported
    IF me->upload_data IS INITIAL.
      MESSAGE ID 'Z_BUPA' TYPE cc_msg_error NUMBER '007'
        RAISING upload_date_not_found.
    ENDIF.

  ENDMETHOD.

*&---------------------------------------------------------------------*
*&  METHOD set_sscrtexts
*&---------------------------------------------------------------------*
  METHOD set_sscrtexts.

    DATA l_text TYPE smp_dyntxt.

    MOVE:
      icon_export          TO l_text-icon_id,
      'Baixar modelo'(t03) TO l_text-text,                  "#EC *
      'Baixar modelo'(t03) TO l_text-icon_text.

    sscrfields-functxt_01 = l_text.

  ENDMETHOD.

  METHOD set_parameter_id.

    DATA:
      lv_dir  TYPE localfile,
      lv_file TYPE localfile.

    CALL FUNCTION 'SO_SPLIT_FILE_AND_PATH'
      EXPORTING
        full_name     = p_file
      IMPORTING
        stripped_name = lv_file   "file name
        file_path     = lv_dir    "directory path
      EXCEPTIONS
        x_error       = 1
        OTHERS        = 2.

    SET PARAMETER ID cc_parameter_id FIELD lv_file.

  ENDMETHOD.

ENDCLASS.                       "lcl_file

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
*&---------------------------------------------------------------------*
*& Class (Implementation) cl_messages
*&---------------------------------------------------------------------*
CLASS lcl_messages IMPLEMENTATION.

  METHOD initialize.

*    Initialize message store.
    CALL FUNCTION 'MESSAGES_ACTIVE'
      EXCEPTIONS
        not_active = 1
        OTHERS     = 2.
    IF sy-subrc EQ 1.
      CALL FUNCTION 'MESSAGES_INITIALIZE'
        EXCEPTIONS
          log_not_active       = 1
          wrong_identification = 2
          OTHERS               = 3.
    ENDIF.

    IF sy-subrc NE 0.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
              WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDIF.
  ENDMETHOD.

*&---------------------------------------------------------------------*
*& METHOD SHOW
*&   Show all messages stored
*&---------------------------------------------------------------------*
  METHOD show.
    DATA: lv_line TYPE i.

    MOVE im_v_line TO lv_line .

    CALL FUNCTION 'MESSAGES_SHOW'
      EXPORTING
        line_from          = lv_line          " Only show messages with longer reference line
        line_to            = lv_line          " Only show messages with shorter reference line
        batch_list_type    = 'J'              " J = job log / L = in spool list / B = both
        show_linno_text    = 'Cliente'(017) " Column header for row
*       show_linno_text_len = '3'             " Column width for row in display
        i_use_grid         = abap_true        " Use ALV Grid for Display; Otherwise Classic ALV
      EXCEPTIONS
        inconsistent_range = 1                " LINE_TO is shorter than LINE_FROM
        no_messages        = 2                " No messages in required interval
        OTHERS             = 3.
    IF sy-subrc NE 0.
      MESSAGE ID sy-msgid TYPE 'S' NUMBER sy-msgno DISPLAY LIKE 'E'
        WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDIF.

  ENDMETHOD.

*&---------------------------------------------------------------------*
*& METHOD STORE
*&   Store messages with lines
*&---------------------------------------------------------------------*
  METHOD store .
    DATA: lv_zeile TYPE i.

    lv_zeile = |{ im_v_zeile ALPHA = OUT }|.

    CALL FUNCTION 'MESSAGE_STORE'
      EXPORTING
        exception_if_not_active = abap_true     " X = exception not_active is initialized if
        arbgb                   = syst-msgid    " Message ID
        msgty                   = syst-msgty    " Type of message (I, S, W, E, A)
        msgv1                   = syst-msgv1    " First variable parameter of message
        msgv2                   = syst-msgv2    " Second variable parameter of message
        msgv3                   = syst-msgv3    " Third variable parameter of message
        msgv4                   = syst-msgv4    " Fourth variable parameter of message
        txtnr                   = sy-msgno      " Message Number
        zeile                   = lv_zeile      " Reference line (if it exists)
      EXCEPTIONS
        message_type_not_valid  = 1                " Type of message not I, S, W, E or A
        not_active              = 2                " Collection of messages not activated
        OTHERS                  = 3.
    IF sy-subrc IS NOT INITIAL.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
        WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDIF.

  ENDMETHOD.

*&---------------------------------------------------------------------*
*& METHOD store_validate
*&   Store messages with lines from method validate
*&---------------------------------------------------------------------*
  METHOD store_validate.

    LOOP AT im_t_return_map ASSIGNING FIELD-SYMBOL(<fs_return_map>).
      MESSAGE ID  <fs_return_map>-id
      TYPE        <fs_return_map>-type
      NUMBER      <fs_return_map>-number
      WITH        <fs_return_map>-message_v1
                  <fs_return_map>-message_v2
                  <fs_return_map>-message_v3
                  <fs_return_map>-message_v4
      INTO DATA(lv_msgdummy).

      CALL METHOD lcl_messages=>store( im_v_index_line ).

    ENDLOOP.

  ENDMETHOD.


*&---------------------------------------------------------------------*
*& Form PROGRESS_INDICATOR
*&---------------------------------------------------------------------*
*& --> iv_text      Texto a ser utilizado na mensagem
*& --> iv_processed Valor sendo processado
*& --> iv_total     Total do valores a serem processados
*&---------------------------------------------------------------------*
  METHOD progress_indicator.

    DATA:
      lv_text     TYPE string,
      lv_output_i TYPE boole_d VALUE IS INITIAL.

    IF im_v_total IS NOT INITIAL.

      lv_text = | { im_v_text } [{ im_v_processed } de { im_v_total }] |.

    ELSE.

      lv_text           = im_v_text .

    ENDIF.

    IF im_v_processed LT 4.
      lv_output_i = abap_true.
    ENDIF.

    CALL METHOD cl_progress_indicator=>progress_indicate
      EXPORTING
        i_text               = lv_text          " Progress Text (If no message transferred in I_MSG*)
        i_processed          = im_v_processed   " Number of Objects Already Processed
        i_total              = im_v_total       " Total Number of Objects to Be Processed
        i_output_immediately = lv_output_i.     " X = Display Progress Immediately

  ENDMETHOD.

ENDCLASS.
