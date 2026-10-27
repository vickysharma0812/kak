# Kakoune config for easifem (Fortran) development.
# Old config: kakrc.bak-2026-10-27
#
# Leader is <space> (Kakoune's user mode), like Helix's space mode.
#   <space>f  files          <space>/  live grep       <space>,  buffer picker
#   <space>e  yazi
#   <space>b  buffer mode    gn / gp   next / prev buffer   ga  last buffer
#   <space>s  doc symbols    <space>S  workspace syms  <space>d  diagnostics
#   <space>a  code action    <space>r  rename          <space>k  hover
#   <space>=  format         <space>c  comment         <space>t  tree-sitter
#   <space>l  all LSP cmds   <space>g  lazygit         <space>+  easifem build/test
#   gd / gr / gy             definition / references / type definition

# ─── tree-sitter ──────────────────────────────────────────────────────────────
# Must come before the colorscheme: KTS resets the ts_* faces when it starts.
evaluate-commands %sh{
    kak-tree-sitter -dks --init "$kak_session" \
        --config "$kak_config/kak-tree-sitter.toml" \
        --with-highlighting --with-text-objects
}

colorscheme catppuccin-mocha

# ─── editor ───────────────────────────────────────────────────────────────────
set-option global ui_options terminal_assistant=none terminal_set_title=true \
    terminal_info_max_width=80 terminal_synchronized=true 'terminal_padding_char= '
set-option global scrolloff 5,3
set-option global tabstop 2
set-option global indentwidth 2
set-option global autowrap_column 78
set-option global grepcmd 'rg --column --smart-case'

add-highlighter global/ number-lines -relative -hlcursor -separator ' '
add-highlighter global/ show-matching
add-highlighter global/ wrap -word -indent -marker '↪ '
add-highlighter global/ column 79 Whitespace

# <tab> inserts spaces
hook global InsertChar \t %{ execute-keys -draft h@ }

# trim trailing whitespace on save
hook global BufWritePre .* %{ try %{ execute-keys -draft '%s\h+$<ret>d' } }

# ─── clipboard (macOS) ────────────────────────────────────────────────────────
hook global RegisterModified '"' %{ nop %sh{
    printf %s "$kak_main_reg_dquote" | pbcopy
} }
map global user p '!pbpaste<ret>'     -docstring 'paste after from clipboard'
map global user P '<a-!>pbpaste<ret>' -docstring 'paste before from clipboard'

# ─── LSP ──────────────────────────────────────────────────────────────────────
# Same servers as ~/.config/helix/languages.toml.
evaluate-commands %sh{ kak-lsp }
remove-hooks global lsp-filetype-.*   # drop kak-lsp's defaults; ours are below

# Extra filetype detection to match Helix's file-types.
hook global BufCreate .*\.(qmd|livemd|mdx|mkdn|mdwn|mdown|markdn|mdtxt|mdtext|workbook) %{ set-option buffer filetype markdown }
hook global BufCreate .*/PULLREQ_EDITMSG %{ set-option buffer filetype markdown }
hook global BufCreate .*\.(ins|Rd|bbx|cbx) %{ set-option buffer filetype latex }
hook global BufCreate .*\.bib %{
    set-option buffer filetype bibtex
    set-option buffer comment_line '%'
}

# simple-completion-language-server (snippets, words, paths), shared by several languages
declare-option -hidden str lsp_scls %{
    [scls]
    command = "simple-completion-language-server"
    root_globs = [".git"]
    envs = { RUST_LOG = "info,simple-completion-language-server=info", LOG_FILE = "/tmp/completion.log" }
    settings_section = "_"
    [scls.settings._]
    feature_words = true
    feature_snippets = true
    snippets_first = true
    snippets_inline_by_word_tail = false
    feature_unicode_input = false
    feature_paths = true
    feature_citations = false
}

