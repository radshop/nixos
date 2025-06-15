{
# Automatic Garbage Collection
nix.gc = {
					automatic = true;
					dates = "weekly";
					options = "--delete-older-than 100d";
			};

	# Auto system update
	system.autoUpgrade = {
				enable = true;
	};
}
