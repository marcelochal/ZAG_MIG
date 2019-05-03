*--------------------------------------------------------------------*
*               P R O J E T O    A G I R - T A E S A                 *
*--------------------------------------------------------------------*
* Consultoria .....: I N T E C H P R O                               *
* Res. ABAP........: Marcelo Alvares                                 *
* Res. Funcional...: Marcelo Alvares                                 *
* Módulo...........: FI                                              *
* Programa.........: ZRAG_CARGA_ACC_POST                             *
* Transação........: N/A                                             *
* Tipo de Programa.: REPORT                                          *
* Request..........:                                                 *
* Objetivo.........: Carga de lançamentos contabeis faturas e saldos *
*--------------------------------------------------------------------*
* Change Control:                                                    *
* Version | Date      | Who                 |   What                 *
*    1.00 | 21/11/18  | Marcelo Alvares     |   Versão Inicial       *
**********************************************************************
*&--------------------------------------------------------------------*
*& Include          ZRAG_CARGA_ACC_POST_TOP
*&--------------------------------------------------------------------*
REPORT zrag_carga_acc_post LINE-SIZE 120.

TYPE-POOLS:
    icon.

TABLES:
*  t001,
  sscrfields.

TYPES:

  BEGIN OF ty_s_gl_balance,                 "Carga de saldos
    comp_code  TYPE bapiacap09-comp_code,
    gl_account TYPE bapiacgl09-gl_account,  "Conta do Razão da contabilidade geral
    bus_area   TYPE bapiacap09-bus_area,    "Divisão
    costcenter TYPE bapiacgl09-costcenter,  " Cost Center
    amt_doccur TYPE bapiaccr09-amt_doccur,  "Montante em moeda do documento
  END OF ty_s_gl_balance,

  BEGIN OF ty_s_bukrs,
    comp_code TYPE bapiacap09-comp_code,
  END OF ty_s_bukrs,

* Accounts payable
  BEGIN OF ty_s_accounts_payable,
    comp_code       TYPE bapiacap09-comp_code,    "Empresa
    vendor_no       TYPE bapiacap09-vendor_no,    "Nº conta do fornecedor
    ref_doc_no      TYPE bapiache09-ref_doc_no,   "Nº documento de referência
    sp_gl_ind       TYPE bapiacap09-sp_gl_ind,    "Código do Razão Especial
    doc_date        TYPE bapiache09-doc_date,     "Data no documento
    pstng_date      TYPE bapiache09-pstng_date,   "Data de lançamento no documento
    header_txt      TYPE bapiache09-header_txt,   "Texto de cabeçalho de documento
    item_text       TYPE bapiacap09-item_text,    "Texto do item
    amt_doccur      TYPE bapiaccr09-amt_doccur,   "Montante em moeda de pagamento
    amt_doccur_mi   TYPE bapiaccr09-amt_doccur,   "Montante em Moeda Interna
    amt_doccur2     TYPE bapiaccr09-amt_doccur,   "Montante MI2
    amt_doccur3     TYPE bapiaccr09-amt_doccur,   "Montante MI3
    currency        TYPE bapiaccr09-currency,
    hwaer           TYPE bapiaccr09-currency,
    hwae2           TYPE bapiaccr09-currency,       "Código da moeda
    hwae3           TYPE bapiaccr09-currency,       "Código da moeda
    tax_code        TYPE bapiacap09-tax_code,       "Código do IVA
    profit_ctr      TYPE bapiacap09-profit_ctr,     "Centro de lucro
    fkber           TYPE fkber,                     "Área funcional
    pmnttrms        TYPE bapiacap09-pmnttrms,       "Chave de condições de pagamento
    bline_date      TYPE bapiacap09-bline_date,     "bline_date "Data base para cálculo do vencimento
    dzbd1t          TYPE bapiacap09-dsct_days1,     "Dias de desconto 1
    dzbd1p          TYPE dzbd1p,                    "Taxa de desconto 1
    dzbd2t          TYPE dzbd2t,                    "Dias de desconto 2
    dzbd2p          TYPE dzbd2p,                    "Taxa de desconto 2
    dzbd3t          TYPE dzbd3t,                    "Prazo para condição líquida
    bapiskfbt       TYPE bapiskfbt,                 "Montante com direito a desconto em moeda do documento
    pmnt_block      TYPE bapiacap09-pmnt_block,     "Chave para o bloqueio de pagamento
    pymt_meth       TYPE bapiacap09-pymt_meth,      "Forma de pagamento
    partner_bk      TYPE bapiacap09-partner_bk,     "Tipo de banco do parceiro
    dzuonr          TYPE dzuonr,                    "Nº atribuição
    bank_id         TYPE bapiacap09-bank_id,        "Chave breve de um banco da empresa
    housebankacctid TYPE bapiacap09-housebankacctid, "Chave breve das coordenadas de uma conta
    businessplace   TYPE bapiacap09-businessplace,  "Filial
    belnr_d         TYPE belnr_d,                   " Nº documento de um documento contábil
    gjahr           TYPE gjahr,                     " Exercício
    saknr           TYPE saknr,                     "
    bus_area        TYPE bapiacap09-bus_area,       " Divisão
    bschl           TYPE bschl,                     " Chave de lançamento
    doc_type        TYPE bapiache09-doc_type,       " Tipo de documento
    vbund           TYPE vbund,                     " Nº sociedade
    bline_date1     TYPE bapiacap09-bline_date,     " Vencimento líquido
