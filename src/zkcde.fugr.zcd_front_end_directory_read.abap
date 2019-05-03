FUNCTION ZCD_FRONT_END_DIRECTORY_READ .
*"--------------------------------------------------------------------
*"*"Interface local:
*"  IMPORTING
*"     VALUE(I_PATH) LIKE  RLGRAP-FILENAME
*"  EXPORTING
*"     VALUE(E_PURE_PATH) LIKE  RLGRAP-FILENAME
*"  TABLES
*"      E_DIRECTORY TYPE  KCDE_DIRECTORY
*"  EXCEPTIONS
*"      DOWNLOAD
*"      UPLOAD
*"      EXECUTE
*"      DIRECTORY_NOT_EXIST
*"      DIRECTORY
*"--------------------------------------------------------------------


* PN 7.5.01: Use another subroutine:
  perform read_directory_new tables e_directory
                              using i_path
                           changing e_pure_path

                              .
  exit.
**************************************
*
*  data: begin of dir occurs 100,
*          line(100),
*        end of dir.
*  data: l_path      like rlgrap-filename,
*        l_file      like rlgrap-filename.
*  data: l_drive(2).
*  data: l_subrc    like sy-subrc,
*        l_strlen   type i,
*        l_last_byt type c.
*
*  perform check_file_exists using    i_path 'DE'  "does file exist
*                            changing l_subrc.
*  if sy-subrc <> 0.
*    raise directory.
*  endif.
*
*  if l_subrc <> 1.
*    if i_path ca '*'.
*      perform __separate_path_file using i_path l_path l_file l_subrc.
*      if l_subrc <> 0.
*        raise directory_not_exist.
*      endif.
*    else.
*      raise directory_not_exist.
*    endif.
*  else.
*    l_path = i_path.
*    l_file = space.
*  endif.
*
*  l_drive = i_path.
*  if l_drive+1(1) = ':'.
*    dir = l_drive.
*    append dir.
*  endif.
**  l_path = i_path.
*  dir = 'cd'.
*
*  write '"' to dir+4.
*  l_strlen = strlen( l_path ).
*  write l_path to dir+5.
*  l_strlen = l_strlen + 5.
*  write '"' to dir+l_strlen.
*
*  append dir.
*  dir = 'del dir_file.txt'.
*  append dir.
*
** 15.03.01 *****************************************
** PN: sometimes the SAP WORKDIR is different to the actual dir.
*
**  dir = 'dir /b '.
**  dir+8 = l_file.
**  concatenate  dir ' > dir_file.txt' into dir.
**  condense dir.
**  append dir.
*  l_strlen = strlen( l_path ) - 1.
*  if l_strlen > 0.
*    l_last_byt = l_path+l_strlen(1).
*    if l_last_byt = '\'.
*      l_path+l_strlen(1) = ' ' .
*    else.
*      l_strlen = l_strlen + 1.
*    endif.
*    e_pure_path = l_path.
*  endif.
*
*  dir = 'dir /b '.
*  dir+8 = l_file.
*
*  data l_dir_file like l_path.
*  if l_path ne '\'.
*    concatenate l_path '\dir_file.txt' into l_dir_file.
*  else.
*    l_dir_file = '\dir_file.txt'.
*  endif.
*  condense l_dir_file no-gaps.
*  concatenate dir ' > ' l_dir_file into dir.
*  condense dir.
*  append dir.
******************************************************
*
*  write: '\dir_file.bat' to l_path+l_strlen.
*  data: l_help(120).
*  write '"' to l_help.
*  write l_path to l_help+1.
*  l_strlen = l_strlen + 1.
*  write '\dir_file.bat' to l_help+l_strlen.
*  l_strlen = l_strlen + 13.
*  write '"' to l_help+l_strlen.
*
** 31.01.01*******************************************
** PN: since 46.b a basis-method for reading directories exists ...
** this should work better:
*  data  new_logic type c.
**  new_logic = 'X'.
*  clear new_logic. " At least until the Interfaces in P9C and U9C are
*                  " are different.
*
*  if not new_logic is initial.
*
*    data lt_data type FILETABLE.
*    data l_file_count type i.
*    data l_directory like rlgrap-filename.
*    data l_filter like rlgrap-filename.
*
*    field-symbols <fs_data> type FILE_TABLE.
*
*    concatenate e_pure_path '\' into l_directory.
*    l_filter = l_file.
*
**    CALL METHOD CL_GUI_FRONTEND_SERVICES=>DIRECTORY_LIST_FILES
**      EXPORTING
**        DIRECTORY                   = l_directory
**        FILTER                      = l_filter
**        FILES_ONLY                  = 'X'
**      CHANGING
**        FILE_TABLE                  = lt_data
**        FILE_COUNT                  = l_file_count
**      EXCEPTIONS
**        CNTL_ERROR                  = 1
**        DIRECTORY_LIST_FILES_FAILED = 2
**        others                      = 3
**        .
**    IF SY-SUBRC <> 0.
**       raise directory_not_exist.
**    ENDIF.
*
*    refresh dir.
*    loop at lt_data assigning <fs_data>.
*      append <fs_data> to dir.
*    endloop.
*
*    read table dir with key line = 'dir_file.txt'
*                 transporting no fields.
*    if sy-subrc = 0.
*      delete dir index sy-tabix.
*    endif.
*
*    read table dir with key line = 'dir_file.bat'
*                 transporting no fields.
*    if sy-subrc = 0.
*      delete dir index sy-tabix.
*    endif.
*
*    e_directory[] = dir[].
*
*    exit.
*  endif.
** **************************************************
*
*
*
*  call function 'WS_DOWNLOAD'
*       exporting
*            filename            = l_path
*       tables
*            data_tab            = dir
*       exceptions
*            file_open_error     = 1
*            file_write_error    = 2
*            invalid_filesize    = 3
*            invalid_table_width = 4
*            invalid_type        = 5
*            no_batch            = 6
*            unknown_error       = 7
*            others              = 8.
*  if sy-subrc <> 0.
*    raise download.
*  endif.
*
*  perform check_file_exists using    l_path 'FE'  "does file exist
*                            changing l_subrc.
*  if sy-subrc <> 0. raise download. endif.
*  if l_subrc <> '1'. message i201(due). endif.
*  perform check_file_exists using    l_path 'FE'  "does file exist
*                            changing l_subrc.
*  if sy-subrc <> 0. raise download. endif.
*  if l_subrc <> '1'. raise download. endif.
*
** PN 24.7.00 Ersatz für WS_EXECUTE, leider nur für WIN...
*  data rc type i.
*  CALL FUNCTION 'GUI_EXEC'
*       EXPORTING
*            COMMAND    = l_path
**         PARAMETER  =
*       IMPORTING
*           RETURNCODE = rc
*          .
** Wenns schief geht, mit WS_EXECUTE probieren ...
*  if not rc is initial.
*    call function 'WS_EXECUTE'
*       exporting
**            program        = l_help
*            program        = l_path
*       importing
*            rbuff          = dir
*       exceptions
*            frontend_error = 1
*            no_batch       = 2
*            prog_not_found = 3
*            illegal_option = 4
*            others         = 5.
*    if sy-subrc <> 0.
*      raise execute.
*    endif.
*
*  endif.
*
*  write e_pure_path to l_path.
*  l_strlen = strlen( l_path ).
*  write '\dir_file.txt' to l_path+l_strlen.
*  l_strlen = l_strlen + 13.
*
*  perform check_file_exists using    l_path 'FE'  "does file exist
*                            changing l_subrc.
*  if sy-subrc <> 0. raise upload. endif.
*  if l_subrc <> '1'. message i202(due). endif.
*  perform check_file_exists using    l_path 'FE'  "does file exist
*                            changing l_subrc.
*  if sy-subrc <> 0. raise upload. endif.
*  if l_subrc <> '1'. raise upload. endif.
*
*  refresh dir.
*  call function 'WS_UPLOAD'
*       exporting
*            filename            = l_path
*       tables
*            data_tab            = dir
*       exceptions
*            conversion_error    = 1
*            file_open_error     = 2
*            file_read_error     = 3
*            invalid_table_width = 4
*            invalid_type        = 5
*            no_batch            = 6
*            unknown_error       = 7
*            others              = 8.
*  if sy-subrc <> 0.
*    raise upload.
*  endif.
*  read table dir with key line = 'dir_file.txt'
*                 transporting no fields.
*  if sy-subrc = 0.
*    delete dir index sy-tabix.
*  endif.
*
*  read table dir with key line = 'dir_file.bat'
*                 transporting no fields.
*  if sy-subrc = 0.
*    delete dir index sy-tabix.
*  endif.
*
*  e_directory[] = dir[].
endfunction.

