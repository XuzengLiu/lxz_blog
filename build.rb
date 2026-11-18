# frozen_string_literal: true

require 'cgi'
require 'date'
require 'erb'
require 'fileutils'
require 'json'
require 'rdoc'
require 'rdoc/markdown'
require 'rdoc/markup/to_html'
require 'yaml'

ROOT = __dir__
DIST = File.join(ROOT, 'dist')
Post = Struct.new(:slug, :date, :title, :summary, :category, :tags, :body, :headings)

def read(path)
  File.read(path, encoding: 'UTF-8')
end

def h(value)
  CGI.escapeHTML(value.to_s)
end

def render(name, **locals)
  ERB.new(read(File.join(ROOT, 'templates', "#{name}.erb")), trim_mode: '-').result_with_hash(locals)
end

def post_path(post)
  "posts/#{post.slug}.html"
end

def page_path(number)
  number == 1 ? 'index.html' : "page/#{number}/index.html"
end

class BlogFormatter < RDoc::Markup::ToHtml
  attr_reader :headings

  def initialize(options)
    super
    @headings = []
  end

  def accept_heading(heading)
    level = heading.level.clamp(2, 6)
    text = to_html(heading.text)
    id = "section-#{@headings.length + 1}"
    @headings << [id, text, level]
    @res << %(<h#{level} id="#{id}">#{text}</h#{level}>\n)
  end

  def accept_verbatim(block)
    language = CGI.escapeHTML(block.format.to_s)
    @res << %(<pre><code data-language="#{language}">#{CGI.escapeHTML(block.text.chomp)}</code></pre>\n)
  end
end

def markdown(body)
  parser = RDoc::Markdown.new
  parser.html = false
  options = RDoc::Options.new
  options.pipe = true
  formatter = BlogFormatter.new(options)
  [parser.parse(body).accept(formatter), formatter.headings]
end

def metadata_text(meta, key)
  value = meta[key]
  raise "请填写 #{key}，文字用引号括起来" unless value.is_a?(String) && !value.strip.empty?

  value.strip
end

def read_post(path)
  filename = File.basename(path, '.md')
  match = /\A(\d{4}-\d{2}-\d{2})-[a-z0-9]+(?:-[a-z0-9]+)*\z/.match(filename)
  raise '文件名应为 YYYY-MM-DD-english-slug.md' unless match

  date = Date.iso8601(match[1])
  sections = /\A---[ \t]*\r?\n(.*?)\r?\n---[ \t]*\r?\n(.*)\z/m.match(read(path).delete_prefix("\uFEFF"))
  raise '用两行 --- 包住文章开头的信息' unless sections

  meta = YAML.safe_load(sections[1])
  raise '文章信息应填写标题、摘要和分类' unless meta.is_a?(Hash)

  category = metadata_text(meta, meta.key?('category') ? 'category' : 'tag')
  tags = meta.fetch('tags', [])
  unless tags.is_a?(Array) && tags.all? { |tag| tag.is_a?(String) && !tag.strip.empty? }
    raise 'tags 应为列表，例如 ["Python", "BFS"]'
  end

  raise '正文不能为空' if sections[2].strip.empty?

  body, headings = markdown(sections[2])
  Post.new(filename, date, metadata_text(meta, 'title'), metadata_text(meta, 'summary'),
           category, tags.map(&:strip).uniq, body, headings)
rescue StandardError => e
  abort "无法生成文章 #{File.basename(path)}：#{e.message}"
end

def write_page(site, path, active:, heading:, content:, post: nil)
  prefix = '../' * path.count('/')
  destination = File.join(DIST, path)
  FileUtils.mkdir_p(File.dirname(destination))
  File.write(destination, render('layout', site: site, active: active, heading: heading,
                                 content: content, post: post, prefix: prefix))
end

site = YAML.safe_load(read(File.join(ROOT, 'site.yml')))
page_size = site.fetch('page_size', 4)
abort 'site.yml 的 page_size 必须是大于 0 的整数' unless page_size.is_a?(Integer) && page_size.positive?

posts = Dir.glob(File.join(ROOT, 'posts', '*.md')).map { |path| read_post(path) }
posts.sort_by! { |post| [post.date, post.slug] }.reverse!
categories = posts.group_by(&:category).sort.to_h
tags = Hash.new { |hash, key| hash[key] = [] }
posts.each { |post| post.tags.each { |tag| tags[tag] << post } }
tags = tags.sort.to_h

FileUtils.rm_rf(DIST)
FileUtils.mkdir_p(DIST)
%w[assets images].each { |name| FileUtils.cp_r(File.join(ROOT, name), DIST) }

chunks = posts.empty? ? [[]] : posts.each_slice(page_size).to_a
chunks.each_with_index do |items, i|
  number = i + 1
  content = render('home', items: items, number: number, total: chunks.length,
                           prefix: number == 1 ? '' : '../../', categories: categories, tags: tags)
  write_page(site, page_path(number), active: 'home', heading: site['title'], content: content)
end

archive = render('groups', groups: posts.group_by { |post| post.date.year }, active: 'archives',
                           heading: '归档', count: posts.length)
write_page(site, 'archives.html', active: 'archives', heading: '归档', content: archive)
[['categories', '分类', categories], ['tags', '标签', tags]].each do |key, label, groups|
  content = render('groups', groups: groups, active: key, heading: label, count: groups.length)
  write_page(site, "#{key}.html", active: key, heading: label, content: content)
end
write_page(site, 'about.html', active: 'about', heading: '关于',
           content: render('about', site: site))

posts.each_with_index do |post, i|
  content = render('post', post: post, older: posts[i + 1], newer: i.positive? ? posts[i - 1] : nil,
                           categories: categories, tags: tags)
  write_page(site, post_path(post), active: 'post', heading: post.title, content: content, post: post)
end

index = posts.map do |post|
  {
    title: post.title, summary: post.summary, date: post.date.iso8601,
    category: post.category, tags: post.tags, path: post_path(post),
    text: CGI.unescapeHTML(post.body.gsub(/<[^>]*>/, ' ')).gsub(/\s+/, ' ').strip
  }
end
File.write(File.join(DIST, 'assets', 'search-index.js'), "window.blogSearchIndex = #{JSON.generate(index)};\n")
puts "已生成 #{posts.length} 篇文章、#{chunks.length} 页首页列表：#{File.join(DIST, 'index.html')}"
