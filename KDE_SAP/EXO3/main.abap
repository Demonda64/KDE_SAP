*&---------------------------------------------------------------------*
*& Report ZKDE_CORR_EXO3
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ZKDE_CORR_EXO3.

INCLUDE ZKDE_CORR_EXO3_TOP.
INCLUDE ZKDE_CORR_EXO3_SCR.
INCLUDE ZKDE_CORR_EXO3_F01.

START-OF-SELECTION.

*PERFORM SELECT_DATA.
PERFORM SELECT_DATA2.
END-OF-SELECTION.