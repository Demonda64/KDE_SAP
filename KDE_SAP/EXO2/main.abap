*&---------------------------------------------------------------------*
*& Report ZKDE_CORR_EXO2
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zkde_corr_exo2.

INCLUDE ZKDE_CORR_EXO2_top. "Déclaration des variables globales
INCLUDE zkde_corr_exo2_scr. "Déclaration des critères de l'écran de sélection
INCLUDE zkde_corr_exo2_f01. " Traitements et routines.

START-OF-SELECTION.

  PERFORM select_data.
  PERFORM display_data.

END-OF-SELECTION.