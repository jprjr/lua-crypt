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

Encryption methods are from the musl C library (also MIT-licensed),
see: https://git.musl-libc.org/cgit/musl/tree/src/crypt
