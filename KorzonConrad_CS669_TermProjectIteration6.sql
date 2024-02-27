-- Conrad Korzon BU MET CS669 Term Project - Part 6
-- 2-24-2024

--TABLES

DROP TABLE scalar_metric;
DROP TABLE boolean_metric;
DROP TABLE categorical_metric;
DROP TABLE enabled_metric;
DROP TABLE recorded_metric;
DROP TABLE category_value;
DROP TABLE metric_option;
DROP TABLE recorded_activity;
DROP TABLE activity_option;
DROP TABLE recorded_external_factor;
DROP TABLE external_factor_option;
DROP TABLE daily_recording;
DROP TABLE mood_option;
DROP TABLE app_user;

CREATE TABLE app_user (
    app_user_id DECIMAL(12) NOT NULL,
    first_name VARCHAR(64) NOT NULL,
    last_name VARCHAR(64) NOT NULL,
    email VARCHAR(64) NOT NULL,
    signup_date DATE NOT NULL,
    PRIMARY KEY (app_user_id)
);

CREATE TABLE mood_option (
    mood_id DECIMAL(12),
    mood_name VARCHAR(24),
    is_positive BOOLEAN,
    PRIMARY KEY (mood_id)
);

CREATE TABLE daily_recording (
    recording_id DECIMAL(24) NOT NULL,
    app_user_id DECIMAL(12) NOT NULL,
    recording_date DATE NOT NULL,
    journal_entry VARCHAR(1000),
    mood_i DECIMAL(12),
    mood_ii DECIMAL(12),
    mood_iii DECIMAL(12),
    mood_iv DECIMAL(12),
    mood_v DECIMAL(12),
    PRIMARY KEY (recording_id),
    FOREIGN KEY (app_user_id) REFERENCES app_user,
    FOREIGN KEY (mood_i) REFERENCES mood_option,
    FOREIGN KEY (mood_ii) REFERENCES mood_option,
    FOREIGN KEY (mood_iii) REFERENCES mood_option,
    FOREIGN KEY (mood_iv) REFERENCES mood_option,
    FOREIGN KEY (mood_v) REFERENCES mood_option
);

CREATE TABLE external_factor_option (
    factor_id DECIMAL(12) NOT NULL,
    factor_name VARCHAR(24) NOT NULL,
    PRIMARY KEY (factor_id)
);

CREATE TABLE recorded_external_factor (
    rec_factor_id DECIMAL(12) NOT NULL,
    factor_id DECIMAL(12) NOT NULL,
    recording_id DECIMAL(24) NOT NULL,
    PRIMARY KEY (rec_factor_id),
    FOREIGN KEY (factor_id) REFERENCES external_factor_option,
    FOREIGN KEY (recording_id) REFERENCES daily_recording
);

CREATE TABLE activity_option (
    activity_opt_id DECIMAL(12) NOT NULL,
    activity_name VARCHAR(24) NOT NULL,
    PRIMARY KEY (activity_opt_id)
);

CREATE TABLE recorded_activity (
    rec_activity_id DECIMAL(12) NOT NULL,
    activity_opt_id DECIMAL(12) NOT NULL,
    recording_id DECIMAL(24) NOT NULL,
    duration DECIMAL(2),
    PRIMARY KEY (rec_activity_id),
    FOREIGN KEY (activity_opt_id) REFERENCES activity_option,
    FOREIGN KEY (recording_id) REFERENCES daily_recording
);

CREATE TABLE metric_option (
    metric_opt_id DECIMAL(12) NOT NULL,
    metric_name VARCHAR(64) NOT NULL,
    metric_type DECIMAL(1) NOT NULL,
    PRIMARY KEY (metric_opt_id)
);

CREATE TABLE enabled_metric (
    enbl_metric_id DECIMAL(12) NOT NULL,
    metric_opt_id DECIMAL(12) NOT NULL,
    app_user_id DECIMAL(12) NOT NULL,
    PRIMARY KEY (enbl_metric_id),
    FOREIGN KEY (metric_opt_id) REFERENCES metric_option,
    FOREIGN KEY (app_user_id) REFERENCES app_user
);

CREATE TABLE recorded_metric (
    rec_metric_id DECIMAL(12) NOT NULL,
    metric_opt_id DECIMAL(12) NOT NULL,
    recording_id DECIMAL(24) NOT NULL,
    PRIMARY KEY (rec_metric_id),
    FOREIGN KEY (metric_opt_id) REFERENCES metric_option,
    FOREIGN KEY (recording_id) REFERENCES daily_recording
);

CREATE TABLE category_value (
    value_id DECIMAL(12) NOT NULL,
    metric_opt_id DECIMAL(12) NOT NULL,
    metric_value VARCHAR(24),
    PRIMARY KEY (value_id),
    FOREIGN KEY (metric_opt_id) REFERENCES metric_option
);

CREATE TABLE categorical_metric (
    rec_metric_id DECIMAL(12) NOT NULL,
    value_id DECIMAL(12) NOT NULL,
    PRIMARY KEY (rec_metric_id),
    FOREIGN KEY (rec_metric_id) REFERENCES recorded_metric,
    FOREIGN KEY (value_id) REFERENCES category_value
);

CREATE TABLE boolean_metric (
    rec_metric_id DECIMAL(12) NOT NULL,
    metric_value BOOLEAN NOT NULL,
    PRIMARY KEY (rec_metric_id),
    FOREIGN KEY (rec_metric_id) REFERENCES recorded_metric
);

CREATE TABLE scalar_metric (
    rec_metric_id DECIMAL(12) NOT NULL,
    metric_value DECIMAL(2) NOT NULL,
    PRIMARY KEY (rec_metric_id),
    FOREIGN KEY (rec_metric_id) REFERENCES recorded_metric
);

CREATE TABLE journal_entry_change (
    entry_change_id DECIMAL(12) NOT NULL,
    recording_id DECIMAL(24) NOT NULL,
    change_date DATE NOT NULL,
    journal_entry_old VARCHAR(1000),
    journal_entry_new VARCHAR(1000),
    PRIMARY KEY (entry_change_id),
    FOREIGN KEY (recording_id) REFERENCES daily_recording
);

--SEQUENCES
--All tables that need them should have an associated sequence.
CREATE SEQUENCE app_user_sequence START WITH 1;
CREATE SEQUENCE mood_opt_sequence START WITH 1;
CREATE SEQUENCE daily_recording_sequence START WITH 1;
CREATE SEQUENCE ext_factor_opt_sequence START WITH 1;
CREATE SEQUENCE rec_ext_factor_sequence START WITH 1;
CREATE SEQUENCE activity_opt_sequence START WITH 1;
CREATE SEQUENCE rec_activity_sequence START WITH 1;
CREATE SEQUENCE metric_opt_sequence START WITH 1;
CREATE SEQUENCE enbl_metric_sequence START WITH 1;
CREATE SEQUENCE rec_metric_sequence START WITH 1;
CREATE SEQUENCE category_value_sequence START WITH 1;
CREATE SEQUENCE journal_entry_change_sequence START WITH 1;

--INDEXES

    -- Foreign Key Based Indexes --
CREATE INDEX RecFactorFctrIdIdx ON recorded_external_factor(factor_id);
CREATE INDEX RecFactorRecIdIdx ON recorded_external_factor(recording_id);
CREATE INDEX RecActivityOptIdIdx ON recorded_activity(activity_opt_id);
CREATE INDEX RecActivityRecIdIdx ON recorded_activity(recording_id);
CREATE INDEX RecMetricOptIdIdx ON recorded_metric(metric_opt_id);
CREATE INDEX RecMetricRecIdIdx ON recorded_metric(recording_id);
CREATE INDEX EnblMetricUsrIdx ON enabled_metric(app_user_id);
CREATE INDEX EnblMetricOptIdx ON enabled_metric(metric_opt_id);
CREATE INDEX CatMetricValIdx ON categorical_metric(value_id);
CREATE INDEX CategoryValMtrcOptIdx ON category_value(metric_opt_id);
    -- I chose to not to index on the mood foreign keys in the daily recording table since the mood table will be small,
    -- and adding 5 new indexes to the daily_recording table may not be worth it considering mood_i,ii,... won't be used in search very often
CREATE INDEX JournalChangeRecordingIdIdx ON journal_entry_change(recording_id);

    -- Query Performance Based Indexes --
CREATE UNIQUE INDEX UserEmailIdx ON app_user(email);                 -- User's email will be used as their login username, so this field will often be used for DB searches.
CREATE UNIQUE INDEX ExtFactorIdx ON external_factor_option(factor_name);    -- Factor name will be a frequently searched field, both by user and during historical recording analysis
CREATE UNIQUE INDEX MetricOptIdx ON metric_option(metric_name);      -- Metric name will be a frequently searched field, both by user and during historical recording analysis
CREATE INDEX CategoryValMtrcValIdx ON category_value(metric_value);  -- Metric value will
CREATE UNIQUE INDEX ActivityOptIdx ON activity_option(activity_name);

CREATE INDEX DailyRecordingUserIdx ON daily_recording(app_user_id);   -- User id on its own is useful for querying daily recording
CREATE UNIQUE INDEX DailyRecordingUserDateIdx
    ON daily_recording(app_user_id, recording_date);
    -- Daily recordings will be regularly searched by user id, or user id and date. Additionally, each user may have at most one daily recording per date.

