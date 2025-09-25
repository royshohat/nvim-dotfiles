return {
    'neovim/nvim-lspconfig',
    dependencies = {
        'williamboman/mason.nvim',
        'williamboman/mason-lspconfig.nvim',
        'hrsh7th/nvim-cmp',
        'hrsh7th/cmp-buffer',
        'hrsh7th/cmp-path',
        'saadparwaiz1/cmp_luasnip',
        'hrsh7th/cmp-nvim-lsp',
        'hrsh7th/cmp-nvim-lua',
        'L3MON4D3/LuaSnip',
        'rafamadriz/friendly-snippets',
    },
    config = function()
        local autoformat_filetypes = { "lua" }

        -- Autoformat on save for specific filetypes
        vim.api.nvim_create_autocmd('LspAttach', {
            -- args specifing the event deitals
            callback = function(args)
                -- get client (vim.lsp.client) by client id
                local client = vim.lsp.get_client_by_id(args.data.client_id)
                if not client then return end
                -- get the current buffer filetype and see if its in autoformat_filetypes tbl
                if vim.tbl_contains(autoformat_filetypes, vim.bo.filetype) then
                    vim.api.nvim_create_autocmd("BufWritePre", {
                        buffer = args.buf,
                        callback = function()
                            vim.lsp.buf.format({
                                formatting_options = { tabSize = 4, insertSpaces = true },
                                bufnr = args.buf,
                                id = client.id
                            })
                        end
                    })
                end
            end
        })

        -- Configure diagnostic signs and location list
        vim.diagnostic.config({
            virtual_text = true, -- disable inline text
            signs = true,
            underline = true,
            update_in_insert = false,
            severity_sort = true,
        })

        -- Keymaps when LSP attaches
        vim.api.nvim_create_autocmd('LspAttach', {
            callback = function(ev)
                local opts = { buffer = ev.buf }
                vim.keymap.set('n', 'K', '<cmd>lua vim.lsp.buf.hover()<cr>', opts)
                vim.keymap.set('n', 'gd', '<cmd>lua vim.lsp.buf.definition()<cr>', opts)
                vim.keymap.set('n', 'gD', '<cmd>lua vim.lsp.buf.declaration()<cr>', opts)
                vim.keymap.set('n', 'gi', '<cmd>lua vim.lsp.buf.implementation()<cr>', opts)
                vim.keymap.set('n', 'go', '<cmd>lua vim.lsp.buf.type_definition()<cr>', opts)
                vim.keymap.set('n', 'gr', '<cmd>lua vim.lsp.buf.references()<cr>', opts)
                vim.keymap.set('n', 'gs', '<cmd>lua vim.lsp.buf.signature_help()<cr>', opts)
                vim.keymap.set('n', '<F2>', '<cmd>lua vim.lsp.buf.rename()<cr>', opts)
                vim.keymap.set({ 'n', 'x' }, '<F3>', '<cmd>lua vim.lsp.buf.format({async = true})<cr>', opts)
                vim.keymap.set('n', '<F4>', '<cmd>lua vim.lsp.buf.code_action()<cr>', opts)
                vim.keymap.set('n', '<leader>lp', ':lopen<CR>', opts)
                vim.keymap.set('n', '<leader>ll', ':lclose<CR>', opts)
            end,
        })

        -- Setup Mason
        require('mason').setup({})
        require('mason-lspconfig').setup({
            ensure_installed = { "lua_ls", "gopls", "pyright", "clangd" },
            handlers = {
                function(server_name)
                    if server_name == "lua_ls" or server_name == "gopls" then return end
                    require('lspconfig')[server_name].setup({})
                end,
                lua_ls = function()
                    require('lspconfig').lua_ls.setup({
                        settings = {
                            Lua = {
                                diagnostics = { globals = { "vim" } },
                            },
                        },
                    })
                end,
                gopls = function()
                    require('lspconfig').gopls.setup({})
                end,
            },
        })

        -- Setup nvim-cmp completion
        local cmp = require('cmp')
        require('luasnip.loaders.from_vscode').lazy_load()
        vim.opt.completeopt = { 'menu', 'menuone', 'noselect' }

        cmp.setup({
            preselect = 'item',
            completion = { completeopt = 'menu,menuone,noinsert' },
            window = { documentation = cmp.config.window.bordered() },
            sources = {
                { name = 'path' },
                { name = 'nvim_lsp' },
                { name = 'nvim_lua' },
                { name = 'buffer',  keyword_length = 3 },
                { name = 'luasnip', keyword_length = 2 },
            },
            snippet = {
                expand = function(args)
                    require('luasnip').lsp_expand(args.body)
                end,
            },
            formatting = {
                fields = { 'abbr', 'menu', 'kind' },
                format = function(entry, item)
                    local n = entry.source.name
                    item.menu = n == 'nvim_lsp' and '[LSP]' or string.format('[%s]', n)
                    return item
                end,
            },
            mapping = cmp.mapping.preset.insert({
                ['<CR>'] = cmp.mapping.confirm({ select = false }),
                ['<C-f>'] = cmp.mapping.scroll_docs(1),
                ['<C-u>'] = cmp.mapping.scroll_docs(-1),
                ['<C-e>'] = cmp.mapping(function()
                    if cmp.visible() then cmp.abort() else cmp.complete() end
                end),
                ['<C-j>'] = cmp.mapping.select_next_item({ behavior = 'select' }),
                ['<C-k>'] = cmp.mapping.select_prev_item({ behavior = 'select' }),
                ['<C-d>'] = cmp.mapping(function(fallback)
                    local luasnip = require('luasnip')
                    if luasnip.jumpable(1) then luasnip.jump(1) else fallback() end
                end, { 'i', 's' }),
                ['<C-b>'] = cmp.mapping(function(fallback)
                    local luasnip = require('luasnip')
                    if luasnip.jumpable(-1) then luasnip.jump(-1) else fallback() end
                end, { 'i', 's' }),
            }),
        })
    end
}
