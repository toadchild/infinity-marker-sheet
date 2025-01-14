all: clean lawson

.PHONY:

clean:
	rm -rf png thumb
	mkdir png
	mkdir thumb

lawson: .PHONY
	./doconversion.pl lawson png

install:
	rm -rf /var/www/infinity/markers/n5/png/
	rm -rf /var/www/infinity/markers/n5/thumb/
	cp -R png thumb index.pl annotation.csv /var/www/infinity/markers/n5

beta:
	rm -rf /var/www/infinity/markers/n5/beta/png/
	rm -rf /var/www/infinity/markers/n5/beta/thumb/
	cp -R png thumb index.pl annotation.csv /var/www/infinity/markers/n5/beta/
