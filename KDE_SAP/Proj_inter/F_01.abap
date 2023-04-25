*&---------------------------------------------------------------------*
*& Include          ZPROJ_INTER_2023_F01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Form create_sales_order
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM create_sales_order .

  DATA: lv_vbeln      LIKE vbak-vbeln,
        ls_header     TYPE bapisdhead1,
        ls_headerx    LIKE bapisdhead1x,
        lt_item       TYPE STANDARD TABLE OF bapisditem,
        ls_item       LIKE LINE OF lt_item,
        lt_itemx      TYPE STANDARD TABLE OF bapisditemx,
        ls_itemx      LIKE LINE OF lt_itemx,
        lt_partner    TYPE STANDARD TABLE OF bapipartnr,
        ls_partner    LIKE LINE OF lt_partner,
        lt_return     TYPE STANDARD TABLE OF bapiret2,
        lr_auart      TYPE RANGE OF auart,
        ls_auart      LIKE LINE OF lr_auart,
        lt_tvarvc     TYPE STANDARD TABLE OF tvarvc,
        ls_log        TYPE bal_s_log,
        ls_msg        TYPE bal_s_msg,
        ls_log_handle TYPE balloghndl,
        lv_id_com     TYPE  zid_com_po.

  CONSTANTS : lc_object TYPE balobj_d VALUE 'ZPROJ_CV'.

* Récupération des types de commandes autorisés pour la création des commandes de vente
  SELECT  * FROM tvarvc
  INTO TABLE lt_tvarvc
  WHERE name = 'ZPROJ_CV_AUART'
  AND   type = 'S'.
  IF sy-subrc = 0.
* On construit un range à partir de cette liste
    LOOP AT lt_tvarvc ASSIGNING FIELD-SYMBOL(<fs_tvarvc>).
      ls_auart-sign   = <fs_tvarvc>-sign.
      ls_auart-option = <fs_tvarvc>-opti.
      ls_auart-low    = <fs_tvarvc>-low.
      APPEND ls_auart TO lr_auart.
    ENDLOOP.
  ENDIF.

  ls_log-object = 'ZLOG_PROJ'.          "Object name
  ls_log-aluser = sy-uname.        "Username
  ls_log-alprog = sy-repid.          "report name


  CALL FUNCTION 'BAL_LOG_CREATE'
    EXPORTING
      i_s_log                 = ls_log
    IMPORTING
      e_log_handle            = ls_log_handle
    EXCEPTIONS
      log_header_inconsistent = 1
      OTHERS                  = 2.

  IF sy-subrc <> 0.
* Implement suitable error handling here
    EXIT.
  ENDIF.


  LOOP AT gt_data ASSIGNING FIELD-SYMBOL(<fs_data>).
    CLEAR : ls_header, ls_headerx, ls_partner, lt_partner , lt_item, lt_itemx, lt_return, lv_vbeln, ls_msg.

    IF <fs_data>-id_com = lv_id_com.
      CONTINUE.
    ENDIF.

    lv_id_com = <fs_data>-id_com.
    CHECK <fs_data>-doc_type IN lr_auart.


    ls_header-doc_type = <fs_data>-doc_type.
    ls_header-sales_org = <fs_data>-sales_org.
    ls_header-distr_chan = <fs_data>-distr_chan.
    ls_header-division = <fs_data>-sect_act.
    ls_header-req_date_h = sy-datum + 5.

    ls_headerx-doc_type = 'X'.
    ls_headerx-sales_org =  'X'.
    ls_headerx-distr_chan =  'X'.
    ls_headerx-division =  'X'.
    ls_headerx-req_date_h = 'X'.
    ls_headerx-updateflag = 'I'.

    ls_partner-partn_numb = <fs_data>-partn_numb_ag.
    ls_partner-partn_role = <fs_data>-partn_role_ag.

    APPEND ls_partner TO lt_partner.

    ls_partner-partn_numb = <fs_data>-partn_numb_we.
    ls_partner-partn_role = <fs_data>-partn_role_we.

    APPEND ls_partner TO lt_partner.

    LOOP AT gt_data ASSIGNING FIELD-SYMBOL(<fs_data2>)
      WHERE id_com = <fs_data>-id_com.
      ls_item-itm_number = <fs_data2>-itm_numb.
      ls_item-material = <fs_data2>-material.
      ls_item-plant = <fs_data2>-plant.
      ls_item-target_qty =  <fs_data2>-quantity.

      CALL FUNCTION 'CONVERSION_EXIT_CUNIT_INPUT'
        EXPORTING
          input          = <fs_data2>-quantity_unit
          language       = sy-langu
        IMPORTING
          output         = <fs_data2>-quantity_unit
        EXCEPTIONS
          unit_not_found = 1
          OTHERS         = 2.

      ls_item-target_qu = <fs_data2>-quantity_unit.

      APPEND ls_item TO lt_item.

      ls_itemx-itm_number = 'X'.
      ls_itemx-material = 'X'.
      ls_itemx-plant = 'X'.
      ls_itemx-target_qty =  'X'.
      ls_itemx-target_qu = 'X'.
      ls_itemx-updateflag = 'I'.

      APPEND ls_itemx TO lt_itemx.

    ENDLOOP.

    CALL FUNCTION 'BAPI_SALESDOCU_CREATEFROMDATA1'
      EXPORTING
        sales_header_in  = ls_header
        sales_header_inx = ls_headerx
      IMPORTING
        salesdocument_ex = lv_vbeln
      TABLES
        return           = lt_return
        sales_items_in   = lt_item
        sales_items_inx  = lt_itemx
        sales_partners   = lt_partner.

    LOOP AT lt_return ASSIGNING FIELD-SYMBOL(<fs_return>) WHERE type = 'E' OR type = 'A'.
      EXIT.
    ENDLOOP.

    IF sy-subrc = 0. "si c'est égal à 0, ERREUR!
      ls_msg-msgty = 'E'.
      ls_msg-msgid = 'ZKDE_MESS'.
      ls_msg-msgno = 012.
      ls_msg-msgv1 = <fs_data>-id_com.
      ROLLBACK WORK.
    ELSE.          "sinon si diffent de 0 alors succès.
      ls_msg-msgty = 'S'.
      ls_msg-msgid = 'ZKDE_MESS'.
      ls_msg-msgno = 013.
      ls_msg-msgv1 = lv_vbeln.
      ls_msg-msgv2 = <fs_data>-id_com.
      COMMIT WORK AND WAIT.
    ENDIF.
    CALL FUNCTION 'BAL_LOG_MSG_ADD'
      EXPORTING
        i_log_handle     = ls_log_handle
        i_s_msg          = ls_msg
      EXCEPTIONS
        log_not_found    = 1
        msg_inconsistent = 2
        log_is_full      = 3
        OTHERS           = 4.
    IF sy-subrc = 0.
      INSERT ls_log_handle INTO TABLE gt_log_handle.
    ENDIF.

  ENDLOOP.

  CALL FUNCTION 'BAL_DB_SAVE'
    EXPORTING
      i_client         = sy-mandt
      i_save_all       = 'X'
      i_t_log_handle   = Gt_log_handle
    EXCEPTIONS
      log_not_found    = 1
      save_not_allowed = 2
      numbering_error  = 3
      OTHERS           = 4.
  IF sy-subrc <> 0.
