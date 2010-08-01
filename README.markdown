# [Ubiquitously](http://ubiquitously.me/)

> Making it easy for you to be everywhere, even if there's no API

## Usage

### Install

    sudo gem install ubiquitously
    
### Run Tests

Fill out `test/config.yml` with your credentials for the different services, then run

    rake test
    
### Register for the services you haven't already

First edit the config file with a username, password, and other fields that all the systems might have.  Then run this

    rake ubiquitously:me
    
### Automatically Post to Services

    require 'rubygems'
    require 'ubiquitously'
    
    # dzone
    Ubiquitously::Dzone::Post.create(
      :title => "A Dzone Post!",
      :description => "Dzone does not let you edit or delete posts once you submit them, so be careful!",
      :tags => ["dzone", "web 2.0"]
    )
    
## How it works

Everything is built around [Mechanize](http://mechanize.rubyforge.org/mechanize/GUIDE_rdoc.html) and [Nokogiri](http://nokogiri.org/tutorials/parsing_an_html_xml_document.html), both led by [Aaron Patterson](http://tenderlovemaking.com/).

Many social bookmarking services do not have API's in order to prevent spammers from ruining their system.  But what about for those of us that actually create content several times a day and want automation?  We're out of luck.

So Ubiquitously creates a simple, RESTful API around some services I need to publish to now, and hopefully it will grow as you guys need more.  The goal is to be semi-low-level and not to provide a full featured api to a service, as some services already have very well-done API's in Ruby.

## Other Possible Services (and Resources)

- [http://www.iwoodpecker.com/collection-of-70-best-social-bookmarking-sites-with-pr-and-alexa/](http://www.iwoodpecker.com/collection-of-70-best-social-bookmarking-sites-with-pr-and-alexa/)
- buzz.yahoo.com
- http://www.wikio.com/about-us
- http://designbump.com/
- http://scriptandstyle.com/submit
- http://www.stumpedia.com/submitlink.php