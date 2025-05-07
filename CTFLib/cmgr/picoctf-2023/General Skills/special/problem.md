# Special

- Namespace: picoctf/picoctf2023
- ID: special
- Type: custom
- Category: General Skills
- Points: 300

## Description

Don't power users get tired of making spelling mistakes in the shell? Not 
anymore! Enter Special, the Spell Checked Interface for Affecting Linux. Now, 
every word is properly spelled and capitalized... automatically and 
behind-the-scenes! Be the first to test Special in beta, and feel free to tell 
us all about how Special streamlines every development process that you face. 
When your co-workers see your amazing shell interface, just tell them: That's 
Special (TM)

Start your instance to see connection details.
## Details
`ssh -p {{port("ssh")}} ctf-player@{{server("ssh")}}`

The password is `{{lookup("password")}}`

## Hints

- Experiment with different shell syntax

## Solution Overview

echo;echo;cat blargh/flag.txt

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

## Learning Objective

Experimenting with shell syntax to avoid filters

## Tags

- ssh
- bash

## Attributes

- author: LT 'syreal' Jones
- organization: picoCTF
- event: picoCTF 2023
