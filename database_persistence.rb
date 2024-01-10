require "pg"

class DatabasePersistence
  def initialize(logger)
    @db = PG.connect(dbname: "bowling")
    @logger = logger
  end

  def query(statement, *params)
    @logger.info "#{statement}: #{params}"
    @db.exec_params(statement, params)
  end

  def users
    sql = "SELECT user_names, hashed_passwords FROM users"
    result = query(sql)
    result.values.to_h
  end

  ### READ
  # returns a hash with the id, name, and sum of points on the
  # season for a given player.
  def player_info(team_id, player_id)
    sql = <<~SQL
      SELECT *
      FROM players
      WHERE players.team_id = $1 AND players.id = $2
    SQL

    result = query(sql, team_id, player_id)
    to_a(result).first
  end

  # returns an array of hashes for the players of a given team, where
  # each hash has: the players id, name, and sum of points on the season -
  # used for the body of the team page.
  def team_players(team_id)
    sql = <<~SQL
      SELECT *
      FROM players
      WHERE team_id = $1
      ORDER BY points DESC;
    SQL

    result = query(sql, team_id)
    to_a(result)
  end

  # returns a hash with the id, name, and sum of points on the
  # season for a given team - used for the header of the team page.
  def team_info(team_id)
    sql = <<~SQL
      SELECT teams.id, teams.name, COALESCE(sum(players.points), 0) AS points
      FROM teams
      LEFT JOIN players
      ON teams.id = players.team_id
      WHERE teams.id = $1
      GROUP BY teams.id;
    SQL

    result = query(sql, team_id)
    to_a(result).first
  end

  # returns an array of hashes for the teams of the league, where
  # each hash has: the teams id, name, and sum of points on the season -
  # used for the body of the league page (aka teams page).
  def league_teams
    sql = <<~SQL
      SELECT teams.id, teams.name, COALESCE(sum(players.points), 0) AS points
      FROM teams
      LEFT JOIN players
      ON teams.id = players.team_id
      GROUP BY teams.id
      ORDER BY points DESC; 
    SQL

    result = query(sql)
    to_a(result)
  end

  ### DELETE
  def delete_player(player_id)
    sql = "DELETE FROM players WHERE id = $1"
    query(sql, player_id)
  end

  def delete_team(team_id)
    sql = "DELETE FROM teams WHERE id = $1"
    query(sql, team_id)
  end


  ### CREATE
  def create_player(team_id, player_name, points)
    player_sql = "INSERT INTO players(team_id, name, points) VALUES ($1, $2, $3);"
    query(player_sql, team_id, player_name, points)
  end

  def create_team(team_name)
    sql = "INSERT INTO teams(name) VALUES ($1);"
    query(sql, team_name)
  end


  ### VALIDATE
  def check_unique_team_name(team_name, team_id)
    sql = "SELECT * FROM teams WHERE id != $1 AND name = $2;"
    to_a(query(sql, team_id, team_name)).first
  end


  ### UPDATE
  def update_player(player_id, player_name, points)
    sql = "UPDATE players SET name=$1, points=$2 WHERE id=$3;"
    query(sql, player_name, points, player_id)
  end

  def update_team(team_name, team_id)
    sql = "UPDATE teams SET name=$1 WHERE id=$2;"
    query(sql, team_name, team_id)
  end

  private

  def to_a(table)
    table.to_a.map { |hash| hash.transform_keys(&:to_sym) }
  end
end