*    empfb           TYPE empfb,                     " Recebedor de pagamento/pagador
    alt_payee       TYPE empfb,                     " Recebedor de pagamento/pagador
    shkzg           TYPE shkzg,                     " Código débito/crédito
    ebeln           TYPE ebeln,                     " Nº do documento de compras
    ebelp           TYPE ebelp,                     " Nº item do documento de compra
    esrnr           TYPE esrnr,                     " Nº participante NDR
    esrre           TYPE esrre,                     " Nº referência NDR (nota de depósito com nº referência)
    esrpz           TYPE esrpz,                     " Dígito de controle de nota de depósito c/nº referência (NDR)
    brcde           TYPE brcde,                     " Representação númerica de cód.barras em form.pagamento
    augbl           TYPE augbl,                     " Nº documento de compensação
    augdt           TYPE augdt,                     " Data de compensação
    qbshb           TYPE qbshb_x8,                  " Montante de imposto retido NA fonte em moeda DO documento
    qsfbt           TYPE qsfbt_x8,                  " Montante isento de irf em moeda DO documento
    qsshb           TYPE qsshb_x8,                  " Montante BASE de imposto retido NA fonte em moeda documento
  END OF ty_s_accounts_payable,

* Accounts receivable ACCOUNTRECEIVABLE LIKE BAPIACAR09 OPTIONAL
  BEGIN OF ty_s_accounts_receivable,
    comp_code       TYPE bapiacar09-comp_code,    "Empresa
    customer        TYPE bapiacar09-customer,     "Nº cliente
    ref_doc_no      TYPE bapiache09-ref_doc_no,   "Nº documento de referência
    sp_gl_ind       TYPE bapiacar09-sp_gl_ind,    "Código do Razão Especial
    doc_date        TYPE bapiache09-doc_date,     "Data no documento
    pstng_date      TYPE bapiache09-pstng_date,   "Data de lançamento no documento
    header_txt      TYPE bapiache09-header_txt,   "Texto de cabeçalho de documento
    item_text       TYPE bapiacar09-item_text,    "Texto do item
    amt_doccur      TYPE bapiaccr09-amt_doccur,   "Montante em moeda de pagamento
    amt_doccur_mi   TYPE bapiaccr09-amt_doccur,   "Montante em Moeda Interna
*    amt_doccur2     TYPE bapiaccr09-amt_doccur,   "Montante MI2
*    amt_doccur3     TYPE bapiaccr09-amt_doccur,   "Montante MI3
    currency        TYPE bapiaccr09-currency,
    hwaer           TYPE bapiaccr09-currency,
