all: ppm jpg

.PHONY:

download:
	rm -f Sheets_Letter.pdf
	wget http://infinitythegame.com/archivo/Sheets_Letter.pdf

ppm: Sheets_Letter.pdf
	rm -rf ppm
	mkdir ppm
	pdfimages Sheets_Letter.pdf ppm/marker

jpg: .PHONY
	rm -rf jpg
	mkdir jpg
	for i in ppm/*; do out=`echo $$i | sed -e 's/ppm/jpg/g'`; convert -density 150 -units PixelsPerInch $$i $$out; done
	./domask.pl annotation.csv jpg
	for i in jpg/*; do mogrify -fuzz 5% -trim +repage $$i; done

install:
	cp index.pl annotation.csv /var/www/inf-dice/markers/
	./install_images.pl /var/www/inf-dice/markers/

beta:
	cp index.pl annotation.csv /var/www/inf-dice/markers/beta/
	./install_images.pl /var/www/inf-dice/markers/beta/
