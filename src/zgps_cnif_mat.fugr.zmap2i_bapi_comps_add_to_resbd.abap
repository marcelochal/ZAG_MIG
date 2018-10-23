FUNCTION ZMAP2I_BAPI_COMPS_ADD_TO_RESBD.
*"----------------------------------------------------------------------
*"*"Interface local:
*"  IMPORTING
*"     REFERENCE(BAPI_NETWORK_COMP_ADD) TYPE
*"        ZEPS_BAPI_NETWORK_COMP_ADD
*"  CHANGING
*"     REFERENCE(RESBD) LIKE  RESBD STRUCTURE  RESBD
*"  EXCEPTIONS
*"      ERROR_CONVERTING_ISO_CODE
*"----------------------------------------------------------------------

* This function module was generated. Don't change it manually!
* <VERSION>|4
* <BAPI_STRUCTURE>|BAPI_NETWORK_COMP_ADD
* <SAP_STRUCTURE>|RESBD
* <INTERN_TO_EXTERN>|
* <APPEND FORM>|X

* <BAPI_FIELD>|BULK_MAT
* <SAP_FIELD>|SCHGT
* <CODE_PART>|A_MOVE
* <ADD_FIELD>|
  MOVE BAPI_NETWORK_COMP_ADD-BULK_MAT
    TO RESBD-SCHGT                                                  .

* <BAPI_FIELD>|BACKFLUSH
* <SAP_FIELD>|RGEKZ
* <CODE_PART>|A_MOVE
* <ADD_FIELD>|
  MOVE BAPI_NETWORK_COMP_ADD-BACKFLUSH
    TO RESBD-RGEKZ                                                  .

* <BAPI_FIELD>|SORT_STRING
* <SAP_FIELD>|SORTF
* <CODE_PART>|A_MOVE
* <ADD_FIELD>|
  MOVE BAPI_NETWORK_COMP_ADD-SORT_STRING
    TO RESBD-SORTF                                                  .

* <BAPI_FIELD>|UNLOAD_PT
* <SAP_FIELD>|ABLAD
* <CODE_PART>|A_MOVE
* <ADD_FIELD>|
  MOVE BAPI_NETWORK_COMP_ADD-UNLOAD_PT
    TO RESBD-ABLAD                                                  .

* <BAPI_FIELD>|TRACKINGNO
* <SAP_FIELD>|BEDNR
* <CODE_PART>|A_MOVE
* <ADD_FIELD>|
  MOVE BAPI_NETWORK_COMP_ADD-TRACKINGNO
    TO RESBD-BEDNR                                                  .

* <BAPI_FIELD>|GR_RCPT
* <SAP_FIELD>|WEMPF
* <CODE_PART>|A_MOVE
* <ADD_FIELD>|
  MOVE BAPI_NETWORK_COMP_ADD-GR_RCPT
    TO RESBD-WEMPF                                                  .

* <BAPI_FIELD>|PREQ_NAME
* <SAP_FIELD>|AFNAM
* <CODE_PART>|A_MOVE
* <ADD_FIELD>|
  MOVE BAPI_NETWORK_COMP_ADD-PREQ_NAME
    TO RESBD-AFNAM                                                  .

* <BAPI_FIELD>|MATL_GROUP
* <SAP_FIELD>|MATKL
* <CODE_PART>|A_MOVE
* <ADD_FIELD>|
  MOVE BAPI_NETWORK_COMP_ADD-MATL_GROUP
    TO RESBD-MATKL                                                  .

* <BAPI_FIELD>|GR_PR_TIME
* <SAP_FIELD>|WEBAZ
* <CODE_PART>|A_MOVE
* <ADD_FIELD>|
  MOVE BAPI_NETWORK_COMP_ADD-GR_PR_TIME
    TO RESBD-WEBAZ                                                  .

* <BAPI_FIELD>|VENDOR_NO
* <SAP_FIELD>|LIFNR
* <CODE_PART>|A_MOVE
* <ADD_FIELD>|
  MOVE BAPI_NETWORK_COMP_ADD-VENDOR_NO
    TO RESBD-LIFNR                                                  .

* <BAPI_FIELD>|GL_ACCOUNT
* <SAP_FIELD>|SAKNR
* <CODE_PART>|A_MOVE
* <ADD_FIELD>|
  MOVE BAPI_NETWORK_COMP_ADD-GL_ACCOUNT
    TO RESBD-SAKNR                                                  .

