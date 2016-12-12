require 'nokogiri'
require 'http'
require 'reverse_markdown'

reports = File.read('index.txt').lines.map(&:chomp).map do |url|
  entry = {}

  response = HTTP.get(url, follow: true)
  html = response.body.to_s
  doc = Nokogiri::HTML(html)

  original_url = doc.css("link[rel=canonical]").attr('href').to_s
  title = doc.css(".entry-title").text.to_s
  body_html = doc.css(".entry-content").to_s
  markdown = ReverseMarkdown.convert(body_html)

  paragraphs = markdown.split("\n\n")
  summary = paragraphs.shift

  {
    original_url: original_url,
    title: title,
    summary: summary,
    body: paragraphs.join("\n\n"),
  }
end

puts JSON.pretty_generate(reports)
