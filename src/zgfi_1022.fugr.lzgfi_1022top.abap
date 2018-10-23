FUNCTION-POOL zgfi_1022.                    "MESSAGE-ID ..

* INCLUDE LZGFI_1022D...                     " Local class definition

INCLUDE icons.

TABLES: anla, t093c.

TYPE-POOLS slis.

TYPES: BEGIN OF y_anka,
         anlkl TYPE anka-anlkl,
       END OF y_anka,
       ty_anka TYPE SORTED TABLE OF y_anka WITH UNIQUE KEY anlkl,

       BEGIN OF y_bukrs,
         bukrs TYPE t001-bukrs,
       END OF y_bukrs,
       ty_bukrs TYPE SORTED TABLE OF y_bukrs WITH UNIQUE KEY bukrs,

       BEGIN OF y_anla,
         anln1 TYPE anla-anln1,
         anln2 TYPE anla-anln2,
         aktiv TYPE anla-aktiv,
       END OF y_anla,
       ty_anla TYPE STANDARD TABLE OF y_anla,

       BEGIN OF y_csks,
         kostl TYPE csks-kostl,
       END OF y_csks,
       ty_csks TYPE SORTED TABLE OF y_csks WITH UNIQUE KEY kostl,

       BEGIN OF y_aufk,
         aufnr TYPE aufk-aufnr,
       END OF y_aufk,
       ty_aufk TYPE SORTED TABLE OF y_aufk WITH UNIQUE KEY aufnr,

       BEGIN OF y_t001w,
         werks TYPE t001w-werks,
       END OF y_t001w,
       ty_t001w TYPE SORTED TABLE OF y_t001w WITH UNIQUE KEY werks,

       BEGIN OF y_t499s,
         werks TYPE t001w-werks,
         stand TYPE t499s-stand,
       END OF y_t499s,
       ty_t499s TYPE SORTED TABLE OF y_t499s WITH UNIQUE KEY werks stand,

       BEGIN OF y_t090,
         afasl TYPE afasl,
       END OF y_t090,
       ty_t090 TYPE SORTED TABLE OF y_t090 WITH UNIQUE KEY afasl,

       BEGIN OF y_t006,
         msehi TYPE msehi,
       END OF y_t006,
       ty_t006 TYPE SORTED TABLE OF y_t006 WITH UNIQUE KEY msehi,

       BEGIN OF y_tgsb,
         gsber TYPE gsber,
       END OF y_tgsb,
       ty_tgsb TYPE SORTED TABLE OF y_tgsb WITH UNIQUE KEY gsber,

       BEGIN OF y_cododi,
         bukrs TYPE zcododi-bukrs,
         werks TYPE zcododi-werks,
         stand TYPE zcododi-stand,
         codti TYPE zcododi-codti,
         gti   TYPE zcododi-gti,
         odi   TYPE zcododi-odi,
         cc    TYPE zcododi-cc,
         data  TYPE zcododi-data,
       END OF y_cododi,
       ty_cododi TYPE SORTED TABLE OF y_cododi WITH UNIQUE KEY bukrs werks stand codti gti odi,

       BEGIN OF y_tipins,
         codti TYPE ztipins-codti,
       END OF y_tipins,
       ty_tipins TYPE SORTED TABLE OF y_tipins WITH UNIQUE KEY codti,

       BEGIN OF y_cmloci,
         cmli TYPE zcmloci-cmli,
       END OF y_cmloci,
       ty_cmloci TYPE SORTED TABLE OF y_cmloci WITH UNIQUE KEY cmli,

       BEGIN OF y_cmcomp,
         cmcomp TYPE zcmcomp-cmcomp,
       END OF y_cmcomp,
       ty_cmcomp TYPE SORTED TABLE OF y_cmcomp WITH UNIQUE KEY cmcomp,

       BEGIN OF y_cmarfi,
         cmaf TYPE zcmarfi-cmaf,
       END OF y_cmarfi,
       ty_cmarfi TYPE SORTED TABLE OF y_cmarfi WITH UNIQUE KEY cmaf,

       BEGIN OF y_tipouc,
         tuc TYPE ztipouc-tuc,
       END OF y_tipouc,
       ty_tipouc TYPE SORTED TABLE OF y_tipouc WITH UNIQUE KEY tuc,

       BEGIN OF y_tipbem,
         tuc  TYPE ztipbem-tuc,
         tbem TYPE ztipbem-tbem,
       END OF y_tipbem,
       ty_tipbem TYPE SORTED TABLE OF y_tipbem WITH UNIQUE KEY tuc tbem,

       BEGIN OF y_paratr,
         tuc     TYPE ztipbem-tuc,
         tbem    TYPE ztipbem-tbem,
         chavea2 TYPE zparatr-chavea2,
         chavea3 TYPE zparatr-chavea3,
         chavea4 TYPE zparatr-chavea4,
         chavea5 TYPE zparatr-chavea5,
         chavea6 TYPE zparatr-chavea6,
       END OF y_paratr,
       ty_paratr TYPE SORTED TABLE OF y_paratr WITH UNIQUE KEY tuc tbem,

       BEGIN OF y_cdguar,
         tuc    TYPE ztipbem-tuc,
         tbem   TYPE ztipbem-tbem,
         coduar TYPE zcdguar-coduar,
       END OF y_cdguar,
       ty_cdguar TYPE SORTED TABLE OF y_cdguar WITH UNIQUE KEY tuc tbem coduar,

       BEGIN OF y_forcad,
         cadastro TYPE zforcad-cadastro,
       END OF y_forcad,
       ty_forcad TYPE SORTED TABLE OF y_forcad WITH UNIQUE KEY cadastro,

       BEGIN OF y_mara,
         matnr TYPE matnr,
       END OF y_mara,
       ty_mara TYPE SORTED TABLE OF y_mara WITH UNIQUE KEY matnr,

       BEGIN OF y_log,
         icon         TYPE iconname,
         linha(7)     TYPE n,
         campo(15),
         message(100),
       END OF y_log,
       ty_log TYPE STANDARD TABLE OF y_log.

