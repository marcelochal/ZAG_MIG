FUNCTION zalm_me_order_create.
*"----------------------------------------------------------------------
*"*"Interface local:
*"  IMPORTING
*"     REFERENCE(ORDER_HEADER) TYPE  ALM_ME_ORDER_HEADER
*"     REFERENCE(P_I_WA_CAMPOS_AD_CABECALHO) TYPE
*"        ZEPM_CAMPOS_AD_CABECALHO
*"     VALUE(I_PARTNER_TPA_KEY) TYPE  FLAG DEFAULT ' '
*"     VALUE(P_I_TESTRUN) TYPE  BAPIE1GLOBAL_DATA-TESTRUN OPTIONAL
*"  EXPORTING
*"     REFERENCE(E_ORDER_HEADER) TYPE  ALM_ME_ORDER_HEADER
*"  TABLES
*"      ORDER_OPERATION STRUCTURE  ALM_ME_ORDER_OPERATION OPTIONAL
*"      ORDER_PARTNER STRUCTURE  ALM_ME_PARTNER_KEY_STRUCT OPTIONAL
*"      ORDER_LONGTEXT STRUCTURE  ALM_ME_LONGTEXT OPTIONAL
*"      ORDER_USERSTATUS STRUCTURE  ALM_ME_USER_STATUS_CHANGES OPTIONAL
*"      RETURN STRUCTURE  BAPIRET2 OPTIONAL
*"----------------------------------------------------------------------

******************************************************************
* This module creates a PM/CS order.
* It uses the CRM order API (crm_cs_api_order_create)
******************************************************************

* order header
  DATA ls_bapi_order_header  TYPE bapi_order_header.
  DATA ls_order_header_exp   TYPE bapi_order_header.
  DATA ls_order_header       TYPE alm_me_order_header.
  DATA ls_notif_header       TYPE alm_me_notif_header.
  DATA order_or_notif VALUE 'O'.
* tables for module calls
*  DATA lt_order_operation  TYPE TABLE OF bapi_order_operation.
*  DATA lt_order_partner    TYPE TABLE OF bapi_ihpa.
*  DATA lt_order_longtext   TYPE TABLE OF bapi2080_notfulltxti.
* help structures for external tables
  DATA ls_operation LIKE LINE OF order_operation.
  DATA ls_partner   LIKE LINE OF order_partner.
  DATA ls_text      LIKE LINE OF order_longtext.
* structures
  DATA ls_order_operation  TYPE bapi_order_operation.
*  DATA ls_order_partner    TYPE bapi_ihpa.
  DATA ls_order_longtext   TYPE bapi2080_notfulltxti.

* Internal structures and tables
  DATA ls_caufvd        TYPE caufvd.
  DATA ls_e_caufvd      TYPE caufvd.
  DATA ls_pmsdo         TYPE pmsdo.
  DATA ls_pmsdo_matnr18 TYPE pmsdo_matnr18.
  DATA lt_afvgd         TYPE TABLE OF csapi_afvgd.
  DATA ls_afvgd         TYPE csapi_afvgd.
  DATA lt_ihpa          TYPE TABLE OF ihpa.
  DATA ls_ihpa          TYPE ihpa.
  DATA ls_iloa          TYPE iloa.

  DATA ls_equz TYPE equz.
  DATA ls_iflo TYPE iflo.

  DATA lt_vbadr   TYPE TABLE OF vbadr.
*  DATA ls_vbadr   TYPE vbadr.

  DATA lt_lines  TYPE TABLE OF tline.
  DATA ls_lines  TYPE tline.
  DATA lt_tline  TYPE TABLE OF csapi_tline.
  DATA ls_tline  TYPE csapi_tline.
  DATA lv_operationtexts.  "Operations passed
  DATA lv_retcd  TYPE sysubrc.
  DATA lv_message.                                          "#EC NEEDED
  DATA lv_date      LIKE sy-datum.                          "N1774973

  TYPE-POOLS itob.                                             ">K1
  CONSTANTS lc_itob_sg TYPE itob_types-bool VALUE 'X'.
  CONSTANTS lc_x VALUE 'X'.
  DATA lv_itob_handle TYPE itob_handle.
  DATA lt_itob_objtab TYPE itob_object_tab.
  DATA ls_itob_obj LIKE LINE OF lt_itob_objtab.
  DATA ls_itob_flags TYPE itob_flags_rec.                      "<K1

