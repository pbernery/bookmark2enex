#!/usr/bin/env ruby
#
# bookmark2enex transforms a HTML Bookmark file to a Evernote notebook (.enex file).
# The HTML Bookmark file is expected to be in the Netscape Bookmark file format
# (see http://msdn.microsoft.com/en-us/library/aa753582%28VS.85%29.aspx).
#
# Copyright (c) 2012 Philippe Bernery
#
require 'nokogiri'
require 'pathname'

def usage
  usage = "bookmark2enex <HTML Bookmark File> <author>\n"
  usage << "\n"
  usage << "Creates an Evernote notebook from a Netscape HTML Bookmark file.\n"
  usage << "\n"
  usage << "The created notebook is named like the bookmark file (with a .enex extension).\n"
  usage << "bookmark2enex handles extra attributes added by Delicious.\n"
end

if ARGV.count < 2
  puts usage
  exit 1
end

bookmark_filename = ARGV[0]
author = ARGV[1]

# Creates an Array of Hash describing links from a Netscape Bookmark file
# @param bookmark_filename [String] the name of bookmark file.
# @return Array<Hash> The hash contains the following keys:
#   - title [String]
#   - link [String]
#   - tags [Array<String>]
#   - creation_date [Time]
#   - notes [String] (Optional)
def links_from_bookmark_file(bookmark_filename)
  links = []

  document = Nokogiri::HTML(File.open(bookmark_filename))
  document.css('dt').each do |dt|
    link = {}

    a = dt.css('a').first
    link[:title] = a.content
    link[:link] = a['href']
    link[:creation_date] = Time.at(a['add_date'].to_i).utc
    link[:tags] = a['tags'].split(',')

    dd = dt.css('+ dd')
    if dd && dd.count > 0
      link[:notes] = dd.first.content
    end

    links << link
  end

  links
end

# Creates a Evernote XML note from a link and
# @param link [String] the link to include in the note
# @param notes [String] the notes to include in the note
# @return [String] a XML string following the http://xml.evernote.com/pub/enml2.dtd DTD.
def create_en_note(link, notes)
  builder = Nokogiri::XML::Builder.new do |xml|
    xml.doc.create_internal_subset('en-note', nil, 'http://xml.evernote.com/pub/enml2.dtd')
    xml.send(:'en-note') do
      xml.a(link)[:href] = link
      if notes
        xml.div { xml.br }
        xml.div notes
      end
    end
  end
  builder.to_xml.to_s
end

# Writes a Evernote notebook .enex file which contents is links.
# @param links [Array<Hash>] the links
# @param enex_filename [String] filename of the output file
def links_to_enex(links, author, enex_filename)
  builder = Nokogiri::XML::Builder.new do |xml|
    xml.doc.create_internal_subset('en-export', nil, 'http://xml.evernote.com/pub/evernote-export2.dtd')
    xml.send(:'en-export') do
      links.each do |link|
        xml.note do
          xml.title link[:title]
          xml.content do
            en_note = create_en_note(link[:link], link[:notes])
            if en_note.length > 0
              xml.cdata en_note
            end
          end
          formatted_creation_time = link[:creation_date].strftime('%Y%m%dT%H%M%SZ')
          xml.created formatted_creation_time
          xml.updated formatted_creation_time
          link[:tags].each do |tag|
            xml.tag tag
          end
          xml.send(:'note-attributes') do
            xml.send(:'subject-date', formatted_creation_time)
            xml.author author
            xml.source 'web.clip'
            xml.send(:'source-url', link[:link])
          end
        end
      end
    end
  end

  File.write(enex_filename, builder.to_xml)
end

links = links_from_bookmark_file(bookmark_filename)
filename = File.basename(bookmark_filename, File.extname(bookmark_filename)) + '.enex'
links_to_enex(links, author, filename)
