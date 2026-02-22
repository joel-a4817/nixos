{ config, pkgs, lib, ... }:
{
  home.username = "joel";
  home.homeDirectory = "/home/joel";
  home.stateVersion = "25.11";
  programs.home-manager.enable = true;

  # Greek keyboard
  home.file.".XCompose".text = ''
    include "%L"
    # Custom Greek letters via Compose key
    # Lowercase: Compose + g + latin equivalent
    <Multi_key> <g> <a> : "α" U03B1   # alpha
    <Multi_key> <g> <b> : "β" U03B2   # beta
    <Multi_key> <g> <g> : "γ" U03B3   # gamma
    <Multi_key> <g> <d> : "δ" U03B4   # delta
    <Multi_key> <g> <e> : "ε" U03B5   # epsilon
    <Multi_key> <g> <z> : "ζ" U03B6   # zeta
    <Multi_key> <g> <h> : "η" U03B7   # eta
    <Multi_key> <g> <q> : "θ" U03B8   # theta (using q for th)
    <Multi_key> <g> <i> : "ι" U03B9   # iota
    <Multi_key> <g> <k> : "κ" U03BA   # kappa
    <Multi_key> <g> <l> : "λ" U03BB   # lambda
    <Multi_key> <g> <m> : "μ" U03BC   # mu
    <Multi_key> <g> <n> : "ν" U03BD   # nu
    <Multi_key> <g> <x> : "ξ" U03BE   # xi
    <Multi_key> <g> <o> : "ο" U03BF   # omicron
    <Multi_key> <g> <p> : "π" U03C0   # pi
    <Multi_key> <g> <r> : "ρ" U03C1   # rho
    <Multi_key> <g> <s> : "σ" U03C3   # sigma (final σ is usually automatic in fonts)
    <Multi_key> <g> <t> : "τ" U03C4   # tau
    <Multi_key> <g> <u> : "υ" U03C5   # upsilon
    <Multi_key> <g> <f> : "φ" U03C6   # phi
    <Multi_key> <g> <c> : "χ" U03C7   # chi (using c for ch)
    <Multi_key> <g> <y> : "ψ" U03C8   # psi (y for ps)
    <Multi_key> <g> <w> : "ω" U03C9   # omega
    # Uppercase: Compose + G (Shift+g) + latin equivalent
    <Multi_key> <G> <A> : "Α" U0391   # Alpha
    <Multi_key> <G> <B> : "Β" U0392   # Beta
    <Multi_key> <G> <G> : "Γ" U0393   # Gamma
    <Multi_key> <G> <D> : "Δ" U0394   # Delta
    <Multi_key> <G> <E> : "Ε" U0395   # Epsilon
    <Multi_key> <G> <Z> : "Ζ" U0396   # Zeta
    <Multi_key> <G> <H> : "Η" U0397   # Eta
    <Multi_key> <G> <Q> : "Θ" U0398   # Theta
    <Multi_key> <G> <I> : "Ι" U0399   # Iota
    <Multi_key> <G> <K> : "Κ" U039A   # Kappa
    <Multi_key> <G> <L> : "Λ" U039B   # Lambda
    <Multi_key> <G> <M> : "Μ" U039C   # Mu
    <Multi_key> <G> <N> : "Ν" U039D   # Nu
    <Multi_key> <G> <X> : "Ξ" U039E   # Xi
    <Multi_key> <G> <O> : "Ο" U039F   # Omicron
    <Multi_key> <G> <P> : "Π" U03A0   # Pi
    <Multi_key> <G> <R> : "Ρ" U03A1   # Rho
    <Multi_key> <G> <S> : "Σ" U03A3   # Sigma
    <Multi_key> <G> <T> : "Τ" U03A4   # Tau
    <Multi_key> <G> <U> : "Υ" U03A5   # Upsilon
    <Multi_key> <G> <F> : "Φ" U03A6   # Phi
    <Multi_key> <G> <C> : "Χ" U03A7   # Chi
    <Multi_key> <G> <Y> : "Ψ" U03A8   # Psi
    <Multi_key> <G> <W> : "Ω" U03A9   # Omega
  '';

  # Cursor settings (configure in sway)
  home.pointerCursor = {
    name = "Bibata-Modern-Amber";
    package = pkgs.bibata-cursors;
    gtk.enable = true;
    x11.enable = true;
  };

  # User packages
  home.packages = with pkgs; [
    heimdall-gui android-tools
    snapshot
    clipse
    calcurse
    libreoffice-qt6-fresh hunspell hunspellDicts.en_AU
    zathura zathuraPkgs.zathura_pdf_mupdf
    discord
    prismlauncher
    signal-desktop
    kicad
    bambu-studio
    opencv
    qt5.qtwayland #Required for Qt apps like those above.
    #yazi pkgs:
    ffmpeg p7zip jq poppler fzf zoxide resvg imagemagick
    trash-cli lazygit fd ripgrep nushell #required by yazi plugins
  ];

programs.foot = {
  enable = true;
  settings = {
    main = {
      font = "JetBrainsMono Nerd Font:size=16";
    };
  };
};

  fonts.fontconfig.enable = true;
  xresources = {
    enable = true;
    properties = {
      "XTerm*renderFont" = "true"; 
      "XTerm*faceName"   = "JetBrains Mono";  
      "XTerm*faceSize"   = "16";
      "XTerm.termName"   = "xterm-256color"; 

      "XTerm.vt100.utf8"            = "2";        
      "XTerm.vt100.metaSendsEscape" = "true";     
      "XTerm.vt100.backarrowKey"    = "false";    
      "XTerm.ttyModes"              = "erase ^?"; 
 
      "XTerm*saveLines"        = "10000";
      "XTerm*scrollBar"        = "false";
      "XTerm*scrollTtyOutput"  = "false";
      "XTerm*scrollKey"        = "true";
      "XTerm.vt100.selectToClipboard" = "true";   
      "XTerm*internalBorder"   = "6";
 
      "XTerm*foreground" = "rgb:a8/a8/a8";
      "XTerm*background" = "rgb:22/22/22";
      "XTerm*color0"  = "#000000";
      "XTerm*color1"  = "#a80000";
      "XTerm*color2"  = "#00a800";
      "XTerm*color3"  = "#a85400";
      "XTerm*color4"  = "#5858b8";
      "XTerm*color5"  = "#a800a8";
      "XTerm*color6"  = "#00a8a8";
      "XTerm*color7"  = "#a8a8a8";
      "XTerm*color8"  = "#545454";
      "XTerm*color9"  = "#fc5454";
      "XTerm*color10" = "#54fc54";
      "XTerm*color11" = "#fcfc54";
      "XTerm*color12" = "#5454fc";
      "XTerm*color13" = "#fc54fc";
      "XTerm*color14" = "#54fcfc";
      "XTerm*color15" = "#fcfcfc";

      "XTerm.vt100.translations" =
        ''#override \
           Ctrl Shift <Key>plus:        larger-vt-font() \n\
           Ctrl Shift <Key>KP_Add:      larger-vt-font() \n\
           Ctrl Shift <Key>minus:       smaller-vt-font() \n\
           Ctrl Shift <Key>KP_Subtract: smaller-vt-font()'';
    };
  };

  programs.yazi = {
    enable = true;
    package = pkgs.yazi.override { _7zz = pkgs._7zz-rar; }; # Support for RAR extraction
    plugins = {
      sudo = pkgs.yaziPlugins.sudo; #https://github.com/TD-Sky/sudo.yazi
      lazygit = pkgs.yaziPlugins.lazygit; #https://github.com/Lil-Dank/lazygit.yazi
      recycle-bin = pkgs.yaziPlugins.recycle-bin; #https://github.com/uhs-robert/recycle-bin.yazi
      restore = pkgs.yaziPlugins.restore; #https://github.com/boydaihungst/restore.yazi
    };
  };

programs.fastfetch.enable = true;

}
