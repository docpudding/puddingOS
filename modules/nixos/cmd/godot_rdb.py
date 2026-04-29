import click
import sys
from static import run_cmd
from os import path
from getpass import getuser

data_directory: str = f"/home/{getuser()}/.local/state/godot-rdb"


@click.command(context_settings=dict(ignore_unknown_options=True))
@click.pass_context
@click.argument("project_path", default="", required=False)
@click.argument("remote", default="", required=False)
@click.argument("extra_args", nargs=-1, required=False)
def cmd(
    ctx: click.Context, project_path: str, remote: str, extra_args: tuple[str, ...]
) -> None:
    """Run and debug a Godot project on a remote machine."""
    if len(project_path) == 0 or len(remote) == 0:
        click.echo(ctx.get_help())
        return

    # Reconstruct the "--" separator used for Godot user arguments (click removes it).
    raw: list[str] = sys.argv[1:]
    if "--" in raw:
        sep: int = raw.index("--") - 2
        godot_args: str = (
            " ".join(extra_args[:sep]) + " -- " + " ".join(extra_args[sep:])
        )
    else:
        godot_args = " ".join(extra_args)

    # Ensure the project path is valid.
    project_directory: str = path.abspath(project_path)
    if not path.exists(f"{project_directory}/project.godot"):
        raise click.UsageError("Not a Godot project.")

    # Set up an SSH environment.
    control_path: str = "/tmp/godot-rdb-remote"
    ssh_opts: str = (
        f"-o ControlMaster=auto -o ControlPath={control_path} -o ControlPersist=60"
    )

    # Ensure data directory exists on remote.
    run_cmd(f'ssh {ssh_opts} {remote} "mkdir -p {data_directory}"')

    # Synchronize project data to the remote destination.
    run_cmd(f"rsync -av --delete {project_directory}/ {remote}:{data_directory}")

    # Close any existing instances on the remote destination.
    run_cmd(f'ssh {ssh_opts} {remote} "pkill godot"')

    # Run the current instance of the project on the remote destination.
    run_cmd(
        f'ssh {ssh_opts} {remote} "systemd-run --user godot4 --path {data_directory}{" " + godot_args if godot_args else ""}"'
    )


if __name__ == "__main__":
    cmd()
