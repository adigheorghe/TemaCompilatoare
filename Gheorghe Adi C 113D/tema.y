%{
#include <stdio.h>
#include <string.h>

int yylex();
int yyerror(const char *msg);
char msg[500];
int validCode=0;
class TVAR
	{
	     char* nume;
	     int valoare;
	     TVAR* next;
	  
	  public:
	     static TVAR* head;
	     static TVAR* tail;

	     TVAR(char* n, int v = -1);
	     TVAR();
	     int exists(char* n);
             void add(char* n, int v = 1);
             int getValue(char* n);
	     void setValue(char* n, int v);
	     void showTable();
	};

	TVAR* TVAR::head;
	TVAR* TVAR::tail;

	TVAR::TVAR(char* n, int v)
	{
	 this->nume = new char[strlen(n)+1];
	 strcpy(this->nume,n);
	 this->valoare = v;
	 this->next = NULL;
	}

	TVAR::TVAR()
	{
	  TVAR::head = NULL;
	  TVAR::tail = NULL;
	}

	int TVAR::exists(char* n)
	{
	  TVAR* tmp = TVAR::head;
	  while(tmp != NULL)
	  {
	    if(strcmp(tmp->nume,n) == 0)
	      return 1;
            tmp = tmp->next;
	  }
	  return 0;
	 }

         void TVAR::add(char* n, int v)
	 {
	   TVAR* elem = new TVAR(n, v);
	   if(head == NULL)
	   {
	     TVAR::head = TVAR::tail = elem;
	   }
	   else
	   {
	     TVAR::tail->next = elem;
	     TVAR::tail = elem;
	   }
	 }

         int TVAR::getValue(char* n)
	 {
	   TVAR* tmp = TVAR::head;
	   while(tmp != NULL)
	   {
	     if(strcmp(tmp->nume,n) == 0)
	      return tmp->valoare;
	     tmp = tmp->next;
	   }
	   return -1;
	  }

	  void TVAR::setValue(char* n, int v)
	  {
	    TVAR* tmp = TVAR::head;
	    while(tmp != NULL)
	    {
	      if(strcmp(tmp->nume,n) == 0)
	      {
		tmp->valoare = v;
	      }
	      tmp = tmp->next;
	    }
	  }
	  void TVAR::showTable()
	  {
	    TVAR* tmp = TVAR::head;
	    printf("Tabela de simboluri:\n");
	    if(tmp==NULL)
	    printf("Este goala\n");
	    while(tmp != NULL)
	    {
	printf("%s   %d\n",tmp->nume,tmp->valoare);
	tmp = tmp->next;
	    }
	  }

	TVAR* ts = NULL;
%}

%union { char* sir; int val; };

%token T_PROGRAM T_VAR T_BEGIN T_END T_INTEGER T_DIV 
T_INT T_READ T_WRITE T_FOR T_DO T_TO T_ID T_ERROR

%type <val> T_INT
%type <sir> T_ID

%type <val> exp
%type <val> term
%type <val> factor

%locations

%start prog

%left '-' '+'
%left '*' T_DIV

%%
prog: 
	T_PROGRAM prog_name T_VAR dec_list T_BEGIN stmt_list T_END {validCode=1;}
	| T_ERROR '\n' prog {validCode=0; yyerror("");YYERROR;};
prog_name: T_ID
	{
 		ts=new TVAR(); 
		ts->add($1);
	}
dec_list:dec 
	| dec_list ';' dec;

dec:	id_list ':' type;

type:	T_INTEGER;

id_list:T_ID
	{
		if(ts==NULL)
		{
		 sprintf(msg,"Tabela de simboluri neinitializata.\n");
		 printf("Linia:%d Coloana:%d",@1.first_line,@1.first_column);
		 yyerror(msg);
		 YYERROR;
		}
		else
		{
		 if(ts->exists($1)==0)
		 ts->add($1);
		}
		}
	| id_list ',' T_ID
		{
		 if(ts==NULL)
		{
		 sprintf(msg,"Tabela de simboluri neinitializata.\n");
		 printf("Linia:%d Coloana:%d",@3.first_line,@3.first_column);
		 yyerror(msg);
		 YYERROR;
		}
		 else
		{
		 if(ts->exists($3)==0)
		 ts->add($3);
		}
		};

stmt_list:
	stmt
	| stmt_list ';' stmt;	
	
stmt:	
	assign
	| read
	| write
	| for;

assign: 
	T_ID '=' exp
		{
		 if(ts->exists($1)==0)
		{
		 sprintf(msg,"Variabila %s nu a fost declarata\n", $1);
		 printf("Linia:%d Coloana:%d",@1.first_line,@1.first_column);
		 yyerror(msg);
		 YYERROR;
		}
	 	 else
		 ts->setValue($1,$3);
		printf("%s",$1);
		};

exp:
	term
	| exp '+' term
		{ $$=$1+$3; }
	| exp '-' term
		{ $$=$1-$3; };

term:
	factor
	| term '*' factor
		{$$=$1 * $3;}
	| term T_DIV factor
		{
		 if($3==0) 
		{
		 printf("Linia:%d Coloana:%d ",@1.first_line,@1.first_column);
		 sprintf(msg,"Erroare semantica: Imaprtire la 0.\n");
		 yyerror(msg);
		 YYERROR;
		}
		 else 
		 $$=$1/$3;
		};
	
factor: 
	T_ID
		{
		 if(ts->exists($1)==0)
		{
		 sprintf(msg,"Variabila %s nu a fost declarata\n", $1);
	 	 printf("Linia:%d Coloana:%d",@1.first_line,@1.first_column);
	 	 yyerror(msg);
		 YYERROR;
		}
		else
		{
		 $$=ts->getValue($1);
		}
		}
	| T_INT {$$=$1;}
	|'(' exp ')' {$$=$2;};

read:
	T_READ '(' id_list ')';

write: 
	T_WRITE '(' id_list ')';

for: 
	T_FOR index_exp T_DO body;

index_exp: 
	T_ID '=' exp T_TO exp
		{
		if(ts->exists($1)==0)
		{
		sprintf(msg,"Variabila %s nu a fost declarata\n", $1);
		printf("Linia:%d Coloana:%d",@1.first_line,@1.first_column);
		yyerror(msg);
		YYERROR;
		};
		ts->setValue($1,$3);
		};

body: stmt
	| T_BEGIN stmt_list T_END;

%%
int main()
{
	yyparse();
	
	if(validCode == 1)
	{
		printf("CORECTA\n");		
	}	
	else
	printf("INCORECTA\n");
	ts->showTable();
       return 0;
}
int yyerror(const char *msg)
{
	printf("Error: %s\n",msg);
	return 1;
}



