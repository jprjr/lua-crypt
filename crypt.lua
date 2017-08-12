-- luacheck: globals ngx
local modname = { 'crypt','core' }
local concat = table.concat
local allowed_chars = './0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz'
local math = require'math'
local random = math.random
local randomseed = math.randomseed
local time = os.time
local gmatch = string.gmatch
local gsub = string.gsub
local sub = string.sub
local len = string.len
local find = string.find
local lower = string.lower
local open = io.open
local close = io.close

local base64_decode, base64_encode

local methods = {
  ['md5'] = {
    prefix = '$1$',
    min_salt = 8,
    max_salt = 8,
  },
  ['sha256'] = {
    prefix = '$5$',
    min_salt = 8,
    max_salt = 16,
  },
  ['sha512'] = {
    prefix = '$6$',
    min_salt = 8,
    max_salt = 16,
  },
  ['apr1'] =  {
    prefix = '$apr1$',
    min_salt = 8,
    max_salt = 8,
  },
  ['sha'] = {
    prefix = '{SHA}',
    min_salt = 0,
    max_salt = 0,
  },
  ['ssha'] = {
    prefix = '{SSHA}',
    min_salt = 8,
    max_salt = 16,
  },
}

methods['sha-256'] = methods['sha256']
methods['sha-512'] = methods['sha512']

local M = {}
M.methods = methods

local function split_hash(hash)
  if sub(hash,1,1) == '$' then
    local index = find(hash,'%$[^%$]*$')
    return sub(hash,1,index), sub(hash,index+1)
  elseif sub(hash,1,1) == '{' then
    if sub(hash,5,5) == '}' then
      return '{SHA}', ''
    elseif sub(hash,6,6) == '}' then
      local bin = base64_decode(sub(hash,7))
      local salt = sub(bin,21)
      return '{SSHA}' .. salt, base64_encode(sub(bin,1,20))
    end
  end
end

local function get_salt(method,salt)
  if not methods[lower(method)] then
    return nil, 'unsupported hash method'
  end

  if salt then
    if len(salt) < methods[lower(method)].min_salt then
      return nil, 'salt too small (minimum ' .. methods[lower(method)].min_salt .. ' bytes)'
    end
    if len(salt) > methods[lower(method)].max_salt then
      return nil, 'salt too large (maximum ' .. methods[lower(method)].max_salt .. ' bytes)'
    end
  end

  salt = salt or ''
  if len(salt) == 0 then
    randomseed(time())
    while len(salt) < methods[lower(method)].max_salt do
      local r = random(1,64)
      salt = salt .. sub(allowed_chars,r,r)
    end
  end

  salt = methods[lower(method)].prefix .. salt .. '$'
  return salt
end

local ok, ffi = pcall(require,'ffi')

if not ok then -- we must be in regular Lua, just use normal C module
  local c_table = require(concat(modname,'.'))
  base64_decode = c_table.base64_decode
  base64_encode = c_table.base64_encode

  local function encrypt(method, key, salt)
    local err
    salt, err = get_salt(method,salt)
    if not salt then
      return nil, err
    end
    return c_table.crypt(key,salt)
  end

  local function check(key,hash)
    local salt = split_hash(hash)
    local hash_test = c_table.crypt(key,salt)

    return hash_test == hash
  end

  M.encrypt = encrypt
  M.check = check

  return M
end

local crypt_lib -- save reference to library/namespace

if ngx then
  base64_encode = ngx.encode_base64
  base64_decode = ngx.decode_base64
  ffi.cdef[[
    int luacrypt(const char *key, const char *salt, char *output);
  ]]
else
  ffi.cdef[[
    int luacrypt(const char *key, const char *salt, char *output);
    int luabase64encode(const char *in, size_t in_len, char *encoded);
    int luabase64decode(const char *in, size_t in_len, char *decoded);
  ]]
end

local hash = ffi.new("char[?]",128)

pcall(function()
  if ffi.C.luacrypt then -- we're in a static binary, already linked, etc
      crypt_lib = ffi.C
  end
end)

if not crypt_lib then -- module not already linked, try to find and open dynamically
  local dir_sep, sep, ssub

  for m in gmatch(package.config, '[^\n]+') do
      local t = gsub(m,'([^%w])','%%%1')
      if not dir_sep then dir_sep = t
          elseif not sep then sep = t
          elseif not ssub then ssub = t end
  end

  local lib_name = concat(modname,dir_sep)

  for m in gmatch(package.cpath, '[^' .. sep ..';]+') do
    local so_path, r = gsub(m,ssub,lib_name)
    if(r > 0) then
      local f = open(so_path)
        if f ~= nil then
          close(f)
          crypt_lib = ffi.load(so_path)
          break
        end
    end
  end

end

if not crypt_lib then
  return nil,'failed to load module'
end

if not base64_decode then
  base64_decode = function(s)
    local decoded = ffi.new("char[?]",128)
    if(crypt_lib.luabase64decode(s,len(s),decoded)) then
      return ffi.string(decoded)
    end
    return nil
  end
  base64_encode = function(s)
    local encoded = ffi.new("char[?]",128)
    if(crypt_lib.luabase64encode(s,len(s),encoded)) then
      return ffi.string(encoded)
    end
    return nil
  end
end

-- now we return the real guts of the module
M.encrypt = function(method,key,salt)
  local err
  salt, err = get_salt(method,salt)
  if not salt then
    return nil, err
  end

  if(crypt_lib.luacrypt(key,salt,hash)) then
    return ffi.string(hash)
  end
  return nil
end

M.check = function(key,exthash)
  local salt = split_hash(exthash)
  if(crypt_lib.luacrypt(key,salt,hash)) then
    return ffi.string(hash) == exthash
  end
  return nil
end

return M


