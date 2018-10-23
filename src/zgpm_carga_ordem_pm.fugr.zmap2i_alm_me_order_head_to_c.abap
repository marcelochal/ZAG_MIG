FUNCTION zmap2i_alm_me_order_head_to_c.
*"----------------------------------------------------------------------
*"*"Interface local:
*"  IMPORTING
*"     REFERENCE(ALM_ME_ORDER_HEADER) LIKE  ALM_ME_ORDER_HEADER
*"       STRUCTURE  ALM_ME_ORDER_HEADER
*"     REFERENCE(P_I_WA_CAMPOS_AD_CABECALHO) TYPE
*"        ZEPM_CAMPOS_AD_CABECALHO
*"  CHANGING
*"     REFERENCE(CAUFVD) LIKE  CAUFVD STRUCTURE  CAUFVD
*"  EXCEPTIONS
*"      ERROR_CONVERTING_ISO_CODE
*"----------------------------------------------------------------------

* This function module was generated. Don't change it manually!
* <VERSION>|4
* <BAPI_STRUCTURE>|ALM_ME_ORDER_HEADER
* <SAP_STRUCTURE>|CAUFVD
* <INTERN_TO_EXTERN>|
* <APPEND FORM>|

* <BAPI_FIELD>|SCALE
* <SAP_FIELD>|SIZECL
* <CODE_PART>|A_MOVE
* <ADD_FIELD>|
  MOVE alm_me_order_header-material
    TO caufvd-sermat.

* <BAPI_FIELD>|SCALE
* <SAP_FIELD>|SIZECL
* <CODE_PART>|A_MOVE
* <ADD_FIELD>|
  MOVE alm_me_order_header-scale
    TO caufvd-sizecl                                                .

* <BAPI_FIELD>|INVEST_PROFILE
* <SAP_FIELD>|IVPRO
* <CODE_PART>|A_MOVE
* <ADD_FIELD>|
  MOVE alm_me_order_header-invest_profile
    TO caufvd-ivpro                                                 .

* <BAPI_FIELD>|CALC_MOTIVE
* <SAP_FIELD>|BEMOT
* <CODE_PART>|A_MOVE
* <ADD_FIELD>|
  MOVE alm_me_order_header-calc_motive
    TO caufvd-bemot                                                 .

* <BAPI_FIELD>|S_ORD_ITEM
* <SAP_FIELD>|KDPOS_AUFK
* <CODE_PART>|A_MOVE
* <ADD_FIELD>|
  MOVE alm_me_order_header-s_ord_item
    TO caufvd-kdpos_aufk                                            .

* <BAPI_FIELD>|SALES_ORD
* <SAP_FIELD>|KDAUF_AUFK
* <CODE_PART>|A_MOVE
* <ADD_FIELD>|
  MOVE alm_me_order_header-sales_ord
    TO caufvd-kdauf_aufk                                            .

* <BAPI_FIELD>|INV_REASON
* <SAP_FIELD>|IZWEK
* <CODE_PART>|A_MOVE
* <ADD_FIELD>|
  MOVE alm_me_order_header-inv_reason
    TO caufvd-izwek                                                 .

* <BAPI_FIELD>|RES_ANAL_KEY
* <SAP_FIELD>|ABGSL
* <CODE_PART>|A_MOVE
* <ADD_FIELD>|
  MOVE alm_me_order_header-res_anal_key
    TO caufvd-abgsl                                                 .

* <BAPI_FIELD>|OVERHEAD_KEY
* <SAP_FIELD>|ZSCHL
* <CODE_PART>|A_MOVE
* <ADD_FIELD>|
  MOVE alm_me_order_header-overhead_key
    TO caufvd-zschl                                                 .

* <BAPI_FIELD>|CSTG_SHEET
* <SAP_FIELD>|KALSM
* <CODE_PART>|A_MOVE
* <ADD_FIELD>|
  MOVE alm_me_order_header-cstg_sheet
    TO caufvd-kalsm                                                 .

