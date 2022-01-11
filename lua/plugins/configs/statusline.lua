local colors = require("colors").get()
local lsp = require "feline.providers.lsp"
local lsp_severity = vim.diagnostic.severity

local icon_styles = {
  default = {
    left = "",
    right = " ",
    main_icon = "  ",
    vi_mode_icon = " ",
    position_icon = " ",
  },
  arrow = {
    left = "",
    right = "",
    main_icon = "  ",
    vi_mode_icon = " ",
    position_icon = " ",
  },

  block = {
    left = " ",
    right = " ",
    main_icon = "   ",
    vi_mode_icon = "  ",
    position_icon = "  ",
  },

  round = {
    left = "",
    right = "",
    main_icon = "  ",
    vi_mode_icon = " ",
    position_icon = " ",
  },

  slant = {
    left = " ",
    right = " ",
    main_icon = "  ",
    vi_mode_icon = " ",
    position_icon = " ",
  },
}

local config = require("core.utils").load_config().plugins.options.statusline

-- statusline style
local user_statusline_style = config.style
local statusline_style = icon_styles[user_statusline_style]

-- show short statusline on small screens
local shortline = config.shortline == false and true

-- Initialize the components table
local components = {
  active = {},
  inactive = {},
}

table.insert(components.active, {})
table.insert(components.active, {})
table.insert(components.active, {})

