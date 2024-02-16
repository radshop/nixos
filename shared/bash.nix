with import <nixpkgs> {};
{
  programs.bash = {
    enable = true;
    bashrcExtra = ''
      function conda-shell {
          nix-shell ~/nixos/conda/conda-shell.nix
      }
    '';
    # profileExtra = ''
    #   docker start sql1
    # '';
  };
}
