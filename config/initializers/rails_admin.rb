RailsAdmin.config do |config|
  ### Popular gems integration

  ## == Devise ==
  # config.authenticate_with do
  #   warden.authenticate! scope: :user
  #   authenticate_or_request_with_http_basic('Login required') do |username, password|
  #     user = User.where(name:username).first
  #     user.authenticate(password) if user
  #   end
  # end
  # config.current_user_method(&:current_user)

  config.authorize_with do
    authenticate_or_request_with_http_basic('Login') do |username, password|
      username == Rails.application.credentials.rails_admin_user && password == Rails.application.credentials.rails_admin_pass
    end
  end
  ## == Cancan ==
  # config.authorize_with :cancan

  ## == Pundit ==
  # config.authorize_with :pundit

  ## == PaperTrail ==
  # config.audit_with :paper_trail, 'User', 'PaperTrail::Version' # PaperTrail >= 3.0.0

  ### More at https://github.com/sferik/rails_admin/wiki/Base-configuration

  ## == Gravatar integration ==
  ## To disable Gravatar integration in Navigation Bar set to false
  # config.show_gravatar = true

  config.actions do
    dashboard # mandatory
    index # mandatory
    new
    export
    bulk_delete
    show
    edit
    delete
    show_in_app

    ## With an audit adapter, you can add:
    # history_index
    # history_show
  end
end
