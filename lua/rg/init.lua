local loop = vim.loop
local api = vim.api

local opts = {
	default_keybindings = {
		enable = true,
		modes = { "v" },
	},
	on_complete = function()
		api.nvim_command("cwindow")
	end,
}

local results = {}
local function onread(err, data)
	if err then
		-- print('ERROR: ', err)
		-- TODO handle err
		return
	end
	if data then
		local vals = vim.split(data, "\n")
		for _, d in pairs(vals) do
			if d ~= "" then
				table.insert(results, d)
			end
		end
	end
end
function search(term)
	local stdout = vim.loop.new_pipe(false)
	local stderr = vim.loop.new_pipe(false)
	local function setQF()
		vim.fn.setqflist({}, "r", { title = "Search Results", lines = results })
		opts.on_complete()
		local count = #results
		for i = 0, count do
			results[i] = nil
		end -- clear the table for the next search
	end
	handle = vim.loop.spawn(
		"rg",
		{
			args = { term, "--vimgrep", "--smart-case" },
			stdio = { nil, stdout, stderr },
		},
		vim.schedule_wrap(function()
			stdout:read_stop()
			stderr:read_stop()
			stdout:close()
			stderr:close()
			handle:close()
			setQF()
		end)
	)
	vim.loop.read_start(stdout, onread)
	vim.loop.read_start(stderr, onread)
end

local function setup(user_opts)
	opts = vim.tbl_deep_extend("force", opts, user_opts or {})
	if opts.default_keybindings and opts.default_keybindings.enable then
		for _, mode in ipairs(opts.default_keybindings.modes) do
			vim.api.nvim_set_keymap(mode, opts.keybindings[mode], "Rg()", {
				expr = true,
				silent = true,
				noremap = true,
			})
		end
	end
end

return {
	search = search,
	setup = setup,
}
