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
  lcl_file=>set_sscrtexts( ).
  WRITE icon_yellow_light AS ICON TO icon_001.
  CALL METHOD lcl_file=>get_parameter.
  CALL METHOD lcl_file=>get_object_from_memory( ).

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
  ENDCASE.

AT SELECTION-SCREEN ON RADIOBUTTON GROUP rb1.
  PERFORM set_screen.

*----------------------------------------------------------------------*
* AT SELECTION-SCREEN OUTPUT
*----------------------------------------------------------------------*
AT SELECTION-SCREEN OUTPUT.
  PERFORM set_screen.

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
        IF wa_screen-group1 EQ 'G1'.
          wa_screen-active    = 0.
          wa_screen-invisible = 1.
          MODIFY SCREEN FROM wa_screen.
        ENDIF.
      ENDLOOP.

    WHEN rb_glact.
      LOOP AT SCREEN INTO wa_screen.
        IF wa_screen-group1 EQ 'G1' OR wa_screen-group1 EQ 'G2'..
          wa_screen-active    = 0.
          wa_screen-invisible = 1.
          MODIFY SCREEN FROM wa_screen.
        ENDIF.
      ENDLOOP.
    WHEN OTHERS.
      LOOP AT SCREEN INTO wa_screen.
        IF wa_screen-group1 EQ 'G1'.
          wa_screen-active    = 1.
          wa_screen-invisible = 0.
          MODIFY SCREEN FROM wa_screen.
        ENDIF.
      ENDLOOP.

  ENDCASE.

*---------------------------------------------------------------------
  CASE abap_true.

    WHEN rb_psbal.
      p_tcode = lcl_ps_balance=>tcode.
      p_gkont = lcl_ps_balance=>gkont.

    WHEN rb_lfn.
      p_tcode = lcl_acc_payable=>tcode.
      p_gkont = lcl_acc_payable=>gkont.

    WHEN rb_kunnr.
      p_tcode = lcl_acc_receivable=>tcode.
      p_gkont = lcl_acc_receivable=>gkont.

  ENDCASE.

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

  MODIFY SCREEN.

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  F_USER_COMMAND
*&---------------------------------------------------------------------*
FORM f_user_command.

  PERFORM set_screen.

ENDFORM.
