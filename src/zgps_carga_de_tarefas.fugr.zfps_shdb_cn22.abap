* --------------------------------------------------------------------------*
*                  T A E S A - MIGRAÇÃO - AGIR                              *
* --------------------------------------------------------------------------*
* Consultoria .....: Intechpro                                              *
* ABAP.............: Richard de Aquino Rodrigues                            *
* Funcional........: André Santos                                           *
* Módulo...........: PS                                                     *
* Programa.........: ZFPS_SHDB_CN22                                         *
* Transação........:                                                        *
* Tipo de Prg......: FUNÇÃO                                                 *
* Objetivo.........: Criar as tarefas de serviço via SHDB na CN22           *
* Data.............: 24/09/2018                                             *
* --------------------------------------------------------------------------*
* Request    | Descrição                                                    *
* --------------------------------------------------------------------------*
* S4DK902284 | AGIR - Carga de Dados para Migração - HXXX - Tarefa          *
* --------------------------------------------------------------------------*

FUNCTION zfps_shdb_cn22.
*"----------------------------------------------------------------------
*"*"Interface local:
*"  IMPORTING
*"     REFERENCE(P_I_DIAG_REDE) TYPE  NW_AUFNR
*"     REFERENCE(P_I_TI_TAREFAS) TYPE  ZTPS_BAPI_BUS2002_ACT_NEW
*"     REFERENCE(P_I_TI_SERVICOS) TYPE  ZTPS_SERVICOS
*"     VALUE(P_I_TESTRUN) TYPE  BAPIE1GLOBAL_DATA-TESTRUN OPTIONAL
*"  EXPORTING
*"     REFERENCE(P_E_TI_RETURN) TYPE  BAPIRET2_TAB
*"----------------------------------------------------------------------

  DATA: wa_params  TYPE ctu_params,
        wa_tarefa  TYPE bapi_bus2002_act_new,
        wa_servico TYPE	zeps_servico,
        ti_bdcdata TYPE tab_bdcdata,
        ti_return  TYPE bapiret2_tab,
        ti_msg     TYPE tab_bdcmsgcoll.

*-------------------------------------------------------------------*
*-------------------------------------------------------------------*
* Para cada Tarefa de Serviço
  LOOP AT p_i_ti_tarefas INTO wa_tarefa WHERE control_key EQ 'PS04'.

*---------------------------------------------------------------------*
    PERFORM: z_fill_bdc USING 'X' 'SAPLCOKO' '2000'
                        CHANGING ti_bdcdata,
             z_fill_bdc USING ' ' 'BDC_CURSOR' 'CAUFVD-AUFNR'
                        CHANGING ti_bdcdata,
             z_fill_bdc USING ' ' 'BDC_OKCODE' '=LIST'
                        CHANGING ti_bdcdata,
             z_fill_bdc USING ' ' 'CAUFVD-AUFNR' p_i_diag_rede
                        CHANGING ti_bdcdata.

*---------------------------------------------------------------------*
    PERFORM: z_fill_bdc USING 'X' 'SAPLCOVG' '2000'
                        CHANGING ti_bdcdata,
             z_fill_bdc USING ' ' 'BDC_OKCODE' '=FRML'
                        CHANGING ti_bdcdata,
             z_fill_bdc USING ' ' 'BDC_CURSOR' 'AFVGD-VORNR(01)'
                        CHANGING ti_bdcdata.

*---------------------------------------------------------------------*
    PERFORM: z_fill_bdc USING 'X' 'SAPLCOVG' '2000'
                        CHANGING ti_bdcdata,
             z_fill_bdc USING ' ' 'BDC_OKCODE' '=EINF'
                        CHANGING ti_bdcdata,
             z_fill_bdc USING ' ' 'BDC_CURSOR' 'AFVGD-VORNR(01)'
                        CHANGING ti_bdcdata.

*---------------------------------------------------------------------*
    PERFORM: z_fill_bdc USING 'X' 'SAPLCOVG' '2000'
                        CHANGING ti_bdcdata,
             z_fill_bdc USING ' ' 'BDC_OKCODE' '/00'
                        CHANGING ti_bdcdata,
             z_fill_bdc USING ' ' 'BDC_CURSOR' 'RC27X-FLG_SERV(01)'
                        CHANGING ti_bdcdata,
             z_fill_bdc USING ' ' 'AFVGD-VORNR(01)' wa_tarefa-activity
                        CHANGING ti_bdcdata,
             z_fill_bdc USING ' ' 'RC27X-FLG_SERV(01)' 'X'
                        CHANGING ti_bdcdata,
             z_fill_bdc USING ' ' 'AFVGD-LTXA1(01)' wa_tarefa-description
                        CHANGING ti_bdcdata.

