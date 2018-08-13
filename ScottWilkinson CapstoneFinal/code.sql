--Project Part 1 - Get familiar with the company.
--Count of all campaigns run by CoolTShirts
SELECT COUNT(DISTINCT utm_campaign) AS 'Campaign Count'
FROM page_visits;

--Count of all channels (sources) in use by CoolTShirts
SELECT COUNT(DISTINCT utm_source) AS 'Channel Count'
FROM page_visits;

--Additional query used in slide deck
--List of all campaigns run by CoolTShirts, sorted by Channel + Campaign
SELECT DISTINCT utm_source AS 'Channels', utm_campaign AS 'Campaigns'
FROM page_visits
ORDER BY Channels, Campaigns;

--List of all pages on the CoolTShirts website where visits are recorded
SELECT DISTINCT page_name AS 'Pages'
FROM page_visits;

--Project Part 2
--Complete first touch count query, with results counted by Channel and Campaign
WITH first_touch AS (
    SELECT user_id,
        MIN(timestamp) as first_touch_at
    FROM page_visits
    GROUP BY user_id),
ft_attr AS (
  SELECT ft.user_id,
         ft.first_touch_at,
         pv.utm_source,
         pv.utm_campaign
  FROM first_touch ft
  JOIN page_visits pv
    ON ft.user_id = pv.user_id
    AND ft.first_touch_at = pv.timestamp
)
SELECT ft_attr.utm_source   AS 'Channel'
, ft_attr.utm_campaign      AS 'Campaign'
, COUNT(*)                  AS 'First Touch Attributions'
FROM ft_attr
GROUP BY ft_attr.utm_campaign, ft_attr.utm_source
ORDER BY COUNT(*) DESC;

--Complete last touch count query, with results counted by Channel and Campaign
WITH last_touch AS (
    SELECT user_id,
        MAX(timestamp) AS last_touch_at
    FROM page_visits
    GROUP BY user_id),
lt_attr AS (
  SELECT lt.user_id,
         lt.last_touch_at,
         pv.utm_source,
         pv.utm_campaign
  FROM last_touch lt
  JOIN page_visits pv
    ON lt.user_id = pv.user_id
    AND lt.last_touch_at = pv.timestamp
)
SELECT lt_attr.utm_source   AS 'Channel'
, lt_attr.utm_campaign      AS 'Campaign'
, COUNT(*)                  AS 'Last Touch Attributions'
FROM lt_attr
GROUP BY lt_attr.utm_campaign, lt_attr.utm_source
ORDER BY COUNT(*) DESC;

--Query to count all visitors who make a purchase
SELECT COUNT(DISTINCT user_id) AS 'Total Conversions (Purchase)'
FROM page_visits
WHERE page_name LIKE '4 - purchase';

--Query to count how many last touches occur on the purchase page by Channel and Campaign
WITH last_touch AS (
    SELECT user_id,
        MAX(timestamp) AS last_touch_at
    FROM page_visits
  	WHERE page_name = '4 - purchase'
    GROUP BY user_id),
lt_attr AS (
  SELECT lt.user_id,
         lt.last_touch_at,
         pv.utm_source,
         pv.utm_campaign
  FROM last_touch lt
  JOIN page_visits pv
    ON lt.user_id = pv.user_id
    AND lt.last_touch_at = pv.timestamp
)
SELECT lt_attr.utm_source   AS 'Channel'
, lt_attr.utm_campaign      AS 'Campaign'
, COUNT(*)                  AS 'Conversions'
FROM lt_attr
GROUP BY lt_attr.utm_campaign, lt_attr.utm_source;

--Additional Queries
--Additional query to find the average number of touches a user has on the website, rounded
SELECT ROUND (1.0 * COUNT (*) / COUNT (DISTINCT user_id), 2) AS 'Average number of visits per user'
FROM page_visits;

--Four additional queries below to count each page's total hits, used to demonstrate where page drops off
SELECT COUNT(DISTINCT user_id) AS 'Total Landing Page Hits'
FROM page_visits
WHERE page_name LIKE '1 - landing_page';

SELECT COUNT(DISTINCT user_id) AS 'Total Cart Hits'
FROM page_visits
WHERE page_name LIKE '2 - shopping_cart';

SELECT COUNT(DISTINCT user_id) AS 'Total Checkout Hits'
FROM page_visits
WHERE page_name LIKE '3 - checkout';

SELECT COUNT(DISTINCT user_id) AS 'Total Purchases'
FROM page_visits
WHERE page_name LIKE '4 - purchase';

--Three additional queries below to show effectiveness of each campaign
SELECT utm_campaign AS 'Campaign'
, COUNT(*)          AS 'LP Hits'
FROM page_visits
WHERE page_name LIKE '1 - landing_page'
GROUP BY utm_campaign
ORDER BY COUNT(*) DESC;

SELECT utm_campaign AS 'Campaign'
, COUNT(*)          AS 'Cart Hits'
FROM page_visits
WHERE page_name LIKE '2 - shopping_cart'
GROUP BY utm_campaign
ORDER BY COUNT(*) DESC;

SELECT utm_campaign AS 'Campaign'
, COUNT(*)          AS 'Checkout Hits'
FROM page_visits
WHERE page_name LIKE '3 - checkout'
GROUP BY utm_campaign
ORDER BY COUNT(*) DESC;