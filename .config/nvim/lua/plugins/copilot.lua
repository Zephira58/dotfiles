return {
  {
    "github/copilot.vim",
    event = "InsertEnter",
    cmd = { "Copilot" },
    init = function()
      vim.g.copilot_no_tab_map = true
      -- Control + P to accept Copilot suggestion
      vim.cmd([[imap <silent><script><expr> <C-p> copilot#Accept("")]])
    end,
  },
}