* Other help structures
  DATA ls_rfc_tline TYPE rfc_tline.
*StartNoteNumber1149113
  DATA: BEGIN OF ls_viqmel,
          tplnr    TYPE viqmel-tplnr,
          equnr    TYPE viqmel-tplnr,
          matnr    TYPE viqmel-matnr,
          priok    TYPE viqmel-priok,
          kdauf    TYPE viqmel-kdauf,
          kdpos    TYPE viqmel-kdpos,
          abckz    TYPE viqmel-abckz,
          serialnr TYPE viqmel-serialnr,
          qmtxt    TYPE viqmel-qmtxt,
        END OF ls_viqmel.
  DATA: ls_notif LIKE ls_viqmel.
*EndNoteNumber1149113
  DATA: ls_t350  TYPE t350,                                 "N1154163
        ls_t003o TYPE t003o.                                "N1154163
  DATA l_vbkd TYPE vbkd.

*--- deactivate dialogflag (bapis always no dialog)
  CALL FUNCTION 'DIALOG_SET_NO_DIALOG'.

  MOVE order_header TO ls_order_header.

*StartNoteNumber1149113
*Check whether order is created with respect to a notification
  IF NOT ls_order_header-notif_no IS INITIAL.

    SELECT SINGLE tplnr equnr matnr serialnr priok kdauf kdpos abckz qmtxt
    FROM viqmel INTO CORRESPONDING FIELDS OF ls_notif WHERE qmnum = ls_order_header-notif_no.

*    Check whether the order has any technical objects associated, if not assign it from
*    notification
    IF ls_order_header-equipment IS INITIAL AND ls_order_header-funct_loc IS INITIAL AND ls_order_header-material IS INITIAL.
      IF NOT ls_notif-tplnr  IS INITIAL.
        MOVE ls_notif-tplnr TO ls_order_header-funct_loc.
      ENDIF.
      IF NOT ls_notif-equnr  IS INITIAL.
        MOVE ls_notif-equnr TO ls_order_header-equipment.
      ENDIF.
      IF NOT ls_notif-matnr IS INITIAL.
        MOVE ls_notif-matnr TO ls_order_header-material.
        IF NOT ls_notif-serialnr  IS INITIAL.
          MOVE ls_notif-serialnr TO ls_order_header-serialno.
        ENDIF.
      ENDIF.
    ENDIF.

*StartNoteNumber1154163
    IF ls_order_header-sales_ord IS INITIAL AND ls_order_header-s_ord_item
    IS INITIAL.
      IF NOT ls_notif-kdauf IS INITIAL AND NOT ls_notif-kdpos IS INITIAL.
*  Customization has to be set inorder for the salesorder data to be
*  copied
        CALL FUNCTION 'CO_TA_T003O_READ'
          EXPORTING
            t003o_auart = ls_order_header-order_type
          IMPORTING
            t003owa     = ls_t003o
          EXCEPTIONS
            not_found   = 1.
        IF sy-subrc = 0 AND  ls_t003o-erloese IS INITIAL.
          CALL FUNCTION 'T350_READ'
            EXPORTING
              auart    = ls_order_header-order_type
              language = sy-langu
              mtype    = 'I'
            IMPORTING
              t350_wa  = ls_t350.

          IF NOT ls_t350-service IS INITIAL.
            MOVE ls_notif-kdauf TO ls_order_header-sales_ord.
            MOVE ls_notif-kdpos TO ls_order_header-s_ord_item.
          ENDIF.
        ENDIF.
      ENDIF.
    ENDIF.
*EndNoteNumber1154163

    IF ls_order_header-priority IS INITIAL .
      IF NOT ls_notif-priok IS INITIAL.
        MOVE ls_notif-priok  TO ls_order_header-priority.
      ENDIF.
    ENDIF.
    IF ls_order_header-short_text IS INITIAL .
      IF NOT ls_notif-qmtxt IS INITIAL.
        MOVE ls_notif-qmtxt  TO ls_order_header-short_text.
      ENDIF.
    ENDIF.
  ENDIF.
*EndNoteNumber1149113
* To convert the sales order number into internal DB format.

  IF ls_order_header-sales_ord IS NOT INITIAL.

    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
      EXPORTING
        input  = ls_order_header-sales_ord
      IMPORTING
        output = ls_order_header-sales_ord.
  ENDIF.

