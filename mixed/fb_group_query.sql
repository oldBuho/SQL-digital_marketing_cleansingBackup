SELECT
	week,
	dma_code,
	SUM(buy_impressions) AS sum_buy_imp, 
	SUM(sell_impressions) AS sum_sell_imp,
	SUM("buySell_impressions") AS sum_buySell_imp,
	SUM(other_impressions) AS sum_other_imp,
	SUM("amount_spent_USD") AS sum_amount_spent_USD
FROM 
	public.fb_final_data
GROUP BY
	week, dma_code
ORDER BY 
	week, dma_code
