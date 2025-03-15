--Search.sql

-- Query to find the total number of views for each category in the last 14 days.
-- The results are ordered by the number of views in descending order.
SELECT c.CATEGORYNAME, COUNT(w.WATCHID) AS WATCHCOUNT
FROM CATEGORY c
JOIN VIDEO v ON c.CATEGORYID = v.CATEGORYID
JOIN WATCHHISTORY w ON v.VIDEOID = w.VIDEOID
WHERE w.WATCHTIME >= SYSDATE - 14
GROUP BY c.CATEGORYNAME
ORDER BY WATCHCOUNT DESC;


-- Query to retrieve user statistics including:
-- the number of unique views, favorites, and episodes watched.
SELECT u.NAME,
       COUNT(DISTINCT w.WATCHID) AS WATCHCOUNT,
       COUNT(DISTINCT f.FAVORITEID) AS FAVORITECOUNT,
       COUNT(DISTINCT e.EPISODEID) AS VIDEOWATCHCOUNT
FROM "USER" u
LEFT JOIN WATCHHISTORY w ON u.USERID = w.USERID
LEFT JOIN FAVORITES f ON u.USERID = f.USERID
LEFT JOIN EPISODE e ON w.VIDEOID = e.VIDEOID
GROUP BY u.NAME;


-- Query to calculate the number of total views and views from Germany for each video.
-- It also calculates the absolute difference between total views and German views.
-- Results are ordered by the difference in descending order.
SELECT v.NAME,
       COUNT(w.WATCHID) AS TOTALWATCH,
       COUNT(CASE WHEN u.COUNTRY = 'Germany' THEN 1 END) AS GERMANYWATCH,
       ABS(COUNT(w.WATCHID) - COUNT(CASE WHEN u.COUNTRY = 'Germany' THEN 1 END)) AS DIFFERENCE
FROM VIDEO v
JOIN WATCHHISTORY w ON v.VIDEOID = w.VIDEOID
JOIN "USER" u ON w.USERID = u.USERID
WHERE w.WATCHTIME >= SYSDATE - 14
GROUP BY v.NAME
ORDER BY DIFFERENCE DESC;


-- Query to find the category with the highest watch count.
-- Also calculates the count of double episodes (episodes * 2) for each category.
SELECT c.CATEGORYNAME,
       COUNT(w.WATCHID) AS WATCHCOUNT,
       COUNT(e.EPISODEID)*2 AS DOUBLEEPISODES
FROM WATCHHISTORY w
JOIN VIDEO v ON w.VIDEOID = v.VIDEOID
JOIN CATEGORY c ON v.CATEGORYID = c.CATEGORYID
JOIN EPISODE e ON v.VIDEOID = e.VIDEOID
GROUP BY c.CATEGORYNAME
ORDER BY WATCHCOUNT DESC
FETCH FIRST 1 ROWS ONLY;


-- Query to find the top 10 pairs of videos that are most frequently watched together by the same user.
SELECT v1.NAME AS VIDEO1, v2.NAME AS VIDEO2, COUNT(*) AS COWATCHCOUNT
FROM WATCHHISTORY w1
JOIN WATCHHISTORY w2 ON w1.USERID = w2.USERID AND w1.VIDEOID < w2.VIDEOID
JOIN VIDEO v1 ON w1.VIDEOID = v1.VIDEOID
JOIN VIDEO v2 ON w2.VIDEOID = v2.VIDEOID
GROUP BY v1.NAME, v2.NAME
ORDER BY COWATCHCOUNT DESC
FETCH FIRST 10 ROWS ONLY;


