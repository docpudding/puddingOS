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
        key = "<F5>";
        mode = "n";
        action.__raw = ''
            (function()
                -- Ordered list of project markers and their default run commands, most specific first.
                local project_runners = {
                --[[
                    { marker = "Cargo.toml", command = "cargo run" },
                    { marker = "package.json", command = "npm start" },
                    { marker = "pyproject.toml", command = "python main.py" },
                    { marker = "go.mod", command = "go run ." },
                    { marker = "project.godot", command = "godot --path ." },
                    { marker = "flake.nix", command = "nix run" },
                    { marker = "Makefile", command = "make" },
                --]]
                }

                -- Handles for the reused run terminal, kept alive across calls via this closure.
                local run_term_win = nil
                local run_term_job = nil

                -- Search upward from the current buffer for the nearest known project marker.
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
