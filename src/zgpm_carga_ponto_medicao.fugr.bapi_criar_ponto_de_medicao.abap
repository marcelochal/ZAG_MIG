* --------------------------------------------------------------------------*
*                  T A E S A - MIGRAÇÃO - AGIR                              *
* --------------------------------------------------------------------------*
* Consultoria .....: Intechpro                                              *
* ABAP.............: Richard de Aquino Rodrigues                            *
* Funcional........: André Santos                                           *
* Módulo...........: PM                                                     *
* Programa.........: BAPI_CRIAR_PONTO_DE_MEDICAO                            *
* Transação........:                                                        *
* Tipo de Prg......: FUNÇÃO                                                 *
* Objetivo.........: Criar ponto de medição                                 *
* Data.............: 11/09/2018                                             *
* --------------------------------------------------------------------------*
* Request    | Descrição                                                    *
* --------------------------------------------------------------------------*
* S4DK902495 | AGIR - Carga de Dados para Migração - HXXX - Ponto Medição   *
* --------------------------------------------------------------------------*

*  OBS1.: Método Standard para criar "Ponto de medição"
*            Função MEASUREM_POINT_DIALOG_SINGLE

*  OBS2.: Esta função chama a função Standad MEASUREM_POINT_DIALOG_SINGLE
*           - Atender ao Migration CockPit

FUNCTION bapi_criar_ponto_de_medicao.
*"----------------------------------------------------------------------
*"*"Interface local:
*"  IMPORTING
*"     VALUE(P_I_WA_PONT_MED) TYPE  ZEAGIR_PONT_MED
*"     VALUE(P_I_TESTRUN) TYPE  BAPIE1GLOBAL_DATA-TESTRUN OPTIONAL
*"  EXPORTING
*"     REFERENCE(P_E_TI_RETURN) TYPE  BAPIRET2_TAB
*"----------------------------------------------------------------------

  DATA:
    lc_message(220)  TYPE c,
    lc_objnr         TYPE j_objnr,
    lc_activity_type TYPE acttyp,
    lc_point         TYPE imrc_point,
    wa_return        TYPE bapiret2,
    wa_is_rimr03     TYPE rimr03,
    wa_impt          TYPE impt,
    wa_imptt         TYPE imptt,
    ti_return_fim    TYPE bapiret2_tab,
    ti_return        TYPE bapiret2_t,
    ti_imptt         TYPE STANDARD TABLE OF imptt.

  DATA lv_pt_med LIKE p_i_wa_pont_med-point.

*-------------------------------------------------------------------*
*-------------------------------------------------------------------*
  SELECT SINGLE objnr INTO lc_objnr
         FROM equi
         WHERE equnr EQ p_i_wa_pont_med-equnr.

  IF sy-subrc EQ 0.

    wa_is_rimr03-mpobj = lc_objnr.
    wa_is_rimr03-point = p_i_wa_pont_med-point.
    wa_is_rimr03-mptyp = p_i_wa_pont_med-mptyp.
    wa_is_rimr03-indct = p_i_wa_pont_med-indct.
    wa_is_rimr03-pttxt = p_i_wa_pont_med-pttxt.
    wa_is_rimr03-atnam = p_i_wa_pont_med-atnam.
    wa_is_rimr03-desir = p_i_wa_pont_med-desir.
    wa_is_rimr03-mlang = sy-langu.

    "Turnaround para carga com numeração extenas de Ponto de Medição
    lv_pt_med = p_i_wa_pont_med-point.
    EXPORT lv_pt_med = lv_pt_med TO MEMORY ID 'PTMD'.

*   Se é execução em teste
    IF NOT p_i_testrun IS INITIAL.

      lc_activity_type = '3'.

    ELSE.

      SELECT SINGLE point INTO lc_point
             FROM imptt
             WHERE point EQ p_i_wa_pont_med-point.

      IF sy-subrc EQ 0.
        lc_activity_type = '2'.
      ELSE.
        lc_activity_type = '1'.
      ENDIF.

    ENDIF.

    CALL FUNCTION 'MEASUREM_POINT_DIALOG_SINGLE'
      EXPORTING
        activity_type            = lc_activity_type
        f11_active               = 'X'
        indicator_initialize     = 'X'
        measurement_point        = p_i_wa_pont_med-point
        measurement_point_type   = p_i_wa_pont_med-mptyp
        measurement_point_object = lc_objnr
        no_dialog                = 'X'
        is_rimr03                = wa_is_rimr03
      IMPORTING
        impt_wa                  = wa_impt
      EXCEPTIONS
        imptt_not_found          = 1
        type_not_found           = 2
        object_not_found         = 3
        no_authority             = 4
        point_is_refmp           = 5
        point_is_not_refmp       = 6
        OTHERS                   = 7.

    CASE sy-subrc.

      WHEN '0'.

        CASE lc_activity_type.

          WHEN '1'.

            MOVE-CORRESPONDING wa_impt TO wa_imptt.
            APPEND wa_imptt TO ti_imptt.

            CALL FUNCTION 'TABLE_IMPTT_UPDATE'
              TABLES
                imptt_ins = ti_imptt.

            wa_return-type = 'S'.
            CONCATENATE 'Ponto de medição criado -'
                        wa_impt-point INTO wa_return-message
                        SEPARATED BY space.
            APPEND wa_return TO ti_return_fim.

          WHEN '2'.

            MOVE-CORRESPONDING wa_impt TO wa_imptt.
            APPEND wa_imptt TO ti_imptt.

            CALL FUNCTION 'TABLE_IMPTT_UPDATE'
              TABLES
                imptt_upd = ti_imptt.

            wa_return-type = 'S'.
            CONCATENATE 'Ponto de medição modificado -'
                        wa_impt-point INTO wa_return-message
                        SEPARATED BY space.
            APPEND wa_return TO ti_return_fim.

          WHEN '3'.

            wa_return-type       = 'S'.
            wa_return-id         = 'Z_BUPA'.
            wa_return-number     = '000'.
            wa_return-message    = 'Simulação ok'.
            wa_return-message_v1 = p_i_wa_pont_med-point.
            APPEND wa_return TO ti_return_fim.

        ENDCASE.

      WHEN '1'.

*       Se é execução em teste
        IF NOT p_i_testrun IS INITIAL.

          wa_return-type = 'S'.
          CONCATENATE 'Simulação ok -'
                      p_i_wa_pont_med-point INTO wa_return-message
                      SEPARATED BY space.
          APPEND wa_return TO ti_return_fim.

        ENDIF.

      WHEN OTHERS.

        CALL FUNCTION 'BAPI_MESSAGE_GETDETAIL'
          EXPORTING
            id         = sy-msgid
            number     = sy-msgno
            language   = 'E'
            textformat = 'ASC'
*           message_v1 = wa_impt-point
          IMPORTING
            message    = lc_message.

        IF sy-subrc = 0.
          wa_return-type       = 'E'.
          wa_return-id         = sy-msgid.
          wa_return-number     = sy-msgno.
          wa_return-message    = lc_message.
          wa_return-message_v1 = p_i_wa_pont_med-point.
          APPEND wa_return TO ti_return_fim.
        ENDIF.

    ENDCASE.

  ELSE.

    wa_return-type = 'E'.
    CONCATENATE 'Equipamento inválido -'
                 p_i_wa_pont_med-equnr INTO wa_return-message
                SEPARATED BY space.
    APPEND wa_return TO ti_return_fim.

  ENDIF.

*---------------------------------------------------------------*
  IF NOT ti_return_fim[] IS INITIAL.
    p_e_ti_return[] = ti_return_fim[].
  ENDIF.

ENDFUNCTION.
