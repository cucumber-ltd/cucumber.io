# frozen_string_literal: true

require 'webmock/rspec'

require_relative '../../lib/sitemap_generator/generator.rb'

describe Generator do
  describe 'external_xml' do
    it 'gets an external xml file and returns that xml parsed' do
      expected =
        '<?xml version="1.0" encoding="UTF-8"?><?xml-stylesheet type="text/xsl" href="//cucumber.ghost.io/sitemap.xsl"?>
          <sitemapindex xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">
            <sitemap>
              <loc>https://cucumber.ghost.io/sitemap-pages.xml</loc>
              <lastmod>2019-04-10T15:19:50.801Z</lastmod>
            </sitemap>
            <sitemap>
              <loc>https://cucumber.ghost.io/sitemap-posts.xml</loc>
              <lastmod>2019-04-05T04:34:10.000Z</lastmod>
            </sitemap>
            <sitemap>
              <loc>https://cucumber.ghost.io/sitemap-authors.xml</loc>
              <lastmod>2019-04-18T03:21:26.896Z</lastmod>
            </sitemap>
            <sitemap>
              <loc>https://cucumber.ghost.io/sitemap-tags.xml</loc>
              <lastmod>2019-03-15T00:27:00.000Z</lastmod>
            </sitemap>
          </sitemapindex>'

      stub_request(:any, 'https://cucumber.ghost.io/sitemap.xml')
        .to_return(body: expected)

      g = Generator.new
      actual = g.external_xml('https://cucumber.ghost.io/sitemap.xml')

      expect(actual.to_xml).to eq xml(expected).to_xml
    end
  end

  describe 'local_xml' do
    it 'reads a local xml file from disk and returns that xml parsed' do
      expected =
        '<?xml version="1.0" encoding="UTF-8"?><?xml-stylesheet type="text/xsl" href="//cucumber.io/sitemap.xsl"?>
        <sitemapindex xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">
          <sitemap>
            <loc>https://cucumber.io/sitemap-pages.xml</loc>
            <lastmod>2019-04-10T15:19:50.801Z</lastmod>
          </sitemap>
          <sitemap>
            <loc>https://cucumber.io/sitemap-posts.xml</loc>
            <lastmod>2019-04-05T04:34:10.000Z</lastmod>
          </sitemap>
          <sitemap>
            <loc>https://cucumber.io/sitemap-authors.xml</loc>
            <lastmod>2019-04-18T03:21:26.896Z</lastmod>
          </sitemap>
          <sitemap>
            <loc>https://cucumber.io/sitemap-tags.xml</loc>
            <lastmod>2019-03-15T00:27:00.000Z</lastmod>
          </sitemap>
        </sitemapindex>'

      g = Generator.new
      actual = g.local_xml('./test_data/sitemaps/sitemap.xml')

      expect(actual.to_xml).to eq xml(expected).to_xml
    end
  end

  describe 'find_children_to_update' do
    describe 'returns a list of child sitemaps whose external last modified dates are newer than the local dates' do
      context 'when only two children have newer external dates' do
        it 'returns only those two' do
          ghost_parent = xml('<?xml version="1.0" encoding="UTF-8"?><?xml-stylesheet type="text/xsl" href="//cucumber.ghost.io/sitemap.xsl"?>
          <sitemapindex xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">
            <sitemap>
              <loc>https://cucumber.ghost.io/sitemap-pages.xml</loc>
              <lastmod>2019-04-10T15:19:50.801Z</lastmod>
            </sitemap>
            <sitemap>
              <loc>https://cucumber.ghost.io/sitemap-posts.xml</loc>
              <lastmod>2019-04-25T04:34:10.000Z</lastmod>
            </sitemap>
            <sitemap>
              <loc>https://cucumber.ghost.io/sitemap-authors.xml</loc>
              <lastmod>2019-04-25T03:21:26.896Z</lastmod>
            </sitemap>
            <sitemap>
              <loc>https://cucumber.ghost.io/sitemap-tags.xml</loc>
              <lastmod>2019-03-15T00:27:00.000Z</lastmod>
            </sitemap>
          </sitemapindex>')

          cuke_parent = xml('<?xml version="1.0" encoding="UTF-8"?><?xml-stylesheet type="text/xsl" href="//cucumber.io/sitemap.xsl"?>
            <sitemapindex xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">
              <sitemap>
                <loc>https://cucumber.io/sitemap-pages.xml</loc>
                <lastmod>2019-04-10T15:19:50.801Z</lastmod>
              </sitemap>
              <sitemap>
                <loc>https://cucumber.io/sitemap-posts.xml</loc>
                <lastmod>2019-04-05T04:34:10.000Z</lastmod>
              </sitemap>
              <sitemap>
                <loc>https://cucumber.io/sitemap-authors.xml</loc>
                <lastmod>2019-04-18T03:21:26.896Z</lastmod>
              </sitemap>
              <sitemap>
                <loc>https://cucumber.io/sitemap-tags.xml</loc>
                <lastmod>2019-03-15T00:27:00.000Z</lastmod>
              </sitemap>
            </sitemapindex>')

          expected = [
            'https://cucumber.ghost.io/sitemap-posts.xml',
            'https://cucumber.ghost.io/sitemap-authors.xml'
          ]

          g = Generator.new
          actual = g.find_children_to_update(ghost_parent, cuke_parent)

          expect(actual).to eq expected
        end
      end

      context 'when no children have newer external dates' do
        it 'returns empty' do
          ghost_parent = xml('<?xml version="1.0" encoding="UTF-8"?><?xml-stylesheet type="text/xsl" href="//cucumber.ghost.io/sitemap.xsl"?>
          <sitemapindex xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">
            <sitemap>
              <loc>https://cucumber.ghost.io/sitemap-tags.xml</loc>
              <lastmod>2019-04-10T15:19:50.801Z</lastmod>
            </sitemap>
          </sitemapindex>')

          cuke_parent = xml('<?xml version="1.0" encoding="UTF-8"?><?xml-stylesheet type="text/xsl" href="//cucumber.io/sitemap.xsl"?>
            <sitemapindex xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">
              <sitemap>
                <loc>https://cucumber.io/sitemap-tags.xml</loc>
                <lastmod>2019-04-10T15:19:50.801Z</lastmod>
              </sitemap>
            </sitemapindex>')

          g = Generator.new
          actual = g.find_children_to_update(ghost_parent, cuke_parent)

          expect(actual).to be_empty
        end
      end
    end

    describe 'assumes that maps not found in our current map are new and must be added' do
      context 'when no children have newer external dates' do
        it 'returns empty' do
          ghost_parent = xml('<?xml version="1.0" encoding="UTF-8"?><?xml-stylesheet type="text/xsl" href="//cucumber.ghost.io/sitemap.xsl"?>
          <sitemapindex xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">
            <sitemap>
              <loc>https://cucumber.ghost.io/sitemap-tags.xml</loc>
              <lastmod>2019-04-10T15:19:50.801Z</lastmod>
            </sitemap>
            <sitemap>
            <loc>https://cucumber.ghost.io/sitemap-new.xml</loc>
            <lastmod>2019-04-10T15:19:50.801Z</lastmod>
          </sitemap>
          </sitemapindex>')

          cuke_parent = xml('<?xml version="1.0" encoding="UTF-8"?><?xml-stylesheet type="text/xsl" href="//cucumber.io/sitemap.xsl"?>
            <sitemapindex xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">
              <sitemap>
                <loc>https://cucumber.io/sitemap-tags.xml</loc>
                <lastmod>2019-04-10T15:19:50.801Z</lastmod>
              </sitemap>
            </sitemapindex>')

          expected = ['https://cucumber.ghost.io/sitemap-new.xml']

          g = Generator.new
          actual = g.find_children_to_update(ghost_parent, cuke_parent)

          expect(actual).to eq expected
        end
      end
    end
  end

  describe 'load_children' do
    it 'loads the provided child maps at the provided urls' do
      posts_child =
        '<?xml version="1.0" encoding="UTF-8"?>
        <?xml-stylesheet type="text/xsl" href="//cucumber.ghost.io/sitemap.xsl"?>
        <urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9" xmlns:image="http://www.google.com/schemas/sitemap-image/1.1">
           <url>
              <loc>https://cucumber.ghost.io/blog/alex-schladebeck-on-testing/</loc>
              <lastmod>2019-05-24T09:47:37.000Z</lastmod>
              <image:image>
                 <image:loc>https://cucumber.ghost.io/content/images/2019/05/alex-cukenfest.png</image:loc>
                 <image:caption>alex-cukenfest.png</image:caption>
              </image:image>
           </url>
           <url>
              <loc>https://cucumber.ghost.io/blog/illustrating-scenarios/</loc>
              <lastmod>2019-04-05T04:34:10.000Z</lastmod>
           </url>
        </urlset>'

      author_child =
        '<?xml version="1.0" encoding="UTF-8"?>
        <?xml-stylesheet type="text/xsl" href="//cucumber.ghost.io/sitemap.xsl"?>
        <urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9" xmlns:image="http://www.google.com/schemas/sitemap-image/1.1">
           <url>
              <loc>https://cucumber.ghost.io/author/theo/</loc>
              <lastmod>2019-05-24T09:36:16.000Z</lastmod>
           </url>
           <url>
              <loc>https://cucumber.ghost.io/author/matt/</loc>
              <lastmod>2019-04-22T04:29:14.000Z</lastmod>
              <image:image>
                 <image:loc>https://cucumber.ghost.io/content/images/2019/02/avatar.jpg</image:loc>
                 <image:caption>avatar.jpg</image:caption>
              </image:image>
           </url>
        </urlset>'

      stub_request(:any, 'https://cucumber.ghost.io/sitemap-posts.xml')
        .to_return(body: posts_child, status: 200)
      stub_request(:any, 'https://cucumber.ghost.io/sitemap-authors.xml')
        .to_return(body: author_child, status: 200)

      expected = [
        { 'loc' => 'https://cucumber.ghost.io/sitemap-posts.xml', 'body' => posts_child },
        { 'loc' => 'https://cucumber.ghost.io/sitemap-authors.xml', 'body' => author_child }
      ]
      input = ['https://cucumber.ghost.io/sitemap-posts.xml', 'https://cucumber.ghost.io/sitemap-authors.xml']

      g = Generator.new
      actual = g.load_children(input)

      expect(actual).to eq expected
    end

    context 'when a provided does not return successfully' do
      it 'does not return those maps' do
        stub_request(:any, 'https://cucumber.ghost.io/sitemap-posts.xml')
          .to_return(body: '"error": "not found"', status: 404)
        stub_request(:any, 'https://cucumber.ghost.io/sitemap-authors.xml')
          .to_return(body: '"error": "server error"', status: 500)

        input = ['https://cucumber.ghost.io/sitemap-posts.xml', 'https://cucumber.ghost.io/sitemap-authors.xml']

        g = Generator.new
        actual = g.load_children(input)

        expect(actual).to be_empty
      end
    end
  end

  describe 'sanitize_children' do
    context 'when ghost urls are found' do
      it 'returns an xml response with cucumber.ghost.io urls changed to cucumber.io' do
        to_sanitize =
          '<?xml version="1.0" encoding="UTF-8"?>
          <?xml-stylesheet type="text/xsl" href="//cucumber.ghost.io/sitemap.xsl"?>
          <urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9" xmlns:image="http://www.google.com/schemas/sitemap-image/1.1">
             <url>
                <loc>https://cucumber.ghost.io/blog/alex-schladebeck-on-testing/</loc>
                <lastmod>2019-05-24T09:47:37.000Z</lastmod>
                <image:image>
                   <image:loc>https://cucumber.ghost.io/content/images/2019/05/alex-cukenfest.png</image:loc>
                   <image:caption>alex-cukenfest.png</image:caption>
                </image:image>
             </url>
             <url>
                <loc>https://cucumber.ghost.io/blog/illustrating-scenarios/</loc>
                <lastmod>2019-04-05T04:34:10.000Z</lastmod>
             </url>
          </urlset>'

        sanitized_xml =
          '<?xml version="1.0" encoding="UTF-8"?>
          <?xml-stylesheet type="text/xsl" href="//cucumber.io/sitemap.xsl"?>
          <urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9" xmlns:image="http://www.google.com/schemas/sitemap-image/1.1">
             <url>
                <loc>https://cucumber.io/blog/alex-schladebeck-on-testing/</loc>
                <lastmod>2019-05-24T09:47:37.000Z</lastmod>
                <image:image>
                   <image:loc>https://cucumber.io/content/images/2019/05/alex-cukenfest.png</image:loc>
                   <image:caption>alex-cukenfest.png</image:caption>
                </image:image>
             </url>
             <url>
                <loc>https://cucumber.io/blog/illustrating-scenarios/</loc>
                <lastmod>2019-04-05T04:34:10.000Z</lastmod>
             </url>
          </urlset>'

        input = [
          { 'loc' => 'https://cucumber.ghost.io/sitemap-posts.xml', 'body' => to_sanitize }
        ]

        expected = [
          { 'loc' => 'https://cucumber.ghost.io/sitemap-posts.xml', 'body' => sanitized_xml }
        ]

        g = Generator.new
        actual = g.sanitize_children(input)

        expect(actual).to eq expected
      end
    end

    context 'when squarespace urls are found' do
      it 'returns an xml response with cucumber-website.squarespace.com urls changed to cucumber.io' do
        to_sanitize =
          '<?xml version="1.0" encoding="UTF-8"?>
          <urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9" xmlns:image="http://www.google.com/schemas/sitemap-image/1.1">
             <url>
                <loc>https://cucumber-website.squarespace.com/events</loc>
                <changefreq>daily</changefreq>
                <priority>0.75</priority>
                <lastmod>2018-11-30</lastmod>
             </url>
             <url>
                <loc>https://cucumber-website.squarespace.com/events/2018/10/18/bdd-kickstart-austin</loc>
                <changefreq>monthly</changefreq>
                <priority>0.5</priority>
                <lastmod>2018-10-01</lastmod>
                <image:image>
                   <image:loc>https://static1.squarespace.com/static/5b64cabf5b409bbf05dbd8b3/t/5b8fadd8575d1fff85ece624/1536142911046/ryan-marsh.JPG</image:loc>
                   <image:title>Events - BDD Kickstart, Austin</image:title>
                   <image:caption>Ryan Marsh Ryan Marsh is an agile coach, trainer, and hacker who works with enterprise software development teams to help them be their very best. Ryan believes enterprise software development can be fun, rewarding, and move at high speed no matter the industry. Ryan has helped technology teams supercharge their development at some of America’s most well-known companies. Ryan is a self taught hacker with a broad background in technology. Ryan leverages this unique experience to help teams reach their full potential. Ryan can be found on Twitter, @ryan_marsh</image:caption>
                </image:image>
                <image:image>
                   <image:loc>https://static1.squarespace.com/static/5b64cabf5b409bbf05dbd8b3/t/5b8fad55352f53909ed52c75/1536057610588/Cukenfest+2018-1681.jpg</image:loc>
                   <image:title>Events - BDD Kickstart, Austin</image:title>
                </image:image>
             </url>
          </urlset>'

        sanitized_xml =
          '<?xml version="1.0" encoding="UTF-8"?>
          <urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9" xmlns:image="http://www.google.com/schemas/sitemap-image/1.1">
             <url>
                <loc>https://cucumber.io/events</loc>
                <changefreq>daily</changefreq>
                <priority>0.75</priority>
                <lastmod>2018-11-30</lastmod>
             </url>
             <url>
                <loc>https://cucumber.io/events/2018/10/18/bdd-kickstart-austin</loc>
                <changefreq>monthly</changefreq>
                <priority>0.5</priority>
                <lastmod>2018-10-01</lastmod>
                <image:image>
                   <image:loc>https://static1.squarespace.com/static/5b64cabf5b409bbf05dbd8b3/t/5b8fadd8575d1fff85ece624/1536142911046/ryan-marsh.JPG</image:loc>
                   <image:title>Events - BDD Kickstart, Austin</image:title>
                   <image:caption>Ryan Marsh Ryan Marsh is an agile coach, trainer, and hacker who works with enterprise software development teams to help them be their very best. Ryan believes enterprise software development can be fun, rewarding, and move at high speed no matter the industry. Ryan has helped technology teams supercharge their development at some of America’s most well-known companies. Ryan is a self taught hacker with a broad background in technology. Ryan leverages this unique experience to help teams reach their full potential. Ryan can be found on Twitter, @ryan_marsh</image:caption>
                </image:image>
                <image:image>
                   <image:loc>https://static1.squarespace.com/static/5b64cabf5b409bbf05dbd8b3/t/5b8fad55352f53909ed52c75/1536057610588/Cukenfest+2018-1681.jpg</image:loc>
                   <image:title>Events - BDD Kickstart, Austin</image:title>
                </image:image>
             </url>
          </urlset>'

        input = [{ 'loc' => 'https://cucumber-website.squarespace.com/sitemap.xml', 'body' => to_sanitize }]
        expected = [{ 'loc' => 'https://cucumber-website.squarespace.com/sitemap.xml', 'body' => sanitized_xml }]

        g = Generator.new
        actual = g.sanitize_children(input)

        expect(actual).to eq expected
      end
    end
  end

  describe 'write_children' do
    it 'writes the provided children to disk' do
      input_xml =
        '<?xml version="1.0" encoding="UTF-8"?>
        <urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9" xmlns:image="http://www.google.com/schemas/sitemap-image/1.1">
           <url>
              <loc>https://cucumber.io/events</loc>
              <changefreq>daily</changefreq>
              <priority>0.75</priority>
              <lastmod>2018-11-30</lastmod>
           </url>
           <url>
              <loc>https://cucumber.io/events/2018/10/18/bdd-kickstart-austin</loc>
              <changefreq>monthly</changefreq>
              <priority>0.5</priority>
              <lastmod>2018-10-01</lastmod>
              <image:image>
                 <image:loc>https://static1.squarespace.com/static/5b64cabf5b409bbf05dbd8b3/t/5b8fadd8575d1fff85ece624/1536142911046/ryan-marsh.JPG</image:loc>
                 <image:title>Events - BDD Kickstart, Austin</image:title>
                 <image:caption>Ryan Marsh Ryan Marsh is an agile coach, trainer, and hacker who works with enterprise software development teams to help them be their very best. Ryan believes enterprise software development can be fun, rewarding, and move at high speed no matter the industry. Ryan has helped technology teams supercharge their development at some of America’s most well-known companies. Ryan is a self taught hacker with a broad background in technology. Ryan leverages this unique experience to help teams reach their full potential. Ryan can be found on Twitter, @ryan_marsh</image:caption>
              </image:image>
              <image:image>
                 <image:loc>https://static1.squarespace.com/static/5b64cabf5b409bbf05dbd8b3/t/5b8fad55352f53909ed52c75/1536057610588/Cukenfest+2018-1681.jpg</image:loc>
                 <image:title>Events - BDD Kickstart, Austin</image:title>
              </image:image>
           </url>
        </urlset>'
      input = [{ 'loc' => 'https://cucumber-website.squarespace.com/sitemap.xml', 'body' => input_xml }]

      g = Generator.new
      g.write_children(input, './temp')

      expect(File.exist?('./temp/sitemap.xml')).to eq true
      expect(File.read('./temp/sitemap.xml')).to eq input_xml
    end
  end
end
