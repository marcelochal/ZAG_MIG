*----------------------------------------------------------------------*
***INCLUDE LZGFI_1022F01.
*----------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*& Form AJUSTA_VALORES
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM ajusta_valores TABLES p_ti_imobilizado TYPE ztfi_imobilizado.

  FIELD-SYMBOLS: <dado> TYPE zefi_imobilizado.

  DATA: lv_menge TYPE anla-menge,
        lv_meins TYPE anla-meins.

*-----------------------------------------------------------------*
*-----------------------------------------------------------------*
  LOOP AT p_ti_imobilizado ASSIGNING <dado>.

**> Rotina de conversão para preencher de 0 , campo ANLN1
    PERFORM f_conversion_alpha CHANGING <dado>-anln1.

**> Rotina de conversão para preencher de 0 , campo ANLN2
    PERFORM f_conversion_alpha CHANGING <dado>-anln2.

**> Rotina de conversão para preencher de 0 , campo GERNR
    PERFORM f_conversion_gernr CHANGING <dado>-sernr.

**> Rotina de conversão para preencher de 0 , campo ANLKL
    PERFORM f_conversion_alpha CHANGING <dado>-anlkl.

**> Rotina de conversão para preencher de 0 , campo KOSTL
    PERFORM f_conversion_alpha CHANGING <dado>-kostl.

**> Rotina de conversão para preencher de 0 , campo ZMATNR
    PERFORM f_conversion_matn1 CHANGING <dado>-zmatnr.

    PERFORM f_conversion_meins USING <dado>-meins CHANGING <dado>-aux_meins.

**> Rotina de conversão para preencher de 0 , campo ZFC
    PERFORM f_conversion_alpha CHANGING <dado>-zfc.

**> Rotina de conversão para preencher de 0
    PERFORM f_conversion_tuc:
         USING '3' CHANGING <dado>-ztuc,
         USING '2' CHANGING <dado>-zatra1,
         USING '2' CHANGING <dado>-zatra2,
         USING '2' CHANGING <dado>-zatra3,
         USING '2' CHANGING <dado>-zatra4,
         USING '2' CHANGING <dado>-zatra5,
         USING '2' CHANGING <dado>-zatra6.

**> Converte campo para letra MAISCULA
    TRANSLATE:
          <dado>-bukrs TO UPPER CASE,
          <dado>-invnr TO UPPER CASE,
          <dado>-gsber TO UPPER CASE,
          <dado>-werks TO UPPER CASE,
          <dado>-stort TO UPPER CASE,
          <dado>-anlkl TO UPPER CASE,
          <dado>-zcontrato TO UPPER CASE,
          <dado>-zodi  TO UPPER CASE,
          <dado>-zti   TO UPPER CASE,
          <dado>-zcm   TO UPPER CASE,
          <dado>-ztuc  TO UPPER CASE,
          <dado>-zatra1    TO UPPER CASE,
          <dado>-zatra2    TO UPPER CASE,
          <dado>-zatra3    TO UPPER CASE,
          <dado>-zatra4    TO UPPER CASE,
          <dado>-zatra5    TO UPPER CASE,
          <dado>-zatra6    TO UPPER CASE,
          <dado>-zuar      TO UPPER CASE,
          <dado>-zfc       TO UPPER CASE.
  ENDLOOP.

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  F_CONVERSION_ALPHA
*&---------------------------------------------------------------------*
*       Conversão para campos com EXIT de Conversão ALPHA
*----------------------------------------------------------------------*
FORM f_conversion_alpha  CHANGING pe_change_alpha.

  CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
    EXPORTING
      input  = pe_change_alpha
    IMPORTING
      output = pe_change_alpha.

ENDFORM.                    " F_CONVERSION_ALPHA

*&---------------------------------------------------------------------*
*&      Form  F_CONVERSION_GERNR
*&---------------------------------------------------------------------*
*       Conversão para campos com EXIT de Conversão GERNR
*----------------------------------------------------------------------*
FORM f_conversion_gernr  CHANGING pe_change_gernr.

  CALL FUNCTION 'CONVERSION_EXIT_GERNR_INPUT'
    EXPORTING
      input  = pe_change_gernr
    IMPORTING
      output = pe_change_gernr.

ENDFORM.                    " F_CONVERSION_GERNR

*&---------------------------------------------------------------------*
*&      Form  SELECT_ANKA
*&---------------------------------------------------------------------*
FORM select_anka  USING    pt_dados TYPE ztfi_imobilizado
                  CHANGING pt_anka TYPE ty_anka.

  DATA lt_dados TYPE ztfi_imobilizado.

  lt_dados[] = pt_dados[].
  SORT lt_dados BY anlkl.
  DELETE ADJACENT DUPLICATES FROM lt_dados COMPARING anlkl.

  SELECT anlkl
  FROM anka
  INTO TABLE pt_anka
  FOR ALL ENTRIES IN lt_dados
  WHERE anlkl EQ lt_dados-anlkl.

ENDFORM.                    " SELECT_ANKA


*&---------------------------------------------------------------------*
*&      Form  VALIDA_ANLKL
*&---------------------------------------------------------------------*
FORM valida_anlkl  USING pt_anka TYPE ty_anka
                         p_index TYPE i
                         p_anlkl TYPE anka-anlkl.
  DATA l_txt TYPE char100.

  IF p_anlkl IS INITIAL.
    _add_log p_index 'ANLKL' 'LOG - Classe do Imobilizado preenchimento obrigatório'.
    EXIT.
  ENDIF.

  READ TABLE pt_anka TRANSPORTING NO FIELDS WITH KEY anlkl = p_anlkl BINARY SEARCH.
  CHECK sy-subrc <> 0.

  CONCATENATE 'LOG - Classe do Imobilizado não cadastrada: ' p_anlkl INTO l_txt.
  _add_log p_index 'ANLKL' l_txt.

ENDFORM.                    " VALIDA_ANLKL

*&---------------------------------------------------------------------*
*&      Form  SELECT_T001
*&---------------------------------------------------------------------*
FORM select_t001  USING    pt_dados TYPE ztfi_imobilizado
                  CHANGING pt_bukrs TYPE ty_bukrs.

  DATA lt_dados TYPE ztfi_imobilizado.

  lt_dados[] = pt_dados[].
  SORT lt_dados BY bukrs.
  DELETE ADJACENT DUPLICATES FROM lt_dados COMPARING bukrs.

  SELECT bukrs
  FROM t001
  INTO TABLE pt_bukrs
  FOR ALL ENTRIES IN lt_dados
  WHERE bukrs EQ lt_dados-bukrs.

ENDFORM.                    " SELECT_ANKA

*&---------------------------------------------------------------------*
*&      Form  VALIDA_BUKRS
*&---------------------------------------------------------------------*
FORM valida_bukrs  USING pt_t001 TYPE ty_bukrs
                         p_index TYPE i
                         p_bukrs TYPE t001-bukrs.
  DATA l_txt TYPE char100.

  IF p_bukrs IS INITIAL.
    _add_log p_index 'BUKRS' 'LOG - Empresa preenchimento obrigatório'.
    EXIT.
  ENDIF.

  READ TABLE pt_t001 TRANSPORTING NO FIELDS WITH KEY bukrs = p_bukrs BINARY SEARCH.
  CHECK sy-subrc <> 0.

  CONCATENATE 'LOG - Empresa não cadastrada: ' p_bukrs INTO l_txt.
  _add_log p_index 'BUKRS' l_txt.

ENDFORM.                    " VALIDA_BUKRS

*&---------------------------------------------------------------------*
*&      Form  SELECT_T001
*&---------------------------------------------------------------------*
FORM select_anla  USING    pt_dados TYPE ztfi_imobilizado
                  CHANGING pt_anla  TYPE ty_anla.
  DATA lt_dados TYPE ztfi_imobilizado.

  lt_dados[] = pt_dados[].
  SORT lt_dados BY anln1 anln2.
  DELETE ADJACENT DUPLICATES FROM lt_dados COMPARING anln1 anln2.

  SELECT anln1 anln2 aktiv
  FROM anla
  INTO TABLE pt_anla
  FOR ALL ENTRIES IN lt_dados
  WHERE anln1 EQ lt_dados-anln1
    AND anln2 EQ lt_dados-anln2
    AND deakt EQ space.

ENDFORM.                    " SELECT_ANKA

*&---------------------------------------------------------------------*
*&      Form  VALIDA_ANLA
*&---------------------------------------------------------------------*
FORM valida_anla  USING pt_anla  TYPE ty_anla
                        p_index  TYPE i
                        p_anln1  TYPE anla-anln1
                        p_anln2  TYPE anla-anln2.

  DATA l_txt TYPE char100.

*  IF p_anln1 IS INITIAL.
*    _add_log p_index 'ANLN1' 'LOG - Nr. Imobilizado preenchimento obrigatório'.
*  ENDIF.
*
*  IF p_anln2 IS INITIAL.
*    _add_log p_index 'ANLN2' 'LOG - Subnr. Imobilizado preenchimento obrigatório'.
*  ENDIF.
  CHECK NOT p_anln1 IS INITIAL OR NOT p_anln2 IS INITIAL.
  SORT pt_anla BY anln1 anln2.
  READ TABLE pt_anla TRANSPORTING NO FIELDS WITH KEY anln1 = p_anln1 anln2 = p_anln2 BINARY SEARCH.
  IF sy-subrc <> 0.
    SORT pt_anla BY anln1.
    READ TABLE pt_anla TRANSPORTING NO FIELDS WITH KEY anln1 = p_anln1 BINARY SEARCH.
    IF sy-subrc <> 0.
      CONCATENATE 'LOG - Nº Imobilizado não cadastrado: ' p_anln1 INTO l_txt.
      _add_log p_index 'ANLN1' l_txt.
    ENDIF.
    CONCATENATE 'LOG - Subnr. de Inventário não cadastrado: ' p_anln2 INTO l_txt.
    _add_log p_index 'ANLN2' l_txt.
  ENDIF.
