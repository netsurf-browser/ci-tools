#!/usr/bin/perl -w

use strict;

my @repos_in_order = qw(
                          buildsystem
                          libwapcaplet
                          libparserutils
                          libcss
                          libhubbub
                          libdom
                          libnsbmp
                          libnsgif
                          librosprite
                          libnsfb
                          libsvgtiny
                          nsgenjsbind
                          netsurf
                      );

my %repos = (
             buildsystem => "buildsystem",
             libwapcaplet => "libwapcaplet",
             libparserutils => "libparserutils",
             libcss => "libcss",
             libhubbub => "libhubbub",
             libdom => "libdom",
             libnsbmp => "libnsbmp",
             libnsgif => "libnsgif",
             librosprite => "librosprite",
             libnsfb => "libnsfb",
             libsvgtiny => "libsvgtiny",
             nsgenjsbind => "nsgenbind",
             rufl => "librufl",
             libpencil => "libpencil",
             netsurf => "netsurf",
            );

my %vers = ();

foreach my $arg (@ARGV) {
   $arg =~ /^([^=]+)=(.*)$/;
   $vers{$1} = $2;
   print "Memoising $1 = $2\n";
}

# Utility functions

sub repourl {
   my $repo = shift;
   return "git://git.netsurf-browser.org/${repo}.git";
}

sub tarurl {
   my $repo = shift;
   return "http://ci.netsurf-browser.org/builds/sources/$repos{${repo}}-$vers{${repo}}.tar.gz";
}

sub tarfile {
   my $repo = shift;
   return "tars/$repos{${repo}}-$vers{${repo}}.tar.gz";
}

`mkdir -p gits tars`;

# Step 1, acquire the versions of all the repos in order

foreach my $repo (keys %repos) {
  if (defined $vers{$repo}) {
     print "Assuming $repo is at $vers{$repo}\n";
  } else {
     print "Interrogating ${repo}...\n";
     my $url = repourl($repo);
     system("git clone $url gits/$repo") unless (-d "gits/$repo");
     system("cd gits/$repo; git remote update origin");
     my $ver = `cd gits/$repo; git describe --abbrev=0 origin/master`;
     chomp $ver;
     $ver =~ s/^release\///;
     $vers{$repo} = $ver;
     print "Determined $repo is at $vers{$repo}\n";
  }
}

# Step 2, acquire the tarballs

foreach my $repo (keys %repos) {
   next if ($vers{$repo} eq '');
   print "Acquiring tar for $repo\n";
   my $url = tarurl($repo);
   my $file = tarfile($repo);
   system("wget -O $file $url") unless (-r $file);
}

# Step 3, prepare the tar

`rm -rf netsurf-all-$vers{netsurf}`;

`mkdir -p netsurf-all-$vers{netsurf}/src`;

foreach my $repo (keys %repos) {
   next if ($vers{$repo} eq '');
   print "Unpacking $repo\n";
   my $file = tarfile($repo);
   system("cd netsurf-all-$vers{netsurf}/src; tar xzf ../../$file");
}

# Step 4, prepare top level Makefile

open INFILE, "<", "basis.mk";
open OUTFILE, ">", "netsurf-all-$vers{netsurf}/Makefile";

while (my $line = <INFILE>) {
   unless ($line =~ /^###([^#]+)###$/) {
      print OUTFILE $line;
      next;
   }
   my $what = $1;
   if ($what eq 'TARGS') {
      my $libtargs = "";
      foreach my $repo (@repos_in_order) {
         next if ($vers{$repo} eq '');
         my $basis = $repos{$repo};
         my $ver = $vers{$repo};
         $repo =~ y/a-z/A-Z/;
         print OUTFILE "${repo}_BASE := src/$basis\n";
         print OUTFILE "${repo}_VERS := $ver\n";
         print OUTFILE "${repo}_TARG := \$(${repo}_BASE)-\$(${repo}_VERS)\n";
         print OUTFILE "\n";
         unless ($repo eq 'NETSURF') {
            $libtargs .= " \$(${repo}_TARG)";
         }
      }
      print OUTFILE "NSLIBTARG :=$libtargs\n";
      print OUTFILE "\n";
   }
}

close OUTFILE;
close INFILE;

print "Tarring it all up\n";
`tar czf netsurf-all-$vers{netsurf}.tar.gz netsurf-all-$vers{netsurf}`;

