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
INCLUDE zrag_carga_acc_post_top.
INCLUDE zrag_carga_acc_post_cl.

*----------------------------------------------------------------------*
* INITIALIZATION
*----------------------------------------------------------------------*
INITIALIZATION.
  CALL METHOD lcl_file=>set_sscrtexts( ).
  CALL METHOD lcl_file=>get_parameter.
  CALL METHOD lcl_file=>get_object_from_memory( ).
  PERFORM set_screen.

*----------------------------------------------------------------------*
* AT SELECTION-SCREEN ON VALUE-REQUEST FOR
*----------------------------------------------------------------------*
AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_file.
  p_file = lcl_file=>select_file( ).

AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_tcode.
  CALL FUNCTION 'F4_TRANSACTION'
    EXPORTING
      object = p_tcode      " Transaction
    IMPORTING
      result = p_tcode.     " Single selection result

AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_vers.
  CALL FUNCTION 'FMCU_SHOW_VERSION'
    EXPORTING
      i_fm_area  = p_fmarea
    IMPORTING
      e_version  = p_vers
    EXCEPTIONS
      no_version = 1
      OTHERS     = 2.
*----------------------------------------------------------------------*
* AT SELECTION-SCREEN
*----------------------------------------------------------------------*b03
AT SELECTION-SCREEN.
  PERFORM set_screen.
  CALL METHOD lcl_file=>set_parameter.
  CASE sscrfields-ucomm.
    WHEN'FC01'.
      CALL METHOD lcl_file=>export_model.
    WHEN'FC02'.
      CALL METHOD lcl_file=>start_upload( ).
    WHEN'FC03'.
      lcl_file=>clear_database_memory( ).
    WHEN'B1_UCOM'.
      CALL METHOD lcl_file=>upload_to_server( ).

  ENDCASE.

AT SELECTION-SCREEN ON RADIOBUTTON GROUP rb1.
  PERFORM set_screen.

*----------------------------------------------------------------------*
* AT SELECTION-SCREEN OUTPUT
*----------------------------------------------------------------------*
AT SELECTION-SCREEN OUTPUT.
  PERFORM set_screen.

*----------------------------------------------------------------------*
* AT SELECTION-SCREEN ON EXIT-COMMAND
*----------------------------------------------------------------------*
*AT SELECTION-SCREEN ON EXIT-COMMAND.

*  CALL METHOD lcl_file=>set_obj_to_memory( ).

*----------------------------------------------------------------------*
* START-OF-SELECTION
*----------------------------------------------------------------------*
START-OF-SELECTION.

  CALL METHOD lcl_file=>start_upload( abap_true ).

END-OF-SELECTION.

*&---------------------------------------------------------------------*
*&      Form  SET_SCREEN
*&---------------------------------------------------------------------*
FORM set_screen .
  DATA:
    wa_screen     TYPE screen,
    lv_ktopl      LIKE skat-ktopl VALUE 'TB00',
    lv_saknr      LIKE skat-saknr,
    lv_txt50      LIKE skat-txt50,
    wtstct        LIKE tstct,
    lv_blart_text LIKE t003t-ltext.

  CASE abap_true.
    WHEN rb_psbal OR rb_lfn OR rb_kunnr.
      LOOP AT SCREEN INTO wa_screen.
        IF wa_screen-group1 EQ 'G1' OR
           wa_screen-group1 EQ 'G5' OR
           wa_screen-group1 EQ 'FM'.
          wa_screen-active    = 0.
          wa_screen-invisible = 1.

          MODIFY SCREEN FROM wa_screen.
        ENDIF.
      ENDLOOP.

    WHEN rb_glact.
      LOOP AT SCREEN INTO wa_screen.
        IF wa_screen-group1 EQ 'G1' OR
           wa_screen-group1 EQ 'G2' OR
           wa_screen-group1 EQ 'G5' OR
           wa_screen-group1 EQ 'G6' OR
           wa_screen-group1 EQ 'FM'.

          wa_screen-active    = 0.
          wa_screen-invisible = 1.
          MODIFY SCREEN FROM wa_screen.
        ENDIF.
      ENDLOOP.

    WHEN rb_glbal.
      LOOP AT SCREEN INTO wa_screen.
        IF wa_screen-group1 EQ 'G1' OR
           wa_screen-group1 EQ 'G5'.
          wa_screen-active    = 1.
          wa_screen-invisible = 0.
        ELSEIF wa_screen-group1 EQ 'FM'.
          wa_screen-active    = 0.
          wa_screen-invisible = 1.
        ENDIF.
        MODIFY SCREEN FROM wa_screen.
      ENDLOOP.

    WHEN rb_fmbo.
      LOOP AT SCREEN INTO wa_screen.
        IF ( wa_screen-group1 EQ 'G1' OR
             wa_screen-group1 EQ 'G2' OR
             wa_screen-group1 EQ 'G5' ) AND
             wa_screen-group1 NE 'G6' .

          wa_screen-active    = 0.
          wa_screen-invisible = 1.
          MODIFY SCREEN FROM wa_screen.
        ELSE.
          wa_screen-active    = 1.
          wa_screen-invisible = 0.
          MODIFY SCREEN FROM wa_screen.
        ENDIF.
      ENDLOOP.

    WHEN OTHERS.
      LOOP AT SCREEN INTO wa_screen.
        IF wa_screen-group1 EQ 'G1'.
          wa_screen-active    = 1.
          wa_screen-invisible = 0.
        ELSEIF wa_screen-group1 EQ 'FM'.
          wa_screen-active    = 0.
          wa_screen-invisible = 1.
        ENDIF.
        MODIFY SCREEN FROM wa_screen.
      ENDLOOP.

  ENDCASE.

  CASE abap_true.
    WHEN rb_file1.
      LOOP AT SCREEN INTO wa_screen.
        IF wa_screen-group1 EQ 'G4'.
          wa_screen-active    = 0.
          wa_screen-invisible = 1.
          MODIFY SCREEN FROM wa_screen.
        ENDIF.
      ENDLOOP.

