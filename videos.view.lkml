view: videos {
  sql_table_name: youtube_videos.videos ;;

  # Dimensions ######################################################################

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

  dimension: length {
    type: number
    sql: ${TABLE}.length ;;
    value_format: "#0.00"
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
