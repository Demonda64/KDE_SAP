*&---------------------------------------------------------------------*
*& Report ZKDE_FORMATION_DEMO
*&---------------------------------------------------------------------*
*& Date Création /  Auteur  / Motif
*& 21.02.2023      KDE(Stms)  Création 1er programme ABAP
*&----------------------------------------------------------
*& Modification / Auteur /  Motif
*&
*&---------------------------------------------------------------------*
REPORT zkde_formation_demo.

* Récupération d'une seule valeur de notre table
** pour un conducteur identifié
*DATA : lv_name  TYPE srmfname,
*       lv_name2 TYPE zdriver_car_kde-name,
*       lv_name3 TYPE char25.
*
*SELECT SINGLE name
*FROM zdriver_car_kde
*INTO lv_name
*WHERE id_driver = 'PAP'.

*WRITE : lv_name.

* Récupération de l'ensemble des valeurs correspondantes
* à ce conducteur
*
** Déclaration de ma structure pour réceptionner les données
*DATA : ls_zdriver TYPE zdriver_car_kde.
*
** Sélection des données
*
**SELECT SINGLE * FROM zdriver_car_kde
**  INTO ls_zdriver
**  WHERE id_driver = 'PAP'.
**
**WRITE : ls_zdriver.
*
** Récupération de l'ensemble des données de la table
*DATA : lt_zdriver TYPE TABLE OF zdriver_car_kde.
*       lv_fusion TYPE string.
*
** Sélection des données
*
*SELECT * FROM zdriver_car_kde
*  INTO TABLE lt_zdriver.
*
** Tri sur la table interne en fonction du prénom
*SORT lt_zdriver BY name ASCENDING.

* Lecteur séquentielle de notre table interne

*LOOP AT lt_zdriver INTO ls_zdriver WHERE car_brand = 'Peugeot'
*                                  AND ( name = 'OSCAR' OR name = 'MAGALI' ).
*  WRITE : ls_zdriver.
*ENDLOOP.


*LOOP AT lt_zdriver INTO ls_zdriver where car_brand = 'Peugeot'.
*
**  IF ls_zdriver-name = 'OSCAR'.
***    CONTINUE.
**    EXIT.
**  ELSEIF ls_zdriver-name = 'MAGALI'.
**    WRITE : ls_zdriver.
**  ELSE.
**    WRITE : 'Heureusement je n''ai pas de peugeot'.
**  ENDIF.
**  CHECK ls_zdriver-name NE 'OSCAR'.
**  CHECK ls_zdriver-name <> 'OSCAR'.
*
**  CASE ls_zdriver-name.
**    WHEN 'OSCAR'.
**      CONTINUE.
**    WHEN 'MAGALI'.
**      WRITE : ls_zdriver.
**    WHEN OTHERS.
**      WRITE : 'Je roule en allemande'.
**  ENDCASE.
*
**  WRITE ls_zdriver.
*CONCATENATE lv_fusion ls_zdriver-name into lv_fusion SEPARATED BY space.
*
*ENDLOOP.


*LOOP AT lt_zdriver INTO ls_zdriver where car_brand = 'Peugeot'.
*
**CONCATENATE lv_fusion ls_zdriver-name into lv_fusion SEPARATED BY space.
*lv_fusion = |{ lv_fusion }{ ls_zdriver-name }|.
*
*ENDLOOP.
*
*WRITE : lv_fusion.

*
*TYPES : BEGIN OF ty_zdriver,
*          id_driver  TYPE z_driver_id_kde,
*          surname    TYPE namef,
*          name       TYPE srmfname,
*          date_birth TYPE p06_datenaiss,
*        END OF ty_zdriver.
*
*DATA : lt_driver TYPE TABLE OF ty_zdriver.
*
*SELECT id_driver surname name date_birth
*  FROM zdriver_car_kde
*  INTO CORRESPONDING FIELDS OF TABLE lt_driver.
*TABLES : zdriver_car_kde.
*
*PARAMETERS : p_id TYPE z_driver_id_kde OBLIGATORY DEFAULT 'PAP'.
**SELECT-OPTIONS : s_id FOR zdriver_car_kde-id_driver.
*
*SELECT id_driver, surname, name, date_birth
*FROM zdriver_car_kde
*INTO TABLE @DATA(lt_driver)
*WHERE id_driver = @p_id.
***WHERE id_driver IN @s_id.
*
*IF 1 = 1.
*ENDIF.
*
*DATA : lo_alv TYPE REF TO cl_salv_table.
*
*CALL METHOD cl_salv_table=>factory
*  IMPORTING
*    r_salv_table = lo_alv
*  CHANGING
*    t_table      = lt_driver.
*
*CALL METHOD lo_alv->display.