* <BAPI_FIELD>|ESTIMATED_COSTS
* <SAP_FIELD>|USER4
* <CODE_PART>|A_MOVE
* <ADD_FIELD>|
  MOVE alm_me_order_header-estimated_costs
    TO caufvd-user4                                                 .

* <BAPI_FIELD>|ENVIR_INVEST
* <SAP_FIELD>|UMWKZ
* <CODE_PART>|A_MOVE
* <ADD_FIELD>|
  MOVE alm_me_order_header-envir_invest
    TO caufvd-umwkz                                                 .

* <BAPI_FIELD>|REFDATE
* <SAP_FIELD>|ADDAT
* <CODE_PART>|A_MOVE
* <ADD_FIELD>|
  MOVE alm_me_order_header-refdate
    TO caufvd-addat                                                 .

* <BAPI_FIELD>|PRODUCTION_FINISH_DATE
* <SAP_FIELD>|GLTRS
* <CODE_PART>|A_MOVE
* <ADD_FIELD>|
  MOVE alm_me_order_header-production_finish_date
    TO caufvd-gltrs                                                 .

* <BAPI_FIELD>|PRODUCTION_START_DATE
* <SAP_FIELD>|GSTRS
* <CODE_PART>|A_MOVE
* <ADD_FIELD>|
  MOVE alm_me_order_header-production_start_date
    TO caufvd-gstrs                                                 .

* <BAPI_FIELD>|MRP_RELEVANT
* <SAP_FIELD>|AUDISP
* <CODE_PART>|A_MOVE
* <ADD_FIELD>|
  MOVE alm_me_order_header-mrp_relevant
    TO caufvd-audisp                                                .

* <BAPI_FIELD>|SCHEDULING_EXACT_BREAK_TIMES
* <SAP_FIELD>|BREAKS
* <CODE_PART>|A_MOVE
* <ADD_FIELD>|
  MOVE alm_me_order_header-scheduling_exact_break_times
    TO caufvd-breaks                                                .

* <BAPI_FIELD>|CAP_REQMTS
* <SAP_FIELD>|AUKBED
* <CODE_PART>|A_MOVE
* <ADD_FIELD>|
  MOVE alm_me_order_header-cap_reqmts
    TO caufvd-aukbed                                                .

* <BAPI_FIELD>|PRODUCTION_START_TIME
* <SAP_FIELD>|GSUZS
* <CODE_PART>|A_MOVE
* <ADD_FIELD>|
  MOVE alm_me_order_header-production_start_time
    TO caufvd-gsuzs                                                 .

* <BAPI_FIELD>|ACTUAL_FINISH_TIME
* <SAP_FIELD>|GEUZI
* <CODE_PART>|A_MOVE
* <ADD_FIELD>|
  MOVE alm_me_order_header-actual_finish_time
    TO caufvd-geuzi                                                 .

* <BAPI_FIELD>|ACTUAL_START_TIME
* <SAP_FIELD>|GSUZI
* <CODE_PART>|A_MOVE
* <ADD_FIELD>|
  MOVE alm_me_order_header-actual_start_time
    TO caufvd-gsuzi                                                 .

* <BAPI_FIELD>|ACTUAL_FINISH_DATE
* <SAP_FIELD>|GETRI
* <CODE_PART>|A_MOVE
* <ADD_FIELD>|
  MOVE alm_me_order_header-actual_finish_date
    TO caufvd-getri                                                 .

* <BAPI_FIELD>|ACTUAL_START_DATE
* <SAP_FIELD>|GSTRI
* <CODE_PART>|A_MOVE
* <ADD_FIELD>|
  MOVE alm_me_order_header-actual_start_date
    TO caufvd-gstri                                                 .

* <BAPI_FIELD>|PRODUCTION_FINISH_TIME
* <SAP_FIELD>|GLUZS
* <CODE_PART>|A_MOVE
* <ADD_FIELD>|
  MOVE alm_me_order_header-production_finish_time
    TO caufvd-gluzs                                                 .

* <BAPI_FIELD>|USER_ST
* <SAP_FIELD>|ASTEX
* <CODE_PART>|A_MOVE
* <ADD_FIELD>|
  MOVE alm_me_order_header-user_st
    TO caufvd-astex                                                 .

