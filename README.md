# app-imoodjournal

iMood Journal Data Parser
=========================

Currently just a script that takes the CSV export of iMood Journal and spits out a better chart.

Deps - system
```
sudo apt-get install gnuplot
```

Deps - Perl

```
cpanm Parse::CSV File::BOM Date::Parse Chart::Gnuplot Statistics::LineFit
```

Produce a graph
```
./iMoodJournal-graph.pl iMoodJournal.csv
```
Will output a 'mood.png' in the current dirrectory.


COPYRIGHT AND LICENCE
=====================

Copyright 2016 by Leon Wright techman@cpan.org

Dist::Zilla handles the generation of the license file.

This program is free software; you can redistribute it and/or modify it under the same terms as Perl itself.
