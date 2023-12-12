#!/bin/bash

# Checksum creator for log files
# By Ed ODonnell
# Release : 2023-12-11
#


# Lets see where we were run from :
script_name=$0
app=$(basename "$0")

# What do we want to do ?
command=""

help="$app : The checksum creator for log files
  usage -

    $app filename                                     Create a checksum of the file
    $app --append filename                            Create the checksum and add it to the end of the file
    $app filename >> filename                         Same as above (make sure you use double >>)
    $app --test \"2023-12-11 20:30:40\" filename        Logs for that line and tests up to there

"



# DEBUG="TRUE"

# And lets start looking for commands 
POSITIONAL=()
while [[ $# -gt 0 ]]
do
        key="$1"

        case $key in
                --help|-help|-h)
                        echo "$help"
                        exit 0
                ;;
		--append|-append|-a)
                        command="append"
                        shift # past parameter
                ;;
		--test|-test|-t)
                        command="test"
                        shift # past parameter
			teststr="$1"
                        shift # past parameter
                ;;
                *)
                        filename="$1" 
                        shift # past parameter
                ;;
        esac
done
set -- "${POSITIONAL[@]}" # restore positional parameters

if [ -z "$filename" ] ; then
	echo "$help"
else

	if [ -z "$command" ] ; then
		if [ "$DEBUG" == "TRUE" ] ; then echo "Filename = $filename" ; fi

		now=`date '+%Y-%m-%d %H:%M:%S'`
		checksumstr=`sha256sum "$filename"`
		checksum=`echo "$checksumstr" | awk '{print $1}'`
	
		str="[$now] Checksum $checksum"
		echo "$str"
	elif [ "$command" == "append" ] ; then
		echo "$str" >> $filename
	elif [ "$command" == "test" ] ; then
		echo "Does this ==>"
		grep "$teststr" "$filename"
		echo "Match this ==>"
		sed -n "/\[$teststr\]/!p;//q" "$filename" | sha256sum
	fi
fi


