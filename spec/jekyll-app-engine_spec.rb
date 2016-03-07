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
  let(:app_yaml) { YAML.load_file(dest_dir("app.yaml")) }
  let(:handlers) { app_yaml["handlers"] }
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
      "upload"       => "spec/dest/index.html",
      "http_headers" => {
        "Cache-Control" => "max-age=3600"
      }
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

  describe "collections" do
    it "puts all the `output:true` into app.yaml" do
      expect(handlers).to include({
        "url"          => "/my_collection/test.html",
        "static_files" => "spec/dest/my_collection/test.html",
        "upload"       => "spec/dest/my_collection/test.html"
      })
    end

    it "doesn't put all the `output:false` into app.yaml" do
      expect(contents).to_not match /\/other_things\/test2\.html/
    end
  end

  it "puts all the static HTML files in the app.yaml file" do
    expect(handlers).to include({
      "url"          => "/some-subfolder/this-is-a-subfile.html",
      "static_files" => "spec/dest/some-subfolder/this-is-a-subfile.html",
      "upload"       => "spec/dest/some-subfolder/this-is-a-subfile.html"
    })
  end

  it "includes the correct number of items" do
    expect(handlers.length).to eql 17
  end

  context "with a base in _config.yml" do
    let(:config) do
      config_override = { "app_engine" => {
        "runtime" => "python27",
        "api_version" => 1
      } }
      Jekyll.configuration(Jekyll::Utils.deep_merge_hashes(overrides, config_override))
    end

    it "correctly uses _config.yml runtime" do
      expect(app_yaml["runtime"]).to eql "python27"
    end
  end
end
