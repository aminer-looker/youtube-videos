connection: "youtube-videos"

# include all the views
include: "*.view"

# include all the dashboards
include: "*.dashboard"

explore: device_types {
  join: videos {
    type: left_outer
    sql_on: ${device_types.video_id} = ${videos.id} ;;
    relationship: many_to_one
  }
}

explore: traffic_sources {
  join: videos {
    type: left_outer
    sql_on: ${traffic_sources.video_id} = ${videos.id} ;;
    relationship: many_to_one
  }
}

explore: videos {}

explore: watch_days {
  join: videos {
    type: left_outer
    sql_on: ${watch_days.video_id} = ${videos.id} ;;
    relationship: many_to_one
  }
}
