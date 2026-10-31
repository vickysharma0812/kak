# Kakoune config for easifem (Fortran) development.
# Old config: kakrc.bak-2026-10-27
#
# Leader is <space> (Kakoune's user mode), like Helix's space mode.
#   <space>f  files          <space>/  live grep       <space>,  buffer picker
#   <space>e  yazi           <space>E  broot           <space>h  git hunks / blame
#   <space>b  buffer mode    gn / gp   next / prev buffer   ga  last buffer
#   <space>s  goto symbol    <space>S  workspace syms  <space>d  diagnostics picker
#   <space>D  diagnostics list (buffer)  <space>?  command palette  <space>'  last picker
#   <space>a  code action    <space>r  rename          <space>k  hover
#   <space>=  format         <space>c  comment         <space>t  tree-sitter
#   <space>l  all LSP cmds (l s goto symbol, l S symbol list)
#   <space>g  lazygit        <space>G  diffnav         <space>+  easifem build/test
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
# Indent guides, like Helix's indent-guides.render: a bar at each indent level
# (every indentwidth columns); the other whitespace stays invisible.
add-highlighter global/indent-guides show-whitespaces -lf ' ' -spc ' ' -nbsp ' ' -tab ' ' -tabpad ' ' -indent '│'

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

# JSON (e.g. the snippet files): checks the syntax as you type, and formats
# (provideFormatter), as Helix does with the same server.
hook global BufSetOption filetype=json %{
    set-option buffer lsp_servers %{
        [vscode-json-language-server]
        root_globs = ["package.json", ".git"]
        args = ["--stdio"]
        settings_section = "_"
        [vscode-json-language-server.settings._]
        provideFormatter = true
        json.format.enable = true
        json.validate.enable = true
    }
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

# Markdown: no language server (formatting is rumdl's command line, below).

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

hook global WinSetOption filetype=(fortran|cmake|toml|latex|bibtex|json) %{
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
map global user D ':remove-hooks global picker-diagnostics; lsp-diagnostics<ret>' -docstring 'diagnostics list (buffer)'
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
hook global WinSetOption filetype=markdown %{
    set-option window formatcmd 'rumdl fmt --silent -'
}
hook global WinSetOption filetype=bibtex %{
    set-option window formatcmd 'bibtex-tidy - --curly --drop-all-caps --remove-empty-fields --sort-fields --sort=year,author,id --strip-enclosing-braces --trailing-commas'
}
hook global WinSetOption filetype=toml     %{ set-option window lsp_format_server taplo }
hook global WinSetOption filetype=latex    %{ set-option window lsp_format_server texlab }
hook global WinSetOption filetype=json     %{ set-option window lsp_format_server vscode-json-language-server }

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

hook global WinSetOption filetype=(fortran|cmake|bibtex|toml|markdown|latex|json) %{
    hook -group format-on-save window BufWritePre .* %{
        try %{ format-smart } catch %{ echo -debug "format: %val{error}" }
    }
    hook -once -always window WinSetOption filetype=.* %{ remove-hooks window format-on-save }
}
map global user = ':format-smart<ret>' -docstring 'format buffer'

# ─── picker (fzf in a tmux popup) ─────────────────────────────────────────────
# bin/kak-picker runs the picker and sends the choice back. The fzf pickers
# also send back their query, so <space>' reopens the last picker with it.
declare-option -hidden str picker_last
declare-option -hidden str picker_query
declare-option -hidden bool picker_resuming false
define-command -hidden -params 1.. picker-popup %{
    set-option global picker_last %arg{1}
    nop %sh{
        q=; [ "$kak_opt_picker_resuming" = true ] && q=$kak_opt_picker_query
        # tmux's environment lacks EDITOR; yazi needs it (bulk rename, `edit`)
        tmux display-popup -E -w 90% -h 85% -d "$PWD" -e "KAK_PICKER_QUERY=$q" \
            ${EDITOR:+-e "EDITOR=$EDITOR"} \
            "$kak_config/bin/kak-picker" "$kak_session" "$kak_client" "$@" \
            >/dev/null 2>&1 </dev/null &
    }
    set-option global picker_resuming false
}
define-command picker-resume -docstring 'reopen the last picker, with its query' %{
    evaluate-commands %sh{
        case $kak_opt_picker_last in
            '') echo "fail 'no picker opened yet'" ;;
            yazi | broot) echo "$kak_opt_picker_last" ;;
            *) echo "set-option global picker_resuming true; picker-$kak_opt_picker_last" ;;
        esac
    }
}

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

