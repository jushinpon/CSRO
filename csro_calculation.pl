=b
Put all folders you want to get CSRO.dat under this folder
=cut
use warnings;
use strict;
use Cwd;

my $currentPath = getcwd();# dir for all scripts
chdir("..");
my $mainPath = getcwd();# main path of Perl4dpgen dir
chdir("$currentPath");

#########You need to assign the following for your own system
my @DLP_elements = ("Al","Co", "Cr", "Fe", "Ni");#must follow your DLP element order!!!!!
my $csro_cut = 2.7; #rcut for calculating csro. Use OVITO to get the proper value
my $sour = "20240608_tension"; #all folders with cfg files
#########

### making exec input
unlink "./alloy_composition.dat";
open(FH, "> ./alloy_composition.dat") or die $!;

print FH "## you must follow the template below:\n";
print FH @DLP_elements . " #total element types in cfg files\n";
for (@DLP_elements){
    print FH "$_\n";
}

print FH "$csro_cut #rlist for global pairs\n";

for my $i (0 .. $#DLP_elements){
    for my $j ($i .. $#DLP_elements){
        print FH "$csro_cut #rcut of $DLP_elements[$i]-$DLP_elements[$j] pair\n";
    }
}
close(FH);
####end of making input for executable 

my $exe = "/opt/CSRO/csro.x"; #executable path
#my $exe = "./csro.x"; #executable path

my $input4exe = "input.cfg";#input cfg name for executable
my $exe_output = "CSRO.dat";#input cfg name for executable

#`rm -rf $currentPath/temp`;#remove old temp folder first
my @all_folders = `find $currentPath/$sour -mindepth 1 -maxdepth 1 -type d`;
map { s/^\s+|\s+$//g; } @all_folders;
#print "@all_folders\n";

for my $f (@all_folders){
    my @all_cfgs = `find $f -mindepth 1 -maxdepth 1 -type f -name "*.cfg"`;
    map { s/^\s+|\s+$//g; } @all_cfgs;
    for my $cfg (@all_cfgs){        
        my $path = `dirname $cfg`;
        $path =~ s/^\s+|\s+$//g;
        my $filename = `basename $cfg`;
        $filename =~ s/^\s+|\s+$//g;
        my $prefix = $filename;
        $prefix =~ s/\.cfg//g;
        #print "\$prefix: $prefix, \$filename: $filename \n";
        unlink "$currentPath/$input4exe";
        unlink "$currentPath/$exe_output";
        `cp $cfg $currentPath/$input4exe`;
        `$exe`;
        unlink "$path/csro-$prefix.dat";
        `mv $currentPath/$exe_output $path/csro-$prefix.dat`;
    }
}