# frozen_string_literal: true

require 'mandrill_mailer'

class MandrillDeviseMailer < Devise::Mailer
  helper :application
  include Devise::Controllers::UrlHelpers
  default from: 'hello@wickedlab.com.au'
  default reply_to: 'hello@wickedlab.com.au'

  def mail(headers = {}, &block)
    MandrillMailer::TemplateMailer.mandrill_mail(
      template: 'devise',
      subject: headers[:subject],
      to: headers[:to],
      from: headers[:from],
      from_name: 'Wicked Lab',
      view_content_link: true,
      vars: {
        content: render(layout: 'devise_mailer').html_safe
      },
      images: [
        {
          name: 'logo.png',
          filename: 'logo.png',
          content: File.read(Rails.root.join('app/assets/images/logo-long-white-bg.png')),
          type: 'image/png'
        }
      ],
      important: true,
      inline_css: true,
      preserve_recipients: true,
      merge_language: 'handlebars'
    ).deliver
  end
end
