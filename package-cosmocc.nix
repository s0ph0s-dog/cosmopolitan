{
  stdenv,
  fetchurl,
  unzip,
}:
stdenv.mkDerivation (finalAttrs: let
  version = "3.9.2";
in{
  # Download and extract the cosmocc toolchain separately, so that the work
  # can be reused (and so that the build doesn't fail when the Cosmopolitan
  # makefile tries to do the same thing)
  pname = "cosmocc";
  version = version;

  strictDeps = true;
  src = fetchurl {
    url = "https://github.com/jart/cosmopolitan/releases/download/${version}/cosmocc-${version}.zip";
    hash = "sha256-9P8Tr2X80wnz8c/QQnWZb7f3KkiXcmYoqMnPcy6FAZM=";
  };
  sourceRoot = ".";

  nativeBuildInputs = [unzip];

  dontCheck = true;
  dontConfigure = true;
  dontPatch = true;
  dontBuild = true;
  dontFixup = true;

  installPhase = ''
    runHook preInstall
    mkdir -p "$out"
    cp -R ./* $out
    runHook postInstall
  '';
})
