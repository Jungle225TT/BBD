--test.sql

-- Test script to insert a large number of favorite entries for testing limits.
BEGIN
    FOR I IN 1..301 LOOP
        -- Insert a new favorite record for the same user and show.
        INSERT INTO FAVORITES(FAVORITEID, USERID, SHOWID) 
        VALUES (SEQ_FAVORITES.NEXTVAL, 1, 1);
    END LOOP;
END;
/



-- Test script to insert a video with a duration exceeding the trigger's limit (3 hours) 
-- and attempt to archive it. This tests the trigger `TRG_ARCHIVEVIDEO_DURATION`.
BEGIN
    -- Insert a video exceeding 3 hours in duration.
    INSERT INTO VIDEO(VIDEOID, NAME, DESCRIPTION, DURATION, PUBLISHDATE, COUNTRY, MULTILANGUAGE, FORMAT, CATEGORYID) 
    VALUES (SEQ_VIDEO.NEXTVAL, 'Long Video', 'A video exceeding 3 hours', 200, TRUNC(SYSDATE), 'France', 'Y', 'HD', 2);
    -- Attempt to archive the video (this should fail due to the trigger).
    INSERT INTO ARCHIVEVIDEO(ARCHIVEID, VIDEOID) 
    VALUES (SEQ_ARCHIVEVIDEO.NEXTVAL, (SELECT VIDEOID FROM VIDEO WHERE NAME = 'Long Video'));
END;
/


-- Test script to insert multiple watch history records to test the watch limit trigger.
BEGIN
    -- Insert three watch records for the same user and video.
    INSERT INTO WATCHHISTORY(WATCHID, USERID, VIDEOID) 
    VALUES (SEQ_WATCHHISTORY.NEXTVAL, 1, 1);
    INSERT INTO WATCHHISTORY(WATCHID, USERID, VIDEOID) 
    VALUES (SEQ_WATCHHISTORY.NEXTVAL, 1, 2);
    INSERT INTO WATCHHISTORY(WATCHID, USERID, VIDEOID) 
    VALUES (SEQ_WATCHHISTORY.NEXTVAL, 1, 3);

    -- Attempt to insert a fourth watch record within the time limit (this should fail).
    INSERT INTO WATCHHISTORY(WATCHID, USERID, VIDEOID) 
    VALUES (SEQ_WATCHHISTORY.NEXTVAL, 1, 1);
END;
/



-- Test script to validate the `VIDEOTOJSON` function and output the result.
SET SERVEROUTPUT ON;
DECLARE
    V_JSON CLOB; -- Variable to store the JSON output
BEGIN
    -- Call the function `VIDEOTOJSON` for a specific video ID and print the result.
    V_JSON := VIDEOTOJSON(1);
    DBMS_OUTPUT.PUT_LINE(V_JSON); -- Output the JSON string to the console
END;
/


-- Test script to generate a new video report using the `GENERATENEWVIDEOREPORT` procedure.
BEGIN
    -- Call the procedure to generate the video report.
    GENERATENEWVIDEOREPORT;
END;
/



-- Test script to generate a user-specific video list using the `GENERATEUSERVIDEOLIST` procedure.
BEGIN
    -- Generate the video list for a specific user ID.
    GENERATEUSERVIDEOLIST(1);
END;
/

