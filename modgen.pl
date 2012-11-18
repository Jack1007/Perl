#! /usr/bin/perl

use File::Basename;

sub Usage {
  die "Usage: ", (split(/\//,__FILE__))[-1], " <ip_host_file> <mod_file>";
}

&Usage if ($#ARGV + 1 != 2);

my $ip_host_file = $ARGV[0];
my $mod_file = $ARGV[1];
my @suffixlist = qw(.pl);
my ($name, $path, $suffix) = fileparse($mod_file, @suffixlist);

open(fh_ip, "$ip_host_file") or die "Can not open $ip_host_file: $!";

my $i;
while (<fh_ip>) {
  chomp(my $ip_host_line = $_);
  (my $ip, my $host) = split(/[\s\t+]/, $ip_host_line);
  my $sub_mod_file = $path . $host . '.cfg';
  print "Cteat $sub_mod_file OK!\n";
  open(fh_mod, "$mod_file") or die "Can not open $mod_file: $!";
  open(fh_sub_mod, ">$sub_mod_file") or die "Can not open $sub_mod_file: $!";
  while (<fh_mod>) {
    my $mod_line = $_;
    $mod_line =~ s#\b\d+\.\d+\.\d+\.\d+\b#$ip#;
    print fh_sub_mod $mod_line;
  }
  close(fh_sub_mod);
  close(fh_mod);
  $i++;
}

close(fh_ip);

print "-------Total $i files created. All Done!-------\n\n";
