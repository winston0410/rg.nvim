# rg.nvim

A plugin that integrates `rg` in nvim, while allowing you to extend it however you want.

This plugin doesn't bundle you into a quickfix list plugin, or a specify UI. You can design whatever you want.

## Usage

Use the default keybinding as an operator (e.g. `<leader>siw` or `vaw<leader>s` and select words that you want to search with.

Once the search is completed, the `opts.on_complete` callback will be called. You can then decide how to present the result of quickfix list.

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

## Inspiration

This plugin is inspired by the following resources:

https://github.com/folke/trouble.nvim

https://teukka.tech/vimloop.html
