*--------------------------------------------------------------------*
*               P R O J E T O    A G I R - T A E S A                 *
*--------------------------------------------------------------------*
* Consultoria .....: I N T E C H P R O                               *
* Res. ABAP........: Marcelo Alvares                                 *
* Res. Funcional...: Marcelo Alvares                                 *
* Módulo...........: BUPA Business Partner                           *
* Programa.........: ZRAG_CARGA_CLIENTES                             *
* Transação........:                                                 *
* Tipo de Programa.: REPORT                                          *
* Request     .....: S4DK902827                                      *
* Objetivo.........: Migração carga inicial de clientes migrados     *
*--------------------------------------------------------------------*
* Change Control:                                                    *
* Version | Date      | Who                 |   What                 *
*    1.00 | 27/09/18  | Marcelo Alvares     |   Versão Inicial       *
**********************************************************************
*&---------------------------------------------------------------------*
*& Include          ZRAG_CARGA_CLIENTES_TOP
*&---------------------------------------------------------------------*
REPORT zrag_carga_clientes.

TABLES: t001, sscrfields.
*----------------------------------------------------------------------
* Types declaration
*----------------------------------------------------------------------
TYPES :

  BEGIN OF ty_s_central_data,
    kunnr          TYPE kunnr,
    grouping       TYPE bu_group,
    ktokd          TYPE ktokd,
    name1          TYPE bu_nameor1,
    name2          TYPE bu_nameor2,
    name3          TYPE bu_nameor3,
    name4          TYPE bu_nameor4,
    anred          TYPE anred,
    firstname      TYPE name_first,
    lastname       TYPE name_last,
    middlename     TYPE namemiddle,
    birthname      TYPE tf_birth_name_ps,
    searchterm1    TYPE ad_sort1,
    searchterm2    TYPE ad_sort2,
    lifnr          TYPE lifnr,
    konzs          TYPE konzs,
    vbund          TYPE vbund,
    street         TYPE ad_street,
    house_no       TYPE ad_hsnm1,
*    city2          TYPE ad_city2,
    district       TYPE ad_city2,
    home_city      TYPE ad_city3,
    postl_cod1     TYPE ad_pstcd1,
    city           TYPE ad_city1,
    country        TYPE land1,
    region         TYPE regio,
    time_zone      TYPE timezone,
    lzone          TYPE lzone,
    building       TYPE ad_bldng,
    roomnumber     TYPE ad_roomnum,
    floor          TYPE ad_floor,
    name_co        TYPE ad_name_co,
    str_suppl1     TYPE ad_strspp1,
    str_suppl2     TYPE ad_strspp2,
    house_no2      TYPE ad_hsnm2,
    str_suppl3     TYPE ad_strspp3,
    location       TYPE ad_lctn,
    taxjurcode     TYPE ad_txjcd,
    suppress_txjcd TYPE char1,
    po_box         TYPE ad_pobx,
    post_code2     TYPE ad_pstcd2,
    po_box_loc     TYPE ad_pobxloc,
    po_box_cty     TYPE ad_pobxcty,
    po_box_reg     TYPE ad_pobxreg,
    post_code3     TYPE ad_pstcd3,
    langu_corr     TYPE syst_langu,
    telnr_long     TYPE ad_telnrlg,
    telnr_long_2   TYPE ad_telnrlg,
    telnr_long_3   TYPE ad_telnrlg,
    mobile_long    TYPE ad_telnrlg,
    mobile_long_2  TYPE ad_telnrlg,
    mobile_long_3  TYPE ad_telnrlg,
    faxnr_long     TYPE ad_fxnrlng,
    faxnr_long_2   TYPE ad_fxnrlng,
    faxnr_long_3   TYPE ad_fxnrlng,
    smtp_addr      TYPE ad_smtpadr,
    smtp_addr_2    TYPE ad_smtpadr,
    smtp_addr_3    TYPE ad_smtpadr,
    uri_typ        TYPE ad_uritype,
    uri_addr       TYPE ad_uriscr,
    dtams          TYPE dtams,
    dtaws          TYPE dtaws,
    knrza          TYPE knrza,
    niels          TYPE niels,
    rpmkr          TYPE rpmkr,
    kukla          TYPE kukla,
    hzuor          TYPE hzuor,
    bran1          TYPE bran1_d,
    bran2          TYPE bran2,
    bran3          TYPE bran3,
    bran4          TYPE bran4,
    bran5          TYPE bran5,
    sperr          TYPE sperr,
    collman        TYPE char1,
    stcd1          TYPE stcd1,
    stcd2          TYPE stcd2,
    stcd3          TYPE stcd3,
    stcd4          TYPE stcd4,
