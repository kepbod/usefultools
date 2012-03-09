#!/usr/bin/perl
use strict;
use warnings;

#
# Program Name: autopm.pl
# Function: Creat perl module automatically.
#

our $AUTHOR = "Xiao'ou Zhang";
our $VERSION = "0.1.0";

use Getopt::Std;
$Getopt::Std::STANDARD_HELP_VERSION = 1;

# set essential messages
sub HELP_MESSAGE {
    print <<HELP;
Usage: autopm.pl -n <name> [-p <path>] [-v <version>] [-a <author>]
                 [-f <function names>] [-i <internal function names>]
        -n Name of perl module
        -p Pathway of perl module
        -f Function names in perl module
        -i Internal function names in perl module
Notice: 1. If there are no arguments, interactive mode will be turned on
           automatically.
        2. If no '-p' argument or no absolute pathway, the current working
           directory will be added by default.
        3. The '-v' argument should be like 'X.X.X', if not, '0.1.0' will be used
           instead.
        4. If no '-v' argument, '0.1.0' will be used by default.
        5. If no '-a' argument, \$USER will be used by default.
        6. Function names and internal function names should be seperated by commas.
HELP
}
sub VERSION_MESSAGE {
    print <<VERSION;
autopm - creat perl module automatically
Version: $VERSION, Maintainer: $AUTHOR
VERSION
}
sub help {
    print <<SIMPLE_HELP;
Usage: autopm.pl -n <name> [-p <path>] [-v <version>] [-a <author>]
                 [-f <function names>] [-i <internal function names>]
See 'autopm.pl --help' for more details.
SIMPLE_HELP
    exit;
}

# get options and check
my %opts;
getopts('hn:p:v:a:f:i:', \%opts) or help();
unless (%opts) { # no arguments, turn on interactive mode
    interactive();
}
elsif ($opts{h} or not exists $opts{n}) {
    help();
}

$opts{v} = '0.1.0' unless exists $opts{v} and $opts{v} ne ''; # set version
if ($opts{v} !~ /\d\.\d\.\d/) { # check version
    $opts{v} = '0.1.0';
}
$opts{a} = $ENV{USER} unless exists $opts{a} and $opts{a} ne ''; # set author

# set and check pathway
$opts{p} =`pwd` unless exists $opts{p} and $opts{p} ne '';
-d $opts{p} and -w $opts{p}
    or die "Your pathway is wrong or no write permission! Please check!\n";
$opts{p} =~ s/([^\/]$)/$1\//;

# write module template
open my $f,">","$opts{p}$opts{n}.pm" or die "Can't creat perl module file!\n";
writeheader();
print $f "##########Subroutine##########\n\n";
if ($opts{f}) {
    writefunction($_) for split /,/,$opts{f};
}
print $f "##########Internal Subroutine##########\n\n";
if ($opts{i}) {
    writeinternalfunction($_) for split /,/,$opts{i};
}
print $f "1;";

##########Subroutine##########

# interactive mode
sub interactive {
    while (1) {
        print "Please input module name:\n";
        chomp($opts{n} = <STDIN>);
        last if $opts{n} ne '';
        print "Module cann't be absent!\n"
    }
    while (1) {
        print "Please input module pathway:\n";
        chomp($opts{p} = <STDIN>);
        chomp($opts{p} = `pwd`) if $opts{p} eq '';
        if (-d $opts{p} and -w $opts{p}) {
            last;
        }
        print "Your pathway is wrong or no write permission!\n";
    }
    print "Please input module version:\n";
    chomp($opts{v} = <STDIN>);
    print "Please input module author:\n";
    chomp($opts{a} = <STDIN>);
    print "Please input module function names (seperated by commas):\n";
    chomp($opts{f} = <STDIN>);
    print "Please input module internal function names (seperated by commas):\n";
    chomp($opts{i} = <STDIN>);
}

# header template
sub writeheader {
    my $fn = '';
    $fn = join " ",(split /,/,$opts{f}) if $opts{f};
    print $f <<HEADER;
#!/usr/bin/perl
use strict;
use warnings;

#
# Module Name: $opts{n}.pm
# Function:
#

package $opts{n};

our \$AUTHOR = "$opts{a}";
our \$VERSION = "$opts{v}";

require Exporter;
our \@ISA = qw(Exporter);
our \@EXPORT_OK = qw($fn);

HEADER
}

# function template
sub writefunction {
    print $f <<FUNCTION;
#
# Name: $_[0]
# Parameter:
# Default Values:
# Return:
#
# Function:
#
# Example:
#
# Notice:
#
sub $_[0] {

}

FUNCTION
}

# internal function template
sub writeinternalfunction {
    print $f <<INTERNAL_FUNCTION;
#
# Function:
#
sub _$_[0] {

}

INTERNAL_FUNCTION
}