--STORED PROCEDURES
-- USE CASE 1: User Registration
CREATE OR REPLACE PROCEDURE ADD_USER (
    first_name_arg IN VARCHAR(64),
    last_name_arg IN VARCHAR(64),
    email_arg IN VARCHAR(64)
) LANGUAGE plpgsql
AS
$reusableproc$
BEGIN
    INSERT INTO app_user (app_user_id, first_name, last_name, email, signup_date)
    VALUES (nextval('app_user_sequence'), first_name_arg, last_name_arg, email_arg, CURRENT_DATE);
END;
$reusableproc$;


-- USE CASE 2: Perform Daily Recording
CREATE OR REPLACE PROCEDURE ADD_DAILY_RECORDING (
    user_id_arg IN DECIMAL(12),
    journal_entry_arg IN VARCHAR(1000),
    mood_i_arg IN DECIMAL(12),
    mood_ii_arg IN DECIMAL(12),
    mood_iii_arg IN DECIMAL(12),
    mood_iv_arg IN DECIMAL(12),
    mood_v_arg IN DECIMAL(12)
) LANGUAGE plpgsql
AS
$reusableproc$
BEGIN
    INSERT INTO daily_recording (recording_id, app_user_id, recording_date, journal_entry, mood_i, mood_ii, mood_iii, mood_iv, mood_v)
    VALUES (nextval('daily_recording_sequence'), user_id_arg, CURRENT_DATE, journal_entry_arg,
    mood_i_arg, mood_ii_arg, mood_iii_arg, mood_iv_arg, mood_v_arg);
END;
$reusableproc$;

-- Add a recorded activity and associate it with a daily recording
CREATE OR REPLACE PROCEDURE ADD_ACTIVITY_RECORDING (
    recording_id_arg IN DECIMAL(12),
    activity_id_arg IN DECIMAL(12),
    duration_arg IN DECIMAL(2)
) LANGUAGE plpgsql
AS
$reusableproc$
BEGIN
    INSERT INTO recorded_activity (rec_activity_id, activity_opt_id, recording_id, duration)
        VALUES (nextval('rec_activity_sequence'), activity_id_arg, recording_id_arg, duration_arg);
END;
$reusableproc$;

-- Add a recorded external factor and associate it with a daily recording
CREATE OR REPLACE PROCEDURE ADD_EXT_FACTOR_RECORDING (
    recording_id_arg IN DECIMAL(12),
    ext_factor_id_arg IN DECIMAL(12)
) LANGUAGE plpgsql
AS
$reusableproc$
BEGIN
    INSERT INTO recorded_external_factor (rec_factor_id, factor_id, recording_id)
        VALUES (nextval('rec_ext_factor_sequence'), ext_factor_id_arg, recording_id_arg);
END;
$reusableproc$;

-- Add a recorded categorical metric to be associated with a daily recording.
CREATE OR REPLACE PROCEDURE ADD_CAT_METRIC_RECORDING (
    recording_id_arg IN DECIMAL(12),
    metric_id_arg IN DECIMAL(12),
    value_id_arg IN DECIMAL(12)
) LANGUAGE plpgsql
AS
$reusableproc$
DECLARE
    rec_metric_id_val DECIMAL(12);
BEGIN
    rec_metric_id_val := nextval('rec_metric_sequence');
    INSERT INTO recorded_metric (rec_metric_id, metric_opt_id, recording_id)
        VALUES (rec_metric_id_val, metric_id_arg, recording_id_arg);
    INSERT INTO categorical_metric (rec_metric_id, value_id)
        VALUES (rec_metric_id_val, value_id_arg);
END;
$reusableproc$;

-- Add a recorded boolean metric to be associated with a daily recording.
CREATE OR REPLACE PROCEDURE ADD_BOOL_METRIC_RECORDING (
    recording_id_arg IN DECIMAL(12),
    metric_id_arg IN DECIMAL(12),
    value_arg IN BOOLEAN
) LANGUAGE plpgsql
AS
$reusableproc$
DECLARE
    rec_metric_id_val DECIMAL(12);
BEGIN
    rec_metric_id_val := nextval('rec_metric_sequence');
    INSERT INTO recorded_metric (rec_metric_id, metric_opt_id, recording_id)
        VALUES (rec_metric_id_val, metric_id_arg, recording_id_arg);
    INSERT INTO boolean_metric (rec_metric_id, metric_value)
        VALUES (rec_metric_id_val, value_arg);
END;
$reusableproc$;

