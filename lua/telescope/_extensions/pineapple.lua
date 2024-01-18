local telescope = require('telescope')

return telescope.register_extension({
    exports = {
        colorschemes = require('telescope._extensions.pineapple_themes'),
    },
})
