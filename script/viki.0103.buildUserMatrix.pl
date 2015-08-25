#!/usr/bin/env perl

use Modern::Perl '2015';
use experimental qw/signatures postderef/;
use autodie;
use Data::Dumper;
use Getopt::Lucid qw( :all );

my %hash;
my %hash2;
my %userViews;
my $opt = Getopt::Lucid->getopt(
  [Param("genres|g")->default("data/genresList"),
  Param("users|u")->default("data/User_attributes.csv"),
  Param("table|t")->default("out/hiScoreHiFreq_genreInfo.txt"),
  Param("threshold|h")->default("50")
])->validate;

my $genre = readGenre($opt->get_genres);
my $threshold = $opt->get_threshold;
my $length = scalar $genre->@*-1;

open my $matrixFile, "<", $opt->get_table;
while(<$matrixFile>)
{
   chomp;
   my ($user, $genreString, $mv) = (split /\t/);

   my $inner = loopGenre($genreString, $genre, $mv, $user);
   if(exists $hash{$user})
   {
      $hash{$user}->[$_] += $inner->[$_] for 0..$length
   }else
   {
      $hash{$user} = $inner;
   }
}

#Feeding in user details
open my $userDataFile, "<", $opt->get_users;
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

#print header
say join "\t", "user", $genre->@*, "country", "gender";
foreach my $user (keys %hash)
{
    say join "\t", $user, $hash{$user}->@*,$hash2{$user}->{country}, $hash2{$user}->{gender};
}



sub readGenre ($filePath)
{
  open my $input, "<", $filePath;
  my @genre = <$input>;
  chomp @genre;
  return \@genre
}

=pod
 readGenre reads in the genrelist,
 stores and returns genres as an array
=cut

sub loopGenre ($genreString, $genre, $mv, $user){

  my @watchedGenres = split ", ", $genreString;
  my $aLength = scalar keys $genre->@*;
  my @inner                     = (0) x $aLength;
  for my $viewedGenre (@watchedGenres){
     my $i = 0;
     for my $atomGenre ($genre->@*){
        $userViews{$user}->{$atomGenre}++ if $mv >= $threshold;
        $inner[$i] = $mv if $atomGenre eq $viewedGenre;
        $i++;
     }
   }
   return \@inner
}

=pod
  \code{loopGenre} takes the genre string and calculate
=cut

=pod
 =head options
 --table: usr genre string mv_ratio
 =head output
 the out gives the username
=cut
