#include "vector.h"

#define INCREASE 2

struct vector {
    size_t size_;
    size_t cap_;
    void ** data_;
};

void resize(vector * vct) {
    if (vct->size_ + 1 == vct->cap_) {
        vct->cap_ *= INCREASE;
        vct->data_ = realloc(vct->data_, sizeof(void *) * vct->cap_);
    }
}

vector * create_vector(size_t size) {
    if (size > 0) {
        vector * vct = (vector *) malloc(sizeof(vector));
        assert(vct != NULL);
        vct->size_ = 0;
        vct->cap_ = size;
        vct->data_ = (void *) malloc(sizeof(void *) * size);
        assert(vct->data_ != NULL);
        return vct;
    }
    return NULL;
}

void delete_vector(vector * vct){
    assert(vct != NULL);
    assert(vct->data_ != NULL);
    free(vct->data_);
    free(vct);
}

void add(vector * vct, void * value){
    assert(vct != NULL);
    assert(value != NULL);
    resize(vct);
    vct->data_[vct->size_++] = value;
}

void* get(const vector * vct, size_t index){
    assert(vct != NULL);
    if (index >= 0) {
        return vct->data_[index];
    }
    return NULL;
}

void print(const vector *vct ){
    for (size_t v = 0; v < vct->size_; ++v) {
        printf("%d\n", *((int *) vct->data_[v]));
    }
}

size_t get_size(const vector * vct){
    size_t sz = vct->size_;
    return sz;
}

size_t get_cap(const vector * vct) {
    return vct->cap_;
}
