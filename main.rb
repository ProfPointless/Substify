require 'sinatra'
require 'sinatra/reloader' if development?

#Einbindung einer SQLite-Datenbank
require_relative "db/sql"
require_relative "authentication"

# Oftmals definiert man sich zusätzliche Funktionen, diese
# werden dann im Helpers-Bereich abgelegt
helpers do
	#Funktionen für die Authentifizierung
	def query_user(name)
	    benutzer = sql "SELECT * FROM users WHERE username='" + name + "' LIMIT 1;"
	    if benutzer.size != 1 then
	        return nil
	    else
	        return benutzer[0]
	    end
	end

	def query_user_by_id(id)
	    benutzer = sql "SELECT * FROM users WHERE id='" + id.to_s + "' LIMIT 1;"
	    if benutzer.size != 1 then
	        return nil
	    else
	        return benutzer[0]
	    end
	end

	def insert_user(username, hash)
		sql ("	INSERT INTO users (username, hash) 
				VALUES ('" + username + "','" + hash + "');")
	end
	#######################################
end



get "/" do
	@title="Startseite"
	if logged_in? then
		redirect to "/home"
	else
		redirect to "/login"
	end
	
end

get '/home' do
  erb :home
end

#Routen für die Authentifizierung
get "/login" do
    erb :login
end

post "/login" do
    if params[:username] == "" || params[:password] == "" then
        redirect to("/login")
    end

    user = query_user(params[:username])
    if user == nil then
        redirect to("/login")
    end

    if not valid_password?(params[:password], user["hash"]) then
        redirect to("/login")
    end

    login user
end

get "/logout" do
    logout
end

get "/register" do
    erb :register
end

post "/register" do
	if params[:username] == "" || params[:password] == "" then
		redirect to ("/register")
	end

	if params[:password] != params[:confirmation] then
		redirect to("/register")
	end

	user = query_user(params[:username])
	if user == nil then
		user = { "username" => params[:username] }
	else
		redirect to("/register")
	end

	user["hash"] = password_hash params[:password]
	insert_user(user["username"], user["hash"])
	
	user=query_user(user["username"])
	
	login user
end
###################################################

get '/about' do
  erb :about
end

get '/contact' do
  erb :contact
end

get '/songs' do
	@songs = sql("select * FROM songs; ")
  erb :songs	
end

get '/new' do
	erb :new_song
end

post '/new' do
	#Erzeuge einen neuen song mit den benannten Parametern:
	neuer_titel = params[:titel]
	neuer_songtext = params[:songtext]
	neue_laenge = params[:laenge]
	neu_erschienen_in = params[:erschienen_in]
	@neuer_song = sql("INSERT INTO songs (titel, songtext, laenge, erschienen_in) VALUES ('#{neuer_titel}','#{neuer_songtext}','#{neue_laenge}' ,'#{neu_erschienen_in}');")
	# Alternative
	#sql ("INSERT INTO songs (titel, songtext, laenge, erschienen_in) VALUES ('#{params[:titel]}','#{params[:songtext]}','#{params[:laenge]}' ,'#{params[:erschienen_in]}');")
	#Weiterleitung zur Übersicht aller Songs
	redirect to("/songs")
end

get '/songs/:id/edit' do
  @this_song = sql("SELECT * FROM songs WHERE ID='" + params[:id].to_s + "';")[0]
  erb :edit_song
end

put '/songs/:id' do |id|
	song_id = id
	veraendeter_titel = params[:titel]
	veraendeter_songtext = params[:songtext]
	veraendete_laenge = params[:laenge]
	veraendet_erschienen_in = params[:erschienen_in]
	#Datensatz wird geändert
	sql("UPDATE songs SET titel='#{veraendeter_titel}', songtext='#{veraendeter_songtext}', laenge='#{veraendete_laenge}', erschienen_in= '#{veraendet_erschienen_in}' WHERE id='#{song_id}';" )
	redirect to("/songs")
end

delete '/song/:id' do
	song_id = params[:id]
	sql ("DELETE FROM songs WHERE id=" + song_id.to_s + ";")
	redirect to("/songs")
end