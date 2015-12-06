#!/usr/bin/perl

use constant VERBOSE => 1;
use constant PROMPT => 1;

my ($op, $glob) = marshall_params();
print_params() if (VERBOSE);
rename_files();

sub rename_files {
	my @files = glob($glob);
	for (@files) {
		my $was = $_;
		eval $op;
		die $@ if $@;
		rename_file($was, $_) unless $was eq $_;
	}
}

sub rename_file {
	my ($old, $new) = @_;
	if (PROMPT) {
		rename($old, $new) if (prompt_choice("rename $old to $new"));
	} else {
		print "renaming $old -> $new..." if (VERBOSE);
		rename($old, $new);
		print "ok\n" if (VERBOSE);
	}
}
	
sub marshall_params {
	my $op;
	my $glob;
	
	if (defined $ARGV[0]) {
		$op = $ARGV[0];
	} else {
		$op = prompt_enter("enter op", "s///");
	}
	
	if (defined $ARGV[1]) {
		$glob = $ARGV[1];
	} else {
		$glob = prompt_enter("enter glob", "*.*");
	}

	return ($op, $glob);
}

sub prompt_choice {
	my ($q) = shift;
	while (1) {
		print("\n$q ? [y]/n/q: ");
		my $r = <STDIN>;
		chomp($r);
		if (! length($r) || ($r =~ /y/i)) {
			return 1;
		} elsif ($r =~ /n/i) {
			return 0;
		} elsif ($r =~ /q/i) {
			print("\nbye");
			exit(1);
		}
	}
}

sub print_params {
	print "op = $op\n";
	print "glob = $glob\n";
}

sub dir_exists {
	$_ = shift; 
	(length && -e && -d) ? return 1 : return 0;
}

sub prompt_enter {
	my ($q, $a) = @_;
	my $r = '';
	while (! $r) {
		printf qq{%s [%s]: }, $q, $a;
		$r = <STDIN>;
		chomp($r);
		$r = length($r) ? $r : $a;
	}
	return $r;
}
