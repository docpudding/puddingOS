[
    {
        key = "<F1>";
        mode = ["n" "i" "v"];
        action = "<ESC>:lua vim.diagnostic.open_float()<CR>";
        options.desc = "Open diagnostic window for hovered item.";
    }
    {
        key = "<F2>";
        mode = ["n" "i" "v"];
        action = "<ESC>:lua vim.lsp.buf.rename()<CR>";
        options.desc = "Open refactoring prompt for hovered item.";
    }
    {
        key = "<F3>";
        mode = ["n" "i" "v"];
        action = "<ESC>:set hlsearch!<CR>";
        options.desc = "Toggle search highlight.";
    }
    {
        key = "`";
        mode = "n";
        action = "<cmd>Telescope buffers<cr>";
        options.desc = "List open buffers.";
    }
    {
        key = "~";
        mode = "n";
        action.__raw = ''
            function()
                local ok = pcall(require('telescope.builtin').git_files, {})
                if not ok then
                    require('telescope.builtin').find_files()
                end
            end
        '';
        options.desc = "Find files (git-aware).";
    }
    {
        key = "?";
        mode = "n";
        action.__raw = ''
            function()
                local builtin = require('telescope.builtin')
                local git_cmd = "git rev-parse --is-inside-work-tree 2>/dev/null"
                local is_git = vim.fn.system(git_cmd):match('true')
                if is_git then
                    local git_root = vim.fn.systemlist('git rev-parse --show-toplevel')[1]
                    builtin.live_grep({ cwd = git_root })
                else
                    builtin.live_grep()
                end
            end
        '';
        options.desc = "Live grep (git-aware).";
    }
    {
        key = "<leader>r";
        mode = "n";
        action = ":%s//";
        options.desc = "Replace last search pattern.";
    }
    {
        key = "<leader>R";
        mode = "n";
        action.__raw = ''
            function()
                vim.fn.feedkeys(":%s/", "n")
            end
        '';
        options.desc = "Find and replace.";
    }
]
