import json
import sys
import os
import re
from collections import defaultdict


def option_to_markdown(name, opt, level=3):
    """Generate Markdown text for a NixOS option."""
    hashes = "#" * level
    lines = []
    lines.append(f"{hashes} `{name}`\n")

    if opt.get("description"):
        desc = opt["description"]
        if isinstance(desc, dict):
            desc = desc.get("text", "")
        lines.append(f"{desc}\n")
    lines.append(f"*Type:* `{opt.get('type', 'unspecified')}`\n")

    if "default" in opt:
        default = opt["default"]
        text = (
            default.get("text", str(default))
            if isinstance(default, dict)
            else str(default)
        )
        lines.append(f"*Default:*\n```nix\n{text}\n```\n")

    if "example" in opt:
        example = opt["example"]
        text = (
            example.get("text", str(example))
            if isinstance(example, dict)
            else str(example)
        )
        lines.append(f"*Example:*\n```nix\n{text}\n```\n")

    return "\n".join(lines)


def keymaps_to_markdown(keymaps):
    """Generate Markdown text for Neovim keymaps."""
    lines = []
    lines.append("### All Keybinds\n")
    lines.append("| Key | Mode | Description |")
    lines.append("|-----|------|-------------|")
    for k in keymaps:
        raw_key = k.get("key", "")
        if raw_key == "`":
            key = "`` ` ``"
        else:
            key = f"`{raw_key}`"
        mode = ", ".join(k.get("mode", []))
        desc = k.get("desc", "")
        lines.append(f"| {key} | {mode} | {desc} |")
    return "\n".join(lines)


def load_extra(src_dir, section_dir, module_label):
    """Loads handwritten guide for a module if it exists."""
    extra_path = os.path.join(src_dir, "extra", section_dir, f"{module_label}.md")

    if os.path.exists(extra_path):
        with open(extra_path) as f:
            return f.read().strip()
    return None


def sort_key(item):
    """Define sort order for module options."""
    name = item[0]
    parts = name.split(".")
    depth = len(parts)
    is_enable = 0 if name.endswith(".enable") else 1
    return (depth, is_enable, name)


def shift_headings(content, shift):
    """Reformat Markdown headers."""

    def replace(match):
        hashes = match.group(1)
        rest = match.group(2)
        return "#" * (len(hashes) + shift) + rest

    return re.sub(r"^(#+)( .+)$", replace, content, flags=re.MULTILINE)


def generate_readme(overview_pages, src_dir):
    """Generate repository README based on the certain sections of the documentation."""
    sections = []

    for i, (title, filepath) in enumerate(overview_pages):
        full_path = os.path.join(src_dir, filepath)
        if not os.path.exists(full_path):
            continue
        with open(full_path) as f:
            content = f.read().strip()
        if i > 0:
            content = shift_headings(content, shift=1)
        sections.append(content)

    sections.append(
        "## Full Documentation\n\n"
        "> 📖 Full documentation is available at: `[docs link — coming soon]`"
    )

    return "\n\n".join(sections)


def parse_overview_pages(summary_lines):
    """Extract page data for generate_readme."""
    pages = []
    in_overview = False

    for line in summary_lines:
        stripped = line.strip()
        if stripped == "# Overview":
            in_overview = True
            continue
        if in_overview:
            if stripped.startswith("#"):
                break
            match = re.match(r"\s*[-*]\s+\[(.+?)\]\((.+?)\)", stripped)
            if match:
                pages.append((match.group(1), match.group(2)))

    return pages


def main():
    nixos_json = sys.argv[1]
    hm_json = sys.argv[2]
    src_dir = sys.argv[3]
    readme_out = sys.argv[4]
    keymaps_json = sys.argv[5]

    with open(keymaps_json) as f:
        keymaps = json.load(f)

    sections = [
        ("nixos", nixos_json, "NixOS Modules"),
        ("home-manager", hm_json, "Home Manager Modules"),
    ]

    summary_lines = [
        "# Summary\n",
        "\n# Overview\n",
        "- [Introduction](intro.md)\n",
        "- [Installation](install.md)\n",
        "\n# Configuration\n",
    ]

    for section_dir, json_path, title in sections:
        with open(json_path) as f:
            options = json.load(f)

        # Find all module boundaries (options ending in .enable).
        module_prefixes = set()
        for name in options:
            if name.endswith(".enable"):
                prefix = name[: -len(".enable")]
                parts = prefix.split(".")
                if len(parts) == 2:
                    module_prefixes.add(prefix)

        # Group options by module prefix.
        modules = defaultdict(dict)
        for name, opt in options.items():
            matched = False
            for prefix in module_prefixes:
                if name == prefix + ".enable" or name.startswith(prefix + "."):
                    modules[prefix][name] = opt
                    matched = True
                    break
            if not matched:
                modules["pos"][name] = opt

        out_dir = os.path.join(src_dir, section_dir)
        os.makedirs(out_dir, exist_ok=True)

        filepath = os.path.join(out_dir, "options.md")
        summary_lines.append(f"- [{title}]({section_dir}/options.md)")

        with open(filepath, "w") as f:
            f.write(f"# {title}\n\n")

            # Write core/unmatched options first.
            if "pos" in modules:
                f.write("## core\n\n")
                extra = load_extra(src_dir, section_dir, "core")
                if extra:
                    f.write(extra + "\n\n")
                    f.write("### Options\n\n")
                for name, opt in sorted(modules["pos"].items(), key=sort_key):
                    f.write(option_to_markdown(name, opt, level=4 if extra else 3))
                    f.write("\n---\n\n")

            # Write each module section.
            for prefix in sorted(module_prefixes):
                module_label = prefix.split(".")[-1]
                f.write(f"## {module_label}\n\n")
                extra = load_extra(src_dir, section_dir, module_label)
                has_keymaps = section_dir == "home-manager" and module_label == "vi"
                if extra:
                    f.write(extra + "\n\n")
                if has_keymaps:
                    f.write(keymaps_to_markdown(keymaps) + "\n\n")
                if extra or has_keymaps:
                    f.write("### Options\n\n")
                for name, opt in sorted(modules[prefix].items(), key=sort_key):
                    f.write(
                        option_to_markdown(
                            name, opt, level=4 if (extra or has_keymaps) else 3
                        )
                    )
                    f.write("\n---\n\n")

    # Write summary file.
    with open(os.path.join(src_dir, "SUMMARY.md"), "w") as f:
        f.write("\n".join(summary_lines))

    # Generate README from Overview pages.
    overview_pages = parse_overview_pages(summary_lines)
    readme_content = generate_readme(overview_pages, src_dir)
    with open(readme_out, "w") as f:
        f.write(readme_content)


if __name__ == "__main__":
    main()