* Implement suitable error handling here
  ENDIF.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form select_data
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM select_data.

* Select avec jointure sur VBAK VBAP KNA1 MARA MAKT

  DATA : lv_post TYPE ntgew,
         lv_comm TYPE f.

  SELECT vbak~vbeln,                                                               " Numéro de la commande de vente
         vbak~auart,                                                               " Type de doc. De vente
         vbak~erdat,                                                               " Date de création de la commande
         vbak~erzet,                                                               " Heure de création
         vbak~vdatu,                                                               " Date de livraison souhaitée
         vbak~vkorg,                                                               " Organisation commerciale
         vbak~vtweg,                                                               " Canal de distribution
         vbak~spart,                                                               " Secteur d’activité
         vbap~kunnr_ana,                                                           " Client donneur d’ordre
         kna1~name1,                                                               " Nom du donneur d’ordre
         vbap~kunwe_ana,                                                           " Client réceptionnaire
         kna1~name2,                                                               " Nom du client réceptionnaire
         kna1~pstlz && @space && kna1~ort01 && @space && kna1~land1 AS address,    " KNA1 - Adresse du client réceptionnaire (Code postal + Ville + Pays)
         vbap~posnr,                                                               " Numéro de poste Com.
         vbap~matnr,                                                               " Article
         makt~maktx,                                                               " Désignation article
         vbap~werks,                                                               " Division
         vbap~zmeng,                                                               " Quantité commandée
         vbap~zieme,                                                               " Unité de quantité
         mara~ntgew,                                                               " Poids net de l’article
         mara~gewei                                                               " Unité de poids

******************************  Depuis les tables  ****************************************
    FROM vbak
    INNER JOIN vbap ON vbap~vbeln = vbak~vbeln
    LEFT OUTER JOIN kna1 ON kna1~kunnr = vbap~kunnr_ana
    LEFT OUTER JOIN makt ON makt~matnr = vbap~matnr
                   AND makt~spras = @sy-langu
    LEFT OUTER JOIN mara ON mara~matnr = makt~matnr
    WHERE vbak~auart IN @s_auart
      AND vbak~vbeln IN @s_vbeln
      AND vbak~vkorg IN @s_vkorg
      AND vbak~vtweg IN @s_vtweg
      AND vbak~spart IN @s_spart
      AND vbap~kunnr_ana IN @s_kunnr
      AND vbap~matnr IN @s_matnr
      AND vbap~werks IN @s_plant
      AND vbak~erdat IN @s_erdat
    ORDER BY vbak~erdat DESCENDING, vbak~erzet DESCENDING
    INTO TABLE @gt_cv.
  IF sy-subrc <> 0.
    MESSAGE e000(zkde_mess).
  ELSE.
    EXPORT data FROM gt_cv TO MEMORY ID 'MEM'.
  ENDIF.

****************************  Calcul poids des postes + poids total de la commande   ******************************************
  LOOP AT gt_cv ASSIGNING FIELD-SYMBOL(<fs_cv>).
    AT NEW vbeln.
      CLEAR <fs_cv>-pds_tot.
    ENDAT.

    LOOP AT gt_cv ASSIGNING FIELD-SYMBOL(<fs_cv2>) WHERE vbeln = <fs_cv>-vbeln.
      <fs_cv2>-pds_post = <fs_cv2>-zmeng * <fs_cv2>-ntgew.
      <fs_cv>-pds_tot =  <fs_cv>-pds_tot  + <fs_cv2>-pds_post.
    ENDLOOP.
  ENDLOOP.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form display_data
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM display_data.

  DATA: lo_alv           TYPE REF TO cl_salv_table,
        lr_events        TYPE REF TO cl_salv_events_table,
        lo_events        TYPE REF TO ycl_event,
        lo_alv_functions TYPE REF TO cl_salv_functions,
        lo_columns       TYPE REF TO cl_salv_columns_table,
        lo_message       TYPE REF TO cx_salv_msg.

  TRY.
      CALL METHOD cl_salv_table=>factory(
        IMPORTING
          r_salv_table = lo_alv
        CHANGING
          t_table      = gt_cv ).
    CATCH cx_salv_msg INTO lo_message.
  ENDTRY.


  lo_alv_functions = lo_alv->get_functions( ).
  lo_alv_functions->set_all( abap_true ).

  lo_columns = lo_alv->get_columns( ).
  lo_columns->set_optimize( abap_true ).

  lr_events = lo_alv->get_event( ).
*
** Custom Button Function
*  lo_alv_functions->add_function( name = 'PRINT'
*                                 icon = 'ICON_PRINT'
*                                 text = 'PRINT COMMANDE DE VENTE'
*                                 tooltip = 'Imprimer un formulaire smartform'
*                                 position = if_salv_c_function_position=>right_of_salv_functions ).

  CREATE OBJECT lo_events.


*** Check Box
*  SET HANDLER click_button FOR lr_events.
*** Button Functionality
*  SET HANDLER button_click FOR lr_events.
  SET HANDLER lo_events->m_double_click FOR lr_events.
  SET HANDLER lo_events->m_hotspot      FOR lr_events.
  SET HANDLER lo_events->m_usercommand FOR lr_events.

  lo_alv->display( ).

ENDFORM.
*&---------------------------------------------------------------------*
*& Form Init_data
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM Init_data .

  " On initialise toutes les variables globales
  CLEAR : gt_file, gt_cv, gt_data, gt_alv.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form get_data_from_file
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM get_data_from_file .

  DATA: lv_filename TYPE rlgrap-filename,
        lv_string   TYPE string,
        ls_file     LIKE LINE OF gt_file.

* Si l'option "fichier local" a été choisie par l'utilisateur
  IF p_rad1 = 'X'.

    lv_string = p_fname.
* On appelle de MF pour récupérer le contenu du fichier CSV dans une table interne
    CALL FUNCTION 'GUI_UPLOAD'
      EXPORTING
        filename                = lv_string
        filetype                = 'ASC'
      TABLES
        data_tab                = gt_file
      EXCEPTIONS
        file_open_error         = 1
        file_read_error         = 2
        no_batch                = 3
        gui_refuse_filetransfer = 4
        invalid_type            = 5
        no_authority            = 6
        unknown_error           = 7
        bad_data_format         = 8
        header_not_allowed      = 9
        separator_not_allowed   = 10
        header_too_long         = 11
        unknown_dp_error        = 12
        access_denied           = 13
        dp_out_of_memory        = 14
        disk_full               = 15
        dp_timeout              = 16
        OTHERS                  = 17.
    IF sy-subrc <> 0.
      CLEAR gt_file.
      MESSAGE e011(zkde_mess).
    ENDIF.
  ENDIF.

