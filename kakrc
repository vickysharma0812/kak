# Kakoune config for easifem (Fortran) development.
# Old config: kakrc.bak-2026-10-27
#
# Leader is <space> (Kakoune's user mode), like Helix's space mode.
#   <space>f  files          <space>/  live grep       <space>,  buffer picker
#   <space>e  broot          <space>E  yazi            <space>h  git hunks / blame
#   <space>b  buffer mode    gn / gp   next / prev buffer   ga  last buffer
#   <space>s  goto symbol    <space>S  workspace syms  <space>d  diagnostics
#   <space>a  code action    <space>r  rename          <space>k  hover
#   <space>=  format         <space>c  comment         <space>t  tree-sitter
#   <space>l  all LSP cmds (l s goto symbol, l S symbol list)
#   <space>g  lazygit        <space>+  easifem build/test
#   gd / gr / gy             definition / references / type definition
#   m         match / surround (mm ms mr md mi ma), as in Helix
#   gw        jump to a word by its two-letter label, as in Helix

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

# Case-insensitive select and search, like Helix: each regex prompt starts with
# (?i). Delete it for an exact-case match.
map global normal s     's(?i)'
map global normal S     'S(?i)'
map global normal <a-k> '<a-k>(?i)'
map global normal <a-K> '<a-K>(?i)'
map global normal /     '/(?i)'
map global normal ?     '?(?i)'
map global normal <a-/> '<a-/>(?i)'
map global normal <a-?> '<a-?>(?i)'

# Helix's x: select the line; pressed again on whole lines, add the next line.
# A count selects that many lines (3x). X is Kakoune's x (to line bounds only).
map global normal x ': helix-x %val{count}<ret>' -docstring 'select line, then add the next'
map global normal X 'x'                            -docstring 'extend to line bounds'
define-command -hidden helix-x -params 1 %{
    execute-keys <a-:>
    helix-x-extend %val{selections_desc} %arg{1}
}
define-command -hidden helix-x-extend -params 2 %{
    execute-keys x
    # unchanged by x: the selections were already whole lines
    evaluate-commands %sh{
        c=${2:-0}; [ "$c" -lt 1 ] && c=1
        if [ "$kak_selections_desc" = "$1" ]; then j=$c; else j=$((c - 1)); fi
        [ $j -gt 0 ] && echo "execute-keys ${j}Jx"
    }
}

add-highlighter global/ number-lines -relative -hlcursor -separator ' '
add-highlighter global/ show-matching
add-highlighter global/ wrap -word -indent -marker '↪ '
add-highlighter global/ column 79 Whitespace

# <tab> inserts spaces
hook global InsertChar \t %{ execute-keys -draft h@ }

# trim trailing whitespace on save
hook global BufWritePre .* %{ try %{ execute-keys -draft '%s\h+$<ret>d' } }

# ─── clipboard (macOS) ────────────────────────────────────────────────────────
# pbcopy runs in the background so yanks and deletes never wait on it
hook global RegisterModified '"' %{ nop %sh{
    { printf %s "$kak_main_reg_dquote" | pbcopy; } >/dev/null 2>&1 </dev/null &
} }
map global user p '!pbpaste<ret>'     -docstring 'paste after from clipboard'
map global user P '<a-!>pbpaste<ret>' -docstring 'paste before from clipboard'

# ─── LSP ──────────────────────────────────────────────────────────────────────
# Same servers as ~/.config/helix/languages.toml.
evaluate-commands %sh{ kak-lsp }
# Ask for code actions only on <space>a, like Helix. Polling them on every idle
# makes fortitude return an error whenever it thinks the file has a syntax error.
set-option global lsp_auto_show_code_actions false
# Show the signature of the call being typed, like Helix's auto-signature-help.
lsp-auto-signature-help-enable
remove-hooks global lsp-filetype-.*   # drop kak-lsp's defaults; ours are below

