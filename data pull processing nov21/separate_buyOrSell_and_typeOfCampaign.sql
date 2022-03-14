/*

1°) be sure template table "poem_data_pull_TEMPLATE" is truncated 
and your source table has the same fields as this template table. 

2) imp, clicks and cost are treated as varchar for later comma extraction in case the data
is rendered as "1,200" so it would be converted to a simple number "1200".

3) BEFORE UPLOAD delete first lines containing report data (date range, source, etc)
and also delete final empty rows

*/

COPY public."poem_data_pull_TEMPLATE" -- table matching origin fields
FROM 'C:\Users\Public\***.csv' -- load here your file name "***"
DELIMITER ','  -- check delimiter
CSV HEADER;


WITH 
	-- table_1 leaves out unneeded fields, joins with "dma_code" and "week" 
	-- and parses impressions from varchar to numeric (remember note above)
	table_1 AS (
		SELECT 
			ACCOUNT_NAME,
			CASE
				WHEN LOWER(t."account_name") = 'shift buy' THEN 'buy'		
				ELSE 'sell'
			END AS buy_or_sell,
			--CUSTOMER_ID,
			-- t.campaign,
			LOWER(t.CAMPAIGN_TYPE) AS campaign_type,
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
			--d.dma_code,
			CASE
				WHEN t."metro_area__User_location" = 'Elmira (Corning) NY'  THEN '565' -- classification not included in table "d"
				WHEN d.dma_code IS NULL THEN '999' -- eg: dma as JP_CHUKYO (JP_%)
				ELSE d.dma_code 
			END AS dma_code,		
			--CITY__USER_LOCATION,
			t.day,
			w.week,
			CURRENCY_CODE,
			-- clicks_as_varchar,
			(REPLACE(t.clicks_as_varchar, ',', ''))::numeric as clicks, -- taking out de thousand-comma
			--impressions_as_varchar,
			(REPLACE(t.impressions_as_varchar, ',', ''))::numeric as impressions,
			--t.cost_as_varchar,
			(REPLACE(t.cost_as_varchar, ',', ''))::numeric as spent_usd
		FROM 
			public."poem_data_pull_TEMPLATE" t
		LEFT JOIN
			public.day_to_week as w
			ON t."day" = w.day
		LEFT JOIN
			public."dma_dmaCode" AS d
			ON t."metro_area__User_location" = d.dma_3 -- verify correct match (see table "d")
	),
	-- classification & segregation of imp, clicks and spent according to 
	-- campaign_type and buy_or_sell by week and dma_code
	table_2 AS (
		SELECT
			week, 
			dma_code,
			-- buy-impression section:
			CASE
				WHEN campaign_type = 'discovery' AND buy_or_sell = 'buy' THEN impressions
				ELSE 0
			END AS p_on_discovery_buy_imp,
			CASE
				WHEN campaign_type = 'display' AND buy_or_sell = 'buy' THEN impressions
				ELSE 0
			END AS p_on_display_buy_imp,
			CASE
				WHEN campaign_type = 'search' AND buy_or_sell = 'buy' THEN impressions
				ELSE 0
			END AS p_on_search_buy_imp,
			CASE
				WHEN campaign_type = 'shopping' AND buy_or_sell = 'buy' THEN impressions
				ELSE 0
			END AS p_on_shopping_buy_imp,	
			CASE
				WHEN campaign_type = 'video' AND buy_or_sell = 'buy' THEN impressions
				ELSE 0
			END AS p_on_video_buy_imp,
		-- sell-impression section:
			CASE
				WHEN campaign_type = 'discovery' AND buy_or_sell = 'sell' THEN impressions
				ELSE 0
			END AS p_on_discovery_sell_imp,
			CASE
				WHEN campaign_type = 'display' AND buy_or_sell = 'sell' THEN impressions
				ELSE 0
			END AS p_on_display_sell_imp,
			CASE
				WHEN campaign_type = 'search' AND buy_or_sell = 'sell' THEN impressions
				ELSE 0
			END AS p_on_search_sell_imp,
			CASE
				WHEN campaign_type = 'shopping' AND buy_or_sell = 'sell' THEN impressions
				ELSE 0
			END AS p_on_shopping_sell_imp,	
			CASE
				WHEN campaign_type = 'video' AND buy_or_sell = 'sell' THEN impressions
				ELSE 0
			END AS p_on_video_sell_imp,
			-- buy-clicks section:
			CASE
				WHEN campaign_type = 'discovery' AND buy_or_sell = 'buy' THEN clicks
				ELSE 0
			END AS p_on_discovery_buy_clicks,
			CASE
				WHEN campaign_type = 'display' AND buy_or_sell = 'buy' THEN clicks
				ELSE 0
			END AS p_on_display_buy_clicks,
			CASE
				WHEN campaign_type = 'search' AND buy_or_sell = 'buy' THEN clicks
				ELSE 0
			END AS p_on_search_buy_clicks,
			CASE
				WHEN campaign_type = 'shopping' AND buy_or_sell = 'buy' THEN clicks
				ELSE 0
			END AS p_on_shopping_buy_clicks,	
			CASE
				WHEN campaign_type = 'video' AND buy_or_sell = 'buy' THEN clicks
				ELSE 0
			END AS p_on_video_buy_clicks,
			-- sell-clicks section:
			CASE
				WHEN campaign_type = 'discovery' AND buy_or_sell = 'sell' THEN clicks
				ELSE 0
			END AS p_on_discovery_sell_clicks,
			CASE
				WHEN campaign_type = 'display' AND buy_or_sell = 'sell' THEN clicks
				ELSE 0
			END AS p_on_display_sell_clicks,
			CASE
				WHEN campaign_type = 'search' AND buy_or_sell = 'sell' THEN clicks
				ELSE 0
			END AS p_on_search_sell_clicks,
			CASE
				WHEN campaign_type = 'shopping' AND buy_or_sell = 'sell' THEN clicks
				ELSE 0
			END AS p_on_shopping_sell_clicks,	
			CASE
				WHEN campaign_type = 'video' AND buy_or_sell = 'sell' THEN clicks
				ELSE 0
			END AS p_on_video_sell_clicks,
			-- buy-spent section:
			CASE
				WHEN campaign_type = 'discovery' AND buy_or_sell = 'buy' THEN spent_usd
				ELSE 0.00
			END AS p_on_discovery_buy_spent_usd,
			CASE
				WHEN campaign_type = 'display' AND buy_or_sell = 'buy' THEN spent_usd
				ELSE 0.00
			END AS p_on_display_buy_spent_usd,
			CASE
				WHEN campaign_type = 'search' AND buy_or_sell = 'buy' THEN spent_usd
				ELSE 0.00
			END AS p_on_search_buy_spent_usd,
			CASE
				WHEN campaign_type = 'shopping' AND buy_or_sell = 'buy' THEN spent_usd
				ELSE 0.00
			END AS p_on_shopping_buy_spent_usd,	
			CASE
				WHEN campaign_type = 'video' AND buy_or_sell = 'buy' THEN spent_usd
				ELSE 0.00
			END AS p_on_video_buy_spent_usd,
			-- sell-spent section:
			CASE
				WHEN campaign_type = 'discovery' AND buy_or_sell = 'sell' THEN spent_usd
				ELSE 0.00
			END AS p_on_discovery_sell_spent_usd,
			CASE
				WHEN campaign_type = 'display' AND buy_or_sell = 'sell' THEN spent_usd
				ELSE 0.00
			END AS p_on_display_sell_spent_usd,
			CASE
				WHEN campaign_type = 'search' AND buy_or_sell = 'sell' THEN spent_usd
				ELSE 0.00
			END AS p_on_search_sell_spent_usd,
			CASE
				WHEN campaign_type = 'shopping' AND buy_or_sell = 'sell' THEN spent_usd
				ELSE 0.00
			END AS p_on_shopping_sell_spent_usd,	
			CASE
				WHEN campaign_type = 'video' AND buy_or_sell = 'sell' THEN spent_usd
				ELSE 0.00
			END AS p_on_video_sell_spent_usd
		FROM table_1
	),
	-- in this final table the clicks and buys are  
	--  grouped by week and dma_code	
	table_3 AS (
		SELECT
			week, 
			dma_code,
			sum(p_on_discovery_buy_imp) AS p_on_discovery_buy_imp,
			sum(p_on_display_buy_imp) AS p_on_display_buy_imp,
			sum(p_on_search_buy_imp) AS p_on_search_buy_imp,
			sum(p_on_shopping_buy_imp) AS p_on_shopping_buy_imp,
			sum(p_on_video_buy_imp) p_on_video_buy_imp,
			sum(p_on_discovery_sell_imp) AS p_on_discovery_sell_imp,
			sum(p_on_display_sell_imp) AS p_on_display_sell_imp,
			sum(p_on_search_sell_imp) AS p_on_search_sell_imp,
			sum(p_on_shopping_sell_imp) AS p_on_shopping_sell_imp,
			sum(p_on_video_sell_imp) AS p_on_video_sell_imp,
			sum(p_on_discovery_buy_clicks) AS p_on_discovery_buy_clicks,
			sum(p_on_display_buy_clicks) AS p_on_display_buy_clicks,
			sum(p_on_search_buy_clicks) AS p_on_search_buy_clicks,
			sum(p_on_shopping_buy_clicks) AS p_on_shopping_buy_clicks,
			sum(p_on_video_buy_clicks) AS p_on_video_buy_clicks,
			sum(p_on_discovery_sell_clicks) AS p_on_discovery_sell_clicks,
			sum(p_on_display_sell_clicks) AS p_on_display_sell_clicks,
			sum(p_on_search_sell_clicks) AS p_on_search_sell_clicks,
			sum(p_on_shopping_sell_clicks) AS p_on_shopping_sell_clicks,
			sum(p_on_video_sell_clicks) AS p_on_video_sell_clicks,
			sum(p_on_discovery_buy_spent_usd) AS p_on_discovery_buy_spent_usd,
			sum(p_on_display_buy_spent_usd) AS p_on_display_buy_spent_usd,
			sum(p_on_search_buy_spent_usd) AS p_on_search_buy_spent_usd,
			sum(p_on_shopping_buy_spent_usd) AS p_on_shopping_buy_spent_usd,
			sum(p_on_video_buy_spent_usd) AS p_on_video_buy_spent_usd,
			sum(p_on_discovery_sell_spent_usd) AS p_on_discovery_sell_spent_usd,
			sum(p_on_display_sell_spent_usd) AS p_on_display_sell_spent_usd,
			sum(p_on_search_sell_spent_usd) AS p_on_search_sell_spent_usd,
			sum(p_on_shopping_sell_spent_usd) AS p_on_shopping_sell_spent_usd,
			sum(p_on_video_sell_spent_usd) AS p_on_video_sell_spent_usd
		FROM table_2
		GROUP BY 
			week, 
			dma_code
		ORDER BY 
			week ASC, 
			dma_code ASC	
	)
		
		
-- final result:

SELECT * FROM table_3;

/*

1) look for DMAs that doesn´t match (null) after running this.. could
be a wrong '999' code applied >> select distinct(dma) from table_1 where dma_code = '999'

2) check if only USD type of money >>> SELECT distinct(currency_code) from table_1

3) to END, remember to TRUNCATE the "poem_data_pull_dis_and_vid" table!!!!

/*

