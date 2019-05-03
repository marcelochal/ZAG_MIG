function ZCD_EXTERN_PP_CALL.
*"----------------------------------------------------------------------
*"*"Interface local:
*"  IMPORTING
*"     VALUE(I_AREA_SUBCLASS) LIKE  TKES1-SUBCLASS DEFAULT '03'
*"     VALUE(I_AREA_TABNAME) LIKE  TKES1-TABNAME
*"  TABLES
*"      I_INTERN STRUCTURE  ZKCDE_CELLS
*"      I_DATAR STRUCTURE  KCDE_DATAR_ATTR
*"      I_HEAD STRUCTURE  KCDE_HEAD_ATTR
*"      I_KEY STRUCTURE  KCDEKEY
*"      I_R_H STRUCTURE  KCDER_H
*"      E_MESG STRUCTURE  KPP_RC_MESG
*"----------------------------------------------------------------------
  data: l_desc       type kcdu_file_description,
        wa_key_flag  type kcdu_key_with_nk_struc,
        wa_datar     like kcdedatar,
        wa_head      like kcdehead,
        wa_r_h       like kcder_h.

  data: ls_key type  kcdu_key.
  data: lt_key type  kcdu_key_tab.
  data: l_file_id like kcdedatar-file_id.
  data: l_area  type kpp_ys_area.
  data: l_subrc like sy-subrc.

  data: ls_prot_kpp type  kcde_ys_prot_kpp.

  l_area-subclass = i_area_subclass.
  l_area-tabname  = i_area_tabname.

  loop at i_key.
    move-corresponding i_key to wa_key_flag.
    move-corresponding i_key to ls_key.
    append ls_key to lt_key.
    append wa_key_flag to l_desc-key.
  endloop.
  loop at i_head.
    move-corresponding i_head to wa_datar.
    append wa_head to l_desc-head.
  endloop.
  loop at i_datar .
    move-corresponding  i_datar to wa_datar.
    wa_datar-dest = l_area.
    append wa_datar to l_desc-datar.
    l_file_id = wa_datar-file_id.
  endloop.
  loop at i_r_h.
    move-corresponding  i_r_h    to wa_r_h.
    append wa_r_h to l_desc-r_h.
  endloop.

  perform enrich_intern tables i_intern l_desc-datar
                               l_desc-head l_desc-key.

  call function 'KCD_EXCEL_SHEET_CHECK'
       exporting
            file_id     = l_file_id
*           I_OUTPUT    = ' '
*           I_NO_CHANGE = 'X'
       importing
            e_subrc     = l_subrc
       tables
            c_t_key     = lt_key
            c_t_datar   = l_desc-datar
            c_t_head    = l_desc-head
            c_t_r_h     = l_desc-r_h
            .
  if l_subrc <> 0.
    message x001(kx).
  endif.
  call function 'K_PLAN_EXCEL_PP'
       exporting
            i_desc        = l_desc
            i_decimal_sep = '.'
       tables
            i_intern      = i_intern
       changing
            xs_prot_kpp   = ls_prot_kpp.

endfunction.
