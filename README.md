# rg.nvim

A plugin that integrates `rg` in nvim, while allowing you to extend it however you want.

## Installation

### `Paq.nvim`

```lua
paq{'winston0410/rg.nvim'}
```

### `Packer.nvim`

```lua
use({"winston0410/rg.nvim"})
```

### `vim-plug`

```lua
Plug 'winston0410/rg.nvim'
```

## Configuration

Initialize the plugin:

```lua
require("rg").setup({})
```

This is the default configuration:

```lua
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
```
