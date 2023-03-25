#pragma once

#include "json-c/json.h"

#include "request.h"

#define TRANSFER "transfer_data.json"

typedef struct transfer_creator transfer_creator_t;
transfer_creator_t * init_transfer_format();
