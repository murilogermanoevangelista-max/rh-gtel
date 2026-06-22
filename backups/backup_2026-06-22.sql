--
-- PostgreSQL database dump
--

\restrict 6NmQbrmyitb0hZbez4BIg2tJGHUxk95Z52Ha5qgZeQCaZxK6rrVdMDzz5psDoY0

-- Dumped from database version 17.6
-- Dumped by pg_dump version 17.10 (Ubuntu 17.10-1.pgdg24.04+1)

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: auth; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA auth;


--
-- Name: extensions; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA extensions;


--
-- Name: graphql; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA graphql;


--
-- Name: graphql_public; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA graphql_public;


--
-- Name: pgbouncer; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA pgbouncer;


--
-- Name: realtime; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA realtime;


--
-- Name: storage; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA storage;


--
-- Name: vault; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA vault;


--
-- Name: pg_stat_statements; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS pg_stat_statements WITH SCHEMA extensions;


--
-- Name: EXTENSION pg_stat_statements; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION pg_stat_statements IS 'track planning and execution statistics of all SQL statements executed';


--
-- Name: pgcrypto; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS pgcrypto WITH SCHEMA extensions;


--
-- Name: EXTENSION pgcrypto; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION pgcrypto IS 'cryptographic functions';


--
-- Name: supabase_vault; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS supabase_vault WITH SCHEMA vault;


--
-- Name: EXTENSION supabase_vault; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION supabase_vault IS 'Supabase Vault Extension';


--
-- Name: uuid-ossp; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS "uuid-ossp" WITH SCHEMA extensions;


--
-- Name: EXTENSION "uuid-ossp"; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION "uuid-ossp" IS 'generate universally unique identifiers (UUIDs)';


--
-- Name: aal_level; Type: TYPE; Schema: auth; Owner: -
--

CREATE TYPE auth.aal_level AS ENUM (
    'aal1',
    'aal2',
    'aal3'
);


--
-- Name: code_challenge_method; Type: TYPE; Schema: auth; Owner: -
--

CREATE TYPE auth.code_challenge_method AS ENUM (
    's256',
    'plain'
);


--
-- Name: factor_status; Type: TYPE; Schema: auth; Owner: -
--

CREATE TYPE auth.factor_status AS ENUM (
    'unverified',
    'verified'
);


--
-- Name: factor_type; Type: TYPE; Schema: auth; Owner: -
--

CREATE TYPE auth.factor_type AS ENUM (
    'totp',
    'webauthn',
    'phone'
);


--
-- Name: oauth_authorization_status; Type: TYPE; Schema: auth; Owner: -
--

CREATE TYPE auth.oauth_authorization_status AS ENUM (
    'pending',
    'approved',
    'denied',
    'expired'
);


--
-- Name: oauth_client_type; Type: TYPE; Schema: auth; Owner: -
--

CREATE TYPE auth.oauth_client_type AS ENUM (
    'public',
    'confidential'
);


--
-- Name: oauth_registration_type; Type: TYPE; Schema: auth; Owner: -
--

CREATE TYPE auth.oauth_registration_type AS ENUM (
    'dynamic',
    'manual'
);


--
-- Name: oauth_response_type; Type: TYPE; Schema: auth; Owner: -
--

CREATE TYPE auth.oauth_response_type AS ENUM (
    'code'
);


--
-- Name: one_time_token_type; Type: TYPE; Schema: auth; Owner: -
--

CREATE TYPE auth.one_time_token_type AS ENUM (
    'confirmation_token',
    'reauthentication_token',
    'recovery_token',
    'email_change_token_new',
    'email_change_token_current',
    'phone_change_token'
);


--
-- Name: action; Type: TYPE; Schema: realtime; Owner: -
--

CREATE TYPE realtime.action AS ENUM (
    'INSERT',
    'UPDATE',
    'DELETE',
    'TRUNCATE',
    'ERROR'
);


--
-- Name: equality_op; Type: TYPE; Schema: realtime; Owner: -
--

CREATE TYPE realtime.equality_op AS ENUM (
    'eq',
    'neq',
    'lt',
    'lte',
    'gt',
    'gte',
    'in'
);


--
-- Name: user_defined_filter; Type: TYPE; Schema: realtime; Owner: -
--

CREATE TYPE realtime.user_defined_filter AS (
	column_name text,
	op realtime.equality_op,
	value text
);


--
-- Name: wal_column; Type: TYPE; Schema: realtime; Owner: -
--

CREATE TYPE realtime.wal_column AS (
	name text,
	type_name text,
	type_oid oid,
	value jsonb,
	is_pkey boolean,
	is_selectable boolean
);


--
-- Name: wal_rls; Type: TYPE; Schema: realtime; Owner: -
--

CREATE TYPE realtime.wal_rls AS (
	wal jsonb,
	is_rls_enabled boolean,
	subscription_ids uuid[],
	errors text[]
);


--
-- Name: buckettype; Type: TYPE; Schema: storage; Owner: -
--

CREATE TYPE storage.buckettype AS ENUM (
    'STANDARD',
    'ANALYTICS',
    'VECTOR'
);


--
-- Name: email(); Type: FUNCTION; Schema: auth; Owner: -
--

CREATE FUNCTION auth.email() RETURNS text
    LANGUAGE sql STABLE
    AS $$
  select 
  coalesce(
    nullif(current_setting('request.jwt.claim.email', true), ''),
    (nullif(current_setting('request.jwt.claims', true), '')::jsonb ->> 'email')
  )::text
$$;


--
-- Name: FUNCTION email(); Type: COMMENT; Schema: auth; Owner: -
--

COMMENT ON FUNCTION auth.email() IS 'Deprecated. Use auth.jwt() -> ''email'' instead.';


--
-- Name: jwt(); Type: FUNCTION; Schema: auth; Owner: -
--

CREATE FUNCTION auth.jwt() RETURNS jsonb
    LANGUAGE sql STABLE
    AS $$
  select 
    coalesce(
        nullif(current_setting('request.jwt.claim', true), ''),
        nullif(current_setting('request.jwt.claims', true), '')
    )::jsonb
$$;


--
-- Name: role(); Type: FUNCTION; Schema: auth; Owner: -
--

CREATE FUNCTION auth.role() RETURNS text
    LANGUAGE sql STABLE
    AS $$
  select 
  coalesce(
    nullif(current_setting('request.jwt.claim.role', true), ''),
    (nullif(current_setting('request.jwt.claims', true), '')::jsonb ->> 'role')
  )::text
$$;


--
-- Name: FUNCTION role(); Type: COMMENT; Schema: auth; Owner: -
--

COMMENT ON FUNCTION auth.role() IS 'Deprecated. Use auth.jwt() -> ''role'' instead.';


--
-- Name: uid(); Type: FUNCTION; Schema: auth; Owner: -
--

CREATE FUNCTION auth.uid() RETURNS uuid
    LANGUAGE sql STABLE
    AS $$
  select 
  coalesce(
    nullif(current_setting('request.jwt.claim.sub', true), ''),
    (nullif(current_setting('request.jwt.claims', true), '')::jsonb ->> 'sub')
  )::uuid
$$;


--
-- Name: FUNCTION uid(); Type: COMMENT; Schema: auth; Owner: -
--

COMMENT ON FUNCTION auth.uid() IS 'Deprecated. Use auth.jwt() -> ''sub'' instead.';


--
-- Name: grant_pg_cron_access(); Type: FUNCTION; Schema: extensions; Owner: -
--

CREATE FUNCTION extensions.grant_pg_cron_access() RETURNS event_trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
  IF EXISTS (
    SELECT
    FROM pg_event_trigger_ddl_commands() AS ev
    JOIN pg_extension AS ext
    ON ev.objid = ext.oid
    WHERE ext.extname = 'pg_cron'
  )
  THEN
    grant usage on schema cron to postgres with grant option;

    alter default privileges in schema cron grant all on tables to postgres with grant option;
    alter default privileges in schema cron grant all on functions to postgres with grant option;
    alter default privileges in schema cron grant all on sequences to postgres with grant option;

    alter default privileges for user supabase_admin in schema cron grant all
        on sequences to postgres with grant option;
    alter default privileges for user supabase_admin in schema cron grant all
        on tables to postgres with grant option;
    alter default privileges for user supabase_admin in schema cron grant all
        on functions to postgres with grant option;

    grant all privileges on all tables in schema cron to postgres with grant option;
    revoke all on table cron.job from postgres;
    grant select on table cron.job to postgres with grant option;
  END IF;
END;
$$;


--
-- Name: FUNCTION grant_pg_cron_access(); Type: COMMENT; Schema: extensions; Owner: -
--

COMMENT ON FUNCTION extensions.grant_pg_cron_access() IS 'Grants access to pg_cron';


--
-- Name: grant_pg_graphql_access(); Type: FUNCTION; Schema: extensions; Owner: -
--

CREATE FUNCTION extensions.grant_pg_graphql_access() RETURNS event_trigger
    LANGUAGE plpgsql
    AS $_$
DECLARE
    func_is_graphql_resolve bool;
BEGIN
    func_is_graphql_resolve = (
        SELECT n.proname = 'resolve'
        FROM pg_event_trigger_ddl_commands() AS ev
        LEFT JOIN pg_catalog.pg_proc AS n
        ON ev.objid = n.oid
    );

    IF func_is_graphql_resolve
    THEN
        -- Update public wrapper to pass all arguments through to the pg_graphql resolve func
        DROP FUNCTION IF EXISTS graphql_public.graphql;
        create or replace function graphql_public.graphql(
            "operationName" text default null,
            query text default null,
            variables jsonb default null,
            extensions jsonb default null
        )
            returns jsonb
            language sql
        as $$
            select graphql.resolve(
                query := query,
                variables := coalesce(variables, '{}'),
                "operationName" := "operationName",
                extensions := extensions
            );
        $$;

        -- This hook executes when `graphql.resolve` is created. That is not necessarily the last
        -- function in the extension so we need to grant permissions on existing entities AND
        -- update default permissions to any others that are created after `graphql.resolve`
        grant usage on schema graphql to postgres, anon, authenticated, service_role;
        grant select on all tables in schema graphql to postgres, anon, authenticated, service_role;
        grant execute on all functions in schema graphql to postgres, anon, authenticated, service_role;
        grant all on all sequences in schema graphql to postgres, anon, authenticated, service_role;
        alter default privileges in schema graphql grant all on tables to postgres, anon, authenticated, service_role;
        alter default privileges in schema graphql grant all on functions to postgres, anon, authenticated, service_role;
        alter default privileges in schema graphql grant all on sequences to postgres, anon, authenticated, service_role;

        -- Allow postgres role to allow granting usage on graphql and graphql_public schemas to custom roles
        grant usage on schema graphql_public to postgres with grant option;
        grant usage on schema graphql to postgres with grant option;
    END IF;

END;
$_$;


--
-- Name: FUNCTION grant_pg_graphql_access(); Type: COMMENT; Schema: extensions; Owner: -
--

COMMENT ON FUNCTION extensions.grant_pg_graphql_access() IS 'Grants access to pg_graphql';


--
-- Name: grant_pg_net_access(); Type: FUNCTION; Schema: extensions; Owner: -
--

CREATE FUNCTION extensions.grant_pg_net_access() RETURNS event_trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
  IF EXISTS (
    SELECT 1
    FROM pg_event_trigger_ddl_commands() AS ev
    JOIN pg_extension AS ext
    ON ev.objid = ext.oid
    WHERE ext.extname = 'pg_net'
  )
  THEN
    IF NOT EXISTS (
      SELECT 1
      FROM pg_roles
      WHERE rolname = 'supabase_functions_admin'
    )
    THEN
      CREATE USER supabase_functions_admin NOINHERIT CREATEROLE LOGIN NOREPLICATION;
    END IF;

    GRANT USAGE ON SCHEMA net TO supabase_functions_admin, postgres, anon, authenticated, service_role;

    IF EXISTS (
      SELECT FROM pg_extension
      WHERE extname = 'pg_net'
      -- all versions in use on existing projects as of 2025-02-20
      -- version 0.12.0 onwards don't need these applied
      AND extversion IN ('0.2', '0.6', '0.7', '0.7.1', '0.8', '0.10.0', '0.11.0')
    ) THEN
      ALTER function net.http_get(url text, params jsonb, headers jsonb, timeout_milliseconds integer) SECURITY DEFINER;
      ALTER function net.http_post(url text, body jsonb, params jsonb, headers jsonb, timeout_milliseconds integer) SECURITY DEFINER;

      ALTER function net.http_get(url text, params jsonb, headers jsonb, timeout_milliseconds integer) SET search_path = net;
      ALTER function net.http_post(url text, body jsonb, params jsonb, headers jsonb, timeout_milliseconds integer) SET search_path = net;

      REVOKE ALL ON FUNCTION net.http_get(url text, params jsonb, headers jsonb, timeout_milliseconds integer) FROM PUBLIC;
      REVOKE ALL ON FUNCTION net.http_post(url text, body jsonb, params jsonb, headers jsonb, timeout_milliseconds integer) FROM PUBLIC;

      GRANT EXECUTE ON FUNCTION net.http_get(url text, params jsonb, headers jsonb, timeout_milliseconds integer) TO supabase_functions_admin, postgres, anon, authenticated, service_role;
      GRANT EXECUTE ON FUNCTION net.http_post(url text, body jsonb, params jsonb, headers jsonb, timeout_milliseconds integer) TO supabase_functions_admin, postgres, anon, authenticated, service_role;
    END IF;
  END IF;
END;
$$;


--
-- Name: FUNCTION grant_pg_net_access(); Type: COMMENT; Schema: extensions; Owner: -
--

COMMENT ON FUNCTION extensions.grant_pg_net_access() IS 'Grants access to pg_net';


--
-- Name: pgrst_ddl_watch(); Type: FUNCTION; Schema: extensions; Owner: -
--

CREATE FUNCTION extensions.pgrst_ddl_watch() RETURNS event_trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
  cmd record;
BEGIN
  FOR cmd IN SELECT * FROM pg_event_trigger_ddl_commands()
  LOOP
    IF cmd.command_tag IN (
      'CREATE SCHEMA', 'ALTER SCHEMA'
    , 'CREATE TABLE', 'CREATE TABLE AS', 'SELECT INTO', 'ALTER TABLE'
    , 'CREATE FOREIGN TABLE', 'ALTER FOREIGN TABLE'
    , 'CREATE VIEW', 'ALTER VIEW'
    , 'CREATE MATERIALIZED VIEW', 'ALTER MATERIALIZED VIEW'
    , 'CREATE FUNCTION', 'ALTER FUNCTION'
    , 'CREATE TRIGGER'
    , 'CREATE TYPE', 'ALTER TYPE'
    , 'CREATE RULE'
    , 'COMMENT'
    )
    -- don't notify in case of CREATE TEMP table or other objects created on pg_temp
    AND cmd.schema_name is distinct from 'pg_temp'
    THEN
      NOTIFY pgrst, 'reload schema';
    END IF;
  END LOOP;
END; $$;


--
-- Name: pgrst_drop_watch(); Type: FUNCTION; Schema: extensions; Owner: -
--

CREATE FUNCTION extensions.pgrst_drop_watch() RETURNS event_trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
  obj record;
BEGIN
  FOR obj IN SELECT * FROM pg_event_trigger_dropped_objects()
  LOOP
    IF obj.object_type IN (
      'schema'
    , 'table'
    , 'foreign table'
    , 'view'
    , 'materialized view'
    , 'function'
    , 'trigger'
    , 'type'
    , 'rule'
    )
    AND obj.is_temporary IS false -- no pg_temp objects
    THEN
      NOTIFY pgrst, 'reload schema';
    END IF;
  END LOOP;
END; $$;


--
-- Name: set_graphql_placeholder(); Type: FUNCTION; Schema: extensions; Owner: -
--

CREATE FUNCTION extensions.set_graphql_placeholder() RETURNS event_trigger
    LANGUAGE plpgsql
    AS $_$
    DECLARE
    graphql_is_dropped bool;
    BEGIN
    graphql_is_dropped = (
        SELECT ev.schema_name = 'graphql_public'
        FROM pg_event_trigger_dropped_objects() AS ev
        WHERE ev.schema_name = 'graphql_public'
    );

    IF graphql_is_dropped
    THEN
        create or replace function graphql_public.graphql(
            "operationName" text default null,
            query text default null,
            variables jsonb default null,
            extensions jsonb default null
        )
            returns jsonb
            language plpgsql
        as $$
            DECLARE
                server_version float;
            BEGIN
                server_version = (SELECT (SPLIT_PART((select version()), ' ', 2))::float);

                IF server_version >= 14 THEN
                    RETURN jsonb_build_object(
                        'errors', jsonb_build_array(
                            jsonb_build_object(
                                'message', 'pg_graphql extension is not enabled.'
                            )
                        )
                    );
                ELSE
                    RETURN jsonb_build_object(
                        'errors', jsonb_build_array(
                            jsonb_build_object(
                                'message', 'pg_graphql is only available on projects running Postgres 14 onwards.'
                            )
                        )
                    );
                END IF;
            END;
        $$;
    END IF;

    END;
$_$;


--
-- Name: FUNCTION set_graphql_placeholder(); Type: COMMENT; Schema: extensions; Owner: -
--

COMMENT ON FUNCTION extensions.set_graphql_placeholder() IS 'Reintroduces placeholder function for graphql_public.graphql';


--
-- Name: graphql(text, text, jsonb, jsonb); Type: FUNCTION; Schema: graphql_public; Owner: -
--

CREATE FUNCTION graphql_public.graphql("operationName" text DEFAULT NULL::text, query text DEFAULT NULL::text, variables jsonb DEFAULT NULL::jsonb, extensions jsonb DEFAULT NULL::jsonb) RETURNS jsonb
    LANGUAGE plpgsql
    AS $$
            DECLARE
                server_version float;
            BEGIN
                server_version = (SELECT (SPLIT_PART((select version()), ' ', 2))::float);

                IF server_version >= 14 THEN
                    RETURN jsonb_build_object(
                        'errors', jsonb_build_array(
                            jsonb_build_object(
                                'message', 'pg_graphql extension is not enabled.'
                            )
                        )
                    );
                ELSE
                    RETURN jsonb_build_object(
                        'errors', jsonb_build_array(
                            jsonb_build_object(
                                'message', 'pg_graphql is only available on projects running Postgres 14 onwards.'
                            )
                        )
                    );
                END IF;
            END;
        $$;


--
-- Name: get_auth(text); Type: FUNCTION; Schema: pgbouncer; Owner: -
--

CREATE FUNCTION pgbouncer.get_auth(p_usename text) RETURNS TABLE(username text, password text)
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO ''
    AS $_$
  BEGIN
      RAISE DEBUG 'PgBouncer auth request: %', p_usename;

      RETURN QUERY
      SELECT
          rolname::text,
          CASE WHEN rolvaliduntil < now()
              THEN null
              ELSE rolpassword::text
          END
      FROM pg_authid
      WHERE rolname=$1 and rolcanlogin;
  END;
  $_$;


--
-- Name: apply_rls(jsonb, integer); Type: FUNCTION; Schema: realtime; Owner: -
--

CREATE FUNCTION realtime.apply_rls(wal jsonb, max_record_bytes integer DEFAULT (1024 * 1024)) RETURNS SETOF realtime.wal_rls
    LANGUAGE plpgsql
    AS $$
declare
    -- Regclass of the table e.g. public.notes
    entity_ regclass = (quote_ident(wal ->> 'schema') || '.' || quote_ident(wal ->> 'table'))::regclass;

    -- I, U, D, T: insert, update ...
    action realtime.action = (
        case wal ->> 'action'
            when 'I' then 'INSERT'
            when 'U' then 'UPDATE'
            when 'D' then 'DELETE'
            else 'ERROR'
        end
    );

    -- Is row level security enabled for the table
    is_rls_enabled bool = relrowsecurity from pg_class where oid = entity_;

    subscriptions realtime.subscription[] = array_agg(subs)
        from
            realtime.subscription subs
        where
            subs.entity = entity_
            -- Filter by action early - only get subscriptions interested in this action
            -- action_filter column can be: '*' (all), 'INSERT', 'UPDATE', or 'DELETE'
            and (subs.action_filter = '*' or subs.action_filter = action::text);

    -- Subscription vars
    working_role regrole;
    working_selected_columns text[];
    claimed_role regrole;
    claims jsonb;

    subscription_id uuid;
    subscription_has_access bool;
    visible_to_subscription_ids uuid[] = '{}';

    -- structured info for wal's columns
    columns realtime.wal_column[];
    -- previous identity values for update/delete
    old_columns realtime.wal_column[];

    error_record_exceeds_max_size boolean = octet_length(wal::text) > max_record_bytes;

    -- Primary jsonb output for record
    output jsonb;

    -- Loop record for iterating unique roles (outer loop)
    role_record record;
    -- Loop record for iterating unique selected_columns within a role (inner loop)
    cols_record record;
    -- Subscription ids visible at the role level (before fanning out by selected_columns)
    visible_role_sub_ids uuid[] = '{}';

begin
    perform set_config('role', null, true);

    columns =
        array_agg(
            (
                x->>'name',
                x->>'type',
                x->>'typeoid',
                realtime.cast(
                    (x->'value') #>> '{}',
                    coalesce(
                        (x->>'typeoid')::regtype, -- null when wal2json version <= 2.4
                        (x->>'type')::regtype
                    )
                ),
                (pks ->> 'name') is not null,
                true
            )::realtime.wal_column
        )
        from
            jsonb_array_elements(wal -> 'columns') x
            left join jsonb_array_elements(wal -> 'pk') pks
                on (x ->> 'name') = (pks ->> 'name');

    old_columns =
        array_agg(
            (
                x->>'name',
                x->>'type',
                x->>'typeoid',
                realtime.cast(
                    (x->'value') #>> '{}',
                    coalesce(
                        (x->>'typeoid')::regtype, -- null when wal2json version <= 2.4
                        (x->>'type')::regtype
                    )
                ),
                (pks ->> 'name') is not null,
                true
            )::realtime.wal_column
        )
        from
            jsonb_array_elements(wal -> 'identity') x
            left join jsonb_array_elements(wal -> 'pk') pks
                on (x ->> 'name') = (pks ->> 'name');

    for role_record in
        select claims_role
        from (select distinct claims_role from unnest(subscriptions)) t
        order by claims_role::text
    loop
        working_role := role_record.claims_role;

        -- Update `is_selectable` for columns and old_columns (once per role)
        columns =
            array_agg(
                (
                    c.name,
                    c.type_name,
                    c.type_oid,
                    c.value,
                    c.is_pkey,
                    pg_catalog.has_column_privilege(working_role, entity_, c.name, 'SELECT')
                )::realtime.wal_column
            )
            from
                unnest(columns) c;

        old_columns =
                array_agg(
                    (
                        c.name,
                        c.type_name,
                        c.type_oid,
                        c.value,
                        c.is_pkey,
                        pg_catalog.has_column_privilege(working_role, entity_, c.name, 'SELECT')
                    )::realtime.wal_column
                )
                from
                    unnest(old_columns) c;

        if action <> 'DELETE' and count(1) = 0 from unnest(columns) c where c.is_pkey then
            -- Fan out 400 error per distinct selected_columns for this role
            for cols_record in
                select selected_columns
                from (select distinct selected_columns from unnest(subscriptions) s where s.claims_role = working_role) t
                order by coalesce(array_to_string(selected_columns, ','), '')
            loop
                working_selected_columns := cols_record.selected_columns;
                return next (
                    jsonb_build_object(
                        'schema', wal ->> 'schema',
                        'table', wal ->> 'table',
                        'type', action
                    ),
                    is_rls_enabled,
                    (select array_agg(s.subscription_id) from unnest(subscriptions) as s where s.claims_role = working_role and (s.selected_columns is not distinct from working_selected_columns)),
                    array['Error 400: Bad Request, no primary key']
                )::realtime.wal_rls;
            end loop;

        -- The claims role does not have SELECT permission to the primary key of entity
        elsif action <> 'DELETE' and sum(c.is_selectable::int) <> count(1) from unnest(columns) c where c.is_pkey then
            -- Fan out 401 error per distinct selected_columns for this role
            for cols_record in
                select selected_columns
                from (select distinct selected_columns from unnest(subscriptions) s where s.claims_role = working_role) t
                order by coalesce(array_to_string(selected_columns, ','), '')
            loop
                working_selected_columns := cols_record.selected_columns;
                return next (
                    jsonb_build_object(
                        'schema', wal ->> 'schema',
                        'table', wal ->> 'table',
                        'type', action
                    ),
                    is_rls_enabled,
                    (select array_agg(s.subscription_id) from unnest(subscriptions) as s where s.claims_role = working_role and (s.selected_columns is not distinct from working_selected_columns)),
                    array['Error 401: Unauthorized']
                )::realtime.wal_rls;
            end loop;

        else
            -- Create the prepared statement (once per role)
            if is_rls_enabled and action <> 'DELETE' then
                if (select 1 from pg_prepared_statements where name = 'walrus_rls_stmt' limit 1) > 0 then
                    deallocate walrus_rls_stmt;
                end if;
                execute realtime.build_prepared_statement_sql('walrus_rls_stmt', entity_, columns);
            end if;

            -- Collect all visible subscription IDs for this role (filter check + RLS check)
            visible_role_sub_ids = '{}';

            for subscription_id, claims in (
                    select
                        subs.subscription_id,
                        subs.claims
                    from
                        unnest(subscriptions) subs
                    where
                        subs.entity = entity_
                        and subs.claims_role = working_role
                        and (
                            realtime.is_visible_through_filters(columns, subs.filters)
                            or (
                              action = 'DELETE'
                              and realtime.is_visible_through_filters(old_columns, subs.filters)
                            )
                        )
            ) loop

                if not is_rls_enabled or action = 'DELETE' then
                    visible_role_sub_ids = visible_role_sub_ids || subscription_id;
                else
                    -- Check if RLS allows the role to see the record
                    perform
                        -- Trim leading and trailing quotes from working_role because set_config
                        -- doesn't recognize the role as valid if they are included
                        set_config('role', trim(both '"' from working_role::text), true),
                        set_config('request.jwt.claims', claims::text, true);

                    execute 'execute walrus_rls_stmt' into subscription_has_access;

                    if subscription_has_access then
                        visible_role_sub_ids = visible_role_sub_ids || subscription_id;
                    end if;
                end if;
            end loop;

            perform set_config('role', null, true);

            -- Inner loop: per distinct selected_columns for this role
            for cols_record in
                select selected_columns
                from (select distinct selected_columns from unnest(subscriptions) s where s.claims_role = working_role) t
                order by coalesce(array_to_string(selected_columns, ','), '')
            loop
                working_selected_columns := cols_record.selected_columns;

                output = jsonb_build_object(
                    'schema', wal ->> 'schema',
                    'table', wal ->> 'table',
                    'type', action,
                    'commit_timestamp', to_char(
                        ((wal ->> 'timestamp')::timestamptz at time zone 'utc'),
                        'YYYY-MM-DD"T"HH24:MI:SS.MS"Z"'
                    ),
                    'columns', (
                        select
                            jsonb_agg(
                                jsonb_build_object(
                                    'name', pa.attname,
                                    'type', pt.typname
                                )
                                order by pa.attnum asc
                            )
                        from
                            pg_attribute pa
                            join pg_type pt
                                on pa.atttypid = pt.oid
                            left join (
                                select unnest(conkey) as pkey_attnum
                                from pg_constraint
                                where conrelid = entity_ and contype = 'p'
                            ) pk on pk.pkey_attnum = pa.attnum
                        where
                            attrelid = entity_
                            and attnum > 0
                            and pg_catalog.has_column_privilege(working_role, entity_, pa.attname, 'SELECT')
                            and (working_selected_columns is null or pa.attname = any(working_selected_columns) or pk.pkey_attnum is not null)
                    )
                )
                -- Add "record" key for insert and update
                || case
                    when action in ('INSERT', 'UPDATE') then
                        jsonb_build_object(
                            'record',
                            (
                                select
                                    jsonb_object_agg(
                                        -- if unchanged toast, get column name and value from old record
                                        coalesce((c).name, (oc).name),
                                        case
                                            when (c).name is null then (oc).value
                                            else (c).value
                                        end
                                    )
                                from
                                    unnest(columns) c
                                    full outer join unnest(old_columns) oc
                                        on (c).name = (oc).name
                                where
                                    coalesce((c).is_selectable, (oc).is_selectable)
                                    and (working_selected_columns is null or coalesce((c).name, (oc).name) = any(working_selected_columns) or coalesce((c).is_pkey, (oc).is_pkey))
                                    and ( not error_record_exceeds_max_size or (octet_length((c).value::text) <= 64))
                            )
                        )
                    else '{}'::jsonb
                end
                -- Add "old_record" key for update and delete
                || case
                    when action = 'UPDATE' then
                        jsonb_build_object(
                                'old_record',
                                (
                                    select jsonb_object_agg((c).name, (c).value)
                                    from unnest(old_columns) c
                                    where
                                        (c).is_selectable
                                        and (working_selected_columns is null or (c).name = any(working_selected_columns) or (c).is_pkey)
                                        and ( not error_record_exceeds_max_size or (octet_length((c).value::text) <= 64))
                                )
                            )
                    when action = 'DELETE' then
                        jsonb_build_object(
                            'old_record',
                            (
                                select jsonb_object_agg((c).name, (c).value)
                                from unnest(old_columns) c
                                where
                                    (c).is_selectable
                                    and (working_selected_columns is null or (c).name = any(working_selected_columns) or (c).is_pkey)
                                    and ( not error_record_exceeds_max_size or (octet_length((c).value::text) <= 64))
                                    and ( not is_rls_enabled or (c).is_pkey ) -- if RLS enabled, we can't secure deletes so filter to pkey
                            )
                        )
                    else '{}'::jsonb
                end;

                -- Filter visible_role_sub_ids to those matching the current selected_columns group
                visible_to_subscription_ids = coalesce(
                    (
                        select array_agg(s.subscription_id)
                        from unnest(subscriptions) s
                        where s.claims_role = working_role
                          and (s.selected_columns is not distinct from working_selected_columns)
                          and s.subscription_id = any(visible_role_sub_ids)
                    ),
                    '{}'::uuid[]
                );

                return next (
                    output,
                    is_rls_enabled,
                    visible_to_subscription_ids,
                    case
                        when error_record_exceeds_max_size then array['Error 413: Payload Too Large']
                        else '{}'
                    end
                )::realtime.wal_rls;
            end loop;

        end if;
    end loop;

    perform set_config('role', null, true);
end;
$$;


--
-- Name: broadcast_changes(text, text, text, text, text, record, record, text); Type: FUNCTION; Schema: realtime; Owner: -
--

CREATE FUNCTION realtime.broadcast_changes(topic_name text, event_name text, operation text, table_name text, table_schema text, new record, old record, level text DEFAULT 'ROW'::text) RETURNS void
    LANGUAGE plpgsql
    AS $$
DECLARE
    -- Declare a variable to hold the JSONB representation of the row
    row_data jsonb := '{}'::jsonb;
BEGIN
    IF level = 'STATEMENT' THEN
        RAISE EXCEPTION 'function can only be triggered for each row, not for each statement';
    END IF;
    -- Check the operation type and handle accordingly
    IF operation = 'INSERT' OR operation = 'UPDATE' OR operation = 'DELETE' THEN
        row_data := jsonb_build_object('old_record', OLD, 'record', NEW, 'operation', operation, 'table', table_name, 'schema', table_schema);
        PERFORM realtime.send (row_data, event_name, topic_name);
    ELSE
        RAISE EXCEPTION 'Unexpected operation type: %', operation;
    END IF;
EXCEPTION
    WHEN OTHERS THEN
        RAISE EXCEPTION 'Failed to process the row: %', SQLERRM;
END;

$$;


--
-- Name: build_prepared_statement_sql(text, regclass, realtime.wal_column[]); Type: FUNCTION; Schema: realtime; Owner: -
--

CREATE FUNCTION realtime.build_prepared_statement_sql(prepared_statement_name text, entity regclass, columns realtime.wal_column[]) RETURNS text
    LANGUAGE sql
    AS $$
      /*
      Builds a sql string that, if executed, creates a prepared statement to
      tests retrive a row from *entity* by its primary key columns.
      Example
          select realtime.build_prepared_statement_sql('public.notes', '{"id"}'::text[], '{"bigint"}'::text[])
      */
          select
      'prepare ' || prepared_statement_name || ' as
          select
              exists(
                  select
                      1
                  from
                      ' || entity || '
                  where
                      ' || string_agg(quote_ident(pkc.name) || '=' || quote_nullable(pkc.value #>> '{}') , ' and ') || '
              )'
          from
              unnest(columns) pkc
          where
              pkc.is_pkey
          group by
              entity
      $$;


--
-- Name: cast(text, regtype); Type: FUNCTION; Schema: realtime; Owner: -
--

CREATE FUNCTION realtime."cast"(val text, type_ regtype) RETURNS jsonb
    LANGUAGE plpgsql IMMUTABLE
    AS $$
declare
  res jsonb;
begin
  if type_::text = 'bytea' then
    return to_jsonb(val);
  end if;
  execute format('select to_jsonb(%L::'|| type_::text || ')', val) into res;
  return res;
end
$$;


--
-- Name: check_equality_op(realtime.equality_op, regtype, text, text); Type: FUNCTION; Schema: realtime; Owner: -
--

CREATE FUNCTION realtime.check_equality_op(op realtime.equality_op, type_ regtype, val_1 text, val_2 text) RETURNS boolean
    LANGUAGE plpgsql IMMUTABLE
    AS $$
      /*
      Casts *val_1* and *val_2* as type *type_* and check the *op* condition for truthiness
      */
      declare
          op_symbol text = (
              case
                  when op = 'eq' then '='
                  when op = 'neq' then '!='
                  when op = 'lt' then '<'
                  when op = 'lte' then '<='
                  when op = 'gt' then '>'
                  when op = 'gte' then '>='
                  when op = 'in' then '= any'
                  else 'UNKNOWN OP'
              end
          );
          res boolean;
      begin
          execute format(
              'select %L::'|| type_::text || ' ' || op_symbol
              || ' ( %L::'
              || (
                  case
                      when op = 'in' then type_::text || '[]'
                      else type_::text end
              )
              || ')', val_1, val_2) into res;
          return res;
      end;
      $$;


--
-- Name: is_visible_through_filters(realtime.wal_column[], realtime.user_defined_filter[]); Type: FUNCTION; Schema: realtime; Owner: -
--

CREATE FUNCTION realtime.is_visible_through_filters(columns realtime.wal_column[], filters realtime.user_defined_filter[]) RETURNS boolean
    LANGUAGE sql IMMUTABLE
    AS $_$
    /*
    Should the record be visible (true) or filtered out (false) after *filters* are applied
    */
        select
            -- Default to allowed when no filters present
            $2 is null -- no filters. this should not happen because subscriptions has a default
            or array_length($2, 1) is null -- array length of an empty array is null
            or bool_and(
                coalesce(
                    realtime.check_equality_op(
                        op:=f.op,
                        type_:=coalesce(
                            col.type_oid::regtype, -- null when wal2json version <= 2.4
                            col.type_name::regtype
                        ),
                        -- cast jsonb to text
                        val_1:=col.value #>> '{}',
                        val_2:=f.value
                    ),
                    false -- if null, filter does not match
                )
            )
        from
            unnest(filters) f
            join unnest(columns) col
                on f.column_name = col.name;
    $_$;


--
-- Name: list_changes(name, name, integer, integer); Type: FUNCTION; Schema: realtime; Owner: -
--

CREATE FUNCTION realtime.list_changes(publication name, slot_name name, max_changes integer, max_record_bytes integer) RETURNS TABLE(wal jsonb, is_rls_enabled boolean, subscription_ids uuid[], errors text[], slot_changes_count bigint)
    LANGUAGE sql
    SET log_min_messages TO 'fatal'
    AS $$
  WITH pub AS (
    SELECT
      concat_ws(
        ',',
        CASE WHEN bool_or(pubinsert) THEN 'insert' ELSE NULL END,
        CASE WHEN bool_or(pubupdate) THEN 'update' ELSE NULL END,
        CASE WHEN bool_or(pubdelete) THEN 'delete' ELSE NULL END
      ) AS w2j_actions,
      coalesce(
        string_agg(
          realtime.quote_wal2json(format('%I.%I', schemaname, tablename)::regclass),
          ','
        ) filter (WHERE ppt.tablename IS NOT NULL),
        ''
      ) AS w2j_add_tables
    FROM pg_publication pp
    LEFT JOIN pg_publication_tables ppt ON pp.pubname = ppt.pubname
    WHERE pp.pubname = publication
    GROUP BY pp.pubname
    LIMIT 1
  ),
  -- MATERIALIZED ensures pg_logical_slot_get_changes is called exactly once
  w2j AS MATERIALIZED (
    SELECT x.*, pub.w2j_add_tables
    FROM pub,
         pg_logical_slot_get_changes(
           slot_name, null, max_changes,
           'include-pk', 'true',
           'include-transaction', 'false',
           'include-timestamp', 'true',
           'include-type-oids', 'true',
           'format-version', '2',
           'actions', pub.w2j_actions,
           'add-tables', pub.w2j_add_tables
         ) x
  ),
  slot_count AS (
    SELECT count(*)::bigint AS cnt
    FROM w2j
    WHERE w2j.w2j_add_tables <> ''
  ),
  rls_filtered AS (
    SELECT xyz.wal, xyz.is_rls_enabled, xyz.subscription_ids, xyz.errors
    FROM w2j,
         realtime.apply_rls(
           wal := w2j.data::jsonb,
           max_record_bytes := max_record_bytes
         ) xyz(wal, is_rls_enabled, subscription_ids, errors)
    WHERE w2j.w2j_add_tables <> ''
      AND xyz.subscription_ids[1] IS NOT NULL
  )
  SELECT rf.wal, rf.is_rls_enabled, rf.subscription_ids, rf.errors, sc.cnt
  FROM rls_filtered rf, slot_count sc

  UNION ALL

  SELECT null, null, null, null, sc.cnt
  FROM slot_count sc
  WHERE NOT EXISTS (SELECT 1 FROM rls_filtered)
$$;


--
-- Name: quote_wal2json(regclass); Type: FUNCTION; Schema: realtime; Owner: -
--

CREATE FUNCTION realtime.quote_wal2json(entity regclass) RETURNS text
    LANGUAGE sql IMMUTABLE STRICT
    AS $$
  SELECT
    realtime.wal2json_escape_identifier(nsp.nspname::text)
    || '.'
    || realtime.wal2json_escape_identifier(pc.relname::text)
  FROM pg_class pc
  JOIN pg_namespace nsp ON pc.relnamespace = nsp.oid
  WHERE pc.oid = entity
$$;


--
-- Name: send(jsonb, text, text, boolean); Type: FUNCTION; Schema: realtime; Owner: -
--

CREATE FUNCTION realtime.send(payload jsonb, event text, topic text, private boolean DEFAULT true) RETURNS void
    LANGUAGE plpgsql
    AS $$
DECLARE
  generated_id uuid;
  final_payload jsonb;
BEGIN
  BEGIN
    generated_id := gen_random_uuid();

    -- Check if payload has an 'id' key, if not, add the generated UUID
    IF payload ? 'id' THEN
      final_payload := payload;
    ELSE
      final_payload := jsonb_set(payload, '{id}', to_jsonb(generated_id));
    END IF;

    -- Set the topic configuration
    EXECUTE format('SET LOCAL realtime.topic TO %L', topic);

    INSERT INTO realtime.messages (id, payload, event, topic, private, extension)
    VALUES (generated_id, final_payload, event, topic, private, 'broadcast');
  EXCEPTION
    WHEN OTHERS THEN
      RAISE WARNING 'WarnSendingBroadcastMessage: %', SQLERRM;
  END;
END;
$$;


--
-- Name: send_binary(bytea, text, text, boolean); Type: FUNCTION; Schema: realtime; Owner: -
--

CREATE FUNCTION realtime.send_binary(payload bytea, event text, topic text, private boolean DEFAULT true) RETURNS void
    LANGUAGE plpgsql
    AS $$
DECLARE
  generated_id uuid;
BEGIN
  BEGIN
    generated_id := gen_random_uuid();

    EXECUTE format('SET LOCAL realtime.topic TO %L', topic);

    INSERT INTO realtime.messages (id, binary_payload, event, topic, private, extension)
    VALUES (generated_id, payload, event, topic, private, 'broadcast');
  EXCEPTION
    WHEN OTHERS THEN
      RAISE WARNING 'WarnSendingBroadcastMessage: %', SQLERRM;
  END;
END;
$$;


--
-- Name: subscription_check_filters(); Type: FUNCTION; Schema: realtime; Owner: -
--

CREATE FUNCTION realtime.subscription_check_filters() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
declare
    col_names text[] = coalesce(
            array_agg(a.attname order by a.attnum),
            '{}'::text[]
        )
        from
            pg_catalog.pg_attribute a
        where
            a.attrelid = new.entity
            and a.attnum > 0
            and not a.attisdropped
            and pg_catalog.has_column_privilege(
                (new.claims ->> 'role'),
                a.attrelid,
                a.attnum,
                'SELECT'
            );
    filter realtime.user_defined_filter;
    col_type regtype;
    in_val jsonb;
    selected_col text;
begin
    for filter in select * from unnest(new.filters) loop
        if not filter.column_name = any(col_names) then
            raise exception 'invalid column for filter %', filter.column_name;
        end if;

        col_type = (
            select atttypid::regtype
            from pg_catalog.pg_attribute
            where attrelid = new.entity
                  and attname = filter.column_name
        );
        if col_type is null then
            raise exception 'failed to lookup type for column %', filter.column_name;
        end if;

        if filter.op = 'in'::realtime.equality_op then
            in_val = realtime.cast(filter.value, (col_type::text || '[]')::regtype);
            if coalesce(jsonb_array_length(in_val), 0) > 100 then
                raise exception 'too many values for `in` filter. Maximum 100';
            end if;
        else
            perform realtime.cast(filter.value, col_type);
        end if;
    end loop;

    if new.selected_columns is not null then
        for selected_col in select * from unnest(new.selected_columns) loop
            if not selected_col = any(col_names) then
                raise exception 'invalid column for select %', selected_col;
            end if;
        end loop;
    end if;

    new.filters = coalesce(
        array_agg(f order by f.column_name, f.op, f.value),
        '{}'
    ) from unnest(new.filters) f;

    new.selected_columns = (
        select array_agg(c order by c)
        from unnest(new.selected_columns) c
    );

    return new;
end;
$$;


--
-- Name: to_regrole(text); Type: FUNCTION; Schema: realtime; Owner: -
--

CREATE FUNCTION realtime.to_regrole(role_name text) RETURNS regrole
    LANGUAGE sql IMMUTABLE
    AS $$ select role_name::regrole $$;


--
-- Name: topic(); Type: FUNCTION; Schema: realtime; Owner: -
--

CREATE FUNCTION realtime.topic() RETURNS text
    LANGUAGE sql STABLE
    AS $$
select nullif(current_setting('realtime.topic', true), '')::text;
$$;


--
-- Name: wal2json_escape_identifier(text); Type: FUNCTION; Schema: realtime; Owner: -
--

CREATE FUNCTION realtime.wal2json_escape_identifier(name text) RETURNS text
    LANGUAGE sql IMMUTABLE STRICT
    AS $$
  -- Prefix `\`, `,`, `.`, and any whitespace with `\`
  SELECT regexp_replace(name, '([\\,.[:space:]])', '\\\1', 'g')
$$;


--
-- Name: allow_any_operation(text[]); Type: FUNCTION; Schema: storage; Owner: -
--

CREATE FUNCTION storage.allow_any_operation(expected_operations text[]) RETURNS boolean
    LANGUAGE sql STABLE
    AS $$
  WITH current_operation AS (
    SELECT storage.operation() AS raw_operation
  ),
  normalized AS (
    SELECT CASE
      WHEN raw_operation LIKE 'storage.%' THEN substr(raw_operation, 9)
      ELSE raw_operation
    END AS current_operation
    FROM current_operation
  )
  SELECT EXISTS (
    SELECT 1
    FROM normalized n
    CROSS JOIN LATERAL unnest(expected_operations) AS expected_operation
    WHERE expected_operation IS NOT NULL
      AND expected_operation <> ''
      AND n.current_operation = CASE
        WHEN expected_operation LIKE 'storage.%' THEN substr(expected_operation, 9)
        ELSE expected_operation
      END
  );
$$;


--
-- Name: allow_only_operation(text); Type: FUNCTION; Schema: storage; Owner: -
--

CREATE FUNCTION storage.allow_only_operation(expected_operation text) RETURNS boolean
    LANGUAGE sql STABLE
    AS $$
  WITH current_operation AS (
    SELECT storage.operation() AS raw_operation
  ),
  normalized AS (
    SELECT
      CASE
        WHEN raw_operation LIKE 'storage.%' THEN substr(raw_operation, 9)
        ELSE raw_operation
      END AS current_operation,
      CASE
        WHEN expected_operation LIKE 'storage.%' THEN substr(expected_operation, 9)
        ELSE expected_operation
      END AS requested_operation
    FROM current_operation
  )
  SELECT CASE
    WHEN requested_operation IS NULL OR requested_operation = '' THEN FALSE
    ELSE COALESCE(current_operation = requested_operation, FALSE)
  END
  FROM normalized;
$$;


--
-- Name: can_insert_object(text, text, uuid, jsonb); Type: FUNCTION; Schema: storage; Owner: -
--

CREATE FUNCTION storage.can_insert_object(bucketid text, name text, owner uuid, metadata jsonb) RETURNS void
    LANGUAGE plpgsql
    AS $$
BEGIN
  INSERT INTO "storage"."objects" ("bucket_id", "name", "owner", "metadata") VALUES (bucketid, name, owner, metadata);
  -- hack to rollback the successful insert
  RAISE sqlstate 'PT200' using
  message = 'ROLLBACK',
  detail = 'rollback successful insert';
END
$$;


--
-- Name: enforce_bucket_name_length(); Type: FUNCTION; Schema: storage; Owner: -
--

CREATE FUNCTION storage.enforce_bucket_name_length() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
begin
    if length(new.name) > 100 then
        raise exception 'bucket name "%" is too long (% characters). Max is 100.', new.name, length(new.name);
    end if;
    return new;
end;
$$;


--
-- Name: extension(text); Type: FUNCTION; Schema: storage; Owner: -
--

CREATE FUNCTION storage.extension(name text) RETURNS text
    LANGUAGE plpgsql IMMUTABLE
    AS $$
DECLARE
    _parts text[];
    _filename text;
BEGIN
    -- Split on "/" to get path segments
    SELECT string_to_array(name, '/') INTO _parts;
    -- Get the last path segment (the actual filename)
    SELECT _parts[array_length(_parts, 1)] INTO _filename;
    -- Extract extension: reverse, split on '.', then reverse again
    RETURN reverse(split_part(reverse(_filename), '.', 1));
END
$$;


--
-- Name: filename(text); Type: FUNCTION; Schema: storage; Owner: -
--

CREATE FUNCTION storage.filename(name text) RETURNS text
    LANGUAGE plpgsql
    AS $$
DECLARE
_parts text[];
BEGIN
	select string_to_array(name, '/') into _parts;
	return _parts[array_length(_parts,1)];
END
$$;


--
-- Name: foldername(text); Type: FUNCTION; Schema: storage; Owner: -
--

CREATE FUNCTION storage.foldername(name text) RETURNS text[]
    LANGUAGE plpgsql IMMUTABLE
    AS $$
DECLARE
    _parts text[];
BEGIN
    -- Split on "/" to get path segments
    SELECT string_to_array(name, '/') INTO _parts;
    -- Return everything except the last segment
    RETURN _parts[1 : array_length(_parts,1) - 1];
END
$$;


--
-- Name: get_common_prefix(text, text, text); Type: FUNCTION; Schema: storage; Owner: -
--

CREATE FUNCTION storage.get_common_prefix(p_key text, p_prefix text, p_delimiter text) RETURNS text
    LANGUAGE sql IMMUTABLE
    AS $$
SELECT CASE
    WHEN position(p_delimiter IN substring(p_key FROM length(p_prefix) + 1)) > 0
    THEN left(p_key, length(p_prefix) + position(p_delimiter IN substring(p_key FROM length(p_prefix) + 1)))
    ELSE NULL
END;
$$;


--
-- Name: get_size_by_bucket(); Type: FUNCTION; Schema: storage; Owner: -
--

CREATE FUNCTION storage.get_size_by_bucket() RETURNS TABLE(size bigint, bucket_id text)
    LANGUAGE plpgsql STABLE
    AS $$
BEGIN
    return query
        select sum((metadata->>'size')::bigint)::bigint as size, obj.bucket_id
        from "storage".objects as obj
        group by obj.bucket_id;
END
$$;


--
-- Name: list_multipart_uploads_with_delimiter(text, text, text, integer, text, text); Type: FUNCTION; Schema: storage; Owner: -
--

CREATE FUNCTION storage.list_multipart_uploads_with_delimiter(bucket_id text, prefix_param text, delimiter_param text, max_keys integer DEFAULT 100, next_key_token text DEFAULT ''::text, next_upload_token text DEFAULT ''::text) RETURNS TABLE(key text, id text, created_at timestamp with time zone)
    LANGUAGE plpgsql
    AS $_$
BEGIN
    RETURN QUERY EXECUTE
        'SELECT DISTINCT ON(key COLLATE "C") * from (
            SELECT
                CASE
                    WHEN position($2 IN substring(key from length($1) + 1)) > 0 THEN
                        substring(key from 1 for length($1) + position($2 IN substring(key from length($1) + 1)))
                    ELSE
                        key
                END AS key, id, created_at
            FROM
                storage.s3_multipart_uploads
            WHERE
                bucket_id = $5 AND
                key ILIKE $1 || ''%'' AND
                CASE
                    WHEN $4 != '''' AND $6 = '''' THEN
                        CASE
                            WHEN position($2 IN substring(key from length($1) + 1)) > 0 THEN
                                substring(key from 1 for length($1) + position($2 IN substring(key from length($1) + 1))) COLLATE "C" > $4
                            ELSE
                                key COLLATE "C" > $4
                            END
                    ELSE
                        true
                END AND
                CASE
                    WHEN $6 != '''' THEN
                        id COLLATE "C" > $6
                    ELSE
                        true
                    END
            ORDER BY
                key COLLATE "C" ASC, created_at ASC) as e order by key COLLATE "C" LIMIT $3'
        USING prefix_param, delimiter_param, max_keys, next_key_token, bucket_id, next_upload_token;
END;
$_$;


--
-- Name: list_objects_with_delimiter(text, text, text, integer, text, text, text); Type: FUNCTION; Schema: storage; Owner: -
--

CREATE FUNCTION storage.list_objects_with_delimiter(_bucket_id text, prefix_param text, delimiter_param text, max_keys integer DEFAULT 100, start_after text DEFAULT ''::text, next_token text DEFAULT ''::text, sort_order text DEFAULT 'asc'::text) RETURNS TABLE(name text, id uuid, metadata jsonb, updated_at timestamp with time zone, created_at timestamp with time zone, last_accessed_at timestamp with time zone)
    LANGUAGE plpgsql STABLE
    AS $_$
DECLARE
    v_peek_name TEXT;
    v_current RECORD;
    v_common_prefix TEXT;

    -- Configuration
    v_is_asc BOOLEAN;
    v_prefix TEXT;
    v_start TEXT;
    v_upper_bound TEXT;
    v_file_batch_size INT;

    -- Seek state
    v_next_seek TEXT;
    v_count INT := 0;

    -- Dynamic SQL for batch query only
    v_batch_query TEXT;

BEGIN
    -- ========================================================================
    -- INITIALIZATION
    -- ========================================================================
    v_is_asc := lower(coalesce(sort_order, 'asc')) = 'asc';
    v_prefix := coalesce(prefix_param, '');
    v_start := CASE WHEN coalesce(next_token, '') <> '' THEN next_token ELSE coalesce(start_after, '') END;
    v_file_batch_size := LEAST(GREATEST(max_keys * 2, 100), 1000);

    -- Calculate upper bound for prefix filtering (bytewise, using COLLATE "C")
    IF v_prefix = '' THEN
        v_upper_bound := NULL;
    ELSIF right(v_prefix, 1) = delimiter_param THEN
        v_upper_bound := left(v_prefix, -1) || chr(ascii(delimiter_param) + 1);
    ELSE
        v_upper_bound := left(v_prefix, -1) || chr(ascii(right(v_prefix, 1)) + 1);
    END IF;

    -- Build batch query (dynamic SQL - called infrequently, amortized over many rows)
    IF v_is_asc THEN
        IF v_upper_bound IS NOT NULL THEN
            v_batch_query := 'SELECT o.name, o.id, o.updated_at, o.created_at, o.last_accessed_at, o.metadata ' ||
                'FROM storage.objects o WHERE o.bucket_id = $1 AND o.name COLLATE "C" >= $2 ' ||
                'AND o.name COLLATE "C" < $3 ORDER BY o.name COLLATE "C" ASC LIMIT $4';
        ELSE
            v_batch_query := 'SELECT o.name, o.id, o.updated_at, o.created_at, o.last_accessed_at, o.metadata ' ||
                'FROM storage.objects o WHERE o.bucket_id = $1 AND o.name COLLATE "C" >= $2 ' ||
                'ORDER BY o.name COLLATE "C" ASC LIMIT $4';
        END IF;
    ELSE
        IF v_upper_bound IS NOT NULL THEN
            v_batch_query := 'SELECT o.name, o.id, o.updated_at, o.created_at, o.last_accessed_at, o.metadata ' ||
                'FROM storage.objects o WHERE o.bucket_id = $1 AND o.name COLLATE "C" < $2 ' ||
                'AND o.name COLLATE "C" >= $3 ORDER BY o.name COLLATE "C" DESC LIMIT $4';
        ELSE
            v_batch_query := 'SELECT o.name, o.id, o.updated_at, o.created_at, o.last_accessed_at, o.metadata ' ||
                'FROM storage.objects o WHERE o.bucket_id = $1 AND o.name COLLATE "C" < $2 ' ||
                'ORDER BY o.name COLLATE "C" DESC LIMIT $4';
        END IF;
    END IF;

    -- ========================================================================
    -- SEEK INITIALIZATION: Determine starting position
    -- ========================================================================
    IF v_start = '' THEN
        IF v_is_asc THEN
            v_next_seek := v_prefix;
        ELSE
            -- DESC without cursor: find the last item in range
            IF v_upper_bound IS NOT NULL THEN
                SELECT o.name INTO v_next_seek FROM storage.objects o
                WHERE o.bucket_id = _bucket_id AND o.name COLLATE "C" >= v_prefix AND o.name COLLATE "C" < v_upper_bound
                ORDER BY o.name COLLATE "C" DESC LIMIT 1;
            ELSIF v_prefix <> '' THEN
                SELECT o.name INTO v_next_seek FROM storage.objects o
                WHERE o.bucket_id = _bucket_id AND o.name COLLATE "C" >= v_prefix
                ORDER BY o.name COLLATE "C" DESC LIMIT 1;
            ELSE
                SELECT o.name INTO v_next_seek FROM storage.objects o
                WHERE o.bucket_id = _bucket_id
                ORDER BY o.name COLLATE "C" DESC LIMIT 1;
            END IF;

            IF v_next_seek IS NOT NULL THEN
                v_next_seek := v_next_seek || delimiter_param;
            ELSE
                RETURN;
            END IF;
        END IF;
    ELSE
        -- Cursor provided: determine if it refers to a folder or leaf
        IF EXISTS (
            SELECT 1 FROM storage.objects o
            WHERE o.bucket_id = _bucket_id
              AND o.name COLLATE "C" LIKE v_start || delimiter_param || '%'
            LIMIT 1
        ) THEN
            -- Cursor refers to a folder
            IF v_is_asc THEN
                v_next_seek := v_start || chr(ascii(delimiter_param) + 1);
            ELSE
                v_next_seek := v_start || delimiter_param;
            END IF;
        ELSE
            -- Cursor refers to a leaf object
            IF v_is_asc THEN
                v_next_seek := v_start || delimiter_param;
            ELSE
                v_next_seek := v_start;
            END IF;
        END IF;
    END IF;

    -- ========================================================================
    -- MAIN LOOP: Hybrid peek-then-batch algorithm
    -- Uses STATIC SQL for peek (hot path) and DYNAMIC SQL for batch
    -- ========================================================================
    LOOP
        EXIT WHEN v_count >= max_keys;

        -- STEP 1: PEEK using STATIC SQL (plan cached, very fast)
        IF v_is_asc THEN
            IF v_upper_bound IS NOT NULL THEN
                SELECT o.name INTO v_peek_name FROM storage.objects o
                WHERE o.bucket_id = _bucket_id AND o.name COLLATE "C" >= v_next_seek AND o.name COLLATE "C" < v_upper_bound
                ORDER BY o.name COLLATE "C" ASC LIMIT 1;
            ELSE
                SELECT o.name INTO v_peek_name FROM storage.objects o
                WHERE o.bucket_id = _bucket_id AND o.name COLLATE "C" >= v_next_seek
                ORDER BY o.name COLLATE "C" ASC LIMIT 1;
            END IF;
        ELSE
            IF v_upper_bound IS NOT NULL THEN
                SELECT o.name INTO v_peek_name FROM storage.objects o
                WHERE o.bucket_id = _bucket_id AND o.name COLLATE "C" < v_next_seek AND o.name COLLATE "C" >= v_prefix
                ORDER BY o.name COLLATE "C" DESC LIMIT 1;
            ELSIF v_prefix <> '' THEN
                SELECT o.name INTO v_peek_name FROM storage.objects o
                WHERE o.bucket_id = _bucket_id AND o.name COLLATE "C" < v_next_seek AND o.name COLLATE "C" >= v_prefix
                ORDER BY o.name COLLATE "C" DESC LIMIT 1;
            ELSE
                SELECT o.name INTO v_peek_name FROM storage.objects o
                WHERE o.bucket_id = _bucket_id AND o.name COLLATE "C" < v_next_seek
                ORDER BY o.name COLLATE "C" DESC LIMIT 1;
            END IF;
        END IF;

        EXIT WHEN v_peek_name IS NULL;

        -- STEP 2: Check if this is a FOLDER or FILE
        v_common_prefix := storage.get_common_prefix(v_peek_name, v_prefix, delimiter_param);

        IF v_common_prefix IS NOT NULL THEN
            -- FOLDER: Emit and skip to next folder (no heap access needed)
            name := rtrim(v_common_prefix, delimiter_param);
            id := NULL;
            updated_at := NULL;
            created_at := NULL;
            last_accessed_at := NULL;
            metadata := NULL;
            RETURN NEXT;
            v_count := v_count + 1;

            -- Advance seek past the folder range
            IF v_is_asc THEN
                v_next_seek := left(v_common_prefix, -1) || chr(ascii(delimiter_param) + 1);
            ELSE
                v_next_seek := v_common_prefix;
            END IF;
        ELSE
            -- FILE: Batch fetch using DYNAMIC SQL (overhead amortized over many rows)
            -- For ASC: upper_bound is the exclusive upper limit (< condition)
            -- For DESC: prefix is the inclusive lower limit (>= condition)
            FOR v_current IN EXECUTE v_batch_query USING _bucket_id, v_next_seek,
                CASE WHEN v_is_asc THEN COALESCE(v_upper_bound, v_prefix) ELSE v_prefix END, v_file_batch_size
            LOOP
                v_common_prefix := storage.get_common_prefix(v_current.name, v_prefix, delimiter_param);

                IF v_common_prefix IS NOT NULL THEN
                    -- Hit a folder: exit batch, let peek handle it
                    v_next_seek := v_current.name;
                    EXIT;
                END IF;

                -- Emit file
                name := v_current.name;
                id := v_current.id;
                updated_at := v_current.updated_at;
                created_at := v_current.created_at;
                last_accessed_at := v_current.last_accessed_at;
                metadata := v_current.metadata;
                RETURN NEXT;
                v_count := v_count + 1;

                -- Advance seek past this file
                IF v_is_asc THEN
                    v_next_seek := v_current.name || delimiter_param;
                ELSE
                    v_next_seek := v_current.name;
                END IF;

                EXIT WHEN v_count >= max_keys;
            END LOOP;
        END IF;
    END LOOP;
END;
$_$;


--
-- Name: operation(); Type: FUNCTION; Schema: storage; Owner: -
--

CREATE FUNCTION storage.operation() RETURNS text
    LANGUAGE plpgsql STABLE
    AS $$
BEGIN
    RETURN current_setting('storage.operation', true);
END;
$$;


--
-- Name: protect_delete(); Type: FUNCTION; Schema: storage; Owner: -
--

CREATE FUNCTION storage.protect_delete() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    -- Check if storage.allow_delete_query is set to 'true'
    IF COALESCE(current_setting('storage.allow_delete_query', true), 'false') != 'true' THEN
        RAISE EXCEPTION 'Direct deletion from storage tables is not allowed. Use the Storage API instead.'
            USING HINT = 'This prevents accidental data loss from orphaned objects.',
                  ERRCODE = '42501';
    END IF;
    RETURN NULL;
END;
$$;


--
-- Name: search(text, text, integer, integer, integer, text, text, text); Type: FUNCTION; Schema: storage; Owner: -
--

CREATE FUNCTION storage.search(prefix text, bucketname text, limits integer DEFAULT 100, levels integer DEFAULT 1, offsets integer DEFAULT 0, search text DEFAULT ''::text, sortcolumn text DEFAULT 'name'::text, sortorder text DEFAULT 'asc'::text) RETURNS TABLE(name text, id uuid, updated_at timestamp with time zone, created_at timestamp with time zone, last_accessed_at timestamp with time zone, metadata jsonb)
    LANGUAGE plpgsql STABLE
    AS $_$
DECLARE
    v_peek_name TEXT;
    v_current RECORD;
    v_common_prefix TEXT;
    v_delimiter CONSTANT TEXT := '/';

    -- Configuration
    v_limit INT;
    v_prefix TEXT;
    v_prefix_lower TEXT;
    v_is_asc BOOLEAN;
    v_order_by TEXT;
    v_sort_order TEXT;
    v_upper_bound TEXT;
    v_file_batch_size INT;

    -- Dynamic SQL for batch query only
    v_batch_query TEXT;

    -- Seek state
    v_next_seek TEXT;
    v_count INT := 0;
    v_skipped INT := 0;
BEGIN
    -- ========================================================================
    -- INITIALIZATION
    -- ========================================================================
    v_limit := LEAST(coalesce(limits, 100), 1500);
    v_prefix := coalesce(prefix, '') || coalesce(search, '');
    v_prefix_lower := lower(v_prefix);
    v_is_asc := lower(coalesce(sortorder, 'asc')) = 'asc';
    v_file_batch_size := LEAST(GREATEST(v_limit * 2, 100), 1000);

    -- Validate sort column
    CASE lower(coalesce(sortcolumn, 'name'))
        WHEN 'name' THEN v_order_by := 'name';
        WHEN 'updated_at' THEN v_order_by := 'updated_at';
        WHEN 'created_at' THEN v_order_by := 'created_at';
        WHEN 'last_accessed_at' THEN v_order_by := 'last_accessed_at';
        ELSE v_order_by := 'name';
    END CASE;

    v_sort_order := CASE WHEN v_is_asc THEN 'asc' ELSE 'desc' END;

    -- ========================================================================
    -- NON-NAME SORTING: Use path_tokens approach (unchanged)
    -- ========================================================================
    IF v_order_by != 'name' THEN
        RETURN QUERY EXECUTE format(
            $sql$
            WITH folders AS (
                SELECT path_tokens[$1] AS folder
                FROM storage.objects
                WHERE objects.name ILIKE $2 || '%%'
                  AND bucket_id = $3
                  AND array_length(objects.path_tokens, 1) <> $1
                GROUP BY folder
                ORDER BY folder %s
            )
            (SELECT folder AS "name",
                   NULL::uuid AS id,
                   NULL::timestamptz AS updated_at,
                   NULL::timestamptz AS created_at,
                   NULL::timestamptz AS last_accessed_at,
                   NULL::jsonb AS metadata FROM folders)
            UNION ALL
            (SELECT path_tokens[$1] AS "name",
                   id, updated_at, created_at, last_accessed_at, metadata
             FROM storage.objects
             WHERE objects.name ILIKE $2 || '%%'
               AND bucket_id = $3
               AND array_length(objects.path_tokens, 1) = $1
             ORDER BY %I %s)
            LIMIT $4 OFFSET $5
            $sql$, v_sort_order, v_order_by, v_sort_order
        ) USING levels, v_prefix, bucketname, v_limit, offsets;
        RETURN;
    END IF;

    -- ========================================================================
    -- NAME SORTING: Hybrid skip-scan with batch optimization
    -- ========================================================================

    -- Calculate upper bound for prefix filtering
    IF v_prefix_lower = '' THEN
        v_upper_bound := NULL;
    ELSIF right(v_prefix_lower, 1) = v_delimiter THEN
        v_upper_bound := left(v_prefix_lower, -1) || chr(ascii(v_delimiter) + 1);
    ELSE
        v_upper_bound := left(v_prefix_lower, -1) || chr(ascii(right(v_prefix_lower, 1)) + 1);
    END IF;

    -- Build batch query (dynamic SQL - called infrequently, amortized over many rows)
    IF v_is_asc THEN
        IF v_upper_bound IS NOT NULL THEN
            v_batch_query := 'SELECT o.name, o.id, o.updated_at, o.created_at, o.last_accessed_at, o.metadata ' ||
                'FROM storage.objects o WHERE o.bucket_id = $1 AND lower(o.name) COLLATE "C" >= $2 ' ||
                'AND lower(o.name) COLLATE "C" < $3 ORDER BY lower(o.name) COLLATE "C" ASC LIMIT $4';
        ELSE
            v_batch_query := 'SELECT o.name, o.id, o.updated_at, o.created_at, o.last_accessed_at, o.metadata ' ||
                'FROM storage.objects o WHERE o.bucket_id = $1 AND lower(o.name) COLLATE "C" >= $2 ' ||
                'ORDER BY lower(o.name) COLLATE "C" ASC LIMIT $4';
        END IF;
    ELSE
        IF v_upper_bound IS NOT NULL THEN
            v_batch_query := 'SELECT o.name, o.id, o.updated_at, o.created_at, o.last_accessed_at, o.metadata ' ||
                'FROM storage.objects o WHERE o.bucket_id = $1 AND lower(o.name) COLLATE "C" < $2 ' ||
                'AND lower(o.name) COLLATE "C" >= $3 ORDER BY lower(o.name) COLLATE "C" DESC LIMIT $4';
        ELSE
            v_batch_query := 'SELECT o.name, o.id, o.updated_at, o.created_at, o.last_accessed_at, o.metadata ' ||
                'FROM storage.objects o WHERE o.bucket_id = $1 AND lower(o.name) COLLATE "C" < $2 ' ||
                'ORDER BY lower(o.name) COLLATE "C" DESC LIMIT $4';
        END IF;
    END IF;

    -- Initialize seek position
    IF v_is_asc THEN
        v_next_seek := v_prefix_lower;
    ELSE
        -- DESC: find the last item in range first (static SQL)
        IF v_upper_bound IS NOT NULL THEN
            SELECT o.name INTO v_peek_name FROM storage.objects o
            WHERE o.bucket_id = bucketname AND lower(o.name) COLLATE "C" >= v_prefix_lower AND lower(o.name) COLLATE "C" < v_upper_bound
            ORDER BY lower(o.name) COLLATE "C" DESC LIMIT 1;
        ELSIF v_prefix_lower <> '' THEN
            SELECT o.name INTO v_peek_name FROM storage.objects o
            WHERE o.bucket_id = bucketname AND lower(o.name) COLLATE "C" >= v_prefix_lower
            ORDER BY lower(o.name) COLLATE "C" DESC LIMIT 1;
        ELSE
            SELECT o.name INTO v_peek_name FROM storage.objects o
            WHERE o.bucket_id = bucketname
            ORDER BY lower(o.name) COLLATE "C" DESC LIMIT 1;
        END IF;

        IF v_peek_name IS NOT NULL THEN
            v_next_seek := lower(v_peek_name) || v_delimiter;
        ELSE
            RETURN;
        END IF;
    END IF;

    -- ========================================================================
    -- MAIN LOOP: Hybrid peek-then-batch algorithm
    -- Uses STATIC SQL for peek (hot path) and DYNAMIC SQL for batch
    -- ========================================================================
    LOOP
        EXIT WHEN v_count >= v_limit;

        -- STEP 1: PEEK using STATIC SQL (plan cached, very fast)
        IF v_is_asc THEN
            IF v_upper_bound IS NOT NULL THEN
                SELECT o.name INTO v_peek_name FROM storage.objects o
                WHERE o.bucket_id = bucketname AND lower(o.name) COLLATE "C" >= v_next_seek AND lower(o.name) COLLATE "C" < v_upper_bound
                ORDER BY lower(o.name) COLLATE "C" ASC LIMIT 1;
            ELSE
                SELECT o.name INTO v_peek_name FROM storage.objects o
                WHERE o.bucket_id = bucketname AND lower(o.name) COLLATE "C" >= v_next_seek
                ORDER BY lower(o.name) COLLATE "C" ASC LIMIT 1;
            END IF;
        ELSE
            IF v_upper_bound IS NOT NULL THEN
                SELECT o.name INTO v_peek_name FROM storage.objects o
                WHERE o.bucket_id = bucketname AND lower(o.name) COLLATE "C" < v_next_seek AND lower(o.name) COLLATE "C" >= v_prefix_lower
                ORDER BY lower(o.name) COLLATE "C" DESC LIMIT 1;
            ELSIF v_prefix_lower <> '' THEN
                SELECT o.name INTO v_peek_name FROM storage.objects o
                WHERE o.bucket_id = bucketname AND lower(o.name) COLLATE "C" < v_next_seek AND lower(o.name) COLLATE "C" >= v_prefix_lower
                ORDER BY lower(o.name) COLLATE "C" DESC LIMIT 1;
            ELSE
                SELECT o.name INTO v_peek_name FROM storage.objects o
                WHERE o.bucket_id = bucketname AND lower(o.name) COLLATE "C" < v_next_seek
                ORDER BY lower(o.name) COLLATE "C" DESC LIMIT 1;
            END IF;
        END IF;

        EXIT WHEN v_peek_name IS NULL;

        -- STEP 2: Check if this is a FOLDER or FILE
        v_common_prefix := storage.get_common_prefix(lower(v_peek_name), v_prefix_lower, v_delimiter);

        IF v_common_prefix IS NOT NULL THEN
            -- FOLDER: Handle offset, emit if needed, skip to next folder
            IF v_skipped < offsets THEN
                v_skipped := v_skipped + 1;
            ELSE
                name := split_part(rtrim(storage.get_common_prefix(v_peek_name, v_prefix, v_delimiter), v_delimiter), v_delimiter, levels);
                id := NULL;
                updated_at := NULL;
                created_at := NULL;
                last_accessed_at := NULL;
                metadata := NULL;
                RETURN NEXT;
                v_count := v_count + 1;
            END IF;

            -- Advance seek past the folder range
            IF v_is_asc THEN
                v_next_seek := lower(left(v_common_prefix, -1)) || chr(ascii(v_delimiter) + 1);
            ELSE
                v_next_seek := lower(v_common_prefix);
            END IF;
        ELSE
            -- FILE: Batch fetch using DYNAMIC SQL (overhead amortized over many rows)
            -- For ASC: upper_bound is the exclusive upper limit (< condition)
            -- For DESC: prefix_lower is the inclusive lower limit (>= condition)
            FOR v_current IN EXECUTE v_batch_query
                USING bucketname, v_next_seek,
                    CASE WHEN v_is_asc THEN COALESCE(v_upper_bound, v_prefix_lower) ELSE v_prefix_lower END, v_file_batch_size
            LOOP
                v_common_prefix := storage.get_common_prefix(lower(v_current.name), v_prefix_lower, v_delimiter);

                IF v_common_prefix IS NOT NULL THEN
                    -- Hit a folder: exit batch, let peek handle it
                    v_next_seek := lower(v_current.name);
                    EXIT;
                END IF;

                -- Handle offset skipping
                IF v_skipped < offsets THEN
                    v_skipped := v_skipped + 1;
                ELSE
                    -- Emit file
                    name := split_part(v_current.name, v_delimiter, levels);
                    id := v_current.id;
                    updated_at := v_current.updated_at;
                    created_at := v_current.created_at;
                    last_accessed_at := v_current.last_accessed_at;
                    metadata := v_current.metadata;
                    RETURN NEXT;
                    v_count := v_count + 1;
                END IF;

                -- Advance seek past this file
                IF v_is_asc THEN
                    v_next_seek := lower(v_current.name) || v_delimiter;
                ELSE
                    v_next_seek := lower(v_current.name);
                END IF;

                EXIT WHEN v_count >= v_limit;
            END LOOP;
        END IF;
    END LOOP;
END;
$_$;


--
-- Name: search_by_timestamp(text, text, integer, integer, text, text, text, text); Type: FUNCTION; Schema: storage; Owner: -
--

CREATE FUNCTION storage.search_by_timestamp(p_prefix text, p_bucket_id text, p_limit integer, p_level integer, p_start_after text, p_sort_order text, p_sort_column text, p_sort_column_after text) RETURNS TABLE(key text, name text, id uuid, updated_at timestamp with time zone, created_at timestamp with time zone, last_accessed_at timestamp with time zone, metadata jsonb)
    LANGUAGE plpgsql STABLE
    AS $_$
DECLARE
    v_cursor_op text;
    v_query text;
    v_prefix text;
BEGIN
    v_prefix := coalesce(p_prefix, '');

    IF p_sort_order = 'asc' THEN
        v_cursor_op := '>';
    ELSE
        v_cursor_op := '<';
    END IF;

    v_query := format($sql$
        WITH raw_objects AS (
            SELECT
                o.name AS obj_name,
                o.id AS obj_id,
                o.updated_at AS obj_updated_at,
                o.created_at AS obj_created_at,
                o.last_accessed_at AS obj_last_accessed_at,
                o.metadata AS obj_metadata,
                storage.get_common_prefix(o.name, $1, '/') AS common_prefix
            FROM storage.objects o
            WHERE o.bucket_id = $2
              AND o.name COLLATE "C" LIKE $1 || '%%'
        ),
        -- Aggregate common prefixes (folders)
        -- Both created_at and updated_at use MIN(obj_created_at) to match the old prefixes table behavior
        aggregated_prefixes AS (
            SELECT
                rtrim(common_prefix, '/') AS name,
                NULL::uuid AS id,
                MIN(obj_created_at) AS updated_at,
                MIN(obj_created_at) AS created_at,
                NULL::timestamptz AS last_accessed_at,
                NULL::jsonb AS metadata,
                TRUE AS is_prefix
            FROM raw_objects
            WHERE common_prefix IS NOT NULL
            GROUP BY common_prefix
        ),
        leaf_objects AS (
            SELECT
                obj_name AS name,
                obj_id AS id,
                obj_updated_at AS updated_at,
                obj_created_at AS created_at,
                obj_last_accessed_at AS last_accessed_at,
                obj_metadata AS metadata,
                FALSE AS is_prefix
            FROM raw_objects
            WHERE common_prefix IS NULL
        ),
        combined AS (
            SELECT * FROM aggregated_prefixes
            UNION ALL
            SELECT * FROM leaf_objects
        ),
        filtered AS (
            SELECT *
            FROM combined
            WHERE (
                $5 = ''
                OR ROW(
                    date_trunc('milliseconds', %I),
                    name COLLATE "C"
                ) %s ROW(
                    COALESCE(NULLIF($6, '')::timestamptz, 'epoch'::timestamptz),
                    $5
                )
            )
        )
        SELECT
            split_part(name, '/', $3) AS key,
            name,
            id,
            updated_at,
            created_at,
            last_accessed_at,
            metadata
        FROM filtered
        ORDER BY
            COALESCE(date_trunc('milliseconds', %I), 'epoch'::timestamptz) %s,
            name COLLATE "C" %s
        LIMIT $4
    $sql$,
        p_sort_column,
        v_cursor_op,
        p_sort_column,
        p_sort_order,
        p_sort_order
    );

    RETURN QUERY EXECUTE v_query
    USING v_prefix, p_bucket_id, p_level, p_limit, p_start_after, p_sort_column_after;
END;
$_$;


--
-- Name: search_v2(text, text, integer, integer, text, text, text, text); Type: FUNCTION; Schema: storage; Owner: -
--

CREATE FUNCTION storage.search_v2(prefix text, bucket_name text, limits integer DEFAULT 100, levels integer DEFAULT 1, start_after text DEFAULT ''::text, sort_order text DEFAULT 'asc'::text, sort_column text DEFAULT 'name'::text, sort_column_after text DEFAULT ''::text) RETURNS TABLE(key text, name text, id uuid, updated_at timestamp with time zone, created_at timestamp with time zone, last_accessed_at timestamp with time zone, metadata jsonb)
    LANGUAGE plpgsql STABLE
    AS $$
DECLARE
    v_sort_col text;
    v_sort_ord text;
    v_limit int;
BEGIN
    -- Cap limit to maximum of 1500 records
    v_limit := LEAST(coalesce(limits, 100), 1500);

    -- Validate and normalize sort_order
    v_sort_ord := lower(coalesce(sort_order, 'asc'));
    IF v_sort_ord NOT IN ('asc', 'desc') THEN
        v_sort_ord := 'asc';
    END IF;

    -- Validate and normalize sort_column
    v_sort_col := lower(coalesce(sort_column, 'name'));
    IF v_sort_col NOT IN ('name', 'updated_at', 'created_at') THEN
        v_sort_col := 'name';
    END IF;

    -- Route to appropriate implementation
    IF v_sort_col = 'name' THEN
        -- Use list_objects_with_delimiter for name sorting (most efficient: O(k * log n))
        RETURN QUERY
        SELECT
            split_part(l.name, '/', levels) AS key,
            l.name AS name,
            l.id,
            l.updated_at,
            l.created_at,
            l.last_accessed_at,
            l.metadata
        FROM storage.list_objects_with_delimiter(
            bucket_name,
            coalesce(prefix, ''),
            '/',
            v_limit,
            start_after,
            '',
            v_sort_ord
        ) l;
    ELSE
        -- Use aggregation approach for timestamp sorting
        -- Not efficient for large datasets but supports correct pagination
        RETURN QUERY SELECT * FROM storage.search_by_timestamp(
            prefix, bucket_name, v_limit, levels, start_after,
            v_sort_ord, v_sort_col, sort_column_after
        );
    END IF;
END;
$$;


--
-- Name: update_updated_at_column(); Type: FUNCTION; Schema: storage; Owner: -
--

CREATE FUNCTION storage.update_updated_at_column() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    NEW.updated_at = now();
    RETURN NEW; 
END;
$$;


SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: audit_log_entries; Type: TABLE; Schema: auth; Owner: -
--

CREATE TABLE auth.audit_log_entries (
    instance_id uuid,
    id uuid NOT NULL,
    payload json,
    created_at timestamp with time zone,
    ip_address character varying(64) DEFAULT ''::character varying NOT NULL
);


--
-- Name: TABLE audit_log_entries; Type: COMMENT; Schema: auth; Owner: -
--

COMMENT ON TABLE auth.audit_log_entries IS 'Auth: Audit trail for user actions.';


--
-- Name: custom_oauth_providers; Type: TABLE; Schema: auth; Owner: -
--

CREATE TABLE auth.custom_oauth_providers (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    provider_type text NOT NULL,
    identifier text NOT NULL,
    name text NOT NULL,
    client_id text NOT NULL,
    client_secret text NOT NULL,
    acceptable_client_ids text[] DEFAULT '{}'::text[] NOT NULL,
    scopes text[] DEFAULT '{}'::text[] NOT NULL,
    pkce_enabled boolean DEFAULT true NOT NULL,
    attribute_mapping jsonb DEFAULT '{}'::jsonb NOT NULL,
    authorization_params jsonb DEFAULT '{}'::jsonb NOT NULL,
    enabled boolean DEFAULT true NOT NULL,
    email_optional boolean DEFAULT false NOT NULL,
    issuer text,
    discovery_url text,
    skip_nonce_check boolean DEFAULT false NOT NULL,
    cached_discovery jsonb,
    discovery_cached_at timestamp with time zone,
    authorization_url text,
    token_url text,
    userinfo_url text,
    jwks_uri text,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT custom_oauth_providers_authorization_url_https CHECK (((authorization_url IS NULL) OR (authorization_url ~~ 'https://%'::text))),
    CONSTRAINT custom_oauth_providers_authorization_url_length CHECK (((authorization_url IS NULL) OR (char_length(authorization_url) <= 2048))),
    CONSTRAINT custom_oauth_providers_client_id_length CHECK (((char_length(client_id) >= 1) AND (char_length(client_id) <= 512))),
    CONSTRAINT custom_oauth_providers_discovery_url_length CHECK (((discovery_url IS NULL) OR (char_length(discovery_url) <= 2048))),
    CONSTRAINT custom_oauth_providers_identifier_format CHECK ((identifier ~ '^[a-z0-9][a-z0-9:-]{0,48}[a-z0-9]$'::text)),
    CONSTRAINT custom_oauth_providers_issuer_length CHECK (((issuer IS NULL) OR ((char_length(issuer) >= 1) AND (char_length(issuer) <= 2048)))),
    CONSTRAINT custom_oauth_providers_jwks_uri_https CHECK (((jwks_uri IS NULL) OR (jwks_uri ~~ 'https://%'::text))),
    CONSTRAINT custom_oauth_providers_jwks_uri_length CHECK (((jwks_uri IS NULL) OR (char_length(jwks_uri) <= 2048))),
    CONSTRAINT custom_oauth_providers_name_length CHECK (((char_length(name) >= 1) AND (char_length(name) <= 100))),
    CONSTRAINT custom_oauth_providers_oauth2_requires_endpoints CHECK (((provider_type <> 'oauth2'::text) OR ((authorization_url IS NOT NULL) AND (token_url IS NOT NULL) AND (userinfo_url IS NOT NULL)))),
    CONSTRAINT custom_oauth_providers_oidc_discovery_url_https CHECK (((provider_type <> 'oidc'::text) OR (discovery_url IS NULL) OR (discovery_url ~~ 'https://%'::text))),
    CONSTRAINT custom_oauth_providers_oidc_issuer_https CHECK (((provider_type <> 'oidc'::text) OR (issuer IS NULL) OR (issuer ~~ 'https://%'::text))),
    CONSTRAINT custom_oauth_providers_oidc_requires_issuer CHECK (((provider_type <> 'oidc'::text) OR (issuer IS NOT NULL))),
    CONSTRAINT custom_oauth_providers_provider_type_check CHECK ((provider_type = ANY (ARRAY['oauth2'::text, 'oidc'::text]))),
    CONSTRAINT custom_oauth_providers_token_url_https CHECK (((token_url IS NULL) OR (token_url ~~ 'https://%'::text))),
    CONSTRAINT custom_oauth_providers_token_url_length CHECK (((token_url IS NULL) OR (char_length(token_url) <= 2048))),
    CONSTRAINT custom_oauth_providers_userinfo_url_https CHECK (((userinfo_url IS NULL) OR (userinfo_url ~~ 'https://%'::text))),
    CONSTRAINT custom_oauth_providers_userinfo_url_length CHECK (((userinfo_url IS NULL) OR (char_length(userinfo_url) <= 2048)))
);


--
-- Name: flow_state; Type: TABLE; Schema: auth; Owner: -
--

CREATE TABLE auth.flow_state (
    id uuid NOT NULL,
    user_id uuid,
    auth_code text,
    code_challenge_method auth.code_challenge_method,
    code_challenge text,
    provider_type text NOT NULL,
    provider_access_token text,
    provider_refresh_token text,
    created_at timestamp with time zone,
    updated_at timestamp with time zone,
    authentication_method text NOT NULL,
    auth_code_issued_at timestamp with time zone,
    invite_token text,
    referrer text,
    oauth_client_state_id uuid,
    linking_target_id uuid,
    email_optional boolean DEFAULT false NOT NULL
);


--
-- Name: TABLE flow_state; Type: COMMENT; Schema: auth; Owner: -
--

COMMENT ON TABLE auth.flow_state IS 'Stores metadata for all OAuth/SSO login flows';


--
-- Name: identities; Type: TABLE; Schema: auth; Owner: -
--

CREATE TABLE auth.identities (
    provider_id text NOT NULL,
    user_id uuid NOT NULL,
    identity_data jsonb NOT NULL,
    provider text NOT NULL,
    last_sign_in_at timestamp with time zone,
    created_at timestamp with time zone,
    updated_at timestamp with time zone,
    email text GENERATED ALWAYS AS (lower((identity_data ->> 'email'::text))) STORED,
    id uuid DEFAULT gen_random_uuid() NOT NULL
);


--
-- Name: TABLE identities; Type: COMMENT; Schema: auth; Owner: -
--

COMMENT ON TABLE auth.identities IS 'Auth: Stores identities associated to a user.';


--
-- Name: COLUMN identities.email; Type: COMMENT; Schema: auth; Owner: -
--

COMMENT ON COLUMN auth.identities.email IS 'Auth: Email is a generated column that references the optional email property in the identity_data';


--
-- Name: instances; Type: TABLE; Schema: auth; Owner: -
--

CREATE TABLE auth.instances (
    id uuid NOT NULL,
    uuid uuid,
    raw_base_config text,
    created_at timestamp with time zone,
    updated_at timestamp with time zone
);


--
-- Name: TABLE instances; Type: COMMENT; Schema: auth; Owner: -
--

COMMENT ON TABLE auth.instances IS 'Auth: Manages users across multiple sites.';


--
-- Name: mfa_amr_claims; Type: TABLE; Schema: auth; Owner: -
--

CREATE TABLE auth.mfa_amr_claims (
    session_id uuid NOT NULL,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL,
    authentication_method text NOT NULL,
    id uuid NOT NULL
);


--
-- Name: TABLE mfa_amr_claims; Type: COMMENT; Schema: auth; Owner: -
--

COMMENT ON TABLE auth.mfa_amr_claims IS 'auth: stores authenticator method reference claims for multi factor authentication';


--
-- Name: mfa_challenges; Type: TABLE; Schema: auth; Owner: -
--

CREATE TABLE auth.mfa_challenges (
    id uuid NOT NULL,
    factor_id uuid NOT NULL,
    created_at timestamp with time zone NOT NULL,
    verified_at timestamp with time zone,
    ip_address inet NOT NULL,
    otp_code text,
    web_authn_session_data jsonb
);


--
-- Name: TABLE mfa_challenges; Type: COMMENT; Schema: auth; Owner: -
--

COMMENT ON TABLE auth.mfa_challenges IS 'auth: stores metadata about challenge requests made';


--
-- Name: mfa_factors; Type: TABLE; Schema: auth; Owner: -
--

CREATE TABLE auth.mfa_factors (
    id uuid NOT NULL,
    user_id uuid NOT NULL,
    friendly_name text,
    factor_type auth.factor_type NOT NULL,
    status auth.factor_status NOT NULL,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL,
    secret text,
    phone text,
    last_challenged_at timestamp with time zone,
    web_authn_credential jsonb,
    web_authn_aaguid uuid,
    last_webauthn_challenge_data jsonb
);


--
-- Name: TABLE mfa_factors; Type: COMMENT; Schema: auth; Owner: -
--

COMMENT ON TABLE auth.mfa_factors IS 'auth: stores metadata about factors';


--
-- Name: COLUMN mfa_factors.last_webauthn_challenge_data; Type: COMMENT; Schema: auth; Owner: -
--

COMMENT ON COLUMN auth.mfa_factors.last_webauthn_challenge_data IS 'Stores the latest WebAuthn challenge data including attestation/assertion for customer verification';


--
-- Name: oauth_authorizations; Type: TABLE; Schema: auth; Owner: -
--

CREATE TABLE auth.oauth_authorizations (
    id uuid NOT NULL,
    authorization_id text NOT NULL,
    client_id uuid NOT NULL,
    user_id uuid,
    redirect_uri text NOT NULL,
    scope text NOT NULL,
    state text,
    resource text,
    code_challenge text,
    code_challenge_method auth.code_challenge_method,
    response_type auth.oauth_response_type DEFAULT 'code'::auth.oauth_response_type NOT NULL,
    status auth.oauth_authorization_status DEFAULT 'pending'::auth.oauth_authorization_status NOT NULL,
    authorization_code text,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    expires_at timestamp with time zone DEFAULT (now() + '00:03:00'::interval) NOT NULL,
    approved_at timestamp with time zone,
    nonce text,
    CONSTRAINT oauth_authorizations_authorization_code_length CHECK ((char_length(authorization_code) <= 255)),
    CONSTRAINT oauth_authorizations_code_challenge_length CHECK ((char_length(code_challenge) <= 128)),
    CONSTRAINT oauth_authorizations_expires_at_future CHECK ((expires_at > created_at)),
    CONSTRAINT oauth_authorizations_nonce_length CHECK ((char_length(nonce) <= 255)),
    CONSTRAINT oauth_authorizations_redirect_uri_length CHECK ((char_length(redirect_uri) <= 2048)),
    CONSTRAINT oauth_authorizations_resource_length CHECK ((char_length(resource) <= 2048)),
    CONSTRAINT oauth_authorizations_scope_length CHECK ((char_length(scope) <= 4096)),
    CONSTRAINT oauth_authorizations_state_length CHECK ((char_length(state) <= 4096))
);


--
-- Name: oauth_client_states; Type: TABLE; Schema: auth; Owner: -
--

CREATE TABLE auth.oauth_client_states (
    id uuid NOT NULL,
    provider_type text NOT NULL,
    code_verifier text,
    created_at timestamp with time zone NOT NULL
);


--
-- Name: TABLE oauth_client_states; Type: COMMENT; Schema: auth; Owner: -
--

COMMENT ON TABLE auth.oauth_client_states IS 'Stores OAuth states for third-party provider authentication flows where Supabase acts as the OAuth client.';


--
-- Name: oauth_clients; Type: TABLE; Schema: auth; Owner: -
--

CREATE TABLE auth.oauth_clients (
    id uuid NOT NULL,
    client_secret_hash text,
    registration_type auth.oauth_registration_type NOT NULL,
    redirect_uris text NOT NULL,
    grant_types text NOT NULL,
    client_name text,
    client_uri text,
    logo_uri text,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone,
    client_type auth.oauth_client_type DEFAULT 'confidential'::auth.oauth_client_type NOT NULL,
    token_endpoint_auth_method text NOT NULL,
    CONSTRAINT oauth_clients_client_name_length CHECK ((char_length(client_name) <= 1024)),
    CONSTRAINT oauth_clients_client_uri_length CHECK ((char_length(client_uri) <= 2048)),
    CONSTRAINT oauth_clients_logo_uri_length CHECK ((char_length(logo_uri) <= 2048)),
    CONSTRAINT oauth_clients_token_endpoint_auth_method_check CHECK ((token_endpoint_auth_method = ANY (ARRAY['client_secret_basic'::text, 'client_secret_post'::text, 'none'::text])))
);


--
-- Name: oauth_consents; Type: TABLE; Schema: auth; Owner: -
--

CREATE TABLE auth.oauth_consents (
    id uuid NOT NULL,
    user_id uuid NOT NULL,
    client_id uuid NOT NULL,
    scopes text NOT NULL,
    granted_at timestamp with time zone DEFAULT now() NOT NULL,
    revoked_at timestamp with time zone,
    CONSTRAINT oauth_consents_revoked_after_granted CHECK (((revoked_at IS NULL) OR (revoked_at >= granted_at))),
    CONSTRAINT oauth_consents_scopes_length CHECK ((char_length(scopes) <= 2048)),
    CONSTRAINT oauth_consents_scopes_not_empty CHECK ((char_length(TRIM(BOTH FROM scopes)) > 0))
);


--
-- Name: one_time_tokens; Type: TABLE; Schema: auth; Owner: -
--

CREATE TABLE auth.one_time_tokens (
    id uuid NOT NULL,
    user_id uuid NOT NULL,
    token_type auth.one_time_token_type NOT NULL,
    token_hash text NOT NULL,
    relates_to text NOT NULL,
    created_at timestamp without time zone DEFAULT now() NOT NULL,
    updated_at timestamp without time zone DEFAULT now() NOT NULL,
    CONSTRAINT one_time_tokens_token_hash_check CHECK ((char_length(token_hash) > 0))
);


--
-- Name: refresh_tokens; Type: TABLE; Schema: auth; Owner: -
--

CREATE TABLE auth.refresh_tokens (
    instance_id uuid,
    id bigint NOT NULL,
    token character varying(255),
    user_id character varying(255),
    revoked boolean,
    created_at timestamp with time zone,
    updated_at timestamp with time zone,
    parent character varying(255),
    session_id uuid
);


--
-- Name: TABLE refresh_tokens; Type: COMMENT; Schema: auth; Owner: -
--

COMMENT ON TABLE auth.refresh_tokens IS 'Auth: Store of tokens used to refresh JWT tokens once they expire.';


--
-- Name: refresh_tokens_id_seq; Type: SEQUENCE; Schema: auth; Owner: -
--

CREATE SEQUENCE auth.refresh_tokens_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: refresh_tokens_id_seq; Type: SEQUENCE OWNED BY; Schema: auth; Owner: -
--

ALTER SEQUENCE auth.refresh_tokens_id_seq OWNED BY auth.refresh_tokens.id;


--
-- Name: saml_providers; Type: TABLE; Schema: auth; Owner: -
--

CREATE TABLE auth.saml_providers (
    id uuid NOT NULL,
    sso_provider_id uuid NOT NULL,
    entity_id text NOT NULL,
    metadata_xml text NOT NULL,
    metadata_url text,
    attribute_mapping jsonb,
    created_at timestamp with time zone,
    updated_at timestamp with time zone,
    name_id_format text,
    CONSTRAINT "entity_id not empty" CHECK ((char_length(entity_id) > 0)),
    CONSTRAINT "metadata_url not empty" CHECK (((metadata_url = NULL::text) OR (char_length(metadata_url) > 0))),
    CONSTRAINT "metadata_xml not empty" CHECK ((char_length(metadata_xml) > 0))
);


--
-- Name: TABLE saml_providers; Type: COMMENT; Schema: auth; Owner: -
--

COMMENT ON TABLE auth.saml_providers IS 'Auth: Manages SAML Identity Provider connections.';


--
-- Name: saml_relay_states; Type: TABLE; Schema: auth; Owner: -
--

CREATE TABLE auth.saml_relay_states (
    id uuid NOT NULL,
    sso_provider_id uuid NOT NULL,
    request_id text NOT NULL,
    for_email text,
    redirect_to text,
    created_at timestamp with time zone,
    updated_at timestamp with time zone,
    flow_state_id uuid,
    CONSTRAINT "request_id not empty" CHECK ((char_length(request_id) > 0))
);


--
-- Name: TABLE saml_relay_states; Type: COMMENT; Schema: auth; Owner: -
--

COMMENT ON TABLE auth.saml_relay_states IS 'Auth: Contains SAML Relay State information for each Service Provider initiated login.';


--
-- Name: schema_migrations; Type: TABLE; Schema: auth; Owner: -
--

CREATE TABLE auth.schema_migrations (
    version character varying(255) NOT NULL
);


--
-- Name: TABLE schema_migrations; Type: COMMENT; Schema: auth; Owner: -
--

COMMENT ON TABLE auth.schema_migrations IS 'Auth: Manages updates to the auth system.';


--
-- Name: sessions; Type: TABLE; Schema: auth; Owner: -
--

CREATE TABLE auth.sessions (
    id uuid NOT NULL,
    user_id uuid NOT NULL,
    created_at timestamp with time zone,
    updated_at timestamp with time zone,
    factor_id uuid,
    aal auth.aal_level,
    not_after timestamp with time zone,
    refreshed_at timestamp without time zone,
    user_agent text,
    ip inet,
    tag text,
    oauth_client_id uuid,
    refresh_token_hmac_key text,
    refresh_token_counter bigint,
    scopes text,
    CONSTRAINT sessions_scopes_length CHECK ((char_length(scopes) <= 4096))
);


--
-- Name: TABLE sessions; Type: COMMENT; Schema: auth; Owner: -
--

COMMENT ON TABLE auth.sessions IS 'Auth: Stores session data associated to a user.';


--
-- Name: COLUMN sessions.not_after; Type: COMMENT; Schema: auth; Owner: -
--

COMMENT ON COLUMN auth.sessions.not_after IS 'Auth: Not after is a nullable column that contains a timestamp after which the session should be regarded as expired.';


--
-- Name: COLUMN sessions.refresh_token_hmac_key; Type: COMMENT; Schema: auth; Owner: -
--

COMMENT ON COLUMN auth.sessions.refresh_token_hmac_key IS 'Holds a HMAC-SHA256 key used to sign refresh tokens for this session.';


--
-- Name: COLUMN sessions.refresh_token_counter; Type: COMMENT; Schema: auth; Owner: -
--

COMMENT ON COLUMN auth.sessions.refresh_token_counter IS 'Holds the ID (counter) of the last issued refresh token.';


--
-- Name: sso_domains; Type: TABLE; Schema: auth; Owner: -
--

CREATE TABLE auth.sso_domains (
    id uuid NOT NULL,
    sso_provider_id uuid NOT NULL,
    domain text NOT NULL,
    created_at timestamp with time zone,
    updated_at timestamp with time zone,
    CONSTRAINT "domain not empty" CHECK ((char_length(domain) > 0))
);


--
-- Name: TABLE sso_domains; Type: COMMENT; Schema: auth; Owner: -
--

COMMENT ON TABLE auth.sso_domains IS 'Auth: Manages SSO email address domain mapping to an SSO Identity Provider.';


--
-- Name: sso_providers; Type: TABLE; Schema: auth; Owner: -
--

CREATE TABLE auth.sso_providers (
    id uuid NOT NULL,
    resource_id text,
    created_at timestamp with time zone,
    updated_at timestamp with time zone,
    disabled boolean,
    CONSTRAINT "resource_id not empty" CHECK (((resource_id = NULL::text) OR (char_length(resource_id) > 0)))
);


--
-- Name: TABLE sso_providers; Type: COMMENT; Schema: auth; Owner: -
--

COMMENT ON TABLE auth.sso_providers IS 'Auth: Manages SSO identity provider information; see saml_providers for SAML.';


--
-- Name: COLUMN sso_providers.resource_id; Type: COMMENT; Schema: auth; Owner: -
--

COMMENT ON COLUMN auth.sso_providers.resource_id IS 'Auth: Uniquely identifies a SSO provider according to a user-chosen resource ID (case insensitive), useful in infrastructure as code.';


--
-- Name: users; Type: TABLE; Schema: auth; Owner: -
--

CREATE TABLE auth.users (
    instance_id uuid,
    id uuid NOT NULL,
    aud character varying(255),
    role character varying(255),
    email character varying(255),
    encrypted_password character varying(255),
    email_confirmed_at timestamp with time zone,
    invited_at timestamp with time zone,
    confirmation_token character varying(255),
    confirmation_sent_at timestamp with time zone,
    recovery_token character varying(255),
    recovery_sent_at timestamp with time zone,
    email_change_token_new character varying(255),
    email_change character varying(255),
    email_change_sent_at timestamp with time zone,
    last_sign_in_at timestamp with time zone,
    raw_app_meta_data jsonb,
    raw_user_meta_data jsonb,
    is_super_admin boolean,
    created_at timestamp with time zone,
    updated_at timestamp with time zone,
    phone text DEFAULT NULL::character varying,
    phone_confirmed_at timestamp with time zone,
    phone_change text DEFAULT ''::character varying,
    phone_change_token character varying(255) DEFAULT ''::character varying,
    phone_change_sent_at timestamp with time zone,
    confirmed_at timestamp with time zone GENERATED ALWAYS AS (LEAST(email_confirmed_at, phone_confirmed_at)) STORED,
    email_change_token_current character varying(255) DEFAULT ''::character varying,
    email_change_confirm_status smallint DEFAULT 0,
    banned_until timestamp with time zone,
    reauthentication_token character varying(255) DEFAULT ''::character varying,
    reauthentication_sent_at timestamp with time zone,
    is_sso_user boolean DEFAULT false NOT NULL,
    deleted_at timestamp with time zone,
    is_anonymous boolean DEFAULT false NOT NULL,
    CONSTRAINT users_email_change_confirm_status_check CHECK (((email_change_confirm_status >= 0) AND (email_change_confirm_status <= 2)))
);


--
-- Name: TABLE users; Type: COMMENT; Schema: auth; Owner: -
--

COMMENT ON TABLE auth.users IS 'Auth: Stores user login data within a secure schema.';


--
-- Name: COLUMN users.is_sso_user; Type: COMMENT; Schema: auth; Owner: -
--

COMMENT ON COLUMN auth.users.is_sso_user IS 'Auth: Set this column to true when the account comes from SSO. These accounts can have duplicate emails.';


--
-- Name: webauthn_challenges; Type: TABLE; Schema: auth; Owner: -
--

CREATE TABLE auth.webauthn_challenges (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    user_id uuid,
    challenge_type text NOT NULL,
    session_data jsonb NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    expires_at timestamp with time zone NOT NULL,
    CONSTRAINT webauthn_challenges_challenge_type_check CHECK ((challenge_type = ANY (ARRAY['signup'::text, 'registration'::text, 'authentication'::text])))
);


--
-- Name: webauthn_credentials; Type: TABLE; Schema: auth; Owner: -
--

CREATE TABLE auth.webauthn_credentials (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    user_id uuid NOT NULL,
    credential_id bytea NOT NULL,
    public_key bytea NOT NULL,
    attestation_type text DEFAULT ''::text NOT NULL,
    aaguid uuid,
    sign_count bigint DEFAULT 0 NOT NULL,
    transports jsonb DEFAULT '[]'::jsonb NOT NULL,
    backup_eligible boolean DEFAULT false NOT NULL,
    backed_up boolean DEFAULT false NOT NULL,
    friendly_name text DEFAULT ''::text NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    last_used_at timestamp with time zone
);


--
-- Name: alojamentos; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.alojamentos (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    nome text NOT NULL,
    endereco text,
    obra_id uuid,
    vagas_total integer DEFAULT 1,
    imobiliaria text,
    contato_imobiliaria text,
    custo_mensal numeric(10,2),
    condominio numeric(10,2),
    iptu numeric(10,2),
    seguro numeric(10,2),
    data_inicio date,
    data_termino date,
    isencao_meses integer,
    indice_reajuste text DEFAULT 'IVAR'::text,
    observacoes text,
    contrato_url text,
    laudo_url text,
    fotos_url text,
    criado_em timestamp with time zone DEFAULT now(),
    caucao numeric DEFAULT 0,
    proprietario text,
    contato_proprietario text,
    moradores_avulsos jsonb DEFAULT '[]'::jsonb,
    isenta_agua boolean DEFAULT false,
    isenta_energia boolean DEFAULT false,
    isenta_gas boolean DEFAULT false,
    isenta_condominio boolean DEFAULT false
);


--
-- Name: alojamentos_contas; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.alojamentos_contas (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    alojamento_id uuid,
    mes integer NOT NULL,
    ano integer NOT NULL,
    tipo text NOT NULL,
    valor numeric(10,2) NOT NULL,
    observacao text,
    criado_em timestamp with time zone DEFAULT now(),
    adm35_numero text,
    adm35_envio date,
    CONSTRAINT alojamentos_contas_mes_check CHECK (((mes >= 1) AND (mes <= 12))),
    CONSTRAINT alojamentos_contas_tipo_check CHECK ((tipo = ANY (ARRAY['agua'::text, 'energia'::text, 'gas'::text, 'condominio'::text, 'outros'::text])))
);


--
-- Name: alojamentos_relatorios; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.alojamentos_relatorios (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    alojamento_id uuid,
    mes integer NOT NULL,
    ano integer NOT NULL,
    avaliador text,
    data_avaliacao date,
    data_recebimento date,
    observacoes text,
    created_at timestamp with time zone DEFAULT now()
);


--
-- Name: efetivo_he; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.efetivo_he (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    data date NOT NULL,
    periodo_ini date,
    matricula text NOT NULL,
    nome text NOT NULL,
    tipo text NOT NULL,
    mins integer DEFAULT 0,
    created_at timestamp with time zone DEFAULT now()
);


--
-- Name: efetivo_horas; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.efetivo_horas (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    data date NOT NULL,
    matricula text NOT NULL,
    nome text NOT NULL,
    departamento text,
    mins_a_trabalhar integer DEFAULT 0,
    mins_trabalhadas integer DEFAULT 0,
    mins_descontos integer DEFAULT 0,
    mins_justificadas integer DEFAULT 0,
    created_at timestamp with time zone DEFAULT now()
);


--
-- Name: efetivo_presenca; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.efetivo_presenca (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    data date NOT NULL,
    cracha character varying(20) NOT NULL,
    nome character varying(200),
    departamento character varying(200),
    horario_entrada character varying(10),
    marcacao character varying(20),
    situacao character varying(20) DEFAULT 'PRESENTE'::character varying,
    obra_id uuid,
    created_at timestamp with time zone DEFAULT now(),
    marcacoes text
);


--
-- Name: empresas; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.empresas (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    nome text NOT NULL,
    cnpj text,
    created_at timestamp without time zone DEFAULT now()
);


--
-- Name: ferias; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ferias (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    funcionario_id uuid,
    matricula text NOT NULL,
    periodo_aquisitivo_inicio date,
    periodo_aquisitivo_fim date,
    dt_limite_ideal date,
    dt_limite_maxima date,
    dias_direito numeric DEFAULT 30,
    dias_vencidos numeric DEFAULT 0,
    programado boolean DEFAULT false,
    data_inicio_programada date,
    data_fim_programada date,
    dias_programados integer,
    importado_em timestamp with time zone DEFAULT now(),
    validado_dp boolean DEFAULT false
);


--
-- Name: folgas; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.folgas (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    funcionario_id uuid,
    data_inicio date NOT NULL,
    periodo_trabalhado integer DEFAULT 90 NOT NULL,
    periodo_folga integer DEFAULT 5 NOT NULL,
    cidade_origem text,
    tipo_passagem text DEFAULT 'nao'::text,
    saida1_projecao date,
    saida1_real date,
    saida2_projecao date,
    saida2_real date,
    saida3_projecao date,
    saida3_real date,
    saida4_projecao date,
    saida4_real date,
    saida5_projecao date,
    saida5_real date,
    created_at timestamp with time zone DEFAULT now(),
    tipo_passagem_aerea boolean DEFAULT false,
    tipo_passagem_terrestre boolean DEFAULT false
);


--
-- Name: funcionarios; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.funcionarios (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    matricula text NOT NULL,
    nome_completo text NOT NULL,
    cpf text,
    ctps text,
    serie_ctps text,
    uf_ctps text,
    pis text,
    data_admissao date,
    situacao text,
    tipo text,
    funcao_id uuid,
    empresa_id uuid,
    obra_id uuid,
    cidade text,
    uf text,
    foto_url text,
    created_at timestamp without time zone DEFAULT now(),
    updated_at timestamp without time zone DEFAULT now(),
    transferido boolean DEFAULT false,
    data_transferencia date,
    obra_transferencia_id uuid,
    centro_custo_transferencia text,
    data_mobilizacao date,
    data_desmobilizacao date,
    funcao_manual text,
    tipo_transferencia text,
    periodo_experiencia integer DEFAULT 45,
    efetivado boolean DEFAULT false,
    observacao_interna text,
    alojamento_id uuid,
    CONSTRAINT funcionarios_situacao_check CHECK ((situacao = ANY (ARRAY['ativo'::text, 'inativo'::text, 'transferido'::text]))),
    CONSTRAINT funcionarios_tipo_check CHECK ((tipo = ANY (ARRAY['nova_admissao'::text, 'transferencia'::text, 'efetivo'::text])))
);


--
-- Name: funcoes; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.funcoes (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    nome text NOT NULL,
    created_at timestamp without time zone DEFAULT now()
);


--
-- Name: obras; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.obras (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    codigo text NOT NULL,
    nome text NOT NULL,
    cidade text,
    uf text,
    empresa_id uuid,
    created_at timestamp without time zone DEFAULT now(),
    centro_custo text
);


--
-- Name: prestadores; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.prestadores (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    obra_id uuid,
    razao_social text,
    cnpj text,
    nome_fantasia text,
    nome_completo text NOT NULL,
    funcao text,
    data_mobilizacao date,
    data_integracao date,
    alojamento_id uuid,
    situacao text DEFAULT 'ativo'::text,
    observacao text,
    created_at timestamp with time zone DEFAULT now(),
    foto_url text
);


--
-- Name: prestadores_presenca; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.prestadores_presenca (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    prestador_id uuid,
    data date NOT NULL,
    situacao text DEFAULT 'AUSENTE'::text
);


--
-- Name: usuarios_acesso; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.usuarios_acesso (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    nome text NOT NULL,
    usuario text NOT NULL,
    senha text NOT NULL,
    perfil text DEFAULT 'usuario'::text NOT NULL,
    obras_ids uuid[] DEFAULT '{}'::uuid[],
    ativo boolean DEFAULT true,
    criado_em timestamp with time zone DEFAULT now(),
    obras_acesso jsonb DEFAULT '[]'::jsonb
);


--
-- Name: messages; Type: TABLE; Schema: realtime; Owner: -
--

CREATE TABLE realtime.messages (
    topic text NOT NULL,
    extension text NOT NULL,
    payload jsonb,
    event text,
    private boolean DEFAULT false,
    updated_at timestamp without time zone DEFAULT now() NOT NULL,
    inserted_at timestamp without time zone DEFAULT now() NOT NULL,
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    binary_payload bytea
)
PARTITION BY RANGE (inserted_at);


--
-- Name: schema_migrations; Type: TABLE; Schema: realtime; Owner: -
--

CREATE TABLE realtime.schema_migrations (
    version bigint NOT NULL,
    inserted_at timestamp(0) without time zone
);


--
-- Name: subscription; Type: TABLE; Schema: realtime; Owner: -
--

CREATE TABLE realtime.subscription (
    id bigint NOT NULL,
    subscription_id uuid NOT NULL,
    entity regclass NOT NULL,
    filters realtime.user_defined_filter[] DEFAULT '{}'::realtime.user_defined_filter[] NOT NULL,
    claims jsonb NOT NULL,
    claims_role regrole GENERATED ALWAYS AS (realtime.to_regrole((claims ->> 'role'::text))) STORED NOT NULL,
    created_at timestamp without time zone DEFAULT timezone('utc'::text, now()) NOT NULL,
    action_filter text DEFAULT '*'::text,
    selected_columns text[],
    CONSTRAINT subscription_action_filter_check CHECK ((action_filter = ANY (ARRAY['*'::text, 'INSERT'::text, 'UPDATE'::text, 'DELETE'::text])))
);


--
-- Name: subscription_id_seq; Type: SEQUENCE; Schema: realtime; Owner: -
--

ALTER TABLE realtime.subscription ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME realtime.subscription_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: buckets; Type: TABLE; Schema: storage; Owner: -
--

CREATE TABLE storage.buckets (
    id text NOT NULL,
    name text NOT NULL,
    owner uuid,
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now(),
    public boolean DEFAULT false,
    avif_autodetection boolean DEFAULT false,
    file_size_limit bigint,
    allowed_mime_types text[],
    owner_id text,
    type storage.buckettype DEFAULT 'STANDARD'::storage.buckettype NOT NULL
);


--
-- Name: COLUMN buckets.owner; Type: COMMENT; Schema: storage; Owner: -
--

COMMENT ON COLUMN storage.buckets.owner IS 'Field is deprecated, use owner_id instead';


--
-- Name: buckets_analytics; Type: TABLE; Schema: storage; Owner: -
--

CREATE TABLE storage.buckets_analytics (
    name text NOT NULL,
    type storage.buckettype DEFAULT 'ANALYTICS'::storage.buckettype NOT NULL,
    format text DEFAULT 'ICEBERG'::text NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    deleted_at timestamp with time zone
);


--
-- Name: buckets_vectors; Type: TABLE; Schema: storage; Owner: -
--

CREATE TABLE storage.buckets_vectors (
    id text NOT NULL,
    type storage.buckettype DEFAULT 'VECTOR'::storage.buckettype NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: migrations; Type: TABLE; Schema: storage; Owner: -
--

CREATE TABLE storage.migrations (
    id integer NOT NULL,
    name character varying(100) NOT NULL,
    hash character varying(40) NOT NULL,
    executed_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


--
-- Name: objects; Type: TABLE; Schema: storage; Owner: -
--

CREATE TABLE storage.objects (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    bucket_id text,
    name text,
    owner uuid,
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now(),
    last_accessed_at timestamp with time zone DEFAULT now(),
    metadata jsonb,
    path_tokens text[] GENERATED ALWAYS AS (string_to_array(name, '/'::text)) STORED,
    version text,
    owner_id text,
    user_metadata jsonb
);


--
-- Name: COLUMN objects.owner; Type: COMMENT; Schema: storage; Owner: -
--

COMMENT ON COLUMN storage.objects.owner IS 'Field is deprecated, use owner_id instead';


--
-- Name: s3_multipart_uploads; Type: TABLE; Schema: storage; Owner: -
--

CREATE TABLE storage.s3_multipart_uploads (
    id text NOT NULL,
    in_progress_size bigint DEFAULT 0 NOT NULL,
    upload_signature text NOT NULL,
    bucket_id text NOT NULL,
    key text NOT NULL COLLATE pg_catalog."C",
    version text NOT NULL,
    owner_id text,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    user_metadata jsonb,
    metadata jsonb
);


--
-- Name: s3_multipart_uploads_parts; Type: TABLE; Schema: storage; Owner: -
--

CREATE TABLE storage.s3_multipart_uploads_parts (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    upload_id text NOT NULL,
    size bigint DEFAULT 0 NOT NULL,
    part_number integer NOT NULL,
    bucket_id text NOT NULL,
    key text NOT NULL COLLATE pg_catalog."C",
    etag text NOT NULL,
    owner_id text,
    version text NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: vector_indexes; Type: TABLE; Schema: storage; Owner: -
--

CREATE TABLE storage.vector_indexes (
    id text DEFAULT gen_random_uuid() NOT NULL,
    name text NOT NULL COLLATE pg_catalog."C",
    bucket_id text NOT NULL,
    data_type text NOT NULL,
    dimension integer NOT NULL,
    distance_metric text NOT NULL,
    metadata_configuration jsonb,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: refresh_tokens id; Type: DEFAULT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.refresh_tokens ALTER COLUMN id SET DEFAULT nextval('auth.refresh_tokens_id_seq'::regclass);


--
-- Data for Name: audit_log_entries; Type: TABLE DATA; Schema: auth; Owner: -
--

COPY auth.audit_log_entries (instance_id, id, payload, created_at, ip_address) FROM stdin;
\.


--
-- Data for Name: custom_oauth_providers; Type: TABLE DATA; Schema: auth; Owner: -
--

COPY auth.custom_oauth_providers (id, provider_type, identifier, name, client_id, client_secret, acceptable_client_ids, scopes, pkce_enabled, attribute_mapping, authorization_params, enabled, email_optional, issuer, discovery_url, skip_nonce_check, cached_discovery, discovery_cached_at, authorization_url, token_url, userinfo_url, jwks_uri, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: flow_state; Type: TABLE DATA; Schema: auth; Owner: -
--

COPY auth.flow_state (id, user_id, auth_code, code_challenge_method, code_challenge, provider_type, provider_access_token, provider_refresh_token, created_at, updated_at, authentication_method, auth_code_issued_at, invite_token, referrer, oauth_client_state_id, linking_target_id, email_optional) FROM stdin;
\.


--
-- Data for Name: identities; Type: TABLE DATA; Schema: auth; Owner: -
--

COPY auth.identities (provider_id, user_id, identity_data, provider, last_sign_in_at, created_at, updated_at, id) FROM stdin;
\.


--
-- Data for Name: instances; Type: TABLE DATA; Schema: auth; Owner: -
--

COPY auth.instances (id, uuid, raw_base_config, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: mfa_amr_claims; Type: TABLE DATA; Schema: auth; Owner: -
--

COPY auth.mfa_amr_claims (session_id, created_at, updated_at, authentication_method, id) FROM stdin;
\.


--
-- Data for Name: mfa_challenges; Type: TABLE DATA; Schema: auth; Owner: -
--

COPY auth.mfa_challenges (id, factor_id, created_at, verified_at, ip_address, otp_code, web_authn_session_data) FROM stdin;
\.


--
-- Data for Name: mfa_factors; Type: TABLE DATA; Schema: auth; Owner: -
--

COPY auth.mfa_factors (id, user_id, friendly_name, factor_type, status, created_at, updated_at, secret, phone, last_challenged_at, web_authn_credential, web_authn_aaguid, last_webauthn_challenge_data) FROM stdin;
\.


--
-- Data for Name: oauth_authorizations; Type: TABLE DATA; Schema: auth; Owner: -
--

COPY auth.oauth_authorizations (id, authorization_id, client_id, user_id, redirect_uri, scope, state, resource, code_challenge, code_challenge_method, response_type, status, authorization_code, created_at, expires_at, approved_at, nonce) FROM stdin;
\.


--
-- Data for Name: oauth_client_states; Type: TABLE DATA; Schema: auth; Owner: -
--

COPY auth.oauth_client_states (id, provider_type, code_verifier, created_at) FROM stdin;
\.


--
-- Data for Name: oauth_clients; Type: TABLE DATA; Schema: auth; Owner: -
--

COPY auth.oauth_clients (id, client_secret_hash, registration_type, redirect_uris, grant_types, client_name, client_uri, logo_uri, created_at, updated_at, deleted_at, client_type, token_endpoint_auth_method) FROM stdin;
\.


--
-- Data for Name: oauth_consents; Type: TABLE DATA; Schema: auth; Owner: -
--

COPY auth.oauth_consents (id, user_id, client_id, scopes, granted_at, revoked_at) FROM stdin;
\.


--
-- Data for Name: one_time_tokens; Type: TABLE DATA; Schema: auth; Owner: -
--

COPY auth.one_time_tokens (id, user_id, token_type, token_hash, relates_to, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: refresh_tokens; Type: TABLE DATA; Schema: auth; Owner: -
--

COPY auth.refresh_tokens (instance_id, id, token, user_id, revoked, created_at, updated_at, parent, session_id) FROM stdin;
\.


--
-- Data for Name: saml_providers; Type: TABLE DATA; Schema: auth; Owner: -
--

COPY auth.saml_providers (id, sso_provider_id, entity_id, metadata_xml, metadata_url, attribute_mapping, created_at, updated_at, name_id_format) FROM stdin;
\.


--
-- Data for Name: saml_relay_states; Type: TABLE DATA; Schema: auth; Owner: -
--

COPY auth.saml_relay_states (id, sso_provider_id, request_id, for_email, redirect_to, created_at, updated_at, flow_state_id) FROM stdin;
\.


--
-- Data for Name: schema_migrations; Type: TABLE DATA; Schema: auth; Owner: -
--

COPY auth.schema_migrations (version) FROM stdin;
20171026211738
20171026211808
20171026211834
20180103212743
20180108183307
20180119214651
20180125194653
00
20210710035447
20210722035447
20210730183235
20210909172000
20210927181326
20211122151130
20211124214934
20211202183645
20220114185221
20220114185340
20220224000811
20220323170000
20220429102000
20220531120530
20220614074223
20220811173540
20221003041349
20221003041400
20221011041400
20221020193600
20221021073300
20221021082433
20221027105023
20221114143122
20221114143410
20221125140132
20221208132122
20221215195500
20221215195800
20221215195900
20230116124310
20230116124412
20230131181311
20230322519590
20230402418590
20230411005111
20230508135423
20230523124323
20230818113222
20230914180801
20231027141322
20231114161723
20231117164230
20240115144230
20240214120130
20240306115329
20240314092811
20240427152123
20240612123726
20240729123726
20240802193726
20240806073726
20241009103726
20250717082212
20250731150234
20250804100000
20250901200500
20250903112500
20250904133000
20250925093508
20251007112900
20251104100000
20251111201300
20251201000000
20260115000000
20260121000000
20260219120000
20260302000000
\.


--
-- Data for Name: sessions; Type: TABLE DATA; Schema: auth; Owner: -
--

COPY auth.sessions (id, user_id, created_at, updated_at, factor_id, aal, not_after, refreshed_at, user_agent, ip, tag, oauth_client_id, refresh_token_hmac_key, refresh_token_counter, scopes) FROM stdin;
\.


--
-- Data for Name: sso_domains; Type: TABLE DATA; Schema: auth; Owner: -
--

COPY auth.sso_domains (id, sso_provider_id, domain, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: sso_providers; Type: TABLE DATA; Schema: auth; Owner: -
--

COPY auth.sso_providers (id, resource_id, created_at, updated_at, disabled) FROM stdin;
\.


--
-- Data for Name: users; Type: TABLE DATA; Schema: auth; Owner: -
--

COPY auth.users (instance_id, id, aud, role, email, encrypted_password, email_confirmed_at, invited_at, confirmation_token, confirmation_sent_at, recovery_token, recovery_sent_at, email_change_token_new, email_change, email_change_sent_at, last_sign_in_at, raw_app_meta_data, raw_user_meta_data, is_super_admin, created_at, updated_at, phone, phone_confirmed_at, phone_change, phone_change_token, phone_change_sent_at, email_change_token_current, email_change_confirm_status, banned_until, reauthentication_token, reauthentication_sent_at, is_sso_user, deleted_at, is_anonymous) FROM stdin;
\.


--
-- Data for Name: webauthn_challenges; Type: TABLE DATA; Schema: auth; Owner: -
--

COPY auth.webauthn_challenges (id, user_id, challenge_type, session_data, created_at, expires_at) FROM stdin;
\.


--
-- Data for Name: webauthn_credentials; Type: TABLE DATA; Schema: auth; Owner: -
--

COPY auth.webauthn_credentials (id, user_id, credential_id, public_key, attestation_type, aaguid, sign_count, transports, backup_eligible, backed_up, friendly_name, created_at, updated_at, last_used_at) FROM stdin;
\.


--
-- Data for Name: alojamentos; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.alojamentos (id, nome, endereco, obra_id, vagas_total, imobiliaria, contato_imobiliaria, custo_mensal, condominio, iptu, seguro, data_inicio, data_termino, isencao_meses, indice_reajuste, observacoes, contrato_url, laudo_url, fotos_url, criado_em, caucao, proprietario, contato_proprietario, moradores_avulsos, isenta_agua, isenta_energia, isenta_gas, isenta_condominio) FROM stdin;
237dd956-2e0d-4e77-a2bd-26a59253b022	Residencial Ilhas de Mediterraneo - Apto 36	Rua Adolfo Rodrigues de Arruda, 86 - Parque Industrial, Itu-SP	0d899f11-785d-4edd-a951-bac82fae074f	1	Carvalho Imobiliária	\N	2472.57	484.93	42.50	31.68	2026-04-02	2029-04-01	18	IVAR	\N	\N	\N	\N	2026-06-03 18:58:06.915954+00	0	\N	\N	[]	f	f	f	f
f6f57e02-f34d-4586-9bc2-d32da81a6931	APARTAMENTO	Avenida Nelson Rubini nº 410 Apto 53 Bloco G Condomínio Residencial Brisa da Mata	0ea37ce8-5f9d-4270-ac46-73e6c169c6d2	2	HAPPY IMOVEIS	\N	2500.00	475.85	\N	\N	2026-02-05	2028-08-04	12	IVAR	\N	\N	https://lqggoshphakeuufibdno.supabase.co/storage/v1/object/public/alojamentos/laudos/1781790108558_Laudo_de_Vistoria_Inicial.pdf	https://lqggoshphakeuufibdno.supabase.co/storage/v1/object/public/alojamentos/fotos/1781790115749_ADM_31_-_03-2026_BRISA_DA_MATA_APTO.pdf	2026-06-18 13:41:59.642516+00	7500	\N	\N	[]	t	f	f	f
5e1a3306-b40c-4277-8c03-5e317063af3b	COSTA RICA	Rua Costa Rica, n° 604	0d899f11-785d-4edd-a951-bac82fae074f	6	COSTA ROCHA IMOVEIS	01140281983	2300.00	\N	\N	\N	2026-04-22	2027-04-22	\N	IVAR	\N	https://lqggoshphakeuufibdno.supabase.co/storage/v1/object/public/alojamentos/contratos/1781784544255_24104-004_-_CONTRATO_COSTA_ROCHAXGTEL_-_RUA_COSTA_RICA,_604.pdf	https://lqggoshphakeuufibdno.supabase.co/storage/v1/object/public/alojamentos/laudos/1781784548934_RELATORIO_ESTRUTURAL_09.pdf	https://lqggoshphakeuufibdno.supabase.co/storage/v1/object/public/alojamentos/fotos/1781784550414_FOTOS.zip	2026-06-18 12:09:13.901544+00	\N	\N	\N	[]	f	f	t	t
c8e6e203-9c03-42cb-9a30-63fca14dc225	Rua Hungria, n° 494	Rua Hungria, n° 494 Bairro: Jardim das Nações. Município: Salto/SP, CEP : 13322-163.	0d899f11-785d-4edd-a951-bac82fae074f	6	Morata	\N	2500.00	\N	77.84	46.92	2026-04-15	2029-04-15	\N	IVAR	\N	\N	\N	\N	2026-06-03 20:43:18.472431+00	7500	\N	\N	[]	f	f	f	f
2b753fd1-03b8-433a-a187-24f4b5ccb1de	Rua das Nações Unidas, n° 600	Rua das Nações Unidas, n° 600, apto 301, bloco 45, resid. Solar dos Pássaros, Salto/SP.	0d899f11-785d-4edd-a951-bac82fae074f	2	Costa Rocha	\N	1700.00	\N	\N	\N	2026-04-01	2027-04-01	\N	IVAR	R$ 1.700,00 (um mil e setecentos reais) incluso condomínio, água, gás e\nIPTU	\N	\N	\N	2026-06-04 10:09:43.697412+00	\N	\N	\N	[{"obs": "Inspetor de Solda - PJ", "nome": "Roberto Gonçalves de Oliveira"}]	f	f	f	f
e42bb35b-e6c4-4db2-8c2b-4c2e8f69a2e3	Vital Brasil 545	Vital Brasil 545, Jardim São Francisco - Salto/SP	0d899f11-785d-4edd-a951-bac82fae074f	8	Teu Imóvel	\N	2300.00	\N	\N	\N	2026-04-10	2029-04-10	12	IVAR	\N	\N	\N	\N	2026-06-04 10:48:05.88079+00	\N	VANILDA LUISA ROSSI	\N	[]	f	f	f	f
a0f063aa-df41-4780-ab24-82be52000892	JULIO PONGELUPPI	RUA JULIO PONGELUPPI – 118 JD.FORTALEZA/ PAULINIA - SP CEP: 13140-054	c2096d7c-a212-4365-9d85-3151167e0436	10	BANCO IMÓVEL	atendimento@bancoimovel.com.br	3500.00	\N	\N	\N	2023-08-22	2024-08-21	\N	IVAR	\N	\N	\N	\N	2026-06-16 12:42:05.155966+00	\N	\N	\N	[]	f	f	f	f
7eca1a31-eb4e-4e6e-b853-57bc6c9ac091	DAS TULIPAS	RUA DAS TULIPAS 190 – PRES. MÉDICI/ PAULINIA - SP CEP: 13140-392	c2096d7c-a212-4365-9d85-3151167e0436	7	DÁLETE DE OLIVEIRA MELO SERVIÇOS IMOBILIARIOS	19 98152-4058	3000.00	\N	\N	576.02	2024-01-10	2026-07-10	30	IVAR	\N	https://lqggoshphakeuufibdno.supabase.co/storage/v1/object/public/alojamentos/contratos/1781619518664_CONTRATO_DE_LOCACAO-_RUA_DAS_TULIPAS_190_PAULINIA.pdf	\N	\N	2026-06-16 14:18:43.978036+00	\N	\N	\N	[]	f	f	f	f
7e18e7ce-a57d-4369-88de-8097c3286957	SAO FELIPE	Rua São Felipe, n° 148.	0d899f11-785d-4edd-a951-bac82fae074f	6	MORATTA IMIVEIS	011942619418	2500.00	\N	\N	46.92	2026-04-15	2029-04-15	\N	IVAR	\N	\N	https://lqggoshphakeuufibdno.supabase.co/storage/v1/object/public/alojamentos/laudos/1781785905178_RELATORIO_ESTRUTURAL_02.pdf	https://lqggoshphakeuufibdno.supabase.co/storage/v1/object/public/alojamentos/fotos/1781785907641_FOTOS.zip	2026-06-18 12:31:51.716825+00	7500	\N	\N	[]	f	f	t	t
1a02849c-86c8-40b7-920d-7f20937d758b	MARIETA	Rua João Jordão, 681 - Res. Marieta Dian Cosmópolis - SP, 13150-000	0ea37ce8-5f9d-4270-ac46-73e6c169c6d2	7	DHG	\N	3500.00	\N	\N	\N	2025-12-02	2028-06-01	12	IVAR	\N	\N	https://lqggoshphakeuufibdno.supabase.co/storage/v1/object/public/alojamentos/laudos/1781789424205_LAUDO_DE_VISTORIA_DE_ENTRADA_-_ASSINADO.pdf	\N	2026-06-18 13:30:53.775191+00	\N	\N	\N	[]	f	f	t	t
326e50c1-0ebc-4674-8bf9-a9cac9ea998d	MONTE ALEGRE	Rua Avelino Beraldo, 115 Bairro Monte Alegre V CEP 13142-382 - Paulínia SP	0ea37ce8-5f9d-4270-ac46-73e6c169c6d2	6	HAPPY IMOVEIS	\N	3800.00	\N	\N	\N	2025-12-08	2028-06-07	12	IVAR	\N	https://lqggoshphakeuufibdno.supabase.co/storage/v1/object/public/alojamentos/contratos/1781789562876_Contrato_Rua_Avelino_Beraldo_115_-_Vila_Monte_Alegre_-_Paulinia_-_Assinado.pdf	https://lqggoshphakeuufibdno.supabase.co/storage/v1/object/public/alojamentos/laudos/1781789565509_Vistoria_de_Entrada.pdf	https://lqggoshphakeuufibdno.supabase.co/storage/v1/object/public/alojamentos/fotos/1781789568234_ADM_31_-_01-2026_AVELINO_BERALDO,_115_-_supervisores.pdf	2026-06-18 13:32:50.512062+00	11400	\N	\N	[]	f	f	t	t
8492df23-4608-4b03-a3dc-7e25f361909f	SERRA AZUL	Rua Ítalo Bressanin 29 Bairro Residencial Serra Azul Paulínia SP cep 13144676	0ea37ce8-5f9d-4270-ac46-73e6c169c6d2	8	DHG	\N	3500.00	\N	\N	\N	2026-01-23	2028-07-22	12	IVAR	\N	https://lqggoshphakeuufibdno.supabase.co/storage/v1/object/public/alojamentos/contratos/1781789731216_Contrato_Assinado_Rua_Italo_Bressanin_29_Bairro_Residencial_Serra_Azul.pdf	https://lqggoshphakeuufibdno.supabase.co/storage/v1/object/public/alojamentos/laudos/1781789736676_LAUDO_DE_VISTORIA_DE_ENTRADA_-_ASSINADO.pdf	https://lqggoshphakeuufibdno.supabase.co/storage/v1/object/public/alojamentos/fotos/1781789757321_ADM_31_-_02-2026_-_SERRA_AZUL.pdf	2026-06-18 13:36:01.542549+00	14000	\N	\N	[]	f	f	t	t
\.


--
-- Data for Name: alojamentos_contas; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.alojamentos_contas (id, alojamento_id, mes, ano, tipo, valor, observacao, criado_em, adm35_numero, adm35_envio) FROM stdin;
\.


--
-- Data for Name: alojamentos_relatorios; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.alojamentos_relatorios (id, alojamento_id, mes, ano, avaliador, data_avaliacao, data_recebimento, observacoes, created_at) FROM stdin;
\.


--
-- Data for Name: efetivo_he; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.efetivo_he (id, data, periodo_ini, matricula, nome, tipo, mins, created_at) FROM stdin;
f9b2dbb1-e811-43f5-89a7-870aceea797d	2026-05-25	2026-05-25	30670	JOAO MARCIO GUILHERMINO SILVA	HE 60%	37	2026-06-18 20:41:49.301946+00
54df3435-8203-4fbe-8976-9d453c92dde0	2026-05-26	2026-05-25	30670	JOAO MARCIO GUILHERMINO SILVA	HE 60%	67	2026-06-18 20:41:49.301946+00
340d93f8-6fb8-42b8-a067-07f585fe6f10	2026-05-27	2026-05-25	30670	JOAO MARCIO GUILHERMINO SILVA	HE 60%	33	2026-06-18 20:41:49.301946+00
fbc292d2-2f19-4ac7-9b71-c0f4bab8d244	2026-05-29	2026-05-25	30670	JOAO MARCIO GUILHERMINO SILVA	HE 60%	13	2026-06-18 20:41:49.301946+00
2b7eed32-3958-45f0-84f2-2420a1e6c900	2026-06-02	2026-05-25	30670	JOAO MARCIO GUILHERMINO SILVA	HE 60%	121	2026-06-18 20:41:49.301946+00
ec1be014-51be-4863-af4c-530234c7bdae	2026-06-09	2026-05-25	30670	JOAO MARCIO GUILHERMINO SILVA	HE 60%	42	2026-06-18 20:41:49.301946+00
0cc89a19-863a-406a-ac2f-04db63230d98	2026-06-10	2026-05-25	30670	JOAO MARCIO GUILHERMINO SILVA	HE 60%	33	2026-06-18 20:41:49.301946+00
66ce54bf-5f0a-4814-8699-548309ac9c35	2026-06-11	2026-05-25	30670	JOAO MARCIO GUILHERMINO SILVA	HE 60%	125	2026-06-18 20:41:49.301946+00
5fd9b1c7-cb0f-4c34-a86c-4db17a5bd477	2026-06-12	2026-05-25	30670	JOAO MARCIO GUILHERMINO SILVA	HE 60%	137	2026-06-18 20:41:49.301946+00
bbb1203c-b363-4fcb-bae6-7981b5cac48e	2026-06-17	2026-05-25	30670	JOAO MARCIO GUILHERMINO SILVA	HE 60%	61	2026-06-18 20:41:49.301946+00
63b3e404-90db-45d1-b248-1f69c48def0c	2026-06-13	2026-05-25	70252	USIEL BRAZ RIBEIRO	HE 60%	480	2026-06-18 20:41:49.301946+00
3134d335-96b4-46df-99be-4fb29b5522b5	2026-06-13	2026-05-25	70252	USIEL BRAZ RIBEIRO	HE 60%	5	2026-06-18 20:41:49.301946+00
a835135e-20e3-4cac-957a-da3dd4190990	2026-05-22	2026-05-25	71110	DIEGO FERREIRA ALVES	HE 60%	14	2026-06-18 20:41:49.301946+00
5264f879-0457-45e5-ac2d-28a9285dbce3	2026-05-26	2026-05-25	71110	DIEGO FERREIRA ALVES	HE 60%	110	2026-06-18 20:41:49.301946+00
efcfadf5-7142-4284-9c98-aa3e3d4f6314	2026-05-27	2026-05-25	71110	DIEGO FERREIRA ALVES	HE 60%	25	2026-06-18 20:41:49.301946+00
a78ce30c-ef83-47aa-8f5c-a21102c31d09	2026-05-28	2026-05-25	71110	DIEGO FERREIRA ALVES	HE 60%	12	2026-06-18 20:41:49.301946+00
35e8ac39-009e-4519-80fe-217078123259	2026-05-29	2026-05-25	71110	DIEGO FERREIRA ALVES	HE 60%	16	2026-06-18 20:41:49.301946+00
2e190c78-fb61-4152-b0c1-db5142098bef	2026-06-01	2026-05-25	71110	DIEGO FERREIRA ALVES	HE 60%	48	2026-06-18 20:41:49.301946+00
7749cebf-611a-434f-be8c-45d23d22c6a7	2026-06-02	2026-05-25	71110	DIEGO FERREIRA ALVES	HE 60%	120	2026-06-18 20:41:49.301946+00
541bb082-5a1f-4bb8-9b9f-644250633c9f	2026-06-09	2026-05-25	71110	DIEGO FERREIRA ALVES	HE 60%	39	2026-06-18 20:41:49.301946+00
304d0fec-6832-469e-8c53-75599ddc8b8d	2026-06-10	2026-05-25	71110	DIEGO FERREIRA ALVES	HE 60%	21	2026-06-18 20:41:49.301946+00
d394e5f5-d1bb-4c67-8e1f-e55cab23a17a	2026-06-12	2026-05-25	71110	DIEGO FERREIRA ALVES	HE 60%	34	2026-06-18 20:41:49.301946+00
d2640b42-39bc-411e-81c4-e0f8a8aa1819	2026-06-13	2026-05-25	71110	DIEGO FERREIRA ALVES	HE 60%	480	2026-06-18 20:41:49.301946+00
b7940532-ded4-42de-aaa1-58179120a0a9	2026-06-13	2026-05-25	71110	DIEGO FERREIRA ALVES	HE 60%	2	2026-06-18 20:41:49.301946+00
0d432d59-a9aa-4489-8838-23b7172a56e5	2026-06-16	2026-05-25	71110	DIEGO FERREIRA ALVES	HE 100%	546	2026-06-18 20:41:49.301946+00
98e07e90-86a8-4233-a8f6-6141ab850139	2026-05-21	2026-05-25	72362	GUSTAVO HENRIQUE CARTACHO LIMA DO NASCIMENTO	HE 60%	35	2026-06-18 20:41:49.301946+00
1cf14d01-8444-40d5-bc6e-4c72de3c2ef3	2026-05-22	2026-05-25	72362	GUSTAVO HENRIQUE CARTACHO LIMA DO NASCIMENTO	HE 60%	148	2026-06-18 20:41:49.301946+00
5683c1cc-d2fc-4356-9e9b-fd32b168e1bb	2026-05-25	2026-05-25	72362	GUSTAVO HENRIQUE CARTACHO LIMA DO NASCIMENTO	HE 60%	91	2026-06-18 20:41:49.301946+00
9f87b7c8-8ed3-408a-9128-a55ab253468c	2026-05-26	2026-05-25	72362	GUSTAVO HENRIQUE CARTACHO LIMA DO NASCIMENTO	HE 60%	120	2026-06-18 20:41:49.301946+00
ec29d36d-0ca5-49d0-b763-00584a5014ec	2026-05-27	2026-05-25	72362	GUSTAVO HENRIQUE CARTACHO LIMA DO NASCIMENTO	HE 60%	120	2026-06-18 20:41:49.301946+00
ede414ed-506b-4c54-b2a3-2db99a98f633	2026-05-28	2026-05-25	72362	GUSTAVO HENRIQUE CARTACHO LIMA DO NASCIMENTO	HE 60%	120	2026-06-18 20:41:49.301946+00
427a32ca-f14e-4e95-9bf6-9df30c4547d6	2026-05-29	2026-05-25	72362	GUSTAVO HENRIQUE CARTACHO LIMA DO NASCIMENTO	HE 60%	180	2026-06-18 20:41:49.301946+00
dcf5025f-5655-4132-8bb9-4ceb49bab387	2026-06-01	2026-05-25	72362	GUSTAVO HENRIQUE CARTACHO LIMA DO NASCIMENTO	HE 60%	74	2026-06-18 20:41:49.301946+00
13883a59-5f70-417f-bac5-ead718ad1815	2026-06-02	2026-05-25	72362	GUSTAVO HENRIQUE CARTACHO LIMA DO NASCIMENTO	HE 60%	169	2026-06-18 20:41:49.301946+00
7e62c9c3-da34-43f3-bcaf-0f3ac1a88f32	2026-06-03	2026-05-25	72362	GUSTAVO HENRIQUE CARTACHO LIMA DO NASCIMENTO	HE 60%	161	2026-06-18 20:41:49.301946+00
ad04ee6c-393c-41a3-bae0-17f26c3396aa	2026-06-08	2026-05-25	72362	GUSTAVO HENRIQUE CARTACHO LIMA DO NASCIMENTO	HE 60%	120	2026-06-18 20:41:49.301946+00
c043689f-0411-435c-a777-253e6a2f013c	2026-06-09	2026-05-25	72362	GUSTAVO HENRIQUE CARTACHO LIMA DO NASCIMENTO	HE 60%	120	2026-06-18 20:41:49.301946+00
274f9e59-db07-4251-aa4a-222438c72a2f	2026-06-10	2026-05-25	72362	GUSTAVO HENRIQUE CARTACHO LIMA DO NASCIMENTO	HE 60%	120	2026-06-18 20:41:49.301946+00
0899823b-5c87-4a8c-b5b8-079f31827ce8	2026-06-13	2026-05-25	72362	GUSTAVO HENRIQUE CARTACHO LIMA DO NASCIMENTO	HE 60%	480	2026-06-18 20:41:49.301946+00
f33ed564-b29f-4ca6-9d24-2a4029543c33	2026-06-13	2026-05-25	72362	GUSTAVO HENRIQUE CARTACHO LIMA DO NASCIMENTO	HE 60%	4	2026-06-18 20:41:49.301946+00
48689a61-17cc-4a27-a213-7dbca6a62754	2026-06-15	2026-05-25	72362	GUSTAVO HENRIQUE CARTACHO LIMA DO NASCIMENTO	HE 60%	173	2026-06-18 20:41:49.301946+00
8274b889-f17e-4ff7-9193-d0dd87fdba75	2026-06-16	2026-05-25	72362	GUSTAVO HENRIQUE CARTACHO LIMA DO NASCIMENTO	HE 100%	725	2026-06-18 20:41:49.301946+00
efee6ba3-bc19-4a20-aaf1-112d5d919136	2026-06-17	2026-05-25	72362	GUSTAVO HENRIQUE CARTACHO LIMA DO NASCIMENTO	HE 60%	177	2026-06-18 20:41:49.301946+00
586d34b4-0643-4334-bc6e-d4016ccdf0df	2026-05-22	2026-05-25	73019	JEIZIEL ALVES SILVA DE ASSIS	HE 60%	24	2026-06-18 20:41:49.301946+00
f92cfdfe-1f8d-43bc-9a71-913386551343	2026-05-25	2026-05-25	73019	JEIZIEL ALVES SILVA DE ASSIS	HE 60%	120	2026-06-18 20:41:49.301946+00
33ccf11c-4142-4736-9d6e-d9db9361f3a5	2026-05-26	2026-05-25	73019	JEIZIEL ALVES SILVA DE ASSIS	HE 60%	123	2026-06-18 20:41:49.301946+00
8a0c9c26-de2f-4286-a7f7-bc05701721b0	2026-05-27	2026-05-25	73019	JEIZIEL ALVES SILVA DE ASSIS	HE 60%	130	2026-06-18 20:41:49.301946+00
18cfee8c-39cf-4756-9559-fb620aed724c	2026-05-28	2026-05-25	73019	JEIZIEL ALVES SILVA DE ASSIS	HE 60%	67	2026-06-18 20:41:49.301946+00
e2bca9d1-c5ea-4b21-a8b6-328504aa740d	2026-05-29	2026-05-25	73019	JEIZIEL ALVES SILVA DE ASSIS	HE 60%	125	2026-06-18 20:41:49.301946+00
5ce120bc-fa18-4ef0-8ad3-bc2211625229	2026-05-30	2026-05-25	73019	JEIZIEL ALVES SILVA DE ASSIS	HE 60%	303	2026-06-18 20:41:49.301946+00
ce0d2665-4f97-4f3a-bd40-8692ba2e63d2	2026-06-01	2026-05-25	73019	JEIZIEL ALVES SILVA DE ASSIS	HE 60%	124	2026-06-18 20:41:49.301946+00
7681b2d8-b098-4ea9-9964-da98eb96b69e	2026-06-02	2026-05-25	73019	JEIZIEL ALVES SILVA DE ASSIS	HE 60%	145	2026-06-18 20:41:49.301946+00
5fbdb090-8e5d-4fca-a0f2-b1950b9130dd	2026-06-03	2026-05-25	73019	JEIZIEL ALVES SILVA DE ASSIS	HE 60%	87	2026-06-18 20:41:49.301946+00
a48bf559-15e7-47ca-93be-c1d997f78af1	2026-06-16	2026-05-25	73019	JEIZIEL ALVES SILVA DE ASSIS	HE 100%	622	2026-06-18 20:41:49.301946+00
f6bc04bb-2944-4734-84f6-bc91e4795175	2026-06-17	2026-05-25	73019	JEIZIEL ALVES SILVA DE ASSIS	HE 60%	118	2026-06-18 20:41:49.301946+00
49ecfaa2-ede4-409d-8545-ce5eb69c08c9	2026-05-22	2026-05-25	73242	RAFAEL FERREIRA ALVES	HE 100%	480	2026-06-18 20:41:49.301946+00
f9a77194-af08-413a-95bf-0163664f77cf	2026-05-25	2026-05-25	73242	RAFAEL FERREIRA ALVES	HE 80%	120	2026-06-18 20:41:49.301946+00
be1e5823-9c9a-4feb-8ee9-2ed769ff5d44	2026-05-25	2026-05-25	73242	RAFAEL FERREIRA ALVES	HE 80%	2	2026-06-18 20:41:49.301946+00
fb921893-1992-441e-b0ac-90a13983541e	2026-05-26	2026-05-25	73242	RAFAEL FERREIRA ALVES	HE 80%	120	2026-06-18 20:41:49.301946+00
12a02cc2-6c0c-4e77-9590-7944598305a7	2026-05-26	2026-05-25	73242	RAFAEL FERREIRA ALVES	HE 80%	2	2026-06-18 20:41:49.301946+00
f457d989-e635-4378-9892-7ff4499200bb	2026-05-27	2026-05-25	73242	RAFAEL FERREIRA ALVES	HE 80%	62	2026-06-18 20:41:49.301946+00
43ac46d0-8ee9-476d-b2cd-612a1613cdc4	2026-05-29	2026-05-25	73242	RAFAEL FERREIRA ALVES	HE 80%	112	2026-06-18 20:41:49.301946+00
9b8c3e3b-4093-4568-a7a0-c77e06022fb9	2026-05-30	2026-05-25	73242	RAFAEL FERREIRA ALVES	HE 100%	483	2026-06-18 20:41:49.301946+00
bbcea06e-e8d6-4634-abb3-810833a623ac	2026-05-23	2026-05-25	73569	EMILLE MARIANE CARDOSO RAMOS	HE 60%	480	2026-06-18 20:41:49.301946+00
c61d5016-8d58-43dd-81f8-aa7e0247682f	2026-05-23	2026-05-25	73569	EMILLE MARIANE CARDOSO RAMOS	HE 60%	5	2026-06-18 20:41:49.301946+00
5120d44d-1bff-4d95-9499-2d77c29e7d6f	2026-06-04	2026-05-25	73569	EMILLE MARIANE CARDOSO RAMOS	HE 60%	60	2026-06-18 20:41:49.301946+00
d4dd4335-2ac4-4a1b-b38e-55033e47faf0	2026-06-16	2026-05-25	73569	EMILLE MARIANE CARDOSO RAMOS	HE 100%	621	2026-06-18 20:41:49.301946+00
6126eeca-3b3b-42c7-bff6-50655660883c	2026-06-17	2026-05-25	73569	EMILLE MARIANE CARDOSO RAMOS	HE 60%	83	2026-06-18 20:41:49.301946+00
3759bdd7-1f7b-41e9-8ce9-ea0990a5495e	2026-05-22	2026-05-25	73759	ALAN FERREIRA ALVES	HE 100%	480	2026-06-18 20:41:49.301946+00
5e3a9718-7be8-4ff5-821d-6ca85f84003e	2026-05-25	2026-05-25	73759	ALAN FERREIRA ALVES	HE 80%	120	2026-06-18 20:41:49.301946+00
cfbe96f5-40a9-4014-b787-96f3a62cbba3	2026-05-25	2026-05-25	73759	ALAN FERREIRA ALVES	HE 80%	2	2026-06-18 20:41:49.301946+00
062c164d-f73e-4e0c-9d36-33cddd8ffde9	2026-05-26	2026-05-25	73759	ALAN FERREIRA ALVES	HE 80%	120	2026-06-18 20:41:49.301946+00
da6f78bf-14b1-4950-9f8f-ecbe7b2c2115	2026-05-26	2026-05-25	73759	ALAN FERREIRA ALVES	HE 80%	2	2026-06-18 20:41:49.301946+00
9c0b87db-8086-448e-b939-1d3d4d8220ca	2026-05-27	2026-05-25	73759	ALAN FERREIRA ALVES	HE 80%	62	2026-06-18 20:41:49.301946+00
c0d9c944-1eb2-4b84-bc08-7453d2f2e939	2026-05-29	2026-05-25	73759	ALAN FERREIRA ALVES	HE 80%	112	2026-06-18 20:41:49.301946+00
962d1bb2-cf27-4247-94f8-ed99f11a78ec	2026-05-30	2026-05-25	73759	ALAN FERREIRA ALVES	HE 100%	485	2026-06-18 20:41:49.301946+00
df4a998f-f37d-437f-b7f2-b7562c19ca76	2026-05-21	2026-05-25	73944	ANDRE LUIS CASTELO BRANCO	HE 60%	13	2026-06-18 20:41:49.301946+00
2589d1c3-361e-4cd4-b675-6781ccbed559	2026-05-22	2026-05-25	73944	ANDRE LUIS CASTELO BRANCO	HE 60%	23	2026-06-18 20:41:49.301946+00
eb7a5d0e-3bae-4c49-8745-b1b09ea523d6	2026-05-25	2026-05-25	73944	ANDRE LUIS CASTELO BRANCO	HE 60%	120	2026-06-18 20:41:49.301946+00
1d6df688-f54b-4c92-bad4-a096ab6ca314	2026-05-26	2026-05-25	73944	ANDRE LUIS CASTELO BRANCO	HE 60%	124	2026-06-18 20:41:49.301946+00
0203034d-5217-4856-9b4e-18a4df72a5f8	2026-05-27	2026-05-25	73944	ANDRE LUIS CASTELO BRANCO	HE 60%	130	2026-06-18 20:41:49.301946+00
4276e713-07fd-4f68-bf59-8fa0a415cacd	2026-05-28	2026-05-25	73944	ANDRE LUIS CASTELO BRANCO	HE 60%	67	2026-06-18 20:41:49.301946+00
4e035f6d-1c08-4ed2-b02c-32ed974cbebc	2026-05-29	2026-05-25	73944	ANDRE LUIS CASTELO BRANCO	HE 60%	33	2026-06-18 20:41:49.301946+00
3e3e510b-bfeb-4473-a6c9-b5bc8b6d8ce3	2026-06-01	2026-05-25	73944	ANDRE LUIS CASTELO BRANCO	HE 60%	124	2026-06-18 20:41:49.301946+00
4fc9451b-bb30-4c8e-994c-ac896daf1562	2026-06-02	2026-05-25	73944	ANDRE LUIS CASTELO BRANCO	HE 60%	120	2026-06-18 20:41:49.301946+00
695f4152-07cb-4cd5-95ba-c7da13a04336	2026-06-03	2026-05-25	73944	ANDRE LUIS CASTELO BRANCO	HE 60%	87	2026-06-18 20:41:49.301946+00
88a15b18-8017-4eaa-98c2-cc86351ef5ae	2026-06-08	2026-05-25	73944	ANDRE LUIS CASTELO BRANCO	HE 60%	120	2026-06-18 20:41:49.301946+00
23d86779-571f-4d0f-a853-4abc557e77a6	2026-06-09	2026-05-25	73944	ANDRE LUIS CASTELO BRANCO	HE 60%	120	2026-06-18 20:41:49.301946+00
6ff2dda6-1172-4446-bc1e-3a2a569d2122	2026-06-10	2026-05-25	73944	ANDRE LUIS CASTELO BRANCO	HE 60%	115	2026-06-18 20:41:49.301946+00
7c60d191-93c6-4e44-b5cc-b08f9bc8eb88	2026-06-11	2026-05-25	73944	ANDRE LUIS CASTELO BRANCO	HE 60%	80	2026-06-18 20:41:49.301946+00
6c47104a-41c0-41f8-86e6-4b6f31e871e7	2026-06-12	2026-05-25	73944	ANDRE LUIS CASTELO BRANCO	HE 60%	120	2026-06-18 20:41:49.301946+00
d26726dc-c78d-40bb-9c74-9bc3166a7843	2026-06-15	2026-05-25	73944	ANDRE LUIS CASTELO BRANCO	HE 60%	126	2026-06-18 20:41:49.301946+00
a4ac7051-6477-43e8-8085-9c97183fd65b	2026-06-16	2026-05-25	73944	ANDRE LUIS CASTELO BRANCO	HE 100%	618	2026-06-18 20:41:49.301946+00
6973e385-3ba8-43a5-98b6-86409208f76b	2026-06-17	2026-05-25	73944	ANDRE LUIS CASTELO BRANCO	HE 60%	118	2026-06-18 20:41:49.301946+00
35bf74a1-c2e7-43a3-890d-f4baf663d522	2026-06-13	2026-05-25	75785	WATILA RODRIGUES MIRANDA	HE 60%	480	2026-06-18 20:41:49.301946+00
a48cff77-ce39-445e-baac-e423cd7af54f	2026-06-13	2026-05-25	75785	WATILA RODRIGUES MIRANDA	HE 60%	6	2026-06-18 20:41:49.301946+00
58aa8e44-7be2-4842-b6de-25ceb2985d6c	2026-06-16	2026-05-25	75785	WATILA RODRIGUES MIRANDA	HE 100%	490	2026-06-18 20:41:49.301946+00
02d49575-1458-4253-bf23-efa53d7863de	2026-06-02	2026-05-25	75786	GERALDO ALVES PINTO	HE 60%	112	2026-06-18 20:41:49.301946+00
d07d948a-50ca-4c95-8c20-7880f842bdd8	2026-06-13	2026-05-25	75786	GERALDO ALVES PINTO	HE 60%	480	2026-06-18 20:41:49.301946+00
a89fc149-15f1-4ad3-9fd1-2cb02fb754bc	2026-06-16	2026-05-25	75786	GERALDO ALVES PINTO	HE 100%	488	2026-06-18 20:41:49.301946+00
24fbcdea-316f-41d6-ad68-f566009ddbc2	2026-05-23	2026-05-25	75787	DEJAILTON JESUS DOS SANTOS	HE 60%	480	2026-06-18 20:41:49.301946+00
c027ae63-46cc-4565-b432-4a2d1e1f3a58	2026-05-23	2026-05-25	75787	DEJAILTON JESUS DOS SANTOS	HE 60%	3	2026-06-18 20:41:49.301946+00
81c8ef71-c4b2-4a0a-bf01-046522a48b30	2026-06-16	2026-05-25	75800	CARLOS HENRIQUE AUGUSTO ARAUJO	HE 100%	489	2026-06-18 20:41:49.301946+00
284d72a8-c491-4a5f-96dc-0e7653e76d15	2026-05-23	2026-05-25	75808	MARCOS BISPO ASSUNCAO	HE 60%	480	2026-06-18 20:41:49.301946+00
9f8257c5-0a2b-40e9-ada7-e0590ec4dc56	2026-05-23	2026-05-25	75808	MARCOS BISPO ASSUNCAO	HE 60%	3	2026-06-18 20:41:49.301946+00
82ed8099-fd44-487b-b3ff-5b26698f0a1e	2026-05-25	2026-05-25	75808	MARCOS BISPO ASSUNCAO	HE 60%	120	2026-06-18 20:41:49.301946+00
a9a6c35d-e289-46ea-82c6-9dea94afbc29	2026-05-26	2026-05-25	75808	MARCOS BISPO ASSUNCAO	HE 60%	121	2026-06-18 20:41:49.301946+00
6a979b47-ae8f-4596-a66f-5cf8d49708d1	2026-06-03	2026-05-25	75813	JADSON SANTOS DOS SANTOS	HE 60%	33	2026-06-18 20:41:49.301946+00
b1758e5d-b016-4ea4-abe2-054c4d571f97	2026-05-26	2026-05-25	75815	RONALDO BARBOSA DE OLIVEIRA	HE 60%	37	2026-06-18 20:41:49.301946+00
cd684bb7-1e68-4fd8-ad50-176fa5a62450	2026-05-29	2026-05-25	75815	RONALDO BARBOSA DE OLIVEIRA	HE 60%	13	2026-06-18 20:41:49.301946+00
aaee0fd8-9784-4db1-834d-8816a2d506c1	2026-05-30	2026-05-25	75815	RONALDO BARBOSA DE OLIVEIRA	HE 60%	480	2026-06-18 20:41:49.301946+00
378dddea-daff-4781-8c29-e53589381b50	2026-05-30	2026-05-25	75815	RONALDO BARBOSA DE OLIVEIRA	HE 60%	4	2026-06-18 20:41:49.301946+00
252d8079-b187-4857-871e-a1840d89866a	2026-06-02	2026-05-25	75815	RONALDO BARBOSA DE OLIVEIRA	HE 60%	109	2026-06-18 20:41:49.301946+00
64e778b2-a809-45fe-933b-dbf4f01cf330	2026-06-03	2026-05-25	75815	RONALDO BARBOSA DE OLIVEIRA	HE 60%	33	2026-06-18 20:41:49.301946+00
c73b889d-3a56-4fd0-b88a-aecf8eb6fb8e	2026-06-09	2026-05-25	75815	RONALDO BARBOSA DE OLIVEIRA	HE 60%	120	2026-06-18 20:41:49.301946+00
6c506142-e753-4978-ad48-a94dfc2c4cb1	2026-06-13	2026-05-25	75815	RONALDO BARBOSA DE OLIVEIRA	HE 60%	480	2026-06-18 20:41:49.301946+00
cf2b2fc5-a72a-4ede-9f65-f1394baec968	2026-06-13	2026-05-25	75815	RONALDO BARBOSA DE OLIVEIRA	HE 60%	5	2026-06-18 20:41:49.301946+00
8709f4c2-2df7-4dd5-a4be-233660687b5e	2026-06-16	2026-05-25	75821	MARCILIO NUNES DE SOUSA	HE 100%	488	2026-06-18 20:41:49.301946+00
e5ce415d-c1fb-4af2-9145-31a7a8bcf761	2026-06-16	2026-05-25	75835	LAMEQUE RODRIGUES SILVA SOARES	HE 100%	488	2026-06-18 20:41:49.301946+00
f82b631c-0cb7-4bc8-a1ad-f45ed9cf8566	2026-06-16	2026-05-25	75836	JOELSON GONCALVES MARQUES	HE 100%	483	2026-06-18 20:41:49.301946+00
9a92ed0f-1f1a-480c-9f15-778ea8320bc9	2026-05-30	2026-05-25	75846	SIRLEI DA SILVA GILBERTO	HE 60%	480	2026-06-18 20:41:49.301946+00
e777903e-d229-4688-ad70-8f3cc473d039	2026-05-30	2026-05-25	75846	SIRLEI DA SILVA GILBERTO	HE 60%	4	2026-06-18 20:41:49.301946+00
fab65633-cf13-4dae-9310-a79691145d4b	2026-06-13	2026-05-25	75847	GABRIEL OLIVEIRA DOS SANTOS	HE 60%	480	2026-06-18 20:41:49.301946+00
5b6facec-195e-4cd9-bad2-2bee22c52b21	2026-06-13	2026-05-25	75847	GABRIEL OLIVEIRA DOS SANTOS	HE 60%	6	2026-06-18 20:41:49.301946+00
f3baeb3d-e6e2-4274-83ba-7178d27a2ead	2026-06-13	2026-05-25	75848	ANTONIO DA SILVA FREITAS	HE 60%	480	2026-06-18 20:41:49.301946+00
1c90084b-3804-4a7e-a8d7-dbd5ca62aa44	2026-06-13	2026-05-25	75848	ANTONIO DA SILVA FREITAS	HE 60%	6	2026-06-18 20:41:49.301946+00
a87c3ac9-e535-4be7-86fc-86289f395d02	2026-06-13	2026-05-25	75849	LUIZ GABRIEL DOS SANTOS ATAIDE	HE 60%	480	2026-06-18 20:41:49.301946+00
203a5b1d-a167-4923-b769-28238e67b3e2	2026-06-13	2026-05-25	75849	LUIZ GABRIEL DOS SANTOS ATAIDE	HE 60%	6	2026-06-18 20:41:49.301946+00
e7a1b96d-f65f-49c9-9887-439e9a3dfad9	2026-06-16	2026-05-25	75851	ANTONIO SANTOS PORTUGAL	HE 100%	487	2026-06-18 20:41:49.301946+00
bc5f6085-e767-4578-b83a-de54d36dd59b	2026-06-13	2026-05-25	75865	KAWANN DOS SANTOS TENORIO FEITOSA	HE 60%	480	2026-06-18 20:41:49.301946+00
0124741c-5ef9-4d3b-9f44-e651aff373ee	2026-06-13	2026-05-25	75865	KAWANN DOS SANTOS TENORIO FEITOSA	HE 60%	5	2026-06-18 20:41:49.301946+00
d0675bf5-9066-4005-8692-2dc77f7059b9	2026-06-13	2026-05-25	75866	IVANILDO DE JESUS SANTOS	HE 60%	480	2026-06-18 20:41:49.301946+00
70bd08ff-52c0-4937-b6bd-f9bdd2461065	2026-06-13	2026-05-25	75866	IVANILDO DE JESUS SANTOS	HE 60%	6	2026-06-18 20:41:49.301946+00
e758a8b3-1e82-4be4-b6bc-5569c8dfaae1	2026-06-09	2026-05-25	75867	ROSEMEIRE DE SOUZA MACHADO	HE 60%	16	2026-06-18 20:41:49.301946+00
493269f9-b6e1-42f1-b52c-7252685100cc	2026-06-16	2026-05-25	75880	NAIRAN DOS SANTOS	HE 100%	482	2026-06-18 20:41:49.301946+00
\.


--
-- Data for Name: efetivo_horas; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.efetivo_horas (id, data, matricula, nome, departamento, mins_a_trabalhar, mins_trabalhadas, mins_descontos, mins_justificadas, created_at) FROM stdin;
271939de-df80-497b-99c0-592bd4ae5b06	2026-06-12	10620	RAIMUNDO NONATO DO NASCIMENTO SANTOS	QUIMICA AMPARO YPE-SP	480	492	0	0	2026-06-16 20:39:13.790396+00
1d086ed6-9e86-4360-888f-88dce87dd98a	2026-06-12	30366	JOSE AUGUSTO FRANCISCO DE SOUZA	QUIMICA AMPARO YPE-SP	480	484	0	0	2026-06-16 20:39:13.790396+00
5556b673-58f8-4443-86a5-2db4f645c18d	2026-06-12	30670	JOAO MARCIO GUILHERMINO SILVA	QUIMICA AMPARO YPE-SP	480	626	0	0	2026-06-16 20:39:13.790396+00
9fbce66e-1c9b-41c3-bde2-82f273f943cb	2026-06-12	70252	USIEL BRAZ RIBEIRO	QUIMICA AMPARO YPE-SP	480	492	0	0	2026-06-16 20:39:13.790396+00
0fb162d5-db2a-4fe2-9f92-1a60b0a68567	2026-06-12	71109	GILSON COELHO MESSIAS	QUIMICA AMPARO YPE-SP	480	491	0	0	2026-06-16 20:39:13.790396+00
d1f6d710-1e37-480e-a6e2-7428eb80a90b	2026-06-12	71110	DIEGO FERREIRA ALVES	QUIMICA AMPARO YPE-SP	480	515	0	0	2026-06-16 20:39:13.790396+00
6c2de2d0-30e2-4296-aa46-245b6c0c6413	2026-06-12	72113	AILTON OLIVEIRA SOUSA	QUIMICA AMPARO YPE-SP	480	490	0	0	2026-06-16 20:39:13.790396+00
79f921e3-4aeb-4c28-b905-c264a1a9ddb2	2026-06-12	72362	GUSTAVO HENRIQUE CARTACHO LIMA DO NASCIMENTO	QUIMICA AMPARO YPE-SP	480	0	480	0	2026-06-16 20:39:13.790396+00
64e7e987-291c-4d90-aa0e-1fd6ca233f93	2026-06-12	72786	JOSUEL DA SILVA ROCHA	QUIMICA AMPARO YPE-SP	480	0	480	0	2026-06-16 20:39:13.790396+00
82927b23-28d4-4dad-a31f-81a86905436b	2026-06-12	73019	JEIZIEL ALVES SILVA DE ASSIS	QUIMICA AMPARO YPE-SP	0	0	0	0	2026-06-16 20:39:13.790396+00
fccc7ac7-738e-4527-82a7-c6b51d6b35a3	2026-06-12	73163	JOSE HERCULES DA SILVA	QUIMICA AMPARO YPE-SP	480	492	0	0	2026-06-16 20:39:13.790396+00
62daa39a-750a-438b-89a1-b8eb3515b498	2026-06-12	73242	RAFAEL FERREIRA ALVES	QUIMICA AMPARO YPE-SP	480	0	480	0	2026-06-16 20:39:13.790396+00
e75c4ae7-79dc-4d45-8347-6988d1f435e3	2026-06-12	73569	EMILLE MARIANE CARDOSO RAMOS	QUIMICA AMPARO YPE-SP	480	0	480	0	2026-06-16 20:39:13.790396+00
d07f46c5-25cb-4ab3-ae9c-3fc1ce21dfb6	2026-06-12	73759	ALAN FERREIRA ALVES	QUIMICA AMPARO YPE-SP	480	0	480	0	2026-06-16 20:39:13.790396+00
de7b08af-405e-41b8-a945-84ee93cf68f9	2026-06-12	73944	ANDRE LUIS CASTELO BRANCO	QUIMICA AMPARO YPE-SP	480	605	0	0	2026-06-16 20:39:13.790396+00
31ccd28e-8d8c-4a2d-8bdb-7fbe5986e82d	2026-06-12	74785	ALTAIR DA SILVA MARTINS	QUIMICA AMPARO YPE-SP	480	487	0	0	2026-06-16 20:39:13.790396+00
6dc06d5c-6944-4c58-ba13-10186e0884a3	2026-06-12	75088	ANTONIO EDNILSON SERAFIM DE OLIVEIRA	QUIMICA AMPARO YPE-SP	480	486	0	0	2026-06-16 20:39:13.790396+00
cedf58c2-4f68-4e01-9a44-95c27a1a0ea6	2026-06-12	75193	DIOGO DOS SANTOS ARAUJO	QUIMICA AMPARO YPE-SP	480	487	0	0	2026-06-16 20:39:13.790396+00
deeec322-4d7b-44a5-938c-60b9a6076821	2026-06-12	75251	ARTHUR HENRIQUE NICACIO DA SILVA	QUIMICA AMPARO YPE-SP	480	475	0	0	2026-06-16 20:39:13.790396+00
a88c563b-f88f-448f-9c8d-31279f7a5ab5	2026-06-12	75532	DENIS BARBOSA DOS SANTOS	QUIMICA AMPARO YPE-SP	480	484	0	0	2026-06-16 20:39:13.790396+00
bb078537-d13f-42ef-9e52-c6716d4af003	2026-06-12	75550	EDMAR GUILHERMINO DA SILVA	QUIMICA AMPARO YPE-SP	480	0	480	0	2026-06-16 20:39:13.790396+00
0ce90918-397d-48e4-b1d2-3eca7a1ff06b	2026-06-12	75708	FRANCISCO SANTIAGO DA SILVA	QUIMICA AMPARO YPE-SP	480	487	0	0	2026-06-16 20:39:13.790396+00
02b7b98d-bfae-4139-acf9-5aa281ea27dc	2026-06-12	75785	WATILA RODRIGUES MIRANDA	QUIMICA AMPARO YPE-SP	480	490	0	0	2026-06-16 20:39:13.790396+00
9955abef-4e32-48e9-bfbb-a15c936994aa	2026-06-12	75786	GERALDO ALVES PINTO	QUIMICA AMPARO YPE-SP	480	491	0	0	2026-06-16 20:39:13.790396+00
86b4c501-628d-4bb4-995d-29e6905c63eb	2026-06-12	75787	DEJAILTON JESUS DOS SANTOS	QUIMICA AMPARO YPE-SP	480	490	0	0	2026-06-16 20:39:13.790396+00
9924eae5-81d1-4986-809e-70d222187068	2026-06-12	75797	EVERTON CHAGAS DE QUEIROZ	QUIMICA AMPARO YPE-SP	480	490	0	0	2026-06-16 20:39:13.790396+00
42373c95-21b9-44a5-a458-a2e9ee270914	2026-06-12	75798	FABIO LUIZ DE FARIAS	QUIMICA AMPARO YPE-SP	480	490	0	0	2026-06-16 20:39:13.790396+00
cb1fac90-c58f-48e8-867b-e61480c52aa5	2026-06-12	75799	WILLIAM SIDNEY SANTOS	QUIMICA AMPARO YPE-SP	480	489	0	0	2026-06-16 20:39:13.790396+00
39ddc5da-4f3f-41f9-b67e-3cbad4247d17	2026-06-12	75800	CARLOS HENRIQUE AUGUSTO ARAUJO	QUIMICA AMPARO YPE-SP	480	490	0	0	2026-06-16 20:39:13.790396+00
e0bf808e-bff9-4f4b-9a53-4d1686517f0c	2026-06-12	75805	JOSE RENATO DA GLORIA SANTOS	QUIMICA AMPARO YPE-SP	480	486	0	0	2026-06-16 20:39:13.790396+00
ac844b37-854e-4303-bb43-93a2d1871ce5	2026-06-12	75808	MARCOS BISPO ASSUNCAO	QUIMICA AMPARO YPE-SP	480	489	0	0	2026-06-16 20:39:13.790396+00
14dee062-dd88-4083-9019-c2fad07356e6	2026-06-12	75809	JONAS DE OLIVEIRA	QUIMICA AMPARO YPE-SP	480	485	0	0	2026-06-16 20:39:13.790396+00
ae6e4a63-7944-4edf-b433-93df4f411a35	2026-06-12	75810	PEDRO JUNIOR CELESTINO DE OLIVEIRA	QUIMICA AMPARO YPE-SP	480	488	0	0	2026-06-16 20:39:13.790396+00
cdd96a33-7a00-411f-a264-d0a1cff9772b	2026-06-12	75811	CRISTIAN FABIO DOS SANTOS DOS REIS	QUIMICA AMPARO YPE-SP	480	486	0	0	2026-06-16 20:39:13.790396+00
7cf0dfee-f462-4675-9b10-cfe96eebb78c	2026-06-12	75812	ESMAEL CARLOS NASCIMENTO DOS SANTOS	QUIMICA AMPARO YPE-SP	480	491	0	0	2026-06-16 20:39:13.790396+00
c91f852a-364d-4341-a63e-c6cad7389bfe	2026-06-12	75813	JADSON SANTOS DOS SANTOS	QUIMICA AMPARO YPE-SP	480	487	0	0	2026-06-16 20:39:13.790396+00
b3d5ccfc-4da2-4246-90cc-fac9ab7a1901	2026-06-12	75814	RICARDO CESAR COSTA SANTOS	QUIMICA AMPARO YPE-SP	480	491	0	0	2026-06-16 20:39:13.790396+00
f069194f-0773-49d0-8aa5-02b76e97effe	2026-06-12	75815	RONALDO BARBOSA DE OLIVEIRA	QUIMICA AMPARO YPE-SP	480	492	0	0	2026-06-16 20:39:13.790396+00
f18e067b-ec4a-42f0-99b1-f7cd4f46d900	2026-06-12	75821	MARCILIO NUNES DE SOUSA	QUIMICA AMPARO YPE-SP	480	493	0	0	2026-06-16 20:39:13.790396+00
13ee1a99-3f85-4667-affd-14074d89781d	2026-06-12	75822	JOSE MARCELO DE SOUSA	QUIMICA AMPARO YPE-SP	480	489	0	0	2026-06-16 20:39:13.790396+00
de2aa94c-d96f-40ad-a430-969a8edf848a	2026-06-12	75826	ALEXSANDRO DE CAMPOS	QUIMICA AMPARO YPE-SP	480	485	0	0	2026-06-16 20:39:13.790396+00
cc32f1cb-2153-4824-a01e-287dd52ea36d	2026-06-12	75828	ALEX LORENZO MATOS SANTOS	QUIMICA AMPARO YPE-SP	480	486	0	0	2026-06-16 20:39:13.790396+00
2dbcf9a9-8d30-4d5a-931d-a6fbba7fc613	2026-06-12	75829	WARLEM ALVES	QUIMICA AMPARO YPE-SP	480	486	0	0	2026-06-16 20:39:13.790396+00
3a49b296-2ea9-4b48-a503-0e51c5487802	2026-06-12	75830	CLAUDIO ASTRO CARVALHO	QUIMICA AMPARO YPE-SP	480	487	0	0	2026-06-16 20:39:13.790396+00
6d7ef6a4-6947-419b-8dbe-a33495dddc62	2026-06-12	75831	ADRIANO FERREIRA GOMES	QUIMICA AMPARO YPE-SP	480	487	0	0	2026-06-16 20:39:13.790396+00
a5c954f8-fee0-47d2-8d71-89ea3a17342d	2026-06-12	75833	UBIRAJARA MENDONCA DOS SANTOS	QUIMICA AMPARO YPE-SP	480	486	0	0	2026-06-16 20:39:13.790396+00
c01d8d88-16e4-4465-ab42-b1e712c17cb4	2026-06-12	75834	JERRI SANTOS DA CONCEICAO PINTO	QUIMICA AMPARO YPE-SP	480	486	0	0	2026-06-16 20:39:13.790396+00
5ffae132-493d-4aaa-a439-fa28dcfcca4f	2026-06-12	75835	LAMEQUE RODRIGUES SILVA SOARES	QUIMICA AMPARO YPE-SP	480	486	0	0	2026-06-16 20:39:13.790396+00
586d5b67-b1fc-4eda-877e-9090a178593a	2026-06-12	75836	JOELSON GONCALVES MARQUES	QUIMICA AMPARO YPE-SP	480	487	0	0	2026-06-16 20:39:13.790396+00
6122634c-c9a9-4f21-9d55-b6f0f0e55c69	2026-06-12	75837	GERSONIEL SOUSA RODRIGUES	QUIMICA AMPARO YPE-SP	480	487	0	0	2026-06-16 20:39:13.790396+00
bb5ef7dc-57ac-44dc-9499-5d5d6d98f981	2026-06-12	75841	MARCELO SILVA	QUIMICA AMPARO YPE-SP	480	486	0	0	2026-06-16 20:39:13.790396+00
ad0e467e-23f8-45ce-b8de-5f9cbc657f80	2026-06-12	75846	SIRLEI DA SILVA GILBERTO	QUIMICA AMPARO YPE-SP	480	484	0	0	2026-06-16 20:39:13.790396+00
aeba51c2-fdf4-4a4c-b599-82b0f913f776	2026-06-12	75847	GABRIEL OLIVEIRA DOS SANTOS	QUIMICA AMPARO YPE-SP	480	494	0	0	2026-06-16 20:39:13.790396+00
98c0c888-deb4-4a2f-a7af-7b6b6cbe562b	2026-06-12	75848	ANTONIO DA SILVA FREITAS	QUIMICA AMPARO YPE-SP	480	492	0	0	2026-06-16 20:39:13.790396+00
2c9cfb51-ee97-41ac-b319-dda400ecd1cd	2026-06-12	75849	LUIZ GABRIEL DOS SANTOS ATAIDE	QUIMICA AMPARO YPE-SP	480	491	0	0	2026-06-16 20:39:13.790396+00
6addc54e-73a9-41ed-98ae-620461fe222a	2026-06-12	75850	MARIA DAS GRACAS DOS SANTOS E SILVA	QUIMICA AMPARO YPE-SP	480	489	0	0	2026-06-16 20:39:13.790396+00
1f3652ef-fd21-4a7a-9d39-488fa72a1b70	2026-06-12	75851	ANTONIO SANTOS PORTUGAL	QUIMICA AMPARO YPE-SP	480	485	0	0	2026-06-16 20:39:13.790396+00
78dfff5e-734d-4bbd-b42b-2e0139aaacf9	2026-06-12	75853	ARGEL QUEIROZ SANTANA	QUIMICA AMPARO YPE-SP	480	486	0	0	2026-06-16 20:39:13.790396+00
7574c186-60b4-48a5-a2fd-06be8a776a43	2026-06-12	75854	JORGE HUGO BARBOSA DUARTE	QUIMICA AMPARO YPE-SP	480	488	0	0	2026-06-16 20:39:13.790396+00
fb1451a5-730d-4f2f-a07c-12cfec45d17e	2026-06-12	75855	WASHINGTON LUIS BARBOSA VENTURA JUNIOR	QUIMICA AMPARO YPE-SP	480	470	14	0	2026-06-16 20:39:13.790396+00
e3a7d575-bdc1-4e83-ae81-9afd6fd76577	2026-06-12	75864	ANTONIO DAMASCENO NOGUEIRA	QUIMICA AMPARO YPE-SP	480	0	480	0	2026-06-16 20:39:13.790396+00
89a21fcc-b5c2-4a77-841d-e9686ec95471	2026-06-12	75865	KAWANN DOS SANTOS TENORIO FEITOSA	QUIMICA AMPARO YPE-SP	480	490	0	0	2026-06-16 20:39:13.790396+00
dd8dba6c-ee75-4fc7-8eb9-74217500bfdb	2026-06-12	75866	IVANILDO DE JESUS SANTOS	QUIMICA AMPARO YPE-SP	480	493	0	0	2026-06-16 20:39:13.790396+00
f92d5345-bf66-41f1-adf7-cea273d900c3	2026-06-12	75867	ROSEMEIRE DE SOUZA MACHADO	QUIMICA AMPARO YPE-SP	480	472	10	0	2026-06-16 20:39:13.790396+00
dc895ece-c3bb-41d9-a791-3575c32ad53b	2026-06-12	75868	MARCUS VINICIUS SILVA DE OLIVEIRA	QUIMICA AMPARO YPE-SP	480	0	480	0	2026-06-16 20:39:13.790396+00
f1ee834f-0880-44d2-9deb-9cd577f67399	2026-06-12	75879	WENDEL KAIC FREITAS LOPES	QUIMICA AMPARO YPE-SP	480	0	480	0	2026-06-16 20:39:13.790396+00
c14867c6-d28c-45f5-8bf5-c601d9e65e48	2026-06-12	75880	NAIRAN DOS SANTOS	QUIMICA AMPARO YPE-SP	480	492	0	0	2026-06-16 20:39:13.790396+00
1a154611-07cf-4724-8eb5-ed69d62bdfa3	2026-06-12	75887	NIVALDO MANUEL DOS SANTOS	QUIMICA AMPARO YPE-SP	480	487	0	0	2026-06-16 20:39:13.790396+00
d81669a3-6ed6-459d-ba5a-966f998297d3	2026-06-12	75888	PAULO RANGEL DE SA PACHECO	QUIMICA AMPARO YPE-SP	480	480	0	0	2026-06-16 20:39:13.790396+00
0ceb7024-c054-41ba-862b-1adcb6244d5c	2026-06-12	75889	FRANCISCO WELLINGTON SILVA LEITE	QUIMICA AMPARO YPE-SP	480	491	0	0	2026-06-16 20:39:13.790396+00
af06d683-0e8c-41df-9bcb-c9b0426a0a3e	2026-06-12	75891	JOÃO PAULO DO CARMO	QUIMICA AMPARO YPE-SP	480	471	10	0	2026-06-16 20:39:13.790396+00
f0197da2-7191-4848-a046-215147cc5cf9	2026-12-05	46361.99967592592	JOAO MARCIO GUILHERMINO SILVA	30670	0	0	137	0	2026-06-18 20:30:46.35719+00
a9e212d2-6293-4905-bf16-cb1dae2433d0	2026-12-05	46361.99967592592	DIEGO FERREIRA ALVES	71110	0	0	34	0	2026-06-18 20:30:46.35719+00
c04e5ebd-c020-498d-9aa8-273f19a73ae1	2026-12-05	46361.99967592592	ANDRE LUIS CASTELO BRANCO	73944	0	0	120	0	2026-06-18 20:30:46.35719+00
42152e6f-f219-42f2-a4f7-9d4fe8efdb56	2026-06-15	10620	RAIMUNDO NONATO DO NASCIMENTO SANTOS	QUIMICA AMPARO YPE-SP	0	0	0	0	2026-06-16 20:43:16.673807+00
9f256ea2-a71d-4f2f-aba6-e253896e2c55	2026-06-15	30366	JOSE AUGUSTO FRANCISCO DE SOUZA	QUIMICA AMPARO YPE-SP	540	551	0	0	2026-06-16 20:43:16.673807+00
2bf19124-c8fd-48bc-b7c5-efb6c66559ac	2026-06-15	30670	JOAO MARCIO GUILHERMINO SILVA	QUIMICA AMPARO YPE-SP	540	561	0	0	2026-06-16 20:43:16.673807+00
6bf5338a-db09-4e4d-8ada-395d93659d48	2026-06-15	70252	USIEL BRAZ RIBEIRO	QUIMICA AMPARO YPE-SP	540	550	0	0	2026-06-16 20:43:16.673807+00
e89552db-844d-4f30-b209-b9d26dc4c3af	2026-06-15	71109	GILSON COELHO MESSIAS	QUIMICA AMPARO YPE-SP	540	550	0	0	2026-06-16 20:43:16.673807+00
779eb840-9efa-47bf-9c16-148264d484ab	2026-06-15	71110	DIEGO FERREIRA ALVES	QUIMICA AMPARO YPE-SP	540	542	0	0	2026-06-16 20:43:16.673807+00
c59f41fb-5cd0-4a8e-93de-e4e1ba5dabf6	2026-06-15	72113	AILTON OLIVEIRA SOUSA	QUIMICA AMPARO YPE-SP	540	551	0	0	2026-06-16 20:43:16.673807+00
27506451-ed95-4b9e-a8d2-3f7208423808	2026-06-15	72362	GUSTAVO HENRIQUE CARTACHO LIMA DO NASCIMENTO	QUIMICA AMPARO YPE-SP	540	714	0	0	2026-06-16 20:43:16.673807+00
5e837bda-781f-45c3-bc95-6cc484a097e9	2026-06-15	72786	JOSUEL DA SILVA ROCHA	QUIMICA AMPARO YPE-SP	540	0	0	540	2026-06-16 20:43:16.673807+00
c5b74b0d-dece-40e6-94bb-fc668e91656b	2026-06-15	73019	JEIZIEL ALVES SILVA DE ASSIS	QUIMICA AMPARO YPE-SP	540	0	0	540	2026-06-16 20:43:16.673807+00
940412f2-70f0-41a1-88df-c2533c51ec4e	2026-06-15	73163	JOSE HERCULES DA SILVA	QUIMICA AMPARO YPE-SP	540	552	0	0	2026-06-16 20:43:16.673807+00
1e9a6cc9-4abc-4d3c-9412-f88097c30254	2026-06-15	73242	RAFAEL FERREIRA ALVES	QUIMICA AMPARO YPE-SP	540	0	0	540	2026-06-16 20:43:16.673807+00
2b196218-c7b1-4173-9c6a-abdc4d382433	2026-06-15	73569	EMILLE MARIANE CARDOSO RAMOS	QUIMICA AMPARO YPE-SP	540	551	0	0	2026-06-16 20:43:16.673807+00
d55ee5bc-1f97-4c97-8f35-f5356e592b42	2026-06-15	73759	ALAN FERREIRA ALVES	QUIMICA AMPARO YPE-SP	540	0	0	540	2026-06-16 20:43:16.673807+00
591de67a-3ef2-442a-bad0-11ad79158e70	2026-06-15	73944	ANDRE LUIS CASTELO BRANCO	QUIMICA AMPARO YPE-SP	540	671	0	0	2026-06-16 20:43:16.673807+00
3546d766-5165-40ba-ad9f-393ac6694892	2026-06-15	74785	ALTAIR DA SILVA MARTINS	QUIMICA AMPARO YPE-SP	540	552	0	0	2026-06-16 20:43:16.673807+00
a13a5cad-3032-42a2-85bc-5698d1e7b819	2026-06-15	75088	ANTONIO EDNILSON SERAFIM DE OLIVEIRA	QUIMICA AMPARO YPE-SP	540	551	0	0	2026-06-16 20:43:16.673807+00
f3aa1a2c-f743-46ec-8412-459a896fc758	2026-06-15	75193	DIOGO DOS SANTOS ARAUJO	QUIMICA AMPARO YPE-SP	540	549	0	0	2026-06-16 20:43:16.673807+00
18213f27-c058-40ca-971a-1f8b4c66b8ee	2026-06-15	75251	ARTHUR HENRIQUE NICACIO DA SILVA	QUIMICA AMPARO YPE-SP	540	549	0	0	2026-06-16 20:43:16.673807+00
521aac5c-16a2-451b-9d7c-e7069d836d16	2026-06-15	75532	DENIS BARBOSA DOS SANTOS	QUIMICA AMPARO YPE-SP	540	552	0	0	2026-06-16 20:43:16.673807+00
2c88076c-b09d-4cd4-9d63-198ef14e124e	2026-06-15	75550	EDMAR GUILHERMINO DA SILVA	QUIMICA AMPARO YPE-SP	540	0	0	540	2026-06-16 20:43:16.673807+00
78536ce9-ff43-44cd-9e55-9ffa100faa04	2026-06-15	75708	FRANCISCO SANTIAGO DA SILVA	QUIMICA AMPARO YPE-SP	540	551	0	0	2026-06-16 20:43:16.673807+00
cd89a41d-ef32-462b-944d-e4513237c443	2026-06-15	75785	WATILA RODRIGUES MIRANDA	QUIMICA AMPARO YPE-SP	540	556	0	0	2026-06-16 20:43:16.673807+00
549e535c-ccef-485f-bcf0-f6c05e090c92	2026-06-15	75786	GERALDO ALVES PINTO	QUIMICA AMPARO YPE-SP	540	551	0	0	2026-06-16 20:43:16.673807+00
2e850a52-a8d7-4b18-a7fc-bce1bf26e57d	2026-06-15	75787	DEJAILTON JESUS DOS SANTOS	QUIMICA AMPARO YPE-SP	540	550	0	0	2026-06-16 20:43:16.673807+00
68da181c-226c-457f-800d-ec694cbf9b8e	2026-06-15	75797	EVERTON CHAGAS DE QUEIROZ	QUIMICA AMPARO YPE-SP	540	555	0	0	2026-06-16 20:43:16.673807+00
0afd7bbe-cda2-436d-b81a-e067a50de51a	2026-06-15	75798	FABIO LUIZ DE FARIAS	QUIMICA AMPARO YPE-SP	540	556	0	0	2026-06-16 20:43:16.673807+00
697040d6-c78c-4ddb-81d7-0bb91a544a12	2026-06-15	75799	WILLIAM SIDNEY SANTOS	QUIMICA AMPARO YPE-SP	540	554	0	0	2026-06-16 20:43:16.673807+00
76df3fdd-f9dd-48c0-8767-63ed170163f0	2026-06-15	75800	CARLOS HENRIQUE AUGUSTO ARAUJO	QUIMICA AMPARO YPE-SP	540	553	0	0	2026-06-16 20:43:16.673807+00
4a42244a-9dd6-4c27-8b74-caf52d17eeba	2026-06-15	75805	JOSE RENATO DA GLORIA SANTOS	QUIMICA AMPARO YPE-SP	540	554	0	0	2026-06-16 20:43:16.673807+00
59bc2b06-95fe-416f-b0b6-abec18963836	2026-06-15	75808	MARCOS BISPO ASSUNCAO	QUIMICA AMPARO YPE-SP	540	555	0	0	2026-06-16 20:43:16.673807+00
894d2efb-0a78-46fc-857e-be8bab87fb3d	2026-06-15	75809	JONAS DE OLIVEIRA	QUIMICA AMPARO YPE-SP	540	550	0	0	2026-06-16 20:43:16.673807+00
fe185fc8-b79a-47fe-acd5-fe390717d515	2026-06-15	75810	PEDRO JUNIOR CELESTINO DE OLIVEIRA	QUIMICA AMPARO YPE-SP	540	553	0	0	2026-06-16 20:43:16.673807+00
3956b6fe-09b1-4b62-9e99-cdc90637bead	2026-06-15	75811	CRISTIAN FABIO DOS SANTOS DOS REIS	QUIMICA AMPARO YPE-SP	540	554	0	0	2026-06-16 20:43:16.673807+00
4a12a174-4726-4628-a866-017a65b8d17f	2026-06-15	75812	ESMAEL CARLOS NASCIMENTO DOS SANTOS	QUIMICA AMPARO YPE-SP	540	551	0	0	2026-06-16 20:43:16.673807+00
1399bb34-d81f-434a-8bc7-f878e79c0da8	2026-06-15	75813	JADSON SANTOS DOS SANTOS	QUIMICA AMPARO YPE-SP	540	555	0	0	2026-06-16 20:43:16.673807+00
b0d344f5-60c4-485a-a9d5-f486772af997	2026-06-15	75814	RICARDO CESAR COSTA SANTOS	QUIMICA AMPARO YPE-SP	540	553	0	0	2026-06-16 20:43:16.673807+00
466ddf17-9c70-48a3-87d5-c7adb5825b8c	2026-06-15	75815	RONALDO BARBOSA DE OLIVEIRA	QUIMICA AMPARO YPE-SP	540	555	0	0	2026-06-16 20:43:16.673807+00
c253f491-56f2-4a9c-9e27-87afd532ca0e	2026-06-15	75821	MARCILIO NUNES DE SOUSA	QUIMICA AMPARO YPE-SP	540	551	0	0	2026-06-16 20:43:16.673807+00
70952fd9-84a0-4e02-9884-fe88db0a5000	2026-06-15	75822	JOSE MARCELO DE SOUSA	QUIMICA AMPARO YPE-SP	540	555	0	0	2026-06-16 20:43:16.673807+00
1556e0b6-56f8-44fc-a29e-2497fee69fda	2026-06-15	75826	ALEXSANDRO DE CAMPOS	QUIMICA AMPARO YPE-SP	540	550	0	0	2026-06-16 20:43:16.673807+00
32b0c31f-b0fd-4484-92d3-0a0b3abb9418	2026-06-15	75828	ALEX LORENZO MATOS SANTOS	QUIMICA AMPARO YPE-SP	540	551	0	0	2026-06-16 20:43:16.673807+00
8a944ec8-0974-451d-9a99-b002757bf06f	2026-06-15	75829	WARLEM ALVES	QUIMICA AMPARO YPE-SP	540	551	0	0	2026-06-16 20:43:16.673807+00
3f57a12d-ba7a-4907-90ea-99ac2c1782ec	2026-06-15	75830	CLAUDIO ASTRO CARVALHO	QUIMICA AMPARO YPE-SP	540	552	0	0	2026-06-16 20:43:16.673807+00
0d781a43-edea-4872-8240-24b1d36d6539	2026-06-15	75831	ADRIANO FERREIRA GOMES	QUIMICA AMPARO YPE-SP	540	548	0	0	2026-06-16 20:43:16.673807+00
84b716b9-fb0d-4dd5-addd-da674dea11ef	2026-06-15	75833	UBIRAJARA MENDONCA DOS SANTOS	QUIMICA AMPARO YPE-SP	540	546	0	0	2026-06-16 20:43:16.673807+00
da4edfc1-1e05-4004-8bb0-7e3bbcdaa0fe	2026-06-15	75834	JERRI SANTOS DA CONCEICAO PINTO	QUIMICA AMPARO YPE-SP	540	548	0	0	2026-06-16 20:43:16.673807+00
79375f5e-676f-4e69-930f-d3f0c4477104	2026-06-15	75835	LAMEQUE RODRIGUES SILVA SOARES	QUIMICA AMPARO YPE-SP	540	548	0	0	2026-06-16 20:43:16.673807+00
4d0f1dac-54ff-44e4-af1b-487e79306a2c	2026-06-15	75836	JOELSON GONCALVES MARQUES	QUIMICA AMPARO YPE-SP	540	551	0	0	2026-06-16 20:43:16.673807+00
a05c6ee8-9a66-4fdc-b8e6-0f5a474f2ff4	2026-06-15	75837	GERSONIEL SOUSA RODRIGUES	QUIMICA AMPARO YPE-SP	540	547	0	0	2026-06-16 20:43:16.673807+00
bb0459d1-ccb7-4ecc-842e-ea7ad7a43a41	2026-06-15	75841	MARCELO SILVA	QUIMICA AMPARO YPE-SP	540	548	0	0	2026-06-16 20:43:16.673807+00
e0709437-d93d-4f7f-9582-e6765d4579c5	2026-06-15	75846	SIRLEI DA SILVA GILBERTO	QUIMICA AMPARO YPE-SP	540	550	0	0	2026-06-16 20:43:16.673807+00
e2b5dcd9-b68d-4b78-b321-69ee8a8bd363	2026-06-15	75847	GABRIEL OLIVEIRA DOS SANTOS	QUIMICA AMPARO YPE-SP	540	554	0	0	2026-06-16 20:43:16.673807+00
ae89c074-7e99-42bc-a495-82e47616e0f3	2026-06-15	75848	ANTONIO DA SILVA FREITAS	QUIMICA AMPARO YPE-SP	540	551	0	0	2026-06-16 20:43:16.673807+00
83d5de28-1584-40af-9b83-ecc168a76319	2026-06-15	75849	LUIZ GABRIEL DOS SANTOS ATAIDE	QUIMICA AMPARO YPE-SP	540	550	0	0	2026-06-16 20:43:16.673807+00
282a1625-2cc4-43a4-820c-4ece882b2d07	2026-06-15	75850	MARIA DAS GRACAS DOS SANTOS E SILVA	QUIMICA AMPARO YPE-SP	540	552	0	0	2026-06-16 20:43:16.673807+00
ab055715-7898-41d4-b530-1993322c5d13	2026-06-15	75851	ANTONIO SANTOS PORTUGAL	QUIMICA AMPARO YPE-SP	540	555	0	0	2026-06-16 20:43:16.673807+00
bd91d6c6-54bb-443a-89e2-cd40cc7f7e22	2026-06-15	75853	ARGEL QUEIROZ SANTANA	QUIMICA AMPARO YPE-SP	540	546	0	0	2026-06-16 20:43:16.673807+00
774609bd-37c8-40ca-ab8c-acd29135f000	2026-06-15	75854	JORGE HUGO BARBOSA DUARTE	QUIMICA AMPARO YPE-SP	540	547	0	0	2026-06-16 20:43:16.673807+00
cf785b83-6bb9-43e9-8416-b046069443e4	2026-06-15	75855	WASHINGTON LUIS BARBOSA VENTURA JUNIOR	QUIMICA AMPARO YPE-SP	540	545	0	0	2026-06-16 20:43:16.673807+00
abe985b5-769c-454f-b83c-83b36feb92a6	2026-06-15	75864	ANTONIO DAMASCENO NOGUEIRA	QUIMICA AMPARO YPE-SP	540	0	0	540	2026-06-16 20:43:16.673807+00
aa1364bf-72f2-4d48-a05e-f753fbab4372	2026-06-15	75865	KAWANN DOS SANTOS TENORIO FEITOSA	QUIMICA AMPARO YPE-SP	540	550	0	0	2026-06-16 20:43:16.673807+00
63bed044-b903-43de-acde-468637bacad6	2026-06-15	75866	IVANILDO DE JESUS SANTOS	QUIMICA AMPARO YPE-SP	540	549	0	0	2026-06-16 20:43:16.673807+00
51be914c-f846-4d3a-8001-4b1293820f5c	2026-06-15	75867	ROSEMEIRE DE SOUZA MACHADO	QUIMICA AMPARO YPE-SP	540	548	0	0	2026-06-16 20:43:16.673807+00
d67ee032-ee7f-4fd8-9076-971f7aec63ce	2026-06-15	75868	MARCUS VINICIUS SILVA DE OLIVEIRA	QUIMICA AMPARO YPE-SP	540	0	0	540	2026-06-16 20:43:16.673807+00
e7219aee-4c70-4818-85f5-f6b0ff88cb8c	2026-06-15	75879	WENDEL KAIC FREITAS LOPES	QUIMICA AMPARO YPE-SP	540	0	540	0	2026-06-16 20:43:16.673807+00
ea5fb0d4-2ac0-4ae4-8772-99d087e61851	2026-06-15	75880	NAIRAN DOS SANTOS	QUIMICA AMPARO YPE-SP	540	549	0	0	2026-06-16 20:43:16.673807+00
e21a7ed8-6e07-4d06-926a-d8e2cead4d9b	2026-06-15	75887	NIVALDO MANUEL DOS SANTOS	QUIMICA AMPARO YPE-SP	540	551	0	0	2026-06-16 20:43:16.673807+00
e7e790f3-3c05-40ac-be79-bacc842f9e90	2026-06-15	75888	PAULO RANGEL DE SA PACHECO	QUIMICA AMPARO YPE-SP	540	553	0	0	2026-06-16 20:43:16.673807+00
541b1589-75ab-4491-98bb-47dadb3b8231	2026-06-15	75889	FRANCISCO WELLINGTON SILVA LEITE	QUIMICA AMPARO YPE-SP	540	546	0	0	2026-06-16 20:43:16.673807+00
c8067151-1fe2-46f0-97d8-74361c3220b3	2026-06-15	75891	JOÃO PAULO DO CARMO	QUIMICA AMPARO YPE-SP	540	548	0	0	2026-06-16 20:43:16.673807+00
\.


--
-- Data for Name: efetivo_presenca; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.efetivo_presenca (id, data, cracha, nome, departamento, horario_entrada, marcacao, situacao, obra_id, created_at, marcacoes) FROM stdin;
68ef3861-ac78-4faa-ab1e-790991b3ca92	2026-06-18	616	JOAO TAVARES DE SENA	SYNGENTA GUARDA-CHUVA	07:00	\N	PRESENTE	\N	2026-06-18 20:19:47.476612+00	06:49
511e5815-ba0b-4e7e-ac0d-5118e2c33dcb	2026-06-18	10044	ADILSON DOS SANTOS	SYNGENTA GUARDA-CHUVA	07:00	\N	PRESENTE	\N	2026-06-18 20:19:47.476612+00	06:55
4ba183b2-36f5-48ad-a8a8-c7d49aac2d90	2026-06-18	10615	PAULO GILSON DA SILVA	DAICHII FILIAL	07:00	\N	PRESENTE	\N	2026-06-18 20:19:47.476612+00	06:59
1e485f54-104a-4d0f-81de-273598b0cc96	2026-06-18	10620	RAIMUNDO NONATO DO NASCIMENTO SANTOS	QUIMICA AMPARO YPE-SP	07:00	\N	PRESENTE	\N	2026-06-18 20:19:47.476612+00	06:51
eaea34c1-a099-4466-86bf-3ec32a63f0bb	2026-06-18	20570	DANIEL PEREIRA DE SOUSA	EMBRAER PUTIM FILIAL	07:00	\N	PRESENTE	\N	2026-06-18 20:19:47.476612+00	06:54
f9e67018-bd9d-41fe-a9bd-4cc8dbd35faa	2026-06-18	20885	JOÃO RAIMUNDO DA CRUZ	EMBRAER PUTIM FILIAL	07:00	\N	PRESENTE	\N	2026-06-18 20:19:47.476612+00	06:51
2f320b63-d852-453d-8f20-9ba997a3b71d	2026-06-18	30366	JOSE AUGUSTO FRANCISCO DE SOUZA	QUIMICA AMPARO YPE-SP	07:00	\N	PRESENTE	\N	2026-06-18 20:19:47.476612+00	06:59
91dc8519-cca1-4795-b18e-197025437ffa	2026-06-18	30670	JOAO MARCIO GUILHERMINO SILVA	QUIMICA AMPARO YPE-SP	07:00	\N	PRESENTE	\N	2026-06-18 20:19:47.476612+00	06:50
bff0896d-38fa-48c7-8233-0380154c07c3	2026-06-18	60480	JOSE VALDIR DA SILVA	EMBRAER PUTIM FILIAL	07:00	\N	PRESENTE	\N	2026-06-18 20:19:47.476612+00	07:02
ebc71bdd-90b3-448a-8bff-ccd1480a3c8b	2026-06-18	60598	CHRISTIAN MAGNO FRANCELINO DA SILVA	OBRAS	07:00	\N	PRESENTE	\N	2026-06-18 20:19:47.476612+00	17:00
54237ac3-d4fc-4203-96e5-0e0d6b634236	2026-06-18	70156	JOSE CARLOS PEREIRA DOS SANTOS	SYNGENTA GUARDA-CHUVA	07:00	\N	PRESENTE	\N	2026-06-18 20:19:47.476612+00	06:54
d64dbd5a-d297-4092-941a-b79edbad911c	2026-06-18	70201	CARLOS JOSE RODRIGUES	DAICHII FILIAL	07:00	\N	PRESENTE	\N	2026-06-18 20:19:47.476612+00	06:50
4fec8c21-c1bc-4928-ac0d-5f17526d0f37	2026-06-18	70252	USIEL BRAZ RIBEIRO	QUIMICA AMPARO YPE-SP	07:00	\N	PRESENTE	\N	2026-06-18 20:19:47.476612+00	06:52
c9adfbdb-6750-4e05-8625-4e4cffb10bb3	2026-06-18	70908	IVANILDO DANIEL PEREIRA NICACIO	Embraer Botucatu Filial	07:15	\N	PRESENTE	\N	2026-06-18 20:19:47.476612+00	07:08
47e94fae-fd44-4d9e-a7e9-f6ca852b8d6f	2026-06-18	70924	ADMAR CESAR COLA	COAMO AGROINDUSTRIAL	07:00	\N	PRESENTE	\N	2026-06-18 20:19:47.476612+00	06:56
20315aca-5a0e-40a2-aa68-e15ff2784f48	2026-06-18	70969	EDSON JOSÉ NOGUEIRA	SYNGENTA GUARDA-CHUVA	07:00	\N	PRESENTE	\N	2026-06-18 20:19:47.476612+00	06:49
1f895965-ade1-4700-894b-6aa5932008d0	2026-06-18	71109	GILSON COELHO MESSIAS	QUIMICA AMPARO YPE-SP	07:00	\N	PRESENTE	\N	2026-06-18 20:19:47.476612+00	06:52
2a7bb3fc-2b3d-4783-9d21-ff8996856b8a	2026-06-18	71110	DIEGO FERREIRA ALVES	QUIMICA AMPARO YPE-SP	07:00	\N	PRESENTE	\N	2026-06-18 20:19:47.476612+00	06:55
66860d7c-1a3b-474a-a08a-cd09ce41db00	2026-06-18	71432	DAVID LUCAS SANTOS PEREIRA	Embraer Botucatu Filial	07:15	\N	PRESENTE	\N	2026-06-18 20:19:47.476612+00	07:02
cf962eb9-7236-4c8a-aaf4-05b505c5e55c	2026-06-16	71110	DIEGO FERREIRA ALVES	QUIMICA AMPARO YPE-SP	07:00	\N	PRESENTE	\N	2026-06-16 19:38:01.934949+00	06:54
4375e4c9-4eef-4169-b5b0-670ba07ea8a4	2026-06-16	72362	GUSTAVO HENRIQUE CARTACHO LIMA DO NASCIMENTO	QUIMICA AMPARO YPE-SP	07:00	\N	PRESENTE	\N	2026-06-16 19:38:01.934949+00	06:55
4056ded8-500b-4e11-ac91-c87b1691e138	2026-06-16	73019	JEIZIEL ALVES SILVA DE ASSIS	QUIMICA AMPARO YPE-SP	07:00	\N	PRESENTE	\N	2026-06-16 19:38:01.934949+00	06:52
3dada291-7ab4-4103-9483-e9ada684205d	2026-06-16	73569	EMILLE MARIANE CARDOSO RAMOS	QUIMICA AMPARO YPE-SP	07:00	\N	PRESENTE	\N	2026-06-16 19:38:01.934949+00	06:54
58e38e44-a49d-4bb4-9e20-cae6ec629b6d	2026-06-16	73944	ANDRE LUIS CASTELO BRANCO	QUIMICA AMPARO YPE-SP	07:00	\N	PRESENTE	\N	2026-06-16 19:38:01.934949+00	06:56
36bed470-7fa5-4f08-a7d4-87206cf9c9c1	2026-06-16	75785	WATILA RODRIGUES MIRANDA	QUIMICA AMPARO YPE-SP	07:00	\N	PRESENTE	\N	2026-06-16 19:38:01.934949+00	06:53
6ca3a2e9-cc61-494b-9423-0b005b8d3355	2026-06-16	75786	GERALDO ALVES PINTO	QUIMICA AMPARO YPE-SP	07:00	\N	PRESENTE	\N	2026-06-16 19:38:01.934949+00	06:52
4fbe3d45-dd4e-4451-82e9-b82e8e86eaff	2026-06-16	75800	CARLOS HENRIQUE AUGUSTO ARAUJO	QUIMICA AMPARO YPE-SP	07:00	\N	PRESENTE	\N	2026-06-16 19:38:01.934949+00	06:54
bc078fb9-fbb3-4470-a8c3-8f4e799efd53	2026-06-16	75821	MARCILIO NUNES DE SOUSA	QUIMICA AMPARO YPE-SP	07:00	\N	PRESENTE	\N	2026-06-16 19:38:01.934949+00	06:52
e5619af0-4db8-41ea-9b68-c326fe8daa86	2026-06-16	75835	LAMEQUE RODRIGUES SILVA SOARES	QUIMICA AMPARO YPE-SP	07:00	\N	PRESENTE	\N	2026-06-16 19:38:01.934949+00	06:52
660c5475-76aa-4a22-bf7c-11a48501ed70	2026-06-16	75836	JOELSON GONCALVES MARQUES	QUIMICA AMPARO YPE-SP	07:00	\N	PRESENTE	\N	2026-06-16 19:38:01.934949+00	06:57
6f863cfd-8598-4aa7-9288-877fd2f1c8ea	2026-06-16	75851	ANTONIO SANTOS PORTUGAL	QUIMICA AMPARO YPE-SP	07:00	\N	PRESENTE	\N	2026-06-16 19:38:01.934949+00	06:53
7414f59e-be98-4c58-a439-3eac825e70dc	2026-06-16	75880	NAIRAN DOS SANTOS	QUIMICA AMPARO YPE-SP	07:00	\N	PRESENTE	\N	2026-06-16 19:38:01.934949+00	06:59
de60edea-b7ac-49fd-8d6a-a2f527a209b8	2026-06-18	71687	CICERO ROMAO MONTEIRO	SYNGENTA GUARDA-CHUVA	07:00	\N	PRESENTE	\N	2026-06-18 20:19:47.476612+00	06:54
2fe35944-98b8-407a-b0e1-de9689207038	2026-06-18	71810	MATHEUS FERREIRA ALVES	COAMO AGROINDUSTRIAL	07:00	\N	PRESENTE	\N	2026-06-18 20:19:47.476612+00	06:58
7a9a5424-b773-46c3-9e86-c28d3187dae5	2026-06-18	72066	LEVY STTÊVÃO LIMA AMORIM	COAMO AGROINDUSTRIAL	07:00	\N	PRESENTE	\N	2026-06-18 20:19:47.476612+00	06:58
453fe325-5c02-4bd4-9f89-f0ce4239d4ac	2026-06-18	72113	AILTON OLIVEIRA SOUSA	QUIMICA AMPARO YPE-SP	07:00	\N	PRESENTE	\N	2026-06-18 20:19:47.476612+00	06:54
3eb6aa2a-556b-4685-9754-00b600a1081e	2026-06-18	72216	MARCOS SALLES FERREIRA	SYNGENTA GUARDA-CHUVA	07:00	\N	PRESENTE	\N	2026-06-18 20:19:47.476612+00	06:54
843a56a6-1012-44da-a6de-3a9413faf78e	2026-06-18	72222	ELTES JOSE MORENO	COAMO AGROINDUSTRIAL	07:00	\N	PRESENTE	\N	2026-06-18 20:19:47.476612+00	06:59
f7218d6a-6bb1-4dd2-b756-68bb71362ea4	2026-06-18	72246	GLEIBSON DO NASCIMENTO FERNANDO	COAMO AGROINDUSTRIAL	07:00	\N	PRESENTE	\N	2026-06-18 20:19:47.476612+00	06:56
9644110c-d919-4fd5-b61a-89d752b1b2ac	2026-06-18	72362	GUSTAVO HENRIQUE CARTACHO LIMA DO NASCIMENTO	QUIMICA AMPARO YPE-SP	07:00	\N	PRESENTE	\N	2026-06-18 20:19:47.476612+00	06:59
213576ab-92a8-47fc-98a1-82d6eb43d0be	2026-06-18	72401	BRUNO LIMA DE MORAES	EMBRAER PUTIM FILIAL	07:00	\N	PRESENTE	\N	2026-06-18 20:19:47.476612+00	06:51
c01578b9-bd4e-477f-aed7-e56dff3eba0f	2026-06-18	72527	GENECI FERREIRA DE RESENDE	COAMO AGROINDUSTRIAL	07:00	\N	PRESENTE	\N	2026-06-18 20:19:47.476612+00	06:59
f137e128-e9cc-4be8-ba4d-1b38f18a0345	2026-06-18	72803	FRANCISCO DOMINGOS SILVA DOS ANJOS	EMBRAER PUTIM FILIAL	07:00	\N	PRESENTE	\N	2026-06-18 20:19:47.476612+00	06:50
20d40f63-d909-4f0f-8a39-d991f21f838f	2026-06-18	73019	JEIZIEL ALVES SILVA DE ASSIS	QUIMICA AMPARO YPE-SP	07:00	\N	PRESENTE	\N	2026-06-18 20:19:47.476612+00	06:55
69ebc2ad-6132-4953-afef-2a7ef5e4c8df	2026-06-18	73163	JOSE HERCULES DA SILVA	QUIMICA AMPARO YPE-SP	07:00	\N	PRESENTE	\N	2026-06-18 20:19:47.476612+00	06:54
02330b9b-ef29-4222-b462-a27fde6adfbd	2026-06-18	73254	CAUAN DE AQUINO	DAICHII FILIAL	07:00	\N	PRESENTE	\N	2026-06-18 20:19:47.476612+00	07:00
12c590b8-70e0-4ba6-a6c4-687eb0fc30b9	2026-06-18	73302	PEDRO FIDELIS DOS SANTOS	Embraer Botucatu Filial	07:15	\N	PRESENTE	\N	2026-06-18 20:19:47.476612+00	07:18
29ac5f7b-3bac-4371-b6b1-d9bde408caad	2026-06-18	73309	TIAGO CRUZ DA SILVA	Embraer GPX FILIAL	07:20	\N	PRESENTE	\N	2026-06-18 20:19:47.476612+00	07:25
c4004250-9560-4e83-8d64-cdac8e50e066	2026-06-18	73332	BRUNO DA CRUZ RODRIGUES	SYNGENTA GUARDA-CHUVA	07:00	\N	PRESENTE	\N	2026-06-18 20:19:47.476612+00	06:54
ef3f8970-a2d2-46b2-ad11-68abee4fc8bb	2026-06-18	73402	JOHNNY RODOLFO FERREIRA DA SILVA	Embraer Botucatu Filial	07:15	\N	PRESENTE	\N	2026-06-18 20:19:47.476612+00	07:17
15740ebd-927c-47de-8da9-36c291bdf095	2026-06-18	73504	JURANDIR DA SILVA BARAUNA	DAICHII FILIAL	07:00	\N	PRESENTE	\N	2026-06-18 20:19:47.476612+00	06:54
c4bc1484-612f-46cf-876e-23817b55cdb4	2026-06-18	73557	ANTONIO JOSE DOS SANTOS	SYNGENTA GUARDA-CHUVA	07:00	\N	PRESENTE	\N	2026-06-18 20:19:47.476612+00	06:55
7e5a6433-3130-4ad3-b21f-de2e6c81cecd	2026-06-18	73569	EMILLE MARIANE CARDOSO RAMOS	QUIMICA AMPARO YPE-SP	07:00	\N	PRESENTE	\N	2026-06-18 20:19:47.476612+00	06:59
1b855d82-9534-4c56-8695-7d96d8b0ff10	2026-06-18	73599	ALEXANDRE JURANDIR BRUDER	Embraer Botucatu Filial	07:15	\N	PRESENTE	\N	2026-06-18 20:19:47.476612+00	07:11
6c850dad-8243-4a62-8ada-99956f0df5e2	2026-06-18	73877	RAFAELLE MALACARNE	COAMO AGROINDUSTRIAL	07:00	\N	PRESENTE	\N	2026-06-18 20:19:47.476612+00	06:58
a7f790db-6a8e-4223-bc85-c9b923535ac1	2026-06-18	73887	REGINALDO FRANCISCO DE MORAES	COAMO AGROINDUSTRIAL	07:00	\N	PRESENTE	\N	2026-06-18 20:19:47.476612+00	06:58
111541c1-9204-49c1-9b48-f6d11658a4a2	2026-06-18	73929	JOAO PAULO BALIZA MUNDIM	DAICHII FILIAL	07:00	\N	PRESENTE	\N	2026-06-18 20:19:47.476612+00	06:59
a250b66f-5367-4164-9d62-3cfbb4071d17	2026-06-18	73944	ANDRE LUIS CASTELO BRANCO	QUIMICA AMPARO YPE-SP	07:00	\N	PRESENTE	\N	2026-06-18 20:19:47.476612+00	06:54
b7d005f3-6883-4932-83bc-13188dc74d99	2026-06-18	73958	BRUNO VANDERLEI CALACA	EMBRAER PUTIM FILIAL	07:00	\N	PRESENTE	\N	2026-06-18 20:19:47.476612+00	06:59
3bd0c6ac-635c-4598-95ef-9823933dd097	2026-06-18	73975	ANDREI LUCAS REIS BARBOSA	EMBRAER PUTIM FILIAL	07:00	\N	PRESENTE	\N	2026-06-18 20:19:47.476612+00	06:50
41f1760f-f6aa-466f-9ed0-041c5f3f3b4c	2026-06-18	74137	PEDRO HENRIQUE DA CUNHA ALVES	EMBRAER PUTIM FILIAL	07:00	\N	PRESENTE	\N	2026-06-18 20:19:47.476612+00	06:51
3579d7cb-2a23-46fe-a5e3-bb314fbb57ca	2026-06-18	74140	HUMBERTO DEMETRIUS BARBOSA	EMBRAER PUTIM FILIAL	07:00	\N	PRESENTE	\N	2026-06-18 20:19:47.476612+00	06:54
c82b701c-767c-41e2-87b4-edebabadcf80	2026-06-18	74207	LUIZ CARLOS SARAIVA CALIXTO	DAICHII FILIAL	07:00	\N	PRESENTE	\N	2026-06-18 20:19:47.476612+00	06:56
f7f59fe7-b348-4e77-b5a6-5f1e120d9310	2026-06-18	74250	ALDAIR DA SILVA OLIVEIRA	DAICHII FILIAL	07:00	\N	PRESENTE	\N	2026-06-18 20:19:47.476612+00	06:49
c6ae1366-3212-4b30-954c-ef681e26e1fa	2026-06-18	74347	JEFFERSON APARECIDO PALMARIM	Embraer Botucatu Filial	07:15	\N	PRESENTE	\N	2026-06-18 20:19:47.476612+00	07:35
da7226c6-f348-47dd-8b37-53e1776633ea	2026-06-18	74785	ALTAIR DA SILVA MARTINS	QUIMICA AMPARO YPE-SP	07:00	\N	PRESENTE	\N	2026-06-18 20:19:47.476612+00	06:54
49425e33-467f-4cb3-857f-9bf884be0b6c	2026-06-18	74846	JOSE EDUARDO DA SILVA SIQUEIRA	SYNGENTA GUARDA-CHUVA	07:00	\N	PRESENTE	\N	2026-06-18 20:19:47.476612+00	06:53
04847eba-3aca-4cd1-ad09-25832cf3dde8	2026-06-18	74847	DANIEL FEITOSA DOS SANTOS	SYNGENTA GUARDA-CHUVA	07:00	\N	PRESENTE	\N	2026-06-18 20:19:47.476612+00	06:54
91225563-fcbb-4f64-b3bc-a078a1df5663	2026-06-18	74854	OZIEL ANDERSON DOS SANTOS	SYNGENTA GUARDA-CHUVA	07:00	\N	PRESENTE	\N	2026-06-18 20:19:47.476612+00	06:50
3f00f59b-8b16-4be0-9e83-6034382624ce	2026-06-18	74857	PAULO RODRIGO PEREIRA PACHECO	SYNGENTA GUARDA-CHUVA	07:00	\N	PRESENTE	\N	2026-06-18 20:19:47.476612+00	06:53
409c3d2e-7d17-42ea-bb29-410efe15f59a	2026-06-18	74869	ADAILSON DOS SANTOS MATOS	SYNGENTA GUARDA-CHUVA	07:00	\N	PRESENTE	\N	2026-06-18 20:19:47.476612+00	06:54
5be68fd7-217e-435d-804e-d044df9750f5	2026-06-18	74985	MARCOS VINICIUS FERNANDES SEVERO	EMBRAER PUTIM FILIAL	07:00	\N	PRESENTE	\N	2026-06-18 20:19:47.476612+00	06:51
d1bfb825-2f5b-42a4-8998-9ad1abc3c203	2026-06-18	74995	LUIZ ANGELO DOS SANTOS	EMBRAER PUTIM FILIAL	07:00	\N	PRESENTE	\N	2026-06-18 20:19:47.476612+00	06:50
eb370d34-dfb1-4640-acf9-b8d2e2159358	2026-06-18	75088	ANTONIO EDNILSON SERAFIM DE OLIVEIRA	QUIMICA AMPARO YPE-SP	07:00	\N	PRESENTE	\N	2026-06-18 20:19:47.476612+00	06:57
f5fc7d8f-914f-4080-ad09-c95c77a38693	2026-06-18	75090	DARIO RODRIGUES PEREIRA DE SA	EMBRAER PUTIM FILIAL	07:00	\N	PRESENTE	\N	2026-06-18 20:19:47.476612+00	06:53
ccb4d1f7-c658-49f7-9b39-205679edbfc3	2026-06-18	75132	THIAGO RODRIGUES DE BRITO	SYNGENTA GUARDA-CHUVA	07:00	\N	PRESENTE	\N	2026-06-18 20:19:47.476612+00	06:54
a01462df-c9f4-4abe-a98c-6e82f4b946ce	2026-06-18	75158	FRANCISCO IDEON DE CARVALHO	COAMO AGROINDUSTRIAL	07:00	\N	PRESENTE	\N	2026-06-18 20:19:47.476612+00	06:58
c4578fa4-5a96-44d9-8e53-e72e3fe25be5	2026-06-18	75172	JOSE MARQUES FERREIRA NETO	DAICHII FILIAL	07:00	\N	PRESENTE	\N	2026-06-18 20:19:47.476612+00	06:50
4bba83b0-cb38-490a-97f9-e686534cb634	2026-06-18	75189	ROGERIO LEMES DE MOURA	Embraer Botucatu Filial	07:15	\N	PRESENTE	\N	2026-06-18 20:19:47.476612+00	07:12
bdc72158-a6e9-439d-932d-366adf4770ac	2026-06-18	75193	DIOGO DOS SANTOS ARAUJO	QUIMICA AMPARO YPE-SP	07:00	\N	PRESENTE	\N	2026-06-18 20:19:47.476612+00	06:54
e10e3acb-fe1d-4136-9701-fa2a3f05a94a	2026-06-18	75251	ARTHUR HENRIQUE NICACIO DA SILVA	QUIMICA AMPARO YPE-SP	07:00	\N	PRESENTE	\N	2026-06-18 20:19:47.476612+00	06:52
93bef910-abcd-424d-a2c9-c4dc8911ad00	2026-06-18	75298	GILMAR ALVES AMARO	Embraer Botucatu Filial	07:15	\N	PRESENTE	\N	2026-06-18 20:19:47.476612+00	07:17
ec685213-0820-4df9-9a3a-9f8cb231e13d	2026-06-18	75338	FRANCISCO OLIVEIRA DA SILVA	Embraer Botucatu Filial	07:15	\N	PRESENTE	\N	2026-06-18 20:19:47.476612+00	07:19
63041c6f-3ec6-47ca-ab57-8348cda593d2	2026-06-18	75353	WESLEY RENIER ALVES DA SILVA	Embraer Botucatu Filial	07:15	\N	PRESENTE	\N	2026-06-18 20:19:47.476612+00	07:18
6b55a478-7e5e-4381-b65d-ccb17a1fa324	2026-06-18	75385	IGLESSE ALMEIDA DO NASCIMENTO	DAICHII FILIAL	07:00	\N	PRESENTE	\N	2026-06-18 20:19:47.476612+00	06:56
3e65ceeb-32f5-46a0-ae71-68a67466520c	2026-06-18	75434	DIEGO RODRIGUES DE MORAES	EMBRAER PUTIM FILIAL	07:00	\N	PRESENTE	\N	2026-06-18 20:19:47.476612+00	06:50
26cb6e1d-21ae-470f-8357-759e0cf9a431	2026-06-18	75467	DENNYS HENRIQUE JOSE DA SILVA	DAICHII FILIAL	07:00	\N	PRESENTE	\N	2026-06-18 20:19:47.476612+00	07:00
cfdc7b5d-60cc-40b3-87cb-7c4ced71ee42	2026-06-18	75502	ANDRESA PINTO	DAICHII FILIAL	07:00	\N	PRESENTE	\N	2026-06-18 20:19:47.476612+00	07:03
5a9c6f36-72b1-4b46-948e-32a6e0eaa6fc	2026-06-18	75509	VINICIUS GABRIEL PETRIN CICONE	Embraer Botucatu Filial	07:15	\N	PRESENTE	\N	2026-06-18 20:19:47.476612+00	07:18
8f2aced6-ad49-476c-8acb-215cc1664676	2026-06-18	75532	DENIS BARBOSA DOS SANTOS	QUIMICA AMPARO YPE-SP	07:00	\N	PRESENTE	\N	2026-06-18 20:19:47.476612+00	06:56
4f35826c-d1dd-4eb2-9f34-cfbbbb591daa	2026-06-17	40638	EDENILTON MACEDO SANTOS	RH 47.144.548.0001-79	07:00	\N	PRESENTE	\N	2026-06-17 17:07:36.630898+00	06:51
52a8275c-5971-45d4-b1d9-0605bb60bb38	2026-06-17	50930	ARTHUR VINICIUS LISBOA DA SILVA	RH 47.144.548.0001-79	07:00	\N	PRESENTE	\N	2026-06-17 17:07:36.630898+00	06:52
9136c855-96b2-4d4d-b2a5-412383fa1234	2026-06-17	60853	ALAN CRISTIAN BATISTA MOREIRA	RH 47.144.548.0001-79	07:00	\N	PRESENTE	\N	2026-06-17 17:07:36.630898+00	06:51
349f004e-6d60-46e4-aa46-e7a3f0bedc44	2026-06-17	70768	ANAILTON DOS SANTOS CHAGAS	RH 47.144.548.0001-79	07:00	\N	PRESENTE	\N	2026-06-17 17:07:36.630898+00	07:07
9c7201d7-478a-4c53-b15c-ee9c94e363e5	2026-06-17	71040	ELIZIER JOSUE DE OLIVEIRA	RH 47.144.548.0001-79	07:00	\N	PRESENTE	\N	2026-06-17 17:07:36.630898+00	06:54
4efad512-3a72-4a61-a50f-b3d42c4e6f3e	2026-06-17	71288	JOSE GERNANDE DA SILVA	RH 47.144.548.0001-79	07:00	\N	PRESENTE	\N	2026-06-17 17:07:36.630898+00	06:52
c9d7fb74-53b6-4470-8dff-b300c7e9681e	2026-06-17	73463	WELITON BASTIAO PEREIRA DOS SANTOS	RH 47.144.548.0001-79	07:00	\N	PRESENTE	\N	2026-06-17 17:07:36.630898+00	06:51
af8c7d3f-c2b5-4a7d-8580-4fe9561ba779	2026-06-17	73643	JOSE ADRIANO RODRIGUES DE MENDONÇA	RH 47.144.548.0001-79	07:00	\N	PRESENTE	\N	2026-06-17 17:07:36.630898+00	06:52
9e57df81-7693-4bdc-ade2-6746b1996dd2	2026-06-17	74351	ALEXANDRE YASUO E GUSHIKEM	RH 47.144.548.0001-79	07:00	\N	PRESENTE	\N	2026-06-17 17:07:36.630898+00	06:51
1e0a034d-edf8-4c57-b3d0-f09d3a5ecf73	2026-06-17	74819	PAULO RICARDO PEREIRA SANTOS	RH 47.144.548.0001-79	07:00	\N	PRESENTE	\N	2026-06-17 17:07:36.630898+00	07:07
9141e11c-d665-4930-aae6-fdfdef5c15e5	2026-06-17	74948	JOSE SERGIO DOS SANTOS	RH 47.144.548.0001-79	07:00	\N	PRESENTE	\N	2026-06-17 17:07:36.630898+00	06:52
5a8bf839-0dbe-4e3d-8822-838f47adb85c	2026-06-17	75207	ANTONIO DE JESUS DA CONCEIÇAO	RH 47.144.548.0001-79	07:00	\N	PRESENTE	\N	2026-06-17 17:07:36.630898+00	06:52
658d7495-09c3-4d38-9dc8-41ee70ab1be7	2026-06-17	75252	EDSON ALVES BARBOSA	RH 47.144.548.0001-79	07:00	\N	PRESENTE	\N	2026-06-17 17:07:36.630898+00	06:54
e3f229bb-f71b-482a-8c5e-84a74972c0a6	2026-06-17	75442	PAULO CESAR FELISBINO	RH 47.144.548.0001-79	07:00	\N	PRESENTE	\N	2026-06-17 17:07:36.630898+00	06:51
e779979d-6739-4d47-8486-f2ff06d2d431	2026-06-17	75618	UEIDRISSON ANDREI PEREIRA GOMES	RH 47.144.548.0001-79	07:00	\N	PRESENTE	\N	2026-06-17 17:07:36.630898+00	06:50
627eb27e-b49e-41b3-9b1c-f5209504f101	2026-06-17	75620	LUIZ HENRIQUE FELISBINO	RH 47.144.548.0001-79	07:00	\N	PRESENTE	\N	2026-06-17 17:07:36.630898+00	07:14
e13b4bcf-8b15-4701-9a78-0563fa594188	2026-06-17	75627	WESLEY BESSA DE OLIVEIRA	RH 47.144.548.0001-79	07:00	\N	PRESENTE	\N	2026-06-17 17:07:36.630898+00	06:52
cf20e982-79ff-413f-9bf7-27a4f309c110	2026-06-17	75649	GUSTAVO ALCANTARA MENEZES	RH 47.144.548.0001-79	07:00	\N	PRESENTE	\N	2026-06-17 17:07:36.630898+00	06:51
9a47423c-383d-4b0f-948a-31eed905f741	2026-06-17	75650	MIKAEL DE LIMA BRITO	RH 47.144.548.0001-79	07:00	\N	PRESENTE	\N	2026-06-17 17:07:36.630898+00	06:58
6c6b3f0e-94d6-4935-95ab-baa20d2b07dc	2026-06-17	75651	KAUA RODRIGUES CARDOSO	RH 47.144.548.0001-79	07:00	\N	PRESENTE	\N	2026-06-17 17:07:36.630898+00	06:52
5e6acf7e-2ea6-4be7-a5c5-15602d838e72	2026-06-17	75727	SUELLEN MICHAELA DE MOURA UEMOTO	RH 47.144.548.0001-79	07:00	\N	PRESENTE	\N	2026-06-17 17:07:36.630898+00	06:56
0fc0eec1-e868-401a-b71a-456ab27495ef	2026-06-17	75765	FRANCISCA RAQUEL DA SILVA	RH 47.144.548.0001-79	07:00	\N	PRESENTE	\N	2026-06-17 17:07:36.630898+00	06:54
0f996a57-5315-46bb-9bda-fb3fb8034a5f	2026-06-18	75550	EDMAR GUILHERMINO DA SILVA	QUIMICA AMPARO YPE-SP	07:00	\N	PRESENTE	\N	2026-06-18 20:19:47.476612+00	06:58
afe8149b-a1f7-4310-97e6-0c4790701ddb	2026-06-18	75552	ABRAAO DOUGLAS GONCALVES DA ROCHA	Embraer Botucatu Filial	07:15	\N	PRESENTE	\N	2026-06-18 20:19:47.476612+00	07:19
c9136afb-4324-4fd7-b9bb-92d6fb370284	2026-06-18	75573	GUILHERME VINICIUS FERREIRA DOS SANTOS	EMBRAER PUTIM FILIAL	07:00	\N	PRESENTE	\N	2026-06-18 20:19:47.476612+00	06:50
336c39ed-418b-4d3c-861f-5d7bb58df71f	2026-06-18	75575	LUCIANO GABRIEL PERES PAULINO	EMBRAER PUTIM FILIAL	07:00	\N	PRESENTE	\N	2026-06-18 20:19:47.476612+00	07:03
e225ea2c-b7c4-420b-9d49-d1f8c890309a	2026-06-18	75581	FRANKLIN DE MELO SOARES	EMBRAER PUTIM FILIAL	07:00	\N	PRESENTE	\N	2026-06-18 20:19:47.476612+00	07:00
60ec5a00-38fb-4986-b62d-6d7ed36225eb	2026-06-18	75583	BRYAN OLIVEIRA PALMARIM	Embraer Botucatu Filial	07:15	\N	PRESENTE	\N	2026-06-18 20:19:47.476612+00	07:19
110df417-52e0-4a89-a910-5c6746c407fa	2026-06-18	75584	VINICIUS APARECIDO FERREIRA DE OLIVEIRA	Embraer Botucatu Filial	07:15	\N	PRESENTE	\N	2026-06-18 20:19:47.476612+00	07:19
1bb70e66-32b8-4ddd-951a-4bae8de28aee	2026-06-18	75585	JOSE FERNANDO SALVADOR	EMBRAER PUTIM FILIAL	07:00	\N	PRESENTE	\N	2026-06-18 20:19:47.476612+00	06:50
68316c1b-c80a-435e-ae77-3b3dc5d576f7	2026-06-18	75591	JONATHAN FELIPE CLETO DA SILVA	EMBRAER PUTIM FILIAL	07:00	\N	PRESENTE	\N	2026-06-18 20:19:47.476612+00	06:59
7a73a376-e5db-46ad-89a6-25de6f766b7b	2026-06-18	75592	HUELBERT MOISES DE OLIVEIRA	DAICHII FILIAL	07:00	\N	PRESENTE	\N	2026-06-18 20:19:47.476612+00	06:52
1cdd4aad-b432-4c8e-8bd7-03962902a6d6	2026-06-18	75593	FABIO RODRIGO SANTANA DA SILVA ROCHA	EMBRAER PUTIM FILIAL	07:00	\N	PRESENTE	\N	2026-06-18 20:19:47.476612+00	06:52
f8bc71fd-ff40-4ea1-aafe-2a0d836fe265	2026-06-18	75621	ALAN DOMINGUES BARBOSA	SYNGENTA GUARDA-CHUVA	07:00	\N	PRESENTE	\N	2026-06-18 20:19:47.476612+00	07:22
d11e5d49-e250-4e1c-ac62-c57b2b051818	2026-06-18	75628	HUDSON NASCIMENTO ALVES DA CRUZ	Embraer Botucatu Filial	07:15	\N	PRESENTE	\N	2026-06-18 20:19:47.476612+00	07:20
63e91bdb-eede-4931-8674-faaaf5fec7f8	2026-06-18	75637	ANA CRISTINA LEAL BITTENCOURT	Embraer Botucatu Filial	08:00	\N	PRESENTE	\N	2026-06-18 20:19:47.476612+00	08:04
123fba71-7da9-4456-ad84-5009199d460c	2026-06-18	75687	ROZILMA DE SOUZA CESAR	DAICHII FILIAL	07:00	\N	PRESENTE	\N	2026-06-18 20:19:47.476612+00	06:59
f552dcb6-184a-45f3-9128-8b38bfa18e5e	2026-06-18	75693	DAVID MAKLIN DOS ANJOS OLIVEIRA	SYNGENTA GUARDA-CHUVA	07:00	\N	PRESENTE	\N	2026-06-18 20:19:47.476612+00	06:40
b5e0f71d-0ac1-4006-8d39-07f8b1e613da	2026-06-18	75699	LUIS FERNANDO DIAS LOUZEIRO	SYNGENTA GUARDA-CHUVA	07:00	\N	PRESENTE	\N	2026-06-18 20:19:47.476612+00	06:49
44eb0846-8d4d-4df7-bfa0-9325f7159b42	2026-06-18	75708	FRANCISCO SANTIAGO DA SILVA	QUIMICA AMPARO YPE-SP	07:00	\N	PRESENTE	\N	2026-06-18 20:19:47.476612+00	06:56
ecf3c659-7bb3-4836-9dd7-bf9c1d32e870	2026-06-18	75723	GIOVANI MAZZALI BELISSIMO	EMBRAER PUTIM FILIAL	07:00	\N	PRESENTE	\N	2026-06-18 20:19:47.476612+00	06:50
df0705dc-3d22-406f-a21e-75ca2f1f6757	2026-06-18	75734	ADRIANA VELOSO ROSA	SYNGENTA GUARDA-CHUVA	07:00	\N	PRESENTE	\N	2026-06-18 20:19:47.476612+00	06:38
b8c3337f-2834-4278-966f-87c86d0283ee	2026-06-18	75742	JOSE JOAO DA SILVA NETO	COAMO AGROINDUSTRIAL	07:00	\N	PRESENTE	\N	2026-06-18 20:19:47.476612+00	06:59
7cec18de-7561-4ed3-9e7f-d8d992b1ca16	2026-06-18	75748	SERGIO APARECIDO LUCAS	Embraer GPX FILIAL	07:20	\N	PRESENTE	\N	2026-06-18 20:19:47.476612+00	07:19
9006d2ae-4665-427c-8040-35b9f5ca6c85	2026-06-18	75757	VALDIR DE ALBUQUERQUE	Embraer Botucatu Filial	07:15	\N	PRESENTE	\N	2026-06-18 20:19:47.476612+00	07:12
c3765680-94ed-423b-82ea-d98f740f91af	2026-06-18	75763	GUSTAVO XAVIER BARBOSA	SYNGENTA GUARDA-CHUVA	07:00	\N	PRESENTE	\N	2026-06-18 20:19:47.476612+00	06:40
83e3ea42-1c8c-4dda-92b3-85e5fde38285	2026-06-18	75776	JERRY DA CONCEIÇÃO SALES	SYNGENTA GUARDA-CHUVA	07:00	\N	PRESENTE	\N	2026-06-18 20:19:47.476612+00	06:54
aa435aad-93e1-45e8-8c70-6475e9630b3c	2026-06-18	75779	ALESSANDRO BARBIERI NOGUEIRA	SYNGENTA GUARDA-CHUVA	07:00	\N	PRESENTE	\N	2026-06-18 20:19:47.476612+00	06:54
b5ec8180-ca9d-4ea9-9201-dd34882d4880	2026-06-18	75782	CHRISTOPHER VINICIUS AMOROSO DOS SANTOS	EMBRAER PUTIM FILIAL	07:00	\N	PRESENTE	\N	2026-06-18 20:19:47.476612+00	06:51
b35258f4-b557-43c4-b4a4-928d19d7df32	2026-06-18	75785	WATILA RODRIGUES MIRANDA	QUIMICA AMPARO YPE-SP	07:00	\N	PRESENTE	\N	2026-06-18 20:19:47.476612+00	06:49
9e6c4d57-cd6f-40be-bbdd-74f84dd0805b	2026-06-18	75786	GERALDO ALVES PINTO	QUIMICA AMPARO YPE-SP	07:00	\N	PRESENTE	\N	2026-06-18 20:19:47.476612+00	06:50
849588cf-13b4-423e-9938-63c332938ee2	2026-06-18	75787	DEJAILTON JESUS DOS SANTOS	QUIMICA AMPARO YPE-SP	07:00	\N	PRESENTE	\N	2026-06-18 20:19:47.476612+00	06:57
1e987ded-a3ce-45a9-8dde-47de75045951	2026-06-18	75788	RAIMUNDO DIAS	SYNGENTA GUARDA-CHUVA	07:00	\N	PRESENTE	\N	2026-06-18 20:19:47.476612+00	06:55
6bed7c14-3c37-4aa3-8205-0bd17e8bc58c	2026-06-18	75793	LUIZ CARLOS FLORENCIO DOS SANTOS	SYNGENTA GUARDA-CHUVA	07:00	\N	PRESENTE	\N	2026-06-18 20:19:47.476612+00	06:49
14ecbd38-83b2-4266-b37f-8e867b468a10	2026-06-18	75795	CARLOS DANIEL FREIRE GOMES	COAMO AGROINDUSTRIAL	07:00	\N	PRESENTE	\N	2026-06-18 20:19:47.476612+00	06:58
1ba33cdc-345b-41d1-b558-bb52d5b8070c	2026-06-18	75796	JOSE FERREIRA DE OLIVEIRA	COAMO AGROINDUSTRIAL	07:00	\N	PRESENTE	\N	2026-06-18 20:19:47.476612+00	06:58
947b8573-a959-4a8c-85a7-e438eebceb87	2026-06-18	75797	EVERTON CHAGAS DE QUEIROZ	QUIMICA AMPARO YPE-SP	07:00	\N	PRESENTE	\N	2026-06-18 20:19:47.476612+00	06:53
7ce32ae4-94ce-4bcb-9c96-f82538db297d	2026-06-18	75798	FABIO LUIZ DE FARIAS	QUIMICA AMPARO YPE-SP	07:00	\N	PRESENTE	\N	2026-06-18 20:19:47.476612+00	06:54
aa7cfb31-5284-4bbb-a27a-c51f95632bc6	2026-06-18	75799	WILLIAM SIDNEY SANTOS	QUIMICA AMPARO YPE-SP	07:00	\N	PRESENTE	\N	2026-06-18 20:19:47.476612+00	06:54
537a247b-9511-41be-bc27-82140193730e	2026-06-18	75800	CARLOS HENRIQUE AUGUSTO ARAUJO	QUIMICA AMPARO YPE-SP	07:00	\N	PRESENTE	\N	2026-06-18 20:19:47.476612+00	06:54
5f1c7de3-069c-42d1-a3e4-8e9cbe137917	2026-06-18	75801	GUSTAVO DE BRITO RESENDE	COAMO AGROINDUSTRIAL	07:00	\N	PRESENTE	\N	2026-06-18 20:19:47.476612+00	06:58
a720b665-bd09-40cd-8f4e-590eb12cef10	2026-06-18	75802	MANUEL NUNES MARQUES	COAMO AGROINDUSTRIAL	07:00	\N	PRESENTE	\N	2026-06-18 20:19:47.476612+00	06:57
d3729558-34a0-4848-b5bb-c852d5e58cf8	2026-06-18	75805	JOSE RENATO DA GLORIA SANTOS	QUIMICA AMPARO YPE-SP	07:00	\N	PRESENTE	\N	2026-06-18 20:19:47.476612+00	06:50
6c6107e6-2011-4077-b471-7a17122ce153	2026-06-18	75808	MARCOS BISPO ASSUNCAO	QUIMICA AMPARO YPE-SP	07:00	\N	PRESENTE	\N	2026-06-18 20:19:47.476612+00	06:51
cd754d4b-9179-48e4-8606-54677073eb6b	2026-06-18	75809	JONAS DE OLIVEIRA	QUIMICA AMPARO YPE-SP	07:00	\N	PRESENTE	\N	2026-06-18 20:19:47.476612+00	06:57
b1dbb4d6-ce75-43b6-a409-196be191deda	2026-06-18	75810	PEDRO JUNIOR CELESTINO DE OLIVEIRA	QUIMICA AMPARO YPE-SP	07:00	\N	PRESENTE	\N	2026-06-18 20:19:47.476612+00	06:55
f071db3e-3161-439d-8d67-7ad9d6c6ce72	2026-06-18	75811	CRISTIAN FABIO DOS SANTOS DOS REIS	QUIMICA AMPARO YPE-SP	07:00	\N	PRESENTE	\N	2026-06-18 20:19:47.476612+00	06:51
99e17a6e-eac1-4662-83ba-2965ee2ba153	2026-06-18	75812	ESMAEL CARLOS NASCIMENTO DOS SANTOS	QUIMICA AMPARO YPE-SP	07:00	\N	PRESENTE	\N	2026-06-18 20:19:47.476612+00	06:50
69557d1e-de75-441d-b625-bef6b017d811	2026-06-18	75813	JADSON SANTOS DOS SANTOS	QUIMICA AMPARO YPE-SP	07:00	\N	PRESENTE	\N	2026-06-18 20:19:47.476612+00	06:51
83cb0ffb-7e3a-4a77-99a3-597f06727df7	2026-06-18	75814	RICARDO CESAR COSTA SANTOS	QUIMICA AMPARO YPE-SP	07:00	\N	PRESENTE	\N	2026-06-18 20:19:47.476612+00	06:53
ed361b5a-8ff0-4935-886e-0a16e58d0c05	2026-06-18	75815	RONALDO BARBOSA DE OLIVEIRA	QUIMICA AMPARO YPE-SP	07:00	\N	PRESENTE	\N	2026-06-18 20:19:47.476612+00	06:51
1029cf74-d597-4f63-b014-3ff94f452afa	2026-06-18	75816	CARLITO FLORENCIO DOS SANTOS	SYNGENTA GUARDA-CHUVA	07:00	\N	PRESENTE	\N	2026-06-18 20:19:47.476612+00	06:45
d15abacd-f684-4d99-bcd5-8c4d86045a1d	2026-06-18	75818	ANTONIO DONISETE DE ANDRADE	COAMO AGROINDUSTRIAL	07:00	\N	PRESENTE	\N	2026-06-18 20:19:47.476612+00	06:52
b4af7592-372b-4add-a7da-91b1fae4bdae	2026-06-18	75819	MICHAEL ADRIANI SOARES DOS SANTOS	COAMO AGROINDUSTRIAL	07:00	\N	PRESENTE	\N	2026-06-18 20:19:47.476612+00	06:59
83e5e1b2-279c-472b-b6fc-9b0333cc1eee	2026-06-18	75820	GILMAR FERREIRA RIBAS	COAMO AGROINDUSTRIAL	07:00	\N	PRESENTE	\N	2026-06-18 20:19:47.476612+00	06:57
246ae321-2f06-40ca-900c-5fe9f5f2156c	2026-06-18	75821	MARCILIO NUNES DE SOUSA	QUIMICA AMPARO YPE-SP	07:00	\N	PRESENTE	\N	2026-06-18 20:19:47.476612+00	06:50
268826c2-7f8f-4a80-a876-b31ace76318e	2026-06-18	75822	JOSE MARCELO DE SOUSA	QUIMICA AMPARO YPE-SP	07:00	\N	PRESENTE	\N	2026-06-18 20:19:47.476612+00	06:50
95ebfeda-d35b-4cb5-8428-197bb5c2131b	2026-06-18	75824	ROSILMAR FRANCISCO DA SILVA	COAMO AGROINDUSTRIAL	07:00	\N	PRESENTE	\N	2026-06-18 20:19:47.476612+00	06:57
12fb071e-2956-49ef-adb3-e8493f67725e	2026-06-18	75826	ALEXSANDRO DE CAMPOS	QUIMICA AMPARO YPE-SP	07:00	\N	PRESENTE	\N	2026-06-18 20:19:47.476612+00	06:56
d483bcea-16c0-4939-b732-2f3e87f6d53d	2026-06-18	75828	ALEX LORENZO MATOS SANTOS	QUIMICA AMPARO YPE-SP	07:00	\N	PRESENTE	\N	2026-06-18 20:19:47.476612+00	06:56
fce2dca9-84de-4576-aa06-321764c4fd31	2026-06-18	75829	WARLEM ALVES	QUIMICA AMPARO YPE-SP	07:00	\N	PRESENTE	\N	2026-06-18 20:19:47.476612+00	06:56
ef2a8c69-0aa1-4ab1-be9f-e8d4451d31a6	2026-06-18	75830	CLAUDIO ASTRO CARVALHO	QUIMICA AMPARO YPE-SP	07:00	\N	PRESENTE	\N	2026-06-18 20:19:47.476612+00	06:57
9c1c62d6-c1fc-4936-b5e3-c57a41194af3	2026-06-18	75831	ADRIANO FERREIRA GOMES	QUIMICA AMPARO YPE-SP	07:00	\N	PRESENTE	\N	2026-06-18 20:19:47.476612+00	06:56
3a16c3c3-49ee-434d-9891-c52976ddf38a	2026-06-18	75833	UBIRAJARA MENDONCA DOS SANTOS	QUIMICA AMPARO YPE-SP	07:00	\N	PRESENTE	\N	2026-06-18 20:19:47.476612+00	06:59
f966d1b2-5db9-45bf-9224-76a58f9651bf	2026-06-18	75834	JERRI SANTOS DA CONCEICAO PINTO	QUIMICA AMPARO YPE-SP	07:00	\N	PRESENTE	\N	2026-06-18 20:19:47.476612+00	06:56
54b4cc7e-6330-40d5-a174-6048af14c77c	2026-06-18	75835	LAMEQUE RODRIGUES SILVA SOARES	QUIMICA AMPARO YPE-SP	07:00	\N	PRESENTE	\N	2026-06-18 20:19:47.476612+00	06:56
d40061b5-4fb0-48a7-8cd1-bdff8c82a14b	2026-06-18	75836	JOELSON GONCALVES MARQUES	QUIMICA AMPARO YPE-SP	07:00	\N	PRESENTE	\N	2026-06-18 20:19:47.476612+00	06:56
0ce4b707-b564-4297-8809-0ad1202bf274	2026-06-18	75837	GERSONIEL SOUSA RODRIGUES	QUIMICA AMPARO YPE-SP	07:00	\N	PRESENTE	\N	2026-06-18 20:19:47.476612+00	06:57
024e2f4e-653e-4a86-a82c-fcfc082894d9	2026-06-18	75839	ERIKA SANTOS DE LIMA	SYNGENTA GUARDA-CHUVA	07:00	\N	PRESENTE	\N	2026-06-18 20:19:47.476612+00	07:01
9bb5e8d4-6d8c-44f8-99f0-2058bc63d4b9	2026-06-18	75840	SIDNEI BARBOZA	COAMO AGROINDUSTRIAL	07:00	\N	PRESENTE	\N	2026-06-18 20:19:47.476612+00	06:54
cb50a95f-bc05-479f-93df-f1a806444b6e	2026-06-18	75841	MARCELO SILVA	QUIMICA AMPARO YPE-SP	07:00	\N	PRESENTE	\N	2026-06-18 20:19:47.476612+00	06:55
64150430-49b1-4dcc-a3a0-499f7a544320	2026-06-18	75842	SIDNEI DE SOUZA PINTO	COAMO AGROINDUSTRIAL	07:00	\N	PRESENTE	\N	2026-06-18 20:19:47.476612+00	06:58
ed985fe4-54bf-4c65-8e14-4e6ef0473118	2026-06-18	75843	MARCELO DE SOUZA DANTAS	COAMO AGROINDUSTRIAL	07:00	\N	PRESENTE	\N	2026-06-18 20:19:47.476612+00	06:53
04f4eccd-a294-497b-a232-cb2ff8f12098	2026-06-18	75845	JOAO CARLOS ALVES DA SILVA	SYNGENTA GUARDA-CHUVA	07:00	\N	PRESENTE	\N	2026-06-18 20:19:47.476612+00	06:55
e9b1e832-be6a-47f2-bf59-ee55ce17106d	2026-06-18	75846	SIRLEI DA SILVA GILBERTO	QUIMICA AMPARO YPE-SP	07:00	\N	PRESENTE	\N	2026-06-18 20:19:47.476612+00	06:57
0162548c-255e-475e-9761-39ad059a8fff	2026-06-18	75847	GABRIEL OLIVEIRA DOS SANTOS	QUIMICA AMPARO YPE-SP	07:00	\N	PRESENTE	\N	2026-06-18 20:19:47.476612+00	06:49
cf697177-4928-4aaf-9a9a-0932400b9f79	2026-06-18	75848	ANTONIO DA SILVA FREITAS	QUIMICA AMPARO YPE-SP	07:00	\N	PRESENTE	\N	2026-06-18 20:19:47.476612+00	06:50
c5e19d54-1457-4a6f-b84d-6085257f35e6	2026-06-18	75849	LUIZ GABRIEL DOS SANTOS ATAIDE	QUIMICA AMPARO YPE-SP	07:00	\N	PRESENTE	\N	2026-06-18 20:19:47.476612+00	06:52
be96ee2f-8209-4b38-acd5-a4843d0c1ff6	2026-06-18	75850	MARIA DAS GRACAS DOS SANTOS E SILVA	QUIMICA AMPARO YPE-SP	07:00	\N	PRESENTE	\N	2026-06-18 20:19:47.476612+00	06:50
c3dc13be-3ec2-453d-a6fa-28c05cbc61de	2026-06-18	75851	ANTONIO SANTOS PORTUGAL	QUIMICA AMPARO YPE-SP	07:00	\N	PRESENTE	\N	2026-06-18 20:19:47.476612+00	06:51
2dad45ed-15dc-40b6-87c0-de9ff6ec5451	2026-06-18	75853	ARGEL QUEIROZ SANTANA	QUIMICA AMPARO YPE-SP	07:00	\N	PRESENTE	\N	2026-06-18 20:19:47.476612+00	06:56
e3b48fa4-d02f-4d4c-8b2d-8b1e0bbe0292	2026-06-18	75854	JORGE HUGO BARBOSA DUARTE	QUIMICA AMPARO YPE-SP	07:00	\N	PRESENTE	\N	2026-06-18 20:19:47.476612+00	06:57
46f62f70-5266-4d67-bb23-8bd3b4729811	2026-06-18	75858	ARLISSON FABIAN MENDES DE JESUS	COAMO AGROINDUSTRIAL	07:00	\N	PRESENTE	\N	2026-06-18 20:19:47.476612+00	06:58
256e3cc4-1a87-490f-bd98-3dbb78b00a6e	2026-06-18	75859	EDSON MARTINS DOS SANTOS	COAMO AGROINDUSTRIAL	07:00	\N	PRESENTE	\N	2026-06-18 20:19:47.476612+00	06:53
29e355df-7c28-4b27-898d-82beeb04d8b9	2026-06-18	75863	JOAQUIM FRANCISCO JUNIOR	COAMO AGROINDUSTRIAL	07:00	\N	PRESENTE	\N	2026-06-18 20:19:47.476612+00	06:52
e7b4498b-650e-44be-95d0-930f20eaf26f	2026-06-18	75864	ANTONIO DAMASCENO NOGUEIRA	QUIMICA AMPARO YPE-SP	07:00	\N	PRESENTE	\N	2026-06-18 20:19:47.476612+00	06:54
75d70bb5-b460-42ac-b3ba-c3c2757168d2	2026-06-18	75865	KAWANN DOS SANTOS TENORIO FEITOSA	QUIMICA AMPARO YPE-SP	07:00	\N	PRESENTE	\N	2026-06-18 20:19:47.476612+00	06:50
c3410deb-daae-4d4b-a164-ecb8f896d7f0	2026-06-18	75866	IVANILDO DE JESUS SANTOS	QUIMICA AMPARO YPE-SP	07:00	\N	PRESENTE	\N	2026-06-18 20:19:47.476612+00	06:53
100eda8c-bd5d-4e52-a4df-6ebb42fdc1ce	2026-06-18	75867	ROSEMEIRE DE SOUZA MACHADO	QUIMICA AMPARO YPE-SP	07:00	\N	PRESENTE	\N	2026-06-18 20:19:47.476612+00	06:53
e19b6771-e0a2-410b-bba4-75e4093fdf03	2026-06-18	75871	EDNEY ANDRADE DOS SANTOS	COAMO AGROINDUSTRIAL	07:00	\N	PRESENTE	\N	2026-06-18 20:19:47.476612+00	06:58
0a5ed222-48f1-440e-9a15-97656232b389	2026-06-18	75872	ROBERTO CARLOS PEREIRA SILVA	COAMO AGROINDUSTRIAL	07:00	\N	PRESENTE	\N	2026-06-18 20:19:47.476612+00	06:57
a14a156f-7ef9-4fc8-a8ad-e929ac23afec	2026-06-18	75873	ANDERSON CAVALCANTI DO NASCIMENTO	COAMO AGROINDUSTRIAL	07:00	\N	PRESENTE	\N	2026-06-18 20:19:47.476612+00	06:57
1add6697-f507-45d4-908f-b95900f4b3c7	2026-06-18	75874	REGINALDO MENEGATTI DOS SANTOS	COAMO AGROINDUSTRIAL	07:00	\N	PRESENTE	\N	2026-06-18 20:19:47.476612+00	06:53
ccc9b534-bd6f-494a-858a-2343c7c67d45	2026-06-18	75875	ADRIANO SANTANA OLIVEIRA	COAMO AGROINDUSTRIAL	07:00	\N	PRESENTE	\N	2026-06-18 20:19:47.476612+00	06:53
62f1b853-f422-4df9-aaf6-1441dd311946	2026-06-18	75876	CLEVERSON DA SILVA	COAMO AGROINDUSTRIAL	07:00	\N	PRESENTE	\N	2026-06-18 20:19:47.476612+00	06:53
fff6fbc1-2ebb-4aad-849f-c49d575bfa5f	2026-06-18	75877	JOSUE JOSE DE OLIVEIRA	SYNGENTA GUARDA-CHUVA	07:00	\N	PRESENTE	\N	2026-06-18 20:19:47.476612+00	06:55
28fcc5f0-aea0-4c98-91a6-ae9a0119c1bd	2026-06-18	75880	NAIRAN DOS SANTOS	QUIMICA AMPARO YPE-SP	07:00	\N	PRESENTE	\N	2026-06-18 20:19:47.476612+00	06:52
82e0c471-b689-471f-9d50-d6cda7a973b9	2026-06-18	75882	DHONATAN OLIVEIRA SOUSA	COAMO AGROINDUSTRIAL	07:00	\N	PRESENTE	\N	2026-06-18 20:19:47.476612+00	06:58
da5f56e4-53a5-497a-8585-3920f1990251	2026-06-18	75887	NIVALDO MANUEL DOS SANTOS	QUIMICA AMPARO YPE-SP	07:00	\N	PRESENTE	\N	2026-06-18 20:19:47.476612+00	06:52
a2872ede-c89f-4168-b375-4e8a6a9925ff	2026-06-18	75888	PAULO RANGEL DE SA PACHECO	QUIMICA AMPARO YPE-SP	07:00	\N	PRESENTE	\N	2026-06-18 20:19:47.476612+00	06:52
5ecd2255-72f1-477d-82ce-082f8452ec74	2026-06-18	75889	FRANCISCO WELLINGTON SILVA LEITE	QUIMICA AMPARO YPE-SP	07:00	\N	PRESENTE	\N	2026-06-18 20:19:47.476612+00	06:52
f5fe993d-cf8c-450d-8fe5-3a617832ddbd	2026-06-18	75891	JOAO PAULO DO CARMO	QUIMICA AMPARO YPE-SP	07:00	\N	PRESENTE	\N	2026-06-18 20:19:47.476612+00	06:53
\.


--
-- Data for Name: empresas; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.empresas (id, nome, cnpj, created_at) FROM stdin;
4489b3ec-6774-4a13-bc24-31b77deb6ae7	GTEL - Grupo Técnico de Eletromecânica SA	47.144.548/0001-79	2026-05-28 11:43:20.609125
145e0a9b-f796-4db5-92e9-33f046f959ae	GTEL - Grupo Técnico de Eletromecânica SA	47.144.548/0001-79	2026-05-28 12:13:28.113305
17e8550c-d196-4b45-8931-5ae1c4042e17	GTEL - Grupo Técnico de Eletromecânica SA	47.144.548/0001-79	2026-05-28 12:45:06.237113
\.


--
-- Data for Name: ferias; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.ferias (id, funcionario_id, matricula, periodo_aquisitivo_inicio, periodo_aquisitivo_fim, dt_limite_ideal, dt_limite_maxima, dias_direito, dias_vencidos, programado, data_inicio_programada, data_fim_programada, dias_programados, importado_em, validado_dp) FROM stdin;
61bd2391-567c-47cc-9dd4-5bb48b1c57c5	aa46cb9c-89c3-4c1d-91de-3c58ad9efed2	075650	2025-09-15	2026-09-14	\N	2027-06-16	30	30	f	\N	\N	\N	2026-06-18 19:54:04.744+00	f
b6876e85-0d3b-4edf-b71d-619fd860a40f	89b01666-1988-48ec-a651-f3e492c26d3b	075088	2025-02-19	2026-02-18	\N	2026-11-20	30	30	f	\N	\N	\N	2026-06-18 19:54:07.069+00	f
83105a22-a9b8-4750-95a8-c0998a6996cb	4ac7e8e1-f572-4fbc-970d-aeff6ba5f6d2	075550	2025-06-26	2026-06-25	\N	2027-03-27	30	30	f	\N	\N	\N	2026-06-18 19:54:07.839+00	f
fcdf7bc6-4b53-46e9-8281-321e7ee943e8	da0d21d6-2889-4fea-b08a-bb5fca1c0c0c	075193	2026-03-07	2027-03-06	\N	2027-12-07	25	0	f	\N	\N	\N	2026-06-18 19:54:08.647+00	f
69a3d36e-bd4b-41a6-be0d-8c3155e47612	7cb832dc-023a-405c-bece-962bddd22d0c	073163	2024-10-09	2025-10-08	\N	2026-07-10	30	30	f	\N	\N	\N	2026-06-18 19:54:11.24+00	f
c4d015c1-47c5-46a2-9eb3-43404f418f27	34062719-61cf-4ef3-b1cc-21bb8a2c0381	073242	2024-11-01	2025-10-31	\N	2026-08-02	30	30	f	\N	\N	\N	2026-06-18 19:54:12.005+00	f
615b6b7a-2385-4e1b-a5df-dd9462a27778	a4f56911-ea8e-4087-8328-6eee7c4a6e6e	073759	2025-04-11	2026-04-10	\N	2027-01-10	30	30	f	\N	\N	\N	2026-06-18 19:54:12.784+00	f
f6e666c8-ebb1-44ed-9a26-9e738e5fe982	54cd7cc3-01d0-4d64-a31d-562d6c2d9073	030366	2025-12-20	2026-12-19	\N	2027-09-20	30	30	f	\N	\N	\N	2026-06-18 19:54:13.554+00	f
a969a821-08df-43dc-b731-068bc5773fc6	cdd7635f-3086-47e8-a87f-3227c76f084f	075708	2025-11-10	2026-11-09	\N	2027-08-11	30	30	f	\N	\N	\N	2026-06-18 19:54:21.306+00	f
cabd7188-b3ac-48c6-8e24-4ed1b62fcf5c	1ff62657-8185-45de-928d-7f9985a94b03	075797	2026-04-15	2027-04-14	\N	2028-01-15	22.5	0	f	\N	\N	\N	2026-06-18 19:54:23.665+00	f
ed8238f3-e8a7-41ae-8ed4-868bbcd99ef9	258bcf6b-a4cb-4fa1-b3a5-8171244ba5bb	075805	2026-04-23	2027-04-22	\N	2028-01-23	20	0	f	\N	\N	\N	2026-06-18 19:54:25.97+00	f
20d1c0fa-df81-403f-aac5-1251ee70d399	f2d98055-bd24-4e4a-a967-55c612ebd750	075811	2026-04-23	2027-04-22	\N	2028-01-23	20	0	f	\N	\N	\N	2026-06-18 19:54:28.307+00	f
c6ecc359-521e-4e8c-bc54-1ab2c3a26924	beff7969-13aa-4ad0-acb3-b178bee25629	075815	2026-04-23	2027-04-22	\N	2028-01-23	20	0	f	\N	\N	\N	2026-06-18 19:54:30.604+00	f
3adafb60-a648-4fc9-bfd7-e8c46ccd1595	1beb7b83-ce97-42f1-8da1-ad6c21cc682a	075828	2026-04-28	2027-04-27	\N	2028-01-28	20	0	f	\N	\N	\N	2026-06-18 19:54:32.902+00	f
ae7615a3-0974-4faf-9da7-70a171b92a3a	1a7f8265-24e3-4ead-bcd0-747192c5cd30	075833	2026-04-28	2027-04-27	\N	2028-01-28	20	0	f	\N	\N	\N	2026-06-18 19:54:35.268+00	f
695f348b-daa5-4972-b9ab-002e3f0946c0	e13fd5d3-8493-4b58-bb54-269993f6fba0	075837	2026-05-04	2027-05-03	\N	2028-02-03	20	0	f	\N	\N	\N	2026-06-18 19:54:37.594+00	f
3a707265-c700-47c1-a159-2cfff7b1f857	be927f52-9181-4a49-8b37-837311673496	075848	2026-05-07	2027-05-06	\N	2028-02-06	20	0	f	\N	\N	\N	2026-06-18 19:54:39.882+00	f
0b7bb017-f6b5-4773-b053-094ab3970226	05f825a2-192a-43d1-8fbe-0279b2c9b178	050187	2025-06-30	2026-06-29	\N	2027-03-31	30	30	f	\N	\N	\N	2026-06-18 19:53:46.32+00	f
8aedfe06-a7cf-4b50-bdce-c670f9a947a5	d9a91097-6b3d-4fd8-adc7-7105b2411e3a	010620	2026-02-14	2027-02-13	\N	2027-11-15	27.5	0	f	\N	\N	\N	2026-06-18 19:53:47.162+00	f
8ce9db84-9d6e-4db8-a670-9581728b1750	478466ce-53df-4ebe-9291-69b4b3d29235	040638	2025-09-12	2026-09-11	\N	2027-06-13	30	30	f	\N	\N	\N	2026-06-18 19:53:47.972+00	f
64d75798-e10a-4f83-a841-b92212b46be0	2ecc58b1-5066-4414-a908-97a36c08b3ec	050930	2026-03-25	2027-03-24	\N	2027-12-25	22.5	0	f	\N	\N	\N	2026-06-18 19:53:48.827+00	f
fd073b1c-9526-4425-a941-abc1f6910262	fcd1f1f3-137d-4e51-9136-928202498461	060853	2026-02-09	2027-02-08	\N	2027-11-10	27.5	0	f	\N	\N	\N	2026-06-18 19:53:49.644+00	f
19feec62-3370-4441-9469-d333d8fc9cad	04509dd6-4ec3-45fa-9fec-7a5577c0ba5e	070768	2025-11-11	2026-11-10	\N	2027-08-12	30	30	f	\N	\N	\N	2026-06-18 19:53:50.463+00	f
9e240ccf-d4eb-442d-af94-e21a072cc446	ed412871-9102-4065-bcf9-d16a9e7bea81	073463	2025-01-23	2026-01-22	\N	2026-10-24	30	30	f	\N	\N	\N	2026-06-18 19:53:52.837+00	f
54bf7698-fa15-41fd-b0f1-eaf790730be9	08df0e04-feb3-40e9-95ea-335a8cc2e69b	073489	2025-01-29	2026-01-28	\N	2026-10-30	30	30	f	\N	\N	\N	2026-06-18 19:53:53.651+00	f
ea16f9d1-e4b6-4c70-a544-075b6539d444	2dc15829-c805-4e47-b083-cd17a008b7a9	074116	2025-08-13	2026-08-12	\N	2027-05-14	30	30	f	\N	\N	\N	2026-06-18 19:53:54.441+00	f
8685df5c-ecdb-4879-a05b-ab3392418c7c	9b1db7a4-3854-4992-b915-1047c364fa46	075620	2025-08-20	2026-08-19	\N	2027-05-21	30	30	f	\N	\N	\N	2026-06-18 19:54:02.423+00	f
3d5ba612-a2ff-49e9-955e-e8c64238e5ac	f09fc646-1a8f-4a6e-8849-d237631a8849	075853	2026-05-07	2027-05-06	\N	2028-02-06	20	0	f	\N	\N	\N	2026-06-18 19:54:42.187+00	f
7a21a1ea-8ba4-4372-b9ea-57bbfaea743e	41f17b9c-a715-4227-92d0-4caf7fa2d8dd	075865	2026-05-14	2027-05-13	\N	2028-02-13	20	0	f	\N	\N	\N	2026-06-18 19:54:44.956+00	f
77c60322-a3e5-48ed-903d-df6b7c3466a0	2c36e097-d770-418a-b702-b9de29ca3c62	075879	2026-05-25	2027-05-24	\N	2028-02-24	17.5	0	f	\N	\N	\N	2026-06-18 19:54:47.502+00	f
d12386e9-e0d2-4da4-b831-d63dc8d959e5	3f70dc11-dc10-41e9-b573-0c962936d7f6	010044	2025-02-17	2026-02-16	\N	2026-11-18	30	30	f	\N	\N	\N	2026-06-18 19:54:49.873+00	f
de603881-ec17-417e-b1f5-34c316830d66	51ffaf0c-00fe-4d5d-821a-40c34a8203d8	073332	2024-12-01	2025-11-30	\N	2026-09-01	30	30	f	\N	\N	\N	2026-06-18 19:54:50.701+00	f
d3639ff0-bcf5-44ef-95f2-43cd559f14cb	cbc8e27d-503d-4447-9e54-2b774c012b66	073557	2025-02-08	2026-02-07	\N	2026-11-09	30	30	f	\N	\N	\N	2026-06-18 19:54:51.471+00	f
b86bf20b-4f78-403e-84fe-5b83a60c3a53	094b876c-ba2c-4518-b30a-28dc1462c38e	075186	2025-03-07	2026-03-06	\N	2026-12-06	30	30	f	\N	\N	\N	2026-06-18 19:54:52.303+00	f
efa2be27-7a0e-4f5e-8a06-9c86d60fbef8	01c0146c-1416-4271-b9d9-eabd6fcd528e	075728	2025-11-26	2026-11-25	\N	2027-08-27	30	30	f	\N	\N	\N	2026-06-18 19:54:53.08+00	f
698f098e-f71c-4d44-9fa1-71ac5a3f5750	18e1524c-4a41-43d2-a70e-aaaa81c6d634	075651	2025-09-15	2026-09-14	\N	2027-06-16	30	30	f	\N	\N	\N	2026-06-18 19:54:05.313+00	f
5d2e078a-3598-4ccd-8524-badcd82aae1a	da0d21d6-2889-4fea-b08a-bb5fca1c0c0c	075193	2025-03-07	2026-03-06	\N	2026-12-06	30	30	f	\N	\N	\N	2026-06-18 19:54:08.442+00	f
849bea82-f00a-42ce-a230-c9695c654985	40e84c7d-2217-4c04-bb08-e3a55fc9a07e	072587	2025-06-02	2026-06-01	\N	2027-03-03	30	30	f	\N	\N	\N	2026-06-18 19:54:09.238+00	f
0a28c615-1ec4-48db-a0e1-a51708e07529	dd0edc19-9be5-4f0a-969c-786fe70bee55	030670	2025-08-09	2026-08-08	\N	2027-05-10	30	30	f	\N	\N	\N	2026-06-18 19:54:14.125+00	f
8ab34826-e02a-4343-8d61-1d36d12e8a63	c19914f1-62c7-4299-8ce8-ce9f35ce98f9	070252	2025-12-10	2026-12-09	\N	2027-09-10	30	30	f	\N	\N	\N	2026-06-18 19:54:14.914+00	f
b216c9d0-4728-4195-b12c-7e525dba034f	c56e2d32-8dfa-4636-86c9-b8a3cbcad162	071109	2025-09-24	2026-09-23	\N	2027-06-25	30	30	f	\N	\N	\N	2026-06-18 19:54:15.687+00	f
2279019f-b39d-448e-945d-5b78e1753aa4	4b9de563-0a07-458b-9319-7d3eb8bbf334	071110	2025-09-24	2026-09-23	\N	2027-06-25	30	30	f	\N	\N	\N	2026-06-18 19:54:16.486+00	f
94448249-dfbe-441b-8b91-7ee082661a78	51a17677-07a9-4a72-91f4-292dcf48a2ee	072113	2025-10-27	2026-10-26	\N	2027-07-28	30	30	f	\N	\N	\N	2026-06-18 19:54:17.27+00	f
680fb4a7-2887-4a47-aacb-cee775b7c11c	2c88777d-11d7-4dcc-9948-9e77d8ef9747	072362	2026-03-30	2027-03-29	\N	2027-12-30	22.5	0	f	\N	\N	\N	2026-06-18 19:54:18.019+00	f
8f3f4947-ab49-4cd9-bfa6-8563d93f2a68	c744692a-9152-43cb-8c92-c2dad53a6dd9	073019	2025-09-14	2026-09-13	\N	2027-06-15	30	30	f	\N	\N	\N	2026-06-18 19:54:18.774+00	f
49654611-1a99-4a01-b451-023382e52c6b	82c546e3-4ba9-4ddd-a28b-c303a2ba31c2	075785	2026-04-07	2027-04-06	\N	2028-01-07	22.5	0	f	\N	\N	\N	2026-06-18 19:54:21.871+00	f
9f5f0699-eccc-4784-ab41-951ad0831aea	8a34f64c-b0af-4a24-a75e-949668c8697f	075798	2026-04-15	2027-04-14	\N	2028-01-15	22.5	0	f	\N	\N	\N	2026-06-18 19:54:24.234+00	f
981fb7cf-5059-46a8-8457-9603e020dd1b	8d639c58-49c6-45bb-83cf-a13f2cf355b5	075808	2026-04-23	2027-04-22	\N	2028-01-23	20	0	f	\N	\N	\N	2026-06-18 19:54:26.552+00	f
857af793-6090-4979-8b82-980397b49a23	e9c22eeb-8b44-45ef-b301-91e65cc90d2e	075812	2026-04-23	2027-04-22	\N	2028-01-23	20	0	f	\N	\N	\N	2026-06-18 19:54:28.884+00	f
bfbba22e-7c66-434a-8614-332a5716fb9f	917fec59-ab61-45db-8f81-9beab2195f1b	075821	2026-04-24	2027-04-23	\N	2028-01-24	20	0	f	\N	\N	\N	2026-06-18 19:54:31.171+00	f
7b8e65b5-2d63-4bf5-9881-ad4c6fd97ebc	e17ada04-7fd7-4ae1-891b-ae6ae0145abe	075829	2026-04-28	2027-04-27	\N	2028-01-28	20	0	f	\N	\N	\N	2026-06-18 19:54:33.498+00	f
12db4a31-c41f-4e92-9d0f-661ecbbc0504	535de7df-c99c-491c-9a5d-670134c0d556	075834	2026-05-04	2027-05-03	\N	2028-02-03	20	0	f	\N	\N	\N	2026-06-18 19:54:35.848+00	f
64058f2d-e98f-4d1f-896c-6eb01c8c9b30	1e97ede4-5066-4ac3-b4b3-09ae236f5caa	075841	2026-05-05	2027-05-04	\N	2028-02-04	20	0	f	\N	\N	\N	2026-06-18 19:54:38.167+00	f
d442cf05-91f4-4630-808d-48cc1e9f6f2b	ba0aa0ea-4f84-4c79-8ca0-01bf069ff89e	075849	2026-05-07	2027-05-06	\N	2028-02-06	20	0	f	\N	\N	\N	2026-06-18 19:54:40.459+00	f
ed08b6fb-cce8-49f3-80e1-0afd11fbd77e	75eacd3d-5c0f-432a-839f-803d5eca0d12	075854	2026-05-08	2027-05-07	\N	2028-02-07	20	0	f	\N	\N	\N	2026-06-18 19:54:42.807+00	f
a32b2f03-15e9-4977-bbd7-7e3d2e61db7c	d9a91097-6b3d-4fd8-adc7-7105b2411e3a	010620	2025-02-14	2026-02-13	\N	2026-11-15	30	30	f	\N	\N	\N	2026-06-18 19:53:46.958+00	f
8dcccca6-f035-4e0d-a55a-51418e1d6bff	478466ce-53df-4ebe-9291-69b4b3d29235	040638	2024-09-12	2025-09-11	\N	2026-06-29	30	30	f	\N	\N	\N	2026-06-18 19:53:47.796+00	f
c84ef974-2f65-45f1-aaca-52d974ad67a0	2ecc58b1-5066-4414-a908-97a36c08b3ec	050930	2025-03-25	2026-03-24	\N	2026-12-24	30	30	f	\N	\N	\N	2026-06-18 19:53:48.632+00	f
ee84a76e-f6db-444a-9285-a0f982bb63dc	fcd1f1f3-137d-4e51-9136-928202498461	060853	2025-02-09	2026-02-08	\N	2026-11-10	30	30	f	\N	\N	\N	2026-06-18 19:53:49.439+00	f
911e2ecb-a798-40aa-966e-d0816c315262	04509dd6-4ec3-45fa-9fec-7a5577c0ba5e	070768	2024-11-11	2025-11-10	\N	2026-08-12	30	30	f	\N	\N	\N	2026-06-18 19:53:50.262+00	f
e05f72f2-8993-482f-bde4-54fb9c8930f4	f4f5e0c6-a407-471e-9cbe-1c9411c62567	071040	2025-06-17	2026-06-16	\N	2027-03-18	30	30	f	\N	\N	\N	2026-06-18 19:53:51.066+00	f
9d02f6a5-a933-4277-8071-bebc15925fcd	0118ef0a-337e-44e1-9eaf-b6e65959576c	074131	2025-08-19	2026-08-18	\N	2027-05-20	30	30	f	\N	\N	\N	2026-06-18 19:53:55.139+00	f
f01f5f40-f5b2-4618-b4ae-cc54fab9539b	e6629df2-78e5-4dfb-8c0a-9dc259cdfce8	074296	2025-09-13	2026-09-12	\N	2027-06-14	24	30	f	\N	\N	\N	2026-06-18 19:53:55.925+00	f
9cb3b888-4236-4f0a-a314-b8c7a0a48143	b8231d04-f70c-4818-95da-8103d8c937a3	074351	2025-09-23	2026-09-22	\N	2027-06-24	30	30	f	\N	\N	\N	2026-06-18 19:53:56.746+00	f
fe8f1286-ef1a-4bd5-a354-021c87167d92	05159e14-4a04-4b7a-9e4f-4cb43d138925	074819	2026-01-10	2027-01-09	\N	2027-10-11	30	30	f	\N	\N	\N	2026-06-18 19:53:57.531+00	f
0595cbd4-37b8-466c-a8ea-49ad0c3bd983	da7daf8d-03ce-4d85-8cc9-834ff097e5ac	074948	2026-02-05	2027-02-04	\N	2027-11-06	27.5	0	f	\N	\N	\N	2026-06-18 19:53:58.303+00	f
3ab4136b-5e9c-4f29-9fc9-8775ddc980c2	525514fa-d774-4a32-94a5-daf799572396	075207	2026-03-13	2027-03-12	\N	2027-12-13	25	0	f	\N	\N	\N	2026-06-18 19:53:59.082+00	f
6f816e23-822c-4aa1-8724-e7f075439e09	02148a14-530c-4549-a5ac-80af04ce6785	075252	2026-03-27	2027-03-26	\N	2027-12-27	22.5	0	f	\N	\N	\N	2026-06-18 19:53:59.882+00	f
6d68a0cd-cea8-49cc-96f8-4a310e52a51b	cf3d40a3-3ecc-47a3-8392-0d6e6b7dbe28	075442	2026-04-30	2027-04-29	\N	2028-01-30	20	0	f	\N	\N	\N	2026-06-18 19:54:00.716+00	f
6c79eee6-664a-4539-ac91-4a18881565d3	1773291d-0948-4de1-ab12-5787fc1d75e8	075621	2025-08-20	2026-08-19	\N	2027-05-21	30	30	f	\N	\N	\N	2026-06-18 19:54:02.992+00	f
1f72641f-8c8e-473f-85ee-d7972ac1ce56	ebaee1a5-8c6f-4ffa-befa-0280b24d7e2b	075866	2026-05-14	2027-05-13	\N	2028-02-13	20	0	f	\N	\N	\N	2026-06-18 19:54:45.742+00	f
940c2ef2-bbca-4d4d-8491-56735c070ae4	709ab55a-f7ed-4e80-a404-49f293fb6447	075880	2026-05-25	2027-05-24	\N	2028-02-24	17.5	0	f	\N	\N	\N	2026-06-18 19:54:48.12+00	f
e322bb6d-9569-4767-bade-33f82bf729f6	e3975bc7-b7a1-417c-bc6c-7d4a71e4714d	075734	2025-12-22	2026-12-21	\N	2027-09-22	30	30	f	\N	\N	\N	2026-06-18 19:54:53.708+00	f
87897d2a-aeb2-48c3-bdad-059ae79d4bd1	7673456e-e717-47ae-8b74-482af33078d9	075727	2025-11-26	2026-11-25	\N	2027-08-27	30	30	f	\N	\N	\N	2026-06-18 19:54:05.898+00	f
6c14b45c-7bfe-46db-83f9-e6676f5e911e	6d1786b8-676c-4511-94b5-b4123162ae8d	074869	2026-01-27	2027-01-26	\N	2027-10-28	27.5	0	f	\N	\N	\N	2026-06-18 19:54:10.086+00	f
9571f7f7-07ad-42a4-b9a3-f5849d7f8deb	c19914f1-62c7-4299-8ce8-ce9f35ce98f9	070252	2024-12-10	2025-12-09	\N	2026-09-10	30	30	f	\N	\N	\N	2026-06-18 19:54:14.718+00	f
fa71fb64-a5eb-4b44-8839-e2d8f71d1ea3	c56e2d32-8dfa-4636-86c9-b8a3cbcad162	071109	2024-09-24	2025-09-23	\N	2026-06-29	30	30	f	\N	\N	\N	2026-06-18 19:54:15.495+00	f
ab80ad0c-bf91-4397-979e-bd65d982cfa1	c744692a-9152-43cb-8c92-c2dad53a6dd9	073019	2024-09-14	2025-09-13	\N	2026-06-29	30	30	t	2026-08-03	2026-09-01	30	2026-06-18 19:54:18.584+00	f
bd6c18a9-a05c-46d0-a87e-6a59880f30e1	c9234c19-cf5c-418f-9a5a-7e93111437c5	071288	2025-08-03	2026-08-02	\N	2027-05-04	30	30	f	\N	\N	\N	2026-06-18 19:53:51.649+00	f
69cbbc23-a6d8-483d-bc2d-08b35d6b69f9	e6629df2-78e5-4dfb-8c0a-9dc259cdfce8	074296	2024-09-13	2025-09-12	\N	2026-06-29	30	30	f	\N	\N	\N	2026-06-18 19:53:55.733+00	f
5c688513-5f10-445b-be17-6a01bc65612b	b8231d04-f70c-4818-95da-8103d8c937a3	074351	2024-09-23	2025-09-22	\N	2026-06-29	30	30	f	\N	\N	\N	2026-06-18 19:53:56.538+00	f
b10d0b64-67b9-495b-bf52-353809b3651a	05159e14-4a04-4b7a-9e4f-4cb43d138925	074819	2025-01-10	2026-01-09	\N	2026-10-11	30	30	f	\N	\N	\N	2026-06-18 19:53:57.336+00	f
a0a2596d-7a97-4a31-af91-890160d2b094	da7daf8d-03ce-4d85-8cc9-834ff097e5ac	074948	2025-02-05	2026-02-04	\N	2026-11-06	30	30	f	\N	\N	\N	2026-06-18 19:53:58.112+00	f
3dc548d0-ee1a-4135-b365-56fccdd5e26c	525514fa-d774-4a32-94a5-daf799572396	075207	2025-03-13	2026-03-12	\N	2026-12-12	30	30	f	\N	\N	\N	2026-06-18 19:53:58.886+00	f
e8d70f1a-31e6-418c-8ce8-9ac6b31fc967	02148a14-530c-4549-a5ac-80af04ce6785	075252	2025-03-27	2026-03-26	\N	2026-12-26	30	30	f	\N	\N	\N	2026-06-18 19:53:59.672+00	f
b09710ee-6764-475f-9d2b-71c66f8e93da	cf3d40a3-3ecc-47a3-8392-0d6e6b7dbe28	075442	2025-04-30	2026-04-29	\N	2027-01-29	30	30	f	\N	\N	\N	2026-06-18 19:54:00.526+00	f
fae76ede-916f-450f-9c31-751dc317d300	4594413b-1406-43f1-b3ed-5af30a6ab880	075594	2025-07-25	2026-07-24	\N	2027-04-25	30	30	f	\N	\N	\N	2026-06-18 19:54:01.289+00	f
a44e84a7-e85a-403a-9050-0f7bf6adb572	4785ec97-ef57-4960-a515-ca79b0a31cee	075627	2025-09-02	2026-09-01	\N	2027-06-03	30	30	f	\N	\N	\N	2026-06-18 19:54:03.584+00	f
d854ddb3-8978-4746-abcc-bb421db316e4	4b9de563-0a07-458b-9319-7d3eb8bbf334	071110	2024-09-24	2025-09-23	\N	2026-06-29	30	30	f	\N	\N	\N	2026-06-18 19:54:16.298+00	f
8b22dd01-ca7b-4097-ac83-d7d942696427	51a17677-07a9-4a72-91f4-292dcf48a2ee	072113	2024-10-27	2025-10-26	\N	2026-07-28	30	30	t	2026-07-13	2026-08-10	30	2026-06-18 19:54:17.067+00	f
6ffe252c-bf9d-4128-b745-869c954db8c6	2c88777d-11d7-4dcc-9948-9e77d8ef9747	072362	2025-03-30	2026-03-29	\N	2026-12-29	30	30	f	\N	\N	\N	2026-06-18 19:54:17.835+00	f
79296aa5-6378-46e1-a333-fc0cccacd38a	4ec450a6-7046-4326-ba4d-30682e19f928	073944	2025-06-17	2026-06-16	\N	2027-03-18	30	30	f	\N	\N	\N	2026-06-18 19:54:19.347+00	f
0949a2fb-69c2-4fc9-9c27-78d50d262532	5d32feb5-73d3-4518-8681-21ceeaa22566	074785	2025-12-20	2026-12-19	\N	2027-09-20	30	30	f	\N	\N	\N	2026-06-18 19:54:20.138+00	f
017375a9-1af2-489c-bc22-0cdeda7414c5	3e252902-8f07-4b31-ad3f-9657cdd3725b	075786	2026-04-07	2027-04-06	\N	2028-01-07	22.5	0	f	\N	\N	\N	2026-06-18 19:54:22.445+00	f
4a948013-1d52-4a64-86cc-dba3130f76d2	722f93bf-64cd-44c7-87eb-6fe9b05ae777	075799	2026-04-15	2027-04-14	\N	2028-01-15	22.5	0	f	\N	\N	\N	2026-06-18 19:54:24.824+00	f
adfa19bc-3309-4bbd-913e-d82cb4b654b0	13b60718-123b-4059-b99f-c9c2d6cea63a	075809	2026-04-23	2027-04-22	\N	2028-01-23	20	0	f	\N	\N	\N	2026-06-18 19:54:27.149+00	f
838defdf-3d16-4b0a-8840-38a813e2806d	487b61f7-2889-4a34-b50c-9c7db75c7d5f	075813	2026-04-23	2027-04-22	\N	2028-01-23	20	0	f	\N	\N	\N	2026-06-18 19:54:29.454+00	f
43a72266-20c3-448a-a7b3-6371be477525	4591a4bb-62f1-48aa-af12-082afd9a16b8	075822	2026-04-24	2027-04-23	\N	2028-01-24	20	0	f	\N	\N	\N	2026-06-18 19:54:31.779+00	f
da7d59b2-d290-42fa-a7d6-1da94129377d	2eafdcdf-2226-40ed-85f6-cbf92b4257ce	075830	2026-04-28	2027-04-27	\N	2028-01-28	20	0	f	\N	\N	\N	2026-06-18 19:54:34.052+00	f
29246526-35b1-426f-96a5-64f5dbc79331	938c088b-e817-4c43-acd6-2571d19bee32	075835	2026-05-04	2027-05-03	\N	2028-02-03	20	0	f	\N	\N	\N	2026-06-18 19:54:36.447+00	f
d6e537e8-cb2e-4bf9-bc39-f046de79aea0	beaa74bb-c384-406f-9b10-5a1b33565e53	075846	2026-05-07	2027-05-06	\N	2028-02-06	20	0	f	\N	\N	\N	2026-06-18 19:54:38.755+00	f
624afc63-3f86-4068-90da-a44316ebdc06	c8a7bf35-ee8a-46e6-8fcb-9d101bed387c	075850	2026-05-07	2027-05-06	\N	2028-02-06	20	0	f	\N	\N	\N	2026-06-18 19:54:41.038+00	f
3f581474-b3a2-4aba-8d51-736b1627da98	a1aebbf0-c987-4a62-82ab-941ed4e7e7b1	075855	2026-05-11	2027-05-10	\N	2028-02-10	20	0	f	\N	\N	\N	2026-06-18 19:54:43.411+00	f
4efb8eaa-bd3a-448d-b854-6972cce83d0c	7c2b7107-4bfa-4a19-9d26-060dbfc1924c	075867	2026-05-18	2027-05-17	\N	2028-02-17	17.5	0	f	\N	\N	\N	2026-06-18 19:54:46.337+00	f
3d5830d2-5da6-453a-ba8b-22c41683449c	ceb4dc7d-3dd1-46d6-a566-14a381a4c7e6	075887	2026-05-28	2027-05-27	\N	2028-02-27	17.5	0	f	\N	\N	\N	2026-06-18 19:54:48.704+00	f
d18ecd88-2296-4750-a044-58dd9d6165bd	174521ea-a404-4d8d-bbc5-d9806cf45983	075765	2026-02-25	2027-02-24	\N	2027-11-26	25	0	f	\N	\N	\N	2026-06-18 19:54:06.484+00	f
be5ff51b-a246-4c45-87b9-71511665c862	89b01666-1988-48ec-a651-f3e492c26d3b	075088	2026-02-19	2027-02-18	\N	2027-11-20	25	0	f	\N	\N	\N	2026-06-18 19:54:07.251+00	f
49832a6b-2cdb-4c73-8180-d9f8d5ef0509	06be1efc-148e-4b38-930c-96ba72b4eca1	075779	2026-03-19	2027-03-18	\N	2027-12-19	22.5	0	f	\N	\N	\N	2026-06-18 19:54:10.68+00	f
f43271ba-19aa-4258-816d-2ca4d95c6080	7cb832dc-023a-405c-bece-962bddd22d0c	073163	2025-10-09	2026-10-08	\N	2027-07-10	30	30	f	\N	\N	\N	2026-06-18 19:54:11.43+00	f
27f44e5c-58a5-4054-9512-603558fbf18f	34062719-61cf-4ef3-b1cc-21bb8a2c0381	073242	2025-11-01	2026-10-31	\N	2027-08-02	30	30	f	\N	\N	\N	2026-06-18 19:54:12.197+00	f
d1666fc1-7365-452a-b175-6b11e397ed00	a4f56911-ea8e-4087-8328-6eee7c4a6e6e	073759	2026-04-11	2027-04-10	\N	2028-01-11	22.5	0	f	\N	\N	\N	2026-06-18 19:54:12.982+00	f
1e62475f-7215-4abe-903a-20ffa3bc9ac8	5d32feb5-73d3-4518-8681-21ceeaa22566	074785	2024-12-20	2025-12-19	\N	2026-09-20	30	30	f	\N	\N	\N	2026-06-18 19:54:19.941+00	f
ceb5cc6f-1c0c-4962-b504-723204565712	4e187f38-3016-46e7-ac27-22928d5338f3	075532	2025-06-16	2026-06-15	\N	2027-03-17	30	30	f	\N	\N	\N	2026-06-18 19:54:20.717+00	f
1dc8039c-9864-4780-96bf-b6d6a72d6b5b	19d7cb2c-e21c-4863-aa70-f426d028d88c	075787	2026-04-09	2027-04-08	\N	2028-01-09	22.5	0	f	\N	\N	\N	2026-06-18 19:54:23.022+00	f
62ebc31c-e8db-4c03-a406-921e7ca5f377	92ce3dcb-4f7d-4cbb-99e4-4349405e77ea	075800	2026-04-15	2027-04-14	\N	2028-01-15	22.5	0	f	\N	\N	\N	2026-06-18 19:54:25.39+00	f
3af2fc5f-2238-4129-927b-e65847ed0d03	a032b7df-3ea8-4faa-b17d-4f5dbbd52994	075810	2026-04-23	2027-04-22	\N	2028-01-23	20	0	f	\N	\N	\N	2026-06-18 19:54:27.73+00	f
9bca8d8a-6ce2-43f0-af01-d6cd0c29ed99	c7758861-4f49-4632-9762-19f5f495a2df	075814	2026-04-23	2027-04-22	\N	2028-01-23	20	0	f	\N	\N	\N	2026-06-18 19:54:30.035+00	f
1a61cc05-743f-41e4-9d0e-bfec34b58ec0	f234c040-0fd9-43ab-b62e-687eaaf47c1d	075826	2026-04-28	2027-04-27	\N	2028-01-28	20	0	f	\N	\N	\N	2026-06-18 19:54:32.344+00	f
b7b7a704-8b48-40ec-af4d-f72de9c607d3	40551037-bf69-4f9e-b3df-adaf6d97527d	075831	2026-04-28	2027-04-27	\N	2028-01-28	20	0	f	\N	\N	\N	2026-06-18 19:54:34.627+00	f
8e76c1d9-2f2c-4577-a964-c33735037388	b7f63435-5138-486e-86a2-bf6dfa450540	075836	2026-05-04	2027-05-03	\N	2028-02-03	20	0	f	\N	\N	\N	2026-06-18 19:54:37.04+00	f
28b6d80e-a99f-4962-baab-417eaa4afadf	fceb40d4-e6ad-4ef6-8e1e-86a175343cf2	075847	2026-05-07	2027-05-06	\N	2028-02-06	20	0	f	\N	\N	\N	2026-06-18 19:54:39.303+00	f
e2b6d0e3-6d6f-4607-83fb-55732309e9bf	3ce155ae-16fa-4fd2-90a2-3cfa719a6867	075851	2026-05-07	2027-05-06	\N	2028-02-06	20	0	f	\N	\N	\N	2026-06-18 19:54:41.618+00	f
68902cc8-172d-40e1-adf9-90c5fd19ba45	17cbdc3e-d043-4eb5-8771-b72a7ac2297a	075864	2026-05-14	2027-05-13	\N	2028-02-13	20	0	f	\N	\N	\N	2026-06-18 19:54:44.348+00	f
4d582d07-2421-464a-975a-61f4e8be3949	1543bea5-f3b5-4289-8136-24338f4042be	075868	2026-05-18	2027-05-17	\N	2028-02-17	17.5	0	f	\N	\N	\N	2026-06-18 19:54:46.916+00	f
02ee4b17-0d66-4ff8-ac16-e8bdeba09afb	0abe8010-ac69-4277-af3d-9a00185b24cd	075888	2026-05-28	2027-05-27	\N	2028-02-27	17.5	0	f	\N	\N	\N	2026-06-18 19:54:49.298+00	f
e0b636df-ef52-43f6-aa6c-2b246dae8ad3	3f70dc11-dc10-41e9-b573-0c962936d7f6	010044	2026-02-17	2027-02-16	\N	2027-11-18	27.5	0	f	\N	\N	\N	2026-06-18 19:54:50.086+00	f
1182acdb-7017-448b-b3ec-07a3a29e5644	51ffaf0c-00fe-4d5d-821a-40c34a8203d8	073332	2025-12-01	2026-11-30	\N	2027-09-01	30	30	f	\N	\N	\N	2026-06-18 19:54:50.904+00	f
e4cf0b98-cb3e-433a-81e9-aac72f760603	cbc8e27d-503d-4447-9e54-2b774c012b66	073557	2026-02-08	2027-02-07	\N	2027-11-09	27.5	0	f	\N	\N	\N	2026-06-18 19:54:51.654+00	f
afd6f5fc-e69e-4fe1-8241-dba8af387103	094b876c-ba2c-4518-b30a-28dc1462c38e	075186	2026-03-07	2027-03-06	\N	2027-12-07	25	0	f	\N	\N	\N	2026-06-18 19:54:52.495+00	f
a2adb4b5-b8dc-4ffe-a201-61f238a0e732	89d1953b-5cff-423d-9239-12133d971027	072779	2025-08-03	2026-08-02	\N	2027-05-04	30	30	f	\N	\N	\N	2026-06-18 19:53:52.245+00	f
10cd6b81-d12c-4114-98fc-74a98612ff3f	ed412871-9102-4065-bcf9-d16a9e7bea81	073463	2026-01-23	2027-01-22	\N	2027-10-24	27.5	0	f	\N	\N	\N	2026-06-18 19:53:53.042+00	f
5ee35e88-eaab-4dbf-8233-b27d2577ab42	08df0e04-feb3-40e9-95ea-335a8cc2e69b	073489	2026-01-29	2027-01-28	\N	2027-10-30	27.5	0	f	\N	\N	\N	2026-06-18 19:53:53.845+00	f
6b911e03-c5d9-4706-947a-9f58d7a3ac2e	aa9c3270-d2e3-46fe-950e-0f9647077ff8	075618	2025-08-20	2026-08-19	\N	2027-05-21	30	30	f	\N	\N	\N	2026-06-18 19:54:01.863+00	f
e8174d6d-f578-4ad2-9bf2-afbf40650741	8dc6d6ec-427a-4a80-8175-97ce13b57c8f	075649	2025-09-15	2026-09-14	\N	2027-06-16	30	30	f	\N	\N	\N	2026-06-18 19:54:04.16+00	f
\.


--
-- Data for Name: folgas; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.folgas (id, funcionario_id, data_inicio, periodo_trabalhado, periodo_folga, cidade_origem, tipo_passagem, saida1_projecao, saida1_real, saida2_projecao, saida2_real, saida3_projecao, saida3_real, saida4_projecao, saida4_real, saida5_projecao, saida5_real, created_at, tipo_passagem_aerea, tipo_passagem_terrestre) FROM stdin;
28acf2fd-48af-4708-9182-f1af6d280e29	709ab55a-f7ed-4e80-a404-49f293fb6447	2026-05-31	180	5	CATU BA	nao	2026-11-27	\N	2027-05-26	\N	2027-11-22	\N	2028-05-20	\N	2028-11-16	\N	2026-06-03 20:16:00.816645+00	f	t
4d23db74-4498-4238-b61c-c33e71d63124	ceb4dc7d-3dd1-46d6-a566-14a381a4c7e6	2026-06-07	90	5	ARARAQUARA SP	nao	2026-09-05	\N	2026-12-04	\N	2027-03-04	\N	2027-06-02	\N	2027-08-31	\N	2026-06-03 20:17:15.67685+00	f	t
af65b816-95ed-4ef8-9672-5330cabe7085	0abe8010-ac69-4277-af3d-9a00185b24cd	2026-06-07	90	5	PAULO AFONSO BA	nao	2026-09-05	\N	2026-12-04	\N	2027-03-04	\N	2027-06-02	\N	2027-08-31	\N	2026-06-03 20:18:45.567456+00	t	t
e5337be9-8a0b-43da-81f0-a47d4f9215c2	40551037-bf69-4f9e-b3df-adaf6d97527d	2026-05-05	90	5	SIMÕES FILHO BA	nao	2026-08-03	\N	2026-11-01	\N	2027-01-30	\N	2027-04-30	\N	2027-07-29	\N	2026-05-28 17:49:20.742627+00	t	t
8a164cf7-451d-4995-a8c6-c5ed5eb8d9cb	51a17677-07a9-4a72-91f4-292dcf48a2ee	2026-05-11	90	5	SAO JOAO DO PARAISO MG	nao	2026-08-09	\N	2026-11-07	\N	2027-02-05	\N	2027-05-06	\N	2027-08-04	\N	2026-05-28 18:04:40.032659+00	f	t
85a1c6ef-e746-41f8-9fed-b5f18a5b4dc7	a032b7df-3ea8-4faa-b17d-4f5dbbd52994	2026-05-01	90	5	CAMPINAS DO PIAUI PI	nao	2026-07-30	\N	2026-10-28	\N	2027-01-26	\N	2027-04-26	\N	2027-07-25	\N	2026-06-03 20:19:57.64201+00	t	t
24da3ee2-de34-4038-9983-33405cdba0c6	a032b7df-3ea8-4faa-b17d-4f5dbbd52994	2026-05-01	90	5	CAMPINAS DO PIAUI PI	nao	2026-07-30	\N	2026-10-28	\N	2027-01-26	\N	2027-04-26	\N	2027-07-25	\N	2026-06-03 20:19:57.64334+00	t	t
6dc5fbd5-d2d9-4426-922d-60d2f8023a1e	1beb7b83-ce97-42f1-8da1-ad6c21cc682a	2026-05-05	90	5	SALVADOR BA	nao	2026-08-03	\N	2026-11-01	\N	2027-01-30	\N	2027-04-30	\N	2027-07-29	\N	2026-05-28 20:00:04.598051+00	t	t
f5a0e200-db09-4816-bec9-63ba632adf98	a032b7df-3ea8-4faa-b17d-4f5dbbd52994	2026-05-01	90	5	CAMPINAS DO PIAUI PI	nao	2026-07-30	\N	2026-10-28	\N	2027-01-26	\N	2027-04-26	\N	2027-07-25	\N	2026-06-03 20:19:57.669139+00	t	t
8c34a275-7c03-474f-a49f-f2487f8e8fdc	5d32feb5-73d3-4518-8681-21ceeaa22566	2026-05-13	90	5	ITAPARICA BA	nao	2026-08-11	\N	2026-11-09	\N	2027-02-07	\N	2027-05-08	\N	2027-08-06	\N	2026-05-28 20:41:45.714336+00	t	t
80b8768c-bf1b-4d0c-8197-931d888ea939	4ec450a6-7046-4326-ba4d-30682e19f928	2026-05-20	60	3	SALGUEIRO PE	nao	2026-07-19	\N	2026-09-17	\N	2026-11-16	\N	2027-01-15	\N	2027-03-16	\N	2026-05-28 20:42:49.756392+00	t	t
27d45ff9-829a-4115-a71c-0900d7c5c143	f234c040-0fd9-43ab-b62e-687eaaf47c1d	2026-05-05	90	5	JACAREI SP	nao	2026-08-03	\N	2026-11-01	\N	2027-01-30	\N	2027-04-30	\N	2027-07-29	\N	2026-05-28 20:44:24.190094+00	f	t
144ecfb5-bea2-475d-882e-2d2bb29e6207	be927f52-9181-4a49-8b37-837311673496	2026-05-18	180	5	ITAITINGA CE	nao	2026-11-14	\N	2027-05-13	\N	2027-11-09	\N	2028-05-07	\N	2028-11-03	\N	2026-05-28 20:52:29.173034+00	f	t
9134a1aa-c7f8-4f0f-be87-dcb964a80124	a032b7df-3ea8-4faa-b17d-4f5dbbd52994	2026-05-01	90	5	CAMPINAS DO PIAUI PI	nao	2026-07-30	\N	2026-10-28	\N	2027-01-26	\N	2027-04-26	\N	2027-07-25	\N	2026-06-03 20:19:57.669136+00	t	t
58a45c06-032c-4e69-a53e-5947d2b43c4e	82c546e3-4ba9-4ddd-a28b-c303a2ba31c2	2026-04-14	90	5	Cruzeiro SP	terrestre	2026-07-13	\N	2026-10-11	\N	2027-01-09	\N	2027-04-09	\N	2027-07-08	\N	2026-05-28 16:53:31.652476+00	f	t
b055d665-98e9-4106-9c4a-c54f48d016c1	19d7cb2c-e21c-4863-aa70-f426d028d88c	2026-04-15	90	5	NAZARE BA	nao	2026-07-14	\N	2026-10-12	\N	2027-01-10	\N	2027-04-10	\N	2027-07-09	\N	2026-06-03 13:04:24.038276+00	t	t
277aa630-d8ff-4c43-a29b-c18c2b5820c4	3ce155ae-16fa-4fd2-90a2-3cfa719a6867	2026-05-11	180	5	CATU BA	nao	2026-11-07	\N	2027-05-06	\N	2027-11-02	\N	2028-04-30	\N	2028-10-27	\N	2026-06-03 16:45:16.114403+00	f	t
16904e96-d5d6-4bca-baec-2ea4699fcf74	f09fc646-1a8f-4a6e-8849-d237631a8849	2026-05-15	90	5	RIBEIRAO BONITO SP	nao	2026-08-13	\N	2026-11-11	\N	2027-02-09	\N	2027-05-10	\N	2027-08-08	\N	2026-06-03 16:47:10.348089+00	f	t
5e47de3b-f8de-4fb9-9bf5-fd50a8a8f5d2	92ce3dcb-4f7d-4cbb-99e4-4349405e77ea	2026-04-28	90	5	BONITO DE SANTA FE PB	nao	2026-07-27	\N	2026-10-25	\N	2027-01-23	\N	2027-04-23	\N	2027-07-22	\N	2026-06-03 16:48:17.710395+00	t	t
c4eb9493-54ab-47fc-a09b-69a3668a5b12	2eafdcdf-2226-40ed-85f6-cbf92b4257ce	2026-05-05	90	5	CANDEIAS BA	nao	2026-08-03	\N	2026-11-01	\N	2027-01-30	\N	2027-04-30	\N	2027-07-29	\N	2026-06-03 16:50:32.441664+00	t	t
75755d69-d829-4b39-bea0-b4cb4f0a58e7	f2d98055-bd24-4e4a-a967-55c612ebd750	2026-05-03	90	5	CANDEIAS BA	nao	2026-08-01	\N	2026-10-30	\N	2027-01-28	\N	2027-04-28	\N	2027-07-27	\N	2026-06-03 16:51:16.114321+00	t	t
89d95e5a-7788-4664-a8c0-bf2dd5f98d55	4e187f38-3016-46e7-ac27-22928d5338f3	2026-05-13	90	5	GRANJA CE	nao	2026-08-11	\N	2026-11-09	\N	2027-02-07	\N	2027-05-08	\N	2027-08-06	\N	2026-06-03 16:54:07.72109+00	t	t
3cc97b23-46c6-4e97-a741-9cba7cfd2993	4b9de563-0a07-458b-9319-7d3eb8bbf334	2026-04-15	90	5	SAO PAULO SP	nao	2026-07-14	\N	2026-10-12	\N	2027-01-10	\N	2027-04-10	\N	2027-07-09	\N	2026-06-03 16:55:17.07797+00	f	t
bf0c9050-484b-4cf2-9247-d383b44da03d	da0d21d6-2889-4fea-b08a-bb5fca1c0c0c	2026-06-03	90	5	JAGUARUANA CE	nao	2026-09-01	\N	2026-11-30	\N	2027-02-28	\N	2027-05-29	\N	2027-08-27	\N	2026-06-03 16:56:47.47973+00	t	t
7dab79c3-2774-4adc-9ea8-bb9b4b3c456c	4ac7e8e1-f572-4fbc-970d-aeff6ba5f6d2	2026-06-03	90	5	LIMOEIRO DO NORTE CE	nao	2026-09-01	\N	2026-11-30	\N	2027-02-28	\N	2027-05-29	\N	2027-08-27	\N	2026-06-03 17:00:59.227019+00	t	t
221ffc49-0d64-4238-abe5-78050d36e860	e9c22eeb-8b44-45ef-b301-91e65cc90d2e	2026-05-02	90	5	RIO DE JANEIRO RJ	nao	2026-07-31	\N	2026-10-29	\N	2027-01-27	\N	2027-04-27	\N	2027-07-26	\N	2026-06-03 17:01:41.957296+00	f	t
5e6bba25-07b3-45a8-a86f-ed322a6005a7	1ff62657-8185-45de-928d-7f9985a94b03	2026-04-23	90	5	SANTO AMARO BA	nao	2026-07-22	\N	2026-10-20	\N	2027-01-18	\N	2027-04-18	\N	2027-07-17	\N	2026-06-03 17:02:42.217207+00	t	t
76582b4b-58ab-4329-8f00-18cba9029213	8a34f64c-b0af-4a24-a75e-949668c8697f	2026-04-22	90	5	CAMPESTRE AL	nao	2026-07-21	\N	2026-10-19	\N	2027-01-17	\N	2027-04-17	\N	2027-07-16	\N	2026-06-03 17:05:01.571269+00	t	t
30eca9fc-529d-41e0-9842-d0e0ee04a74f	cdd7635f-3086-47e8-a87f-3227c76f084f	2026-05-12	90	5	CABECEIRAS DO PIAUI PI	nao	2026-08-10	\N	2026-11-08	\N	2027-02-06	\N	2027-05-07	\N	2027-08-05	\N	2026-06-03 17:06:12.329355+00	t	t
fda972de-ffc8-43aa-bab8-5c7144d4448f	db4f7478-c942-49f4-a173-2a635aa782ae	2026-06-05	180	5	JAGUARUANA CE	nao	2026-12-02	\N	2027-05-31	\N	2027-11-27	\N	2028-05-25	\N	2028-11-21	\N	2026-06-03 17:08:41.891668+00	f	t
3eca87d7-eb09-403f-9162-d7f123be17c0	fceb40d4-e6ad-4ef6-8e1e-86a175343cf2	2026-05-18	180	5	JAGUARUANA CE	nao	2026-11-14	\N	2027-05-13	\N	2027-11-09	\N	2028-05-07	\N	2028-11-03	\N	2026-06-03 17:10:03.578629+00	f	t
651367d4-14fe-4990-b4cb-4bdd4d51eb8b	3e252902-8f07-4b31-ad3f-9657cdd3725b	2026-04-14	90	5	TEODORO SAMPAIO SP	nao	2026-07-13	\N	2026-10-11	\N	2027-01-09	\N	2027-04-09	\N	2027-07-08	\N	2026-06-03 17:11:05.007511+00	f	t
b1a802e5-49ec-48ff-997e-ed36eea45314	e13fd5d3-8493-4b58-bb54-269993f6fba0	2026-05-10	90	5	BOQUEIRAO DO PIAUI PI	nao	2026-08-08	\N	2026-11-06	\N	2027-02-04	\N	2027-05-05	\N	2027-08-03	\N	2026-06-03 17:11:47.603534+00	t	t
1c381a51-3474-4950-92ef-01fda963af9c	c56e2d32-8dfa-4636-86c9-b8a3cbcad162	2026-05-10	90	5	BAHIA BA	nao	2026-08-08	\N	2026-11-06	\N	2027-02-04	\N	2027-05-05	\N	2027-08-03	\N	2026-06-03 17:15:09.985433+00	t	t
4ea4e1da-7dec-4143-ae70-213d490f6099	ebaee1a5-8c6f-4ffa-befa-0280b24d7e2b	2026-05-23	90	5	CATU BA	nao	2026-08-21	\N	2026-11-19	\N	2027-02-17	\N	2027-05-18	\N	2027-08-16	\N	2026-06-03 19:51:37.296518+00	f	t
25c7014d-7479-4a5a-81a4-673baa7cf42c	487b61f7-2889-4a34-b50c-9c7db75c7d5f	2026-05-02	90	5	CATU BA	nao	2026-07-31	\N	2026-10-29	\N	2027-01-27	\N	2027-04-27	\N	2027-07-26	\N	2026-06-03 19:52:27.520509+00	t	t
ad5ebaff-8c1e-46fc-aa14-d6d09370faab	535de7df-c99c-491c-9a5d-670134c0d556	2026-05-10	90	5	CANDEIAS BA	nao	2026-08-08	\N	2026-11-06	\N	2027-02-04	\N	2027-05-05	\N	2027-08-03	\N	2026-06-03 19:54:04.621404+00	t	t
8a808eb2-2374-488b-9c17-40e356ac594e	b7f63435-5138-486e-86a2-bf6dfa450540	2026-05-09	90	5	ABAETETUBA PA	nao	2026-08-07	\N	2026-11-05	\N	2027-02-03	\N	2027-05-04	\N	2027-08-02	\N	2026-06-03 19:55:29.553265+00	t	t
1ec5a7e9-d487-4cc2-878d-61095365d6f2	13b60718-123b-4059-b99f-c9c2d6cea63a	2026-05-03	90	5	PILAR AL	nao	2026-08-01	\N	2026-10-30	\N	2027-01-28	\N	2027-04-28	\N	2027-07-27	\N	2026-06-03 19:56:59.608905+00	t	t
e60d24cf-78b7-4439-8a45-7a662c7e4acd	75eacd3d-5c0f-432a-839f-803d5eca0d12	2026-05-17	90	5	ICO CE	nao	2026-08-15	\N	2026-11-13	\N	2027-02-11	\N	2027-05-12	\N	2027-08-10	\N	2026-06-03 19:57:45.552965+00	t	t
f8251d18-21c2-4261-bd02-9354abb9526f	7cb832dc-023a-405c-bece-962bddd22d0c	2026-06-02	90	5	SAO JOSE DO BELMONTE PE	nao	2026-08-31	\N	2026-11-29	\N	2027-02-27	\N	2027-05-28	\N	2027-08-26	\N	2026-06-03 20:03:35.797933+00	t	t
803fef07-f39b-4150-9eb5-2c2d94b061aa	4591a4bb-62f1-48aa-af12-082afd9a16b8	2026-05-03	90	5	ICO CE	nao	2026-08-01	\N	2026-10-30	\N	2027-01-28	\N	2027-04-28	\N	2027-07-27	\N	2026-06-03 20:05:08.493335+00	t	t
cf4ca93d-1bb7-4dba-b8a2-2c4bd6e3eb09	258bcf6b-a4cb-4fa1-b3a5-8171244ba5bb	2026-05-03	90	5	SALVADOR BA	nao	2026-08-01	\N	2026-10-30	\N	2027-01-28	\N	2027-04-28	\N	2027-07-27	\N	2026-06-03 20:06:03.177824+00	t	t
9be797f5-b094-446f-9959-6383b643f4d8	41f17b9c-a715-4227-92d0-4caf7fa2d8dd	2026-05-24	180	5	VENTUROSA PE	nao	2026-11-20	\N	2027-05-19	\N	2027-11-15	\N	2028-05-13	\N	2028-11-09	\N	2026-06-03 20:07:26.687106+00	f	t
a90d0b8b-33e5-4d67-80fd-2d64de95f86f	938c088b-e817-4c43-acd6-2571d19bee32	2026-05-10	90	5	BOQUEIRAO DO PIAUI PI	nao	2026-08-08	\N	2026-11-06	\N	2027-02-04	\N	2027-05-05	\N	2027-08-03	\N	2026-06-03 20:11:27.88614+00	t	t
f2251cae-ed31-4867-8394-263d53108524	ba0aa0ea-4f84-4c79-8ca0-01bf069ff89e	2026-05-11	180	5	CATU BA	nao	2026-11-07	\N	2027-05-06	\N	2027-11-02	\N	2028-04-30	\N	2028-10-27	\N	2026-06-03 20:12:26.19896+00	f	t
37d1f9eb-ef3a-4582-8b89-5c863475a9b4	1e97ede4-5066-4ac3-b4b3-09ae236f5caa	2026-05-10	90	5	PIRAI RJ	nao	2026-08-08	\N	2026-11-06	\N	2027-02-04	\N	2027-05-05	\N	2027-08-03	\N	2026-06-03 20:13:17.103486+00	f	t
4bfb0320-b437-48b4-b59a-75eeba7a10c9	917fec59-ab61-45db-8f81-9beab2195f1b	2026-05-03	90	5	ICO CE	nao	2026-08-01	\N	2026-10-30	\N	2027-01-28	\N	2027-04-28	\N	2027-07-27	\N	2026-06-03 20:14:14.981163+00	t	t
cb7a80c9-dc84-411a-b71f-74a0e935aaa8	8d639c58-49c6-45bb-83cf-a13f2cf355b5	2026-05-02	90	5	CATU BA	nao	2026-07-31	\N	2026-10-29	\N	2027-01-27	\N	2027-04-27	\N	2027-07-26	\N	2026-06-03 20:14:48.202817+00	t	t
366625e3-bb62-41c7-b6f4-d8284917ab9b	1543bea5-f3b5-4289-8136-24338f4042be	2026-06-05	90	5	CACHOEIRA BA	nao	2026-09-03	\N	2026-12-02	\N	2027-03-02	\N	2027-05-31	\N	2027-08-29	\N	2026-06-03 20:15:33.614116+00	t	t
1c54b1f9-8fc9-41c7-9f8f-a347fb7861db	34062719-61cf-4ef3-b1cc-21bb8a2c0381	2026-06-15	90	5	REMANSO BA	nao	2026-09-13	\N	2026-12-12	\N	2027-03-12	\N	2027-06-10	\N	2027-09-08	\N	2026-06-03 20:24:31.900715+00	t	t
87313a93-7e30-419c-bce0-e49ca72f49d0	c7758861-4f49-4632-9762-19f5f495a2df	2026-05-02	90	5	CATU BA	nao	2026-07-31	\N	2026-10-29	\N	2027-01-27	\N	2027-04-27	\N	2027-07-26	\N	2026-06-03 20:29:20.360019+00	t	t
98e3b93a-5cdd-42c7-9c6f-cd002d5b7f90	beff7969-13aa-4ad0-acb3-b178bee25629	2026-04-28	90	5	LINHARES ES	nao	2026-07-27	\N	2026-10-25	\N	2027-01-23	\N	2027-04-23	\N	2027-07-22	\N	2026-06-03 20:32:19.268959+00	t	t
24b9a3a3-7342-49c9-afcb-86dd02d8e982	1a7f8265-24e3-4ead-bcd0-747192c5cd30	2026-05-05	90	5	ESCADA PE	nao	2026-08-03	\N	2026-11-01	\N	2027-01-30	\N	2027-04-30	\N	2027-07-29	\N	2026-06-03 20:33:25.993335+00	t	t
aa02ae9a-6d28-4bd4-92a9-3722957334bc	c19914f1-62c7-4299-8ce8-ce9f35ce98f9	2026-05-11	90	5	SERRA ES	nao	2026-08-09	\N	2026-11-07	\N	2027-02-05	\N	2027-05-06	\N	2027-08-04	\N	2026-06-03 20:38:11.166328+00	t	t
3d028296-6585-4091-ada4-8eb4a71b4a75	e17ada04-7fd7-4ae1-891b-ae6ae0145abe	2026-05-05	90	5	GUARULHOS SP	nao	2026-08-03	\N	2026-11-01	\N	2027-01-30	\N	2027-04-30	\N	2027-07-29	\N	2026-06-03 20:39:13.091236+00	t	t
e6d258cd-363b-49c2-a66f-9f31cdf152ce	a1aebbf0-c987-4a62-82ab-941ed4e7e7b1	2026-05-17	90	5	SERTAOZINHO SP	nao	2026-08-15	\N	2026-11-13	\N	2027-02-11	\N	2027-05-12	\N	2027-08-10	\N	2026-06-03 20:40:35.217394+00	f	t
406b5fa2-a9f3-429a-b3f9-a914ae9dd2e4	54cd7cc3-01d0-4d64-a31d-562d6c2d9073	2026-05-19	30	5	SAO PAULO SP	nao	2026-06-18	2026-06-22	2026-07-18	\N	2026-08-17	\N	2026-09-16	\N	2026-10-16	\N	2026-06-03 20:02:39.873359+00	f	t
c55e96bb-4fc8-42d8-a3b1-a146e9fc372f	722f93bf-64cd-44c7-87eb-6fe9b05ae777	2026-04-23	90	5	MATA DE SAO JOAO BA	nao	2026-07-22	\N	2026-10-20	\N	2027-01-18	\N	2027-04-18	\N	2027-07-17	\N	2026-06-03 20:42:01.36951+00	t	t
79701ecb-4e0a-4125-bb02-6e8072e1c0a6	d9a91097-6b3d-4fd8-adc7-7105b2411e3a	2026-05-04	30	5	SAO PAULO SP	nao	2026-06-03	2026-06-15	2026-07-03	\N	2026-08-02	\N	2026-09-01	\N	2026-10-01	\N	2026-06-03 20:27:21.174447+00	f	t
664243ac-be35-444e-9a90-6f04b89fbb16	fcd1f1f3-137d-4e51-9136-928202498461	2026-04-13	30	5	GUARATINGUETA	nao	2026-05-13	\N	2026-06-12	\N	2026-07-12	\N	2026-08-11	\N	2026-09-10	\N	2026-06-19 10:38:46.394035+00	f	t
35859d1f-3e45-462a-b956-1d580ae53436	525514fa-d774-4a32-94a5-daf799572396	2026-04-17	90	5	CATU	nao	2026-07-16	\N	2026-10-14	\N	2027-01-12	\N	2027-04-12	\N	2027-07-11	\N	2026-06-19 10:40:51.527297+00	t	t
7e265c5f-090c-474e-b095-40714e7df104	478466ce-53df-4ebe-9291-69b4b3d29235	2026-01-14	30	5	SAO PAULO	nao	2026-02-13	\N	2026-03-15	\N	2026-04-14	\N	2026-05-14	\N	2026-06-13	\N	2026-06-19 10:47:37.768299+00	f	t
ad5dd5ac-9394-49c2-b134-73eab90c8724	02148a14-530c-4549-a5ac-80af04ce6785	2026-05-19	90	5	PAULO AFONSO	nao	2026-08-17	\N	2026-11-15	\N	2027-02-13	\N	2027-05-14	\N	2027-08-12	\N	2026-06-19 10:48:28.025568+00	t	t
47a2cb47-af62-4eb9-88f7-fdc042a63f97	2ecc58b1-5066-4414-a908-97a36c08b3ec	2026-03-26	90	5	MACEIO- AL	nao	2026-06-24	\N	2026-09-22	\N	2026-12-21	\N	2027-03-21	\N	2027-06-19	\N	2026-06-19 10:46:29.685986+00	t	t
82d426fe-e785-4b86-afbf-33f291f3a798	f4f5e0c6-a407-471e-9cbe-1c9411c62567	2026-06-16	45	5	JUIZ DE FORA- MG	nao	2026-07-31	\N	2026-09-14	\N	2026-10-29	\N	2026-12-13	\N	2027-01-27	\N	2026-06-19 10:49:25.008409+00	f	t
2305a353-b511-4679-9e61-ef325438df4e	5868da5b-e78e-4c06-85cc-fce019066e3e	2026-05-20	90	5	CONDADO- PE	nao	2026-08-18	\N	2026-11-16	\N	2027-02-14	\N	2027-05-15	\N	2027-08-13	\N	2026-06-19 10:49:52.294828+00	t	t
bc1480e6-aa1c-46ac-88cf-bf7e0ec8e8ec	c9234c19-cf5c-418f-9a5a-7e93111437c5	2026-05-18	30	5	SAO PAULO	nao	2026-06-17	\N	2026-07-17	\N	2026-08-16	\N	2026-09-15	\N	2026-10-15	\N	2026-06-19 10:50:19.721398+00	f	t
b95b55c4-45c4-4a37-876e-c6d392abd7d9	da7daf8d-03ce-4d85-8cc9-834ff097e5ac	2026-04-14	90	5	PAULO AFONSO- BA	nao	2026-07-13	\N	2026-10-11	\N	2027-01-09	\N	2027-04-09	\N	2027-07-08	\N	2026-06-19 10:50:47.547282+00	t	t
68569806-f957-4faa-b078-9183fcc399a7	05159e14-4a04-4b7a-9e4f-4cb43d138925	2026-04-14	90	5	TERESINA- PI	nao	2026-07-13	\N	2026-10-11	\N	2027-01-09	\N	2027-04-09	\N	2027-07-08	\N	2026-06-19 10:53:17.072263+00	t	t
6dcebab2-3655-4043-b1bb-2b7560ad120e	ed412871-9102-4065-bcf9-d16a9e7bea81	2026-05-04	90	5	SÃO FELIX- BA	nao	2026-08-02	\N	2026-10-31	\N	2027-01-29	\N	2027-04-29	\N	2027-07-28	\N	2026-06-19 10:53:51.027463+00	t	t
d999bc41-581f-4012-9673-ac2c99be8c20	89d1953b-5cff-423d-9239-12133d971027	2026-04-22	30	5	GUARATINGUETA- SP	nao	2026-05-22	\N	2026-06-21	\N	2026-07-21	\N	2026-08-20	\N	2026-09-19	\N	2026-06-19 10:54:26.917737+00	f	t
\.


--
-- Data for Name: funcionarios; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.funcionarios (id, matricula, nome_completo, cpf, ctps, serie_ctps, uf_ctps, pis, data_admissao, situacao, tipo, funcao_id, empresa_id, obra_id, cidade, uf, foto_url, created_at, updated_at, transferido, data_transferencia, obra_transferencia_id, centro_custo_transferencia, data_mobilizacao, data_desmobilizacao, funcao_manual, tipo_transferencia, periodo_experiencia, efetivado, observacao_interna, alojamento_id) FROM stdin;
40e84c7d-2217-4c04-bb08-e3a55fc9a07e	72587	BRUNO GUSTAVO COELHO	\N	\N	\N	\N	\N	2023-06-02	ativo	efetivo	43d587ab-d22c-41ee-89e8-6d58f41c71ac	4489b3ec-6774-4a13-bc24-31b77deb6ae7	0ea37ce8-5f9d-4270-ac46-73e6c169c6d2	SÃO JOSE DOS CAMPOS	SP	https://lqggoshphakeuufibdno.supabase.co/storage/v1/object/public/funcionarios/fotos/1781790876746.png	2026-06-18 13:54:38.493502	2026-06-18 13:54:38.493502	f	\N	\N	\N	2026-01-26	\N	\N	\N	30	f	ALOJADO	f6f57e02-f34d-4586-9bc2-d32da81a6931
4b9de563-0a07-458b-9319-7d3eb8bbf334	071110	DIEGO FERREIRA ALVES	\N	\N	\N	\N	\N	2020-09-24	ativo	nova_admissao	ab979acd-d194-4920-801d-82f3707d67fd	4489b3ec-6774-4a13-bc24-31b77deb6ae7	0d899f11-785d-4edd-a951-bac82fae074f	SAO PAULO	SP	\N	2026-06-02 11:56:26.625017	2026-06-02 11:56:26.625017	f	\N	\N	\N	\N	\N	\N	\N	45	t	\N	\N
40551037-bf69-4f9e-b3df-adaf6d97527d	075831	ADRIANO FERREIRA GOMES	\N	\N	\N	\N	\N	2026-04-28	ativo	nova_admissao	378753e1-7221-45f7-a28e-0f988d31c30b	4489b3ec-6774-4a13-bc24-31b77deb6ae7	0d899f11-785d-4edd-a951-bac82fae074f	SIMÕES FILHO 	BA	https://lqggoshphakeuufibdno.supabase.co/storage/v1/object/public/funcionarios/fotos/1779990513083.jpeg	2026-05-28 17:48:36.108537	2026-05-28 17:48:36.108537	f	\N	\N	\N	2026-05-06	\N	\N	\N	45	f	\N	\N
1beb7b83-ce97-42f1-8da1-ad6c21cc682a	075828	ALEX LORENZO MATOS SANTOS	\N	\N	\N	\N	\N	2026-04-28	ativo	nova_admissao	378753e1-7221-45f7-a28e-0f988d31c30b	4489b3ec-6774-4a13-bc24-31b77deb6ae7	0d899f11-785d-4edd-a951-bac82fae074f	SALVADOR 	BA	https://lqggoshphakeuufibdno.supabase.co/storage/v1/object/public/funcionarios/fotos/1779998362237.png	2026-05-28 19:59:24.434627	2026-05-28 19:59:24.434627	f	\N	\N	\N	2026-05-06	\N	\N	\N	45	f	\N	\N
f234c040-0fd9-43ab-b62e-687eaaf47c1d	075826	ALEXSANDRO DE CAMPOS	\N	\N	\N	\N	\N	2026-04-28	ativo	nova_admissao	378753e1-7221-45f7-a28e-0f988d31c30b	4489b3ec-6774-4a13-bc24-31b77deb6ae7	0d899f11-785d-4edd-a951-bac82fae074f	JACAREI	SP	https://lqggoshphakeuufibdno.supabase.co/storage/v1/object/public/funcionarios/fotos/1779998520457.jpeg	2026-05-28 20:02:01.706726	2026-05-28 20:02:01.706726	f	\N	\N	\N	2026-05-06	\N	\N	\N	45	f	\N	\N
5d32feb5-73d3-4518-8681-21ceeaa22566	074785	ALTAIR DA SILVA MARTINS	\N	\N	\N	\N	\N	2024-12-20	transferido	transferencia	0a96b9a4-ef33-4088-8d90-ca90dcffc41b	17e8550c-d196-4b45-8931-5ae1c4042e17	0d899f11-785d-4edd-a951-bac82fae074f	ITAPARICA	BA	https://lqggoshphakeuufibdno.supabase.co/storage/v1/object/public/funcionarios/fotos/1779999214293.jpg	2026-05-28 20:13:36.267371	2026-05-28 20:13:36.267371	t	2026-05-11	3bd8994a-2652-4f14-a89e-eec4edbf4b00	23959	2026-05-11	\N	\N	recebimento	45	t	\N	\N
51a17677-07a9-4a72-91f4-292dcf48a2ee	072113	AILTON OLIVEIRA SOUSA	\N	\N	\N	\N	\N	2022-10-27	transferido	transferencia	fd98fe54-a012-49ae-8a4f-4359c7556f01	4489b3ec-6774-4a13-bc24-31b77deb6ae7	0d899f11-785d-4edd-a951-bac82fae074f	SAO JOAO DO PARAISO	MG	https://lqggoshphakeuufibdno.supabase.co/storage/v1/object/public/funcionarios/fotos/1779990833551.png	2026-05-28 17:53:56.685143	2026-05-28 17:53:56.685143	t	2026-05-11	f1b4fe50-69ba-4443-aa10-53e4d8d124c7	23698	2026-05-11	\N	\N	recebimento	45	t	\N	\N
b7f63435-5138-486e-86a2-bf6dfa450540	075836	JOELSON GONCALVES MARQUES	\N	\N	\N	\N	\N	2026-05-04	ativo	nova_admissao	c5ddb144-5847-4aec-b64b-cb346f96cfad	4489b3ec-6774-4a13-bc24-31b77deb6ae7	0d899f11-785d-4edd-a951-bac82fae074f	ABAETETUBA	PA	https://lqggoshphakeuufibdno.supabase.co/storage/v1/object/public/funcionarios/fotos/1781717357869.png	2026-06-02 11:58:46.60764	2026-06-02 11:58:46.60764	f	\N	\N	\N	\N	\N	\N	\N	45	f	\N	e42bb35b-e6c4-4db2-8c2b-4c2e8f69a2e3
be927f52-9181-4a49-8b37-837311673496	075848	ANTONIO DA SILVA FREITAS	\N	\N	\N	\N	\N	2026-05-07	ativo	nova_admissao	7d9dffa9-1696-4cb1-bfda-1e2fd2fc255a	4489b3ec-6774-4a13-bc24-31b77deb6ae7	0d899f11-785d-4edd-a951-bac82fae074f	ITAITINGA	CE	https://lqggoshphakeuufibdno.supabase.co/storage/v1/object/public/funcionarios/fotos/1780001269108.jpeg	2026-05-28 20:47:58.383763	2026-05-28 20:47:58.383763	f	\N	\N	\N	2026-05-18	\N	\N	\N	45	f	\N	\N
2c88777d-11d7-4dcc-9948-9e77d8ef9747	072362	GUSTAVO HENRIQUE CARTACHO LIMA DO NASCIMENTO	\N	\N	\N	\N	\N	2023-03-30	ativo	nova_admissao	2715e2bd-f45c-448b-8900-b1374680b947	4489b3ec-6774-4a13-bc24-31b77deb6ae7	0d899f11-785d-4edd-a951-bac82fae074f	PARANAVA	PR	\N	2026-06-02 11:58:46.60764	2026-06-02 11:58:46.60764	f	\N	\N	\N	\N	\N	\N	\N	45	t	\N	\N
c744692a-9152-43cb-8c92-c2dad53a6dd9	073019	JEIZIEL ALVES SILVA DE ASSIS	\N	\N	\N	\N	\N	2023-09-14	ativo	nova_admissao	\N	4489b3ec-6774-4a13-bc24-31b77deb6ae7	0d899f11-785d-4edd-a951-bac82fae074f	AGRESTINA	PE	\N	2026-06-02 11:58:46.60764	2026-06-02 11:58:46.60764	f	\N	\N	\N	\N	\N	ASSISTENTE ADMINISTRATIVO II	\N	45	t	\N	\N
dd0edc19-9be5-4f0a-969c-786fe70bee55	030670	JOAO MARCIO GUILHERMINO SILVA	\N	\N	\N	\N	\N	2012-08-09	ativo	nova_admissao	dee60c7c-2c17-413c-a1e7-d49c12e7e8e2	4489b3ec-6774-4a13-bc24-31b77deb6ae7	0d899f11-785d-4edd-a951-bac82fae074f	FERRAZ DE VASCONCELO	SP	\N	2026-06-02 11:58:46.60764	2026-06-02 11:58:46.60764	f	\N	\N	\N	\N	\N	\N	\N	45	t	\N	\N
54cd7cc3-01d0-4d64-a31d-562d6c2d9073	030366	JOSE AUGUSTO FRANCISCO DE SOUZA	\N	\N	\N	\N	\N	2012-04-16	ativo	nova_admissao	7ccbe19e-d491-46d3-a17e-e0227d6355fc	4489b3ec-6774-4a13-bc24-31b77deb6ae7	0d899f11-785d-4edd-a951-bac82fae074f	ITAQUAQUECETUBA	SP	\N	2026-06-02 11:59:33.324033	2026-06-02 11:59:33.324033	f	\N	\N	\N	\N	\N	\N	\N	45	t	\N	c8e6e203-9c03-42cb-9a30-63fca14dc225
1ff62657-8185-45de-928d-7f9985a94b03	075797	EVERTON CHAGAS DE QUEIROZ	\N	\N	\N	\N	\N	2026-04-15	ativo	nova_admissao	cde079dd-2d53-44c2-9054-6245d154bcf6	4489b3ec-6774-4a13-bc24-31b77deb6ae7	0d899f11-785d-4edd-a951-bac82fae074f	SANTO AMARO	BA	https://lqggoshphakeuufibdno.supabase.co/storage/v1/object/public/funcionarios/fotos/1781717066824.jpeg	2026-06-02 11:57:10.90763	2026-06-02 11:57:10.90763	f	\N	\N	\N	\N	\N	\N	\N	45	f	\N	c8e6e203-9c03-42cb-9a30-63fca14dc225
f2d98055-bd24-4e4a-a967-55c612ebd750	075811	CRISTIAN FABIO DOS SANTOS DOS REIS	\N	\N	\N	\N	\N	2026-04-23	ativo	nova_admissao	c5ddb144-5847-4aec-b64b-cb346f96cfad	4489b3ec-6774-4a13-bc24-31b77deb6ae7	0d899f11-785d-4edd-a951-bac82fae074f	CANDEIAS	BA	https://lqggoshphakeuufibdno.supabase.co/storage/v1/object/public/funcionarios/fotos/1781716950101.png	2026-06-02 11:56:26.625017	2026-06-02 11:56:26.625017	f	\N	\N	\N	\N	\N	\N	\N	45	f	\N	5e1a3306-b40c-4277-8c03-5e317063af3b
3e252902-8f07-4b31-ad3f-9657cdd3725b	075786	GERALDO ALVES PINTO	\N	\N	\N	\N	\N	2026-04-07	ativo	nova_admissao	f510f6aa-f1d8-4fd9-b85f-dd8ff840cf76	4489b3ec-6774-4a13-bc24-31b77deb6ae7	0d899f11-785d-4edd-a951-bac82fae074f	TEODORO SAMPAIO	SP	https://lqggoshphakeuufibdno.supabase.co/storage/v1/object/public/funcionarios/fotos/1781717233724.png	2026-06-02 11:57:10.90763	2026-06-02 11:57:10.90763	f	\N	\N	\N	\N	\N	\N	\N	45	f	obs	7e18e7ce-a57d-4369-88de-8097c3286957
c56e2d32-8dfa-4636-86c9-b8a3cbcad162	071109	GILSON COELHO MESSIAS	\N	\N	\N	\N	\N	2020-09-24	ativo	nova_admissao	ea0e0abb-9679-41a1-8293-33e3adcb6fa9	4489b3ec-6774-4a13-bc24-31b77deb6ae7	0d899f11-785d-4edd-a951-bac82fae074f	BAHIA	BA	\N	2026-06-02 11:58:46.60764	2026-06-02 11:58:46.60764	f	\N	\N	\N	\N	\N	\N	\N	45	t	\N	\N
4ec450a6-7046-4326-ba4d-30682e19f928	073944	ANDRE LUIS CASTELO BRANCO	\N	\N	\N	\N	\N	2024-06-17	ativo	transferencia	c9e71c1f-6fda-4087-9815-9198f7130ce5	4489b3ec-6774-4a13-bc24-31b77deb6ae7	0d899f11-785d-4edd-a951-bac82fae074f	SALGUEIRO	PE	https://lqggoshphakeuufibdno.supabase.co/storage/v1/object/public/funcionarios/fotos/1780000634881.png	2026-05-28 20:37:15.653054	2026-05-28 20:37:15.653054	f	\N	\N	\N	2026-03-17	\N	\N	\N	45	t	\N	2b753fd1-03b8-433a-a187-24f4b5ccb1de
e9c22eeb-8b44-45ef-b301-91e65cc90d2e	075812	ESMAEL CARLOS NASCIMENTO DOS SANTOS	\N	\N	\N	\N	\N	2026-04-23	ativo	nova_admissao	b19eb87e-ab83-4460-b57f-f0302aaa1f0d	4489b3ec-6774-4a13-bc24-31b77deb6ae7	0d899f11-785d-4edd-a951-bac82fae074f	RIO DE JANEIRO	RJ	https://lqggoshphakeuufibdno.supabase.co/storage/v1/object/public/funcionarios/fotos/1781717039496.png	2026-06-02 11:57:10.90763	2026-06-02 11:57:10.90763	f	\N	\N	\N	\N	\N	\N	\N	45	f	\N	5e1a3306-b40c-4277-8c03-5e317063af3b
8a34f64c-b0af-4a24-a75e-949668c8697f	075798	FABIO LUIZ DE FARIAS	\N	\N	\N	\N	\N	2026-04-15	ativo	nova_admissao	b19eb87e-ab83-4460-b57f-f0302aaa1f0d	4489b3ec-6774-4a13-bc24-31b77deb6ae7	0d899f11-785d-4edd-a951-bac82fae074f	CAMPESTRE	AL	https://lqggoshphakeuufibdno.supabase.co/storage/v1/object/public/funcionarios/fotos/1781717084764.jpeg	2026-06-02 11:57:10.90763	2026-06-02 11:57:10.90763	f	\N	\N	\N	\N	\N	\N	\N	45	f	\N	c8e6e203-9c03-42cb-9a30-63fca14dc225
2eafdcdf-2226-40ed-85f6-cbf92b4257ce	075830	CLAUDIO ASTRO CARVALHO	\N	\N	\N	\N	\N	2026-04-28	ativo	nova_admissao	c5ddb144-5847-4aec-b64b-cb346f96cfad	4489b3ec-6774-4a13-bc24-31b77deb6ae7	0d899f11-785d-4edd-a951-bac82fae074f	CANDEIAS	BA	https://lqggoshphakeuufibdno.supabase.co/storage/v1/object/public/funcionarios/fotos/1781716921397.jpeg	2026-06-02 11:56:26.625017	2026-06-02 11:56:26.625017	f	\N	\N	\N	\N	\N	\N	\N	45	f	\N	\N
535de7df-c99c-491c-9a5d-670134c0d556	075834	JERRI SANTOS DA CONCEICAO PINTO	\N	\N	\N	\N	\N	2026-05-04	ativo	nova_admissao	c5ddb144-5847-4aec-b64b-cb346f96cfad	4489b3ec-6774-4a13-bc24-31b77deb6ae7	0d899f11-785d-4edd-a951-bac82fae074f	CANDEIAS	BA	https://lqggoshphakeuufibdno.supabase.co/storage/v1/object/public/funcionarios/fotos/1781717334697.jpeg	2026-06-02 11:58:46.60764	2026-06-02 11:58:46.60764	f	\N	\N	\N	\N	\N	\N	\N	45	f	\N	e42bb35b-e6c4-4db2-8c2b-4c2e8f69a2e3
82c546e3-4ba9-4ddd-a28b-c303a2ba31c2	075785	WATILA RODRIGUES MIRANDA	\N	\N	\N	\N	\N	2026-04-07	ativo	nova_admissao	\N	4489b3ec-6774-4a13-bc24-31b77deb6ae7	0d899f11-785d-4edd-a951-bac82fae074f	CRUZEIRO	SP	https://lqggoshphakeuufibdno.supabase.co/storage/v1/object/public/funcionarios/fotos/1779978635722.png	2026-05-28 13:10:08.939279	2026-05-28 13:10:08.939279	f	\N	\N	\N	2026-04-15	\N	TÉCNICO DE SEGURANÇA DO TRABALHO	\N	45	f	\N	7e18e7ce-a57d-4369-88de-8097c3286957
487b61f7-2889-4a34-b50c-9c7db75c7d5f	075813	JADSON SANTOS DOS SANTOS	\N	\N	\N	\N	\N	2026-04-23	ativo	nova_admissao	cde079dd-2d53-44c2-9054-6245d154bcf6	4489b3ec-6774-4a13-bc24-31b77deb6ae7	0d899f11-785d-4edd-a951-bac82fae074f	CATU	BA	https://lqggoshphakeuufibdno.supabase.co/storage/v1/object/public/funcionarios/fotos/1781717307522.png	2026-06-02 11:58:46.60764	2026-06-02 11:58:46.60764	f	\N	\N	\N	\N	\N	\N	\N	45	f	\N	5e1a3306-b40c-4277-8c03-5e317063af3b
4591a4bb-62f1-48aa-af12-082afd9a16b8	075822	JOSE MARCELO DE SOUSA	\N	\N	\N	\N	\N	2026-04-24	ativo	nova_admissao	55c090af-e003-4b88-b130-6cd81c801d33	4489b3ec-6774-4a13-bc24-31b77deb6ae7	0d899f11-785d-4edd-a951-bac82fae074f	ICO	CE	https://lqggoshphakeuufibdno.supabase.co/storage/v1/object/public/funcionarios/fotos/1781717444676.png	2026-06-02 11:59:33.324033	2026-06-02 11:59:33.324033	f	\N	\N	\N	\N	\N	\N	\N	45	f	\N	7e18e7ce-a57d-4369-88de-8097c3286957
258bcf6b-a4cb-4fa1-b3a5-8171244ba5bb	075805	JOSE RENATO DA GLORIA SANTOS	\N	\N	\N	\N	\N	2026-04-23	ativo	nova_admissao	c5ddb144-5847-4aec-b64b-cb346f96cfad	4489b3ec-6774-4a13-bc24-31b77deb6ae7	0d899f11-785d-4edd-a951-bac82fae074f	SALVADOR	BA	https://lqggoshphakeuufibdno.supabase.co/storage/v1/object/public/funcionarios/fotos/1781717462820.png	2026-06-02 11:59:33.324033	2026-06-02 11:59:33.324033	f	\N	\N	\N	\N	\N	\N	\N	45	f	\N	5e1a3306-b40c-4277-8c03-5e317063af3b
450ab820-1b2e-484e-ad36-c5e5eab184f9	75693	DAVID MAKLIN DOS ANJOS OLIVEIRA	\N	\N	\N	\N	\N	2025-11-04	ativo	efetivo	\N	4489b3ec-6774-4a13-bc24-31b77deb6ae7	0ea37ce8-5f9d-4270-ac46-73e6c169c6d2	\N	\N	https://lqggoshphakeuufibdno.supabase.co/storage/v1/object/public/funcionarios/fotos/1781866401336.jpeg	2026-06-19 10:53:23.510675	2026-06-19 10:53:23.510675	f	\N	\N	\N	2026-06-09	\N	SOLDADOR	\N	30	f	\N	\N
c19914f1-62c7-4299-8ce8-ce9f35ce98f9	070252	USIEL BRAZ RIBEIRO	\N	\N	\N	\N	\N	2018-12-10	ativo	nova_admissao	050b8cd2-1116-4b81-ab1d-e69eebc8c823	4489b3ec-6774-4a13-bc24-31b77deb6ae7	0d899f11-785d-4edd-a951-bac82fae074f	SERRA	AL	\N	2026-06-03 14:53:50.827647	2026-06-03 14:53:50.827647	f	\N	\N	\N	2026-05-13	\N	\N	\N	45	t	\N	\N
cdd7635f-3086-47e8-a87f-3227c76f084f	075708	FRANCISCO SANTIAGO DA SILVA	\N	\N	\N	\N	\N	2025-11-10	ativo	nova_admissao	f5c1578b-6c06-4b0c-a7f6-165779ef8751	4489b3ec-6774-4a13-bc24-31b77deb6ae7	0d899f11-785d-4edd-a951-bac82fae074f	CABECEIRAS DO PIAUI	PI	\N	2026-06-03 12:56:19.930749	2026-06-03 12:56:19.930749	f	\N	\N	\N	\N	\N	\N	\N	45	t	\N	\N
938c088b-e817-4c43-acd6-2571d19bee32	075835	LAMEQUE RODRIGUES SILVA SOARES	\N	\N	\N	\N	\N	2026-05-04	ativo	nova_admissao	55c090af-e003-4b88-b130-6cd81c801d33	4489b3ec-6774-4a13-bc24-31b77deb6ae7	0d899f11-785d-4edd-a951-bac82fae074f	BOQUEIRAO DO PIAUI	PI	https://lqggoshphakeuufibdno.supabase.co/storage/v1/object/public/funcionarios/fotos/1781717504033.png	2026-06-02 11:59:33.324033	2026-06-02 11:59:33.324033	f	\N	\N	\N	\N	\N	\N	\N	45	f	\N	e42bb35b-e6c4-4db2-8c2b-4c2e8f69a2e3
4e187f38-3016-46e7-ac27-22928d5338f3	075532	DENIS BARBOSA DOS SANTOS	\N	\N	\N	\N	\N	2025-06-16	ativo	nova_admissao	fb4ee1c9-e474-462a-8978-e9d53c83bc09	4489b3ec-6774-4a13-bc24-31b77deb6ae7	0d899f11-785d-4edd-a951-bac82fae074f	GRANJA	CE	\N	2026-06-03 12:56:19.930749	2026-06-03 12:56:19.930749	f	\N	\N	\N	\N	\N	\N	\N	30	t	\N	e42bb35b-e6c4-4db2-8c2b-4c2e8f69a2e3
3ce155ae-16fa-4fd2-90a2-3cfa719a6867	075851	ANTONIO SANTOS PORTUGAL	\N	\N	\N	\N	\N	2026-05-07	ativo	nova_admissao	338d331e-ef03-4d94-9369-567ee922f1e9	4489b3ec-6774-4a13-bc24-31b77deb6ae7	0d899f11-785d-4edd-a951-bac82fae074f	CATU	BA	https://lqggoshphakeuufibdno.supabase.co/storage/v1/object/public/funcionarios/fotos/1781716824018.png	2026-06-03 12:56:19.930749	2026-06-03 12:56:19.930749	f	\N	\N	\N	\N	\N	\N	\N	45	f	\N	\N
0abe8010-ac69-4277-af3d-9a00185b24cd	075888	PAULO RANGEL DE SA PACHECO	\N	\N	\N	\N	\N	2026-05-28	ativo	nova_admissao	cde079dd-2d53-44c2-9054-6245d154bcf6	4489b3ec-6774-4a13-bc24-31b77deb6ae7	0d899f11-785d-4edd-a951-bac82fae074f	PAULO AFONSO	BA	https://lqggoshphakeuufibdno.supabase.co/storage/v1/object/public/funcionarios/fotos/1781717810301.png	2026-06-03 14:44:30.37229	2026-06-03 14:44:30.37229	f	\N	\N	\N	\N	\N	\N	\N	45	f	\N	\N
d9a91097-6b3d-4fd8-adc7-7105b2411e3a	010620	RAIMUNDO NONATO DO NASCIMENTO SANTOS	\N	\N	\N	\N	\N	2005-02-14	ativo	nova_admissao	cc968949-d283-47c4-9fd3-d6057d0db40f	4489b3ec-6774-4a13-bc24-31b77deb6ae7	0d899f11-785d-4edd-a951-bac82fae074f	SAO PAULO	SP	\N	2026-06-02 12:00:30.485356	2026-06-02 12:00:30.485356	f	\N	\N	\N	\N	\N	\N	\N	45	t	\N	7e18e7ce-a57d-4369-88de-8097c3286957
17cbdc3e-d043-4eb5-8771-b72a7ac2297a	075864	ANTONIO DAMASCENO NOGUEIRA	\N	\N	\N	\N	\N	2026-05-14	ativo	nova_admissao	32b24cfd-b79a-4b2b-a72d-5cf2a131205c	4489b3ec-6774-4a13-bc24-31b77deb6ae7	0d899f11-785d-4edd-a951-bac82fae074f	JAGUARUANA	CE	https://lqggoshphakeuufibdno.supabase.co/storage/v1/object/public/funcionarios/fotos/1780666534267.jpg	2026-06-03 12:56:19.930749	2026-06-03 12:56:19.930749	f	\N	\N	\N	\N	\N	\N	\N	45	f	\N	\N
a4f56911-ea8e-4087-8328-6eee7c4a6e6e	73759	ALAN FERREIRA ALVES	\N	\N	\N	\N	\N	2024-04-11	transferido	transferencia	4a5727db-1089-4ea5-9908-b25ec46a181f	4489b3ec-6774-4a13-bc24-31b77deb6ae7	0d899f11-785d-4edd-a951-bac82fae074f	REMANSO	BA	\N	2026-06-03 14:17:45.258509	2026-06-03 14:17:45.258509	t	2026-06-15	14d12f35-cd36-4357-9b1e-2e284d11e6a7	24016	\N	\N	\N		45	t	\N	\N
da0d21d6-2889-4fea-b08a-bb5fca1c0c0c	075193	DIOGO DOS SANTOS ARAUJO	\N	\N	\N	\N	\N	2025-03-07	ativo	nova_admissao	fb4ee1c9-e474-462a-8978-e9d53c83bc09	4489b3ec-6774-4a13-bc24-31b77deb6ae7	0d899f11-785d-4edd-a951-bac82fae074f	JAGUARUANA	CE	\N	2026-06-03 12:56:19.930749	2026-06-03 12:56:19.930749	f	\N	\N	\N	\N	\N	\N	\N	30	t	\N	\N
4ac7e8e1-f572-4fbc-970d-aeff6ba5f6d2	075550	EDMAR GUILHERMINO DA SILVA	\N	\N	\N	\N	\N	2025-06-26	ativo	nova_admissao	f5c1578b-6c06-4b0c-a7f6-165779ef8751	4489b3ec-6774-4a13-bc24-31b77deb6ae7	0d899f11-785d-4edd-a951-bac82fae074f	LIMOEIRO DO NORTE	CE	\N	2026-06-03 12:56:19.930749	2026-06-03 12:56:19.930749	f	\N	\N	\N	\N	\N	\N	\N	30	t	\N	\N
7cb832dc-023a-405c-bece-962bddd22d0c	073163	JOSE HERCULES DA SILVA	\N	\N	\N	\N	\N	2023-10-09	ativo	nova_admissao	f5c1578b-6c06-4b0c-a7f6-165779ef8751	4489b3ec-6774-4a13-bc24-31b77deb6ae7	0d899f11-785d-4edd-a951-bac82fae074f	SAO JOSE DO BELMONTE	PE	\N	2026-06-03 12:56:19.930749	2026-06-03 12:56:19.930749	f	\N	\N	\N	\N	\N	\N	\N	45	t	\N	\N
ba0aa0ea-4f84-4c79-8ca0-01bf069ff89e	075849	LUIZ GABRIEL DOS SANTOS ATAIDE	\N	\N	\N	\N	\N	2026-05-07	ativo	nova_admissao	338d331e-ef03-4d94-9369-567ee922f1e9	4489b3ec-6774-4a13-bc24-31b77deb6ae7	0d899f11-785d-4edd-a951-bac82fae074f	CATU	BA	https://lqggoshphakeuufibdno.supabase.co/storage/v1/object/public/funcionarios/fotos/1781717605704.png	2026-06-03 14:25:52.840486	2026-06-03 14:25:52.840486	f	\N	\N	\N	\N	\N	\N	\N	45	f	\N	\N
41f17b9c-a715-4227-92d0-4caf7fa2d8dd	075865	KAWANN DOS SANTOS TENORIO FEITOSA	\N	\N	\N	\N	\N	2026-05-14	ativo	nova_admissao	338d331e-ef03-4d94-9369-567ee922f1e9	4489b3ec-6774-4a13-bc24-31b77deb6ae7	0d899f11-785d-4edd-a951-bac82fae074f	VENTUROSA	PE	https://lqggoshphakeuufibdno.supabase.co/storage/v1/object/public/funcionarios/fotos/1781717480962.jpg	2026-06-03 12:56:19.930749	2026-06-03 12:56:19.930749	f	\N	\N	\N	\N	\N	\N	\N	45	f	\N	\N
c7758861-4f49-4632-9762-19f5f495a2df	075814	RICARDO CESAR COSTA SANTOS	\N	\N	\N	\N	\N	2026-04-23	ativo	nova_admissao	8829bd95-36aa-4565-ae5d-c4f170124b38	4489b3ec-6774-4a13-bc24-31b77deb6ae7	0d899f11-785d-4edd-a951-bac82fae074f	CATU	BA	https://lqggoshphakeuufibdno.supabase.co/storage/v1/object/public/funcionarios/fotos/1781717859000.png	2026-06-02 12:00:30.485356	2026-06-02 12:00:30.485356	f	\N	\N	\N	\N	\N	\N	\N	45	f	\N	5e1a3306-b40c-4277-8c03-5e317063af3b
709ab55a-f7ed-4e80-a404-49f293fb6447	075880	NAIRAN DOS SANTOS	\N	\N	\N	\N	\N	2026-05-25	ativo	nova_admissao	338d331e-ef03-4d94-9369-567ee922f1e9	4489b3ec-6774-4a13-bc24-31b77deb6ae7	0d899f11-785d-4edd-a951-bac82fae074f	CATU	BA	https://lqggoshphakeuufibdno.supabase.co/storage/v1/object/public/funcionarios/fotos/1781717766418.png	2026-06-03 14:34:35.253388	2026-06-03 14:34:35.253388	f	\N	\N	\N	\N	\N	\N	\N	45	f	\N	\N
a032b7df-3ea8-4faa-b17d-4f5dbbd52994	075810	PEDRO JUNIOR CELESTINO DE OLIVEIRA	\N	\N	\N	\N	\N	2026-04-23	ativo	nova_admissao	b19eb87e-ab83-4460-b57f-f0302aaa1f0d	4489b3ec-6774-4a13-bc24-31b77deb6ae7	0d899f11-785d-4edd-a951-bac82fae074f	CAMPINAS DO PIAUI	PI	https://lqggoshphakeuufibdno.supabase.co/storage/v1/object/public/funcionarios/fotos/1781717829139.png	2026-06-02 12:00:30.485356	2026-06-02 12:00:30.485356	f	\N	\N	\N	\N	\N	\N	\N	45	f	\N	\N
34062719-61cf-4ef3-b1cc-21bb8a2c0381	73242	RAFAEL FERREIRA ALVES	\N	\N	\N	\N	\N	2023-11-01	ativo	nova_admissao	a3d6cf77-3d10-4d60-a93d-a109ac86164a	4489b3ec-6774-4a13-bc24-31b77deb6ae7	0d899f11-785d-4edd-a951-bac82fae074f	REMANSO	SP	\N	2026-06-03 14:46:49.51767	2026-06-03 14:46:49.51767	f	\N	\N	\N	\N	\N	\N	\N	45	t	\N	\N
7c2b7107-4bfa-4a19-9d26-060dbfc1924c	075867	ROSEMEIRE DE SOUZA MACHADO	\N	\N	\N	\N	\N	2026-05-18	ativo	nova_admissao	2aa35742-5a21-4e8c-be75-f9dbd6254ec9	4489b3ec-6774-4a13-bc24-31b77deb6ae7	0d899f11-785d-4edd-a951-bac82fae074f	SALTO	SP	https://lqggoshphakeuufibdno.supabase.co/storage/v1/object/public/funcionarios/fotos/1781717911277.png	2026-06-02 12:00:30.485356	2026-06-02 12:00:30.485356	f	\N	\N	\N	\N	\N	\N	\N	45	f	\N	\N
fceb40d4-e6ad-4ef6-8e1e-86a175343cf2	075847	GABRIEL OLIVEIRA DOS SANTOS	\N	\N	\N	\N	\N	2026-05-07	ativo	nova_admissao	338d331e-ef03-4d94-9369-567ee922f1e9	4489b3ec-6774-4a13-bc24-31b77deb6ae7	0d899f11-785d-4edd-a951-bac82fae074f	JAGUARUANA	CE	https://lqggoshphakeuufibdno.supabase.co/storage/v1/object/public/funcionarios/fotos/1781717214063.png	2026-06-03 12:56:19.930749	2026-06-03 12:56:19.930749	f	\N	\N	\N	\N	\N	\N	\N	45	f	\N	\N
ebaee1a5-8c6f-4ffa-befa-0280b24d7e2b	075866	IVANILDO DE JESUS SANTOS	\N	\N	\N	\N	\N	2026-05-14	ativo	nova_admissao	338d331e-ef03-4d94-9369-567ee922f1e9	4489b3ec-6774-4a13-bc24-31b77deb6ae7	0d899f11-785d-4edd-a951-bac82fae074f	CATU	BA	https://lqggoshphakeuufibdno.supabase.co/storage/v1/object/public/funcionarios/fotos/1781717284237.png	2026-06-03 12:56:19.930749	2026-06-03 12:56:19.930749	f	\N	\N	\N	\N	\N	\N	\N	45	f	\N	\N
a1aebbf0-c987-4a62-82ab-941ed4e7e7b1	75855	WASHINGTON LUIS BARBOSA VENTURA JUNIOR	\N	\N	\N	\N	\N	2026-05-11	ativo	nova_admissao	55c090af-e003-4b88-b130-6cd81c801d33	4489b3ec-6774-4a13-bc24-31b77deb6ae7	0d899f11-785d-4edd-a951-bac82fae074f	SERTAOZINHO	SP	https://lqggoshphakeuufibdno.supabase.co/storage/v1/object/public/funcionarios/fotos/1781718041475.jpeg	2026-06-03 14:58:31.564419	2026-06-03 14:58:31.564419	f	\N	\N	\N	2026-05-12	\N	\N	\N	45	f	\N	\N
8d639c58-49c6-45bb-83cf-a13f2cf355b5	075808	MARCOS BISPO ASSUNCAO	\N	\N	\N	\N	\N	2026-04-23	ativo	nova_admissao	55c090af-e003-4b88-b130-6cd81c801d33	4489b3ec-6774-4a13-bc24-31b77deb6ae7	0d899f11-785d-4edd-a951-bac82fae074f	CATU	BA	https://lqggoshphakeuufibdno.supabase.co/storage/v1/object/public/funcionarios/fotos/1781717665910.png	2026-06-02 11:59:33.324033	2026-06-02 11:59:33.324033	f	\N	\N	\N	\N	\N	\N	\N	45	f	\N	5e1a3306-b40c-4277-8c03-5e317063af3b
f09fc646-1a8f-4a6e-8849-d237631a8849	075853	ARGEL QUEIROZ SANTANA	\N	\N	\N	\N	\N	2026-05-07	ativo	nova_admissao	6bd0e213-c32c-463f-9186-af82541d0781	4489b3ec-6774-4a13-bc24-31b77deb6ae7	0d899f11-785d-4edd-a951-bac82fae074f	RIBEIRAO BONITO	SP	https://lqggoshphakeuufibdno.supabase.co/storage/v1/object/public/funcionarios/fotos/1781716848305.png	2026-06-03 12:56:19.930749	2026-06-03 12:56:19.930749	f	\N	\N	\N	\N	\N	\N	\N	45	f	\N	e42bb35b-e6c4-4db2-8c2b-4c2e8f69a2e3
c8a7bf35-ee8a-46e6-8fcb-9d101bed387c	075850	MARIA DAS GRACAS DOS SANTOS E SILVA	\N	\N	\N	\N	\N	2026-05-07	ativo	nova_admissao	d698cd65-a9cd-4419-9e23-7b9df75cfe37	4489b3ec-6774-4a13-bc24-31b77deb6ae7	0d899f11-785d-4edd-a951-bac82fae074f	SALTO	SP	https://lqggoshphakeuufibdno.supabase.co/storage/v1/object/public/funcionarios/fotos/1781717706932.png	2026-06-02 12:00:30.485356	2026-06-02 12:00:30.485356	f	\N	\N	\N	\N	\N	\N	\N	45	f	\N	\N
beaa74bb-c384-406f-9b10-5a1b33565e53	075846	SIRLEI DA SILVA GILBERTO	\N	\N	\N	\N	\N	2026-05-07	ativo	nova_admissao	d698cd65-a9cd-4419-9e23-7b9df75cfe37	4489b3ec-6774-4a13-bc24-31b77deb6ae7	0d899f11-785d-4edd-a951-bac82fae074f	SALTO	SP	https://lqggoshphakeuufibdno.supabase.co/storage/v1/object/public/funcionarios/fotos/1781717949717.png	2026-06-02 12:00:30.485356	2026-06-02 12:00:30.485356	f	\N	\N	\N	\N	\N	\N	\N	45	f	\N	\N
e17ada04-7fd7-4ae1-891b-ae6ae0145abe	075829	WARLEM ALVES	\N	\N	\N	\N	\N	2026-04-28	ativo	nova_admissao	d656b2d1-ec14-4eb8-8edb-2fb325bc6234	4489b3ec-6774-4a13-bc24-31b77deb6ae7	0d899f11-785d-4edd-a951-bac82fae074f	GUARULHOS	SP	https://lqggoshphakeuufibdno.supabase.co/storage/v1/object/public/funcionarios/fotos/1781718011153.jpeg	2026-06-02 12:01:35.03519	2026-06-02 12:01:35.03519	f	\N	\N	\N	\N	\N	\N	\N	45	f	\N	\N
01c0146c-1416-4271-b9d9-eabd6fcd528e	75728	ANDRESSA PEREIRA SAMPAIO GARCIA	\N	\N	\N	\N	\N	2025-11-26	ativo	nova_admissao	96b3bf34-1ff8-498a-8d79-8b58e6c0d27e	4489b3ec-6774-4a13-bc24-31b77deb6ae7	0ea37ce8-5f9d-4270-ac46-73e6c169c6d2	AMERICANA	SP	https://lqggoshphakeuufibdno.supabase.co/storage/v1/object/public/funcionarios/fotos/1781527445961.png	2026-06-15 12:44:07.882552	2026-06-15 12:44:07.882552	f	\N	\N	\N	2025-11-27	\N	\N	\N	30	t	\N	\N
e3975bc7-b7a1-417c-bc6c-7d4a71e4714d	75734	ADRIANA VELOSO ROSA	\N	\N	\N	\N	\N	2025-12-22	ativo	nova_admissao	dd1a458e-5a2a-40ed-8dc8-982a57e5e5d4	4489b3ec-6774-4a13-bc24-31b77deb6ae7	0ea37ce8-5f9d-4270-ac46-73e6c169c6d2	paulinia	SP	https://lqggoshphakeuufibdno.supabase.co/storage/v1/object/public/funcionarios/fotos/1781525994050.jpg	2026-06-15 12:19:54.542111	2026-06-15 12:19:54.542111	f	\N	\N	\N	2025-12-23	\N	\N	\N	30	t	\N	\N
05f825a2-192a-43d1-8fbe-0279b2c9b178	50187	SANDRO ALMADA COSTA	\N	\N	\N	\N	\N	2014-06-30	transferido	transferencia	90d001ce-a035-470c-b477-de26e0779131	4489b3ec-6774-4a13-bc24-31b77deb6ae7	0d899f11-785d-4edd-a951-bac82fae074f	VOLTA REDONDA	GO	\N	2026-06-03 15:09:34.245242	2026-06-03 15:09:34.245242	t	2026-03-28	25341e31-cd60-4743-ad1b-658397ec5d72	23403	\N	\N	\N		45	t	\N	237dd956-2e0d-4e77-a2bd-26a59253b022
7673456e-e717-47ae-8b74-482af33078d9	75727	SUELLEN MICHAELA DE MOURA UEMOTO	\N	\N	\N	\N	\N	2025-11-26	ativo	nova_admissao	96b3bf34-1ff8-498a-8d79-8b58e6c0d27e	4489b3ec-6774-4a13-bc24-31b77deb6ae7	c2096d7c-a212-4365-9d85-3151167e0436	PAULINIA	SP	\N	2026-06-09 21:22:42.808108	2026-06-09 21:22:42.808108	f	\N	\N	\N	\N	\N	\N	\N	30	t	\N	\N
ccab107c-e256-4d35-a7ce-253c8a108154	75896	NAILTON RODRIGUES DE BRITO	\N	\N	\N	\N	\N	2026-06-10	ativo	nova_admissao	fb4ee1c9-e474-462a-8978-e9d53c83bc09	4489b3ec-6774-4a13-bc24-31b77deb6ae7	0d899f11-785d-4edd-a951-bac82fae074f	NOSSA SENHORA DE NAZARE	PI	\N	2026-06-10 21:33:50.134175	2026-06-10 21:33:50.134175	f	\N	\N	\N	\N	\N	\N	\N	45	f	\N	\N
6d1786b8-676c-4511-94b5-b4123162ae8d	74869	ADAILSON DOS SANTOS MATOS	\N	\N	\N	\N	\N	2025-01-27	ativo	efetivo	cde079dd-2d53-44c2-9054-6245d154bcf6	4489b3ec-6774-4a13-bc24-31b77deb6ae7	0ea37ce8-5f9d-4270-ac46-73e6c169c6d2	ARUANA	SE	https://lqggoshphakeuufibdno.supabase.co/storage/v1/object/public/funcionarios/fotos/1781525774003.png	2026-06-15 12:16:15.269331	2026-06-15 12:16:15.269331	f	\N	\N	\N	2026-02-04	\N	\N	\N	30	t	ALOJADO	8492df23-4608-4b03-a3dc-7e25f361909f
3f70dc11-dc10-41e9-b573-0c962936d7f6	10044	ADILSON DOS SANTOS	\N	\N	\N	\N	\N	1997-02-17	ativo	efetivo	\N	4489b3ec-6774-4a13-bc24-31b77deb6ae7	0ea37ce8-5f9d-4270-ac46-73e6c169c6d2	SÃO PAULO	SP	https://lqggoshphakeuufibdno.supabase.co/storage/v1/object/public/funcionarios/fotos/1781525911879.png	2026-06-15 12:18:21.013825	2026-06-15 12:18:21.013825	f	\N	\N	\N	2025-12-23	\N	ENCARREGADO DE TUBULAÇÃO	\N	30	t	ALOJADO	326e50c1-0ebc-4674-8bf9-a9cac9ea998d
b732b7dc-fb35-4a83-8592-79b587d6f5fd	75816	CARLITO FLORENCIO DOS SANTOS	\N	\N	\N	\N	\N	2026-04-23	ativo	efetivo	\N	4489b3ec-6774-4a13-bc24-31b77deb6ae7	0ea37ce8-5f9d-4270-ac46-73e6c169c6d2	COSMOPOLIS	SP	https://lqggoshphakeuufibdno.supabase.co/storage/v1/object/public/funcionarios/fotos/1781865064936.jpg	2026-06-19 10:31:07.759788	2026-06-19 10:31:07.759788	f	\N	\N	\N	0206-04-29	\N	SOLDADOR	\N	30	f	\N	\N
1ec8fda0-fe03-4578-97d4-04670f7e1091	75803	EMILY VITORIA CARDOSO DA SILVA	\N	\N	\N	\N	\N	2026-04-17	ativo	efetivo	\N	4489b3ec-6774-4a13-bc24-31b77deb6ae7	0ea37ce8-5f9d-4270-ac46-73e6c169c6d2	COSMOPOLIS	SP	https://lqggoshphakeuufibdno.supabase.co/storage/v1/object/public/funcionarios/fotos/1781867095352.jpeg	2026-06-19 11:04:57.548326	2026-06-19 11:04:57.548326	f	\N	\N	\N	2026-04-23	\N	SOLDADOR	\N	30	f	\N	\N
cbc8e27d-503d-4447-9e54-2b774c012b66	73557	ANTONIO JOSE DOS SANTOS	\N	\N	\N	\N	\N	2024-02-08	ativo	efetivo	c5ddb144-5847-4aec-b64b-cb346f96cfad	4489b3ec-6774-4a13-bc24-31b77deb6ae7	0ea37ce8-5f9d-4270-ac46-73e6c169c6d2	CANDEIAS	BA	https://lqggoshphakeuufibdno.supabase.co/storage/v1/object/public/funcionarios/fotos/1781527574095.jpg	2026-06-15 12:46:14.851001	2026-06-15 12:46:14.851001	f	\N	\N	\N	2026-02-05	\N	\N	\N	30	t	ALOJADO	8492df23-4608-4b03-a3dc-7e25f361909f
1773291d-0948-4de1-ab12-5787fc1d75e8	75621	ALAN DOMINGUES BARBOSA	\N	\N	\N	\N	\N	2025-08-20	ativo	nova_admissao	7d9dffa9-1696-4cb1-bfda-1e2fd2fc255a	4489b3ec-6774-4a13-bc24-31b77deb6ae7	0ea37ce8-5f9d-4270-ac46-73e6c169c6d2	paulinia	SP	\N	2026-06-15 12:35:20.775476	2026-06-15 12:35:20.775476	f	\N	\N	\N	2026-01-26	\N	\N	\N	30	t	\N	\N
fcd1f1f3-137d-4e51-9136-928202498461	060853	ALAN CRISTIAN BATISTA MOREIRA	\N	\N	\N	\N	\N	2018-02-09	ativo	efetivo	\N	4489b3ec-6774-4a13-bc24-31b77deb6ae7	c2096d7c-a212-4365-9d85-3151167e0436	PAULÍNIA	SP	https://lqggoshphakeuufibdno.supabase.co/storage/v1/object/public/funcionarios/fotos/1781614259416.jpg	2026-06-16 12:51:00.453229	2026-06-16 12:51:00.453229	f	\N	\N	\N	2024-08-05	\N	SOLDADOR TIG III	\N	30	t	\N	a0f063aa-df41-4780-ab24-82be52000892
04509dd6-4ec3-45fa-9fec-7a5577c0ba5e	070768	ANAILTON DOS SANTOS CHAGAS	\N	\N	\N	\N	\N	2019-11-11	ativo	efetivo	\N	4489b3ec-6774-4a13-bc24-31b77deb6ae7	c2096d7c-a212-4365-9d85-3151167e0436	Americana	SP	https://lqggoshphakeuufibdno.supabase.co/storage/v1/object/public/funcionarios/fotos/1781618126691.jpeg	2026-06-16 13:55:28.575052	2026-06-16 13:55:28.575052	f	\N	\N	\N	2024-08-05	\N	ENCARREGADO DE HIDRAULICA	\N	30	t	\N	\N
2dc15829-c805-4e47-b083-cd17a008b7a9	074116	ANTONIEL DOS SANTOS OLIVEIRA	\N	\N	\N	\N	\N	2024-08-13	ativo	efetivo	\N	4489b3ec-6774-4a13-bc24-31b77deb6ae7	c2096d7c-a212-4365-9d85-3151167e0436	PAULÍNIA	SP	https://lqggoshphakeuufibdno.supabase.co/storage/v1/object/public/funcionarios/fotos/1781618273759.jpg	2026-06-16 13:57:55.336964	2026-06-16 13:57:55.336964	f	\N	\N	\N	2025-09-29	\N	ENCARREGADO DE TUBULACAO	\N	30	t	\N	\N
b8231d04-f70c-4818-95da-8103d8c937a3	074351	ALEXANDRE YASUO E GUSHIKEM	\N	\N	\N	\N	\N	2024-09-23	ativo	efetivo	\N	4489b3ec-6774-4a13-bc24-31b77deb6ae7	c2096d7c-a212-4365-9d85-3151167e0436	PAULÍNIA	SP	https://lqggoshphakeuufibdno.supabase.co/storage/v1/object/public/funcionarios/fotos/1781617850831.png	2026-06-16 13:50:53.970543	2026-06-16 13:50:53.970543	f	\N	\N	\N	2024-10-02	\N	1/2 OFICIAL ENCANADOR	\N	30	t	\N	\N
2ecc58b1-5066-4414-a908-97a36c08b3ec	050930	ARTHUR VINICIUS LISBOA DA SILVA	\N	\N	\N	\N	\N	2015-03-25	ativo	efetivo	02a9da83-895c-4439-adff-aa33c7465e2f	4489b3ec-6774-4a13-bc24-31b77deb6ae7	c2096d7c-a212-4365-9d85-3151167e0436	PAULÍNIA	SP	https://lqggoshphakeuufibdno.supabase.co/storage/v1/object/public/funcionarios/fotos/1781619852512.jpg	2026-06-16 14:24:14.184024	2026-06-16 14:24:14.184024	f	\N	\N	\N	2025-07-02	\N	\N	\N	30	t	\N	7eca1a31-eb4e-4e6e-b853-57bc6c9ac091
e6629df2-78e5-4dfb-8c0a-9dc259cdfce8	074296	ECRISOVALDO ROCHA PIMENTA	\N	\N	\N	\N	\N	2024-09-13	ativo	efetivo	\N	4489b3ec-6774-4a13-bc24-31b77deb6ae7	c2096d7c-a212-4365-9d85-3151167e0436	PAULÍNIA	SP	https://lqggoshphakeuufibdno.supabase.co/storage/v1/object/public/funcionarios/fotos/1781619985133.png	2026-06-16 14:26:27.292506	2026-06-16 14:26:27.292506	f	\N	\N	\N	2024-09-23	\N	MONTADOR DE ANDAIME	\N	30	t	\N	\N
525514fa-d774-4a32-94a5-daf799572396	075207	ANTONIO DE JESUS DA CONCEICAO	\N	\N	\N	\N	\N	2025-03-13	ativo	efetivo	\N	4489b3ec-6774-4a13-bc24-31b77deb6ae7	c2096d7c-a212-4365-9d85-3151167e0436	PAULÍNIA	SP	https://lqggoshphakeuufibdno.supabase.co/storage/v1/object/public/funcionarios/fotos/1781619741068.png	2026-06-16 14:22:22.82631	2026-06-16 14:22:22.82631	f	\N	\N	\N	2025-03-24	\N	1/2 OFICIAL ENCANADOR	\N	30	t	\N	a0f063aa-df41-4780-ab24-82be52000892
478466ce-53df-4ebe-9291-69b4b3d29235	040638	EDENILTON MACEDO SANTOS	\N	\N	\N	\N	\N	2013-09-12	ativo	efetivo	\N	4489b3ec-6774-4a13-bc24-31b77deb6ae7	c2096d7c-a212-4365-9d85-3151167e0436	PAULÍNIA	SP	https://lqggoshphakeuufibdno.supabase.co/storage/v1/object/public/funcionarios/fotos/1781620127432.png	2026-06-16 14:28:49.07179	2026-06-16 14:28:49.07179	f	\N	\N	\N	2024-11-18	\N	ENCANADOR INDUSTRIAL III	\N	30	t	\N	a0f063aa-df41-4780-ab24-82be52000892
f4f5e0c6-a407-471e-9cbe-1c9411c62567	071040	ELIZIER JOSUE DE OLIVEIRA	\N	\N	\N	\N	\N	2020-06-17	ativo	efetivo	2aa35742-5a21-4e8c-be75-f9dbd6254ec9	4489b3ec-6774-4a13-bc24-31b77deb6ae7	c2096d7c-a212-4365-9d85-3151167e0436	PAULÍNIA	SP	https://lqggoshphakeuufibdno.supabase.co/storage/v1/object/public/funcionarios/fotos/1781620737437.jpg	2026-06-16 14:38:58.828596	2026-06-16 14:38:58.828596	f	\N	\N	\N	2024-10-14	\N	\N	\N	30	t	\N	7eca1a31-eb4e-4e6e-b853-57bc6c9ac091
02148a14-530c-4549-a5ac-80af04ce6785	075252	EDSON ALVES BARBOSA	\N	\N	\N	\N	\N	2025-03-27	ativo	efetivo	\N	4489b3ec-6774-4a13-bc24-31b77deb6ae7	c2096d7c-a212-4365-9d85-3151167e0436	PAULÍNIA	SP	https://lqggoshphakeuufibdno.supabase.co/storage/v1/object/public/funcionarios/fotos/1781620241748.png	2026-06-16 14:30:42.999056	2026-06-16 14:30:42.999056	f	\N	\N	\N	2025-08-20	\N	MONTADOR DE ANDAIME	\N	30	t	\N	7eca1a31-eb4e-4e6e-b853-57bc6c9ac091
174521ea-a404-4d8d-bbc5-d9806cf45983	075765	FRANCISCA RAQUEL DA SILVA	\N	\N	\N	\N	\N	2026-02-25	ativo	efetivo	d698cd65-a9cd-4419-9e23-7b9df75cfe37	4489b3ec-6774-4a13-bc24-31b77deb6ae7	c2096d7c-a212-4365-9d85-3151167e0436	PAULÍNIA	SP	https://lqggoshphakeuufibdno.supabase.co/storage/v1/object/public/funcionarios/fotos/1781621459152.jpg	2026-06-16 14:51:01.74589	2026-06-16 14:51:01.74589	f	\N	\N	\N	2026-03-04	\N	\N	\N	30	t	\N	\N
8dc6d6ec-427a-4a80-8175-97ce13b57c8f	075649	GUSTAVO ALCANTARA MENEZES	\N	\N	\N	\N	\N	2025-09-15	ativo	efetivo	338d331e-ef03-4d94-9369-567ee922f1e9	4489b3ec-6774-4a13-bc24-31b77deb6ae7	c2096d7c-a212-4365-9d85-3151167e0436	PAULÍNIA	SP	https://lqggoshphakeuufibdno.supabase.co/storage/v1/object/public/funcionarios/fotos/1781621754633.jpg	2026-06-16 14:55:56.353841	2026-06-16 14:55:56.353841	f	\N	\N	\N	2025-09-17	\N	\N	\N	30	t	\N	\N
5868da5b-e78e-4c06-85cc-fce019066e3e	1073643	JOSE ADRIANO RODRIGUES DE MENDONCA	\N	\N	\N	\N	\N	2024-03-06	ativo	efetivo	\N	4489b3ec-6774-4a13-bc24-31b77deb6ae7	c2096d7c-a212-4365-9d85-3151167e0436	PAULÍNIA	SP	https://lqggoshphakeuufibdno.supabase.co/storage/v1/object/public/funcionarios/fotos/1781638016414.jpg	2026-06-16 19:26:58.965384	2026-06-16 19:26:58.965384	f	\N	\N	\N	2024-12-02	\N	PINTOR	\N	30	t	\N	a0f063aa-df41-4780-ab24-82be52000892
06be1efc-148e-4b38-930c-96ba72b4eca1	75779	ALESSANDRO BARBIERI	\N	\N	\N	\N	\N	2026-03-19	ativo	nova_admissao	02a9da83-895c-4439-adff-aa33c7465e2f	4489b3ec-6774-4a13-bc24-31b77deb6ae7	0ea37ce8-5f9d-4270-ac46-73e6c169c6d2	ESTANCIA	SE	https://lqggoshphakeuufibdno.supabase.co/storage/v1/object/public/funcionarios/fotos/1781526967706.jpg	2026-06-15 12:36:08.439582	2026-06-15 12:36:08.439582	f	\N	\N	\N	2026-03-26	\N	\N	\N	30	t	ALOJADO	326e50c1-0ebc-4674-8bf9-a9cac9ea998d
4594413b-1406-43f1-b3ed-5af30a6ab880	075594	JHONATAN GABRIEL LELES ARCENIO	\N	\N	\N	\N	\N	2025-07-25	ativo	efetivo	\N	4489b3ec-6774-4a13-bc24-31b77deb6ae7	c2096d7c-a212-4365-9d85-3151167e0436	PAULÍNIA	SP	https://lqggoshphakeuufibdno.supabase.co/storage/v1/object/public/funcionarios/fotos/1781621877877.jpg	2026-06-16 14:57:59.36855	2026-06-16 14:57:59.36855	f	\N	\N	\N	2025-07-30	\N	1/2 OFICIAL ENCANADOR	\N	30	t	\N	\N
cab0afc8-2ced-4941-b1e1-e9521af4cbd3	71687	CICERO ROMAO MONTEIRO	\N	\N	\N	\N	\N	2022-03-24	ativo	efetivo	02a9da83-895c-4439-adff-aa33c7465e2f	145e0a9b-f796-4db5-92e9-33f046f959ae	0ea37ce8-5f9d-4270-ac46-73e6c169c6d2	Jaboatão dos Guararapes	PE	https://lqggoshphakeuufibdno.supabase.co/storage/v1/object/public/funcionarios/fotos/1781865692126.jpg	2026-06-19 10:39:27.856054	2026-06-19 10:39:27.856054	f	\N	\N	\N	2026-01-06	\N	\N	\N	30	f	\N	\N
c9234c19-cf5c-418f-9a5a-7e93111437c5	071288	JOSE GERNANDE DA SILVA	\N	\N	\N	\N	\N	2021-08-03	ativo	efetivo	c5ddb144-5847-4aec-b64b-cb346f96cfad	4489b3ec-6774-4a13-bc24-31b77deb6ae7	c2096d7c-a212-4365-9d85-3151167e0436	PAULÍNIA	SP	https://lqggoshphakeuufibdno.supabase.co/storage/v1/object/public/funcionarios/fotos/1781697691372.png	2026-06-17 12:01:32.666482	2026-06-17 12:01:32.666482	f	\N	\N	\N	2024-08-05	\N	\N	\N	30	t	\N	a0f063aa-df41-4780-ab24-82be52000892
89d1953b-5cff-423d-9239-12133d971027	072779	VALDEIR DE JESUS JACO	\N	\N	\N	\N	\N	2023-08-03	ativo	efetivo	abbe59ac-4003-4208-8495-c87d8d73fb14	4489b3ec-6774-4a13-bc24-31b77deb6ae7	c2096d7c-a212-4365-9d85-3151167e0436	PAULÍNIA	SP	https://lqggoshphakeuufibdno.supabase.co/storage/v1/object/public/funcionarios/fotos/1781699587730.jpg	2026-06-17 12:33:08.931013	2026-06-17 12:33:08.931013	f	\N	\N	\N	2025-06-04	\N	\N	\N	30	t	\N	a0f063aa-df41-4780-ab24-82be52000892
ed412871-9102-4065-bcf9-d16a9e7bea81	073463	WELITON BASTIAO PEREIRA DOS SANTOS	\N	\N	\N	\N	\N	2024-01-23	ativo	efetivo	\N	4489b3ec-6774-4a13-bc24-31b77deb6ae7	c2096d7c-a212-4365-9d85-3151167e0436	PAULÍNIA	SP	https://lqggoshphakeuufibdno.supabase.co/storage/v1/object/public/funcionarios/fotos/1781699771245.jpeg	2026-06-17 12:36:11.777981	2026-06-17 12:36:11.777981	f	\N	\N	\N	2024-08-05	\N	SOLDADOR	\N	30	t	\N	a0f063aa-df41-4780-ab24-82be52000892
08df0e04-feb3-40e9-95ea-335a8cc2e69b	073489	RODRIGO DE SOUSA AMORIM	\N	\N	\N	\N	\N	2024-01-29	ativo	efetivo	b19eb87e-ab83-4460-b57f-f0302aaa1f0d	4489b3ec-6774-4a13-bc24-31b77deb6ae7	c2096d7c-a212-4365-9d85-3151167e0436	AMERICANA	SP	https://lqggoshphakeuufibdno.supabase.co/storage/v1/object/public/funcionarios/fotos/1781699311793.jpg	2026-06-17 12:28:32.505405	2026-06-17 12:28:32.505405	f	\N	\N	\N	2024-09-11	\N	\N	\N	30	t	\N	\N
fc6858ac-ef5e-4f74-b8e2-671bba1b5fa8	073587	MARIA FATIMA DE SOUZA SILVA	\N	\N	\N	\N	\N	2024-02-15	ativo	efetivo	d698cd65-a9cd-4419-9e23-7b9df75cfe37	4489b3ec-6774-4a13-bc24-31b77deb6ae7	c2096d7c-a212-4365-9d85-3151167e0436	AMERICANA	SP	https://lqggoshphakeuufibdno.supabase.co/storage/v1/object/public/funcionarios/fotos/1781698777773.jpg	2026-06-17 12:19:38.696863	2026-06-17 12:19:38.696863	f	\N	\N	\N	2025-07-28	\N	\N	\N	30	t	\N	\N
0118ef0a-337e-44e1-9eaf-b6e65959576c	074131	JOSE AMILTON DA SILVA	\N	\N	\N	\N	\N	2024-08-19	ativo	efetivo	914d6d69-7338-4197-be53-ac04a5216eba	4489b3ec-6774-4a13-bc24-31b77deb6ae7	c2096d7c-a212-4365-9d85-3151167e0436	COSMÓPOLIS	SP	https://lqggoshphakeuufibdno.supabase.co/storage/v1/object/public/funcionarios/fotos/1781697347017.jpg	2026-06-17 11:55:48.189998	2026-06-17 11:55:48.189998	f	\N	\N	\N	2024-08-26	\N	\N	\N	30	t	\N	\N
05159e14-4a04-4b7a-9e4f-4cb43d138925	074819	PAULO RICARDO PEREIRA SANTOS	\N	\N	\N	\N	\N	2025-01-10	ativo	efetivo	cde079dd-2d53-44c2-9054-6245d154bcf6	4489b3ec-6774-4a13-bc24-31b77deb6ae7	c2096d7c-a212-4365-9d85-3151167e0436	PAULÍNIA	SP	https://lqggoshphakeuufibdno.supabase.co/storage/v1/object/public/funcionarios/fotos/1781699105821.jpg	2026-06-17 12:25:06.477284	2026-06-17 12:25:06.477284	f	\N	\N	\N	2025-06-04	\N	\N	\N	30	t	\N	a0f063aa-df41-4780-ab24-82be52000892
da7daf8d-03ce-4d85-8cc9-834ff097e5ac	074948	JOSE SERGIO DOS SANTOS	\N	\N	\N	\N	\N	2025-02-05	ativo	efetivo	\N	4489b3ec-6774-4a13-bc24-31b77deb6ae7	c2096d7c-a212-4365-9d85-3151167e0436	PAULÍNIA	SP	https://lqggoshphakeuufibdno.supabase.co/storage/v1/object/public/funcionarios/fotos/1781698406797.jpg	2026-06-17 12:13:28.545241	2026-06-17 12:13:28.545241	f	\N	\N	\N	2025-08-20	\N	MONTADOR DE ANDAIME	\N	30	t	\N	7eca1a31-eb4e-4e6e-b853-57bc6c9ac091
cf3d40a3-3ecc-47a3-8392-0d6e6b7dbe28	075442	PAULO CESAR FELISBINO	\N	\N	\N	\N	\N	2025-04-30	ativo	efetivo	\N	4489b3ec-6774-4a13-bc24-31b77deb6ae7	c2096d7c-a212-4365-9d85-3151167e0436	PAULÍNIA	SP	https://lqggoshphakeuufibdno.supabase.co/storage/v1/object/public/funcionarios/fotos/1781698997817.jpg	2026-06-17 12:23:18.69213	2026-06-17 12:23:18.69213	f	\N	\N	\N	2025-05-12	\N	SOLDADOR	\N	30	t	\N	\N
9b1db7a4-3854-4992-b915-1047c364fa46	075620	LUIZ HENRIQUE FELISBINO	\N	\N	\N	\N	\N	2025-08-20	ativo	efetivo	338d331e-ef03-4d94-9369-567ee922f1e9	4489b3ec-6774-4a13-bc24-31b77deb6ae7	c2096d7c-a212-4365-9d85-3151167e0436	PAULÍNIA	SP	https://lqggoshphakeuufibdno.supabase.co/storage/v1/object/public/funcionarios/fotos/1781698660378.jpg	2026-06-17 12:17:41.170255	2026-06-17 12:17:41.170255	f	\N	\N	\N	2025-08-25	\N	\N	\N	30	t	\N	\N
aa9c3270-d2e3-46fe-950e-0f9647077ff8	075618	UEIDRISSON ANDREI PEREIRA GOMES	\N	\N	\N	\N	\N	2025-08-20	ativo	efetivo	914d6d69-7338-4197-be53-ac04a5216eba	4489b3ec-6774-4a13-bc24-31b77deb6ae7	c2096d7c-a212-4365-9d85-3151167e0436	PAULÍNIA	SP	https://lqggoshphakeuufibdno.supabase.co/storage/v1/object/public/funcionarios/fotos/1781699420135.jpg	2026-06-17 12:30:21.274518	2026-06-17 12:30:21.274518	f	\N	\N	\N	2025-08-25	\N	\N	\N	30	t	\N	\N
4785ec97-ef57-4960-a515-ca79b0a31cee	075627	WESLEY BESSA DE OLIVEIRA	\N	\N	\N	\N	\N	2025-09-02	ativo	efetivo	\N	4489b3ec-6774-4a13-bc24-31b77deb6ae7	c2096d7c-a212-4365-9d85-3151167e0436	PAULÍNIA	SP	https://lqggoshphakeuufibdno.supabase.co/storage/v1/object/public/funcionarios/fotos/1781699864209.jpg	2026-06-17 12:37:44.804814	2026-06-17 12:37:44.804814	f	\N	\N	\N	2025-09-10	\N	1/2 OFICIAL SOLDADOR	\N	30	t	\N	\N
18e1524c-4a41-43d2-a70e-aaaa81c6d634	075651	KAUA RODRIGUES CARDOSO	\N	\N	\N	\N	\N	2025-09-15	ativo	efetivo	338d331e-ef03-4d94-9369-567ee922f1e9	4489b3ec-6774-4a13-bc24-31b77deb6ae7	c2096d7c-a212-4365-9d85-3151167e0436	PAULÍNIA	SP	https://lqggoshphakeuufibdno.supabase.co/storage/v1/object/public/funcionarios/fotos/1781698553281.jpeg	2026-06-17 12:15:54.344354	2026-06-17 12:15:54.344354	f	\N	\N	\N	2025-09-17	\N	\N	\N	30	t	\N	\N
aa46cb9c-89c3-4c1d-91de-3c58ad9efed2	075650	MIKAEL DE LIMA BRITO	\N	\N	\N	\N	\N	2025-09-15	ativo	efetivo	338d331e-ef03-4d94-9369-567ee922f1e9	4489b3ec-6774-4a13-bc24-31b77deb6ae7	c2096d7c-a212-4365-9d85-3151167e0436	PAULÍNIA	SP	https://lqggoshphakeuufibdno.supabase.co/storage/v1/object/public/funcionarios/fotos/1781698886569.jpg	2026-06-17 12:21:27.247876	2026-06-17 12:21:27.247876	f	\N	\N	\N	2025-09-17	\N	\N	\N	30	t	\N	\N
df4b5ed2-9c12-4911-b3ff-9ec504be50fa	75699	LUIS FERNANDO DIAS LOUZEIRO	\N	\N	\N	\N	\N	2025-11-05	ativo	nova_admissao	6bd0e213-c32c-463f-9186-af82541d0781	145e0a9b-f796-4db5-92e9-33f046f959ae	0ea37ce8-5f9d-4270-ac46-73e6c169c6d2	\N	\N	\N	2026-06-19 12:44:30.400557	2026-06-19 12:44:30.400557	f	\N	\N	\N	2026-01-26	\N	\N	\N	30	f	\N	\N
db4f7478-c942-49f4-a173-2a635aa782ae	075889	FRANCISCO WELLINGTON SILVA LEITE	\N	\N	\N	\N	\N	2026-06-01	ativo	nova_admissao	338d331e-ef03-4d94-9369-567ee922f1e9	4489b3ec-6774-4a13-bc24-31b77deb6ae7	0d899f11-785d-4edd-a951-bac82fae074f	JAGUARUANA	CE	https://lqggoshphakeuufibdno.supabase.co/storage/v1/object/public/funcionarios/fotos/1781717157467.png	2026-06-03 12:56:19.930749	2026-06-03 12:56:19.930749	f	\N	\N	\N	\N	\N	\N	\N	45	f	\N	\N
13b60718-123b-4059-b99f-c9c2d6cea63a	075809	JONAS DE OLIVEIRA	\N	\N	\N	\N	\N	2026-04-23	ativo	nova_admissao	b19eb87e-ab83-4460-b57f-f0302aaa1f0d	4489b3ec-6774-4a13-bc24-31b77deb6ae7	0d899f11-785d-4edd-a951-bac82fae074f	PILAR	AL	https://lqggoshphakeuufibdno.supabase.co/storage/v1/object/public/funcionarios/fotos/1781717384863.png	2026-06-02 11:59:33.324033	2026-06-02 11:59:33.324033	f	\N	\N	\N	\N	\N	\N	\N	45	f	\N	\N
1e97ede4-5066-4ac3-b4b3-09ae236f5caa	075841	MARCELO SILVA	\N	\N	\N	\N	\N	2026-05-05	ativo	nova_admissao	02a9da83-895c-4439-adff-aa33c7465e2f	4489b3ec-6774-4a13-bc24-31b77deb6ae7	0d899f11-785d-4edd-a951-bac82fae074f	PIRAI	RJ	https://lqggoshphakeuufibdno.supabase.co/storage/v1/object/public/funcionarios/fotos/1781717627830.png	2026-06-03 14:29:36.246529	2026-06-03 14:29:36.246529	f	\N	\N	\N	2026-05-27	\N	\N	\N	45	f	\N	e42bb35b-e6c4-4db2-8c2b-4c2e8f69a2e3
e13fd5d3-8493-4b58-bb54-269993f6fba0	075837	GERSONIEL SOUSA RODRIGUES	\N	\N	\N	\N	\N	2026-05-04	ativo	nova_admissao	abbe59ac-4003-4208-8495-c87d8d73fb14	4489b3ec-6774-4a13-bc24-31b77deb6ae7	0d899f11-785d-4edd-a951-bac82fae074f	BOQUEIRAO DO PIAUI	PI	https://lqggoshphakeuufibdno.supabase.co/storage/v1/object/public/funcionarios/fotos/1781717260352.png	2026-06-02 11:57:10.90763	2026-06-02 11:57:10.90763	f	\N	\N	\N	\N	\N	\N	\N	45	f	\N	e42bb35b-e6c4-4db2-8c2b-4c2e8f69a2e3
1a7f8265-24e3-4ead-bcd0-747192c5cd30	075833	UBIRAJARA MENDONCA DOS SANTOS	\N	\N	\N	\N	\N	2026-04-28	ativo	nova_admissao	02a9da83-895c-4439-adff-aa33c7465e2f	4489b3ec-6774-4a13-bc24-31b77deb6ae7	0d899f11-785d-4edd-a951-bac82fae074f	ESCADA	PE	https://lqggoshphakeuufibdno.supabase.co/storage/v1/object/public/funcionarios/fotos/1781717973720.png	2026-06-02 12:01:35.03519	2026-06-02 12:01:35.03519	f	\N	\N	\N	\N	\N	\N	\N	45	f	\N	\N
ceb4dc7d-3dd1-46d6-a566-14a381a4c7e6	075887	NIVALDO MANUEL DOS SANTOS	\N	\N	\N	\N	\N	2026-05-28	ativo	nova_admissao	55c090af-e003-4b88-b130-6cd81c801d33	4489b3ec-6774-4a13-bc24-31b77deb6ae7	0d899f11-785d-4edd-a951-bac82fae074f	ARARAQUARA	SP	https://lqggoshphakeuufibdno.supabase.co/storage/v1/object/public/funcionarios/fotos/1781717789495.png	2026-06-03 14:41:58.991168	2026-06-03 14:41:58.991168	f	\N	\N	\N	\N	\N	\N	\N	45	f	\N	\N
1543bea5-f3b5-4289-8136-24338f4042be	075868	MARCUS VINICIUS SILVA DE OLIVEIRA	\N	\N	\N	\N	\N	2026-05-18	ativo	nova_admissao	02a9da83-895c-4439-adff-aa33c7465e2f	4489b3ec-6774-4a13-bc24-31b77deb6ae7	0d899f11-785d-4edd-a951-bac82fae074f	CACHOEIRA	BA	https://lqggoshphakeuufibdno.supabase.co/storage/v1/object/public/funcionarios/fotos/1781717685750.jpeg	2026-06-03 14:31:49.46955	2026-06-03 14:31:49.46955	f	\N	\N	\N	\N	\N	\N	\N	45	f	\N	\N
beff7969-13aa-4ad0-acb3-b178bee25629	075815	RONALDO BARBOSA DE OLIVEIRA	\N	\N	\N	\N	\N	2026-04-23	ativo	nova_admissao	f510f6aa-f1d8-4fd9-b85f-dd8ff840cf76	4489b3ec-6774-4a13-bc24-31b77deb6ae7	0d899f11-785d-4edd-a951-bac82fae074f	LINHARES	ES	https://lqggoshphakeuufibdno.supabase.co/storage/v1/object/public/funcionarios/fotos/1781717889359.jpeg	2026-06-02 12:00:30.485356	2026-06-02 12:00:30.485356	f	\N	\N	\N	\N	\N	\N	\N	45	f	\N	7e18e7ce-a57d-4369-88de-8097c3286957
75eacd3d-5c0f-432a-839f-803d5eca0d12	075854	JORGE HUGO BARBOSA DUARTE	\N	\N	\N	\N	\N	2026-05-08	ativo	nova_admissao	cde079dd-2d53-44c2-9054-6245d154bcf6	4489b3ec-6774-4a13-bc24-31b77deb6ae7	0d899f11-785d-4edd-a951-bac82fae074f	ICO	CE	https://lqggoshphakeuufibdno.supabase.co/storage/v1/object/public/funcionarios/fotos/1781717411466.png	2026-06-03 12:56:19.930749	2026-06-03 12:56:19.930749	f	\N	\N	\N	\N	\N	\N	\N	45	f	\N	e42bb35b-e6c4-4db2-8c2b-4c2e8f69a2e3
89b01666-1988-48ec-a651-f3e492c26d3b	075088	ANTONIO EDNILSON SERAFIM DE OLIVEIRA	\N	\N	\N	\N	\N	2025-02-19	ativo	nova_admissao	02a9da83-895c-4439-adff-aa33c7465e2f	4489b3ec-6774-4a13-bc24-31b77deb6ae7	0d899f11-785d-4edd-a951-bac82fae074f	RUSSAS	CE	https://lqggoshphakeuufibdno.supabase.co/storage/v1/object/public/funcionarios/fotos/1781716768819.png	2026-06-03 12:56:19.930749	2026-06-03 12:56:19.930749	f	\N	\N	\N	\N	\N	\N	\N	30	t	\N	\N
2c36e097-d770-418a-b702-b9de29ca3c62	075879	WENDEL KAIC FREITAS LOPES	\N	\N	\N	\N	\N	2026-05-25	ativo	nova_admissao	338d331e-ef03-4d94-9369-567ee922f1e9	4489b3ec-6774-4a13-bc24-31b77deb6ae7	0d899f11-785d-4edd-a951-bac82fae074f	JAGUARUANA	SP	https://lqggoshphakeuufibdno.supabase.co/storage/v1/object/public/funcionarios/fotos/1781718068071.png	2026-06-03 15:00:29.82925	2026-06-03 15:00:29.82925	f	\N	\N	\N	\N	\N	\N	\N	45	f	\N	\N
5049a328-1980-4416-9c2e-77f649cc5b60	74847	DANIEL FEITOSA DOS SANTOS	\N	\N	\N	\N	\N	2025-01-15	ativo	efetivo	b19eb87e-ab83-4460-b57f-f0302aaa1f0d	145e0a9b-f796-4db5-92e9-33f046f959ae	0ea37ce8-5f9d-4270-ac46-73e6c169c6d2	Teotonio Vilela	AL	https://lqggoshphakeuufibdno.supabase.co/storage/v1/object/public/funcionarios/fotos/1781865933848.png	2026-06-19 10:45:35.834239	2026-06-19 10:45:35.834239	f	\N	\N	\N	2026-03-05	\N	\N	\N	30	f	\N	\N
92ce3dcb-4f7d-4cbb-99e4-4349405e77ea	075800	CARLOS HENRIQUE AUGUSTO ARAUJO	\N	\N	\N	\N	\N	2026-04-15	ativo	nova_admissao	b19eb87e-ab83-4460-b57f-f0302aaa1f0d	4489b3ec-6774-4a13-bc24-31b77deb6ae7	0d899f11-785d-4edd-a951-bac82fae074f	BONITO DE SANTA FE	PB	https://lqggoshphakeuufibdno.supabase.co/storage/v1/object/public/funcionarios/fotos/1781716888194.png	2026-06-02 11:56:26.625017	2026-06-02 11:56:26.625017	f	\N	\N	\N	\N	\N	\N	\N	45	f	\N	c8e6e203-9c03-42cb-9a30-63fca14dc225
19d7cb2c-e21c-4863-aa70-f426d028d88c	075787	DEJAILTON JESUS DOS SANTOS	\N	\N	\N	\N	\N	2026-04-09	ativo	nova_admissao	c5ddb144-5847-4aec-b64b-cb346f96cfad	4489b3ec-6774-4a13-bc24-31b77deb6ae7	0d899f11-785d-4edd-a951-bac82fae074f	NAZARE	BA	https://lqggoshphakeuufibdno.supabase.co/storage/v1/object/public/funcionarios/fotos/1781716984239.jpeg	2026-06-02 11:56:26.625017	2026-06-02 11:56:26.625017	f	\N	\N	\N	\N	\N	\N	\N	45	f	\N	c8e6e203-9c03-42cb-9a30-63fca14dc225
722f93bf-64cd-44c7-87eb-6fe9b05ae777	075799	WILLIAM SIDNEY SANTOS	\N	\N	\N	\N	\N	2026-04-15	ativo	nova_admissao	914d6d69-7338-4197-be53-ac04a5216eba	4489b3ec-6774-4a13-bc24-31b77deb6ae7	0d899f11-785d-4edd-a951-bac82fae074f	MATA DE SAO JOAO	BA	https://lqggoshphakeuufibdno.supabase.co/storage/v1/object/public/funcionarios/fotos/1781718098599.png	2026-06-02 12:01:35.03519	2026-06-02 12:01:35.03519	f	\N	\N	\N	\N	\N	\N	\N	45	f	\N	c8e6e203-9c03-42cb-9a30-63fca14dc225
917fec59-ab61-45db-8f81-9beab2195f1b	075821	MARCILIO NUNES DE SOUSA	\N	\N	\N	\N	\N	2026-04-24	ativo	nova_admissao	c5ddb144-5847-4aec-b64b-cb346f96cfad	4489b3ec-6774-4a13-bc24-31b77deb6ae7	0d899f11-785d-4edd-a951-bac82fae074f	ICO	CE	https://lqggoshphakeuufibdno.supabase.co/storage/v1/object/public/funcionarios/fotos/1781717648784.png	2026-06-02 11:59:33.324033	2026-06-02 11:59:33.324033	f	\N	\N	\N	\N	\N	\N	\N	45	f	\N	7e18e7ce-a57d-4369-88de-8097c3286957
a9cf53c8-6a86-4609-930d-98032c3abcbb	70969	EDSON JOSE NOGUEIRA	\N	\N	\N	\N	\N	2020-03-18	ativo	efetivo	2225eb09-8b7d-4f3f-85a0-55a5e20d0c15	4489b3ec-6774-4a13-bc24-31b77deb6ae7	0ea37ce8-5f9d-4270-ac46-73e6c169c6d2	Pirassununga	SP	https://lqggoshphakeuufibdno.supabase.co/storage/v1/object/public/funcionarios/fotos/1781866805632.jpg	2026-06-19 10:59:30.458662	2026-06-19 10:59:30.458662	f	\N	\N	\N	2025-12-15	\N	\N	\N	30	f	\N	\N
1295cbeb-8ac0-4b58-8614-589dd7ff655b	75839	ERIKA SANTOS DE LIMA	\N	\N	\N	\N	\N	2026-05-04	ativo	efetivo	\N	4489b3ec-6774-4a13-bc24-31b77deb6ae7	0ea37ce8-5f9d-4270-ac46-73e6c169c6d2	SUMARÉ	SP	https://lqggoshphakeuufibdno.supabase.co/storage/v1/object/public/funcionarios/fotos/1781867316721.jpeg	2026-06-19 11:08:39.361687	2026-06-19 11:08:39.361687	f	\N	\N	\N	2026-05-04	\N	AUXILIAR DE PLANEJAMENTO	\N	30	f	\N	\N
51ffaf0c-00fe-4d5d-821a-40c34a8203d8	73332	BRUNO DA CRUZ RODRIGUES	\N	\N	\N	\N	\N	2023-12-01	ativo	efetivo	b19eb87e-ab83-4460-b57f-f0302aaa1f0d	4489b3ec-6774-4a13-bc24-31b77deb6ae7	0ea37ce8-5f9d-4270-ac46-73e6c169c6d2	Marilia	SP	https://lqggoshphakeuufibdno.supabase.co/storage/v1/object/public/funcionarios/fotos/1781789122259.png	2026-06-18 13:25:24.564795	2026-06-18 13:25:24.564795	f	\N	\N	\N	2025-12-13	\N	\N	\N	30	t	ALOJADO	1a02849c-86c8-40b7-920d-7f20937d758b
519005c1-dfd6-4952-be33-a68aa37640a6	60868	FABIO DE SOUZA	\N	\N	\N	\N	\N	2018-03-14	ativo	efetivo	\N	4489b3ec-6774-4a13-bc24-31b77deb6ae7	0ea37ce8-5f9d-4270-ac46-73e6c169c6d2	SAO JOSÉ DOS CAMPOS	SP	\N	2026-06-19 11:17:14.858409	2026-06-19 11:17:14.858409	f	\N	\N	\N	2026-01-01	\N	SUPERVISOR DE PLANEJAMENTO	\N	30	f	\N	\N
ad24de67-0d79-4f4f-b164-0d4262e29bae	75763	GUSTAVO XAVIER BARBOSA	\N	\N	\N	\N	\N	2026-02-24	ativo	efetivo	338d331e-ef03-4d94-9369-567ee922f1e9	145e0a9b-f796-4db5-92e9-33f046f959ae	0ea37ce8-5f9d-4270-ac46-73e6c169c6d2	COSMOPOLIS	SP	https://lqggoshphakeuufibdno.supabase.co/storage/v1/object/public/funcionarios/fotos/1781868139690.jpg	2026-06-19 11:22:21.490816	2026-06-19 11:22:21.490816	f	\N	\N	\N	2026-03-02	\N	\N	\N	30	f	\N	\N
5db6a8eb-d6da-4faa-8d00-079ae58901d2	70083	JAIRO BISPO	\N	\N	\N	\N	\N	2018-07-19	ativo	efetivo	02a9da83-895c-4439-adff-aa33c7465e2f	4489b3ec-6774-4a13-bc24-31b77deb6ae7	0ea37ce8-5f9d-4270-ac46-73e6c169c6d2	SÃO PAULO	SP	https://lqggoshphakeuufibdno.supabase.co/storage/v1/object/public/funcionarios/fotos/1781868378528.jpeg	2026-06-19 11:26:20.926611	2026-06-19 11:26:20.926611	f	\N	\N	\N	2025-12-15	\N	\N	\N	30	f	\N	\N
549476d4-87b2-492a-8749-f1be57fb9fd2	75776	JERRY DA CONCEIÇÃO SALES	\N	\N	\N	\N	\N	2026-03-18	ativo	efetivo	b19eb87e-ab83-4460-b57f-f0302aaa1f0d	145e0a9b-f796-4db5-92e9-33f046f959ae	0ea37ce8-5f9d-4270-ac46-73e6c169c6d2	BARRAS	PI	https://lqggoshphakeuufibdno.supabase.co/storage/v1/object/public/funcionarios/fotos/1781869676239.jpg	2026-06-19 11:47:59.54979	2026-06-19 11:47:59.54979	f	\N	\N	\N	2026-03-23	\N	\N	\N	30	f	\N	\N
094b876c-ba2c-4518-b30a-28dc1462c38e	75186	ALVARO SALDANHA LIMA	\N	\N	\N	\N	\N	2025-03-07	ativo	nova_admissao	\N	4489b3ec-6774-4a13-bc24-31b77deb6ae7	0ea37ce8-5f9d-4270-ac46-73e6c169c6d2	SALVADOR	BA	https://lqggoshphakeuufibdno.supabase.co/storage/v1/object/public/funcionarios/fotos/1781527371578.png	2026-06-15 12:42:53.374996	2026-06-15 12:42:53.374996	f	\N	\N	\N	2026-01-06	\N	MECÂNICO MONTADOR	\N	30	t	ALOJADO	\N
8c845812-a24a-4aeb-9ab6-3669da5b915b	75845	JOÃO CARLOS ALVES DA SILVA	\N	\N	\N	\N	\N	2026-05-06	ativo	efetivo	b19eb87e-ab83-4460-b57f-f0302aaa1f0d	4489b3ec-6774-4a13-bc24-31b77deb6ae7	0ea37ce8-5f9d-4270-ac46-73e6c169c6d2	CAMPINAS	SP	https://lqggoshphakeuufibdno.supabase.co/storage/v1/object/public/funcionarios/fotos/1781871038242.png	2026-06-19 12:10:40.159091	2026-06-19 12:10:40.159091	f	\N	\N	\N	2026-05-06	\N	\N	\N	30	f	\N	\N
fd74e6c6-7cf2-4930-bebd-cf003fd4ea60	616	JOÃO TAVARES SENA	\N	\N	\N	\N	\N	1992-07-01	ativo	efetivo	0f58f874-6d22-4add-99cc-d7139c8bdbba	4489b3ec-6774-4a13-bc24-31b77deb6ae7	0ea37ce8-5f9d-4270-ac46-73e6c169c6d2	SÃO JOSÉ DOS CAMPOS	SP	https://lqggoshphakeuufibdno.supabase.co/storage/v1/object/public/funcionarios/fotos/1781871418674.jpg	2026-06-19 12:17:00.196502	2026-06-19 12:17:00.196502	f	\N	\N	\N	2026-03-09	\N	\N	\N	30	f	\N	\N
2c4cfbee-7f04-419a-a859-eb65149911d8	70156	JOSE CARLOS PEREIRA DOS SANTOS	\N	\N	\N	\N	\N	2018-09-11	ativo	efetivo	c5ddb144-5847-4aec-b64b-cb346f96cfad	4489b3ec-6774-4a13-bc24-31b77deb6ae7	0ea37ce8-5f9d-4270-ac46-73e6c169c6d2	MADRE DE DEUS	BA	https://lqggoshphakeuufibdno.supabase.co/storage/v1/object/public/funcionarios/fotos/1781871655434.png	2026-06-19 12:20:56.739425	2026-06-19 12:20:56.739425	f	\N	\N	\N	2026-01-06	\N	\N	\N	30	f	\N	\N
ca917fd7-41c6-4ea9-bb78-03f7c891d340	74846	JOSE EDUARDO DA SILVA SIQUEIRA	\N	\N	\N	\N	\N	2025-01-15	ativo	efetivo	c5ddb144-5847-4aec-b64b-cb346f96cfad	4489b3ec-6774-4a13-bc24-31b77deb6ae7	0ea37ce8-5f9d-4270-ac46-73e6c169c6d2	\N	\N	https://lqggoshphakeuufibdno.supabase.co/storage/v1/object/public/funcionarios/fotos/1781871803561.png	2026-06-19 12:23:24.923264	2026-06-19 12:23:24.923264	f	\N	\N	\N	2026-02-04	\N	\N	\N	30	f	\N	\N
bd7de2ed-7677-412b-94a5-3cf2d9667b31	75877	JOSUE JOSE DE OLIVEIRA	\N	\N	\N	\N	\N	2026-05-25	ativo	efetivo	c5ddb144-5847-4aec-b64b-cb346f96cfad	4489b3ec-6774-4a13-bc24-31b77deb6ae7	0ea37ce8-5f9d-4270-ac46-73e6c169c6d2	AMERICANA	SP	https://lqggoshphakeuufibdno.supabase.co/storage/v1/object/public/funcionarios/fotos/1781872358722.jpeg	2026-06-19 12:32:40.610813	2026-06-19 12:32:40.610813	f	\N	\N	\N	2026-05-27	\N	\N	\N	30	f	\N	\N
146f363f-134a-46bf-91fe-dd87e52c8f88	73240	LUCAS COSTA DA SILVA	\N	\N	\N	\N	\N	2023-11-01	ativo	efetivo	c5ddb144-5847-4aec-b64b-cb346f96cfad	4489b3ec-6774-4a13-bc24-31b77deb6ae7	0ea37ce8-5f9d-4270-ac46-73e6c169c6d2	CAMPINAS	SP	https://lqggoshphakeuufibdno.supabase.co/storage/v1/object/public/funcionarios/fotos/1781872847197.jpg	2026-06-19 12:40:48.890595	2026-06-19 12:40:48.890595	f	\N	\N	\N	2026-06-09	\N	\N	\N	30	f	\N	\N
2d45ed01-cb9f-49aa-b781-a69ed90fe642	75878	LUIS HENRIQUE RIBEIRO	\N	\N	\N	\N	\N	2026-05-25	ativo	efetivo	b19eb87e-ab83-4460-b57f-f0302aaa1f0d	4489b3ec-6774-4a13-bc24-31b77deb6ae7	0ea37ce8-5f9d-4270-ac46-73e6c169c6d2	COSMOPOLIS	SP	https://lqggoshphakeuufibdno.supabase.co/storage/v1/object/public/funcionarios/fotos/1781873305606.png	2026-06-19 12:48:27.846447	2026-06-19 12:48:27.846447	f	\N	\N	\N	2026-05-27	\N	\N	\N	30	f	\N	\N
23f30241-e663-4fa8-b9ca-6a02f57cc7ac	75793	LUIZ CARLOS FLORENCIO DOS SANTOS	\N	\N	\N	\N	\N	2026-04-14	ativo	nova_admissao	\N	145e0a9b-f796-4db5-92e9-33f046f959ae	0ea37ce8-5f9d-4270-ac46-73e6c169c6d2	\N	\N	https://lqggoshphakeuufibdno.supabase.co/storage/v1/object/public/funcionarios/fotos/1781873984406.png	2026-06-19 12:59:46.357094	2026-06-19 12:59:46.357094	f	\N	\N	\N	2026-04-16	\N	SOLDADOR	\N	30	f	\N	\N
f0342518-bd63-4b33-8caf-5fd0609fe44a	74445	MARCOS NUNES DE SOUZA	\N	\N	\N	\N	\N	2024-10-08	ativo	efetivo	\N	145e0a9b-f796-4db5-92e9-33f046f959ae	0ea37ce8-5f9d-4270-ac46-73e6c169c6d2	GOIANA	GO	https://lqggoshphakeuufibdno.supabase.co/storage/v1/object/public/funcionarios/fotos/1781874090797.png	2026-06-19 13:01:08.351453	2026-06-19 13:01:08.351453	f	\N	\N	\N	2026-01-07	\N	SOLDADOR	\N	30	f	\N	\N
6923c92f-fed0-4de4-a0d1-ec7390e85e78	72216	MARCOS SALLES FERREIRA	\N	\N	\N	\N	\N	2023-01-23	ativo	efetivo	c5ddb144-5847-4aec-b64b-cb346f96cfad	4489b3ec-6774-4a13-bc24-31b77deb6ae7	0ea37ce8-5f9d-4270-ac46-73e6c169c6d2	\N	\N	https://lqggoshphakeuufibdno.supabase.co/storage/v1/object/public/funcionarios/fotos/1781875052389.jpg	2026-06-19 13:17:34.23205	2026-06-19 13:17:34.23205	f	\N	\N	\N	2026-02-20	\N	\N	\N	30	f	\N	\N
75d0a357-4313-4646-8ad4-a91705d2f2cf	74854	OZIEL ANDERSON DOS SANTOS	\N	\N	\N	\N	\N	2025-01-21	ativo	efetivo	02a9da83-895c-4439-adff-aa33c7465e2f	145e0a9b-f796-4db5-92e9-33f046f959ae	0ea37ce8-5f9d-4270-ac46-73e6c169c6d2	LIMEIRA	SP	https://lqggoshphakeuufibdno.supabase.co/storage/v1/object/public/funcionarios/fotos/1781875179601.jpg	2026-06-19 13:19:40.680273	2026-06-19 13:19:40.680273	f	\N	\N	\N	2025-12-22	\N	\N	\N	30	f	\N	\N
7f3d6039-9c37-4d94-8875-0cc29bf3f232	75701	VITOR PAULINO ALVES DA SILVA	\N	\N	\N	\N	\N	2025-11-06	ativo	efetivo	338d331e-ef03-4d94-9369-567ee922f1e9	145e0a9b-f796-4db5-92e9-33f046f959ae	0ea37ce8-5f9d-4270-ac46-73e6c169c6d2	\N	\N	\N	2026-06-19 14:12:57.633042	2026-06-19 14:12:57.633042	f	\N	\N	\N	2026-06-09	\N	\N	\N	30	f	\N	\N
7d775bd7-515c-4a33-b524-03c09c467b23	74857	PAULO RODRIGO PEREIRA PACHECO	\N	\N	\N	\N	\N	2025-01-22	ativo	efetivo	c5ddb144-5847-4aec-b64b-cb346f96cfad	4489b3ec-6774-4a13-bc24-31b77deb6ae7	0ea37ce8-5f9d-4270-ac46-73e6c169c6d2	PAULO AFONSO	BA	https://lqggoshphakeuufibdno.supabase.co/storage/v1/object/public/funcionarios/fotos/1781875382426.png	2026-06-19 13:23:03.816271	2026-06-19 13:23:03.816271	f	\N	\N	\N	2026-01-06	\N	\N	\N	30	f	\N	\N
c78775ac-815b-4fae-8534-cb72b04eb579	75788	RAIMUNDO DIAS	\N	\N	\N	\N	\N	2026-04-16	ativo	efetivo	\N	4489b3ec-6774-4a13-bc24-31b77deb6ae7	0ea37ce8-5f9d-4270-ac46-73e6c169c6d2	COSMOPOLIS	SP	https://lqggoshphakeuufibdno.supabase.co/storage/v1/object/public/funcionarios/fotos/1781875750749.png	2026-06-19 13:29:12.745931	2026-06-19 13:29:12.745931	f	\N	\N	\N	2026-04-14	\N	SOLDADOR	\N	30	f	\N	\N
15dca725-12b8-4198-8816-223ffa666037	73489	THIAGO RODRIGUES DE BRITO	\N	\N	\N	\N	\N	2025-02-25	ativo	efetivo	b19eb87e-ab83-4460-b57f-f0302aaa1f0d	4489b3ec-6774-4a13-bc24-31b77deb6ae7	0ea37ce8-5f9d-4270-ac46-73e6c169c6d2	SAO MATHEUS	MA	https://lqggoshphakeuufibdno.supabase.co/storage/v1/object/public/funcionarios/fotos/1781875919497.jpg	2026-06-19 13:32:01.350606	2026-06-19 13:32:01.350606	f	\N	\N	\N	2025-12-15	\N	\N	\N	30	f	\N	\N
022e764f-d223-4747-9960-83f18373028f	75740	UEDINER ALCIDES MARTINS	\N	\N	\N	\N	\N	2026-01-05	ativo	efetivo	\N	145e0a9b-f796-4db5-92e9-33f046f959ae	0ea37ce8-5f9d-4270-ac46-73e6c169c6d2	PAULÍNIA	SP	https://lqggoshphakeuufibdno.supabase.co/storage/v1/object/public/funcionarios/fotos/1781876030405.jpg	2026-06-19 13:33:51.152436	2026-06-19 13:33:51.152436	f	\N	\N	\N	2026-01-07	\N	TECNICO DE SEGURANÇA	\N	30	f	\N	\N
82947628-c1c4-45e2-bf35-963cd4ec4d12	73244	VINICIUS ASTORINO BIZELLI	\N	\N	\N	\N	\N	2023-11-01	ativo	nova_admissao	\N	17e8550c-d196-4b45-8931-5ae1c4042e17	0ea37ce8-5f9d-4270-ac46-73e6c169c6d2	ARARAQUARA	SP	https://lqggoshphakeuufibdno.supabase.co/storage/v1/object/public/funcionarios/fotos/1781876192057.png	2026-06-19 13:36:33.377129	2026-06-19 13:36:33.377129	f	\N	\N	\N	2026-01-05	\N	ANALISTA DE PLANEJAMENTO II	\N	30	f	\N	\N
\.


--
-- Data for Name: funcoes; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.funcoes (id, nome, created_at) FROM stdin;
f5c1578b-6c06-4b0c-a7f6-165779ef8751	1/2 OFICIAL MECANICO MONTADOR	2026-05-28 11:43:20.609125
5e28b195-df76-4ad6-a5b9-572524050dc3	ALMOXARIFE	2026-05-28 11:43:20.609125
4191f3e1-8f91-4597-9b6d-457529bec51a	ASSISTENTE ADMINISTRATIVO	2026-05-28 11:43:20.609125
d9c68ebe-f33f-4431-ac56-a846b9b19b08	COORDENADOR ADM	2026-05-28 11:43:20.609125
be64e377-6fe4-4fc3-a897-b7cfe18a0ba8	ELETRICISTA FORCA E CONTROLE	2026-05-28 11:43:20.609125
fb4ee1c9-e474-462a-8978-e9d53c83bc09	ELETRICISTA MONTADOR	2026-05-28 11:43:20.609125
5008202f-4b1f-4f3f-9629-ff6978a8555a	ENCANADOR	2026-05-28 11:43:20.609125
19f1474f-d028-466c-869a-0bb784f62554	ENCANADOR INDUSTRIAL	2026-05-28 11:43:20.609125
577b7369-a750-4465-87f4-ada70bb20c13	ENCARREGADO ADMINISTRATIVO	2026-05-28 11:43:20.609125
75229003-b822-4bde-bc69-fd4349897ea5	ENGENHEIRO MECANICO	2026-05-28 11:43:20.609125
57bfb287-620a-4dc2-8c49-76d5582bf73c	GERENTE DE CONTRATO	2026-05-28 11:43:20.609125
05859ce0-5ae0-452f-ae44-898b6f7c002c	INSPETOR DE SOLDA	2026-05-28 11:43:20.609125
46ffedcb-07ed-4dcd-8f59-429f434fdb81	MECANICO MONTADOR	2026-05-28 11:43:20.609125
3ced5c78-530a-4168-8d96-142d066c2169	MOTORISTA E OPERADOR DE MUNCK	2026-05-28 11:43:20.609125
7ccbe19e-d491-46d3-a17e-e0227d6355fc	SERRALHEIRO	2026-05-28 11:43:20.609125
40a47611-d820-41f4-830a-3627a0a4a52c	SOLDADOR TIG - ACO INOX	2026-05-28 11:43:20.609125
c8ac1967-55f8-4d50-b3a1-273773aef72e	SOLDADOR TIG - INOX OD	2026-05-28 11:43:20.609125
dee60c7c-2c17-413c-a1e7-d49c12e7e8e2	SUPERVISOR DE ELETRICA	2026-05-28 11:43:20.609125
ab979acd-d194-4920-801d-82f3707d67fd	SUPERVISOR DE MECANICA	2026-05-28 11:43:20.609125
02c2880b-dc80-4053-9169-bdc211cf71a9	TECNICO DE QUALIDADE	2026-05-28 11:43:20.609125
2aa35742-5a21-4e8c-be75-f9dbd6254ec9	TST	2026-05-28 11:43:20.609125
ea0e0abb-9679-41a1-8293-33e3adcb6fa9	ENCARREGADO DE MECANICA	2026-05-28 11:43:20.609125
abbe59ac-4003-4208-8495-c87d8d73fb14	SOLDADOR TIG I	2026-05-28 11:43:20.609125
647f0ad3-caa5-4e06-a986-15a64019a373	OFICIAL ELETRICISTA	2026-05-28 11:43:20.609125
d4e79e4f-2539-45db-b99e-5d17c8f7a3e8	AUXILIAR DE SERVICOS GERAIS	2026-05-28 11:43:20.609125
2715e2bd-f45c-448b-8900-b1374680b947	TECNICO DE PLANEJAMENTO	2026-05-28 11:43:20.609125
a1ef8a21-eec8-404f-aa1e-5dd7b888eb33	ENCARREGADO DE ELETRICA	2026-05-28 11:43:20.609125
cddad82d-5983-4f41-a97a-891318ca715e	1/2 OFICIAL ELETRICISTA	2026-05-28 11:43:20.609125
32b24cfd-b79a-4b2b-a72d-5cf2a131205c	AJUDANTE	2026-05-28 11:43:20.609125
7fa259a6-0c58-47a2-bf92-a4287b509fc6	1/2 OFICIAL MECANICO MONTADOR	2026-05-28 11:45:50.73803
bbac2f86-255e-42d7-a2a4-0811769b3c8c	ALMOXARIFE	2026-05-28 11:45:50.73803
b642dcac-d9be-4101-a76e-fe46366b8013	ASSISTENTE ADMINISTRATIVO	2026-05-28 11:45:50.73803
29e889c8-e176-4f69-81dc-e6884d471206	COORDENADOR ADM	2026-05-28 11:45:50.73803
55121cef-77d0-4fee-af4d-f8ae16501018	ELETRICISTA FORCA E CONTROLE	2026-05-28 11:45:50.73803
b19eb87e-ab83-4460-b57f-f0302aaa1f0d	ELETRICISTA MONTADOR	2026-05-28 11:45:50.73803
0ab5cb66-4350-49a2-b5b6-acbbb4a0f0f3	ENCANADOR	2026-05-28 11:45:50.73803
eaa9beb9-6d37-478a-b7c9-88a56f6038f1	ENCANADOR INDUSTRIAL	2026-05-28 11:45:50.73803
51c831c0-3baa-498c-b48d-c415fe6cfa0b	ENCARREGADO ADMINISTRATIVO	2026-05-28 11:45:50.73803
cee372ae-3449-447a-afb0-c173934105ea	ENGENHEIRO MECANICO	2026-05-28 11:45:50.73803
4cf755b3-77ca-4f4e-af3b-fc2d9e18db5d	GERENTE DE CONTRATO	2026-05-28 11:45:50.73803
be29092a-3421-4ccd-886d-3de0c9961285	INSPETOR DE SOLDA	2026-05-28 11:45:50.73803
922358a4-8a03-4721-a244-8351789cb394	MECANICO MONTADOR	2026-05-28 11:45:50.73803
87fb85da-78b4-44c8-9a55-5f55e3caea0e	MOTORISTA E OPERADOR DE MUNCK	2026-05-28 11:45:50.73803
c1ec9e8f-e4c1-471e-85a7-73e75b727bee	SERRALHEIRO	2026-05-28 11:45:50.73803
1b2a780a-bd20-41fa-a350-92dba3105eea	SOLDADOR TIG - ACO INOX	2026-05-28 11:45:50.73803
c9bc1c36-1a37-4dbc-9b37-41b340a9ecde	SOLDADOR TIG - INOX OD	2026-05-28 11:45:50.73803
a203b010-2a07-4aae-bc3b-59b76c346cce	SUPERVISOR DE ELETRICA	2026-05-28 11:45:50.73803
22b12922-f8ef-4743-b361-5859d229795f	SUPERVISOR DE MECANICA	2026-05-28 11:45:50.73803
dc630330-2307-45d4-adaa-b7cd564f46f1	TECNICO DE QUALIDADE	2026-05-28 11:45:50.73803
15a84938-61f7-411c-9fee-ecb5ffe2d85f	TST	2026-05-28 11:45:50.73803
2bc0213e-1f8a-4fc6-969b-30d5849263e6	ENCARREGADO DE MECANICA	2026-05-28 11:45:50.73803
03f010f5-423a-4375-8411-b9bc66dceef4	SOLDADOR TIG I	2026-05-28 11:45:50.73803
98e8593f-25c9-40ab-83e3-b5301feefd42	OFICIAL ELETRICISTA	2026-05-28 11:45:50.73803
643602ea-615f-4ff0-87e3-fa5b83c612a7	AUXILIAR DE SERVICOS GERAIS	2026-05-28 11:45:50.73803
6d670a8d-ed40-495b-9db2-18935fdd8aa9	TECNICO DE PLANEJAMENTO	2026-05-28 11:45:50.73803
cdcf8798-4da8-415c-a7ce-6abd71ea49c5	ENCARREGADO DE ELETRICA	2026-05-28 11:45:50.73803
fbbee392-731e-427a-aad5-7efac075598f	1/2 OFICIAL ELETRICISTA	2026-05-28 11:45:50.73803
1d78d652-4ebd-4e84-878d-7108aacd75df	AJUDANTE	2026-05-28 11:45:50.73803
37765da3-194b-4a91-8c52-aa526b2e4024	1/2 OFICIAL MECANICO MONTADOR	2026-05-28 12:13:28.113305
d2e9fa2f-640b-459b-9e37-e71acfe56586	ALMOXARIFE	2026-05-28 12:13:28.113305
da15f0b4-47fa-4f84-a113-fd625d51914e	ASSISTENTE ADMINISTRATIVO	2026-05-28 12:13:28.113305
3cd92930-db2e-48d6-9799-b5c97a931a38	COORDENADOR ADM	2026-05-28 12:13:28.113305
c3ec4f85-b108-4530-87e1-36d2258487fa	ELETRICISTA FORCA E CONTROLE	2026-05-28 12:13:28.113305
2b0e496b-cfa9-4528-b4e6-547fc0377fd1	ELETRICISTA MONTADOR	2026-05-28 12:13:28.113305
91c5437b-aab1-4c0e-965d-49358449d174	ENCANADOR	2026-05-28 12:13:28.113305
97ec053a-0278-4bc2-ad1b-9513f51de33d	ENCANADOR INDUSTRIAL	2026-05-28 12:13:28.113305
a6dd4f6b-051d-403d-b434-cc16fd43f926	ENCARREGADO ADMINISTRATIVO	2026-05-28 12:13:28.113305
4b4698a5-f45f-43a2-8116-da94591408aa	ENGENHEIRO MECANICO	2026-05-28 12:13:28.113305
9042602c-1b4e-4623-8c6b-7449a1e10c9b	GERENTE DE CONTRATO	2026-05-28 12:13:28.113305
bd89812c-786d-40a6-8b08-bc5c9392249e	INSPETOR DE SOLDA	2026-05-28 12:13:28.113305
dac7ff25-2fb8-40ba-ba88-b57d23e123e4	MECANICO MONTADOR	2026-05-28 12:13:28.113305
88ed527c-f65d-4c15-a86b-6b716d807685	MOTORISTA E OPERADOR DE MUNCK	2026-05-28 12:13:28.113305
0d6fdae5-adac-4354-8945-bfd2c12d6a26	SERRALHEIRO	2026-05-28 12:13:28.113305
5f64aead-bc20-4a45-b59a-d9e9c964ad27	SOLDADOR TIG - ACO INOX	2026-05-28 12:13:28.113305
425a8b68-3205-4c4a-b2e9-6d38d27f47a6	SOLDADOR TIG - INOX OD	2026-05-28 12:13:28.113305
70d3998a-d4dc-445e-9d02-031e540ed55f	SUPERVISOR DE ELETRICA	2026-05-28 12:13:28.113305
82ad4b82-9ce3-4675-ab70-1301fdf6308c	SUPERVISOR DE MECANICA	2026-05-28 12:13:28.113305
4fdbacbf-d491-475d-8079-d8a689a67e73	TECNICO DE QUALIDADE	2026-05-28 12:13:28.113305
636f0d00-ef62-4e88-9694-2e37387d8bca	TST	2026-05-28 12:13:28.113305
ccd9188f-8e59-4128-a2ba-64dbc2e08e71	ENCARREGADO DE MECANICA	2026-05-28 12:13:28.113305
34af479d-5822-45d7-9f96-551c94a72e33	SOLDADOR TIG I	2026-05-28 12:13:28.113305
02ae9167-d5e0-4d43-ac57-ce61f54dbd15	OFICIAL ELETRICISTA	2026-05-28 12:13:28.113305
dd1a458e-5a2a-40ed-8dc8-982a57e5e5d4	AUXILIAR DE SERVICOS GERAIS	2026-05-28 12:13:28.113305
c3635fe4-5c6a-45e7-a65c-8c2eadb083e5	TECNICO DE PLANEJAMENTO	2026-05-28 12:13:28.113305
9106443f-fb8a-4395-a415-b3b0d61e1d07	ENCARREGADO DE ELETRICA	2026-05-28 12:13:28.113305
9212be9e-54e8-4634-a6b0-529cac525b77	1/2 OFICIAL ELETRICISTA	2026-05-28 12:13:28.113305
38f7c632-3c9c-4303-961f-fac40fc46097	AJUDANTE	2026-05-28 12:13:28.113305
93e57956-24c8-4df1-b96e-5dc3bf68de7b	1/2 OFICIAL MECANICO MONTADOR	2026-05-28 14:49:38.079723
9dc30cb3-98b6-432d-8809-a0e0a7c67628	ALMOXARIFE	2026-05-28 14:49:38.079723
705d6923-cc91-4048-b604-b20deb19576b	ASSISTENTE ADMINISTRATIVO	2026-05-28 14:49:38.079723
9f722303-c0cf-43a9-b8cc-b12619863d5e	COORDENADOR ADM	2026-05-28 14:49:38.079723
6e6644ad-e235-49f5-aa9a-ac0507b7c587	ELETRICISTA FORCA E CONTROLE	2026-05-28 14:49:38.079723
0e1045a4-2cbd-4138-aaca-9bf0e1bd5258	ELETRICISTA MONTADOR	2026-05-28 14:49:38.079723
bad06f70-6e42-4d8a-bb54-7ed9623b9792	ENCANADOR	2026-05-28 14:49:38.079723
cc737a10-a1af-4cb5-9388-92dc0c6b3fc0	ENCANADOR INDUSTRIAL	2026-05-28 14:49:38.079723
d9c0b004-3d29-4483-a22e-601627f71e24	ENCARREGADO ADMINISTRATIVO	2026-05-28 14:49:38.079723
89cf6f5e-0ae5-4b69-a5a1-e1561b1bfc21	ENGENHEIRO MECANICO	2026-05-28 14:49:38.079723
7fb7502c-f7f1-4c8f-ad9d-5e82e94e8159	GERENTE DE CONTRATO	2026-05-28 14:49:38.079723
75b8754a-8409-4791-b9cc-c665ac2c7786	INSPETOR DE SOLDA	2026-05-28 14:49:38.079723
2dce46a2-7f0c-4f94-8190-e5d81472ab39	MECANICO MONTADOR	2026-05-28 14:49:38.079723
ebbbdb90-fb9b-4dc9-bb44-e7c1d378e2df	MOTORISTA E OPERADOR DE MUNCK	2026-05-28 14:49:38.079723
c2cf8ebf-4b4c-46d0-9e23-33cc8aca3a59	SERRALHEIRO	2026-05-28 14:49:38.079723
e331bfe1-4dfa-4eea-a004-37fe36ecad59	SOLDADOR TIG - ACO INOX	2026-05-28 14:49:38.079723
3951cd45-9855-4e1e-bcb4-e6cd787f2082	SOLDADOR TIG - INOX OD	2026-05-28 14:49:38.079723
2225eb09-8b7d-4f3f-85a0-55a5e20d0c15	SUPERVISOR DE ELETRICA	2026-05-28 14:49:38.079723
2a451230-d296-481a-959a-41515b1327d9	SUPERVISOR DE MECANICA	2026-05-28 14:49:38.079723
879b81f2-93b2-4fed-83cc-0ada1bcbff3f	TECNICO DE QUALIDADE	2026-05-28 14:49:38.079723
6a7f0b33-a1cd-426d-9c70-31981f3fd09b	TST	2026-05-28 14:49:38.079723
a5fd6e4c-462e-498d-94de-61b08a738d15	ENCARREGADO DE MECANICA	2026-05-28 14:49:38.079723
85d4e2ee-f662-4112-9fae-af252d73e3f5	SOLDADOR TIG I	2026-05-28 14:49:38.079723
ed8562e1-ff40-4363-9b45-8980bc3c416a	OFICIAL ELETRICISTA	2026-05-28 14:49:38.079723
64fd4e8e-f651-4ed0-a654-2b5349148a12	AUXILIAR DE SERVICOS GERAIS	2026-05-28 14:49:38.079723
d1746f21-7030-4188-9f92-44e6b86c9909	TECNICO DE PLANEJAMENTO	2026-05-28 14:49:38.079723
43d587ab-d22c-41ee-89e8-6d58f41c71ac	ENCARREGADO DE ELETRICA	2026-05-28 14:49:38.079723
bf7b42db-f21d-472a-b294-531403798b5d	1/2 OFICIAL ELETRICISTA	2026-05-28 14:49:38.079723
338d331e-ef03-4d94-9369-567ee922f1e9	AJUDANTE	2026-05-28 14:49:38.079723
9db2c94b-4577-4d09-b95b-74e14a817134	1/2 OFICIAL MECANICO MONTADOR	2026-05-28 12:45:06.237113
660cf090-49f9-49f6-929d-56b368f0f077	ALMOXARIFE	2026-05-28 12:45:06.237113
96b3bf34-1ff8-498a-8d79-8b58e6c0d27e	ASSISTENTE ADMINISTRATIVO	2026-05-28 12:45:06.237113
42957b19-fea1-437e-a7c5-d3bb901dc768	COORDENADOR ADM	2026-05-28 12:45:06.237113
500bb637-344a-4b46-8a55-1e201a956559	ELETRICISTA FORCA E CONTROLE	2026-05-28 12:45:06.237113
db08eb56-a519-4e5a-9552-469ad5022092	ELETRICISTA MONTADOR	2026-05-28 12:45:06.237113
bb52a96e-d4c9-4d1c-95f5-46ca4edbd6da	ENCANADOR	2026-05-28 12:45:06.237113
914d6d69-7338-4197-be53-ac04a5216eba	ENCANADOR INDUSTRIAL	2026-05-28 12:45:06.237113
72111b9e-66e6-45bb-a880-6f8213aadb83	ENCARREGADO ADMINISTRATIVO	2026-05-28 12:45:06.237113
1256e263-8ddc-4f42-a709-8aeff777adfe	ENGENHEIRO MECANICO	2026-05-28 12:45:06.237113
8388416f-593d-4783-88a9-c7fbfe444a2a	GERENTE DE CONTRATO	2026-05-28 12:45:06.237113
8c6831e8-749e-4129-9e26-ef8b35ae7846	INSPETOR DE SOLDA	2026-05-28 12:45:06.237113
54fc3257-284c-400a-92cb-823ed14e12bb	MECANICO MONTADOR	2026-05-28 12:45:06.237113
1e28dc0d-886b-403f-932d-3b0e0bb121f1	MOTORISTA E OPERADOR DE MUNCK	2026-05-28 12:45:06.237113
6ed3d88a-0399-407c-98d7-17e14c39e412	SERRALHEIRO	2026-05-28 12:45:06.237113
dd0b7d73-9f10-4b98-9fa2-5a4566cc8599	SOLDADOR TIG - ACO INOX	2026-05-28 12:45:06.237113
a7259de6-ecc3-477e-9de1-66f495d341ce	SOLDADOR TIG - INOX OD	2026-05-28 12:45:06.237113
796f1e6a-e703-46d7-81dc-34512c83f4aa	SUPERVISOR DE ELETRICA	2026-05-28 12:45:06.237113
39479116-4586-4247-97d8-1d239f0a5e40	SUPERVISOR DE MECANICA	2026-05-28 12:45:06.237113
7eea652f-04e8-4d93-96f7-3dba1039eff2	TECNICO DE QUALIDADE	2026-05-28 12:45:06.237113
6c8c29ed-d2d4-4094-b205-634d8c75e7d2	TST	2026-05-28 12:45:06.237113
0225eda7-e5af-4f5c-8cec-c56a1263fdac	ENCARREGADO DE MECANICA	2026-05-28 12:45:06.237113
7152c1ed-d2f6-4458-8abf-1ea8aaa94d7e	SOLDADOR TIG I	2026-05-28 12:45:06.237113
b8b2c36d-c697-43cc-b99c-0613d4a51805	OFICIAL ELETRICISTA	2026-05-28 12:45:06.237113
bab2270a-24b3-4bab-8b15-efaecbcd3932	AUXILIAR DE SERVICOS GERAIS	2026-05-28 12:45:06.237113
92b68cad-a690-4416-b8ea-a12c4300d0ac	TECNICO DE PLANEJAMENTO	2026-05-28 12:45:06.237113
050b8cd2-1116-4b81-ab1d-e69eebc8c823	ENCARREGADO DE ELETRICA	2026-05-28 12:45:06.237113
d8f950a5-08a9-401a-b641-0e41c0003ebd	1/2 OFICIAL ELETRICISTA	2026-05-28 12:45:06.237113
7caffb6b-e097-42a2-a2af-2174ff22ed08	AJUDANTE	2026-05-28 12:45:06.237113
ada75202-5c20-4780-9f7a-46354bc8c1ed	1/2 OFICIAL MECANICO MONTADOR	2026-05-28 13:00:36.500204
42ccc17f-0ef4-450d-adea-407536bdbd8e	ALMOXARIFE	2026-05-28 13:00:36.500204
6e425393-09ee-4868-a01e-a7a1fe429c67	ASSISTENTE ADMINISTRATIVO	2026-05-28 13:00:36.500204
f7e14767-d50f-4885-a99b-8e1e1ea3fee9	COORDENADOR ADM	2026-05-28 13:00:36.500204
f9b09718-11a9-4121-a9b3-53078f80d4c7	ELETRICISTA FORCA E CONTROLE	2026-05-28 13:00:36.500204
eae884b1-38d5-4406-8815-b2e981c1fb58	ELETRICISTA MONTADOR	2026-05-28 13:00:36.500204
6556abe8-cc5b-4645-9b5b-6309f1eb49f5	ENCANADOR	2026-05-28 13:00:36.500204
33bafa53-3df0-4162-9cd9-66b6b9c6853a	ENCANADOR INDUSTRIAL	2026-05-28 13:00:36.500204
4b693ef5-8c1d-4df2-9ed9-89cdeaf5edec	ENCARREGADO ADMINISTRATIVO	2026-05-28 13:00:36.500204
1fe83703-6b09-4a2e-b748-c65e9bbf35ad	ENGENHEIRO MECANICO	2026-05-28 13:00:36.500204
16670a7c-a4e2-4180-b954-bf0cf0064f7b	GERENTE DE CONTRATO	2026-05-28 13:00:36.500204
b8916406-a8b7-46a9-8ae0-16081c4607fd	INSPETOR DE SOLDA	2026-05-28 13:00:36.500204
4a5727db-1089-4ea5-9908-b25ec46a181f	MECANICO MONTADOR	2026-05-28 13:00:36.500204
848fec3c-0a5b-49a1-a404-aee09c09786a	MOTORISTA E OPERADOR DE MUNCK	2026-05-28 13:00:36.500204
046ef8c5-084c-4d4a-a5ca-3d8bddbad56c	SERRALHEIRO	2026-05-28 13:00:36.500204
f7ba6869-adbf-432a-916c-d879e612adf6	SOLDADOR TIG - ACO INOX	2026-05-28 13:00:36.500204
d2ba0994-18d9-45bb-a8cb-72b2341d805e	SOLDADOR TIG - INOX OD	2026-05-28 13:00:36.500204
d5214a2b-1ea4-402b-9a1e-84e4fa23bad7	SUPERVISOR DE ELETRICA	2026-05-28 13:00:36.500204
6c6a5789-66f9-45a7-84fc-4bee4591078d	SUPERVISOR DE MECANICA	2026-05-28 13:00:36.500204
5080facc-3ef1-414f-8927-da2b8e7b2a94	TECNICO DE QUALIDADE	2026-05-28 13:00:36.500204
9f00c83b-3072-4b7f-8b57-6234899551d0	TST	2026-05-28 13:00:36.500204
abdfe1c7-afcb-4d42-8715-f447b32f4e72	ENCARREGADO DE MECANICA	2026-05-28 13:00:36.500204
c80d7f62-d881-4aae-8b81-f1549410aff2	SOLDADOR TIG I	2026-05-28 13:00:36.500204
f527c6c8-0deb-4a02-bc0d-bf7caf604142	OFICIAL ELETRICISTA	2026-05-28 13:00:36.500204
5e6a6e4a-4829-47e5-81ac-7e5652376f73	AUXILIAR DE SERVICOS GERAIS	2026-05-28 13:00:36.500204
f26a0180-2046-42a1-9abd-ed1bf28d8412	TECNICO DE PLANEJAMENTO	2026-05-28 13:00:36.500204
665423d3-cbb1-453d-94f7-318ec7ef1a7e	ENCARREGADO DE ELETRICA	2026-05-28 13:00:36.500204
cfe19267-5b83-43cf-a747-b5ca87d1ef95	1/2 OFICIAL ELETRICISTA	2026-05-28 13:00:36.500204
457f7b06-33ed-4be8-bcad-cc8cf4a74ea4	AJUDANTE	2026-05-28 13:00:36.500204
a781963c-40b2-4bfb-80d7-2d6d532f3bbe	1/2 OFICIAL MECANICO MONTADOR	2026-05-28 13:06:23.356527
2a0ba318-2ac8-4dec-a446-cafaf0cd27cd	ALMOXARIFE	2026-05-28 13:06:23.356527
0d7a8b24-2f5e-480e-83bc-5cd7f85b11ed	ASSISTENTE ADMINISTRATIVO	2026-05-28 13:06:23.356527
45c9ba6e-71d3-46b8-9f69-dc1602c3f7fd	COORDENADOR ADM	2026-05-28 13:06:23.356527
124a0564-2873-42fa-b4f4-5525c8ec043a	ELETRICISTA FORCA E CONTROLE	2026-05-28 13:06:23.356527
204ffd16-1dd7-44a9-a8e1-971510128280	ELETRICISTA MONTADOR	2026-05-28 13:06:23.356527
378753e1-7221-45f7-a28e-0f988d31c30b	ENCANADOR	2026-05-28 13:06:23.356527
22bef773-4de9-432c-90f3-9bf53be3bc8c	ENCANADOR INDUSTRIAL	2026-05-28 13:06:23.356527
13316e78-e713-4250-af4a-7d05342fe3c6	ENCARREGADO ADMINISTRATIVO	2026-05-28 13:06:23.356527
9074c670-3bc0-4507-b015-3894a06c82e7	ENGENHEIRO MECANICO	2026-05-28 13:06:23.356527
45806436-bbb3-4d64-b70c-773cc9603e2c	GERENTE DE CONTRATO	2026-05-28 13:06:23.356527
9ac47a84-f9a5-4693-88b4-7648d49d768b	INSPETOR DE SOLDA	2026-05-28 13:06:23.356527
cde079dd-2d53-44c2-9054-6245d154bcf6	MECANICO MONTADOR	2026-05-28 13:06:23.356527
da878862-0dc9-4a72-839d-286633c2e1f7	MOTORISTA E OPERADOR DE MUNCK	2026-05-28 13:06:23.356527
e4b76f85-2752-4d5d-9cfd-702840679b60	SERRALHEIRO	2026-05-28 13:06:23.356527
57d71461-b726-4f47-bb96-3df443069605	SOLDADOR TIG - ACO INOX	2026-05-28 13:06:23.356527
9742f505-e8df-43ff-902e-3d2c85f9ef81	SOLDADOR TIG - INOX OD	2026-05-28 13:06:23.356527
3850bf3c-b93d-4b3d-84f7-b9f6b32825cd	SUPERVISOR DE ELETRICA	2026-05-28 13:06:23.356527
2890ec9d-0668-424b-9dd6-a2f5dc117679	SUPERVISOR DE MECANICA	2026-05-28 13:06:23.356527
6b72e7ee-65b4-4ea9-9488-3e579b047f14	TECNICO DE QUALIDADE	2026-05-28 13:06:23.356527
13f39133-9c6b-491f-961a-bf99feaa30e5	TST	2026-05-28 13:06:23.356527
b9218bc0-3d1c-4201-82ac-d94715511c6b	ENCARREGADO DE MECANICA	2026-05-28 13:06:23.356527
004ff949-bcec-471e-a336-528bf2c27c98	SOLDADOR TIG I	2026-05-28 13:06:23.356527
8c370121-79c8-4127-8765-2effb13291bc	OFICIAL ELETRICISTA	2026-05-28 13:06:23.356527
0b962a42-41cc-40cb-8672-03de8735a485	AUXILIAR DE SERVICOS GERAIS	2026-05-28 13:06:23.356527
d888be0e-017a-41aa-91f5-b5fdc6db89fa	TECNICO DE PLANEJAMENTO	2026-05-28 13:06:23.356527
420d66d2-413f-4da3-985b-001019a079d9	ENCARREGADO DE ELETRICA	2026-05-28 13:06:23.356527
b8579a58-d26c-4f6b-b701-44fa4b721cd9	1/2 OFICIAL ELETRICISTA	2026-05-28 13:06:23.356527
b518adfa-7979-4e79-8950-4da701311270	AJUDANTE	2026-05-28 13:06:23.356527
c339d2bc-e56b-4933-b556-1f1451b55e59	1/2 OFICIAL MECANICO MONTADOR	2026-05-28 13:11:51.373666
a235f765-cc0a-45e5-8ad9-a2c8410e1295	ALMOXARIFE	2026-05-28 13:11:51.373666
631d3e26-5d95-46f4-b827-a75ccee4dfd2	ASSISTENTE ADMINISTRATIVO	2026-05-28 13:11:51.373666
1ae8bb8e-20eb-421d-9d3e-71560e7cfce5	COORDENADOR ADM	2026-05-28 13:11:51.373666
a75f9140-63f4-450f-8cb7-044f51393277	ELETRICISTA FORCA E CONTROLE	2026-05-28 13:11:51.373666
9022150c-041a-43a9-9356-1a9e1a08efea	ELETRICISTA MONTADOR	2026-05-28 13:11:51.373666
0072e223-f905-4a2a-9540-6fdc43b9b11c	ENCANADOR	2026-05-28 13:11:51.373666
4695a342-36d7-4a92-8c70-78b190b7bc93	ENCANADOR INDUSTRIAL	2026-05-28 13:11:51.373666
6a0a101c-8563-4e72-a91e-e993254e33c1	ENCARREGADO ADMINISTRATIVO	2026-05-28 13:11:51.373666
31ddba5b-dc5c-45de-9497-80eab1d9a7fd	ENGENHEIRO MECANICO	2026-05-28 13:11:51.373666
d8c705f5-d833-4cdd-8af9-85fadd63e0ca	GERENTE DE CONTRATO	2026-05-28 13:11:51.373666
68cfc201-3e3a-4c79-b1cf-c14064fd6045	INSPETOR DE SOLDA	2026-05-28 13:11:51.373666
9db16231-709d-4bcd-b627-011b5129199a	MECANICO MONTADOR	2026-05-28 13:11:51.373666
51b1e0cc-e78f-492d-a3e2-1b25bd7d1483	MOTORISTA E OPERADOR DE MUNCK	2026-05-28 13:11:51.373666
0f58f874-6d22-4add-99cc-d7139c8bdbba	SERRALHEIRO	2026-05-28 13:11:51.373666
03bbf1f5-6955-45b9-b64f-219c1626c65e	SOLDADOR TIG - ACO INOX	2026-05-28 13:11:51.373666
2aa5e7a4-d577-400e-9756-f02ecebd51ba	SOLDADOR TIG - INOX OD	2026-05-28 13:11:51.373666
ad61d11d-09f4-4623-9139-5f157ef118b3	SUPERVISOR DE ELETRICA	2026-05-28 13:11:51.373666
7e5fef42-67d1-4bb7-bdbe-907922204685	SUPERVISOR DE MECANICA	2026-05-28 13:11:51.373666
8c81e0f9-b19a-4e8c-a0f6-e688358761e4	TECNICO DE QUALIDADE	2026-05-28 13:11:51.373666
26e681b2-4b36-46ae-a87f-6ab0121c5bd8	TST	2026-05-28 13:11:51.373666
09cd3614-4d1e-4234-82d5-ce858577682e	ENCARREGADO DE MECANICA	2026-05-28 13:11:51.373666
02128a2b-19ba-4072-a781-0a65a4e4f5c1	SOLDADOR TIG I	2026-05-28 13:11:51.373666
f4e199ca-8a6f-4232-8ace-f5c3fd2b9476	OFICIAL ELETRICISTA	2026-05-28 13:11:51.373666
be29d15e-cb1d-494b-9ae9-ff2f5f791cb1	AUXILIAR DE SERVICOS GERAIS	2026-05-28 13:11:51.373666
5e976505-25ca-437d-9efb-6e22859c59ee	TECNICO DE PLANEJAMENTO	2026-05-28 13:11:51.373666
b0c79fdb-19ad-4776-a03b-e90254f60925	ENCARREGADO DE ELETRICA	2026-05-28 13:11:51.373666
5e40ceb8-51f0-4e08-87ce-679a658e3695	1/2 OFICIAL ELETRICISTA	2026-05-28 13:11:51.373666
7d9dffa9-1696-4cb1-bfda-1e2fd2fc255a	AJUDANTE	2026-05-28 13:11:51.373666
8829bd95-36aa-4565-ae5d-c4f170124b38	1/2 OFICIAL MECANICO MONTADOR	2026-05-28 13:13:59.595569
93279c25-1370-40af-9bcc-09ae1c28da0c	ALMOXARIFE	2026-05-28 13:13:59.595569
0b9d58cf-e14b-4bfb-b6f9-70259cc30c2c	ASSISTENTE ADMINISTRATIVO	2026-05-28 13:13:59.595569
033767f7-b8ce-4c24-9ab0-cb2adcaf83cb	COORDENADOR ADM	2026-05-28 13:13:59.595569
02a9da83-895c-4439-adff-aa33c7465e2f	ELETRICISTA FORCA E CONTROLE	2026-05-28 13:13:59.595569
c81b694a-65bb-4d52-bd3e-515283cef2de	ELETRICISTA MONTADOR	2026-05-28 13:13:59.595569
412fe641-e3b4-47cd-8dde-54cb38376635	ENCANADOR	2026-05-28 13:13:59.595569
68d8a418-0a01-41ce-a961-a6ef2c85852d	ENCANADOR INDUSTRIAL	2026-05-28 13:13:59.595569
c9e71c1f-6fda-4087-9815-9198f7130ce5	ENCARREGADO ADMINISTRATIVO	2026-05-28 13:13:59.595569
ac1daf6a-2e6a-4497-9b75-176f3c450928	ENGENHEIRO MECANICO	2026-05-28 13:13:59.595569
27adc327-0d8c-4983-946a-f6c7d99ab805	GERENTE DE CONTRATO	2026-05-28 13:13:59.595569
495e9c44-829d-48e9-9206-376b4f430a61	INSPETOR DE SOLDA	2026-05-28 13:13:59.595569
85eb0285-9773-47cd-818e-7722ba3b557d	MECANICO MONTADOR	2026-05-28 13:13:59.595569
a29f4353-cc48-4308-9b1b-80ca2914360e	MOTORISTA E OPERADOR DE MUNCK	2026-05-28 13:13:59.595569
72839f65-b004-4b72-828e-e2c720fb4e6d	SERRALHEIRO	2026-05-28 13:13:59.595569
55c090af-e003-4b88-b130-6cd81c801d33	SOLDADOR TIG - ACO INOX	2026-05-28 13:13:59.595569
7a770096-90d4-4d5a-9a14-23e5550b4bbc	SOLDADOR TIG - INOX OD	2026-05-28 13:13:59.595569
8eeab936-4eee-42d6-ad09-23de1bcd69cf	SUPERVISOR DE ELETRICA	2026-05-28 13:13:59.595569
1007c12f-39bc-4458-8cd5-85e2a0aa4a0b	SUPERVISOR DE MECANICA	2026-05-28 13:13:59.595569
9853e4ad-484b-43eb-9ca0-6dd8adf5753d	TECNICO DE QUALIDADE	2026-05-28 13:13:59.595569
f29fb779-4527-41f8-b6b7-33737916acf8	TST	2026-05-28 13:13:59.595569
ca4610d1-ac6c-4d81-8aa5-1452e1a431ed	ENCARREGADO DE MECANICA	2026-05-28 13:13:59.595569
5c3653ec-7eda-49f2-be8c-3123e9fc0ac5	SOLDADOR TIG I	2026-05-28 13:13:59.595569
f20a94d9-df1b-4a2e-9c73-73ebe942839a	OFICIAL ELETRICISTA	2026-05-28 13:13:59.595569
d698cd65-a9cd-4419-9e23-7b9df75cfe37	AUXILIAR DE SERVICOS GERAIS	2026-05-28 13:13:59.595569
1c1abc9c-35ca-4c3f-86d7-d3a0c49c0a33	TECNICO DE PLANEJAMENTO	2026-05-28 13:13:59.595569
3b4a02c6-e67a-4a65-805e-873d48f69ee0	ENCARREGADO DE ELETRICA	2026-05-28 13:13:59.595569
66dd4bfe-53af-4163-b657-44b3630f1d0b	1/2 OFICIAL ELETRICISTA	2026-05-28 13:13:59.595569
0ddf03a1-08bc-4970-8ced-87ea7f2e51da	AJUDANTE	2026-05-28 13:13:59.595569
3e69933b-b061-4def-84b2-97707fc6c25f	1/2 OFICIAL MECANICO MONTADOR	2026-05-28 13:15:06.333459
380b8f2b-cf04-4f89-b8d5-ec4d9fb84656	ALMOXARIFE	2026-05-28 13:15:06.333459
731cb431-b61b-46f3-b449-f6469aa48b69	ASSISTENTE ADMINISTRATIVO	2026-05-28 13:15:06.333459
1022f7a9-54ff-4a13-bda2-60bb3da0a495	COORDENADOR ADM	2026-05-28 13:15:06.333459
0a96b9a4-ef33-4088-8d90-ca90dcffc41b	ELETRICISTA FORCA E CONTROLE	2026-05-28 13:15:06.333459
8dd4773e-7175-4f55-9537-c7df73164640	ELETRICISTA MONTADOR	2026-05-28 13:15:06.333459
c7871c12-edca-4daf-a196-2fe95fc2f11b	ENCANADOR	2026-05-28 13:15:06.333459
ea486827-8e6e-49b0-8a5e-ad723aed8da3	ENCANADOR INDUSTRIAL	2026-05-28 13:15:06.333459
75cfea10-7c51-42a0-9055-95dd583020bb	ENCARREGADO ADMINISTRATIVO	2026-05-28 13:15:06.333459
9f41b865-3432-4db1-bfce-ff24a2f59ae3	ENGENHEIRO MECANICO	2026-05-28 13:15:06.333459
90d001ce-a035-470c-b477-de26e0779131	GERENTE DE CONTRATO	2026-05-28 13:15:06.333459
d925a5e0-994c-4cd3-94c3-dbb2c22d5955	INSPETOR DE SOLDA	2026-05-28 13:15:06.333459
a3d6cf77-3d10-4d60-a93d-a109ac86164a	MECANICO MONTADOR	2026-05-28 13:15:06.333459
283d4b18-7651-417e-9863-28510522d587	MOTORISTA E OPERADOR DE MUNCK	2026-05-28 13:15:06.333459
5651d64b-3d52-4349-8242-2fe8d5be143b	SERRALHEIRO	2026-05-28 13:15:06.333459
71cbe94c-13c9-4e2b-82d4-6f2a4ea3a6f7	SOLDADOR TIG - ACO INOX	2026-05-28 13:15:06.333459
b37b93fc-b963-4fb0-80f3-e36fda133604	SOLDADOR TIG - INOX OD	2026-05-28 13:15:06.333459
3d5c9ba6-8e58-45ce-852a-339ce31e51e8	SUPERVISOR DE ELETRICA	2026-05-28 13:15:06.333459
02a1bc63-df52-4033-8adb-5ae4ac166a59	SUPERVISOR DE MECANICA	2026-05-28 13:15:06.333459
ce325842-7133-47f2-8cb8-39f3512f06ea	TECNICO DE QUALIDADE	2026-05-28 13:15:06.333459
806fe2a9-dbd0-4f06-ad4d-c75b781efbda	TST	2026-05-28 13:15:06.333459
871c6f12-37e3-407a-b10f-1f8a1b9088b3	ENCARREGADO DE MECANICA	2026-05-28 13:15:06.333459
be9285f9-5b9a-46e4-a6cd-7dc0de1ebd5c	SOLDADOR TIG I	2026-05-28 13:15:06.333459
e5dacaa6-18dc-4320-b6e5-3ea30f82ca4b	OFICIAL ELETRICISTA	2026-05-28 13:15:06.333459
d085f4ce-1c09-4ce0-a8f3-5463b64089d5	AUXILIAR DE SERVICOS GERAIS	2026-05-28 13:15:06.333459
3d44069c-945a-4193-8afc-168d5a33faae	TECNICO DE PLANEJAMENTO	2026-05-28 13:15:06.333459
b0ff2f00-9a58-449c-be14-6700054bea7b	ENCARREGADO DE ELETRICA	2026-05-28 13:15:06.333459
db784410-e69d-4481-aee2-768cc6f2e558	1/2 OFICIAL ELETRICISTA	2026-05-28 13:15:06.333459
06b9ba65-ce34-4b37-bc93-9afe5c659e24	AJUDANTE	2026-05-28 13:15:06.333459
44acb6cb-21b5-4ca0-949d-a0a8c195e93c	1/2 OFICIAL MECANICO MONTADOR	2026-05-28 13:21:19.827432
f510f6aa-f1d8-4fd9-b85f-dd8ff840cf76	ALMOXARIFE	2026-05-28 13:21:19.827432
42f68529-5b20-4fe8-8d07-ed867b57230b	ASSISTENTE ADMINISTRATIVO	2026-05-28 13:21:19.827432
1871457b-afe2-4901-bbf5-e2bf10e577ec	COORDENADOR ADM	2026-05-28 13:21:19.827432
e42d4474-bdb4-4053-af59-258cfeeaf7fd	ELETRICISTA FORCA E CONTROLE	2026-05-28 13:21:19.827432
3f3d72be-44e8-4557-bf61-6d7fceef7bb9	ELETRICISTA MONTADOR	2026-05-28 13:21:19.827432
e30ab108-3f16-4811-9544-a37aadac21e0	ENCANADOR	2026-05-28 13:21:19.827432
f517f830-c820-4602-987f-74eacb30c34a	ENCANADOR INDUSTRIAL	2026-05-28 13:21:19.827432
329c55ce-e889-4947-b566-edd818035e41	ENCARREGADO ADMINISTRATIVO	2026-05-28 13:21:19.827432
f3c1c00d-b7fb-4820-961e-91f52ddab184	ENGENHEIRO MECANICO	2026-05-28 13:21:19.827432
48d4954d-fc79-4c33-9535-d269575c42ff	GERENTE DE CONTRATO	2026-05-28 13:21:19.827432
1a33edac-398b-4d0e-a207-8790d8050a08	INSPETOR DE SOLDA	2026-05-28 13:21:19.827432
f3be3192-7549-4fa7-b800-304270e25b57	MECANICO MONTADOR	2026-05-28 13:21:19.827432
8b7f7f1e-3df7-437e-be19-2c21deb9a278	MOTORISTA E OPERADOR DE MUNCK	2026-05-28 13:21:19.827432
e5a7435e-e7c1-4361-9c6c-35a7f5629646	SERRALHEIRO	2026-05-28 13:21:19.827432
a39955eb-b81c-475a-ba39-3abb5114b788	SOLDADOR TIG - ACO INOX	2026-05-28 13:21:19.827432
73e6e208-06a7-4e44-bf6b-32423d5815e7	SOLDADOR TIG - INOX OD	2026-05-28 13:21:19.827432
6c9d900c-5091-4370-b976-2b8e8616f578	SUPERVISOR DE ELETRICA	2026-05-28 13:21:19.827432
ac3617bf-5db6-4983-a288-7cc57efdf95d	SUPERVISOR DE MECANICA	2026-05-28 13:21:19.827432
acf639d3-37c5-4c36-a993-cf7dc61fbb08	TECNICO DE QUALIDADE	2026-05-28 13:21:19.827432
c4234994-592c-420d-8c69-a123d34d2e6b	TST	2026-05-28 13:21:19.827432
11a21b75-311a-43ae-9591-f4a20067ef45	ENCARREGADO DE MECANICA	2026-05-28 13:21:19.827432
30f7a8c5-f037-4f1a-a8fc-ec324fa28e14	SOLDADOR TIG I	2026-05-28 13:21:19.827432
7e3e3865-85c5-42bb-bce2-cabc6d0145b2	OFICIAL ELETRICISTA	2026-05-28 13:21:19.827432
420d9816-c3b8-4bdb-806e-55118ec2a161	AUXILIAR DE SERVICOS GERAIS	2026-05-28 13:21:19.827432
9072524a-a2d0-46d4-ad2c-efd123230ddb	TECNICO DE PLANEJAMENTO	2026-05-28 13:21:19.827432
73868bc0-896c-4444-90ee-69fcb289829e	ENCARREGADO DE ELETRICA	2026-05-28 13:21:19.827432
4431878f-6cbb-4bb0-81ba-9b89212eb794	1/2 OFICIAL ELETRICISTA	2026-05-28 13:21:19.827432
d36311ad-5544-46fc-a6af-d977202f603b	AJUDANTE	2026-05-28 13:21:19.827432
7149e949-765f-48b2-8822-aad62cab73e6	1/2 OFICIAL MECANICO MONTADOR	2026-05-28 14:30:21.850599
f4ce54ab-8a82-4185-a561-1a443c6c738c	ALMOXARIFE	2026-05-28 14:30:21.850599
4dab3c0b-9b73-4d29-9612-722e72eb694e	ASSISTENTE ADMINISTRATIVO	2026-05-28 14:30:21.850599
d3d78aa8-21ae-44a4-ad61-6f99443b99ff	COORDENADOR ADM	2026-05-28 14:30:21.850599
d7e5cb8b-4a5e-4670-b53d-9b990b244f1f	ELETRICISTA FORCA E CONTROLE	2026-05-28 14:30:21.850599
91dc41a5-8374-4431-84e8-f6fa26b7d02e	ELETRICISTA MONTADOR	2026-05-28 14:30:21.850599
2f3442c7-85ca-4567-9b55-0cec09fbb94c	ENCANADOR	2026-05-28 14:30:21.850599
e1e15be2-7d6a-40de-81d7-db6171eea80b	ENCANADOR INDUSTRIAL	2026-05-28 14:30:21.850599
bd49449d-c4ff-4ca1-a3be-7d917745b4b2	ENCARREGADO ADMINISTRATIVO	2026-05-28 14:30:21.850599
a62f89a7-129a-413f-a364-163c31a21a47	ENGENHEIRO MECANICO	2026-05-28 14:30:21.850599
bac2748b-fe59-4abd-9c8a-df9300f71d27	GERENTE DE CONTRATO	2026-05-28 14:30:21.850599
0fe74c94-ed96-47f4-8db6-478c01cc191a	INSPETOR DE SOLDA	2026-05-28 14:30:21.850599
8c02aab1-0f88-4882-b962-3cc20dd90aae	MECANICO MONTADOR	2026-05-28 14:30:21.850599
eee19bf3-9a4a-4fdf-ad7a-2e9806a348d4	MOTORISTA E OPERADOR DE MUNCK	2026-05-28 14:30:21.850599
8d31dbfd-9a97-4475-b516-22187da0c988	SERRALHEIRO	2026-05-28 14:30:21.850599
1d1aa3e8-53b2-451e-a222-b7bcd5bb9620	SOLDADOR TIG - ACO INOX	2026-05-28 14:30:21.850599
a32ab263-23ac-4ddb-9319-727f4f572d87	SOLDADOR TIG - INOX OD	2026-05-28 14:30:21.850599
253a0173-537d-4a92-86dd-38e9e0ad1c3b	SUPERVISOR DE ELETRICA	2026-05-28 14:30:21.850599
911e6755-0090-4883-965a-2d096e6f1730	SUPERVISOR DE MECANICA	2026-05-28 14:30:21.850599
7253de94-03ec-47b9-9372-09600c1a0493	TECNICO DE QUALIDADE	2026-05-28 14:30:21.850599
6d8dd9da-681b-4bae-bada-ae4578721420	TST	2026-05-28 14:30:21.850599
5b8f341c-968f-4d9f-8297-d973c79262b2	ENCARREGADO DE MECANICA	2026-05-28 14:30:21.850599
b0f47868-20bf-4c04-8458-20f7f7a8f120	SOLDADOR TIG I	2026-05-28 14:30:21.850599
9652cb82-ce82-49e7-847c-06a66d55cb63	OFICIAL ELETRICISTA	2026-05-28 14:30:21.850599
e1bfb178-e494-49c8-9403-a7c644ec6abb	AUXILIAR DE SERVICOS GERAIS	2026-05-28 14:30:21.850599
15e9aabe-f469-48d3-ba8a-3c981229294f	TECNICO DE PLANEJAMENTO	2026-05-28 14:30:21.850599
26970811-a46b-4c9c-93e7-402cc7ee75a5	ENCARREGADO DE ELETRICA	2026-05-28 14:30:21.850599
6bd0e213-c32c-463f-9186-af82541d0781	1/2 OFICIAL ELETRICISTA	2026-05-28 14:30:21.850599
75394b37-b919-4850-b2ab-15aefc560359	AJUDANTE	2026-05-28 14:30:21.850599
e8efcdc8-7638-47fd-988d-cc4d8af03fa6	1/2 OFICIAL MECANICO MONTADOR	2026-05-28 15:36:26.578207
f864ea3a-5d32-4d22-91ab-ca9d4ea6f2ed	ALMOXARIFE	2026-05-28 15:36:26.578207
bfeab413-2fa2-4459-9a70-3d4ef9b555b1	ASSISTENTE ADMINISTRATIVO	2026-05-28 15:36:26.578207
3673de7f-2034-4bcb-8cce-a07732547a14	COORDENADOR ADM	2026-05-28 15:36:26.578207
efc725e4-7add-44a6-a0c4-19db65c5ad9c	ELETRICISTA FORCA E CONTROLE	2026-05-28 15:36:26.578207
fd98fe54-a012-49ae-8a4f-4359c7556f01	ELETRICISTA MONTADOR	2026-05-28 15:36:26.578207
c5ddb144-5847-4aec-b64b-cb346f96cfad	ENCANADOR	2026-05-28 15:36:26.578207
ce707fd5-3539-47d0-97f7-c318d86e9fa9	ENCANADOR INDUSTRIAL	2026-05-28 15:36:26.578207
d3e9070c-4e16-499e-ad29-68ce6b0c7233	ENCARREGADO ADMINISTRATIVO	2026-05-28 15:36:26.578207
a37ade9f-1c34-4a94-a6fb-492a7c795bec	ENGENHEIRO MECANICO	2026-05-28 15:36:26.578207
9ef182b5-29a4-4086-b6f7-0e86ba64e1e3	GERENTE DE CONTRATO	2026-05-28 15:36:26.578207
f4f54c30-e25c-4591-a237-3c9c2868a405	INSPETOR DE SOLDA	2026-05-28 15:36:26.578207
ba943e59-b5ef-4e26-bcf3-4dd582761e96	MECANICO MONTADOR	2026-05-28 15:36:26.578207
52de12e1-9782-4441-a484-b205cef42d8a	MOTORISTA E OPERADOR DE MUNCK	2026-05-28 15:36:26.578207
d691f07e-1bff-4926-90ee-0abc4fa9e36c	SERRALHEIRO	2026-05-28 15:36:26.578207
547b4884-700e-4811-93bf-9f8dd8c4ebe4	SOLDADOR TIG - ACO INOX	2026-05-28 15:36:26.578207
d656b2d1-ec14-4eb8-8edb-2fb325bc6234	SOLDADOR TIG - INOX OD	2026-05-28 15:36:26.578207
7534b310-fc6d-44bf-8d56-9e190ea02c14	SUPERVISOR DE ELETRICA	2026-05-28 15:36:26.578207
ffe39d0c-ec59-40b4-9bfa-76b7542cae8e	SUPERVISOR DE MECANICA	2026-05-28 15:36:26.578207
4a96a854-9eff-4814-b193-f5c2fa746f3b	TECNICO DE QUALIDADE	2026-05-28 15:36:26.578207
9f9750da-f103-418a-b920-d560df4abf87	TST	2026-05-28 15:36:26.578207
bd7fdbac-c6fd-4def-881a-368a0ad1b10a	ENCARREGADO DE MECANICA	2026-05-28 15:36:26.578207
a8b16054-7e65-4dcb-8826-1daa40c93ded	SOLDADOR TIG I	2026-05-28 15:36:26.578207
cc968949-d283-47c4-9fd3-d6057d0db40f	OFICIAL ELETRICISTA	2026-05-28 15:36:26.578207
d934afc0-2fde-47b1-81d9-0e34da09c763	AUXILIAR DE SERVICOS GERAIS	2026-05-28 15:36:26.578207
077b1dc4-ce20-4be0-a6f2-303bca201278	TECNICO DE PLANEJAMENTO	2026-05-28 15:36:26.578207
502057ed-d5a0-4ae8-8110-36b0b90c3bb6	ENCARREGADO DE ELETRICA	2026-05-28 15:36:26.578207
719d24dd-253f-46b8-aae4-c39ab3adbc09	1/2 OFICIAL ELETRICISTA	2026-05-28 15:36:26.578207
7942036b-30f7-470e-883e-4c446cde19cf	AJUDANTE	2026-05-28 15:36:26.578207
\.


--
-- Data for Name: obras; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.obras (id, codigo, nome, cidade, uf, empresa_id, created_at, centro_custo) FROM stdin;
0d899f11-785d-4edd-a951-bac82fae074f	24104I	YPE_Salto_FabrLiq	Salto	SP	4489b3ec-6774-4a13-bc24-31b77deb6ae7	2026-05-28 12:17:36.652254	\N
f1b4fe50-69ba-4443-aa10-53e4d8d124c7	23698	UFV ARAPUÁ KROMA	JAGUARUANA 	CE	4489b3ec-6774-4a13-bc24-31b77deb6ae7	2026-05-28 17:55:21.710926	\N
3bd8994a-2652-4f14-a89e-eec4edbf4b00	23959	UFV Amarante I e II	Amarante	PI	145e0a9b-f796-4db5-92e9-33f046f959ae	2026-05-28 20:14:26.668643	\N
fc4de3dd-31fc-42f5-8de2-2d9ff773e9f7	100	SEDE	\N	\N	4489b3ec-6774-4a13-bc24-31b77deb6ae7	2026-06-03 12:54:08.276	100 SEDE
a0fb8e09-6b5e-454d-8de7-14c62e70fc4c	101	ALMOXARIFADO	\N	\N	4489b3ec-6774-4a13-bc24-31b77deb6ae7	2026-06-03 12:54:08.276	101 ALMOXARIFADO
20c57a2e-373b-495f-b937-011ca3cee784	1940501E	EMBRAER GPX - DEMANDA	\N	\N	4489b3ec-6774-4a13-bc24-31b77deb6ae7	2026-06-03 12:54:08.276	1940501E
42a5a1f8-fff4-4159-af0c-075ed65b0809	1940502E	EMBRAER FARIA LIMA DEMANDA	\N	\N	4489b3ec-6774-4a13-bc24-31b77deb6ae7	2026-06-03 12:54:08.276	1940502E
cbfc1750-6534-4a9b-9742-36d46f9088e8	1940503E	EMBRAER BOTUCATU - DEMANDA	\N	\N	4489b3ec-6774-4a13-bc24-31b77deb6ae7	2026-06-03 12:54:08.276	1940503E
12d03f84-0ffa-49ef-b9dc-ee294c632343	1940505E	EMBRAER EUGENIO DE MELO - DEMANDA	\N	\N	4489b3ec-6774-4a13-bc24-31b77deb6ae7	2026-06-03 12:54:08.276	1940505E
a08a71f7-e6bf-4198-bcc8-538da36b3575	1940506E	EMBRAER FARIA LIMA TI	\N	\N	4489b3ec-6774-4a13-bc24-31b77deb6ae7	2026-06-03 12:54:08.276	1940506E
f07ef654-267a-452a-ad23-ce8812df5bc0	1940507E	EMBRAER GPX - TI	\N	\N	4489b3ec-6774-4a13-bc24-31b77deb6ae7	2026-06-03 12:54:08.276	1940507E
559b08b7-60ce-4c2a-90cd-4413a9123cbb	1940508E	EMBRAER BOTUCATU - TI	\N	\N	4489b3ec-6774-4a13-bc24-31b77deb6ae7	2026-06-03 12:54:08.276	1940508E
077f7dd5-4aba-407e-8cfa-b5cb76f5e2a1	1940510E	EMBRAER TAUBATE	\N	\N	4489b3ec-6774-4a13-bc24-31b77deb6ae7	2026-06-03 12:54:08.276	1940510E
4df2b647-9bc0-43ba-8f03-02e7eeb4256b	1940511E	EMBRAER SOROCABA - DEMANDA	\N	\N	4489b3ec-6774-4a13-bc24-31b77deb6ae7	2026-06-03 12:54:08.276	1940511E
a0f2c225-981e-49be-bff4-633b31fb21ef	1940512E	EMBRAER EUGENIO DE MELO - TI	\N	\N	4489b3ec-6774-4a13-bc24-31b77deb6ae7	2026-06-03 12:54:08.276	1940512E
d7d6d6c8-9f40-4bdb-bebe-70229dfcd23b	1940513E	EMBRAER SA TAUBATE	\N	\N	4489b3ec-6774-4a13-bc24-31b77deb6ae7	2026-06-03 12:54:08.276	1940513E
0c08560e-8c3f-42b8-93a4-360823a97abc	1940525E	EMBRAER CACAPAVA	\N	\N	4489b3ec-6774-4a13-bc24-31b77deb6ae7	2026-06-03 12:54:08.276	1940525E
8fb22fad-feb9-4446-87af-e42fdf83e423	1940526E	EMBRAER CACAPAVA TI	\N	\N	4489b3ec-6774-4a13-bc24-31b77deb6ae7	2026-06-03 12:54:08.276	1940526E
6b0145c0-8a36-413a-84bf-9ac8a1c6c5b1	1940527E	EMBRAER SA - EDE	\N	\N	4489b3ec-6774-4a13-bc24-31b77deb6ae7	2026-06-03 12:54:08.276	1940527E
69e37927-eaed-42c8-9959-da13905e6fc9	1940528E	EMBRAER SA - EDE II	\N	\N	4489b3ec-6774-4a13-bc24-31b77deb6ae7	2026-06-03 12:54:08.276	1940528E
c6f8866b-0ea1-4810-886d-ee0926c4fd18	202	MEIWA	\N	\N	4489b3ec-6774-4a13-bc24-31b77deb6ae7	2026-06-03 12:54:08.276	202 FIXA MEIWA
25341e31-cd60-4743-ad1b-658397ec5d72	23403	DAIICHI SANKYO BRASIL FARMACEUTICA LTDA	\N	\N	4489b3ec-6774-4a13-bc24-31b77deb6ae7	2026-06-03 12:54:08.276	23403
4fea7f8e-8b40-4cb4-a6b6-077ecdfdc25b	23517	RAIZEN GD LTDA - UFV CONCORDIA	\N	\N	4489b3ec-6774-4a13-bc24-31b77deb6ae7	2026-06-03 12:54:08.276	23517
c2096d7c-a212-4365-9d85-3151167e0436	23558	RHODIA BRASIL S A	\N	\N	4489b3ec-6774-4a13-bc24-31b77deb6ae7	2026-06-03 12:54:08.276	23558
7d3ffdc6-837d-446c-bf67-383e69268451	23682I	UFV BA IRAMAIA I	\N	\N	4489b3ec-6774-4a13-bc24-31b77deb6ae7	2026-06-03 12:54:08.276	23682I
ca0aeaf5-7ec0-4356-8fc3-94f1cdcb74ae	23698I	UFV ARAPUA I	\N	\N	4489b3ec-6774-4a13-bc24-31b77deb6ae7	2026-06-03 12:54:08.276	23698I
a40dff69-3824-4b4a-a9a0-f1317cd79d15	23698II	UFV ARAPUA II	\N	\N	4489b3ec-6774-4a13-bc24-31b77deb6ae7	2026-06-03 12:54:08.276	23698II
ee11d856-5a44-4f7e-8a12-8f1b7ea77460	23698III	UFV ARAPUA III	\N	\N	4489b3ec-6774-4a13-bc24-31b77deb6ae7	2026-06-03 12:54:08.276	23698III
3de411ab-2a70-4a1e-9283-420734cce3fe	23698IV	UFV ARAPUA IV	\N	\N	4489b3ec-6774-4a13-bc24-31b77deb6ae7	2026-06-03 12:54:08.276	23698IV
170460df-5595-43a8-9648-014fb8b35595	23787	UFV RN MOSSORO II LTDA	\N	\N	4489b3ec-6774-4a13-bc24-31b77deb6ae7	2026-06-03 12:54:08.276	23787
0ea37ce8-5f9d-4270-ac46-73e6c169c6d2	23898	SYNGENTA PROTECAO DE CULTIVOS	\N	\N	4489b3ec-6774-4a13-bc24-31b77deb6ae7	2026-06-03 12:54:08.276	23898
9eec3ea6-e312-4821-a0e0-db44ac37ca87	23958I	GS E&C BRAZIL LTDA - LG	\N	\N	4489b3ec-6774-4a13-bc24-31b77deb6ae7	2026-06-03 12:54:08.276	23958I
cdf20f78-a409-4306-b0f2-efb6fbf9d905	23959	UFV PI AMARANTE I E II	\N	\N	4489b3ec-6774-4a13-bc24-31b77deb6ae7	2026-06-03 12:54:08.276	23959
8510fe11-35bd-4772-ac9a-073bbd0ff197	23985	COSAN SA - POLI USP	\N	\N	4489b3ec-6774-4a13-bc24-31b77deb6ae7	2026-06-03 12:54:08.276	23985
14d12f35-cd36-4357-9b1e-2e284d11e6a7	24016CNO	UFV SANTA RITA DE CALDAS I	\N	\N	4489b3ec-6774-4a13-bc24-31b77deb6ae7	2026-06-03 12:54:08.276	24016CNO
45808c6d-a0b7-4ecc-8622-578e26ed4515	24104I	QUIMICA AMPARO LTDA CNO	\N	\N	4489b3ec-6774-4a13-bc24-31b77deb6ae7	2026-06-03 12:54:08.276	24104I
e4d4b0db-e80d-46cf-9b56-fa5f707c64aa	24122	ICTSI - RIO BRASIL TERMINAL	\N	\N	4489b3ec-6774-4a13-bc24-31b77deb6ae7	2026-06-03 12:54:08.276	24122
fecd46b3-7f55-4fa2-b0f6-02e351793a4f	24128	COAMO AGROINDUSTRIAL COOPERATIVA	\N	\N	4489b3ec-6774-4a13-bc24-31b77deb6ae7	2026-06-03 12:54:08.276	24128
a999f677-cd94-426b-859d-7f6b9f64bc66	24178	SYNGENTA PROTECAO DE CULTIVOS LTDA	\N	\N	4489b3ec-6774-4a13-bc24-31b77deb6ae7	2026-06-03 12:54:08.276	24178
\.


--
-- Data for Name: prestadores; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.prestadores (id, obra_id, razao_social, cnpj, nome_fantasia, nome_completo, funcao, data_mobilizacao, data_integracao, alojamento_id, situacao, observacao, created_at, foto_url) FROM stdin;
86225441-5b33-4b23-9f6a-02b022db2cb9	0d899f11-785d-4edd-a951-bac82fae074f	EDES ANTONIO RICIERI JUNIOR	52.649.722/0001-75	EDES ANTONIO RICIERI JUNIOR	EDES ANTONIO RICIERI JUNIOR	TÈCNICO DE QUALIDADE	\N	\N	\N	ativo	\N	2026-06-18 21:46:05.998067+00	https://lqggoshphakeuufibdno.supabase.co/storage/v1/object/public/funcionarios/prestadores/1781819839920.png
\.


--
-- Data for Name: prestadores_presenca; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.prestadores_presenca (id, prestador_id, data, situacao) FROM stdin;
\.


--
-- Data for Name: usuarios_acesso; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.usuarios_acesso (id, nome, usuario, senha, perfil, obras_ids, ativo, criado_em, obras_acesso) FROM stdin;
a5b09699-30d2-467a-989c-1bc715b7b554	Murilo Evangelista	Murilo Evangelista	165079	admin	{}	t	2026-06-04 11:06:11.296776+00	[]
95ec5aeb-657c-45e1-aec5-3e21323de199	Suellen Uemoto	Suellen Uemoto	235580	usuario	{}	t	2026-06-17 15:40:05.649298+00	["c2096d7c-a212-4365-9d85-3151167e0436"]
cc22e42c-73a2-43fa-b5dd-afdb482c6166	Andre Branco	Andre Branco	121314	usuario	{0d899f11-785d-4edd-a951-bac82fae074f}	t	2026-06-04 11:24:11.595269+00	["0d899f11-785d-4edd-a951-bac82fae074f"]
13625074-77a3-4ded-8309-902a25409260	Jeziel Assis	Jeziel Assis	102030	usuario	{0d899f11-785d-4edd-a951-bac82fae074f}	t	2026-06-04 11:23:45.696441+00	["0d899f11-785d-4edd-a951-bac82fae074f"]
6cce2bfc-8eaf-4dc8-9e97-0af5b0fb0978	Andressa Pereira Sampaio Garcia	Andressa Garcia	238980	usuario	{}	t	2026-06-17 15:41:59.420263+00	["0ea37ce8-5f9d-4270-ac46-73e6c169c6d2"]
\.


--
-- Data for Name: schema_migrations; Type: TABLE DATA; Schema: realtime; Owner: -
--

COPY realtime.schema_migrations (version, inserted_at) FROM stdin;
20211116024918	2026-04-21 22:23:13
20211116045059	2026-04-21 22:23:13
20211116050929	2026-04-21 22:23:14
20211116051442	2026-04-21 22:23:14
20211116212300	2026-04-21 22:23:14
20211116213355	2026-04-21 22:23:14
20211116213934	2026-04-21 22:23:14
20211116214523	2026-04-21 22:23:14
20211122062447	2026-04-21 22:23:14
20211124070109	2026-04-21 22:23:14
20211202204204	2026-04-21 22:23:14
20211202204605	2026-04-21 22:23:15
20211210212804	2026-04-21 22:23:15
20211228014915	2026-04-21 22:23:15
20220107221237	2026-04-21 22:23:15
20220228202821	2026-04-21 22:23:15
20220312004840	2026-04-21 22:23:15
20220603231003	2026-04-21 22:23:16
20220603232444	2026-04-21 22:23:16
20220615214548	2026-04-21 22:23:16
20220712093339	2026-04-21 22:23:16
20220908172859	2026-04-21 22:23:16
20220916233421	2026-04-21 22:23:16
20230119133233	2026-04-21 22:23:16
20230128025114	2026-04-21 22:23:16
20230128025212	2026-04-21 22:23:17
20230227211149	2026-04-21 22:23:17
20230228184745	2026-04-21 22:23:17
20230308225145	2026-04-21 22:23:17
20230328144023	2026-04-21 22:23:17
20231018144023	2026-04-21 22:23:17
20231204144023	2026-04-21 22:23:17
20231204144024	2026-04-21 22:23:17
20231204144025	2026-04-21 22:23:18
20240108234812	2026-04-21 22:23:18
20240109165339	2026-04-21 22:23:18
20240227174441	2026-04-21 22:23:18
20240311171622	2026-04-21 22:23:18
20240321100241	2026-04-21 22:23:18
20240401105812	2026-04-21 22:23:19
20240418121054	2026-04-21 22:23:19
20240523004032	2026-04-21 22:23:19
20240618124746	2026-04-21 22:23:19
20240801235015	2026-04-21 22:23:20
20240805133720	2026-04-21 22:23:20
20240827160934	2026-04-21 22:23:20
20240919163303	2026-04-21 22:23:20
20240919163305	2026-04-21 22:23:20
20241019105805	2026-04-21 22:23:20
20241030150047	2026-04-21 22:23:21
20241108114728	2026-04-21 22:23:21
20241121104152	2026-04-21 22:23:21
20241130184212	2026-04-21 22:23:21
20241220035512	2026-04-21 22:23:21
20241220123912	2026-04-21 22:23:21
20241224161212	2026-04-21 22:23:21
20250107150512	2026-04-21 22:23:21
20250110162412	2026-04-21 22:23:22
20250123174212	2026-04-21 22:23:22
20250128220012	2026-04-21 22:23:22
20250506224012	2026-04-21 22:23:22
20250523164012	2026-04-21 22:23:22
20250714121412	2026-04-21 22:23:22
20250905041441	2026-04-21 22:23:22
20251103001201	2026-04-21 22:23:22
20251120212548	2026-04-21 22:23:22
20251120215549	2026-04-21 22:23:23
20260218120000	2026-04-21 22:23:23
20260326120000	2026-04-21 22:23:23
20260514120000	2026-06-18 01:38:55
20260527120000	2026-06-18 01:38:55
20260528120000	2026-06-18 01:38:55
20260603120000	2026-06-18 01:38:56
20260605120000	2026-06-18 01:38:56
20260606110000	2026-06-18 01:38:56
\.


--
-- Data for Name: subscription; Type: TABLE DATA; Schema: realtime; Owner: -
--

COPY realtime.subscription (id, subscription_id, entity, filters, claims, created_at, action_filter, selected_columns) FROM stdin;
\.


--
-- Data for Name: buckets; Type: TABLE DATA; Schema: storage; Owner: -
--

COPY storage.buckets (id, name, owner, created_at, updated_at, public, avif_autodetection, file_size_limit, allowed_mime_types, owner_id, type) FROM stdin;
Funcionarios	Funcionarios	\N	2026-05-28 14:29:08.648098+00	2026-05-28 14:29:08.648098+00	f	f	\N	\N	\N	STANDARD
funcionarios	funcionarios	\N	2026-05-28 14:30:21.850599+00	2026-05-28 14:30:21.850599+00	t	f	\N	\N	\N	STANDARD
alojamentos	alojamentos	\N	2026-06-03 19:04:54.110927+00	2026-06-03 19:04:54.110927+00	t	f	\N	\N	\N	STANDARD
\.


--
-- Data for Name: buckets_analytics; Type: TABLE DATA; Schema: storage; Owner: -
--

COPY storage.buckets_analytics (name, type, format, created_at, updated_at, id, deleted_at) FROM stdin;
\.


--
-- Data for Name: buckets_vectors; Type: TABLE DATA; Schema: storage; Owner: -
--

COPY storage.buckets_vectors (id, type, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: migrations; Type: TABLE DATA; Schema: storage; Owner: -
--

COPY storage.migrations (id, name, hash, executed_at) FROM stdin;
0	create-migrations-table	e18db593bcde2aca2a408c4d1100f6abba2195df	2026-04-21 21:05:20.800663
1	initialmigration	6ab16121fbaa08bbd11b712d05f358f9b555d777	2026-04-21 21:05:20.841848
2	storage-schema	f6a1fa2c93cbcd16d4e487b362e45fca157a8dbd	2026-04-21 21:05:20.846595
3	pathtoken-column	2cb1b0004b817b29d5b0a971af16bafeede4b70d	2026-04-21 21:05:20.879881
4	add-migrations-rls	427c5b63fe1c5937495d9c635c263ee7a5905058	2026-04-21 21:05:20.890483
5	add-size-functions	79e081a1455b63666c1294a440f8ad4b1e6a7f84	2026-04-21 21:05:20.894619
6	change-column-name-in-get-size	ded78e2f1b5d7e616117897e6443a925965b30d2	2026-04-21 21:05:20.901922
7	add-rls-to-buckets	e7e7f86adbc51049f341dfe8d30256c1abca17aa	2026-04-21 21:05:20.906802
8	add-public-to-buckets	fd670db39ed65f9d08b01db09d6202503ca2bab3	2026-04-21 21:05:20.911092
9	fix-search-function	af597a1b590c70519b464a4ab3be54490712796b	2026-04-21 21:05:20.915578
10	search-files-search-function	b595f05e92f7e91211af1bbfe9c6a13bb3391e16	2026-04-21 21:05:20.920036
11	add-trigger-to-auto-update-updated_at-column	7425bdb14366d1739fa8a18c83100636d74dcaa2	2026-04-21 21:05:20.924864
12	add-automatic-avif-detection-flag	8e92e1266eb29518b6a4c5313ab8f29dd0d08df9	2026-04-21 21:05:20.929713
13	add-bucket-custom-limits	cce962054138135cd9a8c4bcd531598684b25e7d	2026-04-21 21:05:20.934001
14	use-bytes-for-max-size	941c41b346f9802b411f06f30e972ad4744dad27	2026-04-21 21:05:20.938444
15	add-can-insert-object-function	934146bc38ead475f4ef4b555c524ee5d66799e5	2026-04-21 21:05:20.961816
16	add-version	76debf38d3fd07dcfc747ca49096457d95b1221b	2026-04-21 21:05:20.966294
17	drop-owner-foreign-key	f1cbb288f1b7a4c1eb8c38504b80ae2a0153d101	2026-04-21 21:05:20.970656
18	add_owner_id_column_deprecate_owner	e7a511b379110b08e2f214be852c35414749fe66	2026-04-21 21:05:20.974967
19	alter-default-value-objects-id	02e5e22a78626187e00d173dc45f58fa66a4f043	2026-04-21 21:05:20.980817
20	list-objects-with-delimiter	cd694ae708e51ba82bf012bba00caf4f3b6393b7	2026-04-21 21:05:20.985285
21	s3-multipart-uploads	8c804d4a566c40cd1e4cc5b3725a664a9303657f	2026-04-21 21:05:20.991298
22	s3-multipart-uploads-big-ints	9737dc258d2397953c9953d9b86920b8be0cdb73	2026-04-21 21:05:21.005894
23	optimize-search-function	9d7e604cddc4b56a5422dc68c9313f4a1b6f132c	2026-04-21 21:05:21.014841
24	operation-function	8312e37c2bf9e76bbe841aa5fda889206d2bf8aa	2026-04-21 21:05:21.019266
25	custom-metadata	d974c6057c3db1c1f847afa0e291e6165693b990	2026-04-21 21:05:21.023828
26	objects-prefixes	215cabcb7f78121892a5a2037a09fedf9a1ae322	2026-04-21 21:05:21.030671
27	search-v2	859ba38092ac96eb3964d83bf53ccc0b141663a6	2026-04-21 21:05:21.034787
28	object-bucket-name-sorting	c73a2b5b5d4041e39705814fd3a1b95502d38ce4	2026-04-21 21:05:21.038846
29	create-prefixes	ad2c1207f76703d11a9f9007f821620017a66c21	2026-04-21 21:05:21.042838
30	update-object-levels	2be814ff05c8252fdfdc7cfb4b7f5c7e17f0bed6	2026-04-21 21:05:21.046799
31	objects-level-index	b40367c14c3440ec75f19bbce2d71e914ddd3da0	2026-04-21 21:05:21.050806
32	backward-compatible-index-on-objects	e0c37182b0f7aee3efd823298fb3c76f1042c0f7	2026-04-21 21:05:21.054856
33	backward-compatible-index-on-prefixes	b480e99ed951e0900f033ec4eb34b5bdcb4e3d49	2026-04-21 21:05:21.058975
34	optimize-search-function-v1	ca80a3dc7bfef894df17108785ce29a7fc8ee456	2026-04-21 21:05:21.062991
35	add-insert-trigger-prefixes	458fe0ffd07ec53f5e3ce9df51bfdf4861929ccc	2026-04-21 21:05:21.067023
36	optimise-existing-functions	6ae5fca6af5c55abe95369cd4f93985d1814ca8f	2026-04-21 21:05:21.07099
37	add-bucket-name-length-trigger	3944135b4e3e8b22d6d4cbb568fe3b0b51df15c1	2026-04-21 21:05:21.075029
38	iceberg-catalog-flag-on-buckets	02716b81ceec9705aed84aa1501657095b32e5c5	2026-04-21 21:05:21.080058
39	add-search-v2-sort-support	6706c5f2928846abee18461279799ad12b279b78	2026-04-21 21:05:21.091016
40	fix-prefix-race-conditions-optimized	7ad69982ae2d372b21f48fc4829ae9752c518f6b	2026-04-21 21:05:21.094949
41	add-object-level-update-trigger	07fcf1a22165849b7a029deed059ffcde08d1ae0	2026-04-21 21:05:21.098993
42	rollback-prefix-triggers	771479077764adc09e2ea2043eb627503c034cd4	2026-04-21 21:05:21.103117
43	fix-object-level	84b35d6caca9d937478ad8a797491f38b8c2979f	2026-04-21 21:05:21.107138
44	vector-bucket-type	99c20c0ffd52bb1ff1f32fb992f3b351e3ef8fb3	2026-04-21 21:05:21.111223
45	vector-buckets	049e27196d77a7cb76497a85afae669d8b230953	2026-04-21 21:05:21.115971
46	buckets-objects-grants	fedeb96d60fefd8e02ab3ded9fbde05632f84aed	2026-04-21 21:05:21.127151
47	iceberg-table-metadata	649df56855c24d8b36dd4cc1aeb8251aa9ad42c2	2026-04-21 21:05:21.131991
48	iceberg-catalog-ids	e0e8b460c609b9999ccd0df9ad14294613eed939	2026-04-21 21:05:21.136262
49	buckets-objects-grants-postgres	072b1195d0d5a2f888af6b2302a1938dd94b8b3d	2026-04-21 21:05:21.153323
50	search-v2-optimised	6323ac4f850aa14e7387eb32102869578b5bd478	2026-04-21 21:05:21.158071
51	index-backward-compatible-search	2ee395d433f76e38bcd3856debaf6e0e5b674011	2026-04-21 21:05:21.176089
52	drop-not-used-indexes-and-functions	5cc44c8696749ac11dd0dc37f2a3802075f3a171	2026-04-21 21:05:21.178029
53	drop-index-lower-name	d0cb18777d9e2a98ebe0bc5cc7a42e57ebe41854	2026-04-21 21:05:21.186911
54	drop-index-object-level	6289e048b1472da17c31a7eba1ded625a6457e67	2026-04-21 21:05:21.189719
55	prevent-direct-deletes	262a4798d5e0f2e7c8970232e03ce8be695d5819	2026-04-21 21:05:21.191522
57	s3-multipart-uploads-metadata	f127886e00d1b374fadbc7c6b31e09336aad5287	2026-04-21 21:05:21.202231
58	operation-ergonomics	00ca5d483b3fe0d522133d9002ccc5df98365120	2026-04-21 21:05:21.206574
56	fix-optimized-search-function	b823ed1e418101032fa01374edc9a436e54e3ed4	2026-04-21 21:05:21.196546
59	drop-unused-functions	38456f13e39691c2bbb4b5151d0d1cdbabd4a8c4	2026-05-28 11:40:52.616871
60	optimize-existing-functions-again	db35e1c91a9201e59f4fef8d972c2f277d68b157	2026-05-28 11:40:52.62329
\.


--
-- Data for Name: objects; Type: TABLE DATA; Schema: storage; Owner: -
--

COPY storage.objects (id, bucket_id, name, owner, created_at, updated_at, last_accessed_at, metadata, version, owner_id, user_metadata) FROM stdin;
6f0dee82-8c38-4fb1-879e-a6f3e10536d3	funcionarios	fotos/1779978635722.png	\N	2026-05-28 14:30:38.018106+00	2026-05-28 14:30:38.018106+00	2026-05-28 14:30:38.018106+00	{"eTag": "\\"6cef66ad290aa34baa4e620e62dfd5d0\\"", "size": 37441, "mimetype": "image/png", "cacheControl": "max-age=3600", "lastModified": "2026-05-28T14:30:38.000Z", "contentLength": 37441, "httpStatusCode": 200}	fa9948f0-85cd-4170-8c34-903a2cb52a7b	\N	{}
ac11dd41-ce05-4d57-a1b9-2e80de1eb3d6	funcionarios	fotos/1781617850831.png	\N	2026-06-16 13:50:52.98067+00	2026-06-16 13:50:52.98067+00	2026-06-16 13:50:52.98067+00	{"eTag": "\\"eee9b1fbcfee9c27b0df1940b902fd23\\"", "size": 105546, "mimetype": "image/png", "cacheControl": "max-age=3600", "lastModified": "2026-06-16T13:50:53.000Z", "contentLength": 105546, "httpStatusCode": 200}	6a79e694-45cb-4393-8043-a81d7a544599	\N	{}
b65052b4-4f0f-4d3d-a551-e7d4946bf24f	funcionarios	fotos/1779990513083.jpeg	\N	2026-05-28 17:48:35.485277+00	2026-05-28 17:48:35.485277+00	2026-05-28 17:48:35.485277+00	{"eTag": "\\"98ed6f9eb93ca6482196de99ac79ae17\\"", "size": 35228, "mimetype": "image/jpeg", "cacheControl": "max-age=3600", "lastModified": "2026-05-28T17:48:36.000Z", "contentLength": 35228, "httpStatusCode": 200}	8cb49aca-980f-4965-ad9e-dae6a67d95e8	\N	{}
17b295c2-803f-4744-9ce8-d7124f23b573	funcionarios	fotos/1781718011153.jpeg	\N	2026-06-17 17:40:11.571182+00	2026-06-17 17:40:11.571182+00	2026-06-17 17:40:11.571182+00	{"eTag": "\\"24a7f33376dadfd9e022af5902bf5679\\"", "size": 28832, "mimetype": "image/jpeg", "cacheControl": "max-age=3600", "lastModified": "2026-06-17T17:40:12.000Z", "contentLength": 28832, "httpStatusCode": 200}	930dadc7-48bf-4a7b-8fe3-bc21496ee751	\N	{}
36b9ad6e-5b40-4252-80fe-54575502c00d	funcionarios	fotos/1779990833551.png	\N	2026-05-28 17:53:55.967554+00	2026-05-28 17:53:55.967554+00	2026-05-28 17:53:55.967554+00	{"eTag": "\\"5cddaa1be9f7e5b7aacef906f93fcdc5\\"", "size": 18136, "mimetype": "image/png", "cacheControl": "max-age=3600", "lastModified": "2026-05-28T17:53:56.000Z", "contentLength": 18136, "httpStatusCode": 200}	60d7d7a1-316d-40cd-8a57-b5b4d09ed2fd	\N	{}
72b7de5b-46a4-46dd-803a-7209c265bda5	funcionarios	fotos/1781620737437.jpg	\N	2026-06-16 14:38:58.539746+00	2026-06-16 14:38:58.539746+00	2026-06-16 14:38:58.539746+00	{"eTag": "\\"18a75dc01413e0fd161c0179ee2e9924\\"", "size": 3728, "mimetype": "image/jpeg", "cacheControl": "max-age=3600", "lastModified": "2026-06-16T14:38:59.000Z", "contentLength": 3728, "httpStatusCode": 200}	5318c41e-a5ba-44b0-93b9-5d1ba252c584	\N	{}
5271e56e-0d61-4f12-b667-f9ad0a569581	funcionarios	fotos/1779998362237.png	\N	2026-05-28 19:59:23.818476+00	2026-05-28 19:59:23.818476+00	2026-05-28 19:59:23.818476+00	{"eTag": "\\"209bcc99ab75a136fe2a9f06d29069f8\\"", "size": 378670, "mimetype": "image/png", "cacheControl": "max-age=3600", "lastModified": "2026-05-28T19:59:24.000Z", "contentLength": 378670, "httpStatusCode": 200}	088422b0-7b4f-4055-ae24-edc7325c5b6a	\N	{}
a5597c5f-9b86-422d-85aa-09237bc78d8b	funcionarios	fotos/1779998520457.jpeg	\N	2026-05-28 20:02:01.128098+00	2026-05-28 20:02:01.128098+00	2026-05-28 20:02:01.128098+00	{"eTag": "\\"8ad87bdde89bb3143799b1fcd1e27f95\\"", "size": 58406, "mimetype": "image/jpeg", "cacheControl": "max-age=3600", "lastModified": "2026-05-28T20:02:02.000Z", "contentLength": 58406, "httpStatusCode": 200}	24d3b498-bd47-4c6a-94cf-da17551f83d0	\N	{}
5ceed2ef-7f2c-4895-9d99-c84c15000d73	funcionarios	fotos/1781621877877.jpg	\N	2026-06-16 14:57:59.010694+00	2026-06-16 14:57:59.010694+00	2026-06-16 14:57:59.010694+00	{"eTag": "\\"43b83ecf6b6ee84e986486a8bd43f9bc\\"", "size": 26469, "mimetype": "image/jpeg", "cacheControl": "max-age=3600", "lastModified": "2026-06-16T14:57:59.000Z", "contentLength": 26469, "httpStatusCode": 200}	890d5e53-b892-4058-97f3-bc4522c70def	\N	{}
e3a32c02-00ea-4d72-8693-70f6f9ce0ace	funcionarios	fotos/1779999214293.jpg	\N	2026-05-28 20:13:35.381055+00	2026-05-28 20:13:35.381055+00	2026-05-28 20:13:35.381055+00	{"eTag": "\\"af38f3368caddd9c55cbd8e198c7aa59\\"", "size": 19294, "mimetype": "image/jpeg", "cacheControl": "max-age=3600", "lastModified": "2026-05-28T20:13:36.000Z", "contentLength": 19294, "httpStatusCode": 200}	673a4bf7-fe9a-4e7b-ac7b-dceca55e67ca	\N	{}
2596c116-afad-4aba-a8f6-4a63c4c5ec87	funcionarios	fotos/1780000634881.png	\N	2026-05-28 20:37:15.408746+00	2026-05-28 20:37:15.408746+00	2026-05-28 20:37:15.408746+00	{"eTag": "\\"266ceb61438fe5b51e090d30642c361f\\"", "size": 20222, "mimetype": "image/png", "cacheControl": "max-age=3600", "lastModified": "2026-05-28T20:37:16.000Z", "contentLength": 20222, "httpStatusCode": 200}	f645ed33-dbe3-4b3b-87bd-6ea0d18b2ce3	\N	{}
2af4808c-f450-4f5b-a666-12ceeaa1bdb0	funcionarios	fotos/1781697347017.jpg	\N	2026-06-17 11:55:47.6288+00	2026-06-17 11:55:47.6288+00	2026-06-17 11:55:47.6288+00	{"eTag": "\\"c5e373622260b8dae4199ef798a69da5\\"", "size": 55357, "mimetype": "image/jpeg", "cacheControl": "max-age=3600", "lastModified": "2026-06-17T11:55:48.000Z", "contentLength": 55357, "httpStatusCode": 200}	bcfccb2a-5349-4e1d-a6a3-458f3d84c92c	\N	{}
f1441219-2503-4753-8f50-c1481708db68	funcionarios	fotos/1780001269108.jpeg	\N	2026-05-28 20:47:58.133711+00	2026-05-28 20:47:58.133711+00	2026-05-28 20:47:58.133711+00	{"eTag": "\\"360238fda8277443d9fd647e08bf4292\\"", "size": 281610, "mimetype": "image/jpeg", "cacheControl": "max-age=3600", "lastModified": "2026-05-28T20:47:59.000Z", "contentLength": 281610, "httpStatusCode": 200}	6eb85fb6-2fd9-440c-89ee-400c9a354df8	\N	{}
bd3c0601-4a54-4be6-a061-351abb020126	funcionarios	fotos/1780666534267.jpg	\N	2026-06-05 13:35:37.91889+00	2026-06-05 13:35:37.91889+00	2026-06-05 13:35:37.91889+00	{"eTag": "\\"8eba7f207f17e1429b11c9c48b5b43b8\\"", "size": 19239, "mimetype": "image/jpeg", "cacheControl": "max-age=3600", "lastModified": "2026-06-05T13:35:38.000Z", "contentLength": 19239, "httpStatusCode": 200}	2fe94b72-0eda-4fac-8646-4378d3584601	\N	{}
9ff0a91d-be59-4222-91bc-6a47c918029e	funcionarios	fotos/1781525774003.png	\N	2026-06-15 12:16:14.65442+00	2026-06-15 12:16:14.65442+00	2026-06-15 12:16:14.65442+00	{"eTag": "\\"ed42e4dfd7933e02848c577a1e5c96f4\\"", "size": 206486, "mimetype": "image/png", "cacheControl": "max-age=3600", "lastModified": "2026-06-15T12:16:15.000Z", "contentLength": 206486, "httpStatusCode": 200}	9a858f81-0b6b-40e1-8605-b1e1e7ee26b0	\N	{}
216db699-9d41-4384-b673-0090fb2f1ac6	funcionarios	fotos/1781525911879.png	\N	2026-06-15 12:18:31.982285+00	2026-06-15 12:18:31.982285+00	2026-06-15 12:18:31.982285+00	{"eTag": "\\"a2d46933091178bd4d6caf06ffc92dc0\\"", "size": 24910, "mimetype": "image/png", "cacheControl": "max-age=3600", "lastModified": "2026-06-15T12:18:32.000Z", "contentLength": 24910, "httpStatusCode": 200}	d9614227-7be3-4bc7-a5c6-d72d7af43a20	\N	{}
9bb33a21-99ef-4dc4-ab2d-8309ba308e19	funcionarios	fotos/1781525994050.jpg	\N	2026-06-15 12:19:54.164932+00	2026-06-15 12:19:54.164932+00	2026-06-15 12:19:54.164932+00	{"eTag": "\\"6b0b6e19ee7c05ebf420e89ba302a577\\"", "size": 63377, "mimetype": "image/jpeg", "cacheControl": "max-age=3600", "lastModified": "2026-06-15T12:19:55.000Z", "contentLength": 63377, "httpStatusCode": 200}	2764dc4a-0eb8-42f2-81b1-744b87d6f30c	\N	{}
2659c3d6-d2fe-4096-94c7-1810adc7f41e	funcionarios	fotos/1781526967706.jpg	\N	2026-06-15 12:36:08.038251+00	2026-06-15 12:36:08.038251+00	2026-06-15 12:36:08.038251+00	{"eTag": "\\"da9814a629a73d7f58cb8fa2cddb8a13\\"", "size": 71919, "mimetype": "image/jpeg", "cacheControl": "max-age=3600", "lastModified": "2026-06-15T12:36:09.000Z", "contentLength": 71919, "httpStatusCode": 200}	6f1b4c27-c8ad-45e3-b569-d9f0f7076ed7	\N	{}
6ee15e3e-6108-447c-abb7-a3317243b089	funcionarios	fotos/1781618126691.jpeg	\N	2026-06-16 13:55:27.92036+00	2026-06-16 13:55:27.92036+00	2026-06-16 13:55:27.92036+00	{"eTag": "\\"3b8735bd89455f7cd53d1aece3b2966b\\"", "size": 86494, "mimetype": "image/jpeg", "cacheControl": "max-age=3600", "lastModified": "2026-06-16T13:55:28.000Z", "contentLength": 86494, "httpStatusCode": 200}	57e0f648-3011-4cc0-8243-124ad54d5df3	\N	{}
e9ccd525-586f-44f4-9485-702e097b0f5f	funcionarios	fotos/1781527371578.png	\N	2026-06-15 12:42:52.61391+00	2026-06-15 12:42:52.61391+00	2026-06-15 12:42:52.61391+00	{"eTag": "\\"62e235b5e7cc0f0c9b26460832d0b829\\"", "size": 177667, "mimetype": "image/png", "cacheControl": "max-age=3600", "lastModified": "2026-06-15T12:42:53.000Z", "contentLength": 177667, "httpStatusCode": 200}	5ce3df50-682d-48a1-a12a-6dc2d65c647b	\N	{}
e06caf69-3ad2-4e07-a5b0-c25d44a34dc3	funcionarios	fotos/1781718041475.jpeg	\N	2026-06-17 17:40:41.863492+00	2026-06-17 17:40:41.863492+00	2026-06-17 17:40:41.863492+00	{"eTag": "\\"79999b11a0ec4a5a010b647ffc0d8c12\\"", "size": 109716, "mimetype": "image/jpeg", "cacheControl": "max-age=3600", "lastModified": "2026-06-17T17:40:42.000Z", "contentLength": 109716, "httpStatusCode": 200}	2d827a1b-e7f3-4a35-9d23-86cf4ac739e7	\N	{}
d5cebc23-74a1-48af-82c3-5b9dd3b68fcb	funcionarios	fotos/1781527445961.png	\N	2026-06-15 12:44:07.243119+00	2026-06-15 12:44:07.243119+00	2026-06-15 12:44:07.243119+00	{"eTag": "\\"ae4667727b930f1ad574ac5affe92bdb\\"", "size": 2056062, "mimetype": "image/png", "cacheControl": "max-age=3600", "lastModified": "2026-06-15T12:44:08.000Z", "contentLength": 2056062, "httpStatusCode": 200}	a297437b-551a-46d0-b9d8-5e9ae574b0f5	\N	{}
d718d90c-a177-4201-af54-cae3f60a95a5	funcionarios	fotos/1781618273759.jpg	\N	2026-06-16 13:57:54.863887+00	2026-06-16 13:57:54.863887+00	2026-06-16 13:57:54.863887+00	{"eTag": "\\"4fa74c57bfce9c6ce21b399c6efcfb07\\"", "size": 19896, "mimetype": "image/jpeg", "cacheControl": "max-age=3600", "lastModified": "2026-06-16T13:57:55.000Z", "contentLength": 19896, "httpStatusCode": 200}	4bddd32c-9391-48c5-8d61-85b92906ab41	\N	{}
943616dc-c195-4037-a656-7d57fc849e5d	funcionarios	fotos/1781527574095.jpg	\N	2026-06-15 12:46:14.460997+00	2026-06-15 12:46:14.460997+00	2026-06-15 12:46:14.460997+00	{"eTag": "\\"d529092df83633b92bf4d9e5385658a6\\"", "size": 13568, "mimetype": "image/jpeg", "cacheControl": "max-age=3600", "lastModified": "2026-06-15T12:46:15.000Z", "contentLength": 13568, "httpStatusCode": 200}	92ab4ee1-efd7-4f2f-b4a1-7ea94e49dc90	\N	{}
707a2d09-b092-4d8f-8ade-750334dd1b4d	funcionarios	fotos/1781612775949.jpeg	\N	2026-06-16 12:26:17.223041+00	2026-06-16 12:26:17.223041+00	2026-06-16 12:26:17.223041+00	{"eTag": "\\"f2e43013132ec5f1f18be0e2fed03fad\\"", "size": 40372, "mimetype": "image/jpeg", "cacheControl": "max-age=3600", "lastModified": "2026-06-16T12:26:18.000Z", "contentLength": 40372, "httpStatusCode": 200}	993077e8-4262-4c8e-a49a-2a569d010849	\N	{}
96140e87-a61d-4c92-bfa3-81503012dd42	funcionarios	fotos/1781621459152.jpg	\N	2026-06-16 14:51:00.699141+00	2026-06-16 14:51:00.699141+00	2026-06-16 14:51:00.699141+00	{"eTag": "\\"d618a51270fa855bd187780b5b881c0a\\"", "size": 5210, "mimetype": "image/jpeg", "cacheControl": "max-age=3600", "lastModified": "2026-06-16T14:51:01.000Z", "contentLength": 5210, "httpStatusCode": 200}	c06e8285-693a-40bc-ab59-0c042f23df5d	\N	{}
96c1c3e3-27fd-4479-9c50-c57e9cbc6a75	funcionarios	fotos/1781612778213.jpeg	\N	2026-06-16 12:26:18.644625+00	2026-06-16 12:26:18.644625+00	2026-06-16 12:26:18.644625+00	{"eTag": "\\"f2e43013132ec5f1f18be0e2fed03fad\\"", "size": 40372, "mimetype": "image/jpeg", "cacheControl": "max-age=3600", "lastModified": "2026-06-16T12:26:19.000Z", "contentLength": 40372, "httpStatusCode": 200}	57ded8d5-559b-44ff-969d-8038d4bdb2aa	\N	{}
5322ce1e-f9f1-4751-a60d-e50f4e9b9915	funcionarios	fotos/1781612790413.jpeg	\N	2026-06-16 12:26:30.728018+00	2026-06-16 12:26:30.728018+00	2026-06-16 12:26:30.728018+00	{"eTag": "\\"f2e43013132ec5f1f18be0e2fed03fad\\"", "size": 40372, "mimetype": "image/jpeg", "cacheControl": "max-age=3600", "lastModified": "2026-06-16T12:26:31.000Z", "contentLength": 40372, "httpStatusCode": 200}	395a9156-49b3-4783-88e9-7a329d118221	\N	{}
4a0b3881-abb6-4c4f-bf83-088272ac6aeb	funcionarios	fotos/1781621754633.jpg	\N	2026-06-16 14:55:55.807751+00	2026-06-16 14:55:55.807751+00	2026-06-16 14:55:55.807751+00	{"eTag": "\\"d66cc8d0f4c739d23e6b319903976610\\"", "size": 40991, "mimetype": "image/jpeg", "cacheControl": "max-age=3600", "lastModified": "2026-06-16T14:55:56.000Z", "contentLength": 40991, "httpStatusCode": 200}	c0464f7c-9a13-422f-b33e-0f3e9820850f	\N	{}
f3941024-bca5-4000-abb4-0a8b0e6ef921	funcionarios	fotos/1781612791497.jpeg	\N	2026-06-16 12:26:31.794784+00	2026-06-16 12:26:31.794784+00	2026-06-16 12:26:31.794784+00	{"eTag": "\\"f2e43013132ec5f1f18be0e2fed03fad\\"", "size": 40372, "mimetype": "image/jpeg", "cacheControl": "max-age=3600", "lastModified": "2026-06-16T12:26:32.000Z", "contentLength": 40372, "httpStatusCode": 200}	73460141-9b38-41b5-9814-84f5a12af952	\N	{}
30fda57e-4ed9-4aa9-834d-932997339d3d	funcionarios	fotos/1781612798037.jpeg	\N	2026-06-16 12:26:38.320352+00	2026-06-16 12:26:38.320352+00	2026-06-16 12:26:38.320352+00	{"eTag": "\\"f2e43013132ec5f1f18be0e2fed03fad\\"", "size": 40372, "mimetype": "image/jpeg", "cacheControl": "max-age=3600", "lastModified": "2026-06-16T12:26:39.000Z", "contentLength": 40372, "httpStatusCode": 200}	463baa22-b4b4-4499-a798-045a2c018b71	\N	{}
f7fef817-3752-4f39-bce5-651707ee242f	funcionarios	fotos/1781612817949.jpeg	\N	2026-06-16 12:26:58.282665+00	2026-06-16 12:26:58.282665+00	2026-06-16 12:26:58.282665+00	{"eTag": "\\"f2e43013132ec5f1f18be0e2fed03fad\\"", "size": 40372, "mimetype": "image/jpeg", "cacheControl": "max-age=3600", "lastModified": "2026-06-16T12:26:59.000Z", "contentLength": 40372, "httpStatusCode": 200}	e101e59d-d5ed-475b-a685-107e927374e8	\N	{}
85ce40cd-993f-41ff-abae-02a87a514a66	funcionarios	fotos/1781612832917.jpeg	\N	2026-06-16 12:27:13.276237+00	2026-06-16 12:27:13.276237+00	2026-06-16 12:27:13.276237+00	{"eTag": "\\"f2e43013132ec5f1f18be0e2fed03fad\\"", "size": 40372, "mimetype": "image/jpeg", "cacheControl": "max-age=3600", "lastModified": "2026-06-16T12:27:14.000Z", "contentLength": 40372, "httpStatusCode": 200}	a4eebcde-14e5-4565-a25c-160598dc0a59	\N	{}
34be2edd-fc84-4092-bfb1-05463e6ef120	funcionarios	fotos/1781718068071.png	\N	2026-06-17 17:41:08.552001+00	2026-06-17 17:41:08.552001+00	2026-06-17 17:41:08.552001+00	{"eTag": "\\"c574036bffc384716c59bbe99ae976d0\\"", "size": 64531, "mimetype": "image/png", "cacheControl": "max-age=3600", "lastModified": "2026-06-17T17:41:09.000Z", "contentLength": 64531, "httpStatusCode": 200}	4cfcb661-3310-4651-bd99-99e619413af8	\N	{}
0bec5aac-e924-49a5-9e01-24a7d304e2bc	funcionarios	fotos/1781612837705.jpeg	\N	2026-06-16 12:27:18.005197+00	2026-06-16 12:27:18.005197+00	2026-06-16 12:27:18.005197+00	{"eTag": "\\"f2e43013132ec5f1f18be0e2fed03fad\\"", "size": 40372, "mimetype": "image/jpeg", "cacheControl": "max-age=3600", "lastModified": "2026-06-16T12:27:18.000Z", "contentLength": 40372, "httpStatusCode": 200}	27c23e94-89ad-42be-b975-c1b0aee247f2	\N	{}
e3e0a78d-baa4-4dcd-866b-62624d4c824c	alojamentos	contratos/1781619518664_CONTRATO_DE_LOCACAO-_RUA_DAS_TULIPAS_190_PAULINIA.pdf	\N	2026-06-16 14:18:43.089636+00	2026-06-16 14:18:43.089636+00	2026-06-16 14:18:43.089636+00	{"eTag": "\\"5181f3fd9dc120090a1f780799b18574\\"", "size": 3196403, "mimetype": "application/pdf", "cacheControl": "max-age=3600", "lastModified": "2026-06-16T14:18:44.000Z", "contentLength": 3196403, "httpStatusCode": 200}	18a0faab-4c66-46de-a2c5-4ad3a3c962cb	\N	{}
e603a887-97bd-47c7-9489-1add9a639efb	funcionarios	fotos/1781612842401.jpeg	\N	2026-06-16 12:27:22.87926+00	2026-06-16 12:27:22.87926+00	2026-06-16 12:27:22.87926+00	{"eTag": "\\"f2e43013132ec5f1f18be0e2fed03fad\\"", "size": 40372, "mimetype": "image/jpeg", "cacheControl": "max-age=3600", "lastModified": "2026-06-16T12:27:23.000Z", "contentLength": 40372, "httpStatusCode": 200}	002d31f5-db11-41da-a742-89ae6461446e	\N	{}
36bdc691-84e2-4715-b90f-bcccd4afa8cb	funcionarios	fotos/1781790876746.png	\N	2026-06-18 13:54:37.941464+00	2026-06-18 13:54:37.941464+00	2026-06-18 13:54:37.941464+00	{"eTag": "\\"04980a093af2f11fa0f5f79b732a8c6b\\"", "size": 95091, "mimetype": "image/png", "cacheControl": "max-age=3600", "lastModified": "2026-06-18T13:54:38.000Z", "contentLength": 95091, "httpStatusCode": 200}	2466f564-3a51-4b4b-8dd8-d3fa7cb729a3	\N	{}
5865e257-3d0f-437a-8eca-2303fe24c39c	funcionarios	fotos/1781612849281.jpeg	\N	2026-06-16 12:27:29.6206+00	2026-06-16 12:27:29.6206+00	2026-06-16 12:27:29.6206+00	{"eTag": "\\"f2e43013132ec5f1f18be0e2fed03fad\\"", "size": 40372, "mimetype": "image/jpeg", "cacheControl": "max-age=3600", "lastModified": "2026-06-16T12:27:30.000Z", "contentLength": 40372, "httpStatusCode": 200}	9593b70c-0e85-4bba-9c5f-5c01537bb052	\N	{}
8a5071fd-ce78-431c-937d-62920c47d73a	alojamentos	contratos/1781619522823_CONTRATO_DE_LOCACAO-_RUA_DAS_TULIPAS_190_PAULINIA.pdf	\N	2026-06-16 14:18:47.19699+00	2026-06-16 14:18:47.19699+00	2026-06-16 14:18:47.19699+00	{"eTag": "\\"5181f3fd9dc120090a1f780799b18574\\"", "size": 3196403, "mimetype": "application/pdf", "cacheControl": "max-age=3600", "lastModified": "2026-06-16T14:18:48.000Z", "contentLength": 3196403, "httpStatusCode": 200}	580fc251-d8c2-47e7-ad45-c22ef42b241e	\N	{}
ac76b83f-2871-495f-ba0e-541d1505d3e3	funcionarios	fotos/1781612988197.jpg	\N	2026-06-16 12:29:48.776378+00	2026-06-16 12:29:48.776378+00	2026-06-16 12:29:48.776378+00	{"eTag": "\\"aa9f8bcd02765446242cd74b7ea562df\\"", "size": 56500, "mimetype": "image/jpeg", "cacheControl": "max-age=3600", "lastModified": "2026-06-16T12:29:49.000Z", "contentLength": 56500, "httpStatusCode": 200}	17f99d57-3870-40f5-ad42-a0faa932c3e4	\N	{}
b9cef7b4-c07e-4d2d-a250-95fca6f1cac3	funcionarios	fotos/1781868139690.jpg	\N	2026-06-19 11:22:20.964947+00	2026-06-19 11:22:20.964947+00	2026-06-19 11:22:20.964947+00	{"eTag": "\\"15c9fb401fa559f8776eaf4a9604111d\\"", "size": 53200, "mimetype": "image/jpeg", "cacheControl": "max-age=3600", "lastModified": "2026-06-19T11:22:21.000Z", "contentLength": 53200, "httpStatusCode": 200}	7528badf-52ab-4434-8851-f7e827d7d079	\N	{}
aa6e4acf-e874-43d2-a6e0-e30f8a7288b6	funcionarios	fotos/1781612992653.jpg	\N	2026-06-16 12:29:52.993402+00	2026-06-16 12:29:52.993402+00	2026-06-16 12:29:52.993402+00	{"eTag": "\\"aa9f8bcd02765446242cd74b7ea562df\\"", "size": 56500, "mimetype": "image/jpeg", "cacheControl": "max-age=3600", "lastModified": "2026-06-16T12:29:53.000Z", "contentLength": 56500, "httpStatusCode": 200}	3e2ecf09-82c4-4d96-8d03-c3bf24c21609	\N	{}
92beb34c-4941-432d-a18b-9d91daef29d4	funcionarios	fotos/1781619741068.png	\N	2026-06-16 14:22:22.418681+00	2026-06-16 14:22:22.418681+00	2026-06-16 14:22:22.418681+00	{"eTag": "\\"c321bf608f0ebe4418d0b5c4e69c841e\\"", "size": 37425, "mimetype": "image/png", "cacheControl": "max-age=3600", "lastModified": "2026-06-16T14:22:23.000Z", "contentLength": 37425, "httpStatusCode": 200}	862f9ad9-0ec5-4a23-854e-a5a75feda9a6	\N	{}
aa678c46-65f5-4841-93f4-97b6c4d74a32	funcionarios	fotos/1781612995838.jpg	\N	2026-06-16 12:29:56.210278+00	2026-06-16 12:29:56.210278+00	2026-06-16 12:29:56.210278+00	{"eTag": "\\"aa9f8bcd02765446242cd74b7ea562df\\"", "size": 56500, "mimetype": "image/jpeg", "cacheControl": "max-age=3600", "lastModified": "2026-06-16T12:29:57.000Z", "contentLength": 56500, "httpStatusCode": 200}	5253c133-c1e2-4356-8f41-578f267e3a15	\N	{}
6a38cb2a-8d24-4043-8e12-8fd619bf108c	funcionarios	fotos/1781613027173.jpg	\N	2026-06-16 12:30:27.51745+00	2026-06-16 12:30:27.51745+00	2026-06-16 12:30:27.51745+00	{"eTag": "\\"aa9f8bcd02765446242cd74b7ea562df\\"", "size": 56500, "mimetype": "image/jpeg", "cacheControl": "max-age=3600", "lastModified": "2026-06-16T12:30:28.000Z", "contentLength": 56500, "httpStatusCode": 200}	2e41c6f7-b122-4ea9-9490-918c42fad324	\N	{}
9dadc57d-3353-47dc-961b-2660071480ab	funcionarios	fotos/1781613037269.jpg	\N	2026-06-16 12:30:37.738719+00	2026-06-16 12:30:37.738719+00	2026-06-16 12:30:37.738719+00	{"eTag": "\\"aa9f8bcd02765446242cd74b7ea562df\\"", "size": 56500, "mimetype": "image/jpeg", "cacheControl": "max-age=3600", "lastModified": "2026-06-16T12:30:38.000Z", "contentLength": 56500, "httpStatusCode": 200}	09dc87b4-0264-4cb8-a239-4c8dd6497160	\N	{}
6fcba31a-249e-4a17-8444-a99ec5d83fe3	funcionarios	fotos/1781613038237.jpg	\N	2026-06-16 12:30:38.645628+00	2026-06-16 12:30:38.645628+00	2026-06-16 12:30:38.645628+00	{"eTag": "\\"aa9f8bcd02765446242cd74b7ea562df\\"", "size": 56500, "mimetype": "image/jpeg", "cacheControl": "max-age=3600", "lastModified": "2026-06-16T12:30:39.000Z", "contentLength": 56500, "httpStatusCode": 200}	c0cde98b-e336-4328-be08-01cfddab3c3d	\N	{}
fd133507-a699-42f4-9b6a-d4086cde5f17	funcionarios	fotos/1781613038894.jpg	\N	2026-06-16 12:30:39.191785+00	2026-06-16 12:30:39.191785+00	2026-06-16 12:30:39.191785+00	{"eTag": "\\"aa9f8bcd02765446242cd74b7ea562df\\"", "size": 56500, "mimetype": "image/jpeg", "cacheControl": "max-age=3600", "lastModified": "2026-06-16T12:30:40.000Z", "contentLength": 56500, "httpStatusCode": 200}	1361369f-3dc9-4df3-b788-c056753d2f42	\N	{}
fc496f3a-18b6-4e69-a27a-43def076e755	funcionarios	fotos/1781613047917.jpg	\N	2026-06-16 12:30:48.232743+00	2026-06-16 12:30:48.232743+00	2026-06-16 12:30:48.232743+00	{"eTag": "\\"aa9f8bcd02765446242cd74b7ea562df\\"", "size": 56500, "mimetype": "image/jpeg", "cacheControl": "max-age=3600", "lastModified": "2026-06-16T12:30:49.000Z", "contentLength": 56500, "httpStatusCode": 200}	9da85d43-e649-4791-8234-6392667ccec4	\N	{}
812c29b4-5659-4a95-9f4e-f44ad04ba481	funcionarios	fotos/1781619852512.jpg	\N	2026-06-16 14:24:13.678811+00	2026-06-16 14:24:13.678811+00	2026-06-16 14:24:13.678811+00	{"eTag": "\\"d845754b95d766c5cc770c5ecf62c563\\"", "size": 6019, "mimetype": "image/jpeg", "cacheControl": "max-age=3600", "lastModified": "2026-06-16T14:24:14.000Z", "contentLength": 6019, "httpStatusCode": 200}	082c7e62-171e-448a-897b-bd4619945895	\N	{}
6c47c683-1a9e-4275-ad65-004c588958f1	funcionarios	fotos/1781613066870.jpg	\N	2026-06-16 12:31:07.484385+00	2026-06-16 12:31:07.484385+00	2026-06-16 12:31:07.484385+00	{"eTag": "\\"aa9f8bcd02765446242cd74b7ea562df\\"", "size": 56500, "mimetype": "image/jpeg", "cacheControl": "max-age=3600", "lastModified": "2026-06-16T12:31:08.000Z", "contentLength": 56500, "httpStatusCode": 200}	8cb60a1a-389e-4d93-bdff-7475378cc9c7	\N	{}
e3d3bde3-7907-492f-a093-825122bb1867	funcionarios	fotos/1781718098599.png	\N	2026-06-17 17:41:39.244333+00	2026-06-17 17:41:39.244333+00	2026-06-17 17:41:39.244333+00	{"eTag": "\\"1a0fec6b4e55a338163154385d186b4c\\"", "size": 79719, "mimetype": "image/png", "cacheControl": "max-age=3600", "lastModified": "2026-06-17T17:41:40.000Z", "contentLength": 79719, "httpStatusCode": 200}	b39aa3d7-2138-4991-b1c3-16f46df7c9cd	\N	{}
4facc2a8-3f63-4d5c-9bd6-fc74cef34497	funcionarios	fotos/1781613067694.jpg	\N	2026-06-16 12:31:08.134735+00	2026-06-16 12:31:08.134735+00	2026-06-16 12:31:08.134735+00	{"eTag": "\\"aa9f8bcd02765446242cd74b7ea562df\\"", "size": 56500, "mimetype": "image/jpeg", "cacheControl": "max-age=3600", "lastModified": "2026-06-16T12:31:09.000Z", "contentLength": 56500, "httpStatusCode": 200}	be2f346a-b2ee-4e08-8541-8f9f849cfc88	\N	{}
1290135d-a3ac-42b2-a475-2338fa219028	funcionarios	fotos/1781619853504.jpg	\N	2026-06-16 14:24:14.343847+00	2026-06-16 14:24:14.343847+00	2026-06-16 14:24:14.343847+00	{"eTag": "\\"d845754b95d766c5cc770c5ecf62c563\\"", "size": 6019, "mimetype": "image/jpeg", "cacheControl": "max-age=3600", "lastModified": "2026-06-16T14:24:15.000Z", "contentLength": 6019, "httpStatusCode": 200}	6cc7e959-25eb-4fc5-80ec-70fcc24d7654	\N	{}
8f55cda0-a1fb-4215-ac93-7982135db75d	funcionarios	fotos/1781613843875.jpg	\N	2026-06-16 12:44:04.721679+00	2026-06-16 12:44:04.721679+00	2026-06-16 12:44:04.721679+00	{"eTag": "\\"aa9f8bcd02765446242cd74b7ea562df\\"", "size": 56500, "mimetype": "image/jpeg", "cacheControl": "max-age=3600", "lastModified": "2026-06-16T12:44:05.000Z", "contentLength": 56500, "httpStatusCode": 200}	e121a569-1877-41f3-8048-4f1baf76df59	\N	{}
fcc0c666-7975-425f-943e-d88e2a27bf2b	funcionarios	fotos/1781613870091.jpg	\N	2026-06-16 12:44:30.462777+00	2026-06-16 12:44:30.462777+00	2026-06-16 12:44:30.462777+00	{"eTag": "\\"aa9f8bcd02765446242cd74b7ea562df\\"", "size": 56500, "mimetype": "image/jpeg", "cacheControl": "max-age=3600", "lastModified": "2026-06-16T12:44:31.000Z", "contentLength": 56500, "httpStatusCode": 200}	c76570fd-0eb1-4558-a595-7cdb875f21a6	\N	{}
930e9937-5a93-4d23-ad0c-9bf8977087dd	funcionarios	fotos/1781619985133.png	\N	2026-06-16 14:26:26.900282+00	2026-06-16 14:26:26.900282+00	2026-06-16 14:26:26.900282+00	{"eTag": "\\"49e779fdbd7888d899f499c9f16c9b8c\\"", "size": 372384, "mimetype": "image/png", "cacheControl": "max-age=3600", "lastModified": "2026-06-16T14:26:27.000Z", "contentLength": 372384, "httpStatusCode": 200}	ed57ae9e-5b9a-4c34-8178-565bcb8535df	\N	{}
6000fced-1cc5-4d7f-8d76-070e29953854	funcionarios	fotos/1781613887251.jpg	\N	2026-06-16 12:44:47.592183+00	2026-06-16 12:44:47.592183+00	2026-06-16 12:44:47.592183+00	{"eTag": "\\"aa9f8bcd02765446242cd74b7ea562df\\"", "size": 56500, "mimetype": "image/jpeg", "cacheControl": "max-age=3600", "lastModified": "2026-06-16T12:44:48.000Z", "contentLength": 56500, "httpStatusCode": 200}	70737b54-24a4-4f9c-8632-2367b66fc7bf	\N	{}
0f610434-826d-4c06-980e-b79be5c4a21e	funcionarios	prestadores/1781819839920.png	\N	2026-06-18 21:57:21.645824+00	2026-06-18 21:57:21.645824+00	2026-06-18 21:57:21.645824+00	{"eTag": "\\"da262a8fde1ed48dc62b5c672b13fd87\\"", "size": 550150, "mimetype": "image/png", "cacheControl": "max-age=3600", "lastModified": "2026-06-18T21:57:22.000Z", "contentLength": 550150, "httpStatusCode": 200}	c8f091a3-2445-4088-b14c-d33a67a0e53b	\N	{}
0e87ee39-64ae-49ca-814f-5d0004360b91	funcionarios	fotos/1781613891667.jpg	\N	2026-06-16 12:44:51.974867+00	2026-06-16 12:44:51.974867+00	2026-06-16 12:44:51.974867+00	{"eTag": "\\"aa9f8bcd02765446242cd74b7ea562df\\"", "size": 56500, "mimetype": "image/jpeg", "cacheControl": "max-age=3600", "lastModified": "2026-06-16T12:44:52.000Z", "contentLength": 56500, "httpStatusCode": 200}	3841d307-a908-423c-807c-ca76e7fb6095	\N	{}
5aad3219-9c5b-4436-9a31-e9dc29e5a335	funcionarios	fotos/1781620127432.png	\N	2026-06-16 14:28:48.638801+00	2026-06-16 14:28:48.638801+00	2026-06-16 14:28:48.638801+00	{"eTag": "\\"c291d0add69f0dccfde851d52a174fd3\\"", "size": 22049, "mimetype": "image/png", "cacheControl": "max-age=3600", "lastModified": "2026-06-16T14:28:49.000Z", "contentLength": 22049, "httpStatusCode": 200}	305209a7-d294-4a0e-a190-844952a2d0eb	\N	{}
f7aabc3a-ea6e-4cfa-8d44-d850437a3cdc	funcionarios	fotos/1781613945547.jpg	\N	2026-06-16 12:45:45.867338+00	2026-06-16 12:45:45.867338+00	2026-06-16 12:45:45.867338+00	{"eTag": "\\"aa9f8bcd02765446242cd74b7ea562df\\"", "size": 56500, "mimetype": "image/jpeg", "cacheControl": "max-age=3600", "lastModified": "2026-06-16T12:45:46.000Z", "contentLength": 56500, "httpStatusCode": 200}	2979dc24-fe81-42c0-bdff-c13c1a5b4668	\N	{}
5ae332f2-5e1e-4e90-ba59-6be0086ee2f7	funcionarios	fotos/1781613964720.jpg	\N	2026-06-16 12:46:05.255184+00	2026-06-16 12:46:05.255184+00	2026-06-16 12:46:05.255184+00	{"eTag": "\\"aa9f8bcd02765446242cd74b7ea562df\\"", "size": 56500, "mimetype": "image/jpeg", "cacheControl": "max-age=3600", "lastModified": "2026-06-16T12:46:06.000Z", "contentLength": 56500, "httpStatusCode": 200}	bfd3b548-88da-46b7-a611-fdaefe6cbd36	\N	{}
6a4d10e6-eedf-409b-a21b-815e414c8048	funcionarios	fotos/1781613965883.jpg	\N	2026-06-16 12:46:06.19097+00	2026-06-16 12:46:06.19097+00	2026-06-16 12:46:06.19097+00	{"eTag": "\\"aa9f8bcd02765446242cd74b7ea562df\\"", "size": 56500, "mimetype": "image/jpeg", "cacheControl": "max-age=3600", "lastModified": "2026-06-16T12:46:07.000Z", "contentLength": 56500, "httpStatusCode": 200}	30172ba5-a3d9-4782-b46e-876bb4930700	\N	{}
0a369685-2478-4b06-b7b5-2e9bcd63d59d	funcionarios	fotos/1781613974711.jpg	\N	2026-06-16 12:46:15.018272+00	2026-06-16 12:46:15.018272+00	2026-06-16 12:46:15.018272+00	{"eTag": "\\"aa9f8bcd02765446242cd74b7ea562df\\"", "size": 56500, "mimetype": "image/jpeg", "cacheControl": "max-age=3600", "lastModified": "2026-06-16T12:46:15.000Z", "contentLength": 56500, "httpStatusCode": 200}	338d1ec4-a389-4d5f-a9af-df4de4d86c4b	\N	{}
8683ba88-1c29-4c8a-8254-029614c22ae1	funcionarios	fotos/1781613999039.jpg	\N	2026-06-16 12:46:39.383606+00	2026-06-16 12:46:39.383606+00	2026-06-16 12:46:39.383606+00	{"eTag": "\\"aa9f8bcd02765446242cd74b7ea562df\\"", "size": 56500, "mimetype": "image/jpeg", "cacheControl": "max-age=3600", "lastModified": "2026-06-16T12:46:40.000Z", "contentLength": 56500, "httpStatusCode": 200}	0c4e79a1-9918-4690-a45c-c6c4c25686d1	\N	{}
c0270297-fefb-405e-bca6-a1e7b9fc9c90	funcionarios	fotos/1781620128180.png	\N	2026-06-16 14:28:49.046021+00	2026-06-16 14:28:49.046021+00	2026-06-16 14:28:49.046021+00	{"eTag": "\\"c291d0add69f0dccfde851d52a174fd3\\"", "size": 22049, "mimetype": "image/png", "cacheControl": "max-age=3600", "lastModified": "2026-06-16T14:28:50.000Z", "contentLength": 22049, "httpStatusCode": 200}	57f58614-0d3c-43bd-9e27-2729e1800177	\N	{}
495d8944-119c-4bb8-b136-59b291d4c9bf	funcionarios	fotos/1781614118319.jpg	\N	2026-06-16 12:48:38.867176+00	2026-06-16 12:48:38.867176+00	2026-06-16 12:48:38.867176+00	{"eTag": "\\"aa9f8bcd02765446242cd74b7ea562df\\"", "size": 56500, "mimetype": "image/jpeg", "cacheControl": "max-age=3600", "lastModified": "2026-06-16T12:48:39.000Z", "contentLength": 56500, "httpStatusCode": 200}	23bb2280-f846-4083-bd52-21acd1bab93d	\N	{}
ad7724ae-c995-4cc0-90d9-32578928455f	funcionarios	fotos/1781614121867.jpg	\N	2026-06-16 12:48:42.336623+00	2026-06-16 12:48:42.336623+00	2026-06-16 12:48:42.336623+00	{"eTag": "\\"aa9f8bcd02765446242cd74b7ea562df\\"", "size": 56500, "mimetype": "image/jpeg", "cacheControl": "max-age=3600", "lastModified": "2026-06-16T12:48:43.000Z", "contentLength": 56500, "httpStatusCode": 200}	bc22d998-7b99-415e-9cc9-ec48ab9aa7ed	\N	{}
468e60c2-871b-41d6-8b11-eca2d898cdb4	funcionarios	fotos/1781620241748.png	\N	2026-06-16 14:30:42.64168+00	2026-06-16 14:30:42.64168+00	2026-06-16 14:30:42.64168+00	{"eTag": "\\"2fe53a627559ad3355a274379a8ef5cf\\"", "size": 50688, "mimetype": "image/png", "cacheControl": "max-age=3600", "lastModified": "2026-06-16T14:30:43.000Z", "contentLength": 50688, "httpStatusCode": 200}	8ffbd7cf-ff57-4307-abf4-bea8410e68fd	\N	{}
cbfe6c69-ff6e-4472-adee-4854b7ebdd57	funcionarios	fotos/1781614150299.jpg	\N	2026-06-16 12:49:10.695703+00	2026-06-16 12:49:10.695703+00	2026-06-16 12:49:10.695703+00	{"eTag": "\\"aa9f8bcd02765446242cd74b7ea562df\\"", "size": 56500, "mimetype": "image/jpeg", "cacheControl": "max-age=3600", "lastModified": "2026-06-16T12:49:11.000Z", "contentLength": 56500, "httpStatusCode": 200}	995d9bba-2f01-4b6e-83b9-52eabf527b58	\N	{}
4b0bf0be-88b7-4b1d-85d9-8c4082b3f9c6	funcionarios	fotos/1781621755461.jpg	\N	2026-06-16 14:55:56.348246+00	2026-06-16 14:55:56.348246+00	2026-06-16 14:55:56.348246+00	{"eTag": "\\"d66cc8d0f4c739d23e6b319903976610\\"", "size": 40991, "mimetype": "image/jpeg", "cacheControl": "max-age=3600", "lastModified": "2026-06-16T14:55:57.000Z", "contentLength": 40991, "httpStatusCode": 200}	be577a58-d19f-4b4e-ac6c-a57bac584d6e	\N	{}
04484d20-1007-4889-a5d5-0ce5bdd6fce2	funcionarios	fotos/1781614153932.jpg	\N	2026-06-16 12:49:14.238173+00	2026-06-16 12:49:14.238173+00	2026-06-16 12:49:14.238173+00	{"eTag": "\\"aa9f8bcd02765446242cd74b7ea562df\\"", "size": 56500, "mimetype": "image/jpeg", "cacheControl": "max-age=3600", "lastModified": "2026-06-16T12:49:15.000Z", "contentLength": 56500, "httpStatusCode": 200}	601675ed-d0e9-4b4d-821f-d165a454e485	\N	{}
4b0456eb-4f51-43a0-82ba-566cdc862e84	funcionarios	fotos/1781638016414.jpg	\N	2026-06-16 19:26:58.390171+00	2026-06-16 19:26:58.390171+00	2026-06-16 19:26:58.390171+00	{"eTag": "\\"9d95ddbaf3f7d7c2bc0cea33274a7ade\\"", "size": 5293, "mimetype": "image/jpeg", "cacheControl": "max-age=3600", "lastModified": "2026-06-16T19:26:59.000Z", "contentLength": 5293, "httpStatusCode": 200}	e4a2aeb0-4216-4869-8ff2-daecfa068821	\N	{}
6d3c6902-2436-4114-996b-ce84a02c5ca6	funcionarios	fotos/1781614175739.jpg	\N	2026-06-16 12:49:36.069889+00	2026-06-16 12:49:36.069889+00	2026-06-16 12:49:36.069889+00	{"eTag": "\\"aa9f8bcd02765446242cd74b7ea562df\\"", "size": 56500, "mimetype": "image/jpeg", "cacheControl": "max-age=3600", "lastModified": "2026-06-16T12:49:37.000Z", "contentLength": 56500, "httpStatusCode": 200}	c9e2c0be-d152-4138-95af-d3eec335874a	\N	{}
d69dbc0f-4f5e-44ba-ad40-ca93c5abb80f	funcionarios	fotos/1781697691372.png	\N	2026-06-17 12:01:32.187549+00	2026-06-17 12:01:32.187549+00	2026-06-17 12:01:32.187549+00	{"eTag": "\\"8bd83f24158a3bb098bf07af0b9eba09\\"", "size": 24105, "mimetype": "image/png", "cacheControl": "max-age=3600", "lastModified": "2026-06-17T12:01:33.000Z", "contentLength": 24105, "httpStatusCode": 200}	7ab8d2ac-c191-4003-a8c4-55053a4646b8	\N	{}
c0c0bed9-0f1c-4687-a375-98e931f891d1	funcionarios	fotos/1781614259416.jpg	\N	2026-06-16 12:50:59.96942+00	2026-06-16 12:50:59.96942+00	2026-06-16 12:50:59.96942+00	{"eTag": "\\"aa9f8bcd02765446242cd74b7ea562df\\"", "size": 56500, "mimetype": "image/jpeg", "cacheControl": "max-age=3600", "lastModified": "2026-06-16T12:51:00.000Z", "contentLength": 56500, "httpStatusCode": 200}	10cd54f1-b1f5-49ce-a644-424a953c7363	\N	{}
0b78377e-6646-4e3a-8778-7900f0ff2ec1	alojamentos	contratos/1781784544255_24104-004_-_CONTRATO_COSTA_ROCHAXGTEL_-_RUA_COSTA_RICA,_604.pdf	\N	2026-06-18 12:09:08.574491+00	2026-06-18 12:09:08.574491+00	2026-06-18 12:09:08.574491+00	{"eTag": "\\"c1d7539d31c0e8bb49223c1f02a74a3e\\"", "size": 6549634, "mimetype": "application/pdf", "cacheControl": "max-age=3600", "lastModified": "2026-06-18T12:09:09.000Z", "contentLength": 6549634, "httpStatusCode": 200}	fcc2cfba-9843-4d28-b101-ab8d07b3fbfb	\N	{}
6bf60ab7-497a-414c-886d-898291049f4e	funcionarios	fotos/1781698406797.jpg	\N	2026-06-17 12:13:27.900253+00	2026-06-17 12:13:27.900253+00	2026-06-17 12:13:27.900253+00	{"eTag": "\\"bdb4d6c1378ace71c1486e79b62c25bb\\"", "size": 6424, "mimetype": "image/jpeg", "cacheControl": "max-age=3600", "lastModified": "2026-06-17T12:13:28.000Z", "contentLength": 6424, "httpStatusCode": 200}	4b3dc672-126f-42ee-b33e-f3377e49178b	\N	{}
c3d19ba2-90a9-48d9-b2c3-d671606f4afd	funcionarios	fotos/1781698408360.jpg	\N	2026-06-17 12:13:28.649091+00	2026-06-17 12:13:28.649091+00	2026-06-17 12:13:28.649091+00	{"eTag": "\\"bdb4d6c1378ace71c1486e79b62c25bb\\"", "size": 6424, "mimetype": "image/jpeg", "cacheControl": "max-age=3600", "lastModified": "2026-06-17T12:13:29.000Z", "contentLength": 6424, "httpStatusCode": 200}	60c851f6-38bb-45f8-b187-2159ae241e2b	\N	{}
0342de89-34d3-4e48-9aed-2d44c4726fae	funcionarios	fotos/1781698553281.jpeg	\N	2026-06-17 12:15:53.783047+00	2026-06-17 12:15:53.783047+00	2026-06-17 12:15:53.783047+00	{"eTag": "\\"ef057ae942efa003dfefc6189905fb40\\"", "size": 21794, "mimetype": "image/jpeg", "cacheControl": "max-age=3600", "lastModified": "2026-06-17T12:15:54.000Z", "contentLength": 21794, "httpStatusCode": 200}	7e1c2fc3-fd57-4359-a9c9-c70226d8e9d3	\N	{}
e7d8d8b8-acc5-4486-81e9-0406a03b6c91	funcionarios	fotos/1781698554025.jpeg	\N	2026-06-17 12:15:54.265649+00	2026-06-17 12:15:54.265649+00	2026-06-17 12:15:54.265649+00	{"eTag": "\\"ef057ae942efa003dfefc6189905fb40\\"", "size": 21794, "mimetype": "image/jpeg", "cacheControl": "max-age=3600", "lastModified": "2026-06-17T12:15:55.000Z", "contentLength": 21794, "httpStatusCode": 200}	5ed6219f-55cc-4a50-8530-31e36b52d276	\N	{}
3530cdc4-40c5-4a3a-9be0-b18180b95981	alojamentos	laudos/1781784548934_RELATORIO_ESTRUTURAL_09.pdf	\N	2026-06-18 12:09:10.065252+00	2026-06-18 12:09:10.065252+00	2026-06-18 12:09:10.065252+00	{"eTag": "\\"7824a61a646356111d51ff1b0cbf68ab\\"", "size": 1437994, "mimetype": "application/pdf", "cacheControl": "max-age=3600", "lastModified": "2026-06-18T12:09:11.000Z", "contentLength": 1437994, "httpStatusCode": 200}	453fbff6-06e7-4687-8db7-1b23e4fba66d	\N	{}
936af41c-d0a1-4319-974e-d56a5d275bf0	funcionarios	fotos/1781698660378.jpg	\N	2026-06-17 12:17:40.672155+00	2026-06-17 12:17:40.672155+00	2026-06-17 12:17:40.672155+00	{"eTag": "\\"f2672664d154cbce73d5304e11682d70\\"", "size": 31428, "mimetype": "image/jpeg", "cacheControl": "max-age=3600", "lastModified": "2026-06-17T12:17:41.000Z", "contentLength": 31428, "httpStatusCode": 200}	82c05fca-eaec-4173-8998-ef7f4625ab33	\N	{}
03a8eb49-e219-43d7-adcd-bbd762e83acb	funcionarios	fotos/1781698777773.jpg	\N	2026-06-17 12:19:38.29568+00	2026-06-17 12:19:38.29568+00	2026-06-17 12:19:38.29568+00	{"eTag": "\\"995c4ef1a6b5e55f0fe2dfd378e195c0\\"", "size": 30302, "mimetype": "image/jpeg", "cacheControl": "max-age=3600", "lastModified": "2026-06-17T12:19:39.000Z", "contentLength": 30302, "httpStatusCode": 200}	52f26a94-684a-4a55-a523-674b68f9426c	\N	{}
dfcba7c9-1479-402c-a578-c370139ee9c9	alojamentos	fotos/1781784550414_FOTOS.zip	\N	2026-06-18 12:09:12.820239+00	2026-06-18 12:09:12.820239+00	2026-06-18 12:09:12.820239+00	{"eTag": "\\"e61afb54b88d281b0620576ec649fb7e\\"", "size": 3125690, "mimetype": "application/x-zip-compressed", "cacheControl": "max-age=3600", "lastModified": "2026-06-18T12:09:13.000Z", "contentLength": 3125690, "httpStatusCode": 200}	24ab78e8-98e3-478f-8f24-1d911cd537ea	\N	{}
d55dd5e6-297e-4297-8286-2aa113cffe13	funcionarios	fotos/1781698886569.jpg	\N	2026-06-17 12:21:26.85039+00	2026-06-17 12:21:26.85039+00	2026-06-17 12:21:26.85039+00	{"eTag": "\\"985701e61a8aa48496c452d151c6521a\\"", "size": 4379, "mimetype": "image/jpeg", "cacheControl": "max-age=3600", "lastModified": "2026-06-17T12:21:27.000Z", "contentLength": 4379, "httpStatusCode": 200}	e3d92b64-30c1-4952-a696-5e25fff6693c	\N	{}
d717b596-9fc0-42d1-acce-06ba57507a73	funcionarios	fotos/1781698997817.jpg	\N	2026-06-17 12:23:18.136903+00	2026-06-17 12:23:18.136903+00	2026-06-17 12:23:18.136903+00	{"eTag": "\\"6d5b6bd4d130c70a63c604d50fb17e4b\\"", "size": 41531, "mimetype": "image/jpeg", "cacheControl": "max-age=3600", "lastModified": "2026-06-17T12:23:19.000Z", "contentLength": 41531, "httpStatusCode": 200}	c579e0c4-3c3b-4837-a650-9ebaadd4f4d6	\N	{}
737e2804-e6e5-455c-9c10-71462a27b5cb	alojamentos	contratos/1781784551934_24104-004_-_CONTRATO_COSTA_ROCHAXGTEL_-_RUA_COSTA_RICA,_604.pdf	\N	2026-06-18 12:09:17.172248+00	2026-06-18 12:09:17.172248+00	2026-06-18 12:09:17.172248+00	{"eTag": "\\"c1d7539d31c0e8bb49223c1f02a74a3e\\"", "size": 6549634, "mimetype": "application/pdf", "cacheControl": "max-age=3600", "lastModified": "2026-06-18T12:09:18.000Z", "contentLength": 6549634, "httpStatusCode": 200}	7716f0d2-ea50-4599-9859-f60e56e1cf3b	\N	{}
40c0f3c4-ffa9-4d71-9b7e-5f8afa8c2f63	funcionarios	fotos/1781699105821.jpg	\N	2026-06-17 12:25:06.222575+00	2026-06-17 12:25:06.222575+00	2026-06-17 12:25:06.222575+00	{"eTag": "\\"b2c578c1bf2ac94b8b947af35de3897c\\"", "size": 5768, "mimetype": "image/jpeg", "cacheControl": "max-age=3600", "lastModified": "2026-06-17T12:25:07.000Z", "contentLength": 5768, "httpStatusCode": 200}	2c9613f7-20e6-463b-a401-f23852e206e1	\N	{}
47d02aeb-8a65-4ae7-8216-d8ecc319cc06	funcionarios	fotos/1781699311793.jpg	\N	2026-06-17 12:28:32.234805+00	2026-06-17 12:28:32.234805+00	2026-06-17 12:28:32.234805+00	{"eTag": "\\"ee8b95146e8c847793381a6d3dde9e43\\"", "size": 21692, "mimetype": "image/jpeg", "cacheControl": "max-age=3600", "lastModified": "2026-06-17T12:28:33.000Z", "contentLength": 21692, "httpStatusCode": 200}	6c04ff99-c90c-430c-9822-a93481860d2e	\N	{}
7991edca-e94a-40a7-8be6-f948e2b4061a	funcionarios	fotos/1781865064936.jpg	\N	2026-06-19 10:31:07.443932+00	2026-06-19 10:31:07.443932+00	2026-06-19 10:31:07.443932+00	{"eTag": "\\"f3ae977424b479ed6ff08f5fc219930b\\"", "size": 1006231, "mimetype": "image/jpeg", "cacheControl": "max-age=3600", "lastModified": "2026-06-19T10:31:08.000Z", "contentLength": 1006231, "httpStatusCode": 200}	62acd761-4e32-4c14-9ccc-02b4ca19a30a	\N	{}
5a0afe70-a8db-4a0e-a578-f4e2fffd1f74	funcionarios	fotos/1781699420135.jpg	\N	2026-06-17 12:30:20.946203+00	2026-06-17 12:30:20.946203+00	2026-06-17 12:30:20.946203+00	{"eTag": "\\"e416bab16e25036304b9d1896e9581da\\"", "size": 32990, "mimetype": "image/jpeg", "cacheControl": "max-age=3600", "lastModified": "2026-06-17T12:30:21.000Z", "contentLength": 32990, "httpStatusCode": 200}	cf1363ee-2114-43db-aac5-1bdbc66fb645	\N	{}
7e1f5de4-3f64-4547-a4c4-60e48b7025fa	funcionarios	fotos/1781865692126.jpg	\N	2026-06-19 10:41:32.915239+00	2026-06-19 10:41:32.915239+00	2026-06-19 10:41:32.915239+00	{"eTag": "\\"d682769ef897c218ff894bd2f2ac32bb\\"", "size": 72441, "mimetype": "image/jpeg", "cacheControl": "max-age=3600", "lastModified": "2026-06-19T10:41:33.000Z", "contentLength": 72441, "httpStatusCode": 200}	a702ecaf-170e-47d5-9f2b-def9d23bdc72	\N	{}
422f9dfc-d8ed-4561-a8a2-fb433b32646a	funcionarios	fotos/1781865933848.png	\N	2026-06-19 10:45:34.865572+00	2026-06-19 10:45:34.865572+00	2026-06-19 10:45:34.865572+00	{"eTag": "\\"f63f6cc314bea80a83fcb2261302919f\\"", "size": 55692, "mimetype": "image/png", "cacheControl": "max-age=3600", "lastModified": "2026-06-19T10:45:35.000Z", "contentLength": 55692, "httpStatusCode": 200}	aad7e8c5-cae8-41c1-99d4-2d4b15218129	\N	{}
c54b00b6-6f27-4485-afa2-489bc219fe53	funcionarios	fotos/1781699587730.jpg	\N	2026-06-17 12:33:08.362814+00	2026-06-17 12:33:08.362814+00	2026-06-17 12:33:08.362814+00	{"eTag": "\\"3a6445efa668c182001911549b2e8079\\"", "size": 2979, "mimetype": "image/jpeg", "cacheControl": "max-age=3600", "lastModified": "2026-06-17T12:33:09.000Z", "contentLength": 2979, "httpStatusCode": 200}	a2b907c1-1aa8-417d-8909-8c255521685b	\N	{}
0933ed2f-fcaa-409c-8ec1-b2f0f6476077	funcionarios	fotos/1781699771245.jpeg	\N	2026-06-17 12:36:11.540078+00	2026-06-17 12:36:11.540078+00	2026-06-17 12:36:11.540078+00	{"eTag": "\\"41881b9f5332b7945b73c5a4e6d1e8e4\\"", "size": 19482, "mimetype": "image/jpeg", "cacheControl": "max-age=3600", "lastModified": "2026-06-17T12:36:12.000Z", "contentLength": 19482, "httpStatusCode": 200}	17e54643-b106-4020-8d7d-1815543413d4	\N	{}
23bdde39-96c9-45cb-912e-d3cd234d5c30	alojamentos	laudos/1781785905178_RELATORIO_ESTRUTURAL_02.pdf	\N	2026-06-18 12:31:47.293156+00	2026-06-18 12:31:47.293156+00	2026-06-18 12:31:47.293156+00	{"eTag": "\\"ba152a865eafc1aa2d9a8d2e4c316314\\"", "size": 3168804, "mimetype": "application/pdf", "cacheControl": "max-age=3600", "lastModified": "2026-06-18T12:31:48.000Z", "contentLength": 3168804, "httpStatusCode": 200}	86aeb5f5-6744-4c40-b9f6-14703e435cef	\N	{}
ca23acdf-497d-43f3-a880-43bfd54c277b	funcionarios	fotos/1781699864209.jpg	\N	2026-06-17 12:37:44.487726+00	2026-06-17 12:37:44.487726+00	2026-06-17 12:37:44.487726+00	{"eTag": "\\"1e549bd53bbb7c932e51d0c27fc18552\\"", "size": 7216, "mimetype": "image/jpeg", "cacheControl": "max-age=3600", "lastModified": "2026-06-17T12:37:45.000Z", "contentLength": 7216, "httpStatusCode": 200}	c049a3a8-88bc-4283-b6e9-c817d5cb8a32	\N	{}
38a46073-0802-499b-8d60-9dc56ce773d7	funcionarios	fotos/1781716768819.png	\N	2026-06-17 17:19:29.484143+00	2026-06-17 17:19:29.484143+00	2026-06-17 17:19:29.484143+00	{"eTag": "\\"255b84b25ae3ae1bc19eef2a6a9eae03\\"", "size": 70985, "mimetype": "image/png", "cacheControl": "max-age=3600", "lastModified": "2026-06-17T17:19:30.000Z", "contentLength": 70985, "httpStatusCode": 200}	32138cab-9e2d-43f9-8ca0-111b1e204751	\N	{}
2a6f6ba3-82cf-4de8-893f-3511abca0c4a	alojamentos	fotos/1781785907641_FOTOS.zip	\N	2026-06-18 12:31:50.860938+00	2026-06-18 12:31:50.860938+00	2026-06-18 12:31:50.860938+00	{"eTag": "\\"0c021a040ed52b4654ed42df0ffa8a99\\"", "size": 5138001, "mimetype": "application/x-zip-compressed", "cacheControl": "max-age=3600", "lastModified": "2026-06-18T12:31:51.000Z", "contentLength": 5138001, "httpStatusCode": 200}	2a022eb2-16fa-4949-a034-50a35d641317	\N	{}
3d3c3f88-3d19-4e01-8cbf-caac1b327269	funcionarios	fotos/1781716824018.png	\N	2026-06-17 17:20:25.227664+00	2026-06-17 17:20:25.227664+00	2026-06-17 17:20:25.227664+00	{"eTag": "\\"204113576dd402d85caf83ff4bd5f695\\"", "size": 404152, "mimetype": "image/png", "cacheControl": "max-age=3600", "lastModified": "2026-06-17T17:20:26.000Z", "contentLength": 404152, "httpStatusCode": 200}	002ee3c8-d003-4373-93a6-de5a103374ca	\N	{}
d794b3a0-4b31-4fed-b526-3959509d70c1	funcionarios	fotos/1781716848305.png	\N	2026-06-17 17:20:49.994761+00	2026-06-17 17:20:49.994761+00	2026-06-17 17:20:49.994761+00	{"eTag": "\\"60473b8d669da1532148f99a101444c8\\"", "size": 256087, "mimetype": "image/png", "cacheControl": "max-age=3600", "lastModified": "2026-06-17T17:20:50.000Z", "contentLength": 256087, "httpStatusCode": 200}	dddb3415-cb44-4c92-93fb-0d05042aa0ac	\N	{}
ce149fa4-759f-4bef-b377-1bc0a928d837	funcionarios	fotos/1781866401336.jpeg	\N	2026-06-19 10:53:22.458859+00	2026-06-19 10:53:22.458859+00	2026-06-19 10:53:22.458859+00	{"eTag": "\\"9d323debdcb83f739ed61860f04d3375\\"", "size": 13871, "mimetype": "image/jpeg", "cacheControl": "max-age=3600", "lastModified": "2026-06-19T10:53:23.000Z", "contentLength": 13871, "httpStatusCode": 200}	44e73732-a9ee-4cfd-9737-621ccf9092a0	\N	{}
3e4ffe86-9b6f-49dc-a581-357c7b674517	funcionarios	fotos/1781716888194.png	\N	2026-06-17 17:21:28.480522+00	2026-06-17 17:21:28.480522+00	2026-06-17 17:21:28.480522+00	{"eTag": "\\"457436832210618c62e1bb46f2b2656a\\"", "size": 54733, "mimetype": "image/png", "cacheControl": "max-age=3600", "lastModified": "2026-06-17T17:21:29.000Z", "contentLength": 54733, "httpStatusCode": 200}	0f64d7b5-65ea-45f6-8ef8-946f7a82bc0d	\N	{}
65e88632-4af1-4feb-9499-ccc7e542433c	funcionarios	fotos/1781716921397.jpeg	\N	2026-06-17 17:22:02.524728+00	2026-06-17 17:22:02.524728+00	2026-06-17 17:22:02.524728+00	{"eTag": "\\"0da97c1e39d3d5de297887d5b9a9e1f7\\"", "size": 302066, "mimetype": "image/jpeg", "cacheControl": "max-age=3600", "lastModified": "2026-06-17T17:22:03.000Z", "contentLength": 302066, "httpStatusCode": 200}	8703f06f-c37c-4e4d-b049-7d1ec33a0066	\N	{}
184974c5-3682-47f6-9a25-c4e4cc6c1691	funcionarios	fotos/1781866403560.jpeg	\N	2026-06-19 10:53:23.958602+00	2026-06-19 10:53:23.958602+00	2026-06-19 10:53:23.958602+00	{"eTag": "\\"9d323debdcb83f739ed61860f04d3375\\"", "size": 13871, "mimetype": "image/jpeg", "cacheControl": "max-age=3600", "lastModified": "2026-06-19T10:53:24.000Z", "contentLength": 13871, "httpStatusCode": 200}	76b56d93-86e9-4bd3-aefd-cbea02414208	\N	{}
62cd96a5-1a46-4e83-98a2-dd43fb7b14e2	funcionarios	fotos/1781716950101.png	\N	2026-06-17 17:22:30.43335+00	2026-06-17 17:22:30.43335+00	2026-06-17 17:22:30.43335+00	{"eTag": "\\"9b5d2d7d163f01d11b8cca6b1b24651c\\"", "size": 32234, "mimetype": "image/png", "cacheControl": "max-age=3600", "lastModified": "2026-06-17T17:22:31.000Z", "contentLength": 32234, "httpStatusCode": 200}	0c7c0b43-f083-4c16-ae79-879578309063	\N	{}
36a926c1-5f3a-4e39-87d3-e6c2e2e63d9c	funcionarios	fotos/1781716984239.jpeg	\N	2026-06-17 17:23:04.550821+00	2026-06-17 17:23:04.550821+00	2026-06-17 17:23:04.550821+00	{"eTag": "\\"f709d0f3f3f5e425074d3a95f206454e\\"", "size": 29684, "mimetype": "image/jpeg", "cacheControl": "max-age=3600", "lastModified": "2026-06-17T17:23:05.000Z", "contentLength": 29684, "httpStatusCode": 200}	ad0aa373-6d84-423c-8ae4-0a4e521d1d48	\N	{}
a25478af-38d6-457e-b687-721cf4d547fd	funcionarios	fotos/1781717039496.png	\N	2026-06-17 17:24:04.374956+00	2026-06-17 17:24:04.374956+00	2026-06-17 17:24:04.374956+00	{"eTag": "\\"6a55305095cd8dd0191d64ab4b33bb89\\"", "size": 128491, "mimetype": "image/png", "cacheControl": "max-age=3600", "lastModified": "2026-06-17T17:24:05.000Z", "contentLength": 128491, "httpStatusCode": 200}	687dc473-0c0a-45e8-8a84-a36241ac568b	\N	{}
1bf8d291-b4e3-44ef-a4f5-3bc08c231989	funcionarios	fotos/1781717066824.jpeg	\N	2026-06-17 17:24:26.896248+00	2026-06-17 17:24:26.896248+00	2026-06-17 17:24:26.896248+00	{"eTag": "\\"9a86034eeeb14798adbb10c5b0e9face\\"", "size": 27717, "mimetype": "image/jpeg", "cacheControl": "max-age=3600", "lastModified": "2026-06-17T17:24:27.000Z", "contentLength": 27717, "httpStatusCode": 200}	da715249-29bf-47c9-9743-2a71bedfb12c	\N	{}
6c06cad7-6318-4187-87e5-17b862432945	funcionarios	fotos/1781717233724.png	\N	2026-06-17 17:27:14.335476+00	2026-06-17 17:27:14.335476+00	2026-06-17 17:27:14.335476+00	{"eTag": "\\"0f07b68d9c0b961f8eb9dd15a35500e2\\"", "size": 57065, "mimetype": "image/png", "cacheControl": "max-age=3600", "lastModified": "2026-06-17T17:27:15.000Z", "contentLength": 57065, "httpStatusCode": 200}	0c9ba086-5494-4381-bf24-3d124852107a	\N	{}
db741a65-6646-46a3-a135-5ef6108b00db	funcionarios	fotos/1781789122259.png	\N	2026-06-18 13:25:23.91948+00	2026-06-18 13:25:23.91948+00	2026-06-18 13:25:23.91948+00	{"eTag": "\\"a24101afa197ad1211591b4405eaf06b\\"", "size": 441573, "mimetype": "image/png", "cacheControl": "max-age=3600", "lastModified": "2026-06-18T13:25:24.000Z", "contentLength": 441573, "httpStatusCode": 200}	3dfcde95-19a8-4068-852c-1783444b8719	\N	{}
00b40bec-d7c5-41e8-9407-8110c9c94e71	funcionarios	fotos/1781717284237.png	\N	2026-06-17 17:28:05.499865+00	2026-06-17 17:28:05.499865+00	2026-06-17 17:28:05.499865+00	{"eTag": "\\"285b6c6e71966650947364ded5416277\\"", "size": 416772, "mimetype": "image/png", "cacheControl": "max-age=3600", "lastModified": "2026-06-17T17:28:06.000Z", "contentLength": 416772, "httpStatusCode": 200}	c3a10e92-42cc-481b-a41e-589800cfbb64	\N	{}
8c4c6b78-97ee-4ee6-acde-87179a753e31	funcionarios	fotos/1781717334697.jpeg	\N	2026-06-17 17:28:54.845683+00	2026-06-17 17:28:54.845683+00	2026-06-17 17:28:54.845683+00	{"eTag": "\\"7fd1e523aba9e9a8d1e3ea02d1a17907\\"", "size": 63014, "mimetype": "image/jpeg", "cacheControl": "max-age=3600", "lastModified": "2026-06-17T17:28:55.000Z", "contentLength": 63014, "httpStatusCode": 200}	fb7c438f-676f-4cf4-8daf-d30ce3b96f32	\N	{}
bd6ef791-7842-4390-9d72-e936a6b07432	alojamentos	laudos/1781789424205_LAUDO_DE_VISTORIA_DE_ENTRADA_-_ASSINADO.pdf	\N	2026-06-18 13:30:49.602746+00	2026-06-18 13:30:49.602746+00	2026-06-18 13:30:49.602746+00	{"eTag": "\\"b907070817ec2895d359081626d7fe12\\"", "size": 16250593, "mimetype": "application/pdf", "cacheControl": "max-age=3600", "lastModified": "2026-06-18T13:30:50.000Z", "contentLength": 16250593, "httpStatusCode": 200}	d87e498f-d22e-4d07-a4e1-72f5f210acdb	\N	{}
466e2ee0-eac2-41d3-b7d7-74cfa440db76	funcionarios	fotos/1781717384863.png	\N	2026-06-17 17:29:45.710509+00	2026-06-17 17:29:45.710509+00	2026-06-17 17:29:45.710509+00	{"eTag": "\\"a8ad88b01a172f147f1971bf5ff13a96\\"", "size": 147259, "mimetype": "image/png", "cacheControl": "max-age=3600", "lastModified": "2026-06-17T17:29:46.000Z", "contentLength": 147259, "httpStatusCode": 200}	a1f0feb0-b0e2-45dc-8efd-2e8e65062ac8	\N	{}
4701f034-3c2c-4d32-be8b-05719c4d7fa1	funcionarios	fotos/1781717444676.png	\N	2026-06-17 17:30:45.399754+00	2026-06-17 17:30:45.399754+00	2026-06-17 17:30:45.399754+00	{"eTag": "\\"26855f5e48967cd588703360190bf82b\\"", "size": 86696, "mimetype": "image/png", "cacheControl": "max-age=3600", "lastModified": "2026-06-17T17:30:46.000Z", "contentLength": 86696, "httpStatusCode": 200}	07706771-dfa2-497f-ae75-6b80675bb737	\N	{}
45f8497a-8895-43c4-b91a-394897e1dbaf	alojamentos	laudos/1781789439244_LAUDO_DE_VISTORIA_DE_ENTRADA_-_ASSINADO.pdf	\N	2026-06-18 13:30:59.56591+00	2026-06-18 13:30:59.56591+00	2026-06-18 13:30:59.56591+00	{"eTag": "\\"b907070817ec2895d359081626d7fe12\\"", "size": 16250593, "mimetype": "application/pdf", "cacheControl": "max-age=3600", "lastModified": "2026-06-18T13:31:00.000Z", "contentLength": 16250593, "httpStatusCode": 200}	1c401b43-6151-420a-ab63-b1c7dea261d7	\N	{}
71f6f853-d6a3-444d-abc0-ab0392b48071	funcionarios	fotos/1781717480962.jpg	\N	2026-06-17 17:31:21.094021+00	2026-06-17 17:31:21.094021+00	2026-06-17 17:31:21.094021+00	{"eTag": "\\"93871d524cc7de31424379e1e87b2c6c\\"", "size": 49722, "mimetype": "image/jpeg", "cacheControl": "max-age=3600", "lastModified": "2026-06-17T17:31:22.000Z", "contentLength": 49722, "httpStatusCode": 200}	ff8bf924-c879-4a18-bf30-f9cfac4e6b6e	\N	{}
fbf75397-c288-4e7e-be2d-42851a506adf	alojamentos	contratos/1781789562876_Contrato_Rua_Avelino_Beraldo_115_-_Vila_Monte_Alegre_-_Paulinia_-_Assinado.pdf	\N	2026-06-18 13:32:45.599538+00	2026-06-18 13:32:45.599538+00	2026-06-18 13:32:45.599538+00	{"eTag": "\\"d7bc384247ab30aa0f24bf464bde3589\\"", "size": 2222332, "mimetype": "application/pdf", "cacheControl": "max-age=3600", "lastModified": "2026-06-18T13:32:46.000Z", "contentLength": 2222332, "httpStatusCode": 200}	445e0665-017f-4371-b8da-2ae568ea5341	\N	{}
5a6dbd6a-dec9-4045-8ef0-ab7bacb8aef6	alojamentos	laudos/1781789565509_Vistoria_de_Entrada.pdf	\N	2026-06-18 13:32:48.320403+00	2026-06-18 13:32:48.320403+00	2026-06-18 13:32:48.320403+00	{"eTag": "\\"fec2a6c4f607b4ca359f94c4a9aea10d\\"", "size": 2124472, "mimetype": "application/pdf", "cacheControl": "max-age=3600", "lastModified": "2026-06-18T13:32:49.000Z", "contentLength": 2124472, "httpStatusCode": 200}	2e7d1aad-197b-4f04-b3ce-bae54a2fed4b	\N	{}
0b9ef8b4-99e7-4040-a65c-1e4005f20300	funcionarios	fotos/1781717084764.jpeg	\N	2026-06-17 17:24:46.734578+00	2026-06-17 17:24:46.734578+00	2026-06-17 17:24:46.734578+00	{"eTag": "\\"bb4d1f9d46e78245b61711ba17cd6de5\\"", "size": 244835, "mimetype": "image/jpeg", "cacheControl": "max-age=3600", "lastModified": "2026-06-17T17:24:47.000Z", "contentLength": 244835, "httpStatusCode": 200}	72e1f1f3-af5a-4891-96ec-3f5943786188	\N	{}
1288295a-672c-43a0-864a-63075d407621	alojamentos	fotos/1781789568234_ADM_31_-_01-2026_AVELINO_BERALDO,_115_-_supervisores.pdf	\N	2026-06-18 13:32:49.87988+00	2026-06-18 13:32:49.87988+00	2026-06-18 13:32:49.87988+00	{"eTag": "\\"eeac1171e1538e2923ff253f6921dda4\\"", "size": 1308143, "mimetype": "application/pdf", "cacheControl": "max-age=3600", "lastModified": "2026-06-18T13:32:50.000Z", "contentLength": 1308143, "httpStatusCode": 200}	e7139a0a-505b-412a-b993-4e5f3145d778	\N	{}
d46c3352-c816-4df3-be12-6be433e27475	funcionarios	fotos/1781717157467.png	\N	2026-06-17 17:25:59.051859+00	2026-06-17 17:25:59.051859+00	2026-06-17 17:25:59.051859+00	{"eTag": "\\"c359bd6fcb5ff63b390c3f1103db20c6\\"", "size": 551447, "mimetype": "image/png", "cacheControl": "max-age=3600", "lastModified": "2026-06-17T17:26:00.000Z", "contentLength": 551447, "httpStatusCode": 200}	6376dd51-db35-4ff5-8c9d-2f0259c7caf5	\N	{}
a5fa1768-49c1-481b-b481-a83508fea931	funcionarios	fotos/1781717214063.png	\N	2026-06-17 17:26:54.976788+00	2026-06-17 17:26:54.976788+00	2026-06-17 17:26:54.976788+00	{"eTag": "\\"1fb2e25bd45fce4fdd9d7da544e05ea1\\"", "size": 196722, "mimetype": "image/png", "cacheControl": "max-age=3600", "lastModified": "2026-06-17T17:26:55.000Z", "contentLength": 196722, "httpStatusCode": 200}	40fde796-8e43-40fb-ab74-3529f7a2d229	\N	{}
f3f2ba2b-2e6d-42ed-9f20-ab7d34254ff6	alojamentos	contratos/1781789731216_Contrato_Assinado_Rua_Italo_Bressanin_29_Bairro_Residencial_Serra_Azul.pdf	\N	2026-06-18 13:35:36.493002+00	2026-06-18 13:35:36.493002+00	2026-06-18 13:35:36.493002+00	{"eTag": "\\"038a350caf5336a2610e9301910f094e\\"", "size": 4232104, "mimetype": "application/pdf", "cacheControl": "max-age=3600", "lastModified": "2026-06-18T13:35:37.000Z", "contentLength": 4232104, "httpStatusCode": 200}	ba1e8c86-becc-46d9-b58a-092bdd59a1d2	\N	{}
06e1e4e3-0e95-475f-9208-24a1ac030b0d	funcionarios	fotos/1781717260352.png	\N	2026-06-17 17:27:40.637062+00	2026-06-17 17:27:40.637062+00	2026-06-17 17:27:40.637062+00	{"eTag": "\\"17b88219878c65f349a7af0d78bf127d\\"", "size": 61557, "mimetype": "image/png", "cacheControl": "max-age=3600", "lastModified": "2026-06-17T17:27:41.000Z", "contentLength": 61557, "httpStatusCode": 200}	5bb43f72-d833-4fe6-ad99-c5a5a0a33da0	\N	{}
35275d3b-f1fc-4bc6-9cd2-1a2ded4fd939	funcionarios	fotos/1781717307522.png	\N	2026-06-17 17:28:28.293532+00	2026-06-17 17:28:28.293532+00	2026-06-17 17:28:28.293532+00	{"eTag": "\\"577722a6b1f21077ab9e1ff9e492cd0b\\"", "size": 302876, "mimetype": "image/png", "cacheControl": "max-age=3600", "lastModified": "2026-06-17T17:28:29.000Z", "contentLength": 302876, "httpStatusCode": 200}	6cc79642-5c63-4a14-b53d-7d777aba6551	\N	{}
cc93426b-2f94-433d-80e6-56da389f00fc	alojamentos	contratos/1781789736290_Contrato_Assinado_Rua_Italo_Bressanin_29_Bairro_Residencial_Serra_Azul.pdf	\N	2026-06-18 13:35:43.318048+00	2026-06-18 13:35:43.318048+00	2026-06-18 13:35:43.318048+00	{"eTag": "\\"038a350caf5336a2610e9301910f094e\\"", "size": 4232104, "mimetype": "application/pdf", "cacheControl": "max-age=3600", "lastModified": "2026-06-18T13:35:44.000Z", "contentLength": 4232104, "httpStatusCode": 200}	1065b0af-6534-4448-85c2-38918d9a6d81	\N	{}
01cbaed5-2484-4cc7-9fed-64a01e207a53	funcionarios	fotos/1781717357869.png	\N	2026-06-17 17:29:18.758195+00	2026-06-17 17:29:18.758195+00	2026-06-17 17:29:18.758195+00	{"eTag": "\\"c28c6c5156d989991443b6e93fdfcc41\\"", "size": 275449, "mimetype": "image/png", "cacheControl": "max-age=3600", "lastModified": "2026-06-17T17:29:19.000Z", "contentLength": 275449, "httpStatusCode": 200}	848f9e05-89a5-4028-aac5-1cc66b882f04	\N	{}
44dc22d1-6504-49f1-b6d2-a6750a06c66f	funcionarios	fotos/1781717411466.png	\N	2026-06-17 17:30:13.216954+00	2026-06-17 17:30:13.216954+00	2026-06-17 17:30:13.216954+00	{"eTag": "\\"a421566054b690482f7c78d712d5c160\\"", "size": 797080, "mimetype": "image/png", "cacheControl": "max-age=3600", "lastModified": "2026-06-17T17:30:14.000Z", "contentLength": 797080, "httpStatusCode": 200}	6a3588d6-a940-4aff-89a6-fad539e26625	\N	{}
143f3b87-2cc5-4dd8-a9f4-d5717f494b40	funcionarios	fotos/1781717462820.png	\N	2026-06-17 17:31:03.12743+00	2026-06-17 17:31:03.12743+00	2026-06-17 17:31:03.12743+00	{"eTag": "\\"921205b7691dcb25d950a6a838fc966a\\"", "size": 227630, "mimetype": "image/png", "cacheControl": "max-age=3600", "lastModified": "2026-06-17T17:31:04.000Z", "contentLength": 227630, "httpStatusCode": 200}	e24fca61-ed74-400c-a195-80006b94f7f6	\N	{}
0e449e1c-df50-4eac-86ff-18f434514d34	funcionarios	fotos/1781717504033.png	\N	2026-06-17 17:31:44.256757+00	2026-06-17 17:31:44.256757+00	2026-06-17 17:31:44.256757+00	{"eTag": "\\"a35d6f8eb8169c18dc76b65557ee2f05\\"", "size": 66104, "mimetype": "image/png", "cacheControl": "max-age=3600", "lastModified": "2026-06-17T17:31:45.000Z", "contentLength": 66104, "httpStatusCode": 200}	245bcf51-71b2-4988-b229-c2a389e70c5b	\N	{}
cc3f57c1-73f8-41e8-a56b-8e8741906124	funcionarios	fotos/1781717605704.png	\N	2026-06-17 17:33:26.072347+00	2026-06-17 17:33:26.072347+00	2026-06-17 17:33:26.072347+00	{"eTag": "\\"ea8e2431c2ba28e7e8d722ef86ae850f\\"", "size": 316006, "mimetype": "image/png", "cacheControl": "max-age=3600", "lastModified": "2026-06-17T17:33:27.000Z", "contentLength": 316006, "httpStatusCode": 200}	8422b688-100a-4a5e-8879-50e8ac0ea565	\N	{}
8197baf3-8cdc-4025-b964-9c33b2f6e155	funcionarios	fotos/1781717627830.png	\N	2026-06-17 17:33:48.599262+00	2026-06-17 17:33:48.599262+00	2026-06-17 17:33:48.599262+00	{"eTag": "\\"91baaceb8e2c11f048110b30da5b5136\\"", "size": 326042, "mimetype": "image/png", "cacheControl": "max-age=3600", "lastModified": "2026-06-17T17:33:49.000Z", "contentLength": 326042, "httpStatusCode": 200}	db83febb-4ef6-4ae7-8fc4-d1b0ddbdab07	\N	{}
8ab518a4-b8a8-478e-9601-2f4c3b48364d	funcionarios	fotos/1781717648784.png	\N	2026-06-17 17:34:09.404186+00	2026-06-17 17:34:09.404186+00	2026-06-17 17:34:09.404186+00	{"eTag": "\\"0f8192b2806c70139f9d777e5fc0a33b\\"", "size": 316983, "mimetype": "image/png", "cacheControl": "max-age=3600", "lastModified": "2026-06-17T17:34:10.000Z", "contentLength": 316983, "httpStatusCode": 200}	7404d949-45cf-48d0-b045-1462bd656d64	\N	{}
c8fc4d28-fb0c-4573-951a-3954579a4590	alojamentos	laudos/1781789736676_LAUDO_DE_VISTORIA_DE_ENTRADA_-_ASSINADO.pdf	\N	2026-06-18 13:35:57.011823+00	2026-06-18 13:35:57.011823+00	2026-06-18 13:35:57.011823+00	{"eTag": "\\"c887b9ab11fc9f0392ead57285641984\\"", "size": 11257542, "mimetype": "application/pdf", "cacheControl": "max-age=3600", "lastModified": "2026-06-18T13:35:57.000Z", "contentLength": 11257542, "httpStatusCode": 200}	5e8ab706-2dd0-4689-a216-3253dd47c195	\N	{}
027c53cf-2628-4709-b556-52731e57cd23	funcionarios	fotos/1781717685750.jpeg	\N	2026-06-17 17:34:45.87465+00	2026-06-17 17:34:45.87465+00	2026-06-17 17:34:45.87465+00	{"eTag": "\\"440d78ff5520d3197a1e49b119728918\\"", "size": 30219, "mimetype": "image/jpeg", "cacheControl": "max-age=3600", "lastModified": "2026-06-17T17:34:46.000Z", "contentLength": 30219, "httpStatusCode": 200}	a06ba442-7695-4f73-9f2c-693001e19c9e	\N	{}
ec986e38-9a14-4d39-ac59-a1054e1471b0	funcionarios	fotos/1781717789495.png	\N	2026-06-17 17:36:29.889+00	2026-06-17 17:36:29.889+00	2026-06-17 17:36:29.889+00	{"eTag": "\\"6a76ae5fc08484f6c5b21e27a3e8662c\\"", "size": 191206, "mimetype": "image/png", "cacheControl": "max-age=3600", "lastModified": "2026-06-17T17:36:30.000Z", "contentLength": 191206, "httpStatusCode": 200}	5b632b7f-a6cf-4242-a575-f32a7df46630	\N	{}
1e821ace-82b6-426b-adcd-49956afe5999	funcionarios	fotos/1781717829139.png	\N	2026-06-17 17:37:09.920335+00	2026-06-17 17:37:09.920335+00	2026-06-17 17:37:09.920335+00	{"eTag": "\\"f272d7a21d49048b014445e1b588f4a6\\"", "size": 164871, "mimetype": "image/png", "cacheControl": "max-age=3600", "lastModified": "2026-06-17T17:37:10.000Z", "contentLength": 164871, "httpStatusCode": 200}	ed1b2ceb-99b0-4e11-9440-7d5f7a270a94	\N	{}
1cbb8223-50ed-4a6c-ba5c-6a56d531544d	alojamentos	fotos/1781789757321_ADM_31_-_02-2026_-_SERRA_AZUL.pdf	\N	2026-06-18 13:36:01.184767+00	2026-06-18 13:36:01.184767+00	2026-06-18 13:36:01.184767+00	{"eTag": "\\"d2363db85c57ee5763c19cc11b17e7cd\\"", "size": 1178086, "mimetype": "application/pdf", "cacheControl": "max-age=3600", "lastModified": "2026-06-18T13:36:02.000Z", "contentLength": 1178086, "httpStatusCode": 200}	16578f43-8354-486e-8109-374cce31c4da	\N	{}
fec3abfc-7c78-4af6-bd96-dec2f5f1a92d	funcionarios	fotos/1781717889359.jpeg	\N	2026-06-17 17:38:09.921448+00	2026-06-17 17:38:09.921448+00	2026-06-17 17:38:09.921448+00	{"eTag": "\\"7278aa6b07a6e770d3b5faecb9d4adbd\\"", "size": 19133, "mimetype": "image/jpeg", "cacheControl": "max-age=3600", "lastModified": "2026-06-17T17:38:10.000Z", "contentLength": 19133, "httpStatusCode": 200}	fc440736-ec4e-4e11-b242-e9f87be5ffcf	\N	{}
eae591d0-05c8-4eff-9605-1eab428613d6	alojamentos	laudos/1781789743484_LAUDO_DE_VISTORIA_DE_ENTRADA_-_ASSINADO.pdf	\N	2026-06-18 13:36:01.399823+00	2026-06-18 13:36:01.399823+00	2026-06-18 13:36:01.399823+00	{"eTag": "\\"c887b9ab11fc9f0392ead57285641984\\"", "size": 11257542, "mimetype": "application/pdf", "cacheControl": "max-age=3600", "lastModified": "2026-06-18T13:36:02.000Z", "contentLength": 11257542, "httpStatusCode": 200}	949c7f62-1a10-4b3a-bad1-b2dccff2b0ce	\N	{}
5aa4180b-9735-4c18-8b07-48aa8537f265	funcionarios	fotos/1781717949717.png	\N	2026-06-17 17:39:12.291438+00	2026-06-17 17:39:12.291438+00	2026-06-17 17:39:12.291438+00	{"eTag": "\\"3c1443709f44d13d8f6028d2656b359c\\"", "size": 79696, "mimetype": "image/png", "cacheControl": "max-age=3600", "lastModified": "2026-06-17T17:39:13.000Z", "contentLength": 79696, "httpStatusCode": 200}	8b5584e6-9f8e-4e19-8e35-aea163e424af	\N	{}
84f2bad6-5eac-4e30-8185-c3ea37562655	alojamentos	fotos/1781789761414_ADM_31_-_02-2026_-_SERRA_AZUL.pdf	\N	2026-06-18 13:36:03.386597+00	2026-06-18 13:36:03.386597+00	2026-06-18 13:36:03.386597+00	{"eTag": "\\"d2363db85c57ee5763c19cc11b17e7cd\\"", "size": 1178086, "mimetype": "application/pdf", "cacheControl": "max-age=3600", "lastModified": "2026-06-18T13:36:04.000Z", "contentLength": 1178086, "httpStatusCode": 200}	ca95a1e4-11f6-4d4f-bb45-b33ec584050e	\N	{}
779d6d78-81aa-4160-b232-7ef6e3f8e877	alojamentos	laudos/1781790108558_Laudo_de_Vistoria_Inicial.pdf	\N	2026-06-18 13:41:55.582284+00	2026-06-18 13:41:55.582284+00	2026-06-18 13:41:55.582284+00	{"eTag": "\\"2c6fc8ecbdd1df1e6518b6523aa6431a\\"", "size": 582223, "mimetype": "application/pdf", "cacheControl": "max-age=3600", "lastModified": "2026-06-18T13:41:56.000Z", "contentLength": 582223, "httpStatusCode": 200}	d6ff315a-a932-4994-a78d-51926e66cbab	\N	{}
3431765a-f61b-486b-806b-7b53431d70bd	alojamentos	fotos/1781790115749_ADM_31_-_03-2026_BRISA_DA_MATA_APTO.pdf	\N	2026-06-18 13:41:58.436791+00	2026-06-18 13:41:58.436791+00	2026-06-18 13:41:58.436791+00	{"eTag": "\\"73f3d1a6cfe3d127ad30e5888a857bc6\\"", "size": 623091, "mimetype": "application/pdf", "cacheControl": "max-age=3600", "lastModified": "2026-06-18T13:41:59.000Z", "contentLength": 623091, "httpStatusCode": 200}	413ed1b5-8851-4b02-90e5-c6a48f89944f	\N	{}
ce9bdc64-787c-4a9b-af2d-a80c3d8fbee0	funcionarios	fotos/1781717665910.png	\N	2026-06-17 17:34:26.178137+00	2026-06-17 17:34:26.178137+00	2026-06-17 17:34:26.178137+00	{"eTag": "\\"5717ff0fd16371215d27418207aef5be\\"", "size": 74169, "mimetype": "image/png", "cacheControl": "max-age=3600", "lastModified": "2026-06-17T17:34:27.000Z", "contentLength": 74169, "httpStatusCode": 200}	980c942f-31cc-4150-bba0-5121ea4d3651	\N	{}
51035a20-296b-47c7-b767-bc3be8c4e894	alojamentos	laudos/1781790116808_Laudo_de_Vistoria_Inicial.pdf	\N	2026-06-18 13:42:00.419268+00	2026-06-18 13:42:00.419268+00	2026-06-18 13:42:00.419268+00	{"eTag": "\\"2c6fc8ecbdd1df1e6518b6523aa6431a\\"", "size": 582223, "mimetype": "application/pdf", "cacheControl": "max-age=3600", "lastModified": "2026-06-18T13:42:01.000Z", "contentLength": 582223, "httpStatusCode": 200}	2675624f-6ad9-48a1-8bdd-80411fa26baa	\N	{}
2ad4853b-ec22-415c-b653-413caea00ec8	funcionarios	fotos/1781717706932.png	\N	2026-06-17 17:35:08.27043+00	2026-06-17 17:35:08.27043+00	2026-06-17 17:35:08.27043+00	{"eTag": "\\"bd39dff7ab09cb09663a7765cb12c657\\"", "size": 945453, "mimetype": "image/png", "cacheControl": "max-age=3600", "lastModified": "2026-06-17T17:35:09.000Z", "contentLength": 945453, "httpStatusCode": 200}	ce4f746f-dad4-4937-a1f1-ca135ffa54dc	\N	{}
70a8d33d-3181-493f-bde4-45c54e565f07	funcionarios	fotos/1781866804285.jpg	\N	2026-06-19 11:00:06.395842+00	2026-06-19 11:00:06.395842+00	2026-06-19 11:00:06.395842+00	{"eTag": "\\"7764d5df738c7aeaef750b6f246e6b6d\\"", "size": 85953, "mimetype": "image/jpeg", "cacheControl": "max-age=3600", "lastModified": "2026-06-19T11:00:07.000Z", "contentLength": 85953, "httpStatusCode": 200}	a341ccf1-0ae9-4bc8-a199-e869a871ee9e	\N	{}
a9d1b5ab-da48-41b7-abdc-d82f34b1fda3	funcionarios	fotos/1781717766418.png	\N	2026-06-17 17:36:07.24569+00	2026-06-17 17:36:07.24569+00	2026-06-17 17:36:07.24569+00	{"eTag": "\\"313b83f868d2558fa2877202e31fb612\\"", "size": 447575, "mimetype": "image/png", "cacheControl": "max-age=3600", "lastModified": "2026-06-17T17:36:08.000Z", "contentLength": 447575, "httpStatusCode": 200}	37d8e36e-c9df-458b-99de-7f9c880b99a8	\N	{}
4c821c08-fc52-490b-a63d-e2a64332a0af	funcionarios	fotos/1781717810301.png	\N	2026-06-17 17:36:50.63664+00	2026-06-17 17:36:50.63664+00	2026-06-17 17:36:50.63664+00	{"eTag": "\\"7d0689300cf73ef2b73a0da6864fd1f8\\"", "size": 205404, "mimetype": "image/png", "cacheControl": "max-age=3600", "lastModified": "2026-06-17T17:36:51.000Z", "contentLength": 205404, "httpStatusCode": 200}	34fdd6ca-415e-4968-a12a-d4e7c36575aa	\N	{}
e93cea72-074c-4ba6-82b2-be83bf8d096b	funcionarios	fotos/1781866805632.jpg	\N	2026-06-19 11:00:07.038362+00	2026-06-19 11:00:07.038362+00	2026-06-19 11:00:07.038362+00	{"eTag": "\\"7764d5df738c7aeaef750b6f246e6b6d\\"", "size": 85953, "mimetype": "image/jpeg", "cacheControl": "max-age=3600", "lastModified": "2026-06-19T11:00:08.000Z", "contentLength": 85953, "httpStatusCode": 200}	615aedae-90aa-47a4-af81-46e4f15a1f0f	\N	{}
3abcd3e1-37ab-4dc7-a8f6-da55028b5675	funcionarios	fotos/1781717859000.png	\N	2026-06-17 17:37:39.328467+00	2026-06-17 17:37:39.328467+00	2026-06-17 17:37:39.328467+00	{"eTag": "\\"cfc6d0f6b9f0bf9f61412675e4c5d1d6\\"", "size": 55116, "mimetype": "image/png", "cacheControl": "max-age=3600", "lastModified": "2026-06-17T17:37:40.000Z", "contentLength": 55116, "httpStatusCode": 200}	28f2a12a-1cbf-49eb-86c5-24ab3acabb94	\N	{}
973531b8-9168-41da-ab4a-399ef58af0b3	funcionarios	fotos/1781717911277.png	\N	2026-06-17 17:38:41.127078+00	2026-06-17 17:38:41.127078+00	2026-06-17 17:38:41.127078+00	{"eTag": "\\"d18527d0b2e51bd1a67068330d885aba\\"", "size": 347713, "mimetype": "image/png", "cacheControl": "max-age=3600", "lastModified": "2026-06-17T17:38:42.000Z", "contentLength": 347713, "httpStatusCode": 200}	33d2607e-794e-4482-8191-4640ebaa2b61	\N	{}
c43c3c52-b8c8-4f25-b644-da110e862e27	funcionarios	fotos/1781867095352.jpeg	\N	2026-06-19 11:04:56.87127+00	2026-06-19 11:04:56.87127+00	2026-06-19 11:04:56.87127+00	{"eTag": "\\"1ca1f4d9fe6f35ddc8ec60295c360df0\\"", "size": 204413, "mimetype": "image/jpeg", "cacheControl": "max-age=3600", "lastModified": "2026-06-19T11:04:57.000Z", "contentLength": 204413, "httpStatusCode": 200}	9aa62512-55eb-49fe-9e4e-6602c0c0c2a3	\N	{}
483af474-527b-4a4a-a1fb-91ed67a0ea90	funcionarios	fotos/1781717973720.png	\N	2026-06-17 17:39:34.155814+00	2026-06-17 17:39:34.155814+00	2026-06-17 17:39:34.155814+00	{"eTag": "\\"b066d79fb5a00fb0bfcc38edd39a3f2b\\"", "size": 57080, "mimetype": "image/png", "cacheControl": "max-age=3600", "lastModified": "2026-06-17T17:39:35.000Z", "contentLength": 57080, "httpStatusCode": 200}	ebbd0d69-13d1-4d71-9fe2-5b2c127c84a1	\N	{}
73f2c7be-8d29-4afc-b91a-3e0269e96385	funcionarios	fotos/1781867316721.jpeg	\N	2026-06-19 11:08:38.927019+00	2026-06-19 11:08:38.927019+00	2026-06-19 11:08:38.927019+00	{"eTag": "\\"51a447b089eb17bf67a1795a97d7fa69\\"", "size": 160428, "mimetype": "image/jpeg", "cacheControl": "max-age=3600", "lastModified": "2026-06-19T11:08:39.000Z", "contentLength": 160428, "httpStatusCode": 200}	469f0af1-e290-4bfd-80b9-435fba5d7bcf	\N	{}
7c7e66be-66ae-4bcd-8660-3f5058637126	funcionarios	fotos/1781868378528.jpeg	\N	2026-06-19 11:26:20.13781+00	2026-06-19 11:26:20.13781+00	2026-06-19 11:26:20.13781+00	{"eTag": "\\"41731c32e9e9e4af12bbf6f451f0963d\\"", "size": 110534, "mimetype": "image/jpeg", "cacheControl": "max-age=3600", "lastModified": "2026-06-19T11:26:20.000Z", "contentLength": 110534, "httpStatusCode": 200}	809f4beb-32a8-42c4-8933-5bf60a44a60f	\N	{}
f8ef22ec-fe6b-4559-bf49-f252c712b0b4	funcionarios	fotos/1781869676239.jpg	\N	2026-06-19 11:47:58.759405+00	2026-06-19 11:47:58.759405+00	2026-06-19 11:47:58.759405+00	{"eTag": "\\"78c908201d2b1fb3269c2c28d3473524\\"", "size": 1031302, "mimetype": "image/jpeg", "cacheControl": "max-age=3600", "lastModified": "2026-06-19T11:47:59.000Z", "contentLength": 1031302, "httpStatusCode": 200}	f5f7bb9b-a99f-489e-931e-01a807fa6d66	\N	{}
0af8b1b5-0292-4e5b-bb2e-0173e5194787	funcionarios	fotos/1781869679380.jpg	\N	2026-06-19 11:48:01.4288+00	2026-06-19 11:48:01.4288+00	2026-06-19 11:48:01.4288+00	{"eTag": "\\"78c908201d2b1fb3269c2c28d3473524\\"", "size": 1031302, "mimetype": "image/jpeg", "cacheControl": "max-age=3600", "lastModified": "2026-06-19T11:48:02.000Z", "contentLength": 1031302, "httpStatusCode": 200}	0ee551be-a689-47ab-bb03-b864fdf08dc2	\N	{}
d6d556fa-8859-4152-96c5-78dbd44e1dca	funcionarios	fotos/1781871038242.png	\N	2026-06-19 12:10:39.251763+00	2026-06-19 12:10:39.251763+00	2026-06-19 12:10:39.251763+00	{"eTag": "\\"7c28c7bc865d7f7b58eb52a0eb6f7b9a\\"", "size": 48196, "mimetype": "image/png", "cacheControl": "max-age=3600", "lastModified": "2026-06-19T12:10:40.000Z", "contentLength": 48196, "httpStatusCode": 200}	4717a947-f312-42f4-b9da-420fe36929b4	\N	{}
6ca371ba-62e6-4232-93f3-a4736ed22f11	funcionarios	fotos/1781871418674.jpg	\N	2026-06-19 12:16:59.539521+00	2026-06-19 12:16:59.539521+00	2026-06-19 12:16:59.539521+00	{"eTag": "\\"231408aefaf19b34c4b777e7f1eced17\\"", "size": 20988, "mimetype": "image/jpeg", "cacheControl": "max-age=3600", "lastModified": "2026-06-19T12:17:00.000Z", "contentLength": 20988, "httpStatusCode": 200}	be239729-9a79-49c0-b5f7-ae6393809f33	\N	{}
afb26cbd-1b4f-46c1-a3cd-c2879d87bbd3	funcionarios	fotos/1781871420138.jpg	\N	2026-06-19 12:17:00.415614+00	2026-06-19 12:17:00.415614+00	2026-06-19 12:17:00.415614+00	{"eTag": "\\"231408aefaf19b34c4b777e7f1eced17\\"", "size": 20988, "mimetype": "image/jpeg", "cacheControl": "max-age=3600", "lastModified": "2026-06-19T12:17:01.000Z", "contentLength": 20988, "httpStatusCode": 200}	7fd2b49e-b342-4a99-b64b-3afc9ceb5ccb	\N	{}
1815c3c3-787b-4f42-9379-5d806de952bc	funcionarios	fotos/1781871655434.png	\N	2026-06-19 12:20:56.210729+00	2026-06-19 12:20:56.210729+00	2026-06-19 12:20:56.210729+00	{"eTag": "\\"db1ae0134f757229ba9e11cf45db7d1f\\"", "size": 137451, "mimetype": "image/png", "cacheControl": "max-age=3600", "lastModified": "2026-06-19T12:20:57.000Z", "contentLength": 137451, "httpStatusCode": 200}	3b084ad1-ec06-4159-8ef7-944b2204261e	\N	{}
fefcb790-24aa-4615-a249-78c424f343c6	funcionarios	fotos/1781871803561.png	\N	2026-06-19 12:23:24.351626+00	2026-06-19 12:23:24.351626+00	2026-06-19 12:23:24.351626+00	{"eTag": "\\"5614b24ce7d5535d0c5f93481329093a\\"", "size": 27603, "mimetype": "image/png", "cacheControl": "max-age=3600", "lastModified": "2026-06-19T12:23:25.000Z", "contentLength": 27603, "httpStatusCode": 200}	e1e0b85e-19dc-4eb7-9f03-71d6d0c6561f	\N	{}
e550ff26-2b48-4c37-9768-9e55b78b7b68	funcionarios	fotos/1781872358722.jpeg	\N	2026-06-19 12:32:39.768393+00	2026-06-19 12:32:39.768393+00	2026-06-19 12:32:39.768393+00	{"eTag": "\\"8f229264e69b1dc7c7125365a14840d4\\"", "size": 91534, "mimetype": "image/jpeg", "cacheControl": "max-age=3600", "lastModified": "2026-06-19T12:32:40.000Z", "contentLength": 91534, "httpStatusCode": 200}	484b5b81-cca1-402c-88f0-6a33bc97c09f	\N	{}
96137f7d-6857-4288-9bef-7b83a0967e47	funcionarios	fotos/1781872847197.jpg	\N	2026-06-19 12:40:48.137524+00	2026-06-19 12:40:48.137524+00	2026-06-19 12:40:48.137524+00	{"eTag": "\\"b104b26eae4788a57c58317faea2734b\\"", "size": 13112, "mimetype": "image/jpeg", "cacheControl": "max-age=3600", "lastModified": "2026-06-19T12:40:49.000Z", "contentLength": 13112, "httpStatusCode": 200}	685ad989-d6aa-4359-93ae-8292d816aa8f	\N	{}
cfff4758-c889-46c2-8d36-424b98752074	funcionarios	fotos/1781873305606.png	\N	2026-06-19 12:48:27.184087+00	2026-06-19 12:48:27.184087+00	2026-06-19 12:48:27.184087+00	{"eTag": "\\"383d38298b55a4a5503f7535b4519708\\"", "size": 316082, "mimetype": "image/png", "cacheControl": "max-age=3600", "lastModified": "2026-06-19T12:48:28.000Z", "contentLength": 316082, "httpStatusCode": 200}	34827419-86a6-40c3-ac6d-bb32e521282b	\N	{}
331b080c-3924-44b8-9270-fb0fc592f63e	funcionarios	fotos/1781873984406.png	\N	2026-06-19 12:59:45.426694+00	2026-06-19 12:59:45.426694+00	2026-06-19 12:59:45.426694+00	{"eTag": "\\"1e6fc4a87f4fa402ad33d4352110aed9\\"", "size": 33604, "mimetype": "image/png", "cacheControl": "max-age=3600", "lastModified": "2026-06-19T12:59:46.000Z", "contentLength": 33604, "httpStatusCode": 200}	797e9ba1-6df8-44b7-a8fa-fa819463d13b	\N	{}
534dc931-3b56-4376-975d-571340ab7f77	funcionarios	fotos/1781874090797.png	\N	2026-06-19 13:01:31.695731+00	2026-06-19 13:01:31.695731+00	2026-06-19 13:01:31.695731+00	{"eTag": "\\"a9e3f08ffa2a5f131eb675e763882a59\\"", "size": 162991, "mimetype": "image/png", "cacheControl": "max-age=3600", "lastModified": "2026-06-19T13:01:32.000Z", "contentLength": 162991, "httpStatusCode": 200}	8b372bfa-afe2-45eb-a709-846b661e81f1	\N	{}
f22a95dd-ed0b-4fba-a4bb-4d0222e8d36f	funcionarios	fotos/1781875052389.jpg	\N	2026-06-19 13:17:33.382665+00	2026-06-19 13:17:33.382665+00	2026-06-19 13:17:33.382665+00	{"eTag": "\\"d337358c51bb44e04e1c9217407f4cda\\"", "size": 14195, "mimetype": "image/jpeg", "cacheControl": "max-age=3600", "lastModified": "2026-06-19T13:17:34.000Z", "contentLength": 14195, "httpStatusCode": 200}	221c9e48-24e7-4318-9430-61d810d5d2bf	\N	{}
bf492bf2-d96b-4d44-80cc-b96447fa6fb6	funcionarios	fotos/1781875054273.jpg	\N	2026-06-19 13:17:34.602623+00	2026-06-19 13:17:34.602623+00	2026-06-19 13:17:34.602623+00	{"eTag": "\\"d337358c51bb44e04e1c9217407f4cda\\"", "size": 14195, "mimetype": "image/jpeg", "cacheControl": "max-age=3600", "lastModified": "2026-06-19T13:17:35.000Z", "contentLength": 14195, "httpStatusCode": 200}	ab1062eb-7cab-4145-980f-6a3b2a1c7c29	\N	{}
bd0c0186-6b39-4499-abe6-6d105b3ca73f	funcionarios	fotos/1781875179601.jpg	\N	2026-06-19 13:19:40.186122+00	2026-06-19 13:19:40.186122+00	2026-06-19 13:19:40.186122+00	{"eTag": "\\"75598c3c0cb44c1b8e84ea8a86e64d1d\\"", "size": 59654, "mimetype": "image/jpeg", "cacheControl": "max-age=3600", "lastModified": "2026-06-19T13:19:41.000Z", "contentLength": 59654, "httpStatusCode": 200}	93c89c19-6d21-4af0-b4c7-d3623cf608c7	\N	{}
f7cea29a-86cc-4fa7-a035-5c54d8b1600c	funcionarios	fotos/1781875382426.png	\N	2026-06-19 13:23:03.440068+00	2026-06-19 13:23:03.440068+00	2026-06-19 13:23:03.440068+00	{"eTag": "\\"bbe82ff08e053e7a724af43f9b26e75c\\"", "size": 133986, "mimetype": "image/png", "cacheControl": "max-age=3600", "lastModified": "2026-06-19T13:23:04.000Z", "contentLength": 133986, "httpStatusCode": 200}	5fced484-38c9-49fa-9a96-134940a617ca	\N	{}
4f6e82e2-0d5b-422f-8bdd-068301c7aaeb	funcionarios	fotos/1781875750749.png	\N	2026-06-19 13:29:12.226712+00	2026-06-19 13:29:12.226712+00	2026-06-19 13:29:12.226712+00	{"eTag": "\\"97640e0f39bcd7633fe33199b8064506\\"", "size": 253078, "mimetype": "image/png", "cacheControl": "max-age=3600", "lastModified": "2026-06-19T13:29:13.000Z", "contentLength": 253078, "httpStatusCode": 200}	12c852f4-ffbc-4bd9-8014-0dd98d2e71c5	\N	{}
40639059-48be-424e-9d9d-ad86bdc0af21	funcionarios	fotos/1781875919497.jpg	\N	2026-06-19 13:32:00.807498+00	2026-06-19 13:32:00.807498+00	2026-06-19 13:32:00.807498+00	{"eTag": "\\"81d8a9a9e6761a8212f7fef19f4a1b29\\"", "size": 85195, "mimetype": "image/jpeg", "cacheControl": "max-age=3600", "lastModified": "2026-06-19T13:32:01.000Z", "contentLength": 85195, "httpStatusCode": 200}	7c63a75b-7bbe-409f-9820-dea6e697ae50	\N	{}
9367ef70-b1db-47e5-95bc-af8cfae8ff53	funcionarios	fotos/1781876030405.jpg	\N	2026-06-19 13:33:50.811874+00	2026-06-19 13:33:50.811874+00	2026-06-19 13:33:50.811874+00	{"eTag": "\\"b0760ec235f4851b957d9e407f46959f\\"", "size": 10074, "mimetype": "image/jpeg", "cacheControl": "max-age=3600", "lastModified": "2026-06-19T13:33:51.000Z", "contentLength": 10074, "httpStatusCode": 200}	e0df990b-4807-4680-83e1-d9c1d267525c	\N	{}
0e77cd08-3dce-4424-8a58-f69cb570a167	funcionarios	fotos/1781876192057.png	\N	2026-06-19 13:36:32.698761+00	2026-06-19 13:36:32.698761+00	2026-06-19 13:36:32.698761+00	{"eTag": "\\"57bee9509d2465df58248b9e8f11aa4c\\"", "size": 42734, "mimetype": "image/png", "cacheControl": "max-age=3600", "lastModified": "2026-06-19T13:36:33.000Z", "contentLength": 42734, "httpStatusCode": 200}	8d530739-5052-47df-aa9b-8b5a60921f7e	\N	{}
\.


--
-- Data for Name: s3_multipart_uploads; Type: TABLE DATA; Schema: storage; Owner: -
--

COPY storage.s3_multipart_uploads (id, in_progress_size, upload_signature, bucket_id, key, version, owner_id, created_at, user_metadata, metadata) FROM stdin;
\.


--
-- Data for Name: s3_multipart_uploads_parts; Type: TABLE DATA; Schema: storage; Owner: -
--

COPY storage.s3_multipart_uploads_parts (id, upload_id, size, part_number, bucket_id, key, etag, owner_id, version, created_at) FROM stdin;
\.


--
-- Data for Name: vector_indexes; Type: TABLE DATA; Schema: storage; Owner: -
--

COPY storage.vector_indexes (id, name, bucket_id, data_type, dimension, distance_metric, metadata_configuration, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: secrets; Type: TABLE DATA; Schema: vault; Owner: -
--

COPY vault.secrets (id, name, description, secret, key_id, nonce, created_at, updated_at) FROM stdin;
\.


--
-- Name: refresh_tokens_id_seq; Type: SEQUENCE SET; Schema: auth; Owner: -
--

SELECT pg_catalog.setval('auth.refresh_tokens_id_seq', 1, false);


--
-- Name: subscription_id_seq; Type: SEQUENCE SET; Schema: realtime; Owner: -
--

SELECT pg_catalog.setval('realtime.subscription_id_seq', 1, false);


--
-- Name: mfa_amr_claims amr_id_pk; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.mfa_amr_claims
    ADD CONSTRAINT amr_id_pk PRIMARY KEY (id);


--
-- Name: audit_log_entries audit_log_entries_pkey; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.audit_log_entries
    ADD CONSTRAINT audit_log_entries_pkey PRIMARY KEY (id);


--
-- Name: custom_oauth_providers custom_oauth_providers_identifier_key; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.custom_oauth_providers
    ADD CONSTRAINT custom_oauth_providers_identifier_key UNIQUE (identifier);


--
-- Name: custom_oauth_providers custom_oauth_providers_pkey; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.custom_oauth_providers
    ADD CONSTRAINT custom_oauth_providers_pkey PRIMARY KEY (id);


--
-- Name: flow_state flow_state_pkey; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.flow_state
    ADD CONSTRAINT flow_state_pkey PRIMARY KEY (id);


--
-- Name: identities identities_pkey; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.identities
    ADD CONSTRAINT identities_pkey PRIMARY KEY (id);


--
-- Name: identities identities_provider_id_provider_unique; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.identities
    ADD CONSTRAINT identities_provider_id_provider_unique UNIQUE (provider_id, provider);


--
-- Name: instances instances_pkey; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.instances
    ADD CONSTRAINT instances_pkey PRIMARY KEY (id);


--
-- Name: mfa_amr_claims mfa_amr_claims_session_id_authentication_method_pkey; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.mfa_amr_claims
    ADD CONSTRAINT mfa_amr_claims_session_id_authentication_method_pkey UNIQUE (session_id, authentication_method);


--
-- Name: mfa_challenges mfa_challenges_pkey; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.mfa_challenges
    ADD CONSTRAINT mfa_challenges_pkey PRIMARY KEY (id);


--
-- Name: mfa_factors mfa_factors_last_challenged_at_key; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.mfa_factors
    ADD CONSTRAINT mfa_factors_last_challenged_at_key UNIQUE (last_challenged_at);


--
-- Name: mfa_factors mfa_factors_pkey; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.mfa_factors
    ADD CONSTRAINT mfa_factors_pkey PRIMARY KEY (id);


--
-- Name: oauth_authorizations oauth_authorizations_authorization_code_key; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.oauth_authorizations
    ADD CONSTRAINT oauth_authorizations_authorization_code_key UNIQUE (authorization_code);


--
-- Name: oauth_authorizations oauth_authorizations_authorization_id_key; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.oauth_authorizations
    ADD CONSTRAINT oauth_authorizations_authorization_id_key UNIQUE (authorization_id);


--
-- Name: oauth_authorizations oauth_authorizations_pkey; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.oauth_authorizations
    ADD CONSTRAINT oauth_authorizations_pkey PRIMARY KEY (id);


--
-- Name: oauth_client_states oauth_client_states_pkey; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.oauth_client_states
    ADD CONSTRAINT oauth_client_states_pkey PRIMARY KEY (id);


--
-- Name: oauth_clients oauth_clients_pkey; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.oauth_clients
    ADD CONSTRAINT oauth_clients_pkey PRIMARY KEY (id);


--
-- Name: oauth_consents oauth_consents_pkey; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.oauth_consents
    ADD CONSTRAINT oauth_consents_pkey PRIMARY KEY (id);


--
-- Name: oauth_consents oauth_consents_user_client_unique; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.oauth_consents
    ADD CONSTRAINT oauth_consents_user_client_unique UNIQUE (user_id, client_id);


--
-- Name: one_time_tokens one_time_tokens_pkey; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.one_time_tokens
    ADD CONSTRAINT one_time_tokens_pkey PRIMARY KEY (id);


--
-- Name: refresh_tokens refresh_tokens_pkey; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.refresh_tokens
    ADD CONSTRAINT refresh_tokens_pkey PRIMARY KEY (id);


--
-- Name: refresh_tokens refresh_tokens_token_unique; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.refresh_tokens
    ADD CONSTRAINT refresh_tokens_token_unique UNIQUE (token);


--
-- Name: saml_providers saml_providers_entity_id_key; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.saml_providers
    ADD CONSTRAINT saml_providers_entity_id_key UNIQUE (entity_id);


--
-- Name: saml_providers saml_providers_pkey; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.saml_providers
    ADD CONSTRAINT saml_providers_pkey PRIMARY KEY (id);


--
-- Name: saml_relay_states saml_relay_states_pkey; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.saml_relay_states
    ADD CONSTRAINT saml_relay_states_pkey PRIMARY KEY (id);


--
-- Name: schema_migrations schema_migrations_pkey; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.schema_migrations
    ADD CONSTRAINT schema_migrations_pkey PRIMARY KEY (version);


--
-- Name: sessions sessions_pkey; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.sessions
    ADD CONSTRAINT sessions_pkey PRIMARY KEY (id);


--
-- Name: sso_domains sso_domains_pkey; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.sso_domains
    ADD CONSTRAINT sso_domains_pkey PRIMARY KEY (id);


--
-- Name: sso_providers sso_providers_pkey; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.sso_providers
    ADD CONSTRAINT sso_providers_pkey PRIMARY KEY (id);


--
-- Name: users users_phone_key; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.users
    ADD CONSTRAINT users_phone_key UNIQUE (phone);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: webauthn_challenges webauthn_challenges_pkey; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.webauthn_challenges
    ADD CONSTRAINT webauthn_challenges_pkey PRIMARY KEY (id);


--
-- Name: webauthn_credentials webauthn_credentials_pkey; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.webauthn_credentials
    ADD CONSTRAINT webauthn_credentials_pkey PRIMARY KEY (id);


--
-- Name: alojamentos_contas alojamentos_contas_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.alojamentos_contas
    ADD CONSTRAINT alojamentos_contas_pkey PRIMARY KEY (id);


--
-- Name: alojamentos alojamentos_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.alojamentos
    ADD CONSTRAINT alojamentos_pkey PRIMARY KEY (id);


--
-- Name: alojamentos_relatorios alojamentos_relatorios_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.alojamentos_relatorios
    ADD CONSTRAINT alojamentos_relatorios_pkey PRIMARY KEY (id);


--
-- Name: efetivo_he efetivo_he_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.efetivo_he
    ADD CONSTRAINT efetivo_he_pkey PRIMARY KEY (id);


--
-- Name: efetivo_horas efetivo_horas_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.efetivo_horas
    ADD CONSTRAINT efetivo_horas_pkey PRIMARY KEY (id);


--
-- Name: efetivo_presenca efetivo_presenca_data_cracha_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.efetivo_presenca
    ADD CONSTRAINT efetivo_presenca_data_cracha_key UNIQUE (data, cracha);


--
-- Name: efetivo_presenca efetivo_presenca_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.efetivo_presenca
    ADD CONSTRAINT efetivo_presenca_pkey PRIMARY KEY (id);


--
-- Name: empresas empresas_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.empresas
    ADD CONSTRAINT empresas_pkey PRIMARY KEY (id);


--
-- Name: ferias ferias_matricula_periodo_aquisitivo_inicio_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ferias
    ADD CONSTRAINT ferias_matricula_periodo_aquisitivo_inicio_key UNIQUE (matricula, periodo_aquisitivo_inicio);


--
-- Name: ferias ferias_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ferias
    ADD CONSTRAINT ferias_pkey PRIMARY KEY (id);


--
-- Name: folgas folgas_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.folgas
    ADD CONSTRAINT folgas_pkey PRIMARY KEY (id);


--
-- Name: funcionarios funcionarios_cpf_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.funcionarios
    ADD CONSTRAINT funcionarios_cpf_key UNIQUE (cpf);


--
-- Name: funcionarios funcionarios_matricula_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.funcionarios
    ADD CONSTRAINT funcionarios_matricula_key UNIQUE (matricula);


--
-- Name: funcionarios funcionarios_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.funcionarios
    ADD CONSTRAINT funcionarios_pkey PRIMARY KEY (id);


--
-- Name: funcoes funcoes_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.funcoes
    ADD CONSTRAINT funcoes_pkey PRIMARY KEY (id);


--
-- Name: obras obras_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.obras
    ADD CONSTRAINT obras_pkey PRIMARY KEY (id);


--
-- Name: prestadores prestadores_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.prestadores
    ADD CONSTRAINT prestadores_pkey PRIMARY KEY (id);


--
-- Name: prestadores_presenca prestadores_presenca_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.prestadores_presenca
    ADD CONSTRAINT prestadores_presenca_pkey PRIMARY KEY (id);


--
-- Name: prestadores_presenca prestadores_presenca_prestador_id_data_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.prestadores_presenca
    ADD CONSTRAINT prestadores_presenca_prestador_id_data_key UNIQUE (prestador_id, data);


--
-- Name: usuarios_acesso usuarios_acesso_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.usuarios_acesso
    ADD CONSTRAINT usuarios_acesso_pkey PRIMARY KEY (id);


--
-- Name: usuarios_acesso usuarios_acesso_usuario_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.usuarios_acesso
    ADD CONSTRAINT usuarios_acesso_usuario_key UNIQUE (usuario);


--
-- Name: messages messages_payload_exclusive; Type: CHECK CONSTRAINT; Schema: realtime; Owner: -
--

ALTER TABLE realtime.messages
    ADD CONSTRAINT messages_payload_exclusive CHECK (((payload IS NULL) OR (binary_payload IS NULL))) NOT VALID;


--
-- Name: messages messages_pkey; Type: CONSTRAINT; Schema: realtime; Owner: -
--

ALTER TABLE ONLY realtime.messages
    ADD CONSTRAINT messages_pkey PRIMARY KEY (id, inserted_at);


--
-- Name: subscription pk_subscription; Type: CONSTRAINT; Schema: realtime; Owner: -
--

ALTER TABLE ONLY realtime.subscription
    ADD CONSTRAINT pk_subscription PRIMARY KEY (id);


--
-- Name: schema_migrations schema_migrations_pkey; Type: CONSTRAINT; Schema: realtime; Owner: -
--

ALTER TABLE ONLY realtime.schema_migrations
    ADD CONSTRAINT schema_migrations_pkey PRIMARY KEY (version);


--
-- Name: buckets_analytics buckets_analytics_pkey; Type: CONSTRAINT; Schema: storage; Owner: -
--

ALTER TABLE ONLY storage.buckets_analytics
    ADD CONSTRAINT buckets_analytics_pkey PRIMARY KEY (id);


--
-- Name: buckets buckets_pkey; Type: CONSTRAINT; Schema: storage; Owner: -
--

ALTER TABLE ONLY storage.buckets
    ADD CONSTRAINT buckets_pkey PRIMARY KEY (id);


--
-- Name: buckets_vectors buckets_vectors_pkey; Type: CONSTRAINT; Schema: storage; Owner: -
--

ALTER TABLE ONLY storage.buckets_vectors
    ADD CONSTRAINT buckets_vectors_pkey PRIMARY KEY (id);


--
-- Name: migrations migrations_name_key; Type: CONSTRAINT; Schema: storage; Owner: -
--

ALTER TABLE ONLY storage.migrations
    ADD CONSTRAINT migrations_name_key UNIQUE (name);


--
-- Name: migrations migrations_pkey; Type: CONSTRAINT; Schema: storage; Owner: -
--

ALTER TABLE ONLY storage.migrations
    ADD CONSTRAINT migrations_pkey PRIMARY KEY (id);


--
-- Name: objects objects_pkey; Type: CONSTRAINT; Schema: storage; Owner: -
--

ALTER TABLE ONLY storage.objects
    ADD CONSTRAINT objects_pkey PRIMARY KEY (id);


--
-- Name: s3_multipart_uploads_parts s3_multipart_uploads_parts_pkey; Type: CONSTRAINT; Schema: storage; Owner: -
--

ALTER TABLE ONLY storage.s3_multipart_uploads_parts
    ADD CONSTRAINT s3_multipart_uploads_parts_pkey PRIMARY KEY (id);


--
-- Name: s3_multipart_uploads s3_multipart_uploads_pkey; Type: CONSTRAINT; Schema: storage; Owner: -
--

ALTER TABLE ONLY storage.s3_multipart_uploads
    ADD CONSTRAINT s3_multipart_uploads_pkey PRIMARY KEY (id);


--
-- Name: vector_indexes vector_indexes_pkey; Type: CONSTRAINT; Schema: storage; Owner: -
--

ALTER TABLE ONLY storage.vector_indexes
    ADD CONSTRAINT vector_indexes_pkey PRIMARY KEY (id);


--
-- Name: audit_logs_instance_id_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX audit_logs_instance_id_idx ON auth.audit_log_entries USING btree (instance_id);


--
-- Name: confirmation_token_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE UNIQUE INDEX confirmation_token_idx ON auth.users USING btree (confirmation_token) WHERE ((confirmation_token)::text !~ '^[0-9 ]*$'::text);


--
-- Name: custom_oauth_providers_created_at_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX custom_oauth_providers_created_at_idx ON auth.custom_oauth_providers USING btree (created_at);


--
-- Name: custom_oauth_providers_enabled_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX custom_oauth_providers_enabled_idx ON auth.custom_oauth_providers USING btree (enabled);


--
-- Name: custom_oauth_providers_identifier_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX custom_oauth_providers_identifier_idx ON auth.custom_oauth_providers USING btree (identifier);


--
-- Name: custom_oauth_providers_provider_type_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX custom_oauth_providers_provider_type_idx ON auth.custom_oauth_providers USING btree (provider_type);


--
-- Name: email_change_token_current_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE UNIQUE INDEX email_change_token_current_idx ON auth.users USING btree (email_change_token_current) WHERE ((email_change_token_current)::text !~ '^[0-9 ]*$'::text);


--
-- Name: email_change_token_new_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE UNIQUE INDEX email_change_token_new_idx ON auth.users USING btree (email_change_token_new) WHERE ((email_change_token_new)::text !~ '^[0-9 ]*$'::text);


--
-- Name: factor_id_created_at_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX factor_id_created_at_idx ON auth.mfa_factors USING btree (user_id, created_at);


--
-- Name: flow_state_created_at_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX flow_state_created_at_idx ON auth.flow_state USING btree (created_at DESC);


--
-- Name: identities_email_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX identities_email_idx ON auth.identities USING btree (email text_pattern_ops);


--
-- Name: INDEX identities_email_idx; Type: COMMENT; Schema: auth; Owner: -
--

COMMENT ON INDEX auth.identities_email_idx IS 'Auth: Ensures indexed queries on the email column';


--
-- Name: identities_user_id_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX identities_user_id_idx ON auth.identities USING btree (user_id);


--
-- Name: idx_auth_code; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX idx_auth_code ON auth.flow_state USING btree (auth_code);


--
-- Name: idx_oauth_client_states_created_at; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX idx_oauth_client_states_created_at ON auth.oauth_client_states USING btree (created_at);


--
-- Name: idx_user_id_auth_method; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX idx_user_id_auth_method ON auth.flow_state USING btree (user_id, authentication_method);


--
-- Name: idx_users_created_at_desc; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX idx_users_created_at_desc ON auth.users USING btree (created_at DESC);


--
-- Name: idx_users_email; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX idx_users_email ON auth.users USING btree (email);


--
-- Name: idx_users_last_sign_in_at_desc; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX idx_users_last_sign_in_at_desc ON auth.users USING btree (last_sign_in_at DESC);


--
-- Name: idx_users_name; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX idx_users_name ON auth.users USING btree (((raw_user_meta_data ->> 'name'::text))) WHERE ((raw_user_meta_data ->> 'name'::text) IS NOT NULL);


--
-- Name: mfa_challenge_created_at_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX mfa_challenge_created_at_idx ON auth.mfa_challenges USING btree (created_at DESC);


--
-- Name: mfa_factors_user_friendly_name_unique; Type: INDEX; Schema: auth; Owner: -
--

CREATE UNIQUE INDEX mfa_factors_user_friendly_name_unique ON auth.mfa_factors USING btree (friendly_name, user_id) WHERE (TRIM(BOTH FROM friendly_name) <> ''::text);


--
-- Name: mfa_factors_user_id_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX mfa_factors_user_id_idx ON auth.mfa_factors USING btree (user_id);


--
-- Name: oauth_auth_pending_exp_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX oauth_auth_pending_exp_idx ON auth.oauth_authorizations USING btree (expires_at) WHERE (status = 'pending'::auth.oauth_authorization_status);


--
-- Name: oauth_clients_deleted_at_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX oauth_clients_deleted_at_idx ON auth.oauth_clients USING btree (deleted_at);


--
-- Name: oauth_consents_active_client_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX oauth_consents_active_client_idx ON auth.oauth_consents USING btree (client_id) WHERE (revoked_at IS NULL);


--
-- Name: oauth_consents_active_user_client_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX oauth_consents_active_user_client_idx ON auth.oauth_consents USING btree (user_id, client_id) WHERE (revoked_at IS NULL);


--
-- Name: oauth_consents_user_order_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX oauth_consents_user_order_idx ON auth.oauth_consents USING btree (user_id, granted_at DESC);


--
-- Name: one_time_tokens_relates_to_hash_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX one_time_tokens_relates_to_hash_idx ON auth.one_time_tokens USING hash (relates_to);


--
-- Name: one_time_tokens_token_hash_hash_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX one_time_tokens_token_hash_hash_idx ON auth.one_time_tokens USING hash (token_hash);


--
-- Name: one_time_tokens_user_id_token_type_key; Type: INDEX; Schema: auth; Owner: -
--

CREATE UNIQUE INDEX one_time_tokens_user_id_token_type_key ON auth.one_time_tokens USING btree (user_id, token_type);


--
-- Name: reauthentication_token_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE UNIQUE INDEX reauthentication_token_idx ON auth.users USING btree (reauthentication_token) WHERE ((reauthentication_token)::text !~ '^[0-9 ]*$'::text);


--
-- Name: recovery_token_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE UNIQUE INDEX recovery_token_idx ON auth.users USING btree (recovery_token) WHERE ((recovery_token)::text !~ '^[0-9 ]*$'::text);


--
-- Name: refresh_tokens_instance_id_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX refresh_tokens_instance_id_idx ON auth.refresh_tokens USING btree (instance_id);


--
-- Name: refresh_tokens_instance_id_user_id_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX refresh_tokens_instance_id_user_id_idx ON auth.refresh_tokens USING btree (instance_id, user_id);


--
-- Name: refresh_tokens_parent_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX refresh_tokens_parent_idx ON auth.refresh_tokens USING btree (parent);


--
-- Name: refresh_tokens_session_id_revoked_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX refresh_tokens_session_id_revoked_idx ON auth.refresh_tokens USING btree (session_id, revoked);


--
-- Name: refresh_tokens_updated_at_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX refresh_tokens_updated_at_idx ON auth.refresh_tokens USING btree (updated_at DESC);


--
-- Name: saml_providers_sso_provider_id_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX saml_providers_sso_provider_id_idx ON auth.saml_providers USING btree (sso_provider_id);


--
-- Name: saml_relay_states_created_at_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX saml_relay_states_created_at_idx ON auth.saml_relay_states USING btree (created_at DESC);


--
-- Name: saml_relay_states_for_email_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX saml_relay_states_for_email_idx ON auth.saml_relay_states USING btree (for_email);


--
-- Name: saml_relay_states_sso_provider_id_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX saml_relay_states_sso_provider_id_idx ON auth.saml_relay_states USING btree (sso_provider_id);


--
-- Name: sessions_not_after_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX sessions_not_after_idx ON auth.sessions USING btree (not_after DESC);


--
-- Name: sessions_oauth_client_id_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX sessions_oauth_client_id_idx ON auth.sessions USING btree (oauth_client_id);


--
-- Name: sessions_user_id_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX sessions_user_id_idx ON auth.sessions USING btree (user_id);


--
-- Name: sso_domains_domain_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE UNIQUE INDEX sso_domains_domain_idx ON auth.sso_domains USING btree (lower(domain));


--
-- Name: sso_domains_sso_provider_id_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX sso_domains_sso_provider_id_idx ON auth.sso_domains USING btree (sso_provider_id);


--
-- Name: sso_providers_resource_id_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE UNIQUE INDEX sso_providers_resource_id_idx ON auth.sso_providers USING btree (lower(resource_id));


--
-- Name: sso_providers_resource_id_pattern_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX sso_providers_resource_id_pattern_idx ON auth.sso_providers USING btree (resource_id text_pattern_ops);


--
-- Name: unique_phone_factor_per_user; Type: INDEX; Schema: auth; Owner: -
--

CREATE UNIQUE INDEX unique_phone_factor_per_user ON auth.mfa_factors USING btree (user_id, phone);


--
-- Name: user_id_created_at_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX user_id_created_at_idx ON auth.sessions USING btree (user_id, created_at);


--
-- Name: users_email_partial_key; Type: INDEX; Schema: auth; Owner: -
--

CREATE UNIQUE INDEX users_email_partial_key ON auth.users USING btree (email) WHERE (is_sso_user = false);


--
-- Name: INDEX users_email_partial_key; Type: COMMENT; Schema: auth; Owner: -
--

COMMENT ON INDEX auth.users_email_partial_key IS 'Auth: A partial unique index that applies only when is_sso_user is false';


--
-- Name: users_instance_id_email_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX users_instance_id_email_idx ON auth.users USING btree (instance_id, lower((email)::text));


--
-- Name: users_instance_id_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX users_instance_id_idx ON auth.users USING btree (instance_id);


--
-- Name: users_is_anonymous_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX users_is_anonymous_idx ON auth.users USING btree (is_anonymous);


--
-- Name: webauthn_challenges_expires_at_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX webauthn_challenges_expires_at_idx ON auth.webauthn_challenges USING btree (expires_at);


--
-- Name: webauthn_challenges_user_id_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX webauthn_challenges_user_id_idx ON auth.webauthn_challenges USING btree (user_id);


--
-- Name: webauthn_credentials_credential_id_key; Type: INDEX; Schema: auth; Owner: -
--

CREATE UNIQUE INDEX webauthn_credentials_credential_id_key ON auth.webauthn_credentials USING btree (credential_id);


--
-- Name: webauthn_credentials_user_id_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX webauthn_credentials_user_id_idx ON auth.webauthn_credentials USING btree (user_id);


--
-- Name: idx_aloj_contas_aloj; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_aloj_contas_aloj ON public.alojamentos_contas USING btree (alojamento_id);


--
-- Name: idx_efetivo_cracha; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_efetivo_cracha ON public.efetivo_presenca USING btree (cracha);


--
-- Name: idx_efetivo_data; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_efetivo_data ON public.efetivo_presenca USING btree (data);


--
-- Name: idx_efetivo_horas_data; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_efetivo_horas_data ON public.efetivo_horas USING btree (data);


--
-- Name: idx_efetivo_horas_mat; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_efetivo_horas_mat ON public.efetivo_horas USING btree (matricula);


--
-- Name: idx_func_alojamento; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_func_alojamento ON public.funcionarios USING btree (alojamento_id);


--
-- Name: ix_realtime_subscription_entity; Type: INDEX; Schema: realtime; Owner: -
--

CREATE INDEX ix_realtime_subscription_entity ON realtime.subscription USING btree (entity);


--
-- Name: messages_inserted_at_topic_index; Type: INDEX; Schema: realtime; Owner: -
--

CREATE INDEX messages_inserted_at_topic_index ON ONLY realtime.messages USING btree (inserted_at DESC, topic) WHERE ((extension = 'broadcast'::text) AND (private IS TRUE));


--
-- Name: subscription_subscription_id_entity_filters_action_filter_selec; Type: INDEX; Schema: realtime; Owner: -
--

CREATE UNIQUE INDEX subscription_subscription_id_entity_filters_action_filter_selec ON realtime.subscription USING btree (subscription_id, entity, filters, action_filter, COALESCE(selected_columns, '{}'::text[]));


--
-- Name: bname; Type: INDEX; Schema: storage; Owner: -
--

CREATE UNIQUE INDEX bname ON storage.buckets USING btree (name);


--
-- Name: bucketid_objname; Type: INDEX; Schema: storage; Owner: -
--

CREATE UNIQUE INDEX bucketid_objname ON storage.objects USING btree (bucket_id, name);


--
-- Name: buckets_analytics_unique_name_idx; Type: INDEX; Schema: storage; Owner: -
--

CREATE UNIQUE INDEX buckets_analytics_unique_name_idx ON storage.buckets_analytics USING btree (name) WHERE (deleted_at IS NULL);


--
-- Name: idx_multipart_uploads_list; Type: INDEX; Schema: storage; Owner: -
--

CREATE INDEX idx_multipart_uploads_list ON storage.s3_multipart_uploads USING btree (bucket_id, key, created_at);


--
-- Name: idx_objects_bucket_id_name; Type: INDEX; Schema: storage; Owner: -
--

CREATE INDEX idx_objects_bucket_id_name ON storage.objects USING btree (bucket_id, name COLLATE "C");


--
-- Name: idx_objects_bucket_id_name_lower; Type: INDEX; Schema: storage; Owner: -
--

CREATE INDEX idx_objects_bucket_id_name_lower ON storage.objects USING btree (bucket_id, lower(name) COLLATE "C");


--
-- Name: name_prefix_search; Type: INDEX; Schema: storage; Owner: -
--

CREATE INDEX name_prefix_search ON storage.objects USING btree (name text_pattern_ops);


--
-- Name: vector_indexes_name_bucket_id_idx; Type: INDEX; Schema: storage; Owner: -
--

CREATE UNIQUE INDEX vector_indexes_name_bucket_id_idx ON storage.vector_indexes USING btree (name, bucket_id);


--
-- Name: subscription tr_check_filters; Type: TRIGGER; Schema: realtime; Owner: -
--

CREATE TRIGGER tr_check_filters BEFORE INSERT OR UPDATE ON realtime.subscription FOR EACH ROW EXECUTE FUNCTION realtime.subscription_check_filters();


--
-- Name: buckets enforce_bucket_name_length_trigger; Type: TRIGGER; Schema: storage; Owner: -
--

CREATE TRIGGER enforce_bucket_name_length_trigger BEFORE INSERT OR UPDATE OF name ON storage.buckets FOR EACH ROW EXECUTE FUNCTION storage.enforce_bucket_name_length();


--
-- Name: buckets protect_buckets_delete; Type: TRIGGER; Schema: storage; Owner: -
--

CREATE TRIGGER protect_buckets_delete BEFORE DELETE ON storage.buckets FOR EACH STATEMENT EXECUTE FUNCTION storage.protect_delete();


--
-- Name: objects protect_objects_delete; Type: TRIGGER; Schema: storage; Owner: -
--

CREATE TRIGGER protect_objects_delete BEFORE DELETE ON storage.objects FOR EACH STATEMENT EXECUTE FUNCTION storage.protect_delete();


--
-- Name: objects update_objects_updated_at; Type: TRIGGER; Schema: storage; Owner: -
--

CREATE TRIGGER update_objects_updated_at BEFORE UPDATE ON storage.objects FOR EACH ROW EXECUTE FUNCTION storage.update_updated_at_column();


--
-- Name: identities identities_user_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.identities
    ADD CONSTRAINT identities_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE;


--
-- Name: mfa_amr_claims mfa_amr_claims_session_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.mfa_amr_claims
    ADD CONSTRAINT mfa_amr_claims_session_id_fkey FOREIGN KEY (session_id) REFERENCES auth.sessions(id) ON DELETE CASCADE;


--
-- Name: mfa_challenges mfa_challenges_auth_factor_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.mfa_challenges
    ADD CONSTRAINT mfa_challenges_auth_factor_id_fkey FOREIGN KEY (factor_id) REFERENCES auth.mfa_factors(id) ON DELETE CASCADE;


--
-- Name: mfa_factors mfa_factors_user_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.mfa_factors
    ADD CONSTRAINT mfa_factors_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE;


--
-- Name: oauth_authorizations oauth_authorizations_client_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.oauth_authorizations
    ADD CONSTRAINT oauth_authorizations_client_id_fkey FOREIGN KEY (client_id) REFERENCES auth.oauth_clients(id) ON DELETE CASCADE;


--
-- Name: oauth_authorizations oauth_authorizations_user_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.oauth_authorizations
    ADD CONSTRAINT oauth_authorizations_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE;


--
-- Name: oauth_consents oauth_consents_client_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.oauth_consents
    ADD CONSTRAINT oauth_consents_client_id_fkey FOREIGN KEY (client_id) REFERENCES auth.oauth_clients(id) ON DELETE CASCADE;


--
-- Name: oauth_consents oauth_consents_user_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.oauth_consents
    ADD CONSTRAINT oauth_consents_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE;


--
-- Name: one_time_tokens one_time_tokens_user_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.one_time_tokens
    ADD CONSTRAINT one_time_tokens_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE;


--
-- Name: refresh_tokens refresh_tokens_session_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.refresh_tokens
    ADD CONSTRAINT refresh_tokens_session_id_fkey FOREIGN KEY (session_id) REFERENCES auth.sessions(id) ON DELETE CASCADE;


--
-- Name: saml_providers saml_providers_sso_provider_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.saml_providers
    ADD CONSTRAINT saml_providers_sso_provider_id_fkey FOREIGN KEY (sso_provider_id) REFERENCES auth.sso_providers(id) ON DELETE CASCADE;


--
-- Name: saml_relay_states saml_relay_states_flow_state_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.saml_relay_states
    ADD CONSTRAINT saml_relay_states_flow_state_id_fkey FOREIGN KEY (flow_state_id) REFERENCES auth.flow_state(id) ON DELETE CASCADE;


--
-- Name: saml_relay_states saml_relay_states_sso_provider_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.saml_relay_states
    ADD CONSTRAINT saml_relay_states_sso_provider_id_fkey FOREIGN KEY (sso_provider_id) REFERENCES auth.sso_providers(id) ON DELETE CASCADE;


--
-- Name: sessions sessions_oauth_client_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.sessions
    ADD CONSTRAINT sessions_oauth_client_id_fkey FOREIGN KEY (oauth_client_id) REFERENCES auth.oauth_clients(id) ON DELETE CASCADE;


--
-- Name: sessions sessions_user_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.sessions
    ADD CONSTRAINT sessions_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE;


--
-- Name: sso_domains sso_domains_sso_provider_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.sso_domains
    ADD CONSTRAINT sso_domains_sso_provider_id_fkey FOREIGN KEY (sso_provider_id) REFERENCES auth.sso_providers(id) ON DELETE CASCADE;


--
-- Name: webauthn_challenges webauthn_challenges_user_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.webauthn_challenges
    ADD CONSTRAINT webauthn_challenges_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE;


--
-- Name: webauthn_credentials webauthn_credentials_user_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.webauthn_credentials
    ADD CONSTRAINT webauthn_credentials_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE;


--
-- Name: alojamentos_contas alojamentos_contas_alojamento_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.alojamentos_contas
    ADD CONSTRAINT alojamentos_contas_alojamento_id_fkey FOREIGN KEY (alojamento_id) REFERENCES public.alojamentos(id) ON DELETE CASCADE;


--
-- Name: alojamentos alojamentos_obra_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.alojamentos
    ADD CONSTRAINT alojamentos_obra_id_fkey FOREIGN KEY (obra_id) REFERENCES public.obras(id) ON DELETE SET NULL;


--
-- Name: alojamentos_relatorios alojamentos_relatorios_alojamento_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.alojamentos_relatorios
    ADD CONSTRAINT alojamentos_relatorios_alojamento_id_fkey FOREIGN KEY (alojamento_id) REFERENCES public.alojamentos(id) ON DELETE CASCADE;


--
-- Name: efetivo_presenca efetivo_presenca_obra_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.efetivo_presenca
    ADD CONSTRAINT efetivo_presenca_obra_id_fkey FOREIGN KEY (obra_id) REFERENCES public.obras(id);


--
-- Name: ferias ferias_funcionario_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ferias
    ADD CONSTRAINT ferias_funcionario_id_fkey FOREIGN KEY (funcionario_id) REFERENCES public.funcionarios(id) ON DELETE CASCADE;


--
-- Name: folgas folgas_funcionario_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.folgas
    ADD CONSTRAINT folgas_funcionario_id_fkey FOREIGN KEY (funcionario_id) REFERENCES public.funcionarios(id) ON DELETE CASCADE;


--
-- Name: funcionarios funcionarios_alojamento_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.funcionarios
    ADD CONSTRAINT funcionarios_alojamento_id_fkey FOREIGN KEY (alojamento_id) REFERENCES public.alojamentos(id) ON DELETE SET NULL;


--
-- Name: funcionarios funcionarios_empresa_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.funcionarios
    ADD CONSTRAINT funcionarios_empresa_id_fkey FOREIGN KEY (empresa_id) REFERENCES public.empresas(id);


--
-- Name: funcionarios funcionarios_funcao_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.funcionarios
    ADD CONSTRAINT funcionarios_funcao_id_fkey FOREIGN KEY (funcao_id) REFERENCES public.funcoes(id);


--
-- Name: funcionarios funcionarios_obra_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.funcionarios
    ADD CONSTRAINT funcionarios_obra_id_fkey FOREIGN KEY (obra_id) REFERENCES public.obras(id);


--
-- Name: funcionarios funcionarios_obra_transferencia_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.funcionarios
    ADD CONSTRAINT funcionarios_obra_transferencia_id_fkey FOREIGN KEY (obra_transferencia_id) REFERENCES public.obras(id);


--
-- Name: obras obras_empresa_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.obras
    ADD CONSTRAINT obras_empresa_id_fkey FOREIGN KEY (empresa_id) REFERENCES public.empresas(id);


--
-- Name: prestadores prestadores_alojamento_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.prestadores
    ADD CONSTRAINT prestadores_alojamento_id_fkey FOREIGN KEY (alojamento_id) REFERENCES public.alojamentos(id);


--
-- Name: prestadores prestadores_obra_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.prestadores
    ADD CONSTRAINT prestadores_obra_id_fkey FOREIGN KEY (obra_id) REFERENCES public.obras(id);


--
-- Name: prestadores_presenca prestadores_presenca_prestador_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.prestadores_presenca
    ADD CONSTRAINT prestadores_presenca_prestador_id_fkey FOREIGN KEY (prestador_id) REFERENCES public.prestadores(id) ON DELETE CASCADE;


--
-- Name: objects objects_bucketId_fkey; Type: FK CONSTRAINT; Schema: storage; Owner: -
--

ALTER TABLE ONLY storage.objects
    ADD CONSTRAINT "objects_bucketId_fkey" FOREIGN KEY (bucket_id) REFERENCES storage.buckets(id);


--
-- Name: s3_multipart_uploads s3_multipart_uploads_bucket_id_fkey; Type: FK CONSTRAINT; Schema: storage; Owner: -
--

ALTER TABLE ONLY storage.s3_multipart_uploads
    ADD CONSTRAINT s3_multipart_uploads_bucket_id_fkey FOREIGN KEY (bucket_id) REFERENCES storage.buckets(id);


--
-- Name: s3_multipart_uploads_parts s3_multipart_uploads_parts_bucket_id_fkey; Type: FK CONSTRAINT; Schema: storage; Owner: -
--

ALTER TABLE ONLY storage.s3_multipart_uploads_parts
    ADD CONSTRAINT s3_multipart_uploads_parts_bucket_id_fkey FOREIGN KEY (bucket_id) REFERENCES storage.buckets(id);


--
-- Name: s3_multipart_uploads_parts s3_multipart_uploads_parts_upload_id_fkey; Type: FK CONSTRAINT; Schema: storage; Owner: -
--

ALTER TABLE ONLY storage.s3_multipart_uploads_parts
    ADD CONSTRAINT s3_multipart_uploads_parts_upload_id_fkey FOREIGN KEY (upload_id) REFERENCES storage.s3_multipart_uploads(id) ON DELETE CASCADE;


--
-- Name: vector_indexes vector_indexes_bucket_id_fkey; Type: FK CONSTRAINT; Schema: storage; Owner: -
--

ALTER TABLE ONLY storage.vector_indexes
    ADD CONSTRAINT vector_indexes_bucket_id_fkey FOREIGN KEY (bucket_id) REFERENCES storage.buckets_vectors(id);


--
-- Name: audit_log_entries; Type: ROW SECURITY; Schema: auth; Owner: -
--

ALTER TABLE auth.audit_log_entries ENABLE ROW LEVEL SECURITY;

--
-- Name: flow_state; Type: ROW SECURITY; Schema: auth; Owner: -
--

ALTER TABLE auth.flow_state ENABLE ROW LEVEL SECURITY;

--
-- Name: identities; Type: ROW SECURITY; Schema: auth; Owner: -
--

ALTER TABLE auth.identities ENABLE ROW LEVEL SECURITY;

--
-- Name: instances; Type: ROW SECURITY; Schema: auth; Owner: -
--

ALTER TABLE auth.instances ENABLE ROW LEVEL SECURITY;

--
-- Name: mfa_amr_claims; Type: ROW SECURITY; Schema: auth; Owner: -
--

ALTER TABLE auth.mfa_amr_claims ENABLE ROW LEVEL SECURITY;

--
-- Name: mfa_challenges; Type: ROW SECURITY; Schema: auth; Owner: -
--

ALTER TABLE auth.mfa_challenges ENABLE ROW LEVEL SECURITY;

--
-- Name: mfa_factors; Type: ROW SECURITY; Schema: auth; Owner: -
--

ALTER TABLE auth.mfa_factors ENABLE ROW LEVEL SECURITY;

--
-- Name: one_time_tokens; Type: ROW SECURITY; Schema: auth; Owner: -
--

ALTER TABLE auth.one_time_tokens ENABLE ROW LEVEL SECURITY;

--
-- Name: refresh_tokens; Type: ROW SECURITY; Schema: auth; Owner: -
--

ALTER TABLE auth.refresh_tokens ENABLE ROW LEVEL SECURITY;

--
-- Name: saml_providers; Type: ROW SECURITY; Schema: auth; Owner: -
--

ALTER TABLE auth.saml_providers ENABLE ROW LEVEL SECURITY;

--
-- Name: saml_relay_states; Type: ROW SECURITY; Schema: auth; Owner: -
--

ALTER TABLE auth.saml_relay_states ENABLE ROW LEVEL SECURITY;

--
-- Name: schema_migrations; Type: ROW SECURITY; Schema: auth; Owner: -
--

ALTER TABLE auth.schema_migrations ENABLE ROW LEVEL SECURITY;

--
-- Name: sessions; Type: ROW SECURITY; Schema: auth; Owner: -
--

ALTER TABLE auth.sessions ENABLE ROW LEVEL SECURITY;

--
-- Name: sso_domains; Type: ROW SECURITY; Schema: auth; Owner: -
--

ALTER TABLE auth.sso_domains ENABLE ROW LEVEL SECURITY;

--
-- Name: sso_providers; Type: ROW SECURITY; Schema: auth; Owner: -
--

ALTER TABLE auth.sso_providers ENABLE ROW LEVEL SECURITY;

--
-- Name: users; Type: ROW SECURITY; Schema: auth; Owner: -
--

ALTER TABLE auth.users ENABLE ROW LEVEL SECURITY;

--
-- Name: usuarios_acesso acesso_publico_usuarios; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY acesso_publico_usuarios ON public.usuarios_acesso TO authenticated, anon USING (true) WITH CHECK (true);


--
-- Name: empresas allow_all; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY allow_all ON public.empresas USING (true) WITH CHECK (true);


--
-- Name: ferias allow_all; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY allow_all ON public.ferias USING (true) WITH CHECK (true);


--
-- Name: folgas allow_all; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY allow_all ON public.folgas USING (true) WITH CHECK (true);


--
-- Name: funcionarios allow_all; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY allow_all ON public.funcionarios USING (true) WITH CHECK (true);


--
-- Name: funcoes allow_all; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY allow_all ON public.funcoes USING (true) WITH CHECK (true);


--
-- Name: obras allow_all; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY allow_all ON public.obras USING (true) WITH CHECK (true);


--
-- Name: prestadores allow_all; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY allow_all ON public.prestadores USING (true) WITH CHECK (true);


--
-- Name: prestadores_presenca allow_all; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY allow_all ON public.prestadores_presenca USING (true) WITH CHECK (true);


--
-- Name: alojamentos_contas allow_all_aloj_contas; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY allow_all_aloj_contas ON public.alojamentos_contas USING (true) WITH CHECK (true);


--
-- Name: alojamentos allow_all_alojamentos; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY allow_all_alojamentos ON public.alojamentos USING (true) WITH CHECK (true);


--
-- Name: alojamentos_contas allow_all_alojamentos_contas; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY allow_all_alojamentos_contas ON public.alojamentos_contas USING (true) WITH CHECK (true);


--
-- Name: efetivo_presenca allow_all_efetivo; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY allow_all_efetivo ON public.efetivo_presenca USING (true) WITH CHECK (true);


--
-- Name: efetivo_he allow_all_efetivo_he; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY allow_all_efetivo_he ON public.efetivo_he USING (true) WITH CHECK (true);


--
-- Name: efetivo_horas allow_all_efetivo_horas; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY allow_all_efetivo_horas ON public.efetivo_horas USING (true) WITH CHECK (true);


--
-- Name: alojamentos; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.alojamentos ENABLE ROW LEVEL SECURITY;

--
-- Name: alojamentos_contas; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.alojamentos_contas ENABLE ROW LEVEL SECURITY;

--
-- Name: alojamentos_relatorios; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.alojamentos_relatorios ENABLE ROW LEVEL SECURITY;

--
-- Name: efetivo_he; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.efetivo_he ENABLE ROW LEVEL SECURITY;

--
-- Name: efetivo_horas; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.efetivo_horas ENABLE ROW LEVEL SECURITY;

--
-- Name: efetivo_presenca; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.efetivo_presenca ENABLE ROW LEVEL SECURITY;

--
-- Name: empresas; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.empresas ENABLE ROW LEVEL SECURITY;

--
-- Name: ferias; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.ferias ENABLE ROW LEVEL SECURITY;

--
-- Name: folgas; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.folgas ENABLE ROW LEVEL SECURITY;

--
-- Name: funcionarios; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.funcionarios ENABLE ROW LEVEL SECURITY;

--
-- Name: funcoes; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.funcoes ENABLE ROW LEVEL SECURITY;

--
-- Name: obras; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.obras ENABLE ROW LEVEL SECURITY;

--
-- Name: prestadores; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.prestadores ENABLE ROW LEVEL SECURITY;

--
-- Name: prestadores_presenca; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.prestadores_presenca ENABLE ROW LEVEL SECURITY;

--
-- Name: usuarios_acesso; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.usuarios_acesso ENABLE ROW LEVEL SECURITY;

--
-- Name: messages; Type: ROW SECURITY; Schema: realtime; Owner: -
--

ALTER TABLE realtime.messages ENABLE ROW LEVEL SECURITY;

--
-- Name: objects allow_all_alojamentos_storage; Type: POLICY; Schema: storage; Owner: -
--

CREATE POLICY allow_all_alojamentos_storage ON storage.objects USING ((bucket_id = 'alojamentos'::text)) WITH CHECK ((bucket_id = 'alojamentos'::text));


--
-- Name: objects allow_all_storage; Type: POLICY; Schema: storage; Owner: -
--

CREATE POLICY allow_all_storage ON storage.objects USING ((bucket_id = 'funcionarios'::text)) WITH CHECK ((bucket_id = 'funcionarios'::text));


--
-- Name: buckets; Type: ROW SECURITY; Schema: storage; Owner: -
--

ALTER TABLE storage.buckets ENABLE ROW LEVEL SECURITY;

--
-- Name: buckets_analytics; Type: ROW SECURITY; Schema: storage; Owner: -
--

ALTER TABLE storage.buckets_analytics ENABLE ROW LEVEL SECURITY;

--
-- Name: buckets_vectors; Type: ROW SECURITY; Schema: storage; Owner: -
--

ALTER TABLE storage.buckets_vectors ENABLE ROW LEVEL SECURITY;

--
-- Name: migrations; Type: ROW SECURITY; Schema: storage; Owner: -
--

ALTER TABLE storage.migrations ENABLE ROW LEVEL SECURITY;

--
-- Name: objects; Type: ROW SECURITY; Schema: storage; Owner: -
--

ALTER TABLE storage.objects ENABLE ROW LEVEL SECURITY;

--
-- Name: s3_multipart_uploads; Type: ROW SECURITY; Schema: storage; Owner: -
--

ALTER TABLE storage.s3_multipart_uploads ENABLE ROW LEVEL SECURITY;

--
-- Name: s3_multipart_uploads_parts; Type: ROW SECURITY; Schema: storage; Owner: -
--

ALTER TABLE storage.s3_multipart_uploads_parts ENABLE ROW LEVEL SECURITY;

--
-- Name: vector_indexes; Type: ROW SECURITY; Schema: storage; Owner: -
--

ALTER TABLE storage.vector_indexes ENABLE ROW LEVEL SECURITY;

--
-- Name: supabase_realtime; Type: PUBLICATION; Schema: -; Owner: -
--

CREATE PUBLICATION supabase_realtime WITH (publish = 'insert, update, delete, truncate');


--
-- Name: issue_graphql_placeholder; Type: EVENT TRIGGER; Schema: -; Owner: -
--

CREATE EVENT TRIGGER issue_graphql_placeholder ON sql_drop
         WHEN TAG IN ('DROP EXTENSION')
   EXECUTE FUNCTION extensions.set_graphql_placeholder();


--
-- Name: issue_pg_cron_access; Type: EVENT TRIGGER; Schema: -; Owner: -
--

CREATE EVENT TRIGGER issue_pg_cron_access ON ddl_command_end
         WHEN TAG IN ('CREATE EXTENSION')
   EXECUTE FUNCTION extensions.grant_pg_cron_access();


--
-- Name: issue_pg_graphql_access; Type: EVENT TRIGGER; Schema: -; Owner: -
--

CREATE EVENT TRIGGER issue_pg_graphql_access ON ddl_command_end
         WHEN TAG IN ('CREATE FUNCTION')
   EXECUTE FUNCTION extensions.grant_pg_graphql_access();


--
-- Name: issue_pg_net_access; Type: EVENT TRIGGER; Schema: -; Owner: -
--

CREATE EVENT TRIGGER issue_pg_net_access ON ddl_command_end
         WHEN TAG IN ('CREATE EXTENSION')
   EXECUTE FUNCTION extensions.grant_pg_net_access();


--
-- Name: pgrst_ddl_watch; Type: EVENT TRIGGER; Schema: -; Owner: -
--

CREATE EVENT TRIGGER pgrst_ddl_watch ON ddl_command_end
   EXECUTE FUNCTION extensions.pgrst_ddl_watch();


--
-- Name: pgrst_drop_watch; Type: EVENT TRIGGER; Schema: -; Owner: -
--

CREATE EVENT TRIGGER pgrst_drop_watch ON sql_drop
   EXECUTE FUNCTION extensions.pgrst_drop_watch();


--
-- PostgreSQL database dump complete
--

\unrestrict 6NmQbrmyitb0hZbez4BIg2tJGHUxk95Z52Ha5qgZeQCaZxK6rrVdMDzz5psDoY0

