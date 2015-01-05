#!/usr/bin/perl

use strict;
use warnings;

my $fname = $ARGV[0];
my $dir = $ARGV[1];
open(my $file, '<', $fname);

while(my $line = <$file>){
    chomp $line;
    my ($id, $name, $count, $mask, $size) = split /,/, $line;
    if($mask eq ''){
        next;
    }

    print "Masking $id based on $mask\n";
    system("mv $dir/marker-$id.$dir $dir/orig-marker-$id.$dir");
    system("convert \\( $dir/marker-$mask.$dir -negate \\) $dir/orig-marker-$id.$dir $dir/marker-$mask.$dir -composite $dir/marker-$id.$dir");
}
