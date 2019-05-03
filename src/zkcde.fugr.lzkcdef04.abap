*-------------------------------------------------------------------
***INCLUDE LZCDEF04 .
*-------------------------------------------------------------------
FORM __BUILD_FULL_PATH USING I_PATH     LIKE RLGRAP-FILENAME
                             I_FILENAME LIKE RLGRAP-FILENAME
                             E_FILENAME LIKE RLGRAP-FILENAME.
  DATA: L_LENGTH TYPE I.
  L_LENGTH = STRLEN( I_PATH ).
  IF L_LENGTH > 0.
    E_FILENAME = I_PATH.
    E_FILENAME+L_LENGTH = '\'.
    L_LENGTH = L_LENGTH + 1.
    E_FILENAME+L_LENGTH = I_FILENAME.
  ELSE.
    E_FILENAME = I_FILENAME.
  ENDIF.
ENDFORM.                               " __BUILD_FULL_PATH

*----------------------------------------------------------------------*
FORM _GET_RANGE_ATTR_FROM_FILENAME
                        USING I_APPL     LIKE C_KPP
                              I_FILENAME LIKE RLGRAP-FILENAME
                              E_FILE_ID  LIKE KCDEDATAR-FILE_ID
                              E_SUBRC    LIKE SY-SUBRC.
  DATA: LT_FILE_ID TYPE KCDE_YT_FILE_ID.

  CALL FUNCTION 'KCD_FILE_ID_FOR_FILENAME_GET'
       EXPORTING
            I_APPL     = I_APPL
            I_FILENAME = I_FILENAME
       IMPORTING
            ET_FILE_ID = LT_FILE_ID.
  READ TABLE LT_FILE_ID TRANSPORTING NO FIELDS INDEX 2.
  IF SY-SUBRC = 0.
    E_SUBRC = 8.
    EXIT.
  ENDIF.

  READ TABLE LT_FILE_ID INTO E_FILE_ID INDEX 1.
  IF SY-SUBRC <> 0.
    E_SUBRC = 4.
    EXIT.
  ENDIF.
ENDFORM.                               " _GET_RANGE_ATTR_FROM_FILENAME

*----------------------------------------------------------------------*
FORM _LOAD_FILE TABLES E_FILE TYPE KCDU_EXCEL_FILE
                USING  I_APPL LIKE C_KPP.
  DATA: L_LINES TYPE I.
  DESCRIBE TABLE E_FILE LINES L_LINES.
  CHECK L_LINES = 0.
  SELECT * FROM KCDEFILE INTO TABLE E_FILE
                         WHERE APPL = I_APPL.
ENDFORM.                               " _LOAD_FILE
