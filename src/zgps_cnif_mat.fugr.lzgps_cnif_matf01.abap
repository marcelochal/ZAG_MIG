*----------------------------------------------------------------------*
***INCLUDE LZGPS_CNIF_MATF01.
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Form CHECK_AND_CONVERT_COMP_ADD_2
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> I_COMPONENTS_ADD
*&---------------------------------------------------------------------*
FORM check_and_convert_comp_add_2 TABLES i_components_add
                                  STRUCTURE zeps_bapi_network_comp_add.

  REFRESH i_resbd.
  CLEAR i_resbd.
  CLEAR: gv_projn, gv_prps, gv_proj.
  DATA tmp_resbd LIKE resbd.
  SORT i_components_add STABLE BY activity.
  LOOP AT i_components_add.
    CLEAR tmp_resbd.

*   Adaptada para trabalhar com campos Zs e adicionais
    CALL FUNCTION 'ZMAP2I_BAPI_COMPS_ADD_TO_RESBD'
      EXPORTING
        bapi_network_comp_add     = i_components_add
      CHANGING
        resbd                     = tmp_resbd
      EXCEPTIONS
        error_converting_iso_code = 1
        OTHERS                    = 2.
    IF sy-subrc <> 0.
      PERFORM put_sy_message IN PROGRAM saplco2o.
      flg_error_occured = yx.
      EXIT.
    ELSE.
* KZ: TerminAusrichtung konvertieren
      MOVE-CORRESPONDING tmp_resbd TO i_resbd.
      IF NOT i_resbd-bdter IS INITIAL.
        i_resbd-kzmpf = yx.
      ENDIF.
      CASE i_resbd-kzmpf.
        WHEN '0'.
* Man.Bedarfstermin___
          i_resbd-kzmpf = yx.
        WHEN '1'.
* Ausr.Startterm.Komp.
          i_resbd-funct = funct_start.
          CLEAR i_resbd-kzmpf.
        WHEN '2'.
* Ausr.Endtermin_Komp.
          i_resbd-funct = funct_end.
          CLEAR i_resbd-kzmpf.
      ENDCASE.
      i_resbd-type_of_pur_resv = i_components_add-type_of_pur_resv.
* check valid Input date
      IF NOT i_resbd-bdter IS INITIAL.
        CALL FUNCTION 'CONVERT_DATE_TO_EXTERNAL'
          EXPORTING
            date_internal            = i_resbd-bdter
          EXCEPTIONS
            date_internal_is_invalid = 1
            OTHERS                   = 2.
        IF sy-subrc <> 0.
          PERFORM put_sy_message IN PROGRAM saplco2o.
          flg_error_occured = yx.
          EXIT.
        ENDIF.
      ENDIF.
      APPEND i_resbd.
    ENDIF.
  ENDLOOP.

ENDFORM.                    " check_and_convert_comp_add