-- Add a recorded scalar metric to be associated with a daily recording.
CREATE OR REPLACE PROCEDURE ADD_SCAL_METRIC_RECORDING (
    recording_id_arg IN DECIMAL(12),
    metric_id_arg IN DECIMAL(12),
    value_arg IN DECIMAL(2)
) LANGUAGE plpgsql
AS
$reusableproc$
DECLARE
    rec_metric_id_val DECIMAL(12);
BEGIN
    rec_metric_id_val := nextval('rec_metric_sequence');
    INSERT INTO recorded_metric (rec_metric_id, metric_opt_id, recording_id)
        VALUES (rec_metric_id_val, metric_id_arg, recording_id_arg);
    INSERT INTO scalar_metric (rec_metric_id, metric_value)
        VALUES (rec_metric_id_val, value_arg);
END;
$reusableproc$;

--TRIGGERS
CREATE OR REPLACE FUNCTION JournalEntryChangeFunction()
RETURNS TRIGGER LANGUAGE plpgsql
AS $trigfunc$
    BEGIN
        INSERT INTO journal_entry_change (entry_change_id, recording_id, change_date,
        journal_entry_old, journal_entry_new)
        VALUES (nextval('journal_entry_change_sequence'), OLD.recording_id, CURRENT_DATE,
            OLD.journal_entry, NEW.journal_entry
        );
        RETURN NEW;
    END;
$trigfunc$;

CREATE TRIGGER JournalEntryChangeTrigger
BEFORE UPDATE OF journal_entry ON daily_recording
FOR EACH ROW
EXECUTE PROCEDURE PriceChangeFunction();

-- INSERTS

INSERT INTO mood_option (mood_id, mood_name, is_positive)
VALUES (nextval('mood_opt_sequence'), 'Happy', true), (nextval('mood_opt_sequence'), 'Optimistic', true), 
(nextval('mood_opt_sequence'), 'Relaxed', true), (nextval('mood_opt_sequence'), 'Bored', false), (nextval('mood_opt_sequence'), 'Sad', false),
(nextval('mood_opt_sequence'), 'Agitated', false), (nextval('mood_opt_sequence'), 'Excited', true), (nextval('mood_opt_sequence'), 'Motivated', true),
(nextval('mood_opt_sequence'), 'Unmotivated', false);

INSERT INTO activity_option (activity_opt_id, activity_name)
VALUES (nextval('activity_opt_sequence'), 'Work'), (nextval('activity_opt_sequence'), 'Homework'),
(nextval('activity_opt_sequence'), 'Gym'), (nextval('activity_opt_sequence'), 'Read Novel'),
(nextval('activity_opt_sequence'), 'Spend Time with Friends'),
(nextval('activity_opt_sequence'), 'Nap'), (nextval('activity_opt_sequence'), 'Walk Outside'),
(nextval('activity_opt_sequence'), 'Relax at Home'), (nextval('activity_opt_sequence'), 'Watch TV');

INSERT INTO external_factor_option (factor_id, factor_name)
VALUES (nextval('ext_factor_opt_sequence'), 'Overslept'), (nextval('ext_factor_opt_sequence'), 'Late to Work'),
(nextval('ext_factor_opt_sequence'), 'Skipped Breakfast');

INSERT INTO metric_option (metric_opt_id, metric_name, metric_type)
VALUES (nextval('metric_opt_sequence'), 'Productivity Rating', 3),
(nextval('metric_opt_sequence'), 'Exercised', 2), (nextval('metric_opt_sequence'), 'Sleep Level', 1);

INSERT INTO category_value (value_id, metric_opt_id, metric_value)
VALUES (nextval('category_value_sequence'), (SELECT metric_opt_id FROM metric_option WHERE metric_name='Sleep Level'), '< 7 Hours'),
(nextval('category_value_sequence'), (SELECT metric_opt_id FROM metric_option WHERE metric_name='Sleep Level'), '7-9 Hours'),
(nextval('category_value_sequence'), (SELECT metric_opt_id FROM metric_option WHERE metric_name='Sleep Level'), '> 9 Hours');

-- Procedure Calls

BEGIN TRANSACTION;
CALL ADD_USER('Hannah', 'Van Weiss', 'hannahvw@coolmail.com');
COMMIT TRANSACTION;

BEGIN TRANSACTION;
CALL ADD_USER('Peter', 'Redding', 'peteredd@pear.com');
COMMIT TRANSACTION;

BEGIN TRANSACTION;
DO $$
DECLARE
	recording_id_var DECIMAL(12); user_id_var DECIMAL(12); optimistic_id_var DECIMAL(12);
	bored_id_var DECIMAL(12); activity_id_var DECIMAL(12); factor_id_var DECIMAL(12);
