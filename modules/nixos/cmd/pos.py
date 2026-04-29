import click
from static import run_cmd

from os import system as os_system


@click.group(invoke_without_command=True)
@click.pass_context
def cmd(ctx):
    """Manage a puddingOS system."""
    if ctx.invoked_subcommand is None:
        click.echo(ctx.get_help())


@cmd.command()
@click.option(
    "--flake-hostname",
    default="",
    show_default=False,
    help="Specify a non-matching hostname to build for when rebuilding with flakes.",
)
@click.option(
    "--offline",
    help="Disable network features to ensure successful offline build.",
    is_flag=True,
)
def rebuild(flake_hostname: str = "", offline: bool = False):
    """Rebuild the system."""
    cmd = "sudo nixos-rebuild switch"

    if flake_hostname != "":
        cmd += f" --flake /etc/nixos/flake.nix#{flake_hostname}"
    if offline:
        cmd += " --offline"

    run_cmd(cmd)


@cmd.command()
def update():
    """Update flake inputs."""
    run_cmd("sudo nix flake update --flake /etc/nixos")


@cmd.command()
def upgrade():
    """Upgrade the system (update + rebuild)."""
    update.invoke(ctx=click.Context(update))
    rebuild.invoke(ctx=click.Context(rebuild))


if __name__ == "__main__":
    cmd()
