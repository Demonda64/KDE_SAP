*&---------------------------------------------------------------------*
*&  Include           ZGEN_ALV
*&---------------------------------------------------------------------*

INCLUDE zkde_alv_proj_top.
INCLUDE zkde_alv_class_proj.

*&---------------------------------------------------------------------*
*&      Form  f_list_display
*&---------------------------------------------------------------------*
*       manage the list display
*----------------------------------------------------------------------*
FORM f_list_display.
* by defalut, the ALV list is displayed
  g_x = 'X'. " with 'X', display a list
ENDFORM.                    "f_list_display
*&---------------------------------------------------------------------*
*&      Form  F_CREATE_ALV
*&---------------------------------------------------------------------*
*       Display ALV with all data extracted
*----------------------------------------------------------------------*
FORM  f_create_alv USING t_data.

  DATA: ls_layout_key TYPE salv_s_layout_key.
  IF t_data IS NOT INITIAL.
    TRY.
        CALL METHOD cl_salv_table=>factory
          EXPORTING
            list_display = g_x                              " MGI01+
          IMPORTING
            r_salv_table = go_alv
          CHANGING
            t_table      = t_data.
      CATCH cx_salv_msg.
        MESSAGE i306(8s).
    ENDTRY.
  ENDIF.

  " Layout
  ls_layout_key-report = sy-repid.

  go_function = go_alv->get_functions( ).
  go_disp = go_alv->get_display_settings( ).
  go_cols = go_alv->get_columns( ).
  go_layout = go_alv->get_layout( ).


  " Layout
  go_layout->set_key( ls_layout_key ).
  go_layout->set_save_restriction( ).
  go_layout->set_default( abap_true ).

ENDFORM.                    "f_create_alv

*&---------------------------------------------------------------------*
*&      Form  F_ADD_HOTSPOT
*&---------------------------------------------------------------------*
*       Add Hotspot for few column
*----------------------------------------------------------------------*
*      -->PV_FIELD   Column Name
*      <--PO_COLS    Columns ALV
*----------------------------------------------------------------------*
FORM f_add_hotspot  USING    pv_field TYPE fieldname.
  DATA : lo_col TYPE REF TO cl_salv_column_table.
  TRY.
      lo_col ?= go_cols->get_column( pv_field ).
    CATCH cx_salv_not_found.
      MESSAGE e052(sy) WITH pv_field.
  ENDTRY.

  IF lo_col IS BOUND.
    lo_col->set_cell_type( if_salv_c_cell_type=>hotspot ).
  ENDIF.
ENDFORM.                    " F_ADD_HOTSPOT
*&---------------------------------------------------------------------*
*&      Form  f_hide_column
*&---------------------------------------------------------------------*
*       Hide column
*----------------------------------------------------------------------*
*      -->PV_FIELD   Column Name
*----------------------------------------------------------------------*
FORM f_hide_column USING pv_field TYPE fieldname
                         pv_visible TYPE xfeld.
  DATA : lo_col TYPE REF TO cl_salv_column_table.
  TRY.
      lo_col ?= go_cols->get_column( pv_field ).
    CATCH cx_salv_not_found.
      MESSAGE e052(sy) WITH pv_field.
  ENDTRY.

  IF lo_col IS BOUND.
    lo_col->set_visible( pv_visible ).
  ENDIF.
ENDFORM.                    "f_hide_column
*&---------------------------------------------------------------------*
*&      Form  f_delete_column
*&---------------------------------------------------------------------*
*       Delete column
*----------------------------------------------------------------------*
*      -->PV_FIELD   Column Name
*----------------------------------------------------------------------*
FORM f_delete_column USING pv_field TYPE fieldname
                           pv_delete TYPE xfeld.
  DATA : lo_col TYPE REF TO cl_salv_column_table.
  TRY.
      lo_col ?= go_cols->get_column( pv_field ).
    CATCH cx_salv_not_found.
      MESSAGE e052(sy) WITH pv_field.
  ENDTRY.

  IF lo_col IS BOUND.
    lo_col->set_technical( pv_delete ).
  ENDIF.
