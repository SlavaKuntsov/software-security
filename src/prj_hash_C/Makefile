CC = emcc
CFLAGS = -O2

pages:
	@mkdir -p build
	@${CC} ${CFLAGS} digest.c convert_hexbin.c belt_add.c belt_dgst.c  crypto_free.c -s WASM=1 -s EXPORTED_RUNTIME_METHODS="['ccall', 'cwrap']" -O3 -o ec.js
	@cp *.html build/
	@cp *.wasm build/
	@cp *.js build/

