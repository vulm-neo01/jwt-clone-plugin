local helpers = require "spec.helpers"

local PLUGIN_NAME = "jwt-clone"


for _, strategy in helpers.all_strategies() do
if strategy == "postgres" then
  describe(PLUGIN_NAME .. ": (access) [#" .. strategy .. "]", function()
    local client

    -- lazy_setup(function()

    --   -- Định nghĩa các route và plugins để kiểm thử
    --   local bp = helpers.get_db_utils(strategy == "off" and "postgres" or strategy, nil, { PLUGIN_NAME })

    --   -- Inject a test route. No need to create a service, there is a default
    --   -- service which will echo the request.
    --   local route1 = bp.routes:insert({
    --     hosts = { "test1.com" },
    --   })
    --   -- add the plugin to test to the route we created
    --   bp.plugins:insert {
    --     name = PLUGIN_NAME,
    --     route = { id = route1.id },
    --     config = {
    --       auth_url = "http://httpbin.org/status/200"
    --     },
    --   }

    --   local route2 = bp.routes:insert({
    --     hosts = { "test2.com" },
    --   })
    --   -- add the plugin to test to the route we created
    --   bp.plugins:insert {
    --     name = PLUGIN_NAME,
    --     route = { id = route2.id },
    --     config = {
    --       auth_url = "http://httpbin.org/status/403"
    --     },
    --   }

    --   -- start kong
    --   -- Thiết lập môi trường và chạy Kong
    --   assert(helpers.start_kong({
    --     -- set the strategy
    --     database   = strategy,
    --     -- use the custom test template to create a local mock server
    --     nginx_conf = "spec/fixtures/custom_nginx.template",
    --     -- make sure our plugin gets loaded
    --     plugins = "bundled," .. PLUGIN_NAME,
    --     -- write & load declarative config, only if 'strategy=off'
    --     declarative_config = strategy == "off" and helpers.make_yaml_file() or nil,
    --   }))
    -- end)

    -- lazy_teardown(function()
    --   helpers.stop_kong(nil, true)
    -- end)

    -- -- Chuẩn bị và dọn dẹp trước và sau mỗi bài kiểm thử
    -- before_each(function()
    --   client = helpers.proxy_client()
    -- end)

    -- after_each(function()
    --   if client then client:close() end
    -- end)

    -- -- Mô tả chi tiet các bài kiểm thử
    -- describe("request", function()
    --   it("gets a 'auth' header", function()
    --     local r = client:get("/request", {
    --       headers = {
    --         ["Mini-Auth"] = "sooper-secret",
    --         ["host"] = "test1.com"
    --       }
    --     })
    --     -- validate that the request succeeded, response status 200
    --     assert.response(r).has.status(200)
    --     local header_value = assert.request(r).has.header("mini-auth")
    --     assert.equal("sooper-secret", header_value)
    --   end)
    -- end)
  end)
end
end
