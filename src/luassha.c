#include "sha1.h"
#include "base64.h"
#include <string.h>
#include <stdio.h>

int luassha(const char *key, const char *salt, char *output) {
    char hash[36];
    char hash_b64[49];
    char trimmed_salt[17];

    char *p = output;
    const char *s = salt + 6;
    char *h = hash + 20;

    size_t salt_len = strlen(s);
    if (s[salt_len-1] == '$') {
        salt_len--;
    }
    memcpy(trimmed_salt,s,salt_len);
    trimmed_salt[salt_len] = 0;

    SHA1Context ctx;

    if(SHA1Reset(&ctx) != 0) {
        return 0;
    }

    if(SHA1Input(&ctx,(const uint8_t *)key,strlen(key)) != 0) {
        return 0;
    }

    if(SHA1Input(&ctx,(const uint8_t *)trimmed_salt,salt_len) != 0) {
        return 0;
    }

    if(SHA1Result(&ctx,(uint8_t *)hash) != 0) {
        return 0;
    }
    memcpy(h,trimmed_salt,salt_len);

    if(b64_encode((const uint8_t *)hash,20 + salt_len,(unsigned char *)hash_b64) <= 0) {
        return 0;
    }

    memcpy(p,"{SSHA}",6);
    p += 6;
    memcpy(p,hash_b64,49);

    return 1;
}
