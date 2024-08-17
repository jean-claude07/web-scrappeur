require 'nokogiri'
require 'httparty'
require 'selenium-webdriver'
require 'uri'
require 'fileutils'

# Fonction pour extraire les liens du fichier XML
def extract_links_from_xml(file_path)
  xml_content = File.read(file_path)
  doc = Nokogiri::XML(xml_content)
  links = doc.xpath('//xmlns:loc').map(&:text)
  
  if links.empty?
    puts "Aucun lien trouvé dans les balises <loc> du fichier XML."
    exit
  end
  
  links
end

# Fonction pour obtenir le nom de domaine
def get_domain_name(links)
  first_link = links.find { |link| !link.nil? && !link.empty? }
  if first_link.nil?
    puts "Aucun lien valide trouvé dans les balises <loc>."
    exit
  end
  
  URI.parse(first_link).host
rescue URI::InvalidURIError
  puts "Le premier lien extrait est invalide : #{first_link}"
  exit
end

# Fonction pour créer un dossier
def create_directory(domain)
  FileUtils.mkdir_p(domain)
end

# Fonction pour initialiser le driver Selenium
def initialize_driver
  options = Selenium::WebDriver::Firefox::Options.new
  options.add_argument('--headless')
  Selenium::WebDriver.for(:firefox, options: options)
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

# Fonction pour enregistrer le contenu dans un fichier texte
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

# Chemin du fichier XML
xml_file_path = '/home/elpc/Documents/Extractor/test-fichier.xml'

# Extraire les liens du fichier XML
links = extract_links_from_xml(xml_file_path)

# Obtenir le nom de domaine
domain_name = get_domain_name(links)

# Créer un fichier texte avec tous les liens
File.open("#{domain_name}.txt", 'w') do |file|
  links.each { |link| file.puts(link) }
end

puts "Tous les liens ont été extraits et enregistrés dans #{domain_name}.txt"

# Créer un dossier pour le domaine
create_directory(domain_name)

# Initialiser le driver Selenium
driver = initialize_driver

# Scraper chaque lien
links.each do |url|
  document = scrape_page_with_selenium(driver, url)
  next if document.nil?

  title_h1 = extract_h1(document)
  content = extract_content_by_class(document, "page-content")
  
  save_content(domain_name, title_h1, content)

  sleep(rand(3..6))  # Attente entre 3 et 6 secondes
end

# Fermer le driver Selenium
driver.quit

puts "Scraping terminé!"