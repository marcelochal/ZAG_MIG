*----------------------------------------------------------------------*
*   INCLUDE LZCDEF02                                                   *
*----------------------------------------------------------------------*


form discription_load tables e_head       type kcdu_excel_head
                             e_key        type t_key_flag_type
                             e_r_h        type kcdu_excel_r_h
                       using i_file_id  like kcdedatar-file_id
                             i_range_id like kcdedatar-range_id
                             i_all_tab like on
                             i_appl type kcdu_excel_appl.
  statics: st_init     like off value off,
           st_file_id  like kcdedatar-file_id.
  statics: st_head  type kcdu_excel_head   with header line,
           st_key   type t_key_flag_type   with header line,
           st_r_h   type kcdu_excel_r_h    with header line,
           st_datar type kcdu_excel_datar  with header line,
           st_file  type kcdu_excel_file   with header line.
  data: l_key_pour type   kcdu_key occurs 10 with header line.

  if st_init = off or i_file_id <> st_file_id.
    refresh: st_key, st_head, st_datar, st_file, st_r_h.
    call function 'KCD_EXCEL_SHEET_DESCR_LOAD'
         exporting
              i_file_id = i_file_id
              i_appl    = i_appl
         tables
              e_key     = l_key_pour
              e_head    = st_head
              e_datar   = st_datar
              e_file    = st_file
              e_r_h     = st_r_h.

    loop at l_key_pour.
      move-corresponding l_key_pour to st_key. append st_key.
    endloop.

    perform  _customizing_check tables st_key st_r_h st_datar.

    st_init = on.
    st_file_id = i_file_id.
  endif.
  if i_all_tab = off.
    refresh: e_head, e_key, e_r_h.
    loop at st_r_h where range_id = i_range_id
                         or range_id = c_star.
      append st_r_h to e_r_h.
      case st_r_h-key_head.
        when c_mode_head.
          read table st_head with key head_id = st_r_h-head_id.
          if sy-subrc = 0.
            collect st_head into e_head.
          endif.
        when c_mode_key.
          read table st_key with key key_id = st_r_h-head_id.
          if sy-subrc = 0.
            collect st_key into e_key.
          endif.
        when others.
          message x001(kx).
      endcase.
    endloop.
  else.
    e_head[] = st_head[].
    e_r_h[]  = st_r_h[].
    e_key[]  = st_key[].
  endif.
endform.                               " DISCRIPTION_LOAD

*---------------------------------------------------------------------*
*       FORM DATAR_LOAD                                               *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
*  -->  DATAR                                                         *
*  -->  I_FILE_ID                                                     *
*---------------------------------------------------------------------*
form datar_load tables e_datar   type kcdu_excel_datar
                using  i_file_id like kcdedatar-file_id
                       i_appl    type kcdu_excel_appl .
  select * from kcdedatar where appl     = i_appl
                          and   file_id  = i_file_id.
    if kcdedatar-sfeld <> '*'.
      move-corresponding kcdedatar to e_datar.
      append e_datar.
    endif.
  endselect.
  sort e_datar by dest.
endform.

*----------------------------------------------------------------------*
form _customizing_check tables m_key    type t_key_flag_type
                               i_r_h   type kcdu_excel_r_h
                               i_datar type kcdu_excel_datar.
  data: l_count type i.
* ROW_COL in Key füllen
  loop at m_key.
    perform row_col_fill using m_key-olrow m_key-olcol
                               m_key-urrow m_key-urcol
                               m_key-row_col.
    modify m_key.
  endloop.
* Kennzahl entweder im data_range oder einem! KEY
* d.h. datar-sfeld = space ==>
*                 es existiert genau ein R_H mit SFELD = SPACE
* oder DATAR-SFELD <> SPACE ==> alle R_H-SFELD <> SPACE
  loop at i_datar.
    l_count = 0.
    if i_datar-sfeld = space.
      loop at i_r_h where key_head = c_mode_key
                    and   ( range_id = i_datar-range_id or
                            range_id = c_star ) .
        if i_r_h-sfeld = space. l_count = l_count + 1. endif.
      endloop.
      if l_count <> 1. message i601(du) with i_datar-range_id. endif.
    else.
      loop at i_r_h where key_head  = c_mode_key
                    and   ( range_id = i_datar-range_id or
                            range_id = c_star ) .
*       if i_r_h-sfeld = space.                                "leadcol
        if i_r_h-sfeld = space and i_datar-bezfld = space.     "leadcol
          message i601(du) with i_datar.
        endif.
      endloop.
    endif.
  endloop.
