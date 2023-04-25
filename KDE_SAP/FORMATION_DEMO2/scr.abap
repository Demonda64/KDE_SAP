*&---------------------------------------------------------------------*
*& Include          ZKDE_FORMATION_DEMO2_SCR
*&---------------------------------------------------------------------*

SELECT-OPTIONS s_vbeln FOR vbak-vbeln OBLIGATORY.
SELECT-OPTIONS s_matnr FOR vbap-matnr.
SELECT-OPTIONS s_charg FOR vbap-charg.
SELECT-OPTIONS s_kunnr FOR vbap-kunnr_ana.

PARAMETERS : p_for AS CHECKBOX.