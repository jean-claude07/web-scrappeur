require 'nokogiri'
require 'httparty'
require 'selenium-webdriver'
require 'uri'
require 'fileutils'

# Configurer le driver pour Chrome
options = Selenium::WebDriver::Firefox::Options.new
options.add_argument('--headless') # Optionnel : exécute Chrome sans interface graphique
driver = Selenium::WebDriver.for :firefox, options: options

# Lis les URLs depuis un fichier texte
urls_file = '/home/elpc/Documents/Extractor/www.santiness.com.txt'
urls = File.readlines(urls_file).map(&:chomp)

# Crée un dossier pour chaque domaine
def create_directory(domain)
  FileUtils.mkdir_p(domain)
end

# Fonction pour initialiser le driver Selenium
def initialize_driver
  Selenium::WebDriver.for(:firefox) # Utilisez :chrome ou :firefox selon votre navigateur
end

# Fonction pour extraire le titre H1
def extract_h1(document)
  h1 = document.at_css('h1')
  h1 ? h1.text.strip.gsub(/[^\w\s-]/, '').gsub(/\s+/, '_') : 'no_title'
end

# Fonction pour scraper la page avec Selenium
def scrape_page_with_selenium(driver, url)
  driver.get(url)
  Nokogiri::HTML(driver.page_source)
end

# Fonction pour enregistrer le contenu dans un fichier texte avec le titre en premier
def save_content(domain, title, content)
  filename = "#{domain}/#{title}.txt"
  File.open(filename, 'w') do |file|
    file.puts(title.gsub('_', ' '))
    file.puts(' ')
    file.puts(' ')
    file.puts(content)
  end
  puts "Fichier créé : #{filename}"
end

# Fonction pour extraire le contenu d'une classe spécifique
def extract_content_by_class(document, class_name)
  content = document.at_css("div.#{class_name}")
  content ? content.text.strip : 'no_content'
end

# Initialisation du driver Selenium
driver = initialize_driver

urls.each do |url|
  # Parse le nom de domaine à partir de l'URL
  domain = URI.parse(url).host
  create_directory(domain)

  # Scraper la page avec Selenium
  document = scrape_page_with_selenium(driver, url)
  next if document.nil?

  # Extraire le titre H1
  title_h1 = extract_h1(document)

  # Extraire le contenu de plusieurs classes
  content = extract_content_by_class(document, "page-content")
  
  # Ajouter ici d'autres sélecteurs si nécessaire
  # Example:
  # content_2 = extract_content_by_class(document, "another-class")
  # content += "\n\n" + content_2 unless content_2 == 'no_content'

  # Enregistre le contenu dans un fichier texte
  save_content(domain, title_h1, content)

  # Temporisation pour éviter de surcharger le serveur
  sleep(rand(3..6))  # Attend entre 3 et 6 secondes
end

# Fermer le driver Selenium après avoir terminé
driver.quit

puts "Scraping terminé!"
