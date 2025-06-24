{ pkgs ? import <nixpkgs> {}, ... }:

let
  # Double-tap up arrow script for entering copy mode
  doubleTapScript = pkgs.writeShellScript "tmux-double-up" ''
    #!/bin/bash
    last_file="/tmp/tmux-last-up-$"
    current_time=$(date +%s%3N)

    if [ -f "$last_file" ]; then
        last_time=$(cat "$last_file")
        diff=$((current_time - last_time))
        
        if [ $diff -lt 300 ]; then  # 300ms window
            tmux copy-mode -e
            rm -f "$last_file"
            exit
        fi
    fi

    echo "$current_time" > "$last_file"
    tmux send-keys Up
  '';

in {
  programs.tmux = {
    enable = true;
    package = pkgs.tmux;
    
    # Basic configuration
    terminal = "tmux-256color";
    historyLimit = 50000;
    baseIndex = 1;
    keyMode = "vi";
    mouse = true;
    escapeTime = 10;
    
    # Enable aggressive resize for better multi-session support
    aggressiveResize = true;
    
    # Use 24-hour clock
    clock24 = true;
    
    # Plugins for enhanced functionality
    plugins = with pkgs.tmuxPlugins; [
      # Your existing plugins
      resurrect
      {
        plugin = resurrect;
        extraConfig = ''
          set -g @resurrect-strategy-nvim 'session'
          set -g @resurrect-strategy-vim 'session'
          set -g @resurrect-capture-pane-contents 'on'
          resurrect_dir="$HOME/.tmux/resurrect"
          set -g @resurrect-dir $resurrect_dir
          set -g @resurrect-hook-post-save-all 'target=$(readlink -f $resurrect_dir/last); sed "s| --cmd .*-vim-pack-dir||g; s|/etc/profiles/per-user/$USER/bin/||g" $target | sponge $target'
        '';
      }
      {
        plugin = continuum;
        extraConfig = ''
          set -g @continuum-restore 'on'
          set -g @continuum-save-interval '10'
        '';
      }
      
      # New plugins for enhanced functionality
      {
        plugin = better-mouse-mode;
        extraConfig = ''
          set -g @scroll-speed-num-lines-per-scroll 3
          set -g @scroll-down-exit-copy-mode "on"
          set -g @scroll-without-changing-pane "on"
          set -g @scroll-in-moused-over-pane "on"
        '';
      }
      
      # Sensible defaults
      sensible
      
      # Copy to system clipboard
      {
        plugin = yank;
        extraConfig = ''
          set -g @yank_action 'copy-pipe-no-clear'
          bind -T copy-mode-vi v send-keys -X begin-selection
          bind -T copy-mode-vi C-v send-keys -X rectangle-toggle
          bind -T copy-mode-vi y send-keys -X copy-selection-and-cancel
          bind -T copy-mode-vi Escape send-keys -X cancel
        '';
      }
    ];

    extraConfig = ''
      # ===========================
      # Modern Copy/Paste Support
      # ===========================
      
      # Enable Ctrl+C/V for copy/paste (context-aware)
      bind-key -n C-c if-shell -F "#{selection_present}" \
          "send-keys -X copy-selection-and-cancel" \
          "send-keys C-c"
      
      bind-key -n C-v paste-buffer
      
      # Alternative interrupt key since Ctrl+C is now copy
      bind-key -n C-S-c send-keys C-c
      
      # ===========================
      # Mouse Scroll Auto Copy Mode  
      # ===========================
      
      # Automatically enter copy mode when scrolling up
      bind-key -n WheelUpPane if-shell -F -t = "#{mouse_any_flag}" \
          "send-keys -M" \
          "if -Ft= '#{pane_in_mode}' 'send-keys -M' 'select-pane -t=; copy-mode -e; send-keys -M'"
      
      bind-key -n WheelDownPane select-pane -t= \; send-keys -M
      
      # ===========================
      # Double-tap Up Arrow Support
      # ===========================
      
      # Use external script for double-tap detection
      bind-key -n Up run-shell '${doubleTapScript}'
      
      # ===========================
      # Enhanced Key Bindings
      # ===========================
      
      # Your existing reload binding (updated message)
      bind-key r source-file ~/.config/tmux/tmux.conf \; display-message "~/.tmux.conf reloaded."
      
      # Better pane splitting
      bind | split-window -h -c "#{pane_current_path}"
      bind - split-window -v -c "#{pane_current_path}"
      
      # Vim-style pane navigation
      bind h select-pane -L
      bind j select-pane -D
      bind k select-pane -U
      bind l select-pane -R
      
      # Vim-style pane resizing
      bind -r H resize-pane -L 5
      bind -r J resize-pane -D 5
      bind -r K resize-pane -U 5
      bind -r L resize-pane -R 5
      
      # Vim-style copy mode bindings
      bind-key -T copy-mode-vi v send-keys -X begin-selection
      bind-key -T copy-mode-vi y send-keys -X copy-selection-and-cancel
      bind-key -T copy-mode-vi r send-keys -X rectangle-toggle
      
      # ===========================
      # Visual Enhancements
      # ===========================
      
      # Enable true colors
      set -ga terminal-overrides ",*:Tc"
      set -ga terminal-overrides '*:Ss=\E[%p1%d q:Se=\E[ q'
      
      # Status bar configuration
      set -g status-position bottom
      set -g status-justify left
      set -g status-style 'bg=colour234 fg=colour137'
      
      set -g status-left ""
      set -g status-right '#[fg=colour233,bg=colour241,bold] %d/%m #[fg=colour233,bg=colour245,bold] %H:%M:%S '
      set -g status-right-length 50
      set -g status-left-length 20
      
      # Window status
      setw -g window-status-current-style 'fg=colour1 bg=colour19 bold'
      setw -g window-status-current-format ' #I#[fg=colour249]:#[fg=colour255]#W#[fg=colour249]#F '
      setw -g window-status-style 'fg=colour9 bg=colour18'
      setw -g window-status-format ' #I#[fg=colour237]:#[fg=colour250]#W#[fg=colour244]#F '
      
      # Pane borders
      set -g pane-border-style 'fg=colour238 bg=colour235'
      set -g pane-active-border-style 'fg=colour208 bg=colour236'
      
      # ===========================
      # Performance & Behavior
      # ===========================
      
      # Faster command sequences
      set -s escape-time 10
      
      # Increase repeat timeout
      set -sg repeat-time 600
      
      # Focus events for terminals that support them
      set -g focus-events on
      
      # Expect UTF-8
      setw -g utf8 on
      set -g status-utf8 on
      
      # Monitor activity
      setw -g monitor-activity on
      set -g visual-activity off
      
      # Don't rename windows automatically
      set-option -g allow-rename off
      
      # Start windows and panes at 1, not 0
      set -g base-index 1
      setw -g pane-base-index 1
      
      # Renumber windows when one is closed
      set -g renumber-windows on
      
      # ===========================
      # Additional Useful Bindings
      # ===========================
      
      # Quick window switching
      bind -n M-1 select-window -t 1
      bind -n M-2 select-window -t 2
      bind -n M-3 select-window -t 3
      bind -n M-4 select-window -t 4
      bind -n M-5 select-window -t 5
      
      # Session navigation
      bind C-s choose-session
      
      # Clear screen and history
      bind C-l send-keys 'C-l' \; clear-history
      
      # Toggle synchronize panes
      bind S setw synchronize-panes
      
      # ===========================
      # Copy Mode Enhancements
      # ===========================
      
      # More vim-like copy mode
      bind-key -T copy-mode-vi 'C-h' select-pane -L
      bind-key -T copy-mode-vi 'C-j' select-pane -D
      bind-key -T copy-mode-vi 'C-k' select-pane -U
      bind-key -T copy-mode-vi 'C-l' select-pane -R
      bind-key -T copy-mode-vi 'C-\' select-pane -l
      
      # Search in copy mode
      bind-key -T copy-mode-vi / command-prompt -i -p "search down" "send -X search-forward-incremental \"%%%\""
      bind-key -T copy-mode-vi ? command-prompt -i -p "search up" "send -X search-backward-incremental \"%%%\""
      
      # Copy mode mouse support
      bind-key -T copy-mode-vi MouseDragEnd1Pane send-keys -X copy-selection-and-cancel
    '';
  };
}
