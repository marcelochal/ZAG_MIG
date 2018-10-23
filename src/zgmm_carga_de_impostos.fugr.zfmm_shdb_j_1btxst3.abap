* --------------------------------------------------------------------------*
*                  T A E S A - MIGRAÇÃO - AGIR                              *
* --------------------------------------------------------------------------*
* Consultoria .....: Intechpro                                              *
* ABAP.............: Richard de Aquino Rodrigues                            *
* Funcional........: André Santos                                           *
* Módulo...........: MM                                                     *
* Programa.........: ZFMM_SHDB_J_1BTXST3                                    *
* Transação........:                                                        *
* Tipo de Prg......: FUNÇÃO                                                 *
* Objetivo.........: Criar Cálculo dinâmico de Substituição Tributária      *
* Data.............: 26/09/2018                                             *
* --------------------------------------------------------------------------*
* Request    | Descrição                                                    *
* --------------------------------------------------------------------------*
* S4DK902773 | AGIR - Carga de Dados para Migração - H112 - Impostos        *
* --------------------------------------------------------------------------*

FUNCTION zfmm_shdb_j_1btxst3.
*"----------------------------------------------------------------------
*"*"Interface local:
*"  IMPORTING
*"     REFERENCE(P_I_TI_J_1BTXST3) TYPE  ZTMM_J_1BTXST3
*"     VALUE(P_I_TESTRUN) TYPE  BAPIE1GLOBAL_DATA-TESTRUN OPTIONAL
*"  EXPORTING
*"     REFERENCE(P_E_TI_RETURN) TYPE  BAPIRET2_TAB
*"----------------------------------------------------------------------

  DATA: lc_validfrom  TYPE char10,
        lc_validto    TYPE char10,
        wa_params     TYPE ctu_params,
        wa_j_1btxst3  TYPE j_1btxst3,
        wa_servico    TYPE  zeps_servico,
        ti_bdcdata    TYPE tab_bdcdata,
        ti_return     TYPE bapiret2_tab,
        ti_return_fim TYPE bapiret2_tab,
        ti_msg        TYPE tab_bdcmsgcoll.

*-------------------------------------------------------------------*
*-------------------------------------------------------------------*
* Para cada cálculo dinâmico de Substituição Tributária
  LOOP AT p_i_ti_j_1btxst3 INTO wa_j_1btxst3.

    REFRESH: ti_bdcdata,
             ti_return,
             ti_msg.

*--------------------------------------------------------------*
    CALL FUNCTION 'CONVERSION_EXIT_INVDT_OUTPUT'
      EXPORTING
        input  = wa_j_1btxst3-validfrom
      IMPORTING
        output = lc_validfrom.

    CALL FUNCTION 'CONVERSION_EXIT_INVDT_OUTPUT'
      EXPORTING
        input  = wa_j_1btxst3-validto
      IMPORTING
        output = lc_validto.

*---------------------------------------------------------------------*
    PERFORM: z_fill_bdc USING 'X' 'SAPMSVMA' '0100'
                        CHANGING ti_bdcdata,
             z_fill_bdc USING ' ' 'BDC_CURSOR' 'VIEWNAME'
                        CHANGING ti_bdcdata,
             z_fill_bdc USING ' ' 'BDC_OKCODE' '=UPD'
                        CHANGING ti_bdcdata,
             z_fill_bdc USING ' ' 'VIEWNAME' 'J_1BTXST3'
                        CHANGING ti_bdcdata,
             z_fill_bdc USING ' ' 'VIMDYNFLDS-LTD_DTA_NO' 'X'
                        CHANGING ti_bdcdata.

*---------------------------------------------------------------------*
    PERFORM: z_fill_bdc USING 'X' 'SAPLJ1BW' '0008'
                        CHANGING ti_bdcdata,
             z_fill_bdc USING ' ' 'BDC_CURSOR' 'J_1BTXST3-VALIDTO(01)'
                        CHANGING ti_bdcdata,
             z_fill_bdc USING ' ' 'BDC_OKCODE' '=NEWL'
                        CHANGING ti_bdcdata.

