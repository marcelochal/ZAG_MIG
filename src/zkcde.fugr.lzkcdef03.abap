*----------------------------------------------------------------------*
*   INCLUDE LZCDEF03                                                   *
*----------------------------------------------------------------------*
form head_infos_fill tables i_t242s  structure cfsend_tab
                            i_head   type kcdu_excel_head
                            i_r_h    type kcdu_excel_r_h
                            i_intern type kcde_intern
                     using  e_head_infos type kcde_sender_struc
                            i_range_id   like kcdedatar-range_id
                            i_jmt_tmj.
  clear: e_head_infos.
  loop at i_r_h where key_head = c_mode_head
                and   ( range_id = i_range_id or
                        range_id = c_star ).
    read table i_head with key appl     = g_appl
                               file_id  = i_r_h-file_id
                               head_id  = i_r_h-head_id.

    if sy-subrc = 0.
      read table i_intern with key row = i_head-zrow
                                   col = i_head-col.
      if sy-subrc = 0.
        perform __s_string_set tables i_t242s
                               using i_r_h-sfeld e_head_infos
                                     i_intern-value
                                     i_jmt_tmj.
      endif.
    endif.
  endloop.
endform.                               " HEAD_INFOS_FILL

*----------------------------------------------------------------------*
form __s_string_set tables i_t242s structure cfsend_tab
                    using value(i_sfeld)   like kcdedatar-sfeld
                                e_string   type kcde_sender_struc
                          value(i_value)   type kcde_intern_value
                          value(i_jmt_tmj).
  data: l_conv_value type kcde_intern_value.
  field-symbols: <l_field>.

  read table i_t242s with key sfeld = i_sfeld.

  if i_t242s-ctype = 'D'.
    if not i_jmt_tmj is initial. " sonst ist das Datum im internen form
      call function 'KCD_EXCEL_DATE_CONVERT'
           exporting
                excel_date  = i_value
                date_format = i_jmt_tmj
           importing
                sap_date    = l_conv_value
           exceptions
                others      = 0.

    else.
*     Datum ist im internen Format
      l_conv_value = i_value.
    endif.
  else.
    l_conv_value = i_value.
  endif.
  if sy-subrc = 0.
    assign e_string+i_t242s-coffs(i_t242s-cleng) to <l_field>
                                                type i_t242s-ctype.
    <l_field> = l_conv_value.
  endif.
endform.

*----------------------------------------------------------------------*
form key_fig_fill tables i_t242s structure cfsend_tab
                         i_key type t_key_flag_type
                         i_r_h type kcdu_excel_r_h
                         e_key_fig type kcde_key_fig
                         i_intern type kcde_intern.
  data: l_subrc like sy-subrc.
  loop at i_r_h where sfeld = space.
    read table i_key with key key_id = i_r_h-head_id.
    if sy-subrc <> 0.
      message x001(kx).
    endif.
    loop at i_intern where row >= i_key-olrow
                     and   row <= i_key-urrow
                     and   col >= i_key-olcol
                     and   col <= i_key-urcol.
      if i_r_h-ini_suppr = on.
        if i_intern-value co ' 0'.
          continue.
        endif.
      endif.
      move-corresponding i_key to e_key_fig.
      move-corresponding i_r_h to e_key_fig.
      e_key_fig-sfeld   = i_intern-value.
      translate e_key_fig-sfeld to upper case."#EC SYNTCHAR
      perform __sfeld_check tables i_t242s
                          using e_key_fig-sfeld l_subrc.
      if l_subrc = 0.
        e_key_fig-col  = i_intern-col.
        e_key_fig-zrow = i_intern-row.
        append e_key_fig.
      endif.
    endloop.
  endloop.
endform.                               " KEY_FIG_FILL

