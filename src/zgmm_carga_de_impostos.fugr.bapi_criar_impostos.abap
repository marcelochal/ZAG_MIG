* --------------------------------------------------------------------------*
*                  T A E S A - MIGRAÇÃO - AGIR                              *
* --------------------------------------------------------------------------*
* Consultoria .....: Intechpro                                              *
* ABAP.............: Richard de Aquino Rodrigues                            *
* Funcional........: André Santos                                           *
* Módulo...........: MM                                                     *
* Programa.........: BAPI_CRIAR_IMPOSTOS                                    *
* Transação........:                                                        *
* Tipo de Prg......: FUNÇÃO                                                 *
* Objetivo.........: Criar Impostos                                         *
* Data.............: 25/09/2018                                             *
* --------------------------------------------------------------------------*
* Request    | Descrição                                                    *
* --------------------------------------------------------------------------*
* S4DK902773 | AGIR - Carga de Dados para Migração - H112 - Impostos        *
* --------------------------------------------------------------------------*

FUNCTION bapi_criar_impostos.
*"----------------------------------------------------------------------
*"*"Interface local:
*"  IMPORTING
*"     REFERENCE(P_I_TI_J_1BTXDEF) TYPE  ZTMM_J_1BTXDEF OPTIONAL
*"     REFERENCE(P_I_TI_J_1BTXIP1) TYPE  ZTMM_J_1BTXIP1 OPTIONAL
*"     REFERENCE(P_I_TI_J_1BTXIP2) TYPE  ZTMM_J_1BTXIP2 OPTIONAL
*"     REFERENCE(P_I_TI_J_1BTXIP3) TYPE  ZTMM_J_1BTXIP3 OPTIONAL
*"     REFERENCE(P_I_TI_J_1BTXIC1) TYPE  ZTMM_J_1BTXIC1 OPTIONAL
*"     REFERENCE(P_I_TI_J_1BTXIC2) TYPE  ZTMM_J_1BTXIC2 OPTIONAL
*"     REFERENCE(P_I_TI_J_1BTXIC3) TYPE  ZTMM_J_1BTXIC3 OPTIONAL
*"     REFERENCE(P_I_TI_J_1BTXCI1) TYPE  ZTMM_J_1BTXCI1 OPTIONAL
*"     REFERENCE(P_I_TI_J_1BTXST2) TYPE  ZTMM_J_1BTXST2 OPTIONAL
*"     REFERENCE(P_I_TI_J_1BTXST1) TYPE  ZTMM_J_1BTXST1 OPTIONAL
*"     REFERENCE(P_I_TI_J_1BTXST3) TYPE  ZTMM_J_1BTXST3 OPTIONAL
*"     VALUE(P_I_TESTRUN) TYPE  BAPIE1GLOBAL_DATA-TESTRUN OPTIONAL
*"  EXPORTING
*"     REFERENCE(P_E_TI_RETURN) TYPE  BAPIRET2_TAB
*"----------------------------------------------------------------------

  DATA:
    ti_return     TYPE bapiret2_tab,
    ti_return_fim TYPE bapiret2_tab.

*-------------------------------------------------------------------*
*-------------------------------------------------------------------*
  IF NOT p_i_ti_j_1btxdef[] IS INITIAL.

*   Criar taxas default
    CALL FUNCTION 'ZFMM_SHDB_J_1BTXDEF'
      EXPORTING
        p_i_ti_j_1btxdef = p_i_ti_j_1btxdef[]
        p_i_testrun      = p_i_testrun
      IMPORTING
        p_e_ti_return    = ti_return[].

    APPEND LINES OF ti_return TO ti_return_fim.

  ENDIF.

*-------------------------------------------------------------------*
  IF NOT p_i_ti_j_1btxip1[] IS INITIAL.

*   Criar regras IPI
    CALL FUNCTION 'ZFMM_SHDB_J_1BTXIP1'
      EXPORTING
        p_i_ti_j_1btxip1 = p_i_ti_j_1btxip1[]
        p_i_testrun      = p_i_testrun
      IMPORTING
        p_e_ti_return    = ti_return[].

    APPEND LINES OF ti_return TO ti_return_fim.

  ENDIF.

*-------------------------------------------------------------------*
  IF NOT p_i_ti_j_1btxip2[] IS INITIAL.

*   Criar regras IPI (dep.do material)
    CALL FUNCTION 'ZFMM_SHDB_J_1BTXIP2'
      EXPORTING
        p_i_ti_j_1btxip2 = p_i_ti_j_1btxip2[]
        p_i_testrun      = p_i_testrun
      IMPORTING
        p_e_ti_return    = ti_return[].

    APPEND LINES OF ti_return TO ti_return_fim.

  ENDIF.

