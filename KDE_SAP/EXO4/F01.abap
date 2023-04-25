*&---------------------------------------------------------------------*
*& Include          ZKDE_EX004_F01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Form select_data
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM select_data .

  * 1ère méthode de sélection : AVEC JOINTURES
  
  
    CALL FUNCTION 'ZKDE_SELECT_DATA'
      EXPORTING
        i_matnr      = s_matnr[]
        i_ebeln      = s_ebeln[]
        i_spras      = p_spras
      IMPORTING
        et_commandes = gt_final.
  
  
  
  
  
  * 2ème méthode de sélection : avec plusieurs select / FOR ALL ENTRIES
  *
  *  SELECT ebeln, aedat
  *  FROM ekko
  *  INTO TABLE @DATA(lt_ekko)
  *  WHERE ebeln IN @s_ebeln.
  *
  *  SELECT * FROM ekpo
  *  INTO TABLE @DATA(lt_ekpo)
  *  FOR ALL ENTRIES IN @lt_ekko
  *  WHERE ebeln = @lt_ekko-ebeln
  *  AND   matnr IN @s_matnr.
  *
  *  SELECT matnr, maktx
  *  FROM makt
  *  INTO TABLE @DATA(lt_makt)
  *  FOR ALL ENTRIES IN @lt_ekpo
  *  WHERE matnr = @lt_ekpo-matnr
  *  AND   spras = @p_spras.
  *
  ** Cette 2ème méthode nécessite de rassembler ensuite les données
  *
  *  DATA : ls_final LIKE LINE OF gt_final.
  *
  *  LOOP AT lt_ekko INTO DATA(ls_ekko).
  *    ls_final-ebeln1 = ls_ekko-ebeln.
  *    ls_final-aedat1 = ls_ekko-aedat.
  *    LOOP AT lt_ekpo INTO DATA(ls_ekpo) WHERE ebeln = ls_ekko-ebeln.
  *      MOVE-CORRESPONDING ls_ekpo TO ls_final.
  *      READ TABLE lt_makt INTO DATA(ls_makt) WITH KEY matnr = ls_ekpo-matnr.
  *      IF sy-subrc = 0.
  *        ls_final-maktx = ls_makt-maktx.
  *      ENDIF.
  *      APPEND ls_final to gt_final.
  *    ENDLOOP.
  *  ENDLOOP.
  
  ENDFORM.