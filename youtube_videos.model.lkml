connection: "youtube-videos"

# include all the views
include: "*.view"

# include all the dashboards
include: "*.dashboard"

explore: videos {
  join: device_types {
    type: left_outer
    sql_on: ${videos.id} = ${device_types.video_id} ;;
    relationship: one_to_many
  }
  join: traffic_sources {
    type: left_outer
    sql_on: ${videos.id} = ${traffic_sources.video_id} ;;
    relationship: one_to_many
  }
  join: watch_days {
    type: left_outer
    sql_on: ${videos.id} = ${watch_days.video_id} ;;
    relationship: one_to_many
  }
}