ENDFORM.                    "f_delete_column
*&---------------------------------------------------------------------*
*&      Form  F_ADD_SORT
*&---------------------------------------------------------------------*
*       Add sort on few fields
*----------------------------------------------------------------------*
*      -->PV_FIELD   Column Name
*      -->PS_SORT    Sort info (use by default structure gs_sort_info)
*----------------------------------------------------------------------*
FORM f_add_sort  USING pv_field TYPE fieldname
                       ps_sort TYPE ty_sort_info.
  IF go_sorts IS NOT BOUND.
    go_sorts = go_alv->get_sorts( ).
    go_sorts->set_group_active( ).
  ENDIF.
  TRY.
      CALL METHOD go_sorts->add_sort
        EXPORTING
          columnname = pv_field
          position   = ps_sort-position
          sequence   = ps_sort-sequence
          subtotal   = ps_sort-subtotal
          group      = ps_sort-group
          obligatory = ps_sort-obligatory.
    CATCH cx_salv_not_found cx_salv_existing cx_salv_data_error.
      MESSAGE e052(sy) WITH pv_field.
  ENDTRY.
ENDFORM.                    " F_ADD_SORT
*&---------------------------------------------------------------------*
*&      Form  F_DISPLAY_ALV
*&---------------------------------------------------------------------*
*       Display ALV
*----------------------------------------------------------------------*
FORM f_display_alv.
  "CALL METHOD
  go_alv->display( ).
ENDFORM.                    " F_DISPLAY_ALV
*&---------------------------------------------------------------------*
*&      Form  f_set_col_color
*&---------------------------------------------------------------------*
*       Change color of the columns
*----------------------------------------------------------------------*
*      -->PV_FIELD   Fieldname
*      -->PV_COLOR   Color from type-pool col
*----------------------------------------------------------------------*
FORM f_set_col_color USING    pv_field TYPE fieldname
                              pv_color TYPE char1.

  DATA : lo_col      TYPE REF TO cl_salv_column_table,
         lo_cols_tab TYPE REF TO cl_salv_columns_table,
         ls_color    TYPE lvc_s_colo.

  IF pv_color IS NOT INITIAL.
    TRY.
        lo_col ?= go_cols->get_column( pv_field ).
      CATCH cx_salv_not_found.
        MESSAGE e052(sy) WITH pv_field.
    ENDTRY.

    IF lo_col IS BOUND.
      ls_color-col = pv_color.
      lo_col->set_color( ls_color ).
    ENDIF.
  ELSE.
    lo_cols_tab = go_alv->get_columns( ).
    " Colour entire line
    TRY.
        lo_cols_tab->set_color_column( pv_field ).
      CATCH cx_salv_data_error.                         "#EC NO_HANDLER
    ENDTRY.
  ENDIF.
ENDFORM.                    "f_set_col_color
*&---------------------------------------------------------------------*
*&      Form  F_GET_EVENT
*&---------------------------------------------------------------------*
*       Add events handler
*----------------------------------------------------------------------*
FORM f_get_event USING hotspot function top end after before double.

  IF go_event IS NOT BOUND.
    go_event = go_alv->get_event( ).
  ENDIF.

  IF hotspot IS NOT INITIAL.
    SET HANDLER ycl_event=>m_hotspot FOR go_event.
  ENDIF.

  IF function IS NOT INITIAL.
    SET HANDLER ycl_event=>m_usercommand FOR go_event.
  ENDIF.

  IF top IS NOT INITIAL.
    SET HANDLER ycl_event=>m_top_of_page FOR go_event.
  ENDIF.

  IF end IS NOT INITIAL.
    SET HANDLER ycl_event=>m_end_of_page FOR go_event.
  ENDIF.

  IF after IS NOT INITIAL.
    SET HANDLER ycl_event=>m_after_function FOR go_event.
  ENDIF.

  IF before IS NOT INITIAL.
    SET HANDLER ycl_event=>m_before_function FOR go_event.
  ENDIF.

  IF double IS NOT INITIAL.
    SET HANDLER ycl_event=>m_double_click FOR go_event.
  ENDIF.
