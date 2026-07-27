Bash is a REPLE 
echo hi Its evalute to it what we gave it print the value and it again read it and wait for next input. 
Bash is always in the folder 
pwd 
/users/dave
ls list all the files 
rm file.txt delte the file and no bin direct delete
cd foo 
pwd 
clear
touch new-file.txt
cmd and GUI touches the same file system

basic file manupulations 
touch llesson1.tx 
touch lession2.txt
touch lession3.txt
mv lession3.txt lession4.txt
mv is the command is used to even remane the file as well. 
when a file is exist with the same name and try to rename it it will override it. 
to remvoe a simplar file then write it as rm-lession-*.txt
clear
touch lession-1.txt
touch lession-2.txt 
rm -i lession* remmove all the file matching the text
alias commad to set a shortcut for a command 
alias rm='rm -i'

rm lession* 
alias rm (shows is there any alias is set)
ctrl + L use to clear the screen. 
history command to see the history commands.
----
hidden files
1. to make a file hidden place a .
2. touch .file.txt
3. ls -a to show the hidden files.
4. ---
./ means current directory and  ../ is the cone directory above the current directory 
cd - moves into the last diretcory you are in 
----
Searching the file 
cat file.txt 
grep dave /path 
grep '^dave' /apth ^ match the begining of the line
grep 'dave$' .path $ match that ends with of the line
grep -A1 b file.txt (print one line after the file.txt)
grep -B1 b file.txt (print one line before the file.txt)
grep -C33 b file.txt (print 3 lines before and after the file)
grep -i dave file.txt (use  case insenstite file)
grep -o '^d.' file.txt (only print the pattern that is matched)
grep -i -o '^d.' file.txt 
---
Paging Files
less /usr/share/dict/words  shift + n to go backward or n to move forward.
man ls 
