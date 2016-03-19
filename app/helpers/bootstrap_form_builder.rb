class BootstrapFormBuilder < ActionView::Helpers::FormBuilder
  def form_group(attribute, &block)
    classes = ["form-group", "foo"]
    if errors_on?(attribute)
      classes << "has-error"
    end
    content_tag("div",
                label(attribute, class: "control-label col-lg-2") + "\n" +
                content_tag("div",
                            @template.capture(self, &block),
                            class: "col-lg-6") + "\n" + error_span(attribute),
                class: classes.join(" ")) + "\n"
  end

  def datetime_select(method, options = {}, html_options = {})
    content_tag("div",
                super(method, options,
                      html_options.merge(class: "form-control datetime")),
                class: "form-inline")
  end
end
