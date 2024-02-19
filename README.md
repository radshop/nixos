# nixos

### New computer setup

* run git in a nix shell `nix-shell -p git`
* `git clone https://github.com/radshop/nixos.git ~/nixos/`
* create a folder for this computer `mkdir ~/nixos/COMPUTER`
* make backup folder `sudo mkdir /etc/nixos/bak`
* copy the default config files `sudo cp /etc/nixos/*.nix /etc/nixos/bak/`
* move the config files `sudo mv etc/nixos/*.nix ~/nixos/COMPUTER`
* use the configuration.nix and home.nix as a template from another computer folder that's closest to what you want for this one. Change the hostname and any other changes you want to make
* create a symbolic link to the config file `sudo ln -s /home/miscguy/nixos/COMPUTER/configuration.nix /etc/nixos/configuration.nix`
* `sudo nix-channel --add https://nixos.org/channels/nixos-unstable nixos`
* `sudo nix-channel --add https://github.com/nix-community/home-manager/archive/master.tar.gz home-manager`
* `sudo nix-channel --update`
* `sudo nixos-rebuild switch`

After you have your ssh keys in place, you'll want to switch the git repo from using https to ssh:

* `cd ~/nixos`
* `git remote rm origin`
* `git remote add origin git@github.com:radshop/nixos.git`
* `git fetch origin`
* `git push --set-upstream origin/master`

Now running `sudo ~/nixos/rebuild` will manage the versions and run the rebuild
