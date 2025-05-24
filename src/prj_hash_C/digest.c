#include <stdlib.h>
#include <string.h>

#include <time.h>
#include "include/convert_hexbin.h"

#include "include/belt.h"
#include "include/belt_local.h"

#include <stdio.h>
#include <emscripten/emscripten.h>

clock_t start_t, end_t;
double total_t;



EMSCRIPTEN_KEEPALIVE
char *calcDigest(const unsigned char *data, size_t data_length)
{
	unsigned char BufHash[32];
	char strHash[100];

	start_t = clock();

	belt_hash(data, data_length, BufHash);
	BinToHex(BufHash, 32, strHash, 65);
 	
	end_t = clock();
	total_t = (double)(end_t - start_t) / CLOCKS_PER_SEC;

	char result[300] = {};
	sprintf(result, "{\"digest\":\"%s\",\"time\":\"%f\"}", strHash, total_t);
	char *returnValue = result;
	return returnValue;
}