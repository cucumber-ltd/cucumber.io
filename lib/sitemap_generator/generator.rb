# frozen_string_literal: true

require 'date'
require 'faraday'
require 'nokogiri'
require 'uri'

# Generator keeps our sitemaps up to date
class Generator
  # Generate is the orchestrator
  def generate
    # Setup data for current sitemaps
    ghost_parent = external_xml('https://cucumber.ghost.io/sitemap.xml')
    square_parent = external_xml('https://cucumber-website.squarespace.com/sitemap.xml')
    cuke_parent = local_xml('./static/sitemaps/sitemap.xml')

    # Gather URL of child maps that need to be regenerated
    children_to_update = find_children_to_update(ghost_parent, cuke_parent)
    children_to_update.push('https://cucumber.ghost.io/sitemap-pages.xml')

    # Generate sanitized versions of each child
    children_data = load_children(children_to_update)
    sanitized_children = sanitize_children(children_data)
    written_children = write_children(sanitized_childre)
    # Update our current parent map's lastmod dates for the children we updated
    #   - Open current parent on disk
    #   - Update child last mods
    #   - Write new version to disk
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
      next if loc == '/sitemap-sites.xml'

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

  def write_children(children, location)
    children.each do |child|
      File.open("#{location}/#{URI(child["loc"]).path}", "w") do |file|
        file.write(child["body"])
        file.close
      end
    end
  end
end
