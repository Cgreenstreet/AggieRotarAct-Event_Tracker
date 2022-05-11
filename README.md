# README

This project is an event tracker for the organization Aggie Rotaract. Before coming to us, they were locked out of their previous website and were relying primarily on Google Sheets to manage the logistical side of the organization, but this website allows for the ability to run the organization using one consolidated website. This application is a Rails application and will be used by the organization beginning this upcoming Fall 2021 semester.

The capabilities of this application include:
- Creating and managing Events
- Sign ups for Events
- Point tracking for members
- Tracking members' information


[![Build Test](https://github.com/lbauskar/aggie-rotaract-event-tracker/actions/workflows/ruby.yml/badge.svg)](https://github.com/lbauskar/aggie-rotaract-event-tracker/actions/workflows/ruby.yml)

You can view it at [aggie-rotaract.herokuapp.com](https://aggie-rotaract.herokuapp.com)

# How To Execute The Code

## Install ruby 3.0.0
- Run `bundle install` to install all dependencies. See `gemfile` for all ruby gems used.
- Set up database:
  - Ensure postgreSQL is installed
  - Run the following:
    - `sudo service postgresql start`
    - `psql -U postgres -h localhost`
    - `CREATE DATABASE db_name;` Select any name you would like for db_name
    - `CREATE USER 'username'@'localhost' IDENTIFIED BY 'password';` Select and username and password you would like
    - `GRANT ALL PRIVILEGES ON db_name.* TO 'username'@'localhost';` Use the same db_name and username as in the previous steps
    - `\q` to exit
  - Update `config/database.yml` to match the credentials you chose
  - Run `rake db:setup`
  - Run `rails db:migrate`
## Set up Google Oauth:
  - Using your TAMU account, [create a Google app and make a Client ID](https://support.google.com/cloud/answer/6158849?hl=en#zippy=)
  - On the left sidebar, click credentials, then click on the pencil next to your new Client ID
  - In the top middle/right you should see a Client ID and Client Secret. Keep this webpage open.
  - Go to the root folder of this project and open the terminal. Type `bin/rails credentials:edit`
  - Add this to your credentials
  ```yaml
    google_sign_in:
      client_id: [Your client ID here]
      client_secret: [Your client secret here]
  ```
## Run `rails server` or `rails s` to run the server through localhost

# How to Deploy to Heroku

- Install the Heroku CLI
- Run the following:
  - `heroku login`
  - `git add .`
  - `git commit -m "init"`
  - `heroku create`
  - `git push heroku main`
  - `heroku run rake db:migrate`
- Go to [dashboard.heroku.com](https://dashboard.heroku.com), click on your app, click on settings then click on "Reveal Config Vars"
- Check if a variable with the name RAILS_MASTER_KEY exists, if it does you can skip the steps below
- find the file `config/master.key`, then copy the contents of that file
- create a new variable with the key RAILS_MASTER_KEY and the paste what copied into the value text box
- click add to save this new variable

# CI/CD Process

CI (Continuous Integration) is basically just automatic testing, and it's integrated into GitHub with a tool called [GitHub Actions](https://github.com/features/actions). If you ever fork (make a copy of) this repository and host it on GitHub, everything should be set up automatically. The way we have CI working right now is that whenever you "push" a change onto the `master` or `development` branches, Rspec - testing software for Ruby - will automatically run. If you ever want to change what GitHub Actions does, edit `.github/actions/ruby.yml`.

CD (Continuous Deployment) is having an extra "staging" website where you can test new changes you make before updating the real website. Unlike CI, you can ignore CD if you really want to since it's not part of the repository. We used a [Heroku Pipeline](https://devcenter.heroku.com/articles/pipelines) to implement CD. The linked article does a good job at explaining how it works. We had two separate apps, a staging app and a production app. The staging app would be [connected directly to GitHub](https://devcenter.heroku.com/articles/github-integration), and after we manually test the staging app, we promote it to production.

# ReadMe Video Link
https://youtu.be/peTRmvPcWh4
