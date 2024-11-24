return {
  -- kanagawa.nvim
  {
    'rebelot/kanagawa.nvim',
    lazy = false,
    priority = 1000,
    config = function()
      -- create highlight groups
      vim.cmd [[
        highlight default link MyInlayHint LspInlayHint
      ]]

      -- create highlight groups
      require 'kanagawa'.setup {
        -- NOTE: Run `:KanagawaCompile` to compile the colorscheme
        compile = true,   -- enable compiling the colorscheme
        undercurl = true, -- enable undercurls
        commentStyle = { italic = true },
        functionStyle = {},
        keywordStyle = { italic = true },
        statementStyle = { bold = true },
        typeStyle = {},
        transparent = true,    -- do not set background color
        dimInactive = true,    -- dim inactive window `:h hl-NormalNC`
        terminalColors = true, -- define vim.g.terminal_color_{0,17}
        theme = 'wave',        -- "wave" | "lotus" | "dragon"
        colors = {             -- add/modify theme and palette colors
          palette = {
            -- https://coolors.co/palette/001219-005f73-0a9396-94d2bd-e9d8a6-ee9b00-ca6702-bb3e03-ae2012-9b2226
            RichBlack = '#001219',
            MidnightGreen = '#005f73',
            DarkCyan = '#0a9396',
            TiffanyBlue = '#94d2bd',
            Vanilla = '#e9d8a6',
            Gamboge = '#ee9b00',
            AlloyOrange = '#ca6702',
            Rust = '#bb3e03',
            Rufuos = '#ae2012',
            Auburn = '#9b2226',

            -- https://coolors.co/palette/664d00-6e2a0c-691312-5d0933-291938-042d3a-12403c-475200
            FieldDrab = '#664d00',
            SealBrown = '#6e2a0c',
            Rosewood = '#691312',
            TyrianPurple = '#5d0933',
            DarkPurple = '#291938',
            Gunmetal = '#042d3a',
            BrunswickGreen = '#12403c',
            DarkMossGreen = '#475200',

            -- others
            Prompt = '#2c240b',
          },
        },
        overrides = function(colors)
          return {
            IblScope = { fg = colors.palette.Rust },
            CopilotSuggestion = { fg = colors.palette.Gamboge, bg = colors.palette.RichBlack },
            IlluminatedWordText = { bg = colors.palette.TyrianPurple },
            IlluminatedWordRead = { bg = colors.palette.TyrianPurple },
            IlluminatedWordWrite = { bg = colors.palette.TyrianPurple },
            TelescopeNormal = { bg = colors.palette.RichBlack, fg = colors.palette.Vanilla },
            TelescopeBorder = { bg = colors.palette.RichBlack, fg = colors.palette.sakuraPink },
            TelescopeTitle = { bg = colors.palette.RichBlack, fg = colors.palette.sakuraPink },
            TelescopePromptNormal = { bg = colors.palette.RichBlack },
            TelescopePromptBorder = { bg = colors.palette.RichBlack, fg = colors.palette.surimiOrange },
            TelescopePromptTitle = { bg = colors.palette.RichBlack, fg = colors.palette.surimiOrange },
            MyInlayHint = { fg = colors.palette.Rust, bg = colors.palette.RichBlack },
          }
        end,
      }
      vim.cmd [[colorscheme kanagawa]]
    end,
  },

  -- nvim-notify
  {
    'rcarriga/nvim-notify',
    event = { 'BufReadPost', 'BufNewFile' },
    opts = {
      timeout = 3000,
      render = 'wrapped-compact',
      stages = 'static',
      max_height = function()
        return math.floor(vim.o.lines * 0.75)
      end,
    },
    keys = {
      {
        'zN',
        function()
          vim.g.notify_toggle()
          vim.notify('nvim-notify ' .. (vim.g.nvim_notify_enabled and 'enabled' or 'disabled'), vim.log.levels.INFO,
            { title = 'nvim-notify' })
        end,
        desc = 'Toggle notifications',
      },
    },
    config = function(_, opts)
      local notify = require 'notify'
      notify.setup(opts)

      vim.g.nvim_notify_original = vim.notify
      vim.g.nvim_notify_enabled = true


      -- function to toggle the notification
      vim.g.notify_toggle = function()
        if vim.g.nvim_notify_enabled then
          vim.notify = vim.g.nvim_notify_original
          vim.g.nvim_notify_enabled = false
        else
          vim.notify = notify
          vim.g.nvim_notify_enabled = true
        end
      end

      -- override the vim.notify function
      vim.notify = notify
    end,
  },

  -- dressing.nvim
  {
    'stevearc/dressing.nvim',
    config = true,
  },

  -- nvim-highlight-colors
  {
    'brenoprata10/nvim-highlight-colors',
    config = true,
  },

  -- nvim-ufo
  {
    'kevinhwang91/nvim-ufo',
    dependencies = {
      'kevinhwang91/promise-async',
      {
        'luukvbaal/statuscol.nvim',
        config = function()
          local builtin = require 'statuscol.builtin'
          require 'statuscol'.setup {
            relculright = true,
            segments = {
              { text = { builtin.foldfunc },      click = 'v:lua.ScFa' },
              { text = { '%s' },                  click = 'v:lua.ScSa' },
              { text = { builtin.lnumfunc, ' ' }, click = 'v:lua.ScLa' },
            },
          }
        end,
      },
    },
    event = { 'BufReadPost', 'BufNewFile' },
    keys = {
      {
        'zR',
        function()
          return require 'ufo'.openAllFolds()
        end,
        desc = 'Open all folds',
      },
      {
        'zM',
        function()
          return require 'ufo'.closeAllFolds()
        end,
        desc = 'Close all folds',
      },
    },
    opts = {
      provider_selector = function(_, filetype, buftype)
        return (filetype == '' or buftype == 'nofile') and 'indent' or { 'treesitter', 'indent' }
      end,
      fold_virt_text_handler = function(virtText, lnum, endLnum, width, truncate)
        local newVirtText = {}
        local suffix = (' 󰁂 %d lines'):format(endLnum - lnum)
        local sufWidth = vim.fn.strdisplaywidth(suffix)
        local targetWidth = width - sufWidth
        local curWidth = 0
        for _, chunk in ipairs(virtText) do
          local chunkText = chunk[1]
          local chunkWidth = vim.fn.strdisplaywidth(chunkText)
          if targetWidth > curWidth + chunkWidth then
            table.insert(newVirtText, chunk)
          else
            chunkText = truncate(chunkText, targetWidth - curWidth)
            local hlGroup = chunk[2]
            table.insert(newVirtText, { chunkText, hlGroup })
            chunkWidth = vim.fn.strdisplaywidth(chunkText)
            -- str width returned from truncate() may less than 2nd argument, need padding
            if curWidth + chunkWidth < targetWidth then
              suffix = suffix .. (' '):rep(targetWidth - curWidth - chunkWidth)
            end
            break
          end
          curWidth = curWidth + chunkWidth
        end
        table.insert(newVirtText, { suffix, 'MoreMsg' })
        return newVirtText
      end,
    },
  },

  -- indent-blankline.nvim
  {
    'lukas-reineke/indent-blankline.nvim',
    dependencies = { 'nvim-treesitter/nvim-treesitter' },
    main = 'ibl',
    opts = {
      indent = {
        char = '▏',
      },
      exclude = {
        filetypes = {
          'lspinfo',
          'packer',
          'checkhealth',
          'dashboard',
          'help',
          'lazy',
          'neo-tree',
          'man',
          'gitcommit',
          'TelescopePrompt',
          'TelescopeResults',
          'mason',
          '',
        },
      },
    },
  },

  -- lualine.nvim
  {
    'nvim-lualine/lualine.nvim',
    dependencies = 'nvim-tree/nvim-web-devicons',
    event = { 'BufReadPost', 'BufNewFile' },
    opts = {
      options = {
        disabled_filetypes = {
          'mason',
          'dashboard',
          'NeogitStatus',
          'NeogitCommitView',
          'NeogitPopup',
          'NeogitConsole',
        },
      },
      sections = {
        lualine_a = {
          {
            'mode',
            icons_enabled = true,
            fmt = function(str)
              return str:sub(1, 1)
            end,
          },
        },
        lualine_b = {
          'branch',
          'diff',
          'diagnostics',
        },
        lualine_c = { 'filename', { 'navic', color_correction = 'static' } },
        lualine_x = { 'encoding', 'fileformat', 'filetype' },
        lualine_y = { 'progress' },
        lualine_z = { 'searchcount', 'location' },
      },
      inactive_sections = {
        lualine_a = {},
        lualine_b = {
          'diff',
          'diagnostics',
        },
        lualine_c = { 'filename' },
        lualine_x = { 'location' },
        lualine_y = {},
        lualine_z = {},
      },
      extensions = {
        'man',
        'toggleterm',
        'neo-tree',
        'trouble',
        'lazy',
        'nvim-dap-ui',
      },
    },
  },

  -- which-key.nvim
  {
    'folke/which-key.nvim',
    dependencies = {
      'echasnovski/mini.icons',
    },
    config = function()
      local wk = require 'which-key'
      wk.add {
        { '<leader>f', group = 'find' },
        {
          '<leader>b',
          group = 'buffers',
          desc = 'Buffers',
          expand = function()
            return require 'which-key.extras'.expand.buf()
          end
        },
        {
          mode = { 'n', 'v' },
          { '<leader>q', '<cmd>q<cr>', desc = 'Quit' },
          { '<leader>w', '<cmd>w<cr>', desc = 'Write' },
        },
        {
          '<leader>g',
          group = 'git',
          desc = 'Git',
        },
        {
          '<leader>x',
          group = 'diagnostics',
          desc = 'Diagnostics',
        },
        {
          '<leader>d',
          group = 'debugger',
          desc = 'Debugger',
        },
      }
    end,
  },

  -- smart-splits.nvim
  {
    'mrjones2014/smart-splits.nvim',
    keys =
    {
      {
        '<C-h>',
        function()
          require 'smart-splits'.move_cursor_left()
        end,
        desc = 'Go to left window',
      },
      {
        '<C-j>',
        function()
          require 'smart-splits'.move_cursor_down()
        end,
        desc = 'Go to lower window',
      },

      {
        '<C-k>',
        function()
          require 'smart-splits'.move_cursor_up()
        end,
        desc = 'Go to upper window',
      },
      {
        '<C-l>',
        function()
          require 'smart-splits'.move_cursor_right()
        end,
        desc = 'Go to right window',
      },
      {
        '<A-h>',
        function()
          require 'smart-splits'.resize_left()
        end,
        desc = 'Resize left',
      },
      {
        '<A-j>',
        function()
          require 'smart-splits'.resize_down()
        end,
        desc = 'Resize down',
      },
      {
        '<A-k>',
        function()
          require 'smart-splits'.resize_up()
        end,
        desc = 'Resize up',
      },
      {
        '<A-l>',
        function()
          require 'smart-splits'.resize_right()
        end,
        desc = 'Resize right',
      },
    },
  }
}
