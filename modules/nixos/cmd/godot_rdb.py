import click
from static import run_cmd
from os import path


@click.command(context_settings=dict(ignore_unknown_options=True))
@click.pass_context
@click.argument(
    "project_path",
    default="",
    required=False,
)
@click.argument(
    "remote",
    default="",
    required=False,
)
@click.argument("extra_args", nargs=-1, required=False)
def cmd(ctx: click.Context, project_path: str, remote: str, extra_args: str) -> None:
    """Run and debug a Godot project on a remote machine."""
    if project_path == 0 or len(remote) == 0:
        click.echo(ctx.get_help())
        return

    # Ensure the project path is valid.
    project_directory: str = path.abspath(project_path)
    if not path.exists(f"{project_directory}/project.godot"):
        raise click.UsageError("Not a Godot project.")

    # Synchronize project data to the remote destination.
    run_cmd(f"rsync -av --delete {project_directory}/* {remote}:/tmp/godot-rdb")

    # Set up an SSH environment.
    control_path: str = f"/tmp/godot-rdb-remote"
    ssh_opts: str = (
        f"-o ControlMaster=auto -o ControlPath={control_path} -o ControlPersist=60"
    )

    # Close any existing instances on the remote destination.
    run_cmd(f"ssh {ssh_opts} {remote} 'pkill godot'")

    # Run the current instance of the project on the remote destination.
    run_cmd(
        f"ssh {remote} 'systemd-run --user godot --path /tmp/godot-rdb{' '.join(extra_args)}'"
    )


if __name__ == "__main__":
    cmd()
