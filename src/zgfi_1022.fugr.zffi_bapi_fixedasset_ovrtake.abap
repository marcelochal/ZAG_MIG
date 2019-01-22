FUNCTION ZFFI_BAPI_FIXEDASSET_OVRTAKE.
*"----------------------------------------------------------------------
*"*"Interface local:
*"  IMPORTING
*"     VALUE(KEY) LIKE  BAPI1022_KEY STRUCTURE  BAPI1022_KEY
*"     VALUE(REFERENCE) LIKE  BAPI1022_REFERENCE STRUCTURE
*"        BAPI1022_REFERENCE OPTIONAL
*"     VALUE(CREATESUBNUMBER) LIKE  BAPI1022_MISC-XSUBNO OPTIONAL
*"     VALUE(CREATEGROUPASSET) LIKE  BAPI1022_MISC-XANLGR OPTIONAL
*"     VALUE(TESTRUN) LIKE  BAPI1022_MISC-TESTRUN DEFAULT SPACE
*"     VALUE(GENERALDATA) LIKE  BAPI1022_FEGLG001 STRUCTURE
*"        BAPI1022_FEGLG001 OPTIONAL
*"     VALUE(GENERALDATAX) LIKE  BAPI1022_FEGLG001X STRUCTURE
*"        BAPI1022_FEGLG001X OPTIONAL
*"     VALUE(INVENTORY) LIKE  BAPI1022_FEGLG011 STRUCTURE
*"        BAPI1022_FEGLG011 OPTIONAL
*"     VALUE(INVENTORYX) LIKE  BAPI1022_FEGLG011X STRUCTURE
*"        BAPI1022_FEGLG011X OPTIONAL
*"     VALUE(POSTINGINFORMATION) LIKE  BAPI1022_FEGLG002 STRUCTURE
*"        BAPI1022_FEGLG002 OPTIONAL
*"     VALUE(POSTINGINFORMATIONX) LIKE  BAPI1022_FEGLG002X STRUCTURE
*"        BAPI1022_FEGLG002X OPTIONAL
*"     VALUE(TIMEDEPENDENTDATA) LIKE  BAPI1022_FEGLG003 STRUCTURE
*"        BAPI1022_FEGLG003 OPTIONAL
*"     VALUE(TIMEDEPENDENTDATAX) LIKE  BAPI1022_FEGLG003X STRUCTURE
*"        BAPI1022_FEGLG003X OPTIONAL
*"     VALUE(ALLOCATIONS) LIKE  BAPI1022_FEGLG004 STRUCTURE
*"        BAPI1022_FEGLG004 OPTIONAL
*"     VALUE(ALLOCATIONSX) LIKE  BAPI1022_FEGLG004X STRUCTURE
*"        BAPI1022_FEGLG004X OPTIONAL
*"     VALUE(ORIGIN) LIKE  BAPI1022_FEGLG009 STRUCTURE
*"        BAPI1022_FEGLG009 OPTIONAL
*"     VALUE(ORIGINX) LIKE  BAPI1022_FEGLG009X STRUCTURE
*"        BAPI1022_FEGLG009X OPTIONAL
*"     VALUE(INVESTACCTASSIGNMNT) LIKE  BAPI1022_FEGLG010 STRUCTURE
*"        BAPI1022_FEGLG010 OPTIONAL
*"     VALUE(INVESTACCTASSIGNMNTX) LIKE  BAPI1022_FEGLG010X STRUCTURE
*"        BAPI1022_FEGLG010X OPTIONAL
*"     VALUE(NETWORTHVALUATION) LIKE  BAPI1022_FEGLG006 STRUCTURE
*"        BAPI1022_FEGLG006 OPTIONAL
*"     VALUE(NETWORTHVALUATIONX) LIKE  BAPI1022_FEGLG006X STRUCTURE
*"        BAPI1022_FEGLG006X OPTIONAL
*"     VALUE(REALESTATE) LIKE  BAPI1022_FEGLG007 STRUCTURE
*"        BAPI1022_FEGLG007 OPTIONAL
*"     VALUE(REALESTATEX) LIKE  BAPI1022_FEGLG007X STRUCTURE
*"        BAPI1022_FEGLG007X OPTIONAL
*"     VALUE(INSURANCE) LIKE  BAPI1022_FEGLG008 STRUCTURE
*"        BAPI1022_FEGLG008 OPTIONAL
*"     VALUE(INSURANCEX) LIKE  BAPI1022_FEGLG008X STRUCTURE
*"        BAPI1022_FEGLG008X OPTIONAL
*"     VALUE(LEASING) LIKE  BAPI1022_FEGLG005 STRUCTURE
*"        BAPI1022_FEGLG005 OPTIONAL
*"     VALUE(LEASINGX) LIKE  BAPI1022_FEGLG005X STRUCTURE
*"        BAPI1022_FEGLG005X OPTIONAL
*"     VALUE(GLO_RUS_GEN) LIKE  BAPI1022_GLO_RUS_GEN STRUCTURE
*"        BAPI1022_GLO_RUS_GEN OPTIONAL
*"     VALUE(GLO_RUS_GENX) LIKE  BAPI1022_GLO_RUS_GENX STRUCTURE
*"        BAPI1022_GLO_RUS_GENX OPTIONAL
*"     VALUE(GLO_RUS_PTX) LIKE  BAPI1022_GLO_RUS_PTX STRUCTURE
*"        BAPI1022_GLO_RUS_PTX OPTIONAL
*"     VALUE(GLO_RUS_PTXX) LIKE  BAPI1022_GLO_RUS_PTXX STRUCTURE
*"        BAPI1022_GLO_RUS_PTXX OPTIONAL
*"     VALUE(GLO_RUS_TTX) LIKE  BAPI1022_GLO_RUS_TTX STRUCTURE
*"        BAPI1022_GLO_RUS_TTX OPTIONAL
*"     VALUE(GLO_RUS_TTXX) LIKE  BAPI1022_GLO_RUS_TTXX STRUCTURE
*"        BAPI1022_GLO_RUS_TTXX OPTIONAL
*"     VALUE(GLO_IN_GEN) LIKE  BAPI1022_GLO_IN_GEN STRUCTURE
*"        BAPI1022_GLO_IN_GEN OPTIONAL
*"     VALUE(GLO_IN_GENX) LIKE  BAPI1022_GLO_IN_GENX STRUCTURE
*"        BAPI1022_GLO_IN_GENX OPTIONAL
*"     VALUE(GLO_JP_ANN16) LIKE  BAPI1022_GLO_JP_ANN16 STRUCTURE
*"        BAPI1022_GLO_JP_ANN16 OPTIONAL
*"     VALUE(GLO_JP_ANN16X) LIKE  BAPI1022_GLO_JP_ANN16X STRUCTURE
*"        BAPI1022_GLO_JP_ANN16X OPTIONAL
*"     VALUE(GLO_JP_PTX) LIKE  BAPI1022_GLO_JP_PTX STRUCTURE
*"        BAPI1022_GLO_JP_PTX OPTIONAL
*"     VALUE(GLO_JP_PTXX) LIKE  BAPI1022_GLO_JP_PTXX STRUCTURE
*"        BAPI1022_GLO_JP_PTXX OPTIONAL
*"     VALUE(GLO_TIME_DEP) LIKE  BAPI1022_GLO_TIME_DEP STRUCTURE
*"        BAPI1022_GLO_TIME_DEP OPTIONAL
*"     VALUE(GLO_RUS_GENTD) LIKE  BAPI1022_GLO_RUS_GENTD STRUCTURE
*"        BAPI1022_GLO_RUS_GENTD OPTIONAL
*"     VALUE(GLO_RUS_GENTDX) LIKE  BAPI1022_GLO_RUS_GENTDX STRUCTURE
*"        BAPI1022_GLO_RUS_GENTDX OPTIONAL
*"     VALUE(GLO_RUS_PTXTD) LIKE  BAPI1022_GLO_RUS_PTXTD STRUCTURE
*"        BAPI1022_GLO_RUS_PTXTD OPTIONAL
*"     VALUE(GLO_RUS_PTXTDX) LIKE  BAPI1022_GLO_RUS_PTXTDX STRUCTURE
*"        BAPI1022_GLO_RUS_PTXTDX OPTIONAL
*"     VALUE(GLO_RUS_TTXTD) LIKE  BAPI1022_GLO_RUS_TTXTD STRUCTURE
*"        BAPI1022_GLO_RUS_TTXTD OPTIONAL
*"     VALUE(GLO_RUS_TTXTDX) LIKE  BAPI1022_GLO_RUS_TTXTDX STRUCTURE
*"        BAPI1022_GLO_RUS_TTXTDX OPTIONAL
*"     VALUE(GLO_JP_IMPTD) LIKE  BAPI1022_GLO_JP_IMPTD STRUCTURE
*"        BAPI1022_GLO_JP_IMPTD OPTIONAL
*"     VALUE(GLO_JP_IMPTDX) LIKE  BAPI1022_GLO_JP_IMPTDX STRUCTURE
*"        BAPI1022_GLO_JP_IMPTDX OPTIONAL
*"  EXPORTING
*"     VALUE(COMPANYCODE) LIKE  BAPI1022_1-COMP_CODE
*"     VALUE(ASSET) LIKE  BAPI1022_1-ASSETMAINO
*"     VALUE(SUBNUMBER) LIKE  BAPI1022_1-ASSETSUBNO
*"     VALUE(ASSETCREATED) LIKE  BAPI1022_REFERENCE STRUCTURE
*"        BAPI1022_REFERENCE
*"  TABLES
*"      DEPRECIATIONAREAS STRUCTURE  BAPI1022_DEP_AREAS OPTIONAL
*"      DEPRECIATIONAREASX STRUCTURE  BAPI1022_DEP_AREASX OPTIONAL
*"      INVESTMENT_SUPPORT STRUCTURE  BAPI1022_INV_SUPPORT OPTIONAL
*"      BAPI_TE_ANLU STRUCTURE  BAPI_TE_ANLU OPTIONAL
*"      CUMULATEDVALUES STRUCTURE  BAPI1022_CUMVAL OPTIONAL
*"      POSTEDVALUES STRUCTURE  BAPI1022_POSTVAL OPTIONAL
*"      TRANSACTIONS STRUCTURE  BAPI1022_TRTYPE OPTIONAL
*"      PROPORTIONALVALUES STRUCTURE  BAPI1022_PROPVAL OPTIONAL
*"      RETURN STRUCTURE  BAPIRET2 OPTIONAL
*"      POSTINGHEADERS STRUCTURE  BAPI1022_POSTINGHEADER OPTIONAL
*"----------------------------------------------------------------------

  DATA: ti_extensionin        TYPE TABLE OF bapiparex,
        e_extensionin         TYPE bapiparex,
        e_bapi_te_anlu        TYPE bapi_te_anlu,
        lc_valuepart          TYPE valuepart,
        ls_depreciationareasx TYPE bapi1022_dep_areasx.

  "Montar parâmetro EXENSIONIN
  MOVE 'BAPI_TE_ANLU' TO e_extensionin-structure.

  LOOP AT bapi_te_anlu INTO e_bapi_te_anlu.

    CALL METHOD cl_abap_container_utilities=>fill_container_c
      EXPORTING
        im_value               = e_bapi_te_anlu
      IMPORTING
        ex_container           = lc_valuepart
      EXCEPTIONS
        illegal_parameter_type = 1
        OTHERS                 = 2.

    MOVE lc_valuepart TO e_extensionin-valuepart1.
