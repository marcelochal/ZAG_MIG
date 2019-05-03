*----------------------------------------------------------------------*
*   INCLUDE LKCDEF05                                                   *
*----------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*&      Form  FIND_GROUPS_FOR_DATAR
*&---------------------------------------------------------------------*
*       gruppiert Datenbereiche, die gemeinsam an PP übergeben werden
*       können.
*----------------------------------------------------------------------*
*      -->P_L_DATAR_GROUP  tabelle der gruppen von datar
*      -->P_I_DATAR  text                                              *
*      -->P_I_HEAD  text                                               *
*      -->P_I_KEY  text                                                *
*----------------------------------------------------------------------*
form find_groups_for_datar tables i_group_datar type type_group_datar
                           using  i_desc type  kcdu_file_description.
  data: wa1_datar  like kcdedatar,
        wa2_datar  like kcdedatar.
  data: l_subrc    like sy-subrc,
        l_grouped  like on,
        l_group_id like kcdedatar-range_id.

  refresh i_group_datar.
  clear l_group_id.
  loop at i_desc-datar into wa1_datar.
    l_grouped = off.
    loop at i_group_datar.
      read table i_desc-datar into wa2_datar
                         with key range_id = i_group_datar-range_id.
      if sy-subrc <> 0. message x001(kx). endif.
* passt ein datar in eine vorhanden Gruppe
      perform check_combine_possible using i_desc
                                           wa1_datar wa2_datar l_subrc.
      if l_subrc = 0.   " nimm aktuellen datar in gruppe auf
        l_grouped = on.
        i_group_datar-range_id = wa1_datar-range_id.
        append i_group_datar.
        exit.
      endif.
    endloop.
    if l_grouped = off.
* aktueller datar passt zu keiner gruppe, also: neue Gruppe eröffnen
      l_group_id = l_group_id + 1.
      i_group_datar-range_id = wa1_datar-range_id.
      i_group_datar-group_id = l_group_id.
      append  i_group_datar.
    endif.
  endloop.
endform.                               " FIND_GROUPS_FOR_DATAR
*&---------------------------------------------------------------------*
*&      Form  CHECK_COMBINE_POSSIBLE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_I_HEAD  text                                               *
*      -->P_I_KEY  text                                                *
*      -->P_WA1_DATAR  text                                            *
*      -->P_WA2_DATAR  text                                            *
*----------------------------------------------------------------------*
form check_combine_possible using  i_desc type  kcdu_file_description
                                   i1_datar like kcdedatar
                                   i2_datar like kcdedatar
                                   e_subrc.
*data: wa_key  type kcdu_key_with_nk_struc.
  clear e_subrc.
* gleicher Empfänger
  if i1_datar-dest <> i2_datar-dest or
     i1_datar-appl <> i2_datar-appl.
    e_subrc = 4. exit.
  endif.
* gleiche position in Zeilen
  if i1_datar-olrow <> i2_datar-olrow or
     i1_datar-urrow <> i2_datar-urrow.
    e_subrc = 4. exit.
  endif.
* geiche Kopf
  perform check_combine_head_equ tables i_desc-r_h
                                 using i1_datar-range_id
                                       i2_datar-range_id
                                       e_subrc.
  if e_subrc <> 0. exit. endif.
  perform check_combine_head_equ tables i_desc-r_h
                                 using i2_datar-range_id
                                       i1_datar-range_id
                                       e_subrc.
  if e_subrc <> 0. exit. endif.
* gleiche Schlüssel in Spalten
  perform check_combine_col_key_equ tables i_desc-key i_desc-r_h
                                    using  i1_datar-range_id
                                           i2_datar-range_id
                                           e_subrc.
  if e_subrc <> 0. exit. endif.
  perform check_combine_col_key_equ tables i_desc-key i_desc-r_h
                                    using  i1_datar-range_id
                                           i2_datar-range_id
                                           e_subrc.
  if e_subrc <> 0. exit. endif.

endform.                               " CHECK_COMBINE_POSSIBLE


*----------------------------------------------------------------------*
form check_combine_head_equ tables i_r_h type kcdu_excel_r_h
                            using  i1_range_id like kcdedatar-range_id
                                   i2_range_id like kcdedatar-range_id
                                   e_subrc     like sy-subrc.
*  data: wa1_r_h like kcder_h.

  clear e_subrc.
  loop at i_r_h  transporting no fields
*                 into  wa1_r_h
                     where range_id = i1_range_id
                     and   key_head = c_mode_head.

    read table i_r_h transporting no fields
                     with key key_head = c_mode_head
                              range_id = i2_range_id.
    if sy-subrc <> 0. e_subrc = 4. exit. endif.
  endloop.

endform.                               " CHECK_COMBINE_HEAD_EQU

*----------------------------------------------------------------------*
form check_combine_col_key_equ tables i_key     type kcdu_key_with_nk
                                      i_r_h     type kcdu_excel_r_h
                             using  i1_range_id like kcdedatar-range_id
                                    i2_range_id like kcdedatar-range_id
                                    e_subrc     like sy-subrc.
  data: wa1_r_h like kcder_h,
        wa2_r_h like kcder_h,
        wa_key  type kcdu_key_with_nk_struc.

  clear e_subrc.
  loop at i_key into wa_key where row_col = k_k_rc_col.
    loop at i_r_h into wa1_r_h
                       where range_id = i1_range_id
                       and   head_id  = wa_key-key_id
                       and   key_head = c_mode_key.
      read table i_r_h into wa2_r_h
                       with key range_id = i2_range_id
                                head_id  = wa_key-key_id
                                key_head = c_mode_key.
      if sy-subrc <> 0. e_subrc = 4. exit. endif.
      if wa1_r_h-sfeld <> wa2_r_h-sfeld.
        e_subrc = 4. exit.
      endif.
    endloop.
  endloop.
endform.                               " CHECK_COMBINE_COL_KEY_EQU
