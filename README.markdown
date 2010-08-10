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

It treats everything as a `Post`.  A post has these properties:

- `title`: Name of the post/file/content
- `url`: Url to the post
- `description`: Description/summary/comment for the post.  Ranges from 50-1000 characters.  Most services only allow plain, but some (code snippets, and tumblr) allow html or code.
- `tags`: Array of lowercased tags.  Formats tags how services want them (e.g. comma separated vs. dashed).  Applies tag limits if necessary.  These are user-defined.
- `categories`: Category for the post.  Most services allow 1 category, some up to 4.  These are specific to the service.
- `vote`: Vote for the post, either "up", "down", or "none" (or 1, 0, -1).  Only if applicable to the service.
- `rating`: Rating for the post, 1-5, if applicable.
- `privacy`: Whether the service is public or private (0 || "public", 1 || "private")
- `state`: Status of the post, either "published", "draft", "submitted", or "queued".
- `kind`: The type of post, either post, link, quote, comment, image, video, audio, or answer.
- `format`: The format of your post content, either "plain", "html", "markdown", "textile", or any code (ruby, c, php, etc.).
- `service`: This is generated from the class, e.g. "digg".
- `service_url`: The url the service provides to the post.

Each service requires different things, which are determined by the `validates_presence_of` declaration for each class.  Conceptually, you can divide the services into these categories:

1. Microblogging (twitter, yahoo meme, google buzz, identica)
2. Tumblelogging (tumblr, posterous)
3. Blogging (large posts)
4. Bookmarking (delicious, diigo, mixx, newsvine, reddit, digg...)
5. Code Sharing (gist, snipplr, dzone snippets, snipt)

## How it works

Everything is built around [Mechanize](http://mechanize.rubyforge.org/mechanize/GUIDE_rdoc.html) and [Nokogiri](http://nokogiri.org/tutorials/parsing_an_html_xml_document.html), both led by [Aaron Patterson](http://tenderlovemaking.com/) (watch [Yehuda's "How to do the Impossible video"](http://www.youtube.com/watch?v=mo-lMdQMsdw)).

Many social bookmarking services do not have API's in order to prevent spammers from ruining their system.  But what about for those of us that actually create content several times a day and want automation?  We're out of luck.

So Ubiquitously creates a simple, RESTful API around some services I need to publish to now, and hopefully it will grow as you guys need more.  The goal is to be semi-low-level and not to provide a full featured api to a service, as some services already have very well-done API's in Ruby.

## Why

Currently there's plenty of services to post about yourself: ping.fm, onlywire, posterous...  But what if you want to do the same for other people?  You're left having to go to the page and click one of their social buttons, and filling out the form.  No way I'm filling out more than one for a page.  This solves that problem, making it so you can post someone else's site to a million places just like yours, helping you build a community.

## What you should be doing...

### Writing Tutorials

### Posting in Forums

- Comment in the forums

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
- [http://hubpages.com/hub/viatropos](http://hubpages.com/hub/viatropos)
- [http://www.mybloglog.com/](http://www.mybloglog.com/)
- [http://www.doshdosh.com/a-comprehensive-guide-to-stumbleupon-how-to-build-massive-traffic-to-your-website-and-monetize-it/](http://www.doshdosh.com/a-comprehensive-guide-to-stumbleupon-how-to-build-massive-traffic-to-your-website-and-monetize-it/)
- [http://www.thedesigncubicle.com/2009/12/websites-to-submit-your-design-articles-that-produce-heavy-traffic/](http://www.thedesigncubicle.com/2009/12/websites-to-submit-your-design-articles-that-produce-heavy-traffic/)
- [http://www.warriorforum.com/](http://www.warriorforum.com/)
- [http://lifehacker.com/5509815/how-to-declutter-and-streamline-your-google-reader-inbox](http://lifehacker.com/5509815/how-to-declutter-and-streamline-your-google-reader-inbox)
- [http://www.netvibes.com/](http://www.netvibes.com/)
- [http://www.noodlesoft.com/hazel.php](http://www.noodlesoft.com/hazel.php)

> Linkbuilding is not a sprint... it is a MARATHON!

1. Get a bunch of feeds
2. Read the feeds
3. Share the feeds

## Todo

- if submission already exists (digg, dzone, reddit...), then make description a comment and digg it.
- validations for each service (description wordcount, num tags, categories, title)
- who can post (is it for just me or for other people)?
- programmers_heaven, meta_filter, propeller, sharebrain, shoutwire, sphinn, stumpedia, web_blend, who_freelance, youblr, zabox
- Find image on page for display
- logging at stages in the process
- addthis-like javascript bookmarking tool
- flow:
  - content type: video, image, post, status
  - edit
  - sumbit
- each needs to check to see if post already exists
- handle categories in a generic way
- handle captchas
- if this is actually useful, maybe creating accounts programmatically
- optimize login, i could probably skip the entire "parse form" section and just do a raw post.
- I don't want to support _every_ service because most of them are spammy or are not used much lately.  Let's keep it clean here.  Some services are also invite only and are in very very specific niches outside my realm.  If you would like to support them, feel free to fork and customize.

<cite>copyright @viatropos 2010</cite>