
git_set_prompt() {
  if [ -d ./.git ]; then
    GITBRANCH="(\[\033[0;32m\]$(awk -F '/' '{ print $NF }' .git/HEAD)\[\033[0m\]"

    if [ $(git diff --exit-code > /dev/null 2>&1; echo $?) -eq 1 ] || [ $(git diff-index --cached --quiet --ignore-submodules HEAD --; echo $?) -eq 1 ]; then
      GITBRANCH="$GITBRANCH\[\033[1;31m\]*\[\033[0m\]"
    else
      GITBRANCH="$GITBRANCH\[\033[0;34m\]-\[\033[0m\]"
    fi

    if [ "x$(git status | grep Untracked)" != "x" ]; then
      GITBRANCH="$GITBRANCH\[\033[1;31m\]+\[\033[0m\])"
    else
      GITBRANCH="$GITBRANCH\[\033[0;34m\]-\[\033[0m\])"
    fi
  fi

  echo -ne "${GITBRANCH}"
}