*----------------------------------------------------------------------------------------------------
* EXO N°2

* Besoin exprimé par le Client
* Le client souhaite disposer d'un report lui permettant
* d'afficher certaines informations concernant les articles

*1/ Liste des informations à afficher :
*  - le numéro d'article
*  - le type d'article
*  - son poids net
*  - unité de poids

*2/L'utilisateur souhaite pouvoir afficher ces informations
*en fonction du type d'article et du numéro d'article

* Méthode 1 :
*TABLES : mara.
*SELECT-OPTIONS : s_matnr FOR mara-matnr.
*SELECT-OPTIONS : s_mtart FOR mara-mtart OBLIGATORY.
*PARAMETERS : p_trait AS CHECKBOX DEFAULT 'X'.


***TYPES : BEGIN OF ty_modele,
***          matnr TYPE mara-matnr,
***          mtart TYPE mara-mtart,
***          ntgew TYPE mara-ntgew,
***          gewei TYPE mara-gewei,
***        END OF ty_modele.
**
***DATA : lt_mara TYPE TABLE OF ty_modele.
**
***SELECT matnr mtart ntgew gewei
***FROM mara
***INTO TABLE lt_mara
***WHERE matnr IN S_matnr
***AND mtart IN s_mtart.
*
**Méthode 2 :
*SELECT matnr, mtart, ntgew, gewei
*FROM mara
*INTO TABLE @DATA(lt_mara)
*WHERE matnr IN @S_matnr
*AND mtart IN @s_mtart.
*
*
**DATA : lo_alv TYPE REF TO cl_salv_table.
**
**CALL METHOD cl_salv_table=>factory
**  IMPORTING
**    r_salv_table = lo_alv
**  CHANGING
**    t_table      = lt_mara.
**
**CALL METHOD lo_alv->display.
*
*
**3/ L'utilisateur souhaite qu'on affiche également
** la description de l'article se trouvant dans la table
** MAKT (FOR ALL ENTRIES et Jointures)
*
*SELECT matnr, maktx
*FROM makt
*INTO TABLE @DATA(lt_makt)
*FOR ALL ENTRIES IN @LT_mara
*WHERE matnr = @lt_mara-matnr
*AND   spras = 'F'.
*
*TYPES : BEGIN OF ty_modele,
*          matnr TYPE mara-matnr,
*          maktx TYPE makt-maktx,
*          mtart TYPE mara-mtart,
*          ntgew TYPE mara-ntgew,
*          gewei TYPE mara-gewei,
*        END OF ty_modele.
*
*DATA : lt_final TYPE TABLE OF ty_modele,
**       ls_final type ty_modele,
*       ls_final LIKE LINE OF lt_final,
*       ls_mara  LIKE LINE OF lt_mara,
*       ls_makt  LIKE LINE OF lt_makt.
*
*
*LOOP AT lt_mara INTO ls_mara.
*  CLEAR ls_final.
*  ls_final-matnr = ls_mara-matnr.
*  ls_final-mtart = ls_mara-mtart.
*  ls_final-ntgew = ls_mara-ntgew.
*  ls_final-gewei = ls_mara-gewei.
*  READ TABLE lt_makt INTO ls_makt
*  WITH KEY matnr = ls_mara-matnr.
*  IF sy-subrc = 0.
*    ls_final-maktx = ls_makt-maktx.
*  ENDIF.
*  APPEND ls_final TO lt_final.
*ENDLOOP.
*
*loop at lt_mara ASSIGNING FIELD-SYMBOL(<fs_mara>).
*  <fs_mara>-ntgew = '200'.
*ENDLOOP.
*
*LOOP AT lt_mara into ls_mara.
*  ls_mara-ntgew = '200'.
*  MODIFY lt_mara from ls_mara.
*ENDLOOP.





*3/ L'utilisateur souhaite également disposer
* d'un critère lui permettant de choisir s'il souhaite
* afficher les articles pesant moins d'1 KG

