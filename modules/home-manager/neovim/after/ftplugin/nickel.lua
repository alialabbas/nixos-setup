-- Set the file type
vim.api.nvim_set_option_value("filetype", "nickel", { buf = 0 })
vim.api.nvim_set_option_value("commentstring", "# %s", { buf = 0 })
vim.treesitter.query.set("nickel", "folds",
    "[(uni_record)  (match_expr) (type_atom) (atom)]@fold")
-- This just overrides the variable selection to support multi variable function
vim.treesitter.query.set("nickel", "highlights",
    [[
                (comment) @comment @spell
                [
                  "forall"
                  "in"
                  "let"
                  "default"
                  "doc"
                  "rec"
                ] @keyword

                "fun" @keyword.function

                "import" @keyword.import

                [
                  "if"
                  "then"
                  "else"
                ] @keyword.conditional

                "match" @keyword.conditional

                (types) @type

                "Array" @type.builtin

                ; BUILTIN Constants
                (bool) @boolean

                "null" @constant.builtin

                (num_literal) @number

                (infix_op) @operator

                (type_atom) @type

                (enum_tag) @variable

                (chunk_literal_single) @string

                (chunk_literal_multi) @string

                (str_esc_char) @string.escape

                [
                  "{"
                  "}"
                  "("
                  ")"
                  "[|"
                  "|]"
                ] @punctuation.bracket

                (multstr_start) @punctuation.bracket

                (multstr_end) @punctuation.bracket

                (interpolation_start) @punctuation.bracket

                (interpolation_end) @punctuation.bracket

                (record_field) @variable.member

                (builtin) @function.builtin

                (fun_expr
                   (pattern_fun
                    (ident) @variable.parameter))

                (applicative
                  t1: (applicative
                    (record_operand) @function))
            ]])
