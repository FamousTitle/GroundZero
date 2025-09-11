# frozen_string_literal: true

class Components::Views::Passwords::NewView < Components::Base
  def initialize(email_address:)
    @email_address = email_address
  end

  def view_template
    div(class: "min-h-screen flex items-center justify-center px-4") do
      div(class: "max-w-2xl mx-auto md:w-2/3 w-full") do
        div(class: "px-6 py-4 border border-gray-300 rounded-xl") do
          if (alert = flash[:alert])
            p(id: "alert", class: "py-2 px-3 bg-red-50 mb-5 text-red-500 font-medium rounded-lg inline-block") { alert }
          end

          h1(class: "font-bold text-2xl") { "Forgot your password?" }

          form(action: passwords_path, method: "post", class: "contents") do
            div(class: "my-5") do
              input type: "email",
                    name: "email_address",
                    required: true,
                    autofocus: true,
                    autocomplete: "username",
                    placeholder: "Enter your email address",
                    value: @email_address,
                    class: "block shadow rounded-md border border-gray-400 focus:outline-blue-600 px-3 py-2 mt-2 w-full"
            end

            div(class: "col-span-6 sm:flex sm:items-center sm:gap-4") do
              div(class: "flex w-full items-center justify-between") do
                div(class: "inline") do
                  input type: "submit", value: "Email reset instructions", class: "rounded-lg py-2 px-6 bg-blue-600 text-white inline-block font-medium cursor-pointer"
                end

                div(class: "mt-4 text-sm text-gray-500") do
                  link_to "Create an account", new_registrations_path, class: "text-gray-700 underline mr-8"
                  link_to "Back to sign in", new_session_path, class: "text-gray-700 underline"
                end
              end
            end
          end
        end
      end
    end
  end
end