CONSTANTS: c_tb01 TYPE bukrs VALUE 'TB01'.

DATA: gt_log   TYPE ty_log,
      gs_log   TYPE y_log,
      gv_dados TYPE zefi_imobilizado,
      gv_msehi TYPE t006-msehi.

**> Bdc - Mapeamento Batch-input
DATA  gt_bdc LIKE bdcdata OCCURS 0 WITH HEADER LINE.

DATA racom    TYPE ctu_params.

DATA ti_msg_err  TYPE STANDARD TABLE OF bdcmsgcoll WITH HEADER LINE.

* Dados para chamada da bapi
DATA: gv_bapi1022_key           TYPE bapi1022_key,
      gv_bapi1022_feglg001      TYPE bapi1022_feglg001,
      gv_bapi1022_feglg002      TYPE bapi1022_feglg002,
      gv_bapi1022_feglg001x     TYPE bapi1022_feglg001x,
      gv_bapi1022_feglg002x     TYPE bapi1022_feglg002x,
      gt_bapi1022_cumval        TYPE STANDARD TABLE OF bapi1022_cumval WITH HEADER LINE,
      gt_bapi1022_postval       TYPE STANDARD TABLE OF bapi1022_postval WITH HEADER LINE,
      gv_bapi1022_feglg003      TYPE bapi1022_feglg003,
      gv_bapi1022_feglg003x     TYPE bapi1022_feglg003x,
      gt_extensionin            TYPE STANDARD TABLE OF bapiparex WITH HEADER LINE,
      gv_bapi_te_anlu           TYPE bapi_te_anlu,
      gv_tuc_atrib(21),
      gv_anlu                   TYPE anlu,
      gv_anln1                  TYPE anla-anln1,
      gt_bapi1022_dep_areas     TYPE STANDARD TABLE OF bapi1022_dep_areas WITH HEADER LINE,
      gt_bapi1022_dep_areasx    TYPE STANDARD TABLE OF bapi1022_dep_areasx WITH HEADER LINE,
      gt_bapi1022_postingheader TYPE STANDARD TABLE OF bapi1022_postingheader WITH HEADER LINE,
      gv_return                 TYPE bapiret2,
      gt_return                 TYPE STANDARD TABLE OF bapiret2 WITH HEADER LINE.

DEFINE _add_log.
  gs_log-icon = icon_incomplete.
  gs_log-linha = &1.
  gs_log-campo = &2.
  gs_log-message = &3.
  APPEND gs_log TO gt_log.
END-OF-DEFINITION.

DEFINE _inc.
  &1 = &1 + 1.
END-OF-DEFINITION.

DEFINE _add_log_sucess.
  gs_log-icon = icon_checked.
  gs_log-message = &1.
  APPEND gs_log TO gt_log.
END-OF-DEFINITION.
