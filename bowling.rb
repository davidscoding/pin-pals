require "sinatra"
require "sinatra/content_for"
require "tilt/erubis"
require "bcrypt"
require_relative "database_persistence"

### CONFIGURE
configure do
  enable :sessions
  set :session_secret, "secret"
  set :erb, escape_html: true
end

configure(:development) do
  require "sinatra/reloader"
  also_reload "database_persistence.rb"
end

ITEMS_PER_PAGE = 3

helpers do
  # Used to determine if next / previous page link should be displayed
  def page_in_bounds?(array, page_num, items_per_page)
    return false if !page_num
    return false if page_num < 1
    return true if page_num == 1

    ((page_num - 1) * items_per_page) < array.length
  end
end


### SIGN IN CHECKS
# Checks if user's submission of username and password is valid
def valid_credentials?(username, password)
  credentials = @storage.users
  if credentials.key?(username)
    bcrypt_password = BCrypt::Password.new(credentials[username])
    bcrypt_password == password
  else
    false
  end
end

# Checks if user is currently signed in
def user_signed_in?
  session.key?(:username)
end

# Ensures users can only view page if they are signed in
def require_signed_in_user
  return if user_signed_in?
  session[:target_path] = request.path_info
  session[:message] = "You must be signed in to do that."
  redirect "/users/signin"
end


### GENERAL HELPERS
# Converts strings to integers, returns nil if can't be properly transformed
# Used to check if points input was an integer
def to_i(str)
  begin
    integer_value = Integer(str)
    integer_value
  rescue ArgumentError, TypeError
    nil
  end
end


### VALIDATE USER INPUT / ERROR MESSAGES
# Returns error message if not unique team name
def error_not_unique(team_name, team_id=0)
  if @storage.check_unique_team_name(team_name, team_id)
    "This team name already exists, new name must be unique!"
  end
end

# Returns error message (string) for invalid name entry
def error_for_name(name)
  if !(1..50).cover?(name.length)
    "Name must be between 1 and 50 characters long!"
  end
end

# Returns error message (string) for invalid points entry
def error_for_score(points)
  if !to_i(points)
    "Points entered have to be a valid integer!"
  elsif !(0..3000).cover?(to_i(points))
    <<~ERROR
    You can only score between 0 and 3000 points in a season!
    There are ten games and the max points per game is 300.
    Please enter a number in that range.
    ERROR
  end
end


### HEADER FINDERS
# Returns information about player if the combination of
# team and player id's are valid
# Loads error message and redirects to league page if not valid
def find_player(team_id, player_id)
  player = @storage.player_info(team_id, player_id) if (player_id && team_id)
  return player if player

  session[:error] = "The specified player was not found."
  redirect "/teams/page/1"
end

# Returns information about team header info if the team id is valid
# Loads error message and redirects to league page if not valid
def find_team(team_id)
  team = @storage.team_info(team_id) if team_id
  return team if team

  session[:error] = "The specified team was not found."
  redirect "/teams/page/1"
end


### LOADING HELPERS
# Returns array of entries for current page
def page_values(array, page_num, items_per_page)
  start = (page_num - 1) * items_per_page
  array[start, items_per_page]
end

# Returns array for the body of the current page if valid, assigns
# error message + redirects if invalid page number
def load_page(array, page_num, items_per_page)
  if page_in_bounds?(array, page_num, items_per_page)
    return page_values(array, page_num, items_per_page)
  end

  session[:error] = "Uh oh! That was an out of bounds page number"
  redirect "/teams/page/1"
end

# Initial generic loading method that loads up information passed
# in via params into instance variables.
def load_params
  @team_id = to_i(params[:team_id]) if params[:team_id]
  @player_id = to_i(params[:player_id]) if params[:player_id]
  @page_num = to_i(params[:page_num]) if params[:page_num]
  @points = params[:points] if params[:points]
  @player_name = params[:player_name].strip if params[:player_name]
  @team_name = params[:team_name].strip if params[:team_name]
  @player = params[:player] if params[:player]
  @team = params[:team] if params[:team]
end

