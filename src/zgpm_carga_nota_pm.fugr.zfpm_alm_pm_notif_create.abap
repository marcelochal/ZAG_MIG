FUNCTION zfpm_alm_pm_notif_create .
*"----------------------------------------------------------------------
*"*"Interface local:
*"  IMPORTING
*"     VALUE(EXTERNAL_NUMBER) LIKE  BAPI2080_NOTHDRE-NOTIF_NO OPTIONAL
*"     VALUE(NOTIF_TYPE) LIKE  BAPI2080-NOTIF_TYPE
*"     VALUE(NOTIFHEADER) LIKE  BAPI2080_NOTHDRI STRUCTURE
*"        BAPI2080_NOTHDRI
*"     VALUE(SENDER) LIKE  BAPI_SENDER STRUCTURE  BAPI_SENDER OPTIONAL
*"     VALUE(ORDERID) LIKE  BAPI2080_NOTHDRE-ORDERID OPTIONAL
*"     VALUE(P_I_WA_CAMPOS_ADD_RIQS5) TYPE  ZEPM_CAMPOS_ADD_RIQS5
*"       OPTIONAL
*"  EXPORTING
*"     VALUE(NOTIFHEADER_EXPORT) LIKE  BAPI2080_NOTHDRE STRUCTURE
*"        BAPI2080_NOTHDRE
*"  TABLES
*"      NOTITEM STRUCTURE  BAPI2080_NOTITEMI OPTIONAL
*"      NOTIFCAUS STRUCTURE  BAPI2080_NOTCAUSI OPTIONAL
*"      NOTIFACTV STRUCTURE  BAPI2080_NOTACTVI OPTIONAL
*"      NOTIFTASK STRUCTURE  BAPI2080_NOTTASKI OPTIONAL
*"      NOTIFPARTNR STRUCTURE  BAPI2080_NOTPARTNRI OPTIONAL
*"      LONGTEXTS STRUCTURE  BAPI2080_NOTFULLTXTI OPTIONAL
*"      KEY_RELATIONSHIPS STRUCTURE  BAPI2080_NOTKEYE OPTIONAL
*"      RETURN STRUCTURE  BAPIRET2 OPTIONAL
*"----------------------------------------------------------------------

*--- Initialization
  CLEAR   : return, t_viqmfe, t_viqmur, t_viqmma, t_viqmsm, t_keys,
            t_inlines, t_hpavb, f_riqs5, g_bin_relation, h_mess_wa,
            notifheader_export.
  REFRESH : return, t_viqmfe, t_viqmur, t_viqmma,  t_viqmsm, t_keys,
            t_inlines, t_hpavb.

*--- Check notification type ( "PM" )
  CALL FUNCTION 'IQS4_CHECK_NOTIF_TYPE_PM'
    EXPORTING
      i_qmart = notif_type
    TABLES
      return  = return.
*--- Check fatal errors
  CALL FUNCTION 'IQS4_CHECK_ERROR_SEVERE'
    TABLES
      return       = return
    EXCEPTIONS
      severe_error = 1
      OTHERS       = 2.
  IF NOT sy-subrc IS INITIAL.
    EXIT.
  ENDIF.                               "notification's type is not valid
*--- Loading data in Structure F_RIQS5
  CALL FUNCTION 'ZMAP2I_BAPI2080_NOTHDRI_RIQS5'
    EXPORTING
      bapi2080_nothdri        = notifheader
      p_i_wa_campos_add_riqs5 = p_i_wa_campos_add_riqs5
    CHANGING
      riqs5                   = f_riqs5.
*--- Set Notification Type
  f_riqs5-qmart = notif_type.
*--- Loading data in table T_VIQMFE
  LOOP AT notitem.

    CLEAR notitem-item_key.
    CALL FUNCTION 'MAP2I_BAPI2080_NOTITEMI_VIQMFE'
      EXPORTING
        bapi2080_notitemi = notitem
      CHANGING
        rfc_viqmfe        = t_viqmfe.

    CASE notitem-item_sort_no.
      WHEN '0001'.
