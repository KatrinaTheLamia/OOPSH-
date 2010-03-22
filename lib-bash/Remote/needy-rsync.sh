# This is a library designed to have OOPSH pull files from an rsync server 
# for systems with smaller harddisks. It will result in a temporary local 
# file that the system can still use, even without internets.
#
# Some functions, have not been written yet. `printl` is mostly a planned
# system for localisation in OOPSH. There are also a few functions to test 
# if OOPSH or Needy_Rsynce are properly set up. Rather then set a system 
# environment for it, these functions will check if we are properly setup.
# Oh right: this file will demonstrate the criminal insanity of Katrina.
# As nobody programs BASH in this manner unless they have a LOT of screws 
# loose.

alias cp="rsync";

function needy_rsync_setup() {
    $INFO && echo 'Setting up Needy RSync';
    if [[ ! kitkat_is_setup() ]]; then 
	    $INFO && echo "OOPSH is not set up. Attempting to set it up\n";
	    if [[ ! -f "${OOPSH_HOME:="${HOME:="/home/${USERNAME:="${USER:="OOPSH"}"}"}/OOPSH"}/libexec/OOPSH.sh" ]]; then 
		    ${ERROR:='1'} && echo "Unable to locate OOPSH setup. Sorry... exiting\n";
		    return 1;
	    elif [[ ! . "${OOPSH_HOME}/libexec.sh" ]]
		    ${ERROR:='1'} && echo "Unable to setup OOPSH. Sorry... exiting.\n";
		    return 1;
	    else
		    $INFO && printl('English|Info','OOPSH Setup.');
	    fi;
    fi;
    $INFO && printl('English|Info','Setting up Environment Variables.');
    $INFO || $DEBUG && printl('English|Debug','Environment: $needy_rsync_name -> "Needy_RSync"');
    export needy_rsync_name='Needy_RSync';
    $INFO || $DEBUG && printl('English|Debug',"Environment: \$needy_rsync_home -> \"${OOPSH_HOME}/Needy_RSync\"";
    export needy_rsync_home="${OOPSH_HOME}/Needy_RSync";
    $INFO || $DEBUG && printl('English|Debug','Environment: $rcwd -> "."');
    export rcwd='.';
    if [[ OOPSH_has_config($needy_rsync, $rcwd, "host") ]]; then
	$INFO || printl('English|Info','Grabbing Previous Remote Host Information');
        export needy_remote_host="$(OOPSH_get_config($needy_rsync, $rcwd,'host'))";
    else
        $INFO && printl('English|Info','Setting Remote Host Information');
        $INFO || $DEBUG && printl('English|Debug',"Enviroment: \$remote_host -> \"${USERNAME:="{$USER:='OOPS'}@localhost:~"}\"");
        export needy_remote_host="${USERNAME:="{$USER:='OOPSH'}@localhost:~"}";
        $INFO || printl('English|Info','Storing Remote Host Name');
        kitkat_set_config($needy_rsync, $rcwd, 'host', $remote_host);
    fi;
}

function grab_prompt() {
    if [[ ! OOPSH_is_setup() && ! needy_rsync_is_setup() ]]; then
	if [[ needy_rsync_setup() ]]; then
	    echo -ne "(\[\033[1:31m\]Unable to Needy RSync\[\033[0m\])";
	fi;
    else NEEDY_RSYNC="(\[\033[0:32m\)${remote_host}\>${rcwd}\[\033[0m\])";
    fi;
    echo -ne ${NEEDY_RSYNC:=''};
}

function change_remote($host) {
    export remote_host="$host";
    if [[ ! OOPSH_is_setup() || ! needy_rsync_is_setup() ]]; then
	$INFO && echo "Needy RSync Does not appear to be set up--setting up";
	if [[ needy_rsync_setup() ]]; then
		${ERROR:='1'} && echo "Unable to setup Needy RSync for some reason.";
		return 1;
	fi;
    fi;
    kitkat_config_store($needy_rsync_name, $rcwd, "host", $remote_host);
    return 0;
}

function change_rsync_path($path) {
    export rcwd="$CWD";
    if [[ ! OOPSH_is_setup() || ! needy_rsync_is_setup() ]]; then
	 $INFO && echo "Needy RSync Does not appear to be set up--setting up";
	 if [[ needy_rsync_setup() ]]; then
             ${ERROR:='1'} && echo "Unable to setup Needy RSynce for some reason.";
	     return 1;
         fi;
    fi;
    if [[kitkat_has_config($needy_rsync_name, $rcwd, "host") ]]; then
         export $needy_remote_host="$(OOPSH_get_config($needy_rsync_name, $rcwd, "host"))";
    fi;
    build_path("${needy_rsync_home}/");
    return 0;
};

function rsync_move($from, $to) {
    rsync -rv $from $to;
    rm -rf $from;
};

function grab_file($path) {
    rsync -rv "$remote_host$file" .;
};

function backup_file($path) {
    rsync -rv $path "$remote_host$path";
};

function entry_path($path) {
    grab_file("$rcwd/$path");
    cd $path;
    export rcwd="$rcwd/$path"
}

function leave_path() {
    cd ..;
    backup_file($rcwd);
    if [$clean];
    then rm -rf $rcwd;
    fi;
    export rcwd="$rcwd/.."
};

