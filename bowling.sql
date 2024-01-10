CREATE TABLE users (
  id serial PRIMARY KEY,
  user_names text NOT NULL UNIQUE,
  hashed_passwords text NOT NULL UNIQUE
);

CREATE TABLE teams (
  id serial PRIMARY KEY,
  name text NOT NULL UNIQUE
);

CREATE TABLE players (
  id serial PRIMARY KEY,
  name text NOT NULL,
  points integer NOT NULL DEFAULT 0,
  team_id integer NOT NULL REFERENCES teams(id) ON DELETE CASCADE
);

INSERT INTO users (user_names, hashed_passwords)
VALUES ('admin', '$2a$12$7i4fLvoAftVwbLW9Rck8huj8GUvrTdnpLBk7JXG1N5u7wh4ii2oR6'),
('bowler1', '$2a$12$YJYAq4DOZThlLehs8W5j4uwP3VSAX2zQ3PWkcrRHLVKVKVFFRTXCu'),
('bowler2', '$2a$12$DUEK7weqfNKiZo6xKARrI.AcjyJ8DDv1dfJzJmax1hZ3wSmVY6gHa'),
('bowler3', '$2a$12$LsUXot1p0Os7kf9Ig1GLM.765gY4AeiZqb3I8fAogA09o6ALv1ErC');

INSERT INTO teams(name)
VALUES ('Alley Avengers'),
('Bowling Buddies'),
('Clean Game Companions'),
('Double Dudes'),
('Entry Angle Enthusiasts');

INSERT INTO players(name, team_id, points)
VALUES ('Arash', 1, random() * 1000 + 1000),
('Betty', 1, random() * 1000 + 1000),
('Charles', 1, random() * 1000 + 1000),
('David', 1, random() * 1000 + 1000),
('Emily', 2, random() * 1000 + 1000),
('Faraz', 2, random() * 1000 + 1000),
('George', 2, random() * 1000 + 1000),
('Hector', 2, random() * 1000 + 1000),
('Isilda', 3, random() * 1000 + 1000),
('Jamie', 3, random() * 1000 + 1000),
('Kelly', 3, random() * 1000 + 1000),
('Lolita', 3, random() * 1000 + 1000),
('Morris', 4, random() * 1000 + 1000),
('Nick', 4, random() * 1000 + 1000),
('Oliver', 4, random() * 1000 + 1000),
('Pranav', 4, random() * 1000 + 1000),
('Quinn', 5, random() * 1000 + 1000),
('Rishay', 5, random() * 1000 + 1000),
('Sally', 5, random() * 1000 + 1000),
('Teresa', 5, random() * 1000 + 1000);