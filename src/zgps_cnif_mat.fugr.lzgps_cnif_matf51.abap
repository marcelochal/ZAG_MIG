*----------------------------------------------------------------------*
***INCLUDE LCNIF_MATF51 .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  deletion_chk_mat
*&---------------------------------------------------------------------*
*  aus Form del_chk_mat(saplcodt) übernommen
*----------------------------------------------------------------------*
FORM deletion_chk_mat  USING    imp_RESBD like resbd
                                rc like sy-subrc.
*  Kundeneigene Prüfung beim Löschen
  CALL METHOD badi_matcomp_ref->remove_component_check_013
    EXPORTING
      i_resbd_del = imp_resbd
    EXCEPTIONS
      rejected    = 01.
  if not sy-subrc is initial.
    rc = 1.
    exit.
  endif.
  CALL FUNCTION 'STATUS_CHECK'
    EXPORTING
      OBJNR             = imp_resbd-OBJNR
      STATUS            = STK_LOE
    EXCEPTIONS
      OBJECT_NOT_FOUND  = 01
      STATUS_NOT_ACTIVE = 02.
  if sy-subrc is initial.
* already deleted, no further checks
    rc = 1.
    exit.
  endif.
** check if component is split >>>>>>
*  IF imp_RESBD-SPLKZ EQ SPLIT2.
*    DIFF = imp_RESBD-BDMNG - imp_RESBD-ENMNG.
*    IF DIFF > 0 OR RESBD-KZEAR NE SPACE.
*      IF imp_RESBD-ERFME NE SPACE AND imp_RESBD-ERFME
*        NE imp_RESBD-MEINS.
*        DIFF = DIFF * ( imp_RESBD-UMREN / imp_RESBD-UMREZ ).
*        MESSAGE I596(CO) WITH DIFF imp_RESBD-ERFME.
*      ELSE.
*        MESSAGE I596(CO) WITH DIFF imp_RESBD-MEINS.
*      ENDIF.
*      RAISE ERROR_NO_MESSAGE.
*    ENDIF.
*  ENDIF.
*
* Warnung, falls WM-bereitstellungn bereits erfolgte
  IF NOT imp_RESBD-TBMNG IS INITIAL
     AND imp_RESBD-TBMNG > imp_RESBD-ENMNG.
    MESSAGE I198(C2) WITH imp_RESBD-MATNR into NULL.
    perform put_sy_message in program saplco2o.
  ENDIF.
* Warnung, falls bereits entnommen wurde
  IF NOT imp_RESBD-ENMNG IS INITIAL.
    MESSAGE I750(CN) WITH imp_RESBD-MATNR
                          imp_RESBD-POSNR into NULL.
    perform put_sy_message in program saplco2o.
  endif.
* Warnung, falls Bestellung zur Komponente vorhanden
  IF NOT imp_resbd-flg_purs IS INITIAL.
    MESSAGE i707(cn) WITH imp_resbd-banfnr imp_resbd-banfpo into NULL.
    perform put_sy_message in program saplco2o.
  endif.
ENDFORM.                    " deletion_chk_mat
