* --------------------------------------------------------------------------*
*                  T A E S A - MIGRAÇÃO - AGIR                              *
* --------------------------------------------------------------------------*
* Consultoria .....: Intechpro                                              *
* ABAP.............: Richard de Aquino Rodrigues                            *
* Funcional........: André Santos                                           *
* Módulo...........: MM                                                     *
* Programa.........: ZFMM_SHDB_J_1BTXIP1                                    *
* Transação........:                                                        *
* Tipo de Prg......: FUNÇÃO                                                 *
* Objetivo.........: Criar regras IPI                                       *
* Data.............: 25/09/2018                                             *
* --------------------------------------------------------------------------*
* Request    | Descrição                                                    *
* --------------------------------------------------------------------------*
* S4DK902773 | AGIR - Carga de Dados para Migração - H112 - Impostos        *
* --------------------------------------------------------------------------*

FUNCTION zfmm_shdb_j_1btxip1.
*"----------------------------------------------------------------------
*"*"Interface local:
*"  IMPORTING
*"     REFERENCE(P_I_TI_J_1BTXIP1) TYPE  ZTMM_J_1BTXIP1
*"     VALUE(P_I_TESTRUN) TYPE  BAPIE1GLOBAL_DATA-TESTRUN OPTIONAL
*"  EXPORTING
*"     REFERENCE(P_E_TI_RETURN) TYPE  BAPIRET2_TAB
*"----------------------------------------------------------------------

  DATA: lc_validfrom  TYPE char10,
        wa_params     TYPE ctu_params,
        wa_j_1btxip1  TYPE j_1btxip1,
        wa_servico    TYPE  zeps_servico,
        ti_bdcdata    TYPE tab_bdcdata,
        ti_return     TYPE bapiret2_tab,
        ti_return_fim TYPE bapiret2_tab,
        ti_msg        TYPE tab_bdcmsgcoll.

*-------------------------------------------------------------------*
*-------------------------------------------------------------------*
* Para cada regra IPI
  LOOP AT p_i_ti_j_1btxip1 INTO wa_j_1btxip1.

    REFRESH: ti_bdcdata,
             ti_return,
             ti_msg.

*--------------------------------------------------------------*
    CALL FUNCTION 'CONVERSION_EXIT_INVDT_OUTPUT'
      EXPORTING
        input  = wa_j_1btxip1-validfrom
      IMPORTING
        output = lc_validfrom.

*---------------------------------------------------------------------*
    PERFORM: z_fill_bdc USING 'X' 'SAPMSVMA' '0100'
                        CHANGING ti_bdcdata,
             z_fill_bdc USING ' ' 'BDC_CURSOR' 'VIEWNAME'
                        CHANGING ti_bdcdata,
             z_fill_bdc USING ' ' 'BDC_OKCODE' '=UPD'
                        CHANGING ti_bdcdata,
             z_fill_bdc USING ' ' 'VIEWNAME' 'J_1BTXDEF'
                        CHANGING ti_bdcdata,
             z_fill_bdc USING ' ' 'VIMDYNFLDS-LTD_DTA_NO' 'X'
                        CHANGING ti_bdcdata.

*---------------------------------------------------------------------*
    PERFORM: z_fill_bdc USING 'X' 'SAPLJ1BQ' '0007'
                        CHANGING ti_bdcdata,
             z_fill_bdc USING ' ' 'BDC_CURSOR' 'J_1BTXIP1-WAERS(01)'
                        CHANGING ti_bdcdata,
             z_fill_bdc USING ' ' 'BDC_OKCODE' '=NEWL'
                        CHANGING ti_bdcdata.

