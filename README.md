# SQL
My SQL Project based on Indian Population Census

CREATE DATABASE Project;

SELECT * FROM Project.DBO.Dataset1;

SELECT * FROM Project.DBO.Dataset2;

-- number of rows into our dataset

SELECT count(*) FROM Project..Dataset1

SELECT count(*) FROM Project..Dataset2

-- Dataset for Jharkhand and Bihar

SELECT * FROM Project..Dataset1 where state in ('Jharkhand','Bihar')

-- Population of India

SELECT SUM(Population) Population FROM Project..Dataset2

-- Avg growth of the country by state to state in Percentage

Select avg(Growth)*100 avg_Growth From Project..Dataset1;

Select state,avg(Growth)*100 avg_Growth From Project..Dataset1
GROUP by state --Group by function to group every entry of each of the row by states so that each states is aggregated.

--avg sex ratio

Select state,round(avg(Sex_Ratio),0) avg_SexRatio From Project..Dataset1 -- Used Round function , 0 to remove the decimals.
GROUP by state

-- Want to see the Highest Sex Ratio using Order By Desc.

Select state,round(avg(Sex_Ratio),0) avg_SexRatio From Project..Dataset1 -- Used Round function , 0 to remove the decimals.
GROUP by state
ORDER by avg_SexRatio DESC;

-- Average Literacy Rate From Highest to Lowset

Select state,round(avg(Literacy),0) avg_Literacy From Project..Dataset1 -- Used Round function , 0 to remove the decimals.
GROUP by state
ORDER by avg_Literacy DESC;

-- States which has avg_Literacy above 90.

Select state,round(avg(Literacy),0) avg_Literacy From Project..Dataset1 -- Used Round function , 0 to remove the decimals.
GROUP by state having round(avg(Literacy),0)>90
ORDER by avg_Literacy DESC;

-- Top 3 state showing highest growth ratio

Select top 3 state, avg(Growth)*100 avg_Growth From Project..Dataset1 GROUP By State Order by avg_Growth Desc;

-- Bottom 3 state showing Lowest sex ratio

Select top 3 state,round(avg(Sex_Ratio),0) avg_SexRatio From Project..Dataset1 -- Used Round function , 0 to remove the decimals.
GROUP by state
ORDER by avg_SexRatio asc;

-- top and bottom 3 states in literacy state

DROP table if exists #TopStates

CREATE TABLE #TopStates
( State nvarchar(50),
  TopStates FLOAT
)
insert into #TopStates
Select state,round(avg(Literacy),0) avg_Literacy From Project..Dataset1 -- Used Round function , 0 to remove the decimals.
GROUP by state
ORDER by avg_Literacy DESC;

SELECT top 3 * FROM #TopStates  ORDER by #TopStates.TopStates desc;

DROP table if exists #BottomStates

CREATE TABLE #BottomStates
( State nvarchar(50),
  BottomStates FLOAT
)
insert into #BottomStates
Select state,round(avg(Literacy),0) avg_Literacy From Project..Dataset1 -- Used Round function , 0 to remove the decimals.
GROUP by state
ORDER by avg_Literacy asc;

SELECT top 3 * FROM #BottomStates ORDER by #BottomStates.BottomStates asc;

--Union Operator

SELECT * FROM (
SELECT top 3 * FROM #TopStates  ORDER by #TopStates.TopStates desc) a

UNION

SELECT * From (
SELECT top 3 * FROM #BottomStates ORDER by #BottomStates.BottomStates asc) b;

--States starting with letter a or b or d.

Select distinct state From Project..Dataset1
WHERE LOWER(State) like 'a%'
or LOWER(State) like 'b%'

Select distinct state From Project..Dataset1
WHERE LOWER(State) like 'a%'
or LOWER(State) like 'd%'

-- and statement

Select distinct state From Project..Dataset1
WHERE LOWER(State) like 'a%'
and LOWER(State) like 'm%'

-- Joining both table

--Total males and females

SELECT d.state,sum(d.males) total_males,sum(d.females) total_females FROM
(SELECT c.District,c.state,round(c.population/(c.sex_ratio+1),0) males, round((c.population*sex_ratio)/(c.sex_ratio+1),0) females From
(Select a.District,a.State,a.Sex_ratio sex_ratio,b.population from Project..Dataset1 a inner join Project..Dataset2 b ON a.District=b.District) c) d
GROUP by d.state

-- total literacy rate and Total population of both Literate and Illiterate people.

SELECT c.state,sum(literate_people) Total_Literate_pop,sum(illiterate_people) Total_Illiterate_pop from
(SELECT d.district, d.state, round(d.literacy_Ratio*Population,0) literate_people,Round((1-d.literacy_ratio)*d.population,0) illiterate_people FROM
(Select a.District,a.State,a.literacy/100 Literacy_Ratio,b.population from Project..Dataset1 a inner join Project..Dataset2 b ON a.District=b.District) d) c 
group by c.state 

-- Population  in previous Census and Current Census

Select sum(m.Prev_census) Total_Pop_prev,SUM(m.Curren_Census) Total_Pop_Current from(
Select e.state,sum(e.previous_census_population) Prev_census,sum(e.current_census_population) Curren_Census from
(SELECT d.district,d.state,round(d.population/(1+d.growth),0) Previous_Census_Population,d.Population current_census_Population FROM
(Select a.District,a.State,a.Growth Growth,b.population from Project..Dataset1 a inner join Project..Dataset2 b ON a.District=b.District) d) e 
group by e.State) m

--population vs area

Select (g.total_area/g.Total_Pop_prev) as Prev_Census_Pop_vs_area, (g.total_area/g.Total_Pop_Current) as Current_Census_Pop_vs_area from
(Select q.*,r.total_area from(

Select '1' as Keyy,n.* From
(Select sum(m.Prev_census) Total_Pop_prev,SUM(m.Curren_Census) Total_Pop_Current from(
Select e.state,sum(e.previous_census_population) Prev_census,sum(e.current_census_population) Curren_Census from
(SELECT d.district,d.state,round(d.population/(1+d.growth),0) Previous_Census_Population,d.Population current_census_Population FROM
(Select a.District,a.State,a.Growth Growth,b.population from Project..Dataset1 a inner join Project..Dataset2 b ON a.District=b.District) d) e 
group by e.State) m) n) q inner JOIN (

Select '1' as Keyy,z.* From (
Select sum(area_km2) Total_area from Project..Dataset2)z) r on q.keyy=r.keyy) g

--Window Function

--Output top 3 Districts from each state with highest literacy rate


Select a.* From
(Select district,state,literacy,rank() over(partition by state order by literacy desc) rank from project..Dataset1) a

Where a.rank in (1,2,3) ORDER by state
