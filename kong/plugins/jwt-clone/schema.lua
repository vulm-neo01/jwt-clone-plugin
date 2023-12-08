local typedefs = require "kong.db.schema.typedefs"


local PLUGIN_NAME = "jwt-clone2"

local schema = {
  name = PLUGIN_NAME,
  fields = {
    -- the 'fields' array is the top-level entry with fields defined by Kong
    { consumer = typedefs.no_consumer },  -- this plugin cannot be configured on a consumer (typical for auth plugins)
    { protocols = typedefs.protocols_http },
    { config = {
        type = "record",
        fields = {
          {
            zone_id = {
              description = "Zone identification",
              type = "string",
              -- default = "0",
            },
          },
          {
            network_type = {
              description = "Network type defined here: Viettel, Vina, Mobifone,...",
              type = "string",
              default = "0",-- Wifi
            },
          },
          {
            lang_list = {
              description = "Language can using",
              type = "array",
              elements = {
                type = "string",
              },
              default = {"vi","en",},
            },
          },
          {
            verified_IPs = {
              description = "List of IPs that from Viettel",
              type = "array",
              elements = {
                type = "string",
              },
              default = {
                "10.1.1.1",
                "10.1.0.0/16",
                "10.2.0.0/16",
                "10.3.0.0/16",
                "10.4.0.0/16",
                "10.5.0.0/16",
                "10.6.0.0/16",
                "10.7.0.0/16",
                "10.8.0.0/16",
                "10.9.0.0/16",
                "10.10.0.0/16",
                "10.11.0.0/16",
                "10.12.0.0/16",
              }
            }
          },
          { redis_host = typedefs.host },
          { redis_port = typedefs.port({
             default = 6379
            }),
          },
          { redis_password =
            {
              description = "When using the `redis` policy, this property specifies the password to connect to the Redis server.",
              type = "string",
              len_min = 0,
              referenceable = true
            },
          },
          { redis_username =
            {
              description = "When using the `redis` policy, this property specifies the username to connect to the Redis server when ACL authentication is desired.",
              type = "string",
              referenceable = true
            },
          },
          { redis_ssl =
            {
              description = "When using the `redis` policy, this property specifies if SSL is used to connect to the Redis server.",
              type = "boolean",
              required = true,
              default = false,
            },
          },
          { redis_ssl_verify =
            {
              description = "When using the `redis` policy with `redis_ssl` set to `true`, this property specifies it server SSL certificate is validated. Note that you need to configure the lua_ssl_trusted_certificate to specify the CA (or server) certificate used by your Redis server. You may also need to configure lua_ssl_verify_depth accordingly.",
              type = "boolean",
              required = true,
              default = false }, },
          { redis_server_name = typedefs.sni },
          { redis_timeout =
            {
              description = "When using the `redis` policy, this property specifies the timeout in milliseconds of any command submitted to the Redis server.",
              type = "number",
              default = 2000,
            },
          },
          { redis_database =
            {
              description = "When using the `redis` policy, this property specifies the Redis database to use.",
              type = "integer",
              default = 0
            },
          },
        }
      },
    },
  },
}

return schema
