vim.g.mapleader = " "
vim.keymap.set("n", "<leader>cd", vim.cmd.Ex)
vim.keymap.set("i", "kj", "<Esc>", { noremap = true, silent = true })
vim.keymap.set('n', 'K', function()
    vim.diagnostic.open_float(0, { scope = "line", border = "rounded", focusable = true })
end, { noremap = true, silent = true })
vim.keymap.set('n', '<leader>h', function()
    local params = { textDocument = vim.lsp.util.make_text_document_params() }
    vim.lsp.buf_request(0, 'textDocument/inlayHint', params, function(err, result, ctx, _)
        if err then
            print('Error fetching inlay hints: ' .. err.message)
            return
        end
        local line = vim.api.nvim_win_get_cursor(0)[1] - 1
        for _, hint in ipairs(result or {}) do
            if hint.position.line == line then
                vim.api.nvim_echo({ { hint.label, 'Normal' } }, false, {})
            end
        end
    end)
end, { noremap = true, silent = true })
