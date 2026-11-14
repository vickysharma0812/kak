;; Generated: Helix's c/injections.scm followed by cpp/injections.scm (Helix's
;; "; inherits: c"). Rebuild with the loop in kak-tree-sitter.toml.

((comment) @injection.content
 (#set! injection.language "comment"))

(raw_string_literal
  delimiter: (raw_string_delimiter) @injection.language
  (raw_string_content) @injection.content)