ENDFORM.                    " VALIDA_ANLA

*&---------------------------------------------------------------------*
*&      Form  VALIDA_TXT50
*&---------------------------------------------------------------------*
FORM valida_txt50  USING p_index  TYPE i
                         p_txt50 TYPE anla-txt50.
  CHECK p_txt50 IS INITIAL.
  _add_log p_index 'TXT50' 'LOG - Denominação preenchimento obrigatório'.
ENDFORM.                    " VALIDA_TXT50

*&---------------------------------------------------------------------*
*&      Form  VALIDA_TXA50
*&---------------------------------------------------------------------*
FORM valida_txa50  USING p_index  TYPE i
                         p_txa50 TYPE anla-txa50.
*  CHECK p_txa50 IS INITIAL.
*  _add_log p_index 'TXA50' 'LOG - Denominação preenchimento obrigatório'.
ENDFORM.                    " VALIDA_TXA50

*&---------------------------------------------------------------------*
*&      Form  VALIDA_INVNR
*&---------------------------------------------------------------------*
FORM valida_invnr  USING    p_index TYPE i
                            p_zfc   TYPE anlu-zfc
                            p_invnr TYPE anla-invnr.
  CHECK p_zfc = '01' AND p_invnr IS INITIAL.
  _add_log p_index 'INVNR' 'LOG - Inventário preenchimento obrigatório'.
ENDFORM.                    " VALIDA_INVNR

*&---------------------------------------------------------------------*
*&      Form  VALIDA_AKTIV
*&---------------------------------------------------------------------*
FORM valida_aktiv  USING    p_index TYPE i
                            p_aktiv TYPE any.
  CHECK p_aktiv IS INITIAL.
  _add_log p_index 'AKTIV' 'LOG - Denominação data de incorporação obrigatório'.
ENDFORM.                    " VALIDA_AKTIV

*&---------------------------------------------------------------------*
*&      Form  SELECT_CSKS
*&---------------------------------------------------------------------*
FORM select_csks  USING    pt_dados TYPE ztfi_imobilizado
                  CHANGING pt_csks TYPE ty_csks.

  DATA lt_dados TYPE ztfi_imobilizado.

  lt_dados[] = pt_dados[].
  SORT lt_dados BY kostl.
  DELETE ADJACENT DUPLICATES FROM lt_dados COMPARING kostl.

  SELECT kostl
    FROM csks
    INTO TABLE pt_csks
    FOR ALL ENTRIES IN lt_dados
    WHERE kokrs EQ 'TB00'
      AND kostl EQ lt_dados-kostl
      AND datbi GT sy-datum.

ENDFORM.                    " SELECT_CSKS

*&---------------------------------------------------------------------*
*&      Form  VALIDA_KOSTL
*&---------------------------------------------------------------------*
FORM valida_kostl  USING pt_csks TYPE ty_csks
                         p_index TYPE i
                         p_kostl TYPE csks-kostl.
  DATA l_txt TYPE char100.

  IF p_kostl IS INITIAL.
    _add_log p_index 'KOSTL' 'LOG - Centro de Custo preenchimento obrigatório'.
    EXIT.
  ENDIF.

  READ TABLE pt_csks TRANSPORTING NO FIELDS WITH KEY kostl = p_kostl BINARY SEARCH.
  CHECK sy-subrc <> 0.

  CONCATENATE 'LOG - Centro de Custo não cadastrado: ' p_kostl INTO l_txt.
  _add_log p_index 'KOSTL' l_txt.
ENDFORM.                    " VALIDA_KOSTL

*&---------------------------------------------------------------------*
*&      Form  SELECT_T001W
*&---------------------------------------------------------------------*
FORM select_t001w  USING    pt_dados TYPE ztfi_imobilizado
                  CHANGING pt_t001w  TYPE ty_t001w.
  DATA lt_dados TYPE ztfi_imobilizado.

  lt_dados[] = pt_dados[].
  SORT lt_dados BY werks.
  DELETE ADJACENT DUPLICATES FROM lt_dados COMPARING werks.

  SELECT werks
  FROM t001w
  INTO TABLE pt_t001w
  FOR ALL ENTRIES IN lt_dados
  WHERE werks EQ lt_dados-werks.

ENDFORM.                    " SELECT_T001W

*&---------------------------------------------------------------------*
*&      Form  VALIDA_WERKS
*&---------------------------------------------------------------------*
FORM valida_werks  USING pt_t001w TYPE ty_t001w
                         p_index TYPE i
                         p_werks TYPE t001w-werks.
  DATA l_txt TYPE char100.

  IF p_werks IS INITIAL.
    _add_log p_index 'WERKS' 'LOG - Centro preenchimento obrigatório'.
    EXIT.
  ENDIF.

  READ TABLE pt_t001w TRANSPORTING NO FIELDS WITH KEY werks = p_werks BINARY SEARCH.
  CHECK sy-subrc <> 0.

  CONCATENATE 'LOG - Centro não cadastrado: ' p_werks INTO l_txt.
  _add_log p_index 'WERKS' l_txt.
ENDFORM.                    " VALIDA_WERKS

*&---------------------------------------------------------------------*
*&      Form  SELECT_T499S
*&---------------------------------------------------------------------*
FORM select_t499s  USING    pt_dados TYPE ztfi_imobilizado
                   CHANGING pt_t499s TYPE ty_t499s.
  DATA lt_dados TYPE ztfi_imobilizado.

  lt_dados[] = pt_dados[].
  SORT lt_dados BY werks stort.
  DELETE ADJACENT DUPLICATES FROM lt_dados COMPARING werks stort.

  SELECT werks stand
    FROM t499s
    INTO TABLE pt_t499s
    FOR ALL ENTRIES IN lt_dados
    WHERE werks EQ lt_dados-werks
      AND stand EQ lt_dados-stort.

ENDFORM.                    " SELECT_T499S

*&---------------------------------------------------------------------*
*&      Form  VALIDA_STORT
*&---------------------------------------------------------------------*
FORM valida_stort  USING    pt_t499s TYPE ty_t499s
                            p_index TYPE i
                            p_werks TYPE t001w-werks
                            p_stort TYPE t499s-stand.
  DATA l_txt TYPE char100.

  IF p_stort IS INITIAL.
    _add_log p_index 'STORT' 'LOG - Localização preenchimento obrigatório'.
    EXIT.
  ENDIF.

  READ TABLE pt_t499s TRANSPORTING NO FIELDS WITH KEY werks = p_werks
                                                      stand = p_stort BINARY SEARCH.
  CHECK sy-subrc <> 0.

  CONCATENATE 'LOG - Combinação Centro - Localização não cadastrada: ' p_stort INTO l_txt.
  _add_log p_index 'STORT' l_txt.
ENDFORM.                    " VALIDA_STORT


*&---------------------------------------------------------------------*
*&      Form  VALIDA_NDJAR
*&---------------------------------------------------------------------*
FORM valida_ndjar  USING    p_index  TYPE i
                            p_val TYPE anlb-ndjar
                            p_anlkl TYPE anka-anlkl.

  DATA: ls_ankb TYPE ankb.

  SELECT SINGLE *
  FROM ankb
  INTO ls_ankb
  WHERE anlkl EQ p_anlkl
    AND afabe EQ '01'
    AND afasl <> '0000'.
  IF sy-subrc = 0 AND p_val = ''.
    _add_log p_index 'NDJAR' 'LOG - Vida útil - anos preenchimento obrigatório'.
    EXIT.
  ENDIF.

ENDFORM.                    " VALIDA_NDJAR

*&---------------------------------------------------------------------*
*&      Form  VALIDA_NDPER
*&---------------------------------------------------------------------*
FORM valida_ndper  USING    p_index  TYPE i
                            p_val TYPE anlb-ndper.

  IF p_val = ''.
    _add_log p_index 'NDPER' 'LOG - Vida útil - períodos preenchimento obrigatório'.
    EXIT.
  ENDIF.

ENDFORM.                    " VALIDA_NDPER

*&---------------------------------------------------------------------*
*&      Form  VALIDA_AFABG
*&---------------------------------------------------------------------*
FORM valida_afabg  USING    p_index  TYPE i
                            p_val TYPE anlb-afabg.

  IF p_val IS INITIAL.
    _add_log p_index 'AFABG' 'LOG - Data início depreciação preenchimento obrigatório'.
    EXIT.
  ENDIF.

ENDFORM.                    " VALIDA_AFABG

*&---------------------------------------------------------------------*
*&      Form  VALIDA_MENGE
*&---------------------------------------------------------------------*
FORM valida_menge  USING    p_index  TYPE i
                            p_val TYPE char5.

  IF p_val IS INITIAL.
    _add_log p_index 'MENGE' 'LOG - Quantidade preenchimento obrigatório'.
    EXIT.
  ENDIF.

ENDFORM.                    " VALIDA_MENGE

*&---------------------------------------------------------------------*
*&      Form  SELECT_T006
*&---------------------------------------------------------------------*
FORM select_t006  USING    pt_dados TYPE ztfi_imobilizado
                  CHANGING pt_t006  TYPE ty_t006.

  DATA lt_dados TYPE ztfi_imobilizado.

  lt_dados[] = pt_dados[].
  SORT lt_dados BY aux_meins.
  DELETE ADJACENT DUPLICATES FROM lt_dados COMPARING aux_meins.

  SELECT msehi
    FROM t006
    INTO TABLE pt_t006
    FOR ALL ENTRIES IN lt_dados
    WHERE msehi EQ lt_dados-aux_meins.

ENDFORM.                    " SELECT_T006