# Loads up the rest of specific information required for both
# the header and body of the team page.
def load_team_page
  @team = find_team(@team_id)
  @players = @storage.team_players(@team_id)
  @page_players = load_page(@players, @page_num, ITEMS_PER_PAGE)
end

# Loads up the rest of specific information required for both
# the header and body of the teams(league) page
def load_teams_page
  @teams = @storage.league_teams
  @page_teams = load_page(@teams, @page_num, ITEMS_PER_PAGE)
end

before do
  @storage = DatabasePersistence.new(logger)
  require_signed_in_user unless request.path_info == '/users/signin'
end

# Home
get "/" do
  redirect "/teams/page/1"
end


### VIEW
# View info about team
get "/teams/:team_id/page/:page_num" do
  load_params
  load_team_page

  erb :team, layout: :layout
end

# View list of teams
get "/teams/page/:page_num" do
  load_params
  load_teams_page

  erb :teams, layout: :layout
end


### ADD
# Add player
post "/teams/:team_id/players" do
  load_params
  
  error = error_for_name(@player_name)
  error = error || error_for_score(@points)
  if error
    session[:error] = error
    load_team_page
    erb :team, layout: :layout
  else
    @storage.create_player(@team_id, @player_name, @points)
    session[:success] = "The player #{@player_name} has joined the team!"
    redirect "/teams/#{@team_id}/page/1"
  end
end

# Add team
post "/teams" do
  load_params

  error = error_for_name(@team_name)
  error = error || error_not_unique(@team_name)
  if error
    session[:error] = error
    load_teams_page
    erb :teams, layout: :layout
  else
    @storage.create_team(@team_name)
    session[:success] = "The team #{@team_name} has joined the league!"
    redirect "/teams/page/1"
  end
end


### EDIT
# Edit player
get "/teams/:team_id/players/:player_id/edit" do
  # binding.pry
  load_params
  
  @player = find_player(@team_id, @player_id)

  erb :edit_player, layout: :layout
end

# Edit team
get "/teams/:team_id/edit" do
  load_params

  @team = find_team(@team_id)

  erb :edit_team, layout: :layout
end


### UPDATE
# Update player
post "/teams/:team_id/players/:player_id" do
  load_params

  error = error_for_name(@player_name)
  error = error || error_for_score(@points)
  if error
    session[:error] = error
    erb :edit_player, layout: :layout
  else
    @storage.update_player(@player_id, @player_name, @points)
    session[:success] = "Player is now named #{@player_name} with #{@points} points."
    redirect "/teams/#{@team_id}/page/1"
  end
end

# Update team
post "/teams/:team_id" do
  load_params

  error = error_for_name(@team_name)
  error = error || error_not_unique(@team_name, @team_id)
  # binding.pry
  if error
    session[:error] = error
    erb :edit_team, layout: :layout
  else
    @storage.update_team(@team_name, @team_id)
    session[:success] = "The team name has been updated to #{@team_name}."
    redirect "/teams/page/1"
  end
end


### DELETE
# Delete player
post "/teams/:team_id/players/:player_id/delete" do
  load_params

  @storage.delete_player(@player_id)

  session[:success] = "The player has been deleted."
  redirect "/teams/#{@team_id}/page/1"
end

# Delete team
post "/teams/:team_id/delete" do
  load_params

  @storage.delete_team(@team_id)

  session[:success] = "The team has been deleted."
  redirect "/teams/page/1"
end


### NOT FOUND
# Includes generic message for not found pages
not_found do
  session[:error] = "The page you were looking for couldn't be found!"
  redirect "/"
end


### SIGNIN PAGES
get "/users/signin" do
  erb :signin
end

post "/users/signin" do
  username = params[:username]

  if valid_credentials?(username, params[:password])
    session[:username] = username
    session[:success] = "Welcome to the app, #{username}!"
    redirect session.delete(:target_path) if session[:target_path]
    redirect "/teams/page/1"
  else
    session[:error] = "Invalid credentials"
    status 422
    erb :signin
  end
end

post "/users/signout" do
  session.delete(:username)
  session[:message] = "You have been signed out."
  redirect "/users/signin"
end
