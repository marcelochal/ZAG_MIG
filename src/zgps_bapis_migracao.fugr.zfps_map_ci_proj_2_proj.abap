* --------------------------------------------------------------------------*
*                  T A E S A - MIGRAÇÃO - AGIR                              *
* --------------------------------------------------------------------------*
* Consultoria .....: Intechpro                                              *
* ABAP.............: Richard de Aquino Rodrigues                            *
* Funcional........: André Santos                                           *
* Módulo...........: PS                                                     *
* Programa.........: ZFPS_MAP_CI_PROJ_2_PROJ                                *
* Transação........:                                                        *
* Tipo de Prg......: FUNÇÃO                                                 *
* Objetivo.........: Mapear os campos Zs (CI_PROJ)                          *
* Data.............: 23/07/2018                                             *
* --------------------------------------------------------------------------*
* Request    | Descrição                                                    *
* --------------------------------------------------------------------------*
* S4DK901191 | AGIR Migração - Definição de Projeto                         *
* --------------------------------------------------------------------------*

FUNCTION zfps_map_ci_proj_2_proj.
*"----------------------------------------------------------------------
*"*"Interface local:
*"  IMPORTING
*"     REFERENCE(BAPI_PROJECT_DEFINITION) TYPE
*"        ZEPS_BAPI_PROJECT_DEFINITION
*"  CHANGING
*"     REFERENCE(PROJ) LIKE  PROJ STRUCTURE  PROJ
*"----------------------------------------------------------------------

  TYPES:
    BEGIN OF typ_estr,
      tabname   TYPE tabname,
      fieldname TYPE fieldname,
      fldstat   TYPE as4local,
    END   OF typ_estr.

  TYPES: typ_ti_estr TYPE STANDARD TABLE OF typ_estr.

  DATA: lc_campo_proj(34) TYPE c,
        lc_campo_estr(34) TYPE c,
        ti_estr           TYPE typ_ti_estr,
        wa_estr           TYPE typ_estr.

  FIELD-SYMBOLS: <fs_origem>     TYPE any,
                 <fs_destino>    TYPE any,
                 <fs_campo_proj> TYPE any,
                 <fs_campo_estr> TYPE any.

*----------------------------------------------------------*
*----------------------------------------------------------*
  SELECT
        tabname
        fieldname
        fldstat
        INTO TABLE ti_estr
        FROM dd03m
        WHERE tabname EQ 'CI_PROJ'
         AND  fldstat EQ 'A'.

  IF sy-subrc EQ 0.

    LOOP AT ti_estr INTO wa_estr.

      CONCATENATE 'PROJ-' wa_estr-fieldname INTO lc_campo_proj.

      ASSIGN (lc_campo_proj) TO <fs_campo_proj>.

      IF <fs_campo_proj> IS ASSIGNED.

        CONCATENATE 'BAPI_PROJECT_DEFINITION-' wa_estr-fieldname INTO lc_campo_estr.

        ASSIGN (lc_campo_estr) TO <fs_campo_estr>.

        IF <fs_campo_estr> IS ASSIGNED.

          MOVE <fs_campo_estr> TO <fs_campo_proj>.

        ENDIF.

      ENDIF.

    ENDLOOP.

  ENDIF.

ENDFUNCTION.