*----------------------------------------------------------------------*
form sender_row_fill tables       intern         type kcde_intern
                                  ch_sender      type kcde_sender
                                  i_head         type kcdu_excel_head
                                  i_key          type t_key_flag_type
                                  i_r_h          type kcdu_excel_r_h
                      using  value(i_data_range)  type kcdu_datar
                            value(i_decimal_sep) type c
                            value(i_jmt_tmj).
  data: t242s_tab  like cfsend_tab occurs 50 with header line.
  data: l_srf_number_col like kcdehead-col,
        l_srf_number_row like kcdehead-col,
        l_subrc          like sy-subrc,
        l_count          type i,
        l_do_append      like on.

  data: l_sfeld      like t242s_tab-sfeld,
        l_value      type kcde_intern_value.

  data: l_sender     type kcde_sender with header line,
        l_key_fig    type kcde_key_fig with header line,
        i_head_infos type kcde_sender_struc.

  perform init_range tables t242s_tab i_key i_r_h l_key_fig i_head
                            intern
                     using  i_data_range i_head_infos i_jmt_tmj.

  refresh l_sender.
  loop at intern where row >= i_data_range-olrow
                 and   row <= i_data_range-urrow
                 and   col >= i_data_range-olcol
                 and   col <= i_data_range-urcol.
    if i_data_range-ini_suppr = on and intern-value co ' 0'.
      continue.
    endif.
    l_do_append = on.
    clear: l_subrc, l_sender.
    l_srf_number_col = intern-col.
    l_srf_number_row = intern-row.
    l_sender         = i_head_infos.
* füllen der Kennzahl
    if i_data_range-sfeld = space.
* das Senderfeld, in das der Wert aus den Datarange geschrieben werden
* soll Steht in einem Schlüsselfeld (in Tab l_key_fig).
* Falls Kein Senderfeld gefunden wird, soll der Wert übergangen werden.
      l_count = 0.
      loop at i_r_h where key_head = c_mode_key
                    and   ( range_id = i_data_range-range_id or
                            range_id = c_star ).
        read table i_key with key appl    = g_appl
                                  file_id = i_r_h-file_id
                                  key_id  = i_r_h-head_id.
        if sy-subrc <> 0.
          message x001(kx).
        endif.
        check i_r_h-sfeld = space.
        if l_count > 0.
          message e604(du) with i_data_range-range_id.
        endif.
        l_count = l_count + 1.
        clear l_subrc.
        perform find_sfeld tables l_key_fig
                           using  i_key
                                  l_srf_number_col
                                  l_srf_number_row
                                  l_sfeld
                                  l_subrc.
        if l_subrc = 0.
          perform __s_string_set tables t242s_tab
                                 using  l_sfeld
                                        l_sender
                                        intern-value
                                        i_jmt_tmj.
        endif.
      endloop.
    else.
      perform __s_string_set tables t242s_tab
                             using i_data_range-sfeld
                                   l_sender intern-value
                                   i_jmt_tmj.
    endif.
    check l_subrc = 0.
*                          " Wenn kein Senderfeld gefunden wurde
*                          " wird der Wert aus Datar übergangen.

* füllen der Merkmalswerte aus Key-Bereichen
    loop at i_r_h where key_head = c_mode_key
                  and   ( range_id = i_data_range-range_id or
                          range_id = c_star ).
      read table i_key with key appl     = g_appl
                                file_id  = i_r_h-file_id
                                key_id   = i_r_h-head_id.
      if sy-subrc <> 0.
        message x001(kx).
      endif.

      check i_r_h-sfeld <> space.
      perform find_intern_value_for_key tables intern
                                        using i_key
                                              l_srf_number_col
                                              l_srf_number_row
                                              l_value.
      if i_r_h-ini_suppr = on and l_value co ' 0'.
        l_do_append = off.
        exit.
      endif.
      perform __s_string_set tables t242s_tab
                             using  i_r_h-sfeld
                                    l_sender l_value
                                    i_jmt_tmj.
    endloop.
* Dateiename Spalten und Zeilennummer in Sendersatz bringen
    if i_data_range-fn_field <> space.
      l_value = 'file'.
      perform __s_string_set tables t242s_tab
                             using  i_data_range-fn_field
                                    l_sender
                                    l_value
                                    i_jmt_tmj.
    endif.
    if i_data_range-sp_field <> space.
      l_value = intern-col.
      perform __s_string_set tables t242s_tab
                             using  i_data_range-sp_field
                                    l_sender
                                    l_value
                                    i_jmt_tmj.
    endif.
    if i_data_range-rw_field <> space.
      l_value = intern-row.
      perform __s_string_set tables t242s_tab
                             using  i_data_range-rw_field
                                    l_sender
                                    l_value
                                    i_jmt_tmj.
    endif.
    if l_do_append = on.
      append l_sender.
    endif.
  endloop.
  perform sender_check      tables t242s_tab l_sender ch_sender
                            using i_decimal_sep.
endform.                               " sender_row_fill

*----------------------------------------------------------------------*
form find_sfeld  tables i_key_fig        type kcde_key_fig
                 using  i_key            type kcdu_key_with_nk_struc
                        i_srf_number_col like kcdehead-col
                        i_srf_number_row like kcdehead-col
                        e_sfeld          like kcder_h-sfeld
                        e_subrc          like sy-subrc.
