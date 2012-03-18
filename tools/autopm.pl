#!/usr/bin/perl
use strict;
use warnings;
use Cwd;

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

# check and set version and author
$opts{v} = '0.1.0' unless exists $opts{v} and $opts{v} ne ''; # set version
if ($opts{v} !~ /\d\.\d\.\d/) { # check version
    $opts{v} = '0.1.0';
}
$opts{a} = $ENV{USER} unless exists $opts{a} and $opts{a} ne ''; # set author
$opts{a} = '' unless defined $opts{a}; # if no $ENV{USER}

# set and check pathway
$opts{p} = getpwd() unless exists $opts{p} and $opts{p} ne '';
-d $opts{p} and -w $opts{p}
    or die "Your pathway is wrong or no write permission! Please check!\n";
$opts{p} =~ s/([^\/]$)/$1\//;

# write module template
open my $f,">","$opts{p}$opts{n}.pm" or die "Can't creat $opts{p}$opts{n}.pm!\n";
writeheader(); # write header
print $f "##########Subroutine##########\n\n";
if ($opts{f}) { # write function
    writefunction($_) for split /,/,$opts{f};
}
print $f "##########Internal Subroutine##########\n\n";
if ($opts{i}) { # write internal function
    writeinternalfunction($_) for split /,/,$opts{i};
}
print $f "1;";
close $f;

##########Subroutine##########

#
# Function: Interactive mode.
#
sub interactive {
    while (1) { # input module name
        print "Please input module name:\n";
        chomp($opts{n} = <STDIN>);
        last if $opts{n} ne '';
        print "Module name can't be absent!\n"
    }
    while (1) { # input module pathway
        print "Please input module pathway:\n";
        chomp($opts{p} = <STDIN>);
        $opts{p} = getcwd() if $opts{p} eq '';
        if (-d $opts{p} and -w $opts{p}) {
            last;
        }
        print "Your pathway is wrong or no write permission!\n";
    }
    # input module version
    print "Please input module version:\n";
    chomp($opts{v} = <STDIN>);
    # input module author
    print "Please input module author:\n";
    chomp($opts{a} = <STDIN>);
    # input module function names
    print "Please input module function names (seperated by commas):\n";
    chomp($opts{f} = <STDIN>);
    # input module internal function names
    print "Please input module internal function names (seperated by commas):\n";
    chomp($opts{i} = <STDIN>);
}

#
# Function: Header template.
#
sub writeheader {
    my $fn = ''; # function name
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

#
# Function: Function template.
#
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

#
# Function: Internal function template.
#
sub writeinternalfunction {
    print $f <<INTERNAL_FUNCTION;
#
# Function:
#
sub _$_[0] {

}

INTERNAL_FUNCTION
}