*---------------------------------------------------------------------*
    PERFORM: z_fill_bdc USING 'X' 'SAPLJ1BQ' '0007'
                        CHANGING ti_bdcdata,
             z_fill_bdc USING ' ' 'BDC_CURSOR' 'J_1BTXIP1-WAERS(01)'
                        CHANGING ti_bdcdata,
             z_fill_bdc USING ' ' 'BDC_OKCODE' '/00'
                        CHANGING ti_bdcdata,
             z_fill_bdc USING ' ' 'J_1BTXIP1-WAERS(01)'     wa_j_1btxip1-waers
                        CHANGING ti_bdcdata,
             z_fill_bdc USING ' ' 'J_1BTXIP1-NBMCODE(01)'   wa_j_1btxip1-nbmcode
                        CHANGING ti_bdcdata,
             z_fill_bdc USING ' ' 'J_1BTXIP1-VALIDFROM(01)' lc_validfrom
                        CHANGING ti_bdcdata,
             z_fill_bdc USING ' ' 'J_1BTXIP1-RATE(01)'      wa_j_1btxip1-rate
                        CHANGING ti_bdcdata,
             z_fill_bdc USING ' ' 'J_1BTXIP1-BASE(01)'      wa_j_1btxip1-base
                        CHANGING ti_bdcdata.

*---------------------------------------------------------------------*
    PERFORM: z_fill_bdc USING 'X' 'SAPLJ1BQ' '0005'
                        CHANGING ti_bdcdata,
             z_fill_bdc USING ' ' 'BDC_CURSOR' 'J_1BTXDEF-TAX(02)'
                        CHANGING ti_bdcdata,
             z_fill_bdc USING ' ' 'BDC_OKCODE' '=BACK'
                        CHANGING ti_bdcdata.

*---------------------------------------------------------------------*
    PERFORM: z_fill_bdc USING 'X' 'SAPLJ1BQ' '0007'
                        CHANGING ti_bdcdata,
             z_fill_bdc USING ' ' 'BDC_CURSOR' 'J_1BTXIP1-NBMCODE(02)'
                        CHANGING ti_bdcdata,
             z_fill_bdc USING ' ' 'BDC_OKCODE' '=SAVE'
                        CHANGING ti_bdcdata.

*---------------------------------------------------------------------*
    PERFORM: z_fill_bdc USING 'X' 'SAPLJ1BQ' '0007'
                        CHANGING ti_bdcdata,
             z_fill_bdc USING ' ' 'BDC_CURSOR' 'J_1BTXIP1-NBMCODE(02)'
                        CHANGING ti_bdcdata,
             z_fill_bdc USING ' ' 'BDC_OKCODE' '=BACK'
                        CHANGING ti_bdcdata.

*---------------------------------------------------------------------*
    PERFORM: z_fill_bdc USING 'X' 'SAPLJ1BQ' '0007'
                        CHANGING ti_bdcdata,
             z_fill_bdc USING ' ' 'BDC_CURSOR' 'J_1BTXIP1-NBMCODE(02)'
                        CHANGING ti_bdcdata,
             z_fill_bdc USING ' ' 'BDC_OKCODE' '=BACK'
                        CHANGING ti_bdcdata.

*---------------------------------------------------------------------*
    PERFORM: z_fill_bdc USING 'X' 'SAPMSVMA' '0100'
                        CHANGING ti_bdcdata,
             z_fill_bdc USING ' ' 'BDC_CURSOR' 'VIEWNAME'
                        CHANGING ti_bdcdata,
             z_fill_bdc USING ' ' 'BDC_OKCODE' '/EBACK'
                        CHANGING ti_bdcdata.

*   Modo de processamento para CALL TRANSACTION USING...
    wa_params-dismode = 'N'. "Processar em background

*   Modo de atualização para CALL TRANSACTION USING...
    wa_params-updmode = 'S'. "Síncrono

*   Tamanho standard de tela para CALL TRANSACTION USING...
    wa_params-defsize = 'X'. "Sim

*   Se for execução valendo.
    IF p_i_testrun IS INITIAL.
      wa_params-racommit = 'X'.
    ELSE.
      wa_params-racommit = ' '.
    ENDIF.

    CALL TRANSACTION 'SM30' USING ti_bdcdata
                            OPTIONS FROM wa_params
                            MESSAGES INTO ti_msg[].

    PERFORM z_fill_message USING    ti_msg
                           CHANGING ti_return.

    APPEND LINES OF ti_return TO ti_return_fim.

  ENDLOOP.

*---------------------------------------------------------------------*
  IF NOT ti_return_fim[] IS INITIAL.
    p_e_ti_return[] = ti_return_fim[].
  ENDIF.

ENDFUNCTION.
