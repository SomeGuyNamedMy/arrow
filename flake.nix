{
  description = "my project description";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  inputs.flake-utils = {
      url = "github:numtide/flake-utils";
      inputs.nixpkgs.follows = "nixpkgs";
  };
  inputs.rust-overlay.url = "github:oxalica/rust-overlay";

  outputs = { self, nixpkgs, flake-utils, rust-overlay, ... }:
    flake-utils.lib.eachDefaultSystem
      (system:
        let 
          overlays = [ (import rust-overlay) ];
          pkgs = import nixpkgs {
            inherit system overlays;
          };
        in
        {
          defaultPackage = pkgs.rustPlatform.buildRustPackage rec {
              pname = "arrow";
              version = "0.3.1";
              src = ./.;
              nativeBuildInputs = with pkgs; [
                  pkg-config
                  gdb
                  rust-bin.beta.latest.default
              ];
              buildInputs = with pkgs; [
                  libxkbcommon wayland wayland-protocols vulkan-loader
                  vulkan-tools openssl freetype expat swiftshader fontconfig
              ] ++ (with xorg; [
                libX11 libXcursor libXrandr libXi
              ]);
              cargoLock.lockFile = ./Cargo.lock;
              buildType = "release";
              doCheck = false;
          };
          devShells.default = pkgs.mkShell rec {
              nativeBuildInputs = with pkgs; [pkg-config gdb];
              buildInputs = with pkgs; [
                  rust-bin.beta.latest.default
                  libxkbcommon wayland wayland-protocols vulkan-loader
                  vulkan-tools openssl freetype expat swiftshader fontconfig
              ] ++ (with xorg; [
                libX11 libXcursor libXrandr libXi
              ]);
              shellHook = ''
                  export LD_LIBRARY_PATH="$LD_LIBRARY_PATH:${pkgs.lib.makeLibraryPath buildInputs}";
              '';
          };
        }
      );
}
