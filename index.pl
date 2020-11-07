#!/usr/bin/perl

use strict;
use warnings;
use CGI qw/:standard/;
use PDF::API2;
use Data::Dumper;
use Image::Magick;

my $annotations;
read_annotations();

my $action = param("action") // '';
if($action eq "draw"){
    print_page();
}else{
    print_input();
}

sub imgsize {
    my ($img_name) = @_;
    my $img = new Image::Magick;
    $img->Read($img_name);
    return $img->Get("columns", "rows");
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
Additional sizes for markers may be added upon request.
</p>
<p>
This page features redesigned N4 tokens are created by <a href='https://forum.corvusbelli.com/threads/n4-c1-token-design-questions.37936/'>Lawson Deming</a>.
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
            if($size == $marker->{default_size}){
                $selected = " selected";
            }
            print "<option value='$size'$selected>$size mm</option>\n";
        }
        print "<input type='hidden' name='$marker->{label}_default_size' value='$marker->{default_size}'>\n";
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
    print "<p><a href='http://infinitythegame.com'>Infinity the Game</a> is &copy; Corvus Belli SLL. The sole intended purpose of this tool is to make play aids for Infinity the Game. </p>\n";
    print <<EOF;
</body>
</html>
EOF

}

sub print_page{
    print <<EOF;
Content-Type: application/pdf

EOF
    my $pdf = PDF::API2->new();
    $pdf->info(Author => "Jonathan Polley",
               Title => "Infinty Markers",
               Creator => "http://infinity.ghostlords.com/",
               CreationDate => [localtime],
              );
    my $paper_size = param('paper') // 'Letter';
    $pdf->mediabox($paper_size);
    my @bounds = PDF::API2::Util::page_size($paper_size);
    my $min_x = 72/4.0;
    my $min_y = 72/4.0;
    my $max_x = $bounds[2] - 72/4.0;
    my $max_y = $bounds[3] - 72/4.0;

    my $x = $min_x;
    my $y = $max_y;
    my $max_height = 0;
    my $pad = 0.03 * 72.0;

    my $page = $pdf->page();
    for my $marker (@$annotations){
        my $num = param($marker->{label});
        if($num){
            my $img = $pdf->image_png($marker->{imgfile});
            my ($xres, $yres) = imgsize($marker->{imgfile});

            # 1 point is 1/72 inch
            # Tokens by Lawson are 600 DPI
            # without a $scale, renders at 1:1 pixels:points
            # scale is units of points/pixel
            # Resize images based on the default vs. target size in mm
            my $size = param("$marker->{label}_size");
            my $default_size = param("$marker->{label}_default_size");
            my $scale = 72.0 / 600 * $size / $default_size;
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
                    $page = $pdf->page();
                }

                my $gfx = $page->gfx();
                $gfx->image($img, $x, $y - $scaled_height, $scale);
                $x += $scaled_width + $pad;
            }
        }
    }
    print $pdf->stringify();
}

sub read_annotations{
    $annotations = [];

    open(my $data, '<', "annotation.csv");
    while(my $line = <$data>){
        chomp $line;
        next if !$line;
        my ($id, $name, $mask, $cat, $sizes, $default_size, $overlay) = split /,/, $line;
        $id =~ s/ /_/g;
        if(!$default_size){
            $default_size = 25;
        }

        my @label = ("marker", $id);
        push @label, $overlay if $overlay;
        my $label = join("-", @label);

        my $imgfile = "png/$label.png";
        my $thumbfile = "thumb/$label.png";
        my @sizes = split /\//, $sizes;
        push @$annotations, {id => $id, name => $name, imgfile => $imgfile, thumbfile => $thumbfile, sizes => \@sizes, default_size => $default_size, category => $cat, label => $label};
    }
}
