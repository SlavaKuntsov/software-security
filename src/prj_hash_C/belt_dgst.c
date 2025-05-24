/*
 * Copyright 2020. All Rights Reserved.
 */

#include <stdlib.h>
#include <string.h>

#include "include/belt.h"
#include "include/belt_local.h"
#include "include/crypto_local.h"

static void belt_hash_loop(BELThash_CTX *ctx, const unsigned char block[32])
{
	unsigned char temp64[64];
	unsigned char temp16[16];

	memcpy(temp64, block, 32);
	memcpy(temp64 + 32, ctx->hash, 32);

	BELT_compress(temp64, temp16, ctx->hash);
	BELT_CHUNK128_XOREQ(ctx->s, temp16);
}

int BELT_hash_Init(BELThash_CTX *ctx)
{
	cleanse(ctx, sizeof(*ctx));

	memcpy(ctx->hash, BELT_H, 32);

	return 1;
}

int BELT_hash_Update(BELThash_CTX *ctx, const void *in, size_t in_len)
{
	ctx->bytes_count += in_len;

	if (ctx->buf_len)
	{
		if (in_len < 32 - ctx->buf_len)
		{
			memcpy(ctx->buf + ctx->buf_len, in, in_len);
			ctx->buf_len += (int)in_len;
			return 1;
		}

		memcpy(ctx->buf + ctx->buf_len, in, 32 - ctx->buf_len);
		in_len -= 32 - ctx->buf_len;
		in = (const unsigned char *)in + (32 - ctx->buf_len);

		belt_hash_loop(ctx, ctx->buf);
		ctx->buf_len = 0;
	}

	while (in_len >= 32)
	{
		belt_hash_loop(ctx, in);
		in = (const unsigned char *)in + 32;
		in_len -= 32;
	}

	if (in_len)
		memcpy(ctx->buf, in, ctx->buf_len = (int)in_len);

	return 1;
}

int BELT_hash_Final(BELThash_CTX *ctx, unsigned char *md)
{
	if (ctx->buf_len)
	{
		memset(ctx->buf + ctx->buf_len, 0, 32 - ctx->buf_len);
		belt_hash_loop(ctx, ctx->buf);
	}

	unsigned char temp64[64] = {0}, temp16[16] = {0};

	unsigned long long x_long_mod_128 = ctx->bytes_count << 3;
	UNPACK_U64(x_long_mod_128, temp16);

	memcpy(temp64, temp16, 16);
	memcpy(temp64 + 16, ctx->s, 16);
	memcpy(temp64 + 32, ctx->hash, 32);

	BELT_compress(temp64, temp16, md);

	memset(temp64, 0, sizeof(temp64));
	memset(temp16, 0, sizeof(temp16));

	return 1;
}

unsigned char *belt_hash(const unsigned char *in, size_t in_len, unsigned char *md)
{
	BELThash_CTX c;
	static unsigned char m[32];

	if (md == NULL)
		md = m;
	BELT_hash_Init(&c);
	BELT_hash_Update(&c, in, in_len);
	BELT_hash_Final(&c, md);
	cleanse(&c, sizeof(c));
	return md;
}
