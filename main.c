#define YYDEBUG 1

#include <stdio.h>
//#include "parser.h"
#include "request.h"
#include "transfer_creator.h"

int yyparse();

int main(){
    int yydebug = 1;
    int x = yyparse();
    // request_tree tree = get_request_tree();
    // transfer_creator_t * transfer_format = init_transfer_format();

}
