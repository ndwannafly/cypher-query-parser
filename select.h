#pragma once

typedef enum {
    EQUAL,
    GREATER,
    GREATER_EQUAL,
    LESS,
    LESS_EQUAL,
    NOT_EQUAL,
    LIKE
} select_opt_t;

typedef struct {
    char *attr_name;
    select_opt_t option;
    attr_type_t type;
    base_value_t value;
} select_cond_t;
