

-------------------------------------------------------------------Summaries---------------------------------------------------------------------

--Hourly trends for Searches, Arrests and Drugs related stops.

SELECT DATEPART(HOUR,stop_time) AS HOUR,
SUM(search_conducted) AS SEARCH_CONDUCTED,
SUM(is_arrested) AS ARRESTS,
SUM(drugs_related_stop) AS DRUG_RELATED_STOPS
FROM Police_complaint
GROUP BY DATEPART(HOUR,stop_time)
ORDER BY HOUR


--Which age group is more prone to being stopped by the police?

SELECT CASE
       WHEN driver_age<=20 THEN '<=20'
       WHEN driver_age BETWEEN 21 AND 40 THEN '21-40'
       WHEN driver_age BETWEEN 41 AND 60 THEN '41-60'
       ELSE '61-80' END AS 'AGE_GROUP',
COUNT(*) AS TOTAL_STOPS
FROM Police_complaint
GROUP BY CASE
       WHEN driver_age<=20 THEN '<=20'
       WHEN driver_age BETWEEN 21 AND 40 THEN '21-40'
       WHEN driver_age BETWEEN 41 AND 60 THEN '41-60'
       ELSE '61-80' END
ORDER BY TOTAL_STOPS DESC


--Totol number of stops

SELECT COUNT(*) AS TOTAL_COMPLAINTS
FROM Police_complaint


--Total number of searches conducted in the given time period and the rate at which searches are being conducted

SELECT SUM(SEARCH_CONDUCTED) AS TOTAL_SEARCHES,
100.0*(SUM(SEARCH_CONDUCTED)/
(SELECT COUNT(*)
FROM Police_complaint)) AS STOPS_PERCENTAGE
FROM Police_complaint


--Total drugs related stops

SELECT SUM(DRUGS_RELATED_STOP) AS DRUGS_RELATED_STOPS
FROM Police_complaint


--Show which days of the week show a spike in search conducted and how much of those searches end up being an arrest

SELECT DATEPART(WEEKDAY,stop_date) AS WEEKDAY,
SUM(SEARCH_CONDUCTED) TOTAL_SEARCHES,
100.0*(SUM(IS_ARRESTED)/SUM(SEARCH_CONDUCTED)) AS PERC_ARREST
FROM Police_complaint
GROUP BY DATEPART(WEEKDAY,stop_date)
ORDER BY PERC_ARREST DESC


--What is the percentage of each violations which contribute to the reason for stops

SELECT violation,
COUNT(*) AS TOTAL_STOPS,
100.0*COUNT(*)/
(SELECT COUNT(*) AS TOTAL_COMPLAINTS
FROM Police_complaint) AS  PERC_STOPS
FROM Police_complaint
GROUP BY violation


--Show if the police is bias to a certain ethnic group? Show what percentage of total searches end up being arrested from that ethnic group?

SELECT driver_race,
COUNT(*) AS TOTAL_STOPS,
100.0*SUM(CAST(IS_ARRESTED AS INT))/
COUNT(*) AS ARREST_PERC
FROM Police_complaint
GROUP BY driver_race
ORDER BY ARREST_PERC DESC


--Evaluate whether search rates differ across racial and gender groups. Also measure how often searches lead to formal citations or arrests


SELECT driver_race,driver_gender,
COUNT(*) AS TOTAL_STOPS,
SUM(CAST(SEARCH_CONDUCTED AS INT)) AS TOTAL_SEARCHES,
ROUND(100.0*SUM(CAST(SEARCH_CONDUCTED AS INT))/
COUNT(*),2) AS SEARCH_RATE,
SUM(CASE
    WHEN SEARCH_CONDUCTED=1 AND STOP_OUTCOME IN ('Citation','Arrest')
    THEN 1 ELSE 0
    END) AS CORRECT_SEARCHES,
ROUND(100.0*SUM(CASE
                WHEN SEARCH_CONDUCTED=1 AND STOP_OUTCOME IN ('Citation','Arrest')
                THEN 1 ELSE 0 END)/
                SUM(CAST(SEARCH_CONDUCTED AS INT)),2) AS SEARCH_HIT_RATE
FROM Police_complaint
GROUP BY DRIVER_RACE,DRIVER_GENDER
HAVING COUNT(*) > 50
ORDER BY TOTAL_STOPS DESC


--Map top violation types against stop outcomes and search rates to analyze enforcement severity per offense category.

SELECT violation,
COUNT(*) AS TOT_VIOLATIONS,
SUM(CASE
    WHEN STOP_OUTCOME='Citation'
    THEN 1 ELSE 0 
    END) AS TOT_CITATIONS,
SUM(CASE
    WHEN STOP_OUTCOME='Warning'
    THEN 1 ELSE 0 
    END) AS TOT_WARNINGS,
SUM(CASE
    WHEN STOP_OUTCOME='Arrest'
    THEN 1 ELSE 0 
    END) AS TOT_ARREST,
ROUND(100.0*SUM(CASE
                WHEN STOP_OUTCOME='Citation' 
                THEN 1 ELSE 0
                END)/
                COUNT(*),2) AS CITATION_RATE,
ROUND(100.0*SUM(CAST(SEARCH_CONDUCTED AS INT))/
COUNT(*),2) AS SEARCH_RATE
FROM Police_complaint
WHERE violation IS NOT NULL
GROUP BY violation
ORDER BY TOT_VIOLATIONS DESC;


--Evaluate the number of arrests by age group and driver gender

SELECT age_group,
driver_gender,
SUM(IS_ARRESTED) AS TOTAL_ARRESTS
FROM Police_complaint
GROUP BY AGE_GROUP,DRIVER_GENDER
ORDER BY  TOTAL_ARRESTS DESC

