return {
  {
    "folke/tokyonight.nvim",
    opts = {
      style = "night",
      transparent = true,           -- usa el fondo de Kitty (#0f0f0f)
      terminal_colors = true,
      styles = {
        comments = { italic = true },
        keywords = { italic = false },
        sidebars = "transparent",
        floats = "transparent",
      },
      on_highlights = function(hl, c)
        -- acentos más cercanos a tu azul de waybar (#6090c8)
        hl.CursorLine = { bg = "#1a1a2e" }
        hl.Visual = { bg = "#1e2a40" }
        hl.LineNr = { fg = "#3a3a4e" }
        hl.CursorLineNr = { fg = "#6090c8", bold = true }
        hl.Comment = { fg = "#4a4a5e", italic = true }
      end,
    },
  },
  {
    "LazyVim/LazyVim",
    opts = { colorscheme = "tokyonight" },
  },
}
