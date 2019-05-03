FUNCTION ZCD_FILE_TO_ASPECT_UPDATE.
*"--------------------------------------------------------------------
*"*"Interface local:
*"  IMPORTING
*"     VALUE(I_PATH) LIKE  RLGRAP-FILENAME
*"     VALUE(I_FILENAME) LIKE  RLGRAP-FILENAME
*"     VALUE(I_SEPARATOR) TYPE  C DEFAULT ';'
*"     VALUE(I_DECIMAL_SEP) TYPE  C DEFAULT ','
*"     VALUE(I_JMT_TMJ)
*"     VALUE(I_TEST) TYPE  KCDU_BYTE DEFAULT SPACE
*"  TABLES
*"      E_PROT TYPE  KCDU_PROT
*"--------------------------------------------------------------------
*{ Definitionen                                                      .
  DATA: L_FILENAME     LIKE RLGRAP-FILENAME.
  DATA: L_INTERN       TYPE KCDE_INTERN.
  DATA: L_RA_SEND      TYPE KCDE_RA_SEND WITH HEADER LINE.

  DATA: L_FILE_ID  LIKE KCDEDATAR-FILE_ID,
        L_SUBRC    LIKE SY-SUBRC.
  DATA: L_EXTPROTNR TYPE KCDU_EXTPROTNR.

DEFINE APPEND_PROT.
  CLEAR E_PROT.
  E_PROT-FILENAME = &1.
  E_PROT-REPID    = &2.
  E_PROT-FILE_ID  = &3.
  E_PROT-NUMBR    = &4.
  E_PROT-SUBRC    = &5.
  APPEND E_PROT.
END-OF-DEFINITION.
*}
*{ Initialisierung
  G_APPL = C_KCD.
  REFRESH L_INTERN.

  PERFORM __BUILD_FULL_PATH USING I_PATH I_FILENAME L_FILENAME.
  PERFORM _GET_RANGE_ATTR_FROM_FILENAME USING G_APPL I_FILENAME
                                        L_FILE_ID L_SUBRC.

*  IF L_SUBRC <> 0.
*    APPEND_PROT I_FILENAME ' ' L_FILE_ID ' ' 16.
*    EXIT.
*  ENDIF.
* 31.1.00: Es wird unterschieden ob kein  generischer Dateiname oder  *
* mehr als einer paßt.
Case L_subrc.
    when '0'.
    when '4'.
* Kein Generischer Dateiname paßt.
       APPEND_PROT I_FILENAME ' ' L_FILE_ID ' ' 16.
       EXIT.
    when '8'.
* Mehr als ein generischer Dateiname paßt.
       APPEND_PROT I_FILENAME ' ' L_FILE_ID ' ' 17.
       EXIT.
    when others.
       MESSAGE X001(KX) .

endcase.

*}
*{ Datei einlesen und Konvertierung ins interne Cellenformat
*/ Konvertierung ins Senderstrukturformat
  CALL FUNCTION 'KCD_CSV_FILE_TO_INTERN_CONVERT'
       EXPORTING
            I_FILENAME  = L_FILENAME
            I_SEPARATOR = I_SEPARATOR
       TABLES
            E_INTERN    = L_INTERN
       EXCEPTIONS
            UPLOAD_CSV      = 1
            UPLOAD_FILETYPE = 2
            OTHERS          = 3.
  CASE SY-SUBRC.
    WHEN 0.    "OK
    WHEN 1.    APPEND_PROT I_FILENAME ' ' L_FILE_ID
                                          ' ' 32.   "upload_csv
    WHEN 2.    APPEND_PROT I_FILENAME ' ' L_FILE_ID
                                          ' ' 33.   "upload_filetype
    WHEN OTHERS.
      MESSAGE X001(KX) .
  ENDCASE.
  IF SY-SUBRC <> 0.
    APPEND_PROT I_FILENAME ' ' L_FILE_ID ' ' 32.
  ENDIF.

  CALL FUNCTION 'KCD_INTERN_TO_T242S_CONVERT'
       EXPORTING
            I_FILE_ID     = L_FILE_ID
            I_DECIMAL_SEP = I_DECIMAL_SEP
            I_JMT_TMJ     = I_JMT_TMJ
       TABLES
            INTERN        = L_INTERN
            E_SENDER      = L_RA_SEND
       EXCEPTIONS
            OTHERS        = 1.
  IF SY-SUBRC <> 0. MESSAGE X001(KX). ENDIF.
*}
*{
  IF I_TEST = ON.
    PERFORM __WRITE_TEST_OUTPUT TABLES L_RA_SEND.
  ENDIF.
  PERFORM PACK_L_RA_SEND TABLES L_RA_SEND.
  LOOP AT L_RA_SEND.
    CALL FUNCTION 'KCD_SENDER_TO_ASPECT_UPDATE'
         EXPORTING
              I_REPID            = L_RA_SEND-DEST
              I_TEST             = I_TEST
         TABLES
              I_SENDER           = L_RA_SEND-TAB
         EXCEPTIONS
              OPEN_EIS           = 1
              CLOSE_EIS          = 2
              NO_SENDERSTRUCTURE = 3
              OTHERS             = 4.
    L_SUBRC = SY-SUBRC.
    CALL FUNCTION 'KCD_MESSAGES_PROTNR_GET'
         IMPORTING
              PROTNR  = L_EXTPROTNR.

    APPEND_PROT I_FILENAME L_RA_SEND-DEST L_FILE_ID
                                          L_EXTPROTNR L_SUBRC.
  ENDLOOP.
*}
ENDFUNCTION.

*&---------------------------------------------------------------------*
*&      Form  PACK_L_RA_SEND
*&---------------------------------------------------------------------*
*       Sendersätze aus verschiedenen Datenbereichen mit einer Sender
*       Senderstruktur zusammenfassen
*----------------------------------------------------------------------*
FORM PACK_L_RA_SEND TABLES C_RA_SEND TYPE KCDE_RA_SEND.
  DATA: L_SEND   TYPE KCDE_RA_SEND WITH HEADER LINE.
  DATA: L_WA_RA   TYPE KCDE_SENDER_STRUC.
  DATA: L_OLD_DEST LIKE C_RA_SEND-DEST.
  DATA: L_APPEND LIKE OFF.
  SORT C_RA_SEND BY DEST.
  CLEAR L_OLD_DEST.
  L_APPEND = OFF.
  LOOP AT C_RA_SEND.
    IF C_RA_SEND-DEST <> L_OLD_DEST.
      IF NOT L_OLD_DEST IS INITIAL.
        APPEND L_SEND.
        L_APPEND = OFF.
      ENDIF.
      REFRESH L_SEND-TAB.
      L_OLD_DEST  = C_RA_SEND-DEST.
      L_SEND-DEST = C_RA_SEND-DEST.
    ENDIF.
    LOOP AT C_RA_SEND-TAB INTO L_WA_RA.
      APPEND L_WA_RA TO L_SEND-TAB.
      L_APPEND = ON.
    ENDLOOP.
  ENDLOOP.
  IF L_APPEND = ON.
    APPEND L_SEND.
  ENDIF.
  C_RA_SEND[] = L_SEND[].
ENDFORM.                               " PACK_L_RA_SEND
