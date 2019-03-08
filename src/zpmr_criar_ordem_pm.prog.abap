*&---------------------------------------------------------------------*
*& Report ZPMR_CRIAR_ORDEM_PM
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
REPORT zpmr_criar_ordem_pm.

PARAMETERS: pa_ord  TYPE  aufnr,
            pa_test TYPE testrun AS CHECKBOX.

DATA: wa_header_ordem TYPE zepm_header_iw31,
      ti_operacoes    TYPE ztpm_operacoes_iw31,
      wa_operacao     TYPE zepm_operacoes_iw31,
      ti_return       TYPE bapiret2_tab,
      wa_return       TYPE bapiret2.

*********************
*********************
START-OF-SELECTION.
*********************
*********************

  wa_header_ordem-orderid      =  pa_ord.

  wa_header_ordem-order_type   = 'TCOR'.
  wa_header_ordem-short_text   = 'COMISSIONAMENTO DA ATEIII COC-TAESA'.
  wa_header_ordem-equipment    = '000000000400008500'.

  wa_header_ordem-funct_loc    = 'TAE-CO-CBC-SPC'.
  wa_header_ordem-mn_wk_ctr    = 'CCGOPINF'.
  wa_header_ordem-plant        = 'EA4'.
  wa_header_ordem-location     = 'COCBLC'.
  wa_header_ordem-maintplant   = 'EA4'.
  wa_header_ordem-start_date   = '20171001'.
  wa_header_ordem-finish_date  = '20171231'.

  wa_header_ordem-loc_comp_code = 'TB01'.
  wa_header_ordem-bus_area      = 'D04A'.
  wa_header_ordem-pmacttype     = 'T09'.
  wa_header_ordem-plangroup     = 'GOP'.

  wa_header_ordem-kokrs        = 'TB00'.
  wa_header_ordem-costcenter   = 'HNVTO70003'.
  wa_header_ordem-respcctr     = 'HNVTO70003'.
  wa_header_ordem-profit_ctr   = 'D04A'.

  wa_header_ordem-priority     = '4'.

  wa_header_ordem-currency     = 'BRL'.

*-------------------------------------------------------------------*
  wa_operacao-aufnr           = pa_ord.

  wa_operacao-activity        = '0010'.
  wa_operacao-plant           = 'EA4'.
  wa_operacao-description     = 'COMISSIONAMENTO DA ATEIII COC-TAESA'.
  wa_operacao-work_cntr       = 'CCGOPINF'.
  wa_operacao-acttype         = 'AP-TEC'.

  wa_operacao-calc_key        = '1'.
  wa_operacao-control_key     = 'ZPM1'.

  wa_operacao-work_activity   = '500.0'.
  wa_operacao-duration_normal = '500.0'.

  APPEND wa_operacao TO ti_operacoes.

*-------------------------------------------------------------------*
* Criar ordem
  CALL FUNCTION 'BAPI_CRIAR_ORDEM_PM'
    EXPORTING
      p_i_wa_header_ordem = wa_header_ordem
      p_i_ti_operacoes    = ti_operacoes[]
      p_i_testrun         = pa_test
    IMPORTING
      p_e_ti_return       = ti_return[].

*********************
*********************
END-OF-SELECTION.
*********************
*********************

  LOOP AT ti_return INTO wa_return.
    WRITE /10 wa_return-message.
  ENDLOOP.
