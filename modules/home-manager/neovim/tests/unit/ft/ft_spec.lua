describe("ft module (Helm logic)", function()
  local old_create_autocmd = vim.api.nvim_create_autocmd
  local old_fnamemodify = vim.fn.fnamemodify
  local old_filereadable = vim.fn.filereadable
  local old_fs_find = vim.fs.find
  local old_notify = vim.notify
  local old_system = vim.system
  local old_create_user_command = vim.api.nvim_create_user_command
  
  local helm_callback
  local helm_template_cmd

  before_each(function()
    -- Capture the helm autocmd callback
    vim.api.nvim_create_autocmd = function(events, opts)
      if type(opts.pattern) == "table" and opts.pattern[1] == "*/templates/*.yaml" then
        helm_callback = opts.callback
      end
    end
    
    vim.api.nvim_create_user_command = function(name, callback, opts)
        if name == "HelmTemplate" then
            helm_template_cmd = callback
        end
    end

    -- Mocks
    vim.fn.fnamemodify = function(path, mod) return path end -- simplistic
    vim.fn.filereadable = function() return 1 end
    vim.fs.find = function() return { "Chart.yaml" } end
    vim.notify = function() end
    _G.vim.opt_local = {}

    package.loaded["ft"] = nil
    require("ft")
  end)

  after_each(function()
    vim.api.nvim_create_autocmd = old_create_autocmd
    vim.fn.fnamemodify = old_fnamemodify
    vim.fn.filereadable = old_filereadable
    vim.fs.find = old_fs_find
    vim.notify = old_notify
    vim.system = old_system
    vim.api.nvim_create_user_command = old_create_user_command
  end)

  it("should detect helm file correctly when Chart.yaml is present", function()
    vim.fn.fnamemodify = function(p, m)
        if m == ":t" then return "my-template.yaml" end
        if m == ":h" then return "templates" end
        return p
    end
    
    helm_callback({ match = "templates/my-template.yaml" })
    
    assert.are.equal("helm", vim.opt_local.filetype)
    assert.are.equal(2, vim.opt_local.shiftwidth)
  end)

  it("should NOT detect helm file when Chart.yaml is missing", function()
    vim.fs.find = function() return {} end
    local notified = false
    vim.notify = function() notified = true end

    vim.fn.fnamemodify = function(p, m)
        if m == ":t" then return "my-template.yaml" end
        if m == ":h" then return "templates" end
        return p
    end

    helm_callback({ match = "templates/my-template.yaml" })
    
    assert.is_true(notified)
    assert.is_nil(vim.opt_local.filetype)
  end)

  it("should handle requirements.yaml only if Chart.yaml is in same dir", function()
    vim.fn.fnamemodify = function(p, m)
        if m == ":t" then return "requirements.yaml" end
        return p
    end
    
    -- Case 1: Chart.yaml missing
    vim.fn.filereadable = function() return 0 end
    helm_callback({ match = "requirements.yaml" })
    assert.is_nil(vim.opt_local.filetype)
    
    -- Case 2: Chart.yaml present
    vim.fn.filereadable = function() return 1 end
    helm_callback({ match = "requirements.yaml" })
    assert.are.equal("yaml", vim.opt_local.filetype)
  end)

  describe("HelmTemplate command", function()
    it("should call helm template and show result on success", function()
        -- Mock vim.system for helm template and sed
        vim.system = function(cmd, opts)
            return {
                wait = function()
                    if cmd[1] == "helm" then
                        return { code = 0, stdout = "templated content" }
                    end
                end
            }
        end

        local buf = vim.api.nvim_create_buf(false, true)
        local old_create_buf = vim.api.nvim_create_buf
        vim.api.nvim_create_buf = function() return buf end
        
        local old_get_current_win = vim.api.nvim_get_current_win
        vim.api.nvim_get_current_win = function() return 0 end -- current window

        local old_win_set_buf = vim.api.nvim_win_set_buf
        vim.api.nvim_win_set_buf = function() end

        -- Run the command captured in before_each
        helm_template_cmd()
        
        assert.are.equal("templated content", table.concat(vim.api.nvim_buf_get_text(buf, 0, 0, 0, -1, {}), ""))
        
        vim.api.nvim_buf_delete(buf, { force = true })
        vim.api.nvim_create_buf = old_create_buf
        vim.api.nvim_get_current_win = old_get_current_win
        vim.api.nvim_win_set_buf = old_win_set_buf
    end)
  end)
end)
