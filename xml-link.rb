require 'nokogiri'
require 'open-uri'
require 'uri'

# Charger le fichier XML
file_path = '/home/elpc/Documents/Extractor/test-fichier.xml'
xml_content = File.read(file_path)

# Analyser le contenu du fichier XML
doc = Nokogiri::XML(xml_content)

# Extraire tous les liens dans les balises <loc>
links = doc.xpath('//xmlns:loc').map(&:text)

# Vérifier s'il y a des liens extraits
if links.empty?
  puts "Aucun lien trouvé dans les balises <loc> du fichier XML."
  exit
end

# Obtenir le nom de domaine à partir du premier lien valide
first_link = links.find { |link| !link.nil? && !link.empty? }

if first_link.nil?
  puts "Aucun lien valide trouvé dans les balises <loc>."
  exit
end

begin
  domain_name = URI.parse(first_link).host
rescue URI::InvalidURIError
  puts "Le premier lien extrait est invalide : #{first_link}"
  exit
end

# Créer un fichier texte avec le nom de domaine
output_file_path = "#{domain_name}.txt"
File.open(output_file_path, 'w') do |file|
  links.each do |link|
    file.puts(link)
  end
end

puts "Tous les liens ont été extraits et enregistrés dans #{output_file_path}"
