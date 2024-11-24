return {
  {
    'nvim-treesitter/nvim-treesitter',
    cmd = {
      'TSInstall',
      'TSBufEnable',
      'TSBufDisable',
      'TSModuleInfo',
    },
    build = ':TSUpdate',
    event = { 'BufReadPost', 'BufNewFile' },
    opts = {
      auto_install = true,
      ensure_installed = {
        'asm',
        'awk',
        'bash',
        'bibtex',
        'c',
        'c_sharp',
        'clojure',
        'cmake',
        'comment',
        'commonlisp',
        'cpp',
        'css',
        'csv',
        'cuda',
        'dart',
        'devicetree',
        'diff',
        'disassembly',
        'dockerfile',
        'dot',
        'doxygen',
        'elixir',
        'elm',
        'embedded_template',
        'erlang',
        'fish',
        'git_config',
        'git_rebase',
        'gitattributes',
        'gitcommit',
        'gitignore',
        'go',
        'gomod',
        'gosum',
        'gotmpl',
        'gowork',
        'gpg',
        'graphql',
        'groovy',
        'haskell',
        'haskell_persistent',
        'hcl',
        'helm',
        'html',
        'htmldjango',
        'http',
        'hurl',
        'ini',
        'java',
        'javascript',
        'jq',
        'jsdoc',
        'json',
        'json5',
        'jsonc',
        'jsonnet',
        'latex',
        'llvm',
        'lua',
        'luadoc',
        'luap',
        'make',
        'markdown',
        'markdown_inline',
        'matlab',
        'mermaid',
        'nasm',
        'ninja',
        'nix',
        'objc',
        'objdump',
        'ocaml',
        'ocaml_interface',
        'ocamllex',
        'passwd',
        'pem',
        'perl',
        'php',
        'phpdoc',
        'prisma',
        'promql',
        'proto',
        'pug',
        'puppet',
        'python',
        'qmldir',
        'qmljs',
        'query',
        'rasi',
        'regex',
        'rego',
        'requirements',
        'robot',
        'rst',
        'ruby',
        'rust',
        'scala',
        'scheme',
        'scss',
        'slint',
        'solidity',
        'sql',
        'squirrel',
        'ssh_config',
        'strace',
        'svelte',
        'swift',
        'slint',
        'systemtap',
        'terraform',
        'thrift',
        'toml',
        'tsv',
        'tsx',
        'typescript',
        'verilog',
        'vhs',
        'vim',
        'vimdoc',
        'vue',
        'xml',
        'yaml',
        'zig',
      },
      highlight = { enable = true },
      indent = { enable = true },
    },
    config = function(_, opts)
      -- performance issue
      -- vim.treesitter.query.set('lua', 'injections', '')

      -- gotmpl parser
      -- Run `:TSInstallFromGrammar gotmpl` to download and compile the grammar into your tree-sitter installation
      ---@class parser_config
      local parser_config = require 'nvim-treesitter.parsers'.get_parser_configs()
      parser_config.gotmpl = {
        install_info = {
          url = 'https://github.com/ngalaiko/tree-sitter-go-template',
          files = { 'src/parser.c' }
        },
        filetype = 'gotmpl',
        used_by = { 'gohtmltmpl', 'gotexttmpl', 'gotmpl', 'yaml' }
      }

      -- plantuml parser
      -- Run `:TSInstall plantuml` to download and install the parser
      parser_config.plantuml = {
        install_info = {
          url = 'https://github.com/Decodetalkers/tree_sitter_plantuml',
          branch = 'gh-pages',
          files = { 'src/parser.c' },
        },
        filetype = 'plantuml',
        used_by = { 'plantuml', 'puml' },
      }

      require 'nvim-treesitter.configs'.setup(opts)
    end,
  },

  -- -- nvim-treesitter-context
  -- {
  --   'nvim-treesitter/nvim-treesitter-context',
  --   dependencies = 'nvim-treesitter/nvim-treesitter',
  --   event = { 'BufReadPost', 'BufNewFile' },
  --   config = true,
  -- },

  -- treesj
  {
    'Wansmer/treesj',
    dependencies = 'nvim-treesitter/nvim-treesitter',
    opts = { max_join_length = 150 },
    keys = {
      {
        '<leader>sm',
        function() return require 'treesj'.toggle() end,
        desc = 'Toggle node under cursor',
      },
      {
        '<leader>sj',
        function()
          return require 'treesj'.join()
        end,
        desc = 'Join node under cursor',
      },
      {
        '<leader>ss',
        function()
          return require 'treesj'.split()
        end,
        desc = 'Split node under cursor',
      },
    },
  },

  -- rainbow-delimiters.nvim
  {
    'hiphish/rainbow-delimiters.nvim',
    dependencies = 'nvim-treesitter/nvim-treesitter',
    event = { 'BufReadPost', 'BufNewFile' },
  },
}
