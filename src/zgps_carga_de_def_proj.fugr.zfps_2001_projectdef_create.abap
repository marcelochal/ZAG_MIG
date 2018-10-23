* --------------------------------------------------------------------------*
*                  T A E S A - MIGRAÇÃO - AGIR                              *
* --------------------------------------------------------------------------*
* Consultoria .....: Intechpro                                              *
* ABAP.............: Richard de Aquino Rodrigues                            *
* Funcional........: André Santos                                           *
* Módulo...........: PS                                                     *
* Programa.........: BAPI_ZPROJECTDEF_ZCREATE                               *
* Transação........:                                                        *
* Tipo de Prg......: FUNÇÃO                                                 *
* Objetivo.........: Criar Definição de Projeto                             *
* Data.............: 11/07/2018                                             *
* --------------------------------------------------------------------------*
* Request    | Descrição                                                    *
* --------------------------------------------------------------------------*
* S4DK901191 | AGIR - Carga de Dados para Migração - HXXX - Def. Projeto    *
* --------------------------------------------------------------------------*

*  OBS1.: Método Standard para criar "Definição de Projeto"
*            Função BAPI_PROJECTDEF_CREATE
*               Report R_BAPI_PROJECTDEF_CREATE
*                 Função 2001_PROJECTDEF_CREATE

*  OBS2.: Esta função foi feita a partir de uma cópia da função standard 2001_PROJECTDEF_CREATE
*         Ela foi adaptada para:
*           - Atender ao Migration CockPit
*              - Ter um flag de execução em teste (TESTRUN).
*              - Ter uma única tabela de mensagens de saída (RETURN).
*           - Não trabalharemos com os campos Zs da estrutura CI_PROJ.

FUNCTION zfps_2001_projectdef_create.
*"----------------------------------------------------------------------
*"*"Interface local:
*"  IMPORTING
*"     VALUE(PROJECT_DEFINITION_STRU) TYPE
*"        ZEPS_BAPI_PROJECT_DEFINITION
*"     VALUE(TESTRUN) TYPE  BAPIE1GLOBAL_DATA-TESTRUN OPTIONAL
*"  TABLES
*"      RETURN STRUCTURE  BAPIRET2
*"----------------------------------------------------------------------
  DATA: pspid       LIKE proj-pspid,
        l_proj      LIKE proj,
        msghand_num LIKE sy-uzeit,
        msg_log     LIKE msg_log OCCURS 0 WITH HEADER LINE,
        method_log  LIKE method_log OCCURS 0 WITH HEADER LINE,
        e_msg_text  LIKE msg_text OCCURS 0 WITH HEADER LINE,
        log_level   LIKE method_log-loglevel,
        initialize  LIKE method_log-method VALUE 'initialize'.
  DATA: dialog_status_tmp,
        wa_bapi_project_definition TYPE bapi_project_definition,
        wa_bapireturn1             TYPE bapireturn1,
        wa_bapiret2                TYPE bapiret2,
        wa_message_table           TYPE bapi_meth_message,
        wa_return	                 TYPE bapiret2,
        ti_message_table           TYPE TABLE OF bapi_meth_message,
        ti_return                  TYPE bapiret2tab_ps.

*-------------------------------------------------------------------*
*-------------------------------------------------------------------*
  CLEAR flg_error_occured.

* we are not using any dialogs (set parameter FLAG_DIALOG_STATUS)
  CALL FUNCTION 'DIALOG_GET_STATUS'
    IMPORTING
      dialog_status = dialog_status_tmp.
  CALL FUNCTION 'DIALOG_SET_NO_DIALOG'.

  flag_no_dialog = 'X'.

* neue Stufe im Meldungs-Log setzen
  CALL FUNCTION 'METHOD_START_LOG'
    EXPORTING
      method      = initialize
    IMPORTING
      msghand_num = msghand_num
      log_level   = log_level
    EXCEPTIONS
      OTHERS      = 1.

* Initialize Message Handler
  CALL FUNCTION 'METHOD_LOG_INIT'
    EXPORTING
      msghand_num     = msghand_num
    IMPORTING
      msghand_num_exp = msghand_num
    EXCEPTIONS
      not_authorized  = 1
      OTHERS          = 2.

