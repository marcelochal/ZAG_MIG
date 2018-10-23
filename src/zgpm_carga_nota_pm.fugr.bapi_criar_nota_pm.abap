* --------------------------------------------------------------------------*
*                  T A E S A - MIGRAÇÃO - AGIR                              *
* --------------------------------------------------------------------------*
* Consultoria .....: Intechpro                                              *
* ABAP.............: Richard de Aquino Rodrigues                            *
* Funcional........: André Santos                                           *
* Módulo...........: PM                                                     *
* Programa.........: BAPI_CRIAR_NOTA_PM                                     *
* Transação........:                                                        *
* Tipo de Prg......: FUNÇÃO                                                 *
* Objetivo.........: Criar nota                                             *
* Data.............: 08/09/2018                                             *
* --------------------------------------------------------------------------*
* Request    | Descrição                                                    *
* --------------------------------------------------------------------------*
* S4DK902433 | AGIR - Carga de Dados para Migração - HXXX - Notas de PM     *
* --------------------------------------------------------------------------*

*  OBS1.: Método Standard para criar "Nota"
*            Função ALM_PM_NOTIFICATION_CREATE

*  OBS2.: Esta função chama a função desenv. ZFPM_ALM_PM_NOTIF_CREATE
*           - Atender ao Migration CockPit
*             - Ter um flag de execução em teste (P_I_TESTRUN).
*             - Jogar todas as mensagens para uma única tabela de saída P_E_TI_RETURN
*             - Trabalhar com campos adicionais (Não contemplados na BAPI original)

FUNCTION bapi_criar_nota_pm.
*"----------------------------------------------------------------------
*"*"Interface local:
*"  IMPORTING
*"     VALUE(P_I_WA_HEADER_NOTA) TYPE  ZEPM_HEADER_NOTA
*"     VALUE(P_I_TESTRUN) TYPE  BAPIE1GLOBAL_DATA-TESTRUN OPTIONAL
*"  EXPORTING
*"     REFERENCE(P_E_TI_RETURN) TYPE  BAPIRET2_TAB
*"----------------------------------------------------------------------

  DATA:
    lc_erro             TYPE c,
    ln_item_sort_no     TYPE qlfdpos, "Nº ordenação para o item

    lc_text_line1       TYPE tdline,
    lc_text_line2       TYPE tdline,
    lc_text_line3       TYPE tdline,
    lc_text_line4       TYPE tdline,
    lc_text_line5       TYPE tdline,

    lc_tdline           TYPE line1000,

    wa_return           TYPE bapiret2,
    wa_notifheader      TYPE bapi2080_nothdri,
    wa_nota             TYPE bapi2080_nothdre,
    wa_longtexts        TYPE bapi2080_notfulltxti,
    wa_notitem          TYPE bapi2080_notitemi,
    wa_notifcaus        TYPE bapi2080_notcausi,
    wa_notifactv        TYPE bapi2080_notactvi,
    wa_campos_add_riqs5 TYPE zepm_campos_add_riqs5,
    ti_longtexts        TYPE STANDARD TABLE OF bapi2080_notfulltxti,
    ti_return           TYPE bapiret2_t,
    ti_return_fim       TYPE bapiret2_t,
    ti_notitem          TYPE STANDARD TABLE OF bapi2080_notitemi,
    ti_notifcaus        TYPE STANDARD TABLE OF bapi2080_notcausi,
    ti_notifactv        TYPE STANDARD TABLE OF bapi2080_notactvi.

*-------------------------------------------------------------------*
*-------------------------------------------------------------------*

  MOVE-CORRESPONDING p_i_wa_header_nota TO wa_notifheader.

*  CLEAR:
*        wa_notifheader-code_group.
*         wa_notifheader-coding.

  MOVE-CORRESPONDING p_i_wa_header_nota TO wa_campos_add_riqs5.

*--------------------------------------------------------------*
* Tratar o texto longo

  IF NOT p_i_wa_header_nota-tdline IS INITIAL.

    lc_tdline              = p_i_wa_header_nota-tdline.

    lc_text_line1          = lc_tdline+02(132).
    IF NOT lc_text_line1 IS INITIAL.
      wa_longtexts-objtype   = 'QMEL'.
      wa_longtexts-text_line = lc_text_line1.
      APPEND  wa_longtexts TO ti_longtexts.
      CLEAR   wa_longtexts.
    ENDIF.

    lc_text_line2 = lc_tdline+134(132).
    IF NOT lc_text_line2 IS INITIAL.
      wa_longtexts-objtype   = 'QMEL'.
      wa_longtexts-text_line = lc_text_line2.
      APPEND  wa_longtexts TO ti_longtexts.
      CLEAR   wa_longtexts.
    ENDIF.

    lc_text_line3 = lc_tdline+266(132).
    IF NOT lc_text_line3 IS INITIAL.
      wa_longtexts-objtype   = 'QMEL'.
      wa_longtexts-text_line = lc_text_line3.
      APPEND  wa_longtexts TO ti_longtexts.
      CLEAR   wa_longtexts.
    ENDIF.

    lc_text_line4 = lc_tdline+398(132).
    IF NOT lc_text_line4 IS INITIAL.
      wa_longtexts-objtype   = 'QMEL'.
      wa_longtexts-text_line = lc_text_line4.
      APPEND  wa_longtexts TO ti_longtexts.
      CLEAR   wa_longtexts.
    ENDIF.

    lc_text_line5 = lc_tdline+530(132).
    IF NOT lc_text_line5 IS INITIAL.
      wa_longtexts-objtype   = 'QMEL'.
      wa_longtexts-text_line = lc_text_line5.
      APPEND  wa_longtexts TO ti_longtexts.
      CLEAR   wa_longtexts.
    ENDIF.

  ENDIF.

