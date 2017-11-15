%{ open Ast %}
%token AGENT
%token INIT
%token STEP
%token <string> IDENTIFIER
%token <string> DEFTYPE
%token <int> INT
%token IF
%token ELSE
%token FOR
%token DEFINT
%token MOD
%token DEFVEC2I
%token PLUS MINUS TIMES DIV
%token LPAREN RPAREN
%token NOT
%token SEQ
%token SNE
%token EQUAL
%token EOL
%token EOF
%token COMMA
%token FUNC
%token SEMICOLON
%token LBRACE RBRACE
%token AND
%token OR
%token BINAND
%token BINXOR
%token BINOR
%token GT
%token LT
%token GE
%token LE

%left AND OR
%left BINAND BINXOR BINOR
%left PLUS MINUS
%left DIV TIMES

%start main
%type <Ast.t> main
                               
%%
  main:
    toplevel_list EOF               { $1 }

  toplevel:
    | stmt_list { Stmts $1 }
    | LBRACE stmt_list RBRACE { Stmts $2 }    
    | FUNC IDENTIFIER LPAREN identifier_list RPAREN
      LBRACE stmt_list RBRACE
      { Function($2, $4, $7) }
    | AGENT LBRACE init step RBRACE { Agent($3, $4) }
    
  toplevel_list:
    | { [] }
    | toplevel toplevel_list      { $1 :: $2 }

  init:
    | INIT LBRACE stmt_list RBRACE    { $3 }
  
  step:
    | STEP LBRACE stmt_list RBRACE   { $3 }
    
  identifier_list:
    | { [] }
    | IDENTIFIER
      { [$1] }
    | IDENTIFIER COMMA identifier_list
      { $1 :: $3 }

  if_stmt:
    | IF LPAREN expr RPAREN LBRACE stmt_list RBRACE
         { If($3, $6) }
    | IF LPAREN expr RPAREN
         LBRACE stmt_list RBRACE
         ELSE LBRACE stmt_list RBRACE
         { IfElse($3, $6, $10) }
    
  stmt:
    | if_stmt                              { $1 }
    | declaration SEMICOLON                { $1 }
    | assignment SEMICOLON                 { $1 }
    
  stmt_list:
    | { [] }
    | stmt stmt_list                 { $1 :: $2 }
    
  vec:
    | LPAREN expr COMMA expr RPAREN { Vec($2, $4) }
  
  expr:
      | INT                           { Int($1) }
      | vec                           { $1 }
      | IDENTIFIER                    { Var($1) }
      | LPAREN expr RPAREN            { $2 }
      | binary_op                     { $1 }

  binary_op:
      | expr TIMES expr               { Binop("*", $1, $3) }
      | expr DIV expr                 { Binop("/", $1, $3) }
      | expr PLUS expr                { Binop("+", $1, $3) }
      | expr MINUS expr               { Binop("-", $1, $3) }
      | expr MOD expr                 { Binop("%", $1, $3) }
      | expr GT expr                  { Binop(">", $1, $3) }
      | expr LT expr                  { Binop("<", $1, $3) }
      | expr GE expr                  { Binop(">=", $1, $3) }
      | expr LE expr                  { Binop("<=", $1, $3) }
      | expr SEQ expr                 { Binop("==", $1, $3) }
      | expr SNE expr                 { Binop("!=", $1, $3) }
      | expr AND expr                 { Binop("&&", $1, $3) }
      | expr OR expr                 { Binop("||", $1, $3) }
      | expr BINAND expr              { Binop("|", $1, $3) }
      | expr BINOR expr               { Binop("&", $1, $3) }
      | expr BINXOR expr               { Binop("^", $1, $3) }
    
  declaration:
    | DEFTYPE IDENTIFIER EQUAL expr     { Declar($1, $2, $4)}

  assignment:
    | IDENTIFIER EQUAL expr             { Assign($1, $3) }
