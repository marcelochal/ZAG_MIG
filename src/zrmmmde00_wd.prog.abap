REPORT zrmmmde00_wd MESSAGE-ID vs.

TYPES:
  BEGIN OF   ty_s_table_list,
    tab       TYPE tabnam,             " Nome da tabela
    ddtext    TYPE as4text,            " Descrição breve dos objetos repository
    count     TYPE sapf020_numread,    " Nº de registros de dados lidos
    count_del TYPE sapf020_numdel,     " Nº de registros de dados eliminados
    count_err TYPE numdel,             " Número de entradas de tabelas eliminadas
  END OF ty_s_table_list,

*  BEGIN OF   ty_s_mara,
*    matnr TYPE mara-matnr,  " Nº do material
*    kzwsm TYPE mara-kzwsm,  " Utilização/categorias de unidades de medida
*  END OF ty_s_mara,

  ty_t_table_list TYPE TABLE OF ty_s_table_list WITH UNIQUE SORTED KEY key_01           COMPONENTS tab.

TABLES:
  ampl,   " Tabela das peças de fabricante admitidas                    01
  ebew,   " Avaliação estoque ordem de cliente                          02
  ebewh,  " Avaliação estoque ordem do cliente - histórico              03
  maex,   " Mestre de materiais: controle legal                         04
  makt,   " Textos breves de material                                   05
  mape,   " Mestre de material: file de controle exportações            06
  mapl,   " Atribuição de planos a materiais                            07
  mara,   " Dados gerais de material                                    08
  marc,   " Dados de centro para material                               09
  march,  " Segmento C mestre de material - histórico                   10
  mard,   " Dados de depósito para material                             11
  mardh,  " Segmento de depósito mestre de material - histórico         12
  marm,   " Unidades de medida para material                            13
  mast,   " Ligação material - lista técnica                            14
  maw1,   " Mestre de material: campos proposta e campos especiais SAM  15
  mbew,   " Avaliação do material                                       16
  mbewh,  " Avaliação de material - histórico                           17
  mch1,   " Lotes (para administr.de lotes a nível de todos os centros) 18
  mcha,   " Lotes                                                       19
  mchb,   " Estoques de lotes                                           20
  mchbh,  " Estoques de lotes - histórico                               21
  mean,   " Nº Europeu de Artigo (EAN) do material                      22
  mkal,   " Versões de produção por material                            23
  mkol,   " Estoques especiais do fornecedor                            24
  mkolh,  " Estoques especiais do fornecedor - histórico                25
  mkop,   " Segmento de preços-consignação                              26
  mlan,   " Classificação de impostos para material                     27
  mlgn,   " Dados de material por sistema de depósito                   28
  mlgt,   " Dados de material por ctg.de depósito                       29
  moff,   " Mestres de material ainda pendentes                         30
  msca,   " Carteira de ordens-cliente junto ao fornecedor              31
  mska,   " Estoque por ordem do cliente                                32
  mskah,  " Estoque para ordem de cliente - histórico                   33
  msku,   " Estoques especiais no cliente                               34
  mskuh,  " Estoques especiais do cliente - histórico                   35
  mslb,   " Estoques especiais no fornecedor                            36
  mslbh,  " Estoques especiais do fornecedor - histórico                37
  msoa,   " Total carteira de ordens-cliente junto ao fornecedor        38
  mspr,   " Estoque de projeto                                          39
  msprh,  " Estoque para projeto - histórico                            40
  mssa,   " Total carteira de ordens-cliente                            41
  mssl,   " Total estoques especiais junto ao fornecedor                42
  mssq,   " Total estoques de projeto                                   43
  msta,   " Status do mestre material                                   44
  mver,   " Consumos de material                                        45
  mvke,   " Dados de venda para material                                46
  myms,   " Materiais relevantes para LIFO                              47
  obew,   " Estoque avaliado colocado à disposição do fornecedor        48
  obewh,  " Estoque avaliado colocado à dispos.do fornecedor Histórico  49
  qbew,   " Avaliação estoque para projeto                              50
  qbewh,  " Avaliação estoque para projeto - histórico                  51
  qmat,   " Tipo de controle - parâmetros dependentes de material       52
  t000,   " Mandantes                                                   53
  t100,   " Mensagens                                                   54
  wbew,   " Avaliação de ingrediente ativo                              55
  pgmi,   " Product Group/Member Allocation                             56
  pgzu,   " Product Group/Member Quantity Conversions                   57
  cdhdr,  " Cabeçalho do documento de modificação                       58
  cdpos,  "                                                             59
  stxh,   "                                                             60
  stxl,   "                                                             61
  nriv,   "                                                             62
  t001,   "                                                             63
  drad.   "                                                             64


SELECTION-SCREEN SKIP 2.

SELECT-OPTIONS:
    p_matnr FOR mara-matnr,
    p_ernam FOR mara-ernam.