*    hwae2           TYPE bapiaccr09-currency,     "Código da moeda
*    hwae3           TYPE bapiaccr09-currency,     "Código da moeda
    tax_code        TYPE bapiacar09-tax_code,     "Código do IVA
    profit_ctr      TYPE bapiacar09-profit_ctr,   "Centro de lucro
    fkber           TYPE fkber,                   "Área funcional
    pmnttrms        TYPE bapiacar09-pmnttrms,     "Chave de condições de pagamento
    bline_date      TYPE bapiacar09-bline_date,   "bline_date "Data base para cálculo do vencimento
    dzbd1t          TYPE bapiacar09-dsct_days1,   "Dias de desconto 1
    dzbd1p          TYPE dzbd1p,                  "Taxa de desconto 1
    dzbd2t          TYPE dzbd2t,                  "Dias de desconto 2
    dzbd2p          TYPE dzbd2p,                  "Taxa de desconto 2
    dzbd3t          TYPE dzbd3t,                  "Prazo para condição líquida
    bapiskfbt       TYPE bapiskfbt,               "Montante com direito a desconto em moeda do documento
    pmnt_block      TYPE bapiacar09-pmnt_block,   "Chave para o bloqueio de pagamento
    pymt_meth       TYPE bapiacar09-pymt_meth,    "Forma de pagamento
    dunn_key        TYPE bapiacar09-dunn_key,     "Chave de advertência
    alloc_nmbr      TYPE bapiacar09-alloc_nmbr,   "Nº atribuição
    bank_id         TYPE bapiacar09-bank_id,      "Chave breve de um banco da empresa
    housebankacctid TYPE bapiacar09-housebankacctid, "Chave breve das coordenadas de uma conta
    businessplace   TYPE bapiacar09-businessplace, "Filial
    belnr_d         TYPE belnr_d,                 "Nº documento de um documento contábil
    gjahr           TYPE gjahr,                   "Exercício
*    saknr           TYPE saknr,                   "
    bus_area        TYPE bapiacar09-bus_area,     "Divisão
    bschl           TYPE bschl,                   "Chave de lançamento
    doc_type        TYPE bapiache09-doc_type,     "Tipo de documento
    bline_date1     TYPE bapiacar09-bline_date,   "Vencimento líquido
    saknr           TYPE saknr,
    anfbn           TYPE anfbn,                   "Letra
    vbund           TYPE vbund,                   "Nº sociedade
  END OF ty_s_accounts_receivable,
**********************************************************************

  BEGIN OF ty_s_ps_balance,
    comp_code   TYPE bapiache09-comp_code,   "Empresa
    gl_account  TYPE bapiacgl09-gl_account,  "Conta do Razão da contabilidade geral
    pstng_date  TYPE bapiache09-pstng_date,  "Data de lançamento no documento
    doc_date    TYPE bapiache09-doc_date,    "Data no documento
    type_doc    TYPE bapiache09-doc_type,    "Tipo de documento
    currency    TYPE bapiaccr09-currency,    "Código da moeda
    ref_doc_no  TYPE bapiache09-ref_doc_no,  "Nº documento de referência
    header_txt  TYPE bapiache09-header_txt,  "Texto de cabeçalho de documento
    amt_doccur  TYPE bapiaccr09-amt_doccur,  "Montante em moeda do documento
*    amt_doccur  TYPE c LENGTH 27,            "Montante em moeda do documento
    shkzg       TYPE shkzg,                  "Código débito/crédito
    bus_area    TYPE bapiacgl09-bus_area,    "Divisão
    alloc_nmbr  TYPE bapiacgl09-alloc_nmbr,  "Nº atribuição
    item_text   TYPE bapiacgl09-item_text,   "Texto do item
    wbs_element TYPE bapiacgl09-wbs_element, "Elemento do plano da estrutura do projeto (elemento PEP)
    network     TYPE bapiacgl09-network,     "Nº diagrama de rede para classificação contábil
    activity    TYPE bapiacgl09-activity,    "Nº operação
    quantity    TYPE bapiacgl09-quantity,    "Quantidade
*    quantity_c  TYPE c LENGTH 10,            "Quantidade
    base_uom    TYPE bapiacgl09-base_uom,    "Unidade de medida básica
    material    TYPE bapiacgl09-material,    "Número do material (18 caracteres)