hook global BufSetOption filetype=fortran %{
    set-option buffer lsp_servers %{
        # gfortran diagnostics via ~/.config/efm-langserver/config.yaml
        [efm-langserver]
        root_globs = [".git"]

        [zfls]
        root_globs = ["fpm.toml", ".fortls", ".git", "CMakeLists.txt"]
        args = [
            "--nthreads", "10",
            "--lowercase_intrinsics",
            "--hover_signature",
            "--hover_language", "fortran",
            "--use_signature_help",
            "--incremental_sync",
            "--recursion_limit", "1000",
            "--source_dirs",
            "/Users/easifem/Dropbox/easifem/base/src/**",
            "/Users/easifem/Dropbox/easifem/classes/src/**",
            "/Users/easifem/Dropbox/easifem/seepage/src/**",
            "/Users/easifem/Dropbox/easifem/oneDimElasticity/src/**",
            "/Users/easifem/Dropbox/easifem/elasticity/src/**",
            "/Users/easifem/Dropbox/easifem/sdof/src/**",
            "/Users/easifem/.easifem/easifem/src/tomlf/src/**",
        ]

        [fortitude]
        root_globs = ["fpm.toml", "fortitude.toml", ".git", "CMakeLists.txt"]
        args = ["server"]
        settings_section = "_"
        [fortitude.settings._.settings]
        linelength = 78
        [fortitude.settings._.settings.check]
        select = ["C", "S"]
        ignore = [
            "superfluous-implicit-none",
            "implicit-external-procedures",
            "interface-implicit-typing",
            "bad-quote-string",
        ]
        preview = false
    }
    set-option -add buffer lsp_servers %opt{lsp_scls}
}

hook global BufSetOption filetype=cmake %{
    set-option buffer lsp_servers %{
        [neocmakelsp]
        root_globs = ["CMakeLists.txt", ".git"]
        args = ["stdio"]
    }
    set-option -add buffer lsp_servers %opt{lsp_scls}
}

hook global BufSetOption filetype=toml %{
    set-option buffer lsp_servers %{
        [taplo]
        root_globs = [".git"]
        args = ["lsp", "stdio"]
        [tombi]
        root_globs = ["tombi.toml", "pyproject.toml", ".git"]
        args = ["lsp"]
    }
}

hook global BufSetOption filetype=markdown %{
    set-option buffer lsp_servers %{
        [marksman]
        root_globs = [".marksman.toml", ".git"]
        args = ["server"]
        [rumdl]
        root_globs = [".rumdl.toml", "pyproject.toml", ".git"]
        args = ["server"]
    }
    set-option -add buffer lsp_servers %opt{lsp_scls}
}

hook global BufSetOption filetype=latex %{
    set-option buffer lsp_servers %{
        [texlab]
        root_globs = [".latexmkrc", "Tectonic.toml", ".git"]
        settings_section = "texlab"
        [texlab.settings.texlab]
        build.executable = "latexmk"
        build.args = ["-pdf", "-auxdir=build", "-outdir=.", "-interaction=nonstopmode", "-synctex=1", "%f"]
        build.forwardSearchAfter = true
        build.onSave = true
        forwardSearch.executable = "/Applications/Skim.app/Contents/SharedSupport/displayline"
        forwardSearch.args = ["-g", "-r", "%l", "%p", "%f"]

        [digestif]
        root_globs = [".git"]
    }
    set-option -add buffer lsp_servers %opt{lsp_scls}
}

hook global BufSetOption filetype=bibtex %{
    set-option buffer lsp_servers %{
        [texlab]
        root_globs = [".latexmkrc", "Tectonic.toml", ".git"]
    }
}

hook global BufSetOption filetype=git-commit %{
    set-option buffer lsp_servers %opt{lsp_scls}
}

hook global WinSetOption filetype=(fortran|cmake|toml|markdown|latex|bibtex|git-commit) %{
    lsp-enable-window
    lsp-inlay-diagnostics-enable window
    lsp-inlay-hints-enable window
}

