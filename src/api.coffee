fs       = require "fs"
google   = require "googleapis"
moment   = require "moment"
mysql    = require "promise-mysql"
parseCsv = require "csv-parse/lib/sync"
path     = require "path"
Promise  = require "bluebird"
readline = require "readline"
util     = require "util"
_        = require "underscore"

############################################################################################################

DEVICE_TYPES_DIR    = "./data/device_types"
SUMMARY_DIR         = "./data/summary"
TRAFFIC_SOURCES_DIR = "./data/traffic_sources"
WATCH_TIME_DIR      = "./data/watch_time"

SCOPES = [
  "https://www.googleapis.com/auth/youtube"
  "https://www.googleapis.com/auth/youtube.readonly"
  "https://www.googleapis.com/auth/yt-analytics-monetary.readonly"
  "https://www.googleapis.com/auth/yt-analytics.readonly"
]

OAuth2 = google.auth.OAuth2

authClient = null
db         = null
videos     = null

############################################################################################################

authorizeGoogleApi = ->
  secrets = JSON.parse fs.readFileSync "secrets.json", "UTF-8"
  authClient = new OAuth2 secrets.clientId, secrets.secret
  google.options auth:authClient
  url = authClient.generateAuthUrl access_type:"offline", scope:SCOPES
  code = readline.question "Enter code from #{url}: "
  return new Promise (resolve, reject)->
    authClient.getToken code, (err, tokens)->
      if err? then reject err
      authClient.setTokens(tokens)
      resolve()

createDatabase = ->
  if not db? then throw new Error "db connection is required"
  db.query "create database youtube_videos character set = 'UTF8'"
    .then -> db.query "create database youtube_videos_looker character set = 'UTF8'"
    .then -> db.query "use youtube_videos"

downloadVideos = ->
  api = google.youtube 'v3'

  return new Promise (resolve, reject)->
    params =
      "channelId": "channel==UC7QqXY8JGtbNMcoFhfhqKeg"

    api.query params, (error, response)->
      if error?
        reject error
      else
        console.log "response: #{response}"

dropDatabase = ->
  if not db? then throw new Error "db connection is required"
  db.query "drop database if exists youtube_videos"
    .then -> db.query "drop database if exists youtube_videos_looker"

dumpVideos = ->
  for video in videos
    console.log "id:#{video.id}, youtubeId:#{video.youtubeId}, title:#{video.title}"

establishDatabaseConnection = ->
  mysql.createConnection host:"localhost", user:"root"
    .then (connection)->
      db = connection

loadSchema = ->
  db.query("""
    create table videos (
      id integer primary key auto_increment,
      youtube_id varchar(255) unique not null,
      title text not null,
      length float not null
    ) engine = InnoDB;
  """).then -> db.query("""
    create table watch_days (
      id integer primary key auto_increment,
      video_id integer,
      watch_date date not null,
      minutes_watched integer not null,
      views integer not null,
      likes integer not null,
      shares integer not null,
      comments integer not null,
      unique key (video_id, watch_date),
      foreign key (video_id) references videos (id) on delete cascade
    ) engine = InnoDB;
  """).then -> db.query("""
    create table traffic_sources (
      id integer primary key auto_increment,
      video_id integer not null,
      source_name varchar(255) not null,
      minutes_watched integer not null,
      views integer not null,
      unique key (video_id, source_name),
      foreign key (video_id) references videos (id) on delete cascade
    ) engine = InnoDB;
  """).then -> db.query("""
    create table device_types (
      id integer primary key auto_increment,
      video_id integer not null,
      device_type varchar(255) not null,
      minutes_watched integer not null,
      views integer not null,
      unique key (video_id, device_type),
      foreign key (video_id) references videos (id) on delete cascade
    ) engine = InnoDB;
  """)

############################################################################################################

authorizeGoogleApi()
 #.then -> establishDatabaseConnection()
 #.then -> dropDatabase()
 #.then -> createDatabase()
 #.then -> loadSchema()
  .catch (e)-> console.error e.stack
  .finally -> process.exit()