*&---------------------------------------------------------------------*
*&      Form  VALIDA_MEINS
*&---------------------------------------------------------------------*
FORM valida_meins  USING    pt_data  TYPE ty_t006
                            p_index  TYPE i
                            p_meins    TYPE any
                            p_aux    TYPE any.
  DATA l_txt TYPE char100.

  IF p_meins IS INITIAL.
    _add_log p_index 'MEINS' 'LOG - Unidade de medida preenchimento obrigatório'.
    EXIT.
  ENDIF.

  READ TABLE pt_data
  WITH KEY msehi = p_aux BINARY SEARCH INTO gv_msehi.
  READ TABLE pt_data TRANSPORTING NO FIELDS WITH KEY msehi = p_aux BINARY SEARCH.
  CHECK sy-subrc <> 0.

  CONCATENATE 'LOG - Unidade de medida não cadastrada: ' p_meins INTO l_txt.
  _add_log p_index 'MEINS' l_txt.
ENDFORM.                    " VALIDA_MEINS

*&---------------------------------------------------------------------*
*&      Form  SELECT_TGSB
*&---------------------------------------------------------------------*
FORM select_tgsb  USING    pt_dados TYPE ztfi_imobilizado
                  CHANGING pt_tgsb  TYPE ty_tgsb.

  DATA lt_dados TYPE ztfi_imobilizado.

  lt_dados[] = pt_dados[].
  SORT lt_dados BY gsber.
  DELETE ADJACENT DUPLICATES FROM lt_dados COMPARING gsber.

  SELECT gsber
    FROM tgsb
    INTO TABLE pt_tgsb
    FOR ALL ENTRIES IN lt_dados
    WHERE gsber EQ lt_dados-gsber.

ENDFORM.                    " SELECT_TGSB

*&---------------------------------------------------------------------*
*&      Form  VALIDA_GSBER
*&---------------------------------------------------------------------*
FORM valida_gsber  USING    pt_data  TYPE ty_tgsb
                            p_index  TYPE i
                            p_val    TYPE gsber.
  DATA l_txt TYPE char100.

  IF p_val IS INITIAL.
    _add_log p_index 'GSBER' 'LOG - Divisão preenchimento obrigatório'.
    EXIT.
  ENDIF.

  READ TABLE pt_data TRANSPORTING NO FIELDS WITH KEY gsber = p_val BINARY SEARCH.
  CHECK sy-subrc <> 0.

  CONCATENATE 'LOG - Divisão não cadastrada: ' p_val INTO l_txt.
  _add_log p_index 'GSBER' l_txt.
ENDFORM.                    " VALIDA_GSBER

*&---------------------------------------------------------------------*
*&      Form  SELECT_ZCODODI
*&---------------------------------------------------------------------*
FORM select_zcododi  USING    pt_dados TYPE ztfi_imobilizado
                     CHANGING pt_data  TYPE ty_cododi.

  DATA lt_dados TYPE ztfi_imobilizado.

  lt_dados[] = pt_dados[].
  SORT lt_dados BY bukrs werks stort.
  DELETE ADJACENT DUPLICATES FROM lt_dados COMPARING bukrs werks stort.

  SELECT bukrs werks stand codti gti odi cc data
  FROM zcododi
  INTO TABLE pt_data
  FOR ALL ENTRIES IN lt_dados
  WHERE bukrs EQ lt_dados-bukrs
    AND werks EQ lt_dados-werks
    AND stand EQ lt_dados-stort.

ENDFORM.                    " SELECT_ZCODODI

*&---------------------------------------------------------------------*
*&      Form  SELECT_ZTIPINS
*&---------------------------------------------------------------------*
FORM select_ztipins  USING    pt_dados TYPE ztfi_imobilizado
                     CHANGING pt_data  TYPE ty_tipins.

  DATA lt_dados TYPE ztfi_imobilizado.

  lt_dados[] = pt_dados[].
  SORT lt_dados BY zti.
  DELETE ADJACENT DUPLICATES FROM lt_dados COMPARING zti.

  SELECT codti
  FROM ztipins
  INTO TABLE pt_data
  FOR ALL ENTRIES IN lt_dados
  WHERE codti EQ lt_dados-zti.

ENDFORM.                    " SELECT_ZTIPINS

*&---------------------------------------------------------------------*
*&      Form  select_zcmloci
*&---------------------------------------------------------------------*
FORM select_from_zcm  USING    pt_dados TYPE ztfi_imobilizado
                      CHANGING pt_zcmloci  TYPE ty_cmloci
                               pt_zcmcomp  TYPE ty_cmcomp
                               pt_zcmarfi  TYPE ty_cmarfi.

  DATA lt_dados TYPE ztfi_imobilizado.

  lt_dados[] = pt_dados[].
  SORT lt_dados BY zcm.
  DELETE ADJACENT DUPLICATES FROM lt_dados COMPARING zcm.

  SELECT cmli
  FROM zcmloci
  INTO TABLE pt_zcmloci
  FOR ALL ENTRIES IN lt_dados
  WHERE cmli EQ lt_dados-zcm(1).

  SELECT cmcomp
  FROM zcmcomp
  INTO TABLE pt_zcmcomp
  FOR ALL ENTRIES IN lt_dados
  WHERE cmcomp EQ lt_dados-zcm+1(1).

  SELECT cmaf
  FROM zcmarfi
  INTO TABLE pt_zcmarfi
  FOR ALL ENTRIES IN lt_dados
  WHERE cmaf EQ lt_dados-zcm+2(1).

ENDFORM.                    "select_zcmloci

*&---------------------------------------------------------------------*
*&      Form  valida_ZTI
*&---------------------------------------------------------------------*
FORM valida_zti  USING    pt_data  TYPE ty_tipins
                 p_index  TYPE i
                 p_val    TYPE any.
  DATA l_txt TYPE char100.

  IF p_val IS INITIAL.
    _add_log p_index 'ZTI' 'LOG - Tipo de instalação preenchimento obrigatório'.
    EXIT.
  ENDIF.

  READ TABLE pt_data TRANSPORTING NO FIELDS WITH KEY codti = p_val BINARY SEARCH.
  CHECK sy-subrc <> 0.

  CONCATENATE 'LOG - Tipo de instalação em não cadastrado: ' p_val INTO l_txt.
  _add_log p_index 'ZTI' l_txt.
ENDFORM.                    "valida_ZTI

*&---------------------------------------------------------------------*
*&      Form  select_ztipo_uc
*&---------------------------------------------------------------------*
FORM select_ztipo_uc  USING    pt_dados TYPE ztfi_imobilizado
                      CHANGING pt_data  TYPE ty_tipouc.

  DATA lt_dados TYPE ztfi_imobilizado.

  lt_dados[] = pt_dados[].
  SORT lt_dados BY ztuc.
  DELETE ADJACENT DUPLICATES FROM lt_dados COMPARING ztuc.

  SELECT tuc
  FROM ztipouc
  INTO TABLE pt_data
  FOR ALL ENTRIES IN lt_dados
  WHERE tuc EQ lt_dados-ztuc.

ENDFORM.                    "select_ztipo_uc

*&---------------------------------------------------------------------*
*&      Form  select_zTIPBEM
*&---------------------------------------------------------------------*
FORM select_ztipbem  USING    pt_dados TYPE ztfi_imobilizado
                      CHANGING pt_data  TYPE ty_tipbem.

  DATA lt_dados TYPE ztfi_imobilizado.

  lt_dados[] = pt_dados[].
  SORT lt_dados BY ztuc zatra1.
  DELETE ADJACENT DUPLICATES FROM lt_dados COMPARING ztuc zatra1.

  SELECT tuc tbem
  FROM ztipbem
  INTO TABLE pt_data
  FOR ALL ENTRIES IN lt_dados
  WHERE tuc EQ lt_dados-ztuc
    AND tbem EQ lt_dados-zatra1.

ENDFORM.                    "select_zTIPBEM

*&---------------------------------------------------------------------*
*&      Form  select_zcdguar
*&---------------------------------------------------------------------*
FORM select_zcdguar  USING    pt_dados TYPE ztfi_imobilizado
                     CHANGING pt_data  TYPE ty_cdguar.

  DATA lt_dados TYPE ztfi_imobilizado.

  lt_dados[] = pt_dados[].
  SORT lt_dados BY ztuc zatra1.
  DELETE ADJACENT DUPLICATES FROM lt_dados COMPARING ztuc zatra1.

  SELECT tuc tbem coduar
  FROM zcdguar
  INTO TABLE pt_data
  FOR ALL ENTRIES IN lt_dados
  WHERE tuc EQ lt_dados-ztuc
    AND tbem EQ lt_dados-zatra1.

ENDFORM.                    "select_zcdguar

*&---------------------------------------------------------------------*
*&      Form  select_zforcad
*&---------------------------------------------------------------------*
FORM select_zforcad  USING    pt_dados TYPE ztfi_imobilizado
                     CHANGING pt_data  TYPE ty_forcad.

  DATA lt_dados TYPE ztfi_imobilizado.

  lt_dados[] = pt_dados[].
  SORT lt_dados BY ztuc zatra1.
  DELETE ADJACENT DUPLICATES FROM lt_dados COMPARING zfc.

  SELECT cadastro
  FROM zforcad
  INTO TABLE pt_data
  FOR ALL ENTRIES IN lt_dados
  WHERE cadastro EQ lt_dados-zfc.

ENDFORM.                    "select_zforcad

*&---------------------------------------------------------------------*
*&      Form  select_mara
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->PT_DADOS   text
*      -->PT_DATA    text
*----------------------------------------------------------------------*
FORM select_mara  USING    pt_dados TYPE ztfi_imobilizado
                  CHANGING pt_data  TYPE ty_mara.

  DATA lt_dados TYPE ztfi_imobilizado.

  lt_dados[] = pt_dados[].
  SORT lt_dados BY zmatnr.
  DELETE lt_dados WHERE zmatnr IS INITIAL.
  DELETE ADJACENT DUPLICATES FROM lt_dados COMPARING zmatnr.

  CHECK NOT lt_dados IS INITIAL.
  SELECT matnr
    FROM mara
    INTO TABLE pt_data
    FOR ALL ENTRIES IN lt_dados
    WHERE matnr EQ lt_dados-zmatnr.

ENDFORM.                    "select_mara

