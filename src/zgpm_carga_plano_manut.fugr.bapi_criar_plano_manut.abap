* --------------------------------------------------------------------------*
*                  T A E S A - MIGRAÇÃO - AGIR                              *
* --------------------------------------------------------------------------*
* Consultoria .....: Intechpro                                              *
* ABAP.............: Richard de Aquino Rodrigues                            *
* Funcional........: André Santos                                           *
* Módulo...........: PM                                                     *
* Programa.........: BAPI_CRIAR_PLANO_MANUT                                 *
* Transação........:                                                        *
* Tipo de Prg......: FUNÇÃO                                                 *
* Objetivo.........: Criar Plano de mamutenção                              *
* Data.............: 16/09/2018                                             *
* --------------------------------------------------------------------------*
* Request    | Descrição                                                    *
* --------------------------------------------------------------------------*
* S4DK902570 | AGIR - Carga de Dados para Migração - HXXX - Plano de Manut. *
* --------------------------------------------------------------------------*


*  OBS1.: Método Standard para criar "Plano de manutanção"
*            Função MPLAN_CREATE ou MAINTENANCE_PLAN_POST

*  OBS2.: Esta função chama a função Standard MPLAN_CREATEE
*           - Atender ao Migration CockPit
*             - Ter um flag de execução em teste (P_I_TESTRUN).
*             - Jogar todas as mensagens para uma única tabela de saída P_E_TI_RETURN

FUNCTION bapi_criar_plano_manut.
*"----------------------------------------------------------------------
*"*"Interface local:
*"  IMPORTING
*"     VALUE(P_I_WA_HEADER_PLANO) TYPE  ZEPM_HEADER_PLANO
*"     VALUE(P_I_TESTRUN) TYPE  BAPIE1GLOBAL_DATA-TESTRUN OPTIONAL
*"  EXPORTING
*"     REFERENCE(P_E_TI_RETURN) TYPE  BAPIRET2_TAB
*"----------------------------------------------------------------------

  DATA:
    lc_erro       TYPE c,
    lc_number     TYPE warpl,
    wa_header     TYPE mplan_mpla,
    wa_return     TYPE bapiret2,
    wa_item       TYPE mplan_mpos,
    wa_cycle      TYPE mplan_mmpt,
    ti_items      TYPE STANDARD TABLE OF mplan_mpos,
    ti_cycles     TYPE STANDARD TABLE OF mplan_mmpt,
    ti_return     TYPE bapiret2_t,
    ti_return_fim TYPE bapiret2_t.

*-------------------------------------------------------------------*
*-------------------------------------------------------------------*
  MOVE-CORRESPONDING p_i_wa_header_plano TO wa_header.
  MOVE-CORRESPONDING p_i_wa_header_plano TO wa_item.
  wa_item-mityp = p_i_wa_header_plano-mptyp.
  MOVE-CORRESPONDING p_i_wa_header_plano TO wa_cycle.

  APPEND wa_item  TO ti_items.
  APPEND wa_cycle TO ti_cycles.

*--------------------------------------------------------------*
* Create Maintenance Plan
  CALL FUNCTION 'MPLAN_CREATE'
    EXPORTING
      header = wa_header
    IMPORTING
      number = lc_number
    TABLES
      items  = ti_items
      cycles = ti_cycles
      return = ti_return.

*---------------------------------------------------------------*
  APPEND LINES OF ti_return TO ti_return_fim.

*---------------------------------------------------------------*
  READ TABLE ti_return WITH KEY type = 'E' TRANSPORTING NO FIELDS.
  IF sy-subrc = 0.
    lc_erro = abap_true.
  ELSE.
    IF lc_number IS INITIAL.
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

      CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
        EXPORTING
          wait   = 'X'
        IMPORTING
          return = wa_return.

      IF NOT wa_return IS INITIAL.

        APPEND wa_return TO ti_return_fim.

      ELSE.

        wa_return-type = 'S'.
        CONCATENATE 'Pano de manutenção criado -' lc_number INTO wa_return-message
                                                            SEPARATED BY space.
        APPEND wa_return TO ti_return_fim.

      ENDIF.

    ENDIF.

  ENDIF.

*---------------------------------------------------------------*
  IF NOT ti_return_fim[] IS INITIAL.
    p_e_ti_return[] = ti_return_fim[].
  ENDIF.

ENDFUNCTION.
