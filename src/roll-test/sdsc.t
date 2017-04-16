#!/usr/bin/perl -w
# sdsc roll installation test.  Usage:
# sdsc.t [nodetype]
#   where nodetype is one of "Compute", "Dbnode", "Frontend" or "Login"
#   if not specified, the test assumes either Compute or Frontend

use Test::More qw(no_plan);

my $appliance = $#ARGV >= 0 ? $ARGV[0] :
                -d '/export/rocks/install' ? 'Frontend' : 'Compute';
my $installedOnAppliancesPattern = '.';
my $isInstalled = -d '/opt/sdsc';
my $output;

my $TESTFILE = 'tmpsdsc';

if($appliance =~ /$installedOnAppliancesPattern/) {
  ok($isInstalled, 'sdsc installed');
} else {
  ok(! $isInstalled, 'sdsc not installed');
}

SKIP: {

  skip 'sdsc not installed', 11 if ! $isInstalled;
  ok(-f '/opt/sdsc/devel/Rules.mk', 'devel files installed');
  ok(-f '/etc/profile.d/all-sdsc.sh', '/etc/profile files installed');
  SKIP: {
    skip 'no modulefiles installed', 1 if ! -d '/opt/modulefiles';
    $output = `ls /opt/modulefiles`;
    skip 'no modulefiles installed', 1 if $output !~ /[a-z]/;
    like($ENV{MODULEPATH}, qr#/opt/modulefiles/\w+#, '/opt/modulefiles in MODULEPATH');
  }
  like($ENV{PYTHONPATH}, qr#/opt/sdsc/lib#, '/opt/sdsc/lib in PYTHONPATH');
  like($ENV{PATH}, qr#/opt/sdsc/sbin#, '/opt/sdsc/sbin in PATH');
  like($ENV{PATH}, qr#/opt/sdsc/bin#, '/opt/sdsc/bin in PATH');
  is($ENV{SDSCHOME}, '/opt/sdsc', 'SDSCHOME set');
  is($ENV{SDSCDEVEL}, '/opt/sdsc/devel', 'SDSCDEVEL set');

}

`rm -fr $TESTFILE*`;
