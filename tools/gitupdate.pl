#!/usr/bin/perl
use strict;
use warnings;
use Carp;

#
# Program Name: gitupdate.pl
# Function: Update git repository automatically.
#

our $AUTHOR = "Xiao'ou Zhang";
our $VERSION = "0.1.0";

use Getopt::Std;
$Getopt::Std::STANDARD_HELP_VERSION = 1;

# set essential messages
sub HELP_MESSAGE {
    print <<HELP;
Usage: gitupdate.pl -p <path> [-m <message>]
        -p Pathway of your git repository
        -m Update message (default: Update 'folder name')
Notice: 1. If the argument after '-p' is a folder name, the current working
           directory will be added by default.
        2. If there is no '-m' argument, 'folder name' will be extracted from
           your pathway used for the default message.
        3. More help about git, please see 'git' for more details.
HELP
}
sub VERSION_MESSAGE {
    print <<VERSION;
gitupdate - update git repository automatically
Version: $VERSION, Maintainer: $AUTHOR
VERSION
}
sub help {
    print <<SIMPLE_HELP;
Usage: gitupdate.pl -p <path> [-m <message>]
See 'gitupdate.pl --help' for more details.
SIMPLE_HELP
    exit;
}

# get options and check
my %opts;
getopts('hp:m:', \%opts) or help();
help() if $opts{h} or not %opts or not exists $opts{p};

# check pathway
$opts{p} =~ s/([^\/]$)/$1\//;
-d $opts{p} or croak "Your pathway is wrong! Please check!\n";
-d $opts{p}."/.git/"
    or croak "Your pathway doesn't point to a git repository! Please check!\n";

# check message
unless (exists $opts{m}) {
    $opts{p} =~ /([^\/]+)\/$/;
    $opts{m} = "Update $1";
}

# check git
system("git --version") == 0
    or croak "Can't find 'git'! Please check if it's installed correctly!\n";

# run commands
chdir $opts{p} or croak "Can't open $opts{p}! Please check!\n";
# git add
system("git add . && git add -u") == 0
    or croak "Can't run 'git add'! Please see 'git add -h' for more details!\n";
# git commit
system("git commit -m '$opts{m}'") == 0
    or croak "Can't run 'git commit'! Please see 'git commit -h' for more details!\n";
# git push
system("git push origin master") == 0
    or croak "Can't run 'git push'! Please see 'git push -h' for more details!\n";