PARAMETERS:
  p_test TYPE xtest AS CHECKBOX DEFAULT abap_true.

CLASS:
    zcl_mmde                DEFINITION DEFERRED,
    lcl_progress_indicator  DEFINITION DEFERRED.

DATA: appli            LIKE trse1-appli VALUE 'MM_MARA   ',
      title(30),
      textline1(40),
      textline2(40),
      answer,
      xxxsyslog(32)    TYPE c,
*      gt_itab        LIKE STANDARD TABLE OF ls_itab,
      sy_datum1        LIKE sy-datum,
      sy_uzeit1        LIKE sy-uzeit,
      gs_table_list    TYPE ty_s_table_list,
      gt_table_list    TYPE ty_t_table_list,
      o_mmde           TYPE REF TO zcl_mmde,
      o_prog_ind       TYPE REF TO lcl_progress_indicator,
      lt_ckmlhd        LIKE TABLE OF ckmlhd,
      x                LIKE sy-datar    VALUE 'X',
      appl_m           LIKE rsahd-appl  VALUE 'M',    "Applikation MM
      inflation_active,            "Kennz: InflAblw. ist aktiv
      matnr_initial    LIKE mara-matnr VALUE '',
      pre03_tab        LIKE pre03 OCCURS 0 WITH HEADER LINE,
      clf_object       LIKE rmclf-objek,
      clf_table        LIKE tclt-obtab VALUE 'MARA',
      doc_key          LIKE drad-objky,
      doc_object       LIKE drad-dokob VALUE 'MARA',
      gt_drad          TYPE drad_tab,
      lv_anz_ausp      TYPE syst_dbcnt,
      lv_anz_kssk      TYPE syst_dbcnt,
      lv_test_clfm     TYPE xtest.

DATA: BEGIN OF ws_mara OCCURS 0,
        matnr LIKE mara-matnr,
        kzwsm LIKE mara-kzwsm,
      END   OF ws_mara.

CLASS zcl_mmde DEFINITION FINAL.

  PUBLIC SECTION.

    METHODS:
      fill_alv_output
        IMPORTING
          im_v_dbcnt      TYPE syst_dbcnt
          im_v_table_name TYPE tabname
          im_v_selected   TYPE i,
      get_t_alv_output
        RETURNING
          VALUE(r_result) LIKE gt_table_list,
      set_t_alv_output
        IMPORTING
          im_t_alv_output TYPE ty_t_table_list,
      delete_table
        IMPORTING
          im_t_table TYPE any,
      alv_show.

  PRIVATE SECTION.

    DATA:
      t_alv_output TYPE ty_t_table_list.
    METHODS get_table_name
      IMPORTING
        im_t_table      TYPE any
      RETURNING
        VALUE(r_result) TYPE string.

ENDCLASS.
*&---------------------------------------------------------------------*
*& CLASS DEFINITION LCL_PROGRESS_INDICATOR
*&---------------------------------------------------------------------*
CLASS lcl_progress_indicator DEFINITION.
  PUBLIC SECTION.

* Interface required to serialize the object
    INTERFACES:
      if_serializable_object.

    METHODS:
      constructor
        IMPORTING
          im_v_total TYPE i OPTIONAL
            PREFERRED PARAMETER im_v_total,
      show
        IMPORTING
          VALUE(im_v_text) TYPE any
          im_v_processed   TYPE i OPTIONAL.
  PRIVATE SECTION.

    CONSTANTS:
       ratio_percentage TYPE i VALUE 25.

    DATA:
      total     TYPE i,
      ratio     TYPE decfloat16,
      rtime     TYPE i,
      processed TYPE i.

ENDCLASS.


**********************************************************************
*                         START-OF-SELECTION
**********************************************************************
START-OF-SELECTION.

*  CHECK p_test IS INITIAL.

  CREATE OBJECT o_prog_ind
    EXPORTING
      im_v_total = 64.

  sy_datum1 = sy-datum.
  sy_uzeit1 = sy-uzeit.

* Verificação de autorização Redefinir programas
* Você precisa da autorização S_ADMI_ALL para iniciar o programa
  AUTHORITY-CHECK OBJECT 'S_ADMI_FCD'
  ID 'S_ADMI_FCD' FIELD 'RSET'.
  IF sy-subrc NE 0.
    MESSAGE e203(cz).
*  LEAVE.
*  LEAVE TO TRANSACTION '    '.
  ENDIF.

* ch zu 3.0D - A função não é permitida no cliente produtivo
*               para ser realizado!
*call FUNCTION
  SELECT SINGLE * FROM t000 CLIENT SPECIFIED
                  WHERE mandt = sy-mandt.

  IF t000-cccategory = 'P'.
*  MESSAGE E201(MM).
    MESSAGE ID 'MM' TYPE 'I' NUMBER '201'.
*  LEAVE.
*  LEAVE TO TRANSACTION '    '.
  ENDIF.