ENDFORM.                    " F_GET_EVENT
*&---------------------------------------------------------------------*
*&      Form  F_ADD_STD_BUTTONS
*&---------------------------------------------------------------------*
*       Add standard buttons
*----------------------------------------------------------------------*
FORM f_add_std_buttons.

  IF go_function IS NOT BOUND.
    go_function = go_alv->get_functions( ).
  ENDIF.

  go_function->set_all( ).
ENDFORM.                    " F_ADD_STD_BUTTONS
*&---------------------------------------------------------------------*
*&      Form  F_CHANGE_NAME_COLUMN
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->U_NAME   text
*      -->U_TEXT  text
*----------------------------------------------------------------------*
FORM f_change_name_column  USING   u_field TYPE fieldname
                                   u_text_l TYPE scrtext_l
                                   u_text_m TYPE scrtext_m
                                   u_text_s TYPE scrtext_s.

  DATA : lo_col  TYPE REF TO cl_salv_column_table.
  TRY.
      lo_col ?= go_cols->get_column( u_field ).
    CATCH cx_salv_not_found.
      MESSAGE e052(sy) WITH u_field.
  ENDTRY.

  IF u_text_m IS INITIAL.
    u_text_m = u_text_l(20).
  ENDIF.

  IF u_text_s IS INITIAL.
    u_text_s = u_text_m(10).
  ENDIF.

  IF lo_col IS BOUND.
    lo_col->set_long_text( value = u_text_l ).
    lo_col->set_medium_text( value = u_text_m ).
    lo_col->set_short_text( value = u_text_s ).
  ENDIF.

ENDFORM.                    " CHANGE_NAME_COLUMN
*&---------------------------------------------------------------------*
*&      Form  F_SET_TITLE
*&---------------------------------------------------------------------*
*       Set title
*----------------------------------------------------------------------*
FORM f_set_title USING u_title TYPE lvc_title.

  IF go_disp IS BOUND.
    go_disp->set_list_header( u_title ).
  ENDIF.

ENDFORM.                    " F_SET_TITLE
*&---------------------------------------------------------------------*
*&      Form  F_ADD_SUM
*&---------------------------------------------------------------------*
*       Add sum on few column
*----------------------------------------------------------------------*
*      -->PV_FIELD Column Name
*----------------------------------------------------------------------*
FORM f_add_sum  USING    pv_field TYPE fieldname.

  IF go_aggr IS NOT BOUND.
    go_aggr = go_alv->get_aggregations( ).
  ENDIF.

  TRY.
      go_aggr->add_aggregation( pv_field ).
    CATCH cx_salv_not_found cx_salv_data_error cx_salv_existing.
      MESSAGE e052(sy) WITH pv_field.
  ENDTRY.
ENDFORM.                    " F_ADD_SUM
*&---------------------------------------------------------------------*
*&      Form  F_OPTIMIZE
*&---------------------------------------------------------------------*
*       Optimize
*----------------------------------------------------------------------*
FORM f_optimize.
  go_cols->set_optimize( abap_true ).
ENDFORM.                    " F_OPTIMIZE
*&---------------------------------------------------------------------*
*&      Form  F_SET_STATUS
*&---------------------------------------------------------------------*
*       Set screen status
*----------------------------------------------------------------------*
FORM f_set_status USING pv_status TYPE sypfkey.

  CALL METHOD go_alv->set_screen_status
    EXPORTING
      report        = sy-repid
      pfstatus      = pv_status
      set_functions = cl_salv_model_base=>c_functions_all.
ENDFORM.                    " F_SET_STATUS
*&---------------------------------------------------------------------*
*&      Form  F_HIDE_BUTTON
*&---------------------------------------------------------------------*
*       Hide button
*----------------------------------------------------------------------*
FORM f_hide_button USING pv_field TYPE salv_de_function
                         pv_visible TYPE xfeld.

  DATA : lo_function TYPE REF TO cl_salv_function.