** Notion abordée : checkbox
*IF p_trait IS NOT INITIAL.
*  SELECT mara~matnr, mara~mtart, mara~ntgew, mara~gewei, makt~maktx
*   FROM mara
*   INNER JOIN makt ON makt~matnr = mara~matnr
*   INTO TABLE @DATA(lt_final)
*   WHERE mara~matnr IN @s_matnr
*    AND  mara~mtart IN @s_mtart
*    AND  makt~spras = 'F'.
*  IF sy-subrc = 0. "J'ai trouvé des articles
*    MESSAGE TEXT-002 TYPE 'I'.
*  ELSE.
*    "Je n'ai rien trouvé avec ces critères de sélection
*    MESSAGE TEXT-001 TYPE 'E'.
*  ENDIF.
*ELSE.
*  SELECT matnr, mtart, ntgew, gewei
*   FROM mara
*   INTO TABLE @DATA(lt_final2)
*   WHERE matnr IN @s_matnr
*    AND  mtart IN @s_mtart.
*ENDIF.
*
*DATA : lo_alv TYPE REF TO cl_salv_table.
*
*IF p_trait IS NOT INITIAL.
*  CALL METHOD cl_salv_table=>factory
*    IMPORTING
*      r_salv_table = lo_alv
*    CHANGING
*      t_table      = lt_final.
*
*  CALL METHOD lo_alv->display.
*ELSE.
*  CALL METHOD cl_salv_table=>factory
*    IMPORTING
*      r_salv_table = lo_alv
*    CHANGING
*      t_table      = lt_final2.
*
*  CALL METHOD lo_alv->display.
*ENDIF.

*4/ L'utilisateur souhaite avoir la possibilité
* dans le même écran de choisir entre deux traitements

* s'il coche le radiobutton 1 : il veut qu'on affiche
* les infos des conducteurs se trouvant dans la table
* ZDRIVER_CAR_KDE

* S'il coche le radiobuttion 2 : il veut qu'on affiche
* les infos concernant les articles


*------------Révision de toutes les notions abordées------------
*1/ L'Utilisateur final souhaite disposer d'un report lui permettant
* d'afficher les informations des commandes d'achats
* Ci-dessous, la liste des champs à afficher :
* EBELN  Document achat
* EBELP  Poste
* BUKRS  Société
* BSTYP  Catégorie doc.
* BSART  Type document
* Fournisseur
* Organis. achats
* MATNR
* MENGE
* MEINS
* VOLUM
* VOLEH

*2/ L'utilisateur souhaite pouvoir "filtrer" cette sélection de données
* en fonction du n° commande d'achat / de l'article / de la société
* Il indique que le critère "société" doit être un critère obligatoire
* et que sa valeur par défaut sera "0001'.

*3/ L'utilisateur souhaite également disposer d'une case à cocher lui
* permettant d'afficher ou non le volume de l'article

*4/ L'utilisateur précise enfin qu'il a besoin de messages d'information
* dans l'éventualité où il renseignerait une société qui n'existe pas.
* et dans l'éventualité où aucune information ne serait récupérée.

TABLES : ekko, ekpo.

SELECTION-SCREEN : BEGIN OF BLOCK b01 WITH FRAME TITLE TEXT-003.
  SELECT-OPTIONS s_ebeln FOR ekko-ebeln.
  SELECT-OPTIONS s_bukrs FOR ekko-bukrs.
  SELECT-OPTIONS s_matnr FOR ekpo-matnr.
  PARAMETERS : p_vol AS CHECKBOX DEFAULT 'X'.
  PARAMETERS : p_prog1 RADIOBUTTON GROUP b1,
               p_prog2 RADIOBUTTON GROUP b1.


SELECTION-SCREEN : END OF BLOCK b01.

DATA : lo_alv TYPE REF TO cl_salv_table.


