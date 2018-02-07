# This class renders a Template
# Usage:
# template = Template.find(123)
# host = Host.find(123) # or self
# TemplateRenderer.new(template: template, subjects: { host: host })
#
class TemplateRenderer
  attr_reader :scope, :subjects

  def initialize(template:, subjects: {})
    @scope = Scope.new
    @subjects = subjects
  end

  class Scope
    def get_binding
      binding
    end

    def foreman_server_fqdn
      config = URI.parse(Setting[:foreman_url])
      config.host
    end

    def foreman_server_url
      Setting[:foreman_url]
    end

    [:debug, :info, :warn, :error, :fatal].each do |level|
      define_method("log_#{level}".to_sym) do |msg|
        template_logger.send(level, msg) if msg.present?
      end
    end

    # TODO: add more scope variables
    # TODO: add subject variables + accessors
    # TODO: add template.inputs accessors when that's available
    # TODO: logger
  end

  def render
    # TODO: use polymorphism
    if safe_mode_rendering?
      render_with_safemode
    else
      render_without_safemode
    end
    # TODO: rescue
  end

  def render_with_safemode
    box = Safemode::Box.new(scope, allowed_methods, template_name)
    erb = ERB.new(template, nil, '-')
    box.eval(erb.src, allowed_vars.merge(scope_variables))
  end

  def render_without_safemode
    # we need to keep scope variables and reset them after rendering otherwise they would remain
    # after snippets are rendered in parent template scope
    #kept_variables = {}
    #scope_variables.each { |k,v| kept_variables[k] = instance_variable_get("@#{k}") }

    #allowed_vars.merge(scope_variables).each { |k,v| instance_variable_set "@#{k}", v }
    erb = ERB.new(template, nil, '-')
    # erb allows to set location since Ruby 2.2
    erb.location = template_name, 0 if erb.respond_to?(:location=)
    result = erb.result(scope.get_binding)

    #scope_variables.each { |k,v| instance_variable_set "@#{k}", kept_variables[k] }
    result
  end

  def allowed_methods
    subjects.keys
  end

  private

  def safe_mode_rendering?
    Setting[:safemode_render]
  end
end
