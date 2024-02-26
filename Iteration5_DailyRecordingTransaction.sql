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