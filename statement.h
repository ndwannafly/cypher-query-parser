#pragma once


typedef enum {
    SELECT,
    OUT,
    DELETE
} action_t;

typedef struct {
    action_t type;
    union {
        vector *conditions;
        char *attr_name;
    };
} statement_t;
