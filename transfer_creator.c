#include "transfer_creator.h"


char * get_select(select_opt_t opt) {
    char * res;
    switch (opt) {
        case LESS:
            res = "<";
            break;
        case LESS_EQUAL:
            res = "<=";
            break;
        case NOT_EQUAL:
            res = "!=";
            break;
        case LIKE:
            res = "like";
            break;
        case EQUAL:
            res = "=";
            break;
        case GREATER:
            res = ">";
            break;
        case GREATER_EQUAL:
            res = ">=";
            break;
    }
    return res;
}

struct transfer_creator {
    json_object * obj;
};

transfer_creator_t * init_transfer_format(){
    transfer_creator_t * t = (transfer_creator_t *) malloc(sizeof(transfer_creator_t));
    t->obj = json_object_new_object();
    return t;
}

json_object * add_filename_request(const char *filename) {
    json_object *obj = json_object_new_object();
    json_object_object_add(obj, "filename", json_object_new_string(filename));
    return obj;
}


json_object * prepare_add_schema(add_schema_t t) {
    json_object * vl = json_object_new_object();
    json_object_object_add(vl, "name", json_object_new_string(t.schema_name));
    json_object *jarray = json_object_new_array();
    if (t.attribute_declarations == NULL) {
        json_object_object_add(vl, "attributes", jarray);
        return vl;
    }
    for (size_t i = 0; i < get_size(t.attribute_declarations); ++i) {
        attribute_declaration_t * cur = (attribute_declaration_t *) get(t.attribute_declarations, i);
        json_object * rs = json_object_new_object();
        json_object * obj = json_object_new_object();
        switch (cur->type) {
            case INT:
                json_object_object_add(obj, "attr_name", json_object_new_string(cur->attr_name));
                json_object_object_add(obj, "type", json_object_new_string("integer"));
                json_object_object_add(rs, "attr_name",obj);
                json_object_array_add(jarray, obj);
                break;
            case BOOL:
                json_object_object_add(obj, "attr_name", json_object_new_string(cur->attr_name));
                json_object_object_add(obj, "type", json_object_new_string("bool"));
                json_object_object_add(rs, "attr_name",obj);
                json_object_array_add(jarray, obj);
                break;
            case FLOAT:
                json_object_object_add(obj, "attr_name", json_object_new_string(cur->attr_name));
                json_object_object_add(obj, "type", json_object_new_string("float"));
                json_object_object_add(rs, "attr_name",obj);
                json_object_array_add(jarray, obj);
                break;
            case STR:
                json_object_object_add(obj, "attr_name", json_object_new_string(cur->attr_name));
                json_object_object_add(obj, "type", json_object_new_string("string"));
                json_object_array_add(jarray, obj);
                break;
            case REFERENCE:
                json_object_object_add(obj, "attr_name", json_object_new_string(cur->attr_name));
                json_object_object_add(obj, "type", json_object_new_string("reference"));
                json_object_object_add(obj, "schema_ref", json_object_new_string(cur->schema_ref_name));
                json_object_array_add(jarray, obj);
                break;
        }
    }
    json_object_object_add(vl, "attributes", jarray);
    return vl;
}


json_object * prepare_condition(select_cond_t cond) {
    json_object * obj = json_object_new_object();
    switch (cond.type) {
        case INT:
            json_object_object_add(obj, "attr_name", json_object_new_string(cond.attr_name));
            json_object_object_add(obj, "option", json_object_new_string(get_select(cond.option)));
            json_object_object_add(obj, "value", json_object_new_int(cond.value.integer_value));
            break;
        case BOOL:
            json_object_object_add(obj, "attr_name", json_object_new_string(cond.attr_name));
            json_object_object_add(obj, "option", json_object_new_string(get_select(cond.option)));
            json_object_object_add(obj, "value", json_object_new_string(cond.value.bool_value ? "true" : "false"));
            break;
        case FLOAT:
            json_object_object_add(obj, "attr_name", json_object_new_string(cond.attr_name));
            json_object_object_add(obj, "option", json_object_new_string(get_select(cond.option)));
            json_object_object_add(obj, "value", json_object_new_double(cond.value.float_value));
            break;
        case STR:
        case REFERENCE:
            json_object_object_add(obj, "attr_name", json_object_new_string(cond.attr_name));
            json_object_object_add(obj, "option", json_object_new_string(get_select(cond.option)));
            json_object_object_add(obj, "value", json_object_new_string(cond.value.string_value));
            break;
    }
    return obj;
}

json_object * prepare_statements(const vector * st) {
    json_object * obj = json_object_new_object();
    json_object * jarray = json_object_new_array();
    if (st == NULL){
        json_object_object_add(obj, "statements", jarray);
        return obj;
    }
    for (size_t i = 0; i < get_size(st); ++i) {
        statement_t * var = get(st, i);
        switch (var->type){
            case SELECT:
                json_object * cond_array = json_object_new_array();
                for (size_t i = 0; i < get_size(var->conditions); ++i) {
                    select_cond_t * t = (select_cond_t *) get(var->conditions, i);
                    json_object * cond = prepare_condition(*t);
                    json_object_array_add(cond_array, cond);
                }
                json_object_array_add(jarray, cond_array);
                break;
            case OUT:
                json_object * out = json_object_new_object();
                json_object_object_add(out, "option", json_object_new_string("out"));
                json_object_object_add(out, "schema_name", json_object_new_string(var->attr_name));
                json_object_array_add(jarray, out);
                break;
            case DELETE:
                json_object * delete = json_object_new_object();
                json_object_object_add(delete, "option", json_object_new_string("delete"));
                json_object_array_add(jarray, delete);
                break;
        }
    }
    json_object_object_add(obj, "statements", jarray);
    return obj;
}

void prepare_data_to_transfer(const query_tree * tree, transfer_creator_t * transfer){
    switch (tree->type)
    {
        case OPEN: {
            json_object * open = json_object_new_object();
            json_object_object_add(open, "open", add_filename_request(tree->file_work.filename));
            json_object_object_add(transfer->obj, "request", open);
            break;
        }
        case CREATE: {
            json_object * create = json_object_new_object();
            json_object_object_add(create, "create", add_filename_request(tree->file_work.filename));
            json_object_object_add(transfer->obj, "request", create);
            break;
        }
        case CLOSE: {
            json_object * close = json_object_new_string("close");
            json_object_object_add(transfer->obj, "request", close);
            break;
        }
        case ADD_SCHEMA: {
            json_object * add = prepare_add_schema(tree->add_schema);
            json_object_object_add(transfer->obj, "add_schema", add);
            break;
        }
        case DELETE_SCHEMA: {
            json_object * delete = json_object_new_object();
            json_object_object_add(delete, "name", json_object_new_string(tree->delete_schema.schema_name));
            json_object_object_add(transfer->obj, "delete_schema", delete);
            break;
        }
        case ADD_NODE: {
            break;
        }
        case SELECT_REQ: {
            json_object_object_add(transfer->obj, "selection",  prepare_statements(tree->statements));
            break;
        }
        case UNDEFINED:
            json_object_object_add(transfer->obj, "request", NULL);
            break;
    }
}

const char * get_json_format_string(const transfer_creator_t * t) {
    return json_object_to_json_string_ext(t->obj, JSON_C_TO_STRING_SPACED | JSON_C_TO_STRING_PRETTY);
}
