#!/usr/bin/env perl

use Modern::Perl '2015';
use experimental qw/signatures postderef/;
use autodie;
use Data::Dumper;
use Getopt::Lucid qw( :all );


my %hash;
my %hash2;

my $opt = Getopt::Lucid->getopt([Param("genres|g"),Param("users|u"),Param("table|t")])->validate;

my $genre= readGenre($opt->get_genres);
my $aLength = scalar keys $genre->%*;

open my $matrixFile, "<", $opt->get_table;
while(<$matrixFile>){
        chomp;
        my ($user, $genreString, $mv) = (split /\t/);
        my @inner                     = (0) x $aLength;
        my @astring                   = split ", ", $genreString;
        if(exists $hash{$user})
        {
           for my $singleGenre (@astring)
           {
              for my $key (keys $genre->%*)
              {
                $inner[$key eq $singleGenre ? $genre->{$key} : 0] = 1
              }
           }
           @inner = map { $_ * $mv } @inner;
           $hash{$user}->[$_] += $inner[$_] for 0..$aLength-1;
        }else{
           for my $singleGenre (@astring)
           {
              for my $key (keys $genre->%*)
              {
                $inner[$key eq $singleGenre ? $genre->{$key} : 0] = 1
              }
           }
           #say join "", @inner;
           $hash{$user} = \@inner;
        }
}

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
say "## The country", $hash2{1}->{country};
say "## The gender", $hash2{1}->{gender};

foreach my $user (keys %hash)
{
    say join " ", $user, $hash{$user}->@*,$hash2{$user}->{country}, $hash2{$user}->{gender};
}


sub readGenre ($filePath){
  open my $input, "<", $filePath;
  my @genre = <$input>;
  chomp @genre;
  return { map { $genre[$_-1] => $_ } 1..scalar @genre}
}
