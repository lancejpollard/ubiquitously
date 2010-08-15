module Ubiquitously
  class Page < Base
    attr_accessor :url, :title, :description, :tags, :image
    
    def initialize(attributes = {})
      apply attributes
    end
    
    def parse
      html = Nokogiri::HTML(open(url).read)
      
      self.title = html.xpath("//title").first.text.to_s.strip
      
      self.description = html.xpath("//meta[@name='description']").first["content"] rescue ""
      self.description.strip!
      
      self.tags = html.xpath("//meta[@name='keywords']").first["content"] rescue ""
      self.tags = self.tags.split(/,\s+/).taggify("-", ", ").split(", ")
      
      self.image = html.xpath("//link[@rel='image_src']").first["image_src"] rescue nil
      if self.image.blank?
        self.image = html.xpath("//img").first["src"] rescue nil
      end
      
      self
    end
  end
end
