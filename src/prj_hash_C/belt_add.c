/*
 * Copyright 2022. All Rights Reserved.
 */

#include <stdlib.h>
#include <string.h>

#include "include/belt.h"
#include "include/belt_local.h"

void belt_ctr128_inc(unsigned char *counter)
{
	unsigned int n = 0, c = 1;

	do
	{
		c += counter[n];
		counter[n] = (unsigned char)c;
		c >>= 8;
		n++;
	} while (n < 16);
}

void belt_gmul(unsigned int *out, unsigned int *a, unsigned int *b)
{
	unsigned int temp[16], a_copy[16], b_copy[16];
	unsigned int carry, bufbit;
	int i, j, k;

	for (i = 0; i < 4; i++)
	{
		temp[i] = 0;
		a_copy[i] = a[i];
		b_copy[i] = b[i];
	}

	for (i = 0; i < 4; i++)
	{
		for (j = 0; j < 32; j++)
		{
			if (b_copy[0] & 0x1)
			{
				for (k = 0; k < 4; k++)
					temp[k] = temp[k] ^ a_copy[k];
			}

			bufbit = 0;

			for (k = 0; k < 4; k++)
			{
				carry = a_copy[k] & 0x80000000;
				a_copy[k] = a_copy[k] << 1;
				a_copy[k] += bufbit;
				bufbit = carry >> 31;
			}

			if (carry)
				a_copy[0] = a_copy[0] ^ 0x87;

			bufbit = 0;

			for (k = 3; k >= 0; k--)
			{
				carry = b_copy[k] & 0x1;
				b_copy[k] = b_copy[k] >> 1;
				b_copy[k] += bufbit;
				bufbit = carry << 31;
			}
		}
	}

	for (i = 0; i < 4; i++)
		out[i] = temp[i];
}

void BELT_block_encrypt(const void *in, unsigned char *out, const unsigned char key[32])
{
	int it = 0;
	unsigned int a, b, c, d;

	unsigned int thetas[8];
	unsigned int k[56];

	PACK_U32(key, &thetas[0]);
	PACK_U32(key + 4, &thetas[1]);
	PACK_U32(key + 8, &thetas[2]);
	PACK_U32(key + 12, &thetas[3]);
	PACK_U32(key + 16, &thetas[4]);
	PACK_U32(key + 20, &thetas[5]);
	PACK_U32(key + 24, &thetas[6]);
	PACK_U32(key + 28, &thetas[7]);

	BELT_CHUNK256_COPY(k, thetas);
	BELT_CHUNK256_COPY(k + 8, thetas);
	BELT_CHUNK256_COPY(k + 16, thetas);
	BELT_CHUNK256_COPY(k + 24, thetas);
	BELT_CHUNK256_COPY(k + 32, thetas);
	BELT_CHUNK256_COPY(k + 40, thetas);
	BELT_CHUNK256_COPY(k + 48, thetas);

	PACK_U32((unsigned char *)in, &a);
	PACK_U32((unsigned char *)in + 4, &b);
	PACK_U32((unsigned char *)in + 8, &c);
	PACK_U32((unsigned char *)in + 12, &d);

	for (it = 1; it <= 8; it++)
	{
		b = b ^ BELT_G5(a + k[7 * it - 7]);
		c = c ^ BELT_G21(d + k[7 * it - 6]);
		a = a - BELT_G13(b + k[7 * it - 5]);
		unsigned int e = BELT_G21(b + c + k[7 * it - 4]) ^ it;
		b = b + e;
		c = c - e;
		d = d + BELT_G13(c + k[7 * it - 3]);
		b = b ^ BELT_G21(a + k[7 * it - 2]);
		c = c ^ BELT_G5(d + k[7 * it - 1]);

		unsigned int t;
		BELT_SWAP(a, b, t);
		BELT_SWAP(c, d, t);
		BELT_SWAP(b, c, t);
	}

	UNPACK_U32(b, out);
	UNPACK_U32(d, out + 4);
	UNPACK_U32(a, out + 8);
	UNPACK_U32(c, out + 12);
}

void BELT_block_decrypt(const void *in, unsigned char *out, const unsigned char key[32])
{
	int it;
	unsigned int a, b, c, d;

	unsigned int thetas[8];
	unsigned int k[56];

	PACK_U32(key, &thetas[0]);
	PACK_U32(key + 4, &thetas[1]);
	PACK_U32(key + 8, &thetas[2]);
	PACK_U32(key + 12, &thetas[3]);
	PACK_U32(key + 16, &thetas[4]);
	PACK_U32(key + 20, &thetas[5]);
	PACK_U32(key + 24, &thetas[6]);
	PACK_U32(key + 28, &thetas[7]);

	BELT_CHUNK256_COPY(k, thetas);
	BELT_CHUNK256_COPY(k + 8, thetas);
	BELT_CHUNK256_COPY(k + 16, thetas);
	BELT_CHUNK256_COPY(k + 24, thetas);
	BELT_CHUNK256_COPY(k + 32, thetas);
	BELT_CHUNK256_COPY(k + 40, thetas);
	BELT_CHUNK256_COPY(k + 48, thetas);

	PACK_U32((unsigned char *)in, &a);
	PACK_U32((unsigned char *)in + 4, &b);
	PACK_U32((unsigned char *)in + 8, &c);
	PACK_U32((unsigned char *)in + 12, &d);

	for (it = 8; it >= 1; it--)
	{
		b = b ^ BELT_G5(a + k[7 * it - 1]);
		c = c ^ BELT_G21(d + k[7 * it - 2]);
		a = a - BELT_G13(b + k[7 * it - 3]);
		unsigned int e = BELT_G21(b + c + k[7 * it - 4]) ^ it;
		b = b + e;
		c = c - e;
		d = d + BELT_G13(c + k[7 * it - 5]);
		b = b ^ BELT_G21(a + k[7 * it - 6]);
		c = c ^ BELT_G5(d + k[7 * it - 7]);

		unsigned int t;
		BELT_SWAP(a, b, t);
		BELT_SWAP(c, d, t);
		BELT_SWAP(a, d, t);
	}

	UNPACK_U32(c, out);
	UNPACK_U32(a, out + 4);
	UNPACK_U32(d, out + 8);
	UNPACK_U32(b, out + 12);
}