*&---------------------------------------------------------------------*
*&      Form  select_zparatr
*&---------------------------------------------------------------------*
FORM select_zparatr  USING    pt_dados TYPE ztfi_imobilizado
                     CHANGING pt_data  TYPE ty_paratr.

  DATA lt_dados TYPE ztfi_imobilizado.

  lt_dados[] = pt_dados[].
  SORT lt_dados BY ztuc zatra1.
  DELETE ADJACENT DUPLICATES FROM lt_dados COMPARING ztuc zatra1.

  SELECT tuc tbem chavea2 chavea3 chavea4 chavea5 chavea6
     FROM zparatr
     INTO TABLE pt_data
     FOR ALL ENTRIES IN lt_dados
     WHERE tuc EQ lt_dados-ztuc
       AND tbem EQ lt_dados-zatra1.

ENDFORM.                    "select_zparatr

*&---------------------------------------------------------------------*
*&      Form  valida_zcm
*&---------------------------------------------------------------------*
FORM valida_zcm  USING    pt_zcmloci  TYPE ty_cmloci
                          pt_zcmcomp  TYPE ty_cmcomp
                          pt_zcmarfi  TYPE ty_cmarfi
                          p_index  TYPE i
                          p_zcm TYPE anlu-zcm
                          p_zti  TYPE anlu-zti.
  DATA l_txt TYPE char100.

  IF p_zcm IS INITIAL.
    _add_log p_index 'ZCM' 'LOG - Centro Modular preenchimento obrigatório'.
    EXIT.
  ENDIF.

  IF p_zti NE '20' AND p_zti NE '21' AND
     p_zti NE '22' AND p_zti NE '23'.

    IF p_zcm NE '000'.

      _add_log p_index 'ZTI' 'LOG - Para Tip. Instal. diferente de 20/21/22/23 o C. Modular tem que ser igual a 000'.
    ENDIF.

  ELSE.

    READ TABLE pt_zcmloci TRANSPORTING NO FIELDS WITH KEY cmli = p_zcm(1) BINARY SEARCH.
    IF sy-subrc <> 0.
      CONCATENATE 'LOG - Centro Modular primeiro dígito não cadastrado: ' p_zcm INTO l_txt.
      _add_log p_index 'ZTI' l_txt.
    ENDIF.

    READ TABLE pt_zcmcomp TRANSPORTING NO FIELDS WITH KEY cmcomp = p_zcm+1(1) BINARY SEARCH.
    IF sy-subrc <> 0.
      CONCATENATE 'LOG - Centro Modular segundo dígito não cadastrado: ' p_zcm INTO l_txt.
      _add_log p_index 'ZTI' l_txt.
    ENDIF.

    READ TABLE pt_zcmarfi TRANSPORTING NO FIELDS WITH KEY cmaf = p_zcm+2(1) BINARY SEARCH.
    IF sy-subrc <> 0.
      CONCATENATE 'LOG - Centro Modular terceiro dígito não cadastrado: ' p_zcm INTO l_txt.
      _add_log p_index 'ZTI' l_txt.
    ENDIF.
  ENDIF.
ENDFORM.                    "valida_zcm

*&---------------------------------------------------------------------*
*&      Form  valida_ZTuc
*&---------------------------------------------------------------------*
FORM valida_ztuc  USING    pt_data  TYPE ty_tipouc
                           p_index  TYPE i
                           p_val    TYPE any.
  DATA l_txt TYPE char100.

  IF p_val IS INITIAL.
    _add_log p_index 'ZTUC' 'LOG - Tipo de unidade de cadastro preenchimento obrigatório'.
    EXIT.
  ENDIF.

  READ TABLE pt_data TRANSPORTING NO FIELDS WITH KEY tuc = p_val BINARY SEARCH.
  CHECK sy-subrc <> 0.

  CONCATENATE 'LOG - Tipo de unidade de cadastro não cadastrado: ' p_val INTO l_txt.
  _add_log p_index 'ZTUC' l_txt.
ENDFORM.                    "valida_ZTuc

*&---------------------------------------------------------------------*
*&      Form  valida_zuar
*&---------------------------------------------------------------------*
FORM valida_zuar  USING    pt_data  TYPE ty_cdguar
                           p_index  TYPE i
                           p_tuc    TYPE zcodtuc
                           p_zatra1 TYPE ztbem
                           p_zuar   TYPE zcod_uar.
  DATA l_txt TYPE char100.

  IF p_zuar IS INITIAL.
    _add_log p_index 'ZUAR' 'LOG - Unidade de Adição e Retirada em branco'.
    EXIT.
  ENDIF.

  READ TABLE pt_data TRANSPORTING NO FIELDS WITH KEY tuc = p_tuc
                                                     tbem   = p_zatra1
                                                     coduar = p_zuar BINARY SEARCH.
  CHECK sy-subrc <> 0.

  CONCATENATE 'LOG - Unidade de Adição e Retirada não cadastrada: ' p_zuar INTO l_txt.
  _add_log p_index 'ZTUC' l_txt.
ENDFORM.                    "valida_zuar

*&---------------------------------------------------------------------*
*&      Form  valida_zFC
*&---------------------------------------------------------------------*
FORM valida_zfc  USING     pt_data  TYPE ty_forcad
                           p_index  TYPE i
                           p_val TYPE any.
  DATA l_txt TYPE char100.

  IF p_val IS INITIAL.
    _add_log p_index 'ZFC' 'LOG - Forma de Cadastramento preenchimento obrigatório'.
    EXIT.
  ENDIF.

  READ TABLE pt_data TRANSPORTING NO FIELDS WITH KEY cadastro = p_val BINARY SEARCH.
  CHECK sy-subrc <> 0.

  CONCATENATE 'LOG - Forma de Cadastramento não cadastrada: ' p_val INTO l_txt.
  _add_log p_index 'ZFC' l_txt.
ENDFORM.                    "valida_zFC

*&---------------------------------------------------------------------*
*&      Form  valida_MATNR
*&---------------------------------------------------------------------*
FORM valida_matnr  USING     pt_data  TYPE ty_mara
                             p_index  TYPE i
                             p_val    TYPE any.
  DATA l_txt TYPE char100.

  CHECK NOT p_val IS INITIAL.

  READ TABLE pt_data TRANSPORTING NO FIELDS WITH KEY matnr = p_val BINARY SEARCH.
  CHECK sy-subrc <> 0.

  CONCATENATE 'LOG - Código do Material não cadastrado: ' p_val INTO l_txt.
  _add_log p_index 'ZMATNR' l_txt.
ENDFORM.                    "valida_MATNR

*&---------------------------------------------------------------------*
*&      Form  valida_zatra1
*&---------------------------------------------------------------------*
FORM valida_zatra1  USING    pt_data  TYPE ty_tipbem
                             p_index  TYPE i
                             p_zatra1 TYPE ztipbem-tbem
                             p_ztuc   TYPE ztipbem-tuc.
  DATA l_txt TYPE char100.

  IF p_zatra1  IS INITIAL.
    _add_log p_index 'ZATRA1' 'LOG - Tipo de bem preenchimento obrigatório'.
    EXIT.
  ENDIF.

  READ TABLE pt_data TRANSPORTING NO FIELDS WITH KEY tuc   = p_ztuc
                                                     tbem  = p_zatra1 BINARY SEARCH.
  CHECK sy-subrc <> 0.

  CONCATENATE 'LOG - Tipo de bem não cadastrado: ' p_zatra1 INTO l_txt.
  _add_log p_index 'ZATRA1' l_txt.
ENDFORM.                    "valida_zatra1

*&---------------------------------------------------------------------*
*&      Form  valida_zatra2
*&---------------------------------------------------------------------*
FORM valida_zatra2  USING    pt_data  TYPE ty_paratr
                             p_index  TYPE i
                             p_zatra2 TYPE char2
                             p_zatra1 TYPE ztipbem-tbem
                             p_ztuc   TYPE ztipbem-tuc.
  DATA l_txt TYPE char100.
  DATA ls_data TYPE y_paratr.

  READ TABLE pt_data INTO ls_data WITH KEY tuc   = p_ztuc
                                           tbem  = p_zatra1 BINARY SEARCH.
  IF sy-subrc <> 0.
    CONCATENATE 'LOG - Atributo técnico (A2) não cadastrado: ' p_zatra1 INTO l_txt.
    _add_log p_index 'ZATRA2' l_txt.
  ELSEIF NOT ls_data-chavea2 IS INITIAL.

    SELECT SINGLE codigo
    FROM zcodatr
    INTO sy-tvar0(2)
    WHERE atributo EQ ls_data-chavea2
      AND codigo   EQ p_zatra2.

    CHECK sy-subrc <> 0.

    CONCATENATE 'LOG - Atributo técnico (A2) não cadastrado: ' p_zatra1 INTO l_txt.
    _add_log p_index 'ZATRA2' l_txt.

  ENDIF.

ENDFORM.                    "valida_zatra2

*&---------------------------------------------------------------------*
*&      Form  valida_zatra3
*&---------------------------------------------------------------------*
FORM valida_zatra3  USING    pt_data  TYPE ty_paratr
                             p_index  TYPE i
                             p_zatrax TYPE char2
                             p_zatra1 TYPE ztipbem-tbem
                             p_ztuc   TYPE ztipbem-tuc.
  DATA l_txt TYPE char100.
  DATA ls_data TYPE y_paratr.

  READ TABLE pt_data INTO ls_data WITH KEY tuc   = p_ztuc
                                           tbem  = p_zatra1 BINARY SEARCH.
  IF sy-subrc <> 0.
    CONCATENATE 'LOG - Atributo técnico (A2) não cadastrado: ' p_zatrax INTO l_txt.
    _add_log p_index 'ZATRA3' l_txt.
  ELSEIF NOT ls_data-chavea3 IS INITIAL.

    SELECT SINGLE codigo
    FROM zcodatr
    INTO sy-tvar0(2)
    WHERE atributo EQ ls_data-chavea3
      AND codigo   EQ p_zatrax.

    CHECK sy-subrc <> 0.

    CONCATENATE 'LOG - Atributo técnico (A3) não cadastrado: ' p_zatrax INTO l_txt.
    _add_log p_index 'ZATRA3' l_txt.

  ENDIF.

