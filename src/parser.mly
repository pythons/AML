%{ open Ast %}
%token AGENT
%token <float> FLOAT
%token <string> STRING
%token <string> IDENTIFIER
%token <string> COMMENT
%token <int> INT
%token <bool> BOOL
%token TINT
%token TDOUBLE
%token TSTRING
%token TBOOL
%token TANGLE
%token TVECTOR
%token VOID
%token IF
%token ELSE
%token FOR
%token MOD
%token PRINTLN
%token PLUS MINUS TIMES DIV
%token LPAREN RPAREN
%token NOT
%token SEQ
%token SNE
%token EQUAL
%token EOF
%token COMMA
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
%nonassoc SEQ SNE
%nonassoc GT LT GE LE
%nonassoc NOT
%left PLUS MINUS
%left DIV TIMES MOD

%nonassoc IF
%nonassoc ELSE

%start main
%type <Ast.t> main
                               
%%
  main:
    toplevel_list EOF               { $1 }

  toplevel:
    | AGENT IDENTIFIER stmt SEMICOLON { Agent($2, $3) }
    | stmt                          { Stmt($1) }
    
  toplevel_list:
    | { [] }
    | toplevel toplevel_list      { $1 :: $2 }

  leftvalue:
    | IDENTIFIER                      { Identifier($1) }
    | builtintype IDENTIFIER          { TypeIdentifier($1, $2) }    
      
  expr:    
    | INT                           { Int($1) }
    | BOOL                          { Bool($1) }
    | STRING                        { String($1) }
    | FLOAT                         { Float($1) }
    | leftvalue                     { Leftvalue($1) }
    | LPAREN expr RPAREN            { $2 }
    | binary_op                     { $1 }
    | unary_op                      { $1 }
    | call_stmt                     { $1 }
    | TVECTOR LPAREN expr COMMA expr RPAREN { Vector($3, $5) }
    | TANGLE LPAREN expr COMMA expr RPAREN { Angle($3, $5) }

  expr_list:
    | { [] }
    | expr                          { [$1] }
    | expr COMMA expr_list          { $1 :: $3 }
      
    
  for_stmt:
    | FOR LPAREN assignment SEMICOLON expr SEMICOLON assignment RPAREN
    stmt
          { For($3, $5, $7, $9) }

  call_stmt:
    | IDENTIFIER LPAREN expr_list RPAREN { Call($1, $3) }
    | PRINTLN LPAREN expr_list RPAREN { Println($3) }
      
  if_stmt:
    | IF LPAREN expr RPAREN stmt
      %prec IF;
         { If($3, $5) }
    | IF LPAREN expr RPAREN stmt
         ELSE stmt
         { IfElse($3, $5, $7) }
    
  stmt:
    | SEMICOLON                            { Empty }
    | if_stmt                              { $1 }
    | for_stmt                             { $1 }
    | COMMENT                              { Comment($1) }
    | assignment SEMICOLON                 { $1 }
    | expr SEMICOLON                       { Expr($1) }
    | builtintype IDENTIFIER LPAREN expr_list RPAREN LBRACE stmt_list RBRACE      { Function($1, $2, $4, Stmts($7)) }
    | IDENTIFIER LPAREN expr_list RPAREN LBRACE stmt_list RBRACE      { Function(Builtintype(""), $1, $3, Stmts($6)) }
    | LBRACE stmt_list RBRACE              { Stmts($2) }
    
  stmt_list:
    | { [] }
    | stmt stmt_list                       { $1 :: $2 }
        
  builtintype:
    | TINT                          { Builtintype("int") }
    | TDOUBLE                       { Builtintype("double") }
    | TSTRING                       { Builtintype("string") }
    | TBOOL                         { Builtintype("bool") }
    | TANGLE                        { Builtintype("ang") }
    | TVECTOR                       { Builtintype("vec2f") }
    | VOID                          { Builtintype("void") }
    | IDENTIFIER                    { Builtintype($1) }

  unary_op:
    | NOT expr                      { Unop ("!", $2) }
    
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
    | expr OR expr                  { Binop("||", $1, $3) }
    | expr BINAND expr              { Binop("&", $1, $3) }
    | expr BINOR expr               { Binop("|", $1, $3) }
    | expr BINXOR expr              { Binop("^", $1, $3) }
        
  assignment:
    | leftvalue EQUAL expr             { Assign($1, $3) }
