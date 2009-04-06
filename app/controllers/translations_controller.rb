class TranslationsController < ApplicationController
  # GET /translations
  def index
    respond_to do |format|
      format.json { render :json => session[:__translations].to_json, :status => :ok }
    end
  end

  # POST /translations/save
  def save
    # TODO should accept locale from params?
    I18n.backend.store_translations I18n.locale, { params[:key] => params[:value] }

    respond_to do |format|
      format.js { render :text => params[:value], :layout => false, :status => :ok }
    end
  end
end
