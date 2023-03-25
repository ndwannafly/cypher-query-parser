#pragma once

typedef enum {
    UNDEFINED,
    OPEN,
    CREATE,
    CLOSE,
} query_type;

typedef struct {
    query_type type;
    char* schema_name;
} query_tree;

query_tree get_query_tree();
