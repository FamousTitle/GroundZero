# frozen_string_literal: true

class Components::Base < Phlex::HTML
  include Phlex::Rails::Helpers::Routes
  include Phlex::Rails::Helpers::ImageTag
  include Phlex::Rails::Helpers::LinkTo
  include Phlex::Rails::Helpers::Flash
  include Phlex::Rails::Helpers::TurboFrameTag
  include Phlex::Rails::Helpers::ButtonTo
  include Phlex::SVG::StandardElements

  # Wrap the entire template rendering. Override in subclasses to add wrappers
  # (e.g., Turbo Frames, containers, etc.). Default behavior is a no-op.
  def around_template(&block)
    yield
  end

  if Rails.env.development?
    def before_template
      comment { "Before #{self.class.name}" }
      super
    end
  end
end
