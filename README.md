# bookmark2enex
`bookmark2enex` converts a Netscape Bookmark HTML file to an Evernote .enex notebook.

It has been created to import bookmarks from Delicious to Evernote but could be used to import any bookmarks to Evernote (though it as only been tested with Delicious).

It has been used with Ruby 1.9.3.

# Setup
`bookmark2enex` uses [Bundler](http://gembundler.com/) to managed its dependencies. Install Bundler first with:

    gem install bundler

Install the required gems with the following command:

    bundle install

# How to import Delicious bookmarks into Evernote
Connect to your Delicious account and go to the [settings](https://delicious.com/settings). Click on _export / back up links_. You will get a .html file containing all your bookmarks and their attributes.

In a command line interface (like Terminal on OS X), enter the following command:

    bookmark2enex <your delicious links.html> <your evernote login>

The Evernote login is only used to set an author on each note, it is not used to connect to your Evernote account.

The command creates a note for each link in the bookmark file. A note contains the following attributes from Delicious:

* _'A' TAG CONTENT_: the title of the link
* _HREF_: the link
* _ADD\_DATE_: the creation date of the link
* _TAGS_: the tags of the link
* _DD_: the comment associated with the link

The content of the note is composed of the _link_ and the _link comment_ if there is one.
The _private_ attribute is ignored.

`bookmark2enex` creates a .enex file that you can import into Evernote (either by double-clicking on the file or by selecting _Import notes..._ in the _File_ Evernote menu).
