-- migrations/000001_create_users_table.down.sql
DROP TRIGGER IF EXISTS set_timestamp_users ON users;
DROP TABLE IF EXISTS users;

-- Optionally drop the function if no other tables use it,
-- or manage it in its own migration. For simplicity here, we might drop it.
-- Be careful if other tables created by later migrations depend on this function.
-- DROP FUNCTION IF EXISTS trigger_set_timestamp();
