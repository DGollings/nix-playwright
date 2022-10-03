{ pkgs ? import <nixpkgs> { }, rev }:

let
  inherit (pkgs.stdenv) mkDerivation;
in
mkDerivation {
  name = "ffmpeg-playwright";
  version = rev;

  nativeBuildInputs = [ ];
  dontUnpack = true;

  installPhase = ''
    mkdir $out
    ln -s ${pkgs.ffmpeg}/bin/ffmpeg $out/ffmpeg-linux
  '';
}
