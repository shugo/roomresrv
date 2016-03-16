require "redcarpet"

module ActionView
  class Template
    module Handlers
      class Markdown
        class_attribute :default_format
        self.default_format = Mime::HTML

        def initialize
          @markdown = Redcarpet::Markdown.new(Redcarpet::Render::HTML,
                                              autolink: true,
                                              space_after_headers: true)
        end

        def call(template)
          @markdown.render(template.source).dump + ".html_safe"
        end
      end
    end
  end
end

markdown = ActionView::Template::Handlers::Markdown.new
ActionView::Template.register_template_handler(:md, markdown)