declare-option -hidden str picker_from   # buffer to return to
declare-option -hidden str picker_client # client to show the picker for
declare-option -hidden str picker_list     # diagnostics for the picker
declare-option -hidden str picker_root     # ...and the project root they are relative to
declare-option -hidden str picker_palette  # file holding the palette's mappings

# Diagnostics of the open files on <space>d (Helix's <space>D). kak-lsp only
# offers them as the *diagnostics* buffer (its reply comes later, with the "
# register saved, so no RegisterModified). When that buffer gets its filetype, queue a command
# with `kak -p`: it runs once the reply has filled the buffer, hands the lines
# to fzf, and the picker returns to this buffer. <space>D (the plain list)
# drops a pending picker.
define-command picker-diagnostics -docstring 'pick a diagnostic of the open files' %{
    remove-hooks global picker-diagnostics
    hook -group picker-diagnostics global BufSetOption filetype=lsp-diagnostics %{
        nop %sh{ (
            printf 'evaluate-commands -client %s picker-diagnostics-show\n' "$kak_opt_picker_client" |
                kak -p "$kak_session"
        ) >/dev/null 2>&1 </dev/null & }
        remove-hooks global picker-diagnostics   # last: it ends this hook
    }
    set-option global picker_from %val{bufname}
    set-option global picker_client %val{client}   # (kak-lsp replies have none)
    lsp-diagnostics
}
define-command -hidden picker-diagnostics-show %{
    evaluate-commands -buffer *diagnostics* %{
        execute-keys '%'
        set-option global picker_list %sh{
            list=$(mktemp "${TMPDIR:-/tmp}/kak-diagnostics.XXXXXX")
            printf '%s\n' "$kak_selection" | sed 's/ -- Description: .*//' | grep . >"$list"
            printf %s "$list"
        }
        set-option global picker_root %opt{lsp_project_root}
    }
    picker-popup diagnostics %opt{picker_list} %opt{picker_root} %opt{picker_from}
}

# Every mapping that has a description (Helix's <space>? command palette); the
# chosen one's keys are typed into this tmux pane, so prompts and keys that
# wait for another key work as usual. The mappings are read once per session
# (`debug mappings` writes to the read-only *debug* buffer, which can't be
# cleaned up); :picker-palette-refresh reads them again.
define-command picker-palette -docstring 'pick a key mapping by its description' %{
    evaluate-commands %sh{ [ -s "$kak_opt_picker_palette" ] || echo picker-palette-refresh }
    picker-popup palette %opt{picker_palette} %val{client_env_TMUX_PANE}
}
define-command picker-palette-refresh -docstring 're-read the mappings for the palette' %{
    debug mappings
    evaluate-commands -buffer *debug* %{
        execute-keys 'ge<a-/>^Mappings:<ret>Ge'
        set-option global picker_palette %sh{
            list=${TMPDIR:-/tmp}/kak-palette-$kak_session
            printf '%s\n' "$kak_selection" >"$list"
            printf %s "$list"
        }
    }
}
hook global KakEnd .* %{ nop %sh{ rm -f "$kak_opt_picker_palette" } }

map global user f ':picker-files<ret>'   -docstring 'files'
map global user / ':picker-grep<ret>'    -docstring 'live grep'
map global user , ':picker-buffers<ret>' -docstring 'buffer picker'
map global user e ':yazi<ret>'           -docstring 'yazi file manager'
map global user E ':broot<ret>'          -docstring 'broot file tree'
map global user d ':picker-diagnostics<ret>' -docstring 'diagnostics picker'
map global user ? ':picker-palette<ret>' -docstring 'command palette (all keys)'
map global user <quote> ':picker-resume<ret>' -docstring 'last picker'

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

