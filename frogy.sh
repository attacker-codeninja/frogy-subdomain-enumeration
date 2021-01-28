#!/bin/bash

echo -e "

 _______                                                                                                                                
(_______)                                                                                                                               
 _____  ____  ___    ____  _   _                                                                                                        
|  ___)/ ___)/ _ \  / _  || | | |                                                                                                       
| |   | |   | |_| |( ( | || |_| |                                                                                                       
|_|   |_|    \___/  \_|| | \__  |                                                                                                       
                   (_____|(____/                                                                                                        
    _            _          _                       _           _______                                                 _               
   | |          | |        | |                     (_)         (_______)                                          _    (_)              
    \ \   _   _ | | _    _ | |  ___   ____    ____  _  ____     _____    ____   _   _  ____    ____   ____  ____ | |_   _   ___   ____  
     \ \ | | | || || \  / || | / _ \ |    \  / _  || ||  _ \   |  ___)  |  _ \ | | | ||    \  / _  ) / ___)/ _  ||  _) | | / _ \ |  _ \ 
 _____) )| |_| || |_) )( (_| || |_| || | | |( ( | || || | | |  | |_____ | | | || |_| || | | |( (/ / | |   ( ( | || |__ | || |_| || | | |
(______/  \____||____/  \____| \___/ |_|_|_| \_||_||_||_| |_|  |_______)|_| |_| \____||_|_|_| \____)|_|    \_||_| \___)|_| \___/ |_| |_|
                                                                                                                                        

"

########### Taking User Input  ############

echo -e "\e[94m Enter the organisation name: \e[0m"
read org

echo -e "\e[94m Enter the root domain name: \e[0m"
read domain_name

echo -e "\e[92m Hold on! some house keeping tasks being done... \e[0m"
if test -e wordlist.txt; then
  rm wordlist.txt 
fi

if test -e all.txt; then
  rm all.txt
fi

if test -e temp_wordlist.txt; then
  rm temp_wordlist.txt
fi

if test -e 2021-*; then
  rm 2021-*.txt
fi

############ Find Subdomains ##############
echo -e "\e[92m Identifying Subdomains \e[0m"
./subfinder -d $domain_name -silent >> all.txt

curl -s "https://crt.sh/?q="$org"&output=json" | jq -r '.[].name_value' | sed '/^$/d' | sed 's/\*\.//g' | grep -v " " | grep -v "@" | grep -v "*" | sort -u  >> all.txt
curl -s "https://crt.sh/?q="$org"%&output=json" | jq -r '.[].name_value' | sed '/^$/d' | sed 's/\*\.//g' | grep -v " " | grep -v "@" | grep -v "*" | sort -u  >> all.txt
curl -s "https://crt.sh/?q=%"$org".%&output=json" | jq -r '.[].name_value' | sed '/^$/d' | sed 's/\*\.//g' | grep -v " " | grep -v "@" | grep -v "*" | sort -u >> all.txt
curl -s "https://crt.sh/?q=%"$org"%&output=json" | jq -r '.[].name_value' | sed '/^$/d' | sed 's/\*\.//g' | grep -v " " | grep -v "@" | grep -v "*" | sort -u  >> all.txt

python3.8 sublister/sublist3r.py -d $domain_name -o sublister_output.txt &> /dev/null
cat sublister_output.txt >> all.txt
rm sublister_output.txt

./assetfinder $org | ./anew | grep -v " " | grep -v "@" | grep -v "*" >> all.txt

./findomain-linux -t $domain_name -q >> all.txt

echo -e "\e[93m Bruteforcing subdomains using domain name iterations... \e[0m"

############ Generating Wordlist  ##############
cat all.txt | cut -d "." -f1 >> temp_wordlist.txt
cat all.txt | cut -d "." -f2 >> temp_wordlist.txt
cat all.txt | cut -d "." -f3 >> temp_wordlist.txt
cat all.txt | cut -d "." -f4 >> temp_wordlist.txt
cat all.txt | cut -d "." -f5 >> temp_wordlist.txt
cat all.txt | cut -d "." -f6 >> temp_wordlist.txt
cat all.txt | cut -d "." -f7 >> temp_wordlist.txt
cat all.txt | cut -d "." -f8 >> temp_wordlist.txt
cat all.txt | cut -d "." -f9 >> temp_wordlist.txt
cat all.txt | cut -d "." -f10 >> temp_wordlist.txt

cat temp_wordlist.txt | ./anew | sed '/^$/d' | sed 's/\*\.//g' | grep -v " " | grep -v "@" | grep -v "*" | sort -u >> wordlist.txt

rm temp_wordlist.txt
############ Running Crt.sh on all domain iterations  ##############

for i in $(cat wordlist.txt); do curl -s "https://crt.sh/?q="$i"."$org"&output=json" | jq -r '.[].name_value' | sed '/^$/d' | sed 's/\*\.//g' | grep -v " " | grep -v "@" | grep -v "*" | sort -u; done >> all.txt &> /dev/null

############ Housekeeping Tasks ##############

cat all.txt | ./anew >> $(date +"%FT%T").txt
rm all.txt

echo -e "Result is saved in the  \e[91m$(ls 2021-*.txt) file."
