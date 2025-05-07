#!/usr/bin/python3

import os
from spellchecker import SpellChecker



spell = SpellChecker()

while True:
  cmd = input("Special$ ")
  rval = 0
  
  if cmd == 'exit':
    break
  elif 'sh' in cmd:
    print('Why go back to an inferior shell?')
    continue
  elif cmd[0] == '/':
    print('Absolutely not paths like that, please!')
    continue
    
  # Spellcheck
  spellcheck_cmd = ''
  for word in cmd.split():
    fixed_word = spell.correction(word)
    if fixed_word is None:
      fixed_word = word
    spellcheck_cmd += fixed_word + ' '

  # Capitalize
  fixed_cmd = list(spellcheck_cmd)
  words = spellcheck_cmd.split()
  first_word = words[0]
  first_letter = first_word[0]
  if ord(first_letter) >= 97 and ord(first_letter) <= 122:
    fixed_cmd[0] = chr(ord(spellcheck_cmd[0]) - 0x20)
  fixed_cmd = ''.join(fixed_cmd)
  
  try:
    print(fixed_cmd)
    os.system(fixed_cmd)
  except:
    print("Bad command!")

