local async_utils = require("async.utils")

describe("async.utils", function()
  describe("line_buffered", function()
    it("should buffer partial lines", function()
      local results = {}
      local callback = function(lines, is_exit, exit_obj)
        table.insert(results, { lines = lines, is_exit = is_exit, exit_obj = exit_obj })
      end

      local handler = async_utils.line_buffered(callback)

      handler("hello", false)
      assert.are.equal(0, #results)

      handler(" world\nnext", false)
      assert.are.equal(1, #results)
      assert.are.same({ "hello world" }, results[1].lines)
      assert.is_false(results[1].is_exit)

      handler(" line\n", false)
      assert.are.equal(2, #results)
      assert.are.same({ "next line" }, results[2].lines)
      
      handler("last", false)
      handler(0, true)
      assert.are.equal(3, #results)
      assert.are.same({ "last" }, results[3].lines)
      assert.is_true(results[3].is_exit)
      assert.are.equal(0, results[3].exit_obj)
    end)

    it("should handle multiple lines in one chunk", function()
      local results = {}
      local callback = function(lines, is_exit, exit_obj)
        table.insert(results, { lines = lines, is_exit = is_exit, exit_obj = exit_obj })
      end

      local handler = async_utils.line_buffered(callback)

      handler("line1\nline2\nline3", false)
      assert.are.equal(1, #results)
      assert.are.same({ "line1", "line2" }, results[1].lines)

      handler("\n", false)
      assert.are.equal(2, #results)
      assert.are.same({ "line3" }, results[2].lines)
    end)

    it("should handle \r\n", function()
      local results = {}
      local callback = function(lines, is_exit)
        table.insert(results, { lines = lines, is_exit = is_exit })
      end

      local handler = async_utils.line_buffered(callback)

      handler("line1\r\nline2\r\n", false)
      assert.are.equal(1, #results)
      assert.are.same({ "line1", "line2" }, results[1].lines)
    end)
  end)

  describe("parse_item", function()
    it("should return nil for invalid input", function()
      assert.is_nil(async_utils.parse_item(nil, "%f:%l:%m"))
      assert.is_nil(async_utils.parse_item("foo", nil))
      assert.is_nil(async_utils.parse_item("foo", ""))
    end)

    it("should parse a valid line using efm", function()
      local line = "file.txt:10: Some error"
      local efm = "%f:%l:%m"
      local item = async_utils.parse_item(line, efm)
      
      assert.truthy(item)
      local filename = item.filename ~= "" and item.filename or vim.api.nvim_buf_get_name(item.bufnr)
      assert.is_true(filename:match("file.txt$") ~= nil)
      assert.are.equal(10, item.lnum)
      assert.are.equal(" Some error", item.text)
      assert.are.equal(1, item.valid)
    end)
  end)
end)
