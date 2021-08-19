# Edit config
function ez; nvim ~/config/src/ +"PackerLoad dashboard-nvim" +Dashboard +NvimTreeOpen; end
function ea; nvim ~/config/src/.config/fish/conf.d/myFunctions.fish; end
function sz; exec fish; end

function notes; nvim "~/notes"; end

# Navigation
function cs; cd $argv; ls -A; end
function sc; cd ..; ls -A; end
function csa; cd $argv; ls -Ahl; end
function sca; cd ..; ls -Ahl; end
function la; ls -A $argv; end
function lah; ls -Ahl $argv; end
function ..; cd ..; end
function ...; cd ../..; end
function ....; cd ../../..; end
function ffs; eval sudo $history[1]; end
function :q; exit; end

# Git
function gcm; git commit -m; end
function b; git branch; end
function co; git checkout $argv; end
function s; git status $argv; end
function st; git stash $argv; end
function sd; git stash drop $argv; end
function sp; git stash pop $argv; end
function sa; git stash apply $argv; end
function sl; git stash list $argv; end

