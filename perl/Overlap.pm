#!/usr/bin/perl

package Overlap;

use strict;
use warnings;
use feature "state";

require Exporter;
our @ISA = qw(Exporter);
our @EXPORT_OK = qw(OverlapMax);

##########Subroutine##########

#
# Name: OverlapMax
# Parameter: \@old_array (or \$old_array, when used $flag_of_sorted will be set 1),
#            $seperator (nonword character) (optional),
#            $flag_of_containing_tag (0 or 1) (optional),
#            $flag_of_sorted (0 or 1) (optional)
# Default Values: $seperator = \s, $flag_of_containing_tag = 0, $flag_of_sorted = 0
# Return: @new_array (return the pointer to @new_array in scalar context)
#         $interval (if the first parameter is \$old_array)
#
# Function: Use to extract the max overlaps from this array.
#
# Example: input '2 5', '3 7', '10 16', '12 13', '6 8'
#          output '2 8', '10 16'
#
# Notice:
# 1.When using \$old_array, it will not sort the array again.
# 2.Remember to return the last interval use \$undef_value when use \$old_array.
#
sub OverlapMax {

    # if in void context
    die "OverlapMax can't in void context!\n" unless defined wantarray;

    # initiate internal parameters
    my ($out_sep, $re_sorted_array, @new_array, $is_array, $status);
    state $interval1;

    my $re_old_array = shift; # $re_old_array: \@old_array or \$re_old_array

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

    # check first parameter
    if (ref $re_old_array eq 'ARRAY') {
        $is_array = 1;
    }
    elsif (ref $re_old_array eq 'SCALAR') {
        # if $old_array is undef, return last interval
        unless (defined $$re_old_array) {
            my $tmp = $interval1;
            $interval1 = undef; # clear $interval1 for next usage
            return $tmp;
        }
        $is_array = 0;
        $status = 'uncomplete'; # initiate status
        $re_old_array = [$$re_old_array];
        $flag2 = 1;
    }
    else {
        die "Errors with OverlapMax 1 parameter!";
    }

    unless ($flag2) { # sort @old_array by its first index if not sorted
        $re_sorted_array = _sort($re_old_array, $sep, 1);
    }
    else { # if sorted
        $re_sorted_array = $re_old_array;
    }

    # shift the first interval as the initiate interval if not initiated
    $interval1 = shift @$re_sorted_array unless defined $interval1;
    for my $interval2 (@$re_sorted_array) { # loop if the array is not end
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
            unless ($is_array) { # change status when this interval is closed
                $status = $interval1;
            }
            $interval1 = $interval2;
        }
    }
    unless ($is_array) {
        return $status;
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
    my ($subroutine, $n, $re_old_parameter, $re_value, $re_default) = @_;
    my @new_parameter;
    for (0..$n-1) {
        if (!defined $$re_old_parameter[$_]) { # no parameter, use default instead
            push @new_parameter,$$re_default[$_];
        }
        else {
            push @new_parameter,$$re_old_parameter[$_]; # has parameter, use it
            # check parameter value
            unless ($$re_old_parameter[$_] =~ $$re_value[$_]) {
                my $pos = $_ + 1;
                die "Errors with $subroutine optional parameter $pos \n";
            }
        }
    }
    return @new_parameter;
}

#
# Sort array according to indexes
#
sub _sort {
    my ($re_array, $sep, $flag) = @_;
    my @sorted_array;
    if ($flag == 1) { # sort by the first index
        @sorted_array = sort { (split /$sep/,$a)[0] <=> (split /$sep/,$b)[0] }
                             @$re_array;
    }
    elsif ($flag == 2) { # sort by the first and the second indexes
        @sorted_array = sort { (split /$sep/,$a)[0] <=> (split /$sep/,$b)[0] or
                               (split /$sep/,$a)[1] <=> (split /$sep/,$b)[1] }
                             @$re_array;
    }
    else { # the flag is wrong
        die "Errors occure when sorting!\n";
    }
    return \@sorted_array;
}

1;