*StartNoteNumber 1377930
  IF ls_order_header-equipment IS INITIAL AND ls_order_header-funct_loc IS INITIAL AND
    ls_order_header-material IS NOT INITIAL AND ls_order_header-serialno IS NOT INITIAL.

    CALL FUNCTION 'SERIALNUMBER_READ'
      EXPORTING
        matnr                = ls_order_header-material
        sernr                = ls_order_header-serialno
      IMPORTING
        equz                 = ls_equz
      EXCEPTIONS
        equi_not_found       = 1
        authority_is_missing = 2
        err_handle           = 3
        lock_failure         = 4
        OTHERS               = 5.
    IF sy-subrc EQ 0.
      ls_order_header-equipment = ls_equz-equnr.
      CLEAR ls_equz.
    ENDIF.

  ENDIF.
*EndNoteNumber 1377930

* Map the *_CREATE fields to the according fields if set
  IF NOT ls_order_header-equipment_create IS INITIAL.
    TRANSLATE ls_order_header-equipment_create
      TO UPPER CASE.                                     "#EC TRANSLANG
    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'             "n718844
      EXPORTING
        input  = ls_order_header-equipment_create
      IMPORTING
        output = ls_order_header-equipment.
  ENDIF. "equipment create initial
  IF NOT ls_order_header-funcloc_create IS INITIAL.
    TRANSLATE ls_order_header-funcloc_create
      TO UPPER CASE.                                     "#EC TRANSLANG
    CALL FUNCTION 'CONVERSION_EXIT_TPLNR_INPUT'
      EXPORTING
        input     = ls_order_header-funcloc_create
*       I_FLG_CHECK_INTERNAL = 'X'
      IMPORTING
        output    = ls_order_header-funct_loc
      EXCEPTIONS
        not_found = 1
        OTHERS    = 2.
    IF sy-subrc NE 0.
      CALL FUNCTION 'ALM_ME_MESSAGE_TO_RETURN'
        TABLES
          return = return[].
      CALL FUNCTION 'DIALOG_SET_WITH_DIALOG'.
      EXIT.
    ENDIF.
  ENDIF. "funcloc create initial
* Check if the equipment has an superior
* functional location, and replace the given one when
* it does not match
  IF NOT ls_order_header-equipment IS INITIAL.
* An equipment is given, read the superior funcloc
    CALL FUNCTION 'EQUIPMENT_READ'
      EXPORTING
        equi_no        = ls_order_header-equipment
      IMPORTING
        iloa           = ls_iloa
        equz           = ls_equz
      EXCEPTIONS
        auth_no_begrp  = 1
        auth_no_iwerk  = 2
        auth_no_swerk  = 3
        eqkt_not_found = 4
        equi_not_found = 5
        equz_not_found = 6
        iloa_not_found = 7
        auth_no_ingrp  = 8
        auth_no_kostl  = 9
        err_handle     = 10
        lock_failure   = 11
        auth_no_badi   = 12
        OTHERS         = 13.
    IF sy-subrc NE 0.
      CALL FUNCTION 'ALM_ME_MESSAGE_TO_RETURN'
        TABLES
          return = return[].
* Equipment not vaild-> Don't need to continue
      EXIT.
    ENDIF. "Error handling
    IF ls_iloa-tplnr NE ls_order_header-funct_loc.
* Given funcloc does not match the one the equipment
* is istalled
* Technischer Platz & aus Equipment übernommen
      MESSAGE w006(im) WITH ls_iloa-tplnr INTO lv_message.
      CALL FUNCTION 'ALM_ME_MESSAGE_TO_RETURN'
        TABLES
          return = return.
      MOVE ls_iloa-tplnr TO ls_order_header-funct_loc.
    ENDIF.
    MOVE ls_iloa-proid TO ls_caufvd-pspel.
    IF NOT ls_equz-ingrp IS INITIAL.
      ls_order_header-plangroup = ls_equz-ingrp.
    ENDIF.

    IF NOT ls_iloa-vkorg IS INITIAL.
      ls_order_header-salesorg = ls_iloa-vkorg.
    ENDIF.

    IF NOT ls_iloa-vtweg IS INITIAL.
      ls_order_header-distr_chan = ls_iloa-vtweg.
    ENDIF.

    IF NOT ls_iloa-spart IS INITIAL.
      ls_order_header-division = ls_iloa-spart.
    ENDIF.

