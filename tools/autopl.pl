#!/usr/bin/perl
use strict;
use warnings;

#
# Program Name: autopl.pl
# Function: Creat perl file with simple options automatically.
#

our $AUTHOR = "Xiao'ou Zhang";
our $VERSION = "0.1.0";

use Getopt::Std;
$Getopt::Std::STANDARD_HELP_VERSION = 1;

# set essential messages
sub HELP_MESSAGE {
    print <<HELP;
Usage: autopm.pl
Notice: 1. When start it, it will enter interactive mode automatically.
        2. In interactive mode, if no pathway or no version or in author
           information, the current working directory, '0.1.0' and \$USER will be
           used by default.
HELP
}
sub VERSION_MESSAGE {
    print <<VERSION;
autopl - creat perl file with simple arguments automatically
Version: $VERSION, Maintainer: $AUTHOR
VERSION
}
sub help {
    print <<SIMPLE_HELP;
Usage: autopl.pl
See 'autopl.pl --help' for more details.
SIMPLE_HELP
    exit;
}

# get options and check
my %opts;
getopts('h', \%opts) or help();
if ($opts{h}) {
    help();
}
unless (%opts) {
    interactive();
}

# check and set version and author
$opts{v} = '0.1.0' if $opts{v} eq ''; # set version
if ($opts{v} !~ /\d\.\d\.\d/) { # check version
    $opts{v} = '0.1.0';
}
$opts{a} = $ENV{USER} if $opts{a} eq ''; # set author
$opts{a} = '' unless defined $opts{a}; # if no $ENV{USER}

# modify pathway
$opts{p} =~ s/([^\/]$)/$1\//;

open my $f,">","$opts{p}$opts{n}.pl" or die "Can't creat $opts{p}$opts{n}.pl!\n";
writefile(); # write file
close $f;

##########Subroutine##########

#
# Function: Interactive mode.
#
sub interactive {
    my %p; # used to check reduplicative parameters
    while (1) { # input file name
        print "Please input perl file name:\n";
        chomp($opts{n} = <STDIN>);
        last if $opts{n} ne '';
        print "Perl file name can't be absent!\n"
    }
    while (1) { # input file pathway
        print "Please input perl file pathway:\n";
        chomp($opts{p} = <STDIN>);
        chomp($opts{p} = `pwd`) if $opts{p} eq '';
        if (-d $opts{p} and -w $opts{p}) {
            last;
        }
        print "Your pathway is wrong or no write permission!\n";
    }
    # input version
    print "Please input perl file version (e.g. X.X.X):\n";
    chomp($opts{v} = <STDIN>);
    # input author
    print "Please input perl file author:\n";
    chomp($opts{a} = <STDIN>);
    while (1) { # input essential arguments
        print "Please input perl file essntial arguments (e.g. a:b:):\n";
        chomp($opts{e} = <STDIN>);
        last if $opts{e} =~ /^([a-zA-Z]:)*$/;
        print "Your input format wrong!\n";
    }
    %p = map {$_=>1} (split //,$opts{e}); # record parameters
    while (1) { # input optional arguments
        print "Please input perl file optional arguments without default values (e.g. ab:):\n";
        chomp($opts{o} = <STDIN>);
        if ($opts{o} =~ /^([a-zA-Z]|[a-zA-Z]:)*$/) {
            my $reduplicative_flag = 0;
            for (split //,$opts{o}) {
                if ($_ ne ':' and exists $p{$_}) { # parameter reduplicative
                    $reduplicative_flag = 1;
                    last;
                }
            }
            if ($reduplicative_flag) {
                print "Your arguments are reduplicative!\n";
                next;
            }
            last;
        }
        print "Your input format wrong!\n";
    }
    $p{$_} = 1 for split //,$opts{o}; # record parameters
    while (1) { # input optional arguments
        print "Please input perl file optional arguments with default vlaues (e.g. a=>'zxo',b=>'abc'):\n";
        chomp($opts{d} = <STDIN>);
        my $wrong_flag = 0;
        for (split /,/,$opts{d}) {
            unless (/[a-zA-Z]=>'.+'/) {
                $wrong_flag = 1;
                last;
            }
        }
        unless ($wrong_flag) {
            my $reduplicative_flag = 0;
            for (split /,/,$opts{d}) {
                /^(.)=>/;
                if (exists $p{$1}) { # parameter reduplicative
                    $reduplicative_flag = 1;
                    last;
                }
            }
            if ($reduplicative_flag) {
                print "Your arguments are reduplicative!\n";
                next;
            }
            last;
        }
        print "Your input format wrong!\n";
    }
}

#
# Function: Write file.
#
sub writefile {
    # parameters with defaults
    my %default_p;
    for (split /,/,$opts{d}) {
        /(.)=>'(.*)'/;
        $default_p{$1} = $2;
    }
    # parameters
    my $p = 'h'.$opts{e}.$opts{o};
    $p .= $_.':' for keys %default_p;
    # defaults
    my $default = '';
    $default .= "$_, " for (split /,/,$opts{d});
    # usage parameters
    my $usage_p = '';
    $usage_p .= "-$_ <> " for (split /:/,$opts{e});
    my ($p1, $p2, $o) = ('', '', $opts{o});
    $o =~ s/([^:]$)/$1\$/;
    for (split /:/,$o) {
        if (length($_) > 1) {
            $p2 .= substr $_,-1,1,'';
            $p1 .= $_;
        }
        else {
            $p2 .= $_;
        }
    }
    $usage_p .= "[-$p1] ";
    for (split //,$p2) {
        $usage_p .= "[-$_ <>] " unless /\$/;
    }
    $usage_p .= "[-$_ <>] " for keys %default_p;
    # sub parameter
    my $sub_p = '';
    $sub_p .= "$_ " for (split /:/,$opts{e});
    print $f <<HEADER;
#!/usr/bin/perl
use strict;
use warnings;

#
# Program Name: $opts{n}.pl
# Function:
#

our \$AUTHOR = "$opts{a}";
our \$VERSION = "$opts{v}";

use Getopt::Std;
\$Getopt::Std::STANDARD_HELP_VERSION = 1;

# set essential messages
sub HELP_MESSAGE {
    print <<HELP;
Usage: $opts{n}.pl $usage_p
Notice:
HELP
}
sub VERSION_MESSAGE {
    print <<VERSION;
$opts{n} -
Version: \$VERSION, Maintainer: \$AUTHOR
VERSION
}
sub help {
    print <<SIMPLE_HELP;
Usage: $opts{n}.pl $usage_p
See '$opts{n}.pl --help' for more details.
SIMPLE_HELP
    exit;
}

# get options and check
my \%opts = ( $default);
getopts('$p', \\\%opts) or help();
help() if \$opts{h} or not exist_essential_parameter();

HEADER
    print $f <<BODY;
##########Subroutine##########

#
# Function: Check essential parameters.
#
sub exist_essential_parameter {
    my \@essential_parameter = qw( $sub_p);
    my \$flag = 1;
    for (\@essential_parameter) {
        unless (exists \$opts{\$_}) {
            \$flag = 0;
            last;
        }
    }
    return \$flag;
}
BODY
}
