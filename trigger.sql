--trigger.sql

-- Trigger to ensure that no videos with a duration exceeding 3 hours can be archived.
CREATE OR REPLACE TRIGGER TRG_ARCHIVEVIDEO_DURATION
BEFORE INSERT OR UPDATE ON ARCHIVEVIDEO
FOR EACH ROW
DECLARE
    V_DURATION NUMBER; -- Variable to store the duration of the video
BEGIN
    -- Fetch the duration of the video associated with the given VIDEOID
    SELECT DURATION INTO V_DURATION FROM VIDEO WHERE VIDEOID = :NEW.VIDEOID;

    -- Raise an error if the video duration exceeds 180 minutes (3 hours)
    IF V_DURATION > 180 THEN
        RAISE_APPLICATION_ERROR(-20002, 'Video duration exceeds 3 hours and cannot be archived.');
    END IF;
END;
/



CREATE OR REPLACE TRIGGER TRG_ARCHIVEVIDEO_DURATION
BEFORE INSERT OR UPDATE ON ARCHIVEVIDEO
FOR EACH ROW
DECLARE
    V_DURATION NUMBER;
BEGIN
    SELECT DURATION INTO V_DURATION FROM VIDEO WHERE VIDEOID = :NEW.VIDEOID;
    IF V_DURATION > 180 THEN
        RAISE_APPLICATION_ERROR(-20002,'Video duration exceeds 3 hours and cannot be archived.');
    END IF;
END;
/



-- Trigger to limit the number of watch actions for a single user within one minute.
CREATE OR REPLACE TRIGGER TRG_WATCH_LIMIT
BEFORE INSERT ON WATCHHISTORY
FOR EACH ROW
DECLARE
    V_COUNT INT; -- Variable to store the count of watch actions in the last minute
BEGIN
    -- Count the number of watch actions by the same user within the last minute
    SELECT COUNT(*) INTO V_COUNT
    FROM WATCHHISTORY
    WHERE USERID = :NEW.USERID
      AND WATCHTIME >= SYSTIMESTAMP - INTERVAL '1' MINUTE;

    -- Raise an error if the user has already performed 3 or more watch actions
    IF V_COUNT >= 3 THEN
        RAISE_APPLICATION_ERROR(-20003, 'User cannot watch more than 3 videos within one minute.');
    END IF;
END;
/