* <BAPI_FIELD>|AGMT_ITEM
* <SAP_FIELD>|KTPNR
* <CODE_PART>|A_MOVE
* <ADD_FIELD>|
  MOVE BAPI_NETWORK_COMP_ADD-AGMT_ITEM
    TO RESBD-KTPNR                                                  .

* <BAPI_FIELD>|VSI_SIZE1
* <SAP_FIELD>|ROMS1
* <CODE_PART>|A_MOVE
* <ADD_FIELD>|
  MOVE BAPI_NETWORK_COMP_ADD-VSI_SIZE1
    TO RESBD-ROMS1                                                  .

* <BAPI_FIELD>|S_ORD_ITEM
* <SAP_FIELD>|KDPOS
* <CODE_PART>|A_MOVE
* <ADD_FIELD>|
  MOVE BAPI_NETWORK_COMP_ADD-S_ORD_ITEM
    TO RESBD-KDPOS                                                  .

* <BAPI_FIELD>|WBS_ELEMENT
* <SAP_FIELD>|PSPEL
* <CODE_PART>|A_MOVE
* <ADD_FIELD>|
  MOVE BAPI_NETWORK_COMP_ADD-WBS_ELEMENT
    TO RESBD-PSPEL                                                  .

* <BAPI_FIELD>|CUSTOMER
* <SAP_FIELD>|KUNNR
* <CODE_PART>|A_MOVE
* <ADD_FIELD>|
  MOVE BAPI_NETWORK_COMP_ADD-CUSTOMER
    TO RESBD-KUNNR                                                  .

* <BAPI_FIELD>|SUPP_VENDOR
* <SAP_FIELD>|EMLIF
* <CODE_PART>|A_MOVE
* <ADD_FIELD>|
  MOVE BAPI_NETWORK_COMP_ADD-SUPP_VENDOR
    TO RESBD-EMLIF                                                  .

* <BAPI_FIELD>|ADDR_NO2
* <SAP_FIELD>|ADRN2
* <CODE_PART>|A_MOVE
* <ADD_FIELD>|
  MOVE BAPI_NETWORK_COMP_ADD-ADDR_NO2
    TO RESBD-ADRN2                                                  .

* <BAPI_FIELD>|ADDR_NO
* <SAP_FIELD>|ADRNR
* <CODE_PART>|A_MOVE
* <ADD_FIELD>|
  MOVE BAPI_NETWORK_COMP_ADD-ADDR_NO
    TO RESBD-ADRNR                                                  .

* <BAPI_FIELD>|ORIGINAL_QUANTITY
* <SAP_FIELD>|NOMNG
* <CODE_PART>|A_MOVE
* <ADD_FIELD>|
  MOVE BAPI_NETWORK_COMP_ADD-ORIGINAL_QUANTITY
    TO RESBD-NOMNG                                                  .

* <BAPI_FIELD>|VSI_NO
* <SAP_FIELD>|ROANZ
* <CODE_PART>|A_MOVE
* <ADD_FIELD>|
  MOVE BAPI_NETWORK_COMP_ADD-VSI_NO
    TO RESBD-ROANZ                                                  .

* <BAPI_FIELD>|VSI_FORMULA
* <SAP_FIELD>|RFORM
* <CODE_PART>|A_MOVE
* <ADD_FIELD>|
  MOVE BAPI_NETWORK_COMP_ADD-VSI_FORMULA
    TO RESBD-RFORM                                                  .

* <BAPI_FIELD>|VSI_QTY
* <SAP_FIELD>|ROMEN
* <CODE_PART>|A_MOVE
* <ADD_FIELD>|
  MOVE BAPI_NETWORK_COMP_ADD-VSI_QTY
    TO RESBD-ROMEN                                                  .

* <BAPI_FIELD>|VSI_SIZE3
* <SAP_FIELD>|ROMS3
* <CODE_PART>|A_MOVE
* <ADD_FIELD>|
  MOVE BAPI_NETWORK_COMP_ADD-VSI_SIZE3
    TO RESBD-ROMS3                                                  .

