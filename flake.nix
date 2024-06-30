{
  description = "Example JavaScript development environment for Zero to Nix";

  # Flake inputs
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    rust-overlay.url = "github:oxalica/rust-overlay";
  };

  # Flake outputs
  outputs = { self, nixpkgs, rust-overlay }:
    let
      # Systems supported
      allSystems = [
        "x86_64-linux" # 64-bit Intel/AMD Linux
        "aarch64-linux" # 64-bit ARM Linux
        "x86_64-darwin" # 64-bit Intel macOS
        "aarch64-darwin" # 64-bit ARM macOS
      ];

      overlays = [ (import rust-overlay) ];

      # Helper to provide system-specific attributes
      forAllSystems = f: nixpkgs.lib.genAttrs allSystems (system: f {
        pkgs = import nixpkgs {
          inherit system overlays;
        };
      });

    in
    {
      # Development environment output
      devShells = forAllSystems
        ({ pkgs }:
          let
            deps = with pkgs; [
              (rust-bin.stable.latest.default.override {
                extensions = [ "rust-src" ];
                targets = [ "wasm32-unknown-unknown" ];
              })
              openssl
              pkg-config
              dioxus-cli
              nodejs_22
            ];
          in
          {
            default = pkgs.mkShell {
              # The Nix packages provided in the environment
              packages = deps;
              shellHook = ''
                zellij run --floating -- nix develop .#deps -c dx serve
                zellij run --floating -- nix develop .#deps -c npx tailwindcss -i ./input.css -o ./public/tailwind.css --watch
                nix develop .#deps -c vi ./src/app.rs
              '';
            };
            deps = pkgs.mkShell {
              packages = deps;
            };
          });
    };
}
