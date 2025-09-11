# frozen_string_literal: true

class Components::Views::Passwords::EditView < Components::Base
  def view_template
    div(class: "min-h-screen flex items-center justify-center px-4") do
      div(class: "max-w-2xl mx-auto md:w-2/3 w-full") do
        div(class: "px-6 py-4 border border-gray-300 rounded-xl") do
          if (alert = flash[:alert])
            p(id: "alert", class: "py-2 px-3 bg-red-50 mb-5 text-red-500 font-medium rounded-lg inline-block") { alert }
          end

          h1(class: "font-bold text-2xl") { "Update your password" }

          form(action: password_path(params[:token]), method: "post", class: "contents") do
            input type: "hidden", name: "_method", value: "put"

            div(class: "my-5") do
              input type: "password",
                    name: "password",
                    required: true,
                    autocomplete: "new-password",
                    placeholder: "Enter new password",
                    maxlength: 72,
                    class: "block shadow rounded-md border border-gray-400 focus:outline-blue-600 px-3 py-2 mt-2 w-full"
            end

            div(class: "my-5") do
              input type: "password",
                    name: "password_confirmation",
                    required: true,
                    autocomplete: "new-password",
                    placeholder: "Repeat new password",
                    maxlength: 72,
                    class: "block shadow rounded-md border border-gray-400 focus:outline-blue-600 px-3 py-2 mt-2 w-full"
            end

            div(class: "inline") do
              input type: "submit", value: "Save", class: "rounded-lg py-2 px-6 bg-blue-600 text-white inline-block font-medium cursor-pointer"
            end

            div(class: "mt-4 text-sm text-gray-500") do
              link_to "Back to sign in", new_session_path, class: "text-gray-700 underline mr-8"
              link_to "Create an account", new_registrations_path, class: "text-gray-700 underline"
            end
          end
        end
      end
    end
  end
end
