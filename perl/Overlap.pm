#!/usr/bin/perl

package Overlap;

use strict;
use warnings;

require Exporter;
our @ISA = qw(Exporter);
our @EXPORT_OK = qw(OverlapMax);

##########Subroutine##########

#
# Name: OverlapMax
# Parameter: @old_array, $seperator (nonword character) (optional),
#            $flag_of_containing_tag (0 or 1) (optional),
#            $flag_of_sorted (0 or 1) (optional)
# Default Values: $seperator = \s, $flag_of_containing_tag = 0, $flag_of_sorted = 0
# Return: @new_array (return the pointer to @new_array in scalar context)
#
# Function: Use to extract the max overlaps from this array.
#
# Example: input '2 5', '3 7', '10 16', '12 13', '6 8'
#          output '2 8', '10 16'
#
sub OverlapMax(\@;$$$) {

    # if in void context
    die "OverlapMax can't in void context!\n" unless defined wantarray;

    # initiate internal parameters
    my ($out_sep, $re_sorted_array, @new_array, $interval1);

    my $re_old_array = shift; # $re_old_array: \@old_array

    # check optional parameters
    # $sep: $seperator, $flag1: $flag_of_containing_tag, $flag2: $flag_of_sorted
    my ($sep, $flag1, $flag2) = _parameter_check('OverlapMax', 3, \@_,
                                [qr(\W), qr(0|1), qr(0|1)], ['\s', 0, 0]);

    # set output_seperator
    if ($sep eq '\s') {
        $out_sep = ' ';
    }
    else {
        $out_sep = $sep;
    }


    unless ($flag2) { # sort @old_array by its first index if not sorted
        @$re_sorted_array = sort { (split /$sep/,$a)[0] <=> (split /$sep/,$b)[0] }
                                @$re_old_array;
    }
    else { # if sorted
        $re_sorted_array = $re_old_array;
    }

    # shift the first interval as the initiate interval
    $interval1 = shift @$re_sorted_array;
    for my $interval2 (@$re_sorted_array) { # loop if the array isn't end
        # if $interval1 and $interval2 have overlaps
        if ((split /$sep/,$interval1)[1] >= (split /$sep/,$interval2)[0]) {
            my $tmp = (split /$sep/,$interval1)[1] > (split /$sep/,$interval2)[1] ?
                      (split /$sep/,$interval1)[1] : (split /$sep/,$interval2)[1];
            if ($flag1) { # if has tags
                $interval1 = (split /$sep/,$interval1)[0] . $out_sep . $tmp .
                             $out_sep . (split /$sep/,$interval1,3)[-1] . $out_sep .
                             (split /$sep/,$interval2,3)[-1];
            }
            else { # if not has tags
                $interval1 = (split /$sep/,$interval1)[0] . $out_sep . $tmp;
            }
        }
        else{ # if there are no overlaps between $interval1 and $interval2
            push @new_array,$interval1;
            $interval1 = $interval2;
        }
    }
    push @new_array,$interval1; # push the last interval into @new_array
    # return new array according to context
    return wantarray ? @new_array : \@new_array;
}

##########Internal Subroutine##########

#
# Check parameters imported from outside.
#
sub _parameter_check {
    my ($subroutine, $n, $old_parameter, $type, $default) = @_;
    my @new_parameter;
    for (0..$n-1) {
        if (!defined $$old_parameter[$_]) { # no parameter, use default instead
            push @new_parameter,$$default[$_];
        }
        else {
            push @new_parameter,$$old_parameter[$_]; # has parameter, use it
            # check parameter value
            unless ($$old_parameter[$_] =~ $$type[$_]) {
                my $pos = $_ + 1;
                die "Errors with $subroutine optional parameter $pos \n";
            }
        }
    }
    return @new_parameter;
}

1;
