require "bcrypt"

enable :sessions
set :session_secret, "This should be replaced with a secret string nobody can guess."

def password_hash(password)
    BCrypt::Password.create(password).to_s
end

def valid_password?(password, hash)
    BCrypt::Password.new(hash) == password
end

def current_user
    session[:current_user]
end

def logged_in?
    current_user != nil
end

set(:login) do |required|
    condition do
        if required and not logged_in? then
            session[:original_request] = request.path_info
            redirect to("/login")
        end
    end
end

def login(user)
    session[:current_user] = user
    original_request = session[:original_request]
    session[:original_request] = nil
    redirect to(original_request || "/home")
end

def logout
    session[:current_user] = nil
    redirect to("/home")
end
