; see https://docs.helix-editor.com/themes.html
"end" @number
(identifier) @variable
(string_literal) @string
(number_literal) @constant.numeric
(boolean_literal) @variable.builtin
(comment) @comment

[
 (intrinsic_type)
 "allocatable"
 "attributes"
 "device"
 "dimension"
 "endtype"
 "global"
 "grid_global"
 "host"
 "import"
 "in"
 "inout"
 "intent"
 "optional"
 "out"
 "pointer"
 "type"
 "generic"
 "value"
 ] @type

[
 "contains"
 "private"
 "public"
 ] @variable.builtin

[
 (none)
 "implicit"
 ] @attribute

[
 "endfunction"
 "endprogram"
 "endsubroutine"
 "function"
 "procedure"
 "subroutine"
 ] @keyword

[
 (default)
 (procedure_qualifier)
 "abstract"
 "bind"
 "call"
 "class"
 "continue"
 "cycle"
 "endenum"
 "endinterface"
 "endmodule"
 "endprocedure"
 "endprogram"
 "endsubmodule"
 "enum"
 "enumerator"
 "equivalence"
 "exit"
 "extends"
 "format"
 "goto"
 "include"
 "interface"
 "intrinsic"
 "non_intrinsic"
 "module"
 "namelist"
 "only"
 "parameter"
 "print"
 "procedure"
 "program"
 "read"
 "stop"
 "submodule"
 "use"
 "write"
 ] @keyword


"return" @keyword.control.return

[
 "else"
 "elseif"
 "elsewhere"
 "endif"
 "endwhere"
 "if"
 "then"
 "where"
 "select"
 "case"

 ] @keyword.control.conditional

[
 "do"
 "enddo"
 "forall"
 "while"
 ] @keyword.control.repeat

[
 "*"
 "+"
 "-"
 "/"
 "="
 "<"
 ">"
 "<="
 ">="
 "=="
 "/="
 ] @operator

[
 ".and."
 ".or."
 ".lt."
 ".gt."
 ".ge."
 ".le."
 ".eq."
 ".eqv."
 ".neqv."
 ".ne."
 ".not."
 ] @keyword.operator

;; Brackets
[
 "("
 ")"
 "["
 "]"
 "<<<"
 ">>>"
 ] @punctuation.bracket

;; Delimiter
[
 "::"
 ","
 "%"
 ] @punctuation.delimiter

(parameters
  (identifier) @variable.parameter)

(program_statement
  (name) @namespace)

(module_statement
  (name) @namespace)

(submodule_statement
  (module_name) @variable (name) @namespace)

(function_statement
  (name) @function)

(subroutine_statement
  (name) @function)

(module_procedure_statement
  (name) @function)

(interface_statement
  (name) @variable)

(end_program_statement
  (name) @namespace)

(end_module_statement
  (name) @namespace)

(end_submodule_statement
  (name) @namespace)

(end_function_statement
  (name) @function)

(end_subroutine_statement
  (name) @function)

(end_module_procedure_statement
  (name) @function)

(end_interface_statement
  (name) @variable)

(derived_type_statement
  (type_name) @namespace)

(end_type_statement
  (name) @namespace)

(subroutine_call
  (identifier) @function)

(keyword_argument
  name: (identifier) @keyword)

(derived_type_member_expression
  (type_member) @function)

(call_expression
  (identifier) @function.call)

(module_procedure_statement) @keyword
(end_module_procedure_statement) @keyword

(submodule_statement) @keyword
(end_submodule_statement) @keyword

(function_statement) @keyword
(end_function_statement) @keyword

(subroutine_statement) @keyword
(end_subroutine_statement) @keyword

(module_statement) @keyword
(end_module_statement) @keyword

(program_statement) @keyword
(end_program_statement) @keyword

(end_type_statement) @type

(interface_statement) @keyword
(end_interface_statement) @keyword

(end_do_loop_statement) @keyword.control.repeat
(end_if_statement) @keyword.control.conditional
(end_select_statement) @keyword.control.conditional
