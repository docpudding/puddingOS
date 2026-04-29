import click
from random import choice, randint


@click.command()
@click.argument("arguments", nargs=-1, required=True)
def rng(arguments):
    """puddingOS randomizer utility

    \b
    Behaviour depends on the arguments provided:
      rng <max>        Random integer between 1 and max.
      rng <min> <max>  Random integer between min and max.
      rng <a> <b> ...  Random choice from the provided options.
    """
    if len(arguments) == 1 and arguments[0].isdigit():
        click.echo(randint(1, int(arguments[0])))
    elif len(arguments) == 2 and all(o.isdigit() for o in arguments):
        lo, hi = int(arguments[0]), int(arguments[1])
        if lo > hi:
            raise click.UsageError(
                f"min ({lo}) must be less than or equal to max ({hi})."
            )
        click.echo(randint(lo, hi))
    else:
        click.echo(choice(arguments))


if __name__ == "__main__":
    rng()
