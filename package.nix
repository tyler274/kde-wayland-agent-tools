{
  lib,
  stdenvNoCC,
  makeWrapper,
  bash,
  coreutils,
  gnugrep,
  gawk,
  gnused,
  python3,
  dotool,
  systemd,
  kdePackages,
}:

stdenvNoCC.mkDerivation {
  pname = "kde-wayland-agent-tools";
  version = "0.1.0";
  src = ./.;

  nativeBuildInputs = [ makeWrapper ];
  buildInputs = [ python3 ];

  dontBuild = true;

  installPhase = ''
    runHook preInstall
    mkdir -p $out/bin
    install -m755 bin/* $out/bin/
    # Every script sources kw-env next to itself; the scripts stay in one
    # directory, so wrapProgram's .kw-*-wrapped layout keeps that working.
    for tool in kw-focus kw-input kw-screenshot kw-mpris kw-press-play; do
      wrapProgram $out/bin/$tool --prefix PATH : ${
        lib.makeBinPath [
          bash
          coreutils
          gnugrep
          gawk
          gnused
          dotool
          systemd
          kdePackages.qttools
          kdePackages.spectacle
        ]
      }
    done
    runHook postInstall
  '';

  meta = {
    description = "Drive a KDE Plasma Wayland desktop from a terminal agent";
    homepage = "https://github.com/tyler274/kde-wayland-agent-tools";
    license = lib.licenses.mit;
    platforms = lib.platforms.linux;
    mainProgram = "kw-press-play";
  };
}
