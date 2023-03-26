#define YYDEBUG 1

#include <stdio.h>
#include "parser.h"
#include "query.h"
#include "transfer_creator.h"

int yyparse();

int main(){
    int yydebug = 1;
    int x = yyparse();
    query_tree tree = get_query_tree();
    transfer_creator_t * tc = init_transfer_format();
    prepare_data_to_transfer(&tree, tc);
    printf("%s\n", get_json_format_string(tc));
    FILE * file;
    file = fopen(TRANSFER, "a+");

    if (file == NULL) {
        printf("Could not open or create file!\n");
        return -1;
    }
    fprintf(file, "%s\n", get_json_format_string(tc));
    fclose(file);
    return 0;
}