*----------------------------------------------------------------------*
form __separate_path_file using    i_path like rlgrap-filename
                                   e_path like rlgrap-filename
                                   e_file like rlgrap-filename
                                   e_subrc like sy-subrc.
  data: verz like rlgrap-filename occurs 5 with header line.
  data: l_leng    type i,
        l_path_lg type i,
        l_all_lg  type i.
  split i_path at '\' into table verz.
  loop at verz. endloop.
*  if not verz ca '*'.
*    e_subrc = 4.
*    exit.
*  endif.
  l_leng    = strlen( verz ).
  l_all_lg = strlen( i_path ).
  l_path_lg = l_all_lg - l_leng.
  if l_path_lg = 0.
    e_path = space.
    e_file = i_path.
    e_subrc = 0.
    exit.
  endif.
  e_path = i_path(l_path_lg).
  call function 'WS_QUERY'
       exporting
            filename       = e_path
            query          = 'DE'
       importing
            return         = e_subrc
       exceptions
            inv_query      = 1
            no_batch       = 2
            frontend_error = 3
            others         = 4.
  if sy-subrc <> 0 or e_subrc <> 1.
    e_subrc = 4.
    exit.
  endif.
  e_file = verz.
  e_subrc = 0.
endform.                               " __SEPARATE_PATH_FILE

