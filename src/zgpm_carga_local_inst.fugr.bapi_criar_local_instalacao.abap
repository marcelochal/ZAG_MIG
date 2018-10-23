* --------------------------------------------------------------------------*
*                  T A E S A - MIGRAÇÃO - AGIR                              *
* --------------------------------------------------------------------------*
* Consultoria .....: Intechpro                                              *
* ABAP.............: Richard de Aquino Rodrigues                            *
* Funcional........: André Santos                                           *
* Módulo...........: PM                                                     *
* Programa.........: BAPI_CRIAR_LOCAL_INSTALACAO                            *
* Transação........:                                                        *
* Tipo de Prg......: FUNÇÃO                                                 *
* Objetivo.........: Criar local de instalação                              *
* Data.............: 10/09/2018                                             *
* --------------------------------------------------------------------------*
* Request    | Descrição                                                    *
* --------------------------------------------------------------------------*
* S4DK902451 | AGIR - Carga de Dados para Migração - HXXX - Loc. Instalação *
* --------------------------------------------------------------------------*

*  OBS1.: Método Standard para criar "Local de instalação"
*            Função DMC_MIG_FUNCTIONAL_LOCATION (DMC) ou BAPI_FUNCLOC_CREATE

*  OBS2.: Esta função chama a função desenv. BAPI_ZFUNCLOC_ZCREATE
*           - Atender ao Migration CockPit
*             - Trabalhar com campos Zs

FUNCTION bapi_criar_local_instalacao.
*"----------------------------------------------------------------------
*"*"Interface local:
*"  IMPORTING
*"     VALUE(P_I_EXTERNAL_NUMBER) TYPE  BAPI_ITOB_PARMS-FUNCLOC
*"     VALUE(P_I_LABELING_SYSTEM) TYPE  BAPI_ITOB_PARMS-LABEL_SYST
*"       OPTIONAL
*"     VALUE(P_I_WA_DATA_GENERAL) TYPE  BAPI_ITOB
*"     VALUE(P_I_WA_DATA_SPECIFIC) TYPE  BAPI_ITOB_FL_ONLY
*"     VALUE(P_I_AUTOMATIC_INSTALL) TYPE  BAPIFLAG-BAPIFLAG OPTIONAL
*"     REFERENCE(P_I_WA_CAMPOS_ZS) TYPE  ITOBAPI_CREATE_FL_ONLY
*"       OPTIONAL
*"     REFERENCE(P_I_TESTRUN) TYPE  BAPIE1GLOBAL_DATA-TESTRUN OPTIONAL
*"  EXPORTING
*"     VALUE(P_E_FUNCTLOCATION) TYPE  BAPI_ITOB_PARMS-FUNCLOC_INT
*"     VALUE(P_E_WA_DATA_GENERAL_EXP) TYPE  BAPI_ITOB
*"     VALUE(P_E_WA_DATA_SPECIFIC_EXP) TYPE  BAPI_ITOB_FL_ONLY
*"     REFERENCE(P_E_TI_RETURN) TYPE  BAPIRET2_TAB
*"----------------------------------------------------------------------

  DATA:
    lc_valuepart TYPE valuepart,
    wa_campos_zs TYPE itobapi_create_fl_only,
    wa_li_ext_in TYPE bapiparex,
    ti_campos_zs TYPE tt_it_netw_ext_in,
    ti_return    TYPE bapiret2_t,
    wa_return    TYPE bapiret2.

*-------------------------------------------------------------------*
*-------------------------------------------------------------------*
* Migration of Functional Location
  CALL FUNCTION 'BAPI_ZFUNCLOC_ZCREATE'
    EXPORTING
      external_number   = p_i_external_number
      labeling_system   = p_i_labeling_system
      data_general      = p_i_wa_data_general
      data_specific     = p_i_wa_data_specific
      automatic_install = p_i_automatic_install
      campos_zs         = p_i_wa_campos_zs
    IMPORTING
      functlocation     = p_e_functlocation
      data_general_exp  = p_e_wa_data_general_exp
      data_specific_exp = p_e_wa_data_specific_exp
      return            = wa_return.

  IF wa_return-id IS NOT INITIAL.
    APPEND wa_return TO p_e_ti_return.
  ENDIF.

  IF p_i_testrun = 'X'.
    CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.
  ENDIF.

ENDFUNCTION.
