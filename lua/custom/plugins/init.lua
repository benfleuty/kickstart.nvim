-- ~/.config/nvim/lua/custom/plugins/init.lua

return {
  -- Add these plugins and configurations for TypeScript and React Native

  -- nvim-treesitter for enhanced syntax highlighting, indentation, and code navigation
  -- This is crucial for correctly parsing JSX/TSX
  {
    'nvim-treesitter/nvim-treesitter',
    build = ':TSUpdate',   -- Command to run after installation to install parsers
    opts = {
      ensure_installed = { -- Ensure these parsers are installed
        'javascript',
        'typescript',
        'tsx',
        'json',                      -- Often useful in React Native projects
        'css',                       -- For StyleSheet objects or CSS-in-JS
        'html',                      -- If you mix with web views or HTML components
      },
      highlight = { enable = true }, -- Enable syntax highlighting
      indent = { enable = true },    -- Enable indentation
    },
    -- Configure Treesitter to parse relevant file types
    config = function(_, opts)
      require('nvim-treesitter.configs').setup(opts)
    end,
  },

  -- conform.nvim for integrating external formatters (like Prettier)
  -- This replaces null-ls.nvim for formatting
  {
    'stevearc/conform.nvim',
    lazy = false, -- Ensure the plugin loads eagerly
    config = function()
      require('conform').setup {
        format_on_save = {
          timeout_ms = 500,
          lsp_fallback = true,
        },
        formatters_by_ft = {
          javascript = { 'prettier' },
          javascriptreact = { 'prettier' },
          typescript = { 'prettier' },
          typescriptreact = { 'prettier' },
          json = { 'prettier' },
          yaml = { 'prettier' },
          markdown = { 'prettier' },
          css = { 'prettier' },
        },
      }
    end,
  },

  -- LSP Configuration for TypeScript (tsserver)
  {
    'neovim/nvim-lspconfig',
    -- This 'opts' function will be merged with the existing LSP configurations from kickstart.
    -- Ensure tsserver is configured for JavaScript and TypeScript files.
    opts = {
      servers = {
        -- tsserver configuration for TypeScript and JavaScript/React
        tsserver = {
          filetypes = { 'javascript', 'javascriptreact', 'typescript', 'typescriptreact' },
          -- IMPORTANT: tsserver needs to find a project root (tsconfig.json or jsconfig.json)
          -- This helps it understand your project's context, modules, etc.
          root_dir = require('lspconfig.util').root_pattern('tsconfig.json',
            'jsconfig.json', 'package.json', '.git'),
          -- init_options allows passing specific options to the language server
          init_options = {
            hostInfo = 'neovim',
            preferences = {
              disableSuggestions = false,
              includeCompletionsForModuleExports = true,
              includeCompletionsWithInsertText = true,
              jsx = true, -- Explicitly enable JSX support if needed
            },
          },
          -- Add any specific settings for tsserver if needed
          settings = {},
        },
        -- Optional: Add other relevant LSP servers that might be useful
        -- jsonls for JSON schema validation (e.g., package.json, app.json)
        jsonls = {}, -- Uses default settings, assumes jsonls is available via nvim-lspconfig
        -- If you use Tailwind CSS with React Native, this LSP can be very helpful
        -- tailwindcss = {}, -- Ensure this server is installed via mason/lspinstall first
        -- You might also want to explicitly configure 'eslint' LSP if you prefer it over conform's linter integration
        -- eslint = {
        --   -- Ensure eslint server is installed via mason.nvim
        --   filetypes = { 'javascript', 'javascriptreact', 'typescript', 'typescriptreact' },
        --   -- Example for root_dir (often not strictly necessary as eslint_d should handle it)
        --   root_dir = require('lspconfig.util').root_pattern('.eslintrc.js', '.eslintrc.json', 'package.json'),
        -- },
      },
      -- General LSP options that apply to all servers if not overridden
      -- For example, common keymaps for LSP actions
      -- on_attach = function(client, bufnr)
      --   -- This on_attach might already be handled by kickstart's main LSP setup.
      --   -- Only add if you need to override or add *additional* behavior.
      --   -- For instance, if kickstart doesn't set up keymaps, you could do it here:
      --   -- require('kickstart.plugins.lspconfig').on_attach(client, bufnr) -- if kickstart provides an exported on_attach
      -- end,
    },
  },

  -- LuaSnip for snippets (code templates)
  -- Useful for quickly inserting React components, hooks, etc.
  {
    'L3MON4D3/LuaSnip',
    dependencies = {
      'saadparwaiz1/cmp_luasnip',     -- Integration with nvim-cmp
      'rafamadriz/friendly-snippets', -- Collection of common snippets (includes React/TypeScript)
    },
    build = 'make install_jsregexp',  -- Required for some features like regex in snippets
    config = function()
      -- Load snippets from VS Code compatible format (friendly-snippets uses this)
      require('luasnip.loaders.from_vscode').lazy_load()
      -- You can also define custom snippets directly here or in separate files
      -- Example custom React Native snippet:
      -- local luasnip = require('luasnip')
      -- local s = luasnip.snippet
      -- local t = luasnip.text_node
      -- local i = luasnip.insert_node
      --
      -- luasnip.add_snippets('typescriptreact', {
      --   s('rnf', { -- React Native Function Component with StyleSheet
      --     t('import React from \'react\';'),
      --     t('import { View, Text, StyleSheet } from \'react-native\';'),
      --     t(''),
      --     t('interface '), i(1, 'Props'), t(' {}'),
      --     t(''),
      --     t('const '),
      --     i(2, 'MyComponent'),
      --     t(': React.FC<'), i(1), t('> = ({}) => {'),
      --     t('  return ('),
      --     t('    <View style={styles.container}>'),
      --     t('      <Text>'),
      --     i(3, 'Hello React Native!'),
      --     t('</Text>'),
      --     t('    </View>'),
      --     t('  );'),
      --     t('};'),
      --     t(''),
      --     t('const styles = StyleSheet.create({'),
      --     t('  container: {'),
      --     t('    flex: 1,'),
      --     t('    justifyContent: \'center\','),
      --     t('    alignItems: \'center\',')
      --     t('  },'),
      --     t('});'),
      --     t(''),
      --     t('export default '),
      --     i(2),
      --     t(';'),
      --   }),
      -- })
    end,
  },

  -- nvim-cmp: Autocompletion plugin
  -- Ensure it uses 'luasnip' as a source for snippet completions
  {
    'hrsh7th/nvim-cmp',
    opts = function(_, opts)
      -- Ensure opts.sources is a table
      opts.sources = opts.sources or {}

      -- Insert the 'luasnip' source if it's not already in opts.sources
      local has_luasnip_source = false
      for _, source in ipairs(opts.sources) do
        if source.name == 'luasnip' then
          has_luasnip_source = true
          break
        end
      end
      if not has_luasnip_source then
        table.insert(opts.sources, 1, { name = 'luasnip' })
      end
    end,
  },

  -- Ensure mason.nvim is installed and configured to manage LSP servers and formatters
  -- (This is usually part of kickstart.nvim already, but ensure it's there
  -- if you install servers like 'tsserver' and 'prettier' via Mason)
  {
    'williamboman/mason.nvim',
    opts = function(_, opts)
      -- Ensure tsserver and prettier are set to be installed automatically by Mason
      -- You can also install them manually with `:MasonInstall tsserver prettier`
      opts.ensure_installed = opts.ensure_installed or {}
      vim.list_extend(opts.ensure_installed, { 'tsserver', 'prettier', 'eslint_d' }) -- Added eslint_d for faster eslint
    end,
  },

  -- mason-lspconfig.nvim: Bridges mason.nvim and nvim-lspconfig
  -- (Also usually part of kickstart.nvim)
  {
    'williamboman/mason-lspconfig.nvim',
    opts = function(_, opts)
      -- Set up default server configurations managed by mason-lspconfig
      opts.ensure_installed = opts.ensure_installed or {}
      vim.list_extend(opts.ensure_installed, { 'tsserver', 'jsonls', 'eslint' }) -- Ensure these are installed and set up
    end,
  },
}
