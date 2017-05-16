view: videos {
  sql_table_name: youtube_videos.videos ;;

  dimension: id {
    primary_key: yes
    type: number
    sql: ${TABLE}.id ;;
  }

  dimension: length {
    type: number
    sql: ${TABLE}.length ;;
  }

  dimension: title {
    type: string
    sql: ${TABLE}.title ;;
  }

  dimension: youtube_id {
    type: string
    sql: ${TABLE}.youtube_id ;;
  }

  measure: count {
    type: count
    drill_fields: [id, device_types.count, traffic_sources.count, watch_days.count]
  }
}