ENDFORM.                    "valida_zatra3

*&---------------------------------------------------------------------*
*&      Form  valida_zatra4
*&---------------------------------------------------------------------*
FORM valida_zatra4  USING    pt_data  TYPE ty_paratr
                             p_index  TYPE i
                             p_zatrax TYPE char2
                             p_zatra1 TYPE ztipbem-tbem
                             p_ztuc   TYPE ztipbem-tuc.
  DATA l_txt TYPE char100.
  DATA ls_data TYPE y_paratr.

  READ TABLE pt_data INTO ls_data WITH KEY tuc   = p_ztuc
                                           tbem  = p_zatra1 BINARY SEARCH.
  IF sy-subrc <> 0.
    CONCATENATE 'LOG - Atributo técnico (A4) não cadastrado: ' p_zatrax INTO l_txt.
    _add_log p_index 'ZATRA4' l_txt.
  ELSEIF NOT ls_data-chavea4 IS INITIAL.

    SELECT SINGLE codigo
    FROM zcodatr
    INTO sy-tvar0(2)
    WHERE atributo EQ ls_data-chavea4
      AND codigo   EQ p_zatrax.

    CHECK sy-subrc <> 0.

    CONCATENATE 'LOG - Atributo técnico (A3) não cadastrado: ' p_zatrax INTO l_txt.
    _add_log p_index 'ZATRA4' l_txt.

  ENDIF.

ENDFORM.                    "valida_zatra3

*&---------------------------------------------------------------------*
*&      Form  valida_zatra3
*&---------------------------------------------------------------------*
FORM valida_zatra5  USING    pt_data  TYPE ty_paratr
                             p_index  TYPE i
                             p_zatrax TYPE char2
                             p_zatra1 TYPE ztipbem-tbem
                             p_ztuc   TYPE ztipbem-tuc.
  DATA l_txt TYPE char100.
  DATA ls_data TYPE y_paratr.

  READ TABLE pt_data INTO ls_data WITH KEY tuc   = p_ztuc
                                           tbem  = p_zatra1 BINARY SEARCH.
  IF sy-subrc <> 0.
    CONCATENATE 'LOG - Atributo técnico (A5) não cadastrado: ' p_zatrax INTO l_txt.
    _add_log p_index 'ZATRA5' l_txt.
  ELSEIF NOT ls_data-chavea5 IS INITIAL.

    SELECT SINGLE codigo
    FROM zcodatr
    INTO sy-tvar0(2)
    WHERE atributo EQ ls_data-chavea5
      AND codigo   EQ p_zatrax.

    CHECK sy-subrc <> 0.

    CONCATENATE 'LOG - Atributo técnico (A3) não cadastrado: ' p_zatrax INTO l_txt.
    _add_log p_index 'ZATRA5' l_txt.

  ENDIF.

ENDFORM.                    "valida_zatra5

*&---------------------------------------------------------------------*
*&      Form  valida_zatra6
*&---------------------------------------------------------------------*
FORM valida_zatra6  USING    pt_data  TYPE ty_paratr
                             p_index  TYPE i
                             p_zatrax TYPE char2
                             p_zatra1 TYPE ztipbem-tbem
                             p_ztuc   TYPE ztipbem-tuc.
  DATA l_txt TYPE char100.
  DATA ls_data TYPE y_paratr.

  READ TABLE pt_data INTO ls_data WITH KEY tuc   = p_ztuc
                                           tbem  = p_zatra1 BINARY SEARCH.
  IF sy-subrc <> 0.
    CONCATENATE 'LOG - Atributo técnico (A6) não cadastrado: ' p_zatrax INTO l_txt.
    _add_log p_index 'ZATRA6' l_txt.
  ELSEIF NOT ls_data-chavea6 IS INITIAL.

    SELECT SINGLE codigo
    FROM zcodatr
    INTO sy-tvar0(2)
    WHERE atributo EQ ls_data-chavea6
      AND codigo   EQ p_zatrax.

    CHECK sy-subrc <> 0.

    CONCATENATE 'LOG - Atributo técnico (A6) não cadastrado: ' p_zatrax INTO l_txt.
    _add_log p_index 'ZATRA6' l_txt.

  ENDIF.

ENDFORM.                    "valida_zatra6

*&---------------------------------------------------------------------*
*&      Form  VALIDA_VALAQ
*&---------------------------------------------------------------------*
FORM valida_valaq  USING    p_index  TYPE i
                            p_val TYPE char15.

  IF p_val IS INITIAL.
    _add_log p_index 'VALAQ' 'LOG - Valor Aquisição preenchimento obrigatório'.
    EXIT.
  ENDIF.

ENDFORM.                    " VALIDA_VALAQ

*&---------------------------------------------------------------------*
*&      Form  VALIDA_ZCONT
*&---------------------------------------------------------------------*
FORM valida_zcont      USING     pt_codiodi TYPE ty_cododi
                                 p_index  TYPE i
                                 p_zcontrato TYPE anlu-zcontrato
                                 p_bukrs TYPE bukrs
                                 p_werks TYPE werks_d
                                 p_stort TYPE anlz-stort
                                 p_zti  TYPE anlu-zti
                                 p_zodi TYPE anlu-zodi.
  DATA l_txt TYPE char100.

  IF p_zcontrato IS INITIAL.
    _add_log p_index 'ZCONTRATO' 'LOG - Contrato de concessão preenchimento obrigatório'.
    EXIT.
  ENDIF.
  LOOP AT pt_codiodi TRANSPORTING NO FIELDS WHERE bukrs = p_bukrs
                                              AND werks = p_werks
                                              AND stand = p_stort
                                              AND codti =  p_zti
                                              AND odi   =  p_zodi
                                              AND cc    = p_zcontrato
                                              AND data  >=  sy-datum .
    EXIT.
  ENDLOOP.

  CHECK sy-subrc <> 0.

  CONCATENATE 'LOG - Contrato de concessão não cadastrado: ' p_zcontrato INTO l_txt.
  _add_log p_index 'ZCONTRATO' l_txt.

ENDFORM.                    " VALIDA_ZCONT

*&---------------------------------------------------------------------*
*&      Form  VALIDA_ZODI
*&---------------------------------------------------------------------*
FORM valida_zodi  USING     pt_codiodi TYPE ty_cododi
                            p_index  TYPE i
                            p_bukrs TYPE bukrs
                            p_werks TYPE werks_d
                            p_stort TYPE anlz-stort
                            p_zti  TYPE anlu-zti
                            p_zodi TYPE anlu-zodi.
  DATA l_txt TYPE char100.

  IF p_zodi IS INITIAL.
    _add_log p_index 'ZODI' 'LOG - ODI preenchimento obrigatório'.
    EXIT.
  ENDIF.
  READ TABLE pt_codiodi TRANSPORTING NO FIELDS WITH KEY bukrs = p_bukrs
                                                        werks = p_werks
                                                        stand = p_stort
                                                        codti =  p_zti
                                                        odi   =  p_zodi.
  CHECK sy-subrc <> 0.

  CONCATENATE 'LOG - ODI não cadastrado: ' p_zodi INTO l_txt.
  _add_log p_index 'ZODI' l_txt.

ENDFORM.                    " VALIDA_ZODI

*&---------------------------------------------------------------------*
*&      Form  VALIDA_DEPAC
*&---------------------------------------------------------------------*
FORM valida_depac  USING    p_index  TYPE i
                            p_val TYPE char15.

  IF p_val IS INITIAL.
    _add_log p_index 'DEPAC' 'LOG - Valor Depr Acum preenchimento obrigatório'.
    EXIT.
  ENDIF.

ENDFORM.                    " VALIDA_DEPAC