*set button for posting invisible

  gt_functions = go_function->get_functions( ).
  LOOP AT gt_functions INTO gs_functions.
    lo_function = gs_functions-r_function.

    IF lo_function->get_name( ) = pv_field.
      lo_function->set_visible( pv_visible ).
    ENDIF.
  ENDLOOP.
ENDFORM.                    " F_HIDE_BUTTON
*&---------------------------------------------------------------------*
*&      Form  F_SET_ICON
*&---------------------------------------------------------------------*
*       Add icon
*----------------------------------------------------------------------*
FORM f_set_icon  USING    u_field TYPE fieldname.

  DATA : lo_col  TYPE REF TO cl_salv_column_table.

  TRY.
      lo_col ?= go_cols->get_column( u_field ).
    CATCH cx_salv_not_found.
      MESSAGE e052(sy) WITH u_field.
  ENDTRY.

  lo_col->set_icon( if_salv_c_bool_sap=>true ).


ENDFORM.                    " F_SET_ICON
*&---------------------------------------------------------------------*
*&      Form  F_CREATE_CHECKBOX
*&---------------------------------------------------------------------*
*       Add ALV line selection
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_create_checkbox .

* Column selection
*  IF go_selections IS NOT BOUND.
  go_selections = go_alv->get_selections( ).
*  ENDIF.

  TRY.
      go_selections->set_selection_mode( if_salv_c_selection_mode=>row_column ).
    CATCH cx_salv_not_found.
  ENDTRY.


ENDFORM.                    " F_CREATE_CHECKBOX
*&---------------------------------------------------------------------*
*&      Form  F_GET_ROWS
*&---------------------------------------------------------------------*
*       Get selected rows
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_get_rows .

  gt_rows = go_selections->get_selected_rows( ).

*  TRY.
*
*      DATA(lv_index) = gt_rows[ 1 ].
*
*      gv_commande = gt_display[ lv_index ]-ebeln.
*
*    CATCH cx_sy_itab_line_not_found.
*      RETURN.
*  ENDTRY.


ENDFORM.                    " F_GET_ROWS
*&---------------------------------------------------------------------*
*&      Form  F_REFRESH_ALV
*&---------------------------------------------------------------------*
*       Refresh ALV
*----------------------------------------------------------------------*
FORM f_refresh_alv.

  CALL METHOD go_alv->refresh( ).

ENDFORM.                    " F_REFRESH_ALV
*&---------------------------------------------------------------------*
*&      Form  F_ADD_GEN_BUTTONS
*&---------------------------------------------------------------------*
*       Add additional buttons buttons
*----------------------------------------------------------------------*
FORM f_add_gen_buttons.

  DATA lv_icon TYPE string.

  lv_icon = icon_display.

  TRY.
      go_function->add_function(
        name     = 'DISPALYFILE'
        icon     = lv_icon
        text     = 'Display File'
        tooltip  = 'Display File'
        position = if_salv_c_function_position=>right_of_salv_functions ).
    CATCH cx_salv_wrong_call cx_salv_existing.
  ENDTRY.

ENDFORM.                    " F_ADD_GEN_BUTTONS
*&---------------------------------------------------------------------*
*&      Form  F_SET_ZEBRA
*&---------------------------------------------------------------------*
*       Set Zebra
*----------------------------------------------------------------------*
FORM f_set_zebra.

  IF go_disp IS BOUND.
    go_disp->set_striped_pattern( abap_true ).
  ENDIF.

ENDFORM.                    " F_SET_ZEBRA
*&---------------------------------------------------------------------*
*&      Form  f_change_pos_column
*&---------------------------------------------------------------------*
*       Change the position f the column
*----------------------------------------------------------------------*
*      -->PV_FIELD   Column Name
*----------------------------------------------------------------------*
FORM f_change_pos_column USING pv_field TYPE fieldname
                               pv_pos   TYPE i.

  go_cols->set_column_position( columnname = pv_field
                                position   = pv_pos   ).

