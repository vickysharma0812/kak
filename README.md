# Kakoune config

My [Kakoune](https://kakoune.org) setup for Fortran development on
[easifem](https://github.com/easifem), kept in step with my
[Helix config](https://github.com/vickysharma0812/helix): same language servers,
formatters, tree-sitter grammar, theme and space-leader keys.

## Features

- **Tree-sitter highlighting** via [kak-tree-sitter](https://sr.ht/~hadronized/kak-tree-sitter/),
  with the latest upstream Fortran grammar and Helix's grammars and queries for TOML, Markdown, CMake, JSON, fish and YAML (code blocks
  in Markdown are highlighted in their own language, and YAML front matter as YAML).
- **Soft wrap** at word boundaries for every file type, as in Helix.
- **Indent guides**, a **green cursor in insert mode** and `gw` jump labels, as in Helix.
- **Cursor position remembered** per file between sessions.
- **Fortran filetype** with auto-indent (Kakoune ships none): `autoload/fortran.kak`.
- **Fortran text objects** from tree-sitter: procedures (`f`), modules and types
  (`t`), do loops (`l`), if / select (`I`) and blocks (`B`), with `<a-i>` / `<a-a>`.
- **LSP** via [kakoune-lsp](https://github.com/kakoune-lsp/kakoune-lsp), with the same
  servers as Helix, except that zfls itself runs gfortran, fortitude and fprettier
  for Fortran (Helix still uses efm-langserver and the fortitude server):

  | Language | Servers | Format on save |
  |---|---|---|
  | Fortran | zfls (with gfortran and fortitude), scls | fprettier (through zfls) |
  | CMake | neocmakelsp, scls | gersemi |
  | TOML | taplo, tombi | taplo |
  | Markdown | none | rumdl (`rumdl fmt`) |
  | LaTeX | texlab, digestif, scls | texlab (latexindent) |
  | BibTeX | texlab, scls | bibtex-tidy |

- **Snippets**: VSCode-style snippets from `$SNIPPETS_PATH`, shared with Helix and
  Neovim, served by a patched simple-completion-language-server (see below).
- **Pickers** in tmux popups: [television](https://github.com/alexpasmantier/television)
  (`tv`, the default) or fzf for files, grep, buffers, diagnostics and a
  command palette of every described key, plus yazi and broot; `<space>'`
  reopens the last one (with its query, for fzf). Pick the UI with
  `set-option global picker_tool fzf` (or `tv`).
- **Auto pairs** like Helix: brackets and quotes close themselves, the closing
  character is stepped over, and `<backspace>` deletes an empty pair.
- **Helix-like completion**: `<tab>`/`<s-tab>` or `<down>`/`<up>` move through the menu, `<ret>` accepts.
- **Git signs**: added / changed / deleted line marks (like gitsigns),
  using Kakoune's built-in `git` command.
- Gruvbox dark theme matching Helix's (Catppuccin Mocha kept as an alternative:
  `:colorscheme catppuccin-mocha`), drawn on the terminal's own background
  so Ghostty's `background-opacity` shows through, and a Helix-style modeline
  with the git branch.

## Keys

`<space>` is the leader, as in Helix.

| Key | Action | Key | Action |
|---|---|---|---|
| `<space>F` | files | `<space>/` | live grep |
| `<space>,` | buffer picker | `<space>e` / `<space>f` | yazi / broot |
| `<space>b` | buffer mode | `gn` / `gp` / `ga` | next / previous / last buffer |
| `<space>k` | hover | `<space>a` | code action |
| `<space>r` | rename | `<space>d` | diagnostics picker |
| `<space>s` / `<space>S` | goto symbol (prompt) / workspace symbols | `<c-n>` / `<c-p>` | next / previous diagnostic |
| `<space>d` / `<space>D` | diagnostics picker / list | `<space>?` / `<space>'` | command palette / last picker |
| `gd` / `gr` / `gy` | definition / references / type definition | `<space>l` | all LSP commands (`s` goto symbol, `S` symbol list) |
| `<space>=` | format | `<space>c` | comment lines |
| `<space>t` | tree-sitter menu | `<a-up>` / `<a-down>` | select parent / child node |
| `<space>g` / `<space>G` | lazygit / tuicr (pick commits to review; `:tuicr` takes tuicr arguments) | `<space>+` | easifem background build (`b`, `c`), its errors (`e`, `n`, `p`) and log (`l`), run test (`+`), split `use ..., only:` lists (`u`) |
| `<space>j` / `<space>J` | jjui / jjdiff (tuicr review of the working-copy change; `:jjdiff -r <revset>` for others) | `<space>w` | tmux panes: `h` `j` `k` `l` move, `v` / `s` split, `q` close; also `:vertical-split` and `:horizontal-split [file]` |
| `<space>p` / `<space>P` | paste from clipboard | `mm` | matching bracket |
| `gw` | jump to a word by its label | | |
| `ms` / `mr` / `md` | surround add / replace / delete | `mi` / `ma` | select inside / around |

In insert mode: `<tab>`/`<s-tab>` or `<down>`/`<up>` move through the completion menu, `<ret>` accepts
the picked item, and `<tab>` with no menu open jumps to the next snippet placeholder.

## Requirements

macOS with Homebrew or Arch Linux (Wayland: `wl-clipboard`, `notify-send`), run inside **tmux** (the pickers are tmux popups) and started
from **fish** (which sets `SNIPPETS_PATH`).

- Kakoune, plus `cargo install kak-lsp kak-tree-sitter ktsctl`
- The language servers and formatters in the table above
- `fd`, `ripgrep`, `fzf`, `bat`, `yazi`, `broot`, `lazygit`, `diffnav`, `jj`, `jjui`, `tuicr`, `perl`
- The Fortran grammar, built from upstream
  [tree-sitter-fortran](https://github.com/stadelmanma/tree-sitter-fortran) into `tree-sitter/`:
  ```sh
  git clone --depth 1 https://github.com/stadelmanma/tree-sitter-fortran tree-sitter/sources/fortran
  cd tree-sitter/sources/fortran
  cc -O2 -shared -fPIC -I src src/parser.c src/scanner.c -o ../../grammars/fortran.so
  ```
  Its queries are tracked in `tree-sitter/queries/fortran`.
- Helix with its grammars built (`hx --grammar build`): kak-tree-sitter reads the
  TOML, Markdown and CMake grammars and queries in `~/.config/helix/runtime`, and
  Markdown's inline grammar and the JSON, fish and YAML grammars from the system Helix runtime
  (`/usr/lib/helix/runtime` on Arch, `/opt/homebrew/opt/helix/libexec/runtime` with Homebrew).

## Install

```sh
git clone git@github.com:vickysharma0812/kak.git ~/.config/kak
~/.config/kak/bin/build-scls-kak   # builds bin/scls-kak (needs git and cargo)
```

`autoload/standard-library` links to Kakoune's system autoload directory:
`/usr/share/kak/autoload` on Arch (this branch), `/opt/homebrew/share/kak/autoload`
with Homebrew. Without it the user `autoload/` hides the standard library and
kakrc stops early. On Arch, `~/.cargo/bin` is put first when starting
kak-tree-sitter, so the patched build wins over the pacman package.

## Layout

| Path | What |
|---|---|
| `kakrc` | main config |
| `kak-tree-sitter.toml` | kak-tree-sitter config (Fortran from `tree-sitter/`; TOML, Markdown, CMake, JSON, fish and YAML grammars from Helix) |
| `tree-sitter/queries/fortran/` | Fortran queries (from Helix's, fixed for the upstream grammar) |
| `autoload/fortran.kak` | Fortran filetype and indentation |
| `colors/gruvbox.kak` | default theme (Helix's gruvbox), including tree-sitter faces |
| `colors/catppuccin-mocha.kak` | alternative theme, same faces |
| `bin/easifem-build` | background easifem build with log and notifications |
| `bin/split-use-filter` | runs easifem's `split-use-only.fish` on piped text, for `:split-use` |
| `bin/easifem-errors` | picks the gfortran errors out of a build log for `<space>+ e` |
| `bin/kak-jump-labels` | labels for `gw` (jump to a word on screen) |
| `bin/kak-picker` | tv or fzf (files, grep, buffers, diagnostics, palette), yazi and broot pickers in tmux popups |
| `broot/kak.hjson` | broot verb for the picker: `<ret>` on a file opens it in Kakoune |
| `bin/kak-snippet-flatten` | rewrites VSCode snippets into what kak-lsp can expand |
| `bin/build-scls-kak` | builds the patched scls into `bin/scls-kak` (not tracked) |
| `patches/scls-full-sync.patch` | the scls fix |
| `patches/kak-tree-sitter-text-objects.patch` | the kak-tree-sitter text-object fixes |
| `patches/kak-lsp-did-save.patch` | the kakoune-lsp didSave fix (efm diagnostics) |

## Notes

Step-by-step rebuild instructions for the patched tools are in
[docs/kakoune-guide.md](docs/kakoune-guide.md#patched-tools).

- **Patched scls.** Stock simple-completion-language-server ignores full-document
  `didChange` notifications, which is all kakoune-lsp sends, so it returns no
  snippets in Kakoune. `bin/build-scls-kak` builds a Kakoune-only copy with the fix;
  Helix keeps using the stock binary. Reported upstream as
  [estin/simple-completion-language-server#238](https://github.com/estin/simple-completion-language-server/issues/238).
- **Patched kak-tree-sitter.** Three text-object bugs in kak-tree-sitter 3.2.2 broke
  `<a-i>f` / `<a-a>f` and the loop / if / block objects on Fortran: a node ending
  at a line start became an invalid `line.0` position, a quantified capture such
  as `(_)+ @function.inside` kept only its first node, and a cursor on an
  object's first character (or in the indentation before it) did not count as
  inside it. `patches/kak-tree-sitter-text-objects.patch` fixes all three; apply
  it to the kak-tree-sitter source and `cargo install --path .`.
  Helix is unaffected (it does not use kak-tree-sitter).
- **Patched kakoune-lsp.** kakoune-lsp 22.0.0 sends `didSave` only to servers whose
  `textDocumentSync` lists a save option, so efm-langserver (which reports a bare
  sync kind and lints on save) never ran gfortran. `patches/kak-lsp-did-save.patch`
  sends it anyway, as Helix does; apply it to the kakoune-lsp source and
  `cargo install --path .`.
- **Snippet rewriting.** kakoune-lsp cannot expand nested placeholders, VSCode
  variables or regex transforms, so `bin/kak-snippet-flatten` flattens nesting,
  fills in date and file-name variables, and turns transforms into plain mirrors.
- **Code actions** are only requested on `<space>a`, as in Helix.
- **fortitude through zfls** takes its rules from `~/.config/fortitude/fortitude.toml`,
  which must keep `fix = false`: with fixes on, fortitude prints the fixed
  source instead of the diagnostics zfls reads.
