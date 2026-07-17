This module provides a unified API for running self-hosted web servers locally or on a custom domain. This one of the more extensive puddingOS modules, and includes a complete interface for configuring servers.

Each server has its own submodule (e.g. `pos.servers.gitea` or `pos.servers.authentik`) and all submodules share four universal configuration options: `enable`, `domain`, `host`, and `port`. The `enable` option is what makes the server run on the given machine, while the other options are used to configure the reverse proxy (nginx).

As a general note, this module currently does NOT provide declarative options for configuring the site settings themselves (with a few exceptions). This could be added in the future, but for now the scope is simply to provide an interface for getting servers running and talking to one another.

## Public Hosting

If you want your server to be accessible from a public domain, you will need your own domain with the A Records configured to point to whichever public IP(s) you need to access.

You will also probably want SSL encryption. This module provides a very easy way to do this via Let's Encrypt by setting `pos.servers.acmeEmail` to any valid email address that belongs to you.

If the `domain` option is set for any submodule, then nginx will be configured and run as a reverse proxy. On a basic server setup with only one machine, you can just do something like this:

```nix
pos.servers.acmeEmail = "test@example.com";

pos.servers.gitea.enable = true;
pos.servers.gitea.domain = "example.com";
```

Assuming your DNS records are configured properly, the above configurations should work out of the box for hosting a public Gitea server on the given address. You can also set up multiple applications to run on different subdomains:

```nix
pos.servers = {
    acmeEmail = "test@example.com";

    gitea.enable = true;
    gitea.domain = "git.example.com";

    authentik.enable = true;
    authentik.domain = "auth.example.com";
};
```

Note that you will still need to configure the A Record for each subdomain individually.

### Multiple Server Machines

Remember, configuring the `domain`, `host`, and/or `port` will set up the reverse proxy regardless of whether or not `enable` is set to true. You can utilize this split behaviour to set up a server across multiple machines:

```nix
# Machine 1 (123.456.0.101)
pos.servers = {
    acmeEmail = "test@example.com";

    gitea.domain = "git.example.com";
    gitea.host = "123.456.0.102";

    authentik.domain = "auth.example.com";
    authentik.host = "123.456.0.102";

    vaultwarden.domain = "draw.example.com";
    vaultwarden.host = "123.456.0.103";
};

# Machine 2 (123.456.0.102)
pos.servers.gitea.enable = true;
pos.servers.authentik.enable = true;

# Machine 3 (123.456.0.103)
pos.servers.vaultwarden.enable = true;
```

In the above example, Machine 2 and Machine 3 are hosting actual applications, while Machine 1 is handling domain resolution via nginx.

## Submodules

This module has several submodules, and more will be added in the future. All of them follow the same general configuration system as described above, but some have their own unique behaviour and options.

### authentik (FLAKES ONLY)

This submodule provides a unified authenication/authorization system and enables unified accounts and credentials across multiple servers. This module is a bit unique in the context of puddingOS as it requires you to install a [separate flake](https://github.com/nix-community/authentik-nix) to use as a dependency. In order to install it, you need to provide it as an input and set the `packages` option for the submodule. Here is a minimal example config for a puddingOS installation with authentik:

```nix
{
    inputs = {
        pos.url = "github:docpudding/puddingOS/release-25.11";
        nixpkgs.url = "github:nixos/nixpkgs/nixos-25.11";
        authentik-nix.url = "github:nix-community/authentik-nix";
    };

    outputs = {
        nixpkgs,
        pos,
        authentik-nix,
        ...
    } @ inputs: {
        nixosConfigurations.HOSTNAME = nixpkgs.lib.nixosSystem {
            system = "x86_64-linux";
            specialArgs = { inherit pos; };

            modules = [
                pos.nixosModules.default

                ({ pos, ... }: {
                    pos.enable = true;
                    pos.servers.authentik.enable = true;
                    pos.servers.authentik.packages = authentik-nix.packages.${pkgs.system};
                })
            ];
        };
    };
}
```

In addition to this, you will also need to configure the `secretKey` option. You can do this either as a raw string or through a secret management service such as agenix. Either way, you can generate the key like this:

```sh
openssl rand -base64 60
```

### gitea

This submodule provides a self-hosted platform for Git/VCS repositories. It works essentially out of the box, but there are a few things to consider. Most importantly, Gitea comes with an option built-in SSH server. It can be toggled with the `enableSSH` option and its port can be configured independently via the `sshPort` option.

Also, this submodule restricts new account creation by default. In order to create accounts from the Gitea web interface, you need to enable the `allowRegistration` option. It is recommended that you turn it back off after creating the desired accounts unless you intend to provide a Git service to the general public.
