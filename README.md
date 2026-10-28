# nix-composio

Unofficial Nix package and NixOS module for the
[Composio CLI](https://docs.composio.dev/docs/cli). The complete upstream CLI
bundle is installed because Composio loads runtime support files beside its
executable.

## Run or install the flake package

```console
nix run github:ABoustani/nix-composio -- --version
nix profile install github:ABoustani/nix-composio
```

For a local checkout, replace `github:ABoustani/nix-composio` with `.`.

## NixOS module

Add the flake input and module to your NixOS configuration:

```nix
{
  inputs.nix-composio.url = "github:ABoustani/nix-composio";

  outputs = { nixpkgs, nix-composio, ... }: {
    nixosConfigurations.my-host = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        nix-composio.nixosModules.default
        { programs.composio.enable = true; }
      ];
    };
  };
}
```

The module can also be imported directly:

```nix
{
  imports = [ ./path/to/nix-composio/nix/module.nix ];
  programs.composio.enable = true;
}
```

An overlay is available as `overlays.default` when only `pkgs.composio` is
needed.

## OpenClaw gateway

Enable the module so `composio` is on the gateway's `PATH`, rebuild NixOS, then
authenticate as the same Unix user that runs OpenClaw:

```console
composio login
composio whoami
composio setup skill openclaw
```

Restart the OpenClaw gateway after installing the skill. Composio stores login
and skill state in the user's home directory; this repository intentionally
does not put credentials or mutable state in the Nix store.

## Supported systems

- `x86_64-linux`
- `aarch64-linux`
- `aarch64-darwin`

The package currently pins Composio CLI `0.5.0` and verifies every archive
against the checksum published with the upstream release. The package
expression also includes the upstream `x86_64-darwin` bundle for consumers
using the overlay with Nixpkgs 26.05 or older; current Nixpkgs no longer
supports Intel macOS, so the flake does not export that system.
