*--------------------------------------------------------------------*
*               P R O J E T O    A G I R - T A E S A                 *
*--------------------------------------------------------------------*
* Consultoria .....: I N T E C H P R O                               *
* Res. ABAP........: Francisco Silva                                 *
* Res. Funcional...: Francisco Silva                                 *
* Módulo...........: FI                                              *
* Programa.........: ZRAG_CARGA_ZPCT_PGTO_FOR                        *
* Transação........: N/A                                             *
* Tipo de Programa.: REPORT                                          *
* Request..........: SHDK900281                                      *
* Objetivo.........: Carga de dados da tabela ZPAGFOR                *
*--------------------------------------------------------------------*
* Change Control:                                                    *
* Version | Date      | Who                 |   What                 *
*--------------------------------------------------------------------*
*    1.00 | 28/03/19  | Francisco Silva     |   Versão Inicial       *
**********************************************************************
REPORT  zrag_carga_zpct_pgto_for.

*--------------------------------------------------------------------*
* Variáveis                                                          *
*--------------------------------------------------------------------*
DATA:      gv_tabix    TYPE syst_tabix.

*--------------------------------------------------------------------*
* Constantes                                                         *
*--------------------------------------------------------------------*
CONSTANTS: gc_x        TYPE char1       VALUE 'X'.


*--------------------------------------------------------------------*
* Tabelas Internas                                                   *
*--------------------------------------------------------------------*
DATA:      gt_dados   TYPE TABLE OF zpct_pgto_for.

*--------------------------------------------------------------------*
* Estruturas                                                         *
*--------------------------------------------------------------------*
DATA:      gs_dados   TYPE zpct_pgto_for.

*--------------------------------------------------------------------*
* Tela                                                               *
*--------------------------------------------------------------------*
SELECTION-SCREEN BEGIN OF BLOCK b2 WITH FRAME TITLE TEXT-002.

PARAMETERS p_file LIKE ibipparms-path OBLIGATORY DEFAULT 'C:\'.
SELECTION-SCREEN BEGIN OF LINE.
PARAMETERS p_cabe  AS CHECKBOX USER-COMMAND sy-ucomm DEFAULT 'CABEC'.
SELECTION-SCREEN COMMENT 3(29) TEXT-003 FOR FIELD p_lines.
PARAMETERS p_lines       TYPE int1.
SELECTION-SCREEN END OF LINE.

SELECTION-SCREEN END OF BLOCK b2.

*--------------------------------------------------------------------*
* Evento AT SELECTION-SCREEN OUTPUT                                  *
*--------------------------------------------------------------------*
AT SELECTION-SCREEN OUTPUT.

  IF p_cabe EQ gc_x.

    LOOP AT SCREEN.
      CHECK screen-name = '%_P_LINES_%_APP_%-TEXT' OR screen-name = 'P_LINES'.
      screen-input = 1.
      MODIFY SCREEN.
    ENDLOOP.

    IF p_cabe = gc_x AND p_lines IS INITIAL.
      p_lines = 1.
    ENDIF.

  ELSE.

    p_lines = 0.

    LOOP AT SCREEN.
      CHECK screen-name = '%_P_LINES_%_APP_%-TEXT' OR screen-name = 'P_LINES'.
      screen-input = 0.
      MODIFY SCREEN.
    ENDLOOP.

  ENDIF.

*--------------------------------------------------------------------*
* Evento AT SELECTION-SCREEN ON VALUE-REQUEST                        *
*--------------------------------------------------------------------*
AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_file.

  PERFORM f_help_dir_arq CHANGING p_file.

*--------------------------------------------------------------------*
* Evento START-OF-SELECTION                                          *
*--------------------------------------------------------------------*
START-OF-SELECTION.

  PERFORM f_status_progress USING  '25' TEXT-101.
  PERFORM f_carrega_arquivo TABLES gt_dados USING p_file.
  PERFORM f_status_progress USING  '50' TEXT-102.
  PERFORM f_valida_arquivo.

*&---------------------------------------------------------------------*
*&      Form  F_CARREGAR_ARQUIVO
*&---------------------------------------------------------------------*
*       Faz upload do arquivo de entrada
*----------------------------------------------------------------------*
FORM f_carrega_arquivo  TABLES   pt_file  TYPE table
                        USING    p_file.

  DATA: l_arq            TYPE string,
        l_file_extension TYPE toadd-doc_type,
        ld_scol          TYPE i VALUE '1',
        ld_srow          TYPE i VALUE '1',
        ld_ecol          TYPE i VALUE '256',
        ld_erow          TYPE i VALUE '65536'.

  l_arq = p_file.

  PERFORM f_get_file_extension USING p_file l_file_extension.

  IF l_file_extension(3) = 'XLS' OR l_file_extension(3) = 'xls'.

    PERFORM f_upload_excel_file TABLES  pt_file
                              USING   p_file
                                      ld_scol
                                      ld_srow
                                      ld_ecol
                                      ld_erow.
  ELSE.
    CALL FUNCTION 'GUI_UPLOAD'
      EXPORTING
        filename                = l_arq
        filetype                = 'DAT'
      TABLES
        data_tab                = pt_file
      EXCEPTIONS
        file_open_error         = 1
        file_read_error         = 2
        no_batch                = 3
        gui_refuse_filetransfer = 4
        invalid_type            = 5
        no_authority            = 6
        unknown_error           = 7
        bad_data_format         = 8
        header_not_allowed      = 9
        separator_not_allowed   = 10
        header_too_long         = 11
        unknown_dp_error        = 12
        access_denied           = 13
        dp_out_of_memory        = 14
        disk_full               = 15
        dp_timeout              = 16
        OTHERS                  = 17.
    IF sy-subrc <> 0.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
              WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDIF.
  ENDIF.