* <BAPI_FIELD>|SYS_STATUS
* <SAP_FIELD>|STTXT
* <CODE_PART>|A_MOVE
* <ADD_FIELD>|
  MOVE alm_me_order_header-sys_status
    TO caufvd-sttxt                                                 .

* <BAPI_FIELD>|SCENARIO
* <SAP_FIELD>|SCREENTY
* <CODE_PART>|A_MOVE
* <ADD_FIELD>|
  MOVE alm_me_order_header-scenario
    TO caufvd-screenty                                              .

* <BAPI_FIELD>|CHANGE_DATE
* <SAP_FIELD>|AEDAT
* <CODE_PART>|A_MOVE
* <ADD_FIELD>|
  MOVE alm_me_order_header-change_date
    TO caufvd-aedat                                                 .

* <BAPI_FIELD>|CHANGED_BY
* <SAP_FIELD>|AENAM
* <CODE_PART>|A_MOVE
* <ADD_FIELD>|
  MOVE alm_me_order_header-changed_by
    TO caufvd-aenam                                                 .

* <BAPI_FIELD>|USERSTATUS
* <SAP_FIELD>|ASTTX
* <CODE_PART>|A_MOVE
* <ADD_FIELD>|
  MOVE alm_me_order_header-userstatus
    TO caufvd-asttx                                                 .

* <BAPI_FIELD>|NOTIF_NO
* <SAP_FIELD>|QMNUM
* <CODE_PART>|A_MOVE
* <ADD_FIELD>|
  MOVE alm_me_order_header-notif_no
    TO caufvd-qmnum                                                 .

* <BAPI_FIELD>|LONG_TEXT
* <SAP_FIELD>|TXTKZ
* <CODE_PART>|A_MOVE
* <ADD_FIELD>|
  MOVE alm_me_order_header-long_text
    TO caufvd-txtkz                                                 .

* <BAPI_FIELD>|SHORT_TEXT
* <SAP_FIELD>|KTEXT
* <CODE_PART>|A_MOVE
* <ADD_FIELD>|
  MOVE alm_me_order_header-short_text
    TO caufvd-ktext                                                 .

* <BAPI_FIELD>|OBJECT_NO
* <SAP_FIELD>|OBJNR
* <CODE_PART>|A_MOVE
* <ADD_FIELD>|
  MOVE alm_me_order_header-object_no
    TO caufvd-objnr                                                 .

* <BAPI_FIELD>|STAT_PROF
* <SAP_FIELD>|STATS
* <CODE_PART>|A_MOVE
* <ADD_FIELD>|
  MOVE alm_me_order_header-stat_prof
    TO caufvd-stats                                                 .

* <BAPI_FIELD>|ENTER_DATE
* <SAP_FIELD>|ERDAT
* <CODE_PART>|A_MOVE
* <ADD_FIELD>|
  MOVE alm_me_order_header-enter_date
    TO caufvd-erdat                                                 .

* <BAPI_FIELD>|GROUP_COUNTER
* <SAP_FIELD>|PLNAL
* <CODE_PART>|A_MOVE
* <ADD_FIELD>|
  MOVE alm_me_order_header-group_counter
    TO caufvd-plnal                                                 .

* <BAPI_FIELD>|TASK_LIST_GROUP
* <SAP_FIELD>|PLNNR
* <CODE_PART>|A_MOVE
* <ADD_FIELD>|
  MOVE alm_me_order_header-task_list_group
    TO caufvd-plnnr                                                 .

* <BAPI_FIELD>|CSTGVARACT
* <SAP_FIELD>|KLVARI
* <CODE_PART>|A_MOVE
* <ADD_FIELD>|
  MOVE alm_me_order_header-cstgvaract
    TO caufvd-klvari                                                .

* <BAPI_FIELD>|CSTGVAPPLN
* <SAP_FIELD>|KLVARP
* <CODE_PART>|A_MOVE
* <ADD_FIELD>|
  MOVE alm_me_order_header-cstgvappln
    TO caufvd-klvarp                                                .

