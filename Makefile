all: clean n3 hsn3 killian army6 command grey_camo holoecho_colors audrey_ewing tristan its tunguska

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

army6: .PHONY
	./doconversion.pl army6 jpg

command: .PHONY
	./doconversion.pl command jpg

grey_camo: .PHONY
	./doconversion.pl grey_camo jpg

holoecho_colors: .PHONY
	./doconversion.pl holoecho_colors jpg

audrey_ewing: .PHONY
	./doconversion.pl audrey_ewing jpg

tristan: .PHONY
	./doconversion.pl tristan jpg

its: .PHONY
	./doconversion.pl its jpg

tunguska: .PHONY
	./doconversion.pl tunguska jpg

install:
	rm -rf /var/www/inf-dice/markers/jpg/
	rm -rf /var/www/inf-dice/markers/thumb/
	cp -R jpg thumb index.pl annotation.csv /var/www/inf-dice/markers/

beta:
	rm -rf /var/www/inf-dice/markers/beta/jpg/
	rm -rf /var/www/inf-dice/markers/beta/thumb/
	cp -R jpg thumb index.pl annotation.csv /var/www/inf-dice/markers/beta/
