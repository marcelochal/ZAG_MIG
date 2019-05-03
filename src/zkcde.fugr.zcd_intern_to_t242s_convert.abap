FUNCTION ZCD_INTERN_TO_T242S_CONVERT.
*"--------------------------------------------------------------------
*"*"Interface local:
*"  IMPORTING
*"     VALUE(I_FILE_ID) LIKE  KCDEDATAR-FILE_ID
*"     VALUE(I_DECIMAL_SEP) TYPE  C DEFAULT ','
*"     VALUE(I_JMT_TMJ)
*"  TABLES
*"      INTERN TYPE  KCDE_INTERN
*"      E_SENDER TYPE  KCDE_RA_SEND
*"--------------------------------------------------------------------
  DATA: L_DATA_RANGE TYPE KCDU_EXCEL_DATAR WITH HEADER LINE,
        L_SENDER     TYPE KCDE_SENDER      WITH HEADER LINE,
        L_HEAD       TYPE KCDU_EXCEL_HEAD,
        L_KEY        TYPE T_KEY_FLAG_TYPE,
        L_R_H        TYPE KCDU_EXCEL_R_H.
  DATA: L_LINES TYPE I.

  SORT INTERN BY ROW COL.
  PERFORM DATAR_LOAD  TABLES L_DATA_RANGE
                      USING  I_FILE_ID C_KCD.
  PERFORM DISCRIPTION_LOAD  TABLES L_HEAD L_KEY L_R_H
                            USING  I_FILE_ID L_DATA_RANGE-RANGE_ID
                                   ON C_KCD.
  PERFORM ENRICH_INTERN TABLES INTERN L_DATA_RANGE L_HEAD L_KEY.
  SORT INTERN BY ROW COL.
  LOOP AT L_DATA_RANGE.
    PERFORM DISCRIPTION_LOAD  TABLES L_HEAD L_KEY L_R_H
                              USING  I_FILE_ID L_DATA_RANGE-RANGE_ID
                                     OFF C_KCD.
    REFRESH L_SENDER.
    PERFORM SENDER_ROW_FILL   TABLES INTERN
                                     L_SENDER
                                     L_HEAD
                                     L_KEY
                                     L_R_H
*                              using intern
*                                    l_data_range
                               USING  L_DATA_RANGE
                                     I_DECIMAL_SEP
                                     I_JMT_TMJ.
    DESCRIBE TABLE L_SENDER LINES L_LINES.
    IF L_LINES > 0.
      E_SENDER-RANGE_ID = L_DATA_RANGE-RANGE_ID.
      E_SENDER-DEST     = L_DATA_RANGE-DEST.
      E_SENDER-TAB      = L_SENDER[].
      APPEND E_SENDER.
    ENDIF.
  ENDLOOP.
ENDFUNCTION.
