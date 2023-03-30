#pragma once

#include "json-c/json.h"

#include "query.h"

#define TRANSFER "data.json"

typedef struct transfer_creator transfer_creator_t;

transfer_creator_t * init_transfer_format();

void prepare_data_to_transfer(const query_tree *, transfer_creator_t *);

const char * get_json_format_string(const transfer_creator_t *);
