# Pineapple.nvim

The ultimate theme manager for neovim

## Why?

The goals of this plugin are:

- Find a theme without using google
- Be able to preview a theme in neovim
- Install a theme and change the colorscheme without touching the config

## What does it not do

Pineapple is not designed to:

- Find a theme that works with treesitter, though you can find some of those themes by a text filter of "treesitter" or "Treesitter"
- Manage the installation for your theme, that is the package manager's job
- Find a theme for your lualine or anything else that needs to be seperately themed
- Manage any local themes in development you might be using

## Setup

Pineapple has only been tested with lazy.nvim as a package manager.

Here's the quick setup:

1. Create an empty file in your ~/.config/nvim/lua/YOUR_LUA_DIRECTORY directory (or C:\Users\_\AppData\Local\Nvim if you're a Windows user) (Called pineapple.lua here). This file is for storing your installed themes.
2. Create an empty file in the ~/.config/nvim/after/plugin folder (called theme.lua). This file is for setting the colorscheme.
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

Pineapple is designed to minimally interrupt your startup time. Nothing is loaded until the plugin is opened with the command `Pineapple`.

## Requirements

- Neovim 0.8.0 or greater

## Acknowledgements

This whole idea is from the [vimcolorschemes website](https://vimcolorschemes.com/), and I wanted to put that in a neovim extension.

A modified version of the [vimcolorschemes worker](https://github.com/vimcolorschemes/worker) was used to generate the themes.

## Known Issues

The vimcolorschemes worker has a problem where it incorrectly generates some themes (I think the ones that only use treesitter), leaving large portions of the theme as just black

## Api

The provided api functions can be found at pineapple.api.

## Uninstall

Pineapple is designed to be removed as easily as possible. The steps to remove it are pretty simple:

Add the installation line for whatever your current theme is to your lazy.nvim config file. All your downloaded themes can be seen at ~/.config/nvim/YOUR_LUA_DIRECTORY/YOUR_PINEAPPLE_FILE.lua. After this, you can remove the pineapple install line and run `Lazy sync`.