# Extra filetype detection to match Helix's file-types.
hook global BufCreate .*\.(qmd|livemd|mdx|mkdn|mdwn|mdown|markdn|mdtxt|mdtext|workbook) %{ set-option buffer filetype markdown }
hook global BufCreate .*/PULLREQ_EDITMSG %{ set-option buffer filetype markdown }
hook global BufCreate .*\.(ins|Rd|bbx|cbx) %{ set-option buffer filetype latex }
hook global BufCreate .*\.bib %{
    set-option buffer filetype bibtex
    set-option buffer comment_line '%'
}

# Snippets: simple-completion-language-server serves the VSCode-style snippets in
# $SNIPPETS_PATH (~/.config/nvim/snippets, set in fish config), shared with Helix
# and Neovim. Snippets only: Kakoune already completes words and file paths.
# Uses bin/scls-kak, a copy patched to accept kak-lsp's full-document updates
# (stock scls ignores them and returns nothing). Build it with bin/build-scls-kak;
# Helix keeps using the stock binary.
declare-option -hidden str lsp_scls %{
    [scls]
    command = "/Users/easifem/.config/kak/bin/scls-kak"
    root_globs = [".git"]
    settings_section = "_"
    [scls.settings._]
    feature_snippets = true
    snippets_first = true
    snippets_inline_by_word_tail = false
    feature_words = false
    feature_paths = false
    feature_unicode_input = false
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

        # Lint rules come from the project's config file (fortitude.toml,
        # .fortitude.toml, [extra.fortitude] in fpm.toml, or pyproject.toml);
        # projects without one get fortitude's defaults.
        [fortitude]
        root_globs = ["fortitude.toml", ".fortitude.toml", "fpm.toml", ".git", "CMakeLists.txt"]
        args = ["server"]
        settings_section = "_"
        [fortitude.settings._.settings]
        configurationPreference = "filesystemFirst"
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
    set-option -add buffer lsp_servers %opt{lsp_scls}
}

hook global WinSetOption filetype=(fortran|cmake|toml|markdown|latex|bibtex) %{
    lsp-enable-window
    # no breadcrumbs (Helix has none): saves a documentSymbol request per idle
    remove-hooks window lsp-breadcrumbs
    lsp-inlay-diagnostics-enable window
    lsp-inlay-hints-enable window
}

set-option global lsp_hover_max_info_lines 30

map global user l ':enter-user-mode lsp<ret>'           -docstring 'LSP mode'
map global user k ':lsp-hover<ret>'                     -docstring 'hover'
map global user a ':lsp-code-actions<ret>'              -docstring 'code action'
map global user r ':lsp-rename-prompt<ret>'             -docstring 'rename'
map global user d ':lsp-diagnostics<ret>'               -docstring 'diagnostics'
map global user s ':lsp-goto-document-symbol<ret>'      -docstring 'goto symbol'
map global user S ':lsp-workspace-symbol-incr<ret>'     -docstring 'workspace symbols'
map global goto d '<esc>:lsp-definition<ret>'           -docstring 'definition (LSP)'
map global goto r '<esc>:lsp-references<ret>'           -docstring 'references (LSP)'
map global goto y '<esc>:lsp-type-definition<ret>'      -docstring 'type definition (LSP)'
map global normal <c-n> ':lsp-find-error --include-warnings<ret>'
map global normal <c-p> ':lsp-find-error --previous --include-warnings<ret>'

# ─── completion & snippets ─────────────────────────────────────────────────────
# Kakoune inserts the highlighted item as soon as you move to it (<tab>/<c-n>),
# so there is no "accept" step. To match Helix:
#   <tab> / <s-tab>   move through the completion menu (also <down> / <up>)
#   <ret>             accept: close the menu without a newline (only after you
#                     picked an item; otherwise <ret> is a normal newline).
#                     A snippet expands with its first placeholder selected.
#   <tab>             no menu open: jump to the next snippet placeholder
declare-option -hidden bool completion_menu false

