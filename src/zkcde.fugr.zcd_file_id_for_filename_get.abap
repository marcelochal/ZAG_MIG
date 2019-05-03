function ZCD_FILE_ID_FOR_FILENAME_GET.
*"--------------------------------------------------------------------
*"*"Interface local:
*"  IMPORTING
*"     VALUE(I_APPL) LIKE  KCDEFILE-APPL
*"     VALUE(I_FILENAME) LIKE  RLGRAP-FILENAME
*"  EXPORTING
*"     VALUE(ET_FILE_ID) TYPE  KCDE_YT_FILE_ID
*"--------------------------------------------------------------------
  data: l_file type kcdu_excel_file with header line.
  data: l_filename like  rlgrap-filename,
        l_path     like  rlgrap-filename.
  data: l_subrc like sy-subrc.

  refresh et_file_id.

  perform __separate_path_file using i_filename l_path
                                     l_filename l_subrc.
  perform _load_file tables l_file using i_appl.

  translate l_path to upper case. "#EC TRANSLANG
  loop at l_file.
    if l_filename cp l_file-filename.
      append l_file-file_id to et_file_id.
    endif.
  endloop.
endfunction.
