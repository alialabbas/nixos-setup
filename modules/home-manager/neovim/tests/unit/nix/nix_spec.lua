local nix = require("nix")
local async = require("async")

describe("nix module", function()
  local old_executable = vim.fn.executable
  local old_run = async.run
  local old_notify = vim.notify

  before_each(function()
    vim.fn.executable = function() return 1 end
    vim.notify = function() end
    async.run = function() end
  end)

  after_each(function()
    vim.fn.executable = old_executable
    async.run = old_run
    vim.notify = old_notify
  end)

  it("should notify if nix is missing", function()
    vim.fn.executable = function() return 0 end
    local notified = false
    vim.notify = function(msg, level)
      if msg:find("nix command not found") then notified = true end
    end
    
    nix.shell("pkg")
    assert.is_true(notified)
  end)

  it("should construct nix shell command correctly", function()
    local captured_cmd
    async.run = function(cmd, opts)
      captured_cmd = cmd
    end

    nix.shell("python3 jq")
    assert.are.same({
      "nix", "shell", "nixpkgs#python3", "nixpkgs#jq", "--command", "printenv", "PATH"
    }, captured_cmd)
  end)

  it("should respect existing flakes/shorthands in args", function()
    local captured_cmd
    async.run = function(cmd, opts)
      captured_cmd = cmd
    end

    nix.shell("nixpkgs#hello .#my-pkg")
    assert.are.same({
      "nix", "shell", "nixpkgs#hello", ".#my-pkg", "--command", "printenv", "PATH"
    }, captured_cmd)
  end)

  it("should update PATH on success", function()
    local old_path = vim.env.PATH
    local sink_callbacks
    async.run = function(cmd, opts)
      sink_callbacks = opts.sinks[2]
    end

    nix.shell("hello")
    
    sink_callbacks.on_stdout(nil, "/new/path")
    sink_callbacks.on_exit(nil, { code = 0 })

    assert.are.equal("/new/path", vim.env.PATH)
    vim.env.PATH = old_path
  end)
end)
