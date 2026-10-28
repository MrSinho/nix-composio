{ pkgs, ... }:

let
  inherit (pkgs) lib stdenv;

  version = "0.5.0";

  releases = {
    aarch64-darwin = {
      target = "darwin-aarch64";
      hash = "sha256-UWxJyn8ZPB1047Z/+rOOI8lpr6EsB7RXryPF0gAmvBo=";
    };
    x86_64-darwin = {
      target = "darwin-x64";
      hash = "sha256-6lCbs0NDyHvJ8WNpk90v5yNtLp/EqcHGcBo8a7C+eLc=";
    };
    aarch64-linux = {
      target = "linux-aarch64";
      hash = "sha256-zk/z281gxOL9V0C3keyIuzVhfTiwT1hSp03TJphKo+c=";
    };
    x86_64-linux = {
      target = "linux-x64";
      hash = "sha256-1l8CSnnkOuFCHEPKBOivAO4+Iz3BGk3t8jom92JYtXw=";
    };
  };

  release =
    releases.${stdenv.hostPlatform.system}
      or (throw "composio: unsupported system ${stdenv.hostPlatform.system}");

  composio = stdenv.mkDerivation {
    pname = "composio";
    inherit version;

    src = pkgs.fetchurl {
      url = "https://github.com/ComposioHQ/composio/releases/download/%40composio%2Fcli%40${version}/composio-${release.target}.zip";
      inherit (release) hash;
    };

    nativeBuildInputs = [
      pkgs.unzip
    ]
    ++ lib.optionals stdenv.hostPlatform.isLinux [ pkgs.makeWrapper ];

    dontBuild = true;
    # Bun standalone executables append their payload after the ELF/Mach-O data.
    # Patching or stripping the binary makes it fall back to the Bun runtime.
    dontStrip = true;

    installPhase = ''
      runHook preInstall

      mkdir -p $out/bin $out/lib/composio
      cp -R ./. $out/lib/composio/

      ${
        if stdenv.hostPlatform.isLinux then
          ''
            makeWrapper "${stdenv.cc.bintools.dynamicLinker}" $out/bin/composio \
              --add-flags "$out/lib/composio/composio"
          ''
        else
          ''
            ln -s ../lib/composio/composio $out/bin/composio
          ''
      }

      runHook postInstall
    '';

    meta = {
      description = "CLI for discovering, connecting, and executing Composio tools";
      homepage = "https://composio.dev";
      changelog = "https://github.com/ComposioHQ/composio/releases/tag/%40composio%2Fcli%40${version}";
      license = lib.licenses.mit;
      mainProgram = "composio";
      platforms = builtins.attrNames releases;
      sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
    };
  };
in
{
  inherit composio;
}