* Si l'option "fichier serveur" a été sélectionné par l'utilisateur
  IF p_rad2 = 'X'.
    CONCATENATE p_lpath p_lname INTO lv_filename SEPARATED BY '/'.
    TRANSLATE lv_filename TO LOWER CASE.
    OPEN DATASET lv_filename FOR INPUT IN TEXT MODE ENCODING DEFAULT.
    IF sy-subrc IS INITIAL.
      DO.
        CLEAR ls_file.
        READ DATASET lv_filename INTO ls_file-line.
        IF sy-subrc = 0.
          APPEND ls_file TO gt_file.
        ELSE.
          EXIT.
        ENDIF.
      ENDDO.
    ENDIF.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form prepare_data
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM prepare_data .

  DATA : lv_dummy TYPE string.  "Variable inutile qui sert juste à récupérer la 2ème partie de l'ID COM

  DELETE gt_file INDEX 1.

  LOOP AT gt_file ASSIGNING FIELD-SYMBOL(<fs_file>).
    SPLIT <fs_file>-line AT ';' INTO TABLE DATA(lt_split_csv).
    IF  lines( lt_split_csv ) NE 14.
      CONTINUE.
    ENDIF.

    IF lt_split_csv IS NOT INITIAL.
      APPEND INITIAL LINE TO gt_data ASSIGNING FIELD-SYMBOL(<fs_data>).

      IF <fs_data> IS ASSIGNED.
        SPLIT lt_split_csv[ 1 ] AT 'P' INTO <fs_data>-id_com lv_dummy.
        <fs_data>-doc_type      = lt_split_csv[ 2 ].
        <fs_data>-sales_org     = lt_split_csv[ 3 ].
        <fs_data>-distr_chan    = lt_split_csv[ 4 ].
        <fs_data>-sect_act = lt_split_csv[ 5 ].
        <fs_data>-partn_role_ag = lt_split_csv[ 6 ].
        <fs_data>-partn_numb_ag = lt_split_csv[ 7 ].
        <fs_data>-partn_role_we = lt_split_csv[ 8 ].
        <fs_data>-partn_numb_we = lt_split_csv[ 9 ].
        <fs_data>-itm_numb      = lt_split_csv[ 10 ].
        <fs_data>-material      = lt_split_csv[ 11 ].
        <fs_data>-plant         = lt_split_csv[ 12 ].
        <fs_data>-quantity      = lt_split_csv[ 13 ].
        <fs_data>-quantity_unit = lt_split_csv[ 14 ].
      ENDIF.
    ENDIF.

  ENDLOOP.

ENDFORM.

FORM double_click_event USING lv_row    TYPE i
                        lv_column TYPE lvc_fname.

  DATA : lt_header TYPE ztcv_header,
         ls_header LIKE LINE OF lt_header,
         lt_item   TYPE ZTCV_item,
         ls_item   LIKE LINE OF lt_item.
  DATA : lv_fname   TYPE rs38l_fnam,  "Code du module fonction associé au smartform
         lv_sf_name TYPE tdsfname.    "Nom smartform
  DATA : ls_cv LIKE LINE OF gt_cv.

  lv_sf_name = 'ZCV_KDE'.

  READ TABLE gt_cv INTO ls_cv INDEX lv_row.
  IF sy-subrc = 0.
    CASE lv_column.
      WHEN 'VBELN'.
        SET PARAMETER ID 'AUN' FIELD ls_cv-vbeln.
        CALL TRANSACTION 'VA03' AND SKIP FIRST SCREEN.
      WHEN OTHERS.

        ls_header-vbeln = ls_cv-vbeln.
        ls_header-auart = ls_cv-auart.
        ls_header-erdat = ls_cv-erdat.
        ls_header-erzet = ls_cv-erzet.
        ls_header-vdatu = ls_cv-vdatu.
        ls_header-vkorg = ls_cv-vkorg.
        ls_header-vtweg = ls_cv-vtweg.
        ls_header-spart = ls_cv-spart.
        ls_header-kunnr_ana = ls_cv-kunnr_ana.
        ls_header-name1 = ls_cv-name1.
        ls_header-kunwe_ana = ls_cv-kunwe_ana.
        ls_header-name2 = ls_cv-name2.
        ls_header-adress = ls_cv-adress.
        APPEND ls_header TO lt_header.

        LOOP AT gt_cv ASSIGNING FIELD-SYMBOL(<fs_cv>) WHERE vbeln = ls_cv-vbeln.
          ls_item-posnr    = <fs_cv>-posnr.
          ls_item-matnr    = <fs_cv>-matnr.
          ls_item-maktx    = <fs_cv>-maktx.
          ls_item-werks    = <fs_cv>-werks.
          ls_item-zmeng    = <fs_cv>-zmeng.
          ls_item-zieme    = <fs_cv>-zieme.
          ls_item-ntgew    = <fs_cv>-ntgew.
          ls_item-gewei    = <fs_cv>-gewei.
          ls_item-pds_post = <fs_cv>-pds_post.
          ls_item-pds_tot  = <fs_cv>-pds_tot.
          APPEND ls_item TO lt_item.
        ENDLOOP.

        CALL FUNCTION 'SSF_FUNCTION_MODULE_NAME'
          EXPORTING
            formname           = lv_sf_name
            variant            = ' '
            direct_call        = ' '
          IMPORTING
            fm_name            = lv_fname
          EXCEPTIONS
            no_form            = 1
            no_function_module = 2
            OTHERS             = 3.

        "Appel du smartform
        CALL FUNCTION lv_fname
          EXPORTING
            it_header        = lt_header
            it_item          = lt_item
          EXCEPTIONS
            formatting_error = 1
            internal_error   = 2
            send_error       = 3
            user_canceled    = 4
            OTHERS           = 5.

    ENDCASE.
  ENDIF.

ENDFORM.

FORM hotspot_event USING lv_row    TYPE i
                         lv_column TYPE fieldname.

*  DATA : lo_col TYPE REF TO cl_salv_column_table.
*
*  TRY.
*      lo_col ?= go_cols->get_column( 'VBELN' ).
*    CATCH cx_salv_not_found.
*      MESSAGE e052(sy) WITH lv_column.
*  ENDTRY.
*
*  IF lo_col IS BOUND.
*    lo_col->set_cell_type( if_salv_c_cell_type=>hotspot ).
*  ENDIF.


  READ TABLE gt_cv ASSIGNING FIELD-SYMBOL(<fs_cv>) INDEX lv_row.
  IF sy-subrc IS INITIAL.
    IF <fs_cv>-check IS INITIAL.
      <fs_cv>-check = 'X'.
    ELSE.
      CLEAR <fs_cv>-check.
    ENDIF.
  ENDIF.

  go_alv->refresh( ).

ENDFORM.
*&---------------------------------------------------------------------*
*& Form check_data
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM check_data .

* Un seul check à titre d'exemple.

  "Récupération des articles existants en BDD
  SELECT matnr FROM mara INTO TABLE @DATA(lt_mara).

* Vérification de l'existence des articles présents dans le fichier

  LOOP AT gt_data ASSIGNING FIELD-SYMBOL(<fs_data>).
    READ TABLE lt_mara ASSIGNING FIELD-SYMBOL(<fs_mara>) WITH KEY matnr = <fs_data>-material.
    IF sy-subrc <> 0.
      " Si l'article du fichier n'existe pas dans la table LT_MARA et donc dans la BDD
      " On vide le champ MATERIAL pour une suppression ultérieure de la ligne
      CLEAR <fs_data>-material.
    ENDIF.
  ENDLOOP.

  " On supprime de la table GT_DATA les lignes dont le champ Material est vide
  DELETE gt_data WHERE material IS INITIAL.


ENDFORM.
*&---------------------------------------------------------------------*
*& Module STATUS_9001 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE status_9001 OUTPUT.
  SET PF-STATUS 'STATUT_GUI_9001'.
  SET TITLEBAR 'CREA'.
