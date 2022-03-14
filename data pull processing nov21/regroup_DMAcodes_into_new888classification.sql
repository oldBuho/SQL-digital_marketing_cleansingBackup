/*

In this query all the DMA_codes not inlcuded in the following list
would be grouped as '999':
('511', '618', '623', '635', '803'
 '807', '819', '820', '825', '839', '862')

Remember to first TRUNCATE "public.poem_data_pull_template_step_2" table.

*/

COPY public.poem_data_pull_template_step_2 -- table matching origin fields
FROM 'C:\Users\***.csv' -- load here your file name "***"
DELIMITER ','  -- check delimiter
CSV HEADER;

WITH 
	not_888_table AS (
		SELECT 
			*	
		FROM 
			public.poem_data_pull_template_step_2
		WHERE 
			dma_code IN ('511', '618', '623', '635', '803'
 						'807', '819', '820', '825', '839', '862')
	),
	_888_table AS (
		SELECT 
			week,
			'888' AS new_dma_code, -- instead of the 'dma_code' column
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
		FROM 
			public.poem_data_pull_template_step_2
		WHERE 
			dma_code NOT IN ('511', '618', '623', '635', '803'
 							'807', '819', '820', '825', '839', '862')
		GROUP BY 
			week
		ORDER BY 
			week ASC 
	)
	
-- RESULT

SELECT 
	*
FROM
	(
		SELECT * FROM not_888_table
		UNION ALL
		SELECT * FROM _888_table
	) AS final_table
ORDER BY 
 	week ASC, 
 	dma_code ASC;
					
					
