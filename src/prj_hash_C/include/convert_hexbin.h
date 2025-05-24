
#include <stdio.h>
#include <string.h>

typedef unsigned char ByteData;
unsigned char *datahex(const char *string);
size_t HexToBin(const char *s, ByteData *buff, size_t length);
void BinToHex(const ByteData *buff, size_t length, char *output, size_t outLength);

char *bin2hex(unsigned char *, int);
unsigned char *hex2bin(const char *);
