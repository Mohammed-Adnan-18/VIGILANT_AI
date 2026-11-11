-- VIGILANT AI - Safe Database Rebranding Migration
-- Rebrands the database from 'precursorai' to 'vigilantai' without data loss.
--
-- INSTRUCTIONS:
-- 1. Connect as superuser to the default 'postgres' database:
--      psql -U postgres -d postgres -f rename_database.sql
-- 2. Verify all tables, pgvector extensions, embeddings, and knowledge chunks remain intact.

\echo '*** Starting VIGILANT AI Database Rebrand Migration ***'

-- 1. Terminate any active connections to the old database (required before renaming)
SELECT pg_terminate_backend(pid)
FROM pg_stat_activity
WHERE datname = 'precursorai' AND pid <> pg_backend_pid();

-- 2. Safely rename the database if it exists
DO $$
BEGIN
    IF EXISTS (SELECT 1 FROM pg_database WHERE datname = 'precursorai') THEN
        IF NOT EXISTS (SELECT 1 FROM pg_database WHERE datname = 'vigilantai') THEN
            ALTER DATABASE "precursorai" RENAME TO "vigilantai";
            RAISE NOTICE 'Successfully renamed database precursorai -> vigilantai';
        ELSE
            RAISE NOTICE 'Target database vigilantai already exists. Manual inspection required before merging.';
        END IF;
    ELSE
        RAISE NOTICE 'Database precursorai does not exist; no database rename needed.';
    END IF;
END $$;

-- 3. Safely rename role 'precursor' to 'vigilant' if configured in docker-compose / .env
DO $$
BEGIN
    IF EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'precursor') THEN
        IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'vigilant') THEN
            ALTER ROLE "precursor" RENAME TO "vigilant";
            RAISE NOTICE 'Successfully renamed role precursor -> vigilant';
        ELSE
            RAISE NOTICE 'Role vigilant already exists.';
        END IF;
    END IF;
END $$;

\echo '*** VIGILANT AI Database Rebrand Complete ***'
