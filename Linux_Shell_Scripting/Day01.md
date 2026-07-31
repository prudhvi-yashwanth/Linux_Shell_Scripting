Linux Day-1
------

Environment Setup
---
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
brew install --cask multipass
multipass launch --name devops-lab --cpus 2 --memory 2G --disk 10G
multipass shell devops-lab
---

Commands Learned Today
---
pwd - print working directory to know where we are located.
whoami - To see which user is currenly logged-in
ls -la - long list of the files & directories  in the current directory 
ls -la /var - List of files in var directory irrespective of your location
cd /etc - system configuration files
cd /var - variables data -logs, mail, spools
cd /home user home directory
cd /bin essential commands binaries
---
cd ~ - goes to home direectory
mkdir -p practice/day1 - used to create a direcoty if diretory doenot exist it will cretee if exist. no error.
cd practice/day1
---
touch file1.txt used to create a file
mkdir backup used to create a directpry 
mv draft.txt final.txt - used to move or rename the file.
cp -r  = recursive, needed for folders to copy from one location to other location.
rm backup2/notes-copy.txt            # delete a single file
rmdir backup2                        # delete an EMPTY folder only

find ~/practice -name "*.txt" used to find or locate a file in a direcotry with matching end with .txt
--
End of day-1

