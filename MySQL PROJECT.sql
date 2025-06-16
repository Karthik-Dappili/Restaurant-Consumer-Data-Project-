create database Restaurant_Consumer;
use Restaurant_Consumer;

ALTER TABLE consumers
CHANGE COLUMN `ï»¿Consumer_ID` Consumer_ID VARCHAR(10);
ALTER TABLE consumers 
ADD PRIMARY KEY (Consumer_ID);

ALTER TABLE restaurants
CHANGE COLUMN `restaurants` Restaurant_ID  VARCHAR(10);
ALTER TABLE restaurants 
ADD PRIMARY KEY (Restaurant_ID);

ALTER TABLE restaurant_cuisines
CHANGE COLUMN ï»¿Restaurant_ID Restaurant_ID  VARCHAR(10);

ALTER TABLE ratings
CHANGE COLUMN ï»¿Consumer_ID Consumer_ID  VARCHAR(10);

ALTER TABLE consumer_preferences
CHANGE COLUMN ï»¿Consumer_ID Consumer_ID  VARCHAR(10);

ALTER TABLE consumer_preferences
MODIFY COLUMN Preferred_Cuisine VARCHAR(255);

ALTER TABLE consumer_preferences
ADD PRIMARY KEY (Preferred_Cuisine);

ALTER TABLE restaurant_cuisines
ADD PRIMARY KEY (Cuisine);

-- consumer_preferences.Consumer_ID → consumers.Consumer_ID
ALTER TABLE consumer_preferences 
ADD CONSTRAINT fk_cp_consumer 
FOREIGN KEY (Consumer_ID) REFERENCES consumers(Consumer_ID);

-- restaurant_cuisines.Restaurant_ID → restaurants.Restaurant_ID
ALTER TABLE restaurant_cuisines 
ADD CONSTRAINT fk_rc_restaurant 
FOREIGN KEY (Restaurant_ID) REFERENCES restaurants(Restaurant_ID);

-- ratings.Consumer_ID → consumers.Consumer_ID
ALTER TABLE ratings 
ADD CONSTRAINT fk_ratings_consumer 
FOREIGN KEY (Consumer_ID) REFERENCES consumers(Consumer_ID);

-- ratings.Restaurant_ID → restaurants.Restaurant_ID
ALTER TABLE ratings 
ADD CONSTRAINT fk_ratings_restaurant 
FOREIGN KEY (Restaurant_ID) REFERENCES restaurants(Restaurant_ID);

----------------------------------

--- 1) List all details of consumers who live in the city of 'Cuernavaca'.

select * from consumers
where city='Cuernavaca';


--- 2) Find the Consumer_ID, Age, and Occupation of all consumers who are 'Students' AND are 'Smokers'.

select Consumer_ID, Age, Occupation from consumers
where Occupation= 'student' and smoker ='yes';

--- 3) List the Name, City, Alcohol_Service, and Price of all restaurants that serve 'Wine & Beer' and have a 'Medium' price level.

select name, city, Alcohol_Service,Price from restaurants
where Alcohol_Service='Wine & Beer' and price='medium';

--- 4) Find the names and cities of all restaurants that are part of a 'Franchise'

select name, City from restaurants where Franchise='yes';


--- 5) Show the Consumer_ID, Restaurant_ID, and Overall_Rating for all ratings where the Overall_Rating was 'Highly Satisfactory' (which corresponds to a value of 2, according to the data dictionary).
select Consumer_ID, Restaurant_ID, Overall_Rating
from ratings
where overall_rating =2;


--- joins
--- 1) List the names and cities of all restaurants that have an Overall_Rating of 2 (Highly Satisfactory) from at least one consumer.

select DISTINCT r.name, r.city
from restaurants r 
left join ratings rt
on r.Restaurant_ID= rt.Restaurant_ID
where rt.Overall_Rating =2;

--- 2) Find the Consumer_ID and Age of consumers who have rated restaurants located in 'San Luis Potosi'.
select c.Consumer_ID, c.age 
from consumers c
join ratings rt on c.Consumer_ID = rt.Consumer_ID
join restaurants r ON rt.Restaurant_ID = r.Restaurant_ID 
where c.city='San Luis Potosi';