BEGIN
-- Note: Digi-Journal's application code will know the user and mood id's and thus will not need to
-- select them as we do here, but in this case I do so in order to avoid hard coding foreign keys.
-- Find user id and applicable mood id's
user_id_var := (SELECT app_user_id FROM app_user WHERE email='hannahvw@coolmail.com');
optimistic_id_var := (SELECT mood_id FROM mood_option WHERE mood_name='Optimistic');
bored_id_var := (SELECT mood_id FROM mood_option WHERE mood_name='Bored');

-- Add the daily recording
CALL ADD_DAILY_RECORDING(
	user_id_var, 'Today I had a productive day at work, went to the gym, and read my favorite book.',
	optimistic_id_var, bored_id_var, NULL, NULL, NULL);

-- Find the recording id
recording_id_var := (SELECT recording_id FROM daily_recording WHERE app_user_id=user_id_var AND recording_date=CURRENT_DATE);

-- Add activities
activity_id_var := (SELECT activity_opt_id FROM activity_option WHERE activity_name='Work');
CALL ADD_ACTIVITY_RECORDING(recording_id_var, activity_id_var, 8);

activity_id_var := (SELECT activity_opt_id FROM activity_option WHERE activity_name='Gym');
CALL ADD_ACTIVITY_RECORDING(recording_id_var, activity_id_var, 1);

activity_id_var := (SELECT activity_opt_id FROM activity_option WHERE activity_name='Read Novel');
CALL ADD_ACTIVITY_RECORDING(
	recording_id_var, activity_id_var, 2);

-- Add external factor
factor_id_var := (SELECT factor_id FROM external_factor_option WHERE factor_name='Skipped Breakfast');
CALL ADD_EXT_FACTOR_RECORDING(recording_id_var, factor_id_var);

END;
$$;
COMMIT TRANSACTION;

-- Add user Hannah's custom metrics
CALL ADD_CAT_METRIC_RECORDING(1, 3, 2);
CALL ADD_BOOL_METRIC_RECORDING(1, 2, true);
CALL ADD_SCAL_METRIC_RECORDING(1, 1, 8);

-- Add Peter Journal Recording
BEGIN TRANSACTION;
DO $$
DECLARE
	recording_id_var DECIMAL(12); user_id_var DECIMAL(12); relaxed_id_var DECIMAL(12);
	happy_id_var DECIMAL(12); bored_id_var DECIMAL(12); ext_id_var DECIMAL(12);
BEGIN
user_id_var := (SELECT app_user_id FROM app_user WHERE email='peteredd@pear.com');
relaxed_id_var := (SELECT mood_id FROM mood_option WHERE mood_name='Relaxed');
happy_id_var := (SELECT mood_id FROM mood_option WHERE mood_name='Happy');
bored_id_var := (SELECT mood_id FROM mood_option WHERE mood_name='Bored');

-- Add the daily recording
CALL ADD_DAILY_RECORDING(
	user_id_var, 'Today was super relaxing, I slept in and hung out at home.',
	relaxed_id_var, bored_id_var, happy_id_var, NULL, NULL);

-- Find the recording id
recording_id_var := (SELECT recording_id FROM daily_recording WHERE app_user_id=user_id_var AND recording_date=CURRENT_DATE);

-- Add external factor
ext_id_var := (SELECT factor_id FROM external_factor_option WHERE factor_name='Overslept');
CALL ADD_EXT_FACTOR_RECORDING(recording_id_var, ext_id_var);

-- Add Custom metrics
ext_id_var := (SELECT metric_opt_id FROM metric_option WHERE metric_name='Sleep Level');
CALL ADD_CAT_METRIC_RECORDING(recording_id_var, ext_id_var, 3);

END;
$$;
COMMIT TRANSACTION;

-- Add user Hannah's enabled metrics
INSERT INTO enabled_metric (enbl_metric_id, metric_opt_id, app_user_id)
VALUES (nextval('enbl_metric_sequence'), 1, 1), (nextval('enbl_metric_sequence'), 2, 1),
(nextval('enbl_metric_sequence'), 3, 1);

-- Add user Peter's enabled metrics
INSERT INTO enabled_metric (enbl_metric_id, metric_opt_id, app_user_id)
VALUES (nextval('enbl_metric_sequence'), 2, 2), (nextval('enbl_metric_sequence'), 3, 2);

-- Additional INSERTs for Visualizations Data --

-- New user for visualizations
INSERT INTO app_user (app_user_id, first_name, last_name, email, signup_date)
    VALUES (nextval('app_user_sequence'), 'Janette', 'Crowe', 'jcrow1234@kmail.org', '2024-02-01');