ENDMODULE.
*&---------------------------------------------------------------------*
*& Module STATUS_9002 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE status_9002 OUTPUT.
  SET PF-STATUS 'STATUT_GUI_9002'.
  SET TITLEBAR 'ALV'.
ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_9001  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_9001 INPUT.

  CASE sy-ucomm.
    WHEN 'BACK' OR 'CANCEL'.
      LEAVE TO SCREEN 0.
    WHEN 'EXIT'.
      LEAVE PROGRAM.
    WHEN OTHERS.
  ENDCASE.

ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_9002  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_9002 INPUT.

  DATA : ls_control TYPE ssfctrlop,
         ls_output  TYPE ssfcompop.
  DATA : lt_header  TYPE ztcv_header,
         ls_header  LIKE LINE OF lt_header,
         lt_item    TYPE ztcv_item,
         ls_item    LIKE LINE OF lt_item,
         lv_fname   TYPE rs38l_fnam,  "Code du module fonction associé au smartform
         lv_sf_name TYPE tdsfname.    "Nom smartform

  lv_sf_name = 'ZCOMV_KDE'.
  ls_control-preview = 'X'.
  ls_output-tdnoprev = ' '.

  CASE sy-ucomm.
    WHEN 'BACK' OR 'CANCEL'.
      LEAVE TO SCREEN 0.
    WHEN 'EXIT'.
      LEAVE PROGRAM.
    WHEN 'SMART'.
      READ TABLE gt_cv ASSIGNING FIELD-SYMBOL(<fs_cv>) WITH KEY check = 'X'.
      IF sy-subrc = 0.
        ls_header-vbeln = <fs_cv>-vbeln.
        ls_header-auart = <fs_cv>-auart.
        ls_header-erdat = <fs_cv>-erdat.
        ls_header-erzet = <fs_cv>-erzet.
        ls_header-vdatu = <fs_cv>-vdatu.
        ls_header-vkorg = <fs_cv>-vkorg.
        ls_header-vtweg = <fs_cv>-vtweg.
        ls_header-spart = <fs_cv>-spart.
        ls_header-kunnr_ana = <fs_cv>-kunnr_ana.
        ls_header-name1     = <fs_cv>-name1.
        ls_header-kunwe_ana = <fs_cv>-kunwe_ana.
        ls_header-name2     = <fs_cv>-name2.
        ls_header-adress    = <fs_cv>-adress.

        APPEND ls_header TO lt_header.

        LOOP AT gt_cv ASSIGNING FIELD-SYMBOL(<fs_cv2>) WHERE vbeln = <fs_cv>-vbeln.
          ls_item-posnr    = <fs_cv2>-posnr.
          ls_item-matnr    = <fs_cv2>-matnr.
          ls_item-maktx    = <fs_cv2>-maktx.
          ls_item-werks    = <fs_cv2>-werks.
          ls_item-zmeng    = <fs_cv2>-zmeng.
          ls_item-zieme    = <fs_cv2>-zieme.
          ls_item-ntgew    = <fs_cv2>-ntgew.
          ls_item-gewei    = <fs_cv2>-gewei.
          ls_item-pds_post = <fs_cv2>-pds_post.
          ls_item-pds_tot  = <fs_cv2>-pds_tot.
          APPEND ls_item TO lt_item.
        ENDLOOP.

        CALL FUNCTION 'SSF_FUNCTION_MODULE_NAME'
          EXPORTING
            formname           = lv_sf_name
            variant            = ' '
            direct_call        = ' '
          IMPORTING
            fm_name            = lv_fname
          EXCEPTIONS
            no_form            = 1
            no_function_module = 2
            OTHERS             = 3.

        "Appel du smartform
        CALL FUNCTION lv_fname
          EXPORTING
            iT_header          = lt_header
            it_item            = lt_item
            control_parameters = ls_control
            output_options     = ls_output
          EXCEPTIONS
            formatting_error   = 1
            internal_error     = 2
            send_error         = 3
            user_canceled      = 4
            OTHERS             = 5.
      ENDIF.
    WHEN OTHERS.

  ENDCASE.


ENDMODULE.
*&---------------------------------------------------------------------*
*& Module CREATE_SALES_ORDER OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE create_sales_order OUTPUT.

  PERFORM get_data_from_file.
  PERFORM prepare_data.
  PERFORM check_data.
  PERFORM create_sales_order.
  PERFORM display_log.

ENDMODULE.
*&---------------------------------------------------------------------*
*& Module DISPLAY_ALV OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE display_alv OUTPUT.

  PERFORM select_data.
  PERFORM display_data_dynp.
ENDMODULE.
*&---------------------------------------------------------------------*
*& Form display_data_dynp
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM display_data_dynp .

  DATA: site_container TYPE REF TO cl_gui_custom_container,
        html           TYPE REF TO cl_gui_html_viewer.


** Chargement de l'image dans le 1er container

  CREATE OBJECT site_container
    EXPORTING
      container_name = 'CONTAINER_FUN'.
  CREATE OBJECT html
    EXPORTING
      parent = site_container.

  CALL METHOD html->show_url
    EXPORTING
      url = 'https://i.guim.co.uk/img/media/7889fca13a88183f5f1eaf2c0bfa3f3b96bd7373/0_17_2079_1247/master/2079.jpg?width=1300&quality=45&dpr=2&s=none'.
*      url = 'https://www.youtube.com/watch?v=FJ2tzqCl0L4'.

* Création du Custom container en fonction de l'élement (du nom) dans mon Dynpro
  go_custom_container = NEW cl_gui_custom_container( container_name = 'CONTAINER_ALV' ).

  TRY.
      CALL METHOD cl_salv_table=>factory(
        EXPORTING
          r_container    = go_custom_container
          container_name = 'CONTAINER_ALV'
        IMPORTING
          r_salv_table   = go_alv
        CHANGING
          t_table        = gt_cv ).
    CATCH cx_salv_msg INTO lo_message.
  ENDTRY.

  lo_alv_functions = go_alv->get_functions( ).
  lo_alv_functions->set_all( abap_true ).
*
* Custom Button Function
* Ajout du bouton pour impression du smartform
  lo_alv_functions->add_function( name = 'PRINT_SF'
                                 icon = 'ICON_PRINT'
                                 text = 'IMPRESSION DU FORMULAIRE SMARTFORM'
                                 tooltip = 'Imprimer un formulaire SMARTFORM'
                                  position = if_salv_c_function_position=>right_of_salv_functions ).

* Ajout du bouton pour impression de l'adobe
  lo_alv_functions->add_function( name = 'PRINT_ADOBE'
                                icon = 'ICON_PRINT'
                                text = 'IMPRESSION DU FORMULAIRE ADOBE'
                                tooltip = 'Imprimer un formulaire ADOBE'
                                 position = if_salv_c_function_position=>right_of_salv_functions ).

* Gestion des colonnes de mon objet ALV via l'objet lo_columns
  lo_columns = go_alv->get_columns( ).
  lo_columns->set_optimize( abap_true ).

* Ajout d'une checkbox hotspot via l'objet lo_column
  lo_column ?= lo_columns->get_column('CHECK').
  lo_column->set_cell_type( if_salv_c_cell_type=>checkbox_hotspot ).
  lO_column->set_icon( if_salv_c_bool_sap=>true ).

  lr_events = go_alv->get_event( ).

  CREATE OBJECT lo_events.

