return {
  -- telescope: layout mejorado
  {
    "nvim-telescope/telescope.nvim",
    opts = {
      defaults = {
        layout_strategy = "horizontal",
        layout_config = { prompt_position = "top", width = 0.9, height = 0.8 },
        sorting_strategy = "ascending",
        winblend = 10,
      },
    },
  },

  {
    "zk-org/zk-nvim",
    config = function()
      require("zk").setup({
        picker = "telescope",
      })
    end,
  },
}