--INSERT bulk journal entries to use for visualizations.
INSERT INTO daily_recording (recording_id, app_user_id, recording_date, journal_entry, mood_i, mood_ii, mood_iii)
VALUES
	-- 1st day journal
	(nextval('daily_recording_sequence'), 3, '2024-02-01', 'I went to the beach today with my friends Jack and Robyn! I was so sad when the day ended though.',
	(SELECT mood_id FROM mood_option WHERE mood_name='Excited'), (SELECT mood_id FROM mood_option WHERE mood_name='Relaxed'),
	(SELECT mood_id FROM mood_option WHERE mood_name='Sad')),
	-- 2nd day journal
	(nextval('daily_recording_sequence'), 3, '2024-02-02', 'I had such a rough day at work today, I couldnt wait to get home.',
	(SELECT mood_id FROM mood_option WHERE mood_name='Agitated'), (SELECT mood_id FROM mood_option WHERE mood_name='Bored'), NULL),
	-- 3rd day journal
	(nextval('daily_recording_sequence'), 3, '2024-02-03', 'I had a better day at work, it felt like I accomplished alot.',
	(SELECT mood_id FROM mood_option WHERE mood_name='Motivated'), (SELECT mood_id FROM mood_option WHERE mood_name='Optimistic'), NULL),
	-- 4th day journal
	(nextval('daily_recording_sequence'), 3, '2024-02-04', 'I was in a super zen mood today, feeling so good about life right now.',
	(SELECT mood_id FROM mood_option WHERE mood_name='Happy'), (SELECT mood_id FROM mood_option WHERE mood_name='Relaxed'),
	(SELECT mood_id FROM mood_option WHERE mood_name='Optimistic')),
	-- 5th day journal
	(nextval('daily_recording_sequence'), 3, '2024-02-05', 'I feel so out of it today, I missed my alarm and skipped breakfast to get to work on time.',
	(SELECT mood_id FROM mood_option WHERE mood_name='Unmotivated'), (SELECT mood_id FROM mood_option WHERE mood_name='Sad'), NULL),
	-- 6th day journal
	(nextval('daily_recording_sequence'), 3, '2024-02-06', 'I had a pretty good day off, it was nice and lowkey but I ran out of things to do.',
	(SELECT mood_id FROM mood_option WHERE mood_name='Relaxed'), (SELECT mood_id FROM mood_option WHERE mood_name='Bored'), NULL),
	-- 7th day journal
	(nextval('daily_recording_sequence'), 3, '2024-02-07', 'I had a great workout today and got a bunch of schoolwork done. Cant wait to relax tomorrow.',
	(SELECT mood_id FROM mood_option WHERE mood_name='Motivated'), (SELECT mood_id FROM mood_option WHERE mood_name='Optimistic'),
	(SELECT mood_id FROM mood_option WHERE mood_name='Bored'));

-- INSERT activities and metrics for each journal entry to use for visualizations
BEGIN TRANSACTION;
DO $$
DECLARE
    jrnl_id_var DECIMAL(24);
    metric_id_var DECIMAL(12);