--- 3) List the names of restaurants that serve 'Mexican' cuisine and have been rated by consumer 'U1001'.
select r.name 
from  restaurants r
join restaurant_cuisines rc on r.Restaurant_ID=rc.Restaurant_ID
join  ratings rt on rt.Restaurant_ID=r.Restaurant_ID
where rc.Cuisine = 'Mexican' and rt.Consumer_ID='U1001';

--- 4) Find all details of consumers who prefer 'American' cuisine AND have a 'Medium' budget.


SELECT c.*
FROM consumers c
JOIN consumer_preferences cp ON c.Consumer_ID = cp.Consumer_ID 
WHERE cp.Preferred_Cuisine = 'American'
  AND c.Budget = 'Medium';


--- 5) List restaurants (Name, City) that have received a Food_Rating lower than the average Food_Rating across all rated restaurants.

select r.name,r.city
from restaurants r
join ratings rt 
on r.Restaurant_ID=rt.Restaurant_ID
WHERE rt.Food_Rating< (
select avg(Food_Rating) 
from ratings);


--- 6) Find consumers (Consumer_ID, Age, Occupation) who have rated at least one restaurant but have NOT rated any restaurant that serves 'Italian' cuisine.
select c.Consumer_ID, c.Age,c.Occupation
from consumers c
WHERE c.Consumer_ID NOT IN (
    SELECT DISTINCT r1.Consumer_ID
    FROM ratings r1
    JOIN restaurant_cuisines rc ON r1.Restaurant_ID = rc.Restaurant_ID
    WHERE rc.Cuisine = 'Italian'
);

--- 7) List restaurants (Name) that have received ratings from consumers older than 30.
select r.name
from restaurants r
join ratings rt on r.Restaurant_ID = rt.Restaurant_ID
join consumers c on c.Consumer_ID = rt.Consumer_ID
where c.age>30;

--- 8) Find the Consumer_ID and Occupation of consumers whose preferred cuisine is 'Mexican' and who have given an Overall_Rating of 0 to at least one restaurant (any restaurant).
select c.Consumer_ID, c.Occupation 
from consumers c
join consumer_preferences cp on cp.Consumer_ID = c.Consumer_ID
join ratings rt on c.Consumer_ID = rt.Consumer_ID
where rt.Overall_Rating=0 and cp.Preferred_Cuisine='Mexican';


--- 9) List the names and cities of restaurants that serve 'Pizzeria' cuisine and are located in a city where at least one 'Student' consumer lives.
select r.name, r.city 
from restaurants r 
join restaurant_cuisines rc on r. Restaurant_ID = rc.Restaurant_ID
where rc.Cuisine='Pizzeria' 
and r.city in ( select c.city 
             from consumers c
             where c.Occupation = 'Student'
  );
  
  
  --- 10) Find consumers (Consumer_ID, Age) who are 'Social Drinkers' and have rated a restaurant that has 'No' parking.
SELECT DISTINCT c.Consumer_ID, c.Age
FROM consumers c 
JOIN ratings rt ON rt.Consumer_ID = c.Consumer_ID
JOIN restaurants r ON r.Restaurant_ID = rt.Restaurant_ID
WHERE c.Drink_Level = 'Social Drinkers' 
  AND r.Parking = 'No';
  
  
  --- Questions Emphasizing WHERE Clause and Order of Execution

--- 1) List Consumer_IDs and the count of restaurants they have rated, but only for consumers who are 'Students'. 
--- Show only students who have rated more than 2 restaurants.
select c.Consumer_ID, count(rt.Restaurant_ID) as rt_rating
from consumers c
join ratings rt on rt.Consumer_ID = c.Consumer_ID
where c.Occupation='Student'
group by c.Consumer_ID
having count(rt.Restaurant_ID)>2;





SELECT c.Consumer_ID, COUNT(rt.Restaurant_ID) AS Rated_Restaurants
FROM consumers c
JOIN ratings rt ON c.Consumer_ID = rt.Consumer_ID
WHERE c.Occupation = 'Student'
GROUP BY c.Consumer_ID
HAVING COUNT(rt.Restaurant_ID) > 2;