IF p_prog1 IS NOT INITIAL. "is prog1 = abap_true.
  IF p_vol IS NOT INITIAL.

    SELECT ekko~ebeln, ekpo~ebelp, ekko~bukrs, ekko~bstyp, ekko~bsart, ekko~lifnr,
          ekpo~matnr, ekpo~menge, ekpo~meins, ekpo~volum, ekpo~voleh
      FROM ekko
      INNER JOIN ekpo ON ekpo~ebeln = ekko~ebeln
      INTO TABLE @DATA(lt_commandes)
      WHERE ekko~ebeln IN @s_ebeln
      AND   ekko~bukrs IN @s_bukrs
      AND   ekpo~matnr IN @s_matnr.
    IF sy-subrc <> 0.
      MESSAGE TEXT-001 TYPE 'E'.
    ENDIF.

    CALL METHOD cl_salv_table=>factory
      IMPORTING
        r_salv_table = lo_alv
      CHANGING
        t_table      = lt_commandes.

    CALL METHOD lo_alv->display.

  ELSE.

    SELECT ekko~ebeln, ekpo~ebelp, ekko~bukrs, ekko~bstyp, ekko~bsart, ekko~lifnr,
     ekpo~matnr, ekpo~menge, ekpo~meins
    FROM ekko
    INNER JOIN ekpo ON ekpo~ebeln = ekko~ebeln
    INTO TABLE @DATA(lt_commandes2)
    WHERE ekko~ebeln IN @s_ebeln
    AND   ekko~bukrs IN @s_bukrs
    AND   ekpo~matnr IN @s_matnr.
    IF sy-subrc <> 0.
      MESSAGE TEXT-001 TYPE 'E'.
    ENDIF.

    CALL METHOD cl_salv_table=>factory
      IMPORTING
        r_salv_table = lo_alv
      CHANGING
        t_table      = lt_commandes2.

    CALL METHOD lo_alv->display.

  ENDIF.

ELSE.

  TYPES : BEGIN OF ty_commandes,
            ebeln TYPE ekko-ebeln,
            ebelp TYPE ekpo-ebelp,
            bukrs TYPE ekko-bukrs,
            bstyp TYPE ekko-bstyp,
            bsart TYPE ekko-bsart,
            lifnr TYPE ekko-lifnr,
            matnr TYPE ekpo-matnr,
            menge TYPE ekpo-menge,
            meins TYPE ekpo-meins,
            volum TYPE ekpo-volum,
            voleh TYPE ekpo-voleh,
            vbeln TYPE ekes-vbeln,
          END OF ty_commandes.

  DATA : lt_commandes4 TYPE STANDARD TABLE OF ty_commandes WITH NON-UNIQUE KEY ebeln.
  DATA : ls_commande LIKE LINE OF lt_commandes4.
  DATA : lt_affichage TYPE TABLE OF ty_commandes.


  SELECT ekko~ebeln ekpo~ebelp ekko~bukrs ekko~bstyp ekko~bsart ekko~lifnr
        ekpo~matnr ekpo~menge ekpo~meins ekpo~volum ekpo~voleh ekes~vbeln
    FROM ekko
    INNER JOIN ekpo ON ekpo~ebeln = ekko~ebeln
    INNER JOIN ekes ON ekes~ebeln = ekko~ebeln
    INTO TABLE  lt_commandes4
    WHERE ekko~ebeln IN s_ebeln
    AND   ekko~bukrs IN s_bukrs
    AND   ekpo~matnr IN s_matnr.

  ls_commande-ebeln = '4500000022'.
  ls_commande-ebelp = '20'.
  ls_commande-bukrs = '1710'.
  ls_commande-bstyp = 'F'.
  ls_commande-bsart = ' NB'.
  ls_commande-lifnr = '0017300007 '.
  ls_commande-matnr = 'TG11'.
  ls_commande-menge = 10.
  ls_commande-meins = 'ST'.
  ls_commande-volum = '1'.
  ls_commande-voleh = 'm3'.
  ls_commande-vbeln = '180000078'.
  APPEND ls_commande TO lt_commandes4.

  ls_commande-ebeln = '4500000022'.
  ls_commande-ebelp = '20'.
  ls_commande-bukrs = '1710'.
  ls_commande-bstyp = 'F'.
  ls_commande-bsart = ' NB'.
  ls_commande-lifnr = '0017300007 '.
  ls_commande-matnr = 'TG11'.
  ls_commande-menge = 10.
  ls_commande-meins = 'ST'.
  ls_commande-volum = '200'.
  ls_commande-voleh = 'm3'.
  ls_commande-vbeln = '180000078'.

 MODIFY lt_commandes4 FROM ls_commande  TRANSPORTING volum WHERE ebeln = '4500000022'.

  DELETE lt_commandes4 WHERE ebeln = '4500000022'.

  lt_affichage = lt_commandes4.

  CALL METHOD cl_salv_table=>factory
    IMPORTING
      r_salv_table = lo_alv
    CHANGING
      t_table      = lt_affichage.

  CALL METHOD lo_alv->display.






*  INSERT.
*  APPEND.
*  MODIFY.
*  DELETE.


ENDIF.


* Field symbol
* Les opérations sur la table interne (INSERT / MODIFY / DELETE / APPEND)
* Les opérations sur la table de BDD ZDRIVER_CAR_KDE