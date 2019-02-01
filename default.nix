{ pkgs ? (import <nixpkgs> {})
, coqPackagesInfo ? {
    coq = "https://github.com/coq/coq/tarball/master";
    ssreflect = "https://github.com/math-comp/math-comp/tarball/master";
  }
, shell ? false
}:

let coqPackages =
  if builtins.isString coqPackagesInfo then
    let coq-version-parts = builtins.match "([0-9]+).([0-9]+)" coqPackagesInfo; in
    pkgs."coqPackages_${builtins.concatStringsSep "_" coq-version-parts}"
  else rec {
    coq = import (fetchTarball coqPackagesInfo.coq) {};
    ssreflect = pkgs.coqPackages.ssreflect.overrideAttrs (_: {
      inherit coq;
      src = fetchTarball coqPackagesInfo.ssreflect;
    });
  };
in

with coqPackages;

pkgs.stdenv.mkDerivation {

  name = "lemma-overloading";

  propagatedBuildInputs = [
    coq
    ssreflect
  ];

  src = if shell then null else ./.;

  installFlags = "COQLIB=$(out)/lib/coq/${coq.coq-version}/";
}
