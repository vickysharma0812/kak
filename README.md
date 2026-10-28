# Kakoune config

My [Kakoune](https://kakoune.org) setup for Fortran development on
[easifem](https://github.com/easifem), kept in step with my
[Helix config](https://github.com/vickysharma0812/helix): same language servers,
formatters, tree-sitter grammar, theme and space-leader keys.

## Features

- **Tree-sitter highlighting** via [kak-tree-sitter](https://sr.ht/~hadronized/kak-tree-sitter/),
  reusing the Fortran grammar and queries that Helix builds.
- **Fortran filetype** with auto-indent (Kakoune ships none): `autoload/fortran.kak`.
- **LSP** via [kakoune-lsp](https://github.com/kakoune-lsp/kakoune-lsp), with the same
  servers as Helix:

  | Language | Servers | Format on save |
  |---|---|---|
  | Fortran | zfls, fortitude, efm-langserver (gfortran), scls | fprettier |
  | CMake | neocmakelsp, scls | gersemi |
  | TOML | taplo, tombi | taplo |
  | Markdown | marksman, rumdl, scls | rumdl |
  | LaTeX | texlab, digestif, scls | texlab (latexindent) |
  | BibTeX | texlab, scls | bibtex-tidy |

- **Snippets**: VSCode-style snippets from `$SNIPPETS_PATH`, shared with Helix and
  Neovim, served by a patched simple-completion-language-server (see below).
- **Pickers** in tmux popups: fzf for files, live grep and buffers, plus yazi.
- **Helix-like completion**: `<tab>`/`<s-tab>` or `<down>`/`<up>` move through the menu, `<ret>` accepts.
- Catppuccin Mocha theme matching Helix's, and a Helix-style modeline.

## Keys

`<space>` is the leader, as in Helix.

| Key | Action | Key | Action |
|---|---|---|---|
| `<space>f` | files | `<space>/` | live grep |
| `<space>,` | buffer picker | `<space>e` | yazi |
| `<space>b` | buffer mode | `gn` / `gp` / `ga` | next / previous / last buffer |
| `<space>k` | hover | `<space>a` | code action |
| `<space>r` | rename | `<space>d` | diagnostics |
| `<space>s` / `<space>S` | document / workspace symbols | `<c-n>` / `<c-p>` | next / previous diagnostic |
| `gd` / `gr` / `gy` | definition / references / type definition | `<space>l` | all LSP commands |
| `<space>=` | format | `<space>c` | comment lines |
| `<space>t` | tree-sitter menu | `<a-up>` / `<a-down>` | select parent / child node |
| `<space>g` | lazygit | `<space>+` | easifem build (`b`, `c`) and run test (`+`) |
| `<space>p` / `<space>P` | paste from clipboard | | |

In insert mode: `<tab>`/`<s-tab>` or `<down>`/`<up>` move through the completion menu, `<ret>` accepts
the picked item, and `<tab>` with no menu open jumps to the next snippet placeholder.

## Requirements

macOS with Homebrew, run inside **tmux** (the pickers are tmux popups) and started
from **fish** (which sets `SNIPPETS_PATH`).

- Kakoune, plus `cargo install kak-lsp kak-tree-sitter ktsctl`
- The language servers and formatters in the table above
- `fd`, `ripgrep`, `fzf`, `bat`, `yazi`, `lazygit`, `perl`
- Helix with its Fortran grammar built (`hx --grammar build`): kak-tree-sitter reads
  `~/.config/helix/runtime/grammars/fortran.so` and the queries next to it.

## Install

```sh
git clone git@github.com:vickysharma0812/kak.git ~/.config/kak
~/.config/kak/bin/build-scls-kak   # builds bin/scls-kak (needs git and cargo)
```

`autoload/standard-library` links to Homebrew's `/opt/homebrew/share/kak/autoload`;
adjust it if Kakoune is installed elsewhere.

## Layout

| Path | What |
|---|---|
| `kakrc` | main config |
| `kak-tree-sitter.toml` | kak-tree-sitter config (Fortran grammar from Helix) |
| `autoload/fortran.kak` | Fortran filetype and indentation |
| `colors/catppuccin-mocha.kak` | theme, including tree-sitter faces |
| `bin/kak-picker` | fzf and yazi pickers in tmux popups |
| `bin/kak-snippet-flatten` | rewrites VSCode snippets into what kak-lsp can expand |
| `bin/build-scls-kak` | builds the patched scls into `bin/scls-kak` (not tracked) |
| `patches/scls-full-sync.patch` | the scls fix |
| `patches/kak-tree-sitter-text-objects.patch` | the kak-tree-sitter text-object fixes |

## Notes

- **Patched scls.** Stock simple-completion-language-server ignores full-document
  `didChange` notifications, which is all kakoune-lsp sends, so it returns no
  snippets in Kakoune. `bin/build-scls-kak` builds a Kakoune-only copy with the fix;
  Helix keeps using the stock binary. Reported upstream as
  [estin/simple-completion-language-server#238](https://github.com/estin/simple-completion-language-server/issues/238).
- **Patched kak-tree-sitter.** Two text-object bugs in kak-tree-sitter 3.2.2 broke
  `<a-i>f` / `<a-a>f` on Fortran procedures: a node ending at a line start became
  an invalid `line.0` position, and a quantified capture such as
  `(_)+ @function.inside` kept only its first node. `patches/kak-tree-sitter-text-objects.patch`
  fixes both; apply it to the kak-tree-sitter source and `cargo install --path .`.
  Helix is unaffected (it does not use kak-tree-sitter).
- **Snippet rewriting.** kakoune-lsp cannot expand nested placeholders, VSCode
  variables or regex transforms, so `bin/kak-snippet-flatten` flattens nesting,
  fills in date and file-name variables, and turns transforms into plain mirrors.
- **Code actions** are only requested on `<space>a`, as in Helix; polling them on
  every idle made fortitude report errors.
