# Fortran filetype: detection, comments, indentation.
# Highlighting comes from kak-tree-sitter; this file has no regex highlighters.

hook global BufCreate .*\.(f|F|for|FOR|ftn|f90|F90|f95|F95|f03|F03|f08|F08|fpp|FPP|inc) %{
    set-option buffer filetype fortran
}

hook global WinSetOption filetype=fortran %{
    require-module fortran

    set-option window comment_line '!'
    set-option window tabstop 2
    set-option window indentwidth 2

    hook window ModeChange pop:insert:.* -group fortran-trim-indent fortran-trim-indent
    hook window InsertChar \n -group fortran-indent fortran-indent-on-new-line
    hook window InsertChar [a-zA-Z] -group fortran-indent fortran-indent-on-end

    hook -once -always window WinSetOption filetype=.* %{ remove-hooks window fortran-.+ }
}

provide-module fortran %§

# Lines that open a block whose body should be indented.
# (Kakoune regex: no quantifiers inside lookarounds, hence no (?!...) here.)
declare-option -hidden str fortran_block_open %{^\s*(?i)(?:(?:\w+\s*:\s*)?(?:do|select|associate|block|critical|forall)\b|where\b.*\)\s*$|if\b.*\bthen\b|else\b|elseif\b|case\b|class\s+is\b|class\s+default\b|type\s+is\b|contains\b|(?:abstract\s+)?interface\b|enum\b|submodule\b|program\b|module\s+(?:procedure\s+)?\w+\s*(?:!.*)?$|(?:(?:pure|elemental|impure|recursive|non_recursive|module)\s+)*(?:(?:integer|real|logical|complex|character|double\s+precision|type\s*\(|class\s*\()[^!]*?\s+)?(?:subroutine|function)\b|type\s*(?:,[^!]*)?::\s*\w+|type\s+\w+\s*(?:!.*)?$)}

# Lines that close (or continue) a block: dedent them.
declare-option -hidden str fortran_block_close %{^\s*(?i)(?:end|end(?:do|if|select|associate|block|critical|forall|where|interface|enum|module|submodule|program|subroutine|function|type|procedure)|else|elseif|case|class\s+is|class\s+default|type\s+is|contains)\b}

define-command -hidden fortran-trim-indent %{
    # remove trailing white spaces
    try %{ execute-keys -draft x s \h+$ <ret> d }
}

define-command -hidden fortran-indent-on-new-line %{
    evaluate-commands -draft -itersel %{
        # preserve previous line indent
        try %{ execute-keys -draft <semicolon> K <a-&> }
        # remove trailing white spaces on the previous line
        try %{ execute-keys -draft k x s \h+$ <ret> d }
        # continue a comment: copy its "!" (or "!!") and paste it, plus a space,
        # at the cursor (Z / z), i.e. after the indent just copied.
        # (execute-keys restores the registers it uses: the user's yank is kept.)
        try %{ execute-keys -draft <semicolon> Z k x s ^\h*\K!+ <ret> y z P a<space><esc> }
        # indent after a block opener
        try %{
            execute-keys -draft k x <a-k> %opt{fortran_block_open} <ret>
            execute-keys -draft <semicolon> <a-gt>
        }
    }
}

define-command -hidden fortran-indent-on-end %{
    evaluate-commands -draft -itersel %{
        try %{
            execute-keys -draft x <a-k> %opt{fortran_block_close} <ret>
            # take the indent of the previous non-blank line...
            execute-keys -draft gh <a-?> ^\h*\S <ret> <a-&>
            # ...and dedent unless that line opened the block (empty body).
            # Recomputed from scratch on every keystroke, so it never over-dedents.
            try %{
                execute-keys -draft gh <a-?> ^\h*\S <ret> <semicolon> x <a-K> %opt{fortran_block_open} <ret>
                execute-keys -draft <a-lt>
            }
        }
    }
}

§
