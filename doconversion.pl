#!/usr/bin/perl

use strict;
use warnings;
use Image::Magick;

# called as
# ./doconversion.pl ppm jpg

my ($src, $dest) = @ARGV;

#

open(my $file, '<', "annotation.csv");

while(my $line = <$file>){
    chomp $line;
    my ($id, $name, $mask, $cat, $sizes, $default_size, $overlay) = split /,/, $line;

    # convert file
    my $infile;
    if($id =~ m/^\d\d\d$/){
        $infile = "$src/marker-$id.ppm";
    }else{
        $infile = "$src/$id.png";
        $id =~ s/ /_/g;
    }

    # Skip files that are not in this directory
    if(-f $infile){
        my @label = ("marker", $id);
        push @label, $overlay if $overlay;
        my $label = join("-", @label);

        my $outfile = "$dest/$label.$dest";
        my $thumbfile = "thumb/$label.$dest";

        my $img = new Image::Magick;
        $img->Set(size => '450x450');
        my $status = $img->Read($infile);
        $img->Set(density => "150");
        $img->Set(units => "PixelsPerInch");
        $img->Set(background => "white");
        my ($xres, $yres) = $img->Get("columns", "rows");
        if($xres > 450){
            my $width = 450;
            my $height = $yres * $width / $xres;
            $img->Resize(width => $width, height => $height);
        }

        $img = $img->Flatten();

        # apply mask
        if($mask){
            print "Masking $id based on $mask\n";
            my $maskfile = "$src/marker-$mask.ppm";
            my $mask = new Image::Magick;
            $mask->Read($maskfile);

            my $base = $mask->Clone();
            $base->Negate();

            $base->Composite(image => $img, mask => $mask);
            $img = $base;
        }

        # trim whitespace
        $img->Set(fuzz => "5%");
        $img->Trim();
        ($xres, $yres) = $img->Get("columns", "rows");

        # apply overlay
        if($overlay){
            print "Overlaying $label with $overlay\n";

            my $overlayfile = "overlay/$overlay.png";
            my $overlay = new Image::Magick;
            $overlay->Read($overlayfile);
            $overlay->Resize(width => $xres, height => $yres);
            $img->Composite(image => $overlay);
        }

        # write out the image
        $img->Write($outfile);

        # generate thumbnail
        my $width = 30;
        my $height = $yres * $width / $xres;
        $img->Resize(width => $width, height => $height);
        $img->Write($thumbfile);
    }
}