endform.                               " CUSTOMIZING_CHECK

*&---------------------------------------------------------------------*
*&      Form  ROW_COL_FILL
*&---------------------------------------------------------------------*
*       text                                                           *
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form row_col_fill using value(i_olrow) type kcde_row_col
                        value(i_olcol) type kcde_row_col
                        value(i_urrow) type kcde_row_col
                        value(i_urcol) type kcde_row_col
                              e_row_col type c.
  if i_olcol > i_urcol.
    message x001(kx) with 'Excel Bereich nicht korrekt definiert'(z02)
                          i_olrow i_olcol i_urrow.
* Excel Bereich nicht korrekt definiert
    break_sub.
  endif.
  if i_olrow > i_urrow.
    message x001(kx) with 'Excel Bereich nicht korrekt definiert'(z02)
                          i_olrow i_olcol i_urrow.
  endif.
  if     i_olcol < i_urcol
     and i_olrow < i_urrow.
    e_row_col = k_k_rc_2d.
  elseif i_olcol < i_urcol.
    e_row_col = k_k_rc_row.
  elseif i_olrow < i_urrow.
    e_row_col = k_k_rc_col.
  else.
    e_row_col = k_k_rc_field.
  endif.
endform.                               " ROW_COL_FILL
*&---------------------------------------------------------------------*
*&      Form  T242S_STRUCT_FILL
*&---------------------------------------------------------------------*
*       text                                                           *
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form t242s_struct_fill tables e_t242s structure cfsend_tab
                              using value(i_repid) like kcdedatar-dest
                                          e_cleng  like  cdifie-offst
                                          e_rleng  like  cdifie-offst
                                          e_ileng  like  cdifie-offst.
  call function 'RKC_T242S_TAB_FILL'
       exporting
            repid                = i_repid
       importing
            cleng                = e_cleng
            rleng                = e_rleng
            ileng                = e_ileng
       tables
            i_t242s              = e_t242s
       exceptions
            ddic_not_found       = 1
            no_ddic_struc        = 2
            send_struc_not_found = 3
            others               = 4.
  if sy-subrc <> 0.
    message e872(kx) with i_repid.
  endif.
endform.                               " T242S_STRUCT_FILL

*&---------------------------------------------------------------------*
*&      Form  __SFELD_CHECK
*&---------------------------------------------------------------------*
*       text                                                           *
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form __sfeld_check tables       i_t242s  structure cfsend_tab
                 using  value(i_sfeld) like kcdedatar-sfeld
                              e_subrc  like sy-subrc.
  clear e_subrc .
  read table i_t242s with key sfeld = i_sfeld.
  if sy-subrc <> 0.
    e_subrc = 4.
  endif.
endform.                               " __SFELD_CHECK
*&---------------------------------------------------------------------*
*&      Form  __WRITE_TEST_OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_L_RA_SEND  text                                            *
*----------------------------------------------------------------------*
form __write_test_output tables   i_ra_send type kcde_ra_send.
  data: wa_ra_send_tab type kcde_sender_struc.
  data: l_cfsend_tab like cfsend_tab occurs 0 with header line.
  data: l_cleng like  cdifie-offst.
  data: l_rleng like  cdifie-offst.
  data: l_ileng like  cdifie-offst.
  field-symbols: <l_field>.

  loop at i_ra_send.
    perform t242s_struct_fill tables l_cfsend_tab
                              using  i_ra_send-dest
                                     l_cleng l_rleng l_ileng.
    new-line.
    write: / 'Senderstruktur'(ssk), i_ra_send-dest,
             'Wertebereich'(ssw),   i_ra_send-range_id.
    new-line.
    loop at l_cfsend_tab.
* Achtung foffs wird hier misbraucht
      l_cfsend_tab-foffs = l_cfsend_tab-coffs + sy-tabix .
      modify l_cfsend_tab.
      write at l_cfsend_tab-foffs(l_cfsend_tab-cleng)
                                             l_cfsend_tab-txt20.
    endloop.

    loop at i_ra_send-tab into  wa_ra_send_tab.
      new-line.
      loop at l_cfsend_tab.
        assign wa_ra_send_tab+l_cfsend_tab-coffs(l_cfsend_tab-cleng)
                                                    to <l_field>.
        write at l_cfsend_tab-foffs(l_cfsend_tab-cleng)  <l_field>.

      endloop.
    endloop.
  endloop.
endform.                               " __WRITE_TEST_OUTPUT

