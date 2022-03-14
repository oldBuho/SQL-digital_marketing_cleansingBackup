-- TOTAL TABLE ROWS 231990 

WITH BUY_SELL AS (
				SELECT 
					id,
					camp_name_upper
				FROM 
					campaign_definitions
				WHERE 
					camp_name_upper LIKE '%SELL%'
					AND
					camp_name_upper LIKE '%BUY%'
				) -- #204 ROWS OK
	BUY AS (
				SELECT 
					id,
					camp_name_upper
				FROM 
					campaign_definitions
				WHERE 
					camp_name_upper LIKE '%BUY%'
					AND
					camp_name_upper NOT LIKE '%SELL%'
				UNION -- to take out the exceptions "words" in Fb posts
					SELECT 
					id,
					camp_name_upper
				FROM 
					campaign_definitions
				WHERE 
					camp_name_upper NOT LIKE '%SELL%'
					AND
					camp_name_upper NOT LIKE '%BUY%'
					AND
					camp_name_upper NOT LIKE '%HIRE%'
					AND
					camp_name_upper NOT LIKE '%HIRING%'
						AND
					camp_name_upper NOT LIKE '%JOB%'
					AND
					camp_name_upper NOT LIKE '%WORK%'
				) -- #ROWS 83587  
	SELL AS (
				SELECT 
					id,
					camp_name_upper
				FROM 
					campaign_definitions
				WHERE 
					camp_name_upper LIKE '%SELL%'
					AND
					camp_name_upper NOT LIKE '%BUY%'
			) -- #ROWS 140656  OK
	
-- with the obtainded data  generate an union 
SELECT *
FROM public.fb_final_data
WHERE id NOT IN (
		SELECT id
		FROM "BUY_SELL"
		UNION --
		SELECT id
		FROM BUY
		UNION --
		SELECT id 
		FROM SELL
		);

