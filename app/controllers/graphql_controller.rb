class GraphqlController < DeviseTokenAuth::ApplicationController
  # include TokenAuthHelper
  # include DeviseTokenAuth::Concerns::SetUserByToken

  # If accessing from outside this domain, nullify the session
  # This allows for outside API access while preventing CSRF attacks,
  # but you'll have to authenticate your user separately

  protect_from_forgery with: :null_session

  before_action :set_user_by_token

  def execute
    Rails.logger.debug "GRAPHQL current_user = #{current_user.inspect}"

    variables = ensure_hash(params[:variables])
    query = params[:query]
    operation_name = params[:operationName]
    context = {
      # Query context goes here, for example:
      auth_headers: extract_auth_headers(request.headers),
      current_user: current_user,
    }
    result = GraphqlAppSchema.execute(query, variables: variables, context: context, operation_name: operation_name)
    render json: result

  rescue => e
    raise e unless Rails.env.development?
    handle_error_in_development e
  end

  private

  def extract_auth_headers(headers)
    {
      :'client' => headers[DeviseTokenAuth.headers_names[:'client']],
      :'access-token' => headers[DeviseTokenAuth.headers_names[:'access-token']],
      :'expiry' => headers[DeviseTokenAuth.headers_names[:'expiry']],
      :'uid' => headers[DeviseTokenAuth.headers_names[:'uid']]
    }
  end

  # Handle form data, JSON body, or a blank value
  def ensure_hash(ambiguous_param)
    case ambiguous_param
    when String
      if ambiguous_param.present?
        ensure_hash(JSON.parse(ambiguous_param))
      else
        {}
      end
    when Hash, ActionController::Parameters
      ambiguous_param
    when nil
      {}
    else
      raise ArgumentError, "Unexpected parameter: #{ambiguous_param}"
    end
  end

  def handle_error_in_development(e)
    logger.error e.message
    logger.error e.backtrace.join("\n")

    render json: { error: { message: e.message, backtrace: e.backtrace }, data: {} }, status: 500
  end
end
