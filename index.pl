#!/usr/bin/perl

use strict;
use warnings;
use CGI qw/:standard/;
use PDF::Create;
use Data::Dumper;
use Image::Size;

my $annotations;
read_annotations();

my $action = param("action") // '';
if($action eq "draw"){
    print_page();
}else{
    print_input();
}

sub print_input{
    print <<EOF;
Content-Type: text/html; charset=utf-8

<!DOCTYPE HTML>
<html>
<head>
<meta charset="UTF-8">
<title>Infinity Marker Sheet Creator</title>
</head>
<body>
EOF

    print "<h1>Infinity Marker Sheet Creator</h1>\n";
    print "<p>Create a custom marker sheet by selecting the number and size of each kind of marker you want, along with the size of paper.  When you submit, a PDF will be generated and downloaded.  You can scale markers up or down in size, although there may be quality loss if you do.</p>\n";
    print "<form method='post'>\n";
    print "<h2>Paper Size</h2>\n";
    print "<select name='paper'>\n";
    print "<option value='Letter' selected>Letter</option>\n";
    print "<option value='A4'>A4</option>\n";
    print "</select>\n";
    print "<h2>Markers</h2>\n";
    print "<table>\n";
    print "<tr><th></th><th>Name</th><th>Size</th><th>Count</th></tr>\n";
    for my $marker (@$annotations){
        my ($xres, $yres) = imgsize($marker->{imgfile});
        my $width = 30;
        my $height = $yres * $width / $xres;
        print "<tr>\n";
        print "<td><img src='$marker->{imgfile}' height=$height width=$width></td>\n";
        print "<td>$marker->{name}</td>\n";
        print "<td><input type='text' name='$marker->{id}_size' value='$marker->{size}' size=2> mm</td>\n";
        print "<td> <input type=text name='$marker->{id}' value='0' size=2></td>\n";
        print "</tr>\n";
    }
    print "</table>\n";
    print "<input type='hidden' name='action' value='draw'>\n";
    print "<input type='submit'>\n";
    print "</form>\n";

    print "<h2>Copyright Notice</h2>\n";
    print "<p>This tool was created by <a href='http://ghostlords.com/'>Jonathan Polley</a> to help enhance your enjoyment of Infinity the Game.  Please direct any feedback to <a href='mailto:jonathan\@ghostlords.com'>jonathan\@ghostlords.com</a>.</p>\n";
    print "<p><a href='http://infinitythegame.com'>Infinity the Game</a> is &copy; Corvus Belli SLL. All images are property of and &copy; Corvus Belli SLL. The sole intended purpose of this tool is to make play aids for Infinity the Game. </p>\n";

    print <<EOF;
</body>
</html>
EOF

}

sub print_page{
    print <<EOF;
Content-Type: application/pdf

EOF
    my $pdf = PDF::Create->new(filename => "-",
                               Author => "Jonathan Polley",
                               Title => "Infinty Markers",
                               Creator => "http://ghostlords.com/",
                               CreationDate => [localtime],
                              );
    my $paper_size = param('paper') // 'Letter';
    my $paper = $pdf->get_page_size($paper_size);
    my $min_x = 72/2;
    my $min_y = 72/2;
    my $max_x = $paper->[2] - 72/2;
    my $max_y = $paper->[3] - 72/2;

    my $x = $min_x;
    my $y = $max_y;
    my $max_height = 0;
    my $pad = 72.0/10;

    my $page = $pdf->new_page('MediaBox' => $paper);
    for my $marker (@$annotations){
        my $num = param($marker->{id});
        if($num){
            my $img = $pdf->image($marker->{imgfile});
            my ($xres, $yres) = imgsize($marker->{imgfile});

            # $size in width, in mm
            # 1 point is 1/72 inch
            # without a $scale, renders at 1:1 pixels:points
            # scale is units of points/pixel
            my $size = param("$marker->{id}_size") // $marker->{size};
            my $scale = ($size / 25.4 * 72)/($xres);
            my $scaled_width = $xres * $scale;
            my $scaled_height = $yres * $scale;;

            for(my $i = 0; $i < $num; $i++){
                # find the tallest item in the row
                if($scaled_height > $max_height){
                    $max_height = $scaled_height;
                }

                # if the row is ful, go to next row
                if($x + $scaled_width > $max_x){
                    $y -= $max_height + $pad;
                    $max_height = $scaled_height;
                    $x = $min_x;
                }

                # if the page is full, go to next page
                if($y - $scaled_height < $min_y){
                    $y = $max_y;
                    $max_height = $scaled_height;
                    $x = $min_x;
                    $page = $pdf->new_page('MediaBox' => $paper);
                }

                $page->image(image => $img, xpos => $x, ypos => $y, xscale => $scale, yscale => $scale, yalign => 2);
                $x += $scaled_width + $pad;
            }
        }
    }
    $pdf->close();
}

sub read_annotations{
    $annotations = [];

    open(my $data, '<', "annotation.csv");
    while(my $line = <$data>){
        chomp $line;
        my ($id, $name, $count, $mask, $size) = split /,/, $line;
        my $imgfile = "jpg/marker-$id.jpg";
        push @$annotations, {id => $id, name => $name, count => $count, size => $size, imgfile => $imgfile};
    }
}