* <BAPI_FIELD>|NETWORK_PROFILE
* <SAP_FIELD>|PROFID
* <CODE_PART>|A_MOVE
* <ADD_FIELD>|
  MOVE alm_me_order_header-network_profile
    TO caufvd-profid                                                .

* <BAPI_FIELD>|TASK_LIST_TYPE
* <SAP_FIELD>|PLNTY
* <CODE_PART>|A_MOVE
* <ADD_FIELD>|
  MOVE alm_me_order_header-task_list_type
    TO caufvd-plnty                                                 .

* <BAPI_FIELD>|ENTERED_BY
* <SAP_FIELD>|ERNAM
* <CODE_PART>|A_MOVE
* <ADD_FIELD>|
  MOVE alm_me_order_header-entered_by
    TO caufvd-ernam                                                 .

* <BAPI_FIELD>|LAST_ORD
* <SAP_FIELD>|LAUFN
* <CODE_PART>|A_MOVE
* <ADD_FIELD>|
  MOVE alm_me_order_header-last_ord
    TO caufvd-laufn                                                 .

* <BAPI_FIELD>|CALL_NO
* <SAP_FIELD>|ABNUM
* <CODE_PART>|A_MOVE
* <ADD_FIELD>|
  MOVE alm_me_order_header-call_no
    TO caufvd-abnum                                                 .

* <BAPI_FIELD>|MAINTITEM
* <SAP_FIELD>|WAPOS
* <CODE_PART>|A_MOVE
* <ADD_FIELD>|
  MOVE alm_me_order_header-maintitem
    TO caufvd-wapos                                                 .

* <BAPI_FIELD>|MNTPLAN
* <SAP_FIELD>|WARPL
* <CODE_PART>|A_MOVE
* <ADD_FIELD>|
  MOVE alm_me_order_header-mntplan
    TO caufvd-warpl                                                 .

* <BAPI_FIELD>|PLSECTN
* <SAP_FIELD>|BEBER
* <CODE_PART>|A_MOVE
* <ADD_FIELD>|
  MOVE alm_me_order_header-plsectn
    TO caufvd-beber                                                 .

* <BAPI_FIELD>|MAINTROOM
* <SAP_FIELD>|MSGRP
* <CODE_PART>|A_MOVE
* <ADD_FIELD>|
  MOVE alm_me_order_header-maintroom
    TO caufvd-msgrp                                                 .

* <BAPI_FIELD>|LOCATION
* <SAP_FIELD>|STORT
* <CODE_PART>|A_MOVE
* <ADD_FIELD>|
  MOVE alm_me_order_header-location
    TO caufvd-stort                                                 .

* <BAPI_FIELD>|MAINTPLANT
* <SAP_FIELD>|SWERK
* <CODE_PART>|A_MOVE
* <ADD_FIELD>|
  MOVE alm_me_order_header-maintplant
    TO caufvd-swerk                                                 .

* <BAPI_FIELD>|DEVICEDATA
* <SAP_FIELD>|DEVICEID
* <CODE_PART>|A_MOVE
* <ADD_FIELD>|
  MOVE alm_me_order_header-devicedata
    TO caufvd-deviceid                                              .

* <BAPI_FIELD>|LOC_WKCTR_ID
* <SAP_FIELD>|PPSID
* <CODE_PART>|A_MOVE
* <ADD_FIELD>|
  MOVE alm_me_order_header-loc_wkctr_id
    TO caufvd-ppsid                                                 .

* <BAPI_FIELD>|FUNC_AREA
* <SAP_FIELD>|FUNC_AREA
* <CODE_PART>|A_MOVE
* <ADD_FIELD>|
  MOVE alm_me_order_header-func_area
    TO caufvd-func_area                                             .

* <BAPI_FIELD>|RESPCCTR
* <SAP_FIELD>|KOSTV
* <CODE_PART>|A_MOVE
* <ADD_FIELD>|
  MOVE alm_me_order_header-respcctr
    TO caufvd-kostv                                                 .

