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
INCLUDE zrag_carga_clientes_top.
INCLUDE zrag_carga_clientes_cl.

DATA o_bupa TYPE REF TO lcl_bupa.
*----------------------------------------------------------------------
*	INITIALIZATION
*----------------------------------------------------------------------
INITIALIZATION.

  CALL FUNCTION 'RS_SUPPORT_SELECTIONS'
    EXPORTING
      report               = sy-repid
      variant              = '/DEFAULT'
    EXCEPTIONS
      variant_not_existent = 01
      variant_obsolete     = 02.

  CALL METHOD:
    lcl_messages=>initialize( ),
    lcl_file=>set_sscrtexts( ).

* Gets data in memory or parameters for the file path field
  p_file = lcl_file=>get_init_filename( ).

*----------------------------------------------------------------------
*	Events
*----------------------------------------------------------------------

AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_file.
  p_file = lcl_file=>select_file( ).

AT SELECTION-SCREEN.
  CASE sscrfields-ucomm.
    WHEN'FC01'.
*      CALL METHOD lcl_file=>export_model.
  ENDCASE.

*----------------------------------------------------------------------
*	Beginning of Processing
*----------------------------------------------------------------------
START-OF-SELECTION.

*  Sets the memory parameter for the field
  lcl_file=>set_parameter_id( p_file ).

  CREATE OBJECT o_bupa
    EXCEPTIONS
      upload_error = 1
      OTHERS       = 2.

  IF sy-subrc NE 0.
    MESSAGE ID sy-msgid TYPE 'S' NUMBER sy-msgno DISPLAY LIKE cc_msg_error
      WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    LEAVE LIST-PROCESSING.
  ENDIF.

  CALL METHOD lcl_alv=>show
    EXPORTING
      im_v_test = abap_true
    CHANGING
      it_outtab = o_bupa->t_alv.

*END-OF-SELECTION.

*&---------------------------------------------------------------------*
*& Form BP_RELATIONSHIP_CREATE
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> IT_BP_NUMBERS
*&---------------------------------------------------------------------*
*FORM bp_relationship_create  USING  pt_bp_numbers TYPE STANDARD TABLE.
*  DATA:
*    ls_return             TYPE TABLE OF bapiret2.
*
*  FIELD-SYMBOLS:
*    <fs_bp_numbers>         LIKE s_bp_numbers,
*    <fs_bp_contact_numbers> TYPE ty_e_contact_numbers.
*
*  LOOP AT pt_bp_numbers ASSIGNING <fs_bp_numbers>.
*
*    LOOP AT <fs_bp_numbers>-contact ASSIGNING <fs_bp_contact_numbers>.
*
*      CALL FUNCTION 'BUPR_CONTP_CREATE'
*        EXPORTING
*         IV_PARTNER            =
*          iv_partner_guid       = <fs_bp_numbers>-bp_guid
*         IV_CONTACTPERSON      =
*          iv_contactperson_guid = <fs_bp_contact_numbers>-guid_bp_contact
*          iv_date_from          = sy-datlo
*          iv_x_save             = abap_true
*        TABLES
*          et_return             = ls_return.
*
*      CALL METHOD lcl_bupa=>set_commit( ).
*
*    ENDLOOP.
*  ENDLOOP.
*
*
*ENDFORM.
*&---------------------------------------------------------------------*
*& Form USER_COMMAND
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM user_command_alv USING p_ucomm     TYPE syst_ucomm
                            p_selfield  TYPE slis_selfield ##CALLED.

  CONSTANTS:
    cc_double_click TYPE syst_ucomm VALUE '&IC1',
    cc_all_message  TYPE syst_ucomm VALUE '&ALLMSG'.

  DATA:
    lv_partner_number TYPE bu_partner.


  CASE p_ucomm.

    WHEN cc_double_click.

      CHECK:
          p_selfield-value IS NOT INITIAL.

      CASE p_selfield-fieldname.
        WHEN 'KUNNR'.

          lv_partner_number = lcl_bupa=>get_bp_from_kunnr( p_selfield-value ).

          PERFORM call_transaction_bp USING lv_partner_number.

        WHEN 'BP_NUMBER'.

          lv_partner_number = |{ p_selfield-value ALPHA = IN }|.

          PERFORM call_transaction_bp USING lv_partner_number.

        WHEN OTHERS.

          READ TABLE o_bupa->t_alv ASSIGNING FIELD-SYMBOL(<fs_alv>) INDEX p_selfield-tabindex.

          CALL METHOD lcl_messages=>show( <fs_alv>-kunnr ).

      ENDCASE. "CASE p_selfield-fieldname.

    WHEN cc_all_message.
      CALL METHOD lcl_messages=>show( ).

    WHEN '&EXEC1'.

      CALL METHOD o_bupa->effective_load( ).
      p_selfield-refresh = abap_true.  " refresh ALV list !!!

    WHEN OTHERS.

  ENDCASE. "CASE p_ucomm.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CALL_TRANSACTION_BP
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LV_PARTNER_NUMBER
*&---------------------------------------------------------------------*
FORM call_transaction_bp  USING p_partner_number TYPE bu_partner.

  CHECK p_partner_number IS NOT INITIAL.

  SET PARAMETER ID 'BPA' FIELD p_partner_number.
  CALL TRANSACTION 'BP' WITH AUTHORITY-CHECK.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form ALV_SET_STATUS
*&---------------------------------------------------------------------*
FORM alv_set_status USING p_extab TYPE kkblo_t_extab.

  IF o_bupa->get_test( ) IS INITIAL.
    APPEND '&EXEC1' TO p_extab.
  ENDIF.

  SET PF-STATUS 'ALV_STATUS' EXCLUDING p_extab.

ENDFORM.