# (Kakoune itself only uses <c-n>/<c-p> in this menu.)
hook global InsertCompletionShow .* %{
    set-option window completion_menu true
    map window insert <tab>   <c-n>
    map window insert <s-tab> <c-p>
    map window insert <down>  <c-n>
    map window insert <up>    <c-p>
}
hook global InsertCompletionHide .* %{
    set-option window completion_menu false
    unmap window insert <tab>
    unmap window insert <s-tab>
    unmap window insert <down>
    unmap window insert <up>
    unmap window insert <ret>
}
# Branch on the bool by command name (…-true / …-false) instead of a shell.
hook global InsertKey (<tab>|<s-tab>|<c-n>|<c-p>|<down>|<up>) %{
    evaluate-commands "completion-arm-enter-%opt{completion_menu}"
}
define-command -hidden completion-arm-enter-true %{
    map window insert <ret> '<a-;>:completion-accept<ret><c-o><c-o><a-;>:completion-arm-resume<ret>'
}
define-command -hidden completion-arm-enter-false nop

# Accept = close the menu (<c-o><c-o>), but first switch completers off until the
# next typed character; otherwise LSP completion reopens the menu immediately.
declare-option -hidden str-list completers_saved
define-command -hidden completion-accept %{
    set-option window completers_saved %opt{completers}
    set-option window completers
}
# Armed only after <c-o><c-o>: closing the menu is what expands a snippet, and
# that insertion must not count as "the next typed character".
define-command -hidden completion-arm-resume %{
    hook -group completion-resume window InsertChar .* completion-resume
    hook -group completion-resume window ModeChange pop:insert:.* completion-resume
}
define-command -hidden completion-resume %{
    remove-hooks window completion-resume
    set-option window completers %opt{completers_saved}
}

# kak-lsp cannot expand nested placeholders, VSCode variables or regex transforms
# (used by ~100 of the shared snippets). Same as kak-lsp's own command, but the
# snippet is first rewritten by bin/kak-snippet-flatten.
define-command -override -hidden lsp-snippets-insert-completion -params 1 %{ evaluate-commands %{
    set-option window lsp_snippet_to_insert %sh{
        printf %s "$1" | KAK_SNIPPET_FILE="$kak_buffile" "$kak_config/bin/kak-snippet-flatten"
    }
    lsp-completion-on-accept %{
        # Delete the inserted text.
        select %opt{lsp_completion_inserted_ranges}
        execute-keys '<a-;>d'
        evaluate-commands -save-regs y %{
            set-register y nop
            evaluate-commands -draft -verbatim lsp-snippets-insert %opt[lsp_snippet_to_insert]
            try %reg{y}
        }
    }
}}

# kak-lsp deletes a placeholder's default text as soon as <tab> reaches it, so a
# skipped placeholder ends up empty. Like Helix, keep the default unless you type
# over it: save it before kak-lsp deletes it, and put it back if you <tab> on or
# leave insert mode without typing. This reuses kak-lsp's own jump command with
# its delete step wrapped. (§ delimiter: the awk pattern has an unbalanced brace.)
evaluate-commands %sh§
    kak-lsp | awk '/^define-command lsp-snippets-select-next-placeholders/,/^}/' |
        sed -e 's/^define-command /define-command -override /' \
            -e "s/execute-keys '<a-;>d'/snippet-placeholder-clear/"
§
declare-option -hidden bool snippet_default_saved false
define-command -hidden snippet-placeholder-clear %{
    # An empty placeholder ($0, or a line holding only indentation) is a 1-char
    # selection on the line break; deleting that would join the next line in.
    try %{
        execute-keys '<a-;><a-K>\A\n\z<ret>'
        set-register p %val{selections}
        execute-keys '<a-;>d'
        set-option window snippet_default_saved true
        hook -once -group snippet-typed window InsertChar .* %{ set-option window snippet_default_saved false }
    } catch %{
        set-option window snippet_default_saved false
    }
}
define-command -hidden snippet-placeholder-restore %{
    remove-hooks window snippet-typed
    evaluate-commands "snippet-placeholder-restore-%opt{snippet_default_saved}"
    set-option window snippet_default_saved false
}
define-command -hidden snippet-placeholder-restore-true %{ execute-keys -draft '"pP' }
define-command -hidden snippet-placeholder-restore-false nop
define-command -hidden snippet-next %{
    snippet-placeholder-restore
    try lsp-snippets-select-next-placeholders catch %{ execute-keys -with-hooks <tab> }
}
hook global ModeChange pop:insert:.* %{ try snippet-placeholder-restore }

