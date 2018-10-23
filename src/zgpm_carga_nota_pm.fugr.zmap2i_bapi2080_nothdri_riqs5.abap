FUNCTION zmap2i_bapi2080_nothdri_riqs5.
*"----------------------------------------------------------------------
*"*"Interface local:
*"  IMPORTING
*"     REFERENCE(BAPI2080_NOTHDRI) LIKE  BAPI2080_NOTHDRI STRUCTURE
*"        BAPI2080_NOTHDRI
*"     REFERENCE(P_I_WA_CAMPOS_ADD_RIQS5) TYPE  ZEPM_CAMPOS_ADD_RIQS5
*"  CHANGING
*"     REFERENCE(RIQS5) LIKE  RIQS5 STRUCTURE  RIQS5
*"----------------------------------------------------------------------

* This function module was generated. Don't change it manually!
* <VERSION>|4
* <BAPI_STRUCTURE>|BAPI2080_NOTHDRI
* <SAP_STRUCTURE>|RIQS5
* <INTERN_TO_EXTERN>|
* <APPEND FORM>|

* <BAPI_FIELD>|STRMLFNTIME
* <SAP_FIELD>|AUZTV
* <CODE_PART>|A_MOVE
* <ADD_FIELD>|
  MOVE bapi2080_nothdri-strmlfntime
    TO riqs5-auztv                                                  .

* <BAPI_FIELD>|STRMLFNDATE
* <SAP_FIELD>|AUSVN
* <CODE_PART>|A_MOVE
* <ADD_FIELD>|
  MOVE bapi2080_nothdri-strmlfndate
    TO riqs5-ausvn                                                  .

* <BAPI_FIELD>|BREAKDOWN
* <SAP_FIELD>|MSAUS
* <CODE_PART>|A_MOVE
* <ADD_FIELD>|
  MOVE bapi2080_nothdri-breakdown
    TO riqs5-msaus                                                  .

* <BAPI_FIELD>|PLANGROUP
* <SAP_FIELD>|INGRP
* <CODE_PART>|A_MOVE
* <ADD_FIELD>|
  MOVE bapi2080_nothdri-plangroup
    TO riqs5-ingrp                                                  .

* <BAPI_FIELD>|PLANPLANT
* <SAP_FIELD>|IWERK
* <CODE_PART>|A_MOVE
* <ADD_FIELD>|
  MOVE bapi2080_nothdri-planplant
    TO riqs5-iwerk                                                  .

* <BAPI_FIELD>|PURCH_DATE
* <SAP_FIELD>|BSTDK
* <CODE_PART>|A_MOVE
* <ADD_FIELD>|
  MOVE bapi2080_nothdri-purch_date
    TO riqs5-bstdk                                                  .

* <BAPI_FIELD>|PURCH_NO_C
* <SAP_FIELD>|BSTNK
* <CODE_PART>|A_MOVE
* <ADD_FIELD>|
  MOVE bapi2080_nothdri-purch_no_c
    TO riqs5-bstnk                                                  .

* <BAPI_FIELD>|PM_WKCTR
* <SAP_FIELD>|ARBPL
* <CODE_PART>|A_MOVE
* <ADD_FIELD>|
  MOVE bapi2080_nothdri-pm_wkctr
    TO riqs5-arbpl                                                  .

* <BAPI_FIELD>|DEVICEDATA
* <SAP_FIELD>|DEVICEID
* <CODE_PART>|A_MOVE
* <ADD_FIELD>|
  MOVE bapi2080_nothdri-devicedata
    TO riqs5-deviceid                                               .

* <BAPI_FIELD>|ENDMLFNTIME
* <SAP_FIELD>|AUZTB
* <CODE_PART>|A_MOVE
* <ADD_FIELD>|
  MOVE bapi2080_nothdri-endmlfntime
    TO riqs5-auztb                                                  .

* <BAPI_FIELD>|ENDMLFNDATE
* <SAP_FIELD>|AUSBS
* <CODE_PART>|A_MOVE
* <ADD_FIELD>|
  MOVE bapi2080_nothdri-endmlfndate
    TO riqs5-ausbs                                                  .

* <BAPI_FIELD>|ITM_NUMBER
* <SAP_FIELD>|KDPOS
* <CODE_PART>|A_MOVE
* <ADD_FIELD>|
  MOVE bapi2080_nothdri-itm_number
    TO riqs5-kdpos                                                 .