*    name1          TYPE name1_gp,
*    name2          TYPE name2_gp,
*    name3          TYPE name3_gp,
*    name4          TYPE name4_gp,
  END OF ty_s_central_data,

  BEGIN OF ty_s_sales_data, "Extração dos dados de vendas (Mestre de Clientes) Ativo
    kunnr   TYPE kunnr,     "Nº cliente CHAR 10
    vkorg   TYPE vkorg,     "Organização de vendas CHAR 4
    vtweg   TYPE vtweg,     "Canal de distribuição CHAR 2
    spart   TYPE spart,     "Setor de atividade CHAR 2
    kdgrp   TYPE kdgrp,     "Grupo de clientes CHAR 2
    bzirk   TYPE bzirk,     "Região de vendas CHAR 6
    vkbur   TYPE vkbur,     "Escritório de vendas CHAR 4
    vkgrp   TYPE vkgrp,     "Equipe de vendas CHAR 3
    eikto   TYPE eikto,     "Nosso nº conta no cliente/fornecedore CHAR 12
    awahr   TYPE awahr,     "Item: probabilidade de se transformar em ordem NUMC 3
    klabc   TYPE klabc,     "Classificação de clientes (análise ABC) CHAR 2
    waers   TYPE waers_v02d, "Moeda CUKY 5
    konda   TYPE konda,     "Grupo de preço cliente CHAR 2
    pltyp   TYPE pltyp,     "Categoria de lista de preços CHAR 2
    kalks   TYPE kalks,     "Esquema cliente (p/determinação do esquema de cálculo) CHAR 1
    versg   TYPE stgku,     "Grupo estatístico cliente CHAR 1
    lprio   TYPE lprio,     "Prioridade de remessa NUMC 2
    kzazu   TYPE kzazu_d,   "Código de agrupamento de ordens CHAR 1
    vsbed   TYPE vsbed,     "Condição de expedição CHAR 2
    vwerk   TYPE dwerk_ext, "Centro fornecedor (próprio ou externo) CHAR 4
    autlf   TYPE autlf,     "Fornecimento completo por ordem: obrigatório ? CHAR 1
    kztlf   TYPE kztlf,     "Remessa parcial a nível de item CHAR 1
    perfk   TYPE perfk,     "Datas do faturamento (identificação de calendário) CHAR 2
    incov   TYPE char4,     "
    inco1   TYPE inco1,     "Incoterms parte 1 CHAR 3
    inco2   TYPE inco2,     "Incoterms parte 2 CHAR 28
    inco3_l TYPE char70,    "Campo de caracteres de comprimento 70 CHAR 70
    zterm   TYPE dzterm,    "Chave de condições de pagamento CHAR 4
    ktgrd   TYPE ktgrd,     "Grupo de classificação contábil do cliente CHAR 2
    aufsd   TYPE aufsd_v,   "Bloqueio de ordem para cliente (área de vendas) CHAR 2
    lifsd   TYPE lifsd_v,   "Bloqueio de remessa p/cliente (Vendas e Distribuição) CHAR 2
    faksd   TYPE faksd_v,   "Bloqueio de faturamento para cliente (nível VD) CHAR 2
  END OF ty_s_sales_data,

  BEGIN OF ty_s_sales_partner,
    kunnr TYPE    kunnr,   "Nº cliente CHAR 10
    vkorg TYPE    vkorg,   "Organização de vendas CHAR 4
    vtweg TYPE    vtweg,   "Canal de distribuição CHAR 2
    spart TYPE    spart,   "Setor de atividade  CHAR 2
    parvw TYPE    parvw,   "Função do parceiro  CHAR 2
    kunn2 TYPE    kunn2,   "Nº cliente do parceiro de negócios CHAR 10
    lifnr TYPE    lifnr,   "Nº conta do fornecedor CHAR 10
    pernr TYPE    pernr_d, "Nº pessoal NUMC 8
    parnr TYPE    parnr,   "Nº pessoa de contato NUMC 10
    defpa TYPE    defpa,   "Parceiro default CHAR s1
    knref TYPE    knref,   "Denom.parceiro negócios específica do cliente (cent., dpst.) CHAR    30
  END OF ty_s_sales_partner,

  BEGIN OF ty_s_company_data,
    bukrs   TYPE    bukrs,      " Empresa                               CHAR    4
    kunnr   TYPE    kunnr,      " Nº cliente                            CHAR    10
    sperr   TYPE    sperb_b,    " Bloqueio de contabilização p/empresa  CHAR    1
    zahls   TYPE    dzahls,     " Chave de bloqueio para pagamento      CHAR    1
    altkn   TYPE    altkn,      " Nº antigo de registro mestre          CHAR    10
    mahna   TYPE    mahna,      " Procedimento de advertência           CHAR    4
    mansp   TYPE    mansp,      " Bloqueio de advertências              CHAR    1
    knrma   TYPE    knrma,      " Nº conta do destinatário da advertência   CHAR    10
    madat   TYPE    madat,      " Data da última advertência            DATS    8
    gmvdt   TYPE    gmvdt,      " Data do processo judicial de cobrança DATS    8
    mahns   TYPE    mahns_d,    " Nível de advertência                  NUMC    1
    busab_d TYPE    busab_ma,   " Responsável advertências              CHAR    2
    busab   TYPE    busab,      " Responsável da contabilidade          CHAR    2
    eikto   TYPE    eikto_d,    " Nosso nº conta no cliente             CHAR    12
    tlfns   TYPE    tlfns,      " Nº telefone do responsável do parceiro de negóciosCHAR    30
    tlfxs   TYPE    tlfxs,      " Nº telefax do responsável do parceiro de negócios CHAR    31
    xdezv   TYPE    xdezv,      " Código: processamento descentralizado?            CHAR    1
    kverm   TYPE    kverm,      " Observação                            CHAR    30
    perkz   TYPE    perkz_knb1, " Variante de fatura coletiva           CHAR    1
    zterm   TYPE    dzterm,     " Chave de condições de pagamento           CHAR    4
    zwels   TYPE    dzwels,     " Lista de formas de pagamentos a considerar    CHAR    10
    hbkid   TYPE    hbkid,      " Chave breve de um banco da empresa    CHAR    5
    togru   TYPE    togru,      " Grupo de tolerância para o parceiro de negócios/cta.Razão CHAR    4
    xverr   TYPE    xverr_knb1, " Código: compensação entre cliente e fornecedor?   CHAR    1
    xzver   TYPE    xzver,      " Código: registrar histórico de pagamentos ?   CHAR    1
    xpore   TYPE    xpore,      " Código: pagamento individual das partidas ?   CHAR    1
    xedip   TYPE    xedip,      " Código: enviar aviso de pagamento via EDI     CHAR    1
    knrzb   TYPE    knrzb,      " Nº conta de um pagador divergente             CHAR    10
    akont   TYPE    akont,      " Cta.de reconciliação na contabilidade geral   CHAR    10
    knrze   TYPE    knrze,      " Nº conta da sede (para contas de filiais)     CHAR    10
    zuawa   TYPE    dzuawa,     " Chave para a ordenação por nºs atribuição     CHAR    3
    fdgrv   TYPE    fdgrv,      " Grupo de administração de tesouraria          CHAR    10
  END OF ty_s_company_data,

  BEGIN OF ty_s_tax_classifications,
    kunnr TYPE    kunnr,      "Nº cliente                                           CHAR    10
    aland TYPE    aland,      "País fornecedor (país onde a mercadoria é expedida)  CHAR    3
    tatyp TYPE    tatyp,      "Ctg.imposto (sales tax, federal sales tax,...)       CHAR    4
    taxkd TYPE    takld,      "Classificação fiscal do cliente                      CHAR    1
  END OF ty_s_tax_classifications,

  BEGIN OF ty_s_contact_person,
    kunnr      TYPE    kunnr,       "Nº cliente   CHAR10
    parnr      TYPE    parnr,       "Nº pessoa de contato   NUMC10
    title      TYPE    char80,      "Char 80   CHAR80
    namev      TYPE    namev_vp,    "1º nome   CHAR35
    lname      TYPE    char40,      "Character field of length 40   CHAR40
    langucorr  TYPE    char80,      "Char 80   CHAR80
    abtnr      TYPE    abtnr_pa,    "Departamento da pessoa de contato   CHAR4
    pafkt      TYPE    pafkt,       "Função da pessoa de contato   CHAR2
    pavip      TYPE    pavip,       "Parceiro VIP   CHAR1
    country    TYPE    land1,       "Chave do país   CHAR3
    post_code1 TYPE    ad_pstcd1,   "Código postal da localidade   CHAR10
    city1      TYPE    ad_city1,    "Local   CHAR40
    street     TYPE    ad_street,   "Rua   CHAR60
    house_num1 TYPE    ad_hsnm1,    "Nº   CHAR10
    tel_number TYPE    ad_tlnmbr,   "Nº telefone: código telefónico+nº   CHAR30
    mobile_no  TYPE    char30,      "30 caracteres   CHAR30
    fax_number TYPE    ad_fxnmbr,   "Nº de fax: prefixo + número   CHAR30
    smtp_addr  TYPE    ad_smtpadr,  "Endereço de e-mail   CHAR241
  END OF ty_s_contact_person,

  BEGIN OF ty_s_tax_numbers,
    kunnr   TYPE  kunnr,        " Nº cliente        CHAR    10
    taxtype TYPE  bptaxtype,    " Tipo de nº fiscal CHAR    4
    taxnum  TYPE  bptaxnum,     " Nº ID fiscal para parceiro de negócios    CHAR    20
  END OF ty_s_tax_numbers,

  BEGIN OF ty_s_contact_numbers,
    number_bp_contact TYPE bu_partner,
    guid_bp_contact   TYPE bu_partner_guid,
  END OF ty_s_contact_numbers,

  BEGIN OF ty_s_alv,
    status    TYPE tp_icon,
    kunnr     TYPE kunnr,      "Nº cliente CHAR 10
    bp_number TYPE bu_partner,
