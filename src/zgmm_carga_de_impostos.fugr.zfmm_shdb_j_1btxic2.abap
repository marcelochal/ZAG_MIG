* --------------------------------------------------------------------------*
*                  T A E S A - MIGRAÇÃO - AGIR                              *
* --------------------------------------------------------------------------*
* Consultoria .....: Intechpro                                              *
* ABAP.............: Richard de Aquino Rodrigues                            *
* Funcional........: André Santos                                           *
* Módulo...........: MM                                                     *
* Programa.........: ZFMM_SHDB_J_1BTXIC2                                    *
* Transação........:                                                        *
* Tipo de Prg......: FUNÇÃO                                                 *
* Objetivo.........: Criar regras ICMS                                      *
* Data.............: 26/09/2018                                             *
* --------------------------------------------------------------------------*
* Request    | Descrição                                                    *
* --------------------------------------------------------------------------*
* S4DK902773 | AGIR - Carga de Dados para Migração - H112 - Impostos        *
* --------------------------------------------------------------------------*

FUNCTION zfmm_shdb_j_1btxic2.
*"----------------------------------------------------------------------
*"*"Interface local:
*"  IMPORTING
*"     REFERENCE(P_I_TI_J_1BTXIC2) TYPE  ZTMM_J_1BTXIC2
*"     VALUE(P_I_TESTRUN) TYPE  BAPIE1GLOBAL_DATA-TESTRUN OPTIONAL
*"  EXPORTING
*"     REFERENCE(P_E_TI_RETURN) TYPE  BAPIRET2_TAB
*"----------------------------------------------------------------------

  DATA: lc_validfrom  TYPE char10,
        lc_validto    TYPE char10,
        wa_params     TYPE ctu_params,
        wa_j_1btxic2  TYPE j_1btxic2,
        wa_servico    TYPE  zeps_servico,
        ti_bdcdata    TYPE tab_bdcdata,
        ti_return     TYPE bapiret2_tab,
        ti_return_fim TYPE bapiret2_tab,
        ti_msg        TYPE tab_bdcmsgcoll.

*-------------------------------------------------------------------*
*-------------------------------------------------------------------*
* Para cada regra ICMS
  LOOP AT p_i_ti_j_1btxic2 INTO wa_j_1btxic2.

    REFRESH: ti_bdcdata,
             ti_return,
             ti_msg.

*--------------------------------------------------------------*
    CALL FUNCTION 'CONVERSION_EXIT_INVDT_OUTPUT'
      EXPORTING
        input  = wa_j_1btxic2-validfrom
      IMPORTING
        output = lc_validfrom.

    CALL FUNCTION 'CONVERSION_EXIT_INVDT_OUTPUT'
      EXPORTING
        input  = wa_j_1btxic2-validto
      IMPORTING
        output = lc_validto.

*---------------------------------------------------------------------*
    PERFORM: z_fill_bdc USING 'X' 'SAPMSVMA' '0100'
                        CHANGING ti_bdcdata,
             z_fill_bdc USING ' ' 'BDC_CURSOR' 'VIEWNAME'
                        CHANGING ti_bdcdata,
             z_fill_bdc USING ' ' 'BDC_OKCODE' '=UPD'
                        CHANGING ti_bdcdata,
             z_fill_bdc USING ' ' 'VIEWNAME' 'J_1BTXIC2'
                        CHANGING ti_bdcdata,
             z_fill_bdc USING ' ' 'VIMDYNFLDS-LTD_DTA_NO' 'X'
                        CHANGING ti_bdcdata.

*---------------------------------------------------------------------*
    PERFORM: z_fill_bdc USING 'X' 'SAPLJ1BQ' '0003'
                        CHANGING ti_bdcdata,
             z_fill_bdc USING ' ' 'BDC_CURSOR' 'J_1BTXIC2-SPECF_RATE(01)'
                        CHANGING ti_bdcdata,
             z_fill_bdc USING ' ' 'BDC_OKCODE' '=NEWL'
                        CHANGING ti_bdcdata.

*---------------------------------------------------------------------*
    PERFORM: z_fill_bdc USING 'X' 'SAPLJ1BQ' '0003'
                        CHANGING ti_bdcdata,
             z_fill_bdc USING ' ' 'BDC_CURSOR' 'J_1BTXIC2-SPECF_BASE(01)'
                        CHANGING ti_bdcdata,
             z_fill_bdc USING ' ' 'BDC_OKCODE' '/00'
                        CHANGING ti_bdcdata,
             z_fill_bdc USING ' ' 'J_1BTXIC2-SPECF_RATE(01)' wa_j_1btxic2-specf_rate
                        CHANGING ti_bdcdata,
             z_fill_bdc USING ' ' 'J_1BTXIC2-SPECF_BASE(01)' wa_j_1btxic2-specf_base
                        CHANGING ti_bdcdata,
             z_fill_bdc USING ' ' 'J_1BTXIC2-LAND1(01)'      wa_j_1btxic2-land1
                        CHANGING ti_bdcdata,
             z_fill_bdc USING ' ' 'J_1BTXIC2-SHIPFROM(01)'   wa_j_1btxic2-shipfrom
                        CHANGING ti_bdcdata,
             z_fill_bdc USING ' ' 'J_1BTXIC2-SHIPTO(01)'     wa_j_1btxic2-shipto
                        CHANGING ti_bdcdata,
             z_fill_bdc USING ' ' 'J_1BTXIC2-MATNR(01)'      wa_j_1btxic2-matnr
                        CHANGING ti_bdcdata,
             z_fill_bdc USING ' ' 'J_1BTXIC2-VALIDFROM(01)'  lc_validfrom
                        CHANGING ti_bdcdata,
             z_fill_bdc USING ' ' 'J_1BTXIC2-VALIDTO(01)'    lc_validto
                        CHANGING ti_bdcdata,
             z_fill_bdc USING ' ' 'J_1BTXIC2-RATE(01)'       wa_j_1btxic2-rate
                        CHANGING ti_bdcdata,
             z_fill_bdc USING ' ' 'J_1BTXIC2-BASE(01)'       wa_j_1btxic2-base
                        CHANGING ti_bdcdata,
             z_fill_bdc USING ' ' 'J_1BTXIC2-TAXLAW(01)'     wa_j_1btxic2-taxlaw
                        CHANGING ti_bdcdata.

*---------------------------------------------------------------------*
    PERFORM: z_fill_bdc USING 'X' 'SAPLJ1BQ' '0003'
                        CHANGING ti_bdcdata,
             z_fill_bdc USING ' ' 'BDC_CURSOR' 'J_1BTXIC2-LAND1(02)'
                        CHANGING ti_bdcdata,
             z_fill_bdc USING ' ' 'BDC_OKCODE' '=BACK'
                        CHANGING ti_bdcdata.

*---------------------------------------------------------------------*
    PERFORM: z_fill_bdc USING 'X' 'SAPLJ1BQ' '0003'
                        CHANGING ti_bdcdata,
             z_fill_bdc USING ' ' 'BDC_CURSOR' 'J_1BTXIC2-LAND1(02)'
                        CHANGING ti_bdcdata,
             z_fill_bdc USING ' ' 'BDC_OKCODE' '=SAVE'
                        CHANGING ti_bdcdata.

*---------------------------------------------------------------------*
    PERFORM: z_fill_bdc USING 'X' 'SAPLJ1BQ' '0003'
                        CHANGING ti_bdcdata,
             z_fill_bdc USING ' ' 'BDC_CURSOR' 'J_1BTXIC2 -LAND1(02)'
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
