* --------------------------------------------------------------------------*
*                  T A E S A - MIGRAÇÃO - AGIR                              *
* --------------------------------------------------------------------------*
* Consultoria .....: Intechpro                                              *
* ABAP.............: Richard de Aquino Rodrigues                            *
* Funcional........: André Santos                                           *
* Módulo...........: PS                                                     *
* Programa.........: ZFPS_MAP_NOVOS_CAMPOS_2_PROJ                           *
* Transação........:                                                        *
* Tipo de Prg......: FUNÇÃO                                                 *
* Objetivo.........: Mapear novos campos que a BAPI original não trata      *
* Data.............: 11/07/2018                                             *
* --------------------------------------------------------------------------*
* Request    | Descrição                                                    *
* --------------------------------------------------------------------------*
* S4DK901191 | AGIR - Carga de Dados para Migração - HXXX - Def. Projeto    *
* --------------------------------------------------------------------------*

FUNCTION zfps_map_novos_campos_2_proj.
*"----------------------------------------------------------------------
*"*"Interface local:
*"  IMPORTING
*"     REFERENCE(PROJECT_DEFINITION_STRU) TYPE
*"        ZEPS_BAPI_PROJECT_DEFINITION
*"  CHANGING
*"     REFERENCE(PROJ) TYPE  PROJ
*"----------------------------------------------------------------------

  proj-imprf = project_definition_stru-perf_investimento.
  proj-stort = project_definition_stru-localizacao.

*-----------------------------------------------------------------*

*-----------------------------------------------------------------*

*-----------------------------------------------------------------*

ENDFUNCTION.
