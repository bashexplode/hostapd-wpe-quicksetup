# Coded by Jesse Nebling (@bashexplode)

#### Description
A script that sets up hostapd-wpe in an automated matter, then creates two scripts on disk to quickly create an SSL cert and execute hostapd-wpe to perform an Evil Twin attack.

#### hostapd-wpe-installer.sh

Overview:  
hostapd-wpe-installer.sh pulls dependencies and required files to set up hostapd-wpe, performs necessary configuration changes to install hostapd-wpe on Kali 2 correctly, and creates the cert+ssid-customizer.sh and hostapd-wpe.sh scripts to make it easy to customize for client environments and run.

Usage:  
bash hostapd-wpe-installer.sh

Process Flow:  
Check for internet connection  
Create hostapd folder in the current directory  
Pull necessary dependencies from apt  
Pull hostapd and hostapd-wpe files from sources  
Patch necessary files and customize configuration for Kali 2  
Compile source  
Update run config file so hostapd-wpe runs on wlan0 instead of eth0  
Create hostapd-wpe.sh script in the hostapd directory  
Create cert+ssid-customizer.sh in the hostapd directory  
Give execution rights to the created scripts  



#### cert+ssid-customizer.sh

Overview:  
Prompts the user to enter various information to customize SSL certificate and the name of the SSID that will be broadcasted.

Usage:  
bash cert+ssid-customizer.sh

Process Flow:  
Prompt user for SSID name  
Prompt user for certificate information  
Update SSID name in running configuration  
Update configuration files for certificate creation  
Run bootstrap to utilize configuration files and create certificates  



#### hostapd-wpe.sh

Overview:  
Frees up wireless network interface card and executes hostapd-wpe with the customized configuration file with custom certificates.

Usage:  
bash hostapd-wpe.sh

Process Flow:  
Free wireless NIC  
Run hostapd-wpe with custom configuration and custom certificates  




------
IOCs:  
A hostile replicate access point is created  
Users that try to authenticate to it will not gain access to their intended network  


Suggested Improvements:  
Input sanitization of the cert+ssid-customizer.sh prompts.
