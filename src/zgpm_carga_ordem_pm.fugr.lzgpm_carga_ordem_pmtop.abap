FUNCTION-POOL ZGPM_CARGA_ORDEM_PM.           "MESSAGE-ID ..

* INCLUDE LZGPS_CARGA_DE_PEPSD...            " Local class definition

* INCLUDE ps_bapi_global_data.

*-- constants
CONSTANTS  yx  VALUE 'X'.              "Flag X

CONSTANTS gc_riafvc20 TYPE rsvar-report
   VALUE 'RIAFVC20'.

CONSTANTS gc_riaufk20 TYPE rsvar-report
   VALUE 'RIAUFK20'.


* Long text keys
CONSTANTS gc_textid_header    TYPE thead-tdid
  VALUE 'KOPF'.
CONSTANTS gc_textid_operation TYPE thead-tdid
  VALUE 'AVOT'.
CONSTANTS gc_textid_component TYPE thead-tdid
  VALUE 'MATK'.
CONSTANTS gc_textobject       TYPE thead-tdobject
  VALUE 'AUFK    '.

* Table type for long texts
TYPES gt_textline_table TYPE TABLE OF csapi_tline.
