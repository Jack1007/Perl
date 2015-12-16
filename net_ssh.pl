#! /usr/bin/perl
#

use Net::OpenSSH;
use Getopt::Long;
local $username = 'root';
local $password = '';
local $pass_flag = 0;
my ($exe_cmd, $ipfile, @put, @get, $local_file, $remote_file);

while ($pass_flag < 3) {
  system "stty -echo";
  print "Enter password: ";
  $password = <STDIN>;
  system "stty echo";
  if ($password eq "\n") {
    print "\n";
    $pass_flag ++;
  } else {
    print "\n";
    last;
  }
}

GetOptions (
  'e:s' => \$exe_cmd,
#  'p:s' => \$password,
  'u:s' => \$username,
  'f=s' => \$ipfile,
  'put:s{2,}' => \@put,
  'get:s{2,}' => \@get,
);

my $put_args = @put;
my $get_args = @get;

die "No ip files" if (! $ipfile);
if ($exe_cmd &&  @put || $exe_cmd && @get) {
  die "You Can not use both -e and --put|get options";
} elsif ($exe_cmd && !@put && !@get) {
  &send_cmd($exe_cmd, $ipfile);
} elsif (!$exe_cmd && @put && !@get) {
  die "Option --put need more than 2 args: --put local_file remote_file" if ($put_args < 2);
  $local_file = $put[0];
  $remote_file = $put[$#put];
  &put_files($local_file, $remote_file);
} elsif (!$exe_cmd && @get && !@put) {
  die "Option --get need more than 2 args: --get remote_file local_file" if ($get_args < 2);
  $remote_file = $get[0];
  $local_file = $get[$#get];
  &get_files($remote_file, $local_file);
} elsif (!$exe_cmd && @put && @get) {
  die "You Can not use both --put and --get options";
} else {
  die "You should use -e option to send cmd or --put|get option to send files";
}

sub send_cmd {
  my $exe_cmd = shift;
  my $ipfile = shift;
  open(my $fh, $ipfile) or die "Can not open $ipfile";
  push(my @cmd, $exe_cmd);
  while (<$fh>) {
    chomp(my $host = $_);
    if ($host =~ /^#/) {;}
    else {
      my $ssh = Net::OpenSSH -> new($host, user=>$username, password=>$password, master_opts => [-o => "StrictHostKeyChecking=no"]);
      #$ssh -> error and die "Can not ssh to $host:". $ssh -> error;
      $ssh -> error and print "Can not ssh to $host:". $ssh -> error and next;
      system "echo -e '\033[0;31;1m########## $host ############\033[0m'";
      for my $value ( @cmd) {
        $ssh -> system($value) and \
	system "echo -e '\033[0;32;1m >>> $value seccessed! \033[0m'" or \
	system "echo -e '\033[0;33;1m >>> $value failed! \033[0m'";
	#my $out_flag = @out;
	#if ($out_flag) {print "$value seccessed!!\n"}
	#else {die "exec cmd failed"}
      }
    }
  }
  close($fh);
}

sub put_files {
  my $local_file = shift;
  my $remote_file = shift;
  open(my $fh, $ipfile) or die "Can not open $ipfile";
  while (<$fh>) {
    chomp(my $host = $_);
    if ($host =~ /^#/) {;}
    else {
      my $ssh = Net::OpenSSH -> new($host, user=>$username, password=>$password, master_opts => [-o => "StrictHostKeyChecking=no"]);
      $ssh -> error and die "Can not ssh to $host:" . $ssh -> error;
      system "echo -e '\033[0;31;1m########## $host ############\033[0m'";
      my $flag_scp = $ssh->scp_put({glob => 1}, $local_file, $remote_file);
      if ($flag_scp) { system "echo -e '\033[0;32;1m $local_file ---> $host:$remote_file successed!!\033[0m'";}
      else {system "echo -e '\033[0;33;1m $local_file ---> $host:$remote_file failed!!\033[0m'";}
    }
  }
  close($fh);
}

sub get_files {
  my $remote_file = shift;
  my $local_file = shift;
  open(my $fh, $ipfile) or die "Can not open $ipfile";
  while (<$fh>) {
    chomp(my $host = $_);
    if ($host =~ /^#/) {;}
    else {
      my $ssh = Net::OpenSSH -> new($host, user=>$username, password=>$password, master_opts => [-o => "StrictHostKeyChecking=no"]);
      $ssh -> error and die "Can not ssh to $host:" . $ssh -> error;
      system "echo -e '\033[0;31;1m########## $host ############\033[0m'";
      my $flag_scp = $ssh->scp_get({glob => 1}, $remote_file, $local_file);
      if ($flag_scp) { system "echo -e '\033[0;32;1m $host:$remote_file ---> $local_file successed!!\033[0m'";}
      else {system "echo -e '\033[0;33;1m $host:$remote_file ---> $local_file failed!!\033[0m'";}
    }
  }
  close($fh);
}
