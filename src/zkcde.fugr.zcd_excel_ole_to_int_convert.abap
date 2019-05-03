FUNCTION ZCD_EXCEL_OLE_TO_INT_CONVERT.
*"----------------------------------------------------------------------
*"*"Interface local:
*"  IMPORTING
*"     VALUE(FILENAME) LIKE  RLGRAP-FILENAME
*"     VALUE(I_BEGIN_COL) TYPE  I
*"     VALUE(I_BEGIN_ROW) TYPE  I
*"     VALUE(I_END_COL) TYPE  I
*"     VALUE(I_END_ROW) TYPE  I
*"  TABLES
*"      INTERN STRUCTURE  ZKCDE_CELLS
*"  EXCEPTIONS
*"      INCONSISTENT_PARAMETERS
*"      UPLOAD_OLE
*"----------------------------------------------------------------------
  DATA: EXCEL_TAB TYPE KCDE_SENDER.
  DATA: SEPARATOR TYPE C.
  FIELD-SYMBOLS: <FIELD>.
  DATA: APPLICATION TYPE OLE2_OBJECT,
        WORKBOOK    TYPE OLE2_OBJECT,
        RANGE       TYPE OLE2_OBJECT,
        WORKSHEET   TYPE OLE2_OBJECT.
  DATA: H_CELL  TYPE OLE2_OBJECT.
  DATA: H_CELL1 TYPE OLE2_OBJECT.

  DEFINE M_MESSAGE.
    CASE SY-SUBRC.
      WHEN 0.
      WHEN 1.
        MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
                WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
      WHEN OTHERS. RAISE UPLOAD_OLE.
    ENDCASE.
  END-OF-DEFINITION.

  IF I_BEGIN_ROW > I_END_ROW. RAISE INCONSISTENT_PARAMETERS. ENDIF.
  IF I_BEGIN_COL > I_END_COL. RAISE INCONSISTENT_PARAMETERS. ENDIF.



  IF APPLICATION-HEADER = SPACE OR APPLICATION-HANDLE = -1.
    CREATE OBJECT APPLICATION 'Excel.Application'.
    M_MESSAGE.
  ENDIF.
  CALL METHOD  OF APPLICATION    'Workbooks' = WORKBOOK.
  M_MESSAGE.
  CALL METHOD  OF WORKBOOK 'Open'    EXPORTING #1 = FILENAME.
  M_MESSAGE.
*  set property of application 'Visible' = 1.
*  m_message.

  GET PROPERTY OF  APPLICATION 'ACTIVESHEET' = WORKSHEET.
  M_MESSAGE.

  CALL METHOD OF WORKSHEET 'Cells' = H_CELL
      EXPORTING #1 = I_BEGIN_ROW #2 = I_BEGIN_COL.
  M_MESSAGE.

  CALL METHOD OF WORKSHEET 'Cells' = H_CELL1
      EXPORTING #1 = I_END_ROW #2 = I_END_COL.
  M_MESSAGE.

  CALL METHOD  OF WORKSHEET 'RANGE' = RANGE
                 EXPORTING #1 = H_CELL #2 = H_CELL1.
  M_MESSAGE.
  CALL METHOD OF RANGE 'SELECT'.
  M_MESSAGE.
* copy to Clippboard
  CALL METHOD OF RANGE 'COPY'.
  M_MESSAGE.
*  free   object application.
  M_MESSAGE.

* Without flush, CLPB_IMPORT does not find the data    "SEVERING 5/99
  CALL FUNCTION 'CONTROL_FLUSH'                        "SEVERING 5/99
       EXCEPTIONS    OTHERS = 3.                       "SEVERING 5/99

  CALL FUNCTION 'CLPB_IMPORT'
       TABLES
            DATA_TAB   = EXCEL_TAB
       EXCEPTIONS
            CLPB_ERROR = 1
            OTHERS     = 2.
  IF SY-SUBRC <> 0. MESSAGE X001(KX). ENDIF.
* ASSIGN SEPARATOR TO <FIELD> TYPE 'X'.                 "H916967
* <FIELD> = C_HEX_TAB.                                  "H916967
  SEPARATOR = CL_ABAP_CHAR_UTILITIES=>HORIZONTAL_TAB.   "H916967

  PERFORM SEPARATED_TO_INTERN_CONVERT TABLES EXCEL_TAB INTERN
                                      USING  SEPARATOR.

  set property OF APPLICATION 'CutCopyMode' = 0.
  M_MESSAGE.

  CALL METHOD OF APPLICATION 'QUIT'.
  M_MESSAGE.
  FREE   OBJECT APPLICATION.
  M_MESSAGE.
ENDFUNCTION.