*  SET HANDLER lo_events->m_double_click FOR lr_events.
  SET HANDLER lo_events->m_hotspot     FOR lr_events.
  SET HANDLER lo_events->m_usercommand FOR lr_events.

  go_alv->display( ).




** Création du Field Catalog
*  CALL FUNCTION 'LVC_FIELDCATALOG_MERGE'
*    EXPORTING
*      i_structure_name       = 'ZPROJ_ALV_KDE'
*    CHANGING
*      ct_fieldcat            = gt_fieldcat_grid
*    EXCEPTIONS
*      inconsistent_interface = 1
*      program_error          = 2
*      OTHERS                 = 3.
*  IF sy-subrc <> 0.
*    FREE gt_fieldcat_grid.
*    RETURN.
*  ENDIF.
*
*  "Modification du FieldCat pour la sélection de plusieurs lignes
*
*  LOOP AT gt_fieldcat_grid ASSIGNING FIELD-SYMBOL(<fs_fieldcat_grid>).
*
*    "AJOUT d'une colonne CHECKBOX de ZTS_PROJET_INT_QBA de TYPE CHAR1 EN SE11 que l'on rendra éditable afin de ne pas rendre tous les champs de notre ALV éditable
*
*    CASE <fs_fieldcat_grid>-fieldname.
*      WHEN 'CHECKBOX'.
*        <fs_fieldcat_grid>-checkbox = abap_true. "Permet de cocher plusieurs lignes
*        <fs_fieldcat_grid>-edit = abap_true. "Rend éditable le champ checkbox ce qui signifie que l'on pourra le cocher ou décocher à loisir!
*        <fs_fieldcat_grid>-tech = abap_true. "Cacher la colonne permettant  de sélectionner plusieurs lignes de l'ALV
*        "Modification du FieldCat pour permettre le hotspot click
*        "DECOMMENTER POUR REACTIVER LA FONCTION DE CREATION PAR HOTSPOT CLICK
**          WHEN 'NUM_ARTICLE'.
**            <fs_fieldcat_grid>-hotspot = abap_true.
*      WHEN OTHERS.
*    ENDCASE.
*
**      WRONG : REND TOUTE l'ALV EDITABLE!!!!!
**      <fs_fieldcat_grid>-edit = abap_true.
*  ENDLOOP.
*
*
** Création de l'objet ALV GRID avec pour Custom Container l'objet créé juste avant
*  go_alv_grid = NEW cl_gui_alv_grid( i_parent = go_custom_container ).
*
** Affichage de l'ALV dans le Custom Container
*  go_alv_grid->set_table_for_first_display(
*    CHANGING
*      it_outtab           =  gt_cv              " Table à afficher
*      it_fieldcatalog     =  gt_fieldcat_grid   " Field catalogue
*   EXCEPTIONS
*     invalid_parameter_combination = 1
*     program_error                 = 2
*     too_many_lines                = 3
*     OTHERS                        = 4 ).
*  IF sy-subrc <> 0.
*    RETURN.
*  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form display_log
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM display_log .

  DATA : ls_display_profile TYPE bal_s_prof,
         lv_control_handle  TYPE balcnthndl.

** Chargement de l'image dans le 1er container

  DATA: site_container TYPE REF TO cl_gui_custom_container,
        html           TYPE REF TO cl_gui_html_viewer.

  CREATE OBJECT site_container
    EXPORTING
      container_name = 'CONTAINER_FUN'.
  CREATE OBJECT html
    EXPORTING
      parent = site_container.

  CALL METHOD html->show_url
    EXPORTING
      url = 'https://stms.fr/nos-equipes/'.



* Création du Custom container en fonction de l'élement (du nom) dans mon Dynpro
  go_custom_container2 = NEW cl_gui_custom_container( container_name = 'CONTAINER_LOG' ).

  "get display profile
  CALL FUNCTION 'BAL_DSP_PROFILE_NO_TREE_GET'
    IMPORTING
      e_s_display_profile = ls_display_profile.

  "create control
  CALL FUNCTION 'BAL_CNTL_CREATE'
    EXPORTING
      i_container         = go_custom_container2
      i_s_display_profile = ls_display_profile
      i_t_log_handle      = Gt_log_handle
    IMPORTING
      e_control_handle    = lv_control_handle
    EXCEPTIONS
      OTHERS              = 1.
  IF sy-subrc <> 0.
    MESSAGE i059(/dematic/dep_check) DISPLAY LIKE 'E'.
    RETURN.
  ENDIF.

  CALL METHOD cl_gui_cfw=>flush.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form load_pic_from_db
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      <-- URL
*&---------------------------------------------------------------------*
FORM load_pic_from_db  CHANGING url.

  DATA query_table LIKE w3query OCCURS 1 WITH HEADER LINE.
  DATA html_table LIKE w3html OCCURS 1.
  DATA return_code LIKE w3param-ret_code.
  DATA content_type LIKE w3param-cont_type.
  DATA content_length LIKE w3param-cont_len.
  DATA pic_data LIKE w3mime OCCURS 0.
  DATA pic_size TYPE i.

  REFRESH query_table.
  query_table-name = '_OBJECT_ID'.
* you put the object name here
  query_table-value = 'ZSTMS'.
  APPEND query_table.

  CALL FUNCTION 'WWW_GET_MIME_OBJECT'
    TABLES
      query_string        = query_table
      html                = html_table
      mime                = pic_data
    CHANGING
      return_code         = return_code
      content_type        = content_type
      content_length      = content_length
    EXCEPTIONS
      object_not_found    = 1
      parameter_not_found = 2
      OTHERS              = 3.
  IF sy-subrc = 0.
    pic_size = content_length.
  ENDIF.

  CALL FUNCTION 'DP_CREATE_URL'
    EXPORTING
      type     = 'image'
      subtype  = cndp_sap_tab_unknown
      size     = pic_size
      lifetime = cndp_lifetime_transaction
    TABLES
      data     = pic_data
    CHANGING
      url      = url
    EXCEPTIONS
      OTHERS   = 1.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form generate_output
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM generate_output .

  DATA: lo_dock TYPE REF TO cl_gui_docking_container,
        lo_cont TYPE REF TO cl_gui_container,
        lo_alv  TYPE REF TO cl_salv_table.
*
*   import output table from the memory and free afterwards
  IMPORT data TO GT_cv FROM MEMORY ID 'MEM'.
*
*   Only if there is some data
  CHECK Gt_cv IS NOT INITIAL.
*
*   Create a docking control at bottom
  CHECK lo_dock IS INITIAL.
  CREATE OBJECT lo_dock
    EXPORTING
      repid = sy-cprog
      dynnr = sy-dynnr
      ratio = 80
      side  = cl_gui_docking_container=>dock_at_bottom
      name  = 'DOCK_CONT'.
  IF sy-subrc <> 0.
    MESSAGE 'Error in the Docking control' TYPE 'S'.
  ENDIF.
*
*   Create a SALV for output
  CHECK lo_alv IS INITIAL.
  TRY.
*       Narrow Casting: To initialize custom container from
*       docking container
      lo_cont ?= lo_dock.
