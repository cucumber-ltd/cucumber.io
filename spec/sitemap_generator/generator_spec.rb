# frozen_string_literal: true

require 'time'
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

      it 'excludes /sitemap-pages.xml from being included in the list to update' do
        ghost_parent = xml('<?xml version="1.0" encoding="UTF-8"?><?xml-stylesheet type="text/xsl" href="//cucumber.ghost.io/sitemap.xsl"?>
        <sitemapindex xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">
          <sitemap>
            <loc>https://cucumber.ghost.io/sitemap-pages.xml</loc>
            <lastmod>2019-05-10T15:19:50.801Z</lastmod>
          </sitemap>
        </sitemapindex>')

        cuke_parent = xml('<?xml version="1.0" encoding="UTF-8"?><?xml-stylesheet type="text/xsl" href="//cucumber.io/sitemap.xsl"?>
          <sitemapindex xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">
            <sitemap>
              <loc>https://cucumber.io/sitemap-pages.xml</loc>
              <lastmod>2019-04-10T15:19:50.801Z</lastmod>
            </sitemap>
          </sitemapindex>')

        g = Generator.new
        actual = g.find_children_to_update(ghost_parent, cuke_parent)

        expect(actual).to be_empty
      end
    end

    describe 'assumes that maps not found in our current map are new and must be added' do
      context 'when a new map is found' do
        it 'includes that map to be updated' do
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

  describe 'sanitize_rss' do
    it 'returns an xml response with various ghost urls changed to suitable cucumber.io ones' do
      to_sanitize =
        '<?xml version="1.0" encoding="UTF-8"?>
        <rss xmlns:atom="http://www.w3.org/2005/Atom" xmlns:content="http://purl.org/rss/1.0/modules/content/" xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:media="http://search.yahoo.com/mrss/" version="2.0">
           <channel>
              <title><![CDATA[Cucumber Blog]]></title>
              <description><![CDATA[Thoughts, stories and ideas.]]></description>
              <link>https://cucumber.ghost.io/</link>
              <image>
                 <url>https://cucumber.ghost.io/favicon.png</url>
                 <title>Cucumber Blog</title>
                 <link>https://cucumber.ghost.io/</link>
              </image>
              <generator>Ghost 2.23</generator>
              <lastBuildDate>Fri, 31 May 2019 23:53:35 GMT</lastBuildDate>
              <atom:link href="https://cucumber.ghost.io/rss/" rel="self" type="application/rss+xml" />
              <ttl>60</ttl>
              <item>
                 <title><![CDATA[Alex Schladebeck on Testing - Cucumber Podcast]]></title>
                 <description><![CDATA[<!--kg-card-begin: html--><iframe width="100%" height="166" scrolling="no" frameborder="no" allow="autoplay" src="https://w.soundcloud.com/player/?url=https%3A//api.soundcloud.com/tracks/625808718&color=%23ff5500&auto_play=false&hide_related=false&show_comments=true&show_user=true&show_reposts=false&show_teaser=true"></iframe><!--kg-card-end: html--><p>This month on the Cucumber Podcast we sit down with Alex Schladebeck who identifies as a Tester.</p><p><a href="https://twitter.com/SalFreudenberg">Sal Freudenberg</a> and <a href="https://twitter.com/tooky">Steve Tooke</a> - co-founders of Cucumber - ask her about her recent keynote appearance at <a href="http://cukenfest.cucumber.io">CukenFest London</a> as well as her thoughts on the role of modern testers on agile</p>]]></description>
                 <link>https://cucumber.ghost.io/blog/alex-schladebeck-on-testing/</link>
                 <guid isPermaLink="false">5ce7bb3658b27b00c085bed0</guid>
                 <dc:creator><![CDATA[Theo England]]></dc:creator>
                 <pubDate>Fri, 24 May 2019 09:47:37 GMT</pubDate>
                 <media:content url="https://cucumber.ghost.io/content/images/2019/05/alex-cukenfest.png" medium="image" />
                 <content:encoded><![CDATA[<!--kg-card-begin: html--><iframe width="100%" height="166" scrolling="no" frameborder="no" allow="autoplay" src="https://w.soundcloud.com/player/?url=https%3A//api.soundcloud.com/tracks/625808718&color=%23ff5500&auto_play=false&hide_related=false&show_comments=true&show_user=true&show_reposts=false&show_teaser=true"></iframe><!--kg-card-end: html--><img src="https://cucumber.ghost.io/content/images/2019/05/alex-cukenfest.png" alt="Alex Schladebeck on Testing - Cucumber Podcast"><p>This month on the Cucumber Podcast we sit down with Alex Schladebeck who identifies as a Tester.</p><p><a href="https://twitter.com/SalFreudenberg">Sal Freudenberg</a> and <a href="https://twitter.com/tooky">Steve Tooke</a> - co-founders of Cucumber - ask her about her recent keynote appearance at <a href="http://cukenfest.cucumber.io">CukenFest London</a> as well as her thoughts on the role of modern testers on agile teams.</p><p>Alex can be found on <a href="https://cucumber.ghost.io/blog/alex-schladebeck-on-testing/twitter.com/alex_schl">Twitter</a>. Alex works for <a href="https://www.bredex.de/en/services">Bredex</a> a software consultancy shop based in Germany. </p>]]></content:encoded>
              </item>
           </channel>
        </rss>'

      expected =
        '<?xml version="1.0" encoding="UTF-8"?>
        <rss xmlns:atom="http://www.w3.org/2005/Atom" xmlns:content="http://purl.org/rss/1.0/modules/content/" xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:media="http://search.yahoo.com/mrss/" version="2.0">
           <channel>
              <title><![CDATA[Cucumber Blog]]></title>
              <description><![CDATA[Thoughts, stories and ideas.]]></description>
              <link>https://cucumber.io/</link>
              <image>
                 <url>https://cucumber.io/favicon.png</url>
                 <title>Cucumber Blog</title>
                 <link>https://cucumber.io/</link>
              </image>
              <generator>Ghost 2.23</generator>
              <lastBuildDate>Fri, 31 May 2019 23:53:35 GMT</lastBuildDate>
              <atom:link href="https://cucumber.io/rss/" rel="self" type="application/rss+xml" />
              <ttl>60</ttl>
              <item>
                 <title><![CDATA[Alex Schladebeck on Testing - Cucumber Podcast]]></title>
                 <description><![CDATA[<!--kg-card-begin: html--><iframe width="100%" height="166" scrolling="no" frameborder="no" allow="autoplay" src="https://w.soundcloud.com/player/?url=https%3A//api.soundcloud.com/tracks/625808718&color=%23ff5500&auto_play=false&hide_related=false&show_comments=true&show_user=true&show_reposts=false&show_teaser=true"></iframe><!--kg-card-end: html--><p>This month on the Cucumber Podcast we sit down with Alex Schladebeck who identifies as a Tester.</p><p><a href="https://twitter.com/SalFreudenberg">Sal Freudenberg</a> and <a href="https://twitter.com/tooky">Steve Tooke</a> - co-founders of Cucumber - ask her about her recent keynote appearance at <a href="http://cukenfest.cucumber.io">CukenFest London</a> as well as her thoughts on the role of modern testers on agile</p>]]></description>
                 <link>https://cucumber.io/blog/alex-schladebeck-on-testing/</link>
                 <guid isPermaLink="false">5ce7bb3658b27b00c085bed0</guid>
                 <dc:creator><![CDATA[Theo England]]></dc:creator>
                 <pubDate>Fri, 24 May 2019 09:47:37 GMT</pubDate>
                 <media:content url="https://cucumber.io/images/2019/05/alex-cukenfest.png" medium="image" />
                 <content:encoded><![CDATA[<!--kg-card-begin: html--><iframe width="100%" height="166" scrolling="no" frameborder="no" allow="autoplay" src="https://w.soundcloud.com/player/?url=https%3A//api.soundcloud.com/tracks/625808718&color=%23ff5500&auto_play=false&hide_related=false&show_comments=true&show_user=true&show_reposts=false&show_teaser=true"></iframe><!--kg-card-end: html--><img src="https://cucumber.io/images/2019/05/alex-cukenfest.png" alt="Alex Schladebeck on Testing - Cucumber Podcast"><p>This month on the Cucumber Podcast we sit down with Alex Schladebeck who identifies as a Tester.</p><p><a href="https://twitter.com/SalFreudenberg">Sal Freudenberg</a> and <a href="https://twitter.com/tooky">Steve Tooke</a> - co-founders of Cucumber - ask her about her recent keynote appearance at <a href="http://cukenfest.cucumber.io">CukenFest London</a> as well as her thoughts on the role of modern testers on agile teams.</p><p>Alex can be found on <a href="https://cucumber.io/blog/alex-schladebeck-on-testing/twitter.com/alex_schl">Twitter</a>. Alex works for <a href="https://www.bredex.de/en/services">Bredex</a> a software consultancy shop based in Germany. </p>]]></content:encoded>
              </item>
           </channel>
        </rss>'

      sanitize_map = [
        ['cucumber.ghost.io/blog/', 'cucumber.io/blog/'],
        ['cucumber.ghost.io/content/', 'cucumber.io/'],
        ['cucumber.ghost.io/', 'cucumber.io/']
      ]

      g = Generator.new
      actual = g.sanitize_rss(to_sanitize, sanitize_map)

      expect(actual).to eq expected
    end
  end

  describe 'update_pages_map' do
    it 'adds our docs and blog pages to the sitemap' do
      input_xml_string =
        '<?xml version="1.0" encoding="UTF-8"?>
        <?xml-stylesheet type="text/xsl" href="//cucumber.io/sitemap.xsl"?>
        <urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9" xmlns:image="http://www.google.com/schemas/sitemap-image/1.1">
           <url>
              <loc>https://cucumber.io/events</loc>
              <changefreq>monthly</changefreq>
              <priority>0.75</priority>
              <lastmod>2018-11-30</lastmod>
           </url>
        </urlset>'

      expected_xml_string =
        '<?xml version="1.0" encoding="UTF-8"?>
          <?xml-stylesheet type="text/xsl" href="//cucumber.io/sitemap.xsl"?>
          <urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9" xmlns:image="http://www.google.com/schemas/sitemap-image/1.1">
             <url>
                <loc>https://cucumber.io/blog</loc>
                <changefreq>weekly</changefreq>
                <priority>0.75</priority>
                <lastmod>2019-05-26</lastmod>
             </url>
             <url>
                <loc>https://cucumber.io/docs</loc>
                <changefreq>weekly</changefreq>
                <priority>0.75</priority>
                <lastmod>2019-05-26</lastmod>
             </url>
             <url>
                <loc>https://cucumber.io/events</loc>
                <changefreq>monthly</changefreq>
                <priority>0.75</priority>
                <lastmod>2018-11-30</lastmod>
             </url>
          </urlset>'

      input = [
        { 'loc' => 'https://cucumber.ghost.io/sitemap-authors.xml', 'body' => 'foo' },
        { 'loc' => 'https://cucumber-website.squarespace.com/sitemap.xml', 'body' => input_xml_string }
      ]

      expected = [
        { 'loc' => 'https://cucumber.ghost.io/sitemap-authors.xml', 'body' => 'foo' },
        { 'loc' => 'https://cucumber-website.squarespace.com/sitemap.xml', 'body' => expected_xml_string }
      ]

      g = Generator.new
      actual = g.update_pages_map(input, '2019-05-26')

      expect(xml(actual[1]['body']).to_s).to eq xml(expected[1]['body']).to_s
    end
  end

  describe 'write_children' do
    it 'writes the provided children to disk' do
      posts_xml =
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
      authors_xml = '<?xml version="1.0" encoding="UTF-8"?>
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
      input = [{ 'loc' => 'https://cucumber.ghost.io/sitemap-posts.xml', 'body' => posts_xml },
               { 'loc' => 'https://cucumber.ghost.io/sitemap-authors.xml', 'body' => authors_xml }]

      g = Generator.new
      actual = g.write_children(input, './temp')

      expect(actual).to eq ['/sitemap-posts.xml', '/sitemap-authors.xml']
      expect(File.exist?('./temp/sitemap-posts.xml')).to eq true
      expect(File.read('./temp/sitemap-posts.xml')).to eq posts_xml
      expect(File.exist?('./temp/sitemap-authors.xml')).to eq true
      expect(File.read('./temp/sitemap-authors.xml')).to eq authors_xml
    end

    context 'when the squarespace provided sitemap.xml is to be written' do
      it 'uses the path /sitemap-pages.xml instead' do
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
        actual = g.write_children(input, './temp')

        expect(actual).to eq ['/sitemap-pages.xml']
        expect(File.exist?('./temp/sitemap-pages.xml')).to eq true
        expect(File.read('./temp/sitemap-pages.xml')).to eq input_xml
      end
    end
  end

  describe 'update_parent' do
    it 'updates the last modified date of the children that have been passed in' do
      input_xml = xml('<?xml version="1.0" encoding="UTF-8"?><?xml-stylesheet type="text/xsl" href="//cucumber.io/sitemap.xsl"?>
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
      children = ['/sitemap-pages.xml', '/sitemap-posts.xml', '/sitemap-tags.xml']

      g = Generator.new
      actual = g.update_parent(input_xml, children)

      updated_data = g.local_cuke_data(actual)
      input_data = g.local_cuke_data(input_xml)

      children.each do |child|
        expect(updated_data[child]).to be > input_data[child]
      end
      expect(updated_data['/sitemap-authors.xml']).to eq Date.parse('2019-04-18T03:21:26.896Z')
    end

    context 'when a new child is passed in' do
      it 'writes a new entry to the parent' do
        input_xml = xml('<?xml version="1.0" encoding="UTF-8"?><?xml-stylesheet type="text/xsl" href="//cucumber.io/sitemap.xsl"?>
          <sitemapindex xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">
            <sitemap>
              <loc>https://cucumber.io/sitemap-pages.xml</loc>
              <lastmod>2019-04-10T15:19:50.801Z</lastmod>
            </sitemap>
          </sitemapindex>')
        children = ['/sitemap-posts.xml', '/sitemap-tags.xml']

        g = Generator.new
        actual = g.update_parent(input_xml, children)

        updated_data = g.local_cuke_data(actual)
        children.each do |child|
          expect(updated_data[child]).not_to be_nil
        end
      end
    end
  end

  describe 'update_generator' do
    it 'adds Cucumber to the generator element' do
      to_sanitize =
        '<?xml version="1.0" encoding="UTF-8"?>
        <rss xmlns:atom="http://www.w3.org/2005/Atom" xmlns:content="http://purl.org/rss/1.0/modules/content/" xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:media="http://search.yahoo.com/mrss/" version="2.0">
           <channel>
              <generator>Ghost 2.23</generator>
           </channel>
        </rss>'

      expected =
        xml('<?xml version="1.0" encoding="UTF-8"?>
        <rss xmlns:atom="http://www.w3.org/2005/Atom" xmlns:content="http://purl.org/rss/1.0/modules/content/" xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:media="http://search.yahoo.com/mrss/" version="2.0">
          <channel>
            <generator>Ghost 2.23 &amp; Cucumber</generator>
          </channel>
        </rss>').to_s

      g = Generator.new
      actual = g.update_generator(to_sanitize)

      expect(actual).to eq expected
    end
  end

  describe 'last_mod_time' do
    it 'returns the last modified date returned via a head request' do
      expected = Time.parse('Sat, 01 Jun 2019 04:15:44 GMT')

      stub_request(:head, 'https://cucumber.ghost.io/sitemap.xml')
        .to_return(headers: { 'last-modified' => expected })

      g = Generator.new
      actual = g.last_mod_time('https://cucumber.ghost.io/sitemap.xml')

      expect(actual).to eq expected
    end
  end
end
