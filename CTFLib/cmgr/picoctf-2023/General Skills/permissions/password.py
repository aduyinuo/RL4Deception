#!/usr/bin/env python3
import json
import os
import sys
import re
import random

def generate_password(length=10):
    ALPHABET = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789-+"
    return "".join(random.choices(ALPHABET, k=length))


def flag():
    flag = os.environ.get("FLAG")
    if flag == '':
        print("Flag was not read from environment. Aborting.")
        sys.exit(-1)

    else:
        # Get unique part
        flag_rand = re.search("{.*}$", str(flag))
        if flag_rand == None:
            print("Flag isn't wrapped by curly braces. Aborting.")
            sys.exit(-2)
        else:
            flag_rand = flag_rand.group()
            flag_rand = flag_rand[1:-1]

        new_flag = "picoCTF{uS1ng_v1m_3dit0r_" + flag_rand + "}"
        with open("/root/.flag.txt", "w") as f:
            f.write(new_flag+"\n")
    return new_flag


# generate password
picoplayer_pass = generate_password()
# generate picofied flag
metadata = {"flag":flag()}

metadata["username"] = "picoplayer"
metadata["password"] = picoplayer_pass

password_script = """
chpasswd << EOF
picoplayer:%s
EOF
""" % (picoplayer_pass)

with open("set-passwords.sh", "w") as f:
    f.write(password_script)

with open("/challenge/metadata.json","w") as f:
    f.write(json.dumps(metadata))