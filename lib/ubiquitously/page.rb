module Ubiquitously
  class Page
    attr_accessor :url, :title, :description, :tags, :image
    
    def initialize(attributes = {})
      attributes.each do |key, value|
        self.send("#{key.to_s}=", value) if self.respond_to?(key)
      end
    end
    
    def parse
      html = Nokogiri::HTML(open(url).read)
      
      self.title = html.xpath("//title").first.text.to_s.strip
      
      self.description = html.xpath("//meta[@name='description']").first["content"] rescue ""
      self.description.strip!
      
      self.tags = html.xpath("//meta[@name='keywords']").first["content"] rescue ""
      self.tags = self.tags.split(/,\s+/).map do |tag|
        tag.downcase.gsub(/[^a-z0-9]/, "-").squeeze("-").strip
      end
      
      self.image = html.xpath("//link[@rel='image_src']").first["image_src"] rescue nil
      if self.image.blank?
        self.image = html.xpath("//img").first["src"] rescue nil
      end
      
      self
    end
  end
end
