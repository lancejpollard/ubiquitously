class NilClass; def search(*args); []; end; end

Mechanize::Chain::PostConnectHook.class_eval do
  
  def handle(ctx, params)
    headers = params[:response].to_hash
    if headers.has_key?("location")
      headers["location"].each do |location|
        url = URI.parse(location)
        # we want mechanize to return if it sees a redirect back to localhost for facebook
        if url.host == "localhost" && url.port == 4567
          params[:res_klass] = Net::HTTPSuccess
        end
      end
    end
    
    super(ctx, params)
  end
  
end

class Mechanize::CookieJar
  public
  def save_string
    return YAML::dump(@jar)
  end

  def load_string(str)
    @jar = YAML::load(str)
  end
end
