--ProceduresandFunctionsCreate.sql

CREATE OR REPLACE FUNCTION VIDEOTOJSON(P_VIDEOID INT) RETURN CLOB IS
    -- Declare a variable to hold the JSON output
    V_JSON CLOB;
BEGIN
    -- Construct a JSON object for the video information using the VIDEOID parameter
    SELECT JSON_OBJECT(
        'VideoID' VALUE v.VIDEOID,
        'Name' VALUE v.NAME,
        'Description' VALUE v.DESCRIPTION,
        'Duration' VALUE v.DURATION,
        'PublishDate' VALUE TO_CHAR(v.PUBLISHDATE,'YYYY-MM-DD'),
        'Country' VALUE v.COUNTRY,
        'MultiLanguage' VALUE v.MULTILANGUAGE,
        'Format' VALUE v.FORMAT,
        'Category' VALUE c.CATEGORYNAME
    )
    INTO V_JSON
    FROM VIDEO v
    JOIN CATEGORY c ON v.CATEGORYID = c.CATEGORYID
    WHERE v.VIDEOID = P_VIDEOID;
    RETURN V_JSON;
END;
/


CREATE OR REPLACE PROCEDURE GENERATENEWVIDEOREPORT IS
    -- Declare a variable to hold the report content
    V_REPORT CLOB := 'New Video Release Report:\n';
BEGIN
    -- Loop through videos published in the current week and append to the report
    FOR REC IN (
        SELECT NAME, PUBLISHDATE
        FROM VIDEO
        WHERE PUBLISHDATE BETWEEN TRUNC(SYSDATE,'IW') AND TRUNC(SYSDATE,'IW')+7
    ) LOOP
        V_REPORT := V_REPORT || 'Title: ' || REC.NAME || ', Publish Date: ' || TO_CHAR(REC.PUBLISHDATE,'YYYY-MM-DD') || '\n';
    END LOOP;
    -- Output the report
    DBMS_OUTPUT.PUT_LINE(V_REPORT);
END;
/




CREATE OR REPLACE PROCEDURE GENERATEUSERVIDEOLIST(P_USERID INT) IS
    -- This procedure generates a list of videos watched by the user in the last 14 days
BEGIN
    -- Loop through each video watched by the user, sorted by popularity
    FOR REC IN (
        SELECT v.NAME, COUNT(w.WATCHID) AS POPULARITY
        FROM VIDEO v
        JOIN WATCHHISTORY w ON v.VIDEOID = w.VIDEOID
        JOIN SUBSCRIPTION s ON s.SHOWID = v.CATEGORYID
        WHERE s.USERID = P_USERID
          AND w.WATCHTIME >= SYSDATE - 14
        GROUP BY v.NAME
        ORDER BY POPULARITY DESC
    ) LOOP
        -- Output video name and its popularity count
        DBMS_OUTPUT.PUT_LINE('Video Title: ' || REC.NAME || ', Popularity: ' || REC.POPULARITY);
    END LOOP;
END;
/
