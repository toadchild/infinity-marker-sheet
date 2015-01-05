all: ppm png jpg

download:
	rm -f Sheets_Letter.pdf
	wget http://infinitythegame.com/archivo/Sheets_Letter.pdf

ppm: Sheets_Letter.pdf
	rm -rf ppm
	mkdir ppm
	pdfimages Sheets_Letter.pdf ppm/marker

png: .PHONY
	rm -rf png
	mkdir png
	for i in ppm/*; do out=`echo $$i | sed -e 's/ppm/png/g'`; convert -density 150 -units PixelsPerInch $$i $$out; done
	./domask.pl annotation.csv png
	for i in png/*; do mogrify -fuzz 5% -trim +repage $$i; done

jpg: .PHONY
	rm -rf jpg
	mkdir jpg
	for i in png/*; do out=`echo $$i | sed -e 's/png/jpg/g'`; convert -density 150 -units PixelsPerInch $$i $$out; done

install:
	cp -R jpg index.pl annotation.csv /var/www/inf-dice/markers/

beta:
	cp -R jpg index.pl annotation.csv /var/www/inf-dice/markers/beta/
.PHONY:
