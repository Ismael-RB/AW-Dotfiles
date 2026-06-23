set -l _skip fish bash zsh sh dash python python3 nvim vim nano emacs micro \
    htop btop top less more man git ssh curl wget pacman yay paru sudo doas env

for _f in /usr/share/applications/*.desktop ~/.local/share/applications/*.desktop
    test -f $_f; or continue
    set -l _raw (grep -m1 '^Exec=' $_f 2>/dev/null)
    test -n "$_raw"; or continue
    set -l _name (basename (string replace 'Exec=' '' $_raw | string replace -r ' .*' '' | string trim))
    contains -- $_name $_skip; and continue
    command -q $_name; or continue
    functions -q $_name; and continue
    function $_name --inherit-variable _name
        nohup (command --search $_name) $argv &>/dev/null &
        disown
        exit
    end
end
