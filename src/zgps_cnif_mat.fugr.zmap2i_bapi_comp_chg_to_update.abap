function ZMAP2I_BAPI_COMP_CHG_TO_UPDATE.
*"--------------------------------------------------------------------
*"*"Interface local:
*"  IMPORTING
*"     REFERENCE(BAPI_NETWORK_COMP_CNG_UPD)
*"  LIKE  BAPI_NETWORK_COMP_CNG_UPD
*"  STRUCTURE  BAPI_NETWORK_COMP_CNG_UPD
*"  CHANGING
*"     REFERENCE(RESBD_CHANGE) LIKE  RESBD_CHANGE
*"  STRUCTURE  RESBD_CHANGE
*"--------------------------------------------------------------------

* This function module was generated. Don't change it manually!
* <VERSION>|4
* <BAPI_STRUCTURE>|BAPI_NETWORK_COMP_CNG_UPD
* <SAP_STRUCTURE>|RESBD_CHANGE
* <INTERN_TO_EXTERN>|
* <APPEND FORM>|

* <BAPI_FIELD>|VSI_SIZE1
* <SAP_FIELD>|ROMS1
* <CODE_PART>|A_MOVE
* <ADD_FIELD>|
  move bapi_network_comp_cng_upd-vsi_size1
    to resbd_change-roms1                                           .

* <BAPI_FIELD>|BULK_MAT
* <SAP_FIELD>|SCHGT
* <CODE_PART>|A_MOVE
* <ADD_FIELD>|
  move bapi_network_comp_cng_upd-bulk_mat
    to resbd_change-schgt                                           .

* <BAPI_FIELD>|WITHDRAWN
* <SAP_FIELD>|KZEAR
* <CODE_PART>|A_MOVE
* <ADD_FIELD>|
  move bapi_network_comp_cng_upd-withdrawn
    to resbd_change-kzear                                           .

* <BAPI_FIELD>|BACKFLUSH
* <SAP_FIELD>|RGEKZ
* <CODE_PART>|A_MOVE
* <ADD_FIELD>|
  move bapi_network_comp_cng_upd-backflush
    to resbd_change-rgekz                                           .

* <BAPI_FIELD>|SORT_STRING
* <SAP_FIELD>|SORTP
* <CODE_PART>|A_MOVE
* <ADD_FIELD>|
  move bapi_network_comp_cng_upd-sort_string
    to resbd_change-sortp                                           .

* <BAPI_FIELD>|UNLOAD_PT
* <SAP_FIELD>|ABLAD
* <CODE_PART>|A_MOVE
* <ADD_FIELD>|
  move bapi_network_comp_cng_upd-unload_pt
    to resbd_change-ablad                                           .

* <BAPI_FIELD>|TRACKINGNO
* <SAP_FIELD>|BEDNR
* <CODE_PART>|A_MOVE
* <ADD_FIELD>|
  move bapi_network_comp_cng_upd-trackingno
    to resbd_change-bednr                                           .

* <BAPI_FIELD>|GR_RCPT
* <SAP_FIELD>|WEMPF
* <CODE_PART>|A_MOVE
* <ADD_FIELD>|
  move bapi_network_comp_cng_upd-gr_rcpt
    to resbd_change-wempf                                           .

* <BAPI_FIELD>|PREQ_NAME
* <SAP_FIELD>|AFNAM
* <CODE_PART>|A_MOVE
* <ADD_FIELD>|
  move bapi_network_comp_cng_upd-preq_name
    to resbd_change-afnam                                           .

* <BAPI_FIELD>|MATL_GROUP
* <SAP_FIELD>|MATKL
* <CODE_PART>|A_MOVE
* <ADD_FIELD>|
  move bapi_network_comp_cng_upd-matl_group
    to resbd_change-matkl                                           .

* <BAPI_FIELD>|GR_PR_TIME
* <SAP_FIELD>|WEBAZ
* <CODE_PART>|A_MOVE
* <ADD_FIELD>|
  move bapi_network_comp_cng_upd-gr_pr_time
    to resbd_change-webaz                                           .

* <BAPI_FIELD>|VENDOR_NO
* <SAP_FIELD>|LIFNR
* <CODE_PART>|A_MOVE
* <ADD_FIELD>|
  move bapi_network_comp_cng_upd-vendor_no
    to resbd_change-lifnr                                           .

* <BAPI_FIELD>|GL_ACCOUNT
* <SAP_FIELD>|SAKNR
* <CODE_PART>|A_MOVE
* <ADD_FIELD>|
  move bapi_network_comp_cng_upd-gl_account
    to resbd_change-saknr                                           .

