# Google App Engine doesn't support achors and alias feature of YAML
# Psych doesn't provide an option to disable achors/alias YAML features
#
# HACK: subclass the native YAMLTree, and bypass logic which checks for aliases
# ../psych/vistors/yaml_tree.rb
class GoogleYAMLTree < Psych::Visitors::YAMLTree
  def accept target
    # HACK: disabled alias lookup nuking the instance variable
    @st.instance_variable_set('@obj_to_node', {})
    super
  end
end
