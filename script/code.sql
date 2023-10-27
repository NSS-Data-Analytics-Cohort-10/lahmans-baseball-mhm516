--1. What range of years for baseball games played does the provided database cover? 
SELECT
MIN(yearid), 
MAX(yearid)
FROM collegeplaying AS cp
LEFT JOIN teams AS t
USING (yearid);
--1864 to 2014

--2. Find the name and height of the shortest player in the database. How many games did he play in? What is the name of the team for which he played?
SELECT 
ppl.namefirst, 
ppl.namelast, 
MIN(ppl.height),
app.g_all,
app.teamid
FROM people AS ppl
LEFT JOIN appearances AS app
USING (playerid)
WHERE ppl.height IS NOT NULL
GROUP BY
ppl.namefirst, 
ppl.namelast, 
app.g_all,
app.teamid
ORDER BY MIN(ppl.height)
LIMIT 1;
--"Eddie"	"Gaedel"	43	1	"SLA"

--3. Find all players in the database who played at Vanderbilt University. Create a list showing each player’s first and last names as well as the total salary they earned in the major leagues. Sort this list in descending order by the total salary earned. Which Vanderbilt player earned the most money in the majors?
SELECT 
ppl.namefirst,
ppl.namelast,
SUM(COALESCE(sal.salary, 0)) AS total_sal_earned
FROM collegeplaying AS cp
LEFT JOIN salaries AS sal
USING(playerid)
LEFT JOIN people AS ppl
USING (playerid)
WHERE cp.schoolid LIKE '%vand%'
GROUP BY
ppl.namefirst,
ppl.namelast
ORDER BY total_sal_earned DESC;
--"David"	"Price"	245553888

--4. Using the fielding table, group players into three groups based on their position: label players with position OF as "Outfield", those with position "SS", "1B", "2B", and "3B" as "Infield", and those with position "P" or "C" as "Battery". Determine the number of putouts made by each of these three groups in 2016.
SELECT
CASE
WHEN fp.pos = 'SS' THEN 'Infield'
WHEN fp.pos = '1B' THEN 'Infield'
WHEN fp.pos = '2B' THEN 'Infield'
WHEN fp.pos = '3B' THEN 'Infield'
WHEN fp.pos = 'OF' THEN 'Outfield'
WHEN fp.pos = 'P' THEN 'Battery'
WHEN fp.pos = 'C' THEN 'Battery'
WHEN fp.pos =  'CF' THEN 'Outfield'
WHEN fp.pos =  'RF' THEN 'Outfield'
WHEN fp.pos =  'LF' THEN 'Outfield'
END AS field_positions,
SUM(fp.po) AS po_total
FROM fielding AS fp
WHERE yearid = 2016
GROUP BY field_positions;
--"Battery"	41424
--"Infield"	58934
--"Outfield"	29560   

--5. Find the average number of strikeouts per game by decade since 1920. Round the numbers you report to 2 decimal places. Do the same for home runs per game. Do you see any trends?
   
SELECT
	CASE
		WHEN yearid IN (1920, 1921, 1922, 1923, 1924, 1925, 1926, 1927, 1928, 1929) THEN '1920s'
		WHEN yearid IN (1930,1931,1932,1933,1934,1935,1936,1937,1938,1939) THEN '1930s'
		WHEN yearid IN (1940,1941,1942,1943,1944,1945,1946,1947,1948,1949) THEN '1940s'
		WHEN yearid IN (1950,1951,1952,1953,1954,1955,1956,1957,1958,1959) THEN '1950s'
		WHEN yearid IN (1960,1961,1962,1963,1964,1965,1966,1967,1968,1969) THEN '1960s'
		WHEN yearid IN (1970,1971,1972,1973,1974,1975,1976,1977,1978,1979) THEN '1970s'
		WHEN yearid IN (1980,1981,1982,1983,1984,1985,1986,1987,1988,1989) THEN '1980s'
		WHEN yearid IN (1990,1991,1992,1993,1994,1995,1996,1997,1998,1999) THEN '1990s'
		WHEN yearid IN (2000,2001,2002,2003,2004,2005,2006,2007,2008,2009) THEN '2000s'
		WHEN yearid IN (2010,2011,2012,2013,2014,2015,2016,2017,2018,2019) THEN '2010s'
		END AS decades,
	ROUND(CAST(SUM(so) AS numeric)/CAST(SUM(g) AS NUMERIC),2) AS strikeouts_by_game,
	ROUND(CAST(SUM(hr) AS numeric)/CAST(SUM(g) AS NUMERIC),2) AS hr_by_game 
