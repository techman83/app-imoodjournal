#!/usr/bin/env perl

use strict;
use warnings;
use Parse::CSV;
use File::BOM qw( open_bom );
use Date::Parse;
use POSIX 'strftime';
use AI::DecisionTree;
use Data::Dumper;

# iMoodJournal.csv starts with a BOM marker.
my $filehandle;
open_bom($filehandle, $ARGV[0], ':utf8'),

my $journal = Parse::CSV->new(
  handle    => $filehandle,
  names     => 1,
  csv_attr  => {
    sep_char            => ',',
    quote_char          => '"',
    binary              => 1,
  },
);

my $dtree = new AI::DecisionTree;

my @timestamps;
my @levels;
my $count = 0; 
my $level =  5; # start at the median, though this may throw off the first result.
while ( my $entry = $journal->fetch ) {
  my $result = 0;
  $result = 1 if $entry->{Level} > $level;
  $level = $entry->{Level};

  my $datetime = "$entry->{Date} $entry->{Hour}:$entry->{Minute}";
  my $timestamp = str2time($datetime);
  #my $dow = strftime('%a', $timestamp);

  # Initial concept attempt
  my $attributes;
  foreach my $key (keys $entry) {
    $attributes->{$key} = $entry->{$key} if ($key ne "Comment" && $key ne "Date" && $key ne "Minute" && $key ne "Hour" && $key ne "Level");
  }

  $dtree->add_instance(
    attributes => $attributes, 
    result  => $result,
  );
  $count++;
  exit 0 if $count > 20;
}

$dtree->train;

my $result = $dtree->get_result
    (attributes => {   => 1,
                         => 1,
                    });
print Dumper($result,$dtree);

