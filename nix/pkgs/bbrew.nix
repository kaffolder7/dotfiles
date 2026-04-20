{
  lib,
  buildGoModule,
  fetchFromGitHub,
}:

buildGoModule rec {
  pname = "bbrew";
  version = "2.2.1";

  src = fetchFromGitHub {
    owner = "Valkyrie00";
    repo = "bold-brew";
    # rev   = "v2.2.1";
    rev = "v${version}";
    hash  = "sha256-wcyaUu1OMh5O0haZd7QAAoDydnkzGPIUCohz6zcLT+M=";
  };

  # The Go main package lives here:
  subPackages = [ "cmd/bbrew" ];

  vendorHash = "sha256-5gFyfyerRKfq0uGkyIJ1W4XLhyRR5qPyhc/f2Y2skrI=";

  # Optional: helps keep outputs small
  ldflags = [
    "-s"
    "-w"
  ];

  meta = with lib; {
    description = "Bold Brew (bbrew) - a modern TUI for managing Homebrew packages and casks";
    homepage = "https://github.com/Valkyrie00/bold-brew";
    license = licenses.mit;
    mainProgram = "bbrew";
    platforms = platforms.darwin ++ platforms.linux;
  };
}