void BELT_wblock_encrypt(const void *in, size_t in_len, unsigned char *out, const unsigned char key[32])
{
	unsigned char *r, *r_star, temp16[16], temp_s[16], counter[16] = {0};
	int n, round = 0;
	size_t it;

	n = (in_len + 15) / 16;
	r = (unsigned char *)malloc(in_len);

	/*Step 1*/
	memcpy(r, in, in_len);
	r_star = r + (in_len - 16);

	do
	{
		BELT_CHUNK128_SET_ZERO(temp_s);
		BELT_CHUNK128_SET_ZERO(temp16);
		round++;

		/*Substep 1*/
		memcpy(temp_s, r, 16);
		for (it = 16; it + 16 < in_len; it += 16)
		{
			BELT_CHUNK128_XOREQ(temp_s, r + it);
		}

		/*Substep 2*/
		BELT_block_encrypt(temp_s, temp16, key);
		UNPACK_U64((unsigned long long)round, counter);
		BELT_CHUNK128_XOREQ(r_star, temp16);
		BELT_CHUNK128_XOREQ(r_star, counter);

		/*Substep 3*/
		memmove(r, r + 16, in_len - 16);

		/*Substep 4*/
		memcpy(r_star, temp_s, 16);

	} while (round % (2 * n));

	/*Step 4*/
	memcpy(out, r, in_len);

	free(r);
}

void BELT_wblock_decrypt(const void *in, size_t in_len, unsigned char *out, const unsigned char key[32])
{
	unsigned char *r, *r_star, temp16[16], temp_s[16], counter[16] = {0};
	int n, round = 0;
	size_t it;

	n = (in_len + 15) / 16;
	r = (unsigned char *)malloc(in_len);

	/*Step 1*/
	memcpy(r, in, in_len);
	r_star = r + (in_len - 16);

	round = 2 * n;

	do
	{
		BELT_CHUNK128_SET_ZERO(temp_s);
		BELT_CHUNK128_SET_ZERO(temp16);

		/*Substep 1*/
		memcpy(temp_s, r_star, 16);

		/*Substep 2*/
		memmove(r + 16, r, in_len - 16);

		/*Substep 3*/
		BELT_block_encrypt(temp_s, temp16, key);
		UNPACK_U64((unsigned long long)round, counter);
		BELT_CHUNK128_XOREQ(r_star, temp16);
		BELT_CHUNK128_XOREQ(r_star, counter);

		/*Substep 4*/
		for (it = 16; it + 16 < in_len; it += 16)
		{
			BELT_CHUNK128_XOREQ(temp_s, r + it);
		}
		memcpy(r, temp_s, 16);

		round--;

	} while (round > 0);

	/*Step 4*/
	memcpy(out, r, in_len);

	free(r);
}

void BELT_compress(const unsigned char in[64], unsigned char S[16], unsigned char Y[32])
{
	unsigned char result[32];

	/* 2 */
	BELT_CHUNK128_XOR(result, in + 32, in + 48);
	BELT_block_encrypt(result, result + 16, in);
	BELT_CHUNK128_XOREQ(result, result + 16);
	memcpy(S, result, 16);

	/* 3 */
	memcpy(result + 16, in + 48, 16);
	BELT_block_encrypt(in, result, result);
	BELT_CHUNK128_XOREQ(result, in);
	memcpy(Y, result, 16);

	/* 4 */
	BELT_CHUNK128_SET_ONE(result + 16);
	BELT_CHUNK128_XOR(result, S, result + 16);
	memcpy(result + 16, in + 32, 16);
	BELT_block_encrypt(in + 16, result, result);
	BELT_CHUNK128_XOREQ(result, in + 16);
	memcpy(Y + 16, result, 16);
}

int BELT_keyexpand(unsigned char key[32], const unsigned char *theta, int len)
{
	if (len != 16 && len != 24 && len != 32)
		return 1;

	memcpy(key, theta, len);

	if (len == 16)
		memcpy(key + 16, theta, 16);
	else if (len == 24)
	{
		unsigned int *tmp = (unsigned int *)key;
		tmp[6] = tmp[0] ^ tmp[1] ^ tmp[2];
		tmp[7] = tmp[3] ^ tmp[4] ^ tmp[5];
	}

	return 0;
}

int BELT_keyrep(const unsigned char *key, int n, const unsigned char d[12],
				const unsigned char i[16], int m, unsigned char *out)
{
	unsigned char temp16[16], temp32[32], temp64[64];
	int it;

	if ((m != 16 && m != 24 && m != 32) || n < m)
		return 1;

	BELT_keyexpand(temp32, key, n);

	memcpy(temp64, BELT_H + 4 * (n - 16) + 2 * (m - 16), 4);
	memcpy(temp64 + 4, d, 12);
	memcpy(temp64 + 16, i, 16);
	memcpy(temp64 + 32, temp32, 32);

	BELT_compress(temp64, temp16, temp32);

	for (it = 0; it < m; it++)
		out[it] = temp32[it];

	return 0;
}