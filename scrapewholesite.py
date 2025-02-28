# -*- coding: utf-8 -*-
"""
Created on Fri Feb 28 13:37:23 2025

@author: home
"""

from bs4 import BeautifulSoup as BS
import requests


r = requests.get("https://www.eviews.com/help/helpintro.html")
#r = requests.get("https://webscraper.io/test-sites/e-commerce/allinone")

base_url = "https://www.eviews.com/help/"

def all_pages(base_url):
    response = requests.get(base_url)
    unique_urls = {base_url}
    visited_urls = set()
    while len(unique_urls) > len(visited_urls):
        soup = BS(response.text, "html.parser")

        for link in soup.find_all("a"):
            try:
                url = link["href"]
            except:
                continue
            absolute_url = base_url + url
            unique_urls.add(absolute_url)

        unvisited_url = (unique_urls - visited_urls).pop()
        visited_urls.add(unvisited_url)
        response = requests.get(unvisited_url)

    return unique_urls

#all_pages(base_url)



soup = BS(r.text,features="html.parser")
#%% Write the file
with open("eviews.txt", "w") as file:
    file.write(str(soup))