local M = {}

---@class Async.TaskExitObj
---@field code number
---@field signal number

---@class Async.Task
---@field pid string|number
---@field cmd string[]
---@field name string
---@field sinks Async.Sink[]
---@field running boolean
---@field handle? any # vim.system handle
---@field complete? fun(obj?: Async.TaskExitObj) # Only for Lua tasks

---@class Async.Sink
---@field on_start? fun(task: Async.Task)
---@field on_stdout? fun(task: Async.Task, data: string)
---@field on_stderr? fun(task: Async.Task, data: string)
---@field on_exit? fun(task: Async.Task, obj: Async.TaskExitObj)
---@field validate? fun(task: Async.Task): boolean, string?

-- State: pid -> { handle, cmd, sinks, running }
---@type table<string|number, Async.Task>
local tasks = {}
local lua_task_counter = 0

local list_sink = require("async.sinks.list")

---@class Async.Sinks
---@field buffer {new: fun(opts?: Async.Sink.BufferOpts): Async.Sink}
---@field notify {new: fun(opts?: table): Async.Sink}
---@field fidget {new: fun(opts?: table): Async.Sink}
---@field quickfix {new: fun(opts?: Async.Sink.ListOpts): Async.Sink}
---@field loclist {new: fun(opts?: Async.Sink.ListOpts): Async.Sink}

---@type Async.Sinks
M.sinks = {
  buffer = require("async.sinks.buffer"),
  notify = require("async.sinks.notify"),
  fidget = require("async.sinks.fidget"),
  quickfix = {
    new = function(opts)
      opts = opts or {}
      opts.type = "quickfix"
      return list_sink.new(opts)
    end,
  },
  loclist = {
    new = function(opts)
      opts = opts or {}
      opts.type = "loclist"
      return list_sink.new(opts)
    end,
  },
}

---@param task Async.Task
---@param type "stdout"|"stderr"
---@param data string
local function dispatch(task, type, data)
  -- If task was already marked as not running, ignore incoming data immediately
  if not task.running then return end

  vim.schedule(function()
    -- Check again inside the scheduled callback in case it was stopped 
    -- while this callback was sitting in the queue
    if not task.running then return end

    for _, sink in ipairs(task.sinks) do
      if type == "stdout" and sink.on_stdout then
        sink.on_stdout(task, data)
      elseif type == "stderr" and sink.on_stderr then
        sink.on_stderr(task, data)
      end
    end
  end)
end

---@class Async.RunOpts
---@field sinks? Async.Sink[]
---@field cwd? string
---@field env? table<string, string|number>

---Run a command or a lua function as an async task
---@param target string|string[]|fun(emit: fun(data: string), task: Async.Task)
---@param opts? Async.RunOpts
---@return string|number pid
function M.run(target, opts)
  opts = opts or {}
  local is_lua = type(target) == "function"
  local cmd_list = not is_lua and (type(target) == "string" and { vim.o.shell, vim.o.shellcmdflag, target } or target) or nil
  local sinks = opts.sinks or {}

  ---@type Async.Task
  local task = {
    cmd = cmd_list or { "lua_task" },
    name = is_lua and "lua_task" or (type(target) == "string" and target or table.concat(target, " ")),
    sinks = sinks,
    running = true,
  }

  -- Validate sinks before starting
  for _, sink in ipairs(sinks) do
    if sink.validate then
      local ok, err = sink.validate(task)
      if not ok then
        error(string.format("Task validation failed: %s", err))
      end
    end
  end

  if is_lua then
    lua_task_counter = lua_task_counter + 1
    local task_id = "lua:" .. lua_task_counter
    task.pid = task_id
    tasks[task_id] = task

    task.complete = function(obj)
      vim.schedule(function()
        if not tasks[task_id] then return end
        task.running = false
        for _, sink in ipairs(sinks) do
          if sink.on_exit then sink.on_exit(task, obj or { code = 0, signal = 0 }) end
        end
        tasks[task_id] = nil
      end)
    end

    local emit = function(data)
      dispatch(task, "stdout", data .. "\n")
    end

    for _, sink in ipairs(sinks) do
      if sink.on_start then sink.on_start(task) end
    end

    local ok, err = pcall(target, emit, task)
    if not ok then
      emit("\n[Lua Error]: " .. tostring(err))
      task.complete({ code = 1, signal = 0 })
    end

    return task_id
  end

  local system_opts = {
    cwd = opts.cwd,
    env = opts.env,
    text = true,
    stdout = function(err, data)
      if data then dispatch(task, "stdout", data) end
    end,
    stderr = function(err, data)
      if data then dispatch(task, "stderr", data) end
    end,
  }

  local handle
  handle = vim.system(cmd_list, system_opts, function(obj)
    vim.schedule(function()
      -- If it wasn't already stopped manually
      if tasks[task.pid] then
        task.running = false
        for _, sink in ipairs(sinks) do
          if sink.on_exit then sink.on_exit(task, obj) end
        end
        tasks[task.pid] = nil
      end
    end)
  end)

  task.pid = handle.pid
  task.handle = handle
  tasks[task.pid] = task

  for _, sink in ipairs(sinks) do
    if sink.on_start then sink.on_start(task) end
  end

  return task.pid
end

---Stop a running task by pid
---@param pid string|number
function M.stop(pid)
  local task = tasks[pid]
  if task then
    task.running = false -- Flag immediately to stop processing backlog
    if task.handle then
      task.handle:kill("sigkill")
    end
    -- Remove from list immediately so UI reflects it's gone
    tasks[pid] = nil
    
    -- Notify sinks of premature exit if they have cleanups
    for _, sink in ipairs(task.sinks) do
      if sink.on_exit then
        sink.on_exit(task, { code = 128 + 9, signal = 9 }) -- Simulating SIGKILL exit
      end
    end
  end
end

---Stop all running tasks
function M.stop_all()
  for pid, _ in pairs(tasks) do
    M.stop(pid)
  end
  vim.notify("All tasks terminated.", vim.log.levels.INFO)
end

---List all running tasks
---@return {pid: string|number, cmd: string[], running: boolean}[]
function M.list()
  local result = {}
  for pid, task in pairs(tasks) do
    table.insert(result, { pid = pid, cmd = task.cmd, running = task.running })
  end
  return result
end

---Get status text for statusline
---@return string
function M.status()
  local count = 0
  local names = {}
  for _, task in pairs(tasks) do
    count = count + 1
    -- Use the first word of the name to keep statusline short
    local display_name = vim.split(task.name, " ")[1]
    table.insert(names, display_name)
  end

  if count == 0 then return "" end
  return string.format(" %d (%s)", count, table.concat(names, ","))
end

function M.debug_highlights()
-- ... (existing code)
end

-- Ensure all tasks are killed on exit
vim.api.nvim_create_autocmd("VimLeavePre", {
  callback = function()
    for pid, _ in pairs(tasks) do
      M.stop(pid)
    end
  end,
})

return M