*&---------------------------------------------------------------------*
*&      Form  VALIDA_DADOS
*&---------------------------------------------------------------------*
FORM valida_dados  TABLES pt_dados    TYPE ztfi_imobilizado
                          pt_return   TYPE bapiret2_tab
                   USING  p_i_testrun TYPE testrun.

  DATA: wa_return TYPE bapiret2.

  DATA ls_dados  TYPE zefi_imobilizado.
  DATA l_index   TYPE i.
  DATA lt_anka   TYPE ty_anka.
  DATA lt_t001   TYPE ty_bukrs.
  DATA lt_anla   TYPE ty_anla.
  DATA lt_csks   TYPE ty_csks.
  DATA lt_aufk   TYPE ty_aufk.
  DATA lt_t001w  TYPE ty_t001w.
  DATA lt_t499s  TYPE ty_t499s.
  DATA lt_t090   TYPE ty_t090.
  DATA lt_t006   TYPE ty_t006.
  DATA lt_tgsb   TYPE ty_tgsb.
  DATA lt_cododi TYPE ty_cododi.
  DATA lt_tipins TYPE ty_tipins.
  DATA lt_cmloci TYPE ty_cmloci.
  DATA lt_cmcomp TYPE ty_cmcomp.
  DATA lt_cmarfi TYPE ty_cmarfi.
  DATA lt_tipouc TYPE ty_tipouc.
  DATA lt_tipbem TYPE ty_tipbem.
  DATA lt_paratr TYPE ty_paratr.
  DATA lt_cdguar TYPE ty_cdguar.
  DATA lt_forcad TYPE ty_forcad.
  DATA lt_mara   TYPE ty_mara.

  PERFORM select_anka     USING pt_dados[] CHANGING lt_anka.
  PERFORM select_t001     USING pt_dados[] CHANGING lt_t001.
  PERFORM select_csks     USING pt_dados[] CHANGING lt_csks.
  PERFORM select_t001w    USING pt_dados[] CHANGING lt_t001w.
  PERFORM select_t499s    USING pt_dados[] CHANGING lt_t499s.
  PERFORM select_t006     USING pt_dados[] CHANGING lt_t006.
  PERFORM select_tgsb     USING pt_dados[] CHANGING lt_tgsb.
  PERFORM select_zcododi  USING pt_dados[] CHANGING lt_cododi.
  PERFORM select_ztipins  USING pt_dados[] CHANGING lt_tipins.
  PERFORM select_from_zcm USING pt_dados[] CHANGING lt_cmloci lt_cmcomp lt_cmarfi.
  PERFORM select_ztipo_uc USING pt_dados[] CHANGING lt_tipouc.
  PERFORM select_ztipbem  USING pt_dados[] CHANGING lt_tipbem.
  PERFORM select_zparatr  USING pt_dados[] CHANGING lt_paratr.
  PERFORM select_zcdguar  USING pt_dados[] CHANGING lt_cdguar.
  PERFORM select_zforcad  USING pt_dados[] CHANGING lt_forcad.
  PERFORM select_mara     USING pt_dados[] CHANGING lt_mara.
  LOOP AT pt_dados INTO ls_dados.
    _inc l_index.
    PERFORM valida_bukrs USING lt_t001  l_index  ls_dados-bukrs.
    PERFORM valida_anlkl USING lt_anka  l_index  ls_dados-anlkl.
    PERFORM valida_txt50 USING l_index  ls_dados-txt50.
    PERFORM valida_txa50 USING l_index  ls_dados-txa50.
    PERFORM valida_invnr USING l_index  ls_dados-zfc  ls_dados-invnr.
    PERFORM valida_menge USING l_index  ls_dados-menge.
    PERFORM valida_meins USING lt_t006  l_index  ls_dados-meins ls_dados-aux_meins.
    PERFORM valida_gsber USING lt_tgsb  l_index  ls_dados-gsber.
    PERFORM valida_kostl USING lt_csks  l_index  ls_dados-kostl.
    PERFORM valida_werks USING lt_t001w l_index  ls_dados-werks.
    PERFORM valida_stort USING lt_t499s l_index  ls_dados-werks ls_dados-stort.
    PERFORM valida_aktiv USING l_index  ls_dados-aktiv.
    PERFORM valida_zcont USING lt_cododi l_index    ls_dados-zcontrato  ls_dados-bukrs
                                                    ls_dados-werks      ls_dados-stort
                                                    ls_dados-zti        ls_dados-zodi.
    PERFORM valida_zodi  USING lt_cododi l_index    ls_dados-bukrs      ls_dados-werks
                                                    ls_dados-stort      ls_dados-zti
                                                    ls_dados-zodi.
    PERFORM valida_zti   USING lt_tipins  l_index   ls_dados-zti.
    PERFORM valida_zcm   USING lt_cmloci  lt_cmcomp lt_cmarfi l_index  ls_dados-zcm ls_dados-zti.
    PERFORM valida_ztuc  USING lt_tipouc  l_index   ls_dados-ztuc.
    PERFORM valida_zatra1 USING lt_tipbem l_index   ls_dados-zatra1 ls_dados-ztuc.
    PERFORM valida_zatra2 USING lt_paratr l_index   ls_dados-zatra2 ls_dados-zatra1 ls_dados-ztuc.
    PERFORM valida_zatra3 USING lt_paratr l_index   ls_dados-zatra3 ls_dados-zatra1 ls_dados-ztuc.
    PERFORM valida_zatra4 USING lt_paratr l_index   ls_dados-zatra4 ls_dados-zatra1 ls_dados-ztuc.
    PERFORM valida_zatra5 USING lt_paratr l_index   ls_dados-zatra5 ls_dados-zatra1 ls_dados-ztuc.
    PERFORM valida_zatra6 USING lt_paratr l_index   ls_dados-zatra6 ls_dados-zatra1 ls_dados-ztuc.
    PERFORM valida_zuar   USING lt_cdguar l_index   ls_dados-ztuc ls_dados-zatra1 ls_dados-zuar.
    PERFORM valida_matnr  USING lt_mara   l_index   ls_dados-zmatnr.
    PERFORM valida_afabg  USING l_index   ls_dados-afabg.
    PERFORM valida_ndjar  USING l_index   ls_dados-ndjar ls_dados-anlkl.
    PERFORM valida_valaq  USING l_index   ls_dados-valaq.
    PERFORM valida_depac  USING l_index   ls_dados-depac.
  ENDLOOP.

  IF gt_log[] IS INITIAL.

    LOOP AT pt_dados INTO ls_dados.
      MOVE ls_dados TO gv_dados.
      PERFORM bapi_fixedasset USING p_i_testrun.
    ENDLOOP.

    _add_log_sucess 'Nenhum erro encontrado'.

  ENDIF.

  LOOP AT gt_log INTO gs_log.
    wa_return-message = gs_log-message.
    APPEND wa_return TO pt_return.
    CLEAR  wa_return.
  ENDLOOP.

ENDFORM.                    " VALIDA_DADOS

FORM bapi_fixedasset USING p_i_testrun TYPE testrun.

  CLEAR: gt_bapi1022_dep_areas[], gt_bapi1022_dep_areasx[], gv_return,
         gv_bapi1022_feglg001, gv_bapi1022_feglg001x,
         gv_bapi1022_feglg002, gv_bapi1022_feglg002x,
         gv_bapi1022_feglg003, gv_bapi1022_feglg003x,

         gt_extensionin[], gt_bapi1022_postval[], gt_bapi1022_cumval[].

  DATA: lv_fixedasset_date TYPE anla-aktiv,
        lv_kansw           TYPE anlc-kansw,
        lv_return          TYPE bapiret2,
        lv_knafa           TYPE anlc-knafa,
        lv_bukrs           TYPE anla-bukrs,
        i_anlu             TYPE anlu,
        lv_asset           TYPE bapi1022_1-assetmaino,
        lv_subnumber       TYPE bapi1022_1-assetsubno,
        lv_assetcreated    TYPE bapi1022_reference.
  MOVE: gv_dados-bukrs TO gv_bapi1022_key-companycode,
        gv_dados-anln1 TO gv_bapi1022_key-asset,
        gv_dados-anln2 TO gv_bapi1022_key-subnumber .
  MOVE sy-mandt TO i_anlu.
  MOVE-CORRESPONDING gv_dados TO:  i_anlu, gv_anlu.
  EXPORT i_anlu TO MEMORY ID 'ANLU' .
  MOVE:  gv_dados-anlkl TO gv_bapi1022_feglg001-assetclass,
         gv_dados-txt50 TO gv_bapi1022_feglg001-main_descript,
         gv_dados-txt50 TO gv_bapi1022_feglg001-descript,
         gv_dados-txt50 TO gv_bapi1022_feglg001-descript2,
         gv_dados-sernr TO gv_bapi1022_feglg001-serial_no,
         gv_dados-invnr TO gv_bapi1022_feglg001-invent_no,
         gv_dados-menge TO gv_bapi1022_feglg001-quantity,
         gv_dados-sernr TO gv_bapi1022_feglg001-serial_no,
         gv_msehi TO gv_bapi1022_feglg001-base_uom_iso,
         gv_msehi TO gv_bapi1022_feglg001-base_uom.

  MOVE 'X' TO :
         gv_bapi1022_feglg001x-assetclass,
         gv_bapi1022_feglg001x-main_descript,
         gv_bapi1022_feglg001x-main_descript,
         gv_bapi1022_feglg001x-descript,
         gv_bapi1022_feglg001x-descript2,
         gv_bapi1022_feglg001x-serial_no,
         gv_bapi1022_feglg001x-invent_no,
         gv_bapi1022_feglg001x-quantity,
         gv_bapi1022_feglg001x-serial_no,
         gv_bapi1022_feglg001x-base_uom_iso,
         gv_bapi1022_feglg001x-base_uom.


*  CONCATENATE gv_dados-aktiv+4(4) gv_dados-aktiv+2(2) gv_dados-aktiv(2)
*  INTO lv_fixedasset_date.
  lv_fixedasset_date = gv_dados-aktiv.

  MOVE   lv_fixedasset_date TO gv_bapi1022_feglg002-cap_date.
  MOVE   lv_fixedasset_date TO gv_bapi1022_feglg002-initial_acq.
  MOVE 'X' TO : gv_bapi1022_feglg002x-cap_date, gv_bapi1022_feglg002-initial_acq.


  MOVE:
*         lv_fixedasset_date to gv_bapi1022_feglg003-from_date,
*         '19000101' to gv_bapi1022_feglg003-from_date,
*         '99991231' to gv_bapi1022_feglg003-to_date,
         gv_dados-gsber TO gv_bapi1022_feglg003-bus_area,
         gv_dados-kostl TO gv_bapi1022_feglg003-costcenter,
         gv_dados-werks TO gv_bapi1022_feglg003-plant,
         gv_dados-stort TO gv_bapi1022_feglg003-location.

  MOVE 'X' TO :
         gv_bapi1022_feglg003x-bus_area,
*         gv_bapi1022_feglg003x-from_date,
*         gv_bapi1022_feglg003x-to_date,
         gv_bapi1022_feglg003x-costcenter,
         gv_bapi1022_feglg003x-plant,
         gv_bapi1022_feglg003x-location.


  PERFORM get_tuc USING gv_dados CHANGING gv_tuc_atrib.

  MOVE: gv_dados-bukrs     TO gv_bapi_te_anlu-comp_code,
        gv_dados-anln1     TO gv_bapi_te_anlu-assetmaino,
        gv_dados-anln2     TO gv_bapi_te_anlu-assetsubno,
        gv_dados-zcontrato TO gv_bapi_te_anlu-zcontrato,
        gv_dados-zodi      TO gv_bapi_te_anlu-zodi,
        gv_dados-zti       TO gv_bapi_te_anlu-zti,
        gv_dados-zfc       TO gv_bapi_te_anlu-zfc,
        gv_dados-zuar      TO gv_bapi_te_anlu-zuar,
        gv_dados-ztuc      TO gv_bapi_te_anlu-ztuc,
        gv_dados-zatra1    TO gv_bapi_te_anlu-zatra1,
        gv_dados-zatra2    TO gv_bapi_te_anlu-zatra2,
        gv_dados-zatra3    TO gv_bapi_te_anlu-zatra3,
        gv_dados-zatra4    TO gv_bapi_te_anlu-zatra4,
        gv_dados-zatra5    TO gv_bapi_te_anlu-zatra5,
        gv_dados-zatra6    TO gv_bapi_te_anlu-zatra6,
        gv_dados-zmatnr    TO gv_bapi_te_anlu-zmatnr,
