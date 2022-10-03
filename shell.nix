# confirmed working with rev 934e076a441e318897aa17540f6cf7caadc69028
{ pkgs ? import <nixpkgs> { } }:

let
  # Make sure to adjust data_sha256 when updating this or it will use stale data!
  playwright_version = "1.26.1";
  playwright-browsers = import ./playwright-browsers.nix {
    inherit playwright_version;
    data_sha256 = "sha256:0vi3ipm2dixxm7pwpgv1j5ys6r2x1fpghr7f58m8qvq7d4dwwpm8";
  };
in
pkgs.mkShell {
  packages = [
  ];

  "PLAYWRIGHT_BROWSERS_VERSION" = playwright_version;
  "PLAYWRIGHT_BROWSERS_PATH" = playwright-browsers.browsers;
}
