{ pkgs ? import <nixpkgs> { }, rev }:

let
  inherit (pkgs) fetchzip;
  inherit (pkgs.stdenv) mkDerivation;

  inherit (pkgs.stdenv.hostPlatform) system;
  selectSystem = attrs:
    attrs.${system} or (throw "Unsupported system: ${system}");

  suffix = selectSystem {
    # Not sure how other system compatibility is, needs trial & error
    x86_64-linux = "linux";
    aarch64-linux = "linux-arm64";
    # x86_64-darwin = "mac";
    # aarch64-darwin = "mac-arm64";
  };
  sha256 = {
    # Fill in on demand
    "1024" = selectSystem {
      x86_64-linux = "sha256-2kk+N1vB3aX+aNXu4P/VjEeqVm2jRfCpQk6FKnDdlxQ=";
    };
  }.${rev};

  upstream_chromium = fetchzip {
    url =
      "https://playwright.azureedge.net/builds/chromium/${rev}/chromium-${suffix}.zip";
    inherit sha256;
    stripRoot = true;
  };

  fontconfig = pkgs.makeFontsConf {
    fontDirectories = [ ];
  };
in
mkDerivation {
  name = "chromium-playwright";
  version = rev;
  src = upstream_chromium;

  nativeBuildInputs = [ pkgs.makeWrapper pkgs.patchelf ];

  installPhase = ''
    mkdir $out

    # See here for the Chrome options:
    # https://github.com/NixOS/nixpkgs/issues/136207#issuecomment-908637738
    makeWrapper ${pkgs.chromium}/bin/chromium $out/chrome \
      --set SSL_CERT_FILE /etc/ssl/certs/ca-bundle.crt \
      --set FONTCONFIG_FILE ${fontconfig}
    #ln -s ${pkgs.ffmpeg}/bin/ffmpeg $out/ffmpeg-$FFMPEG_REVISION/ffmpeg-linux
  '';
}