*
*       SALV Table Display on the Docking container
      CALL METHOD cl_salv_table=>factory
        EXPORTING
          list_display   = if_salv_c_bool_sap=>false
          r_container    = lo_cont
          container_name = 'DOCK_CONT'
        IMPORTING
          r_salv_table   = lo_alv
        CHANGING
          t_table        = gt_cv.
    CATCH cx_salv_msg .
  ENDTRY.
*
*   Pf status
  DATA: lo_functions TYPE REF TO cl_salv_functions_list.
  lo_functions = lo_alv->get_functions( ).
  lo_functions->set_default( abap_true ).
*
*   output display
  lo_alv->display( ).

ENDFORM.
*&---------------------------------------------------------------------*
*& Form batch_input
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM batch_input_call_Transac.

  DATA : lv_id_com        TYPE  zid_com_po,
         ls_cr            LIKE LINE OF gt_cr,
         lv_poste         TYPE i,
         lv_quant         TYPE string,
         lt_message       TYPE STANDARD TABLE OF bdcmsgcoll WITH HEADER LINE,
         lo_alv           TYPE REF TO cl_salv_table,
         lo_alv_functions TYPE REF TO cl_salv_functions,
         lo_columns       TYPE REF TO cl_salv_columns_table,
         lv_mabnr         TYPE string,
         lv_kwmeng        TYPE string.


*1/ Réussir à créer une commande de vente manuellement via la transaction VA01
*   Et identifier les champs obligatoires pour permettre la création

*2/ Identifier le nom des zones dynpro et des écrans correspondant
*   pour construire votre enchainement de BATCH INPUT (Perform bdc_dynpro et bdc_field)
*   NB : Vous pouvez utiliser la transaction SHDB pour enregistrer les manipulations faites au niveau transactionnel

*3 / Remplacer les valeurs en "dur" que vous aurez utiliser dans votre BI par les valeurs
*    contenues dans le fichier texte

  LOOP AT gt_data ASSIGNING FIELD-SYMBOL(<fs_data>).
    CLEAR bdcdata.

    IF <fs_data>-id_com = lv_id_com.
      CONTINUE.
    ENDIF.

    lv_id_com = <fs_data>-id_com.

* On mappe les données d'en-tête qui sont les mêmes sur toutes les lignes d'une même commande

    PERFORM bdc_dynpro USING 'SAPMV45A' '0101'.
    PERFORM bdc_field  USING 'BDC_CURSOR' 'VBAK-AUART'.
*    PERFORM bdc_field  USING 'VBAK-AUART' 'JRE'.
    PERFORM bdc_field  USING 'VBAK-AUART' <fs_data>-doc_type.
    PERFORM bdc_field  USING 'BDC_CURSOR' 'VBAK-VKORG'.
*    PERFORM bdc_field  USING 'VBAK-VKORG' '1710'.
    PERFORM bdc_field  USING 'VBAK-VKORG' <fs_data>-sales_org.
    PERFORM bdc_field  USING 'BDC_CURSOR' 'VBAK-VTWEG'.
*    PERFORM bdc_field  USING 'VBAK-VTWEG' '10'.
    PERFORM bdc_field  USING 'VBAK-VTWEG' <fs_data>-distr_chan.
    PERFORM bdc_field  USING 'BDC_CURSOR' 'VBAK-SPART'.
*    PERFORM bdc_field  USING 'VBAK-SPART' '00'.
    PERFORM bdc_field  USING 'VBAK-SPART' <fs_data>-sect_act.
    PERFORM bdc_dynpro USING 'SAPMV45A' '4001'.
    PERFORM bdc_field  USING 'BDC_CURSOR' 'KUAGV-KUNNR'.
*    PERFORM bdc_field  USING 'KUAGV-KUNNR' 'USCU_S04'.
    PERFORM bdc_field  USING 'KUAGV-KUNNR' <fs_data>-partn_numb_ag.
    PERFORM bdc_field  USING 'BDC_CURSOR' 'KUWEV-KUNNR'.
*    PERFORM bdc_field  USING 'KUWEV-KUNNR' 'USCU_L01'.
    PERFORM bdc_field  USING 'KUWEV-KUNNR' <fs_data>-partn_numb_we.
    PERFORM bdc_field  USING 'BDC_CURSOR' 'VBKD-BSTKD'.
    PERFORM bdc_field  USING 'VBKD-BSTKD' '1234'.
    PERFORM bdc_field  USING 'BDC_CURSOR' 'VBAK-AUGRU'.
    PERFORM bdc_field  USING 'VBAK-AUGRU' '007'.
    PERFORM bdc_field  USING 'BDC_SUBSCR' 'SAPMV45A'.

* On doit maintenant récupérer toutes les données de poste d'une même commande
* pour les ajouter toutes dans notre table de données Batch Input
    LOOP AT gt_data ASSIGNING FIELD-SYMBOL(<fs_data2>) WHERE id_com = <fs_data>-id_com.
      CLEAR lv_quant.

      lv_poste = lv_poste + 1.

* On convertit le champ quantité afin qu'il soit adapté au champ du DYNPRO
      MOVE  <fs_data2>-quantity TO lv_quant.

      lv_mabnr =  'RV45A-MABNR(' && lv_poste && ')'.
      lv_kwmeng = 'RV45A-KWMENG(' && lv_poste && ')'.

      PERFORM bdc_field  USING 'BDC_CURSOR' lv_mabnr.
      PERFORM bdc_field  USING lv_mabnr <fs_data2>-material.
      PERFORM bdc_dynpro USING 'SAPMV45A' '4001'.
      PERFORM bdc_field  USING 'BDC_CURSOR' lv_kwmeng.
      PERFORM bdc_field  USING lv_kwmeng lv_quant.

    ENDLOOP.

    PERFORM bdc_dynpro USING 'SAPMV45A' '4001'.
    PERFORM bdc_field  USING 'BDC_OKCODE' '= SICH'.
    CLEAR lv_poste.

    CALL TRANSACTION 'VA01' USING bdcdata MODE 'E' MESSAGES INTO lt_message.

    LOOP AT lt_message.
      CLEAR ls_cr.

      CASE lt_message-msgtyp.
        WHEN 'S'.
          ls_cr-statut = '@08@'.
          MESSAGE s013(zkde_mess) WITH lt_message-msgv2 <fs_data>-id_com INTO ls_cr-message.
          APPEND ls_cr TO gt_cr.
        WHEN 'E'.
          ls_cr-statut = '@0A@'.
          MESSAGE e012(zkde_mess) WITH <fs_data>-id_com INTO ls_cr-message.
          APPEND ls_cr TO gt_cr.

      ENDCASE.

    ENDLOOP.

    CLEAR lt_message[].

  ENDLOOP.


* On créé l'objet ALV qui va permettre d'afficher la table de compte rendu
  CALL METHOD cl_salv_table=>factory
    IMPORTING
      r_salv_table = lo_alv
    CHANGING
      t_table      = gt_cr.

  lo_alv_functions = lo_alv->get_functions( ).
  lo_alv_functions->set_all( abap_true ).

  lo_columns = lo_alv->get_columns( ).
  lo_columns->set_optimize( abap_true ).

  lo_alv->display( ).



