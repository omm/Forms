#include "hbclass.ch"
#include "inkey.ch"

#include "creator.ch"

#define LISTBOX_SLOT 11

CLASS Creator_listbox INHERIT Creator

EXPORTED:

    METHOD edit_form()
    METHOD dropdown(lDropdown) SETGET

HIDDEN:

    CLASSVAR lDropdownListbox AS LOGICAL INIT .F.

ENDCLASS LOCK

METHOD edit_form() CLASS Creator_listbox

    MEMVAR GETLIST

    LOCAL cOldHeader := Window():header(Config():get_config('CreatorListboxHeader'))
    LOCAL cOldFooter := Window():footer(Config():get_config('CreatorListboxFooter'))
    LOCAL nTopLimit := IF(WSelect() == 0, Window():get_top(), 0)
    LOCAL nLeftLimit := IF(WSelect() == 0, Window():get_left(), 0)
    LOCAL nBottomLimit := IF(WSelect() == 0, Window():get_bottom(), MaxRow())
    LOCAL nRightLimit := IF(WSelect() == 0, Window():get_right(), MaxCol())
    LOCAL lActiveUpperLeftCorner := .T.
    LOCAL lFinish := .F.
    LOCAL aoWasGetList
    LOCAL lSave 
    LOCAL cScreen
    LOCAL nKey

    Window():refresh_header()
    Window():refresh_footer()

    SAVE SCREEN TO cScreen

    ::set_type(OBJECT_LISTBOX)
    ::make_form_array()

    DO WHILE !lFinish

        RESTORE SCREEN FROM cScreen 
    
        ::display_form()

        IF ::lDropdownListbox
            GETLIST[Len(GETLIST)][LISTBOX_SLOT]:open()
        ENDIF

        IF ValType(aoWasGetList) == 'A' .AND. Len(aoWasGetList) != 0 .AND. Len(GETLIST) != 0
            aoWasGetList[Len(aoWasGetList)] := __objClone(GETLIST[Len(GETLIST)])
        ELSE
            aoWasGetList := clone_objects_array(GETLIST)
        ENDIF
        
        GETLIST := ASize(GETLIST, Len(GETLIST) - 1)

        nKey := Inkey(0)

        DO CASE
            CASE nKey == K_ALT_A
                lActiveUpperLeftCorner := !lActiveUpperLeftCorner
            CASE nKey == K_ALT_Z
                ::lDropdownListbox := !::lDropdownListbox
            CASE nKey == K_UP
                IF lActiveUpperLeftCorner
                    IF ::get_value(N_TOP_LSB) - 1 < ::get_value(N_BOTTOM_LSB).AND. ::get_value(N_TOP_LSB) - 1 >= nTopLimit
                        ::decrement(N_TOP_LSB)
                    ENDIF
                ELSE
                    IF ::get_value(N_TOP_LSB) < ::get_value(N_BOTTOM_LSB) - 1 .AND. ::get_value(N_BOTTOM_LSB) - 1 >= nTopLimit
                        ::decrement(N_BOTTOM_LSB)
                    ENDIF
                ENDIF    
            CASE nKey == K_LEFT
                IF lActiveUpperLeftCorner
                    IF ::get_value(N_LEFT_LSB) - 1 < ::get_value(N_RIGHT_LSB) .AND. ::get_value(N_LEFT_LSB) - 1 >= nLeftLimit
                        ::decrement(N_LEFT_LSB)
                    ENDIF
                ELSE
                    IF ::get_value(N_LEFT_LSB) < ::get_value(N_RIGHT_LSB) - 1 .AND. ::get_value(N_RIGHT_LSB) - 1 >= nLeftLimit
                        ::decrement(N_RIGHT_LSB)
                    ENDIF
                ENDIF
            CASE nKey == K_DOWN
                IF lActiveUpperLeftCorner
                    IF ::get_value(N_TOP_LSB) + 1 < ::get_value(N_BOTTOM_LSB) .AND. ::get_value(N_TOP_LSB) + 1 <= nBottomLimit
                        ::increment(N_TOP_LSB)
                    ENDIF
                ELSE
                    IF ::get_value(N_TOP_LSB) < ::get_value(N_BOTTOM_LSB) + 1 .AND. ::get_value(N_BOTTOM_LSB) + 1 <= nBottomLimit
                        ::increment(N_BOTTOM_LSB)
                    ENDIF
                ENDIF
            CASE nKey == K_RIGHT
                IF lActiveUpperLeftCorner
                    IF ::get_value(N_LEFT_LSB) + 1 < ::get_value(N_RIGHT_LSB) .AND. ::get_value(N_LEFT_LSB) + 1 <= nRightLimit
                        ::increment(N_LEFT_LSB)
                    ENDIF
                ELSE
                    IF ::get_value(N_LEFT_LSB) < ::get_value(N_RIGHT_LSB) + 1 .AND. ::get_value(N_RIGHT_LSB) + 1 <= nRightLimit
                        ::increment(N_RIGHT_LSB)
                    ENDIF
                ENDIF
            CASE nKey == K_ENTER
                ::form_fast_edit(cScreen)
            CASE nKey == K_ALT_ENTER
                IF YesNo(Config():get_config('DoReadOrder'))
                    ReadModal(aoWasGetList)
                ENDIF
            CASE nKey == K_ESC
                IF YesNo(Config():get_config('YesNoBreakEdition'))
                    IF YesNo(Config():get_config('YesNoSave'))
                        IF ::save_form()
                            lFinish := .T.
                            lSave := .T.
                        ELSE
                            lFinish := .F.
                            lSave := .F.
                        ENDIF
                    ELSE 
                        lFinish := .T.
                        lSave := .F.
                    ENDIF
                ENDIF
        ENDCASE
    ENDDO

    Window():header(cOldHeader)
    Window():footer(cOldFooter)
    Window():refresh_header()
    Window():refresh_footer()

RETURN lSave

METHOD dropdown(lDropdown) CLASS Creator_listbox

    LOCAL lWasDropdown := ::lDropdownListbox

    IF lDropdown != NIL
        assert_type(lDropdown, 'L')
        ::lDropdownListbox := lDropdown
    ENDIF

RETURN lWasDropdown
