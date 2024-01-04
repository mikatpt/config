---@diagnostic disable: param-type-mismatch
local M = {}

M.fn = {}

local bind = function(mode, outer_opts)
    outer_opts = outer_opts or { silent = true }
    return function(lhs, rhs, opts)
        opts = vim.tbl_extend('force', outer_opts, opts or {})
        vim.keymap.set(mode, lhs, rhs, opts)
    end
end

local map_lsp = function(mode, lhs, rhs, opts)
    local redraw = '<CMD>lua require"core.utils".fn.redraw_lsp()<CR>'
    vim.api.nvim_set_keymap(mode, lhs, rhs .. redraw, opts or { silent = true, noremap = true })
end

M.keybinds = {}

M.keybinds.imap = bind('i', { silent = true, noremap = false })
M.keybinds.smap = bind('s', { silent = true, noremap = false })
M.keybinds.xnoremap = bind('x')
M.keybinds.nnoremap = bind('n')
M.keybinds.vnoremap = bind('v')
M.keybinds.inoremap = bind('i')
M.keybinds.cnoremap = bind('c')
M.keybinds.icnoremap = bind('!')
M.keybinds.noreabbrev = bind('na')
M.keybinds.cnoreabbrev = bind('ca')
M.keybinds.map_lsp = map_lsp

-- TODO: change to use vim.fn.system
local windows_git_dir = function()
    vim.cmd('silent! !git rev-parse --is-inside-work-tree')
    return vim.v.shell_error == 0
end

M.fn.is_git_dir = function()
    if vim.loop.os_uname().sysname == 'Windows_NT' then
        return windows_git_dir()
    end
    return os.execute('git rev-parse --is-inside-work-tree >> /dev/null 2>&1') == 0
end

M.fn.redraw_lsp = function()
    for _, id in pairs(vim.tbl_keys(vim.lsp.get_clients())) do
        vim.diagnostic.disable(0, id)
        vim.diagnostic.enable(0, id)
    end
end

M.fn.reload_lsp = function()
    local active = require('lspconfig').util.get_active_clients_list_by_ft(vim.bo.filetype)
    if #active > 0 then
        vim.cmd('LspRestart')
    end
end

M.fn.reload_config = function()
    -- Plenary actually unloads plugins, so we have to manually set them back up.
    -- Tried reloading base modules but that upsets packer - this workaround does functionally the same thing.
    local reload = require('plenary.reload').reload_module
    local plugin_configs = require('modules.config')

    reload('core', true)
    reload('modules.config', true)
    reload('modules.lspconfig', true)

    ---@diagnostic disable-next-line: lowercase-global
    packer_plugins = packer_plugins or {}
    for plugin, _ in pairs(packer_plugins) do
        reload(plugin, true)
        pcall(require, plugin)
        pcall(require, string.gsub(plugin, '.nvim', ''))
    end

    for _, setup in pairs(plugin_configs) do
        setup()
    end

    vim.cmd("execute 'source ' . stdpath('config') . '/init.lua'")
end

M.fn.get_vis_len = function()
    -- Visual markers aren't saved until after selection ends, so we have to exit first and debounce.
    vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<Esc>', true, false, true), 'n', false)

    vim.defer_fn(function()
        local _, start_row, start_col, _ = unpack(vim.fn.getpos("'<"))
        local _, end_row, end_col, _ = unpack(vim.fn.getpos("'>"))

        local lines = vim.fn.getline(start_row, end_row)
        if #lines == 0 then
            return 0
        end

        -- Slice off unselected text in first and last lines if only partially selected.
        if start_row == end_row then
            lines[1] = string.sub(lines[1], start_col, end_col)
        else
            lines[1] = string.sub(lines[1], start_col)
            lines[#lines] = string.sub(lines[#lines], 1, end_col)
        end

        local text = table.concat(lines, '\n')
        print(vim.fn.strlen(text))
    end, 50)
end

M.fn.setup_lazy = function()
    local lazypath = vim.fn.stdpath('data') .. '/lazy/lazy.nvim'
    if not vim.loop.fs_stat(lazypath) then
        vim.fn.system({
            'git',
            'clone',
            '--filter=blob:none',
            'https://github.com/folke/lazy.nvim.git',
            '--branch=stable', -- latest stable release
            lazypath,
        })
    end
    vim.opt.rtp:prepend(lazypath)
end

M.fn.handler = function(_, result, ctx)
    local hov = require('rust-tools.hover_actions')

    if result and result.contents then
        local markdown_lines = vim.lsp.util.convert_input_to_markdown_lines(result.contents, {})
        local final = {}
        local in_code_block = false
        local code_block_start_pattern = '^```%w+'

        for _, line in ipairs(markdown_lines) do
            if line:match(code_block_start_pattern) then
                -- Start of a code block
                in_code_block = true
                final[#final + 1] = line
            elseif line == '```' and in_code_block then
                -- End of a code block, append to the previous line
                final[#final] = final[#final] .. line
                in_code_block = false
            else
                -- Regular line, just append
                final[#final + 1] = line
            end
        end

        result.contents = table.concat(final, '\n')
    end
    hov.handler(_, result, ctx)
end

-- This bit of hacky pre-processing removes the whitespace between markdown code blocks.
-- It relies on some rust-tools internals, so it could break in the future—but rust-tools isn't
-- being updated anyways.
M.fn.rust_tools_hover = function()
    local rt = require('rust-tools')

    local params = vim.lsp.util.make_position_params(0, nil)
    vim.lsp.buf_request(0, 'textDocument/hover', params, rt.utils.mk_handler(M.fn.handler))
end

return M