*       Tipo de catálogo - Dano / Problema Defeito
        t_viqmfe-fekat = 'C'.
*      WHEN '0002'.
**       Tipo de catálogo - Parte
*        t_viqmfe-fekat = 'B'.
    ENDCASE.

    APPEND t_viqmfe.

  ENDLOOP.

*--- Loading data in table T_VIQMUR
  LOOP AT notifcaus.
    CLEAR notifcaus-item_key.
    CLEAR notifcaus-cause_key.
    CALL FUNCTION 'MAP2I_BAPI2080_NOTCAUSI_VIQMUR'
      EXPORTING
        bapi2080_notcausi = notifcaus
      CHANGING
        rfc_viqmur        = t_viqmur.
*   Tipo de catálogo - causas
    t_viqmur-urkat = '5'.
    APPEND t_viqmur.
  ENDLOOP.
*--- Loading data in table T_VIQMMA
  LOOP AT notifactv.
    CLEAR notifactv-act_key.
    CALL FUNCTION 'MAP2I_BAPI2080_NOTACTVI_VIQMMA'
      EXPORTING
        bapi2080_notactvi = notifactv
      CHANGING
        rfc_viqmma        = t_viqmma.
*   Tipo de catálogo - atividades
    t_viqmma-mnkat = 'A'.
    APPEND t_viqmma.
  ENDLOOP.
*--- Loading data in table T_VIQMSM
  LOOP AT notiftask.
    CLEAR notifactv-act_key.
    CALL FUNCTION 'MAP2I_BAPI2080_NOTTASKI_VIQMSM'
      EXPORTING
        bapi2080_nottaski = notiftask
      CHANGING
        rfc_viqmsm        = t_viqmsm.
    APPEND t_viqmsm.
  ENDLOOP.
*--- Loading data in table T_INLINES
  LOOP AT longtexts.
    CLEAR t_inlines.
    CALL FUNCTION 'MAP2I_BAPI2080_NOTFLTXTI_TLINE'
      EXPORTING
        bapi2080_notfulltxti = longtexts
      CHANGING
        rfc_tline            = t_inlines.
    APPEND t_inlines.
  ENDLOOP.
*--- Loading data in table T_IHPAVB
  LOOP AT notifpartnr.
    CLEAR t_hpavb.
    CALL FUNCTION 'MAP2I_BAPI2080_NOTPARTNRI_IHPA'
      EXPORTING
        bapi2080_notpartnri = notifpartnr
      CHANGING
        rfc_ihpa            = t_hpavb.
    APPEND t_hpavb.
  ENDLOOP.
*--- check relationship can be saved, if not only warning
  IF NOT sender IS INITIAL.
*--- conversion to internal structure
    f_sender-logsys = sender-log_system.
*--- check input data
    IF    NOT notifheader-refobjecttype IS INITIAL
      AND NOT notifheader-refobjectkey  IS INITIAL
      AND NOT notifheader-refreltype    IS INITIAL.
      g_bin_relation = 'X'.
    ELSE.
      CLEAR g_bin_relation.
      h_mess_wa-type = 'W'.
      h_mess_wa-cl = 'QM'.
      h_mess_wa-number = '187'.
      CALL FUNCTION 'BALW_BAPIRETURN_GET2'
        EXPORTING
          type   = h_mess_wa-type
          cl     = h_mess_wa-cl
          number = h_mess_wa-number
        IMPORTING
          return = return.
      APPEND return.
    ENDIF.
  ELSE.
    CLEAR g_bin_relation.
    CLEAR f_sender.
  ENDIF.

* Evitar mengagem:
* IM 107 Entrada de catálogo inválida
  FIELD-SYMBOLS: <fs_tq80_sakat> TYPE sakat.
  ASSIGN ('(SAPLIQS4)TQ80-SAKAT') TO <fs_tq80_sakat>.
  <fs_tq80_sakat> = 'B'.

