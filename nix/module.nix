{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.programs.composio;
  pipeline = import ./pipeline.nix { inherit pkgs; };
in
{
  options.programs.composio = {
    enable = lib.mkEnableOption "the Composio CLI";

    package = lib.mkOption {
      type = lib.types.package;
      default = pipeline.composio;
      defaultText = lib.literalExpression "composio package provided by this flake";
      description = "The Composio CLI package to install.";
    };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [ cfg.package ];
  };
}