# ─── remember the cursor position ─────────────────────────────────────────────
# Reopening a file puts the cursor where it was. Positions are kept in
# ~/.local/state/kak/positions ("line col<tab>path", newest last), written on
# save and when the buffer is closed (Kakoune closes every buffer on quit).
# A line given explicitly (kak file +10, gd, grep and picker jumps) still wins:
# it is applied later.
declare-option -hidden str cursor_pos_last
declare-option -hidden str cursor_pos_restore
hook global NormalIdle .* %{ set-option buffer cursor_pos_last "%val{cursor_line} %val{cursor_column}" }
define-command -hidden cursor-pos-save %{ nop %sh{
    [ -f "$kak_buffile" ] && [ -n "$kak_opt_cursor_pos_last" ] || exit 0
    case $kak_buffile in */.git/*) exit 0 ;; esac
    f=${XDG_STATE_HOME:-$HOME/.local/state}/kak/positions
    mkdir -p "${f%/*}"
    printf '%s\t%s\n' "$kak_opt_cursor_pos_last" "$kak_buffile" >>"$f"
    # keep only the newest entry per file once the list grows
    if [ "$(wc -l <"$f")" -gt 2000 ]; then
        awk -F '\t' '{ last[$2] = NR; line[NR] = $0 } END { for (n = 1; n <= NR; n++) if (last[substr(line[n], index(line[n], "\t") + 1)] == n) print line[n] }' "$f" >"$f.tmp" &&
            mv "$f.tmp" "$f"
    fi
} }
hook global BufWritePost .* cursor-pos-save
hook global BufClose     .* cursor-pos-save
hook global BufOpenFile  .* %{ evaluate-commands %sh{
    f=${XDG_STATE_HOME:-$HOME/.local/state}/kak/positions
    [ -f "$f" ] || exit 0
    pos=$(awk -F '\t' -v p="$kak_buffile" '$2 == p { pos = $1 } END { print pos }' "$f")
    [ -n "$pos" ] && echo "set-option buffer cursor_pos_restore '$pos'"
} }
hook global WinDisplay .* %{
    evaluate-commands %sh{
        [ -n "$kak_opt_cursor_pos_restore" ] || exit 0
        set -- $kak_opt_cursor_pos_restore
        echo "set-option buffer cursor_pos_restore ''"
        echo "try %{ select $1.$2,$1.$2 } catch %{ execute-keys ge }"
        echo "execute-keys vc"
    }
}

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

# Uncommitted changes (staged and not) by default; any `git diff` arguments
# work too: :diffnav --cached, :diffnav main, :diffnav HEAD~3 -- src
define-command diffnav -params .. -docstring 'diffnav [<git diff args>]: browse a diff in a popup (default: git diff HEAD)' %{
    evaluate-commands %sh{
        [ $# -eq 0 ] && set -- HEAD
        git diff --quiet "$@" >/dev/null 2>&1
        case $? in
            0) echo "echo 'diffnav: no changes'"; exit ;;
            1) ;;
            *) echo "fail 'diffnav: git diff failed (not a repository, or a bad revision?)'"; exit ;;
        esac
        printf "popup sh -c 'git --no-pager diff \"\$@\" | diffnav' diffnav"
        for a; do printf " '%s'" "$(printf %s "$a" | sed "s/'/''/g")"; done
        echo
    }
}

# easifem build / test (same scripts as Helix's "+" mode)
# Builds run in the background (bin/easifem-build); Kakoune and macOS report
# the result, <space>+ l opens the log of the latest build and <space>+ e lists
# its compiler errors (bin/easifem-errors) in a *make*-style buffer.
define-command easifem-build -params 1 -docstring 'easifem-build <base|classes>: build and install in the background' %{
    nop %sh{ "$kak_config/bin/easifem-build" "$kak_session" "$kak_client" "$1" >/dev/null 2>&1 </dev/null & }
    echo -markup "{Information}easifem: building %arg{1} in the background"
}
define-command easifem-build-base    %{ easifem-build base }
define-command easifem-build-classes %{ easifem-build classes }
declare-option -hidden str easifem_log
define-command -hidden easifem-find-log -params ..1 %{
    evaluate-commands %sh{
        dir=${XDG_CACHE_HOME:-$HOME/.cache}/easifem
        if [ -n "$1" ]; then log=$dir/easifem-build-$1-log.txt
        else log=$(ls -t "$dir"/easifem-build-*-log.txt 2>/dev/null | head -n 1); fi
        [ -f "$log" ] || { echo "fail 'easifem: no build log yet'"; exit; }
        printf "set-option global easifem_log '%s'\n" "$log"
    }
}
define-command easifem-build-log -params ..1 -docstring 'easifem-build-log [base|classes]: open a build log (default: the latest)' %{
    easifem-find-log %arg{@}
    edit -existing %opt{easifem_log}
    set-option buffer autoreload yes
}
# <ret> on an error opens it (as in the *make* buffer of :make).
define-command easifem-build-errors -params ..1 -docstring 'easifem-build-errors [base|classes]: list the compiler errors of a build (default: the latest)' %{
    easifem-find-log %arg{@}
    evaluate-commands -save-regs '"' %sh{
        # paths under the working directory are shown relative to it
        errors=$("$kak_config/bin/easifem-errors" "$kak_opt_easifem_log" |
            awk -v p="$PWD/" 'index($0, p) == 1 { $0 = substr($0, length(p) + 1) } 1')
        if [ -z "$errors" ]; then
            if grep -q '^# finished: exit 0 ' "$kak_opt_easifem_log"; then
                echo "echo 'easifem: the last build had no errors'"
            else
                echo "fail 'easifem: no compiler errors found; <space>+ l opens the log'"
            fi
            exit
        fi
        n=$(printf '%s\n' "$errors" | wc -l | tr -d ' ')
        printf "set-register '\"' '"
        printf '%s\n' "$errors" | sed "s/'/''/g"
        echo "'"
        echo 'edit! -scratch *easifem-errors*'
        echo 'set-option buffer filetype make'
        echo 'set-option buffer jump_current_line 0'
        echo "execute-keys '%Rgg'"
        echo "echo 'easifem: $n error(s); <ret> opens one, <space>+ n / p the next / previous'"
    }
}
# Split every `use ..., only: a, b` into one import per line, with
# $easifem/config/scripts/split-use-only.fish: in the selected lines, or in the
# whole buffer when nothing is selected (only cursors). The text goes through
# the script's stdin mode (bin/split-use-filter), so unsaved edits count and one
# `u` undoes it; text is left as it was if the script fails. Its notes
# (statements it skipped) are shown.
declare-option -hidden str split_use_messages
declare-option -hidden int split_use_before
declare-option -hidden str split_use_where   # where the notes' line numbers count from
define-command split-use -docstring 'split USE ... ONLY lists into one import per line (selected lines, or the whole buffer)' %{
    evaluate-commands %sh{
        script=${easifem:-$HOME/Dropbox/easifem}/config/scripts/split-use-only.fish
        [ -f "$script" ] || echo "fail 'split-use: $script not found'"
    }
    set-option global split_use_messages %sh{ mktemp "${TMPDIR:-/tmp}/kak-split-use.XXXXXX" }
    set-option global split_use_before %val{timestamp}
    evaluate-commands -draft %{
        evaluate-commands %sh{
            for n in $kak_selections_length; do
                [ "$n" -gt 1 ] && {   # whole lines
                    echo "execute-keys x; set-option global split_use_where ' of the selection'"; exit
                }
            done
            echo "execute-keys '%'; set-option global split_use_where ''"
        }
        execute-keys "|%val{config}/bin/split-use-filter %opt{split_use_messages}<ret>"
    }
    evaluate-commands %sh{
        if [ "$kak_timestamp" = "$kak_opt_split_use_before" ]; then
            echo "echo 'split-use: nothing to split'"
        else
            echo "echo 'split-use: done (u undoes it)'"
        fi
        f=$kak_opt_split_use_messages
        [ -s "$f" ] && printf "info -title split-use '%s'\n" \
            "$(sed "s/^<stdin>:\([0-9]*\):/line \1$kak_opt_split_use_where:/; s/'/''/g" "$f")"
        rm -f "$f"
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
map global user G ':diffnav<ret>'      -docstring 'diffnav: uncommitted changes'
declare-user-mode easifem
map global user    + ':enter-user-mode easifem<ret>'   -docstring 'easifem build/test'
map global easifem b ':easifem-build-base<ret>'        -docstring 'build base'
map global easifem c ':easifem-build-classes<ret>'     -docstring 'build classes'
map global easifem l ':easifem-build-log<ret>'         -docstring 'open the latest build log'
map global easifem e ':easifem-build-errors<ret>'      -docstring 'list the errors of the latest build'
map global easifem n ':jump-next *easifem-errors*<ret>'     -docstring 'next build error'
map global easifem p ':jump-previous *easifem-errors*<ret>' -docstring 'previous build error'
map global easifem + ':easifem-run-test<ret>'          -docstring 'run test for this file'
map global easifem u ':split-use<ret>'                -docstring 'split USE ... ONLY lists, one import per line'

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

# The cursor turns green in insert mode, as in Helix (a terminal cursor shape
# can't be set from Kakoune, but the colour can).
hook global ModeChange .*:insert %{
    set-face window PrimaryCursor      PrimaryCursorInsert
    set-face window PrimaryCursorEol   PrimaryCursorInsert
    set-face window SecondaryCursor    SecondaryCursorInsert
    set-face window SecondaryCursorEol SecondaryCursorInsert
}
hook global ModeChange .*:insert:.* %{
    unset-face window PrimaryCursor
    unset-face window PrimaryCursorEol
    unset-face window SecondaryCursor
    unset-face window SecondaryCursorEol
}

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
# clears its marks. Files outside a repo (empty branch) and scratch buffers
# such as *debug* are skipped.
define-command -hidden git-refresh %{
    modeline-update-branch
    evaluate-commands %sh{ [ -n "$kak_opt_modeline_branch" ] && [ -f "$kak_buffile" ] && echo 'gitsigns-show' }
}
define-command -hidden gitsigns-update %{
    evaluate-commands %sh{ [ -n "$kak_opt_modeline_branch" ] && [ -f "$kak_buffile" ] && echo 'git update-diff' }
}
hook global BufWritePost .*                %{ gitsigns-update }
hook global ModeChange   pop:insert:normal %{ gitsigns-update }
hook global BufReload    .*                %{ gitsigns-update }
# The gutter column is as wide as its widest flag, so git's own column would
# appear (and shift the text) with the first change. So draw a copy of git's
# flags plus a blank flag on line 0, which is never drawn but keeps the column
# one wide; kak-lsp does the same for diagnostics. (A copy, because setting
# git_diff_flags from its own hook is a recursive hook call.)
declare-option -hidden line-specs gitsigns_flags
hook global BufSetOption git_diff_flags=.* %{
    set-option buffer gitsigns_flags %opt{git_diff_flags} '0| '
}
define-command -hidden gitsigns-show %{
    git show-diff
    try %{ remove-highlighter window/git-diff }
    try %{ add-highlighter window/gitsigns flag-lines Default gitsigns_flags }
}
define-command -hidden gitsigns-hide %{
    try %{ remove-highlighter window/gitsigns }
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
map global git  h ':gitsigns-hide<ret>'             -docstring 'hide the marks (<space>hg shows them)'
map global git  g ':gitsigns-show<ret>'             -docstring 'show the marks'
