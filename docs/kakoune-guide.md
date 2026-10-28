# Kakoune quick guide

A cheat sheet for this config, written for someone coming from Helix. Kakoune
and Helix share the same idea, **select first, then act**, but many keys differ.

In Kakoune itself: `:doc keys` lists every key, and pausing after `g`,
`<space>`, `[` or `<a-i>` shows a menu of what can follow.

## The core idea

Every command acts on the current selection(s). Moving the cursor *selects* the
text moved over; you then act on it (`d` delete, `c` change, `y` yank, ...).

- **lowercase** key: move and select
- **Shift** (uppercase) key: *extend* the current selection instead
- **Alt** key: usually the "other direction" or "inverse" of the plain key

## Modes

| Key | Action |
|---|---|
| `i` / `a` | insert before / append after the selection |
| `I` / `A` | insert at line start / append at line end |
| `o` / `O` | open a new line below / above |
| `<a-o>` / `<a-O>` | add an empty line below / above, stay in normal mode |
| `<esc>` | back to normal mode |
| `<a-;>` | (in insert mode) run one normal-mode command, then return |
| `:` | command prompt (`:w`, `:q`, `:e file`, ...) |

## Movement

| Key | Action |
|---|---|
| `h` `j` `k` `l` | left, down, up, right |
| `w` / `b` / `e` | next word start / previous word start / word end |
| `<a-w>` `<a-b>` `<a-e>` | same, by WORD (whitespace-separated) |
| `f<c>` / `t<c>` | select to / until the next `<c>` on the line |
| `<a-f><c>` / `<a-t><c>` | same, backwards |
| `gh` / `gl` / `gi` | line start / line end / first non-blank |
| `gg` / `ge` | file start / file end |
| `gt` / `gc` / `gb` | top / centre / bottom of the screen |
| `<number>g` | go to line `<number>` |
| `m` | select to the matching bracket |
| `<c-o>` / `<c-i>` | jump back / forward in the jump list |
| `<c-d>` / `<c-u>` | half page down / up |
| `vv` | centre the view on the cursor (`v` = view menu) |

Add Shift to extend instead: `W`, `J`, `L`, `F<c>`, `M`, `G`, etc.

## Selecting

| Key | Action |
|---|---|
| `x` | expand to full lines (pressing it again does **not** add the next line) |
| `x` then `J` / `K` | add lines below / above (`x5J` = this line plus 5) |
| `%` | whole file |
| `<a-i>` / `<a-a>` | inside / around an object, followed by: `w` word, `(` `[` `{` `<` brackets, `"` `'` quotes, `p` paragraph |
| `[` / `]` | to the start / end of an object (same object keys) |
| `;` | collapse each selection to its cursor |
| `<a-;>` | flip cursor and anchor |
| `*` | use the selection as the search pattern |
| `<a-u>` / `<a-U>` | undo / redo a selection change |

### Multiple selections (multi-cursor)

| Key | Action |
|---|---|
| `s` | inside the selection, select every regex match (`%s foo<ret>` = every `foo`) |
| `S` | split the selection on a regex |
| `<a-s>` | split into one selection per line |
| `C` / `<a-C>` | add a cursor on the line below / above |
| `<a-k>` / `<a-K>` | keep / drop selections matching a regex |
| `,` | keep only the main selection |
| `<a-,>` | drop the main selection |
| `)` / `(` | rotate which selection is the main one |
| `&` | align selections (insert spaces so they line up) |
| `_` | trim whitespace from each selection |
| `<a-_>` | merge touching selections |

In this config, `s`, `S`, `<a-k>`, `<a-K>` and the search prompts start with
`(?i)`, so matching **ignores case** (like Helix). Delete `(?i)` for exact case.

## Editing

| Key | Action |
|---|---|
| `d` / `c` | delete / change (delete and insert) the selection |
| `<a-d>` / `<a-c>` | same, without yanking (clipboard untouched) |
| `y` | yank (also copied to the macOS clipboard) |
| `p` / `P` | paste after / before |
| `R` | replace the selection with the yanked text |
| `r<c>` | replace every selected character with `<c>` |
| `u` / `U` | undo / redo |
| `.` | repeat the last insert (`i`, `a`, `c` and its text) |
| `<a-.>` | repeat the last `f`/`t` or object selection |
| `>` / `<` | indent / dedent |
| `<a-j>` | join lines |
| `~` / `` ` `` / ``<a-`>`` | upper case / lower case / swap case |
| `|` | pipe selections through a shell command (`|sort<ret>`) |
| `!` / `<a-!>` | insert command output before / after |
| `<space>p` / `<space>P` | paste from the macOS clipboard after / before |
| `<space>c` | comment / uncomment lines |

