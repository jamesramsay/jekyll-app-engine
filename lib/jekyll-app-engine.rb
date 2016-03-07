require 'fileutils'
require 'google-yaml'

module Jekyll

  class PageWithoutAFile < Page
    def read_yaml(*)
      @data ||= {}
    end
  end

  class JekyllAppEngine < Jekyll::Generator
    safe true
    priority :lowest

    # Main plugin action, called by Jekyll-core
    def generate(site)
      @site = site
      @app_engine = source_config

      unless app_yaml_exists?
        unless @app_engine
          raise "App engine base configration not found"
        end

        @app_engine["handlers"] ||= {}

        write
        @site.keep_files ||= []
        @site.keep_files << "app.yaml"
      end
    end

    def source_config
      if @site.config.has_key?("app_engine")
        @site.config["app_engine"]
      elsif source_partial_exists?
        YAML.load_file(source_path)
      end
    end

    # Checks if a optional _app.yaml partial already exists
    def source_partial_exists?
      if @site.respond_to?(:in_source_dir)
        File.exists? @site.in_source_dir("_app.yaml")
      else
        File.exists? Jekyll.sanitized_path(@site.source, "_app.yaml")
      end
    end

    # Path to optional _app.yaml partial
    def source_path
      if @site.respond_to?(:in_source_dir)
        @site.in_source_dir("_app.yaml")
      else
        Jekyll.sanitized_path(@site.source, "_app.yaml")
      end
    end

    # Destination for app.yaml file within the site source directory
    def destination_path
      if @site.respond_to?(:in_dest_dir)
        @site.in_dest_dir("app.yaml")
      else
        Jekyll.sanitized_path(@site.dest, "app.yaml")
      end
    end

    def write
      FileUtils.mkdir_p File.dirname(destination_path)
      File.open(destination_path, 'w') { |f| f.write(app_yaml_content) }
    end

    def app_yaml_content
      # HACK: use sub-classed YAML implementation which disables anchors and aliases
      builder = GoogleYAMLTree.create
      builder << generate_app_engine_yaml

      app_yaml = PageWithoutAFile.new(@site, File.dirname(__FILE__), "", "app.yaml")
      app_yaml.content = builder.tree.yaml
      app_yaml.data["layout"] = nil
      app_yaml.render({}, @site.site_payload)
      return app_yaml.output
    end

    def output_collection?(label)
      @site.config["collections"]["#{label}"]["output"]
    end

    def page_types
      page_types_array = [
        {
          "content_type" => "posts",
          "content_collection" => @site.posts.docs
        },
        {
          "content_type" => "pages",
          "content_collection" => @site.pages
        },
        {
          "content_type" => "static",
          "content_collection" => @site.static_files
        },
      ]

      @site.collections.each_pair do |label, collection|
        if label != "posts" and output_collection?(label)
          page_types_array << {
            "content_type" => "collections",
            "content_collection" => collection.docs
          }
        end
      end

      return page_types_array
    end

    def generate_app_engine_yaml
      app_yaml = @app_engine.dup
      generated_handlers = []

      page_types.each do |content|
        generate_handlers(content).each { |handler| generated_handlers << handler }
      end

      app_yaml["handlers"] = generated_handlers

      return app_yaml
    end

    def generate_handlers(content)
      content_type = content["content_type"]
      content_collection = content["content_collection"]
      handlers = []

      handler_template = @app_engine["handlers"][content_type] || {}
      if handler_template.kind_of?(Array) or handler_template.has_key?("url")
        handlers << handler_template
      else
        content_collection.each do |doc|
          handler = {
            "url" => doc.url,
            "static_files" => doc.destination("").sub("#{Dir.pwd}/", ""),
            "upload" => doc.destination("").sub("#{Dir.pwd}/", "")
          }
          handlers << handler.merge!(handler_template.dup).merge!(document_overrides(doc))
        end
      end

      return handlers
    end

    # Document specific app.yaml configuration provided in yaml frontmatter
    def document_overrides(document)
      if document.respond_to?(:data) and document.data.has_key?("app_engine")
        document.data.fetch("app_engine")
      else
        {}
      end
    end

    # Checks if a app.yaml already exists in the site source
    def app_yaml_exists?
      if @site.respond_to?(:in_source_dir)
        File.exists? @site.in_source_dir("app.yaml")
      else
        File.exists? Jekyll.sanitized_path(@site.source, "app.yaml")
      end
    end
  end
end
