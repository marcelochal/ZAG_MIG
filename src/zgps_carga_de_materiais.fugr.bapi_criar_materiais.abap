* --------------------------------------------------------------------------*
*                  T A E S A - MIGRAÇÃO - AGIR                              *
* --------------------------------------------------------------------------*
* Consultoria .....: Intechpro                                              *
* ABAP.............: Richard de Aquino Rodrigues                            *
* Funcional........: André Santos                                           *
* Módulo...........: PS                                                     *
* Programa.........: BAPI_CRIAR_MATERIAIS                                   *
* Transação........:                                                        *
* Tipo de Prg......: FUNÇÃO                                                 *
* Objetivo.........: Criar Materiais                                        *
* Data.............: 03/09/2018                                             *
* --------------------------------------------------------------------------*
* Request    | Descrição                                                    *
* --------------------------------------------------------------------------*
* S4DK902311 | AGIR - Carga de Dados para Migração - HXXX - Materiais       *
* --------------------------------------------------------------------------*

*  OBS1.: Método Standard para criar "Materiais"
*            Função BAPI_BUS2002_ACTELEM_CREATE_M

*  OBS2.: Esta função chama a função standard BAPI_BUS2002_ACTELEM_CREATE_M
*           - Atender ao Migration CockPit
*             - Trabalhar os campos Zs (Não)
*             - Ter um flag de execução em teste (P_I_TESTRUN).
*             - Jogar todas as mensagens para uma única tabela de saída P_E_TI_RETURN


FUNCTION bapi_criar_materiais.
*"----------------------------------------------------------------------
*"*"Interface local:
*"  IMPORTING
*"     VALUE(P_I_DIAG_REDE) TYPE  NW_AUFNR
*"     VALUE(P_I_TI_MATERIAIS) TYPE  ZTPS_BAPI_NETWORK_COMP_ADD
*"     VALUE(P_I_TESTRUN) TYPE  BAPIE1GLOBAL_DATA-TESTRUN OPTIONAL
*"  EXPORTING
*"     REFERENCE(P_E_TI_RETURN) TYPE  BAPIRET2_TAB
*"----------------------------------------------------------------------

  TYPES: BEGIN OF ty_resb,
           aufnr TYPE aufnr, "DR
           vornr TYPE vornr, "Operação
           posnr TYPE aposn, "Item
           matnr TYPE matnr, "Material
         END OF ty_resb.

  TYPES: ty_it_resb TYPE SORTED TABLE OF ty_resb
                    WITH NON-UNIQUE KEY aufnr vornr posnr.

  DATA: lc_valuepart   TYPE valuepart,
        lc_erro        TYPE c,
        wa_return	     TYPE bapiret2,
        wa_campos_zs   TYPE bapi_te_network_act_element,
        wa_prps_ext_in TYPE bapiparex,
        wa_message     TYPE bapi_meth_message,
        ti_campos_zs   TYPE tt_it_netw_ext_in,
        ti_return      TYPE bapiret2_tab,
        ti_return_pc   TYPE bapiret2_tab,
        ti_return_fim  TYPE bapiret2_tab,
        ti_materiais   TYPE ztps_bapi_network_comp_add,
        wa_material    TYPE zeps_bapi_network_comp_add,
        ti_materiais_2 TYPE STANDARD TABLE OF ty_resb,
        wa_material_2  TYPE ty_resb,
        ti_messages    TYPE rpm_bapi_meth_messages,
        ti_resb        TYPE ty_it_resb,
        wa_resb        TYPE ty_resb.

*-------------------------------------------------------------------*
*-------------------------------------------------------------------*

  CALL FUNCTION 'BAPI_PS_INITIALIZATION'.

  ti_materiais[] = p_i_ti_materiais[].

* Adaptada para trabalhar com campos Zs e adicionais
  CALL FUNCTION 'BAPI_ZNETWORK_ZCOMP_ZADD'
    EXPORTING
      number           = p_i_diag_rede
    IMPORTING
      return           = wa_return
    TABLES
      i_components_add = ti_materiais[]
      e_message_table  = ti_messages[].

  IF NOT wa_return IS INITIAL.
    APPEND wa_return TO ti_return_fim.
  ENDIF.

  LOOP AT ti_messages INTO wa_message.
    wa_return-type    = wa_message-message_type.
    wa_return-id      = wa_message-message_id.
    wa_return-number  = wa_message-message_number.
    wa_return-message = wa_message-message_text.
    APPEND wa_return TO ti_return_fim.
    CLEAR  wa_return.
  ENDLOOP.

  READ TABLE ti_return_fim WITH KEY type = 'E' TRANSPORTING NO FIELDS.
  IF sy-subrc = 0.
    lc_erro = abap_true.
  ENDIF.

