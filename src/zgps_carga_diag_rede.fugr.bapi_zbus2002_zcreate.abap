FUNCTION bapi_zbus2002_zcreate.
*"----------------------------------------------------------------------
*"*"Interface local:
*"  IMPORTING
*"     VALUE(I_NEW_NETWORK) LIKE  ZEPS_BAPI_BUS2002_NEW STRUCTURE
*"        ZEPS_BAPI_BUS2002_NEW
*"  TABLES
*"      ET_RETURN STRUCTURE  BAPIRET2
*"      EXTENSIONIN STRUCTURE  BAPIPAREX OPTIONAL
*"      EXTENSIONOUT STRUCTURE  BAPIPAREX OPTIONAL
*"----------------------------------------------------------------------

  DATA: lv_key               TYPE char24,
        lv_dialog_status_tmp TYPE flag,
        lv_msghand_num       LIKE sy-uzeit,
        lv_subrc             LIKE sy-subrc,
        lv_error             TYPE c,
        i_network            TYPE bapi_bus2002_new,
        ls_object            TYPE psguid_ts_guid_for_extern.

  MOVE-CORRESPONDING i_new_network TO i_network.

* Init BAPI
* Exception 'message_handler_error' is NOT caught by design to force a
* dump as we deal with a program error in this case
  CALL FUNCTION 'PS_BAPI_INITIALIZE'
    IMPORTING
      e_dialog_status = lv_dialog_status_tmp
      e_msghand_num   = lv_msghand_num
    TABLES
      return          = et_return.
* Prepare BAPI
  CALL FUNCTION 'PS_BAPI_PREPARE'
    EXPORTING
      i_number                 = i_network-network
      i_network_create         = i_network
      i_method                 = con_net_create
    IMPORTING
      e_number                 = i_network-network
    TABLES
      extensionin              = extensionin
      extensionout             = extensionout
    EXCEPTIONS
      precommit_already_called = 1
      init_missing             = 2
      one_project_violation    = 3
      badi_error               = 4.
  lv_subrc = sy-subrc.

  IF lv_subrc IS INITIAL.
    CALL FUNCTION 'ZCN2002_ZNETWORK_ZCREATE'
      EXPORTING
        i_new_network       = i_new_network
      IMPORTING
        e_nplnr             = i_network-network
      TABLES
        extensionin         = extensionin
      EXCEPTIONS
        network_not_created = 1.
    lv_subrc = sy-subrc.
  ELSE.
*   Prepare failed: convert network number
    CALL FUNCTION 'EXT_NETWORK_GET_INT_NETWORK'
      EXPORTING
        i_ext_network = i_network-network
      IMPORTING
        e_int_network = i_network-network
      EXCEPTIONS
        error_occured = 0.
  ENDIF.

  IF NOT lv_subrc IS INITIAL.
*   Error in prepare or whilst creation
    lv_error = con_yes.
*   external numbering: dequeue number
    IF NOT i_network-network    IS INITIAL AND
       NOT i_network-network(1) EQ con_%.
      CALL FUNCTION 'DEQUEUE_ESORDER'
        EXPORTING
          aufnr = i_network-network.
    ENDIF.
    MESSAGE e007(cnif_pi) WITH TEXT-net i_network-network
                          INTO null.
    CALL FUNCTION 'PS_FLAG_SET_GLOBAL_FLAGS'
      EXPORTING
        i_error = con_yes.
  ELSE.
*   Create successful
    CLEAR lv_error.
    MESSAGE s004(cnif_pi) WITH TEXT-net i_network-network
                          INTO null.
    CALL FUNCTION 'PS_FLAG_SET_GLOBAL_FLAGS'
      EXPORTING
        i_network_data = con_yes.
*   Register object in success buffer table
    CLEAR ls_object.
    ls_object-object_type = con_objtype_network.
    ls_object-network     = i_network-network.
    ls_object-vbkz        = con_net_create.
    CALL FUNCTION 'PS_BAPI_SUCCESS_BT_APPEND'
      EXPORTING
        i_object         = ls_object
      EXCEPTIONS
        wrong_parameters = 0.
  ENDIF.

* Get last message of current activity ('S' vs. 'E') as first one in
* the log (only 'message ... into null' NOT followed by 'perform
* put_sy_message(saplco2o)')
  CALL FUNCTION 'PS_BAPI_MESSAGE_APPEND'
    TABLES
      return = et_return.

* Get remaining messages of current method (stored by 'message ...
* into null' AND 'perform put_sy_message(saplco2o)')
  WRITE i_network-network TO lv_key.
  CALL FUNCTION 'PS_BAPI_APPL_MESSAGE_APP_EXT'
    EXPORTING
      i_objectkey   = lv_key
      i_msghand_num = lv_msghand_num
      i_error_case  = lv_error
    TABLES
      et_return     = et_return.

* Finish BAPI - call late badi, reset dialog flags
  CALL FUNCTION 'PS_BAPI_FINISH'
    EXPORTING
      i_network_create = i_network
      i_dialog_status  = lv_dialog_status_tmp
      i_msghand_num    = lv_msghand_num
      i_number         = i_network-network
      i_method         = con_net_create
      i_subrc          = lv_subrc
    TABLES
      return           = et_return
      extensionin      = extensionin
      extensionout     = extensionout.

ENDFUNCTION.
