FUNCTION-POOL zgpm_carga_equipamento.           "MESSAGE-ID ..

** global type pools
*TYPE-POOLS:
*  itob,
*  slis.


* INCLUDE LZGPS_CARGA_DE_PEPSD...            " Local class definition

* INCLUDE ps_bapi_global_data.

INCLUDE libaptoc.

CONSTANTS:
  BEGIN OF gc_transaction,
    equi_create LIKE sy-tcode       VALUE 'IE01',
    equi_change LIKE sy-tcode       VALUE 'IE02',
    equi_read   LIKE sy-tcode       VALUE 'IE03',           "P9CK232793
  END   OF gc_transaction.
