# lua-crypt

A small Lua module for encrypting passwords

## Usage:

* `local crypt = require'crypt'`

Initializes a new `crypt` object.

Object has the following methods:

* `hash, err = crypt.encrypt(method,key,salt)`
  * Encrypts `key` with given `method` and `salt`
  * `method` is one of:
    * `md5`
    * `apr1`
    * `sha`
    * `ssha`
    * `sha256`
    * `sha512`
  * `salt` is optional and will be randomly generated if not provided (except `sha` - don't encrypt new passwords with `sha`)
  * `err` will contain an error message, like if your salt is too small/large for the method
* `ok = crypt.check(key,hash)`
  * Check if a key encodes to a given hash

## Example:

```lua
local crypt = require'crypt'
local password = 'password'

print(crypt.encrypt('sha512',password,'aaaaaaaa'))
-- prints $6$aaaaaaaa$8rNtDLZ8RXl80fZr/95gEzOX1gZZSL2k8PeA8QihUS8vNBqdQSuQhNemROpSh/izYGOrflqsXDYtPr5f.f21I.

```



## LICENSE

MIT - see file `LICENSE`

Some encryption functions are from the musl C library (also MIT-licensed),
see: https://git.musl-libc.org/cgit/musl/tree/src/crypt

From musl:
  * src/crypt_md5.c
  * src/crypt_sha256.c
  * src/crypt_sha512.c

The base64 functions are from https://github.com/joedf/base64.c (also MIT-licensed).

From https://github.com/joedf/base64.c:
  * src/base64.c
  * src/base64.h

The sha1 functions (sha1.c, sha1.h) are from https://tools.ietf.org/html/rfc3174