*There is no need to include the mandt
*    CONCATENATE sy-mandt e_extensionin-valuepart1 INTO e_extensionin-valuepart1.

    APPEND e_extensionin TO ti_extensionin.

  ENDLOOP.

  PERFORM f_handle_cost_center USING timedependentdata key-companycode .


  PERFORM f_compare_data: USING generaldata         CHANGING generaldatax,
                          USING inventory           CHANGING inventoryx,
                          USING postinginformation  CHANGING postinginformationx,
                          USING timedependentdata   CHANGING timedependentdatax.

  CLEAR depreciationareasx[].

  LOOP AT depreciationareas ASSIGNING FIELD-SYMBOL(<fs_depreciationareas>).
    CLEAR ls_depreciationareasx.
    PERFORM f_compare_data USING    <fs_depreciationareas>
                           CHANGING ls_depreciationareasx.

    MOVE <fs_depreciationareas>-area TO ls_depreciationareasx-area.

    APPEND ls_depreciationareasx TO depreciationareasx.
  ENDLOOP.

  CALL FUNCTION 'BAPI_FIXEDASSET_OVRTAKE_CREATE'
    EXPORTING
      key                  = key
      reference            = reference
      createsubnumber      = createsubnumber
      creategroupasset     = creategroupasset
      testrun              = testrun
      generaldata          = generaldata
      generaldatax         = generaldatax
      inventory            = inventory
      inventoryx           = inventoryx
      postinginformation   = postinginformation
      postinginformationx  = postinginformationx
      timedependentdata    = timedependentdata
      timedependentdatax   = timedependentdatax
      allocations          = allocations
      allocationsx         = allocationsx
      origin               = origin
      originx              = originx
      investacctassignmnt  = investacctassignmnt
      investacctassignmntx = investacctassignmntx
      networthvaluation    = networthvaluation
      networthvaluationx   = networthvaluationx
      realestate           = realestate
      realestatex          = realestatex
      insurance            = insurance
      insurancex           = insurancex
      leasing              = leasing
      leasingx             = leasingx
      glo_rus_gen          = glo_rus_gen
      glo_rus_genx         = glo_rus_genx
      glo_rus_ptx          = glo_rus_ptx
      glo_rus_ptxx         = glo_rus_ptxx
      glo_rus_ttx          = glo_rus_ttx
      glo_rus_ttxx         = glo_rus_ttxx
      glo_in_gen           = glo_in_gen
      glo_in_genx          = glo_in_genx
      glo_jp_ann16         = glo_jp_ann16
      glo_jp_ann16x        = glo_jp_ann16x
      glo_jp_ptx           = glo_jp_ptx
      glo_jp_ptxx          = glo_jp_ptxx
      glo_time_dep         = glo_time_dep
      glo_rus_gentd        = glo_rus_gentd
      glo_rus_gentdx       = glo_rus_gentdx
      glo_rus_ptxtd        = glo_rus_ptxtd
      glo_rus_ptxtdx       = glo_rus_ptxtdx
      glo_rus_ttxtd        = glo_rus_ttxtd
      glo_rus_ttxtdx       = glo_rus_ttxtdx
      glo_jp_imptd         = glo_jp_imptd
      glo_jp_imptdx        = glo_jp_imptdx
    IMPORTING
      companycode          = companycode
      asset                = asset
      subnumber            = subnumber
      assetcreated         = assetcreated
    TABLES
      depreciationareas    = depreciationareas
      depreciationareasx   = depreciationareasx
      investment_support   = investment_support
      extensionin          = ti_extensionin
      cumulatedvalues      = cumulatedvalues
      postedvalues         = postedvalues
      transactions         = transactions
      proportionalvalues   = proportionalvalues
      return               = return
      postingheaders       = postingheaders.


ENDFUNCTION.
