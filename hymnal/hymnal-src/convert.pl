#!/usr/bin/perl
use Encode;

$songDir = 'songs';


sub processSong {
    my $song = shift;
    $song =~ s/<DIV.*?> //g;           # Git rid of the first <DIV>

    # Grab the title and filename
    $song =~ s/<H1.*?>(.*?)<\/H1> //;
    my $title = $1;
    $title =~ s/^ *//;
    my $filename = $title;
    $filename =~ s/[^[:ascii:]]+//g;
    $filename =~ m/^([A-Za-z ,]*)/;
    $filename = $1;
    $filename =~ s/ /_/g;

    $song =~ s/<\/DIV>//g;             # Remove the last </DIV>
    $song =~ s/<P(.*?)>//g;            # Remove <P...> tags
    $song =~ s/<BR>/\n/g;              # Proper \ns in the proper places

    # HTML -> chords
    $song =~ s/<SUP>.*?<B>(.*?)<\/B>.*?<\/SUP>/\\[$1]/g;
    $song =~ s/\[ //g;
    $song =~ s/ \]//g;
    $song =~ s/\[([A-Z]*?)(b)([A-Z1-9m ]*?)\]/\[$1&$3\]/g; # flat symbols -> &s

    $song =~ s/^<.*?> ?// while ($song =~ /^</); # no more leading HTML tags

    # Strip some unneeded HTML tags
    $song =~ s/<.?SPAN(.*?)>// while ($song =~ /<.?SPAN(.*?)>/);
    $song =~ s/<.?FONT(.*?)>// while ($song =~ /<.?FONT(.*?)>/);
    $song =~ s/<.?H1(.*?)>// while ($song =~ /<.?H1(.*?)>/);

    # add chorus breaks
    $song =~ s/<I>/\n\\endverse\n\\beginchorus\n/g;
    $song =~ s/<\/I>/\n\\endchorus\n\\beginverse\n/g;

    # add verse breaks
    $song =~ s/<\/P>/\n\\endverse\n\\beginverse\n/g; # add verse breaks
    $song =~ s/&nbsp;/ /g;             # &nbsp; => ' '

    $song =~ s/<.*?>//g while ($song =~ /<.*?>/); # strip remaining HTML

    # Write output file(s)
    print "Writing: '$title'\n===>in directory: '$filename'\n";
    my $lyricFile = "$songDir/$filename/lyrics.source";
    mkdir("$songDir/$filename");
    open(OUTPUT, ">$songDir/$filename/lyrics.converted");
    print OUTPUT "\\beginverse\n";
    print OUTPUT $song;
    print OUTPUT "\n\\endverse\n";
    close(OUTPUT);
    open(OUTPUT, ">$songDir/$filename/metadata.tex");
    print OUTPUT <<METADATA;
{$title}[
    cr={},
    sr={},
    index={}]
METADATA
    close(OUTPUT);
#    print "\n=============\n"
}


$foundSong = 0;
$song = "";
while (<>) {
    chomp;
    s/\t/ /g;
    s/  / /g while (m/  /);
    $line = decode('ISO-8859-1',$_);

    if (!$foundSong) {
	$foundSong = 1;
	$song = $line;
    } else {
	$song = "$song$line";
	if ($line =~ /<\/DIV>/) {
	    $foundSong = 0;
	    processSong($song);
	    $song = "";
	}
    }
}