* <BAPI_FIELD>|SALES_ORD
* <SAP_FIELD>|LS_KDAUF
* <CODE_PART>|A_MOVE
* <ADD_FIELD>|
  MOVE bapi2080_nothdri-doc_number
    TO riqs5-kdauf                                                 .

* <BAPI_FIELD>|CODING
* <SAP_FIELD>|QMCOD
* <CODE_PART>|A_MOVE
* <ADD_FIELD>|
  MOVE bapi2080_nothdri-coding
    TO riqs5-qmcod                                                  .

* <BAPI_FIELD>|CODE_GROUP
* <SAP_FIELD>|QMGRP
* <CODE_PART>|A_MOVE
* <ADD_FIELD>|
  MOVE bapi2080_nothdri-code_group
    TO riqs5-qmgrp                                                  .

* <BAPI_FIELD>|NOTIFTIME
* <SAP_FIELD>|MZEIT
* <CODE_PART>|A_MOVE
* <ADD_FIELD>|
  MOVE bapi2080_nothdri-notiftime
    TO riqs5-mzeit                                                  .

* <BAPI_FIELD>|NOTIF_DATE
* <SAP_FIELD>|QMDAT
* <CODE_PART>|A_MOVE
* <ADD_FIELD>|
  MOVE bapi2080_nothdri-notif_date
    TO riqs5-qmdat                                                  .

* <BAPI_FIELD>|REPORTEDBY
* <SAP_FIELD>|QMNAM
* <CODE_PART>|A_MOVE
* <ADD_FIELD>|
  MOVE bapi2080_nothdri-reportedby
    TO riqs5-qmnam                                                  .

* <BAPI_FIELD>|DESENDTM
* <SAP_FIELD>|LTRUR
* <CODE_PART>|A_MOVE
* <ADD_FIELD>|
  MOVE bapi2080_nothdri-desendtm
    TO riqs5-ltrur                                                  .

* <BAPI_FIELD>|DIVISION
* <SAP_FIELD>|SPART
* <CODE_PART>|A_MOVE
* <ADD_FIELD>|
  MOVE bapi2080_nothdri-division
    TO riqs5-spart                                                  .

* <BAPI_FIELD>|MATERIAL
* <SAP_FIELD>|MATNR
* <CODE_PART>|A_MOVE
* <ADD_FIELD>|
*MOVE BAPI2080_NOTHDRI-MATERIAL
*  TO RIQS5-MATNR                                                  .
  MOVE bapi2080_nothdri-material_long    "MFLE
    TO riqs5-matnr                                                  .

* <BAPI_FIELD>|SERIALNO
* <SAP_FIELD>|SERIALNR
* <CODE_PART>|A_MOVE
* <ADD_FIELD>|
  MOVE bapi2080_nothdri-serialno
    TO riqs5-serialnr                                               .

* <BAPI_FIELD>|ASSEMBLY
* <SAP_FIELD>|BAUTL
* <CODE_PART>|A_MOVE
* <ADD_FIELD>|
*MOVE BAPI2080_NOTHDRI-ASSEMBLY
*  TO RIQS5-BAUTL                                                  .
  MOVE bapi2080_nothdri-assembly_long     "MFLE
    TO riqs5-bautl                                                  .

* <BAPI_FIELD>|FUNCT_LOC
* <SAP_FIELD>|TPLNR
* <CODE_PART>|A_MOVE
* <ADD_FIELD>|
  MOVE bapi2080_nothdri-funct_loc
    TO riqs5-tplnr                                                  .

* <BAPI_FIELD>|EQUIPMENT
* <SAP_FIELD>|EQUNR
* <CODE_PART>|A_MOVE
* <ADD_FIELD>|
  MOVE bapi2080_nothdri-equipment
    TO riqs5-equnr                                                  .

* <BAPI_FIELD>|RELTYPE
* <SAP_FIELD>|RELTYPE
* <CODE_PART>|A_MOVE
* <ADD_FIELD>|
  MOVE bapi2080_nothdri-refreltype
    TO riqs5-reltype                                                .

* <BAPI_FIELD>|OBJKEY
* <SAP_FIELD>|REFOBJKEY
* <CODE_PART>|A_MOVE
* <ADD_FIELD>|
  MOVE bapi2080_nothdri-refobjectkey
    TO riqs5-refobjkey                                              .

