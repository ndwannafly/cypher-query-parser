#pragma once

typedef enum {
    UNDEFINED,
    OPEN,
    CREATE,
    CLOSE,
} request_type;

typedef struct {
    request_type type;
    char* schema_name;
} request_tree;

request_tree get_request_tree();
