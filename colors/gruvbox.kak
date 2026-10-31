# Gruvbox dark (standard contrast), matching Helix's `gruvbox` theme, with
# faces for kak-tree-sitter (ts_*) and kak-lsp. Same face set as
# catppuccin-mocha.kak, so either can be picked with :colorscheme.

evaluate-commands %sh{
    bg0="rgb:282828";  bg0_s="rgb:32302f"; bg1="rgb:3c3836"; bg2="rgb:504945"
    bg3="rgb:665c54";  bg4="rgb:7c6f64"
    fg0="rgb:fbf1c7";  fg1="rgb:ebdbb2";   fg2="rgb:d5c4a1"; fg3="rgb:bdae93"
    fg4="rgb:a89984";  gray="rgb:928374"
    red0="rgb:cc241d";    red1="rgb:fb4934"
    green0="rgb:98971a";  green1="rgb:b8bb26"
    yellow0="rgb:d79921"; yellow1="rgb:fabd2f"
    blue0="rgb:458588";   blue1="rgb:83a598"
    purple0="rgb:b16286"; purple1="rgb:d3869b"
    aqua0="rgb:689d6a";   aqua1="rgb:8ec07c"
    orange0="rgb:d65d0e"; orange1="rgb:fe8019"
    # Editor background: the terminal's own (gruvbox-dark in Ghostty), so
    # Ghostty's background-opacity shows through. Set to ${bg0} for opaque.
    bg=default

    cat <<EOF
    # code (regex highlighters, used where tree-sitter is not active)
    set-face global value              ${purple1}
    set-face global type               ${yellow1}
    set-face global variable           ${fg1}
    set-face global module             ${aqua1}
    set-face global function           ${green1}
    set-face global string             ${green1}
    set-face global keyword            ${red1}
    set-face global operator           ${purple1}
    set-face global attribute          ${aqua1}+i
    set-face global comment            ${gray}+i
    set-face global documentation      comment
    set-face global meta               ${aqua1}
    set-face global builtin            ${yellow1}

    # markup
    set-face global title              ${aqua1}+b
    set-face global header             ${aqua1}
    set-face global mono               ${red1}
    set-face global block              ${red1}
    set-face global link               ${green1}+u
    set-face global bullet             ${orange1}
    set-face global list               ${fg1}

    # interface
    set-face global Default            ${fg1},${bg}
    set-face global PrimarySelection   default,${bg3}+g
    set-face global SecondarySelection default,${bg2}+g
    set-face global PrimaryCursor      ${bg1},${fg3}+fg
    set-face global SecondaryCursor    ${bg1},${gray}+fg
    set-face global PrimaryCursorEol   ${bg1},${fg4}+fg
    set-face global SecondaryCursorEol ${bg1},${bg4}+fg
    # insert mode (kakrc swaps these in), as Helix's cursor.primary.insert
    set-face global PrimaryCursorInsert   ${bg1},${blue1}+fg
    set-face global SecondaryCursorInsert ${bg1},${blue0}+fg
    set-face global LineNumbers        ${bg3},${bg}
    set-face global LineNumberCursor   ${yellow1},${bg}+b
    set-face global LineNumbersWrapped ${bg2},${bg}
    set-face global MenuForeground     ${bg2},${blue1}+b
    set-face global MenuBackground     ${fg1},${bg2}
    set-face global MenuInfo           ${fg4},${bg2}
    set-face global Information        ${fg1},${bg1}
    set-face global InlineInformation  ${gray},${bg}
    set-face global Error              ${red1},${bg}+b
    set-face global DiagnosticError    ${red1}
    set-face global DiagnosticWarning  ${yellow1}
    set-face global StatusLine         ${fg1},${bg2}
    set-face global StatusLineMode     ${bg1},${orange1}+b
    set-face global StatusLineInfo     ${blue1},${bg2}+b
    set-face global StatusLineValue    ${orange1},${bg2}
    set-face global StatusCursor       ${bg1},${fg3}
    set-face global Prompt             ${bg1},${orange1}+b
    # modeline mode badge (switched by ModeChange hooks in kakrc)
    set-face global ModeNormal         ${bg1},${fg3}+b
    set-face global ModeInsert         ${bg1},${blue1}+b
    set-face global ModePrompt         ${bg1},${orange1}+b
    set-face global ModelineMode       ModeNormal
    set-face global ModelineDim        ${fg4},${bg2}
    set-face global ModelineBranch     ${purple1},${bg2}
    set-face global JumpLabel          ${purple0}+b
    set-face global ModelineError      ${red1},${bg2}
    set-face global ModelineWarning    ${yellow1},${bg2}
    set-face global MatchingChar       ${fg3},${bg3}+b
    set-face global BufferPadding      ${bg2},${bg}
    set-face global Whitespace         ${bg2}+f
    set-face global WrapMarker         Whitespace
    set-face global WhitespaceIndent   ${bg1}

    # kak-lsp
    set-face global InlayHint                ${gray}+i
    set-face global InlayDiagnosticError     ${red1}+i
    set-face global InlayDiagnosticWarning   ${yellow1}+i
    set-face global InlayDiagnosticInfo      ${aqua1}+i
    set-face global InlayDiagnosticHint      ${blue1}+i
    set-face global LineFlagError            ${red1}
    set-face global LineFlagWarning          ${yellow1}
    set-face global LineFlagInfo             ${aqua1}
    set-face global LineFlagHint             ${blue1}
    set-face global DiagnosticInfo           ${aqua1}
    set-face global DiagnosticHint           ${blue1}
    set-face global DiagnosticTagUnnecessary +d
    set-face global DiagnosticTagDeprecated  +s
    set-face global Reference                default,${bg2}
    set-face global ReferenceBind            default,${bg2}+u
    set-face global SnippetsNextPlaceholders default,${bg1}
    set-face global SnippetsOtherPlaceholders default,${bg1}

    # kak-tree-sitter: the scopes Helix's gruvbox sets. Unset children fall
    # back to their parent (ts_keyword_control_repeat -> ts_keyword).
    set-face global ts_attribute                 ${aqua1}+i
    set-face global ts_comment                   ${gray}+i
    set-face global ts_constant                  ${purple1}
    set-face global ts_constant_character        ${aqua1}
    set-face global ts_constant_character_escape ${orange1}
    set-face global ts_constant_macro            ${aqua1}
    set-face global ts_constructor               ${purple1}
    set-face global ts_function                  ${green1}
    set-face global ts_function_builtin          ${yellow1}
    set-face global ts_function_macro            ${blue1}
    set-face global ts_keyword                   ${red1}
    set-face global ts_keyword_control_import    ${aqua1}
    set-face global ts_label                     ${red1}
    set-face global ts_module                    ${aqua1}
    set-face global ts_namespace                 ${fg1}
    set-face global ts_operator                  ${purple1}
    set-face global ts_punctuation               ${orange1}
    set-face global ts_special                   ${purple0}
    set-face global ts_string                    ${green1}
    set-face global ts_string_regexp             ${orange1}
    set-face global ts_string_special            ${orange1}
    set-face global ts_string_special_symbol     ${yellow1}
    set-face global ts_tag                       ${aqua1}
    set-face global ts_type                      ${yellow1}
    set-face global ts_type_enum_variant         +i
    set-face global ts_variable                  ${fg1}
    set-face global ts_variable_builtin          ${orange1}+i
    set-face global ts_variable_other_member     ${blue1}
    set-face global ts_variable_parameter        ${blue1}+i
    set-face global ts_markup_heading            ${aqua1}
    set-face global ts_markup_bold               +b
    set-face global ts_markup_italic             +i
    set-face global ts_markup_strikethrough      +s
    set-face global ts_markup_link_text          ${red1}
    set-face global ts_markup_link_url           ${green1}+u
    set-face global ts_markup_raw                ${red1}
EOF
}
