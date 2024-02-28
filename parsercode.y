%{
    #include <stdio.h>
    #include<stdlib.h>
    #include <ctype.h> 
    #include <string.h>
    #include <unistd.h>

    int counter = 1;



    extern long long yylex();

    void yyerror(char *msg);




    struct SymbolTable {
    char variable[16];
    long long value;
};

/* Initialize a symbol table */
struct SymbolTable symbolTable[100];
int symbolTableSize = 0;

void addToSymbolTable(const char* var, long long val);
int getFromSymbolTable(const char* var);
void calculate(const char* result, const char* op1, const char* operator, const char* op2);
int isNumber(const char* str);
int isDigitPresent(long long num, long long digit);
void performOperation(const char* op, long long* a, long long b);
int sumOfDigits(long long n);


%}



%union{
    char num[5000];
    char nonTerminal[5000];
}


%token <num> NUM
%token ADD
%token SUB
%token MUL
%token DIV


%type <nonTerminal>  expr add term factor start


%right '='
%left ADD
%left SUB
%left MUL
%left DIV
%left UMINUS 

%%

start : expr
        | start expr;     


expr    : add '='              { strcpy($$, $1); }
        ;

add     : add ADD term              { sprintf($$, "t%d", counter++); printf("%s = %s + %s;\n", $$, $1, $3); calculate($$, $1, "+", $3);}
        | add SUB term              { sprintf($$, "t%d", counter++); printf("%s = %s - %s;\n", $$, $1, $3); calculate($$, $1, "-", $3);}
        | term                      { strcpy($$, $1);}
        ;

term    : term MUL factor           { sprintf($$, "t%d", counter++); printf("%s = %s * %s;\n", $$, $1, $3);calculate($$, $1, "*", $3); }
        | term DIV factor           { sprintf($$, "t%d", counter++); printf("%s = %s / %s;\n", $$, $1, $3);calculate($$, $1, "/", $3); }
        | factor                    { strcpy($$, $1); }
        ;

factor  : '(' add ')'              { strcpy($$, $2); }
        | NUM                       { strcpy($$, $1); }
        ;

%%

void yyerror(char *msg) {
    fprintf(stderr,"%s\n",msg);
    //exit(1);
}


int yywrap() {
    return 1;
}

int main() {

        yyparse();


    return 0;
}


/* Function to add/update a variable and its value in the symbol table */
void addToSymbolTable(const char* var, long long val) {
    int i;
    for (i = 0; i < symbolTableSize; ++i) {
        if (strcmp(symbolTable[i].variable, var) == 0) {
            symbolTable[i].value = val;
            return;
        }
    }
    strcpy(symbolTable[symbolTableSize].variable, var);
    symbolTable[symbolTableSize++].value = val;
}

/* Function to retrieve the value of a variable from the symbol table */
int getFromSymbolTable(const char* var) {
    int i;
    for (i = 0; i < symbolTableSize; ++i) {
        if (strcmp(symbolTable[i].variable, var) == 0) {
            return symbolTable[i].value;
        }
    }
    return -9999; /* Return a default value if variable not found */
}

/* Function to perform calculation and store result in symbol table */
void calculate(const char* result, const char* op1, const char* operator, const char* op2) {
    long long val1, val2, resultVal;

    val1 = getFromSymbolTable(op1);

    if (! isNumber(op1)){
        val1 = getFromSymbolTable(op1);
    }
    else val1 = atoi(op1);
    if (! isNumber(op2)){
        val2 = getFromSymbolTable(op2);
    }
    else val2 = atoi(op2);

    performOperation(operator, &val1, val2);

    printf("%s = %lld;\n", result, val1);
    addToSymbolTable(result, val1);
}

int isNumber(const char* str) {
    while (*str) {
        if (!isdigit(*str)) {
            return 0; // Not a number
        }
        str++;
    }
    return 1; // All characters are digits (number)
}

// Function to check if a digit is present in a number
int isDigitPresent(long long num, long long digit) {
    while (num > 0) {
        if (num % 10 == digit) {
            return 1; // Digit found
        }
        num /= 10;
    }
    return 0; // Digit not found
}

int sumOfDigits(long long n) {
    long long sum = 0;
    while (n > 0 || sum > 9) {
        if (n == 0) {
            n = sum;
            sum = 0;
        }
        sum += n % 10;
        n /= 10;
    }
    return sum;
}

void performOperation(const char* op, long long* a, long long b) {
if (op == "+") {
        long long aTemp = *a;
        char strr[100]; 
    int i = 0;
    sprintf(strr, "%d", b);
        while (b > 0) {
            long long digit = strr[i] - '0';
            if (!isDigitPresent(aTemp, digit)) {
                *a = *a * 10 + digit;        //Add digit
            }
            b /= 10;
            i++;
        }
    } else if (op == "-") {
        while (b > 0) {
            long long digit = b % 10;

            // Remove the digit from the original number
            long long tempOriginal = *a;
            long long result = 0, multiplier = 1;

        while (tempOriginal > 0) {
            long long tempDigit = tempOriginal % 10;
            if (tempDigit != digit) {
                result += tempDigit * multiplier;
                multiplier *= 10;
            }
            tempOriginal /= 10;
        }

        *a = result;
        b /= 10;
    }
    } else if (op == "*") {
        b = sumOfDigits(b);
            
            if (!isDigitPresent(*a, b)) {
                *a = *a * 10 + b;
            }
            b /= 10;
        
    } else if (op == "/") {
        b = sumOfDigits(b);
            // Remove the digit from the original number
            long long tempOriginal = *a;
            long long result = 0, multiplier = 1;

        while (tempOriginal > 0) {
            long long tempDigit = tempOriginal % 10;
            if (tempDigit != b) {
                result += tempDigit * multiplier;
                multiplier *= 10;
            }
            tempOriginal /= 10;
        }
        *a = result;
        b /= 10;
    } else {
        printf("Invalid operation.\n");
    }
}