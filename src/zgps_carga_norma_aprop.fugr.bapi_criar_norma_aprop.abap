* --------------------------------------------------------------------------*
*                  T A E S A - MIGRAÇÃO - AGIR                              *
* --------------------------------------------------------------------------*
* Consultoria .....: Intechpro                                              *
* ABAP.............: Richard de Aquino Rodrigues                            *
* Funcional........: André Santos                                           *
* Módulo...........: PS                                                     *
* Programa.........: BAPI_CRIAR_NORMA_APROP                                 *
* Transação........:                                                        *
* Tipo de Prg......: FUNÇÃO                                                 *
* Objetivo.........: Criar Norma de apropriação                             *
* Data.............: 18/09/2018                                             *
* --------------------------------------------------------------------------*
* Request    | Descrição                                                    *
* --------------------------------------------------------------------------*
* S4DK902606 | AGIR - Carga de Dados para Migração - HXXX - Norma de aprop. *
* --------------------------------------------------------------------------*

*  OBS1.: Método Standard para criar "Norma de apropriação"
*            Na ordem
*            Função K_POSTING_RULE_INSERT
*            Função K_SETTLEMENT_RULE_FILL
*            Função K_SETTLEMENT_RULE_SAVE

*  OBS2.: Esta função chama a função Standard EAM_TASKLIST_CREATE
*           - Atender ao Migration CockPit
*             - Ter um flag de execução em teste (P_I_TESTRUN).
*             - Jogar todas as mensagens para uma única tabela de saída P_E_TI_RETURN

FUNCTION bapi_criar_norma_aprop.
*"----------------------------------------------------------------------
*"*"Interface local:
*"  IMPORTING
*"     VALUE(P_I_TI_NORMA_APROP) TYPE  ZTPS_NORMA_APROP
*"     VALUE(P_I_TESTRUN) TYPE  BAPIE1GLOBAL_DATA-TESTRUN OPTIONAL
*"  EXPORTING
*"     REFERENCE(P_E_TI_RETURN) TYPE  BAPIRET2_TAB
*"----------------------------------------------------------------------

  DATA:
    lc_erro          TYPE c,
    lc_dfreg         TYPE dfreg,
    lc_konty         TYPE konty,
    lc_rec_objnr1    TYPE srec_objnr,
    ln_lfdnr         TYPE br_lfdnr,
    lp_tot_percent   TYPE brgprozs,
    wa_return        TYPE bapiret2,
    wa_cobra         TYPE cobra,
    wa_cobrb         TYPE cobrb,
    wa_dftab         TYPE dftabelle,
    wa_i_norma_aprop TYPE	zeps_norma_aprop,
    wa_jest_ins      TYPE jest_upd,
    wa_prps          TYPE prps,
    ti_cobra         TYPE STANDARD TABLE OF cobra,
    ti_cobrb         TYPE STANDARD TABLE OF cobrb,
    ti_dftab         TYPE STANDARD TABLE OF dftabelle,
    ti_jest_ins      TYPE STANDARD TABLE OF jest_upd,
    ti_jest_upd      TYPE STANDARD TABLE OF jest_upd,
    ti_jsto_ins      TYPE STANDARD TABLE OF jsto,
    ti_jsto_upd      TYPE STANDARD TABLE OF jsto_upd,
    ti_obj_del       TYPE STANDARD TABLE OF onr00,
    ti_return        TYPE bapiret2_t,
    ti_return_fim    TYPE bapiret2_t.

