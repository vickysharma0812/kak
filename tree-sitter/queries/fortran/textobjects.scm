
; class objects

((program
  (program_statement)
  .
  (_)+ @class.inside
  .
  (end_program_statement))) @class.around

((module
  (module_statement)
  .
  (_)+ @class.inside
  .
  (end_module_statement))) @class.around


((submodule
  (submodule_statement)
  .
  (_)+ @class.inside
  .
  (end_submodule_statement))) @class.around

((derived_type_definition
  (derived_type_statement)
 .
  (_)+ @class.inside
  . 
  [
  (derived_type_procedures)
  (end_type_statement)
  ])) @class.around
  
((derived_type_procedures
  (contains_statement)
  .
  (_)+ @class.inside
  . 
  )) 
  
((interface
  (interface_statement)
  .
  (_)+ @class.inside
  . 
  (end_interface_statement))) @class.around

; function objects

((module_procedure
   (module_procedure_statement)
   .
   (_)+ @function.inside
   .
   (end_module_procedure_statement))) @function.around

((function
   (function_statement)
   .
   (_)+ @function.inside
   .
   (end_function_statement))) @function.around

((subroutine
   (subroutine_statement)
   .
   (_)+ @function.inside
   .
   (end_subroutine_statement))) @function.around

; Construct objects. KTS takes any capture name; kakrc maps them to object
; mode (mi / ma, <a-i> / <a-a>) and to the <space>t search menus:
;   d  loop         do, do while, do concurrent
;   k  block        block, associate
;   e  conditional  if / else if / else, select case, select type
; "inside" is the body (without the opening and closing statements); in an
; if or select it is the body of the branch the cursor is in. "around" is the
; whole construct, label included. A quantified (_)+ capture spans all its
; nodes (patches/kak-tree-sitter-text-objects.patch).

; loop objects

(do_loop) @loop.around

((do_loop
  (do_statement)
  .
  (_)+ @loop.inside
  .
  (end_do_loop_statement)))

; block objects

(block_construct) @block.around

; `block` is an anonymous token, so the first named child is the label or the
; body. With a label, the second pattern also matches but its span is wider;
; KTS picks the narrowest one around the cursor.
((block_construct
  (block_label_start_expression)
  .
  (_)+ @block.inside
  .
  (end_block_construct_statement)))

((block_construct
  .
  (_)+ @block.inside
  .
  (end_block_construct_statement)))

(associate_statement) @block.around

((associate_statement
  (association_list)
  .
  (_)+ @block.inside
  .
  (end_associate_statement)))

; conditional objects

(if_statement) @conditional.around

; The if body runs from the first node after the condition to the node just
; before the first else-if / else / end if. A quantified (_)+ would be greedy
; and run on over the clauses, so the first and last body nodes are captured
; separately (KTS spans all the nodes of a capture in a match), and the last
; one may not be a clause: nodes that start with "else" / "else if" are refused.
((if_statement
  (parenthesized_expression)
  .
  (_) @conditional.inside
  (_) @conditional.inside
  .
  [
    (elseif_clause)
    (else_clause)
    (end_if_statement)
  ])
  (#not-match? @conditional.inside "^[Ee][Ll][Ss][Ee]([^A-Za-z0-9_]|[Ii][Ff][^A-Za-z0-9_])"))

((if_statement
  (parenthesized_expression)
  .
  (_) @conditional.inside
  .
  [
    (elseif_clause)
    (else_clause)
    (end_if_statement)
  ])
  (#not-match? @conditional.inside "^[Ee][Ll][Ss][Ee]([^A-Za-z0-9_]|[Ii][Ff][^A-Za-z0-9_])"))

((elseif_clause
  (parenthesized_expression)
  .
  (_)+ @conditional.inside
  .))

((else_clause
  .
  (_)+ @conditional.inside
  .))

(select_case_statement) @conditional.around

((case_statement
  (_)
  .
  (_)+ @conditional.inside
  .))

(select_type_statement) @conditional.around

((type_statement
  (_)
  .
  (_)+ @conditional.inside
  .))

; comment objects

(comment) @comment.inside @comment.around

; parameter objects 

((parameters 
   (_)+ @parameter.inside
   )) @parameter.around