* note 389269
  SELECT SINGLE * FROM maw1 WHERE matnr IN p_matnr.     "#EC CI_NOWHERE
  IF sy-subrc EQ 0.
    MESSAGE s201(mm) DISPLAY LIKE 'E'.
    RETURN.
    STOP.
*  LEAVE.
*  LEAVE TO TRANSACTION '    '.
  ENDIF.

* ch zu 3.0D - zusätzliche Sicherheitsabfrage
  IF p_test = space.
    title     = TEXT-001.
    textline1 = TEXT-002.
    textline2 = TEXT-003.
    CLEAR answer.
    CALL FUNCTION 'POPUP_TO_CONFIRM_STEP'
      EXPORTING
        defaultoption = 'N'
        textline1     = textline1
        textline2     = textline2
        titel         = title
      IMPORTING
        answer        = answer
      EXCEPTIONS
        OTHERS        = 1.
    IF answer NE 'J'.
      RETURN.
      STOP.
*    LEAVE TO TRANSACTION '    '.
    ENDIF.
  ENDIF.

  CALL 'C_WRITE_SYSLOG_ENTRY'
    ID 'TYP' FIELD ' '
    ID 'KEY' FIELD 'C00'
    ID 'DATA' FIELD xxxsyslog.

  SET PARAMETER ID 'MAT' FIELD matnr_initial.

*--- Verificando se o processamento de inflação está ativo   ch zu 4.0 ----
  PERFORM check_infl_active.

  DATA:
    lv_where TYPE string VALUE IS INITIAL.

  IF p_matnr[] IS INITIAL.
    lv_where = 'LVORM EQ ABAP_TRUE AND ERNAM IN P_ERNAM'.
  ELSE.
    lv_where = 'LVORM EQ ABAP_TRUE AND MATNR IN P_MATNR AND ERNAM IN P_ERNAM'.
  ENDIF.

  SELECT matnr AS low
      FROM mara
      INTO CORRESPONDING FIELDS OF TABLE p_matnr
      WHERE (lv_where).

  IF syst-subrc IS NOT INITIAL.
    MESSAGE 'Não foi selecionado nenhum material marcado para eliminação' TYPE 'S' DISPLAY LIKE 'E'.
    STOP.
  ELSE.
    p_matnr-sign = 'I'.
    p_matnr-option = 'EQ'.
    MODIFY p_matnr FROM p_matnr TRANSPORTING option sign WHERE low NE space.
  ENDIF.

  CHECK p_matnr IS NOT INITIAL.

  CREATE OBJECT o_mmde.

  CALL METHOD:
    o_mmde->delete_table( marc  ),
    o_mmde->delete_table( march ),
    o_mmde->delete_table( mard  ),
    o_mmde->delete_table( mardh ),
    o_mmde->delete_table( mver  ).

