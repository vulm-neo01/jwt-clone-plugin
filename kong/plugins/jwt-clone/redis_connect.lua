local redis = require "resty.redis"

local kong = kong
local null = ngx.null
local fmt = string.format

local function is_present(str)
  return str and str ~= "" and str ~= null
end

local sock_opts = {}

local function get_db_key(conf)
  return fmt("%s:%d;%d",
             conf.redis_host,
             conf.redis_port,
             conf.redis_database)
end


local function get_redis_connection(conf)
  local red = redis:new()
  red:set_timeout(conf.redis_timeout)

  sock_opts.ssl = conf.redis_ssl
  sock_opts.ssl_verify = conf.redis_ssl_verify
  sock_opts.server_name = conf.redis_server_name

  local db_key = get_db_key(conf)

  -- use a special pool name only if redis_database is set to non-zero
  -- otherwise use the default pool name host:port
  if conf.redis_database ~= 0 then
    sock_opts.pool = db_key
  end

  local ok, err = red:connect(conf.redis_host, conf.redis_port,
                              sock_opts)
  kong.log.debug(ok)
  if not ok then
    kong.log.err("failed to connect to Redis: ", err)
    return kong.response.exit(500, "failed to connect to Redis: "..err)
  end

  local times, err = red:get_reused_times()
  if err then
    kong.log.err("failed to get connect reused times: ", err)
    return kong.response.exit(500, "failed to get connect reused times: "..err)
  end

  if times == 0 then
    if is_present(conf.redis_password) then
      local ok, err
      if is_present(conf.redis_username) then
        ok, err = kong.vault.try(function(cfg)
          return red:auth(cfg.redis_username, cfg.redis_password)
        end, conf)
      else
        ok, err = kong.vault.try(function(cfg)
          return red:auth(cfg.redis_password)
        end, conf)
      end
      if not ok then
        kong.log.err("failed to auth Redis: ", err)
        return kong.response.exit(500, "failed to auth Redis: "..err)
      end
    end

    if conf.redis_database ~= 0 then
      -- Only call select first time, since we know the connection is shared
      -- between instances that use the same redis database

      local ok, err = red:select(conf.redis_database)
      if not ok then
        kong.log.err("failed to change Redis database: ", err)
        return kong.response.exit(500, "failed to change Redis database: "..err)
      end
    end
  end

  return red, db_key, err
end

local _M = {}

_M.__index = _M

function _M:get_data_from_redis(conf, key)
  local red, db_key, err = get_redis_connection(conf)
  if not red then
    return nil, err
  end

  local res, err = red:get(key)
  kong.log.debug(res)

  if res == ngx.null then
    -- The key doesn't exist in Redis
    res = nil
  end

  if err then
    kong.log.err("failed to get data from Redis: ", err)
    return nil, err
  end

  -- Đóng kết nối Redis để giải phóng tài nguyên
  local ok, err = red:set_keepalive(10000, 100)
  if not ok then
    kong.log.err("failed to set Redis keepalive: ", err)
  end


  return res
end

return _M