* kein Key vorhanden -> Fehler
  IF project_definition_stru IS INITIAL.
    CALL FUNCTION 'BALW_BAPIRETURN_GET1'
      EXPORTING
        type       = 'E'
        cl         = 'CJ'
        number     = '003'
      IMPORTING
        bapireturn = wa_bapireturn1
      EXCEPTIONS
        OTHERS     = 1.

    wa_bapiret2 = wa_bapireturn1.
    APPEND wa_bapiret2 TO ti_return.
    CLEAR  wa_bapiret2.

*   Kz. BAPI-Nachrichtenverarbeitung zurücksetzen
    PERFORM set_no_dialog_flag USING space.

*   Set parameter FLAG_DIALOG_STATUS to old value
    IF dialog_status_tmp IS INITIAL.
      CALL FUNCTION 'DIALOG_SET_WITH_DIALOG'.
    ELSE.
      CALL FUNCTION 'DIALOG_SET_NO_DIALOG'.
    ENDIF.

    IF NOT ti_return[] IS INITIAL.
      return[] = ti_return[].
    ENDIF.

    EXIT.
  ENDIF.

  wa_bapi_project_definition = project_definition_stru.

* BAPI-Struktur auf proj mappen
  CALL FUNCTION 'MAP_BAPI_PROJECTDEF_2_PROJ'
    EXPORTING
      bapi_project_definition   = wa_bapi_project_definition
    CHANGING
      proj                      = l_proj
    EXCEPTIONS
      error_converting_iso_code = 1
      OTHERS                    = 2.

  IF sy-subrc <> 0.

    PERFORM put_message USING
                        sy-msgid sy-msgno sy-msgty
                        sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.

  ELSE.

*---------------------------------------------------------------*
* Adaptações para considerar os campos Zs
* da estrutura CI_PROJ (Campos adicionais para Projetos (PROJ)).
*---------------------------------------------------------------*

**   Mapear os campos Zs (CI_PROJ)
*    CALL FUNCTION 'ZFPS_MAP_CI_PROJ_2_PROJ'
*      EXPORTING
*        bapi_project_definition = project_definition_stru
*      CHANGING
*        proj                    = l_proj.

*---------------------------------------------------------------*
* Adaptações para considerar os campos adicionais
* que a BAPI original não trata.
*---------------------------------------------------------------*

*   Mapear novos campos que a BAPI original não trata
    CALL FUNCTION 'ZFPS_MAP_NOVOS_CAMPOS_2_PROJ'
      EXPORTING
        project_definition_stru = project_definition_stru
      CHANGING
        proj                    = l_proj.

  ENDIF.

*---------------------------------------------------------------*
* Ist schon ein gleichnamiges Projekt vorhanden
  CALL FUNCTION 'CJDW_PROJ_SELECT_SINGLE'
    EXPORTING
      pspid     = l_proj-pspid
    EXCEPTIONS
      not_found = 1.

  IF sy-subrc IS INITIAL.
    MOVE project_definition_stru TO sy-msgv1.
    CALL FUNCTION 'BALW_BAPIRETURN_GET1'
      EXPORTING
        type       = 'E'
        cl         = 'CJ'
        number     = '010'
        par1       = sy-msgv1
      IMPORTING
        bapireturn = wa_bapireturn1
      EXCEPTIONS
        OTHERS     = 1.

    wa_bapiret2 = wa_bapireturn1.
    APPEND wa_bapiret2 TO ti_return.
    CLEAR  wa_bapiret2.

*   Kz. BAPI-Nachrichtenverarbeitung zurücksetzen
    PERFORM set_no_dialog_flag USING space.

*   Set parameter FLAG_DIALOG_STATUS to old value
    IF dialog_status_tmp IS INITIAL.
      CALL FUNCTION 'DIALOG_SET_WITH_DIALOG'.
    ELSE.
      CALL FUNCTION 'DIALOG_SET_NO_DIALOG'.
    ENDIF.

    IF NOT ti_return[] IS INITIAL.
      return[] = ti_return[].
    ENDIF.

    EXIT.
  ENDIF.

* Projektdefinition anlegen
  CALL FUNCTION 'CN2D_PROJDEF_CREATE_STRU'
    EXPORTING
      i_pspid       = l_proj-pspid
      i_proj        = l_proj
    EXCEPTIONS
      key_failing   = 1
      create_failed = 2
      OTHERS        = 3.

  IF NOT sy-subrc IS INITIAL OR
     NOT flg_error_occured IS INITIAL.