* <BAPI_FIELD>|PROFIT_CTR
* <SAP_FIELD>|PRCTR
* <CODE_PART>|A_MOVE
* <ADD_FIELD>|
  MOVE alm_me_order_header-profit_ctr
    TO caufvd-prctr                                                 .

* <BAPI_FIELD>|SORTFIELD
* <SAP_FIELD>|EQFNR
* <CODE_PART>|A_MOVE
* <ADD_FIELD>|
  MOVE alm_me_order_header-sortfield
    TO caufvd-eqfnr                                                 .

* <BAPI_FIELD>|ABCINDIC
* <SAP_FIELD>|ABCKZ
* <CODE_PART>|A_MOVE
* <ADD_FIELD>|
  MOVE alm_me_order_header-abcindic
    TO caufvd-abckz                                                 .

* <BAPI_FIELD>|ASSEMBLY
* <SAP_FIELD>|BAUTL
* <CODE_PART>|A_MOVE
* <ADD_FIELD>|
  MOVE alm_me_order_header-assembly
    TO caufvd-bautl                                                 .

* <BAPI_FIELD>|MN_WKCTR_ID
* <SAP_FIELD>|GEWRK
* <CODE_PART>|A_MOVE
* <ADD_FIELD>|
  MOVE alm_me_order_header-mn_wkctr_id
    TO caufvd-gewrk                                                 .

* <BAPI_FIELD>|PLANT
* <SAP_FIELD>|VAWRK
* <CODE_PART>|A_MOVE
* <ADD_FIELD>|
  MOVE alm_me_order_header-plant
    TO caufvd-vawrk                                                 .

* <BAPI_FIELD>|MN_WK_CTR
* <SAP_FIELD>|VAPLZ
* <CODE_PART>|A_MOVE
* <ADD_FIELD>|
  MOVE alm_me_order_header-mn_wk_ctr
    TO caufvd-vaplz                                                 .

* <BAPI_FIELD>|PLANPLANT
* <SAP_FIELD>|IWERK
* <CODE_PART>|A_MOVE
* <ADD_FIELD>|
  MOVE alm_me_order_header-planplant
    TO caufvd-iwerk                                                 .

* <BAPI_FIELD>|ORDER_TYPE
* <SAP_FIELD>|AUART
* <CODE_PART>|A_MOVE
* <ADD_FIELD>|
  MOVE alm_me_order_header-order_type
    TO caufvd-auart                                                 .

* <BAPI_FIELD>|PMACTTYPE
* <SAP_FIELD>|ILART
* <CODE_PART>|A_MOVE
* <ADD_FIELD>|
  MOVE alm_me_order_header-pmacttype
    TO caufvd-ilart                                                 .

* <BAPI_FIELD>|SERIALNO
* <SAP_FIELD>|SERIALNR
* <CODE_PART>|A_MOVE
* <ADD_FIELD>|
  MOVE alm_me_order_header-serialno
    TO caufvd-serialnr                                              .

* <BAPI_FIELD>|EQUIPMENT
* <SAP_FIELD>|EQUNR
* <CODE_PART>|A_MOVE
* <ADD_FIELD>|
  MOVE alm_me_order_header-equipment
    TO caufvd-equnr                                                 .

* <BAPI_FIELD>|FUNCT_LOC
* <SAP_FIELD>|TPLNR
* <CODE_PART>|A_MOVE
* <ADD_FIELD>|
  MOVE alm_me_order_header-funct_loc
    TO caufvd-tplnr                                                 .

* <BAPI_FIELD>|SYSTCOND
* <SAP_FIELD>|ANLZU
* <CODE_PART>|A_MOVE
* <ADD_FIELD>|
  MOVE alm_me_order_header-systcond
    TO caufvd-anlzu                                                 .

* <BAPI_FIELD>|PLANGROUP
* <SAP_FIELD>|INGPR
* <CODE_PART>|A_MOVE
* <ADD_FIELD>|
  MOVE alm_me_order_header-plangroup
    TO caufvd-ingpr                                                 .

