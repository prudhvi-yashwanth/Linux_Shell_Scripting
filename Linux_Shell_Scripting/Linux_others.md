diff between sudo su  and sudo su - 

touch 
echo 
vi 

/home/ubuntu 
touch config.py

echo "hellow.py" > welcome.txt 
vim menu.sh
i insert mode: menu.sh 
:wq
!w 
!q 
cat welcome.txt 
cat -n menu.sh
cat -E menu.sh show end of each line with a doller size
vi about.txt 

simbolic link 
soft link
hard link 

absolute path 
relative path 

ln -s /home/ubuntu/config.py /tmp/

swap & Tempnary memory when total memory is consumed them we use swap memory incase of ram is full

%CPU 0.0 us sy, ni m id wa hi , si st 
sort using CPU use captial P 
when M for memory
kill -1 <PID> Enterprise services like Nginx, Apache, or SSH use this signal to seamlessly reload configuration changes on the fly. This means the service stays active, existing connections are not dropped, and new settings take effect immediately
apt update 
to check the version of the application
applicationname -v or applicationame --version 
apt list -a applicationame
show all the versions avalibale
apt-mark hold nginx to stop autoupgrade
apt-mark unhold nginx to cancle the hold it enables auto upgardes 
sudo apt remove applictaioname like apt remove nginx -y 
apt purge nginx remove all configuraion 
apt autoremove remove unwanted packages or non used packages 
apt remove apache2

systemctl list-unit-files --type=service
to see all the services that are enabled or disabled or what is the status 













