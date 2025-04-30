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
