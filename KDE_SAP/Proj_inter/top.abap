*&---------------------------------------------------------------------*
*& Include          ZPROJ_INTER_2023_TOP
*&---------------------------------------------------------------------*

TABLES : vbak, vbap.

* Typage de la table interne qui va servir à récupérer le contenu du fichier CSV
TYPES:
  BEGIN OF ts_line,
    line TYPE string,
  END OF ts_line,
  tt_line TYPE STANDARD TABLE OF ts_line.

* Typage de la table interne qui servira à stocker les données des Commandes de vente à créer
TYPES : BEGIN OF ty_data,
          id_com        TYPE zid_com_po,
          doc_type      TYPE vbak-auart,
          sales_org     TYPE vbak-vkorg,
          distr_chan    TYPE vbak-vtweg,
          sect_act      TYPE vbak-spart,
          partn_role_ag TYPE parvw,
          partn_numb_ag TYPE vbak-kunnr,
          partn_role_we TYPE parvw,
          partn_numb_we TYPE vbak-kunnr,
          itm_numb      TYPE vbap-posnr,
          material      TYPE vbap-matnr,
          plant         TYPE vbap-werks,
          quantity      TYPE vbap-zmeng,
          quantity_unit TYPE vbap-zieme,
        END OF ty_data.

* Typage de la table qui servira à afficher les commandes de vente créées
TYPES : BEGIN OF ty_cv,
          vbeln     TYPE vbak-vbeln,       " N° de commande de vente
          auart     TYPE vbak-auart,       " Type de commande
          erdat     TYPE vbak-erdat,       " Date de création de la commande
          erzet     TYPE vbak-erzet,       " Heure de création de la commande
          vdatu     TYPE vbak-vdatu,       " Date de livraison souhaitée
          vkorg     TYPE vbak-vkorg,       " Organisation commerciale
          vtweg     TYPE vbak-vtweg,       " Canal de distribution
          spart     TYPE vbak-spart,       " Secteur d'activité
          kunnr_ana TYPE vbap-kunnr_ana,   " N°Client donneur d'ordre
          name1     TYPE kna1-name1,       " Nom du donneur d'ordre
          kunwe_ana TYPE vbap-kunwe_ana,   " N° Client réceptionnaire
          name2     TYPE kna1-name1,       " Nom du réceptionnaire
          adress    TYPE string,           " Adresse du réceptionnaire : Code postal + Ville + Pays
          posnr     TYPE vbap-posnr,       " N° de Poste de la commande
          matnr     TYPE vbap-matnr,       " N° Article
          maktx     TYPE makt-maktx,       " Description de l'article (Dans la langue de connexion du client)
          werks     TYPE vbap-werks,       " Division
          zmeng     TYPE vbap-zmeng,       " Quantité commande de vente
          zieme     TYPE vbap-zieme,       " unité de quantité
          ntgew     TYPE mara-ntgew,       " poids net de l'article
          gewei     TYPE mara-gewei,       " unité de poids
          pds_post  TYPE mara-ntgew,       " poids total du poste
          pds_tot   TYPE mara-ntgew,       " poids total de la commande
          check     TYPE zcheckbox,
        END OF ty_cv.

TYPES : BEGIN OF ty_header,
          vbeln     TYPE vbak-vbeln,
          auart     TYPE vbak-auart,
          erdat     TYPE vbak-erdat,
          erzet     TYPE vbak-erzet,
          vdatu     TYPE vbak-vdatu,
          vkorg     TYPE vbak-vkorg,
          vtweg     TYPE vbak-vtweg,
          spart     TYPE vbak-spart,
          kunnr_ana TYPE vbap-kunnr_ana,
          name1     TYPE kna1-name1,
          kunwe_ana TYPE vbap-kunwe_ana,
          name2     TYPE kna1-name1,
          adress    TYPE string,
        END OF ty_header,
        BEGIN OF ty_item,
          posnr    TYPE vbap-posnr,
          matnr    TYPE vbap-matnr,
          maktx    TYPE makt-maktx,
          werks    TYPE vbap-werks,
          zmeng    TYPE vbap-zmeng,
          zieme    TYPE vbap-zieme,
          ntgew    TYPE mara-ntgew,
          gewei    TYPE mara-gewei,
          pds_post TYPE mara-ntgew,
          pds_tot  TYPE mara-ntgew,
        END OF ty_item.

TYPES : BEGIN OF ty_cr,
          statut  TYPE zkde_icon,
          message TYPE zkde_message,
        END OF ty_cr.

* Déclaration des tables internes

DATA : gt_file              TYPE tt_line,
       gt_data              TYPE STANDARD TABLE OF ty_data,
       gt_cv                TYPE STANDARD TABLE OF ty_cv,
       gt_alv               TYPE STANDARD TABLE OF vbap,
       go_alv_grid          TYPE REF TO cl_gui_alv_grid,
       gt_fieldcat_grid     TYPE lvc_t_fcat,
       go_custom_container  TYPE REF TO cl_gui_custom_container,
       go_custom_container2 TYPE REF TO cl_gui_custom_container,
       gt_log_handle        TYPE bal_t_logh,
       gt_cr                TYPE STANDARD TABLE OF ty_cr.

DATA:   bdcdata LIKE bdcdata    OCCURS 0 WITH HEADER LINE.

DATA: lr_events        TYPE REF TO cl_salv_events_table,

      lo_alv_functions TYPE REF TO cl_salv_functions,
      lo_columns       TYPE REF TO cl_salv_columns_table,
      lo_column        TYPE REF TO cl_salv_column_table,
      lo_message       TYPE REF TO cx_salv_msg.
DATA  lo_events      TYPE REF TO ycl_event.