FUNCTION zffi_fm_comitem_update.
*"----------------------------------------------------------------------
*"*"Interface local:
*"  IMPORTING
*"     VALUE(I_FIKRS) LIKE  FMCI-FIKRS
*"     VALUE(I_GJAHR) LIKE  FMCI-GJAHR
*"     VALUE(I_FLG_COMMIT) LIKE  FMDY-XFELD DEFAULT SPACE
*"  TABLES
*"      T_FMCI TYPE  FMCI_T OPTIONAL
*"      T_FMCIT TYPE  PFM_T_FMCIT OPTIONAL
*"      T_FMHICI TYPE  ZTFI_FMHICI OPTIONAL
*"      T_FMZUBSP TYPE  ZTFI_FMZUBSP OPTIONAL
*"      RETURN STRUCTURE  BAPIRET2
*"----------------------------------------------------------------------

  TYPES: BEGIN OF fmmd_fmci.
      INCLUDE STRUCTURE fmci.
  TYPES: action LIKE fmdy-xfeld.
  TYPES: END OF fmmd_fmci.

  TYPES: fmmd_t_fmci TYPE fmmd_fmci OCCURS 0.

*-----Text: Finanzposition
  TYPES: BEGIN OF fmmd_fmcit.
      INCLUDE STRUCTURE fmcit.
  TYPES: action LIKE fmdy-xfeld.
  TYPES: END OF fmmd_fmcit.

  TYPES: fmmd_t_fmcit TYPE fmmd_fmcit OCCURS 0.

*-----Hierarchie: Finanzposition
  TYPES: BEGIN OF fmmd_fmhici.
      INCLUDE STRUCTURE fmhici.
  TYPES: action LIKE fmdy-xfeld.
  TYPES: END OF fmmd_fmhici.

  TYPES: fmmd_t_fmhici TYPE fmmd_fmhici OCCURS 0.

*------Zuordnungstabelle
  TYPES: BEGIN OF fmmd_fmzubsp.
      INCLUDE STRUCTURE fmzubsp.
  TYPES: action LIKE fmdy-xfeld.
  TYPES: END OF fmmd_fmzubsp.

  TYPES: fmmd_t_fmzubsp TYPE fmmd_fmzubsp OCCURS 0.

  DATA: ls_fmci         TYPE fmci,
        ls_fmcit        TYPE fmcit,
        ls_fmhici       TYPE fmhici,
        ls_fmzubsp      TYPE fmzubsp,
        ls_fmmd_fmci    TYPE fmmd_fmci,
        ls_fmmd_fmcit   TYPE fmmd_fmcit,
        ls_fmmd_fmhici  TYPE fmmd_fmhici,
        ls_fmmd_fmzubsp TYPE fmmd_fmzubsp,
        lt_fmmd_fmci    TYPE fmmd_t_fmci,
        lt_fmmd_fmcit   TYPE fmmd_t_fmcit,
        lt_fmmd_fmhici  TYPE fmmd_t_fmhici,
        lt_fmmd_fmzubsp TYPE fmmd_t_fmzubsp.


  "Ítem financeiro
  LOOP AT t_fmci INTO ls_fmci.
    CLEAR ls_fmmd_fmci.
    MOVE-CORRESPONDING ls_fmci TO ls_fmmd_fmci.
    ls_fmmd_fmci-action = 'I'. "Ïnsert
    APPEND ls_fmmd_fmci TO lt_fmmd_fmci.
  ENDLOOP.

  "Textos do íÍtem financeiro
  LOOP AT t_fmcit INTO ls_fmcit.
    CLEAR ls_fmmd_fmcit.
    MOVE-CORRESPONDING ls_fmcit TO ls_fmmd_fmcit.
    ls_fmmd_fmcit-action = 'I'. "Ïnsert
    APPEND ls_fmmd_fmcit TO lt_fmmd_fmcit.
  ENDLOOP.

  "Hierarquia itens financeiros
  LOOP AT t_fmhici INTO ls_fmhici.
    CLEAR ls_fmmd_fmhici.
    MOVE-CORRESPONDING ls_fmhici TO ls_fmmd_fmhici.
    ls_fmmd_fmhici-action = 'I'. "Ïnsert
    APPEND ls_fmmd_fmhici TO lt_fmmd_fmhici.
  ENDLOOP.

  "Atribuição de elementos BSP
  LOOP AT t_fmzubsp INTO ls_fmzubsp.
    CLEAR ls_fmmd_fmzubsp.
    MOVE-CORRESPONDING ls_fmzubsp TO ls_fmmd_fmzubsp.
    ls_fmmd_fmzubsp-action = 'I'. "Ïnsert
    APPEND ls_fmmd_fmzubsp TO lt_fmmd_fmzubsp.
  ENDLOOP.


  CALL FUNCTION 'FM_COMITEM_UPDATE'
    EXPORTING
      i_fikrs        = i_fikrs
      i_gjahr        = i_gjahr
      i_flg_commit   = i_flg_commit
    TABLES
      t_fmmd_fmci    = lt_fmmd_fmci
      t_fmmd_fmcit   = lt_fmmd_fmcit
      t_fmmd_fmhici  = lt_fmmd_fmhici
*     T_FMMD_FMZUBSP =
    EXCEPTIONS
      error_occurred = 1
      OTHERS         = 2.

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
