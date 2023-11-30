local PLUGIN_NAME = "jwt-clone"


-- helper function to validate data against a schema
local validate do
  local validate_entity = require("spec.helpers").validate_plugin_config_schema
  local plugin_schema = require("kong.plugins."..PLUGIN_NAME..".schema")

  function validate(data)
    return validate_entity(data, plugin_schema)
  end
end


describe(PLUGIN_NAME .. ": (schema)", function()

  -- Mục đích của đoạn mã này là khẳng định rằng khi trường "auth_header"
  -- không có giá trị (ngx.null), hàm validate()
  -- sẽ trả về kết quả không hợp lệ và thông báo lỗi "required field missing"
  -- sẽ được lưu trong biến "err.config.auth_header".
  -- it("auth_header is required", function()
  --   local ok, err = validate({
  --       auth_header = ngx.null,
  --     })
  --   assert.is_falsy(ok)
  --   assert.is_table(err)
  --   assert.equals('required field missing', err.config.auth_header)
  -- end)

end)