--- 2) We want to categorize consumers by an 'Engagement_Score' which is their Age divided by 10 (integer division). List the Consumer_ID, Age, and this calculated Engagement_Score, but only for consumers whose Engagement_Score would be exactly 2 and who use 'Public' transportation.
SELECT c.Consumer_ID, c.Age, (c.Age DIV 10) AS Engagement_Score
FROM consumers c
WHERE (c.Age DIV 10) = 2
  AND c.Transportation_Method = 'Public';

--- 3) For each restaurant, calculate its average Overall_Rating. Then, list the restaurant Name, City, and its calculated average Overall_Rating, but only for restaurants located in 'Cuernavaca' AND whose calculated average Overall_Rating is greater than 1.0.
select r.Name, r.city, avg(rt.Overall_Rating) as avg_over_rtg
from restaurants r
join ratings rt on rt.Restaurant_ID=r.Restaurant_ID
where r.city='Cuernavaca'
group by r.name, r.City
having avg(rt.Overall_Rating)>1.0;
select * from restaurants;

--- 4) Find consumers (Consumer_ID, Age) who are 'Married' and whose Food_Rating for any restaurant is equal to their Service_Rating for that same restaurant, but only consider ratings where the Overall_Rating was 2.
select c.Consumer_ID, c.age 
from consumers c
join ratings rt on rt.Consumer_ID = c.Consumer_ID
where c.Marital_Status = 'Married' and rt.Food_Rating=rt.Service_Rating and rt.Overall_Rating=2;

--- 5) List Consumer_ID, Age, and the Name of any restaurant they rated, but only for consumers who are 'Employed' and have given a Food_Rating of 0 to at least one restaurant located in 'Ciudad Victoria'.
select c.Consumer_ID, c.age, r.name
from consumers c
join ratings rt on rt.Consumer_ID = c.Consumer_ID
join restaurants r on r.Restaurant_ID = rt.Restaurant_ID
where c.Occupation='Employed' and rt.Food_Rating=0 and r.city='Ciudad Victoria';



--- Advanced SQL Concepts: Derived Tables, CTEs, Window Functions, Views, Stored Procedures

--- 1) Using a CTE, find all consumers who live in 'San Luis Potosi'. Then, list their Consumer_ID, Age, and the Name of any Mexican restaurant they have rated with an Overall_Rating of 2.
WITH cnmr AS (
    SELECT c.Consumer_ID, c.Age
    FROM consumers c 
    JOIN consumer_preferences cp ON cp.Consumer_ID = c.Consumer_ID
    WHERE c.City = 'San Luis Potosi' AND cp.Preferred_Cuisine = 'Mexican')
SELECT 
    cnmr.Consumer_ID, cnmr.Age, r.Name AS Restaurant_Name
FROM cnmr
JOIN ratings rt ON cnmr.Consumer_ID = rt.Consumer_ID
JOIN restaurants r ON r.Restaurant_ID = rt.Restaurant_ID
JOIN restaurant_cuisines rc ON r.Restaurant_ID = rc.Restaurant_ID
WHERE rc.Cuisine = 'Mexican' AND rt.Overall_Rating = 2;

--- 2) For each Occupation, find the average age of consumers. Only consider consumers who have made at least one rating. 
--- (Use a derived table to get consumers who have rated).
SELECT Occupation, AVG(age) AS avg_age
FROM (
    SELECT c.Consumer_ID, c.Occupation, c.age
    FROM consumers c
    JOIN ratings rt ON c.Consumer_ID = rt.Consumer_ID
    GROUP BY c.Consumer_ID, c.Occupation, c.age
) AS rated_consumers
GROUP BY rated_consumers.Occupation;



