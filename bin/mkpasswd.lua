#!/usr/bin/env lua
local crypt = require'crypt'

print('Select encryption method:')
print('  md5')
print('  sha')
print('  ssha')
print('  sha256')
print('  sha512')
io.stdout:write('Method? ')
local method = io.read()
io.stdout:write('\n')

if not crypt.methods[method] then
  print(string.format('Method %s not available',method))
  os.exit(1)
end

io.stdout:write('Warning: password will be visible on terminal!\n')
io.stdout:write('Password? ')
local password = io.read()

local enc = crypt.encrypt(method,password)

io.stdout:write('\n' .. enc .. '\n')
