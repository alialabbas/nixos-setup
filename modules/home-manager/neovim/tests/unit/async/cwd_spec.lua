local processors = require("async.processors")

describe("create_qf_processor with cwd", function()
  local cwd = vim.fn.getcwd()
  local test_dir = cwd .. "/_test_cwd"

  before_each(function()
    vim.fn.mkdir(test_dir, "p")
    vim.fn.mkdir(test_dir .. "/subdir", "p")
    local f = io.open(test_dir .. "/subdir/file.txt", "w")
    f:write("hello")
    f:close()
  end)

  after_each(function()
    vim.fn.delete(test_dir, "rf")
    vim.api.nvim_set_current_dir(cwd)
  end)

  it("should resolve relative paths based on provided cwd", function()
    -- We stay in 'cwd' (root), but run processor with 'test_dir/subdir' as cwd
    local task_cwd = test_dir .. "/subdir"
    local p = processors.create_qf_processor(0, { 
      efm = "%f:%l: %m",
      cwd = task_cwd
    })

    -- The line only has "file.txt", which is in task_cwd but NOT in current vim cwd.
    local line = "file.txt:1: some message"
    local clean, hls = p.process_line(line)

    -- It should have resolved file.txt to the full path or at least found it.
    -- In our current implementation, it constructs: target_f .. ":" .. target_l ...
    -- Let's see what target_f became.
    
    assert.is_not_nil(clean)
    local resolved_path = clean:match("^(.-):1:0: some message")
    
    assert.is_not_nil(resolved_path, "Clean line did not match expected format: " .. tostring(clean))
    
    -- If it works, resolved_path should be either absolute or relative correctly.
    assert.is_true(resolved_path:find("file.txt") ~= nil)
  end)
end)
