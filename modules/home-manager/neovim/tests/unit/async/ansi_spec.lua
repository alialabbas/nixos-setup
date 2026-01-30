local ansi = require("async.ansi")

describe("ANSI processing", function()
  it("should strip ANSI codes correctly", function()
    local input = "\27[31mRed Text\27[0m Plain"
    local expected = "Red Text Plain"
    assert.are.equal(expected, ansi.strip(input))
  end)

  it("should generate correct highlight ranges", function()
    local bufnr = vim.api.nvim_create_buf(false, true)
    local processor = ansi.create_processor(bufnr)
    
    local input = "\27[31mRed\27[32mGreen\27[0m"
    local clean, highlights = processor.process_line(input)
    
    assert.are.equal("RedGreen", clean)
    assert.are.equal(2, #highlights)
    
    -- Red part
    assert.are.equal(0, highlights[1][1]) -- start col
    assert.are.equal(3, highlights[1][2]) -- end col
    assert.are.equal("DiagnosticError", highlights[1][3])
    
    -- Green part
    assert.are.equal(3, highlights[2][1])
    assert.are.equal(8, highlights[2][2])
    assert.are.equal("DiagnosticOk", highlights[2][3])
    
    vim.api.nvim_buf_delete(bufnr, { force = true })
  end)

  it("should handle bright colors (90-97)", function()
    local bufnr = vim.api.nvim_create_buf(false, true)
    local processor = ansi.create_processor(bufnr)
    
    local input = "\27[91mBrightRed\27[92mBrightGreen\27[0m"
    local clean, highlights = processor.process_line(input)
    
    assert.are.equal("BrightRedBrightGreen", clean)
    assert.are.equal(2, #highlights)
    assert.are.equal("DiagnosticError", highlights[1][3])
    assert.are.equal("DiagnosticOk", highlights[2][3])
    
    vim.api.nvim_buf_delete(bufnr, { force = true })
  end)

  it("should handle resets and state correctly", function()
    local bufnr = vim.api.nvim_create_buf(false, true)
    local processor = ansi.create_processor(bufnr)
    
    local line1 = "\27[31mStart"
    local clean1, hls1 = processor.process_line(line1)
    assert.are.equal("Start", clean1)
    assert.are.equal("DiagnosticError", hls1[1][3])
    
    local line2 = "Continue\27[0m End"
    local clean2, hls2 = processor.process_line(line2)
    assert.are.equal("Continue End", clean2)
    -- Highlights should only apply to "Continue" because of reset \27[0m
    assert.are.equal(1, #hls2)
    assert.are.equal(0, hls2[1][1])
    assert.are.equal(8, hls2[1][2])
    
    vim.api.nvim_buf_delete(bufnr, { force = true })
  end)
end)