* <BAPI_FIELD>|SUPERIOR_NETWORK
* <SAP_FIELD>|AUFNT
* <CODE_PART>|A_MOVE
* <ADD_FIELD>|
  MOVE alm_me_order_header-superior_network
    TO caufvd-aufnt                                                 .

* <BAPI_FIELD>|BASICSTART
* <SAP_FIELD>|GSUZP
* <CODE_PART>|A_MOVE
* <ADD_FIELD>|
  MOVE alm_me_order_header-basicstart
    TO caufvd-gsuzp                                                 .

* <BAPI_FIELD>|FINISH_DATE
* <SAP_FIELD>|GLTRP
* <CODE_PART>|A_MOVE
* <ADD_FIELD>|
  MOVE alm_me_order_header-finish_date
    TO caufvd-gltrp                                                 .

* <BAPI_FIELD>|START_DATE
* <SAP_FIELD>|GSTRP
* <CODE_PART>|A_MOVE
* <ADD_FIELD>|
  MOVE alm_me_order_header-start_date
    TO caufvd-gstrp                                                 .

* <BAPI_FIELD>|ORDPLANID
* <SAP_FIELD>|PLKNZ
* <CODE_PART>|A_MOVE
* <ADD_FIELD>|
  MOVE alm_me_order_header-ordplanid
    TO caufvd-plknz                                                 .

* <BAPI_FIELD>|DIVISION
* <SAP_FIELD>|SPART
* <CODE_PART>|A_MOVE
* <ADD_FIELD>|
  MOVE alm_me_order_header-division
    TO caufvd-spart                                                 .

* <BAPI_FIELD>|BASIC_FIN
* <SAP_FIELD>|GLUZP
* <CODE_PART>|A_MOVE
* <ADD_FIELD>|
  MOVE alm_me_order_header-basic_fin
    TO caufvd-gluzp                                                 .

* <BAPI_FIELD>|AUTOSCHED
* <SAP_FIELD>|AUTERM
* <CODE_PART>|A_MOVE
* <ADD_FIELD>|
  MOVE alm_me_order_header-autosched
    TO caufvd-auterm                                                .

* <BAPI_FIELD>|SCHED_TYPE
* <SAP_FIELD>|TERKZ
* <CODE_PART>|A_MOVE
* <ADD_FIELD>|
  MOVE alm_me_order_header-sched_type
    TO caufvd-terkz                                                 .

* <BAPI_FIELD>|VERSION
* <SAP_FIELD>|KAPVERSA
* <CODE_PART>|A_MOVE
* <ADD_FIELD>|
  MOVE alm_me_order_header-version
    TO caufvd-kapversa                                              .

* <BAPI_FIELD>|REVISION
* <SAP_FIELD>|REVNR
* <CODE_PART>|A_MOVE
* <ADD_FIELD>|
  MOVE alm_me_order_header-revision
    TO caufvd-revnr                                                 .

* <BAPI_FIELD>|PRIORITY
* <SAP_FIELD>|PRIOK
* <CODE_PART>|A_MOVE
* <ADD_FIELD>|
  MOVE alm_me_order_header-priority
    TO caufvd-priok                                                 .

* <BAPI_FIELD>|DISTR_CHAN
* <SAP_FIELD>|VTWEG
* <CODE_PART>|A_MOVE
* <ADD_FIELD>|
  MOVE alm_me_order_header-distr_chan
    TO caufvd-vtweg                                                 .

* <BAPI_FIELD>|TAXJURCODE
* <SAP_FIELD>|TXJCD
* <CODE_PART>|A_MOVE
* <ADD_FIELD>|
  MOVE alm_me_order_header-taxjurcode
    TO caufvd-txjcd                                                 .

* <BAPI_FIELD>|OBJECTCLASS
* <SAP_FIELD>|SCOPE
* <CODE_PART>|A_MOVE
* <ADD_FIELD>|
  MOVE alm_me_order_header-objectclass
    TO caufvd-scope                                                 .

* <BAPI_FIELD>|PROCESSING_GROUP
* <SAP_FIELD>|ABKRS
* <CODE_PART>|A_MOVE
* <ADD_FIELD>|
  MOVE alm_me_order_header-processing_group
    TO caufvd-abkrs                                                 .

