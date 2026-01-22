{ pkgs ? import <nixpkgs> {} }:

pkgs.python3Packages.buildPythonPackage rec {
  pname = "adblock";
  version = "0.6.0";

  format = "pyproject";

  src = pkgs.fetchFromGitHub {
    owner = "ArniDagur";
    repo = "python-adblock";
    rev = "${version}";
    hash = "sha256-5g5xdUzH/RTVwu4Vfb5Cb1t0ruG0EXgiXjrogD/+JCU=";
  };

  cargoDeps = pkgs.rustPlatform.fetchCargoVendor {
    inherit src;
    hash = "sha256-fetJX6HQxRZ/Az7rJeU9S+s8ttgNPnJEvTLfzGt4xjk=";
  };

  postPatch = ''
    # Remove deprecated [package.metadata.maturin] section completely
    sed -i '/\[package.metadata.maturin\]/,/^$/d' Cargo.toml || true

    # Remove classifiers line to avoid dangling TOML (common cause of parse error at "Programming Language :: Python")
    sed -i '/classifiers = /d' Cargo.toml || true

    # Optional: if there's still junk, strip any trailing commas in arrays (rare)
    sed -i 's/,\s*$//' Cargo.toml
  '';

  nativeBuildInputs = with pkgs; [
    rustPlatform.cargoSetupHook
    rustPlatform.maturinBuildHook
    cargo
    rustc
    pkg-config
    maturin
  ];

  buildInputs = with pkgs; [ openssl ];

  doCheck = false;

  pythonImportsCheck = [ "adblock" ];

  meta = with pkgs.lib; {
    description = "Python wrapper for Brave's adblock Rust library";
    homepage = "https://github.com/ArniDagur/python-adblock";
    license = licenses.mpl20;
  };
}
