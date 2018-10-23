FUNCTION-POOL ZGPM_CARGA_PLANO_MANUT.           "MESSAGE-ID ..

* INCLUDE LZGPS_CARGA_DE_PEPSD...            " Local class definition

* INCLUDE ps_bapi_global_data.

*-- PM -------------------------------------

*--- constants
CONSTANTS chare(1) VALUE 'E'.
CONSTANTS chard(1) VALUE 'D'.

* Report names for selection
CONSTANTS gc_ralm_me_riqmel20
  TYPE rsvar-report VALUE 'RIQMEL20'.

*--- local workareas notification header data
DATA: f_viqmel  LIKE viqmel,
      f_riwo03  LIKE riwo03,
      sap_langu LIKE sy-langu,    "Change status
      w_vrgng   LIKE tc33-vrgng.  "Change status
*--- workaras for relationsships
DATA  f_sender       LIKE bdi_logsys.
*--- Full texts table ( Add, Delete, Get details, Modify )
DATA t_tline  LIKE rfc_tline     OCCURS 0 WITH HEADER LINE.
*--- Items table ( Add, Delete, Create, Modify )
DATA t_viqmfe LIKE rfc_viqmfe    OCCURS 0 WITH HEADER LINE.
*--- Activities table ( Add, Delete, Create, Modify )
DATA t_viqmma LIKE rfc_viqmma    OCCURS 0 WITH HEADER LINE.
*--- Tasks table ( Add, Delete, Create, Modify )
DATA t_viqmsm LIKE rfc_viqmsm    OCCURS 0 WITH HEADER LINE.
*--- Causes table ( Add, Delete, Create, Modify )
DATA t_viqmur LIKE rfc_viqmur    OCCURS 0 WITH HEADER LINE.
*--- Partners table ( Add, Delete, Create, Modify )
DATA t_hpavb  LIKE rfc_ihpa      OCCURS 0 WITH HEADER LINE.

*Data declaration for Get details / Modify******************************
*--- Items table
DATA t_wiqmfe LIKE wqmfe     OCCURS 0 WITH HEADER LINE.
*--- Activities table
DATA t_wiqmma LIKE wqmma     OCCURS 0 WITH HEADER LINE.
*--- Tasks table
DATA t_wiqmsm LIKE wqmsm     OCCURS 0 WITH HEADER LINE.
*--- Causes table
DATA t_wiqmur LIKE wqmur     OCCURS 0 WITH HEADER LINE.
*--- Partners table
DATA t_ihpavb LIKE ihpavb    OCCURS 0 WITH HEADER LINE.

*Data declaration for Create Notification*******************************
DATA: f_riqs5        LIKE riqs5,
      g_bin_relation LIKE qm00-qkz.
DATA: BEGIN OF h_mess_wa,
        type   LIKE bapireturn-type,
        cl     LIKE sy-msgid,
        number LIKE sy-msgno,
        par1   LIKE sy-msgv1,
        par2   LIKE sy-msgv2,
        par3   LIKE sy-msgv3,
        par4   LIKE sy-msgv4,
      END OF h_mess_wa.
*--- Longtext table
DATA t_inlines LIKE rfc_tline    OCCURS 0 WITH HEADER LINE.
*Data declaration for Create / Modify***********************************
*--- Key Relationship table
DATA t_keys    LIKE rfc_key      OCCURS 0 WITH HEADER LINE.
*Data declaration for Modify Notification*******************************
DATA t_ihpa_m  LIKE rfc_ihpa_m   OCCURS 0 WITH HEADER LINE.
DATA  p_head_nochange(1) TYPE c.
