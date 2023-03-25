#pragma once

#include <stdlib.h>
#include <assert.h>
#include <stdio.h>

typedef struct vector vector;

vector * create_vector(size_t);
void delete_vector(vector *);

void add(vector *, void *);
void * get(const vector *, size_t);

void print(const vector *);
size_t get_size(const vector *);
