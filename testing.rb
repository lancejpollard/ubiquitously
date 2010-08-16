require 'rubygems'
require 'mechanize'

agent = Mechanize.new

url = "http://www.unboxedconsulting.com/blog/wikileaks-war-logs-on-rails"
page = agent.get("http://www.reddit.com/?q=#{url}")
form = page.forms.detect {|form| form.form_node["id"] == "search"}

form["q"] = url

page = form.submit

File.open("reddit.html", "w+") {|f| f.puts page.parser.to_html}