* StartNoteNumber 1369150
    IF ls_caufvd-gsber IS INITIAL AND NOT ls_iloa-gsber IS INITIAL.
      ls_order_header-bus_area = ls_iloa-gsber.
    ENDIF.
* EndNoteNumber 1369150

  ELSEIF NOT ls_order_header-funct_loc IS INITIAL.
*Read functional location details
    CALL FUNCTION 'FUNC_LOCATION_READ'
      EXPORTING
        tplnr           = ls_order_header-funct_loc
      IMPORTING
        iflo_wa         = ls_iflo
      EXCEPTIONS
        iflot_not_found = 4
        iloa_not_found  = 6
        OTHERS          = 4.
    IF sy-subrc <> 0.
      CALL FUNCTION 'ALM_ME_MESSAGE_TO_RETURN'
        TABLES
          return = return[].
      EXIT.
    ENDIF.

    IF NOT ls_iflo-ingrp IS INITIAL.
      ls_order_header-plangroup = ls_iflo-ingrp.
    ENDIF.
    MOVE ls_iflo-proid TO ls_caufvd-pspel.

    IF NOT ls_iflo-vkorg IS INITIAL.
      ls_order_header-salesorg = ls_iflo-vkorg.
    ENDIF.

    IF NOT ls_iflo-vtweg IS INITIAL.
      ls_order_header-distr_chan = ls_iflo-vtweg.
    ENDIF.

    IF NOT ls_iflo-spart IS INITIAL.
      ls_order_header-division = ls_iflo-spart.
    ENDIF.

* StartNoteNumber 1369150
    IF ls_caufvd-gsber IS INITIAL AND NOT ls_iflo-gsber IS INITIAL.
      ls_order_header-bus_area = ls_iflo-gsber.
    ENDIF.
* EndNoteNumber 1369150

  ENDIF. "equipment is filled

* Check or determine planning plant
  PERFORM determine_planning_plant
              CHANGING
                 ls_order_header
                 ls_notif_header
                 order_or_notif
                 return[].


***********************************************************
* Convert all the external structures in the internal used
* representation
***********************************************************
*--- structures
* ORDER_HEADER => CAUFVD
* ORDER_PMSDO  => PMSDO

* CALL FUNCTION 'MAP2I_ALM_ME_ORDER_HEADER_TO_C'
  CALL FUNCTION 'ZMAP2I_ALM_ME_ORDER_HEAD_TO_C'
    EXPORTING
      alm_me_order_header        = ls_order_header
      p_i_wa_campos_ad_cabecalho = p_i_wa_campos_ad_cabecalho
    CHANGING
      caufvd                     = ls_caufvd.

* Bapi_order_header -> pmsdo
*  MOVE-CORRESPONDING order_header TO ls_bapi_order_header.  "#EC ENHOK     "N1989169
  MOVE-CORRESPONDING ls_order_header TO ls_bapi_order_header. "#EC ENHOK   "N1989169
  MOVE ls_order_header-salesorg TO ls_bapi_order_header-sales_org. "N1989169

  CALL FUNCTION 'MAP2I_BAPI_ORDER_HEADER_TO_PMS'
    EXPORTING
      bapi_order_header = ls_bapi_order_header
    CHANGING
      pmsdo             = ls_pmsdo.
* start of note 1989169
  ls_pmsdo-vkgrp = ls_iloa-vkgrp.
  ls_pmsdo-vkbur = ls_iloa-vkbur.
* end of note 1989169
* start of note 1546810
  IF NOT ( ls_order_header-sales_ord IS INITIAL AND ls_order_header-s_ord_item IS INITIAL ).

    CALL FUNCTION 'SD_VBKD_SELECT'
      EXPORTING
        i_document_number = ls_order_header-sales_ord
        i_item_number     = ls_order_header-s_ord_item
      IMPORTING
        e_vbkd            = l_vbkd
      EXCEPTIONS
        entry_not_found   = 1
        OTHERS            = 2.

    ls_pmsdo-ffprf = l_vbkd-ffprf.

  ELSEIF NOT ls_order_header-notif_no IS INITIAL.

    CALL FUNCTION 'SD_VBKD_SELECT'
      EXPORTING
        i_document_number = ls_notif-kdauf
        i_item_number     = ls_notif-kdpos
      IMPORTING
        e_vbkd            = l_vbkd
      EXCEPTIONS
        entry_not_found   = 1
        OTHERS            = 2.

    ls_pmsdo-ffprf = l_vbkd-ffprf.

  ENDIF.

