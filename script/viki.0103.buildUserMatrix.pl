#!/usr/bin/env perl

use Modern::Perl '2015';
use experimental qw/signatures postderef/;
use autodie;
use Data::Dumper;
my %hash;
my %hash2;

open my $matrixFile, "<", $ARGV[0];
while(<$matrixFile>){
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


open my $userDataFile, "<", $ARGV[1];
while(<$userDataFile>){
   unless ($. == 1){
      chomp;
      my ($userID, $country, $gender) =  split(/,/);
      $hash2{$userID} =
      {
         country => $country,
         gender  => $gender
      }
   }
}
#say "the country", $hash2{1}->{country};
#say "the gender", $hash2{1}->{gender};

foreach my $user (keys %hash)
{
    say join " ", $user, $hash{$user}->@*,$hash2{$user}->{country}, $hash2{$user}->{gender};
}
