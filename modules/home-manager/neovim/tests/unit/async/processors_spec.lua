local processors = require("async.processors")

describe("async.processors", function()
  describe("create_processor", function()
    it("should process line with default pattern", function()
      local p = processors.create_processor(0)
      local line = "file.txt:10:5: some message"
      local clean, hls = p.process_line(line)
      
      assert.are.equal(line, clean)
      assert.are.equal(3, #hls)
      
      -- Filename
      assert.are.equal(0, hls[1][1])
      assert.are.equal(8, hls[1][2])
      assert.are.equal("Directory", hls[1][3])
      
      -- Line
      assert.are.equal(9, hls[2][1])
      assert.are.equal(11, hls[2][2])
      assert.are.equal("LineNr", hls[2][3])
      
      -- Col
      assert.are.equal(12, hls[3][1])
      assert.are.equal(13, hls[3][2])
      assert.are.equal("Special", hls[3][3])
    end)

    it("should pass through non-matching line without highlights", function()
      local p = processors.create_processor(0)
      local clean, hls = p.process_line("random text")
      assert.are.equal("random text", clean)
      assert.are.same({}, hls)
    end)

    it("should handle custom pattern", function()
      local p = processors.create_processor(0, { pattern = "ERROR (%w+):(.*)" })
      local line = "ERROR CODE1: message"
      local clean, hls = p.process_line(line)
      
      assert.are.equal(line, clean)
      -- captures: CODE1, message
      -- highlights: CODE1 (filename group), message (line group)
      assert.are.equal(2, #hls)
      assert.are.equal("CODE1", line:sub(hls[1][1]+1, hls[1][2]))
    end)
  end)

  describe("create_qf_processor", function()
    local old_getqflist = vim.fn.getqflist
    local old_bufname = vim.fn.bufname

    after_each(function()
      vim.fn.getqflist = old_getqflist
      vim.fn.bufname = old_bufname
    end)

    it("should track state across lines", function()
      local p = processors.create_qf_processor(0, { efm = "%f:%l:%c:%m" })
      
      -- First line with location
      vim.fn.getqflist = function() 
        return { items = { { valid = 1, bufnr = 1, filename = "a.txt", lnum = 1, col = 1, text = "msg1" } } }
      end
      vim.fn.bufname = function() return "a.txt" end

      local clean1, hls1 = p.process_line("a.txt:1:1:msg1")
      assert.are.equal("a.txt:1:1: msg1", clean1)

      -- Second line without location (continuation)
      vim.fn.getqflist = function() 
        return { items = { { valid = 1, bufnr = 0, filename = "", lnum = 0, col = 0, text = "msg2" } } }
      end
      vim.fn.bufname = function() return "" end

      local clean2, hls2 = p.process_line("msg2")
      assert.are.equal("a.txt:1:1: msg2", clean2)
    end)

    it("should NOT use current buffer (bufnr 0) as fallback filename", function()
      local p = processors.create_qf_processor(0, { efm = "Error: %m" })
      
      -- Mock getqflist to return bufnr 0 (current buffer) but no filename
      vim.fn.getqflist = function() 
        return { items = { { valid = 1, bufnr = 0, filename = "", lnum = 0, col = 0, text = "some error" } } }
      end
      -- Mock bufname(0) to return a name, which we want to IGNORE
      vim.fn.bufname = function(n) return n == 0 and "wrong_file.go" or "" end

      local clean, hls = p.process_line("Error: some error")
      
      -- It should be nil because it has no filename in state and we rejected bufnr 0
      assert.is_nil(clean)
    end)
  end)
end)
