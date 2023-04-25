*&---------------------------------------------------------------------*
*& Include          ZKDE_CORR_EXO2_F01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Form SELECT_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM select_data .

  DATA : lt_likp TYPE TABLE OF ty_likp,
         lt_lips TYPE TABLE OF ty_lips,
         lt_vbrk TYPE TABLE OF ty_vbrk,
         lt_vbrp TYPE TABLE OF ty_vbrp,
         lt_marc TYPE TABLE OF ty_marc.


*  DATA : lv_liv TYPE vbeln.
*
*  lv_liv = 'TOTO'.
* DATA(lv_commentaire) = 'PAS COOL'.
*
*  SELECT single vbeln FROM likp INTO @DATA(lv_vbeln) WHERE vbeln = @lv_liv.
*    IF sy-subrc <> 0.
*      MESSAGE e001(zkde_mess) WITH lv_liv lv_commentaire.
*    ENDIF.
*

    SELECT vbeln erdat vstel vkorg
      FROM likp
      INTO TABLE lt_likp
     WHERE vbeln IN s_vbeln.
    IF sy-subrc <> 0.
      MESSAGE i000(zkde_mess).
*     message text-015 type 'E'.
*     EXIT.
    ENDIF.
*  CHECK sy-subrc = 0.


    IF p_lvorm IS INITIAL.
      SELECT lips~vbeln lips~posnr lips~matnr lips~werks lips~lfimg lips~meins
       FROM lips
       INNER JOIN mara ON mara~matnr = lips~matnr
       INTO TABLE lt_lips
       FOR ALL ENTRIES IN lt_likp
       WHERE lips~vbeln     = lt_likp-vbeln
       AND   lips~matnr      IN s_matnr
       AND   lips~werks      IN s_werks
       AND   mara~lvorm = ''.
    ELSE.
      SELECT vbeln posnr matnr werks lfimg meins
      FROM lips
      INTO TABLE lt_lips
      FOR ALL ENTRIES IN lt_likp
      WHERE vbeln     = lt_likp-vbeln
      AND   matnr      IN s_matnr
      AND   werks      IN s_werks.
    ENDIF.

    SELECT matnr werks ekgrp
     FROM marc
     INTO TABLE lt_marc
     FOR ALL ENTRIES IN lt_lips
     WHERE matnr = lt_lips-matnr
      AND  werks = lt_lips-werks.

      SELECT  vbeln posnr fkimg ntgew  gewei netwr vrkme vgbel vgpos
       FROM vbrp
       INTO TABLE lt_vbrp
       FOR ALL ENTRIES IN lt_lips
       WHERE vgbel = lt_lips-vbeln
        AND  vgpos = lt_lips-posnr
        AND  vbeln IN s_vbelnf.

        SELECT vbeln fkart fkdat waerk
          FROM vbrk
          INTO TABLE lt_vbrk
          FOR ALL ENTRIES IN lt_vbrp
         WHERE vbeln = lt_vbrp-vbeln.

          PERFORM merge_data USING lt_vbrk
                                   lt_vbrp
                                   lt_marc
                                   lt_likp
                                   lt_lips.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form merge_data
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LT_VBRK
*&      --> LT_VBRP
*&      --> LT_MARC
*&      --> LT_LIKP
*&      --> LT_LIPS
*&---------------------------------------------------------------------*
FORM merge_data  USING ut_vbrk TYPE ty_t_vbrk
                       ut_vbrp TYPE ty_t_vbrp
                       ut_marc TYPE ty_t_marc
                       ut_likp TYPE ty_t_likp
                       ut_lips TYPE ty_t_lips.

  DATA : ls_final LIKE LINE OF gt_final,
         ls_likp  LIKE LINE OF ut_likp,
         ls_lips  LIKE LINE OF ut_lips,
         ls_vbrp  LIKE LINE OF ut_vbrp,
         ls_vbrk  LIKE LINE OF ut_vbrk,
         ls_marc  LIKE LINE OF ut_marc.

  SORT ut_lips BY vbeln.


  LOOP AT ut_likp ASSIGNING FIELD-SYMBOL(<fs_likp>).
    CLEAR ls_final.
    ls_final-vbeln1 = <fs_likp>-vbeln.
    ls_final-vstel = <fs_likp>-vstel.
    ls_final-vkorg = <fs_likp>-vkorg.
    ls_final-erdat = <fs_likp>-erdat.

    LOOP AT ut_lips INTO ls_lips WHERE vbeln = <fs_likp>-vbeln.


      ls_final-posnr = ls_lips-posnr.
      ls_final-matnr = ls_lips-matnr.
      ls_final-werks = ls_lips-werks.
      ls_final-lfimg = ls_lips-lfimg.
      ls_final-meins = ls_lips-meins.

      READ TABLE ut_marc INTO ls_marc WITH KEY matnr = ls_lips-matnr
                                               werks = ls_lips-werks.
      IF sy-subrc = 0. "Si on a trouvé une ligne qui correspond
        ls_final-ekgrp = ls_marc-ekgrp.
      ENDIF.

      READ TABLE ut_vbrp INTO ls_vbrp WITH KEY vgbel = ls_lips-vbeln
                                               vgpos = ls_lips-posnr.
      IF sy-subrc = 0.
        ls_final-vbeln = ls_vbrp-vbeln.
        ls_final-posnr = ls_vbrp-posnr.
        ls_final-fkimg = ls_vbrp-fkimg.
        ls_final-vrkme = ls_vbrp-vrkme.
        ls_final-ntgew = ls_vbrp-ntgew.
        ls_final-gewei = ls_vbrp-gewei.
        ls_final-netwr = ls_vbrp-netwr.

        READ TABLE ut_vbrk INTO ls_vbrk WITH KEY vbeln = ls_vbrp-vbeln.
        IF sy-subrc = 0.
          ls_final-fkart = ls_vbrk-fkart.
          ls_final-fkdat = ls_vbrk-fkdat.
          ls_final-waerk = ls_vbrk-waerk.
          APPEND ls_final TO gt_final.
        ENDIF.
      ENDIF.

    ENDLOOP.
  ENDLOOP.


  PERFORM play_data.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form display_data
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM display_data .

  DATA : lo_alv TYPE REF TO cl_salv_table.

  CALL METHOD cl_salv_table=>factory
    IMPORTING
      r_salv_table = lo_alv
    CHANGING
      t_table      = gt_final.

  CALL METHOD lo_alv->display.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form play_data
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM play_data .

*FIELD-SYMBOLS : <fs_final> type zscorrection.

  LOOP AT gt_final INTO DATA(ls_final).
    ls_final-erdat = '20230101'.
    ls_final-fkart = 'S1'.
    ls_final-fkimg = '200'.
    MODIFY gt_final FROM ls_final TRANSPORTING erdat fkart fkimg WHERE vbeln = ls_final-vbeln.
  ENDLOOP.

  LOOP AT gt_final ASSIGNING FIELD-SYMBOL(<fs_final>).
    <fs_final>-erdat = '20230101'.
    <fs_final>-fkart = 'S1'.
    <fs_final>-fkimg = '200'.
  ENDLOOP.


  READ TABLE gt_final ASSIGNING FIELD-SYMBOL(<fs_final2>) WITH KEY vbeln1 = 'TOTO'.
*   IF SY-subrc = 0.
*   <fs_final2>-matnr = 'TATA'.
*   endif.
  IF <fs_final2> IS ASSIGNED.
    <fs_final2>-matnr = 'TATA'.
  ENDIF.

ENDFORM.