* <BAPI_FIELD>|VSI_SIZE2
* <SAP_FIELD>|ROMS2
* <CODE_PART>|A_MOVE
* <ADD_FIELD>|
  MOVE BAPI_NETWORK_COMP_ADD-VSI_SIZE2
    TO RESBD-ROMS2                                                  .

* <BAPI_FIELD>|ACTIVITY
* <SAP_FIELD>|VORNR
* <CODE_PART>|A_MOVE
* <ADD_FIELD>|
  MOVE BAPI_NETWORK_COMP_ADD-ACTIVITY
    TO RESBD-VORNR                                                  .

* <BAPI_FIELD>|ITEM_NUMBER
* <SAP_FIELD>|POSNR
* <CODE_PART>|A_MOVE
* <ADD_FIELD>|
  MOVE BAPI_NETWORK_COMP_ADD-ITEM_NUMBER
    TO RESBD-POSNR                                                  .

* <BAPI_FIELD>|MATERIAL
* <SAP_FIELD>|MATNR
* <CODE_PART>|A_MOVE
* <ADD_FIELD>|
  MOVE BAPI_NETWORK_COMP_ADD-MATERIAL_LONG
    TO RESBD-MATNR                                                  .

* <BAPI_FIELD>|PLANT
* <SAP_FIELD>|WERKS
* <CODE_PART>|A_MOVE
* <ADD_FIELD>|
  MOVE BAPI_NETWORK_COMP_ADD-PLANT
    TO RESBD-WERKS                                                  .

* <BAPI_FIELD>|ITEM_CAT
* <SAP_FIELD>|POSTP
* <CODE_PART>|A_MOVE
* <ADD_FIELD>|
  MOVE BAPI_NETWORK_COMP_ADD-ITEM_CAT
    TO RESBD-POSTP                                                  .

* <BAPI_FIELD>|ITEM_TEXT
* <SAP_FIELD>|POTX1
* <CODE_PART>|A_MOVE
* <ADD_FIELD>|
  MOVE BAPI_NETWORK_COMP_ADD-ITEM_TEXT
    TO RESBD-POTX1                                                  .

* <BAPI_FIELD>|MRP_RELEVANT
* <SAP_FIELD>|AUDISP
* <CODE_PART>|A_MOVE
* <ADD_FIELD>|
  MOVE BAPI_NETWORK_COMP_ADD-MRP_RELEVANT
    TO RESBD-AUDISP                                                 .

* <BAPI_FIELD>|REQ_DATE
* <SAP_FIELD>|BDTER
* <CODE_PART>|A_MOVE
* <ADD_FIELD>|
  MOVE BAPI_NETWORK_COMP_ADD-REQ_DATE
    TO RESBD-BDTER                                                  .


  MOVE BAPI_NETWORK_COMP_ADD-MANUAL_REQUIREMENTS_DATE
    TO RESBD-kzmpf                                                  .


* <BAPI_FIELD>|LEAD_TIME_OFFSET_OPR
* <SAP_FIELD>|NLFZV
* <CODE_PART>|A_MOVE
* <ADD_FIELD>|
  MOVE BAPI_NETWORK_COMP_ADD-LEAD_TIME_OFFSET_OPR
    TO RESBD-NLFZV                                                  .

* <BAPI_FIELD>|MRP_DISTRIBUTION_KEY
* <SAP_FIELD>|VERTI
* <CODE_PART>|A_MOVE
* <ADD_FIELD>|
  MOVE BAPI_NETWORK_COMP_ADD-MRP_DISTRIBUTION_KEY
    TO RESBD-VERTI                                                  .

* <BAPI_FIELD>|COST_RELEVANT
* <SAP_FIELD>|SANKA
* <CODE_PART>|A_MOVE
* <ADD_FIELD>|
  MOVE BAPI_NETWORK_COMP_ADD-COST_RELEVANT
    TO RESBD-SANKA                                                  .

* <BAPI_FIELD>|STGE_LOC
* <SAP_FIELD>|LGORT
* <CODE_PART>|A_MOVE
* <ADD_FIELD>|
  MOVE BAPI_NETWORK_COMP_ADD-STGE_LOC
    TO RESBD-LGORT                                                  .

* <BAPI_FIELD>|AGREEMENT
* <SAP_FIELD>|KONNR
* <CODE_PART>|A_MOVE
* <ADD_FIELD>|
  MOVE BAPI_NETWORK_COMP_ADD-AGREEMENT
    TO RESBD-KONNR                                                  .

