function o --description "Launch GUI app and close terminal"
    nohup $argv &>/dev/null &
    disown
    exit
end
