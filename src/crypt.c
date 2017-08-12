#include <lua.h>
#include <lauxlib.h>
#include "lua-crypt.h"
#include "base64.h"

#if !defined(luaL_newlibtable) \
  && (!defined LUA_VERSION_NUM || LUA_VERSION_NUM==501)
static void luaL_setfuncs (lua_State *L, const luaL_Reg *l, int nup) {
  luaL_checkstack(L, nup+1, "too many upvalues");
  for (; l->name != NULL; l++) {  /* fill the table with given functions */
    int i;
    lua_pushstring(L, l->name);
    for (i = 0; i < nup; i++)  /* copy upvalues to the top */
      lua_pushvalue(L, -(nup+1));
    lua_pushcclosure(L, l->func, nup);  /* closure with those upvalues */
    lua_settable(L, -(nup + 3));
  }
  lua_pop(L, nup);  /* remove upvalues */
}
#endif

int luacrypt(const char *key,const char *salt,char *output) {
    if(salt[1] == '1' && salt[2] == '$') {
        return luamd5crypt(key,salt,output);
    }
    if(salt[1] == 'a' && salt[5] == '$') {
        return luamd5crypt(key,salt,output);
    }
    if(salt[1] == '5' && salt[2] == '$') {
        return luasha256crypt(key,salt,output);
    }
    if(salt[1] == '6' && salt[2] == '$') {
        return luasha512crypt(key,salt,output);
    }
    if(salt[0] == '{' && salt[4] == '}') {
        return luasha(key,output);
    }
    if(salt[0] == '{' && salt[5] == '}') {
        return luassha(key,salt,output);
    }
    return 0;
}

int luabase64encode(const char *in, size_t in_len, char *encoded) {
    if(b64_encode((const uint8_t *)in,in_len,(unsigned char *)encoded) <= 0) {
        return 0;
    }
    return 1;
}

int luabase64decode(const char *in, size_t in_len, char *decoded) {
    if(b64_decode((const uint8_t *)in,in_len,(unsigned char *)decoded) <= 0) {
        return 0;
    }
    return 1;
}

int lua_base64_encode(lua_State *L) {
    const char* in;
    char *encoded;
    size_t in_len = 0;
    size_t encoded_len = 0;

    in = lua_tolstring(L,1,&in_len);
    if(!in) {
        lua_pushnil(L);
        return 1;
    }
    encoded_len = b64e_size(in_len) + 1;
    encoded = (char *)lua_newuserdata(L,encoded_len);

    if(!luabase64encode(in,in_len,encoded)) {
        lua_pushnil(L);
        return 1;
    }
    lua_pushlstring(L,encoded,encoded_len-1);
    return 1;
}

int lua_base64_decode(lua_State *L) {
    const char* encoded;
    char *decoded;
    size_t encoded_len = 0;
    size_t decoded_len = 0;
    encoded = lua_tolstring(L,1,&encoded_len);
    if(!encoded) {
        lua_pushnil(L);
        return 1;
    }
    decoded_len = b64d_size(encoded_len);
    decoded = (char *)lua_newuserdata(L,decoded_len);

    if(!decoded) {
        lua_pushnil(L);
        return 1;
    }

    if(!luabase64decode(encoded,encoded_len,decoded)) {
        lua_pushnil(L);
        return 1;
    }

    lua_pushlstring(L,decoded,decoded_len);
    return 1;
}


int lua_crypt(lua_State *L) {
    int hashed = 0;
    char *hash;
    const char* key = luaL_checkstring(L,1);
    const char* salt = luaL_checkstring(L,2);

    if(!key || !salt) {
        lua_pushnil(L);
        return 1;
    }

    hash = (char*)lua_newuserdata(L,128);
    if(!hash) {
        lua_pushnil(L);
        return 1;
    }

    hashed = luacrypt(key,salt,hash);

    if(hashed) {
        lua_pushstring(L,hash);
        return 1;
    }
    lua_pushnil(L);
    return 1;
}

static const struct luaL_Reg functions [] = {
    {"crypt", lua_crypt},
    {"base64_decode",lua_base64_decode},
    {"base64_encode",lua_base64_encode},
    {NULL, NULL}
};

int luaopen_crypt_core(lua_State *L) {
    lua_newtable(L);
    luaL_setfuncs(L,functions,0);
    return 1;
}