*---------------------------------------------------------------------*
*       FORM ENRICH_INTERN                                            *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
*  -->  I_INTERN                                                      *
*  -->  I_DATAR                                                       *
*  -->  I_HEAD                                                        *
*  -->  I_KEY                                                         *
*---------------------------------------------------------------------*
form enrich_intern tables i_intern type kcde_intern
                          i_datar  type kcdu_excel_datar
                          i_head   type kcdu_excel_head
                          i_key    type t_key_flag_type.
  data: l_col        type kcde_row_col,
        l_row        type kcde_row_col,
        l_app_intern type kcde_intern_struc occurs 100 with header line.
  data: l_max_row  type kcde_row_col.
  data: l_max_col  type kcde_row_col.

  define enrich.
    l_row = &1.
    do.
      l_col = &2.
      do.
        read table i_intern with key row = l_row
                                     col = l_col
                            binary search.
        if sy-subrc <> 0.
          l_app_intern-row   = l_row.
          l_app_intern-col   = l_col.
          l_app_intern-value = space.
          collect l_app_intern.
        endif.
        l_col = l_col + 1.
        if l_col > l_max_col. exit. endif.
      enddo.
      l_row = l_row + 1.
      if l_row > l_max_row. exit. endif.
    enddo.
  end-of-definition.

  sort i_intern by row col.
  loop at i_intern.
    l_max_row = i_intern-row.
    if i_intern-col > l_max_col. l_max_col = i_intern-col. endif.
  endloop.
* break beuter.
  perform enrich_datar tables i_intern i_datar
                       using  l_max_row l_max_col.

* loop at i_datar.
*   enrich i_datar-olrow i_datar-olcol i_datar-urcol i_datar-urrow.
* endloop.

  loop at i_key.
    enrich i_key-olrow i_key-olcol.
  endloop.

  loop at i_head.
    enrich i_head-zrow i_head-col .
  endloop.

* Nos, 2.2.2000, i_intern soll mind. die Einträge der Dateibeschreibung
* umfassen. Fall mit dynamischer Zeilenanzahl muß aber noch
* berücksichtigt werden!
*  perform enrich_datar_new tables i_intern i_datar.
*
*  loop at i_key.
*    l_max_row = i_key-urrow.
*    l_max_col = i_key-urcol.
*    enrich i_key-olrow i_key-olcol.
*  endloop.
*
*  loop at i_head.
*    l_max_row = i_head-zrow.
*    l_max_col = i_head-col.
*    enrich i_head-zrow i_head-col .
*  endloop.

  append lines of l_app_intern to i_intern.
  sort i_intern by row col.
endform.                               " ENRICH_INTERN

*---------------------------------------------------------------------*
*       FORM ENRICH_DATAR                                             *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
*  -->  I_INTERN                                                      *
*  -->  I_DATAR                                                       *
*  -->  I_MAX_ROW                                                     *
*  -->  I_MAX_COL                                                     *
*---------------------------------------------------------------------*
form enrich_datar tables i_intern type kcde_intern
                         i_datar  type kcdu_excel_datar
                  using  i_max_row   type kcde_row_col
                         i_max_col   type kcde_row_col.
  data l_col        type kcde_row_col.
  data l_row        type kcde_row_col.
  data l_app_intern type kcde_intern_struc occurs 100 with header line.
  loop at i_datar.
    l_row = i_datar-olrow.
    do.
      l_col = i_datar-olcol.
      do.
        read table i_intern with key row = l_row
                                     col = l_col
                            binary search.
        if sy-subrc <> 0.
          l_app_intern-row   = l_row.
          l_app_intern-col   = l_col.
          l_app_intern-value = space.
          collect l_app_intern.
        endif.
        l_col = l_col + 1.
        if l_col > i_max_col. exit. endif.
      enddo.
      l_row = l_row + 1.
      if l_row > i_max_row. exit. endif.
    enddo.
  endloop.
endform.                               " ENRICH_INTERN

*----------------------------------------------------------------------*

*---------------------------------------------------------------------*
*       FORM ENRICH_DATAR_NEW                                          *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
*  -->  I_INTERN                                                      *
*  -->  I_DATAR                                                       *
*---------------------------------------------------------------------*
form enrich_datar_new tables i_intern type kcde_intern
                         i_datar  type kcdu_excel_datar.
* Noch nicht verwenden.
  data l_col        type kcde_row_col.
  data l_row        type kcde_row_col.
  data l_max_col    type kcde_row_col.
  data l_max_row    type kcde_row_col.

  data l_app_intern type kcde_intern_struc occurs 100 with header line.
  loop at i_datar.
    l_row = i_datar-olrow.
    l_max_row = i_datar-urrow.
    l_max_col = i_datar-urcol.
    do.
      l_col = i_datar-olcol.
      do.
        read table i_intern with key row = l_row
                                     col = l_col
                            binary search.
        if sy-subrc <> 0.
          l_app_intern-row   = l_row.
          l_app_intern-col   = l_col.
          l_app_intern-value = space.
          collect l_app_intern.
        endif.
        l_col = l_col + 1.
        if l_col > l_max_col. exit. endif.
      enddo.
      l_row = l_row + 1.
      if l_row > l_max_row. exit. endif.
    enddo.
  endloop.
endform.                               " ENRICH_INTERN

*----------------------------------------------------------------------*


form file_id_excel_ole_to_int_conve tables xt_intern type kcde_intern
                             using    i_filename
                                      i_file_id like kcdedatar-file_id
                             changing e_subrc like sy-subrc.
  data: lt_head   type  kcdu_head_tab.
  data: lt_key    type  kcdu_key_tab.
  data: lt_r_h    like kcder_h occurs 0.
  data: lt_datar  type  kcdu_datar_tab.
  data: lt_file   like  kcdefile occurs 0.

  field-symbols: <ls_head>  type kcdu_head.
  field-symbols: <ls_key>   type kcdu_key.
  field-symbols: <ls_datar> type kcdu_datar.

  data: l_begin_col type i.
  data: l_begin_row type i.
  data: l_end_col   type i.
  data: l_end_row   type i.

  call function 'KCD_EXCEL_SHEET_DESCR_LOAD'
       exporting
            i_file_id   = i_file_id
            i_appl      = g_appl
       tables
            e_key       = lt_key
            e_head      = lt_head
            e_datar     = lt_datar
            e_file      = lt_file
            e_r_h       = lt_r_h
       exceptions
            not_found   = 16.
  if sy-subrc <> 0.
    e_subrc = sy-subrc.
    exit.
  endif.
  l_begin_col = '9999'.
  l_begin_row = '9999'.
  l_end_col = '0000'.
  l_end_row = '0000'.

  loop at lt_head assigning <ls_head>.
    perform file_desc_cells_supp using <ls_head>-zrow <ls_head>-col
                                       <ls_head>-zrow <ls_head>-col
                                 changing l_begin_col l_begin_row
                                          l_end_col   l_end_row.
  endloop.

  loop at lt_key assigning <ls_key>.
    perform file_desc_cells_supp using <ls_key>-olrow <ls_key>-olcol
                                       <ls_key>-urrow <ls_key>-urcol
                                 changing l_begin_col l_begin_row
                                          l_end_col   l_end_row.
  endloop.

  loop at lt_datar assigning <ls_datar>.
   perform file_desc_cells_supp using <ls_datar>-olrow <ls_datar>-olcol
                                      <ls_datar>-urrow <ls_datar>-urcol
                                  changing l_begin_col l_begin_row
                                           l_end_col   l_end_row.
  endloop.

  call function 'KCD_EXCEL_OLE_TO_INT_CONVERT'
       exporting
            filename                = i_filename
            i_begin_col             = l_begin_col
            i_begin_row             = l_begin_row
            i_end_col               = l_end_col
            i_end_row               = l_end_row
       tables
            intern                  = xt_intern
       exceptions
            INCONSISTENT_PARAMETERS = 201
            UPLOAD_OLE              = 201.
  if sy-subrc <> 0.
    e_subrc = sy-subrc.
    exit.
  endif.


endform.                               " FILE_ID_EXCEL_OLE_TO_INT_CONVE

*----------------------------------------------------------------------*
form file_desc_cells_supp using    i_olrow type kcdu_row_col
                                   i_olcol type kcdu_row_col
                                   i_urrow type kcdu_row_col
                                   i_urcol type kcdu_row_col
                          changing x_begin_col type i
                                   x_begin_row type i
                                   x_end_col   type i
                                   x_end_row   type i.
  if i_olrow < x_begin_row. x_begin_row = i_olrow. endif.
  if i_olcol < x_begin_col. x_begin_col = i_olcol. endif.

  if i_urrow > x_end_row. x_end_row = i_urrow. endif.
  if i_urcol > x_end_col. x_end_col = i_urcol. endif.
endform.                               " FILE_DESC_CELLS_SUPP