# The window <tab> mapping above wins while the menu is open.
map global insert <tab> '<a-;>:snippet-next<ret>' \
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
define-command broot -docstring 'broot file tree; <ret> opens the file' %{ evaluate-commands %sh{
    # start in the current file's directory; fall back to the cwd
    if [ -f "$kak_buffile" ]; then start=${kak_buffile%/*}; else start=$PWD; fi
    printf "picker-popup broot '%s'\n" "$(printf %s "$start" | sed "s/'/''/g")"
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
map global user e ':broot<ret>'          -docstring 'broot file tree'
map global user E ':yazi<ret>'           -docstring 'yazi file manager'

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

define-command lazygit -docstring 'lazygit in a popup' %{
    # refresh the branch and the diff gutter when lazygit exits
    popup sh -c %sh{
        printf 'lazygit; echo "evaluate-commands -client %s git-refresh" | kak -p %s' "$kak_client" "$kak_session"
    }
}

# easifem build / test (same scripts as Helix's "+" mode)
# Builds run in the background (bin/easifem-build); Kakoune and macOS report
# the result, and <space>+ l opens the log of the latest build.
define-command easifem-build -params 1 -docstring 'easifem-build <base|classes>: build and install in the background' %{
    nop %sh{ "$kak_config/bin/easifem-build" "$kak_session" "$kak_client" "$1" >/dev/null 2>&1 </dev/null & }
    echo -markup "{Information}easifem: building %arg{1} in the background"
}
define-command easifem-build-base    %{ easifem-build base }
define-command easifem-build-classes %{ easifem-build classes }
define-command easifem-build-log -params ..1 -docstring 'easifem-build-log [base|classes]: open a build log (default: the latest)' %{
    evaluate-commands %sh{
        dir=${XDG_CACHE_HOME:-$HOME/.cache}/easifem
        if [ -n "$1" ]; then log=$dir/easifem-build-$1-log.txt
        else log=$(ls -t "$dir"/easifem-build-*-log.txt 2>/dev/null | head -n 1); fi
        [ -f "$log" ] || { echo "fail 'easifem: no build log yet'"; exit; }
        printf "edit -existing '%s'\nset-option buffer autoreload yes\n" "$log"
    }
}
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
map global easifem l ':easifem-build-log<ret>'         -docstring 'open the latest build log'
map global easifem + ':easifem-run-test<ret>'          -docstring 'run test for this file'

# ─── match / surround (Helix's `m` mode) ──────────────────────────────────────
# mm match bracket, ms add, mr replace, md delete, mi / ma inside / around.
# Pair keys: ( ) b  [ ] r  { } B  < > a  " Q  ' q  ` g; ms takes any character.
# Kakoune's own `m` is now `mm`; `M` (extend to the matching bracket) is unchanged.
declare-user-mode match
map global normal m ':enter-user-mode match<ret>'
map global match m 'm'     -docstring 'goto matching bracket'
map global match s ':on-key -mode-name surround %{ surround-pair surround-add %val{key} }<ret>' -docstring 'surround add'
map global match r ':on-key -mode-name surround %{ set-option window surround_from %val{key}; on-key -mode-name surround-with %{ surround-pair surround-replace %val{key} } }<ret>' -docstring 'surround replace'
map global match d ':on-key -mode-name surround %{ surround-delete %val{key} }<ret>' -docstring 'surround delete'
map global match i '<a-i>' -docstring 'select inside object'
map global match a '<a-a>' -docstring 'select around object'

# surround-pair <command> <key>: run <command> <open> <close> for that key.
define-command -hidden surround-pair -params 2 %{ evaluate-commands %sh§
    case $2 in
        '('|')'|b)        o='(' c=')' ;;
        '['|']'|r)        o='[' c=']' ;;
        '{'|'}'|B)        o='{' c='}' ;;
        '<lt>'|'<gt>'|a)  o='<' c='>' ;;
        Q|'<dquote>')     o='"' c='"' ;;
        q|'<quote>')      o="'" c="'" ;;
        g)                o='`' c='`' ;;
        '<space>')        o=' ' c=' ' ;;
        '<plus>')         o='+' c='+' ;;
        '<minus>')        o='-' c='-' ;;
        '<semicolon>')    o=';' c=';' ;;
        '<percent>')      o='%' c='%' ;;
        '<esc>')          exit ;;
        '<'*'>')          echo "fail 'surround: no pair for $2'"; exit ;;
        *)                o=$2 c=$2 ;;
    esac
    q="'"
    printf "%s '%s' '%s'\n" "$1" "${o//$q/$q$q}" "${c//$q/$q$q}"
§ }

# Like Helix, the selections then include the new pair.
define-command -hidden surround-add -params 2 %{
    evaluate-commands -save-regs '"' %{
        set-register '"' %arg{1}
        execute-keys -draft P
        set-register '"' %arg{2}
        execute-keys -draft p
        execute-keys '<a-:>L<a-;>H<a-;>'
    }
}

# <a-a> selects the pair with its contents, <a-S> keeps just the two ends.
define-command -hidden surround-delete -params 1 %{
    evaluate-commands -draft %{
        execute-keys "<a-a>%arg{1}<a-S>d"
    }
}

# surround-replace <open> <close>: replace the pair keyed by surround_from
declare-option -hidden str surround_from
define-command -hidden surround-replace -params 2 %{
    evaluate-commands -draft -save-regs '"' %{
        execute-keys "<a-a>%opt{surround_from}<a-S>"
        # the ends alternate open, close, open, close ... in buffer order
        evaluate-commands %sh{
            q="'" o="'${1//$q/$q$q}'" c="'${2//$q/$q$q}'" vals=
            i=0; while [ $i -lt $kak_selection_count ]; do vals="$vals $o $c"; i=$((i + 2)); done
            echo "set-register '\"' $vals"
        }
        execute-keys R
    }
}

# ─── auto pairs (like Helix) ──────────────────────────────────────────────────
# Typing ( [ { " ' ` inserts the closing character too, when the next character
# is a space, the end of the line or a closing bracket (quotes also need no
# letter or digit just before them, so "don't" stays as typed). Typing the
# closing character steps over it, and <backspace> on the opening one of an
# empty pair deletes both. Turn it off with :remove-hooks global auto-pairs.
# In these hooks the cursor is on the character after the one just typed.
# \x7D stands for a closing brace, which would end the %{...} block.
define-command -hidden auto-pairs-open -params 2 %{
    try %{
        execute-keys -draft ';<a-k>[\s)\]\x7D]<ret>'
        execute-keys "%arg{2}<left>"
    }
}
define-command -hidden auto-pairs-skip -params 1 %{
    execute-keys -draft ";<a-k>\Q%arg{1}<ret>d"
}
define-command -hidden auto-pairs-quote -params 1 %{
    try %{
        auto-pairs-skip %arg{1}
    } catch %{
        execute-keys -draft ';hh<a-K>\w<ret>'
        auto-pairs-open %arg{1} %arg{1}
    } catch %{}
}
hook -group auto-pairs global InsertChar \( %{ auto-pairs-open ( ) }
hook -group auto-pairs global InsertChar \[ %{ auto-pairs-open [ ] }
hook -group auto-pairs global InsertChar \{ %{ auto-pairs-open { } }
hook -group auto-pairs global InsertChar '[)\]}]' %{ try %{ auto-pairs-skip %val{hook_param} } }
hook -group auto-pairs global InsertChar '["''`]' %{ auto-pairs-quote %val{hook_param} }
hook -group auto-pairs global InsertDelete \( %{ try %{ auto-pairs-skip ) } }
hook -group auto-pairs global InsertDelete \[ %{ try %{ auto-pairs-skip ] } }
hook -group auto-pairs global InsertDelete \{ %[ try %[ auto-pairs-skip '}' ] ]
hook -group auto-pairs global InsertDelete '["''`]' %{ try %{ auto-pairs-skip %val{hook_param} } }

# ─── jump labels (Helix's gw) ─────────────────────────────────────────────────
# gw draws a two-letter label over every word in view, nearest the cursor first
# (bin/kak-jump-labels); typing a label selects that word. Any other key cancels.
# The jump is saved in the jump list, so <c-o> goes back.
declare-option -hidden range-specs jump_labels
declare-option -hidden str jump_targets
map global goto w '<esc>:goto-word<ret>' -docstring 'jump to a word by its label'
define-command goto-word -docstring 'jump to a word in view by its two-letter label (Helix gw)' %{
    goto-word-labels %val{cursor_line} %val{cursor_column}
    add-highlighter window/goto-word replace-ranges jump_labels
    on-key %{ goto-word-first %val{key} }
}
define-command -hidden goto-word-labels -params 2 %{
    evaluate-commands -draft %{
        evaluate-commands %sh{
            set -- $kak_window_range
            top=$(($1 + 1)) bot=$(($1 + $3))
            [ $bot -gt $kak_buf_line_count ] && bot=$kak_buf_line_count
            echo "select $top.1,$bot.1"
        }
        execute-keys x
        evaluate-commands %sh{
            printf %s "$kak_selection" |
                "$kak_config/bin/kak-jump-labels" "${kak_selection_desc%%.*}" "$1" "$2" "$kak_timestamp"
        }
    }
}
# After the first letter only the labels starting with it remain, showing
# their second letter.
define-command -hidden goto-word-first -params 1 %{
    evaluate-commands %sh{
        case $1 in [a-z]) ;; *) echo goto-word-done; exit ;; esac
        specs=
        for t in $kak_opt_jump_targets; do
            case $t in "$1"?=*) ;; *) continue ;; esac
            start=${t#*=} start=${start%,*}
            specs="$specs '$start,$start|{JumpLabel}$(printf %s "$t" | cut -c2)'"
        done
        [ -n "$specs" ] || { echo goto-word-done; exit; }
        echo "set-option window jump_labels $kak_timestamp $specs"
        echo "on-key %{ goto-word-second $1 %val{key} }"
    }
}
define-command -hidden goto-word-second -params 2 %{
    goto-word-done
    evaluate-commands %sh{
        for t in $kak_opt_jump_targets; do
            case $t in "$1$2"=*) printf 'execute-keys <c-s>\nselect %s\n' "${t#*=}"; exit ;; esac
        done
    }
}
define-command -hidden goto-word-done %{
    remove-highlighter window/goto-word
    unset-option window jump_labels
}

# ─── modeline / prompt ────────────────────────────────────────────────────────
# Helix-style: coloured mode badge, file, LSP status, diagnostics, position.
# The `:` prompt is drawn in the status line, so it shares this bar.
declare-option -hidden str modeline_mode 'NOR'
hook global ModeChange .*:normal %{ set-option window modeline_mode 'NOR'; set-face window ModelineMode ModeNormal }
hook global ModeChange .*:insert %{ set-option window modeline_mode 'INS'; set-face window ModelineMode ModeInsert }
hook global ModeChange .*:prompt %{ set-option window modeline_mode 'CMD'; set-face window ModelineMode ModePrompt }

# File name only, not the path; computed once per buffer, not on every redraw.
declare-option -hidden str modeline_bufname
hook global BufCreate .* %{ set-option buffer modeline_bufname %sh{ printf %s "${kak_bufname##*/}" } }

# Git branch of the file's directory (short commit when detached), like Helix's
# version-control element. One git call when a buffer is shown, when the terminal
# regains focus, and after lazygit closes.
declare-option -hidden str modeline_branch
define-command -hidden modeline-update-branch %{
    set-option buffer modeline_branch %sh{
        cd "${kak_buffile%/*}" 2>/dev/null || exit
        b=$(git branch --show-current 2>/dev/null) || exit
        [ -n "$b" ] || b=$(git rev-parse --short HEAD 2>/dev/null)
        [ -n "$b" ] && printf ' %s ' "$b"
    }
}
hook global WinDisplay .* git-refresh
hook global FocusIn    .* git-refresh

set-option global modelinefmt '{ModelineMode} %opt{modeline_mode} {StatusLine} {StatusLineInfo}%opt{modeline_bufname}{StatusLine} {ModelineBranch}%opt{modeline_branch}{StatusLine}{{context_info}} {{mode_info}} '
set-option -add global modelinefmt %opt{lsp_modeline}
set-option -add global modelinefmt ' {ModelineError}● %opt{lsp_diagnostic_error_count} {ModelineWarning}▲ %opt{lsp_diagnostic_warning_count}{StatusLine}  {StatusLineValue}%val{cursor_line}:%val{cursor_char_column}{StatusLine}  {ModelineDim}%opt{filetype} '

# ─── git signs (like gitsigns / Helix's diff gutter) ──────────────────────────
# Kakoune's stdlib `git` command does the work: show-diff marks added (green),
# changed (blue) and deleted (red) lines against the index, so staging a change
# clears its marks. Files outside a repo (empty branch) are skipped.
define-command -hidden git-refresh %{
    modeline-update-branch
    evaluate-commands %sh{ [ -n "$kak_opt_modeline_branch" ] && echo 'git show-diff' }
}
define-command -hidden gitsigns-update %{
    evaluate-commands %sh{ [ -n "$kak_opt_modeline_branch" ] && echo 'git update-diff' }
}
hook global BufWritePost .*                %{ gitsigns-update }
hook global ModeChange   pop:insert:normal %{ gitsigns-update }
hook global BufReload    .*                %{ gitsigns-update }
# The gutter column is as wide as its widest flag, so it would appear (and
# shift the text) with the first change. A blank flag on line 0, which is
# never drawn, keeps it one column wide; kak-lsp does the same for diagnostics.
# (The hook parameter does not show line-specs values, hence the shell test.)
hook global BufSetOption git_diff_flags=.* %{
    evaluate-commands %sh{
        case $kak_quoted_opt_git_diff_flags in
            *"'0| '"*) ;;
            *) echo "set-option buffer git_diff_flags $kak_quoted_opt_git_diff_flags '0| '" ;;
        esac
    }
}

# Revert rewrites the file from git, so unsaved edits would be mixed in.
define-command -hidden gitsigns-revert %{
    evaluate-commands %sh{ [ "$kak_modified" = true ] && echo "fail 'git: save the buffer first'" }
    git apply --reverse
}

declare-user-mode git
map global user h ':enter-user-mode git<ret>'        -docstring 'git hunks'
map global git  n ':git next-hunk<ret>'              -docstring 'next change'
map global git  p ':git prev-hunk<ret>'              -docstring 'previous change'
map global git  s ':git apply --cached<ret>'         -docstring 'stage selected lines'
map global git  u ':git apply --cached --reverse<ret>' -docstring 'unstage selected lines'
map global git  r ':gitsigns-revert<ret>'            -docstring 'revert selected lines to the index'
map global git  b ':git blame<ret>'                  -docstring 'toggle blame (<ret>: show commit)'
map global git  d ':git diff -- %val{buffile}<ret>'  -docstring 'diff of this file'
map global git  h ':git hide-diff<ret>'              -docstring 'hide the marks (<space>hg shows them)'
map global git  g ':git show-diff<ret>'              -docstring 'show the marks'
