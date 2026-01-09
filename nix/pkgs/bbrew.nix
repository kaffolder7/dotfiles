{ lib
, buildGoModule
, fetchFromGitHub
}:

buildGoModule rec {
  pname = "bbrew";
  version = "2.2.1";

  src = fetchFromGitHub {
    owner = "Valkyrie00";
    repo  = "bold-brew";
    rev   = "v${version}";
    # Fill this in after the first build attempt (see step 3)
    hash  = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=";
  };

  # The Go main package lives here:
  subPackages = [ "cmd/bbrew" ];

  # Fill this in after the first build attempt (see step 3)
  vendorHash = "sha256-BBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBB=";

  # Optional: helps keep outputs small
  ldflags = [
    "-s" "-w"
  ];

  meta = with lib; {
    description = "Bold Brew (bbrew) - a modern TUI for managing Homebrew packages and casks";
    homepage = "https://github.com/Valkyrie00/bold-brew";
    license = licenses.mit;
    mainProgram = "bbrew";
    platforms = platforms.darwin ++ platforms.linux;
  };
}