*---------------------------------------------------------------------*
    PERFORM: z_fill_bdc USING 'X' 'SAPLMLSP' '0200'
                        CHANGING ti_bdcdata,
             z_fill_bdc USING ' ' 'BDC_OKCODE' '=BZE'
                        CHANGING ti_bdcdata,
             z_fill_bdc USING ' ' 'BDC_CURSOR' 'ESLL-KTEXT1(01)'
                        CHANGING ti_bdcdata,
             z_fill_bdc USING ' ' 'RM11P-NEW_ROW' '10'
                        CHANGING ti_bdcdata.

*---------------------------------------------------------------------*
*   Podemos criar vários Serviços para cada Tarefa de Serviço.
    LOOP AT p_i_ti_servicos INTO wa_servico.

      PERFORM: z_fill_bdc USING 'X' 'SAPLMLSP' '0200'
                          CHANGING ti_bdcdata,
               z_fill_bdc USING ' ' 'BDC_OKCODE' '/00'
                          CHANGING ti_bdcdata,
               z_fill_bdc USING ' ' 'BDC_CURSOR' 'ESLL-KSTAR(01)'
                          CHANGING ti_bdcdata,
               z_fill_bdc USING ' ' 'RM11P-NEW_ROW' '  '
                          CHANGING ti_bdcdata,
               z_fill_bdc USING ' ' 'ESLL-EXTROW(01)' wa_servico-extrow
                          CHANGING ti_bdcdata,
               z_fill_bdc USING ' ' 'ESLL-SRVPOS(01)' wa_servico-srvpos
                          CHANGING ti_bdcdata,
               z_fill_bdc USING ' ' 'ESLL-MENGE(01)'  wa_servico-menge
                          CHANGING ti_bdcdata,
               z_fill_bdc USING ' ' 'ESLL-TBTWR(01)'  wa_servico-tbtwr
                          CHANGING ti_bdcdata,
               z_fill_bdc USING ' ' 'ESLL-KSTAR(01)'  wa_servico-kstar
                          CHANGING ti_bdcdata.

      PERFORM: z_fill_bdc USING 'X' 'SAPLMLSP' '0200'
                          CHANGING ti_bdcdata,
               z_fill_bdc USING ' ' 'BDC_OKCODE' '=ESB'
                          CHANGING ti_bdcdata,
               z_fill_bdc USING ' ' 'BDC_CURSOR' 'ESLL-KTEXT1(01)'
                          CHANGING ti_bdcdata,
               z_fill_bdc USING ' ' 'RM11P-NEW_ROW'   wa_servico-extrow
                          CHANGING ti_bdcdata.

    ENDLOOP.

*---------------------------------------------------------------------*
    PERFORM: z_fill_bdc USING 'X' 'SAPLCOVG' '2000'
                        CHANGING ti_bdcdata,
             z_fill_bdc USING ' ' 'BDC_OKCODE' '=BU'
                        CHANGING ti_bdcdata,
             z_fill_bdc USING ' ' 'BDC_CURSOR' 'RC27X-FLG_SERV(01)'
                        CHANGING ti_bdcdata.

  ENDLOOP.

* Modo de processamento para CALL TRANSACTION USING...
  wa_params-dismode = 'N'. "Processar em background

* Modo de atualização para CALL TRANSACTION USING...
  wa_params-updmode = 'S'. "Síncrono

* Tamanho standard de tela para CALL TRANSACTION USING...
  wa_params-defsize = 'X'. "Sim

* Se for execução valendo.
  IF p_i_testrun IS INITIAL.
    wa_params-racommit = 'X'.
  ELSE.
    wa_params-racommit = ' '.
  ENDIF.

  CALL TRANSACTION 'CN22' USING ti_bdcdata
                          OPTIONS FROM wa_params
                          MESSAGES INTO ti_msg[].

  PERFORM z_fill_message USING    ti_msg
                         CHANGING ti_return.

  IF NOT ti_return[] IS INITIAL.
    p_e_ti_return[] = ti_return[].
  ENDIF.

ENDFUNCTION.
