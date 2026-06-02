// @ts-check
import { defineConfig } from "astro/config";
import starlight from "@astrojs/starlight";
import catppuccin from "@catppuccin/starlight";

// https://astro.build/config
export default defineConfig({
    site: "https://docpudding.github.io",
    base: "/puddingOS",
    integrations: [
        starlight({
            customCss: ["./src/style.css"],

            title: "puddingOS",
            logo: {
                src: "./public/favicon.svg",
            },
            social: [
                {
                    icon: "github",
                    label: "GitHub",
                    href: "https://github.com/docpudding/puddingOS",
                },
            ],
            plugins: [
                catppuccin({
                    dark: { flavor: "macchiato", accent: "lavender" },
                    light: { flavor: "latte", accent: "lavender" },
                }),
            ],
            sidebar: [
                {
                    label: "Overview",
                    items: [
                        {
                            label: "Introduction",
                            slug: "overview/introduction",
                        },
                        {
                            label: "Installation",
                            slug: "overview/installation",
                        },
                    ],
                },
                {
                    label: "Configuration",
                    items: [
                        {
                            label: "NixOS Modules",
                            items: [
                                {
                                    autogenerate: {
                                        directory: "configuration/nixos",
                                    },
                                },
                            ],
                        },
                        {
                            label: "Home Manager Modules",
                            items: [
                                {
                                    autogenerate: {
                                        directory: "configuration/home-manager",
                                    },
                                },
                            ],
                        },
                    ],
                },
            ],
        }),
    ],
});
