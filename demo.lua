local crypt = require'crypt'

local password = 'password'

local tests = {
  { method = 'md5'},
  { method = 'md5',
    salt   = 'aaaaaaaa'},
  { method = 'sha' },
  { method = 'ssha'},
  { method = 'ssha',
    salt   = 'aaaaaaaa'},
  { method = 'apr1'},
  { method = 'apr1',
    salt   = 'aaaaaaaa'},
  { method = 'sha256'},
  { method = 'sha256',
    salt   = 'aaaaaaaaaaaaaaaa'},
  { method = 'sha512'},
  { method = 'sha512',
    salt   = 'aaaaaaaa'},
}

for _,v in ipairs(tests) do
  local hash, err = crypt.encrypt(v.method,password,v.salt)
  if err then
    print(err)
    os.exit(1)
  else
    v.hash = hash
  end
  if not v.salt then
    v.salt = ''
  end
  print(v.method .. '(' .. password .. ',' .. v.salt .. '): ' .. hash .. '\n')
end

for _,h in ipairs(tests) do
  if h.hash then
    local res = crypt.check(password,h.hash)
    local res_string = res and 'true' or 'false'
    print('crypt.check('..password..','..h.hash..') = ' .. res_string)
    if not res then
      os.exit(1)
    end
  end
end

