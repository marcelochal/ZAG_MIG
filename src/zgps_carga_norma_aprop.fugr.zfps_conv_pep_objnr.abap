* --------------------------------------------------------------------------*
*                  T A E S A - MIGRAÇÃO - AGIR                              *
* --------------------------------------------------------------------------*
* Consultoria .....: Intechpro                                              *
* ABAP.............: Richard de Aquino Rodrigues                            *
* Funcional........: André Santos                                           *
* Módulo...........: PS                                                     *
* Programa.........: ZFPS_CONV_PEP_OBJNR                                    *
* Transação........:                                                        *
* Tipo de Prg......: FUNÇÃO                                                 *
* Objetivo.........: Converter o Elemento PEP para OBJNR                    *
* Data.............: 21/09/2018                                             *
* --------------------------------------------------------------------------*
* Request    | Descrição                                                    *
* --------------------------------------------------------------------------*
* S4DK902606 | AGIR - Carga de Dados para Migração - HXXX - Norma de aprop. *
* --------------------------------------------------------------------------*

FUNCTION zfps_conv_pep_objnr.
*"----------------------------------------------------------------------
*"*"Interface local:
*"  IMPORTING
*"     REFERENCE(P_I_PEP) TYPE  PS_POSID
*"  EXPORTING
*"     REFERENCE(P_E_OBJNR) TYPE  J_OBJNR
*"----------------------------------------------------------------------

  DATA: lc_objnr TYPE j_objnr,
        lc_pep   TYPE ps_posid.

*----------------------------------------------------------------*
*----------------------------------------------------------------*
  CALL FUNCTION 'CONVERSION_EXIT_ABPSN_INPUT'
    EXPORTING
      input  = p_i_pep
    IMPORTING
      output = lc_pep.

  SELECT objnr INTO lc_objnr
         FROM prps
         UP TO 1 ROWS
         WHERE posid EQ lc_pep.
  ENDSELECT.

  IF sy-subrc EQ 0.
    p_e_objnr = lc_objnr.
  ENDIF.

ENDFUNCTION.
