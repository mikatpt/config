-- Apparently has to be global for treesitter to pick up on it
function __Disable_on_large_files(_, bufnr)
    local max_size = 100 * 1024 -- 100KB
    local file_size = vim.fn.getfsize(vim.api.nvim_buf_get_name(bufnr))

    if file_size > max_size then
        if not vim.b.__disable_large_called then
            vim.defer_fn(function()
                vim.notify('mikatpt: disabling Treesitter for files > 100KB', vim.log.levels.WARN)
                if vim.fn.exists(':IndentBlanklineDisable') then
                    vim.cmd(':IndentBlanklineDisable')
                end
            end, 50)
        end
        vim.b.__disable_large_called = true

        return true
    end
    return false
end

return function()
    require('nvim-treesitter.configs').setup({
        ensure_installed = 'all',
        ignore_install = { 'tlaplus', 'norg' },
        autotag = { enable = true },
        autopairs = { enable = true },
        indent = {
            enable = true,
            disable = { 'python', 'lua', 'go', 'yaml', 'json', 'jsonc', 'html', 'css', 'rust', 'markdown_inline' },
        },
        highlight = {
            enable = true, -- false will disable the whole extension
            disable = __Disable_on_large_files,
            -- Setting this to true will run `:h syntax` and tree-sitter at the same time.
            -- Set this to `true` if you depend on 'syntax' being enabled (like for indentation).
            -- Using this option may slow down your editor, and you may see some duplicate highlights.
            -- Instead of true it can also be a list of languages
            additional_vim_regex_highlighting = true,
        },
        -- From treesitter-refactor plugin
        refactor = {
            highlight_definitions = {
                enable = true,
                disable = __Disable_on_large_files,
            },
            highlight_current_scope = { enable = false },
            navigation = { enable = false },
            smart_rename = { enable = false },
        },
        -- from textobjects plugin
        textobjects = {
            select = {
                enable = true,
                lookahead = true, -- Automatically jump forward to textobj, similar to targets.vim
                keymaps = {
                    ['aa'] = '@parameter.outer',
                    ['ia'] = '@parameter.inner',
                    ['af'] = '@function.outer',
                    ['if'] = '@function.inner',
                    ['ac'] = '@class.outer',
                    -- You can optionally set desc = to the mappings (used in the desc parameter of
                    -- nvim_buf_set_keymap) which plugins like which-key display
                    ['ic'] = { query = '@class.inner', desc = 'Select inner part of a class region' },
                },
                -- You can choose the select mode (default is charwise 'v')
                --
                -- Can also be a function which gets passed a table with the keys
                -- * query_string: eg '@function.inner'
                -- * method: eg 'v' or 'o'
                -- and should return the mode ('v', 'V', or '<c-v>') or a table
                -- mapping query_strings to modes.
                selection_modes = {
                    ['@parameter.outer'] = 'v', -- charwise
                    ['@function.outer'] = 'V', -- linewise
                    ['@class.outer'] = '<c-v>', -- blockwise
                },
                -- If you set this to `true` (default is `false`) then any textobject is
                -- extended to include preceding or succeeding whitespace. Succeeding
                -- whitespace has priority in order to act similarly to eg the built-in
                -- `ap`.
                --
                -- Can also be a function which gets passed a table with the keys
                -- * query_string: eg '@function.inner'
                -- * selection_mode: eg 'v'
                -- and should return true of false
                include_surrounding_whitespace = false,
            },
        },
        incremental_selection = {
            enable = true,
            disable = __Disable_on_large_files,
        },
        move = {
            enable = true,
            set_jumps = true, -- whether to set jumps in the jumplist
            goto_next_start = {
                [']m'] = '@function.outer',
                [']]'] = '@class.outer',
            },
            goto_next_end = {
                [']M'] = '@function.outer',
                [']['] = '@class.outer',
            },
            goto_previous_start = {
                ['[m'] = '@function.outer',
                ['[['] = '@class.outer',
            },
            goto_previous_end = {
                ['[M'] = '@function.outer',
                ['[]'] = '@class.outer',
            },
        },
        swap = {
            enable = true,
            swap_next = {
                ['<leader>a'] = '@parameter.inner',
            },
            swap_previous = {
                ['<leader>A'] = '@parameter.inner',
            },
        },
    })
end
