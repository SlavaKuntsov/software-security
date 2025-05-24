#include <stdlib.h>
#include <string.h>
#include "include/crypto_local.h"

void *zalloc(size_t num)
{
    void *ret = malloc(num);

    if (ret != NULL)
        memset(ret, 0, num);
    return ret;
}

void cleanse(void *ptr, size_t len)
{
    memset(ptr, 0xAA, len);
    memset(ptr, 0x55, len);
    memset(ptr, 0xAA, len);

    memset(ptr, 0, len);
}

void secure_clear_free(void *ptr, size_t len)
{
    cleanse(ptr, len);
    free(ptr);
}

void clear_free(void *ptr, size_t len)
{
    secure_clear_free(ptr, len);
}
