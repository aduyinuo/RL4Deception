# Permissions

- Namespace: picoctf/picoctf2023
- ID: permissions
- Type: custom
- Category: General Skills
- Points: 100
- Templatable: yes
- MaxUsers: 1

## Description

Can you read files in the root file?

## Details

The system admin has provisioned an account for you on the main server:

`ssh -p {{port("ssh")}} {{lookup("username")}}@{{server("ssh")}}`

Password: `{{lookup("password")}}`

Can you login and read the root file?


## Hints
- What permissions do you have?

## Challenge Options

```yaml
cpus: 0.5
memory: 128m
pidslimit: 20
ulimits:
  - nofile=128:128
diskquota: 64m
init: true
```

## Solution Overview

By running `sudo -l`, the player should see that they can run vi as a priviledged user. `sudo vi` then use `:!ls -a /root/` to list files then use `:!cat /root/.flag.txt` to read the flag

## Learning Objective

By the end of this challenge, competitors should have an understanding how to run commands from vim

## Tags

- vim

## Attributes

- author: Geoffrey Njogu
- organization: Cylab Africa
- event: picoCTF 2023
