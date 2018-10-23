FUNCTION zffi_fm_funds_ctr_create.
*"----------------------------------------------------------------------
*"*"Interface local:
*"  IMPORTING
*"     VALUE(I_FIKRS) LIKE  FMFCTR-FIKRS
*"     VALUE(I_FISTL) LIKE  FMFCTR-FICTR
*"     VALUE(I_HIVARNT) LIKE  FMHISV-HIVARNT OPTIONAL
*"     VALUE(I_FMFCTR) TYPE  GENFM_T_FMFCTR
*"     VALUE(I_FMFCTRT) TYPE  ZTFI_FMFCTRT
*"     VALUE(I_FMHISV) TYPE  ZTFI_FMHISV
*"     VALUE(I_FLG_TEST) LIKE  FMDY-XFELD DEFAULT ' '
*"     VALUE(I_FLG_NO_ENQUEUE) LIKE  FMDY-XFELD DEFAULT ' '
*"     VALUE(I_FLG_COMMIT) LIKE  FMDY-XFELD DEFAULT ' '
*"  TABLES
*"      RETURN STRUCTURE  BAPIRET2
*"----------------------------------------------------------------------

  TYPES: BEGIN OF fmmd_fmfctr.
      INCLUDE STRUCTURE fmfctr.
  TYPES:           action LIKE fmdy-xfeld.
  TYPES: END OF fmmd_fmfctr.
*
  TYPES: BEGIN OF fmmd_fmfctrt.
      INCLUDE STRUCTURE fmfctrt.
  TYPES:           action LIKE fmdy-xfeld.
  TYPES: END OF fmmd_fmfctrt.
*
  TYPES: BEGIN OF fmmd_fmhisv.
      INCLUDE STRUCTURE fmhisv.
  TYPES:           action LIKE fmdy-xfeld.
  TYPES: END OF fmmd_fmhisv.
*
  TYPES: fmmd_t_fmfctr_core TYPE fmmd_fmfctr OCCURS 1.
  TYPES: fmmd_t_fmfctrt_core TYPE fmmd_fmfctrt OCCURS 1.
  TYPES: fmmd_t_fmhisv_core TYPE fmmd_fmhisv OCCURS 1.
*
  TYPES: BEGIN OF fmmd_fistl_all,
           fikrs             LIKE fmhisv-fikrs,
           fistl             LIKE fmhisv-fistl,
           tab_fmfctr        TYPE fmmd_t_fmfctr_core,
           tab_fmfctrt       TYPE fmmd_t_fmfctrt_core,
           tab_fmhisv        TYPE fmmd_t_fmhisv_core,
           flg_change        LIKE fmdy-xfeld,
           flg_fmfctr_read   LIKE fmdy-xfeld,         "'X'= gelesen
           flg_fmfctrt_read  LIKE fmdy-xfeld,
           flg_fmfctrt_exist LIKE fmdy-xfeld,
           flg_fmhisv_read   LIKE fmdy-xfeld,         "'S' = Einzeln
           "'A' = Alle
           flg_fmhisv_exist  LIKE fmdy-xfeld,
         END OF fmmd_fistl_all.
*
  DATA: ls_funds_ctr_all     TYPE fmmd_fistl_all,
        ls_funds_ctr         TYPE fmmd_fmfctr,
        ls_funds_ctr_text    TYPE fmmd_fmfctrt,
        ls_funds_ctr_hivarnt TYPE fmmd_fmhisv,
        ls_fmfctr            TYPE fmfctr,
        ls_fmfctrt           TYPE fmfctrt,
        ls_fmhisv            TYPE fmhisv.


  ls_funds_ctr_all-fikrs = i_fikrs.
  ls_funds_ctr_all-fistl = i_fistl.

  "Centro financeiro
  LOOP AT i_fmfctr INTO ls_fmfctr.
    CLEAR ls_funds_ctr.
    ls_funds_ctr-fikrs = i_fikrs.
    ls_funds_ctr-fictr = i_fistl.

    MOVE-CORRESPONDING ls_fmfctr TO ls_funds_ctr.
    ls_funds_ctr-action = 'I'. "Ïnsert
    APPEND ls_funds_ctr TO ls_funds_ctr_all-tab_fmfctr.
  ENDLOOP.

  "Textos do Centro financeiro
  LOOP AT i_fmfctrt INTO ls_fmfctrt.
    CLEAR ls_funds_ctr_text.
    ls_funds_ctr_text-fikrs = i_fikrs.
    ls_funds_ctr_text-fictr = i_fistl.

    MOVE-CORRESPONDING ls_fmfctrt TO ls_funds_ctr_text.
    ls_funds_ctr_text-action = 'I'. "Ïnsert
    APPEND ls_funds_ctr_text TO ls_funds_ctr_all-tab_fmfctrt.
  ENDLOOP.

  "Hierarquia Centro financeiro
  LOOP AT i_fmhisv INTO ls_fmhisv.
    CLEAR ls_funds_ctr_hivarnt.
    ls_funds_ctr_hivarnt-fikrs = i_fikrs.
    ls_funds_ctr_hivarnt-fistl = i_fistl.

    MOVE-CORRESPONDING ls_fmhisv TO ls_funds_ctr_hivarnt.
    ls_funds_ctr_hivarnt-action = 'I'. "Ïnsert
    APPEND ls_funds_ctr_hivarnt TO ls_funds_ctr_all-tab_fmhisv.
  ENDLOOP.


  CALL FUNCTION 'FM_FUNDS_CTR_CREATE_NO_SCREEN'
    EXPORTING
      i_fikrs            = i_fikrs
      i_fistl            = i_fistl
      i_hivarnt          = i_hivarnt
      i_f_fmmd_fistl_all = ls_funds_ctr_all
      i_flg_test         = i_flg_test
      i_flg_commit       = i_flg_commit
      i_flg_no_enqueue   = i_flg_no_enqueue
*   TABLES
*     I_T_LONGTEXT       =
    EXCEPTIONS
      input_error        = 1
      master_data_error  = 2
      update_error       = 3
      error_message      = 4
      OTHERS             = 5.

  IF sy-subrc <> 0.
    return-type       = sy-msgty.
    return-id         = sy-msgid.
    return-number     = sy-msgno.
    return-message_v1 = sy-msgv1.
    return-message_v1 = sy-msgv2.
    return-message_v1 = sy-msgv3.
    return-message_v1 = sy-msgv4.
    APPEND return.
  ENDIF.

ENDFUNCTION.
