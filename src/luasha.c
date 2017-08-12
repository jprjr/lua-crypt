#include "sha1.h"
#include "base64.h"
#include <string.h>
#include <stdio.h>

int luasha(const char *key, char *output) {
    char hash[20];
    char hash_b64[29];

    char *p = output;

    SHA1Context ctx;

    if(SHA1Reset(&ctx) != 0) {
        return 0;
    }

    if(SHA1Input(&ctx,(const uint8_t *)key,strlen(key)) != 0) {
        return 0;
    }

    if(SHA1Result(&ctx,(uint8_t *)hash) != 0) {
        return 0;
    }

    if(b64_encode((const uint8_t *)hash,20,(unsigned char *)hash_b64) <= 0) {
        return 0;
    }

    memcpy(p,"{SHA}",5);
    p += 5;
    memcpy(p,hash_b64,29);

    return 1;
}
