*&---------------------------------------------------------------------*
*& Include          ZKDE_CORR_EXO3_F01
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

  * Pour commencer, Récupérez l'intégralité des données de la table ZDRIVER_CAR_KDE
  
  * 1/ Combien de lignes comptent actuellement notre table ?
  *  DATA : lv_count TYPE i.
  *  SELECT COUNT( * ) FROM zdriver_car_kde INTO lv_count.
  * OU
  *  SELECT COUNT( * ) FROM zdriver_car_kde INTO @DATA(lv_count).
  *-------------------------------------------------------------------------
  * 1bis/ Affichez le nombre de lignes dans une pop up d'information avant
  * d'afficher la table
  *
  *  IF sy-subrc = 0.
  *    MESSAGE i002(zkde_mess) WITH lv_count.
  *    message text-001 type 'E'.
  *  ENDIF.
  *--------------------------------------------------------------------------
  * 2/ Combien de voitures 'NOIR' dans cette table?
  
  *  SELECT COUNT( * ) FROM zdriver_car_kde INTO lv_count WHERE CAR_color = 'NOIR'.
  *    IF sy-subrc = 0.
  *    MESSAGE i003(zkde_mess) WITH lv_count.
  *    ENDIF.
  * OU
  *  SELECT * FROM zdriver_car_kde INTO TABLE gt_display.
  *  IF sy-subrc = 0.
  *    LOOP AT gt_display ASSIGNING FIELD-SYMBOL(<fs_disp>).
  *      IF <fs_disp>-car_color = 'NOIR'.
  *        lv_count = lv_count + 1.
  *      ENDIF.
  *    ENDLOOP.
  *  ENDIF.
  *----------------------------------------------------------------------------
  * 3/ Sélectionnez l'année de fabrication de la voiture la plus récente
  
  *  SELECT MAX( car_year ) FROM zdriver_car_kde INTO @DATA(lv_date).
  *  IF sy-subrc = 0.
  *    MESSAGE i004(zkde_mess) WITH lv_date.
  *  ENDIF.
  
  *----------------------------------------------------------------------------
  * 4/ Récupérez le prénom du propriétaire de cette voiture
  
  *  SELECT SINGLE name FROM zdriver_car_kde INTO @DATA(lv_name)
  *    WHERE car_year = @lv_date.
  *    IF sy-subrc = 0.
  *      MESSAGE i005(zkde_mess) WITH lv_name.
  *    ENDIF.
  
  * 5/ Vérifiez à l'aide d'une lecture directe s'il existe une voiture de la marque "AUDI" dans notre table
  *
  *  READ TABLE gt_display TRANSPORTING NO FIELDS WITH KEY car_brand = 'AUDI'.
  *  IF sy-subrc = 0.
  *    MESSAGE i006(zkde_mess).
  *  ELSE.
  *    MESSAGE i007(zkde_mess).
  *  ENDIF.
  
  
  *6 / Créer une autre table interne au même format que votre 1 ère table
  *    puis Effectuez une lecture séquentielle sur votre 1ère table et ajoutez dans votre 2ème table
  *    uniquement les lignes de la 1ère table pour lesquelles le propriètaire vit à 'Toulouse'
  *    Affichez la 2ème table
  
    DATA : lt_display2 TYPE SORTED TABLE OF zdriver_car_kde WITH NON-UNIQUE KEY ID_driver,
           ls_display2 LIKE LINE OF lt_display2.
  
  *  LOOP AT gt_display ASSIGNING FIELD-SYMBOL(<fs_display>) WHERE city = 'Toulouse' OR city = 'TOULOUSE'.
  *    MOVE <fs_display> TO ls_display2.
  *    APPEND ls_display2 TO lt_display2.
  *  ENDLOOP.
  *
  *  LOOP AT gt_display ASSIGNING <fs_display>.
  *    IF <fs_display>-city = 'Toulouse' OR <fs_display>-city = 'TOULOUSE'.
  *      MOVE <fs_display> TO ls_display2.
  *      APPEND ls_display2 TO lt_display2.
  *    ENDIF.
  *  ENDLOOP.
  *
  *  LOOP AT gt_display ASSIGNING <fs_display>.
  *    CHECK <fs_display>-city = 'Toulouse' OR <fs_display>-city = 'TOULOUSE'.
  *    MOVE <fs_display> TO ls_display2.
  *    APPEND ls_display2 TO lt_display2.
  *  ENDLOOP.
  
  *7/  Videz la 2ème table puis renouvellez la même opération que pour la question 7
  *    mais cette fois ci ne transférez dans la 2ème table que la ligne correspondant
  *    à la première voiture grise que vous trouverez
  *  CLEAR lt_display2.
  *
  *  LOOP AT gt_display ASSIGNING <fs_display>.
  *    CHECK <fs_display>-car_color = 'GRISE'.
  *    ls_display2 = <fs_display>.
  ** ou
  **    MOVE <fs_display> TO ls_display2.
  *    APPEND ls_display2 TO lt_display2.
  *    EXIT.
  *  ENDLOOP.
  *
  *  LOOP AT gt_display ASSIGNING <fs_display> WHERE car_color = 'GRISE'.
  *    ls_display2 = <fs_display>.
  ** ou
  *    MOVE <fs_display> TO ls_display2.
  *    APPEND ls_display2 TO lt_display2.
  *    EXIT.
  *  ENDLOOP.
  
  *
  *  READ TABLE gt_display ASSIGNING <fs_display> WITH KEY car_color = 'GRISE'.
  *  IF sy-subrc = 0.
  *    ls_display2 = <fs_display>.
  *    APPEND ls_display2 TO lt_display2.
  *  ENDIF.
  
  *8/ Ensuite Effacez de nouveau le contenu de la 2ème table et copier l'intégralité
  * de la 1ère table dans la 2ème table
  * puis ajoutez une ligne dans votre 2ème table interne avec de nouvelles informations
  * qui n'existent pas encore dans cette table (Attention à ne pas remettre un ID_DRIVER
  * déjà présent dans la table car pour rappel l'ID_DRIVER est la clé de la table ZDRIVER_CAR_KDE)
  * ajoutez une deuxième fois la même ligne ds la 2ème table
  
    CLEAR lT_display2.
    lt_display2 = gt_display.
  
    DATA : ls_display3 LIKE LINE OF lt_display2.
  
    ls_display3-mandt = sy-mandt.
    ls_display3-id_driver = 'ZDEVKEV'.
    ls_display3-surname  = 'KEKE'.
    ls_display3-name = 'DEV'.
    ls_display3-date_birth = '19901206'.
    ls_display3-city = 'ARRAS'.
    ls_display3-region = 'NORD'.
    ls_display3-country = 'FRANCE'.
    ls_display3-car_brand = 'FERRARI'.
    ls_display3-car_model = 'F40'.
    ls_display3-car_year  = '2002'.
    ls_display3-car_color = 'ROUGE'.
    ls_display3-car_id  = ''.
    ls_display3-lang = 'F'.
  *  APPEND ls_display3 TO lT_display2.
  *  APPEND ls_display3 TO lt_display2.
  
  *  DELETE ADJACENT DUPLICATES FROM lt_display2 COMPARING ID_driver.
  *
  *  IF 1 = 1.
  *  ENDIF.
  
  *9/ Utilisez la 1ère table pour supprimer de la 2ème table toutes les lignes qui se trouvent
  * aussi dans la première table
  
  *  LOOP AT gt_display ASSIGNING FIELD-SYMBOL(<fs_display>).
  *    DELETE lt_display2 WHERE id_driver = <fs_display>-id_driver.
  ** OU
  **    DELETE lt_display2 FROM <fs_display>.
  *  ENDLOOP.
  
  *10/ Modifier la seule ligne qui existe encore dans la 2ème table en changeant la valeur d'un
  * des champs de cette ligne
  *  CLEAR ls_display3.
  *  ls_display3-name = 'HAMILTON'.
  *  MODIFY lt_display2 FROM ls_display3 TRANSPORTING name WHERE id_driver = 'ZDEVKEV'.
  *
  *  IF 1 = 1.
  *  ENDIF.
  
  **-------------Attention, ci-dessous, on va modifier la table de la Base de données ZDRIVER_CAR_KDE
  
  * 11/ Ajoutez le contenu de votre 2ème table interne à la table ZDRIVER_CAR_KDE
  *  INSERT zdriver_car_kde FROM TABLE lt_display2.
  ** 12/ Contrôlez le résultat de votre instruction sans aller consulter la table en BDD
  ** puis vérifiez la Base de données
  *  IF sy-subrc = 0.
  *    " La ligne a bien été ajoutée dans la BDD
  *  ELSE.
  *    " L'insertion dans la BDD a échoué
  *  ENDIF.
  
  * 13/ Ajoutez exactement la même ligne de nouveau dans votre table interne
  *    et utilisez de nouveau cette table interne pour ajouter les deux lignes de votre table dans la table ZDRIVER_CAR_KDE
  *     et contrôler de nouveau : que s'est t-il passé?
    ls_display3-mandt = sy-mandt.
    ls_display3-id_driver = 'ZDEVKEV'.
    ls_display3-surname  = 'KEKE'.
    ls_display3-name = 'DEV'.
    ls_display3-date_birth = '19901206'.
    ls_display3-city = 'ARRAS'.
    ls_display3-region = 'NORD'.
    ls_display3-country = 'FRANCE'.
    ls_display3-car_brand = 'FERRARI'.
    ls_display3-car_model = 'F40'.
    ls_display3-car_year  = '2002'.
    ls_display3-car_color = 'ROUGE'.
    ls_display3-car_id  = ''.
    ls_display3-lang = 'F'.
    APPEND ls_display3 TO lT_display2.
    INSERT zdriver_car_kde FROM TABLE lt_display2 ACCEPTING DUPLICATE KEYS.
    IF sy-subrc = 0.
      " La ligne a bien été ajoutée dans la BDD
    ELSE.
      " L'insertion dans la BDD a échoué
    ENDIF.
  *14/ Ajoutez le mot clé : accepting duplicate key dans votre instruction pr ajouter les deux lignes dans la ZDRIVER_CAR_KDE
  *    Que s'est t-il passé?
  
  *14 / Supprimez la ligne qui est en doublon et ajoutez une nouvelle ligne avec cette fois un ID_DRIVER différent
  
  
  
  
  
  
  
  
  
  
  
*8/
  
  
  
  ENDFORM.
  *&---------------------------------------------------------------------*
  *& Form SELECT_DATA2
  *&---------------------------------------------------------------------*
  *& text
  *&---------------------------------------------------------------------*
  *& -->  p1        text
  *& <--  p2        text
  *&---------------------------------------------------------------------*
  FORM select_data2 .
  
    DATA : lv_spras TYPE spras.
    lv_spras = 'F'.
    DATA : lt_maktx TYPE zty_t_makt.
    DATA : lt_mara TYPE ztmara.
  
    SELECT matnr mtart brgew gewei FROM mara INTO TABLE lt_mara.
    IF sy-subrc = 0.
      CALL FUNCTION 'ZDES_MAT_KDE'
        EXPORTING
          i_spras  = lv_spras
          it_mara  = lt_mara
        IMPORTING
          et_maktx = lt_maktx.
  
    ENDIF.
  
  ENDFORM.