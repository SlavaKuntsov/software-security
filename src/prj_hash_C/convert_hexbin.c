#include <stdlib.h>

#include "include/convert_hexbin.h"

unsigned char *datahex(const char *string)
{
    if (string == NULL)
        return NULL;

    size_t slength = strlen(string);
    if ((slength % 2) != 0) // must be even
        return NULL;

    size_t dlength = slength / 2;

    unsigned char *data = malloc(dlength + 1);
    memset(data, 0, dlength);

    size_t index = 0;
    while (index < slength)
    {
        char c = string[index];
        int value = 0;
        if (c >= '0' && c <= '9')
            value = (c - '0');
        else if (c >= 'A' && c <= 'F')
            value = (10 + (c - 'A'));
        else if (c >= 'a' && c <= 'f')
            value = (10 + (c - 'a'));
        else
        {
            free(data);
            return NULL;
        }

        data[(index / 2)] += value << (((index + 1) % 2) * 4);

        index++;
    }

    return data;
};

ByteData HexChar(char c)
{
    if ('0' <= c && c <= '9')
        return (ByteData)(c - '0');
    if ('A' <= c && c <= 'F')
        return (ByteData)(c - 'A' + 10);
    if ('a' <= c && c <= 'f')
        return (ByteData)(c - 'a' + 10);
    return (ByteData)(-1);
}

size_t HexToBin(const char *s, ByteData *buff, size_t length)
{
    size_t result = 0;
    if (!s || !buff || length <= 0)
        return -2;

    while (*s)
    {
        ByteData nib1 = HexChar(*s++);
        if ((signed)nib1 < 0)
            return -3;
        ByteData nib2 = HexChar(*s++);
        if ((signed)nib2 < 0)
            return -4;

        ByteData bin = (nib1 << 4) + nib2;

        if (length-- <= 0)
            return -5;
        *buff++ = bin;
        ++result;
    }
    return result;
}

void BinToHex(const ByteData *buff, size_t length, char *output, size_t outLength)
{
    char binHex[] = "0123456789ABCDEF";

    if (!output || outLength < 4)
        return (void)(-6);
    *output = '\0';

    if (!buff || length <= 0 || outLength <= 2 * length)
    {
        memcpy(output, "ERR", 4);
        return (void)(-7);
    }

    for (; length > 0; --length, outLength -= 2)
    {
        ByteData byte = *buff++;

        *output++ = binHex[(byte >> 4) & 0x0F];
        *output++ = binHex[byte & 0x0F];
    }
    if (outLength-- <= 0)
        return (void)(-8);
    *output++ = '\0';
};

char *bin2hex(unsigned char *p, int len)
{
    char *hex = malloc(((2 * len) + 1));
    char *r = hex;

    while (len && p)
    {
        (*r) = ((*p) & 0xF0) >> 4;
        (*r) = ((*r) <= 9 ? '0' + (*r) : 'A' - 10 + (*r));
        r++;
        (*r) = ((*p) & 0x0F);
        (*r) = ((*r) <= 9 ? '0' + (*r) : 'A' - 10 + (*r));
        r++;
        p++;
        len--;
    }
    *r = '\0';

    return hex;
}

unsigned char *hex2bin(const char *str)
{
    int len, h;
    unsigned char *result, *err, *p, c;

    err = malloc(1);
    *err = 0;

    if (!str)
        return err;

    if (!*str)
        return err;

    len = 0;
    p = (unsigned char *)str;
    while (*p++)
        len++;

    result = malloc((len / 2) + 1);
    h = !(len % 2) * 4;
    p = result;
    *p = 0;

    c = *str;
    while (c)
    {
        if (('0' <= c) && (c <= '9'))
            *p += (c - '0') << h;
        else if (('A' <= c) && (c <= 'F'))
            *p += (c - 'A' + 10) << h;
        else if (('a' <= c) && (c <= 'f'))
            *p += (c - 'a' + 10) << h;
        else
            return err;

        str++;
        c = *str;

        if (h)
            h = 0;
        else
        {
            h = 4;
            p++;
            *p = 0;
        }
    }

    return result;
}