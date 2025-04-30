- Get controller IP
```
aws ec2 describe-instances \
  --filters "Name=tag:Name,Values=Controller" \
  --query "Reservations[].Instances[].PublicIpAddress" \
  --output text
```

- ssh into controller
```
chmod 400 RL4Deception.pem
ssh -i Network_tf/RL4Deception.pem ubuntu@3.148.118.121
```