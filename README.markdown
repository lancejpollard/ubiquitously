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
5. Code Sharing (gist, snipplr, dzone snippets, snipt, flikode, smipple)

## How it works

Everything is built around [Mechanize](http://mechanize.rubyforge.org/mechanize/GUIDE_rdoc.html) and [Nokogiri](http://nokogiri.org/tutorials/parsing_an_html_xml_document.html), both led by [Aaron Patterson](http://tenderlovemaking.com/) (watch [Yehuda's "How to do the Impossible video"](http://www.youtube.com/watch?v=mo-lMdQMsdw)).

Many social bookmarking services do not have API's in order to prevent spammers from ruining their system.  But what about for those of us that actually create content several times a day and want automation?  We're out of luck.

So Ubiquitously creates a simple, RESTful API around some services I need to publish to now, and hopefully it will grow as you guys need more.  The goal is to be semi-low-level and not to provide a full featured api to a service, as some services already have very well-done API's in Ruby.

## Why

Currently there's plenty of services to post about yourself: ping.fm, onlywire, posterous...  But what if you want to do the same for other people?  You're left having to go to the page and click one of their social buttons, and filling out the form.  No way I'm filling out more than one for a page.  This solves that problem, making it so you can post someone else's site to a million places just like yours, helping you build a community.

## What you should be doing...

### Posting in Forums

- Comment in the forums

### Adding to Article Directories

- Delicious

### Guest Posting

- Envato

### Publishing Documents

- Scribd

### Contributing Code

- snippets, github

### Sharing and Tagging

- Share others' content to stumbleupon, delicious, digg, diigo, reddit, tumblr, twitter, mixx, and identica.
- Tag other's posts on stumbleupon, delicious, digg, diigo, and reddit.
- Stumble other peoples posts that link to you.  You'll benefit them and yourself.
- Write 2-3 sentences to describe each thing you post.  So if you can share 10 things a day, that's 20-30 sentences.

### Commenting on Blogs

- Comment on other people's blogs

## What you should _not_ be doing...

### Self Promoting

- Only posting your content, you will get banned from the sites.

### Spamming

- Posting just the default description to all the sites
- Posting too much

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
- [http://www.webdesignerdepot.com/2010/07/30-places-to-submit-your-website-designs/](http://www.webdesignerdepot.com/2010/07/30-places-to-submit-your-website-designs/)
- [http://knowem.com/](http://knowem.com/)
- [hriscredendino.com/](hriscredendino.com/)
- [http://www.networkworld.com/news/2010/080210-social-media-sucks-up-23.html](http://www.networkworld.com/news/2010/080210-social-media-sucks-up-23.html)
- [http://opensource.newscloud.com](http://opensource.newscloud.com)
- [http://www.doshdosh.com/list-of-social-media-news-websites/](http://www.doshdosh.com/list-of-social-media-news-websites/)
- [http://popurls.com/](http://popurls.com/)
- [http://www.webdesignerdepot.com/2010/07/30-places-to-submit-your-website-designs/](http://www.webdesignerdepot.com/2010/07/30-places-to-submit-your-website-designs/)
- [http://www.shareaholic.com/](http://www.shareaholic.com/)

> Linkbuilding is not a sprint... it is a MARATHON!

1. Get a bunch of feeds
2. Read the feeds
3. Share the feeds

## Todo

- find most appropriate tags for each service
- slideshare
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

## Tags

Programming, Ruby, Rails, Development, textmate (911)javascript (791)css (747)php (729)jquery (452)html (384)Bash (316)mysql (298)ruby (294)python (291)String (244)wordpress (242)array (208)sql (186)image (174)rails (172)java (167)drupal (166)file (165)actionscript (162)

- http://www.noupe.com/
- mashable
- smashing-magazine
- tripwire
- http://www.instantshift.com/user-submitted-news/
- http://designm.ag/submit-news/
- http://speckyboy.com/designnews/design-news-submission-form/
- http://net.tutsplus.com/link-feed/#add
- http://qik.com/
- http://www.associatedcontent.com/
- http://inboundmarketing.com
- http://clipmarks.com
- http://www.addurl.nu/
- http://blog.sponsoredreviews.com/?p=47
- http://www.metamags.com/
- http://www.developersniche.com/
- http://add.io/
- http://www.arto.com/section/frontpage/
- https://www.google.com/bookmarks/l
- amazon wishlist
- netvibes
- evernote
- http://www.evri.com/
- http://pinboard.in
- http://weheartit.com/about
- http://www.soup.io/
- http://izeby.com/
- http://linkmarking.com/
- yahoo meme
- reddit, digg, diigo, and mixx still don't work
- diigo doesn't work because cookie expires.  create mechanize to re-login if cookie doesn't work

## Lists

- http://www.digalist.com
- listiki.com
- tipbo.com
Social Media Profiles. There a whole bunch of social websites online which allow you to insert a link to your website on the profile page. Sign up for some of them, preferably using a username and avatar that brands your business or you as a person. This might come in useful when you decide to promote your site via the social website in the future.

Ask yourself the following questions about the linkability of your content:
Am I Digging this because I want others to see it, and pressing a single button is an easy way for me to say “this is cool?”  
Or am I Digging this because People need to know about this, because they can’t live without it or because without it they would be out of the loop.
Is it possible that my information is so new and/or informative that I will actually become an authority on this information, or serve as a reference for others interested in writing about similar content?

- evernote
- http://www.rubyflow.com

## Command-line

It will save your login data (cookies and oauth tokens) in `~/.u.me`

    u.me user facebook -u "your@email.com" -p "your-pass"
    u.me post digg -t "Oauth on the Command line!?" -d "You can now use Oauth from the command line" -t "oauth, ruby, unix" -u "http://ubiquitously.me"

> It is only one step more to make it so we fully create all the user accounts if they don't exist on all the services