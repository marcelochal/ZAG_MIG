* --------------------------------------------------------------------------*
*                  T A E S A - MIGRAÇÃO - AGIR                              *
* --------------------------------------------------------------------------*
* Consultoria .....: Intechpro                                              *
* ABAP.............: Richard de Aquino Rodrigues                            *
* Funcional........: André Santos                                           *
* Módulo...........: PM                                                     *
* Programa.........: BAPI_CRIAR_LISTA_TAREFAS                               *
* Transação........:                                                        *
* Tipo de Prg......: FUNÇÃO                                                 *
* Objetivo.........: Criar Lista de tarefas                                 *
* Data.............: 16/09/2018                                             *
* --------------------------------------------------------------------------*
* Request    | Descrição                                                    *
* --------------------------------------------------------------------------*
* S4DK902577 | AGIR - Carga de Dados para Migração - HXXX - Lista tarefas   *
* --------------------------------------------------------------------------*

*  OBS1.: Método Standard para criar "Lista de tarefas"
*            Função EAM_TASKLIST_CREATE

*  OBS2.: Esta função chama a função Standard EAM_TASKLIST_CREATE
*           - Atender ao Migration CockPit
*             - Ter um flag de execução em teste (P_I_TESTRUN).
*             - Jogar todas as mensagens para uma única tabela de saída P_E_TI_RETURN

FUNCTION bapi_criar_lista_tarefas.
*"----------------------------------------------------------------------
*"*"Interface local:
*"  IMPORTING
*"     VALUE(P_I_WA_HEADER_LISTA) TYPE  ZEPM_HEADER_LISTA
*"     VALUE(P_I_TI_OPERACOES_LISTA) TYPE  ZTPM_OPERACAO_LISTA
*"     VALUE(P_I_TESTRUN) TYPE  BAPIE1GLOBAL_DATA-TESTRUN OPTIONAL
*"  EXPORTING
*"     REFERENCE(P_E_TI_RETURN) TYPE  BAPIRET2_TAB
*"----------------------------------------------------------------------


  DATA:
    lc_erro        TYPE c,
    lc_ev_plnnr    TYPE plnnr,
    lc_ev_plnal    TYPE plnal,
    wa_header      TYPE eam_s_hdr_ins,
    wa_return      TYPE bapiret2,
    wa_operacao    TYPE eam_s_tl_opr,
    wa_operacao_in TYPE zepm_operacao_lista,
    ti_operacoes   TYPE eam_t_tl_opr,
    ti_return      TYPE bapiret2_t,
    ti_return_fim  TYPE bapiret2_t.

  DATA: ti_operacoes_in TYPE SORTED TABLE OF zepm_operacao_lista
                        WITH NON-UNIQUE KEY plnty plnnr vornr.

*-------------------------------------------------------------------*
*-------------------------------------------------------------------*
  MOVE-CORRESPONDING p_i_wa_header_lista TO wa_header.

  wa_header-arbpl      = p_i_wa_header_lista-arbpl_op.
  wa_header-arbpl_werk = p_i_wa_header_lista-werks_op.

*----------------------------------------------------------*
  ti_operacoes_in[] = p_i_ti_operacoes_lista[].

  LOOP AT ti_operacoes_in INTO wa_operacao_in.

    MOVE-CORRESPONDING wa_operacao_in TO wa_operacao.
    APPEND wa_operacao TO ti_operacoes.
    CLEAR  wa_operacao.

  ENDLOOP.

*--------------------------------------------------------------*
* Create API for task list
  CALL FUNCTION 'EAM_TASKLIST_CREATE'
    EXPORTING
      is_header     = wa_header
      iv_profile    = p_i_wa_header_lista-profidnetz
    IMPORTING
      ev_plnnr      = lc_ev_plnnr
      ev_plnal      = lc_ev_plnal
    TABLES
      it_operations = ti_operacoes
      et_return     = ti_return.

*---------------------------------------------------------------*
  APPEND LINES OF ti_return TO ti_return_fim.

*---------------------------------------------------------------*
  READ TABLE ti_return WITH KEY type = 'E' TRANSPORTING NO FIELDS.
  IF sy-subrc = 0.
    lc_erro = abap_true.
  ELSE.
    IF lc_ev_plnnr IS INITIAL.
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

*     Trigger posting
      CALL FUNCTION 'EAM_TASKLIST_POST'
        EXPORTING
          iv_plnty  = wa_header-plnty
          iv_plnnr  = lc_ev_plnnr
        IMPORTING
          et_return = ti_return.

      APPEND LINES OF ti_return TO ti_return_fim.

      READ TABLE ti_return WITH KEY type = 'E' TRANSPORTING NO FIELDS.

*     Se tudo OK
      IF sy-subrc NE 0.

        CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
          EXPORTING
            wait   = 'X'
          IMPORTING
            return = wa_return.

        IF NOT wa_return IS INITIAL.

          APPEND wa_return TO ti_return_fim.

        ELSE.

          wa_return-type = 'S'.

          CONCATENATE 'Lista criada -' lc_ev_plnnr lc_ev_plnal
                 INTO wa_return-message SEPARATED BY space.

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
