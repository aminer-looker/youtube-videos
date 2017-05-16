view: device_types {
  sql_table_name: youtube_videos.device_types ;;

  # Dimensions ######################################################################

  dimension: device_type {
    type: string
    sql: ${TABLE}.device_type ;;
  }

  dimension: minutes_watched {
    type: number
    sql: ${TABLE}.minutes_watched ;;
    value_format: "#0.00"
  }

  dimension: views {
    type: number
    sql: ${TABLE}.views ;;
  }

  # Measures ########################################################################

  measure: count {
    type: count
    drill_fields: [common_fields*]
  }

  measure: total_minutes_watched {
    type: sum
    sql: ${minutes_watched} ;;
    drill_fields: [common_fields*]
    value_format: "#0.00"
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

  # Drill Sets #######################################################################

  set: common_fields {
    fields: [device_type, minutes_watched, views]
  }
}