--- 3) Using a CTE to get all ratings for restaurants in 'Cuernavaca', rank these ratings within each restaurant based on Overall_Rating (highest first). Display Restaurant_ID, Consumer_ID, Overall_Rating, and the RatingRank.
WITH CuernavacaRatings AS (
    SELECT 
        r.Restaurant_ID,
        rt.Consumer_ID,
        rt.Overall_Rating
    FROM ratings rt
    JOIN restaurants r ON rt.Restaurant_ID = r.Restaurant_ID
    WHERE r.City = 'Cuernavaca'
),
RankedRatings AS (
    SELECT 
        Restaurant_ID,
        Consumer_ID,
        Overall_Rating,
        RANK() OVER (
            PARTITION BY Restaurant_ID 
            ORDER BY Overall_Rating DESC
        ) AS RatingRank
    FROM CuernavacaRatings
)
SELECT * 
FROM RankedRatings
ORDER BY Restaurant_ID, RatingRank;





--- 4) For each rating, show the Consumer_ID, Restaurant_ID, Overall_Rating, and also display the average Overall_Rating given by that specific consumer across all their ratings.
CREATE VIEW ConsumerAverageRatings AS
SELECT 
    Consumer_ID, 
    AVG(Overall_Rating) AS Avg_Rating_By_Consumer
FROM ratings
GROUP BY Consumer_ID;
SELECT 
    rt.Consumer_ID,
    rt.Restaurant_ID,
    rt.Overall_Rating,
    car.Avg_Rating_By_Consumer
FROM ratings rt
JOIN ConsumerAverageRatings car 
    ON rt.Consumer_ID = car.Consumer_ID;


--- 5) Using a CTE, identify students who have a 'Low' budget. Then, for each of these students, list their top 3 most preferred cuisines based on the order they appear in the Consumer_Preferences table (assuming no explicit preference order, use Consumer_ID, Preferred_Cuisine to define order for ROW_NUMBER).
WITH LowBudgetStudents AS (
    SELECT Consumer_ID
    FROM consumers
    WHERE Occupation = 'Student' AND Budget = 'Low'
),
RankedPreferences AS (
    SELECT 
        cp.Consumer_ID,
        cp.Preferred_Cuisine,
        ROW_NUMBER() OVER (
            PARTITION BY cp.Consumer_ID 
            ORDER BY cp.Consumer_ID, cp.Preferred_Cuisine
        ) AS rn
    FROM consumer_preferences cp
    JOIN LowBudgetStudents lbs ON cp.Consumer_ID = lbs.Consumer_ID
)
SELECT Consumer_ID, Preferred_Cuisine
FROM RankedPreferences
WHERE rn <= 3
ORDER BY Consumer_ID, rn;



--- 6) Consider all ratings made by 'Consumer_ID' = 'U1008'. For each rating, show the Restaurant_ID, Overall_Rating, and the Overall_Rating of the next restaurant they rated (if any), ordered by Restaurant_ID (as a proxy for time if rating time isn't available). 
--- Use a derived table to filter for the consumer's ratings first.
SELECT 
  Restaurant_ID, 
  Overall_Rating,
  LEAD(Overall_Rating) OVER (ORDER BY Restaurant_ID) AS Next_Overall_Rating
FROM (
  SELECT rt.Restaurant_ID, rt.Overall_Rating
  FROM ratings rt
  WHERE rt.Consumer_ID = 'U1008'
) AS cst_rated
ORDER BY Restaurant_ID;


--- 7) Create a VIEW named HighlyRatedMexicanRestaurants that shows the Restaurant_ID, Name, and City of all Mexican restaurants that have an average Overall_Rating greater than 1.5.
CREATE VIEW HighlyRatedMexicanRestaurants AS
SELECT 
    r.Restaurant_ID, 
    r.Name, 
    r.City
FROM restaurants r
JOIN restaurant_cuisines rc 
    ON rc.Restaurant_ID = r.Restaurant_ID
JOIN ratings rt 
    ON rt.Restaurant_ID = r.Restaurant_ID
WHERE rc.Cuisine = 'Mexican'
GROUP BY r.Restaurant_ID, r.Name, r.City
HAVING AVG(rt.Overall_Rating) > 1.5;

select * from highlyratedmexicanrestaurants;