* note 808639: collect KALN1 to delete ML data
  SELECT kaln1 AS kalnr FROM mbew
               INTO CORRESPONDING FIELDS OF TABLE lt_ckmlhd
               WHERE matnr IN p_matnr.
  CALL FUNCTION 'CKML_F_ML_DELETE'
    TABLES
      in_ckmlhd = lt_ckmlhd.

  CALL METHOD:
    o_mmde->delete_table( mbew ),
    o_mmde->delete_table( mbewh ).


  SELECT kaln1 AS kalnr FROM ebew
               INTO CORRESPONDING FIELDS OF TABLE lt_ckmlhd
               WHERE matnr IN p_matnr.
  CALL FUNCTION 'CKML_F_ML_DELETE'
    TABLES
      in_ckmlhd = lt_ckmlhd.

  CALL METHOD:
    o_mmde->delete_table( ebew  ),
    o_mmde->delete_table( ebewh ).

  SELECT kaln1 AS kalnr FROM qbew
               INTO CORRESPONDING FIELDS OF TABLE lt_ckmlhd
               WHERE matnr IN p_matnr.
  CALL FUNCTION 'CKML_F_ML_DELETE'
    TABLES
      in_ckmlhd = lt_ckmlhd.

  CALL METHOD:
    o_mmde->delete_table( qbew  ),
    o_mmde->delete_table( qbewh ).

  SELECT kaln1 AS kalnr FROM obew
               INTO CORRESPONDING FIELDS OF TABLE lt_ckmlhd
               WHERE matnr IN p_matnr.
  CALL FUNCTION 'CKML_F_ML_DELETE'
    TABLES
      in_ckmlhd = lt_ckmlhd.

  CALL METHOD:
    o_mmde->delete_table( obew  ),
    o_mmde->delete_table( obewh ),
    o_mmde->delete_table( wbew  ),
    o_mmde->delete_table( mvke  ),
    o_mmde->delete_table( mlan  ),
    o_mmde->delete_table( mlgn  ),
    o_mmde->delete_table( mlgt  ),
    o_mmde->delete_table( marm  ),
    o_mmde->delete_table( makt  ),
    o_mmde->delete_table( msta  ),
    o_mmde->delete_table( moff  ),
    o_mmde->delete_table( myms  ),
    o_mmde->delete_table( mkal  ),
    o_mmde->delete_table( mean  ),
    o_mmde->delete_table( maex  ),
    o_mmde->delete_table( mape  ),
    o_mmde->delete_table( mast  ),
    o_mmde->delete_table( mapl  ),
    o_mmde->delete_table( qmat  ),
    o_mmde->delete_table( mch1  ),
    o_mmde->delete_table( mcha  ),
    o_mmde->delete_table( mchb  ),
    o_mmde->delete_table( mchbh ),
    o_mmde->delete_table( mkop  ),
    o_mmde->delete_table( mkol  ),
    o_mmde->delete_table( mkolh ),
    o_mmde->delete_table( msku  ),
    o_mmde->delete_table( mskuh ),
    o_mmde->delete_table( mska  ),
    o_mmde->delete_table( mskah ),
    o_mmde->delete_table( mssa  ),
    o_mmde->delete_table( msca  ),
    o_mmde->delete_table( msoa  ),
    o_mmde->delete_table( mslb  ),
    o_mmde->delete_table( mslbh ),
    o_mmde->delete_table( mssl  ),
    o_mmde->delete_table( mspr  ),
    o_mmde->delete_table( msprh ),
    o_mmde->delete_table( mssq  ),
    o_mmde->delete_table( ampl  ).


  LOOP AT p_matnr ASSIGNING FIELD-SYMBOL(<fs_matnr>)..
    clf_object = <fs_matnr>-low.
    IF p_test IS INITIAL.
      lv_test_clfm = abap_true.
    ENDIF.

    CALL FUNCTION 'CLFM_DELETE_CLASSIFICATION'
      EXPORTING
        echt_lauf         = lv_test_clfm     " LIVE RUN DEFAULT X, test run blank
        object            = clf_object       " Object number
        table             = clf_table        " Table name of classifiable object
        type              = abap_true        " Type of call: background (X) or update (' ')
        i_no_lock         = abap_true        " No lock necessary
      IMPORTING
        anz_ausp          = lv_anz_ausp      " Number of deleted characteristic records
        anz_kssk          = lv_anz_kssk      " Number of deleted allocation records
      EXCEPTIONS
        foreign_lock      = 1                " Class of other user blocked
        not_deleted       = 2                " Classification data not deleted
        system_failure    = 3                " System lock error
        table_not_found   = 4                " Table not found
        date_not_allowed  = 5                " Date in record = date of change number
        change_nr_changed = 6
        OTHERS            = 7.

    IF sy-subrc EQ 0.

      CALL METHOD o_mmde->fill_alv_output
        EXPORTING
          im_v_table_name = 'AUSP'
          im_v_dbcnt      = lv_anz_ausp
          im_v_selected   = lv_anz_ausp.

      CALL METHOD o_mmde->fill_alv_output
        EXPORTING
          im_v_table_name = 'KSSK'
          im_v_dbcnt      = lv_anz_kssk
          im_v_selected   = lv_anz_kssk.

      PERFORM f_commit_work.

    ENDIF.
  ENDLOOP.


* note 563071: FUGR CUOB not refreshed by the classification
  CALL FUNCTION 'CUOB_INIT_DATA'.

  LOOP AT ws_mara.
    CALL FUNCTION 'VBWS_MARM_CLASSIFICATION_DEL'
      EXPORTING
        i_mara_matnr   = ws_mara-matnr
        i_mara_kzwsm   = ws_mara-kzwsm
        i_without_marm = 'X'.

    PERFORM f_commit_work.
  ENDLOOP.

*--- Lexcluir condições não necessárias
*--- Excluir as atribuições para o documento
  LOOP AT p_matnr ASSIGNING <fs_matnr>.

    doc_key = <fs_matnr>-low.
    CALL FUNCTION 'DOKUMENTE_ZU_OBJEKT'
      EXPORTING
        key           = doc_key
        objekt        = doc_object
      TABLES
        doktab        = gt_drad
      EXCEPTIONS
        kein_dokument = 4.

    IF sy-subrc IS INITIAL.
      DELETE drad FROM TABLE gt_drad.
    ENDIF.

  ENDLOOP.

  PERFORM f_commit_work.

**********************************************************************

  CLEAR gt_drad.
  APPEND LINES OF p_matnr TO gt_drad.

*    LOOP AT p_matnr ASSIGNING <fs_matnr>.
*      mattab-matnr = <fs_matnr>-low.
*      APPEND mattab.
*    ENDLOOP.

  CALL FUNCTION 'CF_ST_MAT_LST_DELETE'
    TABLES
      mat_tab = gt_drad.                 " Table with PRT materials

  PERFORM f_commit_work.

