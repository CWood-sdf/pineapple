# Pineapple.nvim

The ultimate theme manager for neovim

## Why?

The goals of this plugin are pretty simple:

- Find a theme without using google
- Be able to preview a theme in neovim
- Install a theme and change the colorscheme without touching the config

This plugin uses the vimcolorschemes worker to download and generate previews for files.

## Setup

Pineapple has only been tested with lazy.nvim as a package manager.

Here's the quick setup:

1. Create an empty file in your ~/.config/nvim/lua/YOUR_LUA_DIRECTORY/pineapple.lua (or C:\Users\_\AppData\Local\Nvim if you're a Windows user)
2. Create an empty file in the ~/.config/nvim/after/plugin folder
3. Then for setup, put this in your config:

```lua
{
    "CWood-sdf/pineapple",
    dependencies = require("YOUR_LUA_DIRECTORY.pineapple"),
    opts = {
        installedRegistry = "YOUR_LUA_DIRECTORY.pineapple",
        colorschemeFile = "after/plugin/theme.lua"
    },
    lazy = false,
}
```

Note that opts.installedRegistry and colorschemeFile are in different file formats. This is so that opts.installedRegistry can be put in a variable at the top of your lazy config file. The directory that both installedRegistry and colorschemeFile are assumed to be in is $HOME\.config\nvim (or %USERPROFILE%\AppData\Local\Nvim if you're a Windows user)

## Usage

The plugin can be opened with the command `Pineapple`

All the remaps are shown at the top of the plugin.

## Speed

Nothing is loaded until the plugin is opened with the command `Pineapple`, meaning that you can't script the plugin until it is opened. The whole point of this is so that it adds very little time to startup.

## Requirements

- Neovim 0.8.0 or greater

## Acknowledgements

This whole idea is from the [vimcolorschemes website](https://vimcolorschemes.com/), and I wanted to put that in a neovim extension.

A modified version of the [vimcolorschemes worker](https://github.com/vimcolorschemes/worker) was used to generate the themes.

## Known Issues

The vimcolorschemes worker has a problem where it incorrectly generates some themes (I think the ones that only use treesitter)

This plugin is non-customizable, and can't be accessed from scripts (well, it can, but it won't work until the plugin is loaded)
