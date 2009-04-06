class LocalesController < ApplicationController
  before_filter :normalize_http_referer

  # PUT /locales/en/change
  def change
    I18n.locale = params[:id]
    redirect_to :back
  end

  private
    def normalize_http_referer
      request.env["HTTP_REFERER"] ||= "/"
    end
end