*-------------------------------------------------------------------*
  IF NOT p_i_ti_j_1btxip3[] IS INITIAL.

*   Criar IPI agrupado
    CALL FUNCTION 'ZFMM_SHDB_J_1BTXIP3'
      EXPORTING
        p_i_ti_j_1btxip3 = p_i_ti_j_1btxip3[]
        p_i_testrun      = p_i_testrun
      IMPORTING
        p_e_ti_return    = ti_return[].

    APPEND LINES OF ti_return TO ti_return_fim.

  ENDIF.

*-------------------------------------------------------------------*
  IF NOT p_i_ti_j_1btxic1[] IS INITIAL.

*   Criar regulamentos gerais ICMS
    CALL FUNCTION 'ZFMM_SHDB_J_1BTXIC1'
      EXPORTING
        p_i_ti_j_1btxic1 = p_i_ti_j_1btxic1[]
        p_i_testrun      = p_i_testrun
      IMPORTING
        p_e_ti_return    = ti_return[].

    APPEND LINES OF ti_return TO ti_return_fim.

  ENDIF.

*-------------------------------------------------------------------*
  IF NOT p_i_ti_j_1btxic2[] IS INITIAL.

*   Criar regras ICMS
    CALL FUNCTION 'ZFMM_SHDB_J_1BTXIC2'
      EXPORTING
        p_i_ti_j_1btxic2 = p_i_ti_j_1btxic2[]
        p_i_testrun      = p_i_testrun
      IMPORTING
        p_e_ti_return    = ti_return[].

    APPEND LINES OF ti_return TO ti_return_fim.

  ENDIF.

*-------------------------------------------------------------------*
  IF NOT p_i_ti_j_1btxic3[] IS INITIAL.

*   Criar ICMS agrupado
    CALL FUNCTION 'ZFMM_SHDB_J_1BTXIC3'
      EXPORTING
        p_i_ti_j_1btxic3 = p_i_ti_j_1btxic3[]
        p_i_testrun      = p_i_testrun
      IMPORTING
        p_e_ti_return    = ti_return[].

    APPEND LINES OF ti_return TO ti_return_fim.

  ENDIF.

*-------------------------------------------------------------------*
  IF NOT p_i_ti_j_1btxci1[] IS INITIAL.

*   Criar Complemento de regras ICMS
    CALL FUNCTION 'ZFMM_SHDB_J_1BTXCI1'
      EXPORTING
        p_i_ti_j_1btxci1 = p_i_ti_j_1btxci1[]
        p_i_testrun      = p_i_testrun
      IMPORTING
        p_e_ti_return    = ti_return[].

    APPEND LINES OF ti_return TO ti_return_fim.

  ENDIF.

*-------------------------------------------------------------------*
  IF NOT p_i_ti_j_1btxst2[] IS INITIAL.

*   Criar regras sub.tributária (geral)
    CALL FUNCTION 'ZFMM_SHDB_J_1BTXST2'
      EXPORTING
        p_i_ti_j_1btxst2 = p_i_ti_j_1btxst2[]
        p_i_testrun      = p_i_testrun
      IMPORTING
        p_e_ti_return    = ti_return[].

    APPEND LINES OF ti_return TO ti_return_fim.

  ENDIF.

*-------------------------------------------------------------------*
  IF NOT p_i_ti_j_1btxst1[] IS INITIAL.

*   Criar regulamentos de sub.trib.
    CALL FUNCTION 'ZFMM_SHDB_J_1BTXST1'
      EXPORTING
        p_i_ti_j_1btxst1 = p_i_ti_j_1btxst1[]
        p_i_testrun      = p_i_testrun
      IMPORTING
        p_e_ti_return    = ti_return[].

    APPEND LINES OF ti_return TO ti_return_fim.

  ENDIF.

*-------------------------------------------------------------------*
  IF NOT p_i_ti_j_1btxst3[] IS INITIAL.

*   Criar Cálculo dinâmico de Substituição Tributária
    CALL FUNCTION 'ZFMM_SHDB_J_1BTXST3'
      EXPORTING
        p_i_ti_j_1btxst3 = p_i_ti_j_1btxst3[]
        p_i_testrun      = p_i_testrun
      IMPORTING
        p_e_ti_return    = ti_return[].

    APPEND LINES OF ti_return TO ti_return_fim.

  ENDIF.

*-------------------------------------------------------------------*
  IF NOT ti_return_fim[] IS INITIAL.
    p_e_ti_return[] = ti_return_fim[].
  ENDIF.

ENDFUNCTION.
