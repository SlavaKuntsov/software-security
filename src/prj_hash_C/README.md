# gen_ui

## Getting started
This project used belthash add imito writed C++. 
Build from C++ to wasm see in Makefile (You need to install same ......)
This project use CI GITLAB and deploy it to PAGES https://lwo-by.gitlab.io/gen_ui/index.html

##  Если собирать автономно у себя на компе
Для компиляции проекта нужно использовать компилятор Emscripten SDK (https://github.com/emscripten-core/emsdk). Предварительно необходимо установить интерпритатор Python.

* **Установка и настройка emsdk** <br>
```cd emsdk``` <br>
```emsdk install latest``` <br>
```emsdk activate latest``` <br>

* **Сборка проекта** <br>
```bash
emcc digest.c convert_hexbin.c belt_add.c belt_dgst.c belt_mac.c crypto_free.c -s WASM=1 -s EXPORTED_RUNTIME_METHODS="['ccall', 'cwrap']" -O3 -o ec.html
```


##  Если собирать автономно у себя на компе с использованием готового docker образа
* **Для docker** <br>
docker run \
  --rm \
  -v $(pwd):/src \
  -u $(id -u):$(id -g) \
  emscripten/emsdk \
emcc digest.c convert_hexbin.c belt_add.c belt_dgst.c belt_mac.c crypto_free.c -s WASM=1 -s EXPORTED_RUNTIME_METHODS="['ccall', 'cwrap']" -O3 -o ec.html


```
emcc ec.c bignum.c eccrypt.c -O3 -s WASM=1 -s EXPORTED_FUNCTIONS="['_initCurve']" -s EXPORTED_RUNTIME_METHODS="['ccall']" -o EC.js -s w
```


```-s WASM=1``` — Указывает, что мы хотим получить wasm модуль. <br>
```-o ec.html``` — Указывает, что мы хотим, чтобы Emscripten сгенерировал HTML-страницу запускающую наш код, а также сам модуль wasm и код JavaScript который позволит использовать модуль в веб-среде. <br>
```-s EXPORTED_RUNTIME_METHODS=["ccall"]``` — Экспортируем функцию ccall для запуска функций на СИ из JavaScript. <br>
```-O3``` — Уровень оптимизации при компиляции. <br>

* **запуск веб-сервера** <br>
```emrun ec2.html```    или используя файл serv.js: ```node serv.js```
