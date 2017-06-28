class BootstrapFormBuilder < ActionView::Helpers::FormBuilder
  def form_group(attribute, &block)
    classes = ["form-group"]
    if object.errors[attribute].present?
      classes << "has-error"
    end
    label_classes = ["control-label", "col-lg-2 col-sm-3 col-xs-4"]
    required = object.class.validators_on(attribute).any? { |v|
      v.kind == :presence
    }
    if required
      label_classes << "required"
    end
    content_tag("div",
                label(attribute, class: label_classes.join(" ")) + "\n" +
                content_tag("div",
                            @template.capture(self, &block),
                            class: "col-lg-6 col-sm-9 col-xs-12") + "\n" + error_span(attribute),
                class: classes.join(" ")) + "\n"
  end

  def text_field(method, options = {})
    super(method, options.merge(class: "form-control select"))
  end

  def select(method, choices = nil, options = {}, html_options = {}, &block)
    super(method, choices, options,
          html_options.merge(class: "form-control select"),
          &block)
  end

  def collection_select(method, collection, value_method, text_method,
                        options = {}, html_options = {})
    super(method, collection, value_method, text_method, options,
          html_options.merge(class: "form-control select"))
  end

  def datetime_select(method, options = {}, html_options = {})
    if @template.request.from_smartphone?
      html_opts = html_options
    else
      html_opts = html_options.merge(class: "form-control datetime")
    end
    content_tag("div", super(method, options, html_opts), class: "form-inline")
  end

  # The following code came from twitter-boostrap-rails
  # 
  # Copyright (c) 2017 (since 2012) by Seyhun Aky端rek
  # 
  # Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
  # The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
  # THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

  include ActionView::Helpers::FormTagHelper

  def error_span(attribute, options = {})
    options[:span_class] ||= 'help-block'
    options[:error_class] ||= 'has-error'

    if errors_on?(attribute)
      @template.content_tag( :div, :class => options[:error_class] )  do
        content_tag( :span, errors_for(attribute), :class => options[:span_class] )
      end
    end
  end

  def errors_on?(attribute)
    object.errors[attribute].present? if object.respond_to?(:errors)
  end

  def errors_for(attribute)
    object.errors[attribute].try(:join, ', ') || object.errors[attribute].try(:to_s)
  end
end
