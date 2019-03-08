FUNCTION zmap2i_zbus2002_new_to_caufvd .
*"----------------------------------------------------------------------
*"*"Interface local:
*"  IMPORTING
*"     REFERENCE(BAPI_BUS2002_NEW) LIKE  ZEPS_BAPI_BUS2002_NEW
*"       STRUCTURE  ZEPS_BAPI_BUS2002_NEW
*"  CHANGING
*"     REFERENCE(CAUFVD) LIKE  CAUFVD STRUCTURE  CAUFVD
*"  EXCEPTIONS
*"      ERROR_CONVERTING_KEYS
*"----------------------------------------------------------------------

* This function module was generated. Don't change it manually!
* <VERSION>|4
* <BAPI_STRUCTURE>|bapi_bus2002_new
* <SAP_STRUCTURE>|CAUFVD
* <INTERN_TO_EXTERN>|
* <APPEND FORM>|X

  DATA: netw_new LIKE bapi_network,
        lv_subrc LIKE sy-subrc,
        lv_vornt TYPE cn_vornrt.

  MOVE-CORRESPONDING bapi_bus2002_new TO netw_new.

* Check value of NOT_MRP_APPLICABLE (NO_DISP) already here to avoid
* unspecific message e002(00) from old BAPI logic
  IF bapi_bus2002_new-not_mrp_applicable CN ' X123'.
*   Interfaced value is not supported
    MESSAGE e088(cnif_pi) INTO null.
    PERFORM put_sy_message(saplco2o).
    RAISE error_converting_keys.
  ENDIF.

* Some external field names were renamed in new BAPI (whyever)
  netw_new-objectclass_ext      = bapi_bus2002_new-objectclass.
  netw_new-sched_type_forecast  = bapi_bus2002_new-sched_type_fcst.
  netw_new-start_date_forecast  = bapi_bus2002_new-start_date_fcst.
  netw_new-finish_date_forecast = bapi_bus2002_new-finish_date_fcst.

  CALL FUNCTION 'MAP2I_BAPI_NETWORK_TO_CAUFVD'
    EXPORTING
      bapi_network = netw_new
    CHANGING
      caufvd       = caufvd.

* <BAPI_FIELD>|BUS_AREA
* <SAP_FIELD>|GSBER
* <CODE_PART>|A_MOVE
* <ADD_FIELD>|
  MOVE bapi_bus2002_new-bus_area
    TO caufvd-gsber                                                 .

* <BAPI_FIELD>|SALES_DOC_ITEM
* <SAP_FIELD>|VBELP
* <CODE_PART>|A_MOVE
* <ADD_FIELD>|
  MOVE bapi_bus2002_new-sales_doc_item
    TO caufvd-vbelp                                                 .

* <BAPI_FIELD>|SALES_DOC
* <SAP_FIELD>|VBELN
* <CODE_PART>|A_MOVE
* <ADD_FIELD>|
  MOVE bapi_bus2002_new-sales_doc
    TO caufvd-vbeln                                                 .

* <BAPI_FIELD>|COST_VAR_PLAN
* <SAP_FIELD>|KLVARP
* <CODE_PART>|A_MOVE
* <ADD_FIELD>|
  MOVE bapi_bus2002_new-cost_var_plan
    TO caufvd-klvarp                                                .

* <BAPI_FIELD>|COST_VAR_ACTUAL
* <SAP_FIELD>|KLVARI
* <CODE_PART>|A_MOVE
* <ADD_FIELD>|
  MOVE bapi_bus2002_new-cost_var_actual
    TO caufvd-klvari                                                .

* <BAPI_FIELD>|OVERHEAD_KEY
* <SAP_FIELD>|ZSCHL
* <CODE_PART>|A_MOVE
* <ADD_FIELD>|
  MOVE bapi_bus2002_new-overhead_key
    TO caufvd-zschl                                                 .

* <BAPI_FIELD>|COST_SHEET
* <SAP_FIELD>|KALSM
* <CODE_PART>|A_MOVE
* <ADD_FIELD>|
  MOVE bapi_bus2002_new-cost_sheet
    TO caufvd-kalsm                                                 .

* <BAPI_FIELD>|EXEC_FACTOR
* <SAP_FIELD>|AUFKT
* <CODE_PART>|A_MOVE
* <ADD_FIELD>|
  MOVE bapi_bus2002_new-exec_factor
    TO caufvd-aufkt                                                 .

* <BAPI_FIELD>|CHANGE_NO
* <SAP_FIELD>|AENNR
* <CODE_PART>|A_MOVE
* <ADD_FIELD>|
  MOVE bapi_bus2002_new-change_no
    TO caufvd-aennr                                                 .

* <BAPI_FIELD>|PLANNER_GROUP
* <SAP_FIELD>|PLGRP
* <CODE_PART>|A_MOVE
* <ADD_FIELD>|
  MOVE bapi_bus2002_new-planner_group
    TO caufvd-plgrp .