*---------------------------------------------------------------------*
*       FORM CHECK_FILE_EXISTS                                        *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
*  -->  I_PATH                                                        *
*  -->  I_QUERY                                                       *
*  -->  E_SUBRC                                                       *
*---------------------------------------------------------------------*
form check_file_exists using i_path  like rlgrap-filename
                             i_query
                       changing e_subrc like sy-subrc.
  call function 'WS_QUERY'
       exporting
*           ENVIRONMENT    =
            filename       = i_path
            query          = i_query
*           WINID          =
       importing
            return         = e_subrc
       exceptions
            inv_query      = 1
            no_batch       = 2
            frontend_error = 3
            others         = 4.
  if sy-subrc <> 0.
    e_subrc = sy-subrc.
  endif.
endform.


************************************************************************
*
* PN 7.5.01: New Subroutine:
form read_directory_new    tables et_directory type kcde_directory
                            using i_path      LIKE  RLGRAP-FILENAME
                         changing e_pure_path LIKE  RLGRAP-FILENAME
                              .
  data: begin of dir occurs 100,
          line(100),
        end of dir.
  data: l_path      like rlgrap-filename,
        l_file      like rlgrap-filename.
  data: l_subrc    like sy-subrc,
        l_strlen   type i,
        l_last_byt type c.
  data l_dir_file like l_path.

  data: l_dir type string
       ,lt_dir type filetable
       ,l_filter type string
       ,l_count type i
             .
  field-symbols <fs_data> type FILE_TABLE.

* Part 1: Create the Path and the Filter in the old fashioned way:

  perform check_file_exists using    i_path 'DE'  "does file exist
                            changing l_subrc.
  if sy-subrc <> 0.
    raise directory.
  endif.

  if l_subrc <> 1.
    if i_path ca '*'.
      perform __separate_path_file using i_path l_path l_file l_subrc.
      if l_subrc <> 0.
        raise directory_not_exist.
      endif.
    else.
      raise directory_not_exist.
    endif.
  else.
    l_path = i_path.
    l_file = space.
  endif.

  l_strlen = strlen( l_path ) - 1.
  if l_strlen > 0.
    l_last_byt = l_path+l_strlen(1).
    if l_last_byt = '\'.
      l_path+l_strlen(1) = ' ' .
    else.
      l_strlen = l_strlen + 1.
    endif.
    e_pure_path = l_path.
  endif.


* Part2a: Call CL_GUI_FRONTEND_SERVICES=>DIRECTORY_LIST_FILES

  concatenate e_pure_path '\' into l_dir.
  if l_file is initial.
    l_filter = '*.*'. " Load the complete Directory.
  else.
    l_filter = l_file.
  endif.

  CALL METHOD CL_GUI_FRONTEND_SERVICES=>DIRECTORY_LIST_FILES
      EXPORTING
        DIRECTORY                   = l_dir
        FILTER                      = l_filter
        FILES_ONLY                  = 'X'
        DIRECTORIES_ONLY            = ''
      CHANGING
        FILE_TABLE                  = lt_dir
        COUNT                       = l_count
      EXCEPTIONS
        CNTL_ERROR                  = 1
        DIRECTORY_LIST_FILES_FAILED = 2
        WRONG_PARAMETER             = 3
        ERROR_NO_GUI                = 4
        others                      = 5
        .
  IF SY-SUBRC <> 0.
       raise directory.
  ENDIF.
* Excel-Upload Planungsprozessor.                          "SPC_1270022
  if sy-cprog =  'RPCPPXUP' or                             "SPC_1270022
     sy-cprog cs 'FLEX_UPL' .                              "SPC_1270022
     export lt_dir to memory id 'PP_FLEX_UPL_DIR'.         "SPC_1270022
  endif.                                                   "SPC_1270022

* Part 3: Fill the oujtput table with the files.

  clear et_directory[].

  loop at lt_dir assigning <fs_data>.
    if ( <fs_data>-filename ne 'dir_file.bat' ) and
       ( <fs_data>-filename ne 'dir_file.txt' ) .
       append <fs_data>-filename to et_directory.
    endif.
  endloop.


endform.
* **************************************************
