-----DATALEMUR SQL QUESTIONS-------
--Q1 Name of each credit card and the difference in issued amount -----
SELECT card_name,
    MAX(issued_amount) - MIN (issued_amount) AS Difference
FROM monthly_cards_issued
GROUP BY card_name
ORDER BY Difference DESC

--Q2 Calculate the mean of a product
SELECT 
   SUM(item_count*order_occurrences)/SUM(order_occurrences)AS Mean
FROM items_per_order

---Q3 Top 3 Drugs sold in a Pharmacy
SELECT  drug,
Total_sales - cogs AS Total_profit
FROM pharmacy_sales
ORDER BY Total_profit DESC
LIMIT 3


----Q4  Manufactures will non profitable drugs
SELECT 
manufacturer, 
COUNT(drug) AS drug_count,
ABS(SUM(total_sales - cogs)) As total_loss
FROM pharmacy_sales
WHERE total_sales - cogs <=0
GROUP BY manufacturer
ORDER BY total_loss DESC;


-----Q5 Find the total sales of drugs for each manufacturer. 
SELECT manufacturer, 
CONCAT('$', ROUND(SUM(total_sales) / 1000000), ' million') as sales
FROM pharmacy_sales
GROUP BY manufacturer
ORDER BY SUM(total_sales) DESC;


----Q6  Query to find how many members made 3 or more calls
SELECT COUNT(policy_holder_id) AS member_count
FROM(
 SELECT policy_holder_id,
  count (case_id)
  FROM callers
  GROUP BY policy_holder_id
  HAVING COUNT(case_id) >=3
) AS calls;


------Q7 A query to find the percentage of calls that cannot be categorised.
SELECT 
  ROUND(100.0 * COUNT(case_id)/
      (SELECT COUNT(*) FROM callers),1) AS uncategorised_call_pct
FROM callers
WHERE call_category IS NULL 
  OR call_category = 'n/a';


  -----Q8 Calculate the 3-day rolling average of tweets published by each user for each date that a tweet was posted.
  SELECT
  user_id,
  tweet_date,
  ROUND(
    AVG(tweet_num) OVER (
      PARTITION BY user_id
      ORDER BY user_id, tweet_date
      ROWS BETWEEN 2 PRECEDING AND CURRENT ROW), 2)
  AS rolling_avg_3d
FROM (
  SELECT
    user_id,
    tweet_date,
    COUNT(DISTINCT tweet_id) AS tweet_num
  FROM tweets
  GROUP BY user_id, tweet_date) AS tweet_count;

------Q9 Top 5 artist names in ascending order along with their song appearances ranking
  WITH top_artists
AS (SELECT
  artist_id,
  DENSE_RANK() OVER (
  ORDER BY Song_count DESC
  ) AS artist_rank
FROM (
SELECT Ar.artist_id, COUNT(GSR.song_id) AS Song_count 
FROM artists AS Ar
JOIN Songs AS S
ON ar.artist_id = s.artist_id
JOIN global_song_rank AS GSR
ON GSR.song_id = S.song_id
WHERE rank <=10
GROUP BY Ar.artist_id
) AS Top_songs
)

SELECT 
  artists.artist_name,
  top_artists.artist_rank
FROM top_artists
JOIN artists
  ON top_artists.artist_id = artists.artist_id
WHERE top_artists.artist_rank  <= 5
ORDER BY artist_rank, artist_name;


---Q10 A query to find the activation rate of the users
SELECT
  ROUND(
    SUM(
      CASE WHEN texts.email_id IS NOT NULL THEN 1
      ELSE 0 END)::DECIMAL
    / COUNT(user_id),2) AS activation_rate
FROM emails
LEFT JOIN texts
  ON emails.email_id = texts.email_id
  AND signup_action = 'Confirmed';