require 'pathname'

# Send error emails
# TODO Take out hard-coded email address and do something else intelligent by default
class SystemNotifier < ActionMailer::Base
  SYSTEM_EMAIL_ADDRESS = %{"Error  Notifier" <app@class="base">}

  EXCEPTION_RECIPIENTS = %w{scott@butlerpress.com}

  def exception_notification(controller, request, 
                             exception, sent_on=Time.now)

    @subject    = sprintf("[ERROR] %s\#%s (%s) %s",
                          controller.controller_name,
                          controller.action_name,
                          exception.class,
                          exception.message.inspect)

    @body       = { "controller" => controller, "request" => request,
                    "exception"  => exception,
                    "backtrace"  => sanitize_backtrace(exception.backtrace),
                    "host" => request.env["HTTP_HOST"],
                    "rails_root" => rails_root }
    @sent_on    = sent_on
    @from       = SYSTEM_EMAIL_ADDRESS
    @recipients = EXCEPTION_RECIPIENTS
    @headers    = {}
  end

  private

  def sanitize_backtrace(trace)
    re = Regexp.new(/^#{Regexp.escape(rails_root)}/)
    trace.map do |line| 
      Pathname.new(line.gsub(re, "[RAILS_ROOT]")).cleanpath.to_s 
    end
  end

  def rails_root
    @rails_root ||= Pathname.new(RAILS_ROOT).cleanpath.to_s
  end
end
