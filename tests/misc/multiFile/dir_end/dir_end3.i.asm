// include file for dir_end3.a80
        ld      bc,verifyLabel      ; label from first file
        ld      de,verifyLabelFrom_dir_end3.a80
    some_error to check file paths output

        ; do not END here : END : not here */ : END
        /* END : END : not even in // : END : block comment */scf:ccf ; these are LIVE
    // : /* END : END : */ : END // END : END
        xxx     ; MACRO from dir_end1.a80
