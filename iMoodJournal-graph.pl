#!/usr/bin/env perl

use strict;
use warnings;
use Parse::CSV;
use File::BOM qw( open_bom );
use Date::Parse;
use Chart::Gnuplot;
use Statistics::LineFit;
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

my @timestamps;
my @levels;    
while ( my $entry = $journal->fetch ) {
  my $datetime = "$entry->{Date} $entry->{Hour}:$entry->{Minute}";
  my $timestamp = str2time($datetime);
  push( @timestamps, $timestamp );
  push( @levels, $entry->{Level} );
}

# Create the chart object
my $chart = Chart::Gnuplot->new(
  output    => 'mood.png',
  ylabel    => 'Mood Level',
  xlabel    => 'Date / Time',
  bg        => "white",
  timeaxis  => "x",            # declare that x-axis uses time format
  imagesize => '3, 1.7',
  yrange    => [0, 10],
  grid      => "on",
  grid      => {
    color     => "black",
    width     => 1,
    xlines    => 1,
  },
);

# Data set object
my $points = Chart::Gnuplot::DataSet->new(
  xdata     => \@timestamps,
  ydata     => \@levels,
  style     => 'points',
  pointsize => '1.3',
  timefmt   => '%s',      # input time format
);

my $bezier = Chart::Gnuplot::DataSet->new(
  xdata     => \@timestamps,
  ydata     => \@levels,
  style     => 'lines',
  linetype  => 'solid',
  color     => 'blue',
  smooth    => 'bezier',
  width     => '2',
  timefmt   => '%s',      # input time format
);

my $csplines = Chart::Gnuplot::DataSet->new(
  xdata     => \@timestamps,
  ydata     => \@levels,
  style     => 'lines',
  linetype  => 'solid',
  color     => 'green',
  smooth    => 'csplines',
  width     => '2',
  timefmt   => '%s',      # input time format
);

my $lineFit = Statistics::LineFit->new();
$lineFit->setData (\@timestamps, \@levels) or die "Invalid data";
my @predictedYs = $lineFit->predictedYs();
my $fit = Chart::Gnuplot::DataSet->new(
  xdata     => \@timestamps,
  ydata     => \@predictedYs,
  style     => 'lines',
  linetype  => 'solid',
  color     => 'magenta',
  width     => '2',
  timefmt   => '%s',      # input time format
);

# Plot the graph
$chart->plot2d($points, $bezier, $csplines, $fit);