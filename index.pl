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
<style> 
.markers {
    display: flex;
    flex-wrap: wrap;
}

.group {
    margin: 10px;
}
</style>
</head>
<body>
EOF

    print "<h1>Infinity Marker Sheet Creator</h1>\n";
    print <<EOF;
<p>
Create a custom marker sheet by selecting the number and size of each
kind of marker you want, along with the size of paper.
When you submit, a PDF will be generated and downloaded.
</p>
<p>
For each kind of marker, an appropriate set of size choices are available.
Markers not marked "Hi Res" may look slightly blurry if they are being scaled
up, but should still look decent when printed.
Additional sizes for markers may be added upon request.
</p>
EOF
    print "<form method='post'>\n";
    print "<h2>Paper Size</h2>\n";
    print "<select name='paper'>\n";
    print "<option value='Letter' selected>Letter</option>\n";
    print "<option value='A4'>A4</option>\n";
    print "</select>\n";
    print "<h2>Markers</h2>\n";
    print "<div class='markers'>\n";
    my $category = "";

    for my $marker (@$annotations){
        if($category ne $marker->{category}){
            if($category ne ""){
                print "</table>\n";
                print "</div>\n";
            }

            $category = $marker->{category};

            print "<div class='group'>\n";
            print "<h3>$category</h3>\n";
            print "<table>\n";
            print "<tr><th></th><th>Name</th><th>Size</th><th>Count</th></tr>\n";
        }

        print "<tr>\n";
        my ($width, $height) = imgsize($marker->{thumbfile});
        print "<td><img src='$marker->{thumbfile}' height=$height width=$width></td>\n";
        print "<td>$marker->{name}</td>\n";
        print "<td><select name='$marker->{label}_size'>\n";
        for my $size (@{$marker->{sizes}}){
            my $selected = "";
            if($size == 25){
                $selected = " selected";
            }
            print "<option value='$size'$selected>$size mm</option>\n";
        }
        print "</select></td>\n";
        print "<td> <input type=text name='$marker->{label}' value='0' size=2></td>\n";
        print "</tr>\n";
    }
    print "</table>\n";
    print "</div>\n";
    print "</div>\n";

    print "<input type='hidden' name='action' value='draw'>\n";
    print "<input type='submit'>\n";
    print "</form>\n";

    print "<h2>Copyright Notice</h2>\n";
    print "<p>This tool was created by <a href='http://ghostlords.com/'>Jonathan Polley</a> to help enhance your enjoyment of Infinity the Game.  Please direct any feedback to <a href='mailto:infinity\@ghostlords.com'>infinity\@ghostlords.com</a>. My other Infinity resources may be found <a href='http://infinity.ghostlords.com'>here</a>.</p>\n";
    print "<p><a href='http://infinitythegame.com'>Infinity the Game</a> is &copy; Corvus Belli SLL. All images are property of and &copy; Corvus Belli SLL. The sole intended purpose of this tool is to make play aids for Infinity the Game. </p>\n";
    print "<p>Vectorized faction logos created by Vyo on the forum. Human Sphere and Paradiso icons extracted by Killian (Deep-Green-X).  Round command token created by Jakob Kantor.</p>\n";

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
    my $min_x = 72/4.0;
    my $min_y = 72/4.0;
    my $max_x = $paper->[2] - 72/4.0;
    my $max_y = $paper->[3] - 72/4.0;

    my $x = $min_x;
    my $y = $max_y;
    my $max_height = 0;
    my $pad = 72.0/11;

    my $page = $pdf->new_page('MediaBox' => $paper);
    for my $marker (@$annotations){
        my $num = param($marker->{label});
        if($num){
            my $img = $pdf->image($marker->{imgfile});
            my ($xres, $yres) = imgsize($marker->{imgfile});

            # $size in width, in mm
            # 1 point is 1/72 inch
            # without a $scale, renders at 1:1 pixels:points
            # scale is units of points/pixel
            my $size = param("$marker->{label}_size") // 25;
            my $scale = ($size / 25.4 * 72)/($xres) * 1.04;
            my $scaled_width = $xres * $scale;
            my $scaled_height = $yres * $scale;;

            for(my $i = 0; $i < $num; $i++){
                # if the row is ful, go to next row
                if($x + $scaled_width > $max_x){
                    $y -= $max_height + $pad;
                    $max_height = $scaled_height;
                    $x = $min_x;
                }

                # find the tallest item in the row
                if($scaled_height > $max_height){
                    $max_height = $scaled_height;
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
        my ($id, $name, $mask, $cat, $sizes, $overlay) = split /,/, $line;
        $id =~ s/ /_/g;

        my @label = ("marker", $id);
        push @label, $overlay if $overlay;
        my $label = join("-", @label);

        my $imgfile = "jpg/$label.jpg";
        my $thumbfile = "thumb/$label.jpg";
        my @sizes = split /\//, $sizes;
        push @$annotations, {id => $id, name => $name, imgfile => $imgfile, thumbfile => $thumbfile, sizes => \@sizes, category => $cat, label => $label};
    }
}