* end of note 1546810

* StartNote 1891963
* for a service order with revenues, we need another priority of DIP
* values determination: Customizing entry always overrides, if existing
  CALL FUNCTION 'T350_READ'
    EXPORTING
      auart    = ls_order_header-order_type
      language = sy-langu
      mtype    = 'I'
    IMPORTING
      t350_wa  = ls_t350.
  IF ls_pmsdo-ffprf IS INITIAL.
    ls_pmsdo-ffprf = ls_t350-ffprf.
  ENDIF.
* StartNote 1989169
  CALL FUNCTION 'CO_TA_T003O_READ'
    EXPORTING
      t003o_auart = ls_order_header-order_type
    IMPORTING
      t003owa     = ls_t003o
    EXCEPTIONS
      not_found   = 1.
* EndNote 1989169
  IF sy-subrc = 0 AND ls_t003o-erloese IS NOT INITIAL.
    CLEAR ls_pmsdo-faktf.
    ls_pmsdo-ffprf = ls_t350-ffprf.
  ENDIF.
* EndNote 1891963

* StartNote 1774973
  IF NOT ( ls_caufvd-kdauf_aufk IS INITIAL AND ls_caufvd-kdpos_aufk IS INITIAL ).

* set date to check contract
    IF NOT ls_caufvd-gstrs IS INITIAL.
      lv_date  = ls_caufvd-gstrs.
    ELSEIF NOT ls_caufvd-gstrp IS INITIAL.
      lv_date  = ls_caufvd-gstrp.
    ELSEIF NOT ls_caufvd-erdat IS INITIAL.
      lv_date  = ls_caufvd-erdat.
    ELSE.
      lv_date = sy-datum.
    ENDIF.
* check sd position
    CALL FUNCTION 'PM_SD_CONTRACT_CHECK'
      EXPORTING
        vbeln         = ls_caufvd-kdauf_aufk
        vposn         = ls_caufvd-kdpos_aufk
        date          = lv_date
        time          = sy-uzeit
        equnr         = ls_caufvd-equnr
        tplnr         = ls_caufvd-tplnr
        werks         = ls_caufvd-werks
        kokrs         = ls_caufvd-kokrs
        matnr         = ls_caufvd-sermat
        kunum         = ls_caufvd-kunum
      IMPORTING
        x_ps_psp_pnr  = ls_caufvd-pspel
      EXCEPTIONS
        no_contract   = 1
        error_message = 2
        OTHERS        = 3.
    IF sy-subrc <> 0.
      IF sy-subrc = 1.
      ELSE.
        CALL FUNCTION 'ALM_ME_MESSAGE_TO_RETURN'
          TABLES
            return = return[].
        CALL FUNCTION 'DIALOG_SET_WITH_DIALOG'.
      ENDIF.
    ENDIF.
  ENDIF.
* EndNote 1774973

* OPERATIONS   => TI_AFVGD
  LOOP AT order_operation INTO ls_operation.
    MOVE-CORRESPONDING ls_operation TO ls_order_operation.  "#EC ENHOK
    CALL FUNCTION 'MAP2I_BAPI_OPERATION_TO_AFVGD'
      EXPORTING
        bapi_order_operation = ls_order_operation
      CHANGING
        csapi_afvgd          = ls_afvgd.

    ls_afvgd-einsa = ls_operation-constraint_type_start.    "^1031931"
    ls_afvgd-einse = ls_operation-constraint_type_finish.
    ls_afvgd-ntanf = ls_operation-start_cons.
    ls_afvgd-ntanz = ls_operation-strttimcon.
    ls_afvgd-ntend = ls_operation-fin_constr.
    ls_afvgd-ntenz = ls_operation-fintimcons.

*   fill ls_afvgd-arbid
    CALL FUNCTION 'CR_WORKSTATION_CHECK'
      EXPORTING
        arbpl         = ls_operation-work_cntr
*       MSGTY         = 'E'
        werks         = ls_operation-plant
      IMPORTING
        arbid         = ls_afvgd-arbid
      EXCEPTIONS
        error_message = 1.

    IF sy-subrc NE 0.
      CALL FUNCTION 'ALM_ME_MESSAGE_TO_RETURN'
        TABLES
          return = return.
* Do not append the operation, continue checking the next
      CONTINUE.
    ENDIF.
* Check the work and time units and fill in default values
* when nothing is provided from the frontend.
    IF ls_afvgd-arbeh IS INITIAL.
