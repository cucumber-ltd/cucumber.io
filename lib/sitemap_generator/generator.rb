# frozen_string_literal: true

require 'date'
require 'faraday'
require 'nokogiri'
require 'uri'
require 'time'

# Generator keeps our sitemaps up to date
class Generator
  # Generate is the orchestrator
  def generate_sitemaps
    # Setup data for current sitemaps
    ghost_parent = external_xml('https://cucumber.ghost.io/sitemap.xml')
    cuke_parent = local_xml('./static/sitemaps/sitemap.xml')

    # Gather URL of child maps that need to be regenerated
    children_to_update = find_children_to_update(ghost_parent, cuke_parent)
    children_to_update.push('https://cucumber-website.squarespace.com/sitemap.xml')

    # Generate sanitized versions of each child
    children_data = load_children(children_to_update)
    sanitized_children = sanitize_children(children_data)
    children_to_write = update_pages_map(sanitized_children)
    written_children = write_children(sanitized_children)
    puts "wrote children maps: #{written_children}"

    # Update our current parent map's lastmod dates for the children we updated
    # and write it to disk
    new_parent = update_parent(cuke_parent, written_children)
    write_map(new_parent, './static/sitemaps/sitemap.xml')
  end

  def get(url)
    Faraday.get url
  end

  def external_xml(url)
    res = get(url)

    xml(res.body)
  end

  def local_xml(filepath)
    res = File.read(filepath)

    xml(res)
  end

  def xml(location)
    Nokogiri::XML(location) do |config|
      config.strict.noblanks
    end
  end

  def find_children_to_update(ghost_parent, cuke_parent)
    cuke_data = local_cuke_data(cuke_parent)

    # We'll return a map's url string if:
    # - it's not found in our current map
    # - its last_mod date is newer than our matching map
    ghost_parent.css('sitemap').collect do |e|
      loc = e.css('loc').text
      next if loc.include? '/sitemap-pages.xml'

      last_mod = Date.parse(e.css('lastmod').text)
      matched_date = cuke_data.dig(URI(loc).path)

      next if matched_date && last_mod <= matched_date

      loc
    end.compact
  end

  def local_cuke_data(data)
    # Collect the path and lastmod data of the children from our current parent map
    data.css('sitemap').collect { |e| [URI(e.css('loc').text).path, Date.parse(e.css('lastmod').text)] }.to_h
  end

  # load_children returns a hash of the successfully requested maps to be updated.
  # TODO: log when loading a child fails
  def load_children(children)
    children.collect do |child|
      resp = get(child)
      resp.status < 400 ? { 'loc' => child, 'body' => resp.body } : next
    end.compact
  end

  def sanitize_children(children)
    children.collect { |child| { 'loc' => child['loc'], 'body' => sanitize(child['body']) } }
  end

  def sanitize(input)
    edit = input.dup
    edit.gsub!('.ghost', '')
    edit.gsub!('cucumber-website.squarespace.com', 'cucumber.io')

    edit
  end

  def update_pages_map(sanitized_children)
    expected_xml =
      xml('<?xml version="1.0" encoding="UTF-8"?>
        <?xml-stylesheet type="text/xsl" href="//cucumber.io/sitemap.xsl"?>
        <urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9" xmlns:image="http://www.google.com/schemas/sitemap-image/1.1">
           <url>
              <loc>https://cucumber.io/events</loc>
              <changefreq>monthly</changefreq>
              <priority>0.75</priority>
              <lastmod>2018-11-30</lastmod>
           </url>
           <url>
              <loc>https://cucumber.io/blog</loc>
              <changefreq>weekly</changefreq>
              <priority>0.75</priority>
              <lastmod>2018-11-30</lastmod>
           </url>
           <url>
              <loc>https://cucumber.io/docs</loc>
              <changefreq>weekly</changefreq>
              <priority>0.75</priority>
              <lastmod>2018-11-30</lastmod>
           </url>
        </urlset>')
    [
        { 'loc' => 'https://cucumber-website.squarespace.com/sitemap.xml', 'body' => expected_xml }
      ]
  end

  def write_map(data, location)
    File.open(location, 'w') do |file|
      file.write(data)
      file.close
    end
  end

  def write_children(children, location = './static/sitemaps')
    children.collect do |child|
      path = if child['loc'].include? 'squarespace'
               '/sitemap-pages.xml'
             else
               URI(child['loc']).path
             end

      write_map(child['body'], "#{location}#{path}")

      path
    end
  end

  def update_parent(parent_in, children_in)
    t = Time.new.utc.iso8601(3).to_s
    parent = parent_in.dup
    children = children_in.dup

    parent, children = updated_child_times(parent, children, t)

    add_children(parent, children, t)
  end

  def updated_child_times(parent, children, time)
    parent.css('sitemap').each do |sitemap|
      path = URI(sitemap.css('loc').text).path

      if children.include? path
        sitemap.at_css('lastmod').content = time
        children.delete(path)
      end
    end

    [parent, children]
  end

  def add_children(parent, children, time)
    maps = parent.at_css('sitemap')
    children.each do |child|
      maps.add_next_sibling("<sitemap><loc>https://cucumber.io#{child}</loc><lastmod>#{time}</lastmod></sitemap>")
    end

    parent
  end
end
