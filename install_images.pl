#!/usr/bin/perl

use strict;
use warnings;
use Image::Size;

# called as
# ./install_images.pl /var/www/inf-dice/markers/
my ($dest) = @ARGV;

system("rm -rf $dest/jpg");
system("mkdir $dest/jpg");
system("rm -rf $dest/thumb");
system("mkdir $dest/thumb");

open(my $data, '<', "annotation.csv");
while(my $line = <$data>){
    chomp $line;
    my ($id, $name, $count, $mask, $size) = split /,/, $line;
    my $imgfile = "marker-$id.jpg";

    system("cp jpg/$imgfile $dest/jpg/$imgfile");

    # construct thumbnail versions
    my ($xres, $yres) = imgsize("jpg/$imgfile");
    my $width = 30;
    my $height = $yres * $width / $xres;

    system("convert jpg/$imgfile -resize $width"."x"."$height $dest/thumb/$imgfile");
}
