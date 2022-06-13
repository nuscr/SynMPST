%{

open Syntax
open Syntax.Ext

%}

(* ---------------------------------------- *)

%token <string>IDENT
%token <int>INT

%token EOI

%token COMMA
%token SEMICOLON
%token LPAR
%token RPAR
%token LCURLY
%token RCURLY

(* keywords from Scribble.g with original comments *)
%token PROTOCOL_KW
%token GLOBAL_KW
%token ROLE_KW

%token FROM_KW
%token TO_KW
%token OR_KW
%token CHOICE_KW
%token REC_KW
%token CONTINUE_KW

(* pragmas *)
/* %token PRAGMA_START */
/* %token PRAGMA_END */

(* ---------------------------------------- *)
%start < compilation_unit > cu

%%

/* let pragma_value := */
/*   | COLON ; v = IDENT ; { v } */

/* let pragma_decl := */
/*   | k = IDENT ; v = pragma_value? ; { Pragma.pragma_of_string k , v } */

/* (* pragmas *) */
/* let pragmas := */
/*   | PRAGMA_START; ps = separated_list(COMMA, pragma_decl) ; PRAGMA_END ; { ps } */

(* A file is parsed into a compilation unit *)
let cu :=
  /* pgs = pragmas? ; (* Pragma must be at the beginning of a file *) */
  ps = global_protocol_decl* ;
  EOI ;
    {
      ps
    }


(* protocols *)

let global_protocol_decl ==
  protocol_hdr ; nm = name ;
  rs = role_decls ;
  body = global_protocol_body ;
  {
    Protocol { name = nm
             ; roles = rs
             ; interactions = body
             }
  }


let protocol_hdr ==
  GLOBAL_KW ; PROTOCOL_KW? ; { () }
  | PROTOCOL_KW ; { () }

let role_decls == LPAR ; nms = separated_nonempty_list(COMMA, role_decl) ;
                  RPAR ; { nms }

let role_decl == ROLE_KW ; nm = name ; { nm }

let global_protocol_body ==
  LCURLY ; ints = global_interaction* ;
  RCURLY ; { ints }

let global_protocol_block ==
  LCURLY ; ints = global_interaction* ; RCURLY ; { ints }

let global_interaction ==
  global_message_transfer
  | global_recursion
  | global_continue
  | global_choice

let global_choice ==
  CHOICE_KW ;
  ~ = separated_nonempty_list(OR_KW, global_protocol_block) ;
  < Choice >

let global_continue ==
  | CONTINUE_KW ; n = name ; SEMICOLON ; { Continue n }

let global_recursion ==
  | REC_KW ; n = name ;
    gis = global_protocol_block ;
    { Recursion (n, gis) }

let global_message_transfer ==
  msg = message ; FROM_KW ; frn = name ;
  TO_KW ; ton = name ;
  SEMICOLON ;
  { MessageTransfer {label = msg ; sender = frn ; receiver  = ton } }

let message ==
  msg = message_signature ; { msg }
  | nm = name ; { { name = nm ; payloads = [] } }

let message_signature ==
  | nm = name ; LPAR ; pars=separated_list(COMMA, name) ; RPAR ;
      { { Syntax.name = nm
        ; Syntax.payloads = pars
        }
      }

let name ==
  | i = IDENT ; { i }
  | i = INT ; { string_of_int i }
