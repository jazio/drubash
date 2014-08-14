#!/bin/bash
source $HOME/.bash_profile
function exitWithErrorMessage {
    rc=$1
    shift
    echo $@
    exit $rc
}
function usage {
    echo "Usage: $0 <config-name> "
}


master_path=$1
[ -z "${master_path}" ] && usage && exit 50
       
cd  "${master_path}/sites" || exitWithErrorMessage 40 "Unable to chdir to ${master_path}/sites"
php -r 'include("sites.php"); 
foreach($sites as $s) print "$s\n";' 2> /dev/null | sort -u | while read subsite; do
        cd "$subsite" || continue        
		drush fl | grep Enabled | sed '1d' | perl -ple 's,([^ ]) ([^ ]),\1_\2,g'  | awk '{print $2}' >> feature_list.txt
		for line in $(cat feature_list.txt)
		do		   
           drush fr --force --yes "$line"
		done
		rm -f feature_list.txt
        cd  "${master_path}/sites"
done
