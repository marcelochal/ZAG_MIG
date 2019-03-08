FUNCTION-POOL zgps_carga_diag_rede.         "MESSAGE-ID ..

* INCLUDE LZGPS_CARGA_DIAG_REDED...          " Local class definition

CONSTANTS:
  con_net_create      TYPE c VALUE 'G',  "Create network
  con_yes             VALUE 'X',
  con_%               TYPE c VALUE '%',
  con_objtype_network TYPE ps_object_type VALUE '3',
  con_func_area(9)    TYPE c VALUE 'FUNC_AREA',
  con_struc_net_new   LIKE dcobjdef-name VALUE 'BAPI_BUS2002_NEW'.

CONSTANTS:
  BEGIN OF auftragstyp,
    fert TYPE       auftyp VALUE '10',   "Fertigungsauftrag
    netw TYPE       auftyp VALUE '20',   "Netzplan
    inst TYPE       auftyp VALUE '30',   "Instandhaltung
    hiko TYPE       auftyp VALUE '31',   "Instandhaltung - Historie
    rma  TYPE       auftyp VALUE '32',   "SM Rma-Auftrag (für AFPO)
    bord TYPE       auftyp VALUE '40',   "Prozeßauftrag
    qamm TYPE       auftyp VALUE '50',   "Prüfabwicklung
    pord TYPE       auftyp VALUE '60',   "Personal Order
    vert TYPE       auftyp VALUE '70',   "Versandterminierung
    copp TYPE       auftyp VALUE '04',   "CO-PPS-Auftrag
    corp TYPE       auftyp VALUE '05',   "CO-repetative Production
    coqi TYPE       auftyp VALUE '06',   "Prüfkostenauftrag
    kos1 TYPE       auftyp VALUE '01',   "Innenauftrag
  END   OF auftragstyp.


DATA  null.                            " used for message ... into null

INCLUDE lcn2002f01.