## Search

| Key | Action |
|---|---|
| `/` / `<a-/>` | search forward / backward |
| `n` / `<a-n>` | next / previous match |
| `N` | **add** the next match as another selection |
| `?` / `<a-?>` | extend the selection to the next / previous match |
| `<space>/` | live grep over the project (fzf) |

## Macros and registers

| Key | Action |
|---|---|
| `Q` | start / stop recording a macro |
| `q` | play it back |
| `"<r>` | use register `<r>` for the next yank / paste / macro (`"ay`, `"ap`) |
| `Z` / `z` | save / restore the selections |

## Files, buffers and pickers

| Key | Action |
|---|---|
| `<space>f` | find a file (fzf) |
| `<space>e` | yazi: pick a file, `<ret>` opens it in this session |
| `<space>,` | pick an open buffer |
| `gn` / `gp` / `ga` | next / previous / last buffer |
| `<space>b` | buffer menu: `q` close, `Q` close and discard, `o` close others, `w` / `W` write / write all |
| `:e <file>` | open a file (`<tab>` completes paths) |
| `gf` | open the file whose name is selected (select it first, e.g. with `<a-i><a-w>`) |
| `:w` / `:wa` | write / write all (formats and trims trailing spaces first) |
| `:q` / `:q!` | close this window / ... discarding changes |

## Code (LSP, tree-sitter)

| Key | Action |
|---|---|
| `gd` / `gr` / `gy` | definition / references / type definition |
| `<space>k` | hover documentation |
| `<space>a` | code actions |
| `<space>r` | rename |
| `<space>d` | diagnostics list |
| `<c-n>` / `<c-p>` | next / previous error or warning |
| `<space>s` / `<space>S` | document / workspace symbols |
| `<space>=` | format the buffer (also runs on every save) |
| `<space>l` | all LSP commands |
| `<space>t` | tree-sitter menu (`f` function, `a` parameter, `t` type, `c` comment) |
| `<a-up>` / `<a-down>` | select the parent / child syntax node |

### Completion and snippets

In insert mode the menu appears as you type:

- `<tab>` / `<s-tab>` (or `<c-n>` / `<c-p>`): move through the menu
- `<ret>`: accept the picked item (no newline); a snippet expands with its first
  placeholder selected
- `<tab>` with no menu open: jump to the next snippet placeholder; typing
  replaces the default, skipping keeps it

Snippets are the shared VSCode-style ones in `~/.config/nvim/snippets`.

## easifem

| Key | Action |
|---|---|
| `<space>+` `+` | run the current test file (`easifem run`) in a popup |
| `<space>+` `b` / `c` | build and install base / classes |
| `<space>g` | lazygit |

## Sessions

One session per project: all its windows share buffers, registers and a single
language server, so zfls indexes easifem once instead of once per window.

| Command | Action |
|---|---|
| `kak -s classes` | start a session named `classes` |
| `kak -c classes [file]` | open another window in that session |
| `:new` | open another window from inside Kakoune |
| `kak -l` | list running sessions |
| `:rename-session <name>` | name the current session |
| `kak -d -s <name>` | start a session in the background (no window) |
| `:q` | close this window (the session keeps running) |
| `:kill` | end the session (refuses if there are unsaved changes) |
| `:kill!` | end the session, discarding unsaved changes |
| `kak -clear` | remove leftovers of crashed sessions |

Close every session (fish), safely: unsaved sessions stay open.

```fish
for s in (kak -l); echo kill | kak -p $s; end
```

## Troubleshooting

- **Errors or LSP messages**: `:buffer *debug*`
- **No Fortran highlighting**: restart the tree-sitter server, then restart Kakoune:
  `kill (cat $TMPDIR/kak-tree-sitter/pid)`
- **No snippets**: start Kakoune from fish (it sets `SNIPPETS_PATH`), and check
  that `bin/scls-kak` exists (rebuild with `bin/build-scls-kak`)
- **Pickers do nothing**: Kakoune must run inside tmux