BEGIN
    -- Get productivity metric id
    metric_id_var := (SELECT metric_opt_id FROM metric_option WHERE metric_name='Productivity Rating');

    -- 1st day journal
    jrnl_id_var := (SELECT recording_id FROM daily_recording WHERE app_user_id=3 AND recording_date='2024-02-01');
    -- Activities
    INSERT INTO recorded_activity (rec_activity_id, activity_opt_id, recording_id, duration)
    VALUES (nextval('rec_activity_sequence'),
        (SELECT activity_opt_id FROM activity_option WHERE activity_name='Spend Time with Friends'), jrnl_id_var, 8),
    (nextval('rec_activity_sequence'), (SELECT activity_opt_id FROM activity_option WHERE activity_name='Watch TV'), jrnl_id_var, 1);
    -- Custom Metrics
    CALL ADD_SCAL_METRIC_RECORDING(jrnl_id_var, metric_id_var, 1);

    -- 2nd day journal
    jrnl_id_var := (SELECT recording_id FROM daily_recording WHERE app_user_id=3 AND recording_date='2024-02-02');
    -- Activities
    INSERT INTO recorded_activity (rec_activity_id, activity_opt_id, recording_id, duration)
    VALUES (nextval('rec_activity_sequence'), (SELECT activity_opt_id FROM activity_option WHERE activity_name='Work'), jrnl_id_var, 8),
    (nextval('rec_activity_sequence'), (SELECT activity_opt_id FROM activity_option WHERE activity_name='Watch TV'), jrnl_id_var, 3);
    -- Custom Metrics
    CALL ADD_SCAL_METRIC_RECORDING(jrnl_id_var, metric_id_var, 3);

    -- 3rd day journal
    jrnl_id_var := (SELECT recording_id FROM daily_recording WHERE app_user_id=3 AND recording_date='2024-02-03');
    -- Activities
    INSERT INTO recorded_activity (rec_activity_id, activity_opt_id, recording_id, duration)
    VALUES (nextval('rec_activity_sequence'), (SELECT activity_opt_id FROM activity_option WHERE activity_name='Work'), jrnl_id_var, 8),
    (nextval('rec_activity_sequence'), (SELECT activity_opt_id FROM activity_option WHERE activity_name='Gym'), jrnl_id_var, 1),
    (nextval('rec_activity_sequence'), (SELECT activity_opt_id FROM activity_option WHERE activity_name='Read Novel'), jrnl_id_var, 2);
    -- Custom Metrics
    CALL ADD_SCAL_METRIC_RECORDING(jrnl_id_var, metric_id_var, 9);

    -- 4th day journal
    jrnl_id_var := (SELECT recording_id FROM daily_recording WHERE app_user_id=3 AND recording_date='2024-02-04');
    -- Activities
    INSERT INTO recorded_activity (rec_activity_id, activity_opt_id, recording_id, duration)
    VALUES (nextval('rec_activity_sequence'), (SELECT activity_opt_id FROM activity_option WHERE activity_name='Work'), jrnl_id_var, 8),
    (nextval('rec_activity_sequence'), (SELECT activity_opt_id FROM activity_option WHERE activity_name='Gym'), jrnl_id_var, 1),
    (nextval('rec_activity_sequence'), (SELECT activity_opt_id FROM activity_option WHERE activity_name='Read Novel'), jrnl_id_var, 1),
    (nextval('rec_activity_sequence'), (SELECT activity_opt_id FROM activity_option WHERE activity_name='Walk Outside'), jrnl_id_var, 1);
    -- Custom Metrics
    CALL ADD_SCAL_METRIC_RECORDING(jrnl_id_var, metric_id_var, 7);

    -- 5th day journal
    jrnl_id_var := (SELECT recording_id FROM daily_recording WHERE app_user_id=3 AND recording_date='2024-02-05');
    -- Activities
    INSERT INTO recorded_activity (rec_activity_id, activity_opt_id, recording_id, duration)
    VALUES (nextval('rec_activity_sequence'), (SELECT activity_opt_id FROM activity_option WHERE activity_name='Work'), jrnl_id_var, 8),
    (nextval('rec_activity_sequence'), (SELECT activity_opt_id FROM activity_option WHERE activity_name='Nap'), jrnl_id_var, 1),
    (nextval('rec_activity_sequence'), (SELECT activity_opt_id FROM activity_option WHERE activity_name='Watch TV'), jrnl_id_var, 3);
    -- Custom Metrics
    CALL ADD_SCAL_METRIC_RECORDING(jrnl_id_var, metric_id_var, 4);

    -- 6th day journal
    jrnl_id_var := (SELECT recording_id FROM daily_recording WHERE app_user_id=3 AND recording_date='2024-02-06');
    -- Activities
    INSERT INTO recorded_activity (rec_activity_id, activity_opt_id, recording_id, duration)
    VALUES (nextval('rec_activity_sequence'), (SELECT activity_opt_id FROM activity_option WHERE activity_name='Relax at Home'), jrnl_id_var, 5),
    (nextval('rec_activity_sequence'), (SELECT activity_opt_id FROM activity_option WHERE activity_name='Nap'), jrnl_id_var, 1),
    (nextval('rec_activity_sequence'), (SELECT activity_opt_id FROM activity_option WHERE activity_name='Read Novel'), jrnl_id_var, 1),
    (nextval('rec_activity_sequence'), (SELECT activity_opt_id FROM activity_option WHERE activity_name='Watch TV'), jrnl_id_var, 4);
    -- Custom Metrics
    CALL ADD_SCAL_METRIC_RECORDING(jrnl_id_var, metric_id_var, 2);

    -- 7th day journal
    jrnl_id_var := (SELECT recording_id FROM daily_recording WHERE app_user_id=3 AND recording_date='2024-02-07');
    -- Activities
    INSERT INTO recorded_activity (rec_activity_id, activity_opt_id, recording_id, duration)
    VALUES (nextval('rec_activity_sequence'), (SELECT activity_opt_id FROM activity_option WHERE activity_name='Gym'), jrnl_id_var, 2),
    (nextval('rec_activity_sequence'), (SELECT activity_opt_id FROM activity_option WHERE activity_name='Homework'), jrnl_id_var, 5),
    (nextval('rec_activity_sequence'), (SELECT activity_opt_id FROM activity_option WHERE activity_name='Read Novel'), jrnl_id_var, 2);
    -- Custom Metrics
    CALL ADD_SCAL_METRIC_RECORDING(jrnl_id_var, metric_id_var, 10);

