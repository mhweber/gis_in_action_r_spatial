## ----version, eval=FALSE-------------------------------------------------
## version$version.string

## ----version2, echo=FALSE------------------------------------------------
version$version.string

## ----git_version, eval=FALSE---------------------------------------------
## system("git --version")

## ----git_version2, echo=FALSE, eval=TRUE---------------------------------
system("git --version", intern = TRUE)

## ----latex_version, eval=FALSE-------------------------------------------
## system("latex --version")

## ----latex_version2, echo=FALSE, eval=TRUE-------------------------------
system("latex --version", intern = TRUE)

