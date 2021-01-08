#
#  vdc - vector drawable converter
#

svg2vd: $(cooked)/vdc

content-targets += svg2vd
cooked-deps += src/svg2vd/convert.xsl

LOG_SVG2VD = printf "[$(blue)svg2vd$(generic)] "; echo

##

$(cooked)/vdc: src/svg2vd/convert.xsl
	$(LOG_SVG2VD) -n Copying updated vdc stylesheet...
	cp $< $@
	printf "$(green)done$(generic)\n"