*-------------------------------------------------------------------*
*-------------------------------------------------------------------*
  READ TABLE p_i_ti_norma_aprop INTO wa_i_norma_aprop INDEX 1.

  IF sy-subrc EQ 0.

    SELECT SINGLE * INTO wa_cobra
           FROM cobra
           WHERE objnr EQ wa_i_norma_aprop-objnr.

    IF sy-subrc EQ 0.

      SELECT *
             FROM cobrb
             INTO TABLE ti_cobrb
             WHERE objnr EQ wa_i_norma_aprop-objnr.

      SELECT * INTO wa_prps
              FROM prps
              UP TO 1 ROWS
              WHERE objnr = wa_i_norma_aprop-objnr.
      ENDSELECT.

      IF sy-subrc EQ 0.

        CLEAR lp_tot_percent.
        LOOP AT ti_cobrb INTO wa_cobrb.
          lp_tot_percent = lp_tot_percent + wa_cobrb-prozs.
        ENDLOOP.

        IF lp_tot_percent EQ '100.00'.

          ln_lfdnr  = wa_cobrb-lfdnr.

          REFRESH ti_cobrb.

          LOOP AT p_i_ti_norma_aprop INTO wa_i_norma_aprop.

            ln_lfdnr            = ln_lfdnr + 1.

            wa_cobrb-mandt      = sy-mandt.
            wa_cobrb-objnr      = wa_i_norma_aprop-objnr.
            wa_cobrb-bureg      = '000'.
            wa_cobrb-lfdnr      = ln_lfdnr.
            wa_cobrb-perbz      = 'GES'.
            wa_cobrb-konty      = wa_i_norma_aprop-konty.
            wa_cobrb-anln1      = wa_i_norma_aprop-anln1.
            wa_cobrb-anln2      = wa_i_norma_aprop-anln2.
            wa_cobrb-prozs      = wa_i_norma_aprop-prozs.

            wa_cobrb-kokrs      = wa_prps-pkokr.
            wa_cobrb-bukrs      = wa_prps-pbukr.
            wa_cobrb-ps_psp_pnr = wa_prps-pspnr.

            CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
              EXPORTING
                input  = wa_i_norma_aprop-anln1
              IMPORTING
                output = wa_i_norma_aprop-anln1.

            CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
              EXPORTING
                input  = wa_i_norma_aprop-anln2
              IMPORTING
                output = wa_i_norma_aprop-anln2.

            CONCATENATE wa_i_norma_aprop-konty
                        wa_prps-pbukr
                        wa_i_norma_aprop-anln1
                        wa_i_norma_aprop-anln2
                        INTO wa_cobrb-rec_objnr1.

            APPEND wa_cobrb TO ti_cobrb.

          ENDLOOP.

          CALL FUNCTION 'ZK_SRULE_SAVE_UTASK'
            EXPORTING
              p_i_testrun       = p_i_testrun
            TABLES
              t_cobrb_insert    = ti_cobrb
            EXCEPTIONS
              srule_utask_error = 1
              OTHERS            = 2.

          IF sy-subrc =  0.

            IF p_i_testrun IS INITIAL.

              wa_jest_ins-mandt = sy-mandt.
              wa_jest_ins-objnr = wa_i_norma_aprop-objnr.
              wa_jest_ins-stat = 'I0028'.
              wa_jest_ins-inact = space.
              wa_jest_ins-chgkz = 'X'.
              wa_jest_ins-chgnr = '001'.

              APPEND wa_jest_ins TO ti_jest_upd.

              CALL FUNCTION 'STATUS_UPDATE'
                TABLES
                  jest_ins = ti_jest_ins
                  jest_upd = ti_jest_upd
                  jsto_ins = ti_jsto_ins
                  jsto_upd = ti_jsto_upd
                  obj_del  = ti_obj_del.

            ENDIF.

            wa_return-type = 'S'.

            CONCATENATE 'Norma criada -' wa_cobra-objnr
                   INTO wa_return-message SEPARATED BY space.

            APPEND wa_return TO ti_return_fim.

          ELSE.

            wa_return-type = 'E'.

            CONCATENATE 'Erro na Função K_SRULE_SAVE_UTASK -' wa_cobra-objnr
                   INTO wa_return-message SEPARATED BY space.

            APPEND wa_return TO ti_return_fim.

          ENDIF.

        ELSE.

          wa_return-type = 'E'.

          CONCATENATE 'Percentagem de apropriação de custos dif. de 100% - ' wa_i_norma_aprop-objnr
                 INTO wa_return-message SEPARATED BY space.

          APPEND wa_return TO ti_return_fim.

        ENDIF.

      ELSE.

        wa_return-type = 'E'.

        CONCATENATE 'PEP inexistente -' wa_i_norma_aprop-objnr
               INTO wa_return-message SEPARATED BY space.

        APPEND wa_return TO ti_return_fim.

      ENDIF.

    ELSE.

      wa_return-type = 'E'.

      CONCATENATE 'Não existe o objeto na COBRA -' wa_i_norma_aprop-objnr
             INTO wa_return-message SEPARATED BY space.

      APPEND wa_return TO ti_return_fim.

    ENDIF.

  ELSE.

    wa_return-type    = 'E'.
    wa_return-message = 'Não há dados para processar'.
    APPEND wa_return TO ti_return_fim.

  ENDIF.

*---------------------------------------------------------------*
  IF NOT ti_return_fim[] IS INITIAL.
    p_e_ti_return[] = ti_return_fim[].
  ENDIF.

ENDFUNCTION.