* <BAPI_FIELD>|OBJTYPE
* <SAP_FIELD>|REFOBJTYP
* <CODE_PART>|A_MOVE
* <ADD_FIELD>|
  MOVE bapi2080_nothdri-refobjecttype
    TO riqs5-refobjtyp                                              .

* <BAPI_FIELD>|DESENDDATE
* <SAP_FIELD>|LTRMN
* <CODE_PART>|A_MOVE
* <ADD_FIELD>|
  MOVE bapi2080_nothdri-desenddate
    TO riqs5-ltrmn                                                  .

* <BAPI_FIELD>|DESSTTIME
* <SAP_FIELD>|STRUR
* <CODE_PART>|A_MOVE
* <ADD_FIELD>|
  MOVE bapi2080_nothdri-dessttime
    TO riqs5-strur                                                  .

* <BAPI_FIELD>|DESSTDATE
* <SAP_FIELD>|STRMN
* <CODE_PART>|A_MOVE
* <ADD_FIELD>|
  MOVE bapi2080_nothdri-desstdate
    TO riqs5-strmn                                                  .

* <BAPI_FIELD>|PRIORITY
* <SAP_FIELD>|PRIOK
* <CODE_PART>|A_MOVE
* <ADD_FIELD>|
  MOVE bapi2080_nothdri-priority
    TO riqs5-priok                                                  .

* <BAPI_FIELD>|SHORT_TEXT
* <SAP_FIELD>|QMTXT
* <CODE_PART>|A_MOVE
* <ADD_FIELD>|
  MOVE bapi2080_nothdri-short_text
    TO riqs5-qmtxt                                                  .

* <BAPI_FIELD>|SALES_GRP
* <SAP_FIELD>|VKGRP
* <CODE_PART>|A_MOVE
* <ADD_FIELD>|
  MOVE bapi2080_nothdri-sales_grp
    TO riqs5-vkgrp                                                  .

* <BAPI_FIELD>|SALES_OFFICE
* <SAP_FIELD>|VKBUR
* <CODE_PART>|A_MOVE
* <ADD_FIELD>|
  MOVE bapi2080_nothdri-sales_office
    TO riqs5-vkbur                                                  .

* <BAPI_FIELD>|DISTR_CHAN
* <SAP_FIELD>|VTWEG
* <CODE_PART>|A_MOVE
* <ADD_FIELD>|
  MOVE bapi2080_nothdri-distr_chan
    TO riqs5-vtweg                                                  .

* <BAPI_FIELD>|SALES_ORG
* <SAP_FIELD>|VKORG
* <CODE_PART>|A_MOVE
* <ADD_FIELD>|
  MOVE bapi2080_nothdri-sales_org
    TO riqs5-vkorg                                                  .

  MOVE bapi2080_nothdri-scenario
    TO riqs5-auswirk.

  MOVE bapi2080_nothdri-maintplant
    TO riqs5-swerk.

  MOVE bapi2080_nothdri-maintloc
    TO riqs5-stort.

  MOVE bapi2080_nothdri-maintroom
    TO riqs5-msgrp.

  MOVE bapi2080_nothdri-sortfield                           "2041393
    TO riqs5-eqfnr.                                         "2041393

  " Effect field for fiori application
  MOVE bapi2080_nothdri-effect
    TO riqs5-auswk.

*-------------------------------------------------*
* Campos adicionais para RIQS5                    *
*-------------------------------------------------*

  MOVE p_i_wa_campos_add_riqs5-arbplwerk
    TO riqs5-arbplwerk.

  MOVE p_i_wa_campos_add_riqs5-bukrs
    TO riqs5-bukrs.

  MOVE p_i_wa_campos_add_riqs5-anlnr
    TO riqs5-anlnr.

  MOVE p_i_wa_campos_add_riqs5-anlun
  TO riqs5-anlun.

  MOVE p_i_wa_campos_add_riqs5-gsber
  TO riqs5-gsber.

  MOVE p_i_wa_campos_add_riqs5-kostl
    TO riqs5-kostl.

  MOVE p_i_wa_campos_add_riqs5-kokrs
    TO riqs5-kokrs.

* Tipo de catálogo - codificação / partes
  MOVE 'B'
    TO riqs5-qmkat.

ENDFUNCTION.
