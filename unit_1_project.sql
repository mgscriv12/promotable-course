/* Hypothesis / predictions:

- I believe the majority of my outgoing funds were for Rent, followed by Groceries, and shopping. Due to some large auto payments (down payment / pay-off), it’s possible that may have surpassed one or both of these categories.
- The majority of outgoing funds came directly out of my main checking account. After this, my main account used was my Citi Costco card.
- The majority of income was from PayPal, followed by etrade / stock sales.
- Income increased from 2016 to 2017

/* Cleanup - prior to importing any data. ~2.5 hours
Started w/ 90 categories - ended with 35, 2555 rows down to 2006 */

/* Creating table manually */

CREATE TABLE credits(

txn_id INT NOT NULL AUTO_INCREMENT,
`date` DATE,
description VARCHAR(30),
type VARCHAR(30),
category VARCHAR(30),
account VARCHAR(30),
value FLOAT,

PRIMARY KEY(txn_id)
);


/* Made a mistake, the date wasn't formatted properly in excel so it wasn't recognized as a date, needed to change updated format in excel and then import again */

TRUNCATE TABLE credits;

/* After creating the table and uploading most of the data via csv, adding a few more rows that I intentionally left off */

INSERT INTO credits (`date`, `description`, `type`, `category`, `account`, `value`)
VALUES ('2016-01-15',"External Deposit Payroll","credit","Income","MAIN CHECKING",390.60);

INSERT INTO credits (`date`, `description`, `type`, `category`, `account`, `value`)
VALUES ('2016-01-08',"External Deposit Paypal","credit","Income","MAIN CHECKING",1327.45);

INSERT INTO credits (`date`, `description`, `type`, `category`, `account`, `value`)
VALUES ('2016-01-08',"Darick Mitchiner","credit","Income","PayPal Account",132.80);

/* Imported another table in its entirety via csv. Had to remove, adjust date column and primary key, re-import, then I renamed.
after importing again, to remove table: */

DROP TABLE debits;

/* after importing again... */

ALTER TABLE `TABLE 8`
RENAME to `debits`;

/* other necessary changes to format on this table were done via phpMyAdmin */

/* queries to ensure all data is present, compared values to original csvs */

SELECT * FROM `credits` WHERE 1;
SELECT * FROM `debits` WHERE 1;

/* To determine all spending by category: */

SELECT category, CONVERT( SUM( value ) , DECIMAL( 7, 2 ) ) 
FROM debits
GROUP BY category
ORDER BY SUM( value );

/* As expected, Mortgage & Rent was the highest at 26k. I thought Groceries would be second, but Auto & Transport was 14.7k, and Groceries at 11.8k, likely due to the large payments for a down payment and paying off a loan when selling vehicle.
To determine which account was used most often: (since the values are all negative, there was no need to sort) */

SELECT account, CONVERT(SUM(value),DECIMAL(7,2))
FROM debits 
GROUP BY account
ORDER BY SUM(value);

/* My hypothesis was correct, and the majority of funds - 50.4k came from my MAIN CHECKING, and the next highest use account was, by far the Costco Citi card at 35.7k, which was higher than the next account by approximately 27k

Since multiple descriptions of credits include variations of SOMETHING+PayPal, I searched for only those which contained "paypal", the second query determines the total volume of all credits to compare */

SELECT description, category, CONVERT(SUM(value),DECIMAL(7,2))
FROM credits
WHERE description LIKE "%paypal%";

SELECT CONVERT(SUM(value),DECIMAL (8, 2) ) 
FROM credits

/* Had to change second to 8 places due to over 99999.99, and by comparing I can see that the value of the PayPal specific income is more than half of the total, indicating it is the largest type. Next I will pull the total income from stock sales */

SELECT description, category, CONVERT(SUM(value),DECIMAL(7,2))
FROM credits
WHERE category = "Stock Sale"
GROUP BY description;

/* indicates that stock sales are significantly lower than income from PayPal. Only 21.9k in comparison. To determine the next largest credit category: */

SELECT description, category, CONVERT(SUM(value),DECIMAL(7,2))
FROM credits
GROUP BY description
ORDER BY CONVERT(SUM(value),DECIMAL(7,2)) DESC;

/* Shows breakdown of all credits, after removing the top three since they were identified in previous queries, I can see that taxes were my next biggest credits at 9.7k
Comparing credit values between 2016 and 2017: */

SELECT CONVERT(SUM(value),DECIMAL(8,2))
FROM credits
WHERE date<='2016-12-31';

SELECT CONVERT(SUM(value),DECIMAL(8,2))
FROM credits
WHERE date>='2017-01-01';

/* The values returned confirm my hypothesis - that in 2017 my credits were higher than in 2016. The 2017 sum was about 6.4k higher than the  sum of 2016 credits.

To give more insight into comparing the two, I have broken each year down by the credit category. The categories normally found in debits (Travel, Rideshare, Shopping) are due to refunds received (credits) on debits in those categories */

SELECT category,
	CONVERT(SUM(CASE WHEN date<='2016-12-31' then value else 0 end),DECIMAL(7,2)) 2016_total,
    CONVERT(SUM(CASE WHEN date>='2017-01-01' then value else 0 end),DECIMAL(7,2)) 2017_total,                         
	CONVERT(SUM(value),DECIMAL(7,2)) AS total_credits
FROM credits
GROUP BY category
ORDER BY SUM(value) DESC;

/* This gives a little better insight into my total credits and it's easier to see how / why the credits are higher in 2017, as well as each value's portion of the total credits. Income(mostly paychecks) was actually lower, but the stock sales and taxes were both significantly higher which helped to offset */

/* This breaks down debits in 2017 and 2016 by month: */

SELECT  EXTRACT(MONTH FROM date) AS "Month",
CONVERT(SUM(CASE WHEN date<='2016-12-31' then value else 0 end),DECIMAL(7,2)) '2016 debits by month',
CONVERT(SUM(CASE WHEN date>='2017-01-01' then value else 0 end),DECIMAL(7,2)) '2017 debits by month'
FROM debits
GROUP BY EXTRACT(MONTH FROM date)
ORDER BY `2016 debits by month`;

/* I would've expected to have the largest expenses near the Holidays, but it turns out that my move to Chicago
and trading in my car resulted in a large amount of outgoing funds in August and September, being significantly higher than
other months.

To compare 2017 values I just changed the last line from 2016 to 2017.

November and December were both actually lower on the list than I would've expected for both years, 
as the primary spending in 2017 was in July and October (Vacation + anniversary), so it seems that major life events / changes
result in higher spending amounts than the expected and budgeted for holidays and recurring events. */

CREATE TABLE annual_compare
SELECT  EXTRACT(MONTH FROM date) AS "Month",
CONVERT(SUM(CASE WHEN date<='2016-12-31' then value else 0 end),DECIMAL(7,2)) AS '2016',
CONVERT(SUM(CASE WHEN date>='2017-01-01' then value else 0 end),DECIMAL(7,2)) AS '2017'
FROM debits
GROUP BY `Month`
ORDER BY `Month`;

/* I just created a new table to compare the values from month to month with the following query: */

SELECT month, `2016`, `2017`,
ABS(`2016`)-ABS(`2017`) AS difference
FROM annual_compare
GROUP BY `Month`
ORDER BY `difference`;

/* This shows the NET difference in spending. So the negative values indicate there were that many more credits (outgoing) funds.
The largest differences were October and July, where 8.3k more credits were in 2017, compared to 2016. August had the 
"most improved" value, given there was about 8.9k less in credits in 2017, compared to 2016. */
