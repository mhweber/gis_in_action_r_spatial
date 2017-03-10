MDS := $(patsubst %.Rmd,%.md,$(wildcard *.Rmd))
POSTDIR := ../_posts

all: $(MDS)

%.md: %.Rmd    
	Rscript -e "source('knit_it.R'); knit_it('$<')"
	cp $@ ../_posts/.

git: $(POSTDIR)	
	git add -A :/
	git commit -m "automatic build of site"
	git push -u origin gh-pages