*--------------------------------------------------------------*
* Causa
  ln_item_sort_no = '0001'.

  wa_notifcaus-cause_codegrp = p_i_wa_header_nota-urgrp.
  wa_notifcaus-cause_code    = p_i_wa_header_nota-urcod.
  IF NOT wa_notifcaus IS INITIAL.
    wa_notifcaus-item_sort_no  = ln_item_sort_no.  "Nº ordenação para o item
    wa_notifcaus-cause_sort_no = ln_item_sort_no.  "Nº ordenação
    APPEND wa_notifcaus TO ti_notifcaus.
    CLEAR  wa_notifcaus.
  ENDIF.

*--------------------------------------------------------------*
* Atividade / Ação
  ln_item_sort_no = '0001'.

  wa_notifactv-act_codegrp  = p_i_wa_header_nota-mngrp.
  wa_notifactv-act_code     = p_i_wa_header_nota-mncod.
  IF NOT wa_notifactv IS INITIAL.
*    wa_notifactv-item_sort_no = ln_item_sort_no. "Nº ordenação para o item
    wa_notifactv-act_sort_no  = ln_item_sort_no.  "Nº ordenação
    APPEND wa_notifactv TO ti_notifactv.
    CLEAR  wa_notifactv.
  ENDIF.

*--------------------------------------------------------------*
  ln_item_sort_no = '0001'.

* Dano / Problema / Avaria
  wa_notitem-d_codegrp   = p_i_wa_header_nota-fegrp.
  wa_notitem-d_code      = p_i_wa_header_nota-fecod.
* Parte
  wa_notitem-dl_codegrp  = p_i_wa_header_nota-code_group.
  wa_notitem-dl_code     = p_i_wa_header_nota-coding.

  IF NOT wa_notitem IS INITIAL.
    wa_notitem-item_sort_no = ln_item_sort_no. "Nº ordenação
    APPEND wa_notitem TO ti_notitem.
    CLEAR  wa_notitem.
  ENDIF.

*--------------------------------------------------------------*
* Create PM/CS Notification
  CALL FUNCTION 'ZFPM_ALM_PM_NOTIF_CREATE'
    EXPORTING
      external_number         = p_i_wa_header_nota-external_number
      notif_type              = p_i_wa_header_nota-notif_type
      notifheader             = wa_notifheader
      orderid                 = p_i_wa_header_nota-orderid
      p_i_wa_campos_add_riqs5 = wa_campos_add_riqs5
    IMPORTING
      notifheader_export      = wa_nota
    TABLES
      notitem                 = ti_notitem
      notifcaus               = ti_notifcaus
      notifactv               = ti_notifactv
      longtexts               = ti_longtexts
      return                  = ti_return.

*---------------------------------------------------------------*
  APPEND LINES OF ti_return TO ti_return_fim.

*---------------------------------------------------------------*
  READ TABLE ti_return WITH KEY type = 'E' TRANSPORTING NO FIELDS.
  IF sy-subrc = 0.
    lc_erro = abap_true.
  ELSE.
    IF wa_nota-notif_no IS INITIAL.
      lc_erro = abap_true.
    ENDIF.
  ENDIF.

*---------------------------------------------------------------*
* Se for execução em teste.
  IF p_i_testrun EQ abap_true.

* =====> Não faz nada.

* Se for execução valendo.
  ELSE.

*   Se tudo OK
    IF lc_erro IS INITIAL.

      REFRESH ti_return.

*     Save PM/CS Notification
      CALL FUNCTION 'BAPI_ALM_NOTIF_SAVE'
        EXPORTING
          number              = wa_nota-notif_no
          together_with_order = 'X'
        IMPORTING
          notifheader         = wa_nota
        TABLES
          return              = ti_return.

*---------------------------------------------------------------*
      APPEND LINES OF ti_return TO ti_return_fim.

*---------------------------------------------------------------*
      READ TABLE ti_return WITH KEY type = 'E' TRANSPORTING NO FIELDS.
      IF sy-subrc = 0.
        lc_erro = abap_true.
      ENDIF.

*---------------------------------------------------------------*
*     Se tudo OK
      IF lc_erro IS INITIAL.

        CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
          EXPORTING
            wait   = 'X'
          IMPORTING
            return = wa_return.

        IF NOT wa_return IS INITIAL.

          APPEND wa_return TO ti_return_fim.

        ELSE.

          wa_return-type = 'S'.
          CONCATENATE 'Nota criada -' wa_nota-notif_no INTO wa_return-message
                                                      SEPARATED BY space.
          APPEND wa_return TO ti_return_fim.

        ENDIF.

      ENDIF.

    ENDIF.

  ENDIF.

*---------------------------------------------------------------*
  IF NOT ti_return_fim[] IS INITIAL.
    p_e_ti_return[] = ti_return_fim[].
  ENDIF.

ENDFUNCTION.
