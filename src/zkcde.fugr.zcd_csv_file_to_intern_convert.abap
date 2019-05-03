FUNCTION ZCD_CSV_FILE_TO_INTERN_CONVERT.
*"--------------------------------------------------------------------
*"*"Interface local:
*"  IMPORTING
*"     VALUE(I_FILENAME) LIKE  RLGRAP-FILENAME
*"     VALUE(I_SEPARATOR) TYPE  C
*"  TABLES
*"      E_INTERN TYPE  KCDE_INTERN
*"  EXCEPTIONS
*"      UPLOAD_CSV
*"      UPLOAD_FILETYPE
*"--------------------------------------------------------------------
  DATA: CSV_FORMAT TYPE  KCDU_SRECS.
  DATA: WA_ROW     TYPE  KCDU_SREC.
  DATA: L_SEPARATOR TYPE  C.

  DATA: L_NEW_UPLOAD LIKE ON VALUE ON.
  FIELD-SYMBOLS:  <L_TABULATOR>.
* Umstellen auf FB: FILE_OPEN und FILE_NEXT_RECORD
*
  IF L_NEW_UPLOAD = ON.
    CALL FUNCTION 'FILE_OPEN'
         EXPORTING
              FILNM             = I_FILENAME
              UPL               = 'X'
              FILFMT            = 'T'
* Hinweis 0161163
*              OPENMODE          = 'BIN'
*
         EXCEPTIONS
              LOGNAME_NOT_FOUND = 1
              FILE_NOT_OPENED   = 2.
    IF SY-SUBRC <> 0.
      RAISE UPLOAD_CSV.
    ENDIF.
    DO.
      CALL FUNCTION 'FILE_NEXT_RECORD'
           IMPORTING
                NEXT_RECORD = WA_ROW
           EXCEPTIONS
                NO_RECORD   = 1.
      IF SY-SUBRC <> 0. EXIT. ENDIF.
      APPEND WA_ROW TO CSV_FORMAT.
    ENDDO.
  ELSE.
* This should never happen.

*    CALL FUNCTION 'WS_UPLOAD'
*         EXPORTING
*              FILENAME            = I_FILENAME
*         TABLES
*              DATA_TAB            = CSV_FORMAT
*         EXCEPTIONS
*              CONVERSION_ERROR    = 1
*              FILE_OPEN_ERROR     = 2
*              FILE_READ_ERROR     = 3
*              INVALID_TABLE_WIDTH = 4
*              INVALID_TYPE        = 5
*              NO_BATCH            = 6
*              UNKNOWN_ERROR       = 7
*              OTHERS              = 8.
*    IF SY-SUBRC <> 0.
*      RAISE UPLOAD_CSV.
*    ENDIF.
  ENDIF.
  IF I_FILENAME CP '*.CSV'.
    L_SEPARATOR = I_SEPARATOR.
  ELSEIF I_FILENAME CP '*.TXT'.
*    ASSIGN L_SEPARATOR TO <L_TABULATOR> TYPE 'X'.
*    <L_TABULATOR> = C_HEX_TAB.
     class cl_abap_char_utilities definition load.
     l_separator = cl_abap_char_utilities=>horizontal_tab.
  ELSE.
    RAISE UPLOAD_FILETYPE.
  ENDIF.
  PERFORM SEPARATED_TO_INTERN_CONVERT TABLES CSV_FORMAT
                                             E_INTERN
                                      USING  L_SEPARATOR.
ENDFUNCTION.
