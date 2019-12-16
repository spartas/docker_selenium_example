#!/usr/bin/env python3

import json
import requests
from bs4 import BeautifulSoup
import sys
import difflib

DEBUG = False

initialUrl = 'https://www.example.com'

def Test(str_arg):
  print(str_arg)
  return

r = requests.get(initialUrl)
soup = BeautifulSoup(r.text, 'html.parser')

p_soup = soup.prettify()
if 'DEBUG' in globals().keys() and globals()['DEBUG']:
  print('--- Actual result ---')
  print(p_soup)
  print('---')

with open('tests/example.com.html', 'r') as src_file:
  src_html = src_file.read()

if 'DEBUG' in globals().keys() and globals()['DEBUG']:
  print("DIFF")
  print('---')
  [ print(line) for line in difflib.unified_diff(src_html.split("\n"), p_soup.split("\n"), lineterm="", fromfile="expected.html", tofile="actual.html") ]

if src_html == p_soup:
  print("PASSED")
else:
  print("FAILED!")
  sys.exit(1)

