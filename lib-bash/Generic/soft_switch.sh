
# Used for modifying what library is symlinked to one another

relink($software,$version) {
    ln -sf $sofware-$version $software-current;
}

