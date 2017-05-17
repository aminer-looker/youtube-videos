fs       = require "fs"
moment   = require "moment"
mysql    = require "promise-mysql"
parseCsv = require "csv-parse/lib/sync"
path     = require "path"
Promise  = require "bluebird"
util     = require "util"
_        = require "underscore"

############################################################################################################

DEVICE_TYPES_DIR    = "./data/device_types"
SUMMARY_DIR         = "./data/summary"
TRAFFIC_SOURCES_DIR = "./data/traffic_sources"
WATCH_TIME_DIR      = "./data/watch_time"

db     = null
videos = null

############################################################################################################

createDatabase = ->
  if not db? then throw new Error "db connection is required"
  db.query "create database youtube_videos character set = 'UTF8'"
    .then -> db.query "create database youtube_videos_looker character set = 'UTF8'"
    .then -> db.query "use youtube_videos"

dropDatabase = ->
  if not db? then throw new Error "db connection is required"
  db.query "drop database if exists youtube_videos"
    .then -> db.query "drop database if exists youtube_videos_looker"

dumpVideos = ->
  for video in videos
    console.log "id:#{video.id}, youtubeId:#{video.youtubeId}, title:#{video.title}"

establishConnection = ->
  mysql.createConnection host:"localhost", user:"root"
    .then (connection)->
      db = connection

loadCsvData = (dir, isValidFile, onRowFound)->
  if not videos? then throw new Error "videos is required"

  detailFiles = fs.readdirSync dir

  promises = []
  for video in videos
    matchingFiles = _(detailFiles).filter (name)->
      return false unless isValidFile(name)
      return false if name.indexOf(video.youtubeId) is -1
      return true

    if not matchingFiles.length > 0
      console.warn "Could not find file in #{dir} for #{video.title} (#{video.youtubeId})"
      continue

    fileName = path.join dir, matchingFiles[0]
    text = fs.readFileSync fileName, encoding:"utf-8"
    rows = parseCsv text, columns:true

    promises = []
    for row in rows
      promises.push onRowFound(video, row)

  Promise.all promises

loadDeviceTypes = ->
  loadCsvData DEVICE_TYPES_DIR, ((name)-> name.indexOf("device_type.csv") isnt -1), (video, row)->
      query = """
        insert into device_types (
          video_id, device_type, minutes_watched, views
        ) values (?, ?, ?, ?)
      """
      params = [ video.id, row.device_type, row.watch_time_minutes, row.views ]
      return db.query query, params

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

loadTrafficSources = ->
  if not videos? then throw new Error "videos is required"

  detailFiles = fs.readdirSync TRAFFIC_SOURCES_DIR

  promises = []
  for video in videos
    matchingFiles = _(detailFiles).filter (name)->
      return false unless name.indexOf("trafficsources") is 0
      return false if name.indexOf(video.youtubeId) is -1
      return true

    if not matchingFiles.length > 0
      console.warn "Could not find traffic sources file for #{video.title} (#{video.youtubeId})"
      continue

    trafficSourcesFile = path.join TRAFFIC_SOURCES_DIR, matchingFiles[0]
    trafficSourcesText = fs.readFileSync trafficSourcesFile, encoding:"utf-8"
    trafficSourcesRows = parseCsv trafficSourcesText, columns:true

    promises = []
    for row in trafficSourcesRows
      query = """
        insert into traffic_sources (
          video_id, source_name, minutes_watched, views
        )
        values (?, ?, ?, ?)
      """
      params = [
        video.id, row.traffic_source, row.watch_time_minutes, row.views
      ]
      promises.push db.query query, params

  Promise.all promises

loadVideos = ->
  if not db? then throw new Error "db connection is required"

  videos           = []
  summaryFiles     = fs.readdirSync SUMMARY_DIR
  videoSummaryFile = (file for file in summaryFiles when file.indexOf(".video.csv") isnt -1)[0]
  videoSummaryText = fs.readFileSync path.join(SUMMARY_DIR, videoSummaryFile), encoding:"utf-8"
  videoData        = parseCsv videoSummaryText, columns:true

  promises = []
  for row in videoData
    continue if row.video_title is row.video_id # deleted video

    query = "insert into videos (youtube_id, title, length) values (?, ?, ?)"
    params = [ row.video_id, row.video_title, row.video_length_minutes ]
    do (row)->
      promise = db.query query, params
        .then (results)->
          videos.push id:results.insertId, youtubeId:row.video_id, title:row.video_title
      promises.push promise

  Promise.all promises

loadWatchTime = ->
  if not videos? then throw new Error "videos is required"

  detailFiles = fs.readdirSync WATCH_TIME_DIR

  promises = []
  for video in videos
    matchingFiles = _(detailFiles).filter (name)->
      return false unless name.indexOf("watch_time") is 0
      return false if name.indexOf(video.youtubeId) is -1
      return true

    if not matchingFiles.length > 0
      console.warn "Could not find watch time file for #{video.title} (#{video.youtubeId})"
      continue

    watchDayFile = matchingFiles[0]
    watchDayText = fs.readFileSync path.join(WATCH_TIME_DIR, watchDayFile), encoding:"utf-8"
    watchDayRows = parseCsv watchDayText, columns:true

    promises = []
    for row in watchDayRows
      continue if row.watch_time_minutes is "0"

      query = """
        insert into watch_days (
          video_id, watch_date, minutes_watched, views, likes, shares, comments
        )
        values (?, ?, ?, ?, ?, ?, ?)
      """
      params = [
        video.id, row.date, row.watch_time_minutes, row.views, row.likes, row.shares, row.comments
      ]
      promises.push db.query query, params

  Promise.all promises

############################################################################################################

establishConnection()
  .then -> dropDatabase()
  .then -> createDatabase()
  .then -> loadSchema()
  .then -> loadVideos()
  .then -> loadWatchTime()
  .then -> loadTrafficSources()
  .then -> loadDeviceTypes()
  .catch (e)-> console.error e.stack
  .finally -> process.exit()
