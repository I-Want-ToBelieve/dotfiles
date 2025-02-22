{pkgs, ...}: {
  home.packages = with pkgs; [
    bfg-repo-cleaner
    colordiff
    gist
    gitAndTools.git-absorb
    gitAndTools.gitui
    gitAndTools.git-machete
    gitAndTools.gh
    git-filter-repo
  ];

  programs.git = {
    enable = true;
    lfs.enable = true;
    userName = "I-Want-ToBelieve";
    userEmail = "I.Want.ToBelieve.dev@gmail.com";

    delta = {
      enable = true;
      options.map-styles = "bold purple => syntax #8839ef, bold cyan => syntax #1e66f5";
    };

    extraConfig = {
      init = {defaultBranch = "main";};
      diff.colorMoved = "default";
      merge.conflictstyle = "diff3";
      delta = {
        syntax-theme = "Nord";
        line-numbers = true;
      };
      credential.helper = "${pkgs.gitAndTools.gitFull}/bin/git-credential-libsecret";
    };

    aliases = {
      co = "checkout";
      fuck = "commit --amend -m";
      ca = "commit -am";
      d = "diff";
      ps = "!git push origin $(git rev-parse --abbrev-ref HEAD)";
      pl = "!git pull origin $(git rev-parse --abbrev-ref HEAD)";
      af = "!git add $(git ls-files -m -o --exclude-standard | fzf -m)";
      st = "status";
      br = "branch";
      df = "!git hist | peco | awk '{print $2}' | xargs -I {} git diff {}^ {}";
      hist = ''
        log --pretty=format:"%Cgreen%h %Creset%cd %Cblue[%cn] %Creset%s%C(yellow)%d%C(reset)" --graph --date=relative --decorate --all'';
      llog = ''
        log --graph --name-status --pretty=format:"%C(red)%h %C(reset)(%cd) %C(green)%an %Creset%s %C(yellow)%d%Creset" --date=relative'';
      edit-unmerged = "!f() { git ls-files --unmerged | cut -f2 | sort -u ; }; hx `f`";
    };

    ignores = [
      "*~"
      "*.swp"
      "*result*"
      ".direnv"
      "node_modules"
    ];
  };
}
