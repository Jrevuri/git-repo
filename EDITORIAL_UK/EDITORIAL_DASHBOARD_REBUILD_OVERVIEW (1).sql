
CREATE OR REPLACE TABLE `sdp-sandbox-nowtv-int.SGL18.EDITORIAL_DASHBOARD_REBUILD_OVERVIEW` AS

select 
  adobe_date,
  geo_country,
  device_type,
  entry_app_section,
  sum(case when visit is null then 0 else visit end) as total_visits,
  sum(case when click is null then 0 else tile_click end) as total_clicks,
  sum(case when player_click is null then 0 else player_click end) as total_plays,
  count(distinct visitor_id) as total_users
from `sdp-sandbox-nowtv-int.SGL18.EDITORIAL_DASHBOARD_REVAMP_RAW_TABLE`
where entry_app_section is not null
group by 1,2,3,4
order by 1,2,3,4
