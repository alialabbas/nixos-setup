-- Load the default go compiler to get base build error formatting
vim.cmd("compiler go")
local base_efm = vim.bo.errorformat

-- Safe and Absolute Go Test efm:
vim.b.testefm = table.concat({
  [[%-G--- FAIL: %.%#]],
  [[%-GFAIL]],
  [[%-GFAIL\s%.%#]],
  -- 1. Location Only: Capture absolute paths from testify 'Error Trace'
  -- This line has no message, so the processor will store location and hide line.
  [[%*\sError\ Trace:%*\s%f:%l]],
  -- 2. Message Only: Capture the actual Error Message
  -- This line has no location, so the processor will use the stored location.
  [[%*\sError:%*\s%m]],
  -- 3. Both: Standard indented failure header (file:line: message)
  [[%*\s%f:%l:\ %m]],
  -- 4. Standard build errors
  base_efm
}, ",")

vim.b.testprg = "go test"