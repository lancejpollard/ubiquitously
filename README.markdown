# [Ubiquitously](http://ubiquitously.me/)

> Making it easy for you to be everywhere, even if there's no API

## Usage

### Install

    sudo gem install ubiquitously
    
### Run Tests

Fill out `test/config.yml` with your credentials for the different services, then run

    rake test
    
### Automatically Post to Services

    require 'rubygems'
    require 'ubiquitously'
    
    user = Ubiquitously::User.new(
      :username => "viatropos",
      :name => "Lance Pollard",
      :email => "lancejpollard@gmail.com",
      :cookies_path => "_cookies.yml"
    )
    post = Ubiquitously::Post.new(
      :url          => "http://postable.com",
      :title        => "An Interesting Post!",
      :description  => "This is one of those rare things on the web...",
      :tags         => ["writing", "programming", "javascript", "html", "ruby on rails"],
      :user         => user
    )
    post.save("stumbleupon", "delicious", "dzone", "digg", "diigo", "reddit", "tumblr", "mixx")

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

## What you should be doing...

### Writing Tutorials

- http://www.thedesigncubicle.com/2009/12/websites-to-submit-your-design-articles-that-produce-heavy-traffic/

### Posting in Forums

- Comment in the forums

- http://www.warriorforum.com/

### Adding to Article Directories

### Guest Posting

### Publishing Documents

- scribd

### Contributing Code

- snippets, github

### Sharing and Tagging

- Share others' content to stumbleupon, delicious, digg, diigo, reddit, tumblr, twitter, mixx, and identica.
- Tag other's posts on stumbleupon, delicious, digg, diigo, and reddit.
- Stumble other peoples posts that link to you.  You'll benefit them and yourself.

### Commenting on Blogs

- Comment on other people's blogs

## Tips and Resources

- [http://www.highrevenue.com/free-website-traffic/critique-of-50-top-ways-to-drive-traffic-to-your-site](http://www.highrevenue.com/free-website-traffic/critique-of-50-top-ways-to-drive-traffic-to-your-site)
- [http://www.highrevenue.com/linkbuilding-techniques/make-link-building-the-cornerstone-of-you-daily-activities](http://www.highrevenue.com/linkbuilding-techniques/make-link-building-the-cornerstone-of-you-daily-activities)
- Linkbuilding is not a sprint… it is a MARATHON!
- [http://hubpages.com/hub/viatropos](http://hubpages.com/hub/viatropos)
- [http://www.mybloglog.com/](http://www.mybloglog.com/)
- [http://www.doshdosh.com/a-comprehensive-guide-to-stumbleupon-how-to-build-massive-traffic-to-your-website-and-monetize-it/](http://www.doshdosh.com/a-comprehensive-guide-to-stumbleupon-how-to-build-massive-traffic-to-your-website-and-monetize-it/)

1. Get a bunch of feeds
2. Read the feeds
3. Share the feeds

## Todo

- Find image on page for display
- logging and tips
- addthis-like javascript bookmarking tool
- flow:
  - content type: video, image, post, status
  - edit
  - sumbit
- each needs to check to see if post already exists
- handle categories in a generic way
- handle captchas
- if this is actually useful, maybe creating accounts programmatically