#!/usr/bin/perl
use strict;
use warnings;
use Carp;
use Cwd;

#
# Program Name: autopl.pl
# Function: Creat perl file with simple options automatically.
#

our $AUTHOR = "Xiao'ou Zhang";
our $VERSION = "0.4.0";

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
my $p_ref;
if ($opts{h}) {
    help();
}
unless (%opts) {
    $p_ref = interactive();
}

# check and set version and author
$opts{v} = '0.1.0' if $opts{v} eq ''; # set version
if ($opts{v} !~ /\d\.\d\.\d/) { # check version
    $opts{v} = '0.1.0';
}
$opts{a} = $ENV{USER} if $opts{a} eq ''; # set author
$opts{a} = '' if not defined $opts{a}; # if no $ENV{USER}

# modify pathway
$opts{p} =~ s/([^\/]$)/$1\//;

open my $f,">","$opts{p}$opts{n}.pl" or croak "Can't creat $opts{p}$opts{n}.pl!\n";
writefile($p_ref); # write file
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
        $opts{p} = getcwd() if $opts{p} eq '';
        if (-d $opts{p} and -w $opts{p}) {
            last;
        }
        print "Your pathway is wrong or no write permission!\n";
    }
    # input description
    print "Please input the description:\n";
    chomp($opts{i} = <STDIN>);
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
        if ($opts{o} =~ /^([a-zA-Z]:?)*$/) {
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
    ($opts{p1}, $opts{p2}) = ('', '');
    $opts{o} =~ s/([^:]$)/$1\$/;
    for (split /:/,$opts{o}) {
        if (length($_) > 1) {
            $opts{p2} .= substr $_,-1,1,'';
            $opts{p1} .= $_;
        }
        else {
            $opts{p2} .= $_;
        }
    }
    # record parameters
    $p{$_} = 0 for split //,$opts{p1};
    $p{$_} = 1 for split //,$opts{p2};
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
            else {
                $p{$_} = 1 for map {/^(.)=>/; $1} split /,/,$opts{d};
            }
            last;
        }
        print "Your input format wrong!\n";
    }
    if (scalar keys %p) {
        print "Please input the description for each parameter:\n";
        for (keys %p) {
            next if /:/;
            next if $p{$_} == 0;
            print "$_: ";
            chomp($p{$_} = <STDIN>);
        }
    }
    print "If you want the log and error file? (1: yes, 0: no)\n";
    chomp($opts{l} = <STDIN>);
    return \%p;
}

#
# Function: Write file.
#
sub writefile {
    my $p_ref = shift;
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
    $usage_p .= "-$_ <$p_ref->{$_}> " for (split /:/,$opts{e});
    $usage_p .= "[-$opts{p1}] " if $opts{p1} ne '';
    for (split //,$opts{p2}) {
        $usage_p .= "[-$_ <$p_ref->{$_}>] " unless /\$/;
    }
    $usage_p .= "[-$_ <$p_ref->{$_}>] " for keys %default_p;
    # sub parameter
    my $sub_p = '';
    $sub_p .= "$_ " for (split /:/,$opts{e});
    my ($log, $logend) = ('', '');
    if ($opts{l}) {
        $log = <<LOG;
# set log and error file
open STDOUT,'>',"log";
open STDERR,'>',"error";

# record command and starting time
my \$command;
while (my (\$key, \$value) = each %opts) {
    \$command .= " -\$key \$value";
}
print "Command: \$0\$command\\n";
print 'Program starts at ', scalar(localtime(time)), "\\n";
LOG
        $logend = <<LOGEND;
# delete error file if no errors
unlink "error" if -z "error";

# record ending time
print 'Program ends at ', scalar(localtime(time)), "\\n";
LOGEND
    }
    print $f <<HEADER;
#!/usr/bin/perl
use strict;
use warnings;
use Carp;

#
# Program Name: $opts{n}.pl
# Function: $opts{i}
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
$opts{n} - $opts{i}
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

$log
$logend
HEADER
    print $f <<BODY;
##########Subroutine##########

#
# Function: Check essential parameters.
#
sub exist_essential_parameter {
    my \@essential_parameter = qw( $sub_p);
    exists \$opts{\$_} || return 0 for \@essential_parameter;
    return 1;
}
BODY
}
