{
    pkgs,
    config,
    lib,
    ...
}:
with lib; let
    nixvim = import (builtins.fetchGit {
        url = "https://github.com/nix-community/nixvim.git";
        ref = "nixos-26.05";
        rev = "667c8471f4a0fb24d702d1a61af8609f1a5f1ba6";
    });

    rangerWithPynvim = pkgs.ranger.overridePythonAttrs (old: {
        propagatedBuildInputs = (old.propagatedBuildInputs or []) ++ [pkgs.python3Packages.pynvim];
    });

    rangerPreviewScript = pkgs.writeShellScript "ranger-preview" ''
        env COLORTERM=8bit bat --color=always --style=plain --paging=never \
            --theme="Catppuccin Macchiato" -- "$1" 2>/dev/null && exit 5
        exit 1
    '';
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

            # Required for rnvimr, which talks to Neovim over RPC via pynvim.
            withPython3 = true;
            extraPython3Packages = ps: with ps; [pynvim];

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

            # Plugins with no first-class nixvim module, wired up manually.
            extraPlugins = [pkgs.vimPlugins.rnvimr];

            plugins = {
                telescope = {
                    enable = true; # Fuzzy search utility for file names and content.
                    settings.defaults = {
                        # Square corners, matching rnvimr's border shape (no curve option there).
                        borderchars = ["─" "│" "─" "│" "┌" "┐" "┘" "└"];
                    };
                };
                web-devicons.enable = true; # Provides file-type icons.

                # Language Server Protocol (LSP) integrations for various languages.
                lsp = {
                    enable = true;
                    servers.pyright.enable = true; # Python
                    servers.jdtls.enable = true; # Java

                    servers.nil_ls.enable = true; # Nix language
                    servers.markdown_oxide.enable = true; # Markdown
                    servers.lemminx.enable = true; # XML

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
                                command = "${pkgs.prettier}/bin/prettier";
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
                    grammarPackages = config.programs.nixvim.plugins.treesitter.package.allGrammars;
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
                            theme = "catppuccin-nvim";
                            icons_enabled = true;
                        };
                    };
                };
            };

            # Some miscellaneous configuration options.
            filetype.extension.mdx = "markdown";
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

                    default_integrations = true;
                    integrations = {
                        cmp = true;
                        treesitter = true;
                    };
                };
            };

            # Editor appearance
            extraConfigVim = ''
                highlight Normal guibg=none
            '';

            extraConfigLua =
                ''
                    -- Make Neovim backgrounds transparent so the terminal's background shows through.
                    vim.api.nvim_set_hl(0, "NormalNC", { bg = "none" })
                    vim.api.nvim_set_hl(0, "StatusLine", { bg = "none" })
                    vim.api.nvim_set_hl(0, "StatusLineNC", { bg = "none" })
                    vim.api.nvim_set_hl(0, "VertSplit", { bg = "none" })
                    vim.api.nvim_set_hl(0, "SignColumn", { bg = "none" })
                    vim.api.nvim_set_hl(0, "RnvimrNormal", { bg = "none" })

                    -- Telescope: set border color directly here rather than via catppuccin's
                    -- custom_highlights, since Telescope's own setup() call appears to re-apply
                    -- its default highlight groups after the colorscheme's initial pass, undoing
                    -- color-only changes made there. This block runs after all plugin setups,
                    -- so it's authoritative. Hardcoded to Catppuccin Macchiato's actual Blue
                    -- accent hex (#8aadf4), verified from Catppuccin's own style guide table.
                    local catppuccin_macchiato_blue = "#8aadf4"
                    vim.api.nvim_set_hl(0, "TelescopeNormal", { bg = "none" })
                    vim.api.nvim_set_hl(0, "TelescopeBorder", { bg = "none", fg = catppuccin_macchiato_blue })
                    vim.api.nvim_set_hl(0, "TelescopePromptNormal", { bg = "none" })
                    vim.api.nvim_set_hl(0, "TelescopePromptBorder", { bg = "none", fg = catppuccin_macchiato_blue })
                    vim.api.nvim_set_hl(0, "TelescopeResultsNormal", { bg = "none" })
                    vim.api.nvim_set_hl(0, "TelescopeResultsBorder", { bg = "none", fg = catppuccin_macchiato_blue })
                    vim.api.nvim_set_hl(0, "TelescopePreviewNormal", { bg = "none" })
                    vim.api.nvim_set_hl(0, "TelescopePreviewBorder", { bg = "none", fg = catppuccin_macchiato_blue })

                    -- When connected over SSH, use OSC 52 for clipboard sharing.
                    if vim.env.SSH_TTY ~= nil then
                        vim.g.clipboard = 'osc52'
                    end

                    -- rnvimr: run ranger in a floating window, opening files as real buffers
                    -- in this same nvim instance via RPC.
                    vim.g.rnvimr_enable_picker = 1 -- Auto-hide the floating window after picking a file.
                    vim.g.rnvimr_edit_cmd = 'drop' -- Reuse an existing window/tab instead of duplicating.

                    -- Use a dedicated preview script that calls bat directly, bypassing ranger's
                    -- own MIME-detection-based dispatch entirely (see rangerPreviewScript above).
                    vim.g.rnvimr_ranger_cmd = {
                        'ranger',
                        '--cmd=set preview_script ${rangerPreviewScript}',
                        '--cmd=set use_preview_script true',
                    }

                    -- Match Telescope's actual documented default size for its default
                    -- ("horizontal") layout strategy: width = 0.8, height = 0.9, centered.
                    vim.g.rnvimr_layout = {
                        relative = 'editor',
                        width = math.floor(0.8 * vim.o.columns + 0.5),
                        height = math.floor(0.9 * vim.o.lines + 0.5),
                        col = math.floor(0.1 * vim.o.columns + 0.5),
                        row = math.floor(0.05 * vim.o.lines + 0.5),
                        style = 'minimal',
                    }

                    -- Border color limited to the 16-color terminal palette, plus two extended
                    -- indices (16=Peach, 17=Rosewater) that Catppuccin's Alacritty theme defines.
                    -- 4 (regular Blue) matches Catppuccin's actual Blue accent color.
                    vim.g.rnvimr_border_attr = { fg = 4, bg = -1 }

                    -- Close the ranger floating window with Escape, like Telescope. Scoped to
                    -- terminal buffers whose job is actually `ranger`, so this doesn't hijack
                    -- Escape's normal "exit terminal-mode" behavior in other :terminal buffers.
                    vim.api.nvim_create_autocmd("TermOpen", {
                        callback = function(args)
                            if vim.fn.bufname(args.buf):match("ranger") then
                                vim.keymap.set("t", "<Esc>", "<C-\\><C-n>:RnvimrToggle<CR>", {
                                    buffer = args.buf,
                                    silent = true,
                                })
                            end
                        end,
                    })

                    -- Pick up file changes made by other running nvim instances (or externally)
                    -- when this instance regains focus or a buffer is re-entered.
                    vim.api.nvim_create_autocmd({ "FocusGained", "BufEnter", "CursorHold" }, {
                        callback = function()
                            if vim.bo.buftype == "" then
                                vim.cmd("checktime")
                            end
                        end,
                    })
                ''
                + builtins.readFile ./instances.lua;

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
                lemminx # XML language server
                rangerWithPynvim # File browser used by rnvimr, patched with pynvim.
                bat # Syntax-highlighted preview for ranger.
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
