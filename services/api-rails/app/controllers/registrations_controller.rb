class RegistrationsController < Devise::RegistrationsController
  skip_before_action :verify_authenticity_token

  def respond_with(resource, _opts = {})
    if resource.valid?
      render json: resource
    else
      render json: { errors: resource.errors }
    end
  end

end