* Work unit is empty, read the customizing
      SELECT SINGLE arbeh FROM t399i INTO ls_afvgd-arbeh
        WHERE  iwerk EQ ls_order_header-planplant.
    ENDIF.
    IF ls_afvgd-daune IS INITIAL.
* Operation time is intitial
      SELECT SINGLE daune FROM t399i INTO ls_afvgd-daune
        WHERE  iwerk EQ ls_order_header-planplant.
    ENDIF.
    IF ls_afvgd-steus IS INITIAL.
* Control key empty
      PERFORM get_default_ctrl_key USING    order_header-order_type
                                            order_header-planplant
                                   CHANGING ls_afvgd-steus.
    ENDIF.
* Append the operation to the operations table
    APPEND ls_afvgd TO lt_afvgd.
  ENDLOOP.


* PARTNER      => TI_IHPA

* check order partners                                "n753799
* partner role input conversion
  CALL FUNCTION 'ALM_ME_PARTNER_INPUT_CONVERSN'
    CHANGING
      ct_partner = order_partner[].

  CALL FUNCTION 'ALM_ME_ORDER_PARTNER_CHECK'
    EXPORTING
      i_order_partners  = order_partner[]
      i_order_type      = order_header-order_type
      i_partner_tpa_key = i_partner_tpa_key
    CHANGING
      return            = return[]
    EXCEPTIONS
      partner_not_valid = 1
      OTHERS            = 2.
  IF sy-subrc <> 0.
*   error message is already in return table
    CALL FUNCTION 'DIALOG_SET_WITH_DIALOG'.
    EXIT.
  ENDIF.

  LOOP AT order_partner INTO ls_partner.
*    CALL FUNCTION 'MAP2I_BAPI_IHPA_TO_IHPA'
*         EXPORTING
*              bapi_ihpa = ls_order_partner
*         CHANGING
*              ihpa      = ls_ihpa.
    IF i_partner_tpa_key = lc_x.
      CALL FUNCTION 'ALM_ME_PARTNER_KEY_SPLIT_TPA'
        EXPORTING
          partner_key = ls_partner-partner_key
        IMPORTING
*         PARTNER_TYPE =
          partner_id  = ls_ihpa-parnr
*         ADDRESS_ID  =
        .
*     partner role parvw has to be filled by frontend
*     (input conversion was done above)
      MOVE ls_partner-partner_role TO ls_ihpa-parvw.

    ELSE.
      CALL FUNCTION 'ALM_ME_PARTNER_KEY_SPLIT'
        EXPORTING
          partner_key = ls_partner-partner_key
        IMPORTING
          partn_role  = ls_ihpa-parvw
          counter     = ls_ihpa-counter
          partner     = ls_ihpa-parnr.
*               ADDR_NO     = ls_ihpa
    ENDIF.
    APPEND ls_ihpa TO lt_ihpa.
  ENDLOOP.

* Long texts **********************************************
* LT_TLINE  = Operation texts
* LT_TLINES = Order header texts
* Before we throw away the line numbering, we want so sort
* the text by linenumbers
  SORT order_longtext.

* Preprocess the longtexts
  LOOP AT order_longtext INTO ls_text.
    MOVE-CORRESPONDING ls_text TO ls_order_longtext.
    CALL FUNCTION 'MAP2I_BAPI2080_NOTFLTXTI_TLINE'
      EXPORTING
        bapi2080_notfulltxti = ls_order_longtext
      CHANGING
        rfc_tline            = ls_rfc_tline.

* Operation Texts
    IF ls_rfc_tline-refobjtyp = gc_textid_operation.
      MOVE  ls_rfc_tline-tdformat   TO ls_tline-tdformat.
      MOVE  ls_rfc_tline-tdline     TO ls_tline-tdline.
      MOVE  ls_rfc_tline-refobjtyp  TO ls_tline-refobjtyp.
* Longtext for operation, save operation number
* Copy the line to the lt_line table for operation texts
      MOVE ls_rfc_tline-objkey(4) TO ls_tline-vornr.
      MOVE 'X' TO lv_operationtexts.
      APPEND ls_tline TO lt_tline.
    ENDIF. "Operations

* Header Texts
    IF ls_rfc_tline-refobjtyp = gc_textobject.
      IF ls_text-line_number EQ 0.
