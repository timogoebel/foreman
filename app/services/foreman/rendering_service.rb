require 'tempfile'

module Foreman
  class RenderingService
    attr_reader :subjects

    def initialize(subjects: {})
      @subjects = subjects
    end

    def unattended_render(template, overridden_name = nil, scope_variables = {})
      @template_name = template.respond_to?(:name) ? template.name : (overridden_name || 'Unnamed')
      template_logger.info "Rendering template '#{@template_name}'"
      raise ::Foreman::Exception.new(N_("Template '%s' is either missing or has an invalid organization or location"), @template_name) if template.nil?
      content = template.respond_to?(:template) ? template.template : template
      #allowed_variables = allowed_variables_mapping(ALLOWED_VARIABLES)
      #render_safe content, ALLOWED_HELPERS, allowed_variables, scope_variables

      TemplateRenderer.new(template: content, subjects: subjects)
    end

    # TODO: id won't work anymore
    def unattended_render_to_temp_file(content, prefix = id.to_s, options = {})
      file = ""
      Tempfile.open(prefix, Rails.root.join('tmp')) do |f|
        f.print(unattended_render(content))
        f.flush
        f.chmod options[:mode] if options[:mode]
        file = f
      end
      file
    end

    private

    def template_logger
      @template_logger ||= Foreman::Logging.logger('templates')
    end
  end
end
