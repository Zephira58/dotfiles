-- You can add your own plugins here or in other files in this directory!
--  I promise not to create any merge conflicts in this directory :)
--
-- See the kickstart.nvim README for more information

--Automaticly enable spellcheker
vim.cmd("autocmd FileType * setlocal spell spelllang=en_us")
return {
    "github/copilot.vim",
    "wakatime/vim-wakatime",

    --Rust Spesifics
    "neovim/nvim-lspconfig",
    "simrat39/rust-tools.nvim",

}
