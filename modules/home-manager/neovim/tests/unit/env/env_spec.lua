local env = require("env")

describe("env module", function()
  local old_notify = vim.notify
  local notifications = {}

  before_each(function()
    notifications = {}
    vim.notify = function(msg, level)
      table.insert(notifications, { msg = msg, level = level })
    end
  end)

  after_each(function()
    vim.notify = old_notify
  end)

  it("should set an environment variable", function()
    env.set("TEST_VAR", "test_value")
    assert.are.equal("test_value", vim.env.TEST_VAR)
    assert.are.equal(1, #notifications)
    assert.are.equal("Env: TEST_VAR=test_value", notifications[1].msg)
    assert.are.equal(vim.log.levels.INFO, notifications[1].level)
  end)

  it("should handle setting a value", function()
    env.set("TEST_VAR_2", "another_value")
    assert.are.equal("another_value", vim.env.TEST_VAR_2)
    assert.are.equal("Env: TEST_VAR_2=another_value", notifications[1].msg)
  end)

  it("should handle nil value as empty string (which might unset in some environments)", function()
    env.set("TEST_VAR_NIL", nil)
    -- We just check that it doesn't crash and it notifies. 
    -- Some OS/Nvim environments might return nil for empty env vars.
    assert.are.equal(1, #notifications)
    assert.are.equal("Env: TEST_VAR_NIL=", notifications[1].msg)
  end)

  it("should error on empty name", function()
    env.set("", "some_value")
    assert.are.equal(1, #notifications)
    assert.are.equal("Env set: Name required", notifications[1].msg)
    assert.are.equal(vim.log.levels.ERROR, notifications[1].level)
  end)

  it("should error on nil name", function()
    env.set(nil, "some_value")
    assert.are.equal(1, #notifications)
    assert.are.equal("Env set: Name required", notifications[1].msg)
    assert.are.equal(vim.log.levels.ERROR, notifications[1].level)
  end)
end)
