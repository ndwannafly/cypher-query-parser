#pragma once

#include <stdbool.h>
#include <stdlib.h>

#include "vector.h"
#include "attribute.h"
#include "statement.h"
#include "select.h"

typedef enum {
    UNDEFINED,
    OPEN,
    CREATE,
    CLOSE,
    ADD_SCHEMA,
    DELETE_SCHEMA,
    ADD_NODE,
    SELECT_REQ
} query_type;

typedef struct {
    char *filename;
} file_work_t;

typedef struct {
    char *schema_name;
    vector *attribute_declarations;
} add_schema_t;

typedef struct {
    char *schema_name;
} delete_schema_t;

typedef struct {
    char *schema_name;
    vector *attribute_values;
} add_node_t;
typedef struct {
    query_type type;
    char* schema_name;
    union {
        file_work_t file_work;
        add_schema_t add_schema;
        delete_schema_t delete_schema;
        add_node_t add_node;
        vector *statements;
    };
} query_tree;

query_tree get_query_tree();
