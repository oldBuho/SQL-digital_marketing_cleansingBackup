-- from a table that only has impressions and a "kind of type 
-- of" campaign (buy, sell or other) as two colums 
-- I use separate_impressions query to divide that 'impressions' column into three 

WITH separate_impressions AS 
	(
	SELECT
		id,
		week, 
		dma_code, 
		type,
		CASE
			WHEN classification = 'buy' THEN impressions
			ELSE 0
		END AS "imp_buy",
		CASE
			WHEN classification = 'sell' THEN impressions
			ELSE 0
		END AS "imp_sell",
		CASE
			WHEN classification = 'other' THEN impressions
			ELSE 0
		END AS "imp_other",
		"amount_spent_USD"
	FROM 
		public.google_jan6_mar3_2019_semiprocessed 
	),
	final_table AS 
	(
	SELECT 
		week, 
		dma_code,
		type AS campaign_type,
		SUM(imp_buy) AS p_on_g_buy_imp,
		SUM(imp_sell) AS p_on_g_sell_imp,
		SUM(imp_other) AS p_on_g_other_imp,
		SUM("amount_spent_USD") AS amount_spent_USD
	FROM
		separate_impressions
	GROUP BY 
		week, 
		dma_code,
		campaign_type
	ORDER BY 
		week ASC, 
		dma_code ASC
	)
	
select *
from final_table




