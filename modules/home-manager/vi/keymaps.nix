[
    {
        key = "<F1>";
        mode = ["n" "i" "v"];
        action.__raw = ''
            function()
                local line = vim.api.nvim_win_get_cursor(0)[1] - 1
                local diagnostics = vim.diagnostic.get(0, { lnum = line })
                if #diagnostics > 0 then
                    vim.diagnostic.open_float()
                else
                    vim.lsp.buf.hover()
                end
            end
        '';
        options.desc = "Show diagnostic float if present on this line, otherwise LSP hover.";
    }
    {
        key = "<F2>";
        mode = ["n" "i" "v"];
        action = "<ESC>:lua vim.lsp.buf.rename()<CR>";
        options.desc = "Open refactoring prompt for hovered item.";
    }
    {
        key = "<F3>";
        mode = "n";
        action.__raw = ''
            function()
                vim.fn.feedkeys(":%s/", "n")
            end
        '';
        options.desc = "Find and replace.";
    }
    {
        key = "<F5>";
        mode = "n";
        action.__raw = ''
            (function()
                -- Ordered list of project markers and their default run commands, most specific first.
                local project_runners = {
                    { marker = "project.godot", command = "godot --path ." },
                --[[
                    { marker = "Cargo.toml", command = "cargo run" },
                    { marker = "package.json", command = "npm start" },
                    { marker = "pyproject.toml", command = "python main.py" },
                    { marker = "go.mod", command = "go run ." },
                    { marker = "flake.nix", command = "nix run" },
                    { marker = "Makefile", command = "make" },
                --]]
                }

                -- Handles for the reused run terminal, kept alive across calls via this closure.
                local run_term_win = nil
                local run_term_job = nil

                -- Search upward from the current buffer for the nearest known project marker.
                -- Falls back to a bare .virun file so overrides work even with no language marker present.
                local function find_project_runner()
                    local start_dir = vim.fn.expand("%:p:h")
                    if start_dir == "" then
                        start_dir = vim.fn.getcwd()
                    end

                    for _, runner in ipairs(project_runners) do
                        local found = vim.fs.find(runner.marker, { path = start_dir, upward = true })[1]
                        if found ~= nil then
                            return vim.fs.dirname(found), runner.command
                        end
                    end

                    local virun_found = vim.fs.find(".virun", { path = start_dir, upward = true })[1]
                    if virun_found ~= nil then
                        return vim.fs.dirname(virun_found), nil
                    end

                    return nil, nil
                end

                -- Run the current project's command in a single, reused terminal window.
                return function()
                    local root, default_command = find_project_runner()
                    if root == nil then
                        vim.notify("No recognized project type found.", vim.log.levels.WARN)
                        return
                    end

                    -- A .virun file in the project root overrides the default command.
                    local command = default_command
                    local override_path = root .. "/.virun"
                    if vim.fn.filereadable(override_path) == 1 then
                        local lines = vim.fn.readfile(override_path)
                        if #lines > 0 and lines[1] ~= "" then
                            command = lines[1]
                        end
                    end

                    if command == nil then
                        vim.notify("No run command defined for this project.", vim.log.levels.WARN)
                        return
                    end

                    -- Interrupt any run still in progress before starting the next one.
                    if run_term_job ~= nil then
                        vim.fn.jobstop(run_term_job)
                        run_term_job = nil
                    end

                    -- Reuse the existing run window if it's still open, otherwise create it once.
                    if run_term_win == nil or not vim.api.nvim_win_is_valid(run_term_win) then
                        vim.cmd("botright split")
                        vim.api.nvim_win_set_height(0, 15)
                        run_term_win = vim.api.nvim_get_current_win()
                    else
                        vim.api.nvim_set_current_win(run_term_win)
                    end

                    -- Replace the window's buffer with a fresh scratch buffer so old output is cleared.
                    local buf = vim.api.nvim_create_buf(false, true)
                    vim.bo[buf].bufhidden = "wipe"
                    vim.api.nvim_win_set_buf(run_term_win, buf)

                    run_term_job = vim.fn.termopen(command, { cwd = root })
                    vim.cmd("startinsert")
                end
            end)()
        '';
        options.desc = "Run the current project.";
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
        key = "#";
        mode = "n";
        action = "gcc";
        options = {
            desc = "Toggle comment on the current line.";
            remap = true;
        };
    }
    {
        key = "#";
        mode = "v";
        action = "gc";
        options = {
            desc = "Toggle comment on the selection.";
            remap = true;
        };
    }
    {
        key = "<Tab>";
        mode = "n";
        action = "<cmd>RnvimrToggle<CR>";
        options.desc = "Toggle ranger file browser.";
    }
    {
        key = "m";
        mode = "n";
        action = "<cmd>lua PosInstances.move()<CR>";
        options.desc = "Move current buffer to another nvim instance.";
    }
    {
        key = "M";
        mode = "n";
        action = "<cmd>lua PosInstances.popout()<CR>";
        options.desc = "Pop out current buffer into a new nvim instance.";
    }
    {
        key = "r";
        mode = "n";
        action = "<cmd>lua PosInstances.restart_lsp()<CR>";
        options.desc = "Restart LSP for this buffer (like a refresh button).";
    }
    {
        key = "R";
        mode = "n";
        action = "<cmd>lua PosInstances.restart_lsp_everywhere()<CR>";
        options.desc = "Restart LSP for this buffer across all running instances.";
    }
]
