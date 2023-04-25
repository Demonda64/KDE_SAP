*&---------------------------------------------------------------------*
*& Include          ZPROJ_INTER_2023_SCR
*&---------------------------------------------------------------------*

SELECTION-SCREEN BEGIN OF BLOCK b0 WITH FRAME TITLE TEXT-001.

  " Traitement Création de Commande de vente en masse via BAPI_SALESDOCU_CREATEFROMDATA2
  PARAMETERS : p_crea  TYPE xfeld RADIOBUTTON GROUP rb1 USER-COMMAND trait DEFAULT 'X'.

  " Bloc de paramètres relatif au traitement création de commande
  SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE TEXT-002.

    PARAMETERS: p_rad1  RADIOBUTTON GROUP rb2 USER-COMMAND fcode MODIF ID g1 DEFAULT 'X',
                p_fname TYPE localfile MODIF ID g1.                                           "Chemin du fichier local

    SELECTION-SCREEN SKIP 1.
    PARAMETERS: p_rad2       RADIOBUTTON GROUP rb2 MODIF ID g1,
                p_lpath(500) TYPE c MODIF ID g1,                                     " Chemin fichier
                p_lname(100) TYPE c MODIF ID g1,                                     " Nom du fichier
                p_arch(500)  TYPE c MODIF ID g1.                                      " Chemin logique pour archivage des fichiers . csv

    SELECTION-SCREEN SKIP 1.
    PARAMETERS : p_rad3 RADIOBUTTON GROUP rb3 USER-COMMAND fcode MODIF ID g1 DEFAULT 'X',
                 p_rad4 RADIOBUTTON GROUP rb3 MODIF ID g1.

  SELECTION-SCREEN END OF BLOCK b1.

  "Traitement Affichage ALV des commandes de vente créées via ce programme
  PARAMETERS : p_alv  TYPE xfeld RADIOBUTTON GROUP rb1.

  "Bloc de paramètres relatif au traitement ALV
  SELECTION-SCREEN BEGIN OF BLOCK b2 WITH FRAME TITLE TEXT-003.

    PARAMETERS : p_ernam TYPE vbak-ernam MODIF ID g2 DEFAULT sy-uname.


    SELECT-OPTIONS : s_vbeln FOR vbak-vbeln MODIF ID g2,
                     s_auart FOR vbak-auart MODIF ID g2,
                     s_vkorg FOR vbak-vkorg MODIF ID g2 MATCHCODE OBJECT zkdev_matnr,
                     s_vtweg FOR vbak-vtweg MODIF ID g2,
                     s_spart FOR vbak-spart MODIF ID g2,
                     s_matnr FOR vbap-matNr MODIF ID g2,
                     s_plant FOR vbap-werks MODIF ID g2,
                     s_kunnr FOR vbap-kunnr_ana MODIF ID g2,
                     s_erdat FOR vbak-erdat MODIF ID g2..

  SELECTION-SCREEN END OF BLOCK b2.

SELECTION-SCREEN END OF BLOCK b0.


AT SELECTION-SCREEN OUTPUT.

  FREE MEMORY ID sy-cprog.

  " On conditionne l'affichage des deux blocs (Création de CV ou Affichage ALV)
  LOOP AT SCREEN.
    IF p_crea IS NOT INITIAL.
      IF screen-group1 = 'G1'.
        screen-active = 1.
      ELSEIF screen-group1 = 'G2'.
        screen-active = 0.
      ENDIF.
      MODIFY SCREEN.
    ELSEIF p_alv IS NOT INITIAL.
      IF screen-group1 = 'G1'.
        screen-active = 0.
      ELSE.
        screen-active = 1.
      ENDIF.
      MODIFY SCREEN.
    ENDIF.
  ENDLOOP.

  " On grise les paramètres inutilisés en fonction de la source choisie pour le fichier .CSV
  LOOP AT SCREEN.
    IF screen-name = 'P_FNAME'.
      IF p_rad1 IS NOT INITIAL.
        screen-input  = 1.
      ELSE.
        screen-input  = 0.
      ENDIF.
      MODIFY SCREEN.
    ELSEIF screen-name = 'P_LPATH'
       OR screen-name  = 'P_LNAME'
       OR screen-name  = 'P_ARCH'.
      IF p_rad2 IS NOT INITIAL.
        screen-input = 1.
      ELSE.
        screen-input  = 0.
      ENDIF.
      MODIFY SCREEN.
    ENDIF.
  ENDLOOP.


  " On configure le paramètre Fichier PC de manière à ouvrir
  " une fenêtre d'exploration pour récupérer le fichier PC

AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_fname.

  IF p_rad1 IS NOT INITIAL.
    CALL FUNCTION 'F4_FILENAME'
      EXPORTING
        program_name  = syst-cprog
        dynpro_number = syst-dynnr
        field_name    = 'P_FNAME'
      IMPORTING
        file_name     = p_fname.
  ENDIF.