* Line number 0 is synchronized with the short text line
* Mix the shorttext with the first line of the longtext
        IF NOT ls_caufvd-ktext IS INITIAL.
* Only if there is a shorttext, copy first 40 characters
* of shorttext to the longtext
          MOVE ls_caufvd-ktext(40) TO ls_rfc_tline-tdline(40).
          CLEAR ls_caufvd-ktext.
        ENDIF. "
      ENDIF. "Line 0 special treatment
* Copy the line to the lt_lines table for header texts
      MOVE  ls_rfc_tline-tdformat   TO ls_lines-tdformat.
      MOVE  ls_rfc_tline-tdline     TO ls_lines-tdline.
      APPEND ls_lines TO lt_lines.
    ENDIF. "Header
  ENDLOOP.

* Reformat the header text
  CALL FUNCTION 'FORMAT_TEXTLINES'
    EXPORTING
      formatwidth = 64
    TABLES
      lines       = lt_lines
    EXCEPTIONS
      bound_error = 1
      OTHERS      = 2.
  IF sy-subrc NE 0.
    CALL FUNCTION 'ALM_ME_MESSAGE_TO_RETURN'
      TABLES
        return = return.
    CALL FUNCTION 'DIALOG_SET_WITH_DIALOG'.
    EXIT.
  ENDIF. "Error checking
  MOVE gc_textobject    TO ls_tline-refobjtyp.
  CLEAR                    ls_tline-vornr.
  LOOP AT lt_lines INTO ls_lines.
    MOVE ls_lines-tdformat TO ls_tline-tdformat.
    MOVE ls_lines-tdline   TO ls_tline-tdline.
    APPEND ls_tline TO lt_tline.
  ENDLOOP. "lt_lines

*--- order header: workcenter id must be filled
  IF ls_caufvd-gewrk IS INITIAL .
    CALL FUNCTION 'CR_WORKSTATION_CHECK'
      EXPORTING
        arbpl         = ls_caufvd-vaplz
*       MSGTY         = 'E'
        werks         = ls_caufvd-vawrk
      IMPORTING
        arbid         = ls_caufvd-gewrk
      EXCEPTIONS
        error_message = 1.

    IF sy-subrc <> 0.
      CALL FUNCTION 'ALM_ME_MESSAGE_TO_RETURN'
        TABLES
          return = return.
    ENDIF.
  ENDIF.

*--- scheduling data
* priok filled? --> gstrp and gltrp can be initial
  IF ls_caufvd-priok IS INITIAL.
    PERFORM check_order_create_sched_data CHANGING ls_caufvd
                                                   return[] .
  ENDIF.

*--- business area                                      "K1>
*    if gsber initial --> take gsber assigned to object
  IF ls_caufvd-gsber IS INITIAL.
    CLEAR ls_itob_obj. CLEAR ls_itob_flags.

    IF NOT ls_caufvd-tplnr IS INITIAL.
      ls_itob_flags-i_type = '01'.  "floc
      ls_itob_obj-tplnr = ls_caufvd-tplnr.

    ELSEIF NOT ls_caufvd-equnr IS INITIAL.
      ls_itob_flags-i_type = '02'.  "equi
      ls_itob_obj-equnr = ls_caufvd-equnr.
    ENDIF.

*   i_type initial -> no object -> cannot read
    IF NOT ls_itob_flags-i_type IS INITIAL.
      APPEND ls_itob_obj TO lt_itob_objtab.
      CALL FUNCTION 'ITOB_OBJECT_READ'
        EXPORTING
          i_handle       = lv_itob_handle
          i_itob_flags   = ls_itob_flags
*         I_LOCK_ONLY    =
          i_single_mode  = lc_itob_sg
*          IMPORTING
*         E_COUNT_NOT_READ =
*         E_ITOB_TAB     =
        CHANGING
          c_object_tab   = lt_itob_objtab
        EXCEPTIONS
          not_successful = 1
          OTHERS         = 2.
    ENDIF.

    IF sy-subrc = 0.
      READ TABLE lt_itob_objtab INTO ls_itob_obj INDEX 1.
      IF NOT ls_itob_obj-gsber IS INITIAL.
        ls_caufvd-gsber = ls_itob_obj-gsber.
      ENDIF.
    ENDIF.

  ENDIF.                                                "<K1
  CALL FUNCTION 'ALM_ME_EQUI_SERNR_CHECK'
    EXPORTING
      equipment           = ls_caufvd-equnr
      material            = ls_caufvd-sermat
      serialno            = ls_caufvd-serialnr
    EXCEPTIONS
      data_does_not_match = 1
      OTHERS              = 2.
  IF sy-subrc NE 0.
    CALL FUNCTION 'ALM_ME_MESSAGE_TO_RETURN'
      TABLES
        return = return.
    CALL FUNCTION 'DIALOG_SET_WITH_DIALOG'.
    EXIT.
  ENDIF.


