require 'fileutils'

module Jekyll

  class GoogleYAMLTree < Psych::Visitors::YAMLTree
    def accept target
      if target.respond_to?(:to_yaml)
        begin
          loc = target.method(:to_yaml).source_location.first
          if loc !~ /(syck\/rubytypes.rb|psych\/core_ext.rb)/
            unless target.respond_to?(:encode_with)
              if $VERBOSE
                warn "implementing to_yaml is deprecated, please implement \"encode_with\""
              end

              target.to_yaml(:nodump => true)
            end
          end
        rescue
          # public_method or source_location might be overridden,
          # and it's OK to skip it since it's only to emit a warning
        end
      end

      if target.respond_to?(:encode_with)
        dump_coder target
      else
        send(@dispatch_cache[target.class], target)
      end
    end
  end

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
      @app_engine = site.config["app_engine"]

      unless app_yaml_exists?
        unless @app_engine["base"] or source_partial_exists?
          raise "App engine base configration not found"
        end

        write
        @site.keep_files ||= []
        @site.keep_files << "app.yaml"
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
      builder = GoogleYAMLTree.create
      builder << generate_app_engine_yaml

      app_yaml = PageWithoutAFile.new(@site, File.dirname(__FILE__), "", "app.yaml")
      app_yaml.content = builder.tree.yaml
      app_yaml.data["layout"] = nil
      app_yaml.render({}, @site.site_payload)
      return app_yaml.output
    end

    def generate_app_engine_yaml
      if source_partial_exists?
        app_yaml = YAML.load_file(source_path)
      else
        app_yaml = @app_engine["base"].dup
      end

      app_yaml["handlers"] ||= []

      generate_handlers("posts", @site.posts.docs).each { |handler| app_yaml["handlers"] << handler }
      generate_handlers("pages", @site.pages).each { |handler| app_yaml["handlers"] << handler }

      @site.collections.each_pair do |label, collection|
        unless label == "posts"
          generate_handlers("collections", collection.docs).each { |handler| app_yaml["handlers"] << handler }
        end
      end

      generate_handlers("static", @site.static_files).each { |handler| app_yaml["handlers"] << handler }

      return app_yaml
    end

    def generate_handlers(content_type, collection)
      handlers = []

      handler_template = @app_engine["handlers"][content_type] || {}
      if handler_template.kind_of?(Array) or handler_template.has_key?("url")
        handlers << handler_template
      else
        collection.each do |doc|
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
