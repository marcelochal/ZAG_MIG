* --------------------------------------------------------------------------*
*                  T A E S A - MIGRAÇÃO - AGIR                              *
* --------------------------------------------------------------------------*
* Consultoria .....: Intechpro                                              *
* ABAP.............: Richard de Aquino Rodrigues                            *
* Funcional........: André Santos                                           *
* Módulo...........: PM                                                     *
* Programa.........: BAPI_CRIAR_EQUIPAMENTO                                 *
* Transação........:                                                        *
* Tipo de Prg......: FUNÇÃO                                                 *
* Objetivo.........: Criar equipamento                                      *
* Data.............: 10/09/2018                                             *
* --------------------------------------------------------------------------*
* Request    | Descrição                                                    *
* --------------------------------------------------------------------------*
* S4DK902457 | AGIR - Carga de Dados para Migração - HXXX - Equipamento     *
* --------------------------------------------------------------------------*

*  OBS1.: Método Standard para criar "Local de instalação"
*            Função DMC_MIG_EQUIPMENT (DMC) ou BAPI_EQUI_CREATE

*  OBS2.: Esta função chama a função desenv. BAPI_ZEQUI_ZCREATE
*           - Atender ao Migration CockPit
*             - Trabalhar com campos Zs

FUNCTION bapi_criar_equipamento.
*"----------------------------------------------------------------------
*"*"Interface local:
*"  IMPORTING
*"     VALUE(P_I_EXTERNAL_NUMBER) TYPE  BAPI_ITOB_PARMS-EQUIPMENT
*"       OPTIONAL
*"     VALUE(P_I_WA_DATA_GENERAL) TYPE  BAPI_ITOB
*"     VALUE(P_I_WA_DATA_SPECIFIC) TYPE  BAPI_ITOB_EQ_ONLY
*"     VALUE(P_I_DATA_FLEET) TYPE  BAPI_FLEET OPTIONAL
*"     VALUE(P_I_VALID_DATE) TYPE  BAPI_ITOB_PARMS-INST_DATE DEFAULT
*"       SY-DATUM
*"     VALUE(P_I_DATA_INSTALL) TYPE  BAPI_ITOB_EQ_INSTALL OPTIONAL
*"     VALUE(P_I_WA_CAMPOS_ZS) TYPE  ITOBAPI_CREATE_EQ_ONLY OPTIONAL
*"     VALUE(P_I_TESTRUN) TYPE  BAPIE1GLOBAL_DATA-TESTRUN OPTIONAL
*"  EXPORTING
*"     REFERENCE(P_E_EQUIPMENT) TYPE  BAPI_ITOB_PARMS-EQUIPMENT
*"     REFERENCE(P_E_WA_DATA_GENERAL_EXP) LIKE  BAPI_ITOB STRUCTURE
*"        BAPI_ITOB
*"     REFERENCE(P_E_WA_DATA_SPECIFIC_EXP) TYPE  BAPI_ITOB_EQ_ONLY
*"     REFERENCE(P_E_WA_DATA_FLEET_EXP) TYPE  BAPI_FLEET
*"     REFERENCE(P_E_TI_RETURN) TYPE  BAPIRET2_TAB
*"----------------------------------------------------------------------

  DATA:
    lc_equipment(50) TYPE c,
    lc_valuepart     TYPE valuepart,
    lc_message(220)  TYPE c,
    wa_campos_zs     TYPE itobapi_create_eq_only,
    wa_li_ext_in     TYPE bapiparex,
    wa_return        TYPE bapiret2,
    ti_campos_zs     TYPE tt_it_netw_ext_in,
    ti_return        TYPE bapiret2_t.

*-------------------------------------------------------------------*
*-------------------------------------------------------------------*
* PM BAPI: Create Equipment
  CALL FUNCTION 'BAPI_ZEQUI_ZCREATE'
    EXPORTING
      external_number   = p_i_external_number
      data_general      = p_i_wa_data_general
      data_specific     = p_i_wa_data_specific
      data_fleet        = p_i_data_fleet
      valid_date        = p_i_valid_date
      data_install      = p_i_data_install
      campos_zs         = p_i_wa_campos_zs
    IMPORTING
      equipment         = p_e_equipment
      data_general_exp  = p_e_wa_data_general_exp
      data_specific_exp = p_e_wa_data_specific_exp
      data_fleet_exp    = p_e_wa_data_fleet_exp
      return            = wa_return.

*---------------------------------------------------------------*
  IF wa_return-id IS NOT INITIAL.  "Error message
    APPEND wa_return TO p_e_ti_return.
  ELSE.   "Add message if equipment number created.
    MOVE p_e_equipment TO lc_equipment.
    CALL FUNCTION 'BAPI_MESSAGE_GETDETAIL'
      EXPORTING
        id         = 'CNV_DMC_SIN'
        number     = '219'
        language   = 'E'
        textformat = 'ASC'
        message_v1 = lc_equipment
      IMPORTING
        message    = lc_message.

    IF sy-subrc = 0.
      wa_return-type       = 'S'.
      wa_return-id         = 'CNV_DMC_SIN'.
      wa_return-number     = '219'.
      wa_return-message    = lc_message.
      wa_return-message_v1 = p_e_equipment.
      APPEND wa_return TO p_e_ti_return.
    ELSE.
      RETURN.
    ENDIF.
  ENDIF.

  IF p_i_testrun = 'X'.
    CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.
  ENDIF.

ENDFUNCTION.
