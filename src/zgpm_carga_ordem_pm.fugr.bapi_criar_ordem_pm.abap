* --------------------------------------------------------------------------*
*                  T A E S A - MIGRAÇÃO - AGIR                              *
* --------------------------------------------------------------------------*
* Consultoria .....: Intechpro                                              *
* ABAP.............: Richard de Aquino Rodrigues                            *
* Funcional........: André Santos                                           *
* Módulo...........: PM                                                     *
* Programa.........: BAPI_CRIAR_ORDEM_PM                                    *
* Transação........:                                                        *
* Tipo de Prg......: FUNÇÃO                                                 *
* Objetivo.........: Criar ordem                                            *
* Data.............: 06/09/2018                                             *
* --------------------------------------------------------------------------*
* Request    | Descrição                                                    *
* --------------------------------------------------------------------------*
* S4DK902389 | AGIR - Carga de Dados para Migração - HXXX - Ordens de PM    *
* --------------------------------------------------------------------------*

*  OBS1.: Método Standard para criar "Ordem"
*            Função BAPI_ALM_ORDER_MAINTAIN

*  OBS2.: Esta função chama a função standard BAPI_ALM_ORDER_MAINTAIN
*           - Atender ao Migration CockPit
*             - Ter um flag de execução em teste (P_I_TESTRUN).
*             - Jogar todas as mensagens para uma única tabela de saída P_E_TI_RETURN

FUNCTION bapi_criar_ordem_pm.
*"----------------------------------------------------------------------
*"*"Interface local:
*"  IMPORTING
*"     VALUE(P_I_WA_HEADER_ORDEM) TYPE  ZEPM_HEADER_IW31
*"     VALUE(P_I_TI_OPERACOES) TYPE  ZTPM_OPERACOES_IW31
*"     VALUE(P_I_TESTRUN) TYPE  BAPIE1GLOBAL_DATA-TESTRUN OPTIONAL
*"  EXPORTING
*"     REFERENCE(P_E_TI_RETURN) TYPE  BAPIRET2_TAB
*"----------------------------------------------------------------------

  DATA: lc_orderid             TYPE aufnr VALUE '%00000000001',
        li_cont                TYPE sy-tabix,
        lc_erro                TYPE c,
        ti_methods             TYPE STANDARD TABLE OF bapi_alm_order_method,
        wa_methods             TYPE bapi_alm_order_method,
        ti_header              TYPE STANDARD TABLE OF bapi_alm_order_headers_i,
        ti_operations          TYPE STANDARD TABLE OF bapi_alm_order_operation,
        wa_operacao            TYPE zepm_operacoes_iw31,
        wa_operation           TYPE bapi_alm_order_operation,
        wa_return              TYPE bapiret2,
        ti_return              TYPE bapiret2_t,
        ti_return_fim          TYPE bapiret2_t,

        wa_header              TYPE alm_me_order_header,
        wa_campos_ad_cabecalho TYPE zepm_campos_ad_cabecalho,

        wa_order_header        TYPE alm_me_order_header,
        ti_order_operation     TYPE STANDARD TABLE OF alm_me_order_operation,
        wa_order_operation     TYPE alm_me_order_operation.

*-------------------------------------------------------------------*
*-------------------------------------------------------------------*
  MOVE-CORRESPONDING p_i_wa_header_ordem TO wa_header.
  MOVE-CORRESPONDING p_i_wa_header_ordem TO wa_campos_ad_cabecalho.

*--------------------------------------------------------------------*
* Insere as Operações
*--------------------------------------------------------------------*
  LOOP AT p_i_ti_operacoes INTO wa_operacao WHERE NOT activity IS INITIAL.

    MOVE-CORRESPONDING wa_operacao TO wa_order_operation.
    APPEND wa_order_operation TO ti_order_operation.
    CLEAR  wa_order_operation.

  ENDLOOP.

*---------------------------------------------------------------*
* Criar ordem
  CALL FUNCTION 'ZALM_ME_ORDER_CREATE'
    EXPORTING
      order_header               = wa_header
      p_i_wa_campos_ad_cabecalho = wa_campos_ad_cabecalho
      p_i_testrun                = p_i_testrun
    IMPORTING
      e_order_header             = wa_order_header
    TABLES
      order_operation            = ti_order_operation
      return                     = ti_return.

*---------------------------------------------------------------*
  APPEND LINES OF ti_return TO ti_return_fim.

  READ TABLE ti_return WITH KEY type = 'E' TRANSPORTING NO FIELDS.
  IF sy-subrc = 0.
    lc_erro = abap_true.
  ENDIF.

* Se for execução em teste e tudo OK
  IF ( p_i_testrun EQ abap_true ) AND ( lc_erro IS INITIAL ).

    wa_return-type = 'S'.
    CONCATENATE 'Tudo ok -' wa_order_header-orderid INTO wa_return-message
                                                    SEPARATED BY space.
    APPEND wa_return TO ti_return_fim.

  ENDIF.

*---------------------------------------------------------------*
  IF NOT ti_return_fim[] IS INITIAL.
    p_e_ti_return[] = ti_return_fim[].
  ENDIF.

ENDFUNCTION.