* <BAPI_FIELD>|NO_CAP_REQUIREMENTS
* <SAP_FIELD>|KBED
* <CODE_PART>|A_MOVE
* <ADD_FIELD>|
  MOVE bapi_bus2002_new-no_cap_requirements
    TO caufvd-kbed.

* <BAPI_FIELD>|SCHEDULING_EXACT_BREAK_TIMES
* <SAP_FIELD>|BREAKS
* <CODE_PART>|A_MOVE
* <ADD_FIELD>|
  MOVE bapi_bus2002_new-scheduling_exact_break_times
    TO caufvd-breaks.

* <BAPI_FIELD>|CURRENCY
* <SAP_FIELD>|WAERS
* <CODE_PART>|A_MOVE
* <ADD_FIELD>|
  MOVE bapi_bus2002_new-currency
    TO caufvd-waers.

* <BAPI_FIELD>|SUPERIOR_NETW
* <SAP_FIELD>|AUFNT
* <CODE_PART>|A_MOVE
* <ADD_FIELD>|
  MOVE bapi_bus2002_new-superior_netw
    TO caufvd-aufnt.

*--------------------------------------------------------------*
* Campos adicionais                                            *
*--------------------------------------------------------------*

* Centro de custo responsável
  MOVE bapi_bus2002_new-kostv
    TO caufvd-kostv                                                 .

*--------------------------------------------------------------*


* <BAPI_FIELD>|SUPERIOR_NETW_ACT
* <SAP_FIELD>|APLZT
* <CODE_PART>|EXTERNAL_TO_INTERNAL
* <ADD_FIELD>|
  lv_vornt = bapi_bus2002_new-superior_netw_act.
  IF NOT lv_vornt IS INITIAL.
    PERFORM get_aplzt_for_aufnt_vornt
            USING    caufvd-aufnt
                     lv_vornt
            CHANGING caufvd-aplzt
                     lv_subrc.
    IF NOT lv_subrc IS INITIAL.
      MESSAGE e053(cnif_pi) WITH lv_vornt caufvd-aufnt INTO null.
      PERFORM put_sy_message(saplco2o).
      RAISE error_converting_keys.
    ENDIF.
  ENDIF.

* Re-treat mapping of NOT_AUTO_COSTING
  IF bapi_bus2002_new-not_auto_costing EQ '0' OR
     bapi_bus2002_new-not_auto_costing EQ 'X'.
    caufvd-aucost  = space.
    caufvd-naucost = con_yes.
    caufvd-nopcost = con_yes.
    caufvd-costupd = space.
  ELSEIF bapi_bus2002_new-not_auto_costing EQ '1'.
    caufvd-aucost  = space.
    caufvd-naucost = con_yes.
    caufvd-nopcost = space.
    caufvd-costupd = space.
  ELSEIF bapi_bus2002_new-not_auto_costing EQ '2'.
    caufvd-aucost  = con_yes.
    caufvd-naucost = space.
    caufvd-nopcost = space.
    caufvd-costupd = space.
  ELSEIF bapi_bus2002_new-not_auto_costing EQ '3'.
    caufvd-aucost  = space.
    caufvd-naucost = con_yes.
    caufvd-nopcost = space.
    caufvd-costupd = con_yes.
  ELSEIF bapi_bus2002_new-not_auto_costing EQ '4'.
    caufvd-aucost  = con_yes.
    caufvd-naucost = space.
    caufvd-nopcost = space.
    caufvd-costupd = con_yes.
  ELSEIF bapi_bus2002_new-not_auto_costing EQ space.
*   Create mode & SPACE: keep all four fields initial and let module
*   CO_ZF_GET_GENERAL_DATA do the defaulting. But: if it least one of
*   these four fields is set, restore values determined within here,
*   afterwards
    caufvd-aucost  = space.
    caufvd-naucost = space.
    caufvd-nopcost = space.
    caufvd-costupd = space.
  ELSE.
*   Interfaced value is not supported
    MESSAGE e057(cnif_pi) INTO null.
    PERFORM put_sy_message(saplco2o).
    RAISE error_converting_keys.
  ENDIF.

* Re-treat mapping of NOT_MRP_APPLICABLE
  IF bapi_bus2002_new-not_mrp_applicable EQ '1' OR
     bapi_bus2002_new-not_mrp_applicable EQ 'X'.
    caufvd-no_disp = '1'.
    caufvd-audisp  = '1'.
  ELSEIF bapi_bus2002_new-not_mrp_applicable = '2'.
    caufvd-no_disp = 'X'.
    caufvd-audisp  = '2'.
  ELSEIF bapi_bus2002_new-not_mrp_applicable = '3'.
    caufvd-no_disp = space.
    caufvd-audisp  = '3'.
  ELSEIF bapi_bus2002_new-not_mrp_applicable = space.
*   Create mode & SPACE: keep all two fields initial and let module
*   CO_ZF_GET_GENERAL_DATA do the defaulting. But: if it least one of
*   these two fields is set, restore values determined within here,
*   afterwards
    caufvd-no_disp = space.
    caufvd-audisp  = space.
  ENDIF.

ENDFUNCTION.
