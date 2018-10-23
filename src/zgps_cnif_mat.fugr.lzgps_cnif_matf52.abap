*----------------------------------------------------------------------*
***INCLUDE LCNIF_MATF52 .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  postp_det
*&---------------------------------------------------------------------*
*   Bestimmung des Positionstyps
*   perform postp_det(saplcomk)
*----------------------------------------------------------------------*
form postp_det .
 IF i_resbd-postp IS INITIAL.
    PERFORM postp_det_via_t418v.
*      call customer-function '004'       "<<<====  user-exit
*         exporting
*             resbd_imp = resbd
*         importing
*             postp_exp = resbd-postp.

  ENDIF.
endform.                    " postp_det