*        gv_dados-zcontrato TO gv_bapi_te_anlu-zcon_patrimonial,
        gv_dados-zcm       TO gv_bapi_te_anlu-zcm.

*  CONCATENATE gv_dados-afabg+4(4) gv_dados-afabg+2(2) gv_dados-afabg(2)
*  INTO lv_fixedasset_date.
  lv_fixedasset_date = gv_dados-afabg.

  MOVE:
        lv_fixedasset_date TO gt_bapi1022_dep_areas-odep_start_date,
        gv_dados-ndjar TO gt_bapi1022_dep_areas-ulife_yrs,
        gv_dados-ndper TO gt_bapi1022_dep_areas-ulife_prds,
        '01'   TO gt_bapi1022_dep_areas-area,
        'ZTN1' TO gt_bapi1022_dep_areas-dep_key.

  APPEND gt_bapi1022_dep_areas.
  MOVE '05' TO gt_bapi1022_dep_areas-area.
  APPEND gt_bapi1022_dep_areas.

  MOVE 'X' TO :
        gt_bapi1022_dep_areasx-dep_key,
        gt_bapi1022_dep_areasx-odep_start_date,
        gt_bapi1022_dep_areasx-ulife_yrs,
        gt_bapi1022_dep_areasx-ulife_prds.

  MOVE '01' TO  gt_bapi1022_dep_areasx-area.
  APPEND gt_bapi1022_dep_areasx.

  MOVE '05' TO  gt_bapi1022_dep_areasx-area.
  APPEND gt_bapi1022_dep_areasx.

  REPLACE ',' WITH '.' INTO gv_dados-valaq.
  REPLACE ',' WITH '.' INTO gv_dados-depac.
  MOVE 'BRL' TO :  gt_bapi1022_cumval-currency, gt_bapi1022_cumval-currency_iso.
  MOVE gv_dados-valaq TO lv_kansw.
  MOVE gv_dados-depac TO lv_knafa.
  MOVE lv_kansw TO gt_bapi1022_cumval-acq_value.
  MOVE lv_knafa TO gt_bapi1022_cumval-ord_dep.
  MOVE sy-datum(4) TO gt_bapi1022_cumval-fisc_year.
  MOVE '01' TO gt_bapi1022_cumval-area.
  APPEND gt_bapi1022_cumval.
*  MOVE '02' TO gt_bapi1022_cumval-area.
*  APPEND gt_bapi1022_cumval.
*  MOVE '03' TO gt_bapi1022_cumval-area.
*  APPEND gt_bapi1022_cumval.
*  MOVE '04' TO gt_bapi1022_cumval-area.
*  APPEND gt_bapi1022_cumval.
  MOVE '05' TO gt_bapi1022_cumval-area.
  APPEND gt_bapi1022_cumval.

  MOVE gv_dados-aktiv+4(4) TO gt_bapi1022_postingheader-fisc_year.
  MOVE sy-datum TO gt_bapi1022_postingheader-pstng_date.
  MOVE gv_dados-menge TO gt_bapi1022_postingheader-quantity.
  MOVE 'CARGA' TO : gt_bapi1022_postingheader-ref_doc_no,
                    gt_bapi1022_postingheader-alloc_nmbr.

  APPEND gt_bapi1022_postingheader.

  "Sol.: CristinaGodin  28/01/14 - Ini
  CLEAR t093c.
  CALL FUNCTION 'T093C_READ'
    EXPORTING
      i_bukrs   = gv_dados-bukrs
    IMPORTING
      f_t093c   = t093c
    EXCEPTIONS
      not_found = 1
      OTHERS    = 2.

  IF t093c-datum+4 <> '1231'.
    MOVE gv_dados-depnl TO gt_bapi1022_postval-ord_dep.
    APPEND gt_bapi1022_postval.
  ENDIF.

  CLEAR gt_extensionin[].
  PERFORM value_to_string_transform USING gv_bapi_te_anlu CHANGING gt_extensionin.
  CONCATENATE sy-mandt gt_extensionin-valuepart1 INTO gt_extensionin-valuepart1.
  APPEND gt_extensionin.
  CLEAR: gt_return[], gv_return.

  PERFORM f_compare_data:
    USING gv_bapi1022_feglg001  CHANGING gv_bapi1022_feglg001x,
    USING gv_bapi1022_feglg002  CHANGING gv_bapi1022_feglg002x,
    USING gv_bapi1022_feglg003  CHANGING gv_bapi1022_feglg003x.


  CALL FUNCTION 'BAPI_FIXEDASSET_OVRTAKE_CREATE'
    EXPORTING
      key                 = gv_bapi1022_key
      testrun             = p_i_testrun
      generaldata         = gv_bapi1022_feglg001
      generaldatax        = gv_bapi1022_feglg001x
      postinginformation  = gv_bapi1022_feglg002
      postinginformationx = gv_bapi1022_feglg002x
      timedependentdata   = gv_bapi1022_feglg003
      timedependentdatax  = gv_bapi1022_feglg003x
    IMPORTING
      companycode         = lv_bukrs
      asset               = lv_asset
      subnumber           = lv_subnumber
      assetcreated        = lv_assetcreated
    TABLES
      depreciationareas   = gt_bapi1022_dep_areas
      depreciationareasx  = gt_bapi1022_dep_areasx
      cumulatedvalues     = gt_bapi1022_cumval
*     postingheaders      = gt_bapi1022_postingheader
*     extensionin         = gt_extensionin
      return              = gt_return.

  LOOP AT gt_return.
    MOVE gt_return TO lv_return.
    CONCATENATE gv_dados-anln1
    gt_return-message gt_return-message_v1 gt_return-message_v2 gt_return-message_v3 INTO
    gs_log-message SEPARATED BY space.
    IF gt_return-type = 'E'.
      gs_log-icon = icon_incomplete.
    ELSEIF gt_return-type = 'S' AND p_i_testrun IS INITIAL.
      AT FIRST.
        CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'.
        gs_log-icon = icon_checked.
        IF sy-tabix = 1.
          MOVE lv_return-message_v1 TO gv_anln1.
          WAIT UP TO 2 SECONDS.
          PERFORM bdc_as02 USING gv_anlu.
        ENDIF.
      ENDAT.
    ENDIF.
    APPEND gs_log TO gt_log.
  ENDLOOP.
  CLEAR gs_log.
ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  F_CONVERSION_MATN1
*&---------------------------------------------------------------------*
*       Conversão para campos com EXIT de Conversão MATN1
*----------------------------------------------------------------------*
*      <--PE_CHANGE_MATN1  text
*----------------------------------------------------------------------*
FORM f_conversion_matn1  CHANGING pe_change_matn1.

**> Rotina de conversão para preencher de 0 a esquerda qdo numerico
  CALL FUNCTION 'CONVERSION_EXIT_MATN1_INPUT'
    EXPORTING
      input        = pe_change_matn1
    IMPORTING
      output       = pe_change_matn1
    EXCEPTIONS
      length_error = 1
      OTHERS       = 2.

  IF sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.

ENDFORM.                    " F_CONVERSION_MATN1

*&---------------------------------------------------------------------*
*&      Form  F_CONVERSION_MEINS
*&---------------------------------------------------------------------*
FORM f_conversion_meins  USING    p_in  TYPE any
                         CHANGING p_out TYPE any.

  CALL FUNCTION 'CONVERSION_EXIT_CUNIT_INPUT'
    EXPORTING
      input          = p_in
      language       = sy-langu
    IMPORTING
      output         = p_out
    EXCEPTIONS
      unit_not_found = 1
      OTHERS         = 2.
  IF sy-subrc <> 0.
  ENDIF.

ENDFORM.                    " F_CONVERSION_MEINS

*&---------------------------------------------------------------------*
*&      Form  F_CONVERSION_TUC
*&---------------------------------------------------------------------*
FORM f_conversion_tuc  USING p_tam TYPE char1
                       CHANGING p_field TYPE  any.

  DATA: lv_2 TYPE numc2,
        lv_3 TYPE numc3.

  CASE p_tam.
    WHEN '3'.
      lv_3 = p_field.
      p_field = lv_3.
    WHEN '2'.
      lv_2 = p_field.
      p_field = lv_2.
  ENDCASE.

ENDFORM.                    " F_CONVERSION_TUC

*&---------------------------------------------------------------------*
*&      Form  get_tuc
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_DADOS    text
*      -->P_TUC      text
*----------------------------------------------------------------------*
FORM get_tuc USING p_dados TYPE zefi_imobilizado CHANGING p_tuc.

  CONCATENATE: p_dados-ztuc
               p_dados-zatra1
               p_dados-zatra2
               p_dados-zatra3
               p_dados-zatra4
               p_dados-zatra5
               p_dados-zatra6
          INTO p_tuc.

  WRITE p_tuc TO p_tuc
  USING EDIT MASK '___.__.__.__.__.__.__'.

ENDFORM.                    "get_tuc