local get_components = function()
  local M = {}

  M.main_icon = {
    provider = statusline_style.main_icon,

    hl = {
      fg = colors.statusline_bg,
      bg = colors.nord_blue,
    },

    right_sep = { str = statusline_style.right, hl = {
      fg = colors.nord_blue,
      bg = colors.lightbg,
    } },
  }

  M.file = {
    provider = function()
      local filename = vim.fn.expand "%:t"
      local extension = vim.fn.expand "%:e"
      local icon = require("nvim-web-devicons").get_icon(filename, extension)
      if icon == nil then
        icon = " "
        return icon
      end
      return " " .. icon .. " " .. filename .. " "
    end,
    enabled = shortline or function(winid)
      return vim.api.nvim_win_get_width(tonumber(winid) or 0) > 70
    end,
    hl = {
      fg = colors.white,
      bg = colors.lightbg,
    },

    right_sep = { str = statusline_style.right, hl = { fg = colors.lightbg, bg = colors.lightbg2 } },
  }

  M.dir = {
    provider = function()
      local dir_name = vim.fn.fnamemodify(vim.fn.getcwd(), ":t")
      return "  " .. dir_name .. " "
    end,

    enabled = shortline or function(winid)
      return vim.api.nvim_win_get_width(tonumber(winid) or 0) > 80
    end,

    hl = {
      fg = colors.grey_fg2,
      bg = colors.lightbg2,
    },
    right_sep = {
      str = statusline_style.right,
      hi = {
        fg = colors.lightbg2,
        bg = colors.statusline_bg,
      },
    },
  }

  M.git_added = {
    provider = "git_diff_added",
    hl = {
      fg = colors.grey_fg2,
      bg = colors.statusline_bg,
    },
    icon = " ",
  }

  M.git_modified = {
    provider = "git_diff_changed",
    hl = {
      fg = colors.grey_fg2,
      bg = colors.statusline_bg,
    },
    icon = "   ",
  }

  M.git_removed = {
    provider = "git_diff_removed",
    hl = {
      fg = colors.grey_fg2,
      bg = colors.statusline_bg,
    },
    icon = "  ",
  }

  M.diagnostic_errors = {
    provider = "diagnostic_errors",
    enabled = function()
      return lsp.diagnostics_exist(lsp_severity.ERROR)
    end,

    hl = { fg = colors.red },
    icon = "  ",
  }

  M.diagnostic_warnings= {
    provider = "diagnostic_warnings",
    enabled = function()
      return lsp.diagnostics_exist(lsp_severity.WARN)
    end,
    hl = { fg = colors.yellow },
    icon = "  ",
  }

  M.diagnostic_hints = {
    provider = "diagnostic_hints",
    enabled = function()
      return lsp.diagnostics_exist(lsp_severity.HINT)
    end,
    hl = { fg = colors.grey_fg2 },
    icon = "  ",
  }

  M.dianostic_info ={
    provider = "diagnostic_info",
    enabled = function()
      return lsp.diagnostics_exist(lsp_severity.INFO)
    end,
    hl = { fg = colors.green },
    icon = "  ",
  }

  M.lsp_progress = {
    provider = function()
      local Lsp = vim.lsp.util.get_progress_messages()[1]

      if Lsp then
        local msg = Lsp.message or ""
        local percentage = Lsp.percentage or 0
        local title = Lsp.title or ""
        local spinners = {
          "",
          "",
          "",
        }

        local success_icon = {
          "",
          "",
          "",
        }

        local ms = vim.loop.hrtime() / 1000000
        local frame = math.floor(ms / 120) % #spinners

        if percentage >= 70 then
          return string.format(" %%<%s %s %s (%s%%%%) ", success_icon[frame + 1], title, msg, percentage)
        end

        return string.format(" %%<%s %s %s (%s%%%%) ", spinners[frame + 1], title, msg, percentage)
      end

      return ""
    end,
    enabled = shortline or function(winid)
      return vim.api.nvim_win_get_width(tonumber(winid) or 0) > 80
    end,
    hl = { fg = colors.green },
  }

  M.lsp = {
    provider = function()
      if next(vim.lsp.buf_get_clients()) ~= nil then
        return "  LSP"
      else
        return ""
      end
    end,
    enabled = shortline or function(winid)
      return vim.api.nvim_win_get_width(tonumber(winid) or 0) > 70
    end,
    hl = { fg = colors.grey_fg2, bg = colors.statusline_bg },
  }

  M.git_branch = {
    provider = "git_branch",
    enabled = shortline or function(winid)
      return vim.api.nvim_win_get_width(tonumber(winid) or 0) > 70
    end,
    hl = {
      fg = colors.grey_fg2,
      bg = colors.statusline_bg,
    },
    icon = "  ",
  }

  M.git_right_separator = {
    provider = " " .. statusline_style.left,
    hl = {
      fg = colors.one_bg2,
      bg = colors.statusline_bg,
    },
  }

  local mode_colors = {
    ["n"] = { "NORMAL", colors.red },
    ["no"] = { "N-PENDING", colors.red },
    ["i"] = { "INSERT", colors.dark_purple },
    ["ic"] = { "INSERT", colors.dark_purple },
    ["t"] = { "TERMINAL", colors.green },
    ["v"] = { "VISUAL", colors.cyan },
    ["V"] = { "V-LINE", colors.cyan },
    [""] = { "V-BLOCK", colors.cyan },
    ["R"] = { "REPLACE", colors.orange },
    ["Rv"] = { "V-REPLACE", colors.orange },
    ["s"] = { "SELECT", colors.nord_blue },
    ["S"] = { "S-LINE", colors.nord_blue },
    [""] = { "S-BLOCK", colors.nord_blue },
    ["c"] = { "COMMAND", colors.pink },
    ["cv"] = { "COMMAND", colors.pink },
    ["ce"] = { "COMMAND", colors.pink },
    ["r"] = { "PROMPT", colors.teal },
    ["rm"] = { "MORE", colors.teal },
    ["r?"] = { "CONFIRM", colors.teal },
    ["!"] = { "SHELL", colors.green },
  }

  local chad_mode_hl = function()
    return {
      fg = mode_colors[vim.fn.mode()][2],
      bg = colors.one_bg,
    }
  end

  M.mode_left_separator = {
    provider = statusline_style.left,
    hl = function()
      return {
        fg = mode_colors[vim.fn.mode()][2],
        bg = colors.one_bg2,
      }
    end,
  }

  M.mode_icon = {
    provider = statusline_style.vi_mode_icon,
    hl = function()
      return {
        fg = colors.statusline_bg,
        bg = mode_colors[vim.fn.mode()][2],
      }
    end,
  }

  M.mode_string = {
    provider = function()
      return " " .. mode_colors[vim.fn.mode()][1] .. " "
    end,
    hl = chad_mode_hl,
  }

  M.loc_spacer_left = {
    provider = statusline_style.left,
    enabled = shortline or function(winid)
      return vim.api.nvim_win_get_width(tonumber(winid) or 0) > 90
    end,
    hl = {
      fg = colors.grey,
      bg = colors.one_bg,
    }
  }

  M.loc_separator_left = {
    provider = statusline_style.left,
    enabled = shortline or function(winid)
      return vim.api.nvim_win_get_width(tonumber(winid) or 0) > 90
    end,
    hl = {
      fg = colors.green,
      bg = colors.grey,
    },
  }

  M.loc_position_icon = {
    provider = statusline_style.position_icon,
    enabled = shortline or function(winid)
      return vim.api.nvim_win_get_width(tonumber(winid) or 0) > 90
    end,
    hl = {
      fg = colors.black,
      bg = colors.green,
    }
  }

  M.loc_position_text = {
    provider = function()
      local current_line = vim.fn.line "."
      local total_line = vim.fn.line "$"

      if current_line == 1 then
        return " Top "
      elseif current_line == vim.fn.line "$" then
        return " Bot "
      end
      local result, _ = math.modf((current_line / total_line) * 100)
      return " " .. result .. "%% "
    end,

    enabled = shortline or function(winid)
      return vim.api.nvim_win_get_width(tonumber(winid) or 0) > 90
    end,

    hl = {
      fg = colors.green,
      bg = colors.one_bg,
    },
  }
  return M
end

local components_list = get_components()

local left = {}
local right = {}
local middle = {}

table.insert(left, components_list.main_icon)
table.insert(left, components_list.file)
table.insert(left, components_list.dir)

table.insert(left, components_list.git_added)
table.insert(left, components_list.git_modified)
table.insert(left, components_list.git_removed)

table.insert(left, components_list.diagnostic_errors)
table.insert(left, components_list.diagnostic_warnings)
table.insert(left, components_list.diagnostic_hints)
table.insert(left, components_list.diagnostic_info)

table.insert(middle, components_list.lsp_progress)

table.insert(right, components_list.lsp)
table.insert(right, components_list.git_branch)
table.insert(right, components_list.git_right_separator)

table.insert(right, components_list.mode_left_separator)
table.insert(right, components_list.mode_icon)
table.insert(right, components_list.mode_string)

table.insert(right, components_list.loc_spacer_left)
table.insert(right, components_list.loc_separator_left)
table.insert(right, components_list.loc_position_icon)
table.insert(right, components_list.loc_position_text)

components.active[1] = left
components.active[2] = middle
components.active[3] = right

require("feline").setup {
  theme = {
    bg = colors.statusline_bg,
    fg = colors.fg,
  },
  components = components,
}
