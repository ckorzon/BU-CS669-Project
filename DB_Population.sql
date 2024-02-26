INSERT INTO mood_option (mood_id, mood_name, is_positive)
VALUES (nextval('mood_opt_sequence'), 'Happy', true), (nextval('mood_opt_sequence'), 'Optimistic', true), 
(nextval('mood_opt_sequence'), 'Relaxed', true), (nextval('mood_opt_sequence'), 'Bored', false), (nextval('mood_opt_sequence'), 'Sad', false),
(nextval('mood_opt_sequence'), 'Agitated', false);

INSERT INTO activity_option (activity_opt_id, activity_name)
VALUES (nextval('activity_opt_sequence'), 'Work'), (nextval('activity_opt_sequence'), 'Homework'),
(nextval('activity_opt_sequence'), 'Gym'), (nextval('activity_opt_sequence'), 'Read Novel');

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