* <BAPI_FIELD>|VSI_SIZE2
* <SAP_FIELD>|ROMS2
* <CODE_PART>|A_MOVE
* <ADD_FIELD>|
  move bapi_network_comp_cng_upd-vsi_size2
    to resbd_change-roms2                                           .

* <BAPI_FIELD>|S_ORD_ITEM
* <SAP_FIELD>|KDPOS
* <CODE_PART>|A_MOVE
* <ADD_FIELD>|
  move bapi_network_comp_cng_upd-s_ord_item
    to resbd_change-kdpos                                           .

* <BAPI_FIELD>|WBS_ELEMENT
* <SAP_FIELD>|PSPEL
* <CODE_PART>|A_MOVE
* <ADD_FIELD>|
  move bapi_network_comp_cng_upd-wbs_element
    to resbd_change-pspel                                           .

* <BAPI_FIELD>|CUSTOMER
* <SAP_FIELD>|KUNNR
* <CODE_PART>|A_MOVE
* <ADD_FIELD>|
  move bapi_network_comp_cng_upd-customer
    to resbd_change-kunnr                                           .

* <BAPI_FIELD>|SUPP_VENDOR
* <SAP_FIELD>|EMLIF
* <CODE_PART>|A_MOVE
* <ADD_FIELD>|
  move bapi_network_comp_cng_upd-supp_vendor
    to resbd_change-emlif                                           .

* <BAPI_FIELD>|ADDR_NO2
* <SAP_FIELD>|ADRN2
* <CODE_PART>|A_MOVE
* <ADD_FIELD>|
  move bapi_network_comp_cng_upd-addr_no2
    to resbd_change-adrn2                                           .

* <BAPI_FIELD>|ADDR_NO
* <SAP_FIELD>|ADRNR
* <CODE_PART>|A_MOVE
* <ADD_FIELD>|
  move bapi_network_comp_cng_upd-addr_no
    to resbd_change-adrnr                                           .

* <BAPI_FIELD>|ORIGINAL_QUANTITY
* <SAP_FIELD>|NOMNG
* <CODE_PART>|A_MOVE
* <ADD_FIELD>|
  move bapi_network_comp_cng_upd-original_quantity
    to resbd_change-nomng                                           .

* <BAPI_FIELD>|VSI_NO
* <SAP_FIELD>|ROANZ
* <CODE_PART>|A_MOVE
* <ADD_FIELD>|
  move bapi_network_comp_cng_upd-vsi_no
    to resbd_change-roanz                                          .

* <BAPI_FIELD>|VSI_FORMULA
* <SAP_FIELD>|RFORM
* <CODE_PART>|A_MOVE
* <ADD_FIELD>|
  move bapi_network_comp_cng_upd-vsi_formula
    to resbd_change-rform                                           .

* <BAPI_FIELD>|VAR_SIZE_COMP_MEASURE_UNIT
* <SAP_FIELD>|ROKME
* <CODE_PART>|A_MOVE
* <ADD_FIELD>|
  move bapi_network_comp_cng_upd-var_size_comp_measure_unit
    to resbd_change-rokme                                           .

* <BAPI_FIELD>|VSI_QTY
* <SAP_FIELD>|ROMEN
* <CODE_PART>|A_MOVE
* <ADD_FIELD>|
  move bapi_network_comp_cng_upd-vsi_qty
    to resbd_change-romen                                           .

* <BAPI_FIELD>|VSI_SIZE_UNIT
* <SAP_FIELD>|ROMEI
* <CODE_PART>|A_MOVE
* <ADD_FIELD>|
  move bapi_network_comp_cng_upd-vsi_size_unit
    to resbd_change-romei                                           .

* <BAPI_FIELD>|VSI_SIZE3
* <SAP_FIELD>|ROMS3
* <CODE_PART>|A_MOVE
* <ADD_FIELD>|
  move bapi_network_comp_cng_upd-vsi_size3
    to resbd_change-roms3                                           .

* <BAPI_FIELD>|MRP_DISTRIBUTION_KEY
* <SAP_FIELD>|VERTI
* <CODE_PART>|A_MOVE
* <ADD_FIELD>|
  move bapi_network_comp_cng_upd-mrp_distribution_key
    to resbd_change-verti                                           .

* <BAPI_FIELD>|LEAD_TIME_OFFSET_OPR_UNIT
* <SAP_FIELD>|NLFMV
* <CODE_PART>|A_MOVE
* <ADD_FIELD>|
  move bapi_network_comp_cng_upd-lead_time_offset_opr_unit
    to resbd_change-nlfmv                                           .

