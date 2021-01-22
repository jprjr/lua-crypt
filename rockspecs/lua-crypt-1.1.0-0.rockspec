package = "lua-crypt"
version = "1.1.0-0"

source = {
    url = "https://github.com/jprjr/lua-crypt/archive/1.1.0.tar.gz",
    file= "lua-crypt-1.1.0.tar.gz"
}

description = {
    summary = "A small library for encrypting passwords, similar to crypt(3)",
    homepage = "https://github.com/jprjr/lua-crypt",
    maintainer = "John Regan <john@jrjrtech.com>",
    license = "MIT"
}

dependencies = {
    "lua",
}

build = {
    type = "builtin",
    modules = {
        ['crypt'] = 'crypt.lua',
        ['crypt.core'] = {
            sources = {
              'src/base64.c',
              'src/crypt.c',
              'src/crypt_blowfish.c',
              'src/crypt_md5.c',
              'src/crypt_sha256.c',
              'src/crypt_sha512.c',
              'src/luasha.c',
              'src/luassha.c',
              'src/sha1.c',
            },
        }
    }
}

