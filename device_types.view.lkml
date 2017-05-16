view: device_types {
  sql_table_name: youtube_videos.device_types ;;

  dimension: id {
    primary_key: yes
    type: number
    sql: ${TABLE}.id ;;
  }

  dimension: device_type {
    type: string
    sql: ${TABLE}.device_type ;;
  }

  dimension: minutes_watched {
    type: number
    sql: ${TABLE}.minutes_watched ;;
  }

  dimension: video_id {
    type: number
    # hidden: yes
    sql: ${TABLE}.video_id ;;
  }

  dimension: views {
    type: number
    sql: ${TABLE}.views ;;
  }

  measure: count {
    type: count
    drill_fields: [id, videos.id]
  }
}
