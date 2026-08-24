-- Cross-instance buffer migration.

local uv = vim.uv or vim.loop

local registry_dir = (vim.env.XDG_RUNTIME_DIR or "/tmp") .. "/nvim-instances"

local function instance_id()
    return vim.fn.getpid()
end

local function registry_path(id)
    return registry_dir .. "/" .. tostring(id) .. ".json"
end

-- Announce this instance so other instances can find it.
local function register_instance()
    vim.fn.mkdir(registry_dir, "p")
    local entry = {
        servername = vim.v.servername,
        cwd = vim.fn.getcwd(),
        pid = instance_id(),
    }
    vim.fn.writefile({vim.fn.json_encode(entry)}, registry_path(instance_id()))
end

-- Remove this instance's registry entry on exit.
local function unregister_instance()
    local path = registry_path(instance_id())
    if vim.fn.filereadable(path) == 1 then
        vim.fn.delete(path)
    end
end

vim.api.nvim_create_autocmd("VimEnter", {callback = register_instance})
vim.api.nvim_create_autocmd("VimLeavePre", {callback = unregister_instance})

-- List other live instances, pruning entries whose socket no longer exists.
local function list_instances()
    local instances = {}
    local self_pid = instance_id()

    if vim.fn.isdirectory(registry_dir) == 0 then
        return instances
    end

    for _, filename in ipairs(vim.fn.readdir(registry_dir)) do
        local path = registry_dir .. "/" .. filename
        local lines = vim.fn.readfile(path)
        if #lines > 0 then
            local ok, entry = pcall(vim.fn.json_decode, lines[1])
            if ok and entry.pid ~= self_pid then
                if vim.fn.getftype(entry.servername) == "socket" then
                    table.insert(instances, entry)
                else
                    -- Stale entry: the owning instance is gone.
                    vim.fn.delete(path)
                end
            end
        end
    end

    return instances
end

local function connect(servername)
    local ok, channel = pcall(vim.fn.sockconnect, "pipe", servername, {rpc = true})
    if not ok or channel == 0 then
        return nil
    end
    return channel
end

-- Executed inside the target instance via nvim_exec_lua.
-- Receives: path, lines, filetype, modified, cursor.
local remote_receive_code = [[
    local path, lines, filetype, modified, cursor = ...

    if path ~= "" then
        vim.cmd("edit " .. vim.fn.fnameescape(path))
    else
        vim.cmd("enew")
    end

    vim.api.nvim_buf_set_lines(0, 0, -1, false, lines)

    if filetype ~= "" then
        vim.bo.filetype = filetype
    end

    vim.bo.modified = modified

    pcall(vim.api.nvim_win_set_cursor, 0, cursor)
]]

-- Buffer types that can't be meaningfully moved to another process.
local function current_buffer_is_movable()
    return vim.bo.buftype == ""
end

local function snapshot_current_buffer()
    local bufnr = vim.api.nvim_get_current_buf()
    return {
        bufnr = bufnr,
        path = vim.api.nvim_buf_get_name(bufnr),
        lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false),
        filetype = vim.bo[bufnr].filetype,
        modified = vim.bo[bufnr].modified,
        cursor = vim.api.nvim_win_get_cursor(0),
    }
end

local function send_buffer_to(servername)
    local snapshot = snapshot_current_buffer()
    local channel = connect(servername)

    if channel == nil then
        vim.notify("Could not connect to target instance.", vim.log.levels.ERROR)
        return
    end

    local ok = pcall(
        vim.rpcrequest,
        channel,
        "nvim_exec_lua",
        remote_receive_code,
        {snapshot.path, snapshot.lines, snapshot.filetype, snapshot.modified, snapshot.cursor}
    )

    vim.fn.chanclose(channel)

    if not ok then
        vim.notify("Failed to move buffer to target instance.", vim.log.levels.ERROR)
        return
    end

    -- The content was already transferred, so it's safe to force-close here
    -- even if the buffer was unsaved.
    vim.cmd("bdelete! " .. snapshot.bufnr)
end

local function pick_instance(callback)
    local instances = list_instances()

    if #instances == 0 then
        vim.notify("No other nvim instances found.", vim.log.levels.WARN)
        return
    end

    local pickers = require("telescope.pickers")
    local finders = require("telescope.finders")
    local conf = require("telescope.config").values
    local actions = require("telescope.actions")
    local action_state = require("telescope.actions.state")

    pickers.new({}, {
        prompt_title = "Move Buffer To Instance",
        finder = finders.new_table({
            results = instances,
            entry_maker = function(entry)
                return {
                    value = entry,
                    display = entry.cwd .. "  (pid " .. entry.pid .. ")",
                    ordinal = entry.cwd,
                }
            end,
        }),
        sorter = conf.generic_sorter({}),
        attach_mappings = function(prompt_bufnr, _)
            actions.select_default:replace(function()
                local selection = action_state.get_selected_entry()
                actions.close(prompt_bufnr)
                callback(selection.value.servername)
            end)
            return true
        end,
    }):find()
end

-- Stop and reattach the LSP clients for the current buffer.
local function restart_buffer_lsp()
    local bufnr = vim.api.nvim_get_current_buf()
    local clients = vim.lsp.get_clients({bufnr = bufnr})
    for _, client in ipairs(clients) do
        client:stop(true)
    end
    vim.defer_fn(function()
        vim.cmd("edit")
    end, 500)
end

_G.PosInstances = {}

-- Move the current buffer to another running instance, chosen via Telescope.
function _G.PosInstances.move()
    if not current_buffer_is_movable() then
        vim.notify("This buffer type can't be moved between instances.", vim.log.levels.WARN)
        return
    end

    pick_instance(function(servername)
        send_buffer_to(servername)
    end)
end

-- Spawn a new nvim instance in a new Alacritty window and move the current buffer into it.
function _G.PosInstances.popout()
    if not current_buffer_is_movable() then
        vim.notify("This buffer type can't be moved between instances.", vim.log.levels.WARN)
        return
    end

    local socket_path = vim.fn.tempname()

    vim.fn.jobstart({"alacritty", "-e", "nvim", "--listen", socket_path}, {detach = true})

    -- Poll for the new instance's socket to come up, then move the buffer over.
    local attempts = 0
    local timer = uv.new_timer()
    timer:start(
        200,
        200,
        vim.schedule_wrap(function()
            attempts = attempts + 1
            if vim.fn.getftype(socket_path) == "socket" then
                timer:stop()
                timer:close()
                send_buffer_to(socket_path)
            elseif attempts > 25 then
                timer:stop()
                timer:close()
                vim.notify("Timed out waiting for new instance to start.", vim.log.levels.ERROR)
            end
        end)
    )
end

-- Restart LSP clients for the current buffer in this instance only.
function _G.PosInstances.restart_lsp()
    restart_buffer_lsp()
end

-- Restart LSP clients for the current buffer here.
function _G.PosInstances.restart_lsp_everywhere()
    restart_buffer_lsp()

    local remote_code = [[
        local bufnr = vim.api.nvim_get_current_buf()
        local clients = vim.lsp.get_clients({ bufnr = bufnr })
        for _, client in ipairs(clients) do
            client:stop(true)
        end
        vim.defer_fn(function()
            vim.cmd("edit")
        end, 500)
    ]]

    for _, entry in ipairs(list_instances()) do
        local channel = connect(entry.servername)
        if channel ~= nil then
            pcall(vim.rpcrequest, channel, "nvim_exec_lua", remote_code, {})
            vim.fn.chanclose(channel)
        end
    end
end
