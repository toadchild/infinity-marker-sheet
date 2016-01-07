# Infinity Marker Sheet Creator

## Image copyrights and credits
A web app that creates printable custom marker sheets for the tabletop game Infinity

Infinity the Game is Copyright Corvus Belli SLL.  All images unless otherwise noted are copyright Corvus Belli SLL and are used with permission.

Images contributed by other sources:

* Alternate command tokens by Jakob Kantor (found in command/)
* Markers from "Human Sphere" and "Campaign: Paradiso" extracted and collected by Killian Mc Keever (found in killian/)
* Vectorized faction logos create by Vyo (found in killian/) Source: http://infinitytheforums.com/forum/topic/25308-3rd-edition-unit-logos-in-vector-format/

## Usage instructions

If you just want to create a marker sheet, this app is available at http://inf-dice.ghostlords.com/markers/

Should that site go down, a new copy may be installed by following these steps:

1. Clone this repository to a local directory.
2. Install the required tools: pdfimages, wget, ImageMagick
3. Install the required Perl modules: CGI, PDF::Create, Data::Dumper, Image::Size
4. Run `make` to extract, resize, and convert all images.
5. run `make install` to copy `index.pl`, `jpg/`, and `thumb/` to your web server's directory.
6. Ensure that you have execute permissions for Perl scripts.  Apache's mod_perl is not required or used.
