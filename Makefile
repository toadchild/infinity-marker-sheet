all: clean n3 hsn3 killian vyo command grey_camo holoecho_colors

.PHONY:

clean:
	rm -rf jpg thumb
	mkdir jpg
	mkdir thumb

n3: .PHONY
	rm -rf n3
	mkdir n3
	pdfimages Sheets_Letter.pdf n3/marker
	./doconversion.pl n3 jpg

hsn3: .PHONY
	./doconversion.pl hsn3 jpg

killian: .PHONY
	./doconversion.pl killian jpg

vyo: .PHONY
	./doconversion.pl vyo jpg

command: .PHONY
	./doconversion.pl command jpg

grey_camo: .PHONY
	./doconversion.pl grey_camo jpg

holoecho_colors: .PHONY
	./doconversion.pl holoecho_colors jpg

install:
	rm -rf /var/www/inf-dice/markers/jpg/
	rm -rf /var/www/inf-dice/markers/thumb/
	cp -R jpg thumb index.pl annotation.csv /var/www/inf-dice/markers/

beta:
	rm -rf /var/www/inf-dice/markers/beta/jpg/
	rm -rf /var/www/inf-dice/markers/beta/thumb/
	cp -R jpg thumb index.pl annotation.csv /var/www/inf-dice/markers/beta/