--- 8) First, ensure the HighlyRatedMexicanRestaurants view from Q7 exists. Then, using a CTE to find consumers who prefer 'Mexican' cuisine, list those consumers (Consumer_ID) who have not rated any restaurant listed in the HighlyRatedMexicanRestaurants view.
WITH MexicanPreferringConsumers AS (
    SELECT DISTINCT cp.Consumer_ID
    FROM consumer_preferences cp
    WHERE cp.Preferred_Cuisine = 'Mexican'
),
ConsumersWhoRatedHighlyRatedMexican AS (
    SELECT DISTINCT r.Consumer_ID
    FROM ratings r
    JOIN HighlyRatedMexicanRestaurants hr
        ON r.Restaurant_ID = hr.Restaurant_ID
)
SELECT mpc.Consumer_ID
FROM MexicanPreferringConsumers mpc
LEFT JOIN ConsumersWhoRatedHighlyRatedMexican cr
    ON mpc.Consumer_ID = cr.Consumer_ID
WHERE cr.Consumer_ID IS NULL;



--- 9) Create a stored procedure GetRestaurantRatingsAboveThreshold that accepts a Restaurant_ID and a minimum Overall_Rating as input. It should return the Consumer_ID, Overall_Rating, Food_Rating, and Service_Rating for that restaurant where the Overall_Rating meets or exceeds the threshold.
DELIMITER $$

CREATE PROCEDURE GetRestaurantRatingsAboveThreshold (
    IN rest_id VARCHAR(10),
    IN min_rating DECIMAL(3,1)
)
BEGIN
    SELECT 
        Consumer_ID,
        Overall_Rating,
        Food_Rating,
        Service_Rating
    FROM ratings
    WHERE Restaurant_ID = rest_id
      AND Overall_Rating >= min_rating;
END $$

DELIMITER ;

CALL GetRestaurantRatingsAboveThreshold('U1077', 2);



--- 10) Identify the top 2 highest-rated (by Overall_Rating) restaurants for each cuisine type. If there are ties in rating, include all tied restaurants. Display Cuisine, Restaurant_Name, City, and Overall_Rating.
SELECT 
    rc.Cuisine,
    r.Name AS Restaurant_Name,
    r.City,
    rt.Overall_Rating
FROM restaurants r
JOIN restaurant_cuisines rc ON r.Restaurant_ID = rc.Restaurant_ID
JOIN ratings rt ON r.Restaurant_ID = rt.Restaurant_ID
WHERE (
    SELECT COUNT(DISTINCT rt2.Overall_Rating)
    FROM ratings rt2
    JOIN restaurant_cuisines rc2 ON rt2.Restaurant_ID = rc2.Restaurant_ID
    WHERE rc2.Cuisine = rc.Cuisine
      AND rt2.Overall_Rating > rt.Overall_Rating
) < 2
ORDER BY rc.Cuisine, rt.Overall_Rating DESC;



--- 11) First, create a  named ConsumerAverVIEWageRatings that lists Consumer_ID and their average Overall_Rating. Then, using this view and a CTE, find the top 5 consumers by their average overall rating. For these top 5 consumers, list their Consumer_ID, their average rating, and the number of 'Mexican' restaurants they have rated.
CREATE VIEW ConsumerAverageRating AS
SELECT 
    Consumer_ID, 
    AVG(Overall_Rating) AS Avg_Overall_Rating
FROM ratings
GROUP BY Consumer_ID;

WITH Top5Consumers AS (
    SELECT 
        Consumer_ID, 
        Avg_Overall_Rating
    FROM ConsumerAverageRating
    ORDER BY Avg_Overall_Rating DESC
    LIMIT 5
)

SELECT 
    t5.Consumer_ID,
    t5.Avg_Overall_Rating,
    COUNT(DISTINCT rt.Restaurant_ID) AS Mexican_Restaurants_Rated
FROM Top5Consumers t5
JOIN ratings rt ON t5.Consumer_ID = rt.Consumer_ID
JOIN restaurant_cuisines rc ON rt.Restaurant_ID = rc.Restaurant_ID
WHERE rc.Cuisine = 'Mexican'
GROUP BY t5.Consumer_ID, t5.Avg_Overall_Rating;
