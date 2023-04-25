*&---------------------------------------------------------------------*
*& Report ZKDE_FORMATION_DEMO2
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zkde_formation_demo2.

INCLUDE zkde_formation_demo2_top. "Déclaration de mes variables globales
INCLUDE zkde_formation_demo2_scr. "Déclaration de notre écran de sélection
**INCLUDE zkde_formation_demo2_f01. "Traitements effectués sur les données
*
*START-OF-SELECTION.
*
*PERFORM SELECT_DATA.


*DATA : lv_date TYPE string.
*
*CONCATENATE sy-datum+6(2) sy-datum+4(2) sy-datum(4) INTO lv_date SEPARATED BY '.'.
*REPLACE ALL OCCURRENCES OF '.' IN lv_date WITH '/'.
*
*WRITE : lv_date.



























TYPES : BEGIN OF ty_vbrpk,
          fkdat TYPE vbrk-fkdat,
          fkart TYPE vbrk-fkart.
          INCLUDE STRUCTURE vbrp.
TYPES : END OF ty_vbrpk,
ty_t_vbrpk TYPE TABLE OF ty_vbrpk.

DATA : lt_vbrkp TYPE ty_t_vbrpk.


SELECT SINGLE vbeln FROM vbak INTO @DATA(lv_vbeln) WHERE vbeln IN @s_vbeln.
DATA : lr_fkart TYPE RANGE OF fkart.

SELECT sign opti low high from tvarvc INTO TABLE lr_fkart where name = 'ZTYPE_FACTURE'.



*
SELECT vbrk~fkdat, vbrk~fkart, vbrp~*
  FROM vbrk
  INNER JOIN vbrp ON vbrp~vbeln = vbrk~vbeln
  INTO TABLE @lt_vbrkp
  WHERE fkart in @lr_fkart.
*
*SELECT vbrk~fkdat, vbrk~fkart, vbrp~*
*  FROM vbrk
*  INNER JOIN vbrp ON vbrp~vbeln = vbrk~vbeln
*  APPENDING TABLE @lt_vbrkp
*  WHERE fkart = 'S1'.
*
*IF 1 = 1.
*ENDIF.

*SELECT MAX( netwr ) FROM vbrk
*  INTO @DATA(lv_max).
*
*SELECT MIN( netwr ) FROM vbrk
*  INTO @DATA(lv_min).
*
*SELECT AVG( netwr ) FROM vbrk
*  INTO @DATA(lv_avg).
*
*WRITE : 'Montant maximum :', lv_max, 'EUR'.
*SKIP.
*WRITE : 'Montant minimum :', lv_min, 'EUR'.
*SKIP.
*WRITE : 'Montant moyen des factures :', lv_avg, 'EUR'.
*
*IF 1 = 1.
*ENDIF.

"Introduction de la notion d'OFFSET
* 1/ Rajouter une colonne date du jour dans votre table
*    Extraire le jour le mois et l'année de la variable système SY-DATUM
*    et l'afficher au format DD/MM/AAAA dans cette colonne pour chaque ligne de votre table finale
* 2/ Ajouter un message d'information / d'erreur / de succès après chaque instruction décisive
*     en utilisant les éléments de texte de votre programme
* 3/ Remplacer vos messages d'erreur par des messages provenant de la classe de message ZKDE_MESS
* 4/ Déconnectez vous de SAP puis reconnectez vous en anglais
*    Que constatez-vous lorsque vous lancez votre programme?
* 5/ Corrigez le problème constaté à la question 4

* 6/ Commentez tout votre code et déclarez un modèle permettant de récupérer dans la même table interne
*    la date de création de la facture
*    le type de facture
*    + la totalité des champs de la VBRP

* 7/ Récupérez les données évoquées à la question 6 à l'aide d'un SELECT en ne prenant QUE
*    les factures de type F2 (Un champ de la VBRK vous donnera cette information)

* 8/ Effectuez un deuxième select en ne prenant cette fois que les factures de type S1
*    Et stockez les dans la même table que celle utilisée pour le 1er select
*    Débuggez le résultat de votre sélection.  Que constatez-vous?
* 9/ Répetez les opérations 7 et 8 en prenant soin cette fois de ne pas effacer les données
*    résultant du 1er select


* 10/ Créer une table de type RANGE correspondant au type de facture et ajoutez y les valeurs F2 et S1
*    afin de constistuer une liste de valeurs
*    Utilisez ce range pour refaire le même select qu'à l'étape 7
* 11/ Rajouter une autre colonne dans votre table finale nommée "Montant de la facture la plus élevéé"
*    et utilisez le sélect adéquat pour récupérer le montant de la facture la plus élevée dans la VBRK
* 12/ TVARVC : Créer une variable dans la table TVARVC en utilisant la transaction TVARVC
*              Alimentez cette variable avec les types de facture évoqués précédemment
* 13/ Notion de rupture (At NEW, At first,...exemple : at first vbeln, on alimente la date de création)
* car pas besoin de remplir à nouveau ce champ si la ligne suivante correspondant au même numéro de facture
*
*