*    namorg    TYPE bu_nameor1,
  END OF   ty_s_alv,

  BEGIN OF ty_s_t001,
    bukrs TYPE bukrs,
  END OF   ty_s_t001,

  ty_t_contact_numbers TYPE STANDARD TABLE OF ty_s_contact_numbers,
  ty_t_central_data    TYPE STANDARD TABLE OF ty_s_central_data,
  ty_t_sales_data      TYPE STANDARD TABLE OF ty_s_sales_data,
  ty_t_sales_partner   TYPE STANDARD TABLE OF ty_s_sales_partner,
  ty_t_company_data    TYPE STANDARD TABLE OF ty_s_company_data,
  ty_t_tax_classf      TYPE STANDARD TABLE OF ty_s_tax_classifications,
  ty_t_contact_person  TYPE STANDARD TABLE OF ty_s_contact_person,
  ty_t_tax_numbers     TYPE STANDARD TABLE OF ty_s_tax_numbers.

*TYPES: BEGIN OF ty_e_alv.
*    INCLUDE TYPE ty_e_result.
*    INCLUDE TYPE ty_e_upload_layout.
*TYPES: END OF   ty_e_alv.

DATA:
  BEGIN OF s_upload_data,
    central_data   TYPE  TABLE OF ty_s_central_data WITH NON-UNIQUE SORTED KEY key_kunnr COMPONENTS kunnr,
    sales_data     TYPE  TABLE OF ty_s_sales_data   WITH NON-UNIQUE SORTED KEY key_kunnr COMPONENTS kunnr,
    sales_partner  TYPE  ty_t_sales_partner,
    company_data   TYPE  TABLE OF ty_s_company_data WITH NON-UNIQUE SORTED KEY key_kunnr COMPONENTS kunnr,
    tax_classf     TYPE  ty_t_tax_classf,
    contact_person TYPE  ty_t_contact_person,
    tax_numbers    TYPE  ty_t_tax_numbers,
  END OF s_upload_data,

