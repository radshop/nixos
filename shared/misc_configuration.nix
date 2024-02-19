{
# Automatic Garbage Collection
nix.gc = {
					automatic = true;
					dates = "weekly";
					options = "--delete-older-than 7d";
			};

	# Auto system update
	system.autoUpgrade = {
				enable = true;
	};
}
