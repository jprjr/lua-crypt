CROSS =
CC = $(CROSS)gcc
AR = $(CROSS)ar
RANLIB = $(CROSS)ranlib
CFLAGS = -Wall -Wextra -Wno-missing-braces -Wno-sign-compare -fPIC -O3 -g0
LDFLAGS = "-s"
LUA = lua
LUA_LIBS = $(shell pkg-config --libs $(LUA))
LUA_CFLAGS = $(shell pkg-config --cflags $(LUA))
SO_SFX = so

.PHONY: all clean
.SUFFIXES:

all: crypt/core.a crypt/core.$(SO_SFX)

OBJS = src/crypt.o src/crypt_md5.o src/crypt_sha256.o src/crypt_sha512.o src/sha1.o src/luasha.o src/luassha.o src/base64.o

crypt/core.a: $(OBJS)
	mkdir -p crypt
	$(AR) rcs crypt/core.a $^
	$(RANLIB) crypt/core.a

crypt/core.$(SO_SFX): $(OBJS)
	$(CC) $(LDFLAGS) -shared $(LUA_LIBS) -o crypt/core.$(SO_SFX) $^

src/%.o: src/%.c
	$(CC) $(CFLAGS) $(LUA_CFLAGS) -o $@ -c $<

clean:
	rm -f crypt/core.a crypt/core.$(SO_SFX) crypt/core.so crypt/core.dll crypt/core.dylib $(OBJS)
	rmdir crypt
