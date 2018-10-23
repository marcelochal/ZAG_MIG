* --------------------------------------------------------------------------*
*                  T A E S A - MIGRAÇÃO - AGIR                              *
* --------------------------------------------------------------------------*
* Consultoria .....: Intechpro                                              *
* ABAP.............: Richard de Aquino Rodrigues                            *
* Funcional........: André Santos                                           *
* Módulo...........: PS                                                     *
* Programa.........: BAPI_CRIAR_PEPS                                        *
* Transação........:                                                        *
* Tipo de Prg......: FUNÇÃO                                                 *
* Objetivo.........: Criar PEPs                                             *
* Data.............: 31/08/2018                                             *
* --------------------------------------------------------------------------*
* Request    | Descrição                                                    *
* --------------------------------------------------------------------------*
* S4DK901960 | AGIR - Carga de Dados para Migração - HXXX - PEPs            *
* --------------------------------------------------------------------------*


*  OBS1.: Método Standard para criar "PEPs"
*            Função BAPI_BUS2054_CREATE_MULTI

*  OBS2.: Esta função chama a função standard BAPI_BUS2054_CREATE_MULTI
*           - Atender ao Migration CockPit
*             - Trabalhar os campos Zs
*             - Ter um flag de execução em teste (P_I_TESTRUN).
*             - Jogar todas as mensagens para uma única tabela de saída P_E_TI_RETURN


FUNCTION bapi_criar_peps.
*"----------------------------------------------------------------------
*"*"Interface local:
*"  IMPORTING
*"     VALUE(P_I_DEF_PROJETO) TYPE  PS_PSPID
*"     REFERENCE(P_I_TI_PEPS) TYPE  ZTPS_MC_WBS_ELEMENT
*"     REFERENCE(P_I_TI_CAMPOS_ZS) TYPE  ZTPS_BAPI_TE_WBS_ELEMENT
*"       OPTIONAL
*"     VALUE(P_I_TESTRUN) TYPE  BAPIE1GLOBAL_DATA-TESTRUN OPTIONAL
*"  EXPORTING
*"     REFERENCE(P_E_TI_RETURN) TYPE  BAPIRET2_TAB
*"----------------------------------------------------------------------

  DATA: lc_valuepart   TYPE valuepart,
        lc_erro        TYPE c,
        wa_return	     TYPE bapiret2,
        wa_campos_zs   TYPE bapi_te_wbs_element,
        wa_prps_ext_in TYPE bapiparex,
        ti_campos_zs   TYPE tt_it_netw_ext_in,
        ti_peps        TYPE ztps_bapi_bus2054_new,
        ti_return      TYPE bapiret2_tab,
        ti_return_fim  TYPE bapiret2_tab.

*-------------------------------------------------------------------*
*-------------------------------------------------------------------*

  CALL FUNCTION 'BAPI_PS_INITIALIZATION'.

  LOOP AT p_i_ti_campos_zs INTO wa_campos_zs.

    CALL METHOD cl_abap_container_utilities=>fill_container_c
      EXPORTING
        im_value               = wa_campos_zs
      IMPORTING
        ex_container           = lc_valuepart
      EXCEPTIONS
        illegal_parameter_type = 1
        OTHERS                 = 2.

*   A estrutura BAPI_TE_WBS_ELEMENT contém a estrutura CI_PRPS
    wa_prps_ext_in-structure  = 'BAPI_TE_WBS_ELEMENT'.
    wa_prps_ext_in-valuepart1 = lc_valuepart.
    APPEND wa_prps_ext_in TO ti_campos_zs.

  ENDLOOP.

  ti_peps[] = p_i_ti_peps[].

* Create WBS Elements Using BAPI
  CALL FUNCTION 'BAPI_BUS2054_CREATE_MULTI'
    EXPORTING
      i_project_definition = p_i_def_projeto
    TABLES
      it_wbs_element       = ti_peps[]
      et_return            = ti_return[]
      extensionin          = ti_campos_zs[].

  APPEND LINES OF ti_return TO ti_return_fim.

  READ TABLE ti_return WITH KEY type = 'E' TRANSPORTING NO FIELDS.
  IF sy-subrc = 0.
    lc_erro = abap_true.
  ENDIF.

* Se for execução em teste.
  IF p_i_testrun EQ abap_true.

* =====> Não faz nada.

* Se for execução valendo.
  ELSE.

*   Se tudo OK
    IF lc_erro IS INITIAL.

      CALL FUNCTION 'BAPI_PS_PRECOMMIT'
        TABLES
          et_return = ti_return.

      APPEND LINES OF ti_return TO ti_return_fim.

      READ TABLE ti_return WITH KEY type = 'E' TRANSPORTING NO FIELDS.
      IF sy-subrc = 0.
        lc_erro = abap_true.
      ENDIF.

*     Se tudo OK
      IF lc_erro IS INITIAL.

        CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
          EXPORTING
            wait   = 'X'
          IMPORTING
            return = wa_return.

        IF NOT wa_return IS INITIAL.
          APPEND wa_return TO ti_return_fim.
        ENDIF.

      ENDIF.

    ENDIF.

  ENDIF.

  IF NOT ti_return_fim[] IS INITIAL.
    p_e_ti_return[] = ti_return_fim[].
  ENDIF.

ENDFUNCTION.
