-- In this SQL file, write (and comment!) the typical SQL queries users will run on your database

-- Query to return all works of art currently recorded in the database
SELECT
	obj.api_id AS id,
	agt.name_display AS artist,
	obj.title_display AS title,
	obj.date_display AS date,
	obj.medium,
	obj.dimensions,
	obj.description
FROM r_objects_agents AS roa
RIGHT JOIN objects AS obj ON roa.object_id = obj.id
LEFT JOIN agents AS agt ON roa.agent_id = agt.id
LEFT JOIN role_types AS rt ON roa.role_id = rt.id
WHERE rt.name = 'artist'
;


-- Typically query to search for works of art installed at a location, e.g., at a park
SELECT
	obj.title_display,
	l.name_display,
	i.date_display_start_official AS start_date,
	i.date_display_end_official AS end_date,
	i.latitude,
	i.longitude
FROM installations AS i
RIGHT JOIN objects AS obj ON i.object_id = obj.id
LEFT JOIN locations AS l ON i.location_id = l.id
WHERE l.name = '%Park%'
;