ENDFORM.                    "f_change_pos_column
*&---------------------------------------------------------------------*
*&      Form  F_REFRESH_ROWS
*&---------------------------------------------------------------------*
*       Refresh selected rows
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_refresh_rows .

  go_selections->set_selected_rows( gt_rows ).

ENDFORM.                    " F_REFRESH_ROWS
*&---------------------------------------------------------------------*
*&      Form  F_SET_FIXATION
*&---------------------------------------------------------------------*
*       Set Keys for fixing columns
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_set_fixation.

  DATA: lo_cols_tab TYPE REF TO cl_salv_columns_table.

  lo_cols_tab = go_alv->get_columns( ).

  TRY.
      lo_cols_tab->set_key_fixation( ).
    CATCH cx_salv_not_found.
  ENDTRY.

ENDFORM.                    " F_REFRESH_ROWS
*&---------------------------------------------------------------------*
*&      Form  f_fix_column
*&---------------------------------------------------------------------*
*       Fix columns
*       The perform f_set_fixation must be called beforehand
*----------------------------------------------------------------------*
*      -->PV_FIELD   Fieldname
*----------------------------------------------------------------------*
FORM f_fix_column USING    pv_field TYPE fieldname.

  DATA : lo_col  TYPE REF TO cl_salv_column_table.

  TRY.
      lo_col ?= go_cols->get_column( pv_field ).
    CATCH cx_salv_not_found.
      MESSAGE e052(sy) WITH pv_field.
  ENDTRY.

  IF lo_col IS BOUND.
    lo_col->set_key( ).
    lo_col->set_key_presence_required( ).
  ENDIF.
ENDFORM.                    "f_set_col_color
*&---------------------------------------------------------------------*
*&      Form  set_select_values_top_of_page
*&---------------------------------------------------------------------*
*       Routine to display the selection value in ALV header
*----------------------------------------------------------------------*
FORM set_select_values_top_of_page.
*
  DATA: lo_header   TYPE REF TO cl_salv_form_layout_grid,
        lo_h_label  TYPE REF TO cl_salv_form_label,
        lo_h_flow   TYPE REF TO cl_salv_form_layout_flow,
        l_row       TYPE i,
        l_text(150) TYPE c,
        l_from(20)  TYPE c,
        l_to(20)    TYPE c.

  DATA : gt_select TYPE TABLE OF rsparams,
         gt_pool   TYPE TABLE OF textpool.

  FIELD-SYMBOLS : <select> TYPE rsparams,
                  <pool>   TYPE textpool.

  MESSAGE i402(recpsf) INTO l_from.
  MESSAGE i403(recpsf) INTO l_to.

  CALL FUNCTION 'RS_REFRESH_FROM_SELECTOPTIONS'
    EXPORTING
      curr_report     = sy-repid
    TABLES
      selection_table = gt_select
    EXCEPTIONS
      not_found       = 1
      no_report       = 2
      OTHERS          = 3.

  REFRESH gt_pool.
  READ TEXTPOOL sy-repid INTO gt_pool LANGUAGE sy-langu.

*   header object
  CREATE OBJECT lo_header.