*    costcenter  TYPE bapiacgl09-costcenter,  " Cost Center
*    material    TYPE c LENGTH 18,           "Número do material (18 caracteres)
*    quantity    TYPE bapiacgl09-quantity,    "Quantidade
*    dummy       TYPE c,
  END OF ty_s_ps_balance,

  BEGIN OF ty_tbsl,
    bschl TYPE tbsl-bschl,
    shkzg TYPE tbsl-shkzg,
    koart TYPE tbsl-koart,
  END OF ty_tbsl,

  BEGIN OF ty_s_ska1,
    ktopl          TYPE ska1-ktopl,             "Plano de contas
    saknr          TYPE ska1-saknr,             "Nº conta do Razão
    glaccount_type TYPE ska1-glaccount_type,    "Tipo de uma conta do Razão
    xbilk          TYPE ska1-xbilk,             "Código: a conta é uma conta do balanço?
    sakan          TYPE ska1-sakan,             "Nº conta do Razão em comprimento significativo
    bilkt          TYPE ska1-bilkt,             "Nº conta do grupo
    gvtyp          TYPE ska1-gvtyp,             "Tipo de conta de resultados
    ktoks          TYPE ska1-ktoks,             "Grupo de contas: contas do Razão
    mustr          TYPE ska1-mustr,             "Nº conta-modelo
    vbund          TYPE ska1-vbund,             "Nº sociedade parceira
    xloev          TYPE ska1-xloev,             "Código: conta marcada para eliminação?
    xspea          TYPE ska1-xspea,             "Código: conta bloqueada para criação?
    xspeb          TYPE ska1-xspeb,             "Código: conta bloqueada para lançamento?
    xspep          TYPE ska1-xspep,             "Código: conta bloqueada para planejamento?
    mcod1          TYPE ska1-mcod1,             "Critério de pesquisa para utilização matchcode
    func_area      TYPE ska1-func_area,         "Área funcional
    katyp          TYPE skcskb-katyp,           "Categoria de classe de custo
    txt20          TYPE skat-txt20,             "Texto das contas do Razão
    txt50          TYPE skat-txt50,             "Texto descritivo das contas do Razão
  END OF ty_s_ska1,

  BEGIN OF ty_s_skb1,
    bukrs     TYPE    skb1-bukrs,  "Empresa
    saknr     TYPE    skb1-saknr,  "Nº conta do Razão
    begru     TYPE    skb1-begru,  "Grupo autorizações
    busab     TYPE    skb1-busab,  "Sigla do responsável pela contabilidade
    datlz     TYPE    skb1-datlz,  "Data CPU da última execução do programa de cálculo de juros
    fdgrv     TYPE    skb1-fdgrv,  "Grupo de administração de tesouraria
    fdlev     TYPE    skb1-fdlev,  "Nível de tesouraria
    fipls     TYPE    skb1-fipls,  "Item do plano financeiro
    fstag     TYPE    skb1-fstag,  "Grupo de status do campo
    hbkid     TYPE    skb1-hbkid,  "Chave breve de um banco da empresa
    hktid     TYPE    skb1-hktid,  "Chave breve das coordenadas de uma conta
    kdfsl     TYPE    skb1-kdfsl,  "Chave para diferenças de câmbio em contas de ME
    mitkz     TYPE    skb1-mitkz,  "A conta é conta coletiva
    mwskz     TYPE    skb1-mwskz,  "Categoria fiscal no mestre de contas
    stext     TYPE    skb1-stext,  "Texto adicional conta do Razão
    vzskz     TYPE    skb1-vzskz,  "Código de cálculo de juros
    waers     TYPE    skb1-waers,  "Moeda da conta
    wmeth     TYPE    skb1-wmeth,  "Código: administração da conta em sistema externo
    xgkon     TYPE    skb1-xgkon,  "Conta de entrada de caixa / conta de saída de caixa
    xintb     TYPE    skb1-xintb,  "Código: conta só pode ser lançada automaticamente?
    xkres     TYPE    skb1-xkres,  "Código: possível exibir partidas individuais via conta?
    xloeb     TYPE    skb1-xloeb,  "Código: conta marcada para eliminação?
    xnkon     TYPE    skb1-xnkon,  "Código: ClassCont.posterior em lançamentos automáticos?
    xopvw     TYPE    skb1-xopvw,  "Código: administração de partidas em aberto?
    xspeb     TYPE    skb1-xspeb,  "Código: conta bloqueada para lançamento?
    zindt     TYPE    skb1-zindt,  "Data fixada do último cálculo de juros
    zinrt     TYPE    skb1-zinrt,  "Periodicidade dos juros em meses
    zuawa     TYPE    skb1-zuawa,  "Chave para a ordenação por nºs atribuição
    altkt     TYPE    skb1-altkt,  "Nº conta alternativo na empresa
    xmitk     TYPE    skb1-xmitk,  "Código: conta de reconciliação admite entrada de lançamento?
    recid     TYPE    skb1-recid,  "Tipo de custos
    fipos     TYPE    skb1-fipos,  "Item financeiro
    xmwno     TYPE    skb1-xmwno,  "Código: código de imposto não é campo obrigatório
    xsalh     TYPE    skb1-xsalh,  "Código: administrar saldos só em moeda interna
    bewgp     TYPE    skb1-bewgp,  "Grupo de avaliação
    infky     TYPE    skb1-infky,  "Código de inflação
    togru     TYPE    skb1-togru,  "Grupo de tolerância para contas do Razão
    xlgclr    TYPE    skb1-xlgclr, "Compensação específica de grupo de ledgers
    mcakey    TYPE    skb1-mcakey, "Chave MCA
    cochanged TYPE    skb1-cochanged,  "Dados da área de contabilidade de custos modificados
  END OF ty_s_skb1,

  BEGIN OF ty_s_fmbudget,