* <BAPI_FIELD>|PUR_INFO_RECORD_DATA_FIXED
* <SAP_FIELD>|KZFIX
* <CODE_PART>|A_MOVE
* <ADD_FIELD>|
  MOVE BAPI_NETWORK_COMP_ADD-PUR_INFO_RECORD_DATA_FIXED
    TO RESBD-KZFIX                                                  .

* <BAPI_FIELD>|PRICE_UNIT
* <SAP_FIELD>|PEINH
* <CODE_PART>|A_MOVE
* <ADD_FIELD>|
  MOVE BAPI_NETWORK_COMP_ADD-PRICE_UNIT
    TO RESBD-PEINH                                                  .

* <BAPI_FIELD>|PRICE
* <SAP_FIELD>|GPREIS
* <CODE_PART>|A_MOVE
* <ADD_FIELD>|
* ^_nt_1134594
  IF NOT BAPI_NETWORK_COMP_ADD-CURRENCY IS INITIAL.
    CALL FUNCTION 'CNIF_CONVERT_CURRENCY2INT'
         EXPORTING
              I_CURRENCY = BAPI_NETWORK_COMP_ADD-CURRENCY
              I_AMOUNT   = BAPI_NETWORK_COMP_ADD-PRICE
         IMPORTING
              E_AMOUNT   = RESBD-GPREIS.
  ELSE.
    MOVE BAPI_NETWORK_COMP_ADD-PRICE
     TO RESBD-GPREIS                                                 .
  ENDIF.
* v_nt_1134594

* <BAPI_FIELD>|INFO_REC
* <SAP_FIELD>|INFNR
* <CODE_PART>|A_MOVE
* <ADD_FIELD>|
  MOVE BAPI_NETWORK_COMP_ADD-INFO_REC
    TO RESBD-INFNR                                                  .

* <BAPI_FIELD>|PURCH_ORG
* <SAP_FIELD>|EKORG
* <CODE_PART>|A_MOVE
* <ADD_FIELD>|
  MOVE BAPI_NETWORK_COMP_ADD-PURCH_ORG
    TO RESBD-EKORG                                                  .

* <BAPI_FIELD>|PUR_GROUP
* <SAP_FIELD>|EKGRP
* <CODE_PART>|A_MOVE
* <ADD_FIELD>|
  MOVE BAPI_NETWORK_COMP_ADD-PUR_GROUP
    TO RESBD-EKGRP                                                  .

* <BAPI_FIELD>|DELIVERY_DAYS
* <SAP_FIELD>|LIFZT
* <CODE_PART>|A_MOVE
* <ADD_FIELD>|
  MOVE BAPI_NETWORK_COMP_ADD-DELIVERY_DAYS
    TO RESBD-LIFZT                                                  .

* <BAPI_FIELD>|BOMEXPL_NO
* <SAP_FIELD>|SERNR
* <CODE_PART>|A_MOVE
* <ADD_FIELD>|
  MOVE BAPI_NETWORK_COMP_ADD-BOMEXPL_NO
    TO RESBD-SERNR                                                  .

* <BAPI_FIELD>|BATCH
* <SAP_FIELD>|CHARG
* <CODE_PART>|A_MOVE
* <ADD_FIELD>|
  MOVE BAPI_NETWORK_COMP_ADD-BATCH
    TO RESBD-CHARG                                                  .

*--------------------------------------------------------*
* Adaptada para trabalhar com campos Zs e adicionais

* Campos adicionais

  MOVE BAPI_NETWORK_COMP_ADD-MFLIC
    TO RESBD-MFLIC                                                  .

* Campos Zs

  MOVE BAPI_NETWORK_COMP_ADD-EQUNR
    TO RESBD-EQUNR                                                  .

  MOVE BAPI_NETWORK_COMP_ADD-EQKTX
    TO RESBD-EQKTX                                                  .

*--------------------------------------------------------*