* Se for execução em teste.
  IF p_i_testrun EQ abap_true.

*   Se tudo OK
    IF lc_erro IS INITIAL.

      wa_return-type    = 'S'.
      wa_return-message = 'Simulação OK'.
      APPEND wa_return TO ti_return_fim.
      CLEAR  wa_return.

    ENDIF.

* Se for execução valendo.
  ELSE.

*   Se tudo OK
    IF lc_erro IS INITIAL.

      CALL FUNCTION 'BAPI_PS_PRECOMMIT'
        TABLES
          et_return = ti_return_pc.

      LOOP AT ti_return_pc INTO wa_return.

        IF ( wa_return-type   EQ 'I'       ) AND
           ( wa_return-id     EQ 'CNIF_PI' ) AND
           ( wa_return-number EQ '032'     ).

        ELSE.

          APPEND  wa_return TO ti_return_fim.

        ENDIF.

      ENDLOOP.

      READ TABLE ti_return_pc WITH KEY type = 'E' TRANSPORTING NO FIELDS.
      IF sy-subrc = 0.
        lc_erro = abap_true.
      ENDIF.

*     Se tudo OK
      IF lc_erro IS INITIAL.

        CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
          EXPORTING
            wait   = 'X'
          IMPORTING
            return = wa_return.

        IF NOT wa_return IS INITIAL.

          APPEND wa_return TO ti_return_fim.

        ELSE.

          wa_return-type    = 'S'.
          wa_return-message = 'Execução OK'.
          APPEND wa_return TO ti_return_fim.
          CLEAR  wa_return.

        ENDIF.

      ENDIF.

    ENDIF.

*-----------------------------------------------------*
    LOOP AT ti_materiais INTO wa_material.
      wa_material_2-aufnr = p_i_diag_rede.
      wa_material_2-vornr = wa_material-activity.
      wa_material_2-posnr = wa_material-item_number.
      wa_material_2-matnr = wa_material-material.
      APPEND wa_material_2 TO ti_materiais_2.
      CLEAR  wa_material_2.
    ENDLOOP.

    SELECT
          aufnr "DR
          vornr "Operação
          posnr "Item
          matnr "Material
          FROM resb
          INTO TABLE ti_resb
          FOR ALL ENTRIES IN ti_materiais_2
              WHERE matnr EQ ti_materiais_2-matnr
                AND aufnr EQ ti_materiais_2-aufnr
                AND vornr EQ ti_materiais_2-vornr
                AND posnr EQ ti_materiais_2-posnr.

    IF sy-subrc EQ 0.

      LOOP AT ti_materiais INTO wa_material.

        READ TABLE ti_resb INTO wa_resb WITH TABLE KEY aufnr = p_i_diag_rede
                                                       vornr = wa_material-activity
                                                       posnr = wa_material-item_number.

        IF sy-subrc EQ 0.

          IF wa_resb-matnr(18) NE wa_material-material.

            wa_return-type    = 'E'.

            CONCATENATE p_i_diag_rede
                        wa_material-activity
                        wa_material-item_number
                        wa_material-material
                        'Não carregado'
                        INTO wa_return-message
                        SEPARATED BY space.

            APPEND wa_return TO ti_return_fim.
            CLEAR  wa_return.

          ENDIF.

        ELSE.

          wa_return-type    = 'E'.

          CONCATENATE p_i_diag_rede
                      wa_material-activity
                      wa_material-item_number
                      wa_material-material
                      'Não carregado'
                      INTO wa_return-message
                      SEPARATED BY space.

          APPEND wa_return TO ti_return_fim.
          CLEAR  wa_return.

        ENDIF.

      ENDLOOP.

    ELSE.

      LOOP AT ti_materiais INTO wa_material.

        wa_return-type    = 'E'.

        CONCATENATE p_i_diag_rede
                    wa_material-activity
                    wa_material-item_number
                    wa_material-material
                    'Não carregado'
                    INTO wa_return-message
                    SEPARATED BY space.

        APPEND wa_return TO ti_return_fim.
        CLEAR  wa_return.

      ENDLOOP.

    ENDIF.

  ENDIF.

*-----------------------------------------------------*
  IF NOT ti_return_fim[] IS INITIAL.
    p_e_ti_return[] = ti_return_fim[].
  ENDIF.

ENDFUNCTION.
