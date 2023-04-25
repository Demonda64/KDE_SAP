*&---------------------------------------------------------------------*
*& Report ZKDE_DEMO
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zkde_demo.

INCLUDE zkde_alv_proj.
INCLUDE zproj_inter_2023_top.
INCLUDE zproj_inter_2023_scr.
INCLUDE zproj_inter_2023_f01.


START-OF-SELECTION.

  IF p_alv = 'X'.
    PERFORM SELECT_data.
    PERFORM display_data.
  ENDIF.