*&---------------------------------------------------------------------*
*&      Form  VALUE_TO_STRING_TRANSFORM
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->IS_BAPI_ANLU    text
*      -->LS_EXTENSIONIN  text
*----------------------------------------------------------------------*
FORM value_to_string_transform USING is_bapi_anlu CHANGING ls_extension STRUCTURE bapiparex.
  FIELD-SYMBOLS: <lfs_anlu> TYPE c.
  DATA: ld_string TYPE string.
  FIELD-SYMBOLS: <lfs_extension> TYPE c.
  DATA: ld_offset_anlu  TYPE i.
  DATA: l_ref_cont TYPE REF TO cl_nls_struc_container,
        cp_tab     TYPE nls_langu_cp_tab.


  DESCRIBE FIELD ls_extension-structure LENGTH ld_offset_anlu
  IN CHARACTER MODE. "Unicode

  CALL FUNCTION 'NLS_GET_LANGU_CP_TAB'
    EXPORTING
      destination = 'NONE'
    TABLES
      cp_tab      = cp_tab.
*
  l_ref_cont = cl_nls_struc_container=>create( cp_tab =
  cp_tab ).


  ASSIGN is_bapi_anlu TO <lfs_anlu> CASTING.
  l_ref_cont->struc_to_cont( EXPORTING langu = sy-langu
                                       struc = <lfs_anlu>
                              IMPORTING cont = ld_string ).

  ASSIGN ls_extension  TO <lfs_extension>  CASTING.
  MOVE ld_string      TO <lfs_extension>+ld_offset_anlu.

  MOVE 'BAPI_TE_ANLU' TO  ls_extension-structure.

ENDFORM.                    "VALUE_TO_STRING_TRANSFORM

FORM bdc_as02 USING p_anlu TYPE anlu.
  DATA lv_tuc_atrib(21).

  CLEAR : gt_bdc, gt_bdc[].
  PERFORM f_grava_bdc USING: 'X' 'SAPLAIST'         '0100',
      ' ' 'BDC_OKCODE'       '=MAST',
      ' ' 'ANLA-ANLN1'      gv_anln1,
      ' ' 'ANLA-BUKRS'      gv_dados-bukrs.

  PERFORM get_tuc USING gv_dados CHANGING lv_tuc_atrib.

  PERFORM f_grava_bdc USING:
                          'X'  'SAPLAIST'        '1000',
                          ' '  'BDC_OKCODE'      '=TAB05',
                          'X'  'SAPLAIST'        '1000',
                          ' '  'BDC_CURSOR'      'ANLU-ZCONTRATO',
                          ' '  'ANLU-ZCONTRATO'  p_anlu-zcontrato,
                          ' '  'ANLU-ZODI'       p_anlu-zodi,
                          ' '  'ANLU-ZTI'        p_anlu-zti,
                          ' '  'G_CM1'           p_anlu-zcm(1),
                          ' '  'G_CM2'           p_anlu-zcm+1(1),
                          ' '  'G_CM3'           p_anlu-zcm+2(1),
                          ' '  'ANLU-ZUAR'       p_anlu-zuar,
                          ' '  'G_TUC_ATRIB'     lv_tuc_atrib,
                          ' '  'BDC_OKCODE'      '=BUCH'.


  MOVE 'N' TO racom-dismode.
  CLEAR ti_msg_err[].
  CALL TRANSACTION 'AS02' USING gt_bdc OPTIONS FROM racom
             MESSAGES INTO ti_msg_err.
  LOOP AT ti_msg_err.
    IF ti_msg_err-msgtyp = 'E'.
      CONCATENATE ti_msg_err-msgv1 ti_msg_err-msgv2 ti_msg_err-msgv3
      ti_msg_err-msgv4 INTO gs_log-message.
      APPEND gs_log TO gt_log.
    ELSE.
      PERFORM fi_document_change USING gv_anln1.
    ENDIF.
  ENDLOOP.
ENDFORM.

*&---------------------------------------------------------------------*
*&      FORM  F_GRAVA_BDC
*&---------------------------------------------------------------------*
*       Grava Passo A Passo Do Bdc
*----------------------------------------------------------------------*
*      -->pe_flag      indica se é chamada de uma tela
*      -->pe_campo     indica o campo
*      -->pe_conteudo  indica o valor do campo
*----------------------------------------------------------------------*
FORM f_grava_bdc USING pe_flag     TYPE clike
                       pe_campo    TYPE clike
                       pe_conteudo TYPE clike.

  CLEAR gt_bdc.
  IF pe_flag NE space.
    MOVE: pe_campo    TO gt_bdc-program,
          pe_conteudo TO gt_bdc-dynpro,
          pe_flag     TO gt_bdc-dynbegin.
  ELSE.
    MOVE: pe_campo    TO gt_bdc-fnam,
          pe_conteudo TO gt_bdc-fval.
  ENDIF.
  APPEND gt_bdc.

ENDFORM.                    " f_grava_bdc

FORM fi_document_change USING p_anln1 .
  TYPES: BEGIN OF ty_key,
           belnr TYPE belnr_d,
           bukrs TYPE bukrs,
           gjahr TYPE gjahr,
         END OF ty_key,
         BEGIN OF ty_asset,
           bukrs TYPE anla-bukrs,
           anln1 TYPE anla-anln1,
           anln2 TYPE anla-anln2,
         END OF ty_asset.
  DATA ls_key TYPE ty_key.
  DATA lt_bseg TYPE TABLE OF bseg.
  DATA ls_bseg TYPE bseg.
  DATA s_bseg TYPE bseg.
  DATA lt_buztab  TYPE  tpit_t_buztab.
  DATA lt_fldtab  TYPE  tpit_t_fname.
  DATA ls_buztab  LIKE LINE OF lt_buztab.
  DATA ls_fldtab  LIKE LINE OF lt_fldtab.
  DATA lt_errtab  TYPE  tpit_t_errdoc.
  DATA ls_errtab LIKE LINE OF lt_errtab.
  DATA lt_asset TYPE TABLE OF ty_asset.

* imobilizado e item

  SELECT * FROM bseg INTO TABLE lt_bseg
    WHERE bukrs = c_tb01 AND
          gjahr = sy-datum(4)
          AND anln1 = p_anln1
    ORDER BY anln2 DESCENDING.
  ls_fldtab-fname = 'SGTXT'.
  APPEND ls_fldtab TO lt_fldtab.
  CLEAR: ls_fldtab.
  LOOP AT lt_bseg INTO ls_bseg.
    CLEAR lt_buztab[].
    MOVE-CORRESPONDING ls_bseg TO s_bseg.
    CONCATENATE 'CARGA DE IMOBILIZADO' p_anln1 INTO s_bseg-sgtxt SEPARATED BY space.
    MOVE-CORRESPONDING ls_bseg TO ls_buztab.
    APPEND ls_buztab TO lt_buztab.
    CLEAR ls_buztab.
    IF lt_buztab[] IS NOT INITIAL.
      CLEAR lt_errtab.
      WAIT UP TO 2 SECONDS.
      CALL FUNCTION 'FI_ITEMS_MASS_CHANGE'
        EXPORTING
          s_bseg     = s_bseg
        IMPORTING
          errtab     = lt_errtab
        TABLES
          it_buztab  = lt_buztab
          it_fldtab  = lt_fldtab
        EXCEPTIONS
          bdc_errors = 1
          OTHERS     = 2.
      IF sy-subrc <> 0.
* Implement suitable error handling here
      ENDIF.
    ENDIF.
  ENDLOOP.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form f_compare_data
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM f_compare_data USING     p_s_data    TYPE any
                    CHANGING  ch_s_data_x TYPE any.

  DATA:
    lo_table_descr  TYPE REF TO cl_abap_tabledescr,
    lo_struct_descr TYPE REF TO cl_abap_structdescr,
    lo_data         TYPE REF TO data,
    it_columns      TYPE abap_compdescr_tab.

  CREATE DATA lo_data LIKE p_s_data.

  lo_struct_descr ?= cl_abap_structdescr=>describe_by_data_ref( lo_data ).
  it_columns = lo_struct_descr->components.

  LOOP AT it_columns ASSIGNING FIELD-SYMBOL(<fs_field>).

    ASSIGN COMPONENT <fs_field>-name OF STRUCTURE p_s_data TO FIELD-SYMBOL(<fs_comp_data>).
    ASSIGN COMPONENT <fs_field>-name OF STRUCTURE ch_s_data_x  TO FIELD-SYMBOL(<fs_comp_x>).

    CHECK:
        <fs_comp_data>   IS ASSIGNED,
*        <fs_comp_source>    IS ASSIGNED,
        <fs_comp_x>         IS ASSIGNED.

    IF <fs_comp_data> IS NOT INITIAL.
      <fs_comp_x> = abap_true.
    ELSE.
      <fs_comp_x> = abap_false.
    ENDIF.

    UNASSIGN:  <fs_comp_data>, <fs_comp_x>.

  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form F_HANDLE_COST_CENTER
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> TIMEDEPENDENTDATA
*&---------------------------------------------------------------------*
FORM f_handle_cost_center  USING p_s_timedependentdata TYPE bapi1022_feglg003
                                 p_v_bukrs             TYPE bukrs.

  DATA:
    lv_kokrs TYPE tka02-kokrs,
    lt_csks  TYPE STANDARD TABLE OF csks_ex.

  CALL FUNCTION 'KOKRS_GET_FROM_BUKRS'
    EXPORTING
      i_bukrs        = p_v_bukrs
    IMPORTING
      e_kokrs        = lv_kokrs
    EXCEPTIONS
      no_kokrs_found = 1
      OTHERS         = 2.
  IF sy-subrc EQ 0.

    CALL FUNCTION 'K_COSTCENTER_SELECT_SINGLE'
      EXPORTING
        kokrs           = lv_kokrs
        kostl           = p_s_timedependentdata-costcenter
        date_from       = sy-datum
      TABLES
        it_csks_ex      = lt_csks
      EXCEPTIONS
        no_record_found = 1
        OTHERS          = 2.
    IF sy-subrc EQ 0.

      LOOP AT lt_csks ASSIGNING FIELD-SYMBOL(<fs_csks>).

*        p_s_timedependentdata-profit_ctr = <fs_csks>-prctr.
        p_s_timedependentdata-bus_area   = <fs_csks>-gsber.

        EXIT.

      ENDLOOP.

    ENDIF.
  ENDIF.


ENDFORM.
