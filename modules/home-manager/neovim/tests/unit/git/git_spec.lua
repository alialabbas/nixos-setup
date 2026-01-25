local async = require("async")
local git = require("git")

describe("Git Integration", function()
  local old_run = async.run
  local old_notify = vim.notify

  before_each(function()
    vim.notify = function() end
    local script_path = debug.getinfo(1).source:sub(2)
    local root = vim.fn.fnamemodify(script_path, ':p:h:h:h:h')
    vim.cmd("source " .. root .. "/plugin/git.lua")
  end)

  after_each(function()
    async.run = old_run
    vim.notify = old_notify
  end)

      it("ls_files should call async.run with git ls-files", function()
        local called_cmd
        async.run = function(cmd, opts)
          called_cmd = cmd
          return "mock_pid"
        end
  
        git.ls_files("-m")
        assert.are.same({ "git", "ls-files", "-m" }, called_cmd)
      end)
  
      it("ls_files should use the correct buffer name format", function()
        local project = vim.fn.fnamemodify(vim.uv.cwd(), ":t")
        local expected_name = "//git/" .. project
        
        -- Mock async.run to avoid actual execution
        async.run = function() return "mock_pid" end
        
        git.ls_files()
        
        local bufnr = vim.fn.bufnr("^" .. expected_name .. "$")
        assert.truthy(bufnr ~= -1)
      end)
  
      it("should intercept :Git ls-files command", function()
        local ls_files_called = false
        local old_ls_files = git.ls_files
        git.ls_files = function() ls_files_called = true end
  
        vim.cmd("Git ls-files")
        
        assert.is_true(ls_files_called)
        git.ls_files = old_ls_files
      end)
  
      it("should delegate other :Git commands to Fugitive", function()
        local g_called = false
        vim.api.nvim_create_user_command("G", function(opts)
          g_called = true
        end, { nargs = "*" })
  
        pcall(vim.cmd, "Git status")
  
        assert.is_true(g_called)
        vim.cmd("delcommand G")
      end)
  
      it("should provide completion for ls-files", function()
        local matches = git.complete("ls", "Git ls", 6)
        assert.is_true(vim.tbl_contains(matches, "ls-files"))
      end)
  
      it("should provide flag completion for ls-files", function()
        local matches = git.complete("-", "Git ls-files -", 15)
        assert.is_true(vim.tbl_contains(matches, "-m"))
        assert.is_true(vim.tbl_contains(matches, "--modified"))
      end)
  
              it("should aggregate custom subcommands with Fugitive results", function()
  
                -- In tests, we might need to mock both the function and its existence
  
                local old_exists = vim.fn.exists
                local old_getcompletion = vim.fn.getcompletion
  
                vim.fn.exists = function(expr)
  
                  if expr == "*FugitiveComplete" then return 1 end
  
                  if expr == "*fugitive#Complete" then return 0 end
  
                  return old_exists(expr)
  
                end

                vim.fn.getcompletion = function() return {} end
  
          
  
                -- Explicitly assert that FugitiveComplete is called
  
                local fugitive_called = false
  
                vim.fn["FugitiveComplete"] = function(ArgLead, CmdLine, CursorPos)
  
                  fugitive_called = true
  
                  local results = { "status", "commit", "log" }
  
                  local filtered = {}
  
                  for _, r in ipairs(results) do
  
                    if ArgLead == "" or string.find(r, ArgLead, 1, true) == 1 then
  
                      table.insert(filtered, r)
  
                    end
  
                  end
  
                  return filtered
  
                end
  
          
  
                -- Completing at 'Git '
  
                local matches = git.complete("", "Git ", 4)
  
                assert.is_true(fugitive_called, "FugitiveComplete was not called")
  
                assert.is_true(vim.tbl_contains(matches, "ls-files"))
  
                assert.is_true(vim.tbl_contains(matches, "status"))
  
          
  
                -- Completing at 'Git l'
  
                local l_matches = git.complete("l", "Git l", 5)
  
                assert.is_true(vim.tbl_contains(l_matches, "ls-files"))
  
                assert.is_true(vim.tbl_contains(l_matches, "log"))
  
                assert.is_false(vim.tbl_contains(l_matches, "status"))
  
          
  
                vim.fn["FugitiveComplete"] = nil
                vim.fn.exists = old_exists
                vim.fn.getcompletion = old_getcompletion
              end)

  
          
  
              it("should work correctly when fugitive#Complete is the source", function()
  
                local old_exists = vim.fn.exists
                local old_getcompletion = vim.fn.getcompletion
  
                vim.fn.exists = function(expr)
  
                  if expr == "*FugitiveComplete" then return 0 end
  
                  if expr == "*fugitive#Complete" then return 1 end
  
                  return old_exists(expr)
  
                end

                vim.fn.getcompletion = function() return {} end
  
          
  
                local fugitive_called = false
  
                vim.fn["fugitive#Complete"] = function(ArgLead, CmdLine, CursorPos)
  
                  fugitive_called = true
  
                  return { "checkout", "branch" }
  
                end
  
          
  
                local matches = git.complete("che", "Git che", 7)
  
                assert.is_true(fugitive_called, "fugitive#Complete was not called")
  
                assert.is_true(vim.tbl_contains(matches, "checkout"))
  
                assert.is_false(vim.tbl_contains(matches, "ls-files"))
  
          
  
                vim.fn["fugitive#Complete"] = nil
                vim.fn.exists = old_exists
                vim.fn.getcompletion = old_getcompletion
              end)

              it("should not truncate completion matches that don't include the command prefix", function()
                local old_getcompletion = vim.fn.getcompletion
                
                -- Simulate getcompletion returning just the subcommand, which is common
                vim.fn.getcompletion = function(line, type)
                  if line == "G chec" then
                    return { "checkout" }
                  end
                  return {}
                end

                local matches = git.complete("chec", "Git chec", 8)
                assert.is_true(vim.tbl_contains(matches, "checkout"))
                assert.is_false(vim.tbl_contains(matches, "eckout"))

                vim.fn.getcompletion = old_getcompletion
              end)
end)