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
        }
      },
    },
  },
}

return schema