*   information in Bold
  READ TABLE gt_pool ASSIGNING <pool> WITH KEY id = 'R'.
  IF sy-subrc = 0.
    lo_h_label = lo_header->create_label( row = 1 column = 1 ).
    lo_h_label->set_text( <pool>-entry ).
  ENDIF.

  l_row = 1.
  LOOP AT gt_select ASSIGNING <select>.
    CHECK <select>-low IS NOT INITIAL OR <select>-high IS NOT INITIAL.
    CLEAR l_text.
    READ TABLE gt_pool ASSIGNING <pool> WITH KEY key = <select>-selname.
    IF sy-subrc = 0.
      l_text = <pool>-entry.
    ELSE.
      l_text = <select>-selname.
    ENDIF.
    CONDENSE l_text.

    CONCATENATE l_text ':' INTO l_text SEPARATED BY space.

    IF <select>-kind = 'P'.
      CONCATENATE l_text <select>-low INTO l_text SEPARATED BY space.
    ELSE.
      IF <select>-option IS NOT INITIAL.
        CONCATENATE l_text '(' <select>-option ')' INTO l_text SEPARATED BY space.
      ENDIF.

      CONCATENATE l_text l_from <select>-low INTO l_text SEPARATED BY space.

      IF <select>-high IS NOT INITIAL.
        CONCATENATE l_text l_to <select>-high INTO l_text SEPARATED BY space.
      ENDIF.
    ENDIF.

    ADD 1 TO l_row.

    lo_h_flow = lo_header->create_flow( row = l_row  column = 1 ).
*    l_text
    lo_h_flow->create_text( text = l_text ).
  ENDLOOP.
*   set the top of list using the header for Online.
  go_alv->set_top_of_list( lo_header ).
*
*   set the top of list using the header for Print.
  go_alv->set_top_of_list_print( lo_header ).
*
ENDFORM.                    "set_select_values_top_of_page
*&---------------------------------------------------------------------*
*&      Form  f_set_initial_layout
*&---------------------------------------------------------------------*
*       Set initial layout
*       The perform f_set_initial_layout is used to set the initial layout
*----------------------------------------------------------------------*
*      -->PV_LAYOUT   Layout
*----------------------------------------------------------------------*
FORM f_set_initial_layout USING pv_layout TYPE slis_vari.
  IF pv_layout IS NOT INITIAL.
    go_layout->set_initial_layout( pv_layout ).
  ENDIF.
ENDFORM.                    "f_set_initial_layout
*&---------------------------------------------------------------------*
*&      Form  f_set_header
*&---------------------------------------------------------------------*
*       Set header
*       The perform f_set_header is used to set a header
*----------------------------------------------------------------------*
*      -->P_COLUMN   Nb column
*----------------------------------------------------------------------*
FORM f_set_header USING p_column.

  DATA: lo_header   TYPE REF TO cl_salv_form_layout_grid,
        lo_h_label  TYPE REF TO cl_salv_form_label,
        lo_h_flow   TYPE REF TO cl_salv_form_layout_flow,
        l_row       TYPE i,
        l_text(250) TYPE c.

  IF gt_header_alv IS NOT INITIAL.

    CREATE OBJECT lo_header
      EXPORTING
        columns = p_column.

    CLEAR l_row.

    LOOP AT gt_header_alv INTO gs_header_alv.

      IF gs_header_alv-column IS INITIAL.
        gs_header_alv-column = 1.
      ENDIF.

      ADD 1 TO l_row.

      IF gs_header_alv-bold IS NOT INITIAL.
*  write a label in bold
        lo_h_label = lo_header->create_label( row = l_row column = gs_header_alv-column ).
        lo_h_label->set_text( gs_header_alv-text ).
      ELSE.

        lo_h_flow = lo_header->create_flow( row = l_row  column = gs_header_alv-column ).
        lo_h_flow->create_text( text = gs_header_alv-text ).
      ENDIF.
    ENDLOOP.

*   set the top of list using the header.
    go_alv->set_top_of_list( lo_header ).
  ENDIF.
ENDFORM.                    "set_header
*&---------------------------------------------------------------------*
*&      Form  f_set_layout_key
*&---------------------------------------------------------------------*
*       Set key for layout
*
*----------------------------------------------------------------------*
*      -->PV_REPORT   Report name
*      -->PV_HANDLE   Handle
*----------------------------------------------------------------------*
FORM f_set_layout_key USING pv_report pv_handle.

  DATA : ls_key TYPE salv_s_layout_key.
  ls_key-report = pv_report.
  ls_key-handle = pv_handle.
  IF ls_key IS NOT INITIAL.
    go_layout->set_key( ls_key ).
  ENDIF.
ENDFORM.                    "f_set_initial_layout