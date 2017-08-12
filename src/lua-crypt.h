#ifndef _LUA_CRYPT_H
#define _LUA_CRYPT_H

int luamd5crypt(const char *key, const char *setting, char *output);
int luasha256crypt(const char *key, const char *setting, char *output);
int luasha512crypt(const char *key, const char *setting, char *output);
int luasha(const char *key, char *output);
int luassha(const char *key, const char *salt, char *output);

#endif
