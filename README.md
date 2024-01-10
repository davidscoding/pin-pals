Sinatra app for Bowling League Web Application:

- The version of Ruby you used to run this application
2.7.8

- The browser (including version number) that you used to test this application 
Chrome Version 113.0.5672.126 (Official Build) (arm64)

- The version of PostgreSQL you used to create any databases
psql (PostgreSQL) 14.7 (Homebrew)


- How to install, configure, and run the application.

Welcome to the bowling app!
To get started, please follow the instructions below:

1. Navigate in the terminal to inside of the bowling project directory

2. Run the following command in the command line. This creates the database, tables, and 
inserts some sample data into those tables along with the usernames and encrypted passwords.
It also boots up the server.

```
$ bash setup_script.sh bowling
```

3. Navigate to `http://localhost:4567/teams/page/1` on your browser

4. Enter your username and password. Please choose from the following username password pair options:

USERNAME    PASSWORD
admin       secret
bowler1     secret1
bowler2     secret2
bowler3     secret3

5. Feel free to navigate about the site!

6. NOTE: that if you need to close the server for whatever reason, THE DATABASE WILL GET DROPPED AND OVERWRITTEN if 
you rerun the setup script. To reopen the server after already running the setup script while preserving the data, 
please navigate to the project directory and enter the following in terminal:

```
$ bundle exec ruby bowling.rb -p 4567
```

- Any additional details the grader may need to run your code.
Keep in mind that your grader may be unfamiliar with the problem domain. If you think that's a possibility, you may 
wish to add a brief discussion of the vocabulary and concepts used in the application.

Application Overview:

This bowling app stores a list of teams in the sql database. Each team is a collection of players (one to team to many players),
who have name and point total attributes. In this league, the teams are ranked based on the sum of the total points all of their
players have for the season. Since there are 10 games in the season for the league, and the max number of points
you can get in a game is 300, the players are capped at 3000 points for the season. There is no cap on players per team
or teams in the league.

I'll go over the main page types here, note that while the urls are valid for the sample data provided, 
the teams/player/page numbers are just examples here and will be different depending on which entity
you're looking at:


Sign in page:

If you haven't signed in yet, you'll be redirected here. There's a form to submit your username and password.
(look at the instructions above for password username combos)

Teams page (League Home): http://localhost:4567/teams/page/1

At the main home page, we have a list of teams ordered by point total. Each team name is a link
to the roster of the team. Each team also has a delete button which deletes the team as well as
an edit button which takes you to the team edit page. At the bottom are links for the next or previous 
page if valid, as well as a form for adding a new team. That form has validation checks to make sure we've submitted
a valid name.

Team Edit page: http://localhost:4567/teams/1/edit?

At the team edit page, we can edit the name of the team. It's automatically populated with the current name or
the name most recently entered, and will display an error message if you try to enter an invalid name.

Team page (Team roster): http://localhost:4567/teams/1/page/1

At the team page, we have a list ofplayers on a team ordered by point total. Each player has a delete button which 
deletes the player as well as an edit button which takes you to the player edit page. At the bottom are links for 
the next or previous page if valid, as well as a form for adding a new player. That form has validation checks to
make sure we've submitted a valid name and point total.

Team Edit page: http://localhost:4567/teams/1/edit?

At the player edit page, we can edit the name of the team. It's automatically populated with the current name or
the name most recently entered, as well as the current point total or the point total most recently entered and will 
display an error message if you try to enter an invalid name or point total.