set-option global lsp_hover_max_info_lines 30

map global user l ':enter-user-mode lsp<ret>'           -docstring 'LSP mode'
map global user k ':lsp-hover<ret>'                     -docstring 'hover'
map global user a ':lsp-code-actions<ret>'              -docstring 'code action'
map global user r ':lsp-rename-prompt<ret>'             -docstring 'rename'
map global user d ':lsp-diagnostics<ret>'               -docstring 'diagnostics'
map global user s ':lsp-document-symbol<ret>'           -docstring 'document symbols'
map global user S ':lsp-workspace-symbol-incr<ret>'     -docstring 'workspace symbols'
map global goto d '<esc>:lsp-definition<ret>'           -docstring 'definition (LSP)'
map global goto r '<esc>:lsp-references<ret>'           -docstring 'references (LSP)'
map global goto y '<esc>:lsp-type-definition<ret>'      -docstring 'type definition (LSP)'
map global normal <c-n> ':lsp-find-error --include-warnings<ret>'
map global normal <c-p> ':lsp-find-error --previous --include-warnings<ret>'

# ─── completion & snippets ────────────────────────────────────────────────────
# Kakoune inserts the highlighted item as soon as you move to it (<tab>/<c-n>),
# so there is no "accept" step. To match Helix:
#   <tab> / <s-tab>   move through the completion menu
#   <ret>             accept: close the menu without a newline (only after you
#                     picked an item; otherwise <ret> is a normal newline)
#   <tab>             with no menu open: jump to the next snippet placeholder
declare-option -hidden bool completion_menu false

# (Kakoune itself only uses <c-n>/<c-p> in this menu; window maps win over the
# global <tab> mapping below while the menu is open.)
hook global InsertCompletionShow .* %{
    set-option window completion_menu true
    map window insert <tab>   <c-n>
    map window insert <s-tab> <c-p>
}
hook global InsertCompletionHide .* %{
    set-option window completion_menu false
    unmap window insert <tab>
    unmap window insert <s-tab>
    unmap window insert <ret>
}
hook global InsertKey (<tab>|<s-tab>|<c-n>|<c-p>|<down>|<up>) %{
    evaluate-commands %sh{
        [ "$kak_opt_completion_menu" = true ] && echo "map window insert <ret> '<a-;>:completion-accept<ret><c-o><c-o>'"
    }
}

# Accept = close the menu (<c-o><c-o>), but first switch completers off until the
# next typed character; otherwise LSP completion reopens the menu immediately.
declare-option -hidden str-list completers_saved
define-command -hidden completion-accept %{
    set-option window completers_saved %opt{completers}
    set-option window completers
    hook -group completion-resume window InsertChar .* completion-resume
    hook -group completion-resume window ModeChange pop:insert:.* completion-resume
}
define-command -hidden completion-resume %{
    remove-hooks window completion-resume
    set-option window completers %opt{completers_saved}
}
map global insert <tab> '<a-;>:try lsp-snippets-select-next-placeholders catch %{ execute-keys -with-hooks <lt>tab> }<ret>' \
    -docstring 'next snippet placeholder'

# ─── formatter ────────────────────────────────────────────────────────────────
# Same as Helix (auto-format = true there): an external formatcmd where Helix
# has `formatter = ...`, otherwise the LSP server Helix would format with.
# `format-smart` picks whichever applies; it runs on save and on <space>=.
declare-option str lsp_format_server ''

