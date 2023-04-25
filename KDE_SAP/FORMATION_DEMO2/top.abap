*&---------------------------------------------------------------------*
*& Include          ZKDE_FORMATION_DEMO2_TOP
*&---------------------------------------------------------------------*
TABLES : vbak, vbap, kna1.


TYPES : BEGIN OF ty_vbak,
          vbeln TYPE vbak-vbeln,
          erdat TYPE vbak-erdat,
          vkorg TYPE vbak-vkorg,
          vtweg TYPE vbak-vtweg,
          spart TYPE vbak-spart,
          netwr TYPE vbak-netwr,
          waerk TYPE vbak-waerk,
        END OF ty_vbak,
        ty_t_vbak TYPE TABLE OF ty_vbak,
        BEGIN OF ty_vbap,
          vbeln     TYPE vbap-vbeln,
          posnr     TYPE vbap-posnr,
          matnr     TYPE vbap-matnr,
          charg     TYPE vbap-charg,
          kunnr_ana TYPE vbap-kunnr_ana,
          netwr     TYPE vbap-netwr,
          waerk     TYPE vbap-waerk,
        END OF ty_vbap,
        ty_t_vbap TYPE TABLE OF ty_vbap,
        BEGIN OF ty_makt,
          matnr TYPE makt-matnr,
          maktx TYPE makt-maktx,
        END OF ty_makt,
        ty_t_makt TYPE TABLE OF ty_makt,
        BEGIN OF ty_kna1,
          kunnr TYPE kna1-kunnr,
          stras TYPE kna1-spras,
          pstlz TYPE kna1-pstlz,
          ort01 TYPE kna1-ort01,
          land1 TYPE kna1-land1,
          name1 TYPE kna1-name1,
        END OF ty_kna1,
        ty_t_kna1 TYPE TABLE OF ty_kna1.

DATA : gt_final TYPE ztfinal.
*       gt_final type table of zsfinal.