* <BAPI_FIELD>|CURRENCY_ISO
* <SAP_FIELD>|WAERS
* <CODE_PART>|ISO_INT_CURR
* <ADD_FIELD>|CURRENCY
  IF NOT BAPI_NETWORK_COMP_ADD-CURRENCY
  IS INITIAL.
    MOVE BAPI_NETWORK_COMP_ADD-CURRENCY
      TO RESBD-WAERS                                                  .
  ELSEIF BAPI_NETWORK_COMP_ADD-CURRENCY_ISO
  IS INITIAL.
    CLEAR RESBD-WAERS                                                  .
  ELSE.
    CALL FUNCTION 'CURRENCY_CODE_ISO_TO_SAP'
      EXPORTING
        ISO_CODE  = BAPI_NETWORK_COMP_ADD-CURRENCY_ISO
      IMPORTING
        SAP_CODE  = RESBD-WAERS
      EXCEPTIONS
        NOT_FOUND = 1
        OTHERS    = 2.
    IF SY-SUBRC <> 0.
      MESSAGE A547(B1) WITH
      BAPI_NETWORK_COMP_ADD-CURRENCY_ISO
      'CURRENCY_ISO                  '
      RAISING ERROR_CONVERTING_ISO_CODE.
    ENDIF.
  ENDIF.

* <BAPI_FIELD>|VAR_SIZE_COMP_MEASURE_UNIT_ISO
* <SAP_FIELD>|ROKME
* <CODE_PART>|ISO_INT_UNIT
* <ADD_FIELD>|VAR_SIZE_COMP_MEASURE_UNIT
  IF NOT BAPI_NETWORK_COMP_ADD-VAR_SIZE_COMP_MEASURE_UNIT
  IS INITIAL.
    MOVE BAPI_NETWORK_COMP_ADD-VAR_SIZE_COMP_MEASURE_UNIT
      TO RESBD-ROKME                                                  .
  ELSEIF BAPI_NETWORK_COMP_ADD-VAR_SIZE_COMP_MEASURE_UNIT_ISO
  IS INITIAL.
    CLEAR RESBD-ROKME                                                  .
  ELSE.
    CALL FUNCTION 'UNIT_OF_MEASURE_ISO_TO_SAP'
         EXPORTING
              ISO_CODE  =
         BAPI_NETWORK_COMP_ADD-VAR_SIZE_COMP_MEASURE_UNIT_ISO
         IMPORTING
              SAP_CODE  =
         RESBD-ROKME
         EXCEPTIONS
              NOT_FOUND = 1
              OTHERS    = 2.
    IF SY-SUBRC <> 0.
      MESSAGE A548(B1) WITH
      BAPI_NETWORK_COMP_ADD-VAR_SIZE_COMP_MEASURE_UNIT_ISO
      'VAR_SIZE_COMP_MEASURE_UNIT_ISO'
      RAISING ERROR_CONVERTING_ISO_CODE.
    ENDIF.
  ENDIF.

* <BAPI_FIELD>|VSI_SIZE_UNIT_ISO
* <SAP_FIELD>|ROMEI
* <CODE_PART>|ISO_INT_UNIT
* <ADD_FIELD>|VSI_SIZE_UNIT
  IF NOT BAPI_NETWORK_COMP_ADD-VSI_SIZE_UNIT
  IS INITIAL.
    MOVE BAPI_NETWORK_COMP_ADD-VSI_SIZE_UNIT
      TO RESBD-ROMEI                                                  .
  ELSEIF BAPI_NETWORK_COMP_ADD-VSI_SIZE_UNIT_ISO
  IS INITIAL.
    CLEAR RESBD-ROMEI                                                  .
  ELSE.
    CALL FUNCTION 'UNIT_OF_MEASURE_ISO_TO_SAP'
      EXPORTING
        ISO_CODE  = BAPI_NETWORK_COMP_ADD-VSI_SIZE_UNIT_ISO
      IMPORTING
        SAP_CODE  = RESBD-ROMEI
      EXCEPTIONS
        NOT_FOUND = 1
        OTHERS    = 2.
    IF SY-SUBRC <> 0.
      MESSAGE A548(B1) WITH
      BAPI_NETWORK_COMP_ADD-VSI_SIZE_UNIT_ISO
      'VSI_SIZE_UNIT_ISO             '
      RAISING ERROR_CONVERTING_ISO_CODE.
    ENDIF.
  ENDIF.