*    fm_area         TYPE fikrs,             " Financial Management Area
*    process         TYPE buku_process_ui,   " Budgeting Process
*    doctype         TYPE bued_doctype,      " Budget entry document type
*    version         TYPE buku_version,      " Budget Version
*    docdate         TYPE bp_bldat,          " Document Date
    funds_ctr TYPE fistl,             " Funds Center
    cmmt_item TYPE fm_fipex,          " Commitment item
    measure   TYPE fm_measure,        " Funded Program
*    fisc_year       TYPE gjahr,             " Fiscal Year
  END OF ty_s_fmbudget,

  BEGIN OF ty_s_fmbudget_months,
    total_amount_01 TYPE bapicurr_d,        " Currency amount in BAPI interfaces
    total_amount_02 TYPE bapicurr_d,        " Currency amount in BAPI interfaces
    total_amount_03 TYPE bapicurr_d,        " Currency amount in BAPI interfaces
    total_amount_04 TYPE bapicurr_d,        " Currency amount in BAPI interfaces
    total_amount_05 TYPE bapicurr_d,        " Currency amount in BAPI interfaces
    total_amount_06 TYPE bapicurr_d,        " Currency amount in BAPI interfaces
    total_amount_07 TYPE bapicurr_d,        " Currency amount in BAPI interfaces
    total_amount_08 TYPE bapicurr_d,        " Currency amount in BAPI interfaces
    total_amount_09 TYPE bapicurr_d,        " Currency amount in BAPI interfaces
    total_amount_10 TYPE bapicurr_d,        " Currency amount in BAPI interfaces
    total_amount_11 TYPE bapicurr_d,        " Currency amount in BAPI interfaces
    total_amount_12 TYPE bapicurr_d,        " Currency amount in BAPI interfaces
  END OF ty_s_fmbudget_months,

  ty_t_ska1 TYPE TABLE OF ty_s_ska1 WITH NON-UNIQUE SORTED KEY key_ska1 COMPONENTS ktopl saknr,
  ty_t_skb1 TYPE TABLE OF ty_s_skb1 WITH NON-UNIQUE SORTED KEY key_skb1 COMPONENTS bukrs saknr.

