*----------------------------------------------------------------------*
***INCLUDE LZGPS_CARGA_DE_TAREFASF01.
*----------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*& Form Z_FILL_BDC
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM z_fill_bdc USING    im_dynpro TYPE abap_bool
                         im_field  TYPE any
                         im_value  TYPE any
                CHANGING im_ti_bdcdata TYPE tab_bdcdata.

  CASE im_dynpro.

    WHEN abap_true.

      PERFORM z_fill_dynpro USING    im_field
                                     im_value
                            CHANGING im_ti_bdcdata.

    WHEN abap_false.

      PERFORM z_fill_field USING   im_field
                                   im_value
                           CHANGING im_ti_bdcdata.

    WHEN OTHERS.

  ENDCASE.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form Z_FILL_DYNPRO
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM z_fill_dynpro USING   p_im_program TYPE any
                           p_im_dynpro  TYPE any
                  CHANGING p_ti_bdcdata TYPE tab_bdcdata.

  DATA: wa_bdc TYPE bdcdata.

*-----------------------------------------------------------------*
*-----------------------------------------------------------------*
  wa_bdc-program  = p_im_program.
  wa_bdc-dynpro   = p_im_dynpro.
  wa_bdc-dynbegin = 'X'.

  APPEND wa_bdc TO p_ti_bdcdata.


ENDFORM.

*&---------------------------------------------------------------------*
*& Form Z_FILL_FIELD
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM z_fill_field  USING    p_im_field
                            p_im_value
                   CHANGING p_ti_bdcdata TYPE tab_bdcdata.

  DATA: wa_bdc TYPE bdcdata,
        typ    TYPE c LENGTH 1.

*-----------------------------------------------------------------*
*-----------------------------------------------------------------*
  DESCRIBE FIELD p_im_value TYPE typ.

  wa_bdc-fnam = p_im_field.

  CASE typ.

    WHEN 'D' OR 'N' OR 'P'.

      WRITE p_im_value TO wa_bdc-fval LEFT-JUSTIFIED.

    WHEN OTHERS.
      wa_bdc-fval = p_im_value.

  ENDCASE.

  APPEND wa_bdc TO p_ti_bdcdata.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form Z_FILL_MESSAGE
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM z_fill_message  USING    p_ti_msg     TYPE tab_bdcmsgcoll
                     CHANGING p_ti_return  TYPE bapiret2_t.

  DATA: wa_msg    TYPE bdcmsgcoll,
        wa_return TYPE bapiret2.

  CONSTANTS c_langu TYPE langu VALUE 'P'.

*--------------------------------------------------------------*
*--------------------------------------------------------------*
  LOOP AT p_ti_msg INTO wa_msg.

    MOVE: wa_msg-msgtyp TO wa_return-type,
          wa_msg-msgid  TO wa_return-id,
          wa_msg-msgnr  TO wa_return-number,
          wa_msg-msgv1  TO wa_return-message_v1,
          wa_msg-msgv2  TO wa_return-message_v2,
          wa_msg-msgv3  TO wa_return-message_v3,
          wa_msg-msgv4  TO wa_return-message_v4.

    CALL FUNCTION 'BAPI_MESSAGE_GETDETAIL'
      EXPORTING
        id         = wa_return-id
        number     = wa_return-number
        language   = c_langu
        textformat = 'ASC'
        message_v1 = wa_return-message_v1
        message_v2 = wa_return-message_v2
        message_v3 = wa_return-message_v3
        message_v4 = wa_return-message_v4
      IMPORTING
        message    = wa_return-message.

    APPEND wa_return TO p_ti_return.

  ENDLOOP.

ENDFORM.
