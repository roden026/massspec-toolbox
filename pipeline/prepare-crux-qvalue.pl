#!/usr/bin/perl -w
use Cwd;
use File::Spec;
use strict;
use warnings;

require $ENV{'MASSSPEC_TOOLBOX_HOME'}.'/pipeline/conf.pl';
my $path_conf = &get_path();

my $dir_current = File::Spec->rel2abs('.');
my $db_name = $path_conf->{'DB_name'};
$db_name =~ s/\.aa$//;
$db_name =~ s/\.fasta$//;
$db_name = $db_name.'.crux-index';

my $file_script = "run-crux-qvalue.sh";

my $current_dir = getcwd();
my %files;
foreach my $file_csm (`ls ./crux/*.csm.gz`) {
  chomp($file_csm);
  #if( $file_csm =~ /([0-9]+_[A-z0-9]+_[0-9])/ ) {
  if( $file_csm =~ /[A-z0-9]+_([A-z0-9]+)_[0-9a-z]/ ) {
    $files{$1}->{$file_csm} = 1;
  }
}

open(SCRIPT,">$file_script");
print SCRIPT "#!/bin/bash\n";
foreach my $sample (sort keys %files) {
  print SCRIPT "echo 'Set-up $sample'\n";
  foreach my $file_csm (keys %{$files{$sample}}) {
    print SCRIPT "cp $file_csm tmp/\n";
  }
  print SCRIPT "gunzip tmp/*\n";

  my $file_qvalue = File::Spec->catfile($dir_current,'crux',
                                      $sample.'.qvalue_sqt');
  print SCRIPT $path_conf->{'crux'}
          ,' compute-q-values --use-index T '
          ,'--sqt-output-file ',$file_qvalue
          ,' tmp ' ,$db_name,"\n";
  print SCRIPT "echo 'Clean-up $sample'\n";
  print SCRIPT "rm -f tmp/*\n";
}
close(SCRIPT);
`chmod 744 $file_script`;
