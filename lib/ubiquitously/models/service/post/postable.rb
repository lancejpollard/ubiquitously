module Ubiquitously
  module Post
    module Postable
      def self.included(base)
        base.extend ClassMethods
        base.send :include, InstanceMethods
      end
    
      module ClassMethods      
        attr_accessor :title, :url, :description, :tags, :categories, :remote, :service_id, :votes
        # some sites check to see if you're posting duplicate content!
        # perhaps "vote" can mean "favorite" also
        attr_accessor :image, :rating, :privacy, :vote, :status, :must_be_unique, :captcha
        attr_accessor :service_url, :user, :upvotes, :downvotes
        # the application that automates! ("Posted by TweetMeme")
        attr_accessor :source, :source_url
        # kind == regular, link, quote, photo, conversation, video, audio, answer
        attr_accessor :kind
        # plain, html, markdown
        attr_accessor :format, :extension
        # max 55 chars, for custom url if possible
        attr_accessor :slug
        # published, draft, submission, queue
        attr_accessor :state
      
        def submit_to(url = nil)
          @submit_to = url if url
          @submit_to
        end

        def submit_url(post)
          post.tokenize.inject(submit_to) do |result, token|
            result.gsub(/:#{token.first}/, token.last)
          end
        end
      
        # with and without trailing slash, in case we saved it as one over the other
        def url_permutations(url)
          url, params = url.split("?")
          # without_trailing_slash, with www
          a = url.gsub(/\/$/, "").gsub(/http(s)?:\/\/([^\/]+)/) do |match|
            protocol = "http#{$1.to_s}"
            domain = $2
            domain = "www.#{domain}" if domain.split(".").length < 3 # www.google.com == 3, google.com == 2
            "#{protocol}://#{domain}"
          end
          # with_trailing_slash, with www
          b = "#{a}/"
          # without_trailing_slash, without www
          c = a.gsub(/http(s)?:\/\/www\./, "http#{$1.to_s}://")
          # with_trailing_slash, without www
          d = "#{c}/"
        
          [a, b, c, d].map { |url| "#{url}?#{params}".gsub(/\?$/, "") }
        end

        def service
          self.to_s.split("::")[1].underscore.downcase
        end
      end
    
      module InstanceMethods
        def service
          self.class.service
        end
      
        def tokenize
          {
            :url => self.url,
            :title => self.title,
            :description => self.description,
            :tags => self.tags.map { |tag| tag.downcase.gsub(/[^a-z0-9\.]/, " ").squeeze(" ") }.join(", "),
            :categories => self.categories.map { |tag| tag.downcase.gsub(/[^a-z0-9\.]/, " ").squeeze(" ") }
          }
        end
      
        def private?
          privacy == 1 || privacy == "1" || privacy == "private"
        end
      
        def public?
          privacy == 0 || privacy == "0" || privacy == "public"
        end
      
        def url_permutations(url)
          self.class.url_permutations(url)
        end
      
        def submit_url
          self.class.submit_url(self)
        end
      end
    end
  end
end
