#!/bin/bash

#Set this to whereever you have your minecraft jar file
minecraftPath="/etc/minecraft"
#port number for server running minecraft (must be localhost)
minecraftPort=25565

#This updater uses minecraft init scripts to function. 
#Find this script at http://www.minecraftwiki.net/wiki/Tutorials/Server_startup_script
initScript="/etc/init.d/minecraft"
#This is the file we're updating. 
target="minecraft_server.jar"
#Set to 'true' or 'false' for additional information
debugging="false"

currentVersion=
latestVersion=
latestVersionURL=
	

debug() {
	if [[ "$debugging" == "true" ]]
	then
		echo "#DEBUG: $@"
	fi
	return 0
}

sanityCheck() {

	if [ "$minecraftPath" == "" ]
	then
		echo "ERROR: Your minecraft path is not set."
		echo "You should set that in the header of this script."
		return 2
	fi 

	if [ ! -e "$minecraftPath/$target" ]
	then
		echo "WARNING: Could not find the current version of minecraft under the path given: $minecraftPath"
		echo "WARNING: Installing new version of minecraft in $minecraftPath"
		currentVersion="<Not Installed>"
		return 1
	fi

	return 0

}

#Connect to local host on PORT to check the current version. Returns version as string
getCurrentVersion() {
	local dumpFile="dump.bin"
	local dumpFile2="dump2.bin"

	$initScript status | grep "not running" &> /dev/null 
	if [[ $? -eq 0 ]] 
	then
		debug "Local Minecraft Server not running, not able to get version."
		currentVersion=""
		return 1 
	fi

	debug "Getting current version of minecraft from the now-running-server"
	#Send byte code "FE01" to server, and it will give us a byte stream which contains the version
	echo -n -e \\xFE\\x01 | nc localhost $minecraftPort > $dumpFile
	#If this didn't work, give an error and exit.
	if [[ $? -ne 0 ]]
	then
		rm $dumpFile &>/dev/null
		echo "ERROR: Unable to get CURRENT version of minecraft. Either"
		echo "minecraft is not running, or minecraft itself has changed"
		echo "the process by which it leaves versions."
		echo "Ensure minecraft is running here: localhost $minecraftPort"
		return 1
	fi
	#Cut off the beginning of the byte stream we don't care about
	#Use xxd to separate the stream into 2 byte chunks separated by newlines
	cut -b 18- "$dumpFile" | xxd -p -c 2 > $dumpFile2
	local tmp=""
	#build the version number. We are done when we hit the null terminator '0000'
	for each in `cat $dumpFile2`
	do
		local tmp=$tmp$each
		if [ $each == "0000" ]
		then
			break
		fi
	done

	rm $dumpFile $dumpFile2 &>/dev/null	
	#Set current version
	currentVersion=$(echo "$tmp" | xxd -p -r)
	#Tell debugging
	debug "Success! Current version='$currentVersion'"
	return 0

}

scrapeForData() {

	local targetWebsite="http://minecraft.gamepedia.com/Version_history/Development_versions"
	local pageName=$(basename $targetWebsite)
	
	debug "Attempting to get latest version..."	
	#Get the website
	wget -q "$targetWebsite" &> /dev/null
	if [[ $? -ne 0 ]] 
	then
		echo "Failed to scrape website $targetWebsite."
		echo "Website may be down, or has changed."
		exit 1
	fi

	#Latest snapshots are always denoted as "14w06b". FIND THEM!
	#We gather all of them, the last one being the latest version.	
	latestVersion=$(grep -e 'title\=\"[0-9][0-9]w[0-9][0-9].\"' $pageName | sed -e "s/^.*title\=\"//g" | sed -e "s/\".*//g" | sort | tail -n 1)
	
	rm $pageName &> /dev/null
	latestVersionURL="https://s3.amazonaws.com/Minecraft.Download/versions/$latestVersion/minecraft_server.$latestVersion.jar"

	if [[ -z "$latestVersion" ]]
	then
		echo "ERROR: Scrape failure, we couldn't get the current version of minecraft."
		echo "Either the server is currently down, or the scrapper is out of date (more likely)."
		return 1
	else
		debug "Success! Latest version: '$latestVersion'"
		return 0
	fi
}

checkIfUpdateExists() {

getCurrentVersion

if [ -z ""$currentVersion"" ]
then
	debug "Oh noes, we couldn't get the current version"
	return 2
fi

if [ $currentVersion == $latestVersion ] 
then
	debug "We are up to date!"
	return 0
else
	debug "I have detected $currentVersion < $latestVersion"
	return 1
fi

}

updateMinecraft() {
	
	if [ "$minecraftPath" == "" ]
	then
		echo "ERROR: Your minecraft path is not set."
		echo "You should set that in the header of this script."
		return 1
	fi 

	echo "NOTICE: Updating Minecraft from $currentVersion to $latestVersion"
	$initScript status | grep "not running" &> /dev/null 
	if [[ $? -ne 0 ]] 
	then
		debug `$initScript command \say "A new version of Minecraft ($latestVersion) has been released! Server is going down for update!" 2>1`
		debug `$initScript stop 2>1` 
	else
		debug "Minecraft not running, no need to stop it..."
	fi
	rm $target &> /dev/null
	debug "Downloading the newest version..."
	wget -q $latestVersionURL

	debug "Installing..."
	#The current versioning system is "minecraft_server.[version].jar"
	mv "minecraft_server.$latestVersion.jar" "$target"

	debug "Starting the server..."
	debug `$initScript start`
	
	
}
cd $minecraftPath &> /dev/null
sanityCheck
#All is good, proceed normally
if [ $? == 0 ]
then
	scrapeForData || exit 2
	checkIfUpdateExists
	if [ $? == 0 ]
	then
		debug "All is good, Exiting..."
 		exit 0
	elif [ $? == 1 ]
	then
		updateMinecraft
		#We will consider it an error if minecraft needed an update
		exit 1
	fi
#We couldn't find the minecraft file, so we will put one there.
elif [ $? == 1 ]
then
	scrapeForData || exit 2
	updateMinecraft
else
	exit 2
fi
