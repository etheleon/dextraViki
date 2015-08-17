#!/usr/bin/env perl

use Modern::Perl '2015';
use experimental qw/signatures postderef/;
use Data::Dumper;
my %hash;

while(<>){
    chomp;
    unless($. == 1){
        my ($vid,$user, undef, $string) =  (split /\t/);
        my @astring = split "", $string;
        my $len = scalar @astring - 1;
        if(exists $hash{$user})
        {
            map { $hash{$user}[$_] += $astring[$_] } 0..$len;
        }else{
            $hash{$user}->@* = @astring;
        }
    }
}

foreach my $user (keys %hash)
{
    say join " ", $user, $hash{$user}->@*
}
