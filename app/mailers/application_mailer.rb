# frozen_string_literal: true

class ApplicationMailer < MandrillMailer::TemplateMailer
  include ApplicationHelper
  include Rails.application.routes.url_helpers

  MAX_RETRIES = 2
  RETRY_WAIT_SECS = 4

  private_constant :MAX_RETRIES
  private_constant :RETRY_WAIT_SECS

  default from: 'hello@wickedlab.com.au', from_name: 'Wicked Lab', view_content_link: true

  def deliver_now
    retries ||= 0
    super
  rescue Mandrill::Error
    raise if (retries += 1) > MAX_RETRIES

    sleep(RETRY_WAIT_SECS)
    retry
  end

  def send_mail(subject:, content:, to:, bcc: '', attachments: nil)
    subject = "[#{Rails.env}] #{subject}" unless Rails.env.production?

    mandrill_mail(
      template: 'default',
      subject: subject,
      to: wrap_emails(to, type: 'to') + wrap_emails(bcc, type: 'bcc'),
      vars: { content: content },
      important: true,
      images: [logo_image],
      inline_css: true,
      preserve_recipients: true,
      merge_language: 'handlebars',
      attachments: attachments
    )
  end

  private

  def build_renderer
    ApplicationController.renderer.new(http_host: default_http_host, https: force_ssl)
  end

  def default_url_options
    Rails.application.config.action_mailer.default_url_options
  end

  def force_ssl
    Rails.application.config.force_ssl
  end

  def renderer
    @renderer ||= build_renderer
  end

  def render_template(partial, locals)
    renderer.render(layout: 'mailer', partial: File.join(template_root, partial), locals: locals)
  end

  def default_http_host
    default_url_options.values_at(:host, :port).join(':')
  end

  def logo_image
    @logo_image ||= {
      name: 'logo.png',
      filename: 'logo.png',
      content: File.read(Rails.root.join('app/assets/images/logo-long-white-bg-pdf.png')),
      type: 'image/png'
    }
  end

  def wrap_emails(emails, type:)
    return [] if emails.blank?

    Array.wrap(emails).map do |email|
      email.is_a?(Hash) ? email : { email: email, type: type }
    end
  end

  def template_root
    mailer_name = self.class.name.demodulize.underscore.remove(/_mailer\z/).pluralize
    "mailers/#{mailer_name}"
  end
end
