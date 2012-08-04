#! /opt/perl/bin/perl

$no_file = 0;

foreach $option (@ARGV) {
	my $a = substr($option, 0, 1);
	if ($a eq '-') {
		$argvs .= substr($option,1);
		push @options, $option;
	} else {
		$no_file = 1;
		push @file_name, $option;
	}
}

#print "$argvs\n";

$strlen = 0;
$strlen = length($argvs);
$E = 0;
$n = 0;




@ARGV = @file_name;

sub no_option {
	while ($line = <>) {
	chomp($line);
	print "$line\n";
}
}

sub E_option {
	while ($line = <>) {
		chomp($line);
		print "$line\$\n";
	}
}

sub n_option {
	my $i = 1;
	while ($line = <>) {
		chomp($line);
		$_ = $line;
		s/^/$i\t/;
		print "$_\n";
		$i++;
	}
}

sub En_option {
	my $i = 1;
	while ($line = <>) {
		chomp($line);
		$_ = $line;
		s/^/$i\t/;
		s/$/\$\n/;
		print "$_";
		$i++;
	}
}


for ($j = 0; $j < $strlen; $j++) {
	$opt = substr($argvs, $j, 1);
	if ($opt eq 'E') {
		$E++;
	} elsif ($opt eq 'n') {
		$n++;
	} else {
		print STDERR "ERR:Wrong argv {$opt}\n";
	}
}


if ($E > 0 && $n > 0) {
	&En_option;
} elsif ($E > 0 && $n == 0) {
	&E_option;
} elsif ($E == 0 && $n > 0) {
	&n_option;
} else {
	&no_option;
}
