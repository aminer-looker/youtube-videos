view: videos {
  derived_table: {
    sql:
      select v.*, min(w.watch_date) as release_date, max(w.watch_date) as last_viewing
      from youtube_videos.videos v
      join youtube_videos.watch_days w on v.id = w.video_id
      group by v.id, v.length, v.title, v.youtube_id
      ;;
  }

  # Dimensions ######################################################################

  dimension: age {
    type: number
    sql: datediff('2017-05-13', ${release_date}) ;;
  }

  dimension: age_title {
    type: string
    sql: concat(lpad(${age}, 3, '0'), ': ', ${title});;
  }

  dimension: does_mention_mod {
    type: yesno
    sql:
      (locate('BuildCraft', title) > 0) OR
      (locate('GalacticCraft', title) > 0) OR
      (locate('Forge Microblocks', title) > 0) OR
      (locate('Storage Drawers', title) > 0) OR
      (locate('PneumaticCraft', title) > 0) OR
      (locate('RFTools', title) > 0) OR
      (locate('HarvestCraft', title) > 0) OR
      (locate('Agricraft', title) > 0) OR
      (locate('Forestry', title) > 0) OR
      (locate('OpenComputers', title) > 0) OR
      (locate('Gendustry', title) > 0) OR
      (locate('BigReactors', title) > 0) OR
      (locate('Biomes O''Plenty', title) > 0) OR
      (locate('Plant MegaPack', title) > 0)
    ;;
  }

  dimension: is_letsplay {
    label: "Is Let's Play"
    type: yesno
    sql: locate('Let''s Play', ${title}) > 0 ;;
  }

  dimension: is_modspotlight {
    label: "Is Mod Spotlight"
    type: yesno
    sql: locate('Mod Spotlight', ${title}) > 0 ;;
  }

  dimension: last_viewing {
    type: date
    sql: ${TABLE}.last_viewing ;;
  }

  dimension: length {
    type: number
    sql: ${TABLE}.length ;;
    value_format: "#0.00"
  }

  dimension_group: release {
    type: time
    timeframes: [date]
    convert_tz: no
    sql: ${TABLE}.release_date ;;
  }

  dimension: title {
    type: string
    sql: ${TABLE}.title ;;
  }

  dimension: youtube_id {
    type: string
    sql: ${TABLE}.youtube_id ;;
  }

  # Measures ########################################################################

  measure: count {
    type: count
    drill_fields: [common_fields*]
  }

  measure: max_age {
    type: max
    sql: ${age} ;;
  }

  measure: total_length {
    type: sum
    sql: ${length} ;;
  }

  # Hidden Fields ###################################################################

  dimension: id {
    primary_key: yes
    type: number
    sql: ${TABLE}.id ;;
    hidden: yes
  }

  # Drill Sets ######################################################################

  set: common_fields {
    fields: [title, youtube_id, length]
  }
}
