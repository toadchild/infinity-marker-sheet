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
    next if !$line;
    my ($id, $name, $section, $category, $sizes, $default_size) = split /,/, $line;

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
        my $label = join("-", @label);

        my $outfile = "$dest/$label.$dest";
        my $thumbfile = "thumb/$label.$dest";

        my $img = new Image::Magick;
        $img->Set(size => '450x450');
        my $status = $img->Read($infile);
        $img->Set(density => "150");
        $img->Set(units => "PixelsPerInch");
        $img->Set(background => "white");

        $img = $img->Flatten();
        $img->Set(alpha => 'Off');

        # trim whitespace
        $img->Set(fuzz => "5%");
        $img->Trim();
        my ($xres, $yres) = $img->Get("columns", "rows");

        # write out the image
        $img->Write($outfile);

        # generate thumbnail
        my $width = 30;
        my $height = $yres * $width / $xres;
        $img->Resize(width => $width, height => $height);
        $img->Write($thumbfile);
    }
}