* voraussetzung, daß hier alles ok läuft ist, daß i_key_fig nur
* für einen RANGE_ID gefüllt ist.
  case i_key-row_col.
    when k_k_rc_row.                   "key-Bereich in Zeile R
      loop at i_key_fig where col = i_srf_number_col.
        e_sfeld = i_key_fig-sfeld.
      endloop.
      if sy-subrc <> 0. e_subrc = 4. endif.
    when k_k_rc_col.                   "key-Bereich in Spalte C
      loop at i_key_fig where zrow = i_srf_number_row.
        e_sfeld = i_key_fig-sfeld.
      endloop.
      if sy-subrc <> 0. e_subrc = 4. endif.
    when k_k_rc_field.                 "key-Bereich in Feld F
*     Es kann nur zrow oder col gleich sein sonst wäre
*     Zelle aus Wertbereich auch in Schlüsselbereich
      loop at i_key_fig where zrow = i_srf_number_row
                        or    col  = i_srf_number_col.
        e_sfeld = i_key_fig-sfeld.
      endloop.
      if sy-subrc <> 0. e_subrc = 4. endif.
    when others.
      message x001(kx).
  endcase.
endform.                               " FIND_SFELD

*---------------------------------------------------------------------*
form find_intern_value_for_key
                     tables i_intern          type kcde_intern
                     using  i_key        type kcdu_key_with_nk_struc
                            i_srf_number_col  like kcdehead-col
                            i_srf_number_row  like kcdehead-zrow
                            e_value           like i_intern-value.
  clear e_value.
  case i_key-row_col.
    when k_k_rc_row.                   "key-Bereich in Zeile
      read table i_intern with key row = i_key-olrow
                                   col = i_srf_number_col.
      if sy-subrc = 0.
        e_value = i_intern-value.
      else.
        e_value = space.
      endif.
    when k_k_rc_col.                   "key-Bereich in Spalte
      read table i_intern with key row = i_srf_number_row
                                   col = i_key-olcol.
      if sy-subrc = 0.
        e_value = i_intern-value.
      else.
        e_value = space.
      endif.
    when k_k_rc_field.                 "key-Bereich in Feld F
      read table i_intern with key row = i_key-olrow
                                   col = i_key-urcol.
      if sy-subrc = 0.
        e_value = i_intern-value.
      else.
        break_sub.
        message e603(du) with i_key-olcol i_key-urrow.
      endif.
    when others.                       " dies darf nicht sein
      message x001(kx).
  endcase.
endform.                               " find_intern_value_for_key

*----------------------------------------------------------------------*
form sender_check tables i_t242s      structure cfsend_tab
                         i_sender     type kcde_sender
                         e_sender     type kcde_sender
                   using i_decimal_sep type c.
  refresh e_sender.
  loop at i_sender.
    perform  reconvert_format tables i_t242s
                              using  i_sender e_sender
                                     i_decimal_sep.
    e_sender = i_sender.
    append e_sender.
  endloop.
endform.                               " SENDER_CHECK

*---------------------------------------------------------------------*
form reconvert_format tables s_tab       structure cfsend_tab
                      using  i_crecord  type kcde_sender_struc
                             e_record   type kcde_sender_struc
                             i_decimal_sep type c.

  field-symbols: <ls_field>, <ls_cfield>.
  clear e_record.

  loop at s_tab.
*-get-storage-for-the-new-fields--------------------------------------*
    assign e_record+s_tab-coffs(s_tab-cleng)
        to <ls_field> type s_tab-ctype.
    assign i_crecord+s_tab-coffs(s_tab-cleng)
          to <ls_cfield> type s_tab-ctype.
*-give-the-senderfield-the-initial-value.-This-is-especially----------*
*-important-if-the-length-of-the-senderfield-is-zero.-----------------*
    clear <ls_field>.
*-IF-LEN-=-0-AND-SUBRC-=-0-we-have-initial-fields.-the-case-must-be---*
*-considered-to-avoid-dumps-ASSIGN-WITH-LENGTH-0...-------------------*
    case s_tab-itype.
      when 'P'.
        perform __convert_packed using i_decimal_sep
                                       s_tab-fdeci  s_tab-ftype
                                       <ls_cfield>  <ls_field>.
      when 'D'.
        <ls_field> = <ls_cfield>.
      when 'C'.
        <ls_field> = <ls_cfield>.
      when others.
        <ls_field> = <ls_cfield>.
    endcase.
  endloop.