* <BAPI_FIELD>|BASE_UOM_ISO
* <SAP_FIELD>|MEINS
* <CODE_PART>|ISO_INT_UNIT
* <ADD_FIELD>|BASE_UOM
  IF NOT BAPI_NETWORK_COMP_ADD-BASE_UOM
  IS INITIAL.
    MOVE BAPI_NETWORK_COMP_ADD-BASE_UOM
      TO RESBD-MEINS                                                  .
  ELSEIF BAPI_NETWORK_COMP_ADD-BASE_UOM_ISO
  IS INITIAL.
    CLEAR RESBD-MEINS                                                  .
  ELSE.
    CALL FUNCTION 'UNIT_OF_MEASURE_ISO_TO_SAP'
      EXPORTING
        ISO_CODE  = BAPI_NETWORK_COMP_ADD-BASE_UOM_ISO
      IMPORTING
        SAP_CODE  = RESBD-MEINS
      EXCEPTIONS
        NOT_FOUND = 1
        OTHERS    = 2.
    IF SY-SUBRC <> 0.
      MESSAGE A548(B1) WITH
      BAPI_NETWORK_COMP_ADD-BASE_UOM_ISO
      'BASE_UOM_ISO                  '
      RAISING ERROR_CONVERTING_ISO_CODE.
    ENDIF.
  ENDIF.

* <BAPI_FIELD>|LEAD_TIME_OFFSET_OPR_UNIT_ISO
* <SAP_FIELD>|NLFMV
* <CODE_PART>|ISO_INT_UNIT
* <ADD_FIELD>|LEAD_TIME_OFFSET_OPR_UNIT
  IF NOT BAPI_NETWORK_COMP_ADD-LEAD_TIME_OFFSET_OPR_UNIT
  IS INITIAL.
    MOVE BAPI_NETWORK_COMP_ADD-LEAD_TIME_OFFSET_OPR_UNIT
      TO RESBD-NLFMV                                                  .
  ELSEIF BAPI_NETWORK_COMP_ADD-LEAD_TIME_OFFSET_OPR_UNIT_ISO
  IS INITIAL.
    CLEAR RESBD-NLFMV                                                  .
  ELSE.
    CALL FUNCTION 'UNIT_OF_MEASURE_ISO_TO_SAP'
         EXPORTING
              ISO_CODE  =
         BAPI_NETWORK_COMP_ADD-LEAD_TIME_OFFSET_OPR_UNIT_ISO
         IMPORTING
              SAP_CODE  =
         RESBD-NLFMV
         EXCEPTIONS
              NOT_FOUND = 1
              OTHERS    = 2.
    IF SY-SUBRC <> 0.
      MESSAGE A548(B1) WITH
      BAPI_NETWORK_COMP_ADD-LEAD_TIME_OFFSET_OPR_UNIT_ISO
      'LEAD_TIME_OFFSET_OPR_UNIT_ISO '
      RAISING ERROR_CONVERTING_ISO_CODE.
    ENDIF.
  ENDIF.

  PERFORM MAP2I_BAPI_COMPS_ADD_TO_RESBD
    USING
      BAPI_NETWORK_COMP_ADD
    CHANGING
      RESBD                         .





ENDFUNCTION.

*&--------------------------------------------------------------------*
*&      Form  MAP2I_BAPI_COMPS_ADD_TO_RESBD
*&--------------------------------------------------------------------*
*       text
*---------------------------------------------------------------------*
*      -->BAPI_NETWORtextMP_ADD
*      -->RESBD      text
*---------------------------------------------------------------------*
FORM MAP2I_BAPI_COMPS_ADD_TO_RESBD
  USING
    BAPI_NETWORK_COMP_ADD
    STRUCTURE BAPI_NETWORK_COMP_ADD
  CHANGING
    RESBD
    STRUCTURE RESBD                         .
* Bedarfsmenge konvertieren
  resbd-menge = BAPI_NETWORK_COMP_ADD-entry_quantity.
  resbd-einheit = BAPI_NETWORK_COMP_ADD-BASE_UOM.
  if BAPI_NETWORK_COMP_ADD-entry_quantity >= 0.
    resbd-bdmng = BAPI_NETWORK_COMP_ADD-entry_quantity.
    resbd-shkzg = haben.
  else.
    resbd-bdmng = BAPI_NETWORK_COMP_ADD-entry_quantity * ( -1 ).
    resbd-shkzg = soll.
  endif.
ENDFORM.                    "MAP2I_BAPI_COMPS_ADD_TO_RESBD