ENDFORM.
*&---------------------------------------------------------------------*
*& Form bdc_dynpro
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_
*&      --> P_
*&---------------------------------------------------------------------*
FORM bdc_dynpro  USING program dynpro.

  CLEAR bdcdata.
  bdcdata-program = program.
  bdcdata-dynpro = dynpro.
  bdcdata-dynbegin = 'X'.
  APPEND bdcdata.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form bdc_field
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_
*&      --> P_
*&---------------------------------------------------------------------*
FORM bdc_field USING fnam fval.

  CLEAR bdcdata.
  bdcdata-fnam = fnam.
  bdcdata-fval = fval.
  APPEND bdcdata.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form batch_input_session
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM batch_input_session .

  DATA : lv_id_com        TYPE  zid_com_po,
         ls_cr            LIKE LINE OF gt_cr,
         lv_poste         TYPE i,
         lv_quant         TYPE string,
         lt_message       TYPE STANDARD TABLE OF bdcmsgcoll WITH HEADER LINE,
         lo_alv           TYPE REF TO cl_salv_table,
         lo_alv_functions TYPE REF TO cl_salv_functions,
         lo_columns       TYPE REF TO cl_salv_columns_table,
         lv_mabnr         TYPE string,
         lv_kwmeng        TYPE string.

  CALL FUNCTION 'BDC_OPEN_GROUP'
    EXPORTING
      client              = sy-mandt
      group               = 'ZBI_KDE2'
      keep                = 'X'
      user                = sy-uname
    EXCEPTIONS
      client_invalid      = 1
      destination_invalid = 2
      group_invalid       = 3
      group_is_locked     = 4
      holddate_invalid    = 5
      internal_error      = 6
      queue_error         = 7
      running             = 8
      system_lock_error   = 9
      user_invalid        = 10
      OTHERS              = 11.


  LOOP AT gt_data ASSIGNING FIELD-SYMBOL(<fs_data>).
    CLEAR bdcdata.

    IF <fs_data>-id_com = lv_id_com.
      CONTINUE.
    ENDIF.

    lv_id_com = <fs_data>-id_com.

* On mappe les données d'en-tête qui sont les mêmes sur toutes les lignes d'une même commande

    PERFORM bdc_dynpro USING 'SAPMV45A' '0101'.
    PERFORM bdc_field  USING 'BDC_CURSOR' 'VBAK-AUART'.
*    PERFORM bdc_field  USING 'VBAK-AUART' 'JRE'.
    PERFORM bdc_field  USING 'VBAK-AUART' <fs_data>-doc_type.
    PERFORM bdc_field  USING 'BDC_CURSOR' 'VBAK-VKORG'.
*    PERFORM bdc_field  USING 'VBAK-VKORG' '1710'.
    PERFORM bdc_field  USING 'VBAK-VKORG' <fs_data>-sales_org.
    PERFORM bdc_field  USING 'BDC_CURSOR' 'VBAK-VTWEG'.
*    PERFORM bdc_field  USING 'VBAK-VTWEG' '10'.
    PERFORM bdc_field  USING 'VBAK-VTWEG' <fs_data>-distr_chan.
    PERFORM bdc_field  USING 'BDC_CURSOR' 'VBAK-SPART'.
*    PERFORM bdc_field  USING 'VBAK-SPART' '00'.
    PERFORM bdc_field  USING 'VBAK-SPART' <fs_data>-sect_act.
    PERFORM bdc_dynpro USING 'SAPMV45A' '4001'.
    PERFORM bdc_field  USING 'BDC_CURSOR' 'KUAGV-KUNNR'.
*    PERFORM bdc_field  USING 'KUAGV-KUNNR' 'USCU_S04'.
    PERFORM bdc_field  USING 'KUAGV-KUNNR' <fs_data>-partn_numb_ag.
    PERFORM bdc_field  USING 'BDC_CURSOR' 'KUWEV-KUNNR'.
*    PERFORM bdc_field  USING 'KUWEV-KUNNR' 'USCU_L01'.
    PERFORM bdc_field  USING 'KUWEV-KUNNR' <fs_data>-partn_numb_we.
    PERFORM bdc_field  USING 'BDC_CURSOR' 'VBKD-BSTKD'.
    PERFORM bdc_field  USING 'VBKD-BSTKD' '1234'.
    PERFORM bdc_field  USING 'BDC_CURSOR' 'VBAK-AUGRU'.
    PERFORM bdc_field  USING 'VBAK-AUGRU' '007'.
    PERFORM bdc_field  USING 'BDC_SUBSCR' 'SAPMV45A'.

* On doit maintenant récupérer toutes les données de poste d'une même commande
* pour les ajouter toutes dans notre table de données Batch Input
    LOOP AT gt_data ASSIGNING FIELD-SYMBOL(<fs_data2>) WHERE id_com = <fs_data>-id_com.
      CLEAR lv_quant.

      lv_poste = lv_poste + 1.
* On convertit le champ quantité afin qu'il soit adapté au champ du DYNPRO
      MOVE  <fs_data2>-quantity TO lv_quant.


      lv_mabnr =  'RV45A-MABNR(' && lv_poste && ')'.
      lv_kwmeng = 'RV45A-KWMENG(' && lv_poste && ')'.


      PERFORM bdc_field  USING 'BDC_CURSOR' lv_mabnr.
      PERFORM bdc_field  USING lv_mabnr <fs_data2>-material.
      PERFORM bdc_dynpro USING 'SAPMV45A' '4001'.
      PERFORM bdc_field  USING 'BDC_CURSOR' lv_kwmeng.
      PERFORM bdc_field  USING lv_kwmeng lv_quant.
*      CASE lv_poste.
*        WHEN 1.
*          PERFORM bdc_field  USING 'BDC_CURSOR' 'RV45A-MABNR(01)'.
**          PERFORM bdc_field  USING 'RV45A-MABNR(01)' 'TG11'.
*          PERFORM bdc_field  USING 'RV45A-MABNR(01)' <fs_data2>-material.
*          PERFORM bdc_dynpro USING 'SAPMV45A' '4001'.
*          PERFORM bdc_field  USING 'BDC_CURSOR' 'RV45A-KWMENG(01)'.
**          PERFORM bdc_field  USING 'RV45A-KWMENG(01)' '10'.
*          PERFORM bdc_field  USING 'RV45A-KWMENG(01)' lv_quant.
*
*        WHEN 2.
*          PERFORM bdc_field  USING 'BDC_CURSOR' 'RV45A-MABNR(02)'.
**          PERFORM bdc_field  USING 'RV45A-MABNR(02)' 'TG12'.
*          PERFORM bdc_field  USING 'RV45A-MABNR(02)' <fs_data2>-material.
*          PERFORM bdc_field  USING 'BDC_CURSOR' 'RV45A-KWMENG(02)'.   "VRKME
**          PERFORM bdc_field  USING 'RV45A-KWMENG(02)' '15'.
*          PERFORM bdc_field  USING 'RV45A-KWMENG(02)' lv_quant.


*        WHEN 3.
*          PERFORM bdc_field  USING 'BDC_CURSOR' 'RV45A-MABNR(03)'.
**          PERFORM bdc_field  USING 'RV45A-MABNR(03)' 'MZ-FG-M525'.
*          PERFORM bdc_field  USING 'RV45A-MABNR(03)' <fs_data2>-material.
*          PERFORM bdc_field  USING 'BDC_CURSOR' 'RV45A-KWMENG(03)'.   "VRKME
**          PERFORM bdc_field  USING 'RV45A-KWMENG(03)' '15'.
*          PERFORM bdc_field  USING 'RV45A-KWMENG(03)' lv_quant.

