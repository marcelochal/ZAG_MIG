* --------------------------------------------------------------------------*
*                  T A E S A - MIGRAÇÃO - AGIR                              *
* --------------------------------------------------------------------------*
* Consultoria .....: Intechpro                                              *
* ABAP.............: Richard de Aquino Rodrigues                            *
* Funcional........: André Santos                                           *
* Módulo...........: PS                                                     *
* Programa.........: BAPI_CRIAR_TAREFAS                                     *
* Transação........:                                                        *
* Tipo de Prg......: FUNÇÃO                                                 *
* Objetivo.........: Criar Tarefas                                          *
* Data.............: 01/09/2018                                             *
* --------------------------------------------------------------------------*
* Request    | Descrição                                                    *
* --------------------------------------------------------------------------*
* S4DK902284 | AGIR - Carga de Dados para Migração - HXXX - Tarefa          *
* --------------------------------------------------------------------------*

*  OBS1.: Método Standard para criar "Tarefas"
*            Função BAPI_BUS2002_ACT_CREATE_MULTI

*  OBS2.: Esta função chama a função standard BAPI_BUS2002_ACT_CREATE_MULTI
*           - Atender ao Migration CockPit
*             - Trabalhar os campos Zs (Não)
*             - Ter um flag de execução em teste (P_I_TESTRUN).
*             - Jogar todas as mensagens para uma única tabela de saída P_E_TI_RETURN


FUNCTION bapi_criar_tarefas.
*"----------------------------------------------------------------------
*"*"Interface local:
*"  IMPORTING
*"     VALUE(P_I_DIAG_REDE) TYPE  NW_AUFNR
*"     REFERENCE(P_I_TI_TAREFAS) TYPE  ZTPS_BAPI_BUS2002_ACT_NEW
*"     REFERENCE(P_I_TI_CAMPOS_ZS) TYPE  ZTPS_BAPI_TE_NETWORK_ACTIVITY
*"       OPTIONAL
*"     REFERENCE(P_I_TI_SERVICOS) TYPE  ZTPS_SERVICOS OPTIONAL
*"     VALUE(P_I_TESTRUN) TYPE  BAPIE1GLOBAL_DATA-TESTRUN OPTIONAL
*"  EXPORTING
*"     REFERENCE(P_E_TI_RETURN) TYPE  BAPIRET2_TAB
*"----------------------------------------------------------------------

  DATA: lc_valuepart     TYPE valuepart,
        lc_erro          TYPE c,
        li_tabix         TYPE syst_tabix,
        wa_return	       TYPE bapiret2,
        wa_campos_zs     TYPE bapi_te_network_activity,
        wa_prps_ext_in   TYPE bapiparex,
        wa_servico       TYPE	zeps_servico,
        wa_tarefa        TYPE bapi_bus2002_act_new,
        wa_params        TYPE ctu_params,
        ti_et_activities TYPE STANDARD TABLE OF bapi_bus2002_act_detail,
        ti_bdcdata       TYPE tab_bdcdata,
        ti_campos_zs     TYPE tt_it_netw_ext_in,
        ti_tarefas       TYPE ztps_bapi_bus2002_act_new,
        ti_tarefas_serv  TYPE ztps_bapi_bus2002_act_new,
        ti_return        TYPE bapiret2_tab,
        ti_return_fim    TYPE bapiret2_tab.

*-------------------------------------------------------------------*
*-------------------------------------------------------------------*

  CALL FUNCTION 'BAPI_PS_INITIALIZATION'.

*  Não trabalharemos com os campos Zs
*  LOOP AT p_i_ti_campos_zs INTO wa_campos_zs.
*
*    CALL METHOD cl_abap_container_utilities=>fill_container_c
*      EXPORTING
*        im_value               = wa_campos_zs
*      IMPORTING
*        ex_container           = lc_valuepart
*      EXCEPTIONS
*        illegal_parameter_type = 1
*        OTHERS                 = 2.
*
**   A estrutura BAPI_TE_NETWORK_ACTIVITY contém a estrutura CI_AFVU
*    wa_prps_ext_in-structure  = 'BAPI_TE_NETWORK_ACTIVITY'.
*    wa_prps_ext_in-valuepart1 = lc_valuepart.
*    APPEND wa_prps_ext_in TO ti_campos_zs.
*
*  ENDLOOP.

  ti_tarefas[] = p_i_ti_tarefas[].

* Separar as tarefas comuns das de serviço
  LOOP AT ti_tarefas INTO wa_tarefa.
    li_tabix = sy-tabix.
    IF wa_tarefa-control_key EQ 'PS04'.
      APPEND wa_tarefa TO ti_tarefas_serv.
      DELETE ti_tarefas INDEX li_tabix.
    ENDIF.
  ENDLOOP.

  IF NOT ti_tarefas[] IS INITIAL.

*   List: Create Network Activities
    CALL FUNCTION 'BAPI_BUS2002_ACT_CREATE_MULTI'
      EXPORTING
        i_number    = p_i_diag_rede
      TABLES
        it_activity = ti_tarefas[]
        et_return   = ti_return[].
*       EXTENSIONIN = ti_campos_zs[].

    APPEND LINES OF ti_return TO ti_return_fim.

    READ TABLE ti_return WITH KEY type = 'E' TRANSPORTING NO FIELDS.
    IF sy-subrc = 0.
      lc_erro = abap_true.
    ENDIF.

  ENDIF.

* Se tudo OK
  IF lc_erro IS INITIAL.

    IF ( NOT ti_tarefas[] IS INITIAL    ) AND
       (     p_i_testrun  EQ abap_false ).

      CALL FUNCTION 'BAPI_PS_PRECOMMIT'
        TABLES
          et_return = ti_return.

      APPEND LINES OF ti_return TO ti_return_fim.

      READ TABLE ti_return WITH KEY type = 'E' TRANSPORTING NO FIELDS.
      IF sy-subrc = 0.
        lc_erro = abap_true.
      ENDIF.

    ENDIF.

*   Se tudo OK
    IF lc_erro IS INITIAL.

      IF ( NOT ti_tarefas[] IS INITIAL ) AND
         (     p_i_testrun  EQ abap_false ).

        CLEAR wa_return.

        CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
          EXPORTING
            wait   = 'X'
          IMPORTING
            return = wa_return.

      ENDIF.

*     Se tudo OK
      IF wa_return IS INITIAL.

        IF NOT ti_tarefas_serv[] IS INITIAL.

          REFRESH ti_return.

*         Criar as tarefas de serviço via SHDB na CN22
          CALL FUNCTION 'ZFPS_SHDB_CN22'
            EXPORTING
              p_i_diag_rede   = p_i_diag_rede
              p_i_ti_tarefas  = ti_tarefas_serv[]
              p_i_ti_servicos = p_i_ti_servicos[]
              p_i_testrun     = p_i_testrun
            IMPORTING
              p_e_ti_return   = ti_return[].

          APPEND LINES OF ti_return TO ti_return_fim.

        ENDIF.

      ELSE.

        APPEND wa_return TO ti_return_fim.

      ENDIF.

    ENDIF.

  ENDIF.

  IF NOT ti_return_fim[] IS INITIAL.
    p_e_ti_return[] = ti_return_fim[].
  ENDIF.

ENDFUNCTION.
