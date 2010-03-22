

function set_prompt($string) {
    echo -ne "\[\033[0;34m\][\u@\h \W]\[\033[0m\[${string}\[\033[0;34m\]\\$[\033[0m\] "

}

