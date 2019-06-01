# frozen_string_literal: true

require 'date'
require 'faraday'
require 'nokogiri'
require 'uri'
require 'time'

# Generator keeps our sitemaps up to date
class Generator
  # Generate_sitemaps is the orchestrator for creating updated site maps
  def generate_sitemaps
    # Setup data for current sitemaps
    ghost_parent = external_xml('https://cucumber.ghost.io/sitemap.xml')
    cuke_parent = local_xml('./static/sitemaps/sitemap.xml')

    # Gather URL of child maps that need to be regenerated
    children_to_update = find_children_to_update(ghost_parent, cuke_parent).push('https://cucumber-website.squarespace.com/sitemap.xml')

    # Generate sanitized versions of each child
    children_data = load_children(children_to_update)
    sanitized_children = sanitize_children(children_data)
    children_to_write = update_pages_map(sanitized_children)
    written_children = write_children(children_to_write)
    puts "wrote children maps: #{written_children}"

    # Update our current parent map's lastmod dates for the children we updated
    # and write it to disk
    new_parent = update_parent(cuke_parent, written_children)
    write(new_parent, './static/sitemaps/sitemap.xml')
  end

  def generate_rss
    external_url = 'https://cucumber.ghost.io/rss/'
    if last_mod_time(external_url) < last_mod_time('https://cucumber.io/blog/rss')
      puts 'external rss not newer, skipping generation'
      return
    end
    puts "generating new rss file"

    ghost_parent = external_xml(external_url)

    sanitize_map = [
      ['cucumber.ghost.io/blog/', 'cucumber.io/blog/'],
      ['cucumber.ghost.io/', 'cucumber.io/'],
      ['cucumber.ghost.io/content/', 'cucumber.io/content/']
    ]

    sanitized_rss = sanitize_rss(ghost_parent.to_s, sanitize_map)
    final_rss = update_generator(sanitized_rss)

    write(final_rss.to_s, './static/rss/rss.xml')
  end

  def get(url)
    Faraday.get url
  end

  def head(url)
    Faraday.head url
  end

  def last_mod_time(url)
    res = head(url)

    last_mod = res.headers.dig('Last-Modified') || res.headers.dig('last-modified')

    Time.parse(last_mod)
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

  def sanitize_rss(input, sanitize_map)
    edit = input.dup
    sanitize_map.each { |from, to| edit.gsub!(from, to) }

    edit
  end

  def sanitize(input)
    edit = input.dup
    edit.gsub!('.ghost', '')
    edit.gsub!('cucumber-website.squarespace.com', 'cucumber.io')

    edit
  end

  def update_pages_map(children, time = Time.new.strftime('%F'))
    children.collect do |child|
      child['body'] = pages_map_update(child['body'], time) if child['loc'].include? 'squarespace'

      child
    end
  end

  def pages_map_update(map, time)
    body = xml(map)
    url = body.at_css('url')
    %w[blog docs].each do |site|
      url.add_previous_sibling("<url><loc>https://cucumber.io/#{site}</loc><changefreq>weekly</changefreq><priority>0.75</priority><lastmod>#{time}</lastmod></url>")
    end

    body.to_s
  end

  def write(data, location)
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

      write(child['body'], "#{location}#{path}")

      path
    end
  end

  def update_generator(input)
    edit = xml(input.dup)
    edit.at_css('generator').content = edit.css('generator').text + ' & Cucumber'

    edit.to_s
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
