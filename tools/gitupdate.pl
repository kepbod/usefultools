#!/usr/bin/perl
use strict;
use warnings;

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
        3. If message is splited by white spaces, please use quotation marks to
           indicate them.
        4. More help about git, please see 'git' for more details.
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
See 'gitupdate --help' for more details.
SIMPLE_HELP
    exit;
}

# get options and check
my %opts;
getopts('hp:m:', \%opts) or help;
help if $opts{h} or not %opts or not exists $opts{p};

# check pathway
$opts{p} =~ s/([^\/]$)/$1\//;
-d $opts{p} or print "Your pathway is wrong! Please check!\n" and exit;
-d $opts{p}."/.git/"
    or print "Your pathway doesn't point to a git repository! Please check!\n"
    and exit;

# check message
unless (exists $opts{m}) {
    $opts{p} =~ /([^\/]+)\/$/;
    $opts{m} = "Update $1";
}

# check git
system("git --version") == 0
    or print "Can't find 'git'! Please check if it's installed correctly!\n"
    and exit;

# run commands
my $pwd = `pwd`;
chdir $opts{p} or print "Can't open $opts{p}! Please check!\n" and exit;
system("git add .") == 0
    or print "Can't run 'git add'! Please see 'git add -h' for more details!\n"
    and exit;
system("git commit -a -m '$opts{m}'") == 0
    or print "Can't run 'git commit'! Please see 'git commit -h' for more details!\n"
    and exit;
system("git push origin master") == 0
    or print "Can't run 'git push'! Please see 'git push -h' for more details!\n"
    and exit;
chdir $pwd;