* Fehlermeldungen in interner Tabelle übergeben
    CALL FUNCTION 'METHOD_LOG_READ'
      TABLES
        t_method_log_exp = method_log
        t_msg_log_exp    = msg_log
      EXCEPTIONS
        OTHERS           = 1.

    CALL FUNCTION 'MESSAGE_TEXTS_READ'
      TABLES
        t_msg_log_imp   = msg_log
        t_msg_texts_exp = e_msg_text
      EXCEPTIONS
        OTHERS          = 1.

    PERFORM create_msg_table(saplcnif) TABLES method_log
                                              msg_log
                                              e_msg_text
                                              ti_message_table.

    LOOP AT ti_message_table INTO wa_message_table.
      wa_bapiret2-id      = wa_message_table-message_id.
      wa_bapiret2-number  = wa_message_table-message_number.
      wa_bapiret2-type    = wa_message_table-message_type.
      wa_bapiret2-message = wa_message_table-message_text.
      APPEND wa_bapiret2 TO ti_return.
      CLEAR  wa_bapiret2.
    ENDLOOP.

    CALL FUNCTION 'BALW_BAPIRETURN_GET1'
      EXPORTING
        type       = 'E'
        cl         = 'CJ'
        number     = '035'
      IMPORTING
        bapireturn = wa_bapireturn1
      EXCEPTIONS
        OTHERS     = 1.

    wa_bapiret2 = wa_bapireturn1.
    APPEND wa_bapiret2 TO ti_return.
    CLEAR  wa_bapiret2.

  ENDIF.

* Start of note 1478259

  IF flg_error_occured IS INITIAL.
    PERFORM set_no_dialog_flag IN PROGRAM saplco2o USING 'X'.
    IF NOT l_proj IS INITIAL.
      CALL FUNCTION 'CJWB_CHECK_BEFORE_COMMIT'
        EXCEPTIONS
          cancel = 1
          OTHERS = 2.
      IF sy-subrc <> 0.
        flg_error_occured = con_yes.
*       Fehlermeldungen in interner Tabelle übergeben
        CALL FUNCTION 'METHOD_LOG_READ'
          TABLES
            t_method_log_exp = method_log
            t_msg_log_exp    = msg_log
          EXCEPTIONS
            OTHERS           = 1.

        CALL FUNCTION 'MESSAGE_TEXTS_READ'
          TABLES
            t_msg_log_imp   = msg_log
            t_msg_texts_exp = e_msg_text
          EXCEPTIONS
            OTHERS          = 1.

        PERFORM create_msg_table(saplcnif) TABLES method_log
                                                  msg_log
                                                  e_msg_text
                                                  ti_message_table.

        LOOP AT ti_message_table INTO wa_message_table.
          wa_bapiret2-id      = wa_message_table-message_id.
          wa_bapiret2-number  = wa_message_table-message_number.
          wa_bapiret2-type    = wa_message_table-message_type.
          wa_bapiret2-message = wa_message_table-message_text.
          APPEND wa_bapiret2 TO ti_return.
          CLEAR  wa_bapiret2.
        ENDLOOP.

        CALL FUNCTION 'BALW_BAPIRETURN_GET1'
          EXPORTING
            type       = 'E'
            cl         = 'CJ'
            number     = '035'
          IMPORTING
            bapireturn = wa_bapireturn1
          EXCEPTIONS
            OTHERS     = 1.

        wa_bapiret2 = wa_bapireturn1.
        APPEND wa_bapiret2 TO ti_return.
        CLEAR  wa_bapiret2.

      ENDIF.
    ENDIF.

  ENDIF.


  IF flg_error_occured IS INITIAL.
* End of note 1478259

    IF testrun = 'X'.

      CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.

    ELSE.

      CALL FUNCTION 'CJDT_GET_NEW_NUMBERS'.
      PERFORM on_commit(saplcjwb).
      COMMIT WORK.

    ENDIF.

  ENDIF.

* Kz. BAPI-Nachrichtenverarbeitung zurücksetzen
  PERFORM set_no_dialog_flag USING space.

* Set parameter FLAG_DIALOG_STATUS to old value
  IF dialog_status_tmp IS INITIAL.
    CALL FUNCTION 'DIALOG_SET_WITH_DIALOG'.
  ELSE.
    CALL FUNCTION 'DIALOG_SET_NO_DIALOG'.
  ENDIF.

  IF NOT ti_return[] IS INITIAL.
    return[] = ti_return[].
  ENDIF.

ENDFUNCTION.

INCLUDE lco2of05.
