from collections import defaultdict
from json import load
from os import makedirs, listdir
from os.path import exists, join, splitext
from sys import argv


def get_modules(src_dir: str, section_dir: str) -> list[str]:
    """Return module labels based on which hand-written files exist."""
    extra_dir = join(src_dir, "extra", section_dir)
    if not exists(extra_dir):
        return []
    return [splitext(f)[0] for f in listdir(extra_dir) if f.endswith(".md")]


def load_extra(src_dir: str, section_dir: str, module_label: str) -> str | None:
    """Load the hand-written guide for a module if it exists."""
    extra_path = join(src_dir, "extra", section_dir, f"{module_label}.md")
    if exists(extra_path):
        with open(extra_path) as f:
            return f.read().strip()
    return None


def sort_key(item: tuple) -> tuple:
    """Define sort order for module options."""
    name = item[0]
    parts = name.split(".")
    depth = len(parts)
    is_enable = 0 if name.endswith(".enable") else 1
    return (depth, is_enable, name)


def option_to_markdown(name: str, opt: dict) -> str:
    """Generate Markdown text for a NixOS option."""
    lines = [f"`{name}`\n"]

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


def keymaps_to_markdown(keymaps: list) -> str:
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


def main() -> None:
    nixos_json: str = argv[1]
    hm_json: str = argv[2]
    src_dir: str = argv[3]
    out_dir: str = argv[4]
    keymaps_json: str = argv[5]

    with open(keymaps_json) as f:
        keymaps: list = load(f)

    sections = [
        ("nixos", nixos_json),
        ("home-manager", hm_json),
    ]

    for section_dir, json_path in sections:
        with open(json_path) as f:
            options: dict = load(f)

        module_labels: list[str] = get_modules(src_dir, section_dir)
        module_prefixes: set[str] = {
            f"pos.{label}" for label in module_labels if label != "core"
        }

        # Group options by module prefix.
        modules: dict = defaultdict(dict)
        for name, opt in options.items():
            matched = False
            for prefix in module_prefixes:
                if name == prefix + ".enable" or name.startswith(prefix + "."):
                    modules[prefix][name] = opt
                    matched = True
                    break
            if not matched:
                modules["pos"][name] = opt

        makedirs(join(out_dir, section_dir), exist_ok=True)

        for label in module_labels:
            extra = load_extra(src_dir, section_dir, label)
            opts = modules.get("pos" if label == "core" else f"pos.{label}", {})
            has_keymaps = section_dir == "home-manager" and label == "vi"

            with open(join(out_dir, section_dir, f"{label}.md"), "w") as f:
                f.write(f"---\ntitle: {label}\n---\n\n")
                if extra:
                    f.write(extra + "\n\n")
                if has_keymaps:
                    f.write(keymaps_to_markdown(keymaps) + "\n\n")
                if opts:
                    f.write("## Options\n\n")
                    for name, opt in sorted(opts.items(), key=sort_key):
                        f.write(option_to_markdown(name, opt))
                        f.write("\n---\n\n")


if __name__ == "__main__":
    main()
