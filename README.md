# Infinity Marker Sheet Creator

A web app that creates printable custom marker sheets for the tabletop game Infinity

Infinity the Game is Copyright Corvus Belli SLL.  All images unless otherwise noted are copyright Corvus Belli SLL and are used with permission.

## Image copyrights and credits

Images contributed by other sources:

* N4 token set created by Lawson Deming (found in lawson/)

## Usage instructions

If you just want to create a marker sheet, this app is available at http://infinity.ghostlords.com/markers/n4/

Should that site go down, a new copy may be installed by following these steps:

1. Clone this repository to a local directory.
2. Install the required tools: pdfimages, wget, ImageMagick
3. Install the required Perl modules: CGI, PDF::API2, Data::Dumper, Image::Size
4. Run `make` to extract, resize, and convert all images.
5. run `make install` to copy `index.pl`, `png/`, and `thumb/` to your web server's directory.
6. Ensure that you have execute permissions for Perl scripts.  Apache's mod_perl is not required or used.
