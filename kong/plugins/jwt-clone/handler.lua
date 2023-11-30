local http = require("resty.http")


local jwt_decoder = require "kong.plugins.jwt.jwt_parser"
local ngx_re_gmatch = ngx.re.gmatch
local cjson = require "cjson"

local function is_empty(s)
  return s == nil or s == ''
end

local function claim_split (inputstr, sep)

  local resutl = {}

  if sep == nil then
    sep = "%s"
  end

  local t = {}
  local parts = 0

  for str in string.gmatch(inputstr, "([^"..sep.."])") do
    parts = parts + 1
    table.insert(t, str)
  end

  if parts == 2 then
    result["key"] = t[1]
    resutl["value"] = t[2]
  else
    result = nil
  end

  return result
end

local function retrieve_token(request, conf)
  local authorization_header = request.get_headers()["authorization"]

  if not authorization_header then
    return kong.response.exit(500, "jwt-clone -- error when retrieving token, can't find authorization")
  end

  if authorization_header then
    local iterator, iter_err = ngx_re_gmatch(authorization_header, "\\s*[Bb]earer\\s+(.+)")

    if not iterator then
      return nil, iter_err
    end

    local m, err = iterator()

    if err then
      return nil, err
    end

    if m and #m > 0 then
      return m[1]
    end
  end
end

local function init_jwt_claims_config(conf)
  local result = {}

  for k,v in pairs(conf.claims) do
    result[k] = v
  end

  if (not is_empty(conf.validate_iss)) then
    result["iss"] = conf.validate_iss
  end

  if (not is_empty(conf.validate_sub)) then
      result["sub"] = conf.validate_sub
  end

  if (not is_empty(conf.validate_aud)) then
    result["aud"] = conf.validate_aud
  end

  if (not is_empty(conf.validate_azp)) then
    result["azp"] = conf.validate_azp
  end

  if (not is_empty(conf.validate_client_id)) then
    result["client_id"] = conf.validate_client_id
  end

  if (not is_empty(conf.validate_dynamic1)) then
    local claim_parts = claim_split(conf.validate_dynamic1,"==>")
    if not is_empty(claim_parts) then
      result[claim_parts["key"]]= claim_parts["value"]
    end
  end

  if (not is_empty(conf.validate_dynamic2)) then
    local claim_parts = claim_split(conf.validate_dynamic2,"==>")
    if not is_empty(claim_parts) then
      result[claim_parts["key"]]= claim_parts["value"]
    end
  end

  if (not is_empty(conf.validate_dynamic3)) then
    local claim_parts = claim_split(conf.validate_dynamic3,"==>")
    if not is_empty(claim_parts) then
      result[claim_parts["key"]]= claim_parts["value"]
    end
  end

  return result
end

local plugin = {
  PRIORITY = 1500, -- set the plugin priority, which determines plugin execution order
  VERSION = "0.1.1-1", -- version in X.Y.Z format. Check hybrid-mode compatibility requirements.
}

-- runs in the 'access_by_lua_block'
function plugin:access(plugin_conf)
  local set_header = kong.service.request.set_header
  local validate_claims = init_jwt_claims_config(plugin_conf)

  kong.log.inspect(validate_claims)

  local token, err = retrieve_token(ngx.req, plugin_conf)

  if err then
    return kong.response.exit(500, "jwt-clone -- error retrieving token")
  end
  kong.log.debug(token)
  if token then
    set_header("jwt-token", token)

    local jwt, err = jwt_decoder:new(token)
    if err then
      kong.log.error("Can't retrieve token!")
      return kong.response.exit(500, "jwt-clone -- token was found, but failed to be decoded")
    end

    local jwt_claims = jwt.claims
    local headers = kong.request.get_headers()

    kong.log.debug(jwt_claims)
    if(plugin_conf.option_expose_headers) then
      for k, v in pairs(jwt_claims) do
        if(plugin_conf.exposed_headers == "all" or string.match(","..plugin_conf.exposed_headers..",", ","..k..",")) then
          local entry_type = type(v)
          if entry_type == "string" then
            set_header("jwt-claim-"..k, v)
          else
            set_header("jwt-claim-"..k, cjson.encode(v))
          end
          kong.log.debug(k..": "..v)
        end
      end
    end
    kong.log.debug(headers)
    -- kong.log.debug("jwt-token: "..headers["jwt-token"])
    kong.log.debug(kong.request.get_raw_body())
    for claim_key,claim_value in pairs(validate_claims) do
      if jwt_claims[claim_key] == nil or jwt_claims[claim_key] ~= claim_value then
        kong.log.debug("jwt-clone- JSON Web Token has invalid claim value for '"..tostring(claim_key).."'")
        kong.log.debug("jwt-clone - JSON Web Token has invalid claim value for '"..tostring(claim_key).."' you sent '"..tostring(jwt_claims[claim_key]).."' expecting '"..tostring(claim_value).."'")
        return kong.response.exit(401, "jwt-clone - JSON Web Token has invalid claim value for '"..tostring(claim_key).."' you sent '"..tostring(jwt_claims[claim_key]).."' expecting '"..tostring(claim_value).."'")
      end
    end
  end
end

return plugin
