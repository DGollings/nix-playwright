{ pkgs ? import <nixpkgs> { }, playwright_version, data_sha256 }:

let
  inherit (builtins) fetchurl map fromJSON readFile listToAttrs;
  inherit (pkgs.stdenv) mkDerivation;

  browser_revs =
    let
      file = fetchurl {
        url =
          "https://raw.githubusercontent.com/microsoft/playwright/v${playwright_version}/packages/playwright-core/browsers.json";
        sha256 = data_sha256;
      };
      raw_data = fromJSON (readFile file);
    in
    listToAttrs (map
      ({ name, revision, ... }: {
        inherit name;
        value = revision;
      })
      raw_data.browsers);

  chromium-playwright = import ./chromium-playwright.nix {
    inherit pkgs;
    rev = browser_revs.chromium;
  };
  firefox-playwright = import ./firefox-playwright.nix {
    inherit pkgs;
    rev = browser_revs.firefox;
  };
  ffmpeg-playwright = import ./ffmpeg-playwright.nix {
    inherit pkgs;
    rev = browser_revs.ffmpeg;
  };
in
{
  chromium = "${chromium-playwright}/chrome";
  firefox = "${firefox-playwright}/firefox";
  ffmpeg = "${ffmpeg-playwright}/ffmpeg-linux";
  browsers = mkDerivation
    {
      name = "playwright-browsers";
      dontUnpack = true;

      installPhase = ''
        mkdir $out

        mkdir -p $out/chromium-${browser_revs.chromium}/chrome-linux
        cp -r ${chromium-playwright}/* $out/chromium-${browser_revs.chromium}/chrome-linux
        touch $out/chromium-${browser_revs.chromium}/INSTALLATION_COMPLETE

        mkdir -p $out/firefox-${browser_revs.firefox}/firefox
        cp -r ${firefox-playwright}/* $out/firefox-${browser_revs.firefox}/firefox
        touch $out/firefox-${browser_revs.firefox}/INSTALLATION_COMPLETE

        mkdir -p $out/ffmpeg-${browser_revs.ffmpeg}/
        cp -r ${ffmpeg-playwright}/ffmpeg-linux $out/ffmpeg-${browser_revs.ffmpeg}/ffmpeg-linux
        touch $out/ffmpeg-${browser_revs.ffmpeg}/INSTALLATION_COMPLETE
      '';
    };
}

