{
  programs.bash = {
    enable = true;
    bashrcExtra = ''
			# TMUX BASH HISTORY
			# avoid duplicates..
			export HISTCONTROL=ignoredups:erasedups
			# append history entries..
			shopt -s histappend
			# After each command, save and reload history
			export PROMPT_COMMAND="history -a; history -c; history -r; $PROMPT_COMMAND"
    '';
  };
}
