*&---------------------------------------------------------------------*
*& Include          ZKDE_EX004_TOP
*&---------------------------------------------------------------------*

TABLES : ekko, ekpo.

TYPES : BEGIN OF ty_final,
          ebeln1 TYPE ekko-ebeln,
          aedat1 TYPE ekko-aedat,
          maktx  TYPE makt-maktx.
          INCLUDE STRUCTURE ekpo.
TYPES : END OF ty_final.

DATA : gt_final TYPE TABLE OF ty_final.