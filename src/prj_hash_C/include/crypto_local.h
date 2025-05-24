#ifndef CRYPTO_LOCAL_H
#define CRYPTO_LOCAL_H

#ifdef __cplusplus
extern "C"
{
#endif

#include <stdlib.h>

void *zalloc(size_t num);

void cleanse(void *ptr, size_t len);

void secure_clear_free(void *ptr, size_t len);

void clear_free(void *ptr, size_t len); 

int RAND_bytes(unsigned char *buf, int num);

#ifdef __cplusplus
}
#endif

#endif