#!/opt/local/bin/perl

use strict;
use warnings;

use Image::Magick;

for my $src_name (glob("*.svg")){
    my $img = new Image::Magick;
    $img->Set(size => '450x450');
    $img->Set(background=>"white");
    $img->Read($src_name);
    $img->Set(density => 150);
    $img->Set(units => "PixelsPerInch");

    my $dst_name = $src_name;
    $dst_name =~ s/svg$/png/;

    $img->Strip();
    $img->Write($dst_name);
}