FROM teams
WHERE yearid >= 1920
GROUP BY decades
ORDER BY decades

--6. Find the player who had the most success stealing bases in 2016, where __success__ is measured as the percentage of stolen base attempts which are successful. (A stolen base attempt results either in a stolen base or being caught stealing.) Consider only players who attempted _at least_ 20 stolen bases.

SELECT 
	playerid,
	CAST(SUM(COALESCE(sb,1)) AS numeric) AS total_sb,
	CAST(SUM(COALESCE(cs,1)) AS numeric) AS total_cs,
	CAST(SUM(COALESCE(sb,1)) AS numeric) + CAST(SUM(COALESCE(cs,1)) AS numeric) AS total_attempt,
	CASE
	WHEN CAST(SUM(sb) AS numeric) = 0 THEN null
	WHEN CAST(SUM(cs) AS numeric) = 0 THEN null
	ELSE (CAST(SUM(sb) AS numeric)/(CAST(SUM(sb) AS numeric)+CAST(SUM(cs) AS numeric)))*100 
	END AS avg_sb
FROM batting
WHERE yearid = 2016
GROUP BY playerid
HAVING 
	CAST(SUM(COALESCE(sb,1)) AS numeric) + CAST(SUM(COALESCE(cs,1)) AS numeric)>=20
ORDER BY avg_sb desc
LIMIT 1;
--	"owingch01"	21	2	23	91.30434782608695652200
	
7.  From 1970 – 2016, what is the largest number of wins for a team that did not win the world series? What is the smallest number of wins for a team that did win the world series? Doing this will probably result in an unusually small number of wins for a world series champion – determine why this is the case. Then redo your query, excluding the problem year. How often from 1970 – 2016 was it the case that a team with the most wins also won the world series? What percentage of the time?


8. Using the attendance figures from the homegames table, find the teams and parks which had the top 5 average attendance per game in 2016 (where average attendance is defined as total attendance divided by number of games). Only consider parks where there were at least 10 games played. Report the park name, team name, and average attendance. Repeat for the lowest 5 average attendance.


9. Which managers have won the TSN Manager of the Year award in both the National League (NL) and the American League (AL)? Give their full name and the teams that they were managing when they won the award.

10. Find all players who hit their career highest number of home runs in 2016. Consider only players who have played in the league for at least 10 years, and who hit at least one home run in 2016. Report the players' first and last names and the number of home runs they hit in 2016.


**Open-ended questions**

11. Is there any correlation between number of wins and team salary? Use data from 2000 and later to answer this question. As you do this analysis, keep in mind that salaries across the whole league tend to increase together, so you may want to look on a year-by-year basis.

12. In this question, you will explore the connection between number of wins and attendance.
    <ol type="a">
      <li>Does there appear to be any correlation between attendance at home games and number of wins? </li>
      <li>Do teams that win the world series see a boost in attendance the following year? What about teams that made the playoffs? Making the playoffs means either being a division winner or a wild card winner.</li>
    </ol>


13. It is thought that since left-handed pitchers are more rare, causing batters to face them less often, that they are more effective. Investigate this claim and present evidence to either support or dispute this claim. First, determine just how rare left-handed pitchers are compared with right-handed pitchers. Are left-handed pitchers more likely to win the Cy Young Award? Are they more likely to make it into the hall of fame?

  
