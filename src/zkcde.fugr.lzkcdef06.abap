*-------------------------------------------------------------------
***INCLUDE LKCDEF06 .
*-------------------------------------------------------------------
form split_file_descr_for_dest tables   p_intern  type kcde_intern
                                        p_mesg structure kpp_rc_mesg
                       using    p_desc  type kcdu_file_description
                                i_decimal_sep type  c
                       changing xs_prot_kpp type kcde_ys_prot_kpp.
  data: l_desc_part  type kcdu_file_description.
  data: wa_datar     type kcdu_datar,
        wa_head      type kcdu_head,
        wa_r_h       like kcder_h,
        wa_key       type kcdu_key_with_nk_flag_struc.

  data: l_group_datar   type type_group_datar,
        wa_group_datar  type type_group_datar_struc.

  data: l_group_tab like wa_group_datar-group_id occurs 10,
        wa_group_id like wa_group_datar-group_id.
  data: l_count type i.

* datar in gruppen einsortieren
  perform find_groups_for_datar tables l_group_datar
                                using  p_desc.

* Tabelle über Gruppen bilden
  loop at l_group_datar into wa_group_datar.
    collect wa_group_datar-group_id into l_group_tab.
  endloop.

* gruppen abarbeiten
  loop at l_group_tab into wa_group_id.
*{   sammle die Beschreibung einer Gruppe un l_desc_part + verbuche
    clear l_desc_part.
    loop at l_group_datar into wa_group_datar
                          where group_id = wa_group_id.
      loop at p_desc-datar into wa_datar
                           where range_id = wa_group_datar-range_id.
        append wa_datar to l_desc_part-datar.

        loop at p_desc-r_h into wa_r_h
                      where range_id = wa_datar-range_id
                      or    range_id = c_star.
          case wa_r_h-key_head.
            when c_mode_head.
              read table p_desc-head into wa_head
                                with key head_id = wa_r_h-head_id.
              if sy-subrc <> 0. message x001(kx). endif.
              collect wa_head into l_desc_part-head.
            when c_mode_key.
              read table p_desc-key into wa_key
                               with key key_id = wa_r_h-head_id.
              collect wa_key into l_desc_part-key.
            when others. message x001(kx).
          endcase.
          wa_r_h-range_id = c_star.
          collect wa_r_h into l_desc_part-r_h.
        endloop.
      endloop.
    endloop.

*    l_count = 0.                                         "of
*    loop at l_desc_part-key into wa_key
*                            where row_col = k_k_rc_col.
*      l_count = l_count + 1.
*    endloop.
    data: l_saved like on.
    data: l_compl like on.
*    l_saved = off.                                       "of
*
*    if l_count > 1.
*      l_compl = on.
*    else.
*      l_compl = off.
*    endif.

    read table l_desc_part-key with key row_col = k_k_rc_col "of
                                        urrow   = c_row_max
                                        transporting no fields.
    if sy-subrc = 0.                                         "of
      l_compl = off.                                         "of
    else.                                                    "of
      l_compl = on.                                          "of
    endif.                                                   "of

    set extended check off.
    perform add_test_case in program rkcv_excel_upload_add if found
                          tables   p_intern
                          using    l_desc_part
                                   l_compl
                          changing l_saved.
    set extended check on.
    if l_saved = on. exit. endif.
*    if l_count > 1.                                        "of
    if l_compl = on.                                        "of
      call function 'KPP_COMPLEX_LEADCOL_UPLOAD'
           exporting
                i_decimal_sep = i_decimal_sep
           tables
                it_intern     = p_intern
           changing
                xs_prot_kpp   = xs_prot_kpp
                is_desc       = l_desc_part.
    else.
      call function 'K_PLAN_EXCEL_PP'
           exporting
                i_desc        = l_desc_part
                i_decimal_sep = i_decimal_sep
           tables
                i_intern      = p_intern
           changing
                xs_prot_kpp   = xs_prot_kpp.
    endif.
  endloop.
endform.                               " SPLIT_FILE_DESCR_FOR_DEST
