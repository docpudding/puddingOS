from os import system


def run_cmd(cmd: str, silent: bool = False, **kwargs):
    """Run a command on the Linux terminal."""
    if not silent:
        print(f"> {cmd}")
    return system(cmd)