*    WHEN rb_file2.
*      LOOP AT SCREEN INTO wa_screen.
*        IF wa_screen-group1 EQ 'G3'.
*          wa_screen-active    = 0.
*          wa_screen-invisible = 1.
*          MODIFY SCREEN FROM wa_screen.
*        ENDIF.
*      ENDLOOP.
    WHEN OTHERS.
      LOOP AT SCREEN INTO wa_screen.
        IF wa_screen-group1 EQ 'G4'.
          wa_screen-active    = 1.
          wa_screen-invisible = 0.
          MODIFY SCREEN FROM wa_screen.
        ENDIF.
      ENDLOOP.
  ENDCASE.

*---------------------------------------------------------------------
  IF p_tcode IS INITIAL.
    CASE abap_true.
      WHEN rb_psbal.
        p_tcode = lcl_ps_balance=>tcode.
      WHEN rb_lfn.
        p_tcode = lcl_acc_payable=>tcode.
      WHEN rb_kunnr.
        p_tcode = lcl_acc_receivable=>tcode.
      WHEN OTHERS.
        p_tcode = lcl_ps_balance=>tcode.
    ENDCASE.
  ENDIF.

  IF p_gkont IS INITIAL.
    CASE abap_true.
      WHEN rb_psbal.
        p_gkont = lcl_ps_balance=>gkont.
      WHEN rb_lfn.
        p_gkont = lcl_acc_payable=>gkont.
      WHEN rb_kunnr.
        p_gkont = lcl_acc_receivable=>gkont.
      WHEN OTHERS.
        p_gkont = lcl_ps_balance=>gkont.
    ENDCASE.
  ENDIF.

*---------------------------------------------------------------------
* Get text for GL account
  lv_saknr = p_gkont.

  PERFORM set_text_account IN PROGRAM saplgl_account_master_maintain USING    lv_ktopl lv_saknr
                                                                   CHANGING lv_txt50.
  gt_gkont = lv_txt50.

*---------------------------------------------------------------------
* Get text for Transaction Code
  CALL FUNCTION 'TSTCT_SINGLE_READ'
    EXPORTING
      sprache    = sy-langu         " Language
      tcode      = p_tcode          " Transaction Code
    IMPORTING
      wtstct     = wtstct           " Transaction Code Texts
    EXCEPTIONS
      wrong_call = 1                " DE-EN-LANG-SWITCH-NO-TRANSLATION
      OTHERS     = 2.
  IF sy-subrc EQ 0.
    gt_tcode = wtstct-ttext.
  ENDIF.

*---------------------------------------------------------------------
* Get text for FI Document type
  CALL FUNCTION 'FI_DOCUMENT_TYPE_DATA'
    EXPORTING
      i_blart = p_blart           " Document type
    IMPORTING
      e_ltext = lv_blart_text.

  gt_blart = lv_blart_text.

*---------------------------------------------------------------------
* Get Textos de tipos de movimento
  SELECT SINGLE txt FROM t856t INTO gt_bewar
            WHERE trtyp = p_bewar
              AND langu = sy-langu.

*---------------------------------------------------------------------
* Get Textos tipo doc FM
  DATA:
    l_t_doctypet TYPE fmed_t_doctypet.
  CALL FUNCTION 'FMCU_GET_DOCTYPES'
    EXPORTING
      i_flg_with_text = abap_true
    IMPORTING
*     e_t_doctype     = l_t_doctype
      e_t_doctypet    = l_t_doctypet
    EXCEPTIONS
      no_doctype      = 1
      OTHERS          = 2.
  READ TABLE l_t_doctypet ASSIGNING FIELD-SYMBOL(<fs_doctypet>)
    WITH KEY langu   = sy-langu
             doctype = p_dtype
    BINARY SEARCH.
  IF sy-subrc IS INITIAL.
    gt_dtype = <fs_doctypet>-text.
  ENDIF.


  SELECT SINGLE text15 FROM buprocess_uit
    INTO gt_proc
  WHERE langu = syst-langu AND
        process_ui = p_proces.

  MODIFY SCREEN.

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  F_USER_COMMAND
*&---------------------------------------------------------------------*
FORM f_user_command.

  PERFORM set_screen.

ENDFORM.