*        WHEN OTHERS.
*      ENDCASE.

    ENDLOOP.

    PERFORM bdc_dynpro USING 'SAPMV45A' '4001'.
    PERFORM bdc_field  USING 'BDC_OKCODE' '= SICH'.
    CLEAR lv_poste.

    CALL FUNCTION 'BDC_INSERT'
      EXPORTING
        tcode            = 'VA01'
      TABLES
        dynprotab        = bdcdata
      EXCEPTIONS
        internal_error   = 1
        not_open         = 2
        queue_error      = 3
        tcode_invalid    = 4
        printing_invalid = 5
        posting_invalid  = 6
        OTHERS           = 7.

  ENDLOOP.


  CALL FUNCTION 'BDC_CLOSE_GROUP'
    EXCEPTIONS
      not_open    = 1
      queue_error = 2
      OTHERS      = 3.

** On créé l'objet ALV qui va permettre d'afficher la table de compte rendu
*  CALL METHOD cl_salv_table=>factory
*    IMPORTING
*      r_salv_table = lo_alv
*    CHANGING
*      t_table      = gt_cr.
*
*  lo_alv_functions = lo_alv->get_functions( ).
*  lo_alv_functions->set_all( abap_true ).
*
*  lo_columns = lo_alv->get_columns( ).
*  lo_columns->set_optimize( abap_true ).
*
*  lo_alv->display( ).
ENDFORM.

FORM usercommand_event USING i_ucomm TYPE salv_de_function.


* Déclaration des tables / structures qui seront envoyées aux formulaires
  DATA : ls_header  LIKE zscv_header,
         lt_item    TYPE ztcv_item,
         ls_item    LIKE LINE OF lt_item.


* Déclaration de données pour le formulaire smartform
  DATA : ls_control TYPE ssfctrlop,
         ls_output  TYPE ssfcompop,
         lv_fname   TYPE rs38l_fnam,  "Code du module fonction associé au smartform
         lv_sf_name TYPE tdsfname.    "Nom smartform


* Déclaration de données pour le formulaire ADOBE
  DATA : ls_sfpoutputparams TYPE sfpoutputparams,
         ls_docparams       TYPE sfpdocparams,
         ls_pdf_file        TYPE fpformoutput,
         lv_formname        TYPE fpname,
         lv_fmname          TYPE funcname,
         lv_mseg            TYPE  string,
         lv_w_cx_root       TYPE  REF TO cx_root.  " exception class

* J'alimente les tables d'en-tête et de poste qui seront envoyés aux formulaires
  READ TABLE gt_cv ASSIGNING FIELD-SYMBOL(<fs_cv>) WITH KEY check = 'X'.
  IF sy-subrc = 0.
    ls_header-vbeln = <fs_cv>-vbeln.
    ls_header-auart = <fs_cv>-auart.
    ls_header-erdat = <fs_cv>-erdat.
    ls_header-erzet = <fs_cv>-erzet.
    ls_header-vdatu = <fs_cv>-vdatu.
    ls_header-vkorg = <fs_cv>-vkorg.
    ls_header-vtweg = <fs_cv>-vtweg.
    ls_header-spart = <fs_cv>-spart.
    ls_header-kunnr_ana = <fs_cv>-kunnr_ana.
    ls_header-name1     = <fs_cv>-name1.
    ls_header-kunwe_ana = <fs_cv>-kunwe_ana.
    ls_header-name2     = <fs_cv>-name2.
    ls_header-adress    = <fs_cv>-adress.

    LOOP AT gt_cv ASSIGNING FIELD-SYMBOL(<fs_cv2>) WHERE vbeln = <fs_cv>-vbeln.
      ls_item-posnr    = <fs_cv2>-posnr.
      ls_item-matnr    = <fs_cv2>-matnr.
      ls_item-maktx    = <fs_cv2>-maktx.
      ls_item-werks    = <fs_cv2>-werks.
      ls_item-zmeng    = <fs_cv2>-zmeng.
      ls_item-zieme    = <fs_cv2>-zieme.
      ls_item-ntgew    = <fs_cv2>-ntgew.
      ls_item-gewei    = <fs_cv2>-gewei.
      ls_item-pds_post = <fs_cv2>-pds_post.
      ls_item-pds_tot  = <fs_cv2>-pds_tot.
      APPEND ls_item TO lt_item.
    ENDLOOP.
  ENDIF.

  CASE i_ucomm.
    WHEN 'PRINT_SF'.
      lv_sf_name = 'ZCOMV_KDE'.
      ls_control-preview  = 'X'.
*      ls_control-device   = 'LP01'.
      ls_output-tdnoprev  = ' '.

      CALL FUNCTION 'SSF_FUNCTION_MODULE_NAME'
        EXPORTING
          formname           = lv_sf_name
          variant            = ' '
          direct_call        = ' '
        IMPORTING
          fm_name            = lv_fname
        EXCEPTIONS
          no_form            = 1
          no_function_module = 2
          OTHERS             = 3.

      "Appel du smartform
      CALL FUNCTION lv_fname
        EXPORTING
          is_header          = ls_header
          it_item            = lt_item
          control_parameters = ls_control
          output_options     = ls_output
        EXCEPTIONS
          formatting_error   = 1
          internal_error     = 2
          send_error         = 3
          user_canceled      = 4
          OTHERS             = 5.
    WHEN 'PRINT_ADOBE'.
      lv_formname = 'ZADOBE_FORM_KDE'.
      ls_sfpoutputparams-dest     = 'LP01'.
*      ls_sfpoutputparams-nodialog = 'X'.
      ls_sfpoutputparams-preview  = 'X'.

      CALL FUNCTION 'FP_JOB_OPEN'
        CHANGING
          ie_outputparams = ls_sfpoutputparams
        EXCEPTIONS
          cancel          = 1
          usage_error     = 2
          system_error    = 3
          internal_error  = 4
          OTHERS          = 5.

      IF sy-subrc <> 0.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
        WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
      ENDIF.

      TRY .
          CALL FUNCTION 'FP_FUNCTION_MODULE_NAME'
            EXPORTING
              i_name     = lv_formname
            IMPORTING
              e_funcname = lv_fmname.

        CATCH cx_root INTO lv_w_cx_root.
          lv_mseg = lv_w_cx_root->get_text( ).
          MESSAGE lv_mseg TYPE 'E'.

      ENDTRY.

      MOVE: sy-langu TO ls_docparams-langu.

      CALL FUNCTION lv_fmname
        EXPORTING
          /1bcdwb/docparams = ls_docparams
          is_header         = ls_header
          it_item           = lt_item
*    IMPORTING
*         /1bcdwb/formoutput = ls_pdf_file
        EXCEPTIONS
          usage_error       = 1
          system_error      = 2
          internal_error    = 3
          OTHERS            = 4.

      IF sy-subrc <> 0.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
        WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
      ENDIF.

      CALL FUNCTION 'FP_JOB_CLOSE'
*   IMPORTING
*     e_result             =
        EXCEPTIONS
          usage_error    = 1
          system_error   = 2
          internal_error = 3
          OTHERS         = 4.

      IF sy-subrc <> 0.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
        WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
      ENDIF.
    WHEN OTHERS.

  ENDCASE.

ENDFORM.