#!/usr/bin/env perl
#Configuration file to store directories and settings
my %CFG = (
    'dir' => {
        'preblast' => {
            'IP'     => 99.32.4.0,
            'user'   => 'aname',
            'pswd'   => 'p4ssw0rd',
            'status' => 'unavailable'
        },

        'blast' => {
            'IP'     => 129.99.10.5
            'user'   => 'guest',
            'pswd'   => 'guest'
            'status' => 'unavailable'
        },

	
        'blast' => {
            'IP'     => 129.99.10.5
            'user'   => 'guest',
            'pswd'   => 'guest'
            'status' => 'unavailable'
        }


    },
    'imeout' => 60,
    'log' => {
        'file'  => '/var/log/my_log.log',
        'level' => 'warn',
    },
    'temp' => 'remove me'
);


my %config;
my @list_of_directories_to_generate = qw(1out blast fasta fasta/split log quartiles);
my @preblast_configuration_files = ('Pfam-A.clans.tsv','clans.conf','clans_sorted.conf');
my @scheduler_job_files = ('');

my $base_dir      = "~/EFI/";
my $scripts_dir   = "$base_dir/scripts";
my $scheduler_dir = "$base_dir/scheduler";
my $config_dir 	  = "$scripts_dir/configuration";
my $qsub_dir      = "$scripts_dir/qsub_scripts";

$config{'directories'} = @directories;
$config{'files'} = @files;i
$config{'general'}{'clan_file'} = "$base_dir/scripts/configuration/clans.conf"
$config{'general'}{'sorted_clans'} = "$base_dir/scripts/ 