CLASS:
  lcl_acc_payable     DEFINITION DEFERRED,
  lcl_acc_receivable  DEFINITION DEFERRED,
  lcl_bal_log         DEFINITION DEFERRED,
  lcl_file            DEFINITION DEFERRED,
  lcl_gl_balance      DEFINITION DEFERRED,
  lcl_ps_balance      DEFINITION DEFERRED,
  lcl_glaccount       DEFINITION DEFERRED,
  lcl_fmbudget        DEFINITION DEFERRED.

RANGES:
  r_div     FOR tgsb-gsber,
  r_bukrs   FOR t001-bukrs.

DEFINE upper_case.
  SET LOCALE LANGUAGE sy-langu.
  TRANSLATE &1 TO UPPER CASE.
  SET LOCALE LANGUAGE space.
END-OF-DEFINITION.

DATA:
  o_file_gl        TYPE REF TO lcl_gl_balance,
  o_file_ap        TYPE REF TO lcl_acc_payable,
  o_file_ps        TYPE REF TO lcl_ps_balance,
  o_file_ar        TYPE REF TO lcl_acc_receivable,
  o_file_glaccount TYPE REF TO lcl_glaccount,
  o_file_fmbudget  TYPE REF TO lcl_fmbudget,

  BEGIN OF gs_glaccount,
    ska1 TYPE ty_t_ska1,
    skb1 TYPE ty_t_skb1,
  END OF gs_glaccount.

CONSTANTS:
  co_parameter_id1 TYPE memoryid VALUE 'ZMIG_FILE_01',
  co_parameter_id2 TYPE memoryid VALUE 'ZMIG_FILE_02',
  co_parameter_sak TYPE memoryid VALUE 'SAK'.

*--------------------------------------------------------------------
*   PARÂMETROS DE SELEÇÃO
*--------------------------------------------------------------------
SELECTION-SCREEN:
  FUNCTION KEY 1,
  FUNCTION KEY 2,
  FUNCTION KEY 3.

SELECTION-SCREEN BEGIN OF BLOCK b01 WITH FRAME TITLE TEXT-t01.

*SELECTION-SCREEN BEGIN OF LINE.
PARAMETERS p_file  TYPE rlgrap-filename  MODIF ID g3 MEMORY ID co_parameter_id1 . ##EXISTS
SELECTION-SCREEN COMMENT 79(5)  icon_001 MODIF ID g3.
PARAMETERS p_fserv TYPE rcgfiletr-ftappl MODIF ID g4 MEMORY ID co_parameter_id2 DEFAULT '/tmp/'. ##EXISTS

SELECTION-SCREEN SKIP.
PARAMETERS:
  rb_file1 RADIOBUTTON GROUP rb1 MODIF ID rb1 USER-COMMAND rb_sel DEFAULT 'X',
  rb_file2 RADIOBUTTON GROUP rb1 MODIF ID rb1.

SELECTION-SCREEN PUSHBUTTON 35(20) b1_text  USER-COMMAND b1_ucom MODIF ID g4.
SELECTION-SCREEN COMMENT    56(5)  icon_002                      MODIF ID g4.

SELECTION-SCREEN SKIP.

SELECTION-SCREEN BEGIN OF BLOCK b02 WITH FRAME TITLE TEXT-t02.
PARAMETERS:
  p_budat TYPE budat OBLIGATORY DEFAULT sy-datum    MODIF ID g1 , "Data de lançamento no documento
  p_bldat TYPE bldat OBLIGATORY DEFAULT sy-datum    MODIF ID g1,  "Data no documento
  p_bewar TYPE bseg-bewar OBLIGATORY DEFAULT 'Z00'  MODIF ID g2.  "Saldo Inicial
SELECTION-SCREEN COMMENT 58(50) gt_bewar            MODIF ID g2.
PARAMETERS:
  p_blart TYPE bkpf-blart OBLIGATORY DEFAULT 'UE'   MODIF ID g1.
SELECTION-SCREEN COMMENT 58(50) gt_blart            MODIF ID g1.
PARAMETERS:
  p_bktxt TYPE bktxt            DEFAULT 'Migração de saldos GL' MODIF ID g6,
  p_xblnr TYPE xblnr1           DEFAULT 'Migração saldos GL'    MODIF ID g1,
  p_park  TYPE xpark_it                                         MODIF ID g1,
