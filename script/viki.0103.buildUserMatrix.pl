#!/usr/bin/env perl

use Modern::Perl '2015';
use experimental qw/signatures postderef/;
use autodie;
use Data::Dumper;
use Getopt::Lucid qw( :all );

my %hash;
my %hash2;

my $opt = Getopt::Lucid->getopt([
      Param("genres|g")
])->validate;

my @genre = readGenre($opt->get_genres)->@*;
say Dumper @genre;

#open my $matrixFile, "<", $ARGV[0];
#while(<$matrixFile>){
#    chomp;
#    unless($. == 1){
#        my ($user, $string) =  (split /\t/);
#        my @astring = split "|", $string;
#        my $len = scalar @astring - 1;
#        if(exists $hash{$user})
#        {
#            map { $hash{$user}[$_] += $astring[$_] } 0..$len;
#        }else{
#            $hash{$user}->@* = @astring;
#        }
#    }
#}
#
#
#open my $userDataFile, "<", $ARGV[1];
#while(<$userDataFile>){
#   unless ($. == 1){
#      chomp;
#      my ($userID, $country, $gender) =  split(/,/);
#      $hash2{$userID} =
#      {
#         country => $country,
#         gender  => $gender
#      }
#   }
#}
##say "the country", $hash2{1}->{country};
##say "the gender", $hash2{1}->{gender};
#
#foreach my $user (keys %hash)
#{
#    say join " ", $user, $hash{$user}->@*,$hash2{$user}->{country}, $hash2{$user}->{gender};
#}


sub readGenre ($filePath){
  open my $input, "<", $filePath;
  my @genre = <$input>;
  chomp @genre;
  return \@genre;
}
