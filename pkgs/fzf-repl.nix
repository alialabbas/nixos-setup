{ stdenv
, lib
, fetchFromGitHub
, bash
}:
stdenv.mkDerivation {
  name = "fzf-repl";
  pname = "fzf-repl";
  version = "08049f6";
  src = fetchFromGitHub {
    owner = "DanielFGray";
    repo = "fzf-scripts";
    rev = "15156e3cb56c715464a2421e6f4e4356a26ac975";
    sha256 = "sha256-rynePmia169HOvL0M2GTWrndulS6dKjfx7rT0GK9J0I=";
  };
  buildInputs = [ bash ];
  nativeBuildInputs = [ ];
  installPhase = ''
    mkdir -p $out/bin
    cp fzrepl $out/bin/fzf-repl
  '';
}
