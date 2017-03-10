knit_it<-function(rmdfile){
	knitr::opts_knit$set(base.dir = "../figure/",base.url="{{ site.url }}/figure/")
	knitr::opts_chunk$set(fig.path="")
	knitr::render_jekyll()
	knitr::knit(rmdfile,tangle=TRUE)
	knitr::knit(rmdfile)
}