*--- Create notification
  CALL FUNCTION 'IQS4_CREATE_NOTIFICATION'
    EXPORTING
      i_qmnum            = external_number
      i_aufnr            = orderid
      i_riqs5            = f_riqs5
      i_task_det         = ' '
      i_conv             = 'X'
      i_bin_relationship = g_bin_relation
      i_sender           = f_sender
      i_post             = ' '
      i_refresh_complete = ' '
      i_rfc_call         = 'X'                   "note 843127
    IMPORTING
      e_viqmel           = f_viqmel
    TABLES
      i_inlines_t        = t_inlines
      i_viqmfe_t         = t_viqmfe
      i_viqmur_t         = t_viqmur
      i_viqmsm_t         = t_viqmsm
      i_viqmma_t         = t_viqmma
      i_ihpa_t           = t_hpavb
      e_keys             = t_keys
      return             = return.
*--- Check fatal errors
  CALL FUNCTION 'IQS4_CHECK_ERROR_SEVERE'
    TABLES
      return       = return
    EXCEPTIONS
      severe_error = 1
      OTHERS       = 2.
  IF NOT sy-subrc IS INITIAL.
    EXIT.
  ENDIF.                               "notification's type is not valid
*--- Loading data in Structure NOTIFHEADER
  CALL FUNCTION 'MAP2E_VIQMEL_BAPI2080_NOTHDRE'
    EXPORTING
      viqmel           = f_viqmel
    CHANGING
      bapi2080_nothdre = notifheader_export.
*--- Loading data in table NOTITEM
  REFRESH notitem.
  CLEAR notitem.
  LOOP AT t_viqmfe.
    CALL FUNCTION 'MAP2E_VIQMFE_BAPI2080_NOTITEMI'
      EXPORTING
        rfc_viqmfe        = t_viqmfe
      CHANGING
        bapi2080_notitemi = notitem.
    APPEND notitem.
  ENDLOOP.
*--- Loading data in table NOTIFCAUS
  REFRESH notifcaus.
  CLEAR notifcaus.
  LOOP AT t_viqmur.
    CALL FUNCTION 'MAP2E_VIQMUR_BAPI2080_NOTCAUSI'
      EXPORTING
        rfc_viqmur        = t_viqmur
      CHANGING
        bapi2080_notcausi = notifcaus.
    APPEND notifcaus.
  ENDLOOP.
*--- Loading data in table NOTIFACTV
  REFRESH notifactv.
  CLEAR notifactv.
  LOOP AT t_viqmma.
    CALL FUNCTION 'MAP2E_VIQMMA_BAPI2080_NOTACTVI'
      EXPORTING
        rfc_viqmma        = t_viqmma
      CHANGING
        bapi2080_notactvi = notifactv.
    APPEND notifactv.
  ENDLOOP.
*--- Loading data in table NOTIFTASK
  REFRESH notiftask.
  CLEAR notiftask.
  LOOP AT t_viqmsm.
    CALL FUNCTION 'MAP2E_VIQMSM_BAPI2080_NOTTASKI'
      EXPORTING
        rfc_viqmsm        = t_viqmsm
      CHANGING
        bapi2080_nottaski = notiftask.
    APPEND notiftask.
  ENDLOOP.
*--- Loading data in the table : NOTIFPARTNR
  CLEAR   notifpartnr.
  REFRESH notifpartnr.
  LOOP AT t_hpavb.
    CLEAR notifpartnr.
    CALL FUNCTION 'MAP2E_IHPA_BAPI2080_NOTPARTNRI'
      EXPORTING
        rfc_ihpa            = t_hpavb
      CHANGING
        bapi2080_notpartnri = notifpartnr.
    APPEND notifpartnr.
  ENDLOOP.
*--- Loading data in table KEY_RELATIONSHIPS
  LOOP AT t_keys.
    CLEAR key_relationships.
    CALL FUNCTION 'MAP2E_RFC_KEY_BAPI2080_NOTKEYE'
      EXPORTING
        rfc_key          = t_keys
      CHANGING
        bapi2080_notkeye = key_relationships.
    APPEND key_relationships.
  ENDLOOP.

ENDFUNCTION.
