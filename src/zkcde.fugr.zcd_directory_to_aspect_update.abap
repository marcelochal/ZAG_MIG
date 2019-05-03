FUNCTION ZCD_DIRECTORY_TO_ASPECT_UPDATE.
*"--------------------------------------------------------------------
*"*"Interface local:
*"  IMPORTING
*"     VALUE(I_PATH) LIKE  RLGRAP-FILENAME
*"     VALUE(I_FILE_ID) LIKE  KCDEFILE-FILE_ID DEFAULT SPACE
*"     VALUE(I_DECIMAL_SEP) TYPE  C DEFAULT ','
*"     VALUE(I_JMT_TMJ)
*"     VALUE(I_SEPARATOR) TYPE  C DEFAULT ';'
*"     VALUE(I_APPL) TYPE  KCDU_EXCEL_APPL
*"     VALUE(I_TEST) TYPE  KCDU_BYTE DEFAULT SPACE
*"  TABLES
*"      E_PROT TYPE  KCDU_PROT
*"      XT_PROT_KPP TYPE  KCDE_YT_PROT_KPP OPTIONAL
*"  EXCEPTIONS
*"      DIRECTORY_READ
*"--------------------------------------------------------------------
  DATA: L_DIRECTORY TYPE KCDE_DIRECTORY WITH HEADER LINE.
  DATA: L_PURE_PATH LIKE  RLGRAP-FILENAME.

  CALL FUNCTION 'KCD_FRONT_END_DIRECTORY_READ'
       EXPORTING
            I_PATH              = I_PATH
       IMPORTING
            E_PURE_PATH         = L_PURE_PATH
       TABLES
            E_DIRECTORY         = L_DIRECTORY
       EXCEPTIONS
            DOWNLOAD            = 1
            UPLOAD              = 2
            EXECUTE             = 3
            DIRECTORY_NOT_EXIST = 4
            DIRECTORY           = 5
            OTHERS              = 6.
  IF SY-SUBRC <> 0. RAISE DIRECTORY_READ. ENDIF.

  LOOP AT  L_DIRECTORY .
    SET UPDATE TASK LOCAL.
    IF L_DIRECTORY CP '*.CSV' OR L_DIRECTORY CP '*.TXT'.
      CASE I_APPL.
        WHEN C_KPP.
          CALL FUNCTION 'KCD_FILE_TO_PP_UPDATE'
               EXPORTING
                    I_PATH        = L_PURE_PATH
                    I_FILENAME    = L_DIRECTORY
                    I_FILE_ID     = I_FILE_ID
                    I_SEPARATOR   = I_SEPARATOR
                    I_DECIMAL_SEP = I_DECIMAL_SEP
                    I_JMT_TMJ     = I_JMT_TMJ
               TABLES
                    XT_PROT_KPP   = XT_PROT_KPP
               EXCEPTIONS
                    OTHERS        = 1.
          IF SY-SUBRC <> 0. MESSAGE X001(KX). ENDIF.
        WHEN C_KCD.
          CALL FUNCTION 'KCD_FILE_TO_ASPECT_UPDATE'
               EXPORTING
                    I_PATH        = L_PURE_PATH
                    I_FILENAME    = L_DIRECTORY
                    I_SEPARATOR   = I_SEPARATOR
                    I_DECIMAL_SEP = I_DECIMAL_SEP
                    I_JMT_TMJ     = I_JMT_TMJ
                    I_TEST        = I_TEST
               TABLES
                    E_PROT        = E_PROT
               EXCEPTIONS
                    OTHERS        = 1.
          IF SY-SUBRC <> 0. MESSAGE X001(KX). ENDIF.
      ENDCASE.
    ENDIF.
    commit work.
  ENDLOOP.
ENDFUNCTION.