*---- Löschen der Konfigurationsparamter    -CH/20.06.94 zu 2.2a ----
  LOOP AT p_matnr ASSIGNING <fs_matnr>.
    CALL FUNCTION 'CUVO_DELETE_CUCO'
      EXPORTING
        cuco_id     = 'MARA'
        cuco_object = <fs_matnr>-low.
  ENDLOOP.

  PERFORM f_commit_work.

*---- Löschen der Daten für die Inflationsabwicklung    ch zu 4.0
  IF  NOT pre03_tab[] IS INITIAL AND NOT inflation_active IS INITIAL.
    CALL FUNCTION 'ARRAY_DELETE_MAT_INFL_DATA'
      TABLES
        t_matnr                 = pre03_tab
      EXCEPTIONS
        j_1ainfmbw_delete_error = 1
        OTHERS                  = 2.
    PERFORM f_commit_work.
  ENDIF.

  CALL METHOD:
    o_mmde->delete_table( cdpos ),
    o_mmde->delete_table( cdhdr ).

  CALL METHOD o_mmde->delete_table( mara ).

  IF p_test IS NOT INITIAL.

    CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.

  ENDIF.

*---------------------------------------------------------------------
*                       SHOW ALV
*---------------------------------------------------------------------
  MESSAGE ID 'VS' TYPE 'S' NUMBER '821' WITH appli.

  CALL METHOD o_mmde->alv_show.

**********************************************************************
****************** END-OF-SELECTION **********************************
END-OF-SELECTION.

*---------------------------------------------------------------------*
* Verifique a inflação de qualquer empresa
* está ativo. Se sim, então a bandeira correspondente
* Conjunto INFLATION_ACTIVE.
*---------------------------------------------------------------------*
FORM check_infl_active.
  SELECT * FROM t001.
    CALL FUNCTION 'CHECK_INFLATION_ACTIVE'
      EXPORTING
        i_bukrs                 = t001-bukrs
        i_appl                  = appl_m
      EXCEPTIONS
        inflation_not_active    = 1
        bukrs_and_bwkey_initial = 2
        OTHERS                  = 3.
    IF sy-subrc = 0.
      inflation_active = x.
      EXIT.
    ENDIF.
  ENDSELECT.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form F_COMMIT_WORK
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM f_commit_work .

  IF p_test IS INITIAL.
    COMMIT WORK AND WAIT.
  ENDIF.

ENDFORM.



CLASS zcl_mmde IMPLEMENTATION.

  METHOD fill_alv_output.

    DATA:
      ls_alv_output LIKE LINE OF me->t_alv_output,
      ls_dd02v      TYPE dd02v.

    ls_alv_output-tab       = im_v_table_name.
    ls_alv_output-count     = im_v_selected.
    ls_alv_output-count_del = im_v_dbcnt.
    ls_alv_output-count_err = im_v_selected - im_v_dbcnt.

    CALL FUNCTION 'DD_TABL_GET'
      EXPORTING
        langu          = sy-langu         " Language in which Texts are Read
        tabl_name      = im_v_table_name  " Name of the table to be read
        withtext       = abap_true
      IMPORTING
        dd02v_wa_a     = ls_dd02v
      EXCEPTIONS
        access_failure = 1
        OTHERS         = 2.

    ls_alv_output-ddtext = ls_dd02v-ddtext.

*    APPEND is not necessary MA004818
*    READ TABLE me->t_alv_output FROM ls_alv_output TRANSPORTING NO FIELDS.
*
*    IF syst-subrc IS NOT INITIAL.
*      APPEND ls_alv_output TO me->t_alv_output.
*    ELSE.
    COLLECT ls_alv_output INTO me->t_alv_output.
*    ENDIF.

  ENDMETHOD.

  METHOD get_t_alv_output.
    r_result = me->t_alv_output.
  ENDMETHOD.

  METHOD set_t_alv_output.
    me->t_alv_output = im_t_alv_output.
  ENDMETHOD.

  METHOD delete_table.
    CONSTANTS:
      lc_material  TYPE c LENGTH 15 VALUE 'MATERIAL',
      lc_konsilief TYPE c LENGTH 15 VALUE 'KONSILIEF',
      lc_charge    TYPE c LENGTH 15 VALUE 'CHARGE'.

    DATA:
      lv_tab_name TYPE tabname,
      lv_selected TYPE i,
      lv_where    TYPE string VALUE 'MATNR IN P_MATNR'.

