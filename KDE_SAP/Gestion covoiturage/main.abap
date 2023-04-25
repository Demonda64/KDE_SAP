*&---------------------------------------------------------------------*
*& Report ZKDE_EXO_COVOIT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zkde_exo_covoit.

INCLUDE zkde_exo_covoit_top.
INCLUDE zkde_exo_covoit_scr.
INCLUDE zkde_exo_covoit_f01.

START-OF-SELECTION.

  IF s_datet IS INITIAL.
    IF P_radio2 IS NOT INITIAL.
      MESSAGE TEXT-008 TYPE 'E'.
    ENDIF.
  ENDIF.

  IF P_radio1 = 'X'.
* 1er traitement : insertion dans les tables de la BDD
    PERFORM insert_data.
  ENDIF.


  IF P_radio2 = 'X'.
* 2eme traitement : selection & affichage dans les tables de la BDD
    PERFORM select_data.
  ENDIF.