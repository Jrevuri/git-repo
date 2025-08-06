WITH VIEWING AS (
SELECT
        SPN.*
        ,V.VIEWING_DATE
        ,V.TITLE
        ,V.CHANNEL
        ,V.SUBGENRE
        ,V.CAPPED_VIEWING_DURATION
FROM `sdp-sandbox-nowtv-prod.DATAMARTS.VADES` V INNER JOIN `sdp-sandbox-nowtv-int.JWN43.Nuts_Sports_Custs`SPN 
ON V.PROFILE_ID = SPN.PROFILE_ID
  AND V.VIEWING_DATE BETWEEN DATE(SPN.effective_from) AND DATE(SPN.effective_to)
WHERE COUNTRY_CODE = 'UK'
  AND VIEWING_DATE BETWEEN '2025-01-01' AND CURRENT_DATE()
  AND PRODUCT = "SPORTS"
  AND VIEWING_SCENARIO = 'LIVE'
),

  ENGAGEMENT AS(


  SELECT
        PROFILE_ID
        ,CHANNEL
        ,PC_NUT1
        ,NUT1_NAME
		    ,PC_NUT2
        ,NUT2_NAME
		    ,PC_NUT3
        ,NUT3_NAME
        ,DATE_TRUNC(VIEWING_DATE, WEEK(MONDAY)) AS week_start_date
        
        ,CASE
            WHEN SUBGENRE like '%cricket%' AND CAPPED_VIEWING_DURATION>= 180 then 'Cricket' 
            WHEN SUBGENRE like '%tennis%' AND CAPPED_VIEWING_DURATION>= 180 then 'Tennis'
            WHEN SUBGENRE like '%golf%' AND CAPPED_VIEWING_DURATION>= 180 then 'Golf'
            WHEN SUBGENRE like '%football%' AND lower(TITLE) like'%efl%' AND CAPPED_VIEWING_DURATION>= 180 then 'EFL'
            WHEN SUBGENRE like '%football%' AND lower(TITLE) not like'%efl%' AND CAPPED_VIEWING_DURATION>= 180 then 'Football'
            WHEN SUBGENRE like '%motor sport%' AND (lower(title) like '%formula%' OR lower(title) like '%f1%' OR lower(title) like '%live formula%') AND CAPPED_VIEWING_DURATION>= 180 THEN 'F1'
            WHEN SUBGENRE like '%darts%' AND CAPPED_VIEWING_DURATION>= 180 then 'Darts'
            WHEN (SUBGENRE like '%rugby league%' or subgenre = 'rugby') AND CAPPED_VIEWING_DURATION>= 180 then 'Rugby'
            ELSE 'Other'
          END AS SPORTS_TYPE
        ,COUNT(DISTINCT VIEWING_DATE) AS FREQUENCY
        ,COUNT(DISTINCT TITLE) AS REPERTOIRE_TITLE
  FROM VIEWING
  GROUP BY ALL
  )



  SELECT 
        CHANNEL
        ,PC_NUT1 as pc_Nut1
		,PC_NUT2 as pc_Nut2
		,PC_NUT3 as pc_Nut3
        ,NUT1_name as nut1_name
		,NUT2_name as nut2_name
		,NUT3_name as nut3_name
        ,week_start_date as wk_start_date
        ,EXTRACT(WEEK FROM week_start_date) AS week_num
        ,AVG(FREQUENCY) AS average_frequency
        ,AVG(REPERTOIRE_TITLE) AS average_repertoire
        ,NULL AS REPERTOIRE_CHANNEL_SERVICE_KEY
        ,COUNT(DISTINCT PROFILE_ID) AS user_count
        ,COUNT(CASE WHEN FREQUENCY > 0 THEN PROFILE_ID END) AS VIEWERS
        ,SAFE_DIVIDE(COUNT(CASE WHEN FREQUENCY > 0 THEN PROFILE_ID END),COUNT(PROFILE_ID)) AS REACH
        ,sports_type
   FROM ENGAGEMENT
     GROUP BY ALL