*   Avoid deletion of CONSTANTS variables.
    CONCATENATE lc_charge lc_konsilief lc_material INTO DATA(lv_dummy).

    lv_tab_name = me->get_table_name( im_t_table ).

    CALL METHOD o_prog_ind->show
      EXPORTING
        im_v_text = lv_tab_name.

    CASE lv_tab_name.
      WHEN 'CDHDR' OR 'CDPOS'.
        lv_where = '( objectclas = lc_material OR objectclas = lc_konsilief OR objectclas = lc_charge ) AND objectid IN p_matnr'.

      WHEN 'AMPL'.
        lv_where = 'BMATN IN P_MATNR'.

    ENDCASE.

    SELECT COUNT( * ) FROM (lv_tab_name) INTO lv_selected
        BYPASSING BUFFER
        WHERE (lv_where).

    DELETE FROM (lv_tab_name) WHERE (lv_where).

    PERFORM f_commit_work.
    CALL METHOD me->fill_alv_output
      EXPORTING
        im_v_dbcnt      = syst-dbcnt
        im_v_table_name = lv_tab_name
        im_v_selected   = lv_selected.

  ENDMETHOD.


  METHOD get_table_name.
    DATA lo_descr_ref  TYPE REF TO cl_abap_typedescr.

    lo_descr_ref = cl_abap_tabledescr=>describe_by_data( p_data = im_t_table  ).
    r_result = lo_descr_ref->get_relative_name( ).
  ENDMETHOD.


  METHOD alv_show.

    DATA:
      lt_fcat     TYPE slis_t_fieldcat_alv,
      ls_layout   TYPE slis_layout_alv,
      lt_eventtab TYPE slis_t_event.

    PERFORM f_set_fieldcatalog    CHANGING lt_fcat.

    PERFORM f_eventtab_build      CHANGING lt_eventtab.

    CALL FUNCTION 'REUSE_ALV_LIST_DISPLAY'
      EXPORTING
        i_callback_program = sy-repid
        is_layout          = ls_layout
        it_fieldcat        = lt_fcat
        it_events          = lt_eventtab
      TABLES
        t_outtab           = me->t_alv_output
      EXCEPTIONS
        program_error      = 1
        OTHERS             = 2.

    IF sy-subrc NE 0.
      MESSAGE ID sy-msgid TYPE 'S' NUMBER sy-msgno DISPLAY LIKE sy-msgty
              WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDIF.

  ENDMETHOD.

ENDCLASS.


*&---------------------------------------------------------------------*
*&      Form  eventtab_build
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      <--P_LT_EVENTTAB  text
*----------------------------------------------------------------------*
FORM f_eventtab_build   CHANGING xt_eventtab TYPE slis_t_event.
  DATA: ls_events TYPE slis_alv_event,
        gv_ucomm  LIKE sy-ucomm.

  CONSTANTS:
    gc_endoflist TYPE slis_alv_event-form VALUE   'END_OF_LIST',
    gc_topofpage TYPE slis_alv_event-form VALUE   'TOP_OF_PAGE'.

  CALL FUNCTION 'REUSE_ALV_EVENTS_GET'
    EXPORTING
      i_list_type     = 0
    IMPORTING
      et_events       = xt_eventtab
    EXCEPTIONS
      list_type_wrong = 1
      OTHERS          = 2.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.
* Set the Subroutine for the Event Top-of-Page
  READ TABLE xt_eventtab WITH KEY name =  slis_ev_top_of_page
                           INTO ls_events.
  IF sy-subrc = 0.
    MOVE slis_ev_top_of_page TO ls_events-form.
    MODIFY xt_eventtab FROM ls_events INDEX sy-tabix.
  ENDIF.

* Sets the Subroutine for PF-Status
  READ TABLE xt_eventtab WITH KEY name = slis_ev_pf_status_set
                          INTO ls_events.
  IF sy-subrc = 0.
    MOVE slis_ev_pf_status_set TO ls_events-form.
    APPEND ls_events TO xt_eventtab.
  ENDIF.

* Sets the Subroutine for the Event User-Command
  READ TABLE xt_eventtab WITH KEY name = slis_ev_user_command
                           INTO ls_events.
  IF sy-subrc = 0.
    MOVE slis_ev_user_command TO ls_events-form.
    APPEND ls_events TO xt_eventtab.
  ENDIF.

*Pass the subroutine name to the TOP-OF-PAGE event when the top of page
*is triggered
  READ TABLE xt_eventtab INTO ls_events WITH
       KEY name = slis_ev_top_of_page.
  IF sy-subrc = 0.
    ls_events-form = gc_topofpage.

    MODIFY xt_eventtab FROM ls_events TRANSPORTING form WHERE name = slis_ev_top_of_page.
  ENDIF.

*Pass the subroutine name to the END-OF-LIST event when the end of list
*is triggered
  IF sy-batch = 'X' OR gv_ucomm = 'PRIN'.

    READ TABLE xt_eventtab INTO ls_events WITH
         KEY name = slis_ev_end_of_list.
    IF sy-subrc = 0.
      ls_events-form = gc_endoflist.
      MODIFY xt_eventtab FROM ls_events TRANSPORTING form
             WHERE name = slis_ev_end_of_list.
    ENDIF.
  ENDIF.

ENDFORM.                    " eventtab_build

