local function enable_transperency()
    vim.api.nvim_set_hl(0, "Normal", { bg = "none" })
end

return {
    "rose-pine/neovim",
    name = "rose-pine",
    config = function()
        vim.cmd("colorscheme rose-pine")
        enable_transperency();
    end
}
