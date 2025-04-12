# RL4Deception
🛠️ Cyber Deception Network Setup Summary
This guide outlines the complete process of setting up a cyber deception network using Terraform and Bash automation. It includes all necessary corrections and lessons learned along the way.

1. ✅ Terraform Network Deployment (AWS)
📦 Components Created
- VPC: CIDR block 10.0.0.0/16
- Subnets:
  - Public Web: 10.0.1.0/24
  - Private A (DB/NTP): 10.0.2.0/24
  - Private B (PC1–3/InternalWeb): 10.0.3.0/24
- Controller: 10.0.4.0/24
- Routing:
  - Public RT → Internet Gateway
  - Private RT → NAT Gateway

- EC2 Instances:
  - Controller, DB, InternalWeb, NTP, PC1, PC2, PC3, PublicWeb1, PublicWeb2

- Security Group:
  - Open SSH (port 22) to 0.0.0.0/0
  - Open port 17737 for internal control traffic

⚠️ Issues Resolved
- Region mismatch: AMIs and Availability Zones were mismatched (us-east-1 vs us-east-2). Fixed by explicitly setting AZ to us-east-2a.
- AMI not found: Used public, verified Ubuntu 24.04 LTS image (ami-0c262369dcdfc38a8) for us-east-2.
- PendingVerification: EC2 resource access temporarily blocked. Waited for AWS to complete verification before reapplying.
- Elastic IP for Controller: Explicitly attached and output for easier SSH access.

2. 🔐 SSH Key Setup and Access
- ✅ Key Management
- Used RL4Deception.pem for initial key pair in Terraform.
- Created user_key / user_key.pub on the controller for internal communication.

⚠️ Issues & Fixes
- Permission denied (publickey): Solved by creating /home/user/.ssh/authorized_keys with the right public key and permissions (700 folder, 600 file).
- Missing .ssh directory: Ensured creation using deployment scripts.

3. 👤 User Account + Password SSH
- ✅ Actions
- Created a user account on each internal host.
- Used patch scripts from controller to:
  - Create user
  - Set known password
  - Allow password login by modifying /etc/ssh/sshd_config
  - Restart SSH

⚠️ Issues & Fixes
- Password login blocked: Fixed with PasswordAuthentication yes in sshd_config.
- Cowrie SCP blocked: Added public key manually to user@host to re-enable file transfer.

4. 💣 Internal Vulnerability Deployment
- ✅ Features
- Created weak guest user with NOPASSWD:ALL sudo
- SUID enabled on bash and find
- Cronjob planted for the DB host

- 🔧 Tools
- deploy_internal_vuln.sh: runs the above setup on all relevant internal hosts
- verify_internal.sh: checks for correct setup (users, permissions, cron, etc.)

5. 🐍 Cowrie Honeypot Deployment
- ✅ Process
- Uploaded deploy_cowrie.sh to each host
- Installed Cowrie in a Python venv under ~/cowrie
- Passwordless sudo was enabled for user to allow installation
- Key-based SCP used to avoid login issues

⚠️ Issues Resolved
- Sudo requires TTY: Fixed by setting NOPASSWD:ALL and non-interactive SSH sudo usage
- Installed Cowrie on controller accidentally: Later corrected by running on each target via SSH

6. 🎛️ Management Scripts
- start_all.sh: Start Cowrie across all nodes
- stop_all.sh: Stop Cowrie across all nodes
- verify_all.sh: Check if Cowrie is running on all nodes

✅ Final Result
- We now have:
- A fully deployed AWS-based cyber deception network
- Custom vulnerabilities on internal machines
- Honeypot services running on attacker-facing nodes
- Automated management from a single controller host