ENDFORM.                    " F_CARREGAR_ARQUIVO

*&---------------------------------------------------------------------*
*&      FORM  F_STATUS_PROGRESS
*&---------------------------------------------------------------------*
*       Status Do Progresso
*----------------------------------------------------------------------*
*      -->p_porct  porcentagem de execução
*      -->p_text_001  texto de processamento
*----------------------------------------------------------------------*
FORM f_status_progress USING    p_porct TYPE clike
                                p_text TYPE clike.

**> exibe status de progresso
  CALL FUNCTION 'SAPGUI_PROGRESS_INDICATOR'
    EXPORTING
      percentage = p_porct
      text       = p_text.

ENDFORM.                    " f_status_progress

*&---------------------------------------------------------------------*
*&      Form  f_get_file_extension
*&---------------------------------------------------------------------*
FORM f_get_file_extension USING file_name file_extension.

  DATA l_str TYPE string.

  CALL FUNCTION 'SO_SPLIT_FILE_AND_PATH'
    EXPORTING
      full_name     = file_name
    IMPORTING
      stripped_name = l_str.

  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.

  SPLIT l_str AT '.' INTO l_str file_extension.
  TRANSLATE file_extension TO UPPER CASE.

ENDFORM. " f_get_file_extension

*&---------------------------------------------------------------------*
*&      Form  f_upload_excel_file
*&---------------------------------------------------------------------*
FORM f_upload_excel_file TABLES p_table
                         USING  p_file
                                p_scol
                                p_srow
                                p_ecol
                                p_erow.

  DATA : lt_intern TYPE  zkcde_cells OCCURS 0 WITH HEADER LINE.
  FIELD-SYMBOLS : <fs>.
* Has the following format:
*             Row number   | Colum Number   |   Value
*             ---------------------------------------
*      i.e.     1                 1             Name1
*               2                 1             Joe

  DATA : ld_index TYPE i.
* Note: Alternative function module - 'ALSM_EXCEL_TO_INTERNAL_TABLE'

  CALL FUNCTION 'ZCD_EXCEL_OLE_TO_INT_CONVERT'
    EXPORTING
      filename                = p_file
      i_begin_col             = p_scol
      i_begin_row             = p_srow
      i_end_col               = p_ecol
      i_end_row               = p_erow
    TABLES
      intern                  = lt_intern
    EXCEPTIONS
      inconsistent_parameters = 1
      upload_ole              = 2
      OTHERS                  = 3.
  IF sy-subrc <> 0.
    MESSAGE e999(z_pm) WITH TEXT-e02.
  ENDIF.

  IF lt_intern[] IS INITIAL.
    MESSAGE e999(z_pm) WITH TEXT-e03.
  ELSE.
    SORT lt_intern BY row col.
    LOOP AT lt_intern.
      IF lt_intern-row LE p_lines.
        CONTINUE.
      ENDIF.
      MOVE lt_intern-col TO ld_index.
      ASSIGN COMPONENT ld_index OF STRUCTURE p_table TO <fs>.
      IF ld_index = 8.
        TRANSLATE lt_intern-value USING ',.'.
      ENDIF.
      MOVE: lt_intern-value TO <fs>.
      AT END OF row.
        APPEND p_table.
        CLEAR p_table.
      ENDAT.
    ENDLOOP.
  ENDIF.

ENDFORM.                    "f_upload_excel_file

*&---------------------------------------------------------------------*
*&      Form  f_help_dir_arq
*&---------------------------------------------------------------------*
FORM f_help_dir_arq CHANGING p_local_arq TYPE ibipparms-path.

  CALL FUNCTION 'F4_FILENAME'
    EXPORTING
      program_name  = syst-cprog
      dynpro_number = syst-dynnr
    IMPORTING
      file_name     = p_local_arq.

ENDFORM.                    " f_help_dir_arq

*&---------------------------------------------------------------------*
*&      Form  f_valida_arquivo
*&---------------------------------------------------------------------*
FORM f_valida_arquivo.

  DATA: lv_reg TYPE numc5.

  LOOP AT gt_dados INTO gs_dados.

    gv_tabix = sy-tabix.

    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
      EXPORTING
        input  = gs_dados-lifnr
      IMPORTING
        output = gs_dados-lifnr.

    MODIFY gt_dados from gs_dados INDEX gv_tabix.

    PERFORM f_valida_fornecedor.

  ENDLOOP.

  IF gt_dados[] IS INITIAL.
    MESSAGE e999(z_pm) WITH TEXT-e01.
  ELSE.
    PERFORM f_status_progress USING  '75'  TEXT-103.
    PERFORM f_atualiza_tabela.
    DESCRIBE TABLE gt_dados LINES lv_reg..
    MESSAGE e999(z_pm) WITH TEXT-104 lv_reg TEXT-105.
  ENDIF.

ENDFORM.                    "f_valida_arquivo

*&---------------------------------------------------------------------*
*&      Form  f_valida_fornecedor
*&---------------------------------------------------------------------*
FORM f_valida_fornecedor.

  SELECT COUNT( * )
    FROM lfa1
   WHERE lifnr EQ gs_dados-lifnr.

  IF sy-subrc IS NOT INITIAL.
    DELETE gt_dados INDEX gv_tabix.
  ENDIF.

ENDFORM.                    "f_valida_fornecedor

*&---------------------------------------------------------------------*
*&      Form  f_atualiza_tabela
*&---------------------------------------------------------------------*
FORM f_atualiza_tabela.

  DELETE FROM zpct_pgto_for.
  COMMIT WORK.

  MODIFY zpct_pgto_for FROM TABLE gt_dados.
  COMMIT WORK.

ENDFORM.                    "f_atualiza_tabela
