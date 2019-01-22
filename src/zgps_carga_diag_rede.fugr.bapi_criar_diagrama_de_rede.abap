* --------------------------------------------------------------------------*
*                  T A E S A - MIGRAÇÃO - AGIR                              *
* --------------------------------------------------------------------------*
* Consultoria .....: Intechpro                                              *
* ABAP.............: Richard de Aquino Rodrigues                            *
* Funcional........: André Santos                                           *
* Módulo...........: PS                                                     *
* Programa.........: BAPI_CRIAR_DIAGRAMA_DE_REDE                            *
* Transação........:                                                        *
* Tipo de Prg......: FUNÇÃO                                                 *
* Objetivo.........: Criar diagrama de rede                                 *
* Data.............: 31/08/2018                                             *
* --------------------------------------------------------------------------*
* Request    | Descrição                                                    *
* --------------------------------------------------------------------------*
* S4DK902260 | AGIR - Carga de Dados para Migração - HXXX - Diag. de Rede    *
* --------------------------------------------------------------------------*

*  OBS1.: Método Standard para criar "Diagramas de Rede"
*            Função BAPI_BUS2002_CREATE

*  OBS2.: Esta função chama a função standard BAPI_BUS2002_CREATE
*         Ela foi adaptada para:
*           - Atender ao Migration CockPit
*             - Trabalhar os campos Zs
*             - Ter um flag de execução em teste (I_TESTRUN).
*             - Jogar todas as mensagens para uma única tabela de saída P_E_TI_RETURN

FUNCTION bapi_criar_diagrama_de_rede.
*"----------------------------------------------------------------------
*"*"Interface local:
*"  IMPORTING
*"     VALUE(P_I_WA_NETWORK) TYPE  BAPI_BUS2002_NEW
*"     VALUE(P_I_WA_CAMPOS_ZS) TYPE  ZEPS_BAPI_TE_NETWORK OPTIONAL
*"     VALUE(P_I_TESTRUN) TYPE  BAPIE1GLOBAL_DATA-TESTRUN OPTIONAL
*"  EXPORTING
*"     REFERENCE(P_E_TI_RETURN) TYPE  BAPIRET2_TAB
*"----------------------------------------------------------------------

  DATA: lc_valuepart   TYPE valuepart,
        lc_erro        TYPE c,
        wa_return	     TYPE bapiret2,
        wa_aufk_ext_in TYPE bapiparex,
        ti_campos_zs   TYPE tt_it_netw_ext_in,
        ti_return      TYPE bapiret2_tab,
        ti_return_fim  TYPE bapiret2_tab.

*-------------------------------------------------------------------*
*-------------------------------------------------------------------*

*----------------------------------------------------------*
* Tratamento dos campos Zs (CI_AUFK)
*----------------------------------------------------------*

  IF NOT p_i_wa_campos_zs IS INITIAL.

    CALL METHOD cl_abap_container_utilities=>fill_container_c
      EXPORTING
        im_value               = p_i_wa_campos_zs
      IMPORTING
        ex_container           = lc_valuepart
      EXCEPTIONS
        illegal_parameter_type = 1
        OTHERS                 = 2.

*   A estrutura BAPI_TE_NETWORK contém a estrutura CI_AUFK
*   wa_aufk_ext_in-structure  = 'BAPI_TE_NETWORK'.
    wa_aufk_ext_in-structure  = 'ZEPS_BAPI_TE_NETWORK'.
    wa_aufk_ext_in-valuepart1 = lc_valuepart.
    APPEND wa_aufk_ext_in TO ti_campos_zs.

  ENDIF.

*----------------------------------------------------------*
  CALL FUNCTION 'BAPI_PS_INITIALIZATION'.

* Create Network Header Using BAPI
  CALL FUNCTION 'BAPI_BUS2002_CREATE'
    EXPORTING
      i_network   = p_i_wa_network
    TABLES
      et_return   = ti_return
      extensionin = ti_campos_zs.

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