*&---------------------------------------------------------------------*
*&      Form  f_set_fieldcatalog
*&---------------------------------------------------------------------*
FORM f_set_fieldcatalog   CHANGING ch_t_fcat TYPE slis_t_fieldcat_alv.

  DATA : lr_tabdescr TYPE REF TO cl_abap_structdescr,
         lr_data     TYPE REF TO data,
         lt_dfies    TYPE ddfields.

  CREATE DATA lr_data LIKE gs_table_list.

  lr_tabdescr ?= cl_abap_structdescr=>describe_by_data_ref( lr_data ).
  lt_dfies = cl_salv_data_descr=>read_structdescr( lr_tabdescr ).

  MOVE-CORRESPONDING lt_dfies TO ch_t_fcat.

  LOOP AT ch_t_fcat ASSIGNING FIELD-SYMBOL(<fs_fcat>).
    CASE <fs_fcat>-fieldname.
      WHEN 'COUNT_DEL' OR 'COUNT'.
        <fs_fcat>-just = 'L'.
        <fs_fcat>-outputlen = 14.
      WHEN 'COUNT_ERR'.
        <fs_fcat>-just = 'L'.
        <fs_fcat>-outputlen = 14.
        <fs_fcat>-seltext_l = 'Nº de Erros'.
        <fs_fcat>-seltext_m = 'Nº de Erros'.
        <fs_fcat>-seltext_s = 'Nº de Erros'.
    ENDCASE.
  ENDLOOP.

ENDFORM.                    " fieldcat_merge

*< This form is for printing the top of page.
FORM top_of_page.

  DATA: ls_varueb      TYPE c LENGTH 140,
        ls_line        TYPE slis_listheader,
        lt_top_of_page TYPE slis_t_listheader.

  CLEAR:
    ls_line,
    lt_top_of_page.

  ls_line-typ  = 'A'.
  ls_line-info = sy-title.
  APPEND ls_line TO lt_top_of_page.

  IF p_test IS INITIAL.
    ls_varueb+65(17) = 'Execução efetiva'.
  ELSE.
    ls_varueb+65(17) = 'Execução de teste'.
  ENDIF.

  CONDENSE ls_varueb.
  MOVE ls_varueb TO ls_line-info.
  APPEND ls_line TO lt_top_of_page.

  CALL FUNCTION 'REUSE_ALV_COMMENTARY_WRITE'
    EXPORTING
      it_list_commentary = lt_top_of_page.

ENDFORM.                    "top_of_page

*---------------------------------------------------------------------*
*       FORM DELETE_TEXT                                              *
*---------------------------------------------------------------------*
*FORM delete_text.
*
*  DATA: BEGIN OF stxh_tab OCCURS 20.
*      INCLUDE STRUCTURE stxh.
*  DATA: END OF stxh_tab.
*  DO.
*    REFRESH stxh_tab.
*    SELECT * FROM stxh WHERE tdobject =  'MATERIAL  '
*                       OR    tdobject =  'MVKE      '
*                       OR    tdobject =  'MDTXT     '
*                       OR    tdobject =  'KONSILIEF '
*                       OR    tdobject =  'CHARGE    '.
*      stxh_tab = stxh.
*      APPEND stxh_tab.
*      IF sy-dbcnt EQ cluster.
*        EXIT.
*      ENDIF.
*    ENDSELECT.
*    IF sy-subrc NE 0.
*      EXIT.
*    ENDIF.
*    PERFORM f_commit_work.
*    LOOP AT stxh_tab.
*      DELETE FROM stxl
*             WHERE relid      = 'TX'
*             AND   tdobject   = stxh_tab-tdobject
*             AND   tdname     = stxh_tab-tdname
*             AND   tdid       = stxh_tab-tdid
*             AND   tdspras    = stxh_tab-tdspras.
*      DELETE FROM stxh
*             WHERE tdobject   = stxh_tab-tdobject
*             AND   tdname     = stxh_tab-tdname
*             AND   tdid       = stxh_tab-tdid
*             AND   tdspras    = stxh_tab-tdspras.
*    ENDLOOP.
*    PERFORM f_commit_work.
*  ENDDO.
*ENDFORM.

*---------------------------------------------------------------------*
*       Repetir faixas de números Material e EAN                 *
*---------------------------------------------------------------------*
*FORM reset_nriv.
** Nummernkreise
*  SELECT * FROM nriv WHERE object = 'MATERIALNR' OR
*                           object = 'EANGEWICHT' OR
*                           object = 'EUROPARTNR' OR
*                           object = 'PROP      ' OR   "mk/07.02.94
*                           object = 'PROW      '.
*    CLEAR nriv-nrlevel.
*    UPDATE nriv.
*  ENDSELECT.
*  PERFORM f_commit_work.
*ENDFORM.

