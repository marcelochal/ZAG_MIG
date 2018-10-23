* --------------------------------------------------------------------------*
*                  T A E S A - MIGRAÇÃO - AGIR                              *
* --------------------------------------------------------------------------*
* Consultoria .....: Intechpro                                              *
* ABAP.............: Richard de Aquino Rodrigues                            *
* Funcional........: André Santos                                           *
* Módulo...........: FI                                                     *
* Programa.........: ZFFI_BAPI_CRIAR_IMOBILIZADO                            *
* Transação........:                                                        *
* Tipo de Prg......: FUNÇÃO                                                 *
* Objetivo.........: Criar Imobilizado                                      *
* Data.............: 28/09/2018                                             *
* --------------------------------------------------------------------------*
* Request    | Descrição                                                    *
* --------------------------------------------------------------------------*
* S4DK902435 | AGIR - Carga de Dados para Migração - H89 - Imobilizado      *
* --------------------------------------------------------------------------*

* Foram aproveitadas rotinas do programa ZAAC0005

FUNCTION zffi_bapi_criar_imobilizado.
*"----------------------------------------------------------------------
*"*"Interface local:
*"  IMPORTING
*"     REFERENCE(P_I_TI_IMOBILIZADO) TYPE  ZTFI_IMOBILIZADO
*"     REFERENCE(P_I_TESTRUN) TYPE  BAPIE1GLOBAL_DATA-TESTRUN OPTIONAL
*"  EXPORTING
*"     REFERENCE(P_E_TI_RETURN) TYPE  BAPIRET2_TAB
*"----------------------------------------------------------------------

  DATA: ti_imobilizado TYPE ztfi_imobilizado,
        ti_return      TYPE bapiret2_tab.

*--------------------------------------------------------------*
*--------------------------------------------------------------*
  REFRESH gt_log.

*-------------------------------------------------------*
* Evitar erro "Preencher todos os campos obrigatórios"
  sy-tcode = 'SE38'.

*-------------------------------------------------------*
  ti_imobilizado[] = p_i_ti_imobilizado[].

*-------------------------------------------------------*
  PERFORM ajusta_valores TABLES ti_imobilizado.

*-------------------------------------------------------*
  PERFORM valida_dados TABLES ti_imobilizado
                              ti_return
                       USING  p_i_testrun.

*-------------------------------------------------------*
  IF NOT ti_return[] IS INITIAL.
    p_e_ti_return[] = ti_return[].
  ENDIF.

ENDFUNCTION.
