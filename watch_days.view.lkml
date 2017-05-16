view: watch_days {
  sql_table_name: youtube_videos.watch_days ;;

  # Dimensions ######################################################################

  dimension: comments {
    type: number
    sql: ${TABLE}.comments ;;
  }

  dimension: likes {
    type: number
    sql: ${TABLE}.likes ;;
  }

  dimension: minutes_watched {
    type: number
    sql: ${TABLE}.minutes_watched ;;
    value_format: "#0.00"
  }

  dimension: shares {
    type: number
    sql: ${TABLE}.shares ;;
  }

  dimension: views {
    type: number
    sql: ${TABLE}.views ;;
  }

  dimension_group: watch {
    type: time
    timeframes: [date]
    convert_tz: no
    sql: ${TABLE}.watch_date ;;
  }

  # Measures ########################################################################

  measure: average_minutes_watched {
    type: number
    sql: ${total_minutes_watched} / ${total_views} ;;
    value_format: "#0.00"
  }

  measure: average_views {
    type: average
    sql: ${views} ;;
    value_format: "#0.00"
  }

  measure: count {
    type: count
    drill_fields: [common_fields*]
  }

  measure: cumulative_minutes_watched {
    type: running_total
    sql: ${minutes_watched} ;;
  }

  measure: average_percent_watched {
    type: number
    sql: ${average_minutes_watched} / ${videos.length};;
    value_format: "#0.00%"
  }

  measure: earliest_date {
    type: date
    sql: min(${TABLE}.watch_date) ;;
  }

  measure: latest_date {
    type: date
    sql: max(${TABLE}.watch_date) ;;
  }

  measure: total_comments {
    type: sum
    sql: ${comments} ;;
    drill_fields: [common_fields*]
  }

  measure: total_likes {
    type: sum
    sql: ${likes} ;;
    drill_fields: [common_fields*]
  }

  measure: total_minutes_watched {
    type: sum
    sql: ${minutes_watched} ;;
    drill_fields: [common_fields*]
    value_format: "#0.00"
  }

  measure: total_shares {
    type: sum
    sql: ${shares} ;;
    drill_fields: [common_fields*]
  }

  measure: total_views {
    type: sum
    sql: ${views} ;;
    drill_fields: [common_fields*]
  }

  # Hidden Fields ###################################################################

  dimension: id {
    primary_key: yes
    type: number
    sql: ${TABLE}.id ;;
    hidden: yes
  }

  dimension: video_id {
    type: number
    sql: ${TABLE}.video_id ;;
    hidden: yes
  }

  # Drill Sets ######################################################################

  set: common_fields {
    fields: [watch_date, videos.title, minutes_watched, views]
  }
}
