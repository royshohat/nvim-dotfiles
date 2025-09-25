require("config.options")
require("config.keybinds")
require("config.lazy")

-- autocommand for overriding default = formatting
vim.api.nvim_create_autocmd("LspAttach", {
    callback = function(_)
        vim.keymap.set("n", "<leader>fl", vim.lsp.buf.format)
    end,
})
