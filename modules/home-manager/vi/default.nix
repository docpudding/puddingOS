{
    pkgs,
    config,
    lib,
    ...
}:
with lib; let
    nixvim = import (builtins.fetchTarball {
        url = "https://github.com/nix-community/nixvim/archive/nixos-25.11.tar.gz";
        sha256 = "1v4gghvjrzj7kwzvwgwjbhbiavwzbc5ncwjicc1jgjwdmbdaqhw7";
    });
in {
    imports = [nixvim.homeManagerModules.nixvim];

    options.pos.vi = {
        enable = mkOption {
            type = types.bool;
            default = false;
            description = "Enable Neovim configurations.";
        };
    };

    config = mkIf (config.pos.vi.enable
        && config.pos.enable) {
        programs.nixvim = {
            enable = true;
            defaultEditor = true;

            keymaps = import ./keymaps.nix;

            # Run from the terminal using vi, vim, or nvim.
            viAlias = true;
            vimAlias = true;

            # Use the objectively correct tab length.
            opts = {
                tabstop = 4;
                shiftwidth = 4;
                expandtab = true;
            };

            # Enable clipboard integration, including on Wayland.
            clipboard = {
                register = "unnamedplus";
                providers.wl-copy.enable = true;
            };

            plugins = {
                telescope.enable = true; # Fuzzy search utility for file names and content.
                web-devicons.enable = true; # Provides file-type icons.

                # Language Server Protocol (LSP) integrations for various languages.
                lsp = {
                    enable = true;
                    servers.pyright.enable = true; # Python
                    servers.jdtls.enable = true; # Java

                    servers.nil_ls.enable = true; # Nix language
                    servers.markdown_oxide.enable = true; # Markdown

                    # TypeScript/JavaScript language with support for Vue/etc.
                    servers.ts_ls = {
                        enable = true;
                        filetypes = [
                            "javascript"
                            "javascriptreact"
                            "javascript.jsx"
                            "typescript"
                            "typescriptreact"
                            "typescript.tsx"
                            "vue"
                        ];
                    };

                    # Vue framework
                    servers.vue_ls = {
                        enable = true;
                        extraOptions.init_options.typescript.tsdk = "${pkgs.typescript}/lib/node_modules/typescript/lib";
                    };

                    # Godot Engine scripting language
                    servers.gdscript = {
                        enable = true;
                        package = pkgs.godot;
                        filetypes = ["gd" "gdscript"];
                        rootMarkers = ["project.godot"];
                        autostart = true;
                    };
                };

                # Auto-formatter.
                conform-nvim = {
                    enable = true;
                    settings = {
                        formatters_by_ft = {
                            # Use Prettier for all languages that it supports.
                            javascript = ["prettier"];
                            javascriptreact = ["prettier"];
                            typescript = ["prettier"];
                            typescriptreact = ["prettier"];
                            json = ["prettier"];
                            jsonc = ["prettier"];
                            html = ["prettier"];
                            css = ["prettier"];
                            scss = ["prettier"];
                            less = ["prettier"];
                            yaml = ["prettier"];
                            markdown = ["prettier"];
                            graphql = ["prettier"];
                            vue = ["prettier"];

                            # Godot scripts.
                            gd = ["gd_format"];
                            gdscript = ["gd_format"];

                            # Use dedicated formatters for other languages.
                            python = ["ruff_format"];
                            nix = ["alejandra_format"];
                        };

                        # Use special options for certain formatters.
                        formatters = {
                            prettier = {
                                command = "${pkgs.nodePackages.prettier}/bin/prettier";
                                args = ["--tab-width" "4" "--stdin-filepath" "$FILENAME"];
                            };

                            alejandra_format = {
                                command = "alejandra";
                                args = [
                                    "--experimental-config"
                                    "${./alejandra.toml}"
                                ];
                            };

                            ruff_format = {
                                command = "ruff";
                                args = ["format" "-"];
                                stdin = true;
                            };

                            gd_format = {
                                command = "gdformat";
                                args = ["-"];
                                stdin = true;
                            };
                        };

                        # Automatically apply the formatter before writing to file.
                        format_on_save = {
                            lsp_fallback = true;
                            timeout_ms = 1000;
                        };
                    };
                };

                # Auto-completion.
                cmp = {
                    enable = true;
                    settings = {
                        snippet.expand = ''
                            function(args)
                                require("luasnip").lsp_expand(args.body)
                            end
                        '';

                        # Completion sources by priority order.
                        sources = [
                            {name = "nvim_lsp";} # LSP server completions.
                            {name = "luasnip";} # Snippet completions.
                            {name = "nvim_lua";} # Neovim LUA API completions.
                            {name = "buffer";} # Words from open buffers completions.
                            {name = "path";} # File system path completions.
                        ];

                        # Keybinds for navigating the completion menu.
                        mapping = {
                            "<Tab>" = "cmp.mapping.select_next_item()";
                            "<S-Tab>" = "cmp.mapping.select_prev_item()";
                        };
                    };
                };

                # Dependencies for the auto-completion plugin.
                cmp-nvim-lsp.enable = true;
                cmp-buffer.enable = true;
                cmp-path.enable = true;
                cmp-cmdline.enable = true;
                cmp_luasnip.enable = true;
                luasnip.enable = true;

                # Syntax parsing/highlighting/etc.
                treesitter = {
                    enable = true;
                    grammarPackages = pkgs.vimPlugins.nvim-treesitter.passthru.allGrammars;
                    settings.highlight.enable = true;
                };

                # Improved status bar.
                lualine = {
                    enable = true;
                    settings = {
                        # Configure content and layout.
                        sections = {
                            lualine_a = ["mode"];
                            lualine_b = ["branch" "diff" "diagnostics"];
                            lualine_c = ["filename"];
                            lualine_x = ["filetype"];
                            lualine_y = ["progress"];
                            lualine_z = ["location"];
                        };

                        # Configure styling.
                        options = {
                            theme = "catppuccin";
                            icons_enabled = true;
                        };
                    };
                };
            };

            # Some miscellaneous configuration options.
            opts = {
                number = true; # Show absolute line numbers.
                relativenumber = false; # Disable relative line numbers.
            };

            # Use Catppuccin colorscheme to match the rest of the system.
            colorschemes.catppuccin = {
                enable = true;
                settings = {
                    flavour = "macchiato";
                    background = {
                        light = "latte";
                        dark = "macchiato";
                    };

                    # Integrate with Neovim plugins.
                    default_integrations = true;
                    integrations = {
                        cmp = true;
                        treesitter = true;
                    };

                    # Extra style configuraiton.
                    custom_highlights = ''
                        function(colors)
                            return {
                                TelescopeBorder = { fg = colors.lavender},
                            }
                        end
                    '';
                };
            };

            # Editor appearance
            extraConfigVim = ''
                highlight Normal guibg=none
            '';

            # Make Neovim backgrounds transparent so the terminal's background shows through.
            extraConfigLua = ''
                vim.api.nvim_set_hl(0, "NormalNC", { bg = "none" })
                vim.api.nvim_set_hl(0, "StatusLine", { bg = "none" })
                vim.api.nvim_set_hl(0, "StatusLineNC", { bg = "none" })
                vim.api.nvim_set_hl(0, "VertSplit", { bg = "none" })
                vim.api.nvim_set_hl(0, "SignColumn", { bg = "none" })
                vim.api.nvim_set_hl(0, "TelescopeNormal", { bg = "none" })
                vim.api.nvim_set_hl(0, "TelescopeBorder", { bg = "none" })
                vim.api.nvim_set_hl(0, "TelescopePromptNormal", { bg = "none" })
                vim.api.nvim_set_hl(0, "TelescopePromptBorder", { bg = "none" })
                vim.api.nvim_set_hl(0, "TelescopeResultsNormal", { bg = "none" })
                vim.api.nvim_set_hl(0, "TelescopeResultsBorder", { bg = "none" })
                vim.api.nvim_set_hl(0, "TelescopePreviewNormal", { bg = "none" })
                vim.api.nvim_set_hl(0, "TelescopePreviewBorder", { bg = "none" })
            '';

            # Prerequisite packages
            extraPackages = with pkgs; [
                nil # Nix language server
                alejandra # Nix language formatter
                pyright # Nix language server
                ruff # Python language formatter
                gdtoolkit_4 # For GDScript support
                ripgrep # Used by Telescope for live grep.
                nodejs # Required for certain web development features.
                typescript # Used by JavaScript/Typescript plugins.
                vue-language-server # Provides @vue/typescript-plugin for ts_ls.
                #gcc # For building native extensions
                #gnumake # For building native extensions
            ];
        };

        # Define an extra alias for elevated editing while retaining userspace configurations.
        programs.fish.shellAliases.svi = "sudo -E nvim";

        # Configure the nix language formatter to use four-space indentation.
        xdg.configFile."alejandra.toml".text = ''
            # (experimental) Configuration options for Alejandra
            indentation = "FourSpaces" # Or: TwoSpaces, Tabs
        '';
    };
}
