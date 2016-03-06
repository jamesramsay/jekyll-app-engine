# Google App Engine doesn't support achors and alias feature of YAML
# Psych doesn't provide an option to disable achors/alias YAML features
#
# HACK: subclass the native YAMLTree, and bypass logic which checks for aliases
# ../psych/vistors/yaml_tree.rb
class GoogleYAMLTree < Psych::Visitors::YAMLTree
  def accept target
    # HACK: disabled alias lookup
    # return any aliases we find
    # if @st.key? target
    #   oid         = @st.id_for target
    #   node        = @st.node_for target
    #   anchor      = oid.to_s
    #   node.anchor = anchor
    #   return @emitter.alias anchor
    # end

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
