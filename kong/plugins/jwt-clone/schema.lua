local typedefs = require "kong.db.schema.typedefs"


local PLUGIN_NAME = "jwt-clone"


local schema = {
  name = PLUGIN_NAME,
  fields = {
    -- the 'fields' array is the top-level entry with fields defined by Kong
    { consumer = typedefs.no_consumer },  -- this plugin cannot be configured on a consumer (typical for auth plugins)
    { protocols = typedefs.protocols_http },
    { config = {
        -- The 'config' record is the custom part of the plugin schema
        type = "record",
        fields = {
            -- Các trường cấu hình cho plugin
            { log_level = { type = "string", default = "info" } },
            { option_expose_headers = { type = "boolean", default = true } },
            { exposed_headers = { type = "string", default = "all" } },
            { validate_iss = { type = "string" } },
            { validate_sub = { type = "string" } },
            { validate_aud = { type = "string" } },
            { validate_azp = { type = "string" } },
            { validate_client_id = { type = "string" } },
            { validate_dynamic1 = { type = "string" } },
            { validate_dynamic2 = { type = "string" } },
            { validate_dynamic3 = { type = "string" } },
            { claims = {
                type = "map",
                keys = {
                    type = "string",
                    match_none = {
                        { pattern = "^$", err = "Claim name không thể để trống" },
                    },
                },
                values = {
                    type = "string",
                    match_none = {
                        { pattern = "^$", err = "Giá trị claim để kiểm tra không thể để trống" },
                    },
                },
                default = {}
            } },
        },
      },
    },
  },
}

return schema
