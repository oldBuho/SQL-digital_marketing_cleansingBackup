WITH 
	-- these JOINS add "week" and "dma_code" to inital "table"
	table_1 AS (   
		SELECT 
			t.campaign,
			t.campaign_id,
			t."site_CM360",
			t.placement,
			t.date,
			w.week,
			t.creative,
			t.dma,
			d.dma_code,
			t.impressions, 
			t.clicks
		FROM  
			public."1535940_POEM_DMA_20211019_174731_3468272742" AS t
		INNER JOIN
			public."dma_dmaCode" AS d
			ON t.dma = d.dma_dcm
		INNER JOIN
			public.day_to_week as w
			ON t.date = w.day
	), 
	-- separate buy or sell : all are "buy" 
	-- except creative with “pile of cash” is seller 
	table_2 AS (
		SELECT
			creative AS creative_sell
		FROM 
			public."1535940_POEM_DMA_20211019_174731_3468272742"
		WHERE 
			creative ILIKE '%pile of cash%'
	),
	-- table containing new columns: week, dma_code, buy_or_sell
	table_3 AS (
		SELECT 
			*, 
			CASE 
				WHEN creative IN (SELECT creative_sell FROM table_2)
					THEN 'sell' 
				ELSE 'buy'
			END AS buy_or_sell
		FROM 
			table_1
	),
	-- use columns created in table_3 to seggregate impressions and clicks  
	-- according to buy or sell classification
	table_4 AS (
		SELECT
			week, 
			dma_code, 
			buy_or_sell,
			CASE
				WHEN buy_or_sell = 'buy' THEN impressions
				ELSE 0
			END AS "imp_buy",
			CASE
				WHEN buy_or_sell = 'sell' THEN impressions
				ELSE 0
			END AS "imp_sell",
				CASE
				WHEN buy_or_sell = 'buy' THEN clicks
				ELSE 0
			END AS "click_buy",
			CASE
				WHEN buy_or_sell = 'sell' THEN clicks
				ELSE 0
			END AS "click_sell"
		FROM 
			table_3
		ORDER BY 
			dma_code ASC, 
			week ASC
	), 
	-- in this final table the clicks and buys are  
	--  grouped by week and dma_code
	table_5 AS (
		SELECT 
			week, 
			dma_code,
			SUM(imp_buy) AS p_on_CISPK_buy_imp,
			SUM(imp_sell) AS p_on_CISPK_sell_imp,
			SUM(click_buy) AS p_on_CISPK_buy_click,
			SUM(click_sell) AS p_on_CISPK_sell_click
		FROM
			table_4
		GROUP BY 
			week, 
			dma_code
		ORDER BY 
			week ASC, 
			dma_code ASC
	)

-- final result
SELECT 
	*
FROM
	table_5;
