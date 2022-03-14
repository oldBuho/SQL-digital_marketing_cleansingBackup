/*

1° be sure template table "poem_data_pull_dis_and_vid" is truncated 
and your source table has the same fields as this template table. 

note: imp and clicks are treated as varchar for later comma extraction in case the data
is rendered as "1,200" so it would be converted to a simple number "1200".

BEFORE UPLOAD delete first lines containing report data (date range, source, etc)
and also delete final empty rows

*/

COPY public.poem_data_pull_dis_and_vid -- table matching origin fields
FROM 'C:\Users\Public\***.csv' -- load here your file name "***"
DELIMITER ','  -- check delimiter
CSV HEADER;



WITH 
	-- table_1 leaves out unneeded fields, joins with "dma_code" and "week" 
	-- and parses impressions from varchar to numeric (remember note above)
	table_1 AS (
		SELECT 
			--ACCOUNT_NAME,
			--CUSTOMER_ID,
			LOWER(campaign) AS campaign,
			--CAMPAIGN_TYPE,
			--CAMPAIGN_SUBTYPE,
			--LABELS_ON_CAMPAIGN,
			--CAMPAIGN_BID_STRATEGY,
			--CAMPAIGN_BID_STRATEGY_TYPE,
			--CAMPAIGN_SITELINKS_ACTIVE,
			--CAMPAIGN_SITELINKS_DISAPPROVED,
			--CAMPAIGN_PHONE_NUMBERS_ACTIVE,
			--CAMPAIGN_PHONE_NUMBERS_DISAPPROVED,
			--CAMPAIGN_APPS_ACTIVE,
			--CAMPAIGN_APPS_DISAPPROVED,
			--CAMPAIGN_APPS_LEVEL,
			--CAMPAIGN_DESKTOP_BID_ADJ,
			--CAMPAIGN_MOBILE_BID_ADJ,
			--CAMPAIGN_TABLET_BID_ADJ,
			t."metro_area__User_location" as dma,
			d.dma_code,
			--CITY__USER_LOCATION,
			t.day,
			w.week,
			--CURRENCY_CODE,
			-- clicks_as_varchar,
			(REPLACE(t.clicks_as_varchar, ',', ''))::numeric as clicks,
			--impressions_as_varchar,
			(REPLACE(t.impressions_as_varchar, ',', ''))::numeric as impressions,
			t.COST as spent
		FROM 
			PUBLIC.POEM_DATA_PULL_DIS_AND_VID t
		INNER JOIN
			public.day_to_week as w
			ON t."day" = w.day
		INNER JOIN
			public."dma_dmaCode" AS d
			ON t."metro_area__User_location" = d.dma_3
	), 
	-- defining buy_sell_campaigns
	buy_sell_campaigns AS  (
		SELECT DISTINCT campaign 
		FROM table_1
		WHERE campaign LIKE '%sell%'
			AND
			campaign LIKE '%buy%'
	),
	-- defining sell_campaigns
	sell_campaigns AS (	
		SELECT DISTINCT campaign 
		FROM table_1
		WHERE campaign LIKE '%sell%'
			AND
			campaign NOT LIKE '%buy%'
	),
	-- defining buy_campaigns
	buy_campaigns AS (	
		SELECT DISTINCT campaign 
		FROM table_1
		WHERE campaign LIKE '%buy%'
			AND
			campaign NOT LIKE '%sell%'
	),
	-- table_1 including buy or sale classification field
	table_2 AS (
		SELECT 
			*, -- ALL FIELDS INCLUDED
			CASE 
				WHEN campaign IN (SELECT campaign FROM buy_sell_campaigns)
					THEN 'buysell' 
				WHEN campaign IN (SELECT campaign FROM sell_campaigns)
					THEN 'sell'
				WHEN campaign IN (SELECT campaign FROM buy_campaigns)
					THEN 'buy'		
				ELSE 'other'
			END AS buy_sell_buysell -- NEW classification field
		FROM 
			table_1
	),
	-- use columns created in table_2 to seggregate impressions and clicks  
	-- according to buy or sell classification
	table_3 AS (
		SELECT
			week, 
			dma_code, 
			buy_sell_buysell,
			CASE
				WHEN buy_sell_buysell = 'buy' THEN impressions
				ELSE 0
			END AS "imp_buy",
			CASE
				WHEN buy_sell_buysell = 'sell' THEN impressions
				ELSE 0
			END AS "imp_sell",		
			CASE
				WHEN buy_sell_buysell = 'buysell' THEN impressions
				ELSE 0
			END AS "imp_buysell",		
			CASE
				WHEN buy_sell_buysell = 'other' THEN impressions
				ELSE 0
			END AS "imp_other",	
			CASE
				WHEN buy_sell_buysell = 'buy' THEN clicks
				ELSE 0
			END AS "clk_buy",
			CASE
				WHEN buy_sell_buysell = 'sell' THEN clicks
				ELSE 0
			END AS "clk_sell",		
			CASE
				WHEN buy_sell_buysell = 'buysell' THEN clicks
				ELSE 0
			END AS "clk_buysell",
			CASE
				WHEN buy_sell_buysell = 'other' THEN clicks
				ELSE 0
			END AS "clk_other",			
			CASE
				WHEN buy_sell_buysell = 'buy' THEN spent
				ELSE 0::money
			END AS "spt_buy",
			CASE
				WHEN buy_sell_buysell = 'sell' THEN spent
				ELSE 0::money
			END AS "spt_sell",		
			CASE
				WHEN buy_sell_buysell = 'buysell' THEN spent
				ELSE 0::money
 			END AS "spt_buysell",
			CASE
				WHEN buy_sell_buysell = 'other' THEN spent
				ELSE 0::money
			END AS "spt_other"		
		FROM 
			table_2
		ORDER BY 
			dma_code ASC, 
			week ASC
	),
	-- in this final table the clicks and buys are  
	--  grouped by week and dma_code		
	table_4 AS (
		SELECT 
			week, 
			dma_code,
			SUM(imp_buy) AS p_on_CISPK_buy_imp,
			SUM(imp_sell) AS p_on_CISPK_sell_imp,
			SUM(imp_buysell) AS p_on_CISPK_buysell_imp,
			SUM(imp_other) AS p_on_CISPK_other_imp,

			SUM(clk_buy) AS p_on_CISPK_buy_click,
			SUM(clk_sell) AS p_on_CISPK_sell_click,
			SUM(clk_buysell) AS p_on_CISPK_buysell_click,
			SUM(clk_other) AS p_on_CISPK_other_click,		
		
			SUM(spt_buy) AS buy_amount_spent_usd,
			SUM(spt_sell) AS sell_amount_spent_usd,
			SUM(spt_buysell) AS buysell_amount_spent_usd,
			SUM(spt_other) AS other_amount_spent_usd	
		FROM
			table_3
		GROUP BY 
			week, 
			dma_code
		ORDER BY 
			week ASC, 
			dma_code ASC		
	)
	
	
-- final result:
SELECT * FROM table_4;


-- to END, remember to TRUNCATE the "poem_data_pull_dis_and_vid" table!!!!








	
	
