# -*- coding: utf-8 -*-
"""
Created on Fri Feb 28 13:37:23 2025

@author: home
"""
from selenium import webdriver
from selenium.webdriver.chrome.service import Service
from selenium.webdriver.chrome.options import Options
from selenium.webdriver.common.by import By
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
from bs4 import BeautifulSoup
import time

# Chrome options
chrome_options = Options()
chrome_options.add_argument("--headless")  # Run without GUI
chrome_options.add_argument("--disable-gpu")
chrome_options.add_argument(
    "user-agent=Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/131.0.6778.265 Safari/537.36"
)

# Path to Chromedriver
service = Service(r"C:\Users\home\Downloads\chromedriver-win64\chromedriver-win64\chromedriver.exe")  # Update the path
#%%
try:
    # Initialize WebDriver
    driver = webdriver.Chrome(service=service, options=chrome_options)
    
    # Open the Naukri Gulf "Top Jobs by Designation" page
    #url = "https://www.naukrigulf.com/top-jobs-by-designation"
    url = "https://www.eviews.com/help/helpintro.html"
    
    
    
    driver.get(url)
    
    # Wait for the required section to load (with the correct class name)
    
    WebDriverWait(driver, 100).until(lambda driver: driver.execute_script('return document.readyState') == 'complete')
    
    # Get the page source
    html = driver.page_source
    
    # Parse the HTML with BeautifulSoup
    soup = BeautifulSoup(html, "html.parser")      
    
    with open("eviews.txt", "w") as file:
        file.write(str(soup))

    # Locate the section containing job titles
    

#    print(f"{i}. {r.text.strip()}")
    
finally:
    # Close the WebDriver
    driver.quit()

