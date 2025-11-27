return {
    "ThePrimeagen/harpoon",
    -- Note: Ensure this branch is correct for your setup.
    -- The default is usually 'master' unless you explicitly want 'harpoon2'.
    branch = "harpoon2",
    dependencies = {
        -- *** FIX 1: ADD TELESCOPE AS A DEPENDENCY ***
        "nvim-telescope/telescope.nvim", 
        "nvim-lua/plenary.nvim",
    },
    config = function()
        -- Move the required Lua functions and variables INSIDE the config block.
        -- This ensures Telescope is loaded *before* Harpoon tries to use it.
        local conf = require("telescope.config").values
        local themes = require("telescope.themes")
        local harpoon = require("harpoon")

        -- *** FIX 2: Corrected 'prompt_title' spelling (optional but good practice) ***
        local function toggle_telescope(harpoon_files)
            local file_paths = {}
            for _, item in ipairs(harpoon_files.items) do
                table.insert(file_paths, item.value)
            end
            
            local opts = themes.get_ivy({
                prompt_title = "Working List" -- Corrected spelling from 'promt_title'
            })

            require("telescope.pickers").new(opts, {
                finder = require("telescope.finders").new_table {
                    results = file_paths,
                },
                previewer = conf.file_previewer(opts),
                sorter = conf.generic_sorter(opts),
            }):find()
        end

        -- Keymaps
        vim.keymap.set("n", "<leader>a", function() harpoon:list():add() end, { desc = "Harpoon: Add File" })
        vim.keymap.set("n", "<C-e>", function() harpoon.ui:toggle_quick_menu(harpoon:list()) end, { desc = "Harpoon: Toggle Menu" })
        vim.keymap.set("n", "<leader>fl", function() toggle_telescope(harpoon:list()) end, { desc = "Harpoon: Telescope List" })
        vim.keymap.set("n", "<C-p>", function() harpoon:list():prev() end, { desc = "Harpoon: Previous File" })
        vim.keymap.set("n", "<C-n>", function() harpoon:list():next() end, { desc = "Harpoon: Next File" })
    end
}
