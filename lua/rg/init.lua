local loop = vim.loop
local api = vim.api

local opts = {
	default_keybindings = {
		enable = true,
		modes = { "n", "v" },
		binding = "<Leader>s",
	},
	on_complete = function()
		api.nvim_command("cwindow")
	end,
	program = {
		command = "rg",
		args = { "--vimgrep", "--smart-case" },
	},
}

local results = {}

local function onread(err, data)
	if err then
		api.nvim_err_writeln(err)
		return
	end
	if data then
		local vals = vim.split(data, "\n")
		for _, d in ipairs(vals) do
			if d ~= "" then
				table.insert(results, d)
			end
		end
	end
end

local function update_quickfix()
	vim.fn.setqflist({}, "r", { title = "Search Results", lines = results })
	opts.on_complete()
	local count = #results
	for i = 0, count do
		results[i] = nil
	end -- clear the table for the next search
end

local function trigger_rg(term)
	print("rg term", term)
	local stdout = loop.new_pipe(false)
	local stderr = loop.new_pipe(false)
	handle = loop.spawn(
		opts.program.command,
		{
			args = vim.list_extend({ term }, opts.program.args),
			stdio = { nil, stdout, stderr },
		},
		vim.schedule_wrap(function()
			stdout:read_stop()
			stderr:read_stop()
			stdout:close()
			stderr:close()
			handle:close()
			update_quickfix()
		end)
	)
	loop.read_start(stdout, onread)
	loop.read_start(stderr, onread)
end

local function search()
	local start_row, start_col = unpack(api.nvim_win_get_cursor(0))
	-- Use ] mark for working in normal mode
	local end_row, end_col = unpack(api.nvim_buf_get_mark(0, "]"))

	if end_row > 1 then
		return api.nvim_err_writeln("Multiline searching is not supported yet")
	end

	local lines = api.nvim_buf_get_lines(0, start_row - 1, end_row, false)

	lines[#lines] = lines[#lines]:sub(start_col, end_col + 1)

	-- if end_row > 1 then
	-- return api.nvim_err_writeln("multi line unsupported")
	-- end

	-- local lines = api.nvim_buf_get_lines(0, start_row - 1, end_row, false)

	-- if start_col ~= 0 then
	-- lines[start_row] = lines[start_row]:sub(start_col, -1)
	-- end

	-- if end_col ~= #lines[#lines] then
	-- lines[#lines] = lines[#lines]:sub(1, end_col + 1)
	-- end

	trigger_rg(lines[1])
end

local function setup(user_opts)
	opts = vim.tbl_deep_extend("force", opts, user_opts or {})
	if opts.default_keybindings and opts.default_keybindings.enable then
		for _, mode in ipairs(opts.default_keybindings.modes) do
			api.nvim_set_keymap(mode, opts.default_keybindings.binding, "Rg()", {
				expr = true,
				silent = true,
				noremap = true,
			})
		end
	end

	vim.api.nvim_exec("command! -nargs=+ -complete=dir -bar Rg lua require'rg'.trigger_rg(<q-args>)", true)
end

return {
	search = search,
	trigger_rg = trigger_rg,
	setup = setup,
}