* <BAPI_FIELD>|LEAD_TIME_OFFSET_OPR
* <SAP_FIELD>|NLFZV
* <CODE_PART>|A_MOVE
* <ADD_FIELD>|
  move bapi_network_comp_cng_upd-lead_time_offset_opr
    to resbd_change-nlfzv                                           .

* <BAPI_FIELD>|MANUAL_REQUIREMENTS_DATE
* <SAP_FIELD>|KZMPF
* <CODE_PART>|A_MOVE
* <ADD_FIELD>|
  move bapi_network_comp_cng_upd-manual_requirements_date
    to resbd_change-kzmpf                                           .

* <BAPI_FIELD>|REQ_DATE
* <SAP_FIELD>|BDTER
* <CODE_PART>|A_MOVE
* <ADD_FIELD>|
  move bapi_network_comp_cng_upd-req_date
    to resbd_change-bdter                                           .

* <BAPI_FIELD>|MRP_RELEVANT
* <SAP_FIELD>|AUDISP
* <CODE_PART>|A_MOVE
* <ADD_FIELD>|
  move bapi_network_comp_cng_upd-mrp_relevant
    to resbd_change-audisp                                          .

* <BAPI_FIELD>|ITEM_TEXT
* <SAP_FIELD>|POTX1
* <CODE_PART>|A_MOVE
* <ADD_FIELD>|
  move bapi_network_comp_cng_upd-item_text
    to resbd_change-potx1                                           .

* <BAPI_FIELD>|BASE_UOM
* <SAP_FIELD>|MEINS
* <CODE_PART>|A_MOVE
* <ADD_FIELD>|
  move bapi_network_comp_cng_upd-base_uom
    to resbd_change-meins                                           .

* <BAPI_FIELD>|CHANGE_NOMNG
* <SAP_FIELD>|CHANGE_NOMNG
* <CODE_PART>|A_MOVE
* <ADD_FIELD>|
  move bapi_network_comp_cng_upd-change_nomng
    to resbd_change-change_nomng                                    .

* <BAPI_FIELD>|ENTRY_QUANTITY
* <SAP_FIELD>|BDMNG
* <CODE_PART>|A_MOVE
* <ADD_FIELD>|
  move bapi_network_comp_cng_upd-entry_quantity
    to resbd_change-bdmng                                           .

* <BAPI_FIELD>|ITEM_NUMBER
* <SAP_FIELD>|POSNR
* <CODE_PART>|A_MOVE
* <ADD_FIELD>|
  move bapi_network_comp_cng_upd-item_number
    to resbd_change-posnr                                           .

* <BAPI_FIELD>|ACTIVITY
* <SAP_FIELD>|VORNR
* <CODE_PART>|A_MOVE
* <ADD_FIELD>|
  move bapi_network_comp_cng_upd-activity
    to resbd_change-vornr                                           .

* <BAPI_FIELD>|COMPONENT
* <SAP_FIELD>|COMPONENT
* <CODE_PART>|A_MOVE
* <ADD_FIELD>|
  move bapi_network_comp_cng_upd-component
    to resbd_change-component                                       .

* <BAPI_FIELD>|COST_RELEVANT
* <SAP_FIELD>|SANKA
* <CODE_PART>|A_MOVE
* <ADD_FIELD>|
  move bapi_network_comp_cng_upd-cost_relevant
    to resbd_change-sanka                                           .

* <BAPI_FIELD>|AGMT_ITEM
* <SAP_FIELD>|KTPNR
* <CODE_PART>|A_MOVE
* <ADD_FIELD>|
  move bapi_network_comp_cng_upd-agmt_item
    to resbd_change-ktpnr                                           .

* <BAPI_FIELD>|AGREEMENT
* <SAP_FIELD>|KONNR
* <CODE_PART>|A_MOVE
* <ADD_FIELD>|
  move bapi_network_comp_cng_upd-agreement
    to resbd_change-konnr                                           .

* <BAPI_FIELD>|PUR_INFO_RECORD_DATA_FIXED
* <SAP_FIELD>|KZFIX
* <CODE_PART>|A_MOVE
* <ADD_FIELD>|
  move bapi_network_comp_cng_upd-pur_info_record_data_fixed
    to resbd_change-kzfix                                           .

* <BAPI_FIELD>|CURRENCY
* <SAP_FIELD>|WAERS
* <CODE_PART>|A_MOVE
* <ADD_FIELD>|
  move bapi_network_comp_cng_upd-currency
    to resbd_change-waers                                           .