* <BAPI_FIELD>|PROJ_DEF
* <SAP_FIELD>|PRONR
* <CODE_PART>|A_MOVE
* <ADD_FIELD>|
  MOVE alm_me_order_header-proj_def
    TO caufvd-pronr                                                 .

* <BAPI_FIELD>|SUPERIOR_COUNTER
* <SAP_FIELD>|APLZT
* <CODE_PART>|A_MOVE
* <ADD_FIELD>|
  MOVE alm_me_order_header-superior_counter
    TO caufvd-aplzt                                                 .

* <BAPI_FIELD>|SALESORG
* <SAP_FIELD>|VKORG
* <CODE_PART>|A_MOVE
* <ADD_FIELD>|
  MOVE alm_me_order_header-salesorg
    TO caufvd-vkorg                                                 .

* <BAPI_FIELD>|STANDORDER
* <SAP_FIELD>|DAUFN
* <CODE_PART>|A_MOVE
* <ADD_FIELD>|
  MOVE alm_me_order_header-standorder
    TO caufvd-daufn                                                 .

* <BAPI_FIELD>|COSTCENTER
* <SAP_FIELD>|KOSTL
* <CODE_PART>|A_MOVE
* <ADD_FIELD>|
  MOVE alm_me_order_header-costcenter
    TO caufvd-kostl                                                 .

* <BAPI_FIELD>|ASSET_NO
* <SAP_FIELD>|ANLNR
* <CODE_PART>|A_MOVE
* <ADD_FIELD>|
  MOVE alm_me_order_header-asset_no
    TO caufvd-anlnr                                                 .

* <BAPI_FIELD>|SUB_NUMBER
* <SAP_FIELD>|ANLUN
* <CODE_PART>|A_MOVE
* <ADD_FIELD>|
  MOVE alm_me_order_header-sub_number
    TO caufvd-anlun                                                 .

* <BAPI_FIELD>|CURRENCY_ISO
* <SAP_FIELD>|WAERS
* <CODE_PART>|ISO_INT_CURR
* <ADD_FIELD>|CURRENCY
  IF NOT alm_me_order_header-currency
  IS INITIAL.
    MOVE alm_me_order_header-currency
      TO caufvd-waers                                                 .
  ELSEIF alm_me_order_header-currency_iso
  IS INITIAL.
    CLEAR caufvd-waers                                                 .
  ELSE.
    CALL FUNCTION 'CURRENCY_CODE_ISO_TO_SAP'
      EXPORTING
        iso_code  =
                    alm_me_order_header-currency_iso
      IMPORTING
        sap_code  =
                    caufvd-waers
      EXCEPTIONS
        not_found = 1
        OTHERS    = 2.
    IF sy-subrc <> 0.
      MESSAGE a547(b1) WITH
      alm_me_order_header-currency_iso
      'CURRENCY_ISO                  '
      RAISING error_converting_iso_code.
    ENDIF.
  ENDIF.

* map business area                                         "K1
  MOVE alm_me_order_header-bus_area                           "K1
    TO caufvd-gsber.                                          "K1

*------------------------------------------------------*
* Campos adicionais (Cabeçalho)                        *
*------------------------------------------------------*

  MOVE p_i_wa_campos_ad_cabecalho-artpr
    TO caufvd-artpr.

  MOVE p_i_wa_campos_ad_cabecalho-kokrs
    TO caufvd-kokrs.

  MOVE p_i_wa_campos_ad_cabecalho-obknr
    TO caufvd-obknr.

  MOVE p_i_wa_campos_ad_cabecalho-plgrp
    TO caufvd-plgrp.

  MOVE p_i_wa_campos_ad_cabecalho-plnnr
    TO caufvd-plnnr.

  MOVE p_i_wa_campos_ad_cabecalho-wapos
    TO caufvd-wapos.

  MOVE p_i_wa_campos_ad_cabecalho-warpl
    TO caufvd-warpl.

ENDFUNCTION.
