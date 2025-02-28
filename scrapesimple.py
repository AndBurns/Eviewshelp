# -*- coding: utf-8 -*-
"""
Created on Fri Feb 28 13:37:23 2025

@author: home
"""
from bs4 import BeautifulSoup
from bs4.element import Comment
import urllib.request
import re
import ssl

def tag_visible(element):
    if element.parent.name in ['style', 'script', 'head', 'title', 'meta', '[document]']:
        return False
    if isinstance(element, Comment):
        return False
    if re.match(r"[\n]+",str(element)): return False
    return True
def text_from_html(url):
    body = urllib.request.urlopen(url,context=ssl._create_unverified_context()).read()
    soup = BeautifulSoup(body ,features="html.parser")
    texts = soup.findAll(string=True)
    visible_texts = filter(tag_visible, texts)  
    text = u",".join(t.strip() for t in visible_texts)
    text = text.lstrip().rstrip()
    text = text.split(',')
    clean_text = ''
    for sen in text:
        if sen:
            sen = sen.rstrip().lstrip()
            clean_text += sen+','
    return clean_text
url = 'https://www.eviews.com/help/helpintro.html'
url = 'https://www.eviews.com/help/helpintro.html#page/content%2Fpreface.html%23'
print(text_from_html(url))