* Structure to identify the relation of BP with client, created or not
  BEGIN OF s_bp_numbers,
    bp_number       TYPE bu_partner,
    bp_guid         TYPE bu_partner_guid,
    kunnr           TYPE kunnr,
    task_bp         TYPE bus_ei_object_task,
    task_customer   TYPE bus_ei_object_task,
    create_customer TYPE boole_d,
    errors_found    TYPE errors_found,
    contact         TYPE ty_t_contact_numbers,
  END OF s_bp_numbers.

*----------------------------------------------------------------------
* Variables declaration
*----------------------------------------------------------------------
"   Good practices do not use global variables!!!
"   Make the appropriate statements in class
*----------------------------------------------------------------------
* Constants declaration
*----------------------------------------------------------------------
CONSTANTS:
  cc_grouping_naco         TYPE bu_group           VALUE 'NACO',       "Clientes ONS
  cc_msg_error             TYPE smesg-msgty        VALUE 'E',          "Type of message (E)
  cc_pais_iso_br           TYPE intca              VALUE 'BR',         "Codigo ISO BR telefone
  cc_parameter_id          TYPE memoryid           VALUE 'ZBUPA_FILE_01',
  cc_rolecategory_contact  TYPE bu_partnerrolecat  VALUE 'BUP001',     "Pessoa de contato
  cc_rolecategory_client   TYPE bu_partnerrolecat  VALUE 'FLCU00',     "Cliente (contab.financ.)
  cc_rolecategory_client2  TYPE bu_partnerrolecat  VALUE 'FLCU01',     "Cliente (Org. Vendas)
  cc_taxtype_cnpj          TYPE bptaxtype          VALUE 'BR1',        "BR1  Brasil: nº CNPJ
  cc_taxtype_insc_estadual TYPE bptaxtype          VALUE 'BR3',        "BR3  Brasil: inscrição estadual
  cc_title_key_3           TYPE ad_title           VALUE '0003',       "Forma de Tratamento "Empresa"
  cc_languiso_pt           TYPE laiso              VALUE 'PT',         "Código de idiomas ISO de 2 dígitos
  cc_object_task_update    TYPE bus_ei_object_task VALUE 'U',          "
  cc_object_task_insert    TYPE bus_ei_object_task VALUE 'I'.

*----------------------------------------------------------------------
*   SELECTION PARAMETERS
*----------------------------------------------------------------------
SELECTION-SCREEN BEGIN OF BLOCK b01 WITH FRAME TITLE TEXT-t01.
PARAMETERS  p_file TYPE rlgrap-filename OBLIGATORY MEMORY ID cc_parameter_id ##EXISTS.
SELECTION-SCREEN: FUNCTION KEY 1.
SELECTION-SCREEN SKIP.

*SELECTION-SCREEN BEGIN OF BLOCK b011 WITH FRAME TITLE TEXT-t02.
*SELECT-OPTIONS : s_bukrs  FOR  t001-bukrs.
*SELECTION-SCREEN END OF BLOCK b011.

*SELECTION-SCREEN SKIP.
*PARAMETERS p_test TYPE xtest AS CHECKBOX DEFAULT abap_true.
SELECTION-SCREEN END OF BLOCK b01.
