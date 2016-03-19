class BootstrapFormBuilder < ActionView::Helpers::FormBuilder
  def form_group(attribute, &block)
    classes = ["form-group", "foo"]
    if errors_on?(attribute)
      classes << "has-error"
    end
    label_classes = ["control-label", "col-lg-2"]
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
                            class: "col-lg-6") + "\n" + error_span(attribute),
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
    content_tag("div",
                super(method, options,
                      html_options.merge(class: "form-control datetime")),
                class: "form-inline")
  end
end