* <BAPI_FIELD>|PRICE_UNIT
* <SAP_FIELD>|PEINH
* <CODE_PART>|A_MOVE
* <ADD_FIELD>|
  move bapi_network_comp_cng_upd-price_unit
    to resbd_change-peinh                                           .

* <BAPI_FIELD>|PRICE
* <SAP_FIELD>|GPREIS
* <CODE_PART>|A_MOVE
* <ADD_FIELD>|
  move bapi_network_comp_cng_upd-price
    to resbd_change-gpreis                                          .

* <BAPI_FIELD>|INFO_REC
* <SAP_FIELD>|INFNR
* <CODE_PART>|A_MOVE
* <ADD_FIELD>|
  move bapi_network_comp_cng_upd-info_rec
    to resbd_change-infnr                                           .

* <BAPI_FIELD>|PURCH_ORG
* <SAP_FIELD>|EKORG
* <CODE_PART>|A_MOVE
* <ADD_FIELD>|
  move bapi_network_comp_cng_upd-purch_org
    to resbd_change-ekorg                                           .

* <BAPI_FIELD>|PUR_GROUP
* <SAP_FIELD>|EKGRP
* <CODE_PART>|A_MOVE
* <ADD_FIELD>|
  move bapi_network_comp_cng_upd-pur_group
    to resbd_change-ekgrp                                           .

* <BAPI_FIELD>|DELIVERY_DAYS
* <SAP_FIELD>|LIFZT
* <CODE_PART>|A_MOVE
* <ADD_FIELD>|
  move bapi_network_comp_cng_upd-delivery_days
    to resbd_change-lifzt                                           .

* <BAPI_FIELD>|BOMEXPL_NO
* <SAP_FIELD>|SERNR
* <CODE_PART>|A_MOVE
* <ADD_FIELD>|
  move bapi_network_comp_cng_upd-bomexpl_no
    to resbd_change-sernr                                           .

* <BAPI_FIELD>|BATCH
* <SAP_FIELD>|CHARG
* <CODE_PART>|A_MOVE
* <ADD_FIELD>|
  move bapi_network_comp_cng_upd-batch
    to resbd_change-charg                                           .

* <BAPI_FIELD>|STGE_LOC
* <SAP_FIELD>|LGORT
* <CODE_PART>|A_MOVE
* <ADD_FIELD>|
  move bapi_network_comp_cng_upd-stge_loc
    to resbd_change-lgort                                           .

* ISO-Felder sind eingegeben
  if not bapi_network_comp_cng_upd-base_uom_iso is initial.
    move  bapi_network_comp_cng_upd-base_uom_iso to
    resbd_change-meins.
  endif.
  if not bapi_network_comp_cng_upd-lead_time_offset_opr_unit_iso is
  initial.
    move  bapi_network_comp_cng_upd-lead_time_offset_opr_unit_iso to
    resbd_change-nlfmv.
  endif.
  if not bapi_network_comp_cng_upd-currency_iso is initial.
    move  bapi_network_comp_cng_upd-currency_iso to
    resbd_change-waers.
  endif.
  if not bapi_network_comp_cng_upd-vsi_size_unit_iso is initial.
    move  bapi_network_comp_cng_upd-vsi_size_unit_iso to
    resbd_change-romei.
  endif.
  if not bapi_network_comp_cng_upd-var_size_comp_measure_unit_iso is
  initial.
    move  bapi_network_comp_cng_upd-var_size_comp_measure_unit_iso to
    resbd_change-rokme.
  endif.

  perform map2i_bapi_comp_chg_to_update
    using
      bapi_network_comp_cng_upd
    changing
      resbd_change.

endfunction.


*&--------------------------------------------------------------------*
*&      Form  MAP2I_BAPI_COMP_CHG_TO_UPDATE
*&--------------------------------------------------------------------*
*       text
*---------------------------------------------------------------------*
*      -->BAPI_NETWORtextMP_CNG_UPD
*      -->RESBD_CHANGtext
*---------------------------------------------------------------------*
form map2i_bapi_comp_chg_to_update
  using
    bapi_network_comp_cng_upd
    structure bapi_network_comp_cng_upd
  changing
    resbd_change
    structure resbd_change                  .
* Kz: TerminAusrichtung geändert, dann sollte FUNCT auch als geändert
* kennzeichen
  if not resbd_change-kzmpf is initial.
    resbd_change-funct = yx.
  endif.
endform.                    "MAP2I_BAPI_COMP_CHG_TO_UPDATE
