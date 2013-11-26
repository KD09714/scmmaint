use File::Copy;
use File::Basename qw/dirname/;
use File::Remove qw(remove);
use File::Copy::Recursive qw(fcopy rcopy dircopy fmove rmove dirmove);
use vars qw($password);
do 'c:/scm/tools/codemove.pl';

$CFGDIR="C:/scm/cfg";
$TEMPDIR="c:/scm/log";
$BASEDIR="C:/scm/tools";
$winzip_path="C:/Program Files/WinZip";
$changeman_path="C:/Program Files/Serena/ChangeMan/DS/Client";
$SCMHOST="sams-mal-scmweb";
my $VERSION="2013.1.1";

$project=$ARGV[0];;

##Fetching the freeze information.
$cmd="$BASEDIR/FreezeProject.bat getfreezelist $project > $TEMPDIR/freeze-${project}.txt";
system($cmd);

##Date and Time calculation
my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime(time);
$year += 1900; my @month_abbr = qw( 01 02 03 04 05 06 07 08 09 10 11 12 );
my $DATE1="$year$month_abbr[$mon]$mday"; ## gives 20100221
my $TIME1="$hour$min$sec"; ##20:45:27

$desc="freeze on ${DATE1}-${TIME1}";

##Remove Blank and Unwanted Lines from the file.
open (F1, "$TEMPDIR/freeze-${project}.txt" ) || die "Could not open file freeze-${project}.txt : $!";
	$lastfreeze=<F1>; chomp($lastfreeze);
	@freezeinfo=split(/\|/,$lastfreeze);
	print "Last freeze found to be $freezeinfo[2]";
	$thisfreeze=$freezeinfo[2];
close F1;

##Increment for next freeze.
@freezenumber=split(/\./,$thisfreeze);
$length=@freezenumber;

$nextfreezenumber="$freezenumber[${length}-1]";
$nextfreezenumber=$nextfreezenumber+1;
$i=1; $nextfreeze=$freezenumber[0];

do 
{
	$nextfreeze="${nextfreeze}.$freezenumber[$i]";
	$i=${i}+1;
} while $i<${length}-1;
$nextfreeze="$nextfreeze.$nextfreezenumber";
print "\nNext freeze: $nextfreeze\n";
#GlobalOffice_2.0_122_AC $CFGDIR
open (FREEZE, ">$CFGDIR/${project}.freeze.cfg" ) || die "Could not open file $CFGDIR/${project}.freeze.cfg : $!";
print FREEZE "lastfreeze=$nextfreeze";
close FREEZE;

print "\nFreezing $project ... \n";
$freezecmd="${BASEDIR}/cmnproj -h:${SCMHOST} -af -p:${project} -release:${nextfreeze} -u:codemove -ps:${password} -desc:\"${desc}\" -v > $TEMPDIR/newfreeze-${project}.log 2>&1";
system($freezecmd);

open (LOG, "$TEMPDIR/newfreeze-${project}.log" ) || die "Could not open file newfreeze-${project}.log : $!";
while(defined($line=<LOG>))
{
	print "$line";
	chomp($line); 
	if (($line =~ /Frozen/) && ($line =~ /successfully/)) { $RETURN = "SUCCESS";	}
}
close LOG;
if ( $RETURN eq "SUCCESS" ) {
print "FREEZE-SUCCESS "; }
else { print "FREEZE-FAILURE"};