#!/usr/bin/env perl 
use warnings;
use strict;
use Daemon::Control;
 
use Cwd qw(abs_path);
 
Daemon::Control->new(
{
name => "Starman",
lsb_start => '$syslog $remote_fs',
lsb_stop => '$syslog',
lsb_sdesc => 'Starman Short',
lsb_desc => 'Starman controls the web sites.',
path => abs_path($0),
 
program => '/usr/local/bin/starman',
program_args => [ '--workers', '10', './bin/app.pl' ],
 
user => 'starman',
group => 'starman',
 
pid_file => 'tmp/starman.pid',
stderr_file => 'tmp/starman.err',
stdout_file => 'tmp/starman.out',
 
fork => 2,
 
}
)->run;