hook global WinSetOption filetype=fortran %{
    set-option window formatcmd 'fprettier --config=/Users/easifem/.config/fprettier/fprettier.toml'
}
hook global WinSetOption filetype=cmake %{
    set-option window formatcmd 'gersemi --quiet -'
}
hook global WinSetOption filetype=bibtex %{
    set-option window formatcmd 'bibtex-tidy - --curly --drop-all-caps --remove-empty-fields --sort-fields --sort=year,author,id --strip-enclosing-braces --trailing-commas'
}
hook global WinSetOption filetype=toml     %{ set-option window lsp_format_server taplo }
hook global WinSetOption filetype=markdown %{ set-option window lsp_format_server rumdl }
hook global WinSetOption filetype=latex    %{ set-option window lsp_format_server texlab }

define-command format-smart -docstring 'format the buffer (formatcmd or LSP)' %{
    evaluate-commands %sh{
        if [ -n "$kak_opt_formatcmd" ]; then
            echo format-buffer
        elif [ -n "$kak_opt_lsp_format_server" ]; then
            echo "lsp-formatting-sync $kak_opt_lsp_format_server"
        else
            echo "fail %{no formatter for filetype $kak_opt_filetype}"
        fi
    }
}

hook global WinSetOption filetype=(fortran|cmake|bibtex|toml|markdown|latex) %{
    hook -group format-on-save window BufWritePre .* %{
        try %{ format-smart } catch %{ echo -debug "format: %val{error}" }
    }
    hook -once -always window WinSetOption filetype=.* %{ remove-hooks window format-on-save }
}
map global user = ':format-smart<ret>' -docstring 'format buffer'

# ─── picker (fzf in a tmux popup) ─────────────────────────────────────────────
define-command -hidden -params 1.. picker-popup %{ nop %sh{
    tmux display-popup -E -w 90% -h 85% -d "$PWD" \
        "$kak_config/bin/kak-picker" "$kak_session" "$kak_client" "$@" \
        >/dev/null 2>&1 </dev/null &
} }

define-command picker-files -docstring 'pick a file' %{ picker-popup files }
define-command picker-grep  -docstring 'live grep'   %{ picker-popup grep }
define-command yazi -docstring 'yazi file manager; opens the chosen file(s)' %{ evaluate-commands %sh{
    # start at the current file, like Helix's <space>e; fall back to the cwd
    if [ -f "$kak_buffile" ]; then start=$kak_buffile; else start=$PWD; fi
    printf "picker-popup yazi '%s'\n" "$(printf %s "$start" | sed "s/'/''/g")"
} }
define-command picker-buffers -docstring 'pick a buffer' %{ evaluate-commands %sh{
    list=$(mktemp "${TMPDIR:-/tmp}/kak-buffers.XXXXXX")
    eval set -- "$kak_quoted_buflist"
    for b; do case $b in \**) ;; *) printf '%s\n' "$b" ;; esac; done >"$list"
    printf 'picker-popup buffers %s\n' "$list"
} }

map global user f ':picker-files<ret>'   -docstring 'files'
map global user / ':picker-grep<ret>'    -docstring 'live grep'
map global user , ':picker-buffers<ret>' -docstring 'buffer picker'
map global user e ':yazi<ret>'           -docstring 'yazi file manager'

# ─── buffers ──────────────────────────────────────────────────────────────────
# ga (last buffer) is built in; gn / gp match Helix.
map global goto n '<esc>:buffer-next<ret>'     -docstring 'next buffer'
map global goto p '<esc>:buffer-previous<ret>' -docstring 'previous buffer'

define-command delete-other-buffers -docstring 'close all other unmodified buffers' %{
    evaluate-commands %sh{
        eval set -- "$kak_quoted_buflist"
        for b; do
            [ "$b" = "$kak_bufname" ] && continue
            case $b in \**) continue ;; esac
            printf "try %%{ delete-buffer '%s' }\n" "$(printf %s "$b" | sed "s/'/''/g")"
        done
    }
}

