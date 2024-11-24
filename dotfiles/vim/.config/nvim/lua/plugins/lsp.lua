return {
  -- nvim-lspconfig
  {
    'neovim/nvim-lspconfig',
    cmd = { 'LspStart', 'LspStop', 'LspRestart', 'LspInfo', 'LspLog' },
    event = { 'BufReadPre', 'BufNewFile' },
    dependencies = {
      { 'folke/neodev.nvim' },
      { 'hrsh7th/nvim-cmp' },
      {
        'williamboman/mason.nvim',
        cmd = { 'Mason', 'MasonInstall', 'MasonInstallAll', 'MasonUninstall', 'MasonUninstallAll', 'MasonLog' },
        opts = {
          PATH = 'prepend',

          ui = {
            icons = {
              package_pending = ' ',
              package_installed = '󰄳 ',
              package_uninstalled = ' 󰚌',
            },
          },
          max_concurrent_installers = 10,
        },
      },
      {
        'williamboman/mason-lspconfig.nvim',
        cmd = { 'LspInstall', 'LspUninstall' },
        opts = {
          ensure_installed = {
            -- lsp servers
            'asm_lsp',
            'basedpyright',
            'bashls',
            'biome',
            'clangd',
            'cmake',
            'cssls',
            'denols',
            'diagnosticls',
            'dockerls',
            'efm',
            'eslint',
            'golangci_lint_ls',
            'gopls',
            'gradle_ls',
            'grammarly',
            'graphql',
            'helm_ls',
            'html',
            'jqls',
            'jsonls',
            'lua_ls',
            'marksman',
            'neocmake',
            'perlnavigator',
            'pyright',
            'ruff_lsp',
            'rust_analyzer',
            'slint_lsp',
            'solargraph',
            'solc',
            'solidity',
            'sqlls',
            'taplo',
            'terraformls',
            'texlab',
            'ltex',
            'tflint',
            'ts_ls',
            'java_language_server',
            'vimls',
            'yamlls',
            'zk',
            'zls',
          },
        },
      },
      { 'b0o/schemastore.nvim' },
      { 'ray-x/go.nvim' },
    },
    keys = {
      {
        'gd',
        function()
          return require 'telescope.builtin'.lsp_definitions()
        end,
        desc = 'Goto Definition',
      },
      {
        'gr',
        function()
          return require 'telescope.builtin'.lsp_references()
        end,
        desc = 'References',
      },
      {
        'gR',
        function()
          return vim.lsp.buf.rename()
        end,
        desc = 'Rename',
      },
      {
        'gD',
        vim.lsp.buf.declaration,
        desc = 'Goto Declaration',
      },
      {
        'gI',
        function()
          return require 'telescope.builtin'.lsp_implementations()
        end,
        desc = 'Goto Implementation',
      },
      {
        'gy',
        function()
          return require 'telescope.builtin'.lsp_type_definitions()
        end,
        desc = 'Goto T[y]pe Definition',
      },
      { 'K',  vim.lsp.buf.hover,          desc = 'Hover' },
      { 'gK', vim.lsp.buf.signature_help, desc = 'Signature Help' },
    },
    config = function()
      local capabilities = vim.lsp.protocol.make_client_capabilities()
      capabilities.textDocument.completion.completionItem.snippetSupport = true
      capabilities.workspace.didChangeWatchedFiles.dynamicRegistration = true
      capabilities.offsetEncoding = { 'utf-16', 'utf-8' }

      local lspconfig = require 'lspconfig'
      local handlers = require 'etc/lsp_handlers'

      lspconfig.autotools_ls.setup {}

      lspconfig.cssls.setup {
        capabilities = capabilities,
      }

      lspconfig.omnisharp.setup {
        capabilities = capabilities,
        enable_roslyn_analyzers = false,
      }

      lspconfig.slint_lsp.setup {
        capabilities = capabilities,
        single_file_support = true,
      }

      -- lspconfig.csharp_ls.setup {
      --   capabilities = capabilities,
      -- }

      lspconfig.gopls.setup {
        capabilities = capabilities,
        cmd = { 'gopls', 'serve' },
        settings = {
          gopls = {
            analyses = {
              unusedparams = true,
            },
            staticcheck = true,
            gofumpt = true,
          },
        },
      }

      lspconfig.java_language_server.setup {}

      lspconfig.golangci_lint_ls.setup {
        capabilities = capabilities,
      }

      lspconfig.texlab.setup {
        settings = {
          texlab = {
            bibtexFormatter = 'texlab',
            build = {
              args = { '-X', 'compile', '%f', '--synctex', '--keep-logs', '--keep-intermediates' },
              executable = 'tectonic',
            },
            chktex = {
              onEdit = false,
              onOpenAndSave = false,
            },
            formatterLineLength = 120,
            forwardSearch = {
              executable = 'zathura',
              args = { '--synctex-forward', '%l:1:%f', '%p' }
            },
            latexFormatter = 'latexindent',
            latexindent = {
              modifyLineBreaks = false
            }
          }
        }
      }

      lspconfig.ltex.setup {
        filetypes = { 'tex', 'latex', 'plaintex', 'bib' },
      }

      lspconfig.clangd.setup {
        capabilities = require 'cmp_nvim_lsp'.default_capabilities(),
        cmd = {
          'clangd',
          '--offset-encoding=utf-16',
        },
        on_attach = function(client)
          require 'clangd_extensions.inlay_hints'.setup_autocmd()
          require 'clangd_extensions.inlay_hints'.set_inlay_hints()
        end,
        filetypes = { 'c', 'cpp', 'objc', 'objcpp', 'cuda' },
      }

      lspconfig.helm_ls.setup {
        capabilities = capabilities,
        filetypes = { 'helm' },
        cmd = { 'helm_ls', 'serve' },
      }

      lspconfig.diagnosticls.setup {
        capabilities = capabilities,
        on_init = function(client)
          client.server_capabilities.documentFormattingProvider = true
          client.server_capabilities.documentRangeFormattingProvider = true
          client.server_capabilities.executeCommandProvider = true
          client.request = handlers.client_request(client)
        end,
        filetypes = { 'markdown', 'tex', 'text', 'pandoc' },
        handlers = {
          ['textDocument/codeAction'] = {
            type = 'local_lsp',
            handler = handlers.lintCodeAction,
          },
          ['workspace/executeCommand'] = {
            type = 'local_lsp',
            handler = handlers.workspaceExecuteCommand,
          },
        },
      }

      lspconfig.grammarly.setup {
        capabilities = capabilities,
        on_init = function(client)
          client.server_capabilities.documentFormattingProvider = true
          client.server_capabilities.documentRangeFormattingProvider = true
          client.server_capabilities.executeCommandProvider = true
          -- client.resolved_capabilities.execute_command = true
        end,
        filetypes = { 'markdown', 'tex', 'text', 'pandoc' },
        settings = {
          grammarly = {
            config = {
              documentDomain = 'academic',
            },
          },
        },
      }

      lspconfig.taplo.setup {
        capabilities = capabilities,
      }

      lspconfig.terraformls.setup {
        capabilities = capabilities,
        cmd = { 'terraform-ls', 'serve' },
        filetypes = { 'tf', 'terraform', 'terraform-vars' },
        root_dir = lspconfig.util.root_pattern('.terraform', '.git'),
      }

      lspconfig.lua_ls.setup {
        on_init = function(client)
          local path = client.workspace_folders[1].name
          if vim.uv.fs_stat(path .. '/.luarc.json') or vim.uv.fs_stat(path .. '/.luarc.jsonc') then
            return
          end

          client.config.settings.Lua = vim.tbl_deep_extend('force', client.config.settings.Lua, {
            runtime = {
              version = 'LuaJIT',
            },
            workspace = {
              checkThirdParty = false,
              library = {
                vim.env.VIMRUNTIME
              },
              -- library = vim.api.nvim_get_runtime_file('', true),
            },
            diagnostics = {
              enable = true,
              globals = {
                'vim',
                'describe',
                'it',
                'before_each',
                'after_each',
                'teardown',
                'pending',
                'lfs',
              },
            },
            hint = {
              enable = true,
            },
          })
        end,
        settings = {
          Lua = {}
        }
      }

      lspconfig.bashls.setup {
        capabilities = capabilities,
      }

      lspconfig.rust_analyzer.setup {
        capabilities = capabilities,
        on_attach = function(client, bufnr)
          vim.lsp.inlay_hint.enable(true, { bufnr = bufnr })
        end,
        settings = {
          ['rust-analyzer'] = {
            imports = {
              granularity = {
                group = 'module',
              },
              prefix = 'self',
            },
            check = {
              command = 'clippy',
            },
            inlayHints = {
              chainingHints = {
                enable = true,
              },
              typeHints = {
                enable = true,
              },
              parameterHints = {
                enable = true,
              },
              maxLength = 120,
            },
          },
        },
      }


      --Enable (broadcasting) snippet capability for completion
      local jsonls_capabilities = vim.lsp.protocol.make_client_capabilities()
      jsonls_capabilities.textDocument.completion.completionItem.snippetSupport = true
      lspconfig.jsonls.setup {
        capabilities = jsonls_capabilities,
        settings = {
          json = {
            schemas = require 'schemastore'.json.schemas(),
            validate = { enable = true },
          },
        },
      }

      lspconfig.yamlls.setup {
        capabilities = capabilities,
        settings = {
          yaml = {
            schemas = vim.tbl_deep_extend('force',
              require 'schemastore'.yaml.schemas(),
              {
                ['https://raw.githubusercontent.com/jeewangue/kubernetes-json-schema/master/v1.28.3-standalone-strict/all.json'] = '*.k8s.yaml',

              }
            ),
            schemaStore = {
              enable = false,
              url = '',
            },
            format = {
              enable = true,
              format = {
                printWidth = 160,
              },
            },
            hover = true,
            completion = true,
            validate = true,

          },
        },
      }

      lspconfig.basedpyright.setup {
      }

      lspconfig.ts_ls.setup {
        capabilities = capabilities,
      }

      lspconfig.ruff_lsp.setup {
        capabilities = capabilities,
      }

      lspconfig.marksman.setup {
        capabilities = capabilities,
        filetypes = { 'markdown', 'markdown.mdx', 'markdown.pandoc', 'pandoc' },
      }

      lspconfig.eslint.setup {
        capabilities = capabilities,
      }

      lspconfig.solargraph.setup {
        -- cmd = { 'bundle', 'exec', 'solargraph', 'stdio' },
        cmd = { 'solargraph', 'stdio' },
      }


      lspconfig.efm.setup {
        capabilities = capabilities,
        init_options = {
          documentFormatting = true,
          documentRangeFormatting = true,
          hover = true,
          documentSymbol = true,
          codeAction = true,
          completion = true
        },
        filetypes = { 'cfn', 'yaml' },
        settings = {
          log_level = 1,
          rootMarkers = { '.git/' },
          languages = {
            cfn = {
              {
                lintCommand = 'cfn-lint -f parseable',
                lintStdin = false,
                lintIgnoreExitCode = true,
                lintFormats = { '%f:%l:%c:%e:%k:%t%n:%m' },
              }
            },
            yaml = {
              {
                lintCommand =
                'yamllint -f parsable -d "{extends: default, rules: {line-length: disable, comments: disable, comments-indentation: disable, document-start: disable}}" -',
                lintStdin = true,
                lintIgnoreExitCode = true,
                lintFormats = { '%f:%l:%c: %m' },
                formatCommand = 'prettier --parser yaml',
                formatStdin = true
              }
            },
          }
        },
        single_file_support = true,
      }

      lspconfig.cmake.setup {
        capabilities = capabilities,
        on_attach = function(client)
          client.server_capabilities.hoverProvider = false
          client.server_capabilities.documentSymbolProvider = false
        end,
      }

      lspconfig.neocmake.setup {
        capabilities = capabilities,
      }

      lspconfig.dockerls.setup {
      }

      require 'mason-lspconfig'.setup {}
    end,
  },

  -- lsp-inlayhints.nvim
  {
    'lvimuser/lsp-inlayhints.nvim',
    event = 'LspAttach',
    config = true,
  },

  -- nvim-navic
  {
    'SmiteshP/nvim-navic',
    event = 'LspAttach',
    opts = {
      highlight = true,
      lsp = {
        auto_attach = true,
        preference = {
          'yamlls', 'jsonls', 'ts_ls', 'pyright', 'rust_analyzer', 'clangd', 'gopls', 'bashls'
        },
      },
      icons = {
        Array = ' ',
        Boolean = ' ',
        Class = ' ',
        Color = ' ',
        Constant = ' ',
        Constructor = ' ',
        Copilot = ' ',
        Enum = ' ',
        EnumMember = ' ',
        Event = ' ',
        Field = ' ',
        File = ' ',
        Folder = ' ',
        Function = ' ',
        Interface = ' ',
        Key = ' ',
        Keyword = ' ',
        Method = ' ',
        Module = ' ',
        Namespace = ' ',
        Null = ' ',
        Number = ' ',
        Object = ' ',
        Operator = ' ',
        Package = ' ',
        Property = ' ',
        Reference = ' ',
        Snippet = ' ',
        String = ' ',
        Struct = ' ',
        Text = ' ',
        TypeParameter = ' ',
        Unit = ' ',
        Value = ' ',
        Variable = ' ',
      },
    },
  },

  -- mfussenegger/nvim-lint
  {
    'mfussenegger/nvim-lint',
    event = { 'BufReadPre', 'BufNewFile' },
    config = function()
      local lint = require 'lint'
      lint.linters_by_ft = {
        -- python = { 'mypy' },
        make = { 'checkmake' },
        sh = { 'shellcheck' },
        markdown = { 'markdownlint' },
        json = { 'jsonlint' },
        dockerfile = { 'hadolint' },
        htmldjango = { 'djlint' },
        proto = { 'buf_lint' },
        protobuf = { 'buf_lint' },
        terraform = { 'tflint', 'trivy' },
      }

      vim.api.nvim_create_autocmd({ 'BufEnter' }, {
        callback = function()
          require 'lint'.try_lint()
        end,
      })

      vim.api.nvim_create_autocmd({ 'BufWritePost' }, {
        callback = function()
          require 'lint'.try_lint()
        end,
      })
    end,
  },

  -- conform.nvim
  {
    'stevearc/conform.nvim',
    event = { 'BufWritePre' },
    cmd = { 'ConformInfo' },
    keys = {
      {
        '<leader>fm',
        function()
          require 'conform'.format { async = true, lsp_fallback = true }
        end,
        desc = 'Format with Conform',
      },
    },
    opts = {
      formatters_by_ft = {
        -- Conform will run multiple formatters sequentially
        python = { 'isort', 'black', 'ruff' },
        -- Use a sub-list to run only the first available formatter
        javascript = { 'prettier' },
        typescript = { 'prettier' },
        -- rust = { 'rustfmt' },
        sh = { 'shfmt' },
        toml = { 'taplo' },
        go = { 'gofumpt', 'goimports' },
        gotmpl = { 'prettier' },
        markdown = { 'prettier' },
        pandoc = { 'prettier' },
        java = { 'google-java-format' },
        sql = { 'sleek' },
        xml = { 'xmlformat' },
        html = { 'prettier' },
        json = { 'prettier' },
        htmldjango = { 'djlint' },
        css = { 'prettier' },
        scss = { 'prettier' },
        sass = { 'prettier' },
        cmake = { 'gersemi' },
        proto = { 'buf' },
      },
      formatters = {
        shfmt = {
          prepend_args = { '-i', '2' },
        },
      },
    },
    config = true,
  },

  -- ThePrimeagen/refactoring.nvim
  {
    'ThePrimeagen/refactoring.nvim',
    dependencies = {
      'nvim-lua/plenary.nvim',
      'nvim-treesitter/nvim-treesitter',
      'nvim-telescope/telescope.nvim',
    },
    keys = {
      {
        '<leader>rr',
        function()
          require 'telescope'.extensions.refactoring.refactors()
        end,
        mode = { 'n', 'x' },
      }
    },
    config = function()
      require 'refactoring'.setup()
      require 'telescope'.load_extension 'refactoring'
    end,
  },

  -- clangd_extensions.nvim
  {
    'p00f/clangd_extensions.nvim',
    filetypes = { 'c', 'cpp', 'objc', 'objcpp', 'cuda' },
    opts = {
      inlay_hints = {
        highlight = 'MyInlayHint',
      },
    },
  },

  -- fidget.nvim
  {
    'j-hui/fidget.nvim',
    event = 'LspAttach',
    -- NOTE: Keep branch option until further notice
    -- Related: https://github.com/j-hui/fidget.nvim/commit/a6c51e2
    -- Also related: https://github.com/j-hui/fidget.nvim/issues/131
    branch = 'legacy',
    opts = {
      window = {
        blend = 0,
        relative = 'editor'
      },
      text = { spinner = 'dots' }
    },
  },

  -- lsp_lines.nvim
  {
    'https://git.sr.ht/~whynothugo/lsp_lines.nvim',
    event = 'LspAttach',
    keys = {
      {
        '<leader>ll',
        function()
          local enabled = require 'lsp_lines'.toggle()
          vim.g.lsp_lines_enabled = enabled
          vim.diagnostic.config {
            virtual_text = not enabled,
            virtual_lines = enabled,
          }
        end,
        desc = 'Toggle LSP Lines',
      },
    },
    config = function()
      vim.g.lsp_lines_enabled = true

      vim.diagnostic.config {
        virtual_text = false,
        virtual_lines = true,
      }

      require 'lsp_lines'.setup()
    end,
  },

  -- actions-preview.nvim
  {
    'aznhe21/actions-preview.nvim',
    dependencies = 'nvim-telescope/telescope.nvim',
    event = 'LspAttach',
    keys = {
      {
        'gf',
        function()
          require 'actions-preview'.code_actions()
        end,
        mode = { 'n', 'v' },
        desc = 'Open actions-preview.nvim',
      },
    },
    opts = {
      diff = {
        algorithm = 'patience',
      },
      telescope = {
        sorting_strategy = 'ascending',
        layout_strategy = 'vertical',
        layout_config = {
          width = 0.8,
          height = 0.9,
          prompt_position = 'top',
          preview_cutoff = 20,
          preview_height = function(_, _, max_lines)
            return max_lines - 15
          end,
        },
      },
    },
  },

  -- rust-tools.nvim
  -- {
  --   'simrat39/rust-tools.nvim',
  --   event = 'BufReadPre',
  --   ft = { 'rust' },
  --   config = function()
  --     require 'rust-tools'.setup {
  --       tools = {
  --         autoSetHints = true,
  --         runnables = {
  --           use_telescope = true,
  --         },
  --         inlay_hints = {
  --           show_parameter_hints = true,
  --           parameter_hints_prefix = '<- ',
  --           other_hints_prefix = '=> ',
  --           highlight = 'MyInlayHint',
  --         },
  --       },
  --     }
  --   end,
  -- },

  -- nvim-dap
  {
    'mfussenegger/nvim-dap',
    dependencies = {
      -- nvim-dap-virtual-text
      {
        'theHamsta/nvim-dap-virtual-text',
        opts = { highlight_new_as_changed = true }
      },

      -- mason-nvim-dap.nvim
      {
        'jay-babu/mason-nvim-dap.nvim',
        cmd = { 'DapInstall', 'DapUninstall' },
        dependencies = 'williamboman/mason.nvim',
        opts = {
          automatic_installation = true,
          ensure_installed = { 'cpptools', 'codelldb', 'delve', 'go-debug-adapter', 'node-debug2-adapter', 'debugpy' },
          handlers = {},
        },
      },

      -- goto-breakpoints.nvim
      {
        'ofirgall/goto-breakpoints.nvim',
        keys = {
          -- stylua: ignore start
          { ']b', function() return require 'goto-breakpoints'.next() end, desc = 'Next breakpoint' },
          { '[b', function() return require 'goto-breakpoints'.prev() end, desc = 'Previous breakpoint' },
          -- stylua: ignore end
        },
      },

      -- nvim-dap-ui
      {
        'rcarriga/nvim-dap-ui',
        dependencies = { 'nvim-neotest/nvim-nio' },
        keys = {
          -- stylua: ignore start
          { '<leader>du', function() return require 'dapui'.toggle() end, desc = 'Dap UI' },
          { '<leader>de', function() return require 'dapui'.eval() end,   desc = 'Eval',  mode = { 'n', 'v' } },
          -- stylua: ignore end
        },
        config = function()
          local dap = require 'dap'
          local dapui = require 'dapui'
          dapui.setup()
          dap.listeners.after.event_initialized['dapui_config'] = function()
            dapui.open()
          end
          dap.listeners.before.event_terminated['dapui_config'] = function()
            dapui.close()
          end
          dap.listeners.before.event_exited['dapui_config'] = function()
            dapui.close()
          end
        end,
      },
      {
        'mfussenegger/nvim-dap-python',
      }
    },
    keys = {
      {
        '<leader>dB',
        function() return require 'dap'.set_breakpoint(vim.fn.input 'Breakpoint condition: ') end,
        desc = 'Breakpoint Condition'
      },
      {
        '<leader>db',
        function() return require 'dap'.toggle_breakpoint() end,
        desc = 'Toggle Breakpoint'
      },
      {
        '<leader>dc',
        function() return require 'dap'.continue() end,
        desc = 'Continue'
      },
      {
        '<leader>dC',
        function() return require 'dap'.run_to_cursor() end,
        desc = 'Run to Cursor'
      },
      {
        '<leader>dg',
        function() return require 'dap'.goto_() end,
        desc = 'Go to line (no execute)'
      },
      {
        '<leader>di',
        function() return require 'dap'.step_into() end,
        desc = 'Step Into'
      },
      {
        '<leader>dj',
        function() return require 'dap'.down() end,
        desc = 'Down'
      },
      {
        '<leader>dk',
        function() return require 'dap'.up() end,
        desc = 'Up'
      },
      {
        '<leader>dl',
        function() return require 'dap'.run_last() end,
        desc = 'Run Last'
      },
      {
        '<leader>dO',
        function() return require 'dap'.step_out() end,
        desc = 'Step Out'
      },
      {
        '<leader>do',
        function() return require 'dap'.step_over() end,
        desc = 'Step Over'
      },
      {
        '<leader>dp',
        function() return require 'dap'.pause() end,
        desc = 'Pause'
      },
      {
        '<leader>dr',
        function() return require 'dap'.repl.toggle() end,
        desc = 'Toggle REPL'
      },
      {
        '<leader>ds',
        function() return require 'dap'.session() end,
        desc = 'Session'
      },
      {
        '<leader>dt',
        function() return require 'dap'.terminate() end,
        desc = 'Terminate'
      },
      {
        '<leader>dw',
        function() return require 'dap.ui.widgets'.hover() end,
        desc = 'Widgets'
      },
    },
    config = function()
      vim.api.nvim_set_hl(0, 'DapStoppedLine', { default = true, link = 'Visual' })


      local dap = require 'dap'
      require 'dap-python'.setup(vim.fn.exepath 'python')

      dap.adapters.cppdbg = {
        id = 'cppdbg',
        type = 'executable',
        command = 'OpenDebugAD7',
      }

      dap.adapters.go = {
        id = 'go-debug-adapter',
        type = 'executable',
        command = 'go-debug-adapter',
      }



      dap.configurations.python = {
        {
          type = 'python',
          name = 'Launch file',
          request = 'launch',
          program = '${file}',
          cwd = function()
            local cwd = '${workspaceFolder}'
            local custom_cwd = vim.fn.input('cwd [' .. cwd .. ']: ')
            return custom_cwd ~= '' and custom_cwd or cwd
          end,
        },
        {
          type = 'python',
          request = 'attach',
          name = 'Attach remote (with path mapping)',
          connect = function()
            local host = vim.fn.input 'Host [127.0.0.1]: '
            host = host ~= '' and host or '127.0.0.1'
            local port = tonumber(vim.fn.input 'Port [5678]: ') or 5678
            return { host = host, port = port }
          end,
          pathMappings = function()
            local cwd = '${workspaceFolder}'
            local local_path = vim.fn.input('Local path mapping [' .. cwd .. ']: ')
            local_path = local_path ~= '' and local_path or cwd
            local remote_path = vim.fn.input 'Remote path mapping [.]: '
            remote_path = remote_path ~= '' and remote_path or '.'
            return { { localRoot = local_path, remoteRoot = remote_path }, }
          end
        },
      }


      dap.configurations.go = {
        {
          type = 'go',
          name = 'Debug',
          request = 'launch',
          showLog = false,
          program = '${file}',
          dlvToolPath = vim.fn.exepath 'dlv' -- Adjust to where delve is installed
        },
      }
    end,
  },

  -- yanzkun/gotests.nvim
  {
    'yanskun/gotests.nvim',
    ft = 'go',
    config = function()
      require 'gotests'.setup()
    end,
  },

  -- ray-x/go.nvim
  {
    'ray-x/go.nvim',
    dependencies = { -- optional packages
      'ray-x/guihua.lua',
      'neovim/nvim-lspconfig',
      'nvim-treesitter/nvim-treesitter',
    },
    config = function()
      require 'go'.setup {
        lsp_cfg = true,
        -- diagnostic = ,
      }
    end,
    event = { 'CmdlineEnter' },
    ft = { 'go', 'gomod' },
    build = ':lua require("go.install").update_all_sync()' -- if you need to install/update all binaries
  }
}
