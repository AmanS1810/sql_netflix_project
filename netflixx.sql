-- 15 Business Problems & Solutions
select * from netflix
--1. Count the number of Movies vs TV Shows

	select type , count(*) as total_content 
	from netflix 
	group by type

	
--2. Find the most common rating for movies and TV shows
		select 
			type,rating
			from
			(
				select type, rating, count(*),
				rank() over(partition by type order by count(*) desc) as ranking
				from netflix
				group by 1,2
			) as t1
			where 
				ranking=1

--3. List all movies released in a specific year (e.g., 2020)

   select * from netflix
   where type='Movie'
   			AND
   		 release_year=2020
   order by title asc
		
--4. Find the top 5 countries with the most content on Netflix
		select 
			unnest(string_to_array(country, ',')) as new_country,
			count(show_id) as total_content
		from netflix
		group by 1 
		order by 2 desc
		limit 6


--5. Identify the longest movie

select title,  substring(duration, 1,position ('m' in duration)-1)::int duration
from Netflix
where type = 'Movie' and duration is not null
order by 2 desc
limit 1 

 
--6. Find content added in the last 5 years
		select 
		 * 
		 from netflix
		 where to_date(date_added,'Month dd, YYYY')> CURRENT_DATE - INTERVAL '5 Years'

--7. Find all the movies/TV shows by director 'Rajiv Chilaka'!
 	
	 select type, title, Director
	 from netflix 
	 where director ilike '%Rajiv Chilaka%'
	 
--8. List all TV shows with more than 5 seasons

	SELECT *
	FROM netflix
	WHERE 
		TYPE = 'TV Show'
		AND
		SPLIT_PART(duration, ' ', 1)::INT > 5


	 
--9. Count the number of content items in each genre
		select 
			unnest(string_to_array(listed_in, ',')) as new_genre,
			count(show_id) as total_content
		from netflix
		group by 1 
		order by 2 desc

--10.Find each year and the average numbers of content release in India on netflix.
   --Return top 5 year with highest avg content release!

		SELECT 
		country,
		release_year,
		COUNT(show_id) as total_release,
		ROUND(
		COUNT(show_id)::numeric/(SELECT COUNT(show_id) FROM netflix WHERE country = 'India')::numeric * 100 
		,2)as avg_release
		FROM netflix
		WHERE country = 'India' 
		GROUP BY country, 2
		ORDER BY release_year DESC 
		LIMIT 5
		

--11. List all movies that are documentaries
  	SELECT * FROM netflix
	WHERE listed_in ILIKE '%documentaries'


--12. Find all content without a director
			SELECT *  FROM netflix
			where director IS null

--13. Find how many movies actor 'Salman Khan' appeared in last 10 years!
			select casts, type, title , release_year,date_added
			from netflix
			where casts ilike '% Salman Khan%'
			and 
			 release_year> EXTRACT(YEAR FROM CURRENT_DATE)-12

--14. Find the top 10 actors who have appeared in the highest number of movies produced in India.
     		SELECT 
			UNNEST(STRING_TO_ARRAY(casts, ',')) as actor,
			COUNT(*)
			FROM netflix
			WHERE country ilike '%India%'
			GROUP BY 1
			ORDER BY 2 DESC
			LIMIT 10

--15.Categorize the content based on the presence of the keywords 'kill' and 'violence' in the description field. Label content containing these keywords as 'Bad' and all other content as 'Good'.
--Count how many items fall into each category.

WITH new_table
AS	
		(
			select 
			*,
			CASE 
			WHEN 
			description ilike '%kill%'
			OR
			description ilike '%violence%' THEN 'BAD_CONTENT'
			ELSE 'GOOD_CONTENT' 
			END CATEGORY
		FROM netflix	
		)
		select category, 
		count(*) as total_content	
		from new_table
		group by 1