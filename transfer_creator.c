#include "transfer_creator.h"


struct transfer_creator {
    json_object * obj;
};

transfer_creator_t * init_transfer_format(){
    transfer_creator_t * t = (transfer_creator_t *) malloc(sizeof(transfer_creator_t));
    t->obj = json_object_new_object();
    return t;
}
