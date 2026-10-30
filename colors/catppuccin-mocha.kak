# Catppuccin Mocha, with faces for kak-tree-sitter (ts_*) and kak-lsp.

evaluate-commands %sh{
    rosewater="rgb:f5e0dc"; flamingo="rgb:f2cdcd"; pink="rgb:f5c2e7"
    mauve="rgb:cba6f7";     red="rgb:f38ba8";      maroon="rgb:eba0ac"
    peach="rgb:fab387";     yellow="rgb:f9e2af";   green="rgb:a6e3a1"
    teal="rgb:94e2d5";      sky="rgb:89dceb";      sapphire="rgb:74c7ec"
    blue="rgb:89b4fa";      lavender="rgb:b4befe"; text="rgb:cdd6f4"
    subtext0="rgb:a6adc8";  overlay2="rgb:9399b2"; overlay1="rgb:7f849c"
    overlay0="rgb:6c7086";  surface2="rgb:585b70"; surface1="rgb:45475a"
    surface0="rgb:313244";  base="rgb:1e1e2e";     mantle="rgb:181825"
    crust="rgb:11111b"
    # Editor background: the terminal's own (Catppuccin base in Ghostty), so
    # Ghostty's background-opacity shows through. Set to ${base} for opaque.
    bg=default

    cat <<EOF
    # code (regex highlighters, used where tree-sitter is not active)
    set-face global value              ${peach}
    set-face global type               ${yellow}
    set-face global variable           ${text}
    set-face global module             ${lavender}
    set-face global function           ${blue}
    set-face global string             ${green}
    set-face global keyword            ${mauve}
    set-face global operator           ${sky}
    set-face global attribute          ${yellow}
    set-face global comment            ${overlay0}+i
    set-face global documentation      comment
    set-face global meta               ${pink}
    set-face global builtin            ${red}

    # markup
    set-face global title              ${blue}+b
    set-face global header             ${mauve}
    set-face global mono               ${green}
    set-face global block              ${teal}
    set-face global link               ${rosewater}+u
    set-face global bullet             ${peach}
    set-face global list               ${text}

    # interface
    set-face global Default            ${text},${bg}
    set-face global PrimarySelection   default,${surface2}+g
    set-face global SecondarySelection default,${surface1}+g
    set-face global PrimaryCursor      ${crust},${rosewater}+fg
    set-face global SecondaryCursor    ${crust},${overlay2}+fg
    set-face global PrimaryCursorEol   ${crust},${sapphire}+fg
    set-face global SecondaryCursorEol ${crust},${overlay2}+fg
    # insert mode (kakrc swaps these in), as Helix's cursor.primary.insert
    set-face global PrimaryCursorInsert   ${crust},${green}+fg
    set-face global SecondaryCursorInsert ${crust},rgb:7ea87f+fg
    set-face global LineNumbers        ${surface1},${bg}
    set-face global LineNumberCursor   ${lavender},${bg}+b
    set-face global LineNumbersWrapped ${surface0},${bg}
    set-face global MenuForeground     ${crust},${lavender}+b
    set-face global MenuBackground     ${subtext0},${mantle}
    set-face global MenuInfo           ${overlay0},${mantle}
    set-face global Information        ${text},${mantle}
    set-face global InlineInformation  ${overlay2},${bg}
    set-face global Error              ${red},${bg}+b
    set-face global DiagnosticError    ${red}
    set-face global DiagnosticWarning  ${yellow}
    set-face global StatusLine         ${text},${surface0}
    set-face global StatusLineMode     ${crust},${peach}+b
    set-face global StatusLineInfo     ${blue},${surface0}+b
    set-face global StatusLineValue    ${peach},${surface0}
    set-face global StatusCursor       ${crust},${rosewater}
    set-face global Prompt             ${crust},${mauve}+b
    # modeline mode badge (switched by ModeChange hooks in kakrc)
    set-face global ModeNormal         ${crust},${blue}+b
    set-face global ModeInsert         ${crust},${green}+b
    set-face global ModePrompt         ${crust},${mauve}+b
    set-face global ModelineMode       ModeNormal
    set-face global ModelineDim        ${overlay1},${surface0}
    set-face global ModelineBranch     ${mauve},${surface0}
    set-face global JumpLabel          ${red}+b
    set-face global ModelineError      ${red},${surface0}
    set-face global ModelineWarning    ${yellow},${surface0}
    set-face global MatchingChar       ${peach},${surface1}+b
    set-face global BufferPadding      ${surface0},${bg}
    set-face global Whitespace         ${surface1}+f
    set-face global WrapMarker         Whitespace
    set-face global WhitespaceIndent   ${surface0}

    # kak-lsp
    set-face global InlayHint                ${overlay0}+i
    set-face global InlayDiagnosticError     ${red}+i
    set-face global InlayDiagnosticWarning   ${yellow}+i
    set-face global InlayDiagnosticInfo      ${sky}+i
    set-face global InlayDiagnosticHint      ${teal}+i
    set-face global LineFlagError            ${red}
    set-face global LineFlagWarning          ${yellow}
    set-face global LineFlagInfo             ${sky}
    set-face global LineFlagHint             ${teal}
    set-face global DiagnosticInfo           ${sky}
    set-face global DiagnosticHint           ${teal}
    set-face global DiagnosticTagUnnecessary +d
    set-face global DiagnosticTagDeprecated  +s
    set-face global Reference                default,${surface1}
    set-face global ReferenceBind            default,${surface1}+u
    set-face global SnippetsNextPlaceholders default,${surface0}
    set-face global SnippetsOtherPlaceholders default,${surface0}

    # kak-tree-sitter: exactly the scopes Helix's catppuccin_mocha sets.
    # Unset children fall back to their parent (ts_keyword_control_repeat ->
    # ts_keyword), and captures with no listed group stay unstyled, as in Helix.
    set-face global ts_attribute                 ${yellow}
    set-face global ts_type                      ${yellow}
    set-face global ts_type_enum_variant         ${teal}
    set-face global ts_constructor               ${sapphire}
    set-face global ts_constant                  ${peach}
    set-face global ts_constant_character        ${teal}
    set-face global ts_constant_character_escape ${pink}
    set-face global ts_string                    ${green}
    set-face global ts_string_regexp             ${pink}
    set-face global ts_string_special            ${blue}
    set-face global ts_string_special_symbol     ${red}
    set-face global ts_comment                   ${overlay2}+i
    set-face global ts_variable                  ${text}
    set-face global ts_variable_parameter        ${maroon}+i
    set-face global ts_variable_builtin          ${red}
    set-face global ts_variable_other_member     ${blue}
    set-face global ts_label                     ${sapphire}
    set-face global ts_punctuation               ${overlay2}
    set-face global ts_punctuation_special       ${sky}
    set-face global ts_keyword                   ${mauve}
    set-face global ts_keyword_control_conditional ${mauve}+i
    set-face global ts_operator                  ${sky}
    set-face global ts_function                  ${blue}
    set-face global ts_function_macro            ${mauve}
    set-face global ts_tag                       ${blue}
    set-face global ts_namespace                 ${yellow}+i
    set-face global ts_special                   ${blue}
    set-face global ts_markup_heading_1          ${red}
    set-face global ts_markup_heading_2          ${peach}
    set-face global ts_markup_heading_3          ${yellow}
    set-face global ts_markup_heading_4          ${green}
    set-face global ts_markup_heading_5          ${sapphire}
    set-face global ts_markup_heading_6          ${lavender}
    set-face global ts_markup_list               ${teal}
    set-face global ts_markup_list_unchecked     ${overlay2}
    set-face global ts_markup_list_checked       ${green}
    set-face global ts_markup_bold               ${red}+b
    set-face global ts_markup_italic             ${red}+i
    set-face global ts_markup_link_url           ${blue}+iu
    set-face global ts_markup_link_text          ${lavender}
    set-face global ts_markup_link_label         ${sapphire}
    set-face global ts_markup_raw                ${green}
    set-face global ts_markup_quote              ${pink}
EOF
}
