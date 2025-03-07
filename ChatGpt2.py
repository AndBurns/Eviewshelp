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

# Path to Chromedriver (update accordingly)
service = Service(r"C:\Users\home\Downloads\chromedriver-win64\chromedriver-win64\chromedriver.exe")

try:
    # Initialize WebDriver
    driver = webdriver.Chrome(service=service, options=chrome_options)
    
    # Open the EViews help page
    url = "https://www.eviews.com/help/helpintro.html"
    driver.get(url)
    
    # Wait for the page to fully load
    WebDriverWait(driver, 10).until(lambda driver: driver.execute_script('return document.readyState') == 'complete')
    
    # Wait for the iframe to be present
    try:
        iframe = WebDriverWait(driver, 10).until(EC.presence_of_element_located((By.TAG_NAME, "iframe")))
        driver.switch_to.frame(iframe)
        print("Switched to iframe successfully.")
        
        # Wait for content inside the iframe to load
        WebDriverWait(driver, 10).until(lambda driver: driver.execute_script('return document.readyState') == 'complete')
        time.sleep(3)  # Ensure iframe content loads
        
        # Get the iframe's inner content
        iframe_html = driver.page_source
        
        # Parse with BeautifulSoup
        iframe_soup = BeautifulSoup(iframe_html, "html.parser")
        iframe_text = iframe_soup.get_text(separator="\n", strip=True)
        
        # Save the extracted iframe text
        with open("eviews_iframe_text.txt", "w", encoding="utf-8") as file:
            file.write(iframe_text)
        
        print("Iframe text extraction completed.")
        
    except Exception as e:
        print("No iframe found or failed to switch:", e)
    
finally:
    driver.quit()
