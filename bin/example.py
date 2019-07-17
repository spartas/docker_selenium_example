#!/usr/bin/env python3

import json
from selenium import webdriver
from selenium.webdriver import ActionChains
from selenium.webdriver.common.keys import Keys
from bs4 import BeautifulSoup
import sys

DEBUG = False

initialUrl = 'https://www.example.com'

def Test(str_arg):
  print(str_arg)
  return

options = webdriver.ChromeOptions()
options.binary_location = '/usr/bin/chromium-browser'
options.headless = True
options.add_argument('window-size=1200x600')
options.add_argument('no-sandbox')

browser = webdriver.Chrome(options=options)
browser.implicitly_wait(20)
browser.get(initialUrl)

str_src = browser.page_source

browser.close()

soup = BeautifulSoup(str_src, 'html.parser')

p_soup = soup.prettify()
if 'DEBUG' in globals().keys() and globals()['DEBUG']:
  print('--- Actual result ---')
  print(p_soup)
  print('---')

with open('tests/example.com.html', 'r') as src_file:
  src_html = src_file.read().rstrip('\n')

if 'DEBUG' in globals().keys() and globals()['DEBUG']:
  print(src_html)
  print('---')
  print()
  print('--- Expected result ---')

if src_html == p_soup:
  print("PASSED")
else:
  print("FAILED!")
  sys.exit(1)

