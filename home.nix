{ config, pkgs, lib, ... }:
{
  home.username = "joel";
  home.homeDirectory = "/home/joel";
  home.stateVersion = "25.11";
  programs.home-manager.enable = true;

  # Cursor settings (configure in sway)
  home.pointerCursor = {
    name = "Bibata-Modern-Amber";
    package = pkgs.bibata-cursors;
    gtk.enable = true;
    x11.enable = true;
  };

  # User packages
  home.packages = with pkgs; [
    prismlauncher
    signal-desktop
    kicad
    prusa-slicer
    bambu-studio
    opencv
    qt5.qtwayland #Required for Qt apps like those above.
    #yazi pkgs:
    ffmpeg p7zip jq poppler fzf zoxide resvg imagemagick
    trash-cli jdupes lazygit #required by yazi plugins
    fd ripgrep #required by neovim (telescope) and yazi.
  ];

programs.foot = {
  enable = true;
  settings = {
    main = {
      font = "JetBrainsMono Nerd Font:size=16";
    };
    colors = {
      alpha = 0.88;
      background = "1d1c22";
      foreground = "ffffff";
    };
  };
};

  programs.yazi = {
    enable = true;
    package = pkgs.yazi.override { _7zz = pkgs._7zz-rar; }; # Support for RAR extraction
    plugins = { #don't need chmod or sudo for now.
      #yaziPlugins.chmod #https://github.com/yazi-rs/plugins/tree/main/chmod.yazi
      #yaziPlugins.sudo #https://github.com/TD-Sky/sudo.yazi
      git         = pkgs.yaziPlugins.git; #https://github.com/yazi-rs/plugins/tree/main/git.yazi
      lazygit     = pkgs.yaziPlugins.lazygit; #https://github.com/Lil-Dank/lazygit.yazi
      recycle-bin = pkgs.yaziPlugins.recycle-bin; #https://github.com/uhs-robert/recycle-bin.yazi
      restore     = pkgs.yaziPlugins.restore; #https://github.com/boydaihungst/restore.yazi
    };
  };

programs.neovim = {
  enable = true;
  defaultEditor = true;
  viAlias = true;
  vimAlias = true;

  plugins = with pkgs.vimPlugins; [
    telescope-nvim
    plenary-nvim
    telescope-fzf-native-nvim
  ];

  extraLuaConfig = ''
    vim.g.mapleader = " "

    vim.opt.number = true
    vim.opt.relativenumber = true
    vim.opt.termguicolors = true
    vim.opt.expandtab = true
    vim.opt.shiftwidth = 2
    vim.opt.tabstop = 2
    vim.opt.signcolumn = "yes"

    vim.cmd [[
      hi Normal guibg=NONE ctermbg=NONE
      hi NormalNC guibg=NONE ctermbg=NONE
      hi NonText guibg=NONE ctermbg=NONE
    ]]

    require("telescope").setup({
      extensions = {
        fzf = {
          fuzzy = true,
          override_generic_sorter = true,
          override_file_sorter = true,
          case_mode = "smart_case",
        },
      },
    })
    require("telescope").load_extension("fzf")

    local map = vim.keymap.set
    local opts = { noremap = true, silent = true }
    local builtin = require("telescope.builtin")

    map("n", "<leader>ff", builtin.find_files, opts)
    map("n", "<leader>fg", builtin.live_grep, opts)
    map("n", "<leader>fb", builtin.buffers, opts)
    map("n", "<leader>fh", builtin.help_tags, opts)

    map("n", "<leader>gc", builtin.git_commits,  { desc = "Git commits" })
    map("n", "<leader>gC", builtin.git_bcommits, { desc = "Git commits (file)" })
    map("n", "<leader>gb", builtin.git_branches, { desc = "Git branches" })
    map("n", "<leader>gs", builtin.git_status,   { desc = "Git status" })
    map("n", "<leader>gS", builtin.git_stash,    { desc = "Git stash" })

    map("n", "<leader>mm", ":set modifiable<CR>", opts)
  '';
};

programs.fastfetch.enable = true;

}