*  p_gkont TYPE gkont OBLIGATORY DEFAULT '9100021999'            MODIF ID g2.
  p_gkont TYPE gkont MEMORY ID co_parameter_sak                 MODIF ID g2.
SELECTION-SCREEN COMMENT 58(50) gt_gkont                        MODIF ID g2.
*PARAMETERS p_tcode TYPE tcode OBLIGATORY DEFAULT sy-tcode       MODIF ID g2.
PARAMETERS p_tcode TYPE tcode                                   MODIF ID g2.
SELECTION-SCREEN COMMENT 58(50) gt_tcode                        MODIF ID g2.
PARAMETERS p_glbal1 TYPE boolean AS CHECKBOX DEFAULT abap_true  MODIF ID g5.

PARAMETERS:
  p_fmarea TYPE fmbw_s_screen-fm_area   DEFAULT 'TB00'      MODIF ID fm,
  p_proces TYPE fmbh-process_ui         DEFAULT 'ENTR'      MODIF ID fm.
SELECTION-SCREEN COMMENT 58(50) gt_proc                     MODIF ID fm.
PARAMETERS
  p_dtype  TYPE fmeddoctype-doctype     DEFAULT 'UPL'       MODIF ID fm.
SELECTION-SCREEN COMMENT 58(50) gt_dtype                    MODIF ID fm.
PARAMETERS:
  p_vers   TYPE fmbh-version            DEFAULT '0'         MODIF ID fm,
  p_pstdat TYPE fmbh-postdate           DEFAULT syst-datum  MODIF ID fm,
*  p_measu  TYPE fmbw_s_screen-smeasure                      MODIF ID fm,
  p_fiyear TYPE fmbw_s_screen-rfiscyear DEFAULT syst-datum(4) MODIF ID fm,
  p_budcat TYPE fmbw_s_screen-budcat    DEFAULT '9F'        MODIF ID fm,
  p_budty  TYPE fmbw_s_screen-sbudtype  DEFAULT 'BT01'      MODIF ID fm.
SELECTION-SCREEN END OF BLOCK b02.

*Tipo de processamento
SELECTION-SCREEN BEGIN OF BLOCK b03 WITH FRAME TITLE TEXT-t03.
PARAMETERS:
  rb_glbal RADIOBUTTON GROUP rb2 MODIF ID rb2 USER-COMMAND rb_sel DEFAULT 'X', "Saldo de contas do razÃ£o
  rb_psbal RADIOBUTTON GROUP rb2 MODIF ID rb2, "Saldo de projetos
  rb_lfn   RADIOBUTTON GROUP rb2 MODIF ID rb2, "Faturas de Fornecedores
  rb_kunnr RADIOBUTTON GROUP rb2 MODIF ID rb2, "Faturas de Clientes
  rb_glact RADIOBUTTON GROUP rb2 MODIF ID rb2, "Plano de Contas
  rb_fmbo  RADIOBUTTON GROUP rb2 MODIF ID rb2. "Dotação orcamento
SELECTION-SCREEN END OF BLOCK b03.

SELECTION-SCREEN BEGIN OF BLOCK b04 WITH FRAME TITLE TEXT-t04.
PARAMETERS:
  p_test  TYPE xtest   AS CHECKBOX DEFAULT abap_true,
  p_swlog TYPE boolean AS CHECKBOX DEFAULT abap_true.

SELECTION-SCREEN END OF BLOCK b04.

SELECTION-SCREEN BEGIN OF BLOCK b05 WITH FRAME TITLE TEXT-t05.
PARAMETERS:
  rb_up1 RADIOBUTTON GROUP rb3 MODIF ID rb3 USER-COMMAND rb_sel DEFAULT 'X',
  rb_up2 RADIOBUTTON GROUP rb3 MODIF ID rb3.
SELECTION-SCREEN END OF BLOCK b05.

SELECTION-SCREEN END OF BLOCK b01.
