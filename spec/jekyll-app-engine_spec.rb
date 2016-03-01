# encoding: UTF-8

require 'spec_helper'

describe(Jekyll::JekyllAppEngine) do
  let(:overrides) do
    {
      "source"      => source_dir,
      "destination" => dest_dir,
      "url"         => "http://example.org",
      "collections" => {
        "my_collection" => { "output" => true },
        "other_things"  => { "output" => false }
      }
    }
  end
  let(:config) do
    Jekyll.configuration(overrides)
  end
  let(:site)     { Jekyll::Site.new(config) }
  let(:contents) { File.read(dest_dir("app.yaml")) }
  let(:handlers) { YAML.load_file(dest_dir("app.yaml"))["handlers"] }
  before(:each) do
    site.process
  end

  it "has no layout" do
    expect(contents).not_to match(/\ATHIS IS MY LAYOUT/)
  end

  it "creates an app.yaml file" do
    expect(File.exist?(dest_dir("app.yaml"))).to be_truthy
  end

  it "doesn't have multiple new lines or trailing whitespace" do
    expect(contents).to_not match /\s+\n/
    expect(contents).to_not match /\n{2,}/
  end

  it "puts all the pages in the app.yaml file" do
    expect(handlers).to include({
      "url"          => "/",
      "static_files" => "spec/dest/index.html",
      "upload"       => "spec/dest/index.html"
    })
    expect(handlers).to include({
      "url"          => "/some-subfolder/this-is-a-subpage.html",
      "static_files" => "spec/dest/some-subfolder/this-is-a-subpage.html",
      "upload"       => "spec/dest/some-subfolder/this-is-a-subpage.html"
    })
  end

  it "only strips 'index.html' from end of permalink" do
    expect(handlers).to include({
      "url"          => "/some-subfolder/test_index.html",
      "static_files" => "spec/dest/some-subfolder/test_index.html",
      "upload"       => "spec/dest/some-subfolder/test_index.html"
    })
  end

  it "puts all the posts in the app.yaml file" do
    expect(handlers).to include({
      "url"          => "/2013/12/12/dec-the-second.html",
      "static_files" => "spec/dest/2013/12/12/dec-the-second.html",
      "upload"       => "spec/dest/2013/12/12/dec-the-second.html",
      "http_headers" => {
              "Link" => "</static/css/style.css>; rel=preload; as=style"
      }
    })
    expect(handlers).to include({
      "url"          => "/2014/03/02/march-the-second.html",
      "static_files" => "spec/dest/2014/03/02/march-the-second.html",
      "upload"       => "spec/dest/2014/03/02/march-the-second.html",
      "http_headers" => {
              "Link" => "</static/css/style.css>; rel=preload; as=style"
      }
    })
    expect(handlers).to include({
      "url"          => "/2014/03/04/march-the-fourth.html",
      "static_files" => "spec/dest/2014/03/04/march-the-fourth.html",
      "upload"       => "spec/dest/2014/03/04/march-the-fourth.html",
      "http_headers" => {
              "Link" => "</static/css/style.css>; rel=preload; as=style"
      }
    })
  end

  # describe "collections" do
  #   it "puts all the `output:true` into app.yaml" do
  #     expect(contents).to match /<loc>http:\/\/example\.org\/my_collection\/test\.html<\/loc>/
  #   end
  #
  #   it "doesn't put all the `output:false` into app.yaml" do
  #     expect(contents).to_not match /<loc>http:\/\/example\.org\/other_things\/test2\.html<\/loc>/
  #   end
  #
  #   it "remove 'index.html' for directory custom permalinks" do
  #     expect(contents).to match /<loc>http:\/\/example\.org\/permalink\/<\/loc>/
  #   end
  #
  #   it "doesn't remove filename for non-directory custom permalinks" do
  #     expect(contents).to match /<loc>http:\/\/example\.org\/permalink\/unique_name\.html<\/loc>/
  #   end
  #
  #   it "performs URI encoding of site paths" do
  #     expect(contents).to match /<loc>http:\/\/example\.org\/this%20url%20has%20an%20%C3%BCmlaut<\/loc>/
  #   end
  # end

  it "puts all the static HTML files in the app.yaml file" do
    expect(handlers).to include({
      "url"          => "/some-subfolder/this-is-a-subfile.html",
      "static_files" => "spec/dest/some-subfolder/this-is-a-subfile.html",
      "upload"       => "spec/dest/some-subfolder/this-is-a-subfile.html"
    })
  end

  # it "does not include assets or any static files that aren't .html" do
  #   expect(contents).not_to match /<loc>http:\/\/example\.org\/images\/hubot\.png<\/loc>/
  #   expect(contents).not_to match /<loc>http:\/\/example\.org\/feeds\/atom\.xml<\/loc>/
  # end
  #
  # it "does include assets or any static files with .xhtml and .htm extensions" do
  #   expect(contents).to match /\/some-subfolder\/xhtml\.xhtml/
  #   expect(contents).to match /\/some-subfolder\/htm\.htm/
  # end

  it "includes the correct number of items" do
    expect(handlers.length).to eql 18
  end

  # context "with a baseurl" do
  #   let(:config) do
  #     Jekyll.configuration(Jekyll::Utils.deep_merge_hashes(overrides, {"baseurl" => "/bass"}))
  #   end
  #
  #   it "correctly adds the baseurl to the static files" do
  #     expect(contents).to match /<loc>http:\/\/example\.org\/bass\/some-subfolder\/this-is-a-subfile\.html<\/loc>/
  #   end
  #
  #   it "correctly adds the baseurl to the collections" do
  #     expect(contents).to match /<loc>http:\/\/example\.org\/bass\/my_collection\/test\.html<\/loc>/
  #   end
  #
  #   it "correctly adds the baseurl to the pages" do
  #     expect(contents).to match /<loc>http:\/\/example\.org\/bass\/<\/loc>/
  #     expect(contents).to match /<loc>http:\/\/example\.org\/bass\/some-subfolder\/this-is-a-subpage\.html<\/loc>/
  #   end
  #
  #   it "correctly adds the baseurl to the posts" do
  #     expect(contents).to match /<loc>http:\/\/example\.org\/bass\/2014\/03\/04\/march-the-fourth\.html<\/loc>/
  #     expect(contents).to match /<loc>http:\/\/example\.org\/bass\/2014\/03\/02\/march-the-second\.html<\/loc>/
  #     expect(contents).to match /<loc>http:\/\/example\.org\/bass\/2013\/12\/12\/dec-the-second\.html<\/loc>/
  #   end
  # end
end