* Set the WO_FLAG to enable the dark processing
  MOVE lc_x TO ls_caufvd-wo_flag.

**************************************************************
* Call the CRM API to create an order
**************************************************************
* needed parameters
*   header
*     (caufvd)      autyp, auart, iwerk, gewrk, gstrp (caufvd)
*   operation
*     (csapi_afvgd) arbid (determine via work_cntr and plant)
*                   vornr, steus
**************************************************************

  DATA: l_commit,
        l_post.

  IF NOT p_i_testrun IS INITIAL.
    l_commit = space.
    l_post   = space.
  ELSE.
    l_commit = 'X'.
    l_post   = 'X'.
  ENDIF.

  CALL FUNCTION 'CO_ZF_DATA_RESET_COMPLETE'.

* Mapping LNUM
  MOVE-CORRESPONDING ls_pmsdo TO ls_pmsdo_matnr18.
  MOVE ls_pmsdo-matnr TO ls_pmsdo_matnr18-matnr_long.
  CALL FUNCTION 'CRM_CS_API_ORDER_CREATE'
    EXPORTING
      i_caufvd      = ls_caufvd
      i_pmsdo       = ls_pmsdo_matnr18
      i_post        = l_post
      i_commit      = l_commit
      i_wait        = ' '
      i_calc_prio   = ' '
      i_upd_key_ref = 'X'
    IMPORTING
      e_caufvd      = ls_e_caufvd
    TABLES
      te_return     = return
      ti_afvgd      = lt_afvgd
      ti_ihpa       = lt_ihpa
      ti_tline      = lt_tline
      ti_vbadr      = lt_vbadr
    EXCEPTIONS
      error_message = 1.

  IF sy-subrc = 0.
    APPEND ls_afvgd TO lt_afvgd.
  ELSE.
    CALL FUNCTION 'ALM_ME_MESSAGE_TO_RETURN'
      TABLES
        return = return.
  ENDIF.

* Add the longtexts of operations if available
  IF lv_operationtexts NE space.
    PERFORM create_operationtexts TABLES lt_tline
                                  USING ls_e_caufvd
                                        lv_retcd.
    IF lv_retcd NE 0.
      CALL FUNCTION 'ALM_ME_MESSAGE_TO_RETURN'
        TABLES
          return = return.
      CALL FUNCTION 'DIALOG_SET_WITH_DIALOG'.
      EXIT.
    ENDIF.
  ENDIF.

* Do the user status changes
  IF NOT order_userstatus[] IS INITIAL.
    CALL FUNCTION 'ALM_ME_ORDER_USERSTATUS_CHANGE'
      EXPORTING
        order_id            = ls_e_caufvd-aufnr
      TABLES
        order_user_status   = order_userstatus
        return              = return[]
      EXCEPTIONS
        status_change_error = 1
        OTHERS              = 2.

    IF sy-subrc NE 0.
* Error
      CALL FUNCTION 'DIALOG_SET_WITH_DIALOG'.
      EXIT.
    ENDIF.
  ENDIF. "user status change table filled?

***********************************************************
* Convert all the internal used structures in the external
* representation
***********************************************************
* CAUFVD => ORDER_HEADER
  CALL FUNCTION 'MAP2E_CAUFVD_TO_BAPI_ORDER_HEA'
    EXPORTING
      caufvd            = ls_e_caufvd
    CHANGING
      bapi_order_header = ls_order_header_exp.

* Fill export structure e_order_header
  CLEAR e_order_header.
  MOVE-CORRESPONDING ls_order_header_exp TO e_order_header. "#EC ENHOK
  MOVE ls_order_header_exp-material_long TO e_order_header-material.        "MFLE

  CALL FUNCTION 'DIALOG_SET_WITH_DIALOG'.

ENDFUNCTION.

INCLUDE lalm_me_orderf20.
INCLUDE lalm_me_orderf19.
INCLUDE lalm_me_orderf16.
INCLUDE lalm_me_orderf17.
