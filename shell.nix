# SPDX-FileCopyrightText: 2024 Caleb Depatie
#
# SPDX-License-Identifier: 0BSD

{
  pkgs ? import <nixpkgs> {} 
}:  pkgs.mkShell {
  nativeBuildInputs = with pkgs.buildPackages; [
    zig
    reuse
  ];
}
