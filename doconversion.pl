#!/usr/bin/perl

use strict;
use warnings;
use Image::Size;

# called as
# ./doconversion.pl ppm jpg

my ($src, $dest) = @ARGV;

#

open(my $file, '<', "annotation.csv");

while(my $line = <$file>){
    chomp $line;
    my ($id, $name, $count, $mask) = split /,/, $line;

    # convert file
    my $infile = "$src/marker-$id.$src";
    my $outfile = "$dest/marker-$id.$dest";
    my $thumbfile = "thumb/marker-$id.$dest";
    system("convert -density 150 -units PixelsPerInch $infile $outfile");

    # apply mask
    if($mask){
        print "Masking $id based on $mask\n";
        my $maskfile = "$src/marker-$mask.$src";
        my $tmpfile = "$dest/orig-marker-$id.$dest";

        system("mv $outfile $tmpfile");
        system("convert \\( $maskfile -negate \\) $tmpfile $maskfile -composite $outfile");
        unlink($tmpfile);
    }

    # trim whitespace
    system("mogrify -fuzz 5% -trim +repage $outfile");

    # generate thumbnail
    my ($xres, $yres) = imgsize($outfile);
    my $width = 30;
    my $height = $yres * $width / $xres;

    system("convert $outfile -resize $width"."x"."$height $thumbfile");
}