*---------------------------------------------------------------------*
*       FORM DELETE_VORPLANUNG                                        *
*---------------------------------------------------------------------*
*FORM delete_vorplanung.
*
*  DATA: BEGIN OF pgmi_tab OCCURS 20.
*      INCLUDE STRUCTURE pgmi.
*  DATA: END OF pgmi_tab.
*  DO.
*    REFRESH pgmi_tab.
*    SELECT * FROM pgmi WHERE pgtyp = 'V'.
*      pgmi_tab = pgmi.
*      APPEND pgmi_tab.
*      IF sy-dbcnt EQ cluster.
*        EXIT.
*      ENDIF.
*    ENDSELECT.
*    IF sy-subrc NE 0.
*      EXIT.
*    ENDIF.
*    PERFORM f_commit_work.
*    LOOP AT pgmi_tab.
*      DELETE FROM pgzu
*             WHERE pgtyp      = pgmi_tab-pgtyp
*             AND   prgrp      = pgmi_tab-prgrp.
*      DELETE FROM pgmi
*             WHERE pgtyp      = pgmi_tab-pgtyp
*             AND   prgrp      = pgmi_tab-prgrp.
*    ENDLOOP.
*    PERFORM f_commit_work.
*  ENDDO.
*ENDFORM.
*---------------------------------------------------------------------*
*       FORM DELETE_STANDARDPR                                        *
* A partir de 3.0, o tipo de grupo de produtos W (configuração de pré-planejamento) *
* considerado.                                   ch/01.02.1995
*---------------------------------------------------------------------*
*FORM delete_standardpr.                     "CH/20.6.94  zu 2.2a
*
** Löschen der PGMI-/ PGZU-Einträge
*  DATA: BEGIN OF pgmi_s_tab OCCURS 20.
*      INCLUDE STRUCTURE pgmi.
*  DATA: END OF pgmi_s_tab.
*  DO.
*    REFRESH pgmi_s_tab.
*    SELECT * FROM pgmi WHERE pgtyp = 'S'
*                       OR    pgtyp = 'W'.             "ch/01.02.1995
*      pgmi_s_tab = pgmi.
*      APPEND pgmi_s_tab.
*      IF sy-dbcnt EQ cluster.
*        EXIT.
*      ENDIF.
*    ENDSELECT.
*    IF sy-subrc NE 0.
*      EXIT.
*    ENDIF.
*    PERFORM f_commit_work.
*    LOOP AT pgmi_s_tab.
*      DELETE FROM pgzu
*             WHERE pgtyp      = pgmi_s_tab-pgtyp
*             AND   prgrp      = pgmi_s_tab-prgrp.
*      DELETE FROM pgmi
*             WHERE pgtyp      = pgmi_s_tab-pgtyp
*             AND   prgrp      = pgmi_s_tab-prgrp.
*    ENDLOOP.
*    PERFORM f_commit_work.
*  ENDDO.
*
*ENDFORM.


*&=====================================================================*
*& CLASS IMPLEMENTATION LCL_PROGRESS_INDICATOR
*&=====================================================================*
CLASS lcl_progress_indicator IMPLEMENTATION.

  METHOD constructor.

    me->total = im_v_total.

    IF me->total IS NOT INITIAL.
      me->ratio = me->total / ratio_percentage.
    ENDIF.
  ENDMETHOD.

*&---------------------------------------------------------------------*
*& METHOD PROGRESS_INDICATOR
*&---------------------------------------------------------------------*
*& --> iv_text      Texto a ser utilizado na mensagem
*& --> iv_processed Valor sendo processado
*& --> iv_total     Total do valores a serem processados
*&---------------------------------------------------------------------*
  METHOD show.

    DATA:
      lv_text      TYPE string,
      lv_output_i  TYPE boole_d VALUE IS INITIAL,
      lv_processed TYPE i,
      lv_rtime     TYPE i.


    IF           im_v_processed IS INITIAL.
      ADD 1 TO me->processed.
      lv_processed = me->processed.
    ELSE.
      lv_processed = im_v_processed.
    ENDIF.

    IF lv_processed IS NOT INITIAL AND lv_processed EQ 1.
      GET RUN TIME FIELD me->rtime.
    ENDIF.

    IF me->total IS NOT INITIAL.
      lv_text = |Deletando registros da Tabela: { im_v_text } [{ lv_processed } do total { me->total }] |.
    ELSE.
      lv_text = im_v_text .
    ENDIF.

    DATA(lv_result_mod) = lv_processed MOD me->ratio.

*   Displays the message every 25% OR every 10sec or First times
    IF ( lv_processed LT 4 )    OR
         lv_result_mod IS INITIAL OR
       ( lv_rtime - me->rtime ) GT 10000. "10 sec
      lv_output_i = abap_true.
    ENDIF.

*   Always show
    lv_output_i = abap_true.

    CALL METHOD cl_progress_indicator=>progress_indicate
      EXPORTING
        i_text               = lv_text          " Progress Text (If no message transferred in I_MSG*)
        i_processed          = lv_processed   " Number of Objects Already Processed
        i_total              = me->total        " Total Number of Objects to Be Processed
        i_output_immediately = lv_output_i.     " X = Display Progress Immediately

  ENDMETHOD.

ENDCLASS.