*---------------------------------------------------------------------*
    PERFORM: z_fill_bdc USING 'X' 'SAPLJ1B0' '0003'
                        CHANGING ti_bdcdata,
             z_fill_bdc USING ' ' 'BDC_CURSOR' 'J_1BTXST2-SHIPFROM'
                        CHANGING ti_bdcdata,
             z_fill_bdc USING ' ' 'BDC_OKCODE' '/00'
                        CHANGING ti_bdcdata,
             z_fill_bdc USING ' ' 'J_1BTXST3-LAND1(01)'      wa_j_1btxst3-land1
                        CHANGING ti_bdcdata,
             z_fill_bdc USING ' ' 'J_1BTXST3-SHIPFROM(01)'   wa_j_1btxst3-shipfrom
                        CHANGING ti_bdcdata,
             z_fill_bdc USING ' ' 'J_1BTXST3-SHIPTO(01)'     wa_j_1btxst3-shipto
                        CHANGING ti_bdcdata,
             z_fill_bdc USING ' ' 'J_1BTXST3-GRUOP'          wa_j_1btxst3-gruop
                        CHANGING ti_bdcdata,
             z_fill_bdc USING ' ' 'J_1BTXST3-VALUE'          wa_j_1btxst3-value
                        CHANGING ti_bdcdata,
             z_fill_bdc USING ' ' 'J_1BTXST3-VALIDFROM(01)'  lc_validfrom
                        CHANGING ti_bdcdata,
             z_fill_bdc USING ' ' 'J_1BTXST3-VALIDTO(01)'    lc_validto
                        CHANGING ti_bdcdata,
             z_fill_bdc USING ' ' 'J_1BTXST3-SUR_TYPE'       wa_j_1btxst3-sur_type
                        CHANGING ti_bdcdata,
             z_fill_bdc USING ' ' 'J_1BTXST3-RATE'           wa_j_1btxst3-rate
                        CHANGING ti_bdcdata,
             z_fill_bdc USING ' ' 'J_1BTXST3-PRICE'          wa_j_1btxst3-price
                        CHANGING ti_bdcdata,
             z_fill_bdc USING ' ' 'J_1BTXST3-MINPRICE'       wa_j_1btxst3-minprice
                        CHANGING ti_bdcdata,
             z_fill_bdc USING ' ' 'J_1BTXST3-FACTOR'         wa_j_1btxst3-factor
                        CHANGING ti_bdcdata,
             z_fill_bdc USING ' ' 'J_1BTXST3-BASERED1'       wa_j_1btxst3-basered1
                        CHANGING ti_bdcdata,
             z_fill_bdc USING ' ' 'J_1BTXST3-FCP_BASERED1'   wa_j_1btxst3-fcp_basered1
                        CHANGING ti_bdcdata,
             z_fill_bdc USING ' ' 'J_1BTXST3-BASERED2'       wa_j_1btxst3-basered2
                        CHANGING ti_bdcdata,
             z_fill_bdc USING ' ' 'J_1BTXST3-FCP_BASERED2'   wa_j_1btxst3-fcp_basered2
                        CHANGING ti_bdcdata,
             z_fill_bdc USING ' ' 'J_1BTXST3-ICMSBASER'      wa_j_1btxst3-icmsbaser
                        CHANGING ti_bdcdata.

*---------------------------------------------------------------------*
    PERFORM: z_fill_bdc USING 'X' 'SAPLJ1BW' '0008'
                        CHANGING ti_bdcdata,
             z_fill_bdc USING ' ' 'BDC_CURSOR' 'J_1BTXST3-VALIDTO(01)'
                        CHANGING ti_bdcdata,
             z_fill_bdc USING ' ' 'BDC_OKCODE' '=SAVE'
                        CHANGING ti_bdcdata.

*---------------------------------------------------------------------*
    PERFORM: z_fill_bdc USING 'X' 'SAPLJ1BW' '0008'
                        CHANGING ti_bdcdata,
             z_fill_bdc USING ' ' 'BDC_CURSOR' 'J_1BTXST3-VALIDTO(01)'
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