END;
$$;
COMMIT TRANSACTION;

--QUERIES

-- Question 1 Query
SELECT mood_i_opt.mood_name AS mood_i_name, mood_ii_opt.mood_name AS mood_ii_name, activity_name
FROM app_user
JOIN daily_recording ON app_user.app_user_id=daily_recording.app_user_id
JOIN mood_option AS mood_i_opt ON daily_recording.mood_i=mood_i_opt.mood_id
JOIN mood_option AS mood_ii_opt ON daily_recording.mood_ii=mood_ii_opt.mood_id
JOIN recorded_activity ON daily_recording.recording_id=recorded_activity.recording_id
JOIN activity_option ON recorded_activity.activity_opt_id=activity_option.activity_opt_id
WHERE app_user.app_user_id=(SELECT app_user_id FROM app_user WHERE email='hannahvw@coolmail.com')
AND recording_date = CAST('2024-02-19' AS DATE);

-- Question 2 Query
SELECT category_value.metric_value, COUNT(categorical_metric.rec_metric_id)
FROM (SELECT app_user_id FROM app_user WHERE email='hannahvw@coolmail.com') AS user_info
JOIN daily_recording ON daily_recording.app_user_id=user_info.app_user_id
JOIN recorded_metric ON daily_recording.recording_id=recorded_metric.recording_id
JOIN (SELECT metric_opt_id FROM metric_option WHERE metric_name='Sleep Level') AS metric_opt
ON recorded_metric.metric_opt_id=metric_opt.metric_opt_id
JOIN categorical_metric ON recorded_metric.rec_metric_id=categorical_metric.rec_metric_id
RIGHT JOIN category_value ON category_value.value_id=categorical_metric.value_id
GROUP BY category_value.metric_value;

-- Question 3 Query
CREATE OR REPLACE VIEW user_enabled_metrics AS 
SELECT * FROM (
	SELECT app_user.app_user_id, metric_option.metric_opt_id, metric_name,
	CASE 
		WHEN metric_type=1 THEN 'CATEGORICAL'
		WHEN metric_type=2 THEN 'BOOLEAN'
		WHEN metric_type=3 THEN 'SCALAR'
		ELSE 'UNDEFINED'
	END AS metric_type
	FROM metric_option
	JOIN enabled_metric ON metric_option.metric_opt_id=enabled_metric.metric_opt_id
	JOIN app_user ON enabled_metric.app_user_id=app_user.app_user_id
);

SELECT metric_name, metric_type, COUNT(rec_metric_id) AS times_submitted
FROM user_enabled_metrics
JOIN (SELECT app_user_id FROM app_user WHERE email='hannahvw@coolmail.com') AS user_info
ON user_enabled_metrics.app_user_id=user_info.app_user_id
JOIN (SELECT recording_id, app_user_id FROM daily_recording) AS recording_info
ON recording_info.app_user_id=user_info.app_user_id
JOIN recorded_metric ON recorded_metric.recording_id=recording_info.recording_id
AND recorded_metric.metric_opt_id=user_enabled_metrics.metric_opt_id
GROUP BY metric_name, metric_type;

-- Data Visualization Query 1
-- Capture relationship between activities and moods
SELECT activity_name, COUNT(CASE WHEN is_positive THEN activity_option.activity_opt_id END) AS positve_day_count,
COUNT(CASE WHEN is_positive=false THEN activity_option.activity_opt_id END) AS negative_day_count,
COUNT(activity_option.activity_opt_id) AS total_count
FROM daily_recording
JOIN recorded_activity ON daily_recording.recording_id=recorded_activity.recording_id
JOIN mood_option ON daily_recording.mood_i=mood_option.mood_id
JOIN activity_option ON recorded_activity.activity_opt_id=activity_option.activity_opt_id
WHERE daily_recording.app_user_id=3
GROUP BY activity_option.activity_opt_id
ORDER BY total_count;

-- Data Visualization Query 2
-- Capture relationship between activities and productivity rating
SELECT activity_name, SUM(duration) AS sum_duration, SUM(metric_value) AS sum_productivity,
ROUND((SUM(metric_value) / SUM(duration)),2) AS productivity_rating
FROM daily_recording
JOIN recorded_activity ON daily_recording.recording_id=recorded_activity.recording_id
JOIN activity_option ON recorded_activity.activity_opt_id=activity_option.activity_opt_id
JOIN recorded_metric ON daily_recording.recording_id=recorded_metric.recording_id
JOIN scalar_metric ON recorded_metric.rec_metric_id=scalar_metric.rec_metric_id
WHERE daily_recording.app_user_id=3 AND metric_opt_id=1
GROUP BY activity_option.activity_opt_id
ORDER BY productivity_rating;