endform.

*----------------------------------------------------------------------*
form __convert_packed using    i_decimal_sep
                               i_decim     like cfsend_tab-fdeci
                               i_type      like cfsend_tab-ftype
                               i_cfield
                               e_field.
  data: l_float type f.
  data: l_save_value(30).

  l_save_value = i_cfield.
  if i_cfield is initial.
    e_field = 0.
  else.
*-perhaps-we-have-a-decimal-comma-------------------------------------*
    case i_decimal_sep.
      when c_pu_co.                    "sowohl Punkt als auch Komma
*                                   werden als dezimalseparator
*                                   interpretiert.
*                                   d.h. der anwender stellt sicher,
*                                   daß es keine tausender sep's gibt
        translate i_cfield using ',.'.
      when c_comma.
        translate i_cfield using '. '.
        condense i_cfield no-gaps.
        replace ',' with '.' into i_cfield.
      when c_point.
        translate i_cfield using ', '.
        condense i_cfield no-gaps.
    endcase.

    if i_decim > 0.
      perform check_decim using i_decim i_cfield.
    endif.
    if i_cfield co ' 0123456789.+-'.
      e_field = i_cfield.
*-allow-floats--------------------------------------------------------*
    elseif i_type = 'F' and i_cfield co ' E0123456789.+-'.
      l_float = i_cfield.
      e_field = l_float.
    else.
* & kann nicht in eine gepackte Zahl konvertiert werden
      message a933(kx) with l_save_value '0'.
    endif.
  endif.

endform.                               " __CONVERT_PACKED

*---------------------------------------------------------------------*
form check_decim using i_fdeci like cfsend_tab-fdeci
                       ch_cfield.
  data: l_length type i,
        l_i      type i,
        l_point_ex like on.
  field-symbols <l_byt> type c.

  l_point_ex = off.
  l_i = 0.
  describe field ch_cfield length l_length in character mode. "UNICODE
* Zahl linksbündig bringen
  do.
    assign ch_cfield(1) to <l_byt>.
    if <l_byt> <> space. exit. endif.
    ch_cfield = ch_cfield+1.
    l_i = l_i + 1.
    if l_i > l_length. exit. endif.
  enddo.

  if ch_cfield ca c_point.
    l_point_ex = on.
  endif.
  l_i = sy-fdpos + i_fdeci.
  if l_point_ex = on and l_i > l_length. message x001(kx). endif.

  if l_point_ex = on.
    l_i = sy-fdpos.
  else.
    l_i = strlen( ch_cfield ).
    assign ch_cfield+l_i(1) to <l_byt>.
    if <l_byt> = ' '. <l_byt> = c_point. endif.
  endif.

  do i_fdeci times.
    l_i = l_i + 1.
    assign ch_cfield+l_i(1) to <l_byt>.
    if <l_byt> = ' '. <l_byt> = '0'. endif.
  enddo.
  if ch_cfield ca c_point.
  endif.
* zuviele Stellen abschneiden
  l_i = sy-fdpos + i_fdeci + 1.
  write space to ch_cfield+l_i.
  replace c_point with ' ' into ch_cfield.
  condense ch_cfield no-gaps.
endform.

*---------------------------------------------------------------------*
form init_range tables t242s_tab  structure cfsend_tab
                       i_key        type t_key_flag_type
                       i_r_h        type kcdu_excel_r_h
                       i_key_fig    type kcde_key_fig
                       i_head       type kcdu_excel_head
                       intern       type kcde_intern
                using  i_datar      type t_datar_struc
                       i_head_infos type kcde_sender_struc
                       i_jmt_tmj.

  data:  l_cleng  like  cdifie-offst,
         l_rleng  like  cdifie-offst,
         l_ileng  like  cdifie-offst.

* read the senderstructure into an internal table ---------------------
  perform t242s_struct_fill tables t242s_tab
                            using  i_datar-dest l_cleng l_rleng l_ileng.
* Use the head-Description to fill a referenz-sender-string ----------
  perform head_infos_fill   tables t242s_tab i_head i_r_h intern
                            using  i_head_infos i_datar-range_id
                                   i_jmt_tmj.
* use the key-description to read the keyfigure information out off the
* sheet
  perform key_fig_fill      tables t242s_tab i_key i_r_h
                                                   i_key_fig intern.
endform.
