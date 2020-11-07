all: clean lawson

.PHONY:

clean:
	rm -rf png thumb
	mkdir png
	mkdir thumb

lawson: .PHONY
	./doconversion.pl lawson png

install:
	rm -rf /var/www/infinity/markers/n4/png/
	rm -rf /var/www/infinity/markers/n4/thumb/
	cp -R png thumb index.pl annotation.csv /var/www/infinity/markers/n4

beta:
	rm -rf /var/www/infinity/markers/n4/beta/png/
	rm -rf /var/www/infinity/markers/n4/beta/thumb/
	cp -R png thumb index.pl annotation.csv /var/www/infinity/markers/n4/beta/
