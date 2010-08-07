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
    
## API

There's a pretty simple API to this, please let me know what I can do to make it better.

    # some way to store cookies for all the services you'll login to
    user = Ubiquitously::User.new(
      :username => "your-name",
      :cookie_path => "data/cookies.yml"
    )
    
    post = Ubiquitously::Post.new(
      :url => "http://wikipedia.org/an-article",
      :title => "My Article",
      :tags => ["article", "community-wiki"]
    )
    
    post.save(:dzone, :digg, :diigo, :newsvine)
    
    post.dzone? #=> true, dzone has the record
    post.dzone.tags #=> ["dzone's", "tags"]
    post.tumblr? #=> false, tumblr doesn't have it
    post.tumblr.save
    
You can also create accounts for users (eventually):

    user = Ubiquitously::User.new(:username => "your-name")
    user.create(
      :dzone, :reddit, :sphinn,
      :username => "something",
      :password => "something"
    )

## How it thinks

It divides actions into 4:

1. Microblogging (twitter, yahoo meme, google buzz, identica)
2. Tumblelogging (tumblr, posterous)
3. Blogging (large posts)
4. Bookmarking

## How it works

Everything is built around [Mechanize](http://mechanize.rubyforge.org/mechanize/GUIDE_rdoc.html) and [Nokogiri](http://nokogiri.org/tutorials/parsing_an_html_xml_document.html), both led by [Aaron Patterson](http://tenderlovemaking.com/).

Many social bookmarking services do not have API's in order to prevent spammers from ruining their system.  But what about for those of us that actually create content several times a day and want automation?  We're out of luck.

So Ubiquitously creates a simple, RESTful API around some services I need to publish to now, and hopefully it will grow as you guys need more.  The goal is to be semi-low-level and not to provide a full featured api to a service, as some services already have very well-done API's in Ruby.

## Why

Currently there's plenty of services to post about yourself: ping.fm, onlywire, posterous...  But what if you want to do the same for other people?  You're left having to go to the page and click one of their social buttons, and filling out the form.  No way I'm filling out more than one for a page.  This solves that problem, making it so you can post someone else's site to a million places just like yours, helping you build a community.

## Todo

- Find image on page for display
- logging and tips
- addthis-like javascript bookmarking tool
- flow:
  - content type: video, image, post, status
  - edit
  - sumbit

## Other Possible Services (and Resources)

- [http://www.iwoodpecker.com/collection-of-70-best-social-bookmarking-sites-with-pr-and-alexa/](http://www.iwoodpecker.com/collection-of-70-best-social-bookmarking-sites-with-pr-and-alexa/)
- buzz.yahoo.com
- http://www.wikio.com/about-us
- http://designbump.com/
- http://scriptandstyle.com/submit
- http://www.stumpedia.com/submitlink.php
- [http://github.com/heurionconsulting/bookmark_url_to/blob/master/lib/bookmark_url_to.rb](http://github.com/heurionconsulting/bookmark_url_to/blob/master/lib/bookmark_url_to.rb)
- Squidoo: http://www.squidoo.com/lensmaster/bookmark
- http://github.com/mwunsch/tumblr
  photo, link, quote, conversation, video, audio
- automatically post code to github gists
- publish to twitter, identica, buzz, friendfeed...
- http://pingomatic.com/
- http://www.diigo.com/user/viatropos
- https://www.threadsy.com
- http://blogmarks.net/marks/search/ruby+on+rails
- http://youblr.com/web/ruby+on+rails
- http://www.social-bookmarking.net/search/ruby%20on%20rails
- http://www.doshdosh.com/the-secret-to-building-a-popular-blog/
- yahoo meme
- http://feedback.seesmic.com/forums/37482-ping-fm/suggestions/436114-add-robust-ability-to-schedule-updates?utm_campaign=Widgets&utm_medium=widget&utm_source=feedback.seesmic.com
- http://www.lettermelater.com/
- schedule updates to go out.
- http://viatropos.status.net