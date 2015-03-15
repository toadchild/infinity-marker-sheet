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
	./doconversion.pl ppm jpg
	./doconversion.pl killian jpg
	./doconversion.pl command jpg

install:
	rm -rf /var/www/inf-dice/markers/jpg/
	rm -rf /var/www/inf-dice/markers/thumb/
	cp -R jpg thumb index.pl annotation.csv /var/www/inf-dice/markers/

beta:
	rm -rf /var/www/inf-dice/markers/beta/jpg/
	rm -rf /var/www/inf-dice/markers/beta/thumb/
	cp -R jpg thumb index.pl annotation.csv /var/www/inf-dice/markers/beta/
