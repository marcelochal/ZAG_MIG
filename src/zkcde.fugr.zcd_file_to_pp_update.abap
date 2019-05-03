function ZCD_FILE_TO_PP_UPDATE.
*"--------------------------------------------------------------------
*"*"Interface local:
*"  IMPORTING
*"     VALUE(I_PATH) LIKE  RLGRAP-FILENAME
*"     VALUE(I_FILENAME) LIKE  RLGRAP-FILENAME
*"     VALUE(I_FILE_ID) LIKE  KCDEFILE-FILE_ID DEFAULT SPACE
*"     VALUE(I_SEPARATOR) TYPE  C DEFAULT ';'
*"     VALUE(I_DECIMAL_SEP) TYPE  C DEFAULT ','
*"     VALUE(I_JMT_TMJ)
*"     VALUE(I_SAVE_REC) TYPE  C DEFAULT SPACE
*"  TABLES
*"      XT_PROT_KPP TYPE  KCDE_YT_PROT_KPP
*"--------------------------------------------------------------------
*{    Daten- und define deklaration
  data: l_filename  like rlgrap-filename.
  data: l_intern    type kcde_intern.

  data: l_file_id  like kcdedatar-file_id,
        l_subrc    like sy-subrc,
        l_dummy_range_id  like kcdedatar-range_id.
* data: l_dest_tab like kcdedatar-dest occurs 20 with header line.
* Dateibeschreibung
  data: l_mesg      like kpp_rc_mesg occurs 0.
  data: l_desc      type kcdu_file_description.
  data: ls_prot_kpp type kcde_ys_prot_kpp.

  define append_prot_kpp.
    clear ls_prot_kpp.
    ls_prot_kpp-filename = &1.
    ls_prot_kpp-file_id  = &2.
    ls_prot_kpp-extnr    = &3.
    ls_prot_kpp-subrc    = &4.
    append ls_prot_kpp to xt_prot_kpp.
  end-of-definition.
*}
*{    Initialisieren
  g_appl = c_kpp.

  refresh l_intern.

  perform __build_full_path using i_path i_filename l_filename.

  if i_file_id is initial.
    perform _get_range_attr_from_filename using g_appl i_filename
                                                l_file_id l_subrc.

    if l_subrc <> 0.
      if l_subrc = 4.
        append_prot_kpp i_filename ' ' ' ' 16.
      else.
        append_prot_kpp i_filename ' ' ' ' 17.
      endif.
      exit.
    endif.
  else.
    l_file_id = i_file_id.
    translate l_file_id to upper case. "#EC TRANSLANG
  endif.
*}
*{ Einlesen einer Datei und Konvertierung ins intern Format
  if l_filename cp '*.TXT'  or
     l_filename cp '*.CSV'.
    call function 'KCD_CSV_FILE_TO_INTERN_CONVERT'
         exporting
              i_filename      = l_filename
              i_separator     = i_separator
         tables
              e_intern        = l_intern
         exceptions
              upload_csv      = 1
              upload_filetype = 2.
*              others          = 3.
    l_subrc = sy-subrc.
  else.
*    perform file_id_excel_ole_to_int_conve tables   l_intern
*                                           using    l_filename
*                                                    l_file_id
*                                           changing l_subrc.
    l_subrc = 2.
* this form seemed to work in some cases but in some it does clearly not
* for example, first row (which is not shown inside grid in
* inplace-excel) is not transferred to internal table
* in documentation it is told to save to file for upload in txt-format !
* to prevent a user to try to upload an non-txt/csv file and possibly
* get problems, this perform is currently commented out
*kcd_excel_ole_to_int_convert
  endif.
  case l_subrc.
    when 0.                                                 "OK
    when 1.   append_prot_kpp i_filename ' ' ' ' 32.   "upload_csv
    when 2.   append_prot_kpp i_filename ' ' ' ' 33.   "upload_filetype
    when 16.  append_prot_kpp i_filename ' ' ' ' 16.  "keine Dateibesch
    when 201. append_prot_kpp i_filename ' ' ' ' 32.  "ole
    when others.
      message x001(kx) .
  endcase.
  if l_subrc <> 0.
    exit.
  endif.
*}
*{
  sort l_intern by row col.
  perform datar_load  tables l_desc-datar
                      using  l_file_id c_kpp.
  perform discription_load  tables l_desc-head l_desc-key l_desc-r_h
                            using  l_file_id l_dummy_range_id
                                   on c_kpp.
  perform enrich_intern tables l_intern l_desc-datar
                               l_desc-head l_desc-key.
  sort l_intern by row col.

  ls_prot_kpp-filename = i_filename.
  ls_prot_kpp-file_id  = l_file_id.
  perform split_file_descr_for_dest tables l_intern l_mesg
                                    using l_desc
                                          i_decimal_sep
                                    changing ls_prot_kpp.
  append ls_prot_kpp to xt_prot_kpp.
*}
endfunction.
