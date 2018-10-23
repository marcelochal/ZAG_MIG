*----------------------------------------------------------------------*
***INCLUDE LCNIF_MATF50 .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  check_sos_active
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_TMP_RESBD  text
*      -->P_MSFCV  text
*      -->P_ACTIVE  text
*----------------------------------------------------------------------*
form check_sos_active using i_resbd structure resbd
                            i_msfcv structure msfcv
                            e_active type c.

 clear e_active.
* Neuer BADI gemäß User Exit '015'
 CALL METHOD badi_matcomp_ref->check_sos_active_015
        EXPORTING
          i_resbd  = i_resbd
          i_msfcv  = i_msfcv
        importing
          e_active = e_active.
endform.
