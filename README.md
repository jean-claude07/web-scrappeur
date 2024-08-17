# web-scrappeur
Web scrapping ruby use Selenium with .xml file

Web Scraper for Blog Content
This Ruby script automates the process of scraping blog content from multiple web pages. It reads URLs from a text file, extracts the main content, and saves it to organized text files.

Features:
Title Extraction: Extracts the main heading (<h1>) of the page as the title for the saved content.
Content Scraping: Scrapes the content from a specified CSS class, ensuring you capture the main body of the article or post.
File Organization: Automatically creates directories based on the domain name of each URL, organizing your scraped content neatly.
Customizable: Easily adjust the class selectors and other parameters to fit different website structures.
Rate Limiting: Includes random delays between requests to avoid overloading servers and to mimic human browsing patterns.