declare-user-mode buffer
map global user   b ':enter-user-mode buffer<ret>'  -docstring 'buffer mode'
map global buffer b ':picker-buffers<ret>'          -docstring 'picker'
map global buffer n ':buffer-next<ret>'             -docstring 'next'
map global buffer p ':buffer-previous<ret>'         -docstring 'previous'
map global buffer a 'ga'                            -docstring 'alternate (last)'
map global buffer q ':delete-buffer<ret>'           -docstring 'close'
map global buffer Q ':delete-buffer!<ret>'          -docstring 'close, discard changes'
map global buffer o ':delete-other-buffers<ret>'    -docstring 'close others'
map global buffer w ':write<ret>'                   -docstring 'write'
map global buffer W ':write-all<ret>'               -docstring 'write all'

# ─── tree-sitter keys ─────────────────────────────────────────────────────────
# <space>t opens the KTS menu: f/a/t/c = search function/parameter/type/comment,
# s = select parent node, r/c = next/prev sibling.
map global user t ':enter-user-mode tree-sitter<ret>' -docstring 'tree-sitter'
# expand / shrink selection to parent / child node (Helix's <a-o>/<a-i>)
map global normal <a-up>   ":tree-sitter-nav '""parent""'<ret>"
map global normal <a-down> ":tree-sitter-nav '""first_child""'<ret>"

# ─── misc ─────────────────────────────────────────────────────────────────────
define-command -hidden popup -params 1.. -docstring 'run a command in a tmux popup' %{ nop %sh{
    tmux display-popup -E -w 90% -h 90% -d "$PWD" "$@" >/dev/null 2>&1 </dev/null &
} }

define-command lazygit -docstring 'lazygit in a popup' %{ popup lazygit }

# easifem build / test (same scripts as Helix's "+" mode)
define-command easifem-build-base    %{ nop %sh{ ~/.config/tmux/scripts/buildBase.sh    >/dev/null 2>&1 </dev/null & } }
define-command easifem-build-classes %{ nop %sh{ ~/.config/tmux/scripts/buildClasses.sh >/dev/null 2>&1 </dev/null & } }
define-command easifem-run-test -docstring 'easifem run on this file' %{
    write
    popup bash -c %sh{
        printf '%s' "bash ~/.config/helix/scripts/easifemRunTest.sh '$kak_buffile'; read -rp 'Press Enter...'"
    }
}

map global user c ':comment-line<ret>' -docstring 'comment lines'
map global user g ':lazygit<ret>'      -docstring 'lazygit'
declare-user-mode easifem
map global user    + ':enter-user-mode easifem<ret>'   -docstring 'easifem build/test'
map global easifem b ':easifem-build-base<ret>'        -docstring 'build base'
map global easifem c ':easifem-build-classes<ret>'     -docstring 'build classes'
map global easifem + ':easifem-run-test<ret>'          -docstring 'run test for this file'

# ─── modeline / prompt ────────────────────────────────────────────────────────
# Helix-style: coloured mode badge, file, LSP status, diagnostics, position.
# The `:` prompt is drawn in the status line, so it shares this bar.
declare-option -hidden str modeline_mode 'NOR'
hook global ModeChange .*:normal %{ set-option window modeline_mode 'NOR'; set-face window ModelineMode ModeNormal }
hook global ModeChange .*:insert %{ set-option window modeline_mode 'INS'; set-face window ModelineMode ModeInsert }
hook global ModeChange .*:prompt %{ set-option window modeline_mode 'CMD'; set-face window ModelineMode ModePrompt }

set-option global modelinefmt '{ModelineMode} %opt{modeline_mode} {StatusLine} {StatusLineInfo}%val{bufname}{StatusLine} {{context_info}} {{mode_info}} '
set-option -add global modelinefmt %opt{lsp_modeline}
set-option -add global modelinefmt ' {ModelineError}● %opt{lsp_diagnostic_error_count} {ModelineWarning}▲ %opt{lsp_diagnostic_warning_count}{StatusLine}  {StatusLineValue}%val{cursor_line}:%val{cursor_char_column}{StatusLine}  {ModelineDim}%opt{filetype} '
