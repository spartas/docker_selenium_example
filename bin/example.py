#!/usr/bin/env python3

import json
from selenium import webdriver
from selenium.webdriver import ActionChains
from selenium.webdriver.common.keys import Keys
from bs4 import BeautifulSoup

DEBUG = True

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

if 'DEBUG' in globals().keys() and globals()['DEBUG']:
  print(soup.prettify())

