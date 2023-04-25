*&---------------------------------------------------------------------*
*&  Include           ZGEN_ALV_CLASS
*&---------------------------------------------------------------------*

*Class for event CL_SALV_EVENTS_TABLE
CLASS ycl_event DEFINITION.
  PUBLIC SECTION.
    CLASS-METHODS : m_hotspot FOR EVENT link_click
      OF cl_salv_events_table
      IMPORTING row column.

    CLASS-METHODS : m_usercommand FOR EVENT added_function
      OF cl_salv_events_table
      IMPORTING e_salv_function.

    CLASS-METHODS : m_top_of_page FOR EVENT top_of_page
      OF cl_salv_events_table
      IMPORTING r_top_of_page
                page
                table_index.

    CLASS-METHODS : m_end_of_page FOR EVENT end_of_page
      OF cl_salv_events_table
      IMPORTING r_end_of_page
                page.

    CLASS-METHODS : m_before_function FOR EVENT before_salv_function
      OF cl_salv_events_table
      IMPORTING e_salv_function.

    CLASS-METHODS : m_after_function FOR EVENT after_salv_function
      OF cl_salv_events_table
      IMPORTING e_salv_function.

    CLASS-METHODS : m_double_click FOR EVENT double_click
      OF cl_salv_events_table
      IMPORTING row
                column.


ENDCLASS.                    "ycl_event DEFINITION

*----------------------------------------------------------------------*
*       CLASS ycl_event IMPLEMENTATION
*----------------------------------------------------------------------*
*
*----------------------------------------------------------------------*
CLASS ycl_event IMPLEMENTATION.
  METHOD m_hotspot.

    PERFORM hotspot_event IN PROGRAM (sy-repid) IF FOUND USING row column.

  ENDMETHOD.                    "m_hotspot
  METHOD m_usercommand.

    PERFORM usercommand_event IN PROGRAM (sy-repid) IF FOUND USING e_salv_function .

  ENDMETHOD.                    "m_usercommand
  METHOD m_top_of_page.

    PERFORM top_of_page_event IN PROGRAM (sy-repid) IF FOUND USING r_top_of_page page table_index.

  ENDMETHOD.                    "m_top_of_page
  METHOD m_end_of_page.

    PERFORM end_of_page_event IN PROGRAM (sy-repid) IF FOUND USING r_end_of_page page.

  ENDMETHOD.                    "m_end_of_page
  METHOD m_before_function.

    PERFORM before_function_event IN PROGRAM (sy-repid) IF FOUND USING e_salv_function.

  ENDMETHOD.                    "m_before_function
  METHOD m_after_function.

    PERFORM after_function_event IN PROGRAM (sy-repid) IF FOUND USING e_salv_function.

  ENDMETHOD.                    "m_after_function
  METHOD m_double_click.

    PERFORM double_click_event IN PROGRAM (sy-repid) IF FOUND USING row column.

  ENDMETHOD.                    "m_before_function

ENDCLASS.                    "ycl_event IMPLEMENTATION