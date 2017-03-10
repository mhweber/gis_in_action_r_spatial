## ----git_config, echo=FALSE----------------------------------------------
system("git config --global -l",intern = TRUE)

## ----git_remote, echo=FALSE----------------------------------------------
system("git remote -v",intern = TRUE)

## ----git_status, echo=FALSE, cache=TRUE----------------------------------
system("git status",intern = TRUE)

## ----git_commit, echo=FALSE, cache=TRUE----------------------------------
system("git commit -m 'My Changes'",intern = TRUE)