END-of-SELECTION.


* Révision 1ère semaine de formation :

**1/ Déclarez une variable capable de stocker chacune des données ci-dessous :
** - un nombre entier
*  DATA : lv_entier  TYPE i,
** - un nombre avec décimale
*         lv_dec     TYPE decfloat16,
** - un nom de famille
*         lv_nom     TYPE string,
** - un numéro d'article
*         lv_article TYPE mara-matnr,
** - une date
*         lv_date    TYPE dats,
** - un texte d'une longueur non connue / illimitée
*         lv_text    TYPE string.
**2/ Déclarez une structure capable de stocker les données de la table VBRK
*  DATA : ls_vbrk TYPE vbrk.

*3/ Déclarez un modèle avec lequel on pourra créer une structure
*   capable de stocker les valeurs contenues dans les champs ci-dessous :

* - Numéro de commande d'achat
* - Numéro de poste
*-  Date de création de la commande
* - numéro d'article
* - Désignation article

*  TYPES : BEGIN OF ty_modele,
*            ebeln TYPE ekko-ebeln,
*            ebelp TYPE ebelp,
*            aedat TYPE ekko-aedat,
*            matnr TYPE matnr,
*            maktx TYPE maktx,
*          END OF ty_modele.
*
**4/ Déclarez la structure basée sur le modèle créé précédemment
*  DATA : ls_modele TYPE ty_modele.
*
**5/ Déclarez une table capable de stocker plusieurs lignes identiques à la structure précédemment créé
*  DATA : lt_modele TYPE TABLE OF ty_modele.
*
**6/ Déclarez les critères de sélection pour l'écran de sélection
**   - un critère permettant de saisir une valeur unique pour la date de création de la commande d'achat
**   - un critère permettant de saisir plusieurs numéros de commande d'achat
**   - un critère obligatoire permettant de saisir un type de document d'achat (champ BSART) avec 'NB' comme valeur par défaut
**   - une case à cocher permettant à l'utilisateur de ne sélectionner QUE les commandes créés pendant l'année en cours
**   - un radiobouton permettant à l'utilisateur de choisir la langue de la désignation article
*  TABLES : ekko.
*
*  PARAMETERS : p_date TYPE ekko-aedat.
*  SELECT-OPTIONS : s_ebeln FOR ekko-ebeln.
*  PARAMETERS : p_type TYPE ekko-bsart OBLIGATORY DEFAULT 'NB'.
*  PARAMETERS : p_year AS CHECKBOX.
*  PARAMETERS : p_fr TYPE makt-spras RADIOBUTTON GROUP rb1,
*               p_en TYPE makt-spras RADIOBUTTON GROUP rb1.
*
**7/ Effectuer une requête SQL permettant de récupérer les champs de la question 3 dans la table créé pour la question 5
**   et intégréz les critères de sélection de votre écran dans cette requête SQL.
**   (Attention, une jointure devra être effectuée pour récupérer l'ensemble des champs avec UNE SEULE requête SQL)
*
*  IF p_fr = 'X'.
*    SELECT ekko~ebeln ekpo~ebelp ekko~aedat  ekpo~matnr makt~maktx
*      FROM ekko
*      INNER JOIN ekpo ON ekpo~ebeln = ekko~ebeln
*      INNER JOIN makt ON makt~matnr = ekpo~matnr
*      INTO TABLE lt_modele
*      WHERE ekko~ebeln IN s_ebeln
*      AND   ekko~aedat = p_date
*      AND   ekko~bsart = p_type
*      AND   makt~spras = 'F'.
*  ELSEIF p_en = 'X'.
*    SELECT ekko~ebeln ekpo~ebelp ekko~aedat ekpo~matnr makt~maktx
*    FROM ekko
*    INNER JOIN ekpo ON ekpo~ebeln = ekko~ebeln
*    INNER JOIN makt ON makt~matnr = ekpo~matnr
*    INTO TABLE lt_modele
*    WHERE ekko~ebeln IN s_ebeln
*    AND   ekko~aedat = p_date
*    AND   ekko~bsart = p_type
*    AND   makt~spras = 'E'.
*  ENDIF.
*
*
*
**8/ Appelez les méthodes "Factory" et "display" de la classe CL_SALV_TABLE
**  Pour afficher votre table interne
*




*