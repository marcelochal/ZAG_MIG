FUNCTION zcn2002_znetwork_zcreate.
*"----------------------------------------------------------------------
*"*"Interface local:
*"  IMPORTING
*"     VALUE(I_NEW_NETWORK) LIKE  ZEPS_BAPI_BUS2002_NEW STRUCTURE
*"        ZEPS_BAPI_BUS2002_NEW
*"  EXPORTING
*"     VALUE(E_NPLNR) LIKE  BAPI_BUS2002_NEW-NETWORK
*"  TABLES
*"      EXTENSIONIN STRUCTURE  BAPIPAREX OPTIONAL
*"  EXCEPTIONS
*"      NETWORK_NOT_CREATED
*"----------------------------------------------------------------------

  DATA: ls_caufvd       LIKE caufvd,
        ls_afvgd        LIKE afvgd,
        ls_bapi_te_netw LIKE bapi_te_network,
        i_network       TYPE bapi_bus2002_new.

  FIELD-SYMBOLS: <func_area> TYPE any.

  MOVE-CORRESPONDING i_new_network TO i_network.

* Functional area is available for networks only as of release 4.6C
  IF NOT i_network-func_area IS INITIAL.
*   Field FUNC_AREA does not exist in AFVC (thus, structure AFVGD) in
*   release 4.6B
    ASSIGN COMPONENT con_func_area
           OF STRUCTURE ls_afvgd
           TO <func_area>.
    IF NOT sy-subrc IS INITIAL.
*     Assign failed: clear field and store info as I-message
      MESSAGE i082(cnif_pi) WITH TEXT-fua sy-saprl INTO null.
      PERFORM put_sy_message(saplco2o).
      CLEAR i_network-func_area.
    ENDIF.
  ENDIF.

* Convert BAPI input values to upper case and/or ALPHA
  CALL FUNCTION 'PS_BAPI_SET_UPPER_AND_ALPHA'
    EXPORTING
      i_structure_name = con_struc_net_new
    CHANGING
      c_structure      = i_network
    EXCEPTIONS
      invalid_date     = 1.
  IF NOT sy-subrc IS INITIAL.
    MESSAGE e080(cnif_pi) INTO null.
    PERFORM put_sy_message(saplco2o).
    RAISE network_not_created.
  ENDIF.

* Map external data to internal structure
  CALL FUNCTION 'ZMAP2I_ZBUS2002_NEW_TO_CAUFVD'
    EXPORTING
      bapi_bus2002_new      = i_new_network
    CHANGING
      caufvd                = ls_caufvd
    EXCEPTIONS
      error_converting_keys = 1.
  IF NOT sy-subrc IS INITIAL.
    RAISE network_not_created.
  ENDIF.

* move extension with standard customer include CI_AUFK to ls_caufvd
  LOOP AT extensionin WHERE structure = 'BAPI_TE_NETWORK'
          AND valuepart1(12) = i_network-network.
*   move extension into structure containing components of CI_AUFK
    CALL METHOD cl_abap_container_utilities=>read_container_c
      EXPORTING
        im_container           = extensionin+30
      IMPORTING
        ex_value               = ls_bapi_te_netw
      EXCEPTIONS
        illegal_parameter_type = 1
        OTHERS                 = 2.


*    MOVE extensionin+30 TO ls_bapi_te_netw.                  "#EC ENHOK
*   move into corresponding fields of CAUFVD
    CATCH SYSTEM-EXCEPTIONS conversion_errors = 1.
      MOVE-CORRESPONDING ls_bapi_te_netw TO ls_caufvd.      "#EC ENHOK
    ENDCATCH.
    IF NOT sy-subrc IS INITIAL.
      MESSAGE e061(cnif_pi) WITH 'CI_AUFK' i_network-network INTO null.
*     error when transferring ExtensionIn to &1 (&2)
      PERFORM put_sy_message(saplco2o).
      RAISE network_not_created.
    ENDIF.
  ENDLOOP.

* External project definition name was interfaced but no corresponding
* internal number was detected: project definition does not exist
  IF NOT i_network-project_definition IS INITIAL AND
         ls_caufvd-pronr              IS INITIAL.
    MESSAGE e011(cj) WITH i_network-project_definition INTO null.
    PERFORM put_sy_message(saplco2o).
    RAISE network_not_created.
  ENDIF.
* External WBS element name was interfaced but no corresponding
* internal number was detected: WBS element does not exist
  IF NOT i_network-wbs_element IS INITIAL AND
         ls_caufvd-projn       IS INITIAL.
    MESSAGE e021(cj) WITH i_network-wbs_element INTO null.
    PERFORM put_sy_message(saplco2o).
    RAISE network_not_created.
  ENDIF.

* Prepare creation (netw profile, netw type, plant, params of netw
* type, MRP controller, if external numbering: network number,
* existence, enqueuing etc.)
  CALL FUNCTION 'CN2002_NET_CREATE_PREPARE'
    EXPORTING
      i_caufvd                = ls_caufvd
    IMPORTING
      e_caufvd                = ls_caufvd
    EXCEPTIONS
      no_network_profile      = 1
      no_network_type         = 2
      no_network_parameters   = 3
      no_plant                = 4
      no_mrp_controller       = 5
      no_external_number      = 6
      external_number         = 7
      network_exists          = 8
      network_enqueued        = 9
      enqueue_error           = 10
      no_general_network_data = 11.

  IF NOT sy-subrc IS INITIAL.
*   Messages already stored in msg handler -> just raise exception
    RAISE network_not_created.
  ENDIF.

* Check & register network header
  CALL FUNCTION 'CN2002_NET_CREATE_CHECK_ADD'
    EXPORTING
      i_caufvd            = ls_caufvd
    IMPORTING
      e_caufvd            = ls_caufvd
    EXCEPTIONS
      network_not_created = 1.
  IF NOT sy-subrc IS INITIAL.
*   Messages already stored in msg handler -> just raise exception
    RAISE network_not_created.
  ENDIF.

* Subnetwork can only be processed when the entry of the new network
* has already been created in the buffer tables
  IF NOT ls_caufvd-aufnt IS INITIAL OR
     NOT ls_caufvd-aplzt IS INITIAL.
    CALL FUNCTION 'CN2002_NW_SET_SUPERIOR_NETW'
      EXPORTING
        i_caufvd_new = ls_caufvd
        i_aufnt_new  = ls_caufvd-aufnt
        i_vornr_new  = i_network-superior_netw_act
        i_new_mode   = con_yes
        i_edit_mode  = space
      IMPORTING
        e_caufvd     = ls_caufvd
      EXCEPTIONS
        not_ok       = 1.
    IF NOT sy-subrc IS INITIAL.
*     Messages already stored in msg handler -> just raise exception
      RAISE network_not_created.
    ENDIF.
  ENDIF.

* Set network number
  e_nplnr = ls_caufvd-aufnr.

ENDFUNCTION.
