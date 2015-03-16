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
    my ($id, $name, $mask, $cat, $sizes, $overlay) = split /,/, $line;

    # convert file
    my $infile;
    my $special = 0;
    if($id =~ m/^\d\d\d$/){
        $infile = "$src/marker-$id.$src";
    }else{
        $infile = "$src/$id.png";
        $id =~ s/ /_/g;
        $special = 1;
    }

    # Skip files that are not in this directory
    if(-f $infile){
        my @label = ("marker", $id);
        push @label, $overlay if $overlay;
        my $label = join("-", @label);

        my $outfile = "$dest/$label.$dest";
        my $thumbfile = "thumb/$label.$dest";

        my $resize = "";
        my ($xres, $yres) = imgsize($infile);
        if($special && $xres > 350){
            my $width = 350;
            my $height = $yres * $width / $xres;
            $resize = "-resize ".$width."x".$height;
        }

        system("convert -density 150 -units PixelsPerInch -background white -flatten $resize '$infile' $outfile");

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
        ($xres, $yres) = imgsize($outfile);

        # apply overlay
        if($overlay){
            print "Overlaying $label with $overlay\n";

            my $overlayfile = "overlay/$overlay.png";
            my $tmpoverlay = "overlay/tmp-$overlay.png";
            my $tmpfile = "$dest/tmp-$label.$dest";

            # Make a copy of the overlay at the correct size
            system("convert -resize ".$xres."x".$yres." $overlayfile $tmpoverlay");
            system("convert $outfile $tmpoverlay -composite $tmpfile");
            system("mv $tmpfile $outfile");
            unlink($tmpoverlay);
        }

        # generate thumbnail
        my $width = 30;
        my $height = $yres * $width / $xres;

        system("convert $outfile -resize $width"."x"."$height $thumbfile");
    }
}
