SELECT *
FROM subscriptions
limit 100;

-- query 1.1 
SELECT min(subscription_start) AS first_customer, 
       max(subscription_start) AS last_activity
  FROM subscriptions;

-- query 1.2 
SELECT min(subscription_end) AS first_end  
  FROM subscriptions;

-- query 1.3
SELECT distinct segment,
       count(*)
  FROM subscriptions
GROUP BY segment;


WITH months AS(
SELECT
  '2017-01-01' AS first_day,
  '2017-01-31' AS last_day
UNION
SELECT
  '2017-02-01' AS first_day,
  '2017-02-28' AS last_day
  UNION
SELECT
  '2017-03-01' AS first_day,
  '2017-03-31' AS last_day
),
cross_join AS(
 SELECT * 
   FROM subscriptions
 CROSS JOIN months
),
status AS(
   SELECT id, 
          first_day as month,
         CASE
            WHEN subscription_start < first_day 
             AND (subscription_end > first_day OR subscription_end IS NULL) 
             AND segment=87
            THEN 1 
            ELSE 0 
          END AS is_active_87,
         CASE
            WHEN subscription_start < first_day 
             AND (subscription_end > first_day OR subscription_end IS NULL) 
             AND segment=30
            THEN 1 
            ELSE 0 
          END AS is_active_30,
          CASE
            WHEN subscription_end BETWEEN first_day AND last_day
             AND segment=87
            THEN 1 
            ELSE 0 
          END AS is_canceled_87,
          CASE
            WHEN subscription_end BETWEEN first_day AND last_day
             AND segment=30
            THEN 1 
            ELSE 0 
          END AS is_canceled_30            
   FROM cross_join
),
status_aggregate AS(
  SELECT month,
         sum(is_active_87) AS sum_active_87,  
         sum(is_active_30) AS sum_active_30, 
         sum(is_canceled_87) AS sum_canceled_87,
         sum(is_canceled_30) AS sum_canceled_30
   FROM status
  GROUP BY month
)

 
 SELECT month,
       round(1.0 * sum_canceled_87 / sum_active_87, 6)  AS "churn_rate_87",
       round(1.0 * sum_canceled_30 / sum_active_30, 6)  AS "churn_rate_30"
   FROM status_aggregate ;



WITH months AS(
SELECT
  '2017-01-01' AS first_day,
  '2017-01-31' AS last_day
UNION
SELECT
  '2017-02-01' AS first_day,
  '2017-02-28' AS last_day
  UNION
SELECT
  '2017-03-01' AS first_day,
  '2017-03-31' AS last_day
),
cross_join AS(
 SELECT * 
   FROM subscriptions
 CROSS JOIN months
),
status AS(
   SELECT id, 
          first_day AS month,
          segment,
         CASE
            WHEN subscription_start < first_day 
             AND (subscription_end > first_day OR subscription_end IS NULL) 
            THEN 1 
            ELSE 0 
          END AS is_active,
          CASE
            WHEN subscription_end BETWEEN first_day AND last_day
            THEN 1 
            ELSE 0 
          END AS is_canceled
   FROM cross_join
),
status_aggregate AS(
  SELECT month,
         segment,
         sum(is_active) AS sum_active,  
         sum(is_canceled) AS sum_canceled
   FROM status
  GROUP BY month, segment
)

 
 SELECT month, segment,
       round(1.0 * sum_canceled / sum_active, 6)  AS "churn_rate"
   FROM status_aggregate ;