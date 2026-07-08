--
-- PostgreSQL database dump
--

\restrict IgbrIEp1p93anfUa3PZfqcGk6NPJLV8IhPRGEEgRBel6b3TEd3W2gygno57eaDv

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
    'in',
    'like',
    'ilike',
    'is',
    'match',
    'imatch',
    'isdistinct'
);


--
-- Name: user_defined_filter; Type: TYPE; Schema: realtime; Owner: -
--

CREATE TYPE realtime.user_defined_filter AS (
	column_name text,
	op realtime.equality_op,
	value text,
	negate boolean
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
-- Name: check_equality_op(realtime.equality_op, regtype, text, text, boolean); Type: FUNCTION; Schema: realtime; Owner: -
--

CREATE FUNCTION realtime.check_equality_op(op realtime.equality_op, type_ regtype, val_1 text, val_2 text, negate boolean) RETURNS boolean
    LANGUAGE plpgsql STABLE
    AS $$
declare
    op_symbol text;
    res boolean;
begin
    -- IS DISTINCT FROM / IS NOT DISTINCT FROM: infix, both sides typed literals
    if op = 'isdistinct' then
        execute format(
            'select %L::%s %s %L::%s',
            val_1,
            type_::text,
            case when negate then 'IS NOT DISTINCT FROM' else 'IS DISTINCT FROM' end,
            val_2,
            type_::text
        ) into res;
        return res;
    end if;

    -- IS requires a keyword RHS (NULL, TRUE, FALSE, UNKNOWN), not a typed literal
    if op = 'is' then
        if val_2 not in ('null', 'true', 'false', 'unknown') then
            raise exception 'invalid value for is filter: must be null, true, false, or unknown';
        end if;
        execute format(
            'select %L::%s %s %s',
            val_1,
            type_::text,
            case when negate then 'IS NOT' else 'IS' end,
            upper(val_2)
        ) into res;
        return res;
    end if;

    op_symbol = case
        when op = 'eq'    then '='
        when op = 'neq'   then '!='
        when op = 'lt'    then '<'
        when op = 'lte'   then '<='
        when op = 'gt'    then '>'
        when op = 'gte'   then '>='
        when op = 'in'    then '= any'
        when op = 'like'   then 'LIKE'
        when op = 'ilike'  then 'ILIKE'
        when op = 'match'  then '~'
        when op = 'imatch' then '~*'
        else null
    end;

    if op_symbol is null then
        raise exception 'unsupported equality operator: %', op::text;
    end if;

    execute format(
        'select %L::%s %s (%L::%s)',
        val_1,
        type_::text,
        op_symbol,
        val_2,
        case when op = 'in' then type_::text || '[]' else type_::text end
    ) into res;

    return case when negate then not res else res end;
end;
$$;


--
-- Name: is_visible_through_filters(realtime.wal_column[], realtime.user_defined_filter[]); Type: FUNCTION; Schema: realtime; Owner: -
--

CREATE FUNCTION realtime.is_visible_through_filters(columns realtime.wal_column[], filters realtime.user_defined_filter[]) RETURNS boolean
    LANGUAGE sql STABLE
    AS $$
    select
        filters is null
        or array_length(filters, 1) is null
        or coalesce(
            count(col.name) = count(1)
            and sum(
                realtime.check_equality_op(
                    op:=f.op,
                    type_:=coalesce(col.type_oid::regtype, col.type_name::regtype),
                    val_1:=col.value #>> '{}',
                    val_2:=f.value,
                    negate:=coalesce(f.negate, false)
                )::int
            ) filter (where col.name is not null) = count(col.name),
            false
        )
    from
        unnest(filters) f
        left join unnest(columns) col
            on f.column_name = col.name;
$$;


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
        elsif filter.op = 'is'::realtime.equality_op then
            -- `is` requires a keyword RHS rather than a typed literal
            if filter.value not in ('null', 'true', 'false', 'unknown') then
                raise exception 'invalid value for is filter: must be null, true, false, or unknown';
            end if;
            -- IS NULL works for any type, but IS TRUE/FALSE/UNKNOWN require a boolean
            -- operand. Reject the non-null keywords on non-boolean columns here so they
            -- don't abort apply_rls at WAL time.
            if filter.value <> 'null' and col_type <> 'boolean'::regtype then
                raise exception 'is % filter requires a boolean column, got %', filter.value, col_type::text;
            end if;
        elsif filter.op in ('like'::realtime.equality_op, 'ilike'::realtime.equality_op) then
            -- like/ilike apply the text pattern operator (~~); reject column types that
            -- have no such operator instead of failing at WAL time
            if not exists (
                select 1 from pg_catalog.pg_operator
                where oprname = '~~' and oprleft = col_type
            ) then
                raise exception 'operator % requires a text-compatible column type, got %', filter.op::text, col_type::text;
            end if;
        elsif filter.op in ('match'::realtime.equality_op, 'imatch'::realtime.equality_op) then
            -- match/imatch apply the regex operators ~ / ~*; reject column types that have
            -- no such operator (e.g. integer) instead of failing at WAL time, mirroring the
            -- like/ilike guard above.
            if not exists (
                select 1 from pg_catalog.pg_operator
                where oprname = case when filter.op = 'imatch'::realtime.equality_op then '~*' else '~' end
                  and oprleft = col_type
                  and oprright = col_type
                  and oprresult = 'boolean'::regtype
            ) then
                raise exception 'operator % requires a text-compatible column type, got %', filter.op::text, col_type::text;
            end if;
            -- validate the regex eagerly so a bad pattern is rejected here, not inside
            -- apply_rls where it would abort the WAL stream for the entity
            begin
                perform '' ~ filter.value;
            exception when others then
                raise exception 'invalid regular expression for % filter: %', filter.op::text, sqlerrm;
            end;
        else
            -- eq/neq/lt/lte/gt/gte: value must be coercable to the type
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

    -- Apply consistent order to filters so the unique constraint can't be tricked by a
    -- different filter order. negate is part of the sort key.
    new.filters = coalesce(
        array_agg(f order by f.column_name, f.op, f.value, f.negate),
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
    custom_claims_allowlist text[] DEFAULT '{}'::text[] NOT NULL,
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
    isenta_condominio boolean DEFAULT false,
    tipo_alojamento text DEFAULT 'residencia'::text,
    valor_diaria numeric
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
    anexo_url text,
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
    created_at timestamp with time zone DEFAULT now(),
    anexo_url text
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
    tipo_passagem_terrestre boolean DEFAULT false,
    saida1_programada date,
    saida2_programada date,
    saida3_programada date,
    saida4_programada date,
    saida5_programada date
);


--
-- Name: fornecedor_orcamentos; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.fornecedor_orcamentos (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    fornecedor_id uuid,
    descricao text,
    valor numeric,
    data date,
    arquivo_url text,
    created_at timestamp with time zone DEFAULT now()
);


--
-- Name: fornecedores; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.fornecedores (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    razao_social text NOT NULL,
    nome_fantasia text,
    cnpj text,
    inscricao_estadual text,
    situacao text DEFAULT 'ativo'::text,
    endereco text,
    cidade text,
    estado text,
    cep text,
    contato_nome text,
    telefone text,
    email text,
    tipo_fornecimento text,
    forma_pagamento text,
    dados_pagamento text,
    observacoes text,
    cartao_cnpj_url text,
    created_at timestamp with time zone DEFAULT now(),
    obra_id uuid
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
    periodo_experiencia text DEFAULT 45,
    efetivado boolean DEFAULT false,
    observacao_interna text,
    alojamento_id uuid,
    data_demissao date,
    tipo_demissao text,
    motivo_demissao text,
    salario numeric(10,2),
    tipo_pagamento text,
    alojamento_origem_id uuid,
    data_integracao_origem date,
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
-- Name: matriz_contatos; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.matriz_contatos (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    obra text,
    crd text,
    nome text NOT NULL,
    cargo text,
    setor text,
    email text,
    contato text,
    lider_imediato text,
    gestor_obra text,
    responsavel_contrato text,
    cidade text,
    estado text,
    tipo_obra text,
    endereco text,
    foto_url text,
    created_at timestamp with time zone DEFAULT now()
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
-- Name: passagens_seq_number; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.passagens_seq_number
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: passagens; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.passagens (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    seq integer DEFAULT nextval('public.passagens_seq_number'::regclass) NOT NULL,
    crd text,
    funcionario_id uuid,
    nome_completo text,
    data_nascimento date,
    funcao text,
    rg text,
    cpf text,
    tipo_viagem text,
    folga_a_cada_dias integer,
    aereo_data_solicitacao date,
    aereo_data_ida date,
    aereo_hora_ida_entre text,
    aereo_data_volta date,
    aereo_hora_volta_entre text,
    aereo_origem_ida text,
    aereo_destino_ida text,
    aereo_bagagem text,
    aereo_origem_volta text,
    aereo_destino_volta text,
    aereo_observacoes text,
    terr_data_solicitacao date,
    terr_data_ida date,
    terr_data_volta date,
    terr_observacoes text,
    terr_origem_ida_1 text,
    terr_hora_ida_1 text,
    terr_destino_ida_1a text,
    terr_hora_destino_ida_1a text,
    terr_destino_ida_1b text,
    terr_hora_destino_ida_1b text,
    terr_origem_ida_2 text,
    terr_hora_ida_2 text,
    terr_destino_ida_2a text,
    terr_hora_destino_ida_2a text,
    terr_destino_ida_2b text,
    terr_hora_destino_ida_2b text,
    terr_origem_volta_1 text,
    terr_hora_volta_1 text,
    terr_destino_volta_1a text,
    terr_hora_destino_volta_1a text,
    terr_destino_volta_1b text,
    terr_hora_destino_volta_1b text,
    terr_origem_volta_2 text,
    terr_hora_volta_2 text,
    terr_destino_volta_2a text,
    terr_hora_destino_volta_2a text,
    terr_destino_volta_2b text,
    terr_hora_destino_volta_2b text,
    loc_data_retirada date,
    loc_hora_retirada_entre text,
    loc_cidade_retirada text,
    loc_observacoes text,
    loc_data_entrega date,
    loc_hora_entrega_entre text,
    loc_km text,
    loc_tipo_locacao text,
    loc_tipo_veiculo text,
    hosp_data_checkin date,
    hosp_hora_checkin_entre text,
    hosp_cidade text,
    hosp_data_checkout date,
    hosp_hora_checkout_entre text,
    hosp_hotel_referencia text,
    hosp_faturar_1 text,
    hosp_faturar_2 text,
    hosp_faturar_3 text,
    hosp_tipo_quarto text,
    observacoes_gerais text,
    status text DEFAULT 'pendente'::text,
    obra_id uuid,
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now()
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
-- Name: treinamentos; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.treinamentos (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    funcionario_id uuid,
    tipo text NOT NULL,
    nr_codigo text,
    categoria_cnh text,
    nome_treinamento text,
    data_realizacao date,
    periodicidade_meses integer,
    vencimento_manual boolean DEFAULT false,
    data_vencimento date,
    observacao text,
    created_at timestamp with time zone DEFAULT now()
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

COPY auth.custom_oauth_providers (id, provider_type, identifier, name, client_id, client_secret, acceptable_client_ids, scopes, pkce_enabled, attribute_mapping, authorization_params, enabled, email_optional, issuer, discovery_url, skip_nonce_check, cached_discovery, discovery_cached_at, authorization_url, token_url, userinfo_url, jwks_uri, created_at, updated_at, custom_claims_allowlist) FROM stdin;
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
20260625000000
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

COPY public.alojamentos (id, nome, endereco, obra_id, vagas_total, imobiliaria, contato_imobiliaria, custo_mensal, condominio, iptu, seguro, data_inicio, data_termino, isencao_meses, indice_reajuste, observacoes, contrato_url, laudo_url, fotos_url, criado_em, caucao, proprietario, contato_proprietario, moradores_avulsos, isenta_agua, isenta_energia, isenta_gas, isenta_condominio, tipo_alojamento, valor_diaria) FROM stdin;
5e1a3306-b40c-4277-8c03-5e317063af3b	COSTA RICA	Rua Costa Rica, n° 604	0d899f11-785d-4edd-a951-bac82fae074f	6	COSTA ROCHA IMOVEIS	01140281983	2300.00	\N	\N	\N	2026-04-22	2027-04-22	\N	IVAR	\N	https://lqggoshphakeuufibdno.supabase.co/storage/v1/object/public/alojamentos/contratos/1781784544255_24104-004_-_CONTRATO_COSTA_ROCHAXGTEL_-_RUA_COSTA_RICA,_604.pdf	https://lqggoshphakeuufibdno.supabase.co/storage/v1/object/public/alojamentos/laudos/1781784548934_RELATORIO_ESTRUTURAL_09.pdf	https://lqggoshphakeuufibdno.supabase.co/storage/v1/object/public/alojamentos/fotos/1781784550414_FOTOS.zip	2026-06-18 12:09:13.901544+00	\N	\N	\N	[]	f	f	t	t	residencia	\N
f6f57e02-f34d-4586-9bc2-d32da81a6931	APARTAMENTO	Avenida Nelson Rubini nº 410 Apto 53 Bloco G Condomínio Residencial Brisa da Mata	0ea37ce8-5f9d-4270-ac46-73e6c169c6d2	2	HAPPY IMOVEIS	\N	2500.00	475.85	\N	\N	2026-02-05	2028-08-04	12	IVAR	\N	\N	https://lqggoshphakeuufibdno.supabase.co/storage/v1/object/public/alojamentos/laudos/1781790108558_Laudo_de_Vistoria_Inicial.pdf	https://lqggoshphakeuufibdno.supabase.co/storage/v1/object/public/alojamentos/fotos/1781790115749_ADM_31_-_03-2026_BRISA_DA_MATA_APTO.pdf	2026-06-18 13:41:59.642516+00	7500	\N	\N	[]	t	f	f	f	residencia	\N
c8e6e203-9c03-42cb-9a30-63fca14dc225	Rua Hungria, n° 494	Rua Hungria, n° 494 Bairro: Jardim das Nações. Município: Salto/SP, CEP : 13322-163.	0d899f11-785d-4edd-a951-bac82fae074f	7	Morata	\N	2500.00	\N	77.84	46.92	2026-04-15	2029-04-15	\N	IVAR	\N	\N	\N	\N	2026-06-03 20:43:18.472431+00	7500	\N	\N	[]	f	f	f	f	residencia	\N
a2004f54-f73c-4e26-9661-7d5a42e160cb	Administrativo	Rua Adalberto Machado da Luz, nº 279 – Jardim Cidade Alta – Campo Mourão - PR	fecd46b3-7f55-4fa2-b0f6-02e351793a4f	4	FABRI IMOBILIARIA E GESTÃO DE SERVIÇOS LTDA	44999140548	2375.00	\N	\N	\N	2026-04-01	2027-03-31	12	IGP-M/FGV	\N	https://lqggoshphakeuufibdno.supabase.co/storage/v1/object/public/alojamentos/contratos/1782417486377_24128-006_-_CONTRATO_-_FABRI_X_GTEL_-_CASA_-_RUA_ADALBERTO_MACHADO-assinado.pdf	\N	\N	2026-06-25 19:58:10.089169+00	\N	\N	\N	[]	f	f	t	t	residencia	\N
8d6ff09c-6e94-4f27-9e84-d6561a87ca74	OPERACIONAL - RUA DAS ORQUIDEAS, 71	RUA DAS ORQUIDEAS, 71 - JD FLORIDA - BARUERI, SP - 06407-210	25341e31-cd60-4743-ad1b-658397ec5d72	10	LUCARELLI PLANEJAMENTO IMOBILIARIO LTDA	\N	4500.00	\N	\N	\N	2026-01-13	2028-07-13	12	IVAR	\N	\N	\N	\N	2026-06-27 13:54:15.189006+00	13500	\N	\N	[]	f	f	t	t	residencia	\N
56f35f51-2e54-4692-82da-a1a505608111	CRISTOVÃO DINIZ	Rua Cristóvão Diniz 104, Jardim Santa Efigenia	0d899f11-785d-4edd-a951-bac82fae074f	6	\N	\N	\N	\N	\N	\N	\N	\N	\N	IVAR	\N	\N	https://lqggoshphakeuufibdno.supabase.co/storage/v1/object/public/alojamentos/laudos/1782568710692_RELATORIO_ESTRUTURAL_13.pdf	https://lqggoshphakeuufibdno.supabase.co/storage/v1/object/public/alojamentos/fotos/1782568713103_FOTOS.zip	2026-06-27 13:58:36.814251+00	\N	\N	\N	[]	f	f	t	t	residencia	\N
a0f063aa-df41-4780-ab24-82be52000892	JULIO PONGELUPPI	RUA JULIO PONGELUPPI – 118 JD.FORTALEZA/ PAULINIA - SP CEP: 13140-054	c2096d7c-a212-4365-9d85-3151167e0436	10	BANCO IMÓVEL	atendimento@bancoimovel.com.br	3500.00	\N	\N	\N	2023-08-22	2026-08-21	\N	IVAR	\N	\N	\N	\N	2026-06-16 12:42:05.155966+00	\N	\N	\N	[]	f	f	f	f	residencia	\N
d717dbdf-5fba-40c2-ad9f-bc9a4579027a	OPERACIONAL - RUA DA PRATA, 388	RUA DA PRATA, 388 - JD DOS CAMARGOS - BARUERI, SP	25341e31-cd60-4743-ad1b-658397ec5d72	5	ICONNE IMOVEIS LTDA	\N	2500.00	\N	\N	\N	2025-04-01	2026-09-30	\N	IGPM	\N	\N	\N	https://lqggoshphakeuufibdno.supabase.co/storage/v1/object/public/alojamentos/fotos/1782569588538_LAUDO_DE_VISTORIA_-_ICONNE_X_GTEL_-_RUA_DA_PRATA_.pdf_-_Alude.pdf	2026-06-27 14:13:10.839841+00	5000	\N	\N	[]	t	f	t	t	residencia	\N
e42bb35b-e6c4-4db2-8c2b-4c2e8f69a2e3	Vital Brasil 545	Vital Brasil 545, Jardim São Francisco - Salto/SP	0d899f11-785d-4edd-a951-bac82fae074f	8	Teu Imóvel	\N	2300.00	\N	\N	\N	2026-04-10	2029-04-10	12	IVAR	\N	\N	\N	\N	2026-06-04 10:48:05.88079+00	\N	VANILDA LUISA ROSSI	\N	[]	f	f	f	f	residencia	\N
7eca1a31-eb4e-4e6e-b853-57bc6c9ac091	DAS TULIPAS	RUA DAS TULIPAS 190 – PRES. MÉDICI/ PAULINIA - SP CEP: 13140-392	c2096d7c-a212-4365-9d85-3151167e0436	7	DÁLETE DE OLIVEIRA MELO SERVIÇOS IMOBILIARIOS	19 98152-4058	3000.00	\N	\N	576.02	2024-01-10	2026-07-10	30	IVAR	\N	https://lqggoshphakeuufibdno.supabase.co/storage/v1/object/public/alojamentos/contratos/1781619518664_CONTRATO_DE_LOCACAO-_RUA_DAS_TULIPAS_190_PAULINIA.pdf	\N	\N	2026-06-16 14:18:43.978036+00	\N	\N	\N	[]	f	f	f	f	residencia	\N
7e18e7ce-a57d-4369-88de-8097c3286957	SAO FELIPE	Rua São Felipe, n° 148.	0d899f11-785d-4edd-a951-bac82fae074f	6	MORATTA IMIVEIS	011942619418	2500.00	\N	\N	46.92	2026-04-15	2029-04-15	\N	IVAR	\N	\N	https://lqggoshphakeuufibdno.supabase.co/storage/v1/object/public/alojamentos/laudos/1781785905178_RELATORIO_ESTRUTURAL_02.pdf	https://lqggoshphakeuufibdno.supabase.co/storage/v1/object/public/alojamentos/fotos/1781785907641_FOTOS.zip	2026-06-18 12:31:51.716825+00	7500	\N	\N	[]	f	f	t	t	residencia	\N
1a02849c-86c8-40b7-920d-7f20937d758b	MARIETA	Rua João Jordão, 681 - Res. Marieta Dian Cosmópolis - SP, 13150-000	0ea37ce8-5f9d-4270-ac46-73e6c169c6d2	7	DHG	\N	3500.00	\N	\N	\N	2025-12-02	2028-06-01	12	IVAR	\N	\N	https://lqggoshphakeuufibdno.supabase.co/storage/v1/object/public/alojamentos/laudos/1781789424205_LAUDO_DE_VISTORIA_DE_ENTRADA_-_ASSINADO.pdf	\N	2026-06-18 13:30:53.775191+00	\N	\N	\N	[]	f	f	t	t	residencia	\N
326e50c1-0ebc-4674-8bf9-a9cac9ea998d	MONTE ALEGRE	Rua Avelino Beraldo, 115 Bairro Monte Alegre V CEP 13142-382 - Paulínia SP	0ea37ce8-5f9d-4270-ac46-73e6c169c6d2	6	HAPPY IMOVEIS	\N	3800.00	\N	\N	\N	2025-12-08	2028-06-07	12	IVAR	\N	https://lqggoshphakeuufibdno.supabase.co/storage/v1/object/public/alojamentos/contratos/1781789562876_Contrato_Rua_Avelino_Beraldo_115_-_Vila_Monte_Alegre_-_Paulinia_-_Assinado.pdf	https://lqggoshphakeuufibdno.supabase.co/storage/v1/object/public/alojamentos/laudos/1781789565509_Vistoria_de_Entrada.pdf	https://lqggoshphakeuufibdno.supabase.co/storage/v1/object/public/alojamentos/fotos/1781789568234_ADM_31_-_01-2026_AVELINO_BERALDO,_115_-_supervisores.pdf	2026-06-18 13:32:50.512062+00	11400	\N	\N	[]	f	f	t	t	residencia	\N
8492df23-4608-4b03-a3dc-7e25f361909f	SERRA AZUL	Rua Ítalo Bressanin 29 Bairro Residencial Serra Azul Paulínia SP cep 13144676	0ea37ce8-5f9d-4270-ac46-73e6c169c6d2	8	DHG	\N	3500.00	\N	\N	\N	2026-01-23	2028-07-22	12	IVAR	\N	https://lqggoshphakeuufibdno.supabase.co/storage/v1/object/public/alojamentos/contratos/1781789731216_Contrato_Assinado_Rua_Italo_Bressanin_29_Bairro_Residencial_Serra_Azul.pdf	https://lqggoshphakeuufibdno.supabase.co/storage/v1/object/public/alojamentos/laudos/1781789736676_LAUDO_DE_VISTORIA_DE_ENTRADA_-_ASSINADO.pdf	https://lqggoshphakeuufibdno.supabase.co/storage/v1/object/public/alojamentos/fotos/1781789757321_ADM_31_-_02-2026_-_SERRA_AZUL.pdf	2026-06-18 13:36:01.542549+00	14000	\N	\N	[]	f	f	t	t	residencia	\N
b80b8e4d-b5a6-42fd-8f0a-30842977f28d	SAO TOME	Rua São Tomé, n° 79, Jardim São Judas Tadeu, Salto/SP, CEP: 13327-390	0d899f11-785d-4edd-a951-bac82fae074f	2	MORATTA IMOVEIS	011942619418	2500.00	\N	\N	\N	2026-04-30	2029-04-30	\N	IVAR	\N	\N	https://lqggoshphakeuufibdno.supabase.co/storage/v1/object/public/alojamentos/laudos/1782569643321_RELATORIO_ESTRUTURAL_14.pdf	https://lqggoshphakeuufibdno.supabase.co/storage/v1/object/public/alojamentos/fotos/1782569645867_I135-A1377533-rafael-rogerio-moraes-x-gtel-grupo-tecnico-eletromecanica-s_-_SAO_TOME.pdf	2026-06-27 14:14:10.554396+00	7500	\N	\N	[]	f	f	t	t	residencia	\N
2b753fd1-03b8-433a-a187-24f4b5ccb1de	SOLAR DOS PASSAROS, BL45 AP301	Rua das Nações Unidas, n° 600, apto 301, bloco 45, resid. Solar dos Pássaros, Salto/SP.	0d899f11-785d-4edd-a951-bac82fae074f	2	Costa Rocha	\N	1700.00	\N	\N	\N	2026-04-01	2027-04-01	\N	IVAR	R$ 1.700,00 (um mil e setecentos reais) incluso condomínio, água, gás e\nIPTU	\N	\N	https://lqggoshphakeuufibdno.supabase.co/storage/v1/object/public/alojamentos/fotos/1782581639876_FOTO.zip	2026-06-04 10:09:43.697412+00	\N	\N	\N	[{"obs": "Inspetor de Solda - PJ", "nome": "Roberto Gonçalves de Oliveira"}]	f	f	f	f	residencia	\N
aaa18e15-4d77-4cbf-afb8-22fb51fd0b5d	SAO TOME	Rua São Tomé, n79, Jardim São Judas Tadeu, Salto/SP, CEP: 13327-390	0d899f11-785d-4edd-a951-bac82fae074f	2	MORATTA IMOVEIS	011942619418	2500.00	\N	\N	\N	2026-04-30	2029-04-30	\N	IVAR	\N	https://lqggoshphakeuufibdno.supabase.co/storage/v1/object/public/alojamentos/contratos/1782570085692_I135-A1377533-rafael-rogerio-moraes-x-gtel-grupo-tecnico-eletromecanica-s_-_SAO_TOME.pdf	https://lqggoshphakeuufibdno.supabase.co/storage/v1/object/public/alojamentos/laudos/1782570089405_RELATORIO_ESTRUTURAL_14.pdf	https://lqggoshphakeuufibdno.supabase.co/storage/v1/object/public/alojamentos/fotos/1782570091032_foto.zip	2026-06-27 14:22:05.684954+00	7500	\N	\N	[]	f	f	t	t	residencia	\N
7cec8c21-12e1-491d-89fb-fd3599eae796	RUI BARBOSA	Rua Rui Barbosa, n° 972. Bairro: Vila Teixeira, Município: Salto/SP, CEP : 13320-360	0d899f11-785d-4edd-a951-bac82fae074f	9	MORATTA IMOVEIS	011942619418	2300.00	\N	\N	\N	2026-04-25	2029-04-25	\N	IVAR	\N	https://lqggoshphakeuufibdno.supabase.co/storage/v1/object/public/alojamentos/contratos/1782567540620_I135-A1368675-alfredo-tarossi-junior-x-gtel-grupo-tecnico-eletromecanica-s_RUI_BARBOSA.pdf	https://lqggoshphakeuufibdno.supabase.co/storage/v1/object/public/alojamentos/laudos/1782567542555_RELATORIO_ESTRUTURAL_10.pdf	https://lqggoshphakeuufibdno.supabase.co/storage/v1/object/public/alojamentos/fotos/1782567544834_foto.zip	2026-06-27 13:39:08.726279+00	6900	\N	\N	[]	f	f	f	f	residencia	\N
8371894c-46f8-42bf-9673-e9b149342305	PAU BRASIL	Rua Pau-Brasil, n° 132, Vila Flora, Salto/SP, CEP: 13321-111	0d899f11-785d-4edd-a951-bac82fae074f	6	MORATTA IMOVEIS	011942619418	1900.00	\N	62.08	35.93	2026-04-25	2029-04-25	\N	IVAR	\N	https://lqggoshphakeuufibdno.supabase.co/storage/v1/object/public/alojamentos/contratos/1782570903815_24104-011_-_JULIANA_CRISTINA_X_GTEL_-_RUA_PAU_BRASIL,_132.pdf	https://lqggoshphakeuufibdno.supabase.co/storage/v1/object/public/alojamentos/laudos/1782570909464_RELATORIO_ESTRUTURAL_16.pdf	https://lqggoshphakeuufibdno.supabase.co/storage/v1/object/public/alojamentos/fotos/1782570911379_FOTO.zip	2026-06-27 14:35:15.263309+00	5700	\N	\N	[]	f	f	t	t	residencia	\N
b7abc826-8aba-4f32-8e08-587315389657	NEPAL	RUA NEPAL, N 455, JARDIM PLANALTO, SALTO/SP, CEP: 13322253	0d899f11-785d-4edd-a951-bac82fae074f	7	MORATTA IMOVEIS	011942619418	\N	2200.00	\N	41.42	2026-05-20	2029-05-20	\N	IVAR	\N	\N	\N	https://lqggoshphakeuufibdno.supabase.co/storage/v1/object/public/alojamentos/fotos/1782571368164_FOTO.zip	2026-06-27 14:42:49.745639+00	6600	\N	\N	[]	f	f	t	t	residencia	\N
6be4e2bb-dd50-4b0a-b0e4-8fc31df65942	OPERACIONAL - RUA SÃO FRANCISCO, 20B	RUA SÃO FRANCISCO, 20B - VILA SÃO SILVESTRE - BARUERI, SP - 06417-040	25341e31-cd60-4743-ad1b-658397ec5d72	4	MEGAN IMOVEIS LTDA EPP	\N	2000.00	\N	\N	\N	2025-06-02	2027-12-01	15	IGPM	\N	\N	\N	\N	2026-06-27 16:28:22.085425+00	6000	\N	\N	[]	f	f	t	t	residencia	\N
f2c322ef-2125-4052-88f7-58d45ba5135f	ADM - RUA PROF. ELVIRA L. SALLES NEMES, 388	RUA PROF. ELVIRA LEFEVRE SALLES NEMER, 388 - JD SÃO PEDRO - BARUERI, SP - 06402-190	25341e31-cd60-4743-ad1b-658397ec5d72	2	MAX LIDER CONSULTORIA IMOBILIARIA LTDA EPP	\N	2400.00	\N	\N	\N	2026-04-01	2027-04-01	12	IGPM	\N	\N	\N	\N	2026-06-27 16:21:52.179637+00	7200	\N	\N	[]	f	f	t	t	residencia	\N
d1b9c5b6-5594-487e-b8f0-22abace46f0f	SOLAR DOS PASSAROS, BL39 AP303	Rua das Nações Unidas, n° 600/664, Bloco 39 Apto 303 - Solar dos Pássaros	0d899f11-785d-4edd-a951-bac82fae074f	2	MORATTA IMOVEIS	011942619418	1800.00	\N	\N	13.99	2026-04-15	2029-04-15	\N	IVAR	\N	\N	\N	https://lqggoshphakeuufibdno.supabase.co/storage/v1/object/public/alojamentos/fotos/1782581285551_FOTOS.zip	2026-06-27 17:28:07.638442+00	5400	\N	\N	[]	f	f	f	f	residencia	\N
cdb01167-5280-41c1-9fe4-882d20e951a5	ADM - RUA DR. FAUSTO DIAS FERRAZ, 49	RUA DR. FAUSTO DIAS FERRAZ, 49 APTO 01 - VILA MORELLATO - BARUERI, SP - 06408-200	25341e31-cd60-4743-ad1b-658397ec5d72	3	MEGA NEGOCIOS	\N	1990.00	595.00	\N	\N	2025-04-01	2027-10-01	12	IVAR	\N	\N	\N	https://lqggoshphakeuufibdno.supabase.co/storage/v1/object/public/alojamentos/fotos/1782570141552_Termo_de_Vistoria__Cruz_Preta_GLR01_-_Alude.pdf	2026-06-27 14:22:23.380906+00	5970	\N	\N	[]	t	f	t	t	residencia	\N
d7dc066e-653e-4559-bbfd-671fa657cbe9	EVENIES GONZAGA - COORDENAÇÃO	Rua Eviner Gonzaga, 30 Edifício Residencial Ágata, Bloco 07 Apto  23. Bairro – Jardim das Constelações - Salto/SP	0d899f11-785d-4edd-a951-bac82fae074f	1	ROCHA COSTA	01140281983	1800.00	\N	\N	\N	2026-04-22	2028-10-22	\N	IVAR	\N	\N	https://lqggoshphakeuufibdno.supabase.co/storage/v1/object/public/alojamentos/laudos/1782582527554_RELATORIO_ESTRUTURAL_13.docx	https://lqggoshphakeuufibdno.supabase.co/storage/v1/object/public/alojamentos/fotos/1782582536811_foto.zip	2026-06-27 17:48:59.623961+00	\N	\N	\N	[]	f	f	t	t	residencia	\N
60c169d2-c301-454c-8f5a-cea1a2be53d5	SOLLARE BL11 AP304	Rua das Nações Unidas, n° 2111, Bloco 11 Apto 304 - Residencial Sollare	0d899f11-785d-4edd-a951-bac82fae074f	2	MORATTA IMOVEIS	\N	1323.27	280.08	14.03	\N	2026-04-15	2029-04-15	\N	IVAR	\N	\N	https://lqggoshphakeuufibdno.supabase.co/storage/v1/object/public/alojamentos/laudos/1782584222425_RELATORIO_ESTRUTURAL_07_at.pdf	https://lqggoshphakeuufibdno.supabase.co/storage/v1/object/public/alojamentos/fotos/1782584224117_FOTO.zip	2026-06-27 18:17:06.237746+00	\N	\N	\N	[]	f	f	f	f	residencia	\N
51afffdb-a64b-4305-8aaf-46c187b33639	RUA ADOLFO - GERENCIA	Rua Adolfo Rodrigues de Arruda, 86 - Parque Industrial, Itu-SP	0d899f11-785d-4edd-a951-bac82fae074f	1	SILVANA CARVALHO	\N	2472.57	484.93	42.50	31.68	2026-04-02	2027-04-02	\N	IVAR	\N	https://lqggoshphakeuufibdno.supabase.co/storage/v1/object/public/alojamentos/contratos/1782583874409_24104-001_-_Silvana_Carvalho_x_Gtel_-_Rua_Adolfo_Rodrigues_de_Arruda,_86_.pdf	https://lqggoshphakeuufibdno.supabase.co/storage/v1/object/public/alojamentos/laudos/1782583878296_RELATORIO_ESTRUTURAL_06.pdf	\N	2026-06-27 18:11:20.04789+00	\N	\N	\N	[]	f	f	f	f	residencia	\N
31c7f2f6-8717-4135-b04f-e1224e48ab85	SOLARE BL 09 AP 102	Rua das Nações Unidas, n° 2111, apto 102, bloco 09,  térreo, cond. Resid. Sollare, Salto/SP.	0d899f11-785d-4edd-a951-bac82fae074f	\N	Costa Rocha	\N	1500.00	264.96	29.00	\N	2026-04-17	2027-04-17	\N	IVAR	\N	\N	https://lqggoshphakeuufibdno.supabase.co/storage/v1/object/public/alojamentos/laudos/1782584524350_RELATORIO_ESTRUTURAL_11.pdf	https://lqggoshphakeuufibdno.supabase.co/storage/v1/object/public/alojamentos/fotos/1782584527375_FOTO.zip	2026-06-27 18:22:09.019268+00	\N	\N	\N	[]	f	f	f	f	residencia	\N
ae89e516-b560-4cbd-9150-5d3acc49e49a	RUA RUSSIA	Rua Rússia 837 Jardim Planalto - Salto – SP	0d899f11-785d-4edd-a951-bac82fae074f	7	MORATTA IMOVEIS	011942619418	1900.00	\N	\N	35.93	2026-05-20	2029-02-20	\N	IVAR	\N	https://lqggoshphakeuufibdno.supabase.co/storage/v1/object/public/alojamentos/contratos/1782734772683_24104-015_-_FERNANDA_MARIA_BUSELLI_X_GTEL_-_RUA_RUSSIA_837.pdf	https://lqggoshphakeuufibdno.supabase.co/storage/v1/object/public/alojamentos/laudos/1782580797663_RELATORIO_ESTRUTURAL_19.pdf	https://lqggoshphakeuufibdno.supabase.co/storage/v1/object/public/alojamentos/fotos/1782580800852_FOTO.zip	2026-06-27 17:20:02.748708+00	\N	\N	\N	[]	f	f	t	t	residencia	\N
8c8b88eb-d98b-4bba-a6db-863727896332	PAU BRASIL	Rua Pau-Brasil, n° 132, Vila Flora, Salto/SP, CEP: 13321-111	0d899f11-785d-4edd-a951-bac82fae074f	6	MORATTA IMOVEIS	011942619418	1900.00	\N	\N	\N	2026-04-25	2029-04-25	\N	IVAR	\N	https://lqggoshphakeuufibdno.supabase.co/storage/v1/object/public/alojamentos/contratos/1782570570288_24104-011_-_JULIANA_CRISTINA_X_GTEL_-_RUA_PAU_BRASIL,_132.pdf	https://lqggoshphakeuufibdno.supabase.co/storage/v1/object/public/alojamentos/laudos/1782570574361_RELATORIO_ESTRUTURAL_16.pdf	https://lqggoshphakeuufibdno.supabase.co/storage/v1/object/public/alojamentos/fotos/1782570575442_FOTO.zip	2026-06-27 14:29:37.655374+00	5700	\N	\N	[]	f	f	t	t	residencia	\N
512791df-7e73-40e2-818c-4955f95f5aba	RUA RUSSIA	Rua Rússia 837 Jardim Planalto - Salto - SP	0d899f11-785d-4edd-a951-bac82fae074f	7	\N	\N	\N	\N	\N	\N	\N	\N	\N	IVAR	\N	\N	https://lqggoshphakeuufibdno.supabase.co/storage/v1/object/public/alojamentos/laudos/1782580704554_RELATORIO_ESTRUTURAL_19.pdf	https://lqggoshphakeuufibdno.supabase.co/storage/v1/object/public/alojamentos/fotos/1782580706597_FOTO.zip	2026-06-27 17:18:27.92769+00	\N	\N	\N	[]	f	f	t	t	residencia	\N
02800faf-0e3a-40c5-b354-4e64d8a6f5ad	RUA PREFEITO	Rua Prefeito João Batista Ferrari, n° 52	0d899f11-785d-4edd-a951-bac82fae074f	6	MORATTA IMOVEIS	011942619418	2300.00	\N	\N	43.26	2026-06-10	2029-06-10	\N	IVAR	\N	\N	https://lqggoshphakeuufibdno.supabase.co/storage/v1/object/public/alojamentos/laudos/1782736357195_RELATORIO_ESTRUTURAL_20.pdf	https://lqggoshphakeuufibdno.supabase.co/storage/v1/object/public/alojamentos/fotos/1782736358687_foto.zip	2026-06-29 12:15:42.654308+00	6900	\N	\N	[]	f	f	t	t	residencia	\N
08c90ae3-d954-4510-91bc-1a0fb93c6c68	Hotel 365	Av. Fernando Corrêa da Costa, 8780 - Jardim Pres., Cuiabá - MT, 78090-000	ae387bdc-cf9e-4d3a-ad30-5a16e85801bc	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-07-03 01:55:07.794881+00	\N	\N	\N	[]	f	f	f	f	hotel	255
6def14ab-7549-47b2-b268-e0775a28a51f	Hotel Fabiel	Av. Archimedes Pereira Lima, 6855 - Altos do Coxipó, Cuiabá - MT, 78088-505	ae387bdc-cf9e-4d3a-ad30-5a16e85801bc	5	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-07-07 20:39:12.432187+00	\N	\N	\N	[]	f	f	f	f	hotel	137.5
\.


--
-- Data for Name: alojamentos_contas; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.alojamentos_contas (id, alojamento_id, mes, ano, tipo, valor, observacao, criado_em, adm35_numero, adm35_envio, anexo_url) FROM stdin;
d59392cd-dd08-4474-97f0-85ec07105300	cdb01167-5280-41c1-9fe4-882d20e951a5	5	2026	energia	197.20	\N	2026-06-27 17:33:17.029142+00	ADM31	2026-06-24	\N
a3b0bc16-12d4-4085-bd7f-79601196064e	f2c322ef-2125-4052-88f7-58d45ba5135f	6	2026	energia	148.56	\N	2026-06-27 17:35:03.675351+00	ADM31	2026-06-24	\N
18f65e73-1595-4b89-a8c7-33629b792b8d	d717dbdf-5fba-40c2-ad9f-bc9a4579027a	5	2026	energia	183.16	\N	2026-06-27 17:37:32.266286+00	ADM31	2026-06-24	\N
660ad7bf-bd2c-44d1-90f8-d7f348adf11c	8d6ff09c-6e94-4f27-9e84-d6561a87ca74	5	2026	agua	161.86	\N	2026-06-27 17:45:45.162625+00	ADM31	2026-06-24	\N
34092cb2-3c66-43cd-9ab1-398dcbd8c593	6be4e2bb-dd50-4b0a-b0e4-8fc31df65942	6	2026	agua	81.24	\N	2026-06-27 17:46:55.196023+00	ADM31	2026-06-24	\N
b9cc5de6-a9d6-4ce9-a21c-a2909668d0e8	c8e6e203-9c03-42cb-9a30-63fca14dc225	5	2026	agua	142.22	\N	2026-06-27 18:45:44.331314+00	1	2026-05-19	\N
14e9ebba-9a65-453a-86db-90afa0b6879d	e42bb35b-e6c4-4db2-8c2b-4c2e8f69a2e3	5	2026	agua	63.92	\N	2026-06-27 18:46:48.638407+00	1	2026-05-19	\N
0330d9dd-362e-4ff8-b7cc-b21a86d8e95e	51afffdb-a64b-4305-8aaf-46c187b33639	4	2026	agua	66.20	\N	2026-06-27 18:49:29.145441+00	1	2026-05-19	\N
f293c339-a884-4fc3-b4d6-366240404a99	8371894c-46f8-42bf-9673-e9b149342305	5	2026	agua	63.92	\N	2026-06-27 18:52:22.128579+00	2	2026-05-28	\N
e505215e-71ec-4b4d-9f9a-4ce2c2d73155	5e1a3306-b40c-4277-8c03-5e317063af3b	5	2026	agua	63.92	\N	2026-06-27 18:54:21.00368+00	2	2026-05-28	\N
845ef7b8-5b12-4915-9202-db9b957b5a9a	7e18e7ce-a57d-4369-88de-8097c3286957	5	2026	agua	65.20	\N	2026-06-27 18:55:18.286832+00	2	2026-05-28	\N
0c833096-f9c4-4675-b8f9-4eb661186c00	5e1a3306-b40c-4277-8c03-5e317063af3b	5	2026	energia	36.81	\N	2026-06-27 18:56:01.347126+00	2	2026-05-28	\N
1f460cb8-a45f-4621-9400-df896036ef5a	c8e6e203-9c03-42cb-9a30-63fca14dc225	6	2026	energia	280.12	\N	2026-06-27 18:59:18.515347+00	3	2026-06-18	\N
2f45bdf7-1e21-4a59-ae9d-6eda65203745	5e1a3306-b40c-4277-8c03-5e317063af3b	6	2026	energia	99.66	\N	2026-06-27 19:00:29.253707+00	4	2026-06-24	\N
21eeba41-4009-4cbe-b0bd-ab0fac3adf17	d1b9c5b6-5594-487e-b8f0-22abace46f0f	6	2026	energia	100.06	\N	2026-06-27 19:02:05.85381+00	4	2026-06-24	\N
11fa1089-a796-44c5-b103-c18bad0fbdf3	b7abc826-8aba-4f32-8e08-587315389657	6	2026	agua	63.92	\N	2026-06-27 19:02:51.211612+00	4	2026-06-24	\N
756b65dd-7a12-419c-9578-2c1eebbc417c	5e1a3306-b40c-4277-8c03-5e317063af3b	6	2026	agua	133.11	\N	2026-06-27 19:04:29.405458+00	5	2026-06-27	\N
8528872e-0cfd-4d76-9b59-692e0883bc4d	c8e6e203-9c03-42cb-9a30-63fca14dc225	6	2026	agua	125.90	\N	2026-06-27 19:05:19.996399+00	5	2026-06-27	\N
f4d70a8d-1ff3-4904-8a60-83a6d944575b	f6f57e02-f34d-4586-9bc2-d32da81a6931	6	2026	energia	266.11	\N	2026-06-29 11:03:50.214564+00	012	2026-06-24	\N
9fec6bfc-17d7-4536-bd3e-c22b1274bf72	f6f57e02-f34d-4586-9bc2-d32da81a6931	6	2026	gas	91.87	\N	2026-06-29 11:09:56.603882+00	ADM 013	2026-06-29	\N
db25e9fa-478d-4d5e-83f5-ea3c4727b0df	326e50c1-0ebc-4674-8bf9-a9cac9ea998d	6	2026	agua	103.90	\N	2026-06-29 11:14:34.196008+00	011	2026-06-24	\N
778bfcf1-a1f6-4f00-aa52-1952627d2ac7	326e50c1-0ebc-4674-8bf9-a9cac9ea998d	6	2026	energia	179.41	\N	2026-06-29 11:15:23.461588+00	011	2026-06-24	\N
2cec60aa-fed4-4b10-bedc-ecb6ba0bdde3	326e50c1-0ebc-4674-8bf9-a9cac9ea998d	5	2026	energia	188.57	\N	2026-06-29 11:16:15.721635+00	011	2026-06-24	\N
632d14e6-c1dd-448b-9aee-ec7d628c00bf	8492df23-4608-4b03-a3dc-7e25f361909f	6	2026	agua	577.59	\N	2026-06-29 11:16:44.576104+00	011	2026-06-24	\N
b9f2d81c-028d-4683-8edd-8938e3f74ba7	8492df23-4608-4b03-a3dc-7e25f361909f	6	2026	energia	266.11	\N	2026-06-29 11:17:04.487138+00	012	2026-06-24	\N
8a0c6525-b269-4d57-9e88-9831659ac6a7	cdb01167-5280-41c1-9fe4-882d20e951a5	5	2026	gas	11.31	\N	2026-06-30 12:44:15.936309+00	33	2026-06-30	\N
130c3677-47a7-46af-8535-d9e7846d7771	cdb01167-5280-41c1-9fe4-882d20e951a5	6	2026	gas	10.18	\N	2026-06-30 12:46:13.185258+00	33	2026-06-30	\N
4884767f-4dba-45e6-9762-5ee3f60d6f70	7eca1a31-eb4e-4e6e-b853-57bc6c9ac091	6	2026	agua	191.32	\N	2026-07-02 17:36:32.350905+00	55	2026-06-23	\N
9287636d-aacd-4a64-a971-63459c9fe83f	a0f063aa-df41-4780-ab24-82be52000892	6	2026	agua	124.35	\N	2026-07-02 17:38:09.346083+00	55	2026-06-23	\N
f06f22a7-ec46-4b73-818a-c0cc48122358	a0f063aa-df41-4780-ab24-82be52000892	6	2026	energia	434.17	\N	2026-07-02 17:59:40.658851+00	54	2026-06-15	\N
33b8bf0e-4b24-4a17-8693-d7233ed293a9	7eca1a31-eb4e-4e6e-b853-57bc6c9ac091	6	2026	energia	305.01	\N	2026-07-02 18:01:32.24407+00	53	2026-06-09	\N
a248e3fe-0ae4-4a2c-af2a-5bdb7fa3a7b2	d717dbdf-5fba-40c2-ad9f-bc9a4579027a	6	2026	energia	32.27	\N	2026-07-06 13:53:27.539528+00	34	2026-07-06	https://lqggoshphakeuufibdno.supabase.co/storage/v1/object/public/alojamentos/contas/1783346006565_ENEL_-_R_DA_PRATA__336_-_06.2026_-_R__32_27.pdf
1295206a-8c89-4963-8161-18efa626ed3e	8d6ff09c-6e94-4f27-9e84-d6561a87ca74	7	2026	energia	166.97	\N	2026-07-06 13:54:50.163432+00	34	2026-07-06	https://lqggoshphakeuufibdno.supabase.co/storage/v1/object/public/alojamentos/contas/1783346071312_ENEL_-_R_DAS_ORQUIDEAS__71_-_07.2026_-_R__166_97.pdf
d5f8a76c-7756-4a42-9766-0f1f4087e3b8	cdb01167-5280-41c1-9fe4-882d20e951a5	6	2026	energia	165.61	\N	2026-07-06 13:57:48.361278+00	34	2026-07-06	https://lqggoshphakeuufibdno.supabase.co/storage/v1/object/public/alojamentos/contas/1783346266752_ENEL_-_R_DR_FAUSTO__49_-_06.2026_-_R__165_61.pdf
d6a5d670-f640-4305-94ea-a3f5bb7eb62d	f2c322ef-2125-4052-88f7-58d45ba5135f	7	2026	energia	137.97	\N	2026-07-06 13:58:31.699974+00	34	2026-07-06	https://lqggoshphakeuufibdno.supabase.co/storage/v1/object/public/alojamentos/contas/1783346309981_ENEL_-_R_PROF_ELVIRA__388_-_07.2026_-_R__137_97.pdf
9ac0d4eb-16af-4954-93b5-7d769ce6c8b4	6be4e2bb-dd50-4b0a-b0e4-8fc31df65942	7	2026	energia	43.97	\N	2026-07-06 13:59:14.716497+00	34	2026-07-06	https://lqggoshphakeuufibdno.supabase.co/storage/v1/object/public/alojamentos/contas/1783346353806_ENEL_-_R_SAO_FRANCISCO__20B_-_07.2026_-_R__43_97.pdf
1359ce67-8303-49d8-86cc-2daa960e3f29	f2c322ef-2125-4052-88f7-58d45ba5135f	6	2026	agua	188.75	\N	2026-07-06 13:59:55.570675+00	34	2026-07-06	https://lqggoshphakeuufibdno.supabase.co/storage/v1/object/public/alojamentos/contas/1783346394974_SABESP_-_R_PROF_ELVIRA__338_-_06.2026_-_R__188_75.pdf
8819c8f7-0afb-4db0-bff0-f33e94e20b56	8d6ff09c-6e94-4f27-9e84-d6561a87ca74	5	2026	energia	183.16	\N	2026-07-06 14:02:48.282294+00	31	2026-06-24	https://lqggoshphakeuufibdno.supabase.co/storage/v1/object/public/alojamentos/contas/1783346566892_ENEL_-_R_DA_PRATA__336_-_05.2026_-_R__183_16.pdf
\.


--
-- Data for Name: alojamentos_relatorios; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.alojamentos_relatorios (id, alojamento_id, mes, ano, avaliador, data_avaliacao, data_recebimento, observacoes, created_at, anexo_url) FROM stdin;
9d5cc041-07b2-43ce-82a9-01695d763780	cdb01167-5280-41c1-9fe4-882d20e951a5	6	2026	CAUAN DE AQUINO	2026-06-30	2026-07-01	\N	2026-07-02 19:55:14.257174+00	\N
7b1fdbf4-e822-481f-a835-327b26fc725d	f2c322ef-2125-4052-88f7-58d45ba5135f	6	2026	CAUAN DE AQUINO	2026-06-30	2026-07-01	\N	2026-07-02 19:55:54.038143+00	\N
0c5e3c3b-747d-4788-8662-b363a42bc6e3	d717dbdf-5fba-40c2-ad9f-bc9a4579027a	6	2026	CAUAN DE AQUINO	2026-06-30	2026-07-01	\N	2026-07-02 19:56:09.689174+00	\N
0ddc328b-dd5d-40be-887e-483e75efd4d3	8d6ff09c-6e94-4f27-9e84-d6561a87ca74	6	2026	CAUAN DE AQUINO	2026-06-30	2026-07-01	\N	2026-07-02 19:56:24.126295+00	\N
84d55245-8c4d-4409-854d-cdc9b22351b6	6be4e2bb-dd50-4b0a-b0e4-8fc31df65942	6	2026	CAUAN DE AQUINO	2026-06-30	2026-07-01	\N	2026-07-02 19:57:11.966084+00	\N
4a638d3a-f159-4903-a742-f35bb6243859	5e1a3306-b40c-4277-8c03-5e317063af3b	6	2026	JEIZIEL ASSIS	2026-06-18	2026-06-18	SEM PENDÊNCIA	2026-07-02 20:03:24.409947+00	\N
d4131c7f-049a-4ef2-a554-00e9c962afc0	f6f57e02-f34d-4586-9bc2-d32da81a6931	6	2026	ANDRESSA	2026-06-30	2026-07-03	\N	2026-07-03 12:00:21.276805+00	\N
7f150949-c7cd-4640-b99d-e1c4bc0c3559	1a02849c-86c8-40b7-920d-7f20937d758b	6	2026	ANDRESSA	2026-06-30	2026-07-03	\N	2026-07-03 12:00:32.62343+00	\N
4f67ae85-f044-46af-886d-985d91249271	326e50c1-0ebc-4674-8bf9-a9cac9ea998d	6	2026	ANDRESSA	2026-06-30	2026-07-03	\N	2026-07-03 12:00:39.519076+00	\N
509518b4-6df9-4936-afd7-87a766c30cf3	8492df23-4608-4b03-a3dc-7e25f361909f	6	2026	ANDRESSA	2026-06-30	2026-07-03	\N	2026-07-03 12:00:50.056332+00	\N
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
7dfb01a9-7b7a-496c-94d2-3792363669d2	2026-07-02	616	JOAO TAVARES DE SENA	SYNGENTA GUARDA-CHUVA	07:00	\N	PRESENTE	\N	2026-07-03 10:43:23.664604+00	06:49
2715762b-1a5a-4153-abed-62eface2529f	2026-07-02	10044	ADILSON DOS SANTOS	SYNGENTA GUARDA-CHUVA	07:00	\N	PRESENTE	\N	2026-07-03 10:43:23.664604+00	06:51
79da13e5-ce8b-4b2a-a99f-bc496923d65e	2026-07-02	70156	JOSE CARLOS PEREIRA DOS SANTOS	SYNGENTA GUARDA-CHUVA	07:00	\N	PRESENTE	\N	2026-07-03 10:43:23.664604+00	06:51
f047686d-cd2d-4663-846c-4d546563476e	2026-07-02	70969	EDSON JOSÉ NOGUEIRA	SYNGENTA GUARDA-CHUVA	07:00	\N	PRESENTE	\N	2026-07-03 10:43:23.664604+00	06:50
78f0229c-8d44-4d0c-ba0e-d8b0e4c53691	2026-07-02	71687	CICERO ROMAO MONTEIRO	SYNGENTA GUARDA-CHUVA	07:00	\N	PRESENTE	\N	2026-07-03 10:43:23.664604+00	06:51
8ad58898-f49d-4272-9853-b99750ed3a4b	2026-07-02	72216	MARCOS SALLES FERREIRA	SYNGENTA GUARDA-CHUVA	07:00	\N	PRESENTE	\N	2026-07-03 10:43:23.664604+00	06:51
a7dde37a-bf42-4608-a431-6b790e9c2a52	2026-07-02	72587	BRUNO GUSTAVO COELHO	SYNGENTA GUARDA-CHUVA	07:00	\N	PRESENTE	\N	2026-07-03 10:43:23.664604+00	06:54
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
9ad5458c-151d-452c-87d4-4e0d44ac8b91	2026-07-02	73244	VINICIUS ASTORINO BIZELLI	SYNGENTA GUARDA-CHUVA	07:00	\N	PRESENTE	\N	2026-07-03 10:43:23.664604+00	07:00
8aafbc93-831d-40e4-ba76-9aba8884273d	2026-07-02	73557	ANTONIO JOSE DOS SANTOS	SYNGENTA GUARDA-CHUVA	07:00	\N	PRESENTE	\N	2026-07-03 10:43:23.664604+00	06:52
f4bcf3da-e7ab-49ed-9c56-3d86b977e05b	2026-07-02	74846	JOSE EDUARDO DA SILVA SIQUEIRA	SYNGENTA GUARDA-CHUVA	07:00	\N	PRESENTE	\N	2026-07-03 10:43:23.664604+00	06:50
323d2e8f-bd61-4e71-929a-fea1d1848e4a	2026-07-02	74847	DANIEL FEITOSA DOS SANTOS	SYNGENTA GUARDA-CHUVA	07:00	\N	PRESENTE	\N	2026-07-03 10:43:23.664604+00	06:51
961739d7-4735-478f-9bd7-54a6637f8008	2026-07-02	74854	OZIEL ANDERSON DOS SANTOS	SYNGENTA GUARDA-CHUVA	07:00	\N	PRESENTE	\N	2026-07-03 10:43:23.664604+00	06:48
3e01c286-8346-49fe-bb18-6411700504d6	2026-07-02	74857	PAULO RODRIGO PEREIRA PACHECO	SYNGENTA GUARDA-CHUVA	07:00	\N	PRESENTE	\N	2026-07-03 10:43:23.664604+00	06:50
ff44b3ff-7d90-433b-88a6-1a9af1b7a7e9	2026-07-02	74869	ADAILSON DOS SANTOS MATOS	SYNGENTA GUARDA-CHUVA	07:00	\N	PRESENTE	\N	2026-07-03 10:43:23.664604+00	06:50
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
f63c480e-1b11-4c04-9d3a-0b957a4997b3	2026-07-02	75132	THIAGO RODRIGUES DE BRITO	SYNGENTA GUARDA-CHUVA	07:00	\N	PRESENTE	\N	2026-07-03 10:43:23.664604+00	06:51
4aa18099-e851-49be-a470-c3d87d60e1b2	2026-07-02	75621	ALAN DOMINGUES BARBOSA	SYNGENTA GUARDA-CHUVA	07:00	\N	PRESENTE	\N	2026-07-03 10:43:23.664604+00	06:53
40803981-20d7-47d2-9f29-97f27d1d5b99	2026-07-02	75693	DAVID MAKLIN DOS ANJOS OLIVEIRA	SYNGENTA GUARDA-CHUVA	07:00	\N	PRESENTE	\N	2026-07-03 10:43:23.664604+00	06:41
055bfb2c-503d-44c0-97a5-e8407ca030b0	2026-07-02	75699	LUIS FERNANDO DIAS LOUZEIRO	SYNGENTA GUARDA-CHUVA	07:00	\N	PRESENTE	\N	2026-07-03 10:43:23.664604+00	06:48
39402bdd-6b1a-4c09-b87c-e98f14c9fb06	2026-07-02	75728	ANDRESSA PEREIRA SAMPAIO GARCIA	SYNGENTA GUARDA-CHUVA	07:00	\N	PRESENTE	\N	2026-07-03 10:43:23.664604+00	07:00
50a4f4af-45f3-4392-9db3-0adc1882af18	2026-07-02	75740	UEDINER ALCIDES MARTINS	SYNGENTA GUARDA-CHUVA	07:00	\N	PRESENTE	\N	2026-07-03 10:43:23.664604+00	07:01
599c96ab-51fb-4122-acca-f7175d16541c	2026-07-02	75763	GUSTAVO XAVIER BARBOSA	SYNGENTA GUARDA-CHUVA	07:00	\N	PRESENTE	\N	2026-07-03 10:43:23.664604+00	06:41
54b48aa6-24d1-470f-a9d7-c51dc58f1137	2026-07-02	75776	JERRY DA CONCEIÇÃO SALES	SYNGENTA GUARDA-CHUVA	07:00	\N	PRESENTE	\N	2026-07-03 10:43:23.664604+00	06:52
971472eb-a13c-41e7-9720-625f7da6687d	2026-07-02	75788	RAIMUNDO DIAS	SYNGENTA GUARDA-CHUVA	07:00	\N	PRESENTE	\N	2026-07-03 10:43:23.664604+00	06:49
10a9eb89-3abc-461a-a156-0f27d30449e2	2026-07-02	75803	EMILY VITORIA CARDOSO DA SILVA	SYNGENTA GUARDA-CHUVA	07:00	\N	PRESENTE	\N	2026-07-03 10:43:23.664604+00	06:56
b06f8a73-4e25-41eb-95ed-c0e5326c217f	2026-07-02	75839	ERIKA SANTOS DE LIMA	SYNGENTA GUARDA-CHUVA	07:00	\N	PRESENTE	\N	2026-07-03 10:43:23.664604+00	07:00
98b8544a-cfa5-4b4d-a899-740e4e7a08ea	2026-07-02	75845	JOAO CARLOS ALVES DA SILVA	SYNGENTA GUARDA-CHUVA	07:00	\N	PRESENTE	\N	2026-07-03 10:43:23.664604+00	06:52
dafa7fc4-f941-4ecd-aa86-4fbceceec209	2026-07-02	75906	JEFFERSON GERSON MENDES DA SILVA	SYNGENTA GUARDA-CHUVA	07:00	\N	PRESENTE	\N	2026-07-03 10:43:23.664604+00	06:56
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
d5975d38-de20-4d16-996e-85efad719bf6	2026-06-23	10620	RAIMUNDO NONATO DO NASCIMENTO SANTOS	QUIMICA AMPARO YPE-SP	07:00	\N	PRESENTE	\N	2026-06-23 20:58:43.092762+00	06:52
b835c95e-9985-4f32-ba5f-e7d524dae235	2026-06-23	70252	USIEL BRAZ RIBEIRO	QUIMICA AMPARO YPE-SP	07:00	\N	PRESENTE	\N	2026-06-23 20:58:43.092762+00	06:57
902e3ff7-b1fa-4d98-a9af-c37b3def2bf1	2026-06-23	71109	GILSON COELHO MESSIAS	QUIMICA AMPARO YPE-SP	07:00	\N	PRESENTE	\N	2026-06-23 20:58:43.092762+00	06:58
b5a8fb73-1464-4eed-aca7-5596932b22a1	2026-06-23	71110	DIEGO FERREIRA ALVES	QUIMICA AMPARO YPE-SP	07:00	\N	PRESENTE	\N	2026-06-23 20:58:43.092762+00	07:00
43dfd6e7-dfee-4f6b-98fa-42cb2b068de7	2026-06-23	72113	AILTON OLIVEIRA SOUSA	QUIMICA AMPARO YPE-SP	07:00	\N	PRESENTE	\N	2026-06-23 20:58:43.092762+00	06:55
44dcc34d-6ae2-4ee8-a9a7-736a09782d5c	2026-06-23	72362	GUSTAVO HENRIQUE CARTACHO LIMA DO NASCIMENTO	QUIMICA AMPARO YPE-SP	07:00	\N	PRESENTE	\N	2026-06-23 20:58:43.092762+00	06:58
4bfbdf42-4987-43d8-8845-50b190484cfc	2026-06-23	73019	JEIZIEL ALVES SILVA DE ASSIS	QUIMICA AMPARO YPE-SP	07:00	\N	PRESENTE	\N	2026-06-23 20:58:43.092762+00	06:50
f9ba6cec-256f-4b2f-87e5-710c46d29925	2026-06-23	73163	JOSE HERCULES DA SILVA	QUIMICA AMPARO YPE-SP	07:00	\N	PRESENTE	\N	2026-06-23 20:58:43.092762+00	06:56
07adda65-9e5d-48e0-a528-aba4b2e9fe70	2026-06-23	73569	EMILLE MARIANE CARDOSO RAMOS	QUIMICA AMPARO YPE-SP	07:00	\N	PRESENTE	\N	2026-06-23 20:58:43.092762+00	07:02
b19bba4f-3208-4085-8e24-76475bdc1ecd	2026-06-23	73944	ANDRE LUIS CASTELO BRANCO	QUIMICA AMPARO YPE-SP	07:00	\N	PRESENTE	\N	2026-06-23 20:58:43.092762+00	06:58
654ac8e2-a0d4-4f95-b1b1-ceb6a39c984c	2026-06-23	74785	ALTAIR DA SILVA MARTINS	QUIMICA AMPARO YPE-SP	07:00	\N	PRESENTE	\N	2026-06-23 20:58:43.092762+00	06:55
22a8f450-d71f-494e-99c1-c3e05a142fa8	2026-06-23	75088	ANTONIO EDNILSON SERAFIM DE OLIVEIRA	QUIMICA AMPARO YPE-SP	07:00	\N	PRESENTE	\N	2026-06-23 20:58:43.092762+00	06:55
e670381b-1369-466e-ae11-cda923cdc561	2026-06-23	75193	DIOGO DOS SANTOS ARAUJO	QUIMICA AMPARO YPE-SP	07:00	\N	PRESENTE	\N	2026-06-23 20:58:43.092762+00	06:55
1e75eeef-ff31-4160-9a81-a76f8c401863	2026-06-23	75251	ARTHUR HENRIQUE NICACIO DA SILVA	QUIMICA AMPARO YPE-SP	07:00	\N	PRESENTE	\N	2026-06-23 20:58:43.092762+00	06:57
ef9ad6d5-a278-4490-ac2d-3eb201efe7e9	2026-06-23	75532	DENIS BARBOSA DOS SANTOS	QUIMICA AMPARO YPE-SP	07:00	\N	PRESENTE	\N	2026-06-23 20:58:43.092762+00	07:01
081fd687-3543-4f43-af67-604f49d2226f	2026-06-23	75550	EDMAR GUILHERMINO DA SILVA	QUIMICA AMPARO YPE-SP	07:00	\N	PRESENTE	\N	2026-06-23 20:58:43.092762+00	06:55
a855f716-514a-489f-a712-4a384490b89a	2026-06-23	75708	FRANCISCO SANTIAGO DA SILVA	QUIMICA AMPARO YPE-SP	07:00	\N	PRESENTE	\N	2026-06-23 20:58:43.092762+00	07:01
d225cddb-faec-4bb7-9f40-a377d9e68628	2026-06-23	75785	WATILA RODRIGUES MIRANDA	QUIMICA AMPARO YPE-SP	07:00	\N	PRESENTE	\N	2026-06-23 20:58:43.092762+00	06:50
4291056b-df80-45c5-9c31-ebe6b37b4ec2	2026-06-23	75786	GERALDO ALVES PINTO	QUIMICA AMPARO YPE-SP	07:00	\N	PRESENTE	\N	2026-06-23 20:58:43.092762+00	06:52
9c6d78c2-4e9f-489a-aa94-e07c46be034e	2026-06-23	75787	DEJAILTON JESUS DOS SANTOS	QUIMICA AMPARO YPE-SP	07:00	\N	PRESENTE	\N	2026-06-23 20:58:43.092762+00	07:02
d44661cc-5913-4d8c-8ed6-9642fe99ba66	2026-06-23	75797	EVERTON CHAGAS DE QUEIROZ	QUIMICA AMPARO YPE-SP	07:00	\N	PRESENTE	\N	2026-06-23 20:58:43.092762+00	06:56
70d7169c-3ee0-4452-b2fb-99d07e1d0a4f	2026-06-23	75798	FABIO LUIZ DE FARIAS	QUIMICA AMPARO YPE-SP	07:00	\N	PRESENTE	\N	2026-06-23 20:58:43.092762+00	06:57
368585d7-ac42-49b1-a4ac-c0e3d0ba7c2d	2026-06-23	75799	WILLIAM SIDNEY SANTOS	QUIMICA AMPARO YPE-SP	07:00	\N	PRESENTE	\N	2026-06-23 20:58:43.092762+00	06:57
3f1b2533-d6af-4127-9fa8-c4ef889d1154	2026-06-23	75800	CARLOS HENRIQUE AUGUSTO ARAUJO	QUIMICA AMPARO YPE-SP	07:00	\N	PRESENTE	\N	2026-06-23 20:58:43.092762+00	06:56
224ae08f-01d7-46cc-a75a-a947c3a2d235	2026-06-23	75805	JOSE RENATO DA GLORIA SANTOS	QUIMICA AMPARO YPE-SP	07:00	\N	PRESENTE	\N	2026-06-23 20:58:43.092762+00	06:50
82f64a1b-4c05-49b9-a720-86249e45fad0	2026-06-23	75808	MARCOS BISPO ASSUNCAO	QUIMICA AMPARO YPE-SP	07:00	\N	PRESENTE	\N	2026-06-23 20:58:43.092762+00	06:51
c33ac480-877d-4605-8eb5-71cdcc3ee897	2026-06-23	75809	JONAS DE OLIVEIRA	QUIMICA AMPARO YPE-SP	07:00	\N	PRESENTE	\N	2026-06-23 20:58:43.092762+00	07:01
88590bfd-b436-49c1-94ee-675b1f87cd39	2026-06-23	75810	PEDRO JUNIOR CELESTINO DE OLIVEIRA	QUIMICA AMPARO YPE-SP	07:00	\N	PRESENTE	\N	2026-06-23 20:58:43.092762+00	07:00
04436bd0-2f59-42ac-b941-1763548525db	2026-06-23	75811	CRISTIAN FABIO DOS SANTOS DOS REIS	QUIMICA AMPARO YPE-SP	07:00	\N	PRESENTE	\N	2026-06-23 20:58:43.092762+00	06:51
7660d380-3a26-423a-87d9-3f988db7263e	2026-06-23	75812	ESMAEL CARLOS NASCIMENTO DOS SANTOS	QUIMICA AMPARO YPE-SP	07:00	\N	PRESENTE	\N	2026-06-23 20:58:43.092762+00	06:50
49acb263-5753-4bbc-98a5-54c58d59c4a5	2026-06-23	75813	JADSON SANTOS DOS SANTOS	QUIMICA AMPARO YPE-SP	07:00	\N	PRESENTE	\N	2026-06-23 20:58:43.092762+00	06:56
8a03d75f-a4f1-499a-be6c-b0a645abe0f2	2026-06-23	75814	RICARDO CESAR COSTA SANTOS	QUIMICA AMPARO YPE-SP	07:00	\N	PRESENTE	\N	2026-06-23 20:58:43.092762+00	06:57
d83d5b7c-e0cf-473a-b04e-d54cab3b0318	2026-06-23	75815	RONALDO BARBOSA DE OLIVEIRA	QUIMICA AMPARO YPE-SP	07:00	\N	PRESENTE	\N	2026-06-23 20:58:43.092762+00	06:50
6c82f5ff-4198-4d39-b8ec-9fdd14bbcc68	2026-06-23	75821	MARCILIO NUNES DE SOUSA	QUIMICA AMPARO YPE-SP	07:00	\N	PRESENTE	\N	2026-06-23 20:58:43.092762+00	06:50
b66d9afb-fd9a-4394-bddd-19ed92beee3a	2026-06-23	75822	JOSE MARCELO DE SOUSA	QUIMICA AMPARO YPE-SP	07:00	\N	PRESENTE	\N	2026-06-23 20:58:43.092762+00	06:50
a710e715-69c2-47d4-ac6c-f083a194b6e6	2026-06-23	75826	ALEXSANDRO DE CAMPOS	QUIMICA AMPARO YPE-SP	07:00	\N	PRESENTE	\N	2026-06-23 20:58:43.092762+00	07:01
f6fceb8a-6213-4919-8603-474e1f30643b	2026-06-23	75828	ALEX LORENZO MATOS SANTOS	QUIMICA AMPARO YPE-SP	07:00	\N	PRESENTE	\N	2026-06-23 20:58:43.092762+00	07:01
a2f16948-1b8d-48c8-9f6c-528510ec5332	2026-06-23	75829	WARLEM ALVES	QUIMICA AMPARO YPE-SP	07:00	\N	PRESENTE	\N	2026-06-23 20:58:43.092762+00	07:01
b5f2eb90-a9c3-46db-84e0-9897005dd6bb	2026-06-23	75830	CLAUDIO ASTRO CARVALHO	QUIMICA AMPARO YPE-SP	07:00	\N	PRESENTE	\N	2026-06-23 20:58:43.092762+00	07:00
0ccf8ad9-87eb-4061-b025-7e166c6da9ee	2026-06-23	75831	ADRIANO FERREIRA GOMES	QUIMICA AMPARO YPE-SP	07:00	\N	PRESENTE	\N	2026-06-23 20:58:43.092762+00	07:00
ce7079cb-8711-46f6-9911-e4c38e8b457a	2026-06-23	75833	UBIRAJARA MENDONCA DOS SANTOS	QUIMICA AMPARO YPE-SP	07:00	\N	PRESENTE	\N	2026-06-23 20:58:43.092762+00	07:01
080b315a-c5d1-4e18-985e-5c5994dbb931	2026-06-23	75834	JERRI SANTOS DA CONCEICAO PINTO	QUIMICA AMPARO YPE-SP	07:00	\N	PRESENTE	\N	2026-06-23 20:58:43.092762+00	07:01
ec71a4ca-2256-43e2-83b0-bfcac7b4a2b0	2026-06-23	75835	LAMEQUE RODRIGUES SILVA SOARES	QUIMICA AMPARO YPE-SP	07:00	\N	PRESENTE	\N	2026-06-23 20:58:43.092762+00	07:01
89a7d1b1-56a0-47ec-849a-2b934ee742bf	2026-06-23	75836	JOELSON GONCALVES MARQUES	QUIMICA AMPARO YPE-SP	07:00	\N	PRESENTE	\N	2026-06-23 20:58:43.092762+00	07:01
f051d28f-546d-4497-9168-319f3c6261ee	2026-06-23	75837	GERSONIEL SOUSA RODRIGUES	QUIMICA AMPARO YPE-SP	07:00	\N	PRESENTE	\N	2026-06-23 20:58:43.092762+00	07:01
85f167d2-9767-435e-a9f7-555a97ea7fca	2026-06-23	75841	MARCELO SILVA	QUIMICA AMPARO YPE-SP	07:00	\N	PRESENTE	\N	2026-06-23 20:58:43.092762+00	07:00
7fcf54c4-6af8-493d-aedf-33560410a9c5	2026-06-23	75846	SIRLEI DA SILVA GILBERTO	QUIMICA AMPARO YPE-SP	07:00	\N	PRESENTE	\N	2026-06-23 20:58:43.092762+00	07:02
cd267335-38a3-48ba-8dc3-471cb9394cf6	2026-06-23	75847	GABRIEL OLIVEIRA DOS SANTOS	QUIMICA AMPARO YPE-SP	07:00	\N	PRESENTE	\N	2026-06-23 20:58:43.092762+00	06:50
f0720901-05ac-452b-9e97-eb7d61114731	2026-06-23	75848	ANTONIO DA SILVA FREITAS	QUIMICA AMPARO YPE-SP	07:00	\N	PRESENTE	\N	2026-06-23 20:58:43.092762+00	06:51
fa096300-b733-48b8-9aa8-be49c34f8a3e	2026-06-23	75849	LUIZ GABRIEL DOS SANTOS ATAIDE	QUIMICA AMPARO YPE-SP	07:00	\N	PRESENTE	\N	2026-06-23 20:58:43.092762+00	06:51
001b2d27-fa71-4050-848b-4c24b4c9b002	2026-06-23	75850	MARIA DAS GRACAS DOS SANTOS E SILVA	QUIMICA AMPARO YPE-SP	07:00	\N	PRESENTE	\N	2026-06-23 20:58:43.092762+00	06:52
2f21aee5-a519-49c0-824d-6adced3d3f01	2026-06-23	75851	ANTONIO SANTOS PORTUGAL	QUIMICA AMPARO YPE-SP	07:00	\N	PRESENTE	\N	2026-06-23 20:58:43.092762+00	06:51
bb84de49-c22c-41d7-80e5-fe7738f26c04	2026-06-23	75853	ARGEL QUEIROZ SANTANA	QUIMICA AMPARO YPE-SP	07:00	\N	PRESENTE	\N	2026-06-23 20:58:43.092762+00	07:02
175abbc9-2651-4f4c-937f-67e7ccfc02d2	2026-06-23	75854	JORGE HUGO BARBOSA DUARTE	QUIMICA AMPARO YPE-SP	07:00	\N	PRESENTE	\N	2026-06-23 20:58:43.092762+00	07:05
4a3e34f9-a86f-44a8-a5f1-29fbc041328f	2026-06-23	75864	ANTONIO DAMASCENO NOGUEIRA	QUIMICA AMPARO YPE-SP	07:00	\N	PRESENTE	\N	2026-06-23 20:58:43.092762+00	06:56
6ffb9598-6c31-42a3-a2c1-e041ae1c2a33	2026-06-23	75865	KAWANN DOS SANTOS TENORIO FEITOSA	QUIMICA AMPARO YPE-SP	07:00	\N	PRESENTE	\N	2026-06-23 20:58:43.092762+00	06:51
866b5172-4940-43ba-b08d-441a6142f25a	2026-06-23	75866	IVANILDO DE JESUS SANTOS	QUIMICA AMPARO YPE-SP	07:00	\N	PRESENTE	\N	2026-06-23 20:58:43.092762+00	06:51
99e962bc-5509-40aa-aa2a-23de1a161d6f	2026-06-23	75867	ROSEMEIRE DE SOUZA MACHADO	QUIMICA AMPARO YPE-SP	07:00	\N	PRESENTE	\N	2026-06-23 20:58:43.092762+00	06:52
7e213727-9bbf-481e-ab04-b67c6b051aad	2026-06-23	75880	NAIRAN DOS SANTOS	QUIMICA AMPARO YPE-SP	07:00	\N	PRESENTE	\N	2026-06-23 20:58:43.092762+00	06:56
997bfde5-d837-4166-86b8-fbe9bea7c0af	2026-06-23	75887	NIVALDO MANUEL DOS SANTOS	QUIMICA AMPARO YPE-SP	07:00	\N	PRESENTE	\N	2026-06-23 20:58:43.092762+00	06:56
5b578987-6ec4-4072-8adc-8dc71025ae80	2026-06-23	75888	PAULO RANGEL DE SA PACHECO	QUIMICA AMPARO YPE-SP	07:00	\N	PRESENTE	\N	2026-06-23 20:58:43.092762+00	06:56
9ca6b869-af12-4edf-b18c-18ad31ba78b7	2026-06-23	75889	FRANCISCO WELLINGTON SILVA LEITE	QUIMICA AMPARO YPE-SP	07:00	\N	PRESENTE	\N	2026-06-23 20:58:43.092762+00	06:55
bb9201d6-a568-4e62-9ca9-5c5f16edec26	2026-06-23	75891	JOAO PAULO DO CARMO	QUIMICA AMPARO YPE-SP	07:00	\N	PRESENTE	\N	2026-06-23 20:58:43.092762+00	06:52
8338738d-e908-4058-a613-b6544e264c69	2026-01-06	616	JOAO TAVARES DE SENA	SYNGENTA GUARDA-CHUVA	07:00	\N	PRESENTE	\N	2026-07-01 17:07:57.86926+00	06:47
8a7ef6bf-55a7-4568-b8d9-c6910544fb6d	2026-01-06	10044	ADILSON DOS SANTOS	SYNGENTA GUARDA-CHUVA	07:00	\N	PRESENTE	\N	2026-07-01 17:07:57.86926+00	06:47
4cc527e8-09ea-4214-88f6-c606a4efe70c	2026-01-06	70156	JOSE CARLOS PEREIRA DOS SANTOS	SYNGENTA GUARDA-CHUVA	07:00	\N	PRESENTE	\N	2026-07-01 17:07:57.86926+00	06:48
c1f36bcb-5e63-44f5-afcf-dc515da5f340	2026-01-06	70969	EDSON JOSÉ NOGUEIRA	SYNGENTA GUARDA-CHUVA	07:00	\N	PRESENTE	\N	2026-07-01 17:07:57.86926+00	06:52
bf2e44d4-e04a-43bb-85a9-a511d39f0e09	2026-01-06	71687	CICERO ROMAO MONTEIRO	SYNGENTA GUARDA-CHUVA	07:00	\N	PRESENTE	\N	2026-07-01 17:07:57.86926+00	06:57
fd572b50-dcd6-4f68-b4c1-9546abd7fb40	2026-01-06	72216	MARCOS SALLES FERREIRA	SYNGENTA GUARDA-CHUVA	07:00	\N	PRESENTE	\N	2026-07-01 17:07:57.86926+00	06:47
6247a1db-8abf-4a23-aac9-0df2e3185a4a	2026-01-06	72587	BRUNO GUSTAVO COELHO	SYNGENTA GUARDA-CHUVA	07:00	\N	PRESENTE	\N	2026-07-01 17:07:57.86926+00	06:53
20e83ace-29d7-4ed6-baa9-4bc865cef78e	2026-01-06	73244	VINICIUS ASTORINO BIZELLI	SYNGENTA GUARDA-CHUVA	07:00	\N	PRESENTE	\N	2026-07-01 17:07:57.86926+00	07:00
3114aad8-1eca-426f-83af-bcc23a3a0938	2026-01-06	73557	ANTONIO JOSE DOS SANTOS	SYNGENTA GUARDA-CHUVA	07:00	\N	PRESENTE	\N	2026-07-01 17:07:57.86926+00	06:49
7e85c7c3-5ff9-4bf1-b4a4-fb7a7dcbef5e	2026-01-06	74846	JOSE EDUARDO DA SILVA SIQUEIRA	SYNGENTA GUARDA-CHUVA	07:00	\N	PRESENTE	\N	2026-07-01 17:07:57.86926+00	06:47
59e00758-3748-40e8-8e6a-24a3bb31c869	2026-01-06	74847	DANIEL FEITOSA DOS SANTOS	SYNGENTA GUARDA-CHUVA	07:00	\N	PRESENTE	\N	2026-07-01 17:07:57.86926+00	06:47
31f112fa-0997-4761-8c1a-bc9976bdd395	2026-01-06	74854	OZIEL ANDERSON DOS SANTOS	SYNGENTA GUARDA-CHUVA	07:00	\N	PRESENTE	\N	2026-07-01 17:07:57.86926+00	06:42
bad55a21-a887-4dbf-9e70-6238ef701b59	2026-01-06	74857	PAULO RODRIGO PEREIRA PACHECO	SYNGENTA GUARDA-CHUVA	07:00	\N	PRESENTE	\N	2026-07-01 17:07:57.86926+00	06:47
ea4c884b-2b9e-43e3-847c-2a147da39fd0	2026-01-06	74869	ADAILSON DOS SANTOS MATOS	SYNGENTA GUARDA-CHUVA	07:00	\N	PRESENTE	\N	2026-07-01 17:07:57.86926+00	06:47
131d32de-6da2-4ef9-a9bc-e96eeffb89a9	2026-01-06	75132	THIAGO RODRIGUES DE BRITO	SYNGENTA GUARDA-CHUVA	07:00	\N	PRESENTE	\N	2026-07-01 17:07:57.86926+00	06:48
18d5c9fa-c35a-4fdb-97a4-bec5e3dc438c	2026-01-06	75621	ALAN DOMINGUES BARBOSA	SYNGENTA GUARDA-CHUVA	07:00	\N	PRESENTE	\N	2026-07-01 17:07:57.86926+00	06:54
1aac1bc6-ec2e-4727-ad7c-14fbd1d6870a	2026-01-06	75693	DAVID MAKLIN DOS ANJOS OLIVEIRA	SYNGENTA GUARDA-CHUVA	07:00	\N	PRESENTE	\N	2026-07-01 17:07:57.86926+00	07:07
b6a47555-f80d-4491-8040-b7b49655c69a	2026-01-06	75699	LUIS FERNANDO DIAS LOUZEIRO	SYNGENTA GUARDA-CHUVA	07:00	\N	PRESENTE	\N	2026-07-01 17:07:57.86926+00	06:47
6f7a6e86-fa3e-49bc-8089-5ab010cb1909	2026-01-06	75728	ANDRESSA PEREIRA SAMPAIO GARCIA	SYNGENTA GUARDA-CHUVA	07:00	\N	PRESENTE	\N	2026-07-01 17:07:57.86926+00	07:00
b4bd67f4-20f9-4715-a641-534a7d27755a	2026-01-06	75740	UEDINER ALCIDES MARTINS	SYNGENTA GUARDA-CHUVA	07:00	\N	PRESENTE	\N	2026-07-01 17:07:57.86926+00	07:07
70bf3d82-17de-421b-b2c1-44651f8a3614	2026-01-06	75763	GUSTAVO XAVIER BARBOSA	SYNGENTA GUARDA-CHUVA	07:00	\N	PRESENTE	\N	2026-07-01 17:07:57.86926+00	06:40
f4e5a3ed-5e17-4079-a5bc-74084a68b1af	2026-01-06	75776	JERRY DA CONCEIÇÃO SALES	SYNGENTA GUARDA-CHUVA	07:00	\N	PRESENTE	\N	2026-07-01 17:07:57.86926+00	06:48
0ae6a39d-47dd-446b-9933-2d56d694cd28	2026-01-06	75788	RAIMUNDO DIAS	SYNGENTA GUARDA-CHUVA	07:00	\N	PRESENTE	\N	2026-07-01 17:07:57.86926+00	06:59
d0a33ba7-d680-428b-995c-e42a82865f42	2026-01-06	75803	EMILY VITORIA CARDOSO DA SILVA	SYNGENTA GUARDA-CHUVA	07:00	\N	PRESENTE	\N	2026-07-01 17:07:57.86926+00	06:54
8f252af9-a035-41f3-a44c-76a4479ef820	2026-01-06	75816	CARLITO FLORENCIO DOS SANTOS	SYNGENTA GUARDA-CHUVA	07:00	\N	PRESENTE	\N	2026-07-01 17:07:57.86926+00	06:46
e7ab81a6-416f-4921-8271-4e59637da557	2026-01-06	75839	ERIKA SANTOS DE LIMA	SYNGENTA GUARDA-CHUVA	07:00	\N	PRESENTE	\N	2026-07-01 17:07:57.86926+00	09:00
f2bf8cf3-882d-4cb5-a217-a89b01d2f48a	2026-01-06	75845	JOAO CARLOS ALVES DA SILVA	SYNGENTA GUARDA-CHUVA	07:00	\N	PRESENTE	\N	2026-07-01 17:07:57.86926+00	06:55
43d42303-3c40-4d8c-990c-95abdcaae072	2026-01-06	75906	JEFFERSON GERSON MENDES DA SILVA	SYNGENTA GUARDA-CHUVA	07:00	\N	PRESENTE	\N	2026-07-01 17:07:57.86926+00	07:17
434ddf5f-2bf1-4abc-adf6-0df236721782	2026-07-03	70201	CARLOS JOSE RODRIGUES	DAICHII FILIAL	07:00	\N	PRESENTE	\N	2026-07-03 12:56:36.023453+00	06:50
289f8d6b-1d16-40c3-a343-3a8651738c27	2026-07-03	71144	CARLOS HENRIQUE FERREIRA SOUZA	DAICHII FILIAL	09:00	\N	PRESENTE	\N	2026-07-03 12:56:36.023453+00	08:01
b4b0deb9-69e9-4005-875f-3376ff96910a	2026-07-03	73254	CAUAN DE AQUINO	DAICHII FILIAL	07:00	\N	PRESENTE	\N	2026-07-03 12:56:36.023453+00	07:00
2e95ff5b-ca39-40d8-b69e-1af42d017d94	2026-07-03	73504	JURANDIR  DA SILVA BARAUNA	DAICHII FILIAL	07:00	\N	PRESENTE	\N	2026-07-03 12:56:36.023453+00	06:50
10ee03af-0677-45e6-ab05-68ef184e5013	2026-07-03	73929	JOAO PAULO BALIZA MUNDIM	DAICHII FILIAL	07:00	\N	PRESENTE	\N	2026-07-03 12:56:36.023453+00	06:54
34c9a97e-f48b-4be8-abd5-d0f3188013cb	2026-07-03	74250	ALDAIR DA SILVA OLIVEIRA	DAICHII FILIAL	07:00	\N	PRESENTE	\N	2026-07-03 12:56:36.023453+00	06:52
434594d9-4637-48a1-87ea-2a436fbf9033	2026-07-03	75172	JOSE MARQUES FERREIRA NETO	DAICHII FILIAL	07:00	\N	PRESENTE	\N	2026-07-03 12:56:36.023453+00	06:51
62f2a0ed-d0d1-40f3-bf61-f00df90d2d3e	2026-07-03	75385	IGLESSE ALMEIDA DO NASCIMENTO	DAICHII FILIAL	07:00	\N	PRESENTE	\N	2026-07-03 12:56:36.023453+00	06:50
924e5bbc-8482-46ce-872c-b439bfb1b74c	2026-07-03	75467	DENNYS HENRIQUE JOSE DA SILVA	DAICHII FILIAL	07:00	\N	PRESENTE	\N	2026-07-03 12:56:36.023453+00	06:54
3e71c4ea-b034-4b8e-b739-e2db3005edd5	2026-07-03	75502	ANDRESA PINTO	DAICHII FILIAL	07:00	\N	PRESENTE	\N	2026-07-03 12:56:36.023453+00	07:04
6ce2ff67-d9fb-4fb6-aca4-6906767e0194	2026-07-03	75592	HUELBERT MOISES DE OLIVEIRA	DAICHII FILIAL	07:00	\N	PRESENTE	\N	2026-07-03 12:56:36.023453+00	06:49
e087c1b0-96ed-49c3-89a7-9189d12e29bd	2026-06-25	616	JOAO TAVARES DE SENA	SYNGENTA GUARDA-CHUVA	07:00	\N	PRESENTE	\N	2026-06-25 14:04:22.451421+00	06:50
5948cdc4-0828-4ec1-87ee-1cf6bdd9dfdc	2026-06-25	10044	ADILSON DOS SANTOS	SYNGENTA GUARDA-CHUVA	07:00	\N	PRESENTE	\N	2026-06-25 14:04:22.451421+00	06:55
8f9c1254-2ecd-49be-8744-5117921a0bc5	2026-06-25	70156	JOSE CARLOS PEREIRA DOS SANTOS	SYNGENTA GUARDA-CHUVA	07:00	\N	PRESENTE	\N	2026-06-25 14:04:22.451421+00	06:50
ed89ee71-01af-4fbc-a18a-08ec1e8ab4f7	2026-06-25	70969	EDSON JOSÉ NOGUEIRA	SYNGENTA GUARDA-CHUVA	07:00	\N	PRESENTE	\N	2026-06-25 14:04:22.451421+00	06:51
1bb912b5-2ec7-4d81-8a51-31dcbccd027b	2026-06-25	72216	MARCOS SALLES FERREIRA	SYNGENTA GUARDA-CHUVA	07:00	\N	PRESENTE	\N	2026-06-25 14:04:22.451421+00	06:50
c4480c24-7a31-4e3e-836d-1820ed01a116	2026-06-25	72587	BRUNO GUSTAVO COELHO	SYNGENTA GUARDA-CHUVA	07:00	\N	PRESENTE	\N	2026-06-25 14:04:22.451421+00	06:51
dd29dbc9-ef45-4531-988d-e21161cdc9ce	2026-06-25	73332	BRUNO DA CRUZ RODRIGUES	SYNGENTA GUARDA-CHUVA	07:00	\N	PRESENTE	\N	2026-06-25 14:04:22.451421+00	06:51
d19502fc-822a-4911-9585-a516a2123d16	2026-06-25	74846	JOSE EDUARDO DA SILVA SIQUEIRA	SYNGENTA GUARDA-CHUVA	07:00	\N	PRESENTE	\N	2026-06-25 14:04:22.451421+00	06:50
7c4aaab9-041a-44a8-8c11-baec9a69fabc	2026-06-25	74854	OZIEL ANDERSON DOS SANTOS	SYNGENTA GUARDA-CHUVA	07:00	\N	PRESENTE	\N	2026-06-25 14:04:22.451421+00	06:42
fbff6bcb-5836-44d5-9180-d39322bc34b2	2026-06-25	74857	PAULO RODRIGO PEREIRA PACHECO	SYNGENTA GUARDA-CHUVA	07:00	\N	PRESENTE	\N	2026-06-25 14:04:22.451421+00	06:51
23c6fec3-a2f4-4185-bbb3-92adfbc278a0	2026-06-25	74869	ADAILSON DOS SANTOS MATOS	SYNGENTA GUARDA-CHUVA	07:00	\N	PRESENTE	\N	2026-06-25 14:04:22.451421+00	06:50
90d9ca6e-552b-497f-8b5f-58b340ddf9fd	2026-06-25	75132	THIAGO RODRIGUES DE BRITO	SYNGENTA GUARDA-CHUVA	07:00	\N	PRESENTE	\N	2026-06-25 14:04:22.451421+00	06:50
dd67cee3-0790-40ca-81c7-34a872dda941	2026-06-25	75186	ALVARO SALDANHA LIMA	SYNGENTA GUARDA-CHUVA	07:00	\N	PRESENTE	\N	2026-06-25 14:04:22.451421+00	06:51
42912065-63ce-4e9c-bab2-8ab3bb59b830	2026-06-25	75621	ALAN DOMINGUES BARBOSA	SYNGENTA GUARDA-CHUVA	07:00	\N	PRESENTE	\N	2026-06-25 14:04:22.451421+00	07:02
d3e7f413-28af-458e-8c6d-fbb04b62f9b6	2026-06-25	75693	DAVID MAKLIN DOS ANJOS OLIVEIRA	SYNGENTA GUARDA-CHUVA	07:00	\N	PRESENTE	\N	2026-06-25 14:04:22.451421+00	06:42
c23de509-1478-40ed-8b78-a249662af168	2026-06-25	75699	LUIS FERNANDO DIAS LOUZEIRO	SYNGENTA GUARDA-CHUVA	07:00	\N	PRESENTE	\N	2026-06-25 14:04:22.451421+00	06:49
2402b603-af39-4405-8bc9-8fa4b4a388da	2026-06-25	75740	UEDINER ALCIDES MARTINS	SYNGENTA GUARDA-CHUVA	07:00	\N	PRESENTE	\N	2026-06-25 14:04:22.451421+00	06:52
c18e4a84-088b-4f56-9245-e13f8e5397a2	2026-07-03	75687	ROZILMA DE SOUZA CESAR	DAICHII FILIAL	07:00	\N	PRESENTE	\N	2026-07-03 12:56:36.023453+00	06:58
75b22eb0-7954-43d5-b2dd-7128c1d67d73	2026-06-25	75776	JERRY DA CONCEIÇÃO SALES	SYNGENTA GUARDA-CHUVA	07:00	\N	PRESENTE	\N	2026-06-25 14:04:22.451421+00	06:51
6f164597-bf92-447d-b9ca-3be1d276f364	2026-06-25	75779	ALESSANDRO BARBIERI NOGUEIRA	SYNGENTA GUARDA-CHUVA	07:00	\N	PRESENTE	\N	2026-06-25 14:04:22.451421+00	06:50
2e897286-bb89-4346-89e0-8b59a00ebf09	2026-06-25	75793	LUIZ CARLOS FLORENCIO DOS SANTOS	SYNGENTA GUARDA-CHUVA	07:00	\N	PRESENTE	\N	2026-06-25 14:04:22.451421+00	06:51
0f8fd16f-bf13-4646-ae4b-5bedd6ea13f8	2026-06-25	75803	EMILY VITORIA CARDOSO DA SILVA	SYNGENTA GUARDA-CHUVA	07:00	\N	PRESENTE	\N	2026-06-25 14:04:22.451421+00	06:42
e5f40f6e-62ad-4548-b315-a7fb81f53c0d	2026-06-25	75816	CARLITO FLORENCIO DOS SANTOS	SYNGENTA GUARDA-CHUVA	07:00	\N	PRESENTE	\N	2026-06-25 14:04:22.451421+00	06:48
7b48260c-d2aa-4c2b-8d1d-7379d5cc9343	2026-06-25	75839	ERIKA SANTOS DE LIMA	SYNGENTA GUARDA-CHUVA	07:00	\N	PRESENTE	\N	2026-06-25 14:04:22.451421+00	07:04
f5302560-10ec-410f-a0e3-c87033a67280	2026-06-25	75845	JOAO CARLOS ALVES DA SILVA	SYNGENTA GUARDA-CHUVA	07:00	\N	PRESENTE	\N	2026-06-25 14:04:22.451421+00	06:55
a54c5efd-f075-45b2-bef3-4facbaa32f3a	2026-06-27	70201	CARLOS JOSE RODRIGUES	DAICHII FILIAL	\N	\N	PRESENTE	\N	2026-06-27 17:56:37.323355+00	06:50
123d3ddc-4477-47b9-bbd4-2cd3e662397a	2026-06-27	73254	CAUAN DE AQUINO	DAICHII FILIAL	\N	\N	PRESENTE	\N	2026-06-27 17:56:37.323355+00	07:03
b7e64495-83ee-4cd4-97c1-cbfed64b515c	2026-06-27	73504	JURANDIR DA SILVA BARAUNA	DAICHII FILIAL	\N	\N	PRESENTE	\N	2026-06-27 17:56:37.323355+00	06:41
af434fdb-61ef-4d86-8c08-131a115976e4	2026-06-27	73929	JOAO PAULO BALIZA MUNDIM	DAICHII FILIAL	\N	\N	PRESENTE	\N	2026-06-27 17:56:37.323355+00	06:51
472a45f2-1661-4ced-8aca-c054bc6cf5ca	2026-06-27	74250	ALDAIR DA SILVA OLIVEIRA	DAICHII FILIAL	\N	\N	PRESENTE	\N	2026-06-27 17:56:37.323355+00	06:46
1c49288f-56bb-4013-8aaf-1b2bc27b15e7	2026-06-27	75172	JOSE MARQUES FERREIRA NETO	DAICHII FILIAL	\N	\N	PRESENTE	\N	2026-06-27 17:56:37.323355+00	06:52
fd33ed01-45f3-4786-b604-900dca2bc6f8	2026-06-27	75385	IGLESSE ALMEIDA DO NASCIMENTO	DAICHII FILIAL	\N	\N	PRESENTE	\N	2026-06-27 17:56:37.323355+00	06:50
ad79a897-3699-469c-af6d-6a03c2a5905e	2026-06-27	75467	DENNYS HENRIQUE JOSE DA SILVA	DAICHII FILIAL	\N	\N	PRESENTE	\N	2026-06-27 17:56:37.323355+00	06:52
66904f09-07ab-47e4-af6e-9de7c8a6a350	2026-06-27	75687	ROZILMA DE SOUZA CESAR	DAICHII FILIAL	\N	\N	PRESENTE	\N	2026-06-27 17:56:37.323355+00	06:53
bd645afb-2adc-4545-995c-96ea19a3a0da	2026-07-03	75908	AUDIMIR DOS SANTOS	DAICHII FILIAL	07:00	\N	PRESENTE	\N	2026-07-03 12:56:36.023453+00	06:58
6f101b18-9a86-4efa-8992-de80364de65a	2026-07-03	75909	VINICIUS APASSITE BITENCOURT	DAICHII FILIAL	07:00	\N	PRESENTE	\N	2026-07-03 12:56:36.023453+00	06:50
2c81bd2d-9846-46d7-8971-5af8a915858b	2026-07-07	616	JOAO TAVARES DE SENA	SYNGENTA GUARDA-CHUVA	07:00	\N	PRESENTE	\N	2026-07-07 20:06:47.328697+00	06:48
ba4c8ef4-7f75-4931-8701-505c80f8f333	2026-07-07	10044	ADILSON DOS SANTOS	SYNGENTA GUARDA-CHUVA	07:00	\N	PRESENTE	\N	2026-07-07 20:06:47.328697+00	06:50
a08521f6-ff96-43e3-9afd-9648233547a0	2026-07-07	70156	JOSE CARLOS PEREIRA DOS SANTOS	SYNGENTA GUARDA-CHUVA	07:00	\N	PRESENTE	\N	2026-07-07 20:06:47.328697+00	06:52
7ee40e46-6082-4931-935a-c8d020d97256	2026-07-07	70969	EDSON JOSÉ NOGUEIRA	SYNGENTA GUARDA-CHUVA	07:00	\N	PRESENTE	\N	2026-07-07 20:06:47.328697+00	06:48
48322826-41cd-4658-9dd6-6a2a47373df6	2026-07-07	71687	CICERO ROMAO MONTEIRO	SYNGENTA GUARDA-CHUVA	07:00	\N	PRESENTE	\N	2026-07-07 20:06:47.328697+00	06:51
18530fbf-f77b-4448-b303-30f17eacbb6e	2026-07-07	72216	MARCOS SALLES FERREIRA	SYNGENTA GUARDA-CHUVA	07:00	\N	PRESENTE	\N	2026-07-07 20:06:47.328697+00	06:49
a5a1e72e-0457-4b44-8feb-854c632e790a	2026-07-07	72587	BRUNO GUSTAVO COELHO	SYNGENTA GUARDA-CHUVA	07:00	\N	PRESENTE	\N	2026-07-07 20:06:47.328697+00	06:48
4e084905-1fa1-4c7a-9a91-29e537682938	2026-07-07	72683	CLAYTON HENRIQUE DE SOUZA	SYNGENTA GUARDA-CHUVA	07:00	\N	PRESENTE	\N	2026-07-07 20:06:47.328697+00	06:48
241b5119-cf21-42df-8fd1-70ac627ffe6d	2026-07-07	73332	BRUNO DA CRUZ RODRIGUES	SYNGENTA GUARDA-CHUVA	07:00	\N	PRESENTE	\N	2026-07-07 20:06:47.328697+00	06:51
aba4f611-e723-48ab-be6f-5a861d573f93	2026-07-07	73557	ANTONIO JOSE DOS SANTOS	SYNGENTA GUARDA-CHUVA	07:00	\N	PRESENTE	\N	2026-07-07 20:06:47.328697+00	06:52
1d31c7d6-628f-45c7-a16b-52047685dacd	2026-07-07	74846	JOSE EDUARDO DA SILVA SIQUEIRA	SYNGENTA GUARDA-CHUVA	07:00	\N	PRESENTE	\N	2026-07-07 20:06:47.328697+00	06:49
c62a7a28-78e8-4ea0-a161-7662eab63b7e	2026-07-07	74847	DANIEL FEITOSA DOS SANTOS	SYNGENTA GUARDA-CHUVA	07:00	\N	PRESENTE	\N	2026-07-07 20:06:47.328697+00	06:50
c8a34a62-6634-40c0-bf22-811e8d61c0a7	2026-07-07	74854	OZIEL ANDERSON DOS SANTOS	SYNGENTA GUARDA-CHUVA	07:00	\N	PRESENTE	\N	2026-07-07 20:06:47.328697+00	06:50
c24e723c-1fa6-4bbb-9d41-8c7f92d82440	2026-06-30	616	JOAO TAVARES DE SENA	SYNGENTA GUARDA-CHUVA	07:00	\N	PRESENTE	\N	2026-06-30 19:13:26.228637+00	06:48
3a2df8d0-95c9-4bfa-bcbb-2f2b373bfb06	2026-06-30	10044	ADILSON DOS SANTOS	SYNGENTA GUARDA-CHUVA	07:00	\N	PRESENTE	\N	2026-06-30 19:13:26.228637+00	06:50
badb2e09-2ce3-46c7-b817-3d27d41a39c2	2026-06-30	70156	JOSE CARLOS PEREIRA DOS SANTOS	SYNGENTA GUARDA-CHUVA	07:00	\N	PRESENTE	\N	2026-06-30 19:13:26.228637+00	06:50
80b9bdf2-b2d9-43e5-ab16-4ce5c1f6de5f	2026-06-30	71687	CICERO ROMAO MONTEIRO	SYNGENTA GUARDA-CHUVA	07:00	\N	PRESENTE	\N	2026-06-30 19:13:26.228637+00	06:50
e454a385-2fbc-4da1-8c40-aa150adbd6b8	2026-06-30	72216	MARCOS SALLES FERREIRA	SYNGENTA GUARDA-CHUVA	07:00	\N	PRESENTE	\N	2026-06-30 19:13:26.228637+00	06:50
49346efe-9a12-4f81-a546-7e1dcf8f19a0	2026-06-30	74846	JOSE EDUARDO DA SILVA SIQUEIRA	SYNGENTA GUARDA-CHUVA	07:00	\N	PRESENTE	\N	2026-06-30 19:13:26.228637+00	06:50
e1aec996-d6c2-493b-b3b5-b8a1fd8fa8ca	2026-06-30	74847	DANIEL FEITOSA DOS SANTOS	SYNGENTA GUARDA-CHUVA	07:00	\N	PRESENTE	\N	2026-06-30 19:13:26.228637+00	06:50
4d708ae1-74bc-4154-b949-d98d45eceae2	2026-06-30	74854	OZIEL ANDERSON DOS SANTOS	SYNGENTA GUARDA-CHUVA	07:00	\N	PRESENTE	\N	2026-06-30 19:13:26.228637+00	06:49
e84eacdd-ba1d-4606-9c24-7c92351e30e6	2026-06-30	74857	PAULO RODRIGO PEREIRA PACHECO	SYNGENTA GUARDA-CHUVA	07:00	\N	PRESENTE	\N	2026-06-30 19:13:26.228637+00	06:50
5b40267f-ac5c-4096-81ca-ae0ad94f4621	2026-06-30	74869	ADAILSON DOS SANTOS MATOS	SYNGENTA GUARDA-CHUVA	07:00	\N	PRESENTE	\N	2026-06-30 19:13:26.228637+00	06:49
59508aa9-6b74-4179-ae83-9f8ab2442d10	2026-06-30	75132	THIAGO RODRIGUES DE BRITO	SYNGENTA GUARDA-CHUVA	07:00	\N	PRESENTE	\N	2026-06-30 19:13:26.228637+00	06:49
af74787d-1ebe-467e-8285-cfb83d2402e1	2026-06-30	75186	ALVARO SALDANHA LIMA	SYNGENTA GUARDA-CHUVA	07:00	\N	PRESENTE	\N	2026-06-30 19:13:26.228637+00	06:51
801e57e8-a5c8-4b59-b300-7cb3667dc97c	2026-06-30	75621	ALAN DOMINGUES BARBOSA	SYNGENTA GUARDA-CHUVA	07:00	\N	PRESENTE	\N	2026-06-30 19:13:26.228637+00	06:55
da90f830-21b3-4dd8-8e82-e1659484766b	2026-06-30	75693	DAVID MAKLIN DOS ANJOS OLIVEIRA	SYNGENTA GUARDA-CHUVA	07:00	\N	PRESENTE	\N	2026-06-30 19:13:26.228637+00	07:05
160606c4-a4a6-4dac-ba8c-d66cb20fc9b9	2026-06-30	75699	LUIS FERNANDO DIAS LOUZEIRO	SYNGENTA GUARDA-CHUVA	07:00	\N	PRESENTE	\N	2026-06-30 19:13:26.228637+00	06:48
cb0f8ca8-ce1e-4ca7-8922-855b85a13762	2026-06-30	75728	ANDRESSA PEREIRA SAMPAIO GARCIA	SYNGENTA GUARDA-CHUVA	07:00	\N	PRESENTE	\N	2026-06-30 19:13:26.228637+00	07:00
01e0ed22-b85d-4072-8afa-6b1677905166	2026-06-30	75740	UEDINER ALCIDES MARTINS	SYNGENTA GUARDA-CHUVA	07:00	\N	PRESENTE	\N	2026-06-30 19:13:26.228637+00	06:48
d61ba7c1-2f99-461f-b616-3a31e1eb54d7	2026-06-30	75763	GUSTAVO XAVIER BARBOSA	SYNGENTA GUARDA-CHUVA	07:00	\N	PRESENTE	\N	2026-06-30 19:13:26.228637+00	06:44
02f312ba-a4ce-49db-a41e-83cf0f768a59	2026-06-30	75776	JERRY DA CONCEIÇÃO SALES	SYNGENTA GUARDA-CHUVA	07:00	\N	PRESENTE	\N	2026-06-30 19:13:26.228637+00	06:50
55cc0789-7622-4797-a984-39556f009061	2026-06-30	75788	RAIMUNDO DIAS	SYNGENTA GUARDA-CHUVA	07:00	\N	PRESENTE	\N	2026-06-30 19:13:26.228637+00	06:55
3c31e047-567d-4ea7-b1ed-255b90b7b589	2026-06-30	75793	LUIZ CARLOS FLORENCIO DOS SANTOS	SYNGENTA GUARDA-CHUVA	07:00	\N	PRESENTE	\N	2026-06-30 19:13:26.228637+00	06:50
01caaa4d-3590-4199-9b6e-d7a8714f52cb	2026-06-30	75803	EMILY VITORIA CARDOSO DA SILVA	SYNGENTA GUARDA-CHUVA	07:00	\N	PRESENTE	\N	2026-06-30 19:13:26.228637+00	06:51
787a518b-4e71-4e1c-bbc6-45aa78c71658	2026-06-30	75816	CARLITO FLORENCIO DOS SANTOS	SYNGENTA GUARDA-CHUVA	07:00	\N	PRESENTE	\N	2026-06-30 19:13:26.228637+00	06:46
08484379-d7e8-4da0-a8ef-d3f3affcc0b3	2026-06-30	75839	ERIKA SANTOS DE LIMA	SYNGENTA GUARDA-CHUVA	07:00	\N	PRESENTE	\N	2026-06-30 19:13:26.228637+00	06:59
3f43f922-227a-4a8c-8620-12b85ab21cf9	2026-06-30	75845	JOAO CARLOS ALVES DA SILVA	SYNGENTA GUARDA-CHUVA	07:00	\N	PRESENTE	\N	2026-06-30 19:13:26.228637+00	07:01
21901d97-7261-4456-abe4-655338339184	2026-06-30	75906	JEFFERSON GERSON MENDES DA SILVA	SYNGENTA GUARDA-CHUVA	07:00	\N	PRESENTE	\N	2026-06-30 19:13:26.228637+00	06:59
4c8c37f8-4790-4be2-b184-a250fa5f0e04	2026-07-06	70201	CARLOS JOSE RODRIGUES	DAICHII FILIAL	07:00	\N	PRESENTE	\N	2026-07-06 11:25:58.758038+00	06:55
455d0f99-9167-4b6c-b4ce-923214b4fbe2	2026-07-06	71144	CARLOS HENRIQUE FERREIRA SOUZA	DAICHII FILIAL	09:00	\N	PRESENTE	\N	2026-07-06 11:25:58.758038+00	07:04
ef5d33b4-4859-4cd2-a689-4ff9c1fca40c	2026-07-06	73254	CAUAN DE AQUINO	DAICHII FILIAL	07:00	\N	PRESENTE	\N	2026-07-06 11:25:58.758038+00	07:31
62a76134-8da8-4d84-86b8-b2e97862d05b	2026-07-06	73504	JURANDIR  DA SILVA BARAUNA	DAICHII FILIAL	07:00	\N	PRESENTE	\N	2026-07-06 11:25:58.758038+00	06:50
f6430d7d-7cfd-49dc-9b52-2e7f5045e307	2026-07-06	73929	JOAO PAULO BALIZA MUNDIM	DAICHII FILIAL	07:00	\N	PRESENTE	\N	2026-07-06 11:25:58.758038+00	06:50
5e72e6bf-ac94-4761-99d0-3be83e2f1a41	2026-07-06	74250	ALDAIR DA SILVA OLIVEIRA	DAICHII FILIAL	07:00	\N	PRESENTE	\N	2026-07-06 11:25:58.758038+00	06:49
514567b3-0360-4358-b389-8f633155a12f	2026-07-06	75172	JOSE MARQUES FERREIRA NETO	DAICHII FILIAL	07:00	\N	PRESENTE	\N	2026-07-06 11:25:58.758038+00	06:51
588e0da7-533b-4943-9453-a447f1687fb4	2026-07-06	75385	IGLESSE ALMEIDA DO NASCIMENTO	DAICHII FILIAL	07:00	\N	PRESENTE	\N	2026-07-06 11:25:58.758038+00	06:55
5088e8cf-e946-4cff-9364-dfdd06af1cd5	2026-07-06	75467	DENNYS HENRIQUE JOSE DA SILVA	DAICHII FILIAL	07:00	\N	PRESENTE	\N	2026-07-06 11:25:58.758038+00	06:52
d9a4412e-fa84-4f9a-922a-047c8b87999d	2026-07-06	75502	ANDRESA PINTO	DAICHII FILIAL	07:00	\N	PRESENTE	\N	2026-07-06 11:25:58.758038+00	07:02
861481a5-1949-4ca6-bb3f-218f7ccd63ea	2026-07-06	75592	HUELBERT MOISES DE OLIVEIRA	DAICHII FILIAL	07:00	\N	PRESENTE	\N	2026-07-06 11:25:58.758038+00	06:49
70837d75-bc99-492f-91ea-4cf4bf722383	2026-07-06	75687	ROZILMA DE SOUZA CESAR	DAICHII FILIAL	07:00	\N	PRESENTE	\N	2026-07-06 11:25:58.758038+00	06:58
75eba7b9-82b2-4b71-80b0-b0e62a8dc96c	2026-07-06	75908	AUDIMIR DOS SANTOS	DAICHII FILIAL	07:00	\N	PRESENTE	\N	2026-07-06 11:25:58.758038+00	07:01
3221a44e-ff64-4157-8241-b2aad142426c	2026-07-07	74869	ADAILSON DOS SANTOS MATOS	SYNGENTA GUARDA-CHUVA	07:00	\N	PRESENTE	\N	2026-07-07 20:06:47.328697+00	06:49
74796070-2adc-4f85-b413-63d75cdc61da	2026-07-07	75132	THIAGO RODRIGUES DE BRITO	SYNGENTA GUARDA-CHUVA	07:00	\N	PRESENTE	\N	2026-07-07 20:06:47.328697+00	06:50
ca1085d3-7d3a-4343-aafc-e97ad4e552e9	2026-07-07	75693	DAVID MAKLIN DOS ANJOS OLIVEIRA	SYNGENTA GUARDA-CHUVA	07:00	\N	PRESENTE	\N	2026-07-07 20:06:47.328697+00	06:47
fecb5a3e-d592-4cea-b216-91b74b876dca	2026-07-07	75740	UEDINER ALCIDES MARTINS	SYNGENTA GUARDA-CHUVA	07:00	\N	PRESENTE	\N	2026-07-07 20:06:47.328697+00	06:48
1785148a-0cbe-49a7-bd97-b96268c6e826	2026-07-07	75763	GUSTAVO XAVIER BARBOSA	SYNGENTA GUARDA-CHUVA	07:00	\N	PRESENTE	\N	2026-07-07 20:06:47.328697+00	06:41
7f6a9f30-d908-4c4b-b7b9-721beaa1e7f0	2026-07-07	75776	JERRY DA CONCEIÇÃO SALES	SYNGENTA GUARDA-CHUVA	07:00	\N	PRESENTE	\N	2026-07-07 20:06:47.328697+00	06:49
d43298e4-5148-402a-9f91-fc849d27bd5e	2026-07-07	75779	ALESSANDRO BARBIERI NOGUEIRA	SYNGENTA GUARDA-CHUVA	07:00	\N	PRESENTE	\N	2026-07-07 20:06:47.328697+00	06:52
d07d4b4e-69f1-458f-9baf-0147b1f746d3	2026-07-07	75788	RAIMUNDO DIAS	SYNGENTA GUARDA-CHUVA	07:00	\N	PRESENTE	\N	2026-07-07 20:06:47.328697+00	06:53
1dfd146b-4ef5-4f22-af47-7981e647afce	2026-07-07	75803	EMILY VITORIA CARDOSO DA SILVA	SYNGENTA GUARDA-CHUVA	07:00	\N	PRESENTE	\N	2026-07-07 20:06:47.328697+00	06:54
fa7fe15d-d275-4df6-85ea-a6a39ff3f7a7	2026-07-07	75816	CARLITO FLORENCIO DOS SANTOS	SYNGENTA GUARDA-CHUVA	07:00	\N	PRESENTE	\N	2026-07-07 20:06:47.328697+00	06:53
6b89307e-5369-4561-b97e-996956e16f2b	2026-07-07	75839	ERIKA SANTOS DE LIMA	SYNGENTA GUARDA-CHUVA	07:00	\N	PRESENTE	\N	2026-07-07 20:06:47.328697+00	07:02
e615a8a4-81d6-4882-bef7-57072bae5252	2026-07-07	75845	JOAO CARLOS ALVES DA SILVA	SYNGENTA GUARDA-CHUVA	07:00	\N	PRESENTE	\N	2026-07-07 20:06:47.328697+00	06:59
4981e54b-7c31-491a-a29e-6b1d66f9ad16	2026-07-07	75906	JEFFERSON GERSON MENDES DA SILVA	SYNGENTA GUARDA-CHUVA	07:00	\N	PRESENTE	\N	2026-07-07 20:06:47.328697+00	06:59
5e27c56a-4f28-40ff-8d69-e6d4e4f7e54b	2026-02-06	616	JOAO TAVARES DE SENA	SYNGENTA GUARDA-CHUVA	07:00	\N	PRESENTE	\N	2026-07-03 10:38:01.257085+00	06:49
57a29de5-bb05-4448-a6f1-78fd9a2e05d8	2026-02-06	10044	ADILSON DOS SANTOS	SYNGENTA GUARDA-CHUVA	07:00	\N	PRESENTE	\N	2026-07-03 10:38:01.257085+00	06:51
0b3cefbc-c5fe-4cbd-b26b-89ae39fa54d6	2026-02-06	70156	JOSE CARLOS PEREIRA DOS SANTOS	SYNGENTA GUARDA-CHUVA	07:00	\N	PRESENTE	\N	2026-07-03 10:38:01.257085+00	06:51
4955399c-3446-4b7f-9eb5-ff05b2c047b7	2026-02-06	70969	EDSON JOSÉ NOGUEIRA	SYNGENTA GUARDA-CHUVA	07:00	\N	PRESENTE	\N	2026-07-03 10:38:01.257085+00	06:50
5b88d1c6-8185-4427-9083-7ed35823c6c4	2026-02-06	71687	CICERO ROMAO MONTEIRO	SYNGENTA GUARDA-CHUVA	07:00	\N	PRESENTE	\N	2026-07-03 10:38:01.257085+00	06:51
20436a04-8d92-45a7-a658-23764c51217a	2026-02-06	72216	MARCOS SALLES FERREIRA	SYNGENTA GUARDA-CHUVA	07:00	\N	PRESENTE	\N	2026-07-03 10:38:01.257085+00	06:51
a17d18f7-c630-4e92-a882-7b4a6de8c299	2026-02-06	72587	BRUNO GUSTAVO COELHO	SYNGENTA GUARDA-CHUVA	07:00	\N	PRESENTE	\N	2026-07-03 10:38:01.257085+00	06:54
857e4b9e-8761-4f53-8281-144d0bfdcd7f	2026-02-06	73244	VINICIUS ASTORINO BIZELLI	SYNGENTA GUARDA-CHUVA	07:00	\N	PRESENTE	\N	2026-07-03 10:38:01.257085+00	07:00
5c76ecf6-be22-455c-bed1-0d17dfbe73d9	2026-02-06	73557	ANTONIO JOSE DOS SANTOS	SYNGENTA GUARDA-CHUVA	07:00	\N	PRESENTE	\N	2026-07-03 10:38:01.257085+00	06:52
281222d6-3224-4860-b152-ea82d6beb03b	2026-02-06	74846	JOSE EDUARDO DA SILVA SIQUEIRA	SYNGENTA GUARDA-CHUVA	07:00	\N	PRESENTE	\N	2026-07-03 10:38:01.257085+00	06:50
a631b52d-a9c4-4db1-b4d2-aeed46d42c70	2026-02-06	74847	DANIEL FEITOSA DOS SANTOS	SYNGENTA GUARDA-CHUVA	07:00	\N	PRESENTE	\N	2026-07-03 10:38:01.257085+00	06:51
4bcf4450-b0fe-4268-bd7d-83e04b656706	2026-02-06	74854	OZIEL ANDERSON DOS SANTOS	SYNGENTA GUARDA-CHUVA	07:00	\N	PRESENTE	\N	2026-07-03 10:38:01.257085+00	06:48
c60af570-27fa-461c-99b6-c0fa7859ad8d	2026-02-06	74857	PAULO RODRIGO PEREIRA PACHECO	SYNGENTA GUARDA-CHUVA	07:00	\N	PRESENTE	\N	2026-07-03 10:38:01.257085+00	06:50
69030f69-e32d-45b2-a5b0-8a1cb02274f0	2026-02-06	74869	ADAILSON DOS SANTOS MATOS	SYNGENTA GUARDA-CHUVA	07:00	\N	PRESENTE	\N	2026-07-03 10:38:01.257085+00	06:50
dbef84c6-b9ed-4db2-a803-33891e3b6648	2026-02-06	75132	THIAGO RODRIGUES DE BRITO	SYNGENTA GUARDA-CHUVA	07:00	\N	PRESENTE	\N	2026-07-03 10:38:01.257085+00	06:51
0be4a227-04a4-4210-bb88-9218b34a2bf2	2026-02-06	75621	ALAN DOMINGUES BARBOSA	SYNGENTA GUARDA-CHUVA	07:00	\N	PRESENTE	\N	2026-07-03 10:38:01.257085+00	06:53
acee56e7-42f1-46e3-8b8c-28b472aac064	2026-02-06	75693	DAVID MAKLIN DOS ANJOS OLIVEIRA	SYNGENTA GUARDA-CHUVA	07:00	\N	PRESENTE	\N	2026-07-03 10:38:01.257085+00	06:41
f49b4a98-e577-41e0-a8ba-b4ae93f36f2d	2026-02-06	75699	LUIS FERNANDO DIAS LOUZEIRO	SYNGENTA GUARDA-CHUVA	07:00	\N	PRESENTE	\N	2026-07-03 10:38:01.257085+00	06:48
d54583dd-c68b-4f85-bca3-fc9498dbac13	2026-02-06	75728	ANDRESSA PEREIRA SAMPAIO GARCIA	SYNGENTA GUARDA-CHUVA	07:00	\N	PRESENTE	\N	2026-07-03 10:38:01.257085+00	07:00
8af9cc95-54ee-40d6-8c1b-f4a3f178a6b8	2026-02-06	75740	UEDINER ALCIDES MARTINS	SYNGENTA GUARDA-CHUVA	07:00	\N	PRESENTE	\N	2026-07-03 10:38:01.257085+00	07:01
f0a69a20-dcef-4ee9-aa98-dc9e67a99ddf	2026-02-06	75763	GUSTAVO XAVIER BARBOSA	SYNGENTA GUARDA-CHUVA	07:00	\N	PRESENTE	\N	2026-07-03 10:38:01.257085+00	06:41
ea953486-d214-495c-bc09-aa1ccdeb9967	2026-02-06	75776	JERRY DA CONCEIÇÃO SALES	SYNGENTA GUARDA-CHUVA	07:00	\N	PRESENTE	\N	2026-07-03 10:38:01.257085+00	06:52
c29c9bbe-6393-4f66-9b95-e010cea234b8	2026-02-06	75788	RAIMUNDO DIAS	SYNGENTA GUARDA-CHUVA	07:00	\N	PRESENTE	\N	2026-07-03 10:38:01.257085+00	06:49
996cd60e-40ba-4450-b6ba-8295038c466d	2026-02-06	75803	EMILY VITORIA CARDOSO DA SILVA	SYNGENTA GUARDA-CHUVA	07:00	\N	PRESENTE	\N	2026-07-03 10:38:01.257085+00	06:56
fd6d5a4b-514a-4566-bb70-3b3f2c1f0699	2026-02-06	75839	ERIKA SANTOS DE LIMA	SYNGENTA GUARDA-CHUVA	07:00	\N	PRESENTE	\N	2026-07-03 10:38:01.257085+00	07:00
29e2ab81-40b5-42a7-889b-5a103ec06121	2026-02-06	75845	JOAO CARLOS ALVES DA SILVA	SYNGENTA GUARDA-CHUVA	07:00	\N	PRESENTE	\N	2026-07-03 10:38:01.257085+00	06:52
b08b2520-742f-48dd-a2e9-e1436a5d30ba	2026-02-06	75906	JEFFERSON GERSON MENDES DA SILVA	SYNGENTA GUARDA-CHUVA	07:00	\N	PRESENTE	\N	2026-07-03 10:38:01.257085+00	06:56
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
48a18f4f-8907-42f4-b6ab-5c304741ed58	23f30241-e663-4fa8-b9ca-6a02f57cc7ac	075793	2026-04-14	2027-04-13	\N	2028-01-14	22.5	0	f	\N	\N	\N	2026-07-06 20:31:57.354+00	f
371ffd7d-cf2a-4737-895c-22d3fcb81801	8c845812-a24a-4aeb-9ab6-3669da5b915b	075845	2026-05-06	2027-05-05	\N	2028-02-05	20	0	f	\N	\N	\N	2026-07-06 20:32:00.97+00	f
aa42f3ba-92eb-46ea-91a2-9d56800d4943	bd7de2ed-7677-412b-94a5-3cf2d9667b31	075877	2026-05-25	2027-05-24	\N	2028-02-24	17.5	0	f	\N	\N	\N	2026-07-06 20:32:01.843+00	f
9f66922c-e89c-4937-ab24-08d6d2c2b007	7cb832dc-023a-405c-bece-962bddd22d0c	073163	2024-10-09	2025-10-08	\N	2026-07-10	30	30	f	\N	\N	\N	2026-07-06 20:32:05.459+00	f
c94f2519-f4e2-4cdb-9541-972b8069fa1a	34062719-61cf-4ef3-b1cc-21bb8a2c0381	073242	2025-11-01	2026-10-31	\N	2027-08-02	30	30	f	\N	\N	\N	2026-07-06 20:32:06.957+00	f
68f5693d-8fb2-47e3-8a68-3a9c66aee0ec	0c146680-e6c5-4a86-8707-fc7185d20631	073569	2025-02-12	2026-02-11	\N	2026-11-13	30	30	f	\N	\N	\N	2026-07-06 20:32:07.923+00	f
7a6a452e-5f17-48f2-b157-2a56a40eaa65	a4f56911-ea8e-4087-8328-6eee7c4a6e6e	073759	2026-04-11	2027-04-10	\N	2028-01-11	22.5	0	f	\N	\N	\N	2026-07-06 20:32:09.364+00	f
fbc56acf-ca2b-4c17-a7ef-4c7120d7c2a5	c19914f1-62c7-4299-8ce8-ce9f35ce98f9	070252	2025-12-10	2026-12-09	\N	2027-09-10	30	30	f	\N	\N	\N	2026-07-06 20:32:12.174+00	f
545b4849-3930-4de0-b95b-404ad02a35a4	4b9de563-0a07-458b-9319-7d3eb8bbf334	071110	2024-09-24	2025-09-23	\N	2026-06-29	30	30	f	\N	\N	\N	2026-07-06 20:32:14.285+00	f
20c61cb6-aec5-4c66-9f25-7d510501e32a	51a17677-07a9-4a72-91f4-292dcf48a2ee	072113	2025-10-27	2026-10-26	\N	2027-07-28	30	30	f	\N	\N	\N	2026-07-06 20:32:15.661+00	f
602748b3-6019-47dd-a5b9-36e01b6db89e	2c88777d-11d7-4dcc-9948-9e77d8ef9747	072362	2025-03-30	2026-03-29	\N	2026-12-29	30	30	f	\N	\N	\N	2026-07-06 20:32:16.559+00	f
77ac72d5-f559-463e-9472-e9656d910c5d	c744692a-9152-43cb-8c92-c2dad53a6dd9	073019	2025-09-14	2026-09-13	\N	2027-06-15	30	30	f	\N	\N	\N	2026-07-06 20:32:17.843+00	f
4085cce9-aa7d-4048-85a4-de3972abe170	5d32feb5-73d3-4518-8681-21ceeaa22566	074785	2025-12-20	2026-12-19	\N	2027-09-20	30	30	f	\N	\N	\N	2026-07-06 20:32:19.91+00	f
d64ece03-1dac-4950-9524-2a5027bef4f5	2643d90b-d363-471d-8a18-02139ddf4fde	075251	2025-03-27	2026-03-26	\N	2026-12-26	30	30	f	\N	\N	\N	2026-07-06 20:32:20.844+00	f
d083f096-45fe-4a92-8618-39ae02c00ac9	cdd7635f-3086-47e8-a87f-3227c76f084f	075708	2025-11-10	2026-11-09	\N	2027-08-11	30	30	f	\N	\N	\N	2026-07-06 20:32:23.213+00	f
c6da0dd9-04a0-4055-a3eb-e521d36eeb3d	82c546e3-4ba9-4ddd-a28b-c303a2ba31c2	075785	2026-04-07	2027-04-06	\N	2028-01-07	22.5	0	f	\N	\N	\N	2026-07-06 20:32:24.103+00	f
4226b62f-62aa-4a59-a69d-3d745045ef60	8a34f64c-b0af-4a24-a75e-949668c8697f	075798	2026-04-15	2027-04-14	\N	2028-01-15	22.5	0	f	\N	\N	\N	2026-07-06 20:32:27.757+00	f
334fb88c-5c50-4846-a40e-702a4025976d	722f93bf-64cd-44c7-87eb-6fe9b05ae777	075799	2026-04-15	2027-04-14	\N	2028-01-15	22.5	0	f	\N	\N	\N	2026-07-06 20:32:28.625+00	f
f2949f8c-7313-4134-a5c3-bf67a2f9ad9a	13b60718-123b-4059-b99f-c9c2d6cea63a	075809	2026-04-23	2027-04-22	\N	2028-01-23	20	0	f	\N	\N	\N	2026-07-06 20:32:32.239+00	f
f6cf8fb8-fda7-471e-b66f-09f4c89cd232	a032b7df-3ea8-4faa-b17d-4f5dbbd52994	075810	2026-04-23	2027-04-22	\N	2028-01-23	20	0	f	\N	\N	\N	2026-07-06 20:32:33.108+00	f
4d46b5fe-8e18-4204-abf8-25eb0aaa5287	c7758861-4f49-4632-9762-19f5f495a2df	075814	2026-04-23	2027-04-22	\N	2028-01-23	20	0	f	\N	\N	\N	2026-07-06 20:32:36.572+00	f
3c57fcf3-c50d-4b95-8cd0-7a550293b65d	beff7969-13aa-4ad0-acb3-b178bee25629	075815	2026-04-23	2027-04-22	\N	2028-01-23	20	0	f	\N	\N	\N	2026-07-06 20:32:37.454+00	f
97a28c63-54d1-44bb-a7c5-f1a71075069b	1beb7b83-ce97-42f1-8da1-ad6c21cc682a	075828	2026-04-28	2027-04-27	\N	2028-01-28	20	0	f	\N	\N	\N	2026-07-06 20:32:40.912+00	f
76ccdc8c-320e-4c1b-9b73-b6b55febd298	e17ada04-7fd7-4ae1-891b-ae6ae0145abe	075829	2026-04-28	2027-04-27	\N	2028-01-28	20	0	f	\N	\N	\N	2026-07-06 20:32:41.823+00	f
585c9e7f-54d0-4674-b5a7-6b670b2f1197	535de7df-c99c-491c-9a5d-670134c0d556	075834	2026-05-04	2027-05-03	\N	2028-02-03	20	0	f	\N	\N	\N	2026-07-06 20:32:45.392+00	f
90f8221c-a7ca-4bc0-ba6c-c79de0750cec	938c088b-e817-4c43-acd6-2571d19bee32	075835	2026-05-04	2027-05-03	\N	2028-02-03	20	0	f	\N	\N	\N	2026-07-06 20:32:46.361+00	f
33455662-68ba-4c22-b35f-192fa4de3f4f	beaa74bb-c384-406f-9b10-5a1b33565e53	075846	2026-05-07	2027-05-06	\N	2028-02-06	20	0	f	\N	\N	\N	2026-07-06 20:32:49.997+00	f
2bfd860a-7e83-41b0-a94c-07a2bd98aab2	fceb40d4-e6ad-4ef6-8e1e-86a175343cf2	075847	2026-05-07	2027-05-06	\N	2028-02-06	20	0	f	\N	\N	\N	2026-07-06 20:32:50.894+00	f
f4883208-f201-47ea-bda4-1571b49b36c4	3ce155ae-16fa-4fd2-90a2-3cfa719a6867	075851	2026-05-07	2027-05-06	\N	2028-02-06	20	0	f	\N	\N	\N	2026-07-06 20:32:54.571+00	f
56fe4bb3-6f38-492e-88cf-956ca9b40242	f09fc646-1a8f-4a6e-8849-d237631a8849	075853	2026-05-07	2027-05-06	\N	2028-02-06	20	0	f	\N	\N	\N	2026-07-06 20:32:55.459+00	f
3cdba16a-065e-48da-9b0c-88e87966b966	7c2b7107-4bfa-4a19-9d26-060dbfc1924c	075867	2026-05-18	2027-05-17	\N	2028-02-17	17.5	0	f	\N	\N	\N	2026-07-06 20:33:00.842+00	f
0410bb2e-1ac6-45da-9b84-eb2839947613	0abe8010-ac69-4277-af3d-9a00185b24cd	075888	2026-05-28	2027-05-27	\N	2028-02-27	17.5	0	f	\N	\N	\N	2026-07-06 20:33:05.373+00	f
8a676c96-319c-45bd-b695-e6e0be161399	3f70dc11-dc10-41e9-b573-0c962936d7f6	010044	2026-02-17	2027-02-16	\N	2027-11-18	27.5	0	f	\N	\N	\N	2026-07-06 20:33:08.369+00	f
c677fd8f-2140-4077-b297-f70b2a78a7a0	2c4cfbee-7f04-419a-a859-eb65149911d8	070156	2025-09-11	2026-09-10	\N	2027-06-12	30	30	f	\N	\N	\N	2026-07-06 20:33:11.527+00	f
6bca6ded-3417-4dab-8ee2-ef93cf57cdb2	51ffaf0c-00fe-4d5d-821a-40c34a8203d8	073332	2024-12-01	2025-11-30	\N	2026-09-01	30	30	f	\N	\N	\N	2026-07-06 20:33:15.981+00	f
4956ece3-f958-416f-a6ca-0c51eaa2e227	cbc8e27d-503d-4447-9e54-2b774c012b66	073557	2026-02-08	2027-02-07	\N	2027-11-09	27.5	0	f	\N	\N	\N	2026-07-06 20:33:17.396+00	f
070d0d4b-d2c9-4464-8019-4162c1629c17	094b876c-ba2c-4518-b30a-28dc1462c38e	075186	2025-03-07	2026-03-06	\N	2026-12-06	30	30	f	\N	\N	\N	2026-07-06 20:33:21.884+00	f
ce9f1b7e-2548-4a8e-9aae-b0f08580a5f5	022e764f-d223-4747-9960-83f18373028f	075740	2026-01-05	2027-01-04	\N	2027-10-06	30	30	f	\N	\N	\N	2026-07-06 20:33:24.9+00	f
c210ddac-13c4-4d4f-9fe3-95798acebf8d	1ec8fda0-fe03-4578-97d4-04670f7e1091	075803	2026-04-17	2027-04-16	\N	2028-01-17	22.5	0	f	\N	\N	\N	2026-07-06 20:31:58.331+00	f
8fd00e9c-1064-4ca7-bf42-d70969a0cf33	2d45ed01-cb9f-49aa-b781-a69ed90fe642	075878	2026-05-25	2027-05-24	\N	2028-02-24	17.5	0	f	\N	\N	\N	2026-07-06 20:32:02.748+00	f
f756004f-79d0-46e1-b611-042fa399540d	7cb832dc-023a-405c-bece-962bddd22d0c	073163	2025-10-09	2026-10-08	\N	2027-07-10	30	30	f	\N	\N	\N	2026-07-06 20:32:05.7+00	f
12858abd-4950-42cc-99af-771705c926ee	54cd7cc3-01d0-4d64-a31d-562d6c2d9073	030366	2025-12-20	2026-12-19	\N	2027-09-20	30	30	f	\N	\N	\N	2026-07-06 20:32:10.26+00	f
9be574f6-931d-43ca-942c-54dcdb7ae241	c56e2d32-8dfa-4636-86c9-b8a3cbcad162	071109	2024-09-24	2025-09-23	\N	2026-06-29	30	30	f	\N	\N	\N	2026-07-06 20:32:13.069+00	f
b4cfb307-638a-4d8e-818b-a03fd6750f89	4b9de563-0a07-458b-9319-7d3eb8bbf334	071110	2025-09-24	2026-09-23	\N	2027-06-25	30	30	f	\N	\N	\N	2026-07-06 20:32:14.537+00	f
abf2fc14-6941-472b-921a-bef63807ae39	4ec450a6-7046-4326-ba4d-30682e19f928	073944	2025-06-17	2026-06-16	\N	2027-03-18	30	30	f	\N	\N	\N	2026-07-06 20:32:18.755+00	f
f7284189-9449-4ed9-a609-157dda4727ae	3e252902-8f07-4b31-ad3f-9657cdd3725b	075786	2026-04-07	2027-04-06	\N	2028-01-07	22.5	0	f	\N	\N	\N	2026-07-06 20:32:24.948+00	f
1f1d0a40-ae6e-425c-a0e6-50d740a5ee9b	92ce3dcb-4f7d-4cbb-99e4-4349405e77ea	075800	2026-04-15	2027-04-14	\N	2028-01-15	22.5	0	f	\N	\N	\N	2026-07-06 20:32:29.469+00	f
a1e33592-caba-4fc8-9683-6a1e37d8257c	f2d98055-bd24-4e4a-a967-55c612ebd750	075811	2026-04-23	2027-04-22	\N	2028-01-23	20	0	f	\N	\N	\N	2026-07-06 20:32:33.959+00	f
329d3d6a-32c8-4da9-8f4a-743ffccdbcf8	917fec59-ab61-45db-8f81-9beab2195f1b	075821	2026-04-24	2027-04-23	\N	2028-01-24	20	0	f	\N	\N	\N	2026-07-06 20:32:38.349+00	f
cbf31f4c-b4a5-411d-8aec-475cdd441850	2eafdcdf-2226-40ed-85f6-cbf92b4257ce	075830	2026-04-28	2027-04-27	\N	2028-01-28	20	0	f	\N	\N	\N	2026-07-06 20:32:42.734+00	f
620d6208-3883-4c6f-a316-9dc386e4f08d	b7f63435-5138-486e-86a2-bf6dfa450540	075836	2026-05-04	2027-05-03	\N	2028-02-03	20	0	f	\N	\N	\N	2026-07-06 20:32:47.284+00	f
3c563ac1-a195-4dc4-b6bb-f5c52096a7a3	be927f52-9181-4a49-8b37-837311673496	075848	2026-05-07	2027-05-06	\N	2028-02-06	20	0	f	\N	\N	\N	2026-07-06 20:32:51.759+00	f
4866279c-3940-47ae-9c26-57e289834a20	75eacd3d-5c0f-432a-839f-803d5eca0d12	075854	2026-05-08	2027-05-07	\N	2028-02-07	20	0	f	\N	\N	\N	2026-07-06 20:32:56.367+00	f
63997ddc-9c8f-4d58-ae5c-018c57a4af18	17cbdc3e-d043-4eb5-8771-b72a7ac2297a	075864	2026-05-14	2027-05-13	\N	2028-02-13	20	0	f	\N	\N	\N	2026-07-06 20:32:58.072+00	f
0b539ad8-d71c-4247-ac94-510e0158a0c3	1543bea5-f3b5-4289-8136-24338f4042be	075868	2026-05-18	2027-05-17	\N	2028-02-17	17.5	0	f	\N	\N	\N	2026-07-06 20:33:01.805+00	f
647a1150-60d5-4e6a-b8fe-c06ee3eb31b4	2c36e097-d770-418a-b702-b9de29ca3c62	075879	2026-05-25	2027-05-24	\N	2028-02-24	17.5	0	f	\N	\N	\N	2026-07-06 20:33:02.628+00	f
0a5837be-b1fb-4161-b4cf-99248ea727fb	cada9130-9918-4bd4-9f11-7166c5188955	070924	2026-02-17	2027-02-16	\N	2027-11-18	27.5	0	f	\N	\N	\N	2026-07-06 20:33:06.242+00	f
476cbec0-14aa-4410-9561-75b58805d28e	fd74e6c6-7cf2-4930-bebd-cf003fd4ea60	000616	2025-07-01	2026-06-30	\N	2027-04-01	30	30	f	\N	\N	\N	2026-07-06 20:33:07.205+00	f
96661e20-8858-49e4-90d8-f1f2d178536c	519005c1-dfd6-4952-be33-a68aa37640a6	060868	2025-03-14	2026-03-13	\N	2026-12-13	30	30	f	\N	\N	\N	2026-07-06 20:33:09.179+00	f
920708c5-9893-4e1a-b47a-767bc12fdc37	a9cf53c8-6a86-4609-930d-98032c3abcbb	070969	2025-03-18	2026-03-17	\N	2026-12-17	30	30	f	\N	\N	\N	2026-07-06 20:33:12.385+00	f
414688e4-f6cb-492e-9d0c-fd78c5302ee6	cab0afc8-2ced-4941-b1e1-e9521af4cbd3	071687	2026-03-24	2027-03-23	\N	2027-12-24	22.5	0	f	\N	\N	\N	2026-07-06 20:33:13.977+00	f
52b2b335-c8b3-4614-8e12-3ad1cf22f038	82947628-c1c4-45e2-bf35-963cd4ec4d12	073244	2024-11-01	2025-10-31	\N	2026-08-02	30	30	f	\N	\N	\N	2026-07-06 20:33:14.899+00	f
5da66a18-7a84-4ebe-8ead-b7e7f01efcf2	51ffaf0c-00fe-4d5d-821a-40c34a8203d8	073332	2025-12-01	2026-11-30	\N	2027-09-01	30	30	f	\N	\N	\N	2026-07-06 20:33:16.214+00	f
ed1412b4-8469-4ba1-8dbb-cb0bf21c42f6	478466ce-53df-4ebe-9291-69b4b3d29235	040638	2025-09-12	2026-09-11	\N	2027-06-13	30	30	f	\N	\N	\N	2026-07-06 20:31:12.994+00	f
c07e4eae-33f3-4418-a172-7cc67fae4d3a	12783ba4-0452-4220-8429-c7c8070473d4	075909	2026-06-26	2027-06-25	2027-06-25	2028-06-25	30	0	f	\N	\N	\N	2026-07-06 20:06:43.461+00	f
df3ec4bf-1057-425d-bbc6-e5c142cee624	9d249fdb-c48d-4208-a046-4288d5a6b389	071144	2025-11-03	2026-11-02	\N	2027-08-04	30	30	f	\N	\N	\N	2026-07-06 20:30:56.33+00	f
dc7558d1-3dfc-4e79-9913-caa0c2815905	d9a91097-6b3d-4fd8-adc7-7105b2411e3a	010620	2025-02-14	2026-02-13	\N	2026-11-15	30	30	f	\N	\N	\N	2026-07-06 20:30:59.336+00	f
50d26e4b-0d29-4c75-9aef-f235b29c7f54	2176ab2e-1917-4251-a2a1-2c3534905aad	073504	2025-02-01	2026-01-31	\N	2026-11-02	30	30	f	\N	\N	\N	2026-07-06 20:31:02.316+00	f
c7016ea2-27a0-42f6-a812-e8c288240d5d	f0342518-bd63-4b33-8caf-5fd0609fe44a	074445	2024-10-08	2025-10-07	\N	2026-07-09	30	30	t	2026-06-22	2026-07-11	30	2026-07-06 20:33:18.286+00	f
bbce3bec-2639-4ec9-b1d9-fc1d52d2bf5b	75d0a357-4313-4646-8ad4-a91705d2f2cf	074854	2026-01-21	2027-01-20	\N	2027-10-22	27.5	0	f	\N	\N	\N	2026-07-06 20:33:19.78+00	f
338d5d9c-8d2a-4cbc-9e92-a4705e518b58	7d775bd7-515c-4a33-b524-03c09c467b23	074857	2025-01-22	2026-01-21	\N	2026-10-23	30	30	f	\N	\N	\N	2026-07-06 20:33:20.752+00	f
1df0501e-9d74-4afc-9990-1401ce2516a7	094b876c-ba2c-4518-b30a-28dc1462c38e	075186	2026-03-07	2027-03-06	\N	2027-12-07	25	0	f	\N	\N	\N	2026-07-06 20:33:22.101+00	f
08ae6ac8-03b2-4bb1-aeaf-0b088a077843	4c291f0b-ec29-4014-8447-ff8141486133	074475	2024-10-14	2025-10-13	\N	2026-07-15	30	30	t	2026-06-08	2026-07-07	30	2026-07-06 20:31:05.778+00	f
210c59b0-cbd8-4146-be5b-174d27785468	97a4b2be-e75f-4345-b6cb-e2a485f681d9	075502	2025-05-21	2026-05-20	\N	2027-02-19	30	30	f	\N	\N	\N	2026-07-06 20:31:10.299+00	f
79081a7b-1d1f-420a-8a5a-66a0de58d1d6	f4f5e0c6-a407-471e-9cbe-1c9411c62567	071040	2025-06-17	2026-06-16	\N	2027-03-18	30	30	f	\N	\N	\N	2026-07-06 20:31:17.171+00	f
6379baa2-298a-475e-8e8f-762582ec2b0c	146f363f-134a-46bf-91fe-dd87e52c8f88	073240	2025-11-01	2026-10-31	\N	2027-08-02	30	30	f	\N	\N	\N	2026-07-06 20:31:19.877+00	f
10189f7d-5403-41de-a37c-28209bfcdec0	05159e14-4a04-4b7a-9e4f-4cb43d138925	074819	2025-01-10	2026-01-09	\N	2026-10-11	30	30	f	\N	\N	\N	2026-07-06 20:31:26.908+00	f
1fe482fa-68ad-450e-ad37-b167dd628320	da7daf8d-03ce-4d85-8cc9-834ff097e5ac	074948	2026-02-05	2027-02-04	\N	2027-11-06	27.5	0	f	\N	\N	\N	2026-07-06 20:31:28.334+00	f
069ad39e-2765-453a-b263-71c84976a22a	4594413b-1406-43f1-b3ed-5af30a6ab880	075594	2025-07-25	2026-07-24	\N	2027-04-25	30	30	f	\N	\N	\N	2026-07-06 20:31:32.511+00	f
6f2e8460-53bf-4a7f-9819-c09550d17e72	8dc6d6ec-427a-4a80-8175-97ce13b57c8f	075649	2025-09-15	2026-09-14	\N	2027-06-16	30	30	f	\N	\N	\N	2026-07-06 20:31:37.092+00	f
58dbd88b-ac6f-4357-ab4c-22d8d3013383	7673456e-e717-47ae-8b74-482af33078d9	075727	2025-11-26	2026-11-25	\N	2027-08-27	30	30	f	\N	\N	\N	2026-07-06 20:31:41.604+00	f
1a2a4b5c-0636-485c-b82d-d8488ce53f75	4ac7e8e1-f572-4fbc-970d-aeff6ba5f6d2	075550	2025-06-26	2026-06-25	\N	2027-03-27	30	30	f	\N	\N	\N	2026-07-06 20:31:44.59+00	f
39bfeb96-8d43-4567-a58f-32456206c47c	5049a328-1980-4416-9c2e-77f649cc5b60	074847	2026-01-15	2027-01-14	\N	2027-10-16	30	30	f	\N	\N	\N	2026-07-06 20:31:50.57+00	f
2a83c861-0f10-4b71-a886-830d480bf0a5	06be1efc-148e-4b38-930c-96ba72b4eca1	075779	2026-03-19	2027-03-18	\N	2027-12-19	22.5	0	f	\N	\N	\N	2026-07-06 20:31:55.49+00	f
30e35316-ec53-403c-a956-75cb49c7b2ea	b732b7dc-fb35-4a83-8592-79b587d6f5fd	075816	2026-04-23	2027-04-22	\N	2028-01-23	20	0	f	\N	\N	\N	2026-07-06 20:31:59.244+00	f
906e5536-a3fa-4bf6-8bca-5fc3b89e2d5f	f9c553cc-bebf-4f36-b246-90b784ead557	072786	2025-08-03	2026-08-02	\N	2027-05-04	30	30	f	\N	\N	\N	2026-07-06 20:32:03.641+00	f
a7a0ac48-2ef9-4643-852d-609b12aa2108	34062719-61cf-4ef3-b1cc-21bb8a2c0381	073242	2024-11-01	2025-10-31	\N	2026-08-02	30	30	f	\N	\N	\N	2026-07-06 20:32:06.666+00	f
24d7c90f-831d-4ef8-a16c-2aaba857a954	0c146680-e6c5-4a86-8707-fc7185d20631	073569	2026-02-12	2027-02-11	\N	2027-11-13	27.5	0	f	\N	\N	\N	2026-07-06 20:32:08.173+00	f
4493d206-78dd-43b0-b3fe-14e36e73cde5	dd0edc19-9be5-4f0a-969c-786fe70bee55	030670	2025-08-09	2026-08-08	\N	2027-05-10	30	30	f	\N	\N	\N	2026-07-06 20:32:11.07+00	f
1b57ba5d-d59b-4143-9e30-87b9dbeac491	51a17677-07a9-4a72-91f4-292dcf48a2ee	072113	2024-10-27	2025-10-26	\N	2026-07-28	30	30	t	2026-07-13	2026-08-10	30	2026-07-06 20:32:15.424+00	f
089357b8-2ddf-4b5d-b51e-89b305a65ff8	2c88777d-11d7-4dcc-9948-9e77d8ef9747	072362	2026-03-30	2027-03-29	\N	2027-12-30	22.5	0	f	\N	\N	\N	2026-07-06 20:32:16.782+00	f
3a714dd6-96de-4342-b553-8ad384df1414	05f825a2-192a-43d1-8fbe-0279b2c9b178	050187	2025-06-30	2026-06-29	\N	2027-03-31	30	30	f	\N	\N	\N	2026-07-06 20:30:54.999+00	f
92ff477a-c5e3-47f2-bf41-0d47846d252f	45c95f63-f01a-40d2-be78-0957b27917d1	072683	2025-07-04	2026-07-03	\N	2027-04-04	30	30	f	\N	\N	\N	2026-07-06 20:30:57.24+00	f
0fb86c35-4829-41ab-80a6-89de2092ff6f	8eda57ec-d586-4d0d-af4e-e087142dec04	010615	2025-01-27	2026-01-26	\N	2026-10-28	30	30	f	\N	\N	\N	2026-07-06 20:30:58.228+00	f
57a58e24-c13d-4d78-8962-115836a6730d	d9a91097-6b3d-4fd8-adc7-7105b2411e3a	010620	2026-02-14	2027-02-13	\N	2027-11-15	27.5	0	f	\N	\N	\N	2026-07-06 20:30:59.58+00	f
f5dc3468-4b1c-4304-a58d-67178fa97901	5d32feb5-73d3-4518-8681-21ceeaa22566	074785	2024-12-20	2025-12-19	\N	2026-09-20	30	30	f	\N	\N	\N	2026-07-06 20:32:19.663+00	f
2a167a7b-5a3a-4333-8797-9b1e0ff50964	2643d90b-d363-471d-8a18-02139ddf4fde	075251	2026-03-27	2027-03-26	\N	2027-12-27	22.5	0	f	\N	\N	\N	2026-07-06 20:32:21.072+00	f
c425c4ca-7516-47be-8ddf-75a01cef2324	19d7cb2c-e21c-4863-aa70-f426d028d88c	075787	2026-04-09	2027-04-08	\N	2028-01-09	22.5	0	f	\N	\N	\N	2026-07-06 20:32:25.977+00	f
cab0e8a2-3658-4e84-bf60-ffd893bea2b1	258bcf6b-a4cb-4fa1-b3a5-8171244ba5bb	075805	2026-04-23	2027-04-22	\N	2028-01-23	20	0	f	\N	\N	\N	2026-07-06 20:32:30.38+00	f
f222ae9d-1d4e-41e6-938d-7a83e4e2e625	e9c22eeb-8b44-45ef-b301-91e65cc90d2e	075812	2026-04-23	2027-04-22	\N	2028-01-23	20	0	f	\N	\N	\N	2026-07-06 20:32:34.83+00	f
d036930c-bbdb-4a2a-ad0a-713c01d43b0b	4591a4bb-62f1-48aa-af12-082afd9a16b8	075822	2026-04-24	2027-04-23	\N	2028-01-24	20	0	f	\N	\N	\N	2026-07-06 20:32:39.19+00	f
e0585d8a-ba4d-40aa-8b2a-67357e899070	40551037-bf69-4f9e-b3df-adaf6d97527d	075831	2026-04-28	2027-04-27	\N	2028-01-28	20	0	f	\N	\N	\N	2026-07-06 20:32:43.584+00	f
355b57c9-0b84-4a7e-9cc2-45d0a9852d33	e13fd5d3-8493-4b58-bb54-269993f6fba0	075837	2026-05-04	2027-05-03	\N	2028-02-03	20	0	f	\N	\N	\N	2026-07-06 20:32:48.223+00	f
f5326703-2424-43b2-aaad-7e2c3c20c5d7	ba0aa0ea-4f84-4c79-8ca0-01bf069ff89e	075849	2026-05-07	2027-05-06	\N	2028-02-06	20	0	f	\N	\N	\N	2026-07-06 20:32:52.69+00	f
47bc34e5-33d4-4c16-9752-214737467c7c	2176ab2e-1917-4251-a2a1-2c3534905aad	073504	2026-02-01	2027-01-31	\N	2027-11-02	27.5	0	f	\N	\N	\N	2026-07-06 20:31:02.542+00	f
cb9289f3-7421-41ca-a9df-0ee84d98283a	4c291f0b-ec29-4014-8447-ff8141486133	074475	2025-10-14	2026-10-13	\N	2027-07-15	30	30	f	\N	\N	\N	2026-07-06 20:31:06.062+00	f
0f906729-cf9b-403d-a480-4784e3b89a12	efa824c4-d56b-4973-b518-f3a6784a62ce	075385	2026-04-15	2027-04-14	\N	2028-01-15	22.5	0	f	\N	\N	\N	2026-07-06 20:31:08.402+00	f
b2b00880-2b11-433f-89aa-0d87f4b5126f	b9e896d8-adaa-4e9b-9f5c-a8a9293c2898	075467	2025-05-06	2026-05-05	\N	2027-02-04	30	30	f	\N	\N	\N	2026-07-06 20:31:09.239+00	f
fdb73331-59ae-467c-8429-78d37ce862a7	60ec1e4b-02fb-4960-885c-df2115df65ed	075592	2025-07-24	2026-07-23	\N	2027-04-24	30	30	f	\N	\N	\N	2026-07-06 20:31:11.096+00	f
71a83188-bf6c-46a5-842d-dd9238c825c4	a1aebbf0-c987-4a62-82ab-941ed4e7e7b1	075855	2026-05-11	2027-05-10	\N	2028-02-10	20	0	f	\N	\N	\N	2026-07-06 20:32:57.19+00	f
b9bde55c-568c-4c1e-bd53-7c374e5f9813	41f17b9c-a715-4227-92d0-4caf7fa2d8dd	075865	2026-05-14	2027-05-13	\N	2028-02-13	20	0	f	\N	\N	\N	2026-07-06 20:32:58.975+00	f
bdeb7231-4206-499c-ae15-5587c10fb906	709ab55a-f7ed-4e80-a404-49f293fb6447	075880	2026-05-25	2027-05-24	\N	2028-02-24	17.5	0	f	\N	\N	\N	2026-07-06 20:33:03.499+00	f
c70cad66-611a-41b8-9a1b-c39d529c5414	3f70dc11-dc10-41e9-b573-0c962936d7f6	010044	2025-02-17	2026-02-16	\N	2026-11-18	30	30	f	\N	\N	\N	2026-07-06 20:33:08.105+00	f
d080bd4d-54db-42f5-91b1-05afe3663ff8	519005c1-dfd6-4952-be33-a68aa37640a6	060868	2026-03-14	2027-03-13	\N	2027-12-14	25	0	f	\N	\N	\N	2026-07-06 20:33:09.463+00	f
9868649c-1179-4899-be7e-7eed45f4fab8	a9cf53c8-6a86-4609-930d-98032c3abcbb	070969	2026-03-18	2027-03-17	\N	2027-12-18	22.5	0	f	\N	\N	\N	2026-07-06 20:33:12.621+00	f
d9e95d90-6f3c-4ab9-bc17-f5407f81abc5	cbc8e27d-503d-4447-9e54-2b774c012b66	073557	2025-02-08	2026-02-07	\N	2026-11-09	30	30	f	\N	\N	\N	2026-07-06 20:33:17.15+00	f
b8e74a50-c37e-4886-a378-9360a7afdceb	f0342518-bd63-4b33-8caf-5fd0609fe44a	074445	2025-10-08	2026-10-07	\N	2027-07-09	30	30	f	\N	\N	\N	2026-07-06 20:33:18.528+00	f
45bba5cb-e34f-42c7-858a-72e0b7765a00	01c0146c-1416-4271-b9d9-eabd6fcd528e	075728	2025-11-26	2026-11-25	\N	2027-08-27	30	30	f	\N	\N	\N	2026-07-06 20:33:23.016+00	f
29ac9031-3b2b-4a7b-8845-916bfcc27828	ccab729b-5d81-49ca-a18c-b62922aa7eb4	075687	2025-10-24	2026-10-23	\N	2027-07-25	30	30	f	\N	\N	\N	2026-07-06 20:31:11.943+00	f
6add2615-0c47-421a-8ce9-5f530e3deb23	2ecc58b1-5066-4414-a908-97a36c08b3ec	050930	2025-03-25	2026-03-24	\N	2026-12-24	30	30	f	\N	\N	\N	2026-07-06 20:31:13.885+00	f
e88faa5f-4c6d-44b6-8c40-32eeedb11372	fcd1f1f3-137d-4e51-9136-928202498461	060853	2026-02-09	2027-02-08	\N	2027-11-10	27.5	0	f	\N	\N	\N	2026-07-06 20:31:15.245+00	f
db3b0501-5ef3-4996-96a5-8c27b8347309	04509dd6-4ec3-45fa-9fec-7a5577c0ba5e	070768	2024-11-11	2025-11-10	\N	2026-08-12	30	30	f	\N	\N	\N	2026-07-06 20:31:16.056+00	f
b45608c3-d950-4597-bc6b-80e566fff7d0	c9234c19-cf5c-418f-9a5a-7e93111437c5	071288	2025-08-03	2026-08-02	\N	2027-05-04	30	30	f	\N	\N	\N	2026-07-06 20:31:17.992+00	f
2b3ad159-6a8d-4811-bb8a-6f7edfe40351	89d1953b-5cff-423d-9239-12133d971027	072779	2025-08-03	2026-08-02	\N	2027-05-04	30	30	f	\N	\N	\N	2026-07-06 20:31:18.806+00	f
54a6c5ca-34be-4c40-a5bc-2ca2cc21bbda	ed412871-9102-4065-bcf9-d16a9e7bea81	073463	2025-01-23	2026-01-22	\N	2026-10-24	30	30	f	\N	\N	\N	2026-07-06 20:31:20.669+00	f
ef52794c-77f0-4b52-8ce0-e629410d000f	08df0e04-feb3-40e9-95ea-335a8cc2e69b	073489	2026-01-29	2027-01-28	\N	2027-10-30	27.5	0	f	\N	\N	\N	2026-07-06 20:31:22.01+00	f
6dfc4df2-f7d7-4e25-a134-3e64a55e1300	2dc15829-c805-4e47-b083-cd17a008b7a9	074116	2025-08-13	2026-08-12	\N	2027-05-14	30	30	f	\N	\N	\N	2026-07-06 20:31:22.835+00	f
c46e5f20-a1c3-4eeb-85fa-70827e0fe463	e6629df2-78e5-4dfb-8c0a-9dc259cdfce8	074296	2025-09-13	2026-09-12	\N	2027-06-14	24	30	f	\N	\N	\N	2026-07-06 20:31:24.766+00	f
2cb1d213-fca6-42ed-b16a-349dcc08398b	b8231d04-f70c-4818-95da-8103d8c937a3	074351	2024-09-23	2025-09-22	\N	2026-06-29	30	30	t	2026-08-03	2026-09-01	30	2026-07-06 20:31:25.659+00	f
9691ef67-330b-4013-9c2d-5fb81e38ee44	05159e14-4a04-4b7a-9e4f-4cb43d138925	074819	2026-01-10	2027-01-09	\N	2027-10-11	30	30	f	\N	\N	\N	2026-07-06 20:31:27.138+00	f
4108e316-8371-470c-9b58-90b9fc22a0b1	525514fa-d774-4a32-94a5-daf799572396	075207	2025-03-13	2026-03-12	\N	2026-12-12	30	30	f	\N	\N	\N	2026-07-06 20:31:29.162+00	f
b736977d-3994-46f7-a404-cef299552863	02148a14-530c-4549-a5ac-80af04ce6785	075252	2026-03-27	2027-03-26	\N	2027-12-27	22.5	0	f	\N	\N	\N	2026-07-06 20:31:30.52+00	f
9e306cea-c921-47d7-b080-d6173e39d66f	cf3d40a3-3ecc-47a3-8392-0d6e6b7dbe28	075442	2025-04-30	2026-04-29	\N	2027-01-29	30	30	f	\N	\N	\N	2026-07-06 20:31:31.359+00	f
1acbff2f-f809-4d59-acef-6d4798e3901d	aa9c3270-d2e3-46fe-950e-0f9647077ff8	075618	2025-08-20	2026-08-19	\N	2027-05-21	30	30	f	\N	\N	\N	2026-07-06 20:31:33.399+00	f
f6213b2c-ec60-4bd5-b3c9-19c705e99037	9b1db7a4-3854-4992-b915-1047c364fa46	075620	2025-08-20	2026-08-19	\N	2027-05-21	30	30	f	\N	\N	\N	2026-07-06 20:31:34.26+00	f
55fef12d-9052-4093-9591-eebcdca955e1	aa46cb9c-89c3-4c1d-91de-3c58ad9efed2	075650	2025-09-15	2026-09-14	\N	2027-06-16	30	30	f	\N	\N	\N	2026-07-06 20:31:37.991+00	f
20c74059-56ae-42ed-8389-911780997206	18e1524c-4a41-43d2-a70e-aaaa81c6d634	075651	2025-09-15	2026-09-14	\N	2027-06-16	30	30	f	\N	\N	\N	2026-07-06 20:31:38.844+00	f
85162800-6ca8-498c-805f-3ea18cb94363	174521ea-a404-4d8d-bbc5-d9806cf45983	075765	2026-02-25	2027-02-24	\N	2027-11-26	25	0	f	\N	\N	\N	2026-07-06 20:31:42.522+00	f
4ebf26c1-c2b8-41b5-92b4-d128cb2cfe89	89b01666-1988-48ec-a651-f3e492c26d3b	075088	2025-02-19	2026-02-18	\N	2026-11-20	30	30	f	\N	\N	\N	2026-07-06 20:31:43.39+00	f
c893851d-1eff-4823-a3f7-446558bac43b	da0d21d6-2889-4fea-b08a-bb5fca1c0c0c	075193	2025-03-07	2026-03-06	\N	2026-12-06	30	30	f	\N	\N	\N	2026-07-06 20:31:45.532+00	f
673b2a4b-9399-478e-9a50-4e6ef9739879	889b3979-f279-4693-92a5-2f9b6dfc1936	071466	2026-04-27	2027-04-26	\N	2028-01-27	20	0	f	\N	\N	\N	2026-07-06 20:31:46.893+00	f
0c1b836b-4b9d-454f-920f-abc49ccd7774	6923c92f-fed0-4de4-a0d1-ec7390e85e78	072216	2026-01-23	2027-01-22	\N	2027-10-24	27.5	0	f	\N	\N	\N	2026-07-06 20:31:47.798+00	f
71deac47-2bbf-4d48-b607-5625136ccf6f	6d1786b8-676c-4511-94b5-b4123162ae8d	074869	2026-01-27	2027-01-26	\N	2027-10-28	27.5	0	f	\N	\N	\N	2026-07-06 20:31:51.451+00	f
75e984d9-55d2-409d-8c02-fada35adf39f	df4b5ed2-9c12-4911-b3ff-9ec504be50fa	075699	2025-11-05	2026-11-04	\N	2027-08-06	30	30	f	\N	\N	\N	2026-07-06 20:31:52.624+00	f
99509443-1213-47ea-b724-726c4b0b3d19	c78775ac-815b-4fae-8534-cb72b04eb579	075788	2026-04-14	2027-04-13	\N	2028-01-14	22.5	0	f	\N	\N	\N	2026-07-06 20:31:56.39+00	f
6520b0bd-ddf1-4aeb-9679-582bde066035	1295cbeb-8ac0-4b58-8614-589dd7ff655b	075839	2026-05-04	2027-05-03	\N	2028-02-03	20	0	f	\N	\N	\N	2026-07-06 20:32:00.112+00	f
031cde1e-8c5b-4e75-85a5-a7b72c8cf776	68fd8b3c-130b-4141-a1db-d165e4c38aaf	073929	2025-06-13	2026-06-12	\N	2027-03-14	30	30	f	\N	\N	\N	2026-07-06 20:32:04.614+00	f
feaff7bb-6937-4c9b-bbf9-548e41c02395	a4f56911-ea8e-4087-8328-6eee7c4a6e6e	073759	2025-04-11	2026-04-10	\N	2027-01-10	30	30	f	\N	\N	\N	2026-07-06 20:32:09.136+00	f
b6ca3395-cb1f-4701-aa81-e740a4309fd2	c19914f1-62c7-4299-8ce8-ce9f35ce98f9	070252	2024-12-10	2025-12-09	\N	2026-09-10	30	30	t	2026-08-17	2026-09-16	30	2026-07-06 20:32:11.928+00	f
6b050b0a-2663-4dcc-8de3-cf491959d501	c56e2d32-8dfa-4636-86c9-b8a3cbcad162	071109	2025-09-24	2026-09-23	\N	2027-06-25	30	30	f	\N	\N	\N	2026-07-06 20:32:13.38+00	f
35b17149-3176-463c-b3b6-a1590c2f749d	61272d13-22cb-499f-82a2-d9f85d2fff88	073254	2025-11-01	2026-10-31	\N	2027-08-02	30	30	f	\N	\N	\N	2026-07-06 20:31:01.453+00	f
e2c0a598-33ab-47f3-ae76-1893ccc398e2	c744692a-9152-43cb-8c92-c2dad53a6dd9	073019	2024-09-14	2025-09-13	\N	2026-06-29	30	30	t	2026-08-03	2026-09-01	30	2026-07-06 20:32:17.623+00	f
480cbebf-bba9-4762-bc4d-881113f20ab1	4e187f38-3016-46e7-ac27-22928d5338f3	075532	2025-06-16	2026-06-15	\N	2027-03-17	30	30	f	\N	\N	\N	2026-07-06 20:32:22.332+00	f
8d62c819-9361-4a46-951e-10a3ff955f4f	1ff62657-8185-45de-928d-7f9985a94b03	075797	2026-04-15	2027-04-14	\N	2028-01-15	22.5	0	f	\N	\N	\N	2026-07-06 20:32:26.894+00	f
87ddcee9-317a-4b71-8b95-ce9127f2488b	8d639c58-49c6-45bb-83cf-a13f2cf355b5	075808	2026-04-23	2027-04-22	\N	2028-01-23	20	0	f	\N	\N	\N	2026-07-06 20:32:31.315+00	f
63d315c3-123e-49ff-9117-d7ef6e6fb748	487b61f7-2889-4a34-b50c-9c7db75c7d5f	075813	2026-04-23	2027-04-22	\N	2028-01-23	20	0	f	\N	\N	\N	2026-07-06 20:32:35.696+00	f
b512eefd-df5d-4a09-b0b4-ba95dfece581	f234c040-0fd9-43ab-b62e-687eaaf47c1d	075826	2026-04-28	2027-04-27	\N	2028-01-28	20	0	f	\N	\N	\N	2026-07-06 20:32:40.089+00	f
cf5a9b39-c333-4764-9416-800742d55e4b	1a7f8265-24e3-4ead-bcd0-747192c5cd30	075833	2026-04-28	2027-04-27	\N	2028-01-28	20	0	f	\N	\N	\N	2026-07-06 20:32:44.454+00	f
ef2f1dc2-f85d-449f-a9c2-9f2f73e63c9f	1e97ede4-5066-4ac3-b4b3-09ae236f5caa	075841	2026-05-05	2027-05-04	\N	2028-02-04	20	0	f	\N	\N	\N	2026-07-06 20:32:49.102+00	f
415b1cdf-befc-4871-9303-76510b6f46a4	c8a7bf35-ee8a-46e6-8fcb-9d101bed387c	075850	2026-05-07	2027-05-06	\N	2028-02-06	20	0	f	\N	\N	\N	2026-07-06 20:32:53.62+00	f
882f9277-126f-4805-a1ba-6e7c62207a23	2d46e8fa-a999-410b-a861-e7ace3cef2aa	075908	2026-06-26	2027-06-25	2027-06-25	2028-06-25	30	0	f	\N	\N	\N	2026-07-06 20:05:59.264+00	f
259bcbcb-226b-4722-aa05-ee2e007be420	9d249fdb-c48d-4208-a046-4288d5a6b389	071144	2024-11-03	2025-11-02	\N	2026-08-04	30	30	t	2026-08-10	2026-08-29	20	2026-07-06 20:30:56.069+00	f
de9e53cc-4f67-4e11-87ed-07620385c95b	8eda57ec-d586-4d0d-af4e-e087142dec04	010615	2026-01-27	2027-01-26	\N	2027-10-28	27.5	0	f	\N	\N	\N	2026-07-06 20:30:58.483+00	f
578ba5e5-f57e-4d8e-b4ac-5dfe700e7474	e387b8f9-be91-4baa-b571-1e77d9967c7c	070201	2025-11-23	2026-11-22	\N	2027-08-24	30	30	f	\N	\N	\N	2026-07-06 20:31:00.53+00	f
b28efccc-2cd2-4342-828d-b1ef890cdaa9	14300a3f-d1ae-41f3-a4c4-adcfca696717	074207	2025-08-29	2026-08-28	\N	2027-05-30	30	30	f	\N	\N	\N	2026-07-06 20:31:03.889+00	f
c8adca38-447a-4233-8831-ee3cce410081	fb78102a-f3e2-4d54-835e-da3b1c1d9785	074250	2025-09-05	2026-09-04	\N	2027-06-06	30	30	f	\N	\N	\N	2026-07-06 20:31:04.8+00	f
49b603a7-d1a9-4c12-9d36-e566c918e410	149426d3-e92e-49aa-95ae-cfbf4c3e79eb	075172	2026-03-03	2027-03-02	\N	2027-12-03	25	0	f	\N	\N	\N	2026-07-06 20:31:07.221+00	f
3ff1dccb-a099-43ee-a00c-1f719c3550ff	efa824c4-d56b-4973-b518-f3a6784a62ce	075385	2025-04-15	2026-04-14	\N	2027-01-14	30	30	f	\N	\N	\N	2026-07-06 20:31:08.154+00	f
8838d76c-d55d-4664-967c-70809f0a1137	b9e896d8-adaa-4e9b-9f5c-a8a9293c2898	075467	2026-05-06	2027-05-05	\N	2028-02-05	20	0	f	\N	\N	\N	2026-07-06 20:31:09.49+00	f
71e636f2-baaa-4a6d-9010-4fc4c467d120	478466ce-53df-4ebe-9291-69b4b3d29235	040638	2024-09-12	2025-09-11	\N	2026-06-29	30	30	t	2026-08-03	2026-09-01	30	2026-07-06 20:31:12.756+00	f
d3d01aba-d398-48a6-a9fd-8f7850fdbf2b	ebaee1a5-8c6f-4ffa-befa-0280b24d7e2b	075866	2026-05-14	2027-05-13	\N	2028-02-13	20	0	f	\N	\N	\N	2026-07-06 20:32:59.923+00	f
49df9989-b56a-48a1-8995-e2e9f25e3993	ceb4dc7d-3dd1-46d6-a566-14a381a4c7e6	075887	2026-05-28	2027-05-27	\N	2028-02-27	17.5	0	f	\N	\N	\N	2026-07-06 20:33:04.423+00	f
aabe3cf9-4135-4a25-9ba4-fe2d6e5a9893	5db6a8eb-d6da-4faa-8d00-079ae58901d2	070083	2025-07-19	2026-07-18	\N	2027-04-19	30	30	f	\N	\N	\N	2026-07-06 20:33:10.603+00	f
e60b52b7-ac99-422f-8d35-e7a9267bb377	cab0afc8-2ced-4941-b1e1-e9521af4cbd3	071687	2025-03-24	2026-03-23	\N	2026-12-23	30	30	f	\N	\N	\N	2026-07-06 20:33:13.726+00	f
94267fe1-ddc4-42dd-8d20-6c15ec631ab9	82947628-c1c4-45e2-bf35-963cd4ec4d12	073244	2025-11-01	2026-10-31	\N	2027-08-02	30	30	f	\N	\N	\N	2026-07-06 20:33:15.122+00	f
14593223-efb7-47b3-908e-c755ade9e658	75d0a357-4313-4646-8ad4-a91705d2f2cf	074854	2025-01-21	2026-01-20	\N	2026-10-22	30	30	f	\N	\N	\N	2026-07-06 20:33:19.48+00	f
b0f1d498-cdbd-485c-8d6e-1d4e27c68a16	7d775bd7-515c-4a33-b524-03c09c467b23	074857	2026-01-22	2027-01-21	\N	2027-10-23	27.5	0	f	\N	\N	\N	2026-07-06 20:33:20.97+00	f
3f2874a3-fedf-4345-b173-c19eb8843308	e3975bc7-b7a1-417c-bc6c-7d4a71e4714d	075734	2025-12-22	2026-12-21	\N	2027-09-22	30	30	f	\N	\N	\N	2026-07-06 20:33:23.961+00	f
71c960b5-504a-4dba-b389-1f75384ced7d	2ecc58b1-5066-4414-a908-97a36c08b3ec	050930	2026-03-25	2027-03-24	\N	2027-12-25	22.5	0	f	\N	\N	\N	2026-07-06 20:31:14.117+00	f
085062e9-0647-4dbe-9e2a-75f7c0975925	fcd1f1f3-137d-4e51-9136-928202498461	060853	2025-02-09	2026-02-08	\N	2026-11-10	30	30	f	\N	\N	\N	2026-07-06 20:31:15.021+00	f
584b7990-4bd9-4ae8-9aa0-3c38ae834668	04509dd6-4ec3-45fa-9fec-7a5577c0ba5e	070768	2025-11-11	2026-11-10	\N	2027-08-12	30	30	f	\N	\N	\N	2026-07-06 20:31:16.308+00	f
c092242d-3edd-4d3a-b108-576f3e6ba04a	146f363f-134a-46bf-91fe-dd87e52c8f88	073240	2024-11-01	2025-10-31	\N	2026-08-02	30	30	f	\N	\N	\N	2026-07-06 20:31:19.644+00	f
8a061a91-d75a-4d7f-b439-322329e9a616	ed412871-9102-4065-bcf9-d16a9e7bea81	073463	2026-01-23	2027-01-22	\N	2027-10-24	27.5	0	f	\N	\N	\N	2026-07-06 20:31:20.887+00	f
9e870892-2671-402d-9c37-5fce75e59ca2	08df0e04-feb3-40e9-95ea-335a8cc2e69b	073489	2025-01-29	2026-01-28	\N	2026-10-30	30	30	f	\N	\N	\N	2026-07-06 20:31:21.748+00	f
fc38863b-f635-45e9-a3f9-5fac1909dcb0	0118ef0a-337e-44e1-9eaf-b6e65959576c	074131	2025-08-19	2026-08-18	\N	2027-05-20	30	30	t	2026-06-01	2026-06-30	30	2026-07-06 20:31:23.677+00	f
5713b240-3b44-47ab-be54-2bc461902fcb	e6629df2-78e5-4dfb-8c0a-9dc259cdfce8	074296	2024-09-13	2025-09-12	\N	2026-06-29	30	30	t	2026-06-01	2026-06-30	30	2026-07-06 20:31:24.521+00	f
18bedff3-6cc5-44a2-bedb-461407055d50	b8231d04-f70c-4818-95da-8103d8c937a3	074351	2025-09-23	2026-09-22	\N	2027-06-24	30	30	f	\N	\N	\N	2026-07-06 20:31:25.918+00	f
c4542102-13a9-47b2-a79b-4f8c44cca989	da7daf8d-03ce-4d85-8cc9-834ff097e5ac	074948	2025-02-05	2026-02-04	\N	2026-11-06	30	30	f	\N	\N	\N	2026-07-06 20:31:28.071+00	f
14680d70-1e7e-4041-ae37-530fd51e8f65	525514fa-d774-4a32-94a5-daf799572396	075207	2026-03-13	2027-03-12	\N	2027-12-13	25	0	f	\N	\N	\N	2026-07-06 20:31:29.406+00	f
2700476f-e5b1-4f54-b8b2-815ac7cb89a9	02148a14-530c-4549-a5ac-80af04ce6785	075252	2025-03-27	2026-03-26	\N	2026-12-26	30	30	f	\N	\N	\N	2026-07-06 20:31:30.295+00	f
657707f8-0af0-4265-aaff-d537a016897b	cf3d40a3-3ecc-47a3-8392-0d6e6b7dbe28	075442	2026-04-30	2027-04-29	\N	2028-01-30	20	0	f	\N	\N	\N	2026-07-06 20:31:31.595+00	f
9bb3a2a8-9977-4295-937b-7b421b110bb1	1773291d-0948-4de1-ab12-5787fc1d75e8	075621	2025-08-20	2026-08-19	\N	2027-05-21	30	30	f	\N	\N	\N	2026-07-06 20:31:35.298+00	f
f760bf76-9032-423a-8189-497c6f340e4b	4785ec97-ef57-4960-a515-ca79b0a31cee	075627	2025-09-02	2026-09-01	\N	2027-06-03	30	30	f	\N	\N	\N	2026-07-06 20:31:36.197+00	f
5e5b6a77-d2f2-4563-ba1f-e95211d2205b	450ab820-1b2e-484e-ad36-c5e5eab184f9	075693	2025-11-04	2026-11-03	\N	2027-08-05	30	30	f	\N	\N	\N	2026-07-06 20:31:39.74+00	f
771d9c5b-1f00-41b6-862c-91e741287800	7f3d6039-9c37-4d94-8875-0cc29bf3f232	075701	2025-11-06	2026-11-05	\N	2027-08-07	30	30	f	\N	\N	\N	2026-07-06 20:31:40.649+00	f
ab08268f-cee9-4f16-b1d8-61cec3a14daf	89b01666-1988-48ec-a651-f3e492c26d3b	075088	2026-02-19	2027-02-18	\N	2027-11-20	25	0	f	\N	\N	\N	2026-07-06 20:31:43.636+00	f
307cc530-d095-4bb3-9aab-103aa50c09c7	da0d21d6-2889-4fea-b08a-bb5fca1c0c0c	075193	2026-03-07	2027-03-06	\N	2027-12-07	25	0	f	\N	\N	\N	2026-07-06 20:31:45.768+00	f
4a940c21-fba8-45c3-add9-e136fc8dd24e	889b3979-f279-4693-92a5-2f9b6dfc1936	071466	2025-04-27	2026-04-26	\N	2027-01-26	30	30	f	\N	\N	\N	2026-07-06 20:31:46.649+00	f
d0755e36-0492-4c7b-b7d3-46d626abd5ea	40e84c7d-2217-4c04-bb08-e3a55fc9a07e	072587	2025-06-02	2026-06-01	\N	2027-03-03	30	30	f	\N	\N	\N	2026-07-06 20:31:48.724+00	f
5e640f6b-3d44-449b-bebc-3caeed0c9f08	ca917fd7-41c6-4ea9-bb78-03f7c891d340	074846	2026-01-15	2027-01-14	\N	2027-10-16	30	30	f	\N	\N	\N	2026-07-06 20:31:49.694+00	f
bcfeb63b-25a0-4017-8755-6331581c969d	ad24de67-0d79-4f4f-b164-0d4262e29bae	075763	2026-02-24	2027-02-23	\N	2027-11-25	25	0	f	\N	\N	\N	2026-07-06 20:31:53.563+00	f
02c67f53-e563-4b0e-b51a-649a84009745	549476d4-87b2-492a-8749-f1be57fb9fd2	075776	2026-03-18	2027-03-17	\N	2027-12-18	22.5	0	f	\N	\N	\N	2026-07-06 20:31:54.515+00	f
\.


--
-- Data for Name: folgas; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.folgas (id, funcionario_id, data_inicio, periodo_trabalhado, periodo_folga, cidade_origem, tipo_passagem, saida1_projecao, saida1_real, saida2_projecao, saida2_real, saida3_projecao, saida3_real, saida4_projecao, saida4_real, saida5_projecao, saida5_real, created_at, tipo_passagem_aerea, tipo_passagem_terrestre, saida1_programada, saida2_programada, saida3_programada, saida4_programada, saida5_programada) FROM stdin;
28acf2fd-48af-4708-9182-f1af6d280e29	709ab55a-f7ed-4e80-a404-49f293fb6447	2026-05-31	180	5	CATU BA	nao	2026-11-27	\N	2027-05-26	\N	2027-11-22	\N	2028-05-20	\N	2028-11-16	\N	2026-06-03 20:16:00.816645+00	f	t	\N	\N	\N	\N	\N
af65b816-95ed-4ef8-9672-5330cabe7085	0abe8010-ac69-4277-af3d-9a00185b24cd	2026-06-07	90	5	PAULO AFONSO BA	nao	2026-09-05	\N	2026-12-04	\N	2027-03-04	\N	2027-06-02	\N	2027-08-31	\N	2026-06-03 20:18:45.567456+00	t	t	\N	\N	\N	\N	\N
80b8768c-bf1b-4d0c-8197-931d888ea939	4ec450a6-7046-4326-ba4d-30682e19f928	2026-05-20	60	3	SALGUEIRO PE	nao	2026-07-19	\N	2026-09-17	\N	2026-11-16	\N	2027-01-15	\N	2027-03-16	\N	2026-05-28 20:42:49.756392+00	t	t	\N	\N	\N	\N	\N
144ecfb5-bea2-475d-882e-2d2bb29e6207	be927f52-9181-4a49-8b37-837311673496	2026-05-18	180	5	ITAITINGA CE	nao	2026-11-14	\N	2027-05-13	\N	2027-11-09	\N	2028-05-07	\N	2028-11-03	\N	2026-05-28 20:52:29.173034+00	f	t	\N	\N	\N	\N	\N
58a45c06-032c-4e69-a53e-5947d2b43c4e	82c546e3-4ba9-4ddd-a28b-c303a2ba31c2	2026-04-14	90	5	Cruzeiro SP	terrestre	2026-07-13	\N	2026-10-11	\N	2027-01-09	\N	2027-04-09	\N	2027-07-08	\N	2026-05-28 16:53:31.652476+00	f	t	\N	\N	\N	\N	\N
277aa630-d8ff-4c43-a29b-c18c2b5820c4	3ce155ae-16fa-4fd2-90a2-3cfa719a6867	2026-05-11	180	5	CATU BA	nao	2026-11-07	\N	2027-05-06	\N	2027-11-02	\N	2028-04-30	\N	2028-10-27	\N	2026-06-03 16:45:16.114403+00	f	t	\N	\N	\N	\N	\N
16904e96-d5d6-4bca-baec-2ea4699fcf74	f09fc646-1a8f-4a6e-8849-d237631a8849	2026-05-15	90	5	RIBEIRAO BONITO SP	nao	2026-08-13	\N	2026-11-11	\N	2027-02-09	\N	2027-05-10	\N	2027-08-08	\N	2026-06-03 16:47:10.348089+00	f	t	\N	\N	\N	\N	\N
3cc97b23-46c6-4e97-a741-9cba7cfd2993	4b9de563-0a07-458b-9319-7d3eb8bbf334	2026-04-15	90	5	SAO PAULO SP	nao	2026-07-14	\N	2026-10-12	\N	2027-01-10	\N	2027-04-10	\N	2027-07-09	\N	2026-06-03 16:55:17.07797+00	f	t	\N	\N	\N	\N	\N
7dab79c3-2774-4adc-9ea8-bb9b4b3c456c	4ac7e8e1-f572-4fbc-970d-aeff6ba5f6d2	2026-06-03	90	5	LIMOEIRO DO NORTE CE	nao	2026-09-01	\N	2026-11-30	\N	2027-02-28	\N	2027-05-29	\N	2027-08-27	\N	2026-06-03 17:00:59.227019+00	t	t	\N	\N	\N	\N	\N
221ffc49-0d64-4238-abe5-78050d36e860	e9c22eeb-8b44-45ef-b301-91e65cc90d2e	2026-05-02	90	5	RIO DE JANEIRO RJ	nao	2026-07-31	\N	2026-10-29	\N	2027-01-27	\N	2027-04-27	\N	2027-07-26	\N	2026-06-03 17:01:41.957296+00	f	t	\N	\N	\N	\N	\N
fda972de-ffc8-43aa-bab8-5c7144d4448f	db4f7478-c942-49f4-a173-2a635aa782ae	2026-06-05	180	5	JAGUARUANA CE	nao	2026-12-02	\N	2027-05-31	\N	2027-11-27	\N	2028-05-25	\N	2028-11-21	\N	2026-06-03 17:08:41.891668+00	f	t	\N	\N	\N	\N	\N
3eca87d7-eb09-403f-9162-d7f123be17c0	fceb40d4-e6ad-4ef6-8e1e-86a175343cf2	2026-05-18	180	5	JAGUARUANA CE	nao	2026-11-14	\N	2027-05-13	\N	2027-11-09	\N	2028-05-07	\N	2028-11-03	\N	2026-06-03 17:10:03.578629+00	f	t	\N	\N	\N	\N	\N
651367d4-14fe-4990-b4cb-4bdd4d51eb8b	3e252902-8f07-4b31-ad3f-9657cdd3725b	2026-04-14	90	5	TEODORO SAMPAIO SP	nao	2026-07-13	\N	2026-10-11	\N	2027-01-09	\N	2027-04-09	\N	2027-07-08	\N	2026-06-03 17:11:05.007511+00	f	t	\N	\N	\N	\N	\N
1c381a51-3474-4950-92ef-01fda963af9c	c56e2d32-8dfa-4636-86c9-b8a3cbcad162	2026-05-10	90	5	BAHIA BA	nao	2026-08-08	\N	2026-11-06	\N	2027-02-04	\N	2027-05-05	\N	2027-08-03	\N	2026-06-03 17:15:09.985433+00	t	t	\N	\N	\N	\N	\N
4ea4e1da-7dec-4143-ae70-213d490f6099	ebaee1a5-8c6f-4ffa-befa-0280b24d7e2b	2026-05-23	90	5	CATU BA	nao	2026-08-21	\N	2026-11-19	\N	2027-02-17	\N	2027-05-18	\N	2027-08-16	\N	2026-06-03 19:51:37.296518+00	f	t	\N	\N	\N	\N	\N
f8251d18-21c2-4261-bd02-9354abb9526f	7cb832dc-023a-405c-bece-962bddd22d0c	2026-06-02	90	5	SAO JOSE DO BELMONTE PE	nao	2026-08-31	\N	2026-11-29	\N	2027-02-27	\N	2027-05-28	\N	2027-08-26	\N	2026-06-03 20:03:35.797933+00	t	t	\N	\N	\N	\N	\N
9be797f5-b094-446f-9959-6383b643f4d8	41f17b9c-a715-4227-92d0-4caf7fa2d8dd	2026-05-24	180	5	VENTUROSA PE	nao	2026-11-20	\N	2027-05-19	\N	2027-11-15	\N	2028-05-13	\N	2028-11-09	\N	2026-06-03 20:07:26.687106+00	f	t	\N	\N	\N	\N	\N
f2251cae-ed31-4867-8394-263d53108524	ba0aa0ea-4f84-4c79-8ca0-01bf069ff89e	2026-05-11	180	5	CATU BA	nao	2026-11-07	\N	2027-05-06	\N	2027-11-02	\N	2028-04-30	\N	2028-10-27	\N	2026-06-03 20:12:26.19896+00	f	t	\N	\N	\N	\N	\N
1c54b1f9-8fc9-41c7-9f8f-a347fb7861db	34062719-61cf-4ef3-b1cc-21bb8a2c0381	2026-06-15	90	5	REMANSO BA	nao	2026-09-13	\N	2026-12-12	\N	2027-03-12	\N	2027-06-10	\N	2027-09-08	\N	2026-06-03 20:24:31.900715+00	t	t	\N	\N	\N	\N	\N
98e3b93a-5cdd-42c7-9c6f-cd002d5b7f90	beff7969-13aa-4ad0-acb3-b178bee25629	2026-04-28	90	5	LINHARES ES	nao	2026-07-27	\N	2026-10-25	\N	2027-01-23	\N	2027-04-23	\N	2027-07-22	\N	2026-06-03 20:32:19.268959+00	t	t	\N	\N	\N	\N	\N
e6d258cd-363b-49c2-a66f-9f31cdf152ce	a1aebbf0-c987-4a62-82ab-941ed4e7e7b1	2026-05-17	90	5	SERTAOZINHO SP	nao	2026-08-15	\N	2026-11-13	\N	2027-02-11	\N	2027-05-12	\N	2027-08-10	\N	2026-06-03 20:40:35.217394+00	f	t	\N	\N	\N	\N	\N
406b5fa2-a9f3-429a-b3f9-a914ae9dd2e4	54cd7cc3-01d0-4d64-a31d-562d6c2d9073	2026-05-19	30	5	SAO PAULO SP	nao	2026-06-18	2026-06-22	2026-07-18	\N	2026-08-17	\N	2026-09-16	\N	2026-10-16	\N	2026-06-03 20:02:39.873359+00	f	t	\N	\N	\N	\N	\N
8c34a275-7c03-474f-a49f-f2487f8e8fdc	5d32feb5-73d3-4518-8681-21ceeaa22566	2026-05-13	90	5	ITAPARICA BA	nao	2026-08-11	\N	2026-11-09	\N	2027-02-07	\N	2027-05-08	\N	2027-08-06	\N	2026-05-28 20:41:45.714336+00	t	t	2026-07-14	\N	\N	\N	\N
4d23db74-4498-4238-b61c-c33e71d63124	ceb4dc7d-3dd1-46d6-a566-14a381a4c7e6	2026-06-07	90	5	ARARAQUARA SP	nao	2026-09-05	\N	2026-12-04	\N	2027-03-04	\N	2027-06-02	\N	2027-08-31	\N	2026-06-03 20:17:15.67685+00	f	t	2026-09-04	\N	\N	\N	\N
76582b4b-58ab-4329-8f00-18cba9029213	8a34f64c-b0af-4a24-a75e-949668c8697f	2026-04-22	90	5	CAMPESTRE AL	nao	2026-07-21	\N	2026-10-19	\N	2027-01-17	\N	2027-04-17	\N	2027-07-16	\N	2026-06-03 17:05:01.571269+00	t	t	2026-08-06	\N	\N	\N	\N
89d95e5a-7788-4664-a8c0-bf2dd5f98d55	4e187f38-3016-46e7-ac27-22928d5338f3	2026-05-13	90	5	GRANJA CE	nao	2026-08-11	\N	2026-11-09	\N	2027-02-07	\N	2027-05-08	\N	2027-08-06	\N	2026-06-03 16:54:07.72109+00	t	t	2026-08-14	\N	\N	\N	\N
aa02ae9a-6d28-4bd4-92a9-3722957334bc	c19914f1-62c7-4299-8ce8-ce9f35ce98f9	2026-05-11	90	5	SERRA ES	nao	2026-08-09	\N	2026-11-07	\N	2027-02-05	\N	2027-05-06	\N	2027-08-04	\N	2026-06-03 20:38:11.166328+00	t	t	2026-08-10	\N	\N	\N	\N
24da3ee2-de34-4038-9983-33405cdba0c6	a032b7df-3ea8-4faa-b17d-4f5dbbd52994	2026-05-01	90	5	CAMPINAS DO PIAUI PI	nao	2026-07-30	\N	2026-10-28	\N	2027-01-26	\N	2027-04-26	\N	2027-07-25	\N	2026-06-03 20:19:57.64334+00	t	t	2026-08-07	\N	\N	\N	\N
24b9a3a3-7342-49c9-afcb-86dd02d8e982	1a7f8265-24e3-4ead-bcd0-747192c5cd30	2026-05-05	90	5	ESCADA PE	nao	2026-08-03	\N	2026-11-01	\N	2027-01-30	\N	2027-04-30	\N	2027-07-29	\N	2026-06-03 20:33:25.993335+00	t	t	2026-08-07	\N	\N	\N	\N
bf0c9050-484b-4cf2-9247-d383b44da03d	da0d21d6-2889-4fea-b08a-bb5fca1c0c0c	2026-06-03	90	5	JAGUARUANA CE	nao	2026-09-01	\N	2026-11-30	\N	2027-02-28	\N	2027-05-29	\N	2027-08-27	\N	2026-06-03 16:56:47.47973+00	t	t	2026-09-03	\N	\N	\N	\N
37d1f9eb-ef3a-4582-8b89-5c863475a9b4	1e97ede4-5066-4ac3-b4b3-09ae236f5caa	2026-05-10	90	5	PIRAI RJ	nao	2026-08-08	\N	2026-11-06	\N	2027-02-04	\N	2027-05-05	\N	2027-08-03	\N	2026-06-03 20:13:17.103486+00	f	t	2026-08-08	\N	\N	\N	\N
1ec5a7e9-d487-4cc2-878d-61095365d6f2	13b60718-123b-4059-b99f-c9c2d6cea63a	2026-05-03	90	5	PILAR AL	nao	2026-08-01	\N	2026-10-30	\N	2027-01-28	\N	2027-04-28	\N	2027-07-27	\N	2026-06-03 19:56:59.608905+00	t	t	2026-08-07	\N	\N	\N	\N
ad5ebaff-8c1e-46fc-aa14-d6d09370faab	535de7df-c99c-491c-9a5d-670134c0d556	2026-05-10	90	5	CANDEIAS BA	nao	2026-08-08	\N	2026-11-06	\N	2027-02-04	\N	2027-05-05	\N	2027-08-03	\N	2026-06-03 19:54:04.621404+00	t	t	2026-08-07	\N	\N	\N	\N
25c7014d-7479-4a5a-81a4-673baa7cf42c	487b61f7-2889-4a34-b50c-9c7db75c7d5f	2026-05-02	90	5	CATU BA	nao	2026-07-31	\N	2026-10-29	\N	2027-01-27	\N	2027-04-27	\N	2027-07-26	\N	2026-06-03 19:52:27.520509+00	t	t	2026-08-07	\N	\N	\N	\N
a90d0b8b-33e5-4d67-80fd-2d64de95f86f	938c088b-e817-4c43-acd6-2571d19bee32	2026-05-10	90	5	BOQUEIRAO DO PIAUI PI	nao	2026-08-08	\N	2026-11-06	\N	2027-02-04	\N	2027-05-05	\N	2027-08-03	\N	2026-06-03 20:11:27.88614+00	t	t	2026-08-07	\N	\N	\N	\N
b055d665-98e9-4106-9c4a-c54f48d016c1	19d7cb2c-e21c-4863-aa70-f426d028d88c	2026-04-15	90	5	NAZARE BA	nao	2026-07-14	\N	2026-10-12	\N	2027-01-10	\N	2027-04-10	\N	2027-07-09	\N	2026-06-03 13:04:24.038276+00	t	t	2026-07-10	\N	\N	\N	\N
4bfb0320-b437-48b4-b59a-75eeba7a10c9	917fec59-ab61-45db-8f81-9beab2195f1b	2026-05-03	90	5	ICO CE	nao	2026-08-01	\N	2026-10-30	\N	2027-01-28	\N	2027-04-28	\N	2027-07-27	\N	2026-06-03 20:14:14.981163+00	t	t	2026-07-10	\N	\N	\N	\N
5e6bba25-07b3-45a8-a86f-ed322a6005a7	1ff62657-8185-45de-928d-7f9985a94b03	2026-04-23	90	5	SANTO AMARO BA	nao	2026-07-22	\N	2026-10-20	\N	2027-01-18	\N	2027-04-18	\N	2027-07-17	\N	2026-06-03 17:02:42.217207+00	t	t	2026-07-10	\N	\N	\N	\N
803fef07-f39b-4150-9eb5-2c2d94b061aa	4591a4bb-62f1-48aa-af12-082afd9a16b8	2026-05-03	90	5	ICO CE	nao	2026-08-01	\N	2026-10-30	\N	2027-01-28	\N	2027-04-28	\N	2027-07-27	\N	2026-06-03 20:05:08.493335+00	t	t	2026-07-10	\N	\N	\N	\N
30eca9fc-529d-41e0-9842-d0e0ee04a74f	cdd7635f-3086-47e8-a87f-3227c76f084f	2026-05-12	90	5	CABECEIRAS DO PIAUI PI	nao	2026-08-10	\N	2026-11-08	\N	2027-02-06	\N	2027-05-07	\N	2027-08-05	\N	2026-06-03 17:06:12.329355+00	t	t	2026-08-14	\N	\N	\N	\N
e60d24cf-78b7-4439-8a45-7a662c7e4acd	75eacd3d-5c0f-432a-839f-803d5eca0d12	2026-05-17	90	5	ICO CE	nao	2026-08-15	\N	2026-11-13	\N	2027-02-11	\N	2027-05-12	\N	2027-08-10	\N	2026-06-03 19:57:45.552965+00	t	t	2026-08-14	\N	\N	\N	\N
c4eb9493-54ab-47fc-a09b-69a3668a5b12	2eafdcdf-2226-40ed-85f6-cbf92b4257ce	2026-05-05	90	5	CANDEIAS BA	nao	2026-08-03	\N	2026-11-01	\N	2027-01-30	\N	2027-04-30	\N	2027-07-29	\N	2026-06-03 16:50:32.441664+00	t	t	2026-07-17	\N	\N	\N	\N
75755d69-d829-4b39-bea0-b4cb4f0a58e7	f2d98055-bd24-4e4a-a967-55c612ebd750	2026-05-03	90	5	CANDEIAS BA	nao	2026-08-01	\N	2026-10-30	\N	2027-01-28	\N	2027-04-28	\N	2027-07-27	\N	2026-06-03 16:51:16.114321+00	t	t	2026-07-17	\N	\N	\N	\N
8a808eb2-2374-488b-9c17-40e356ac594e	b7f63435-5138-486e-86a2-bf6dfa450540	2026-05-09	90	5	ABAETETUBA PA	nao	2026-08-07	\N	2026-11-05	\N	2027-02-03	\N	2027-05-04	\N	2027-08-02	\N	2026-06-03 19:55:29.553265+00	t	t	2026-07-17	\N	\N	\N	\N
cf4ca93d-1bb7-4dba-b8a2-2c4bd6e3eb09	258bcf6b-a4cb-4fa1-b3a5-8171244ba5bb	2026-05-03	90	5	SALVADOR BA	nao	2026-08-01	\N	2026-10-30	\N	2027-01-28	\N	2027-04-28	\N	2027-07-27	\N	2026-06-03 20:06:03.177824+00	t	t	2026-07-17	\N	\N	\N	\N
3d028296-6585-4091-ada4-8eb4a71b4a75	e17ada04-7fd7-4ae1-891b-ae6ae0145abe	2026-05-05	90	5	GUARULHOS SP	nao	2026-08-03	\N	2026-11-01	\N	2027-01-30	\N	2027-04-30	\N	2027-07-29	\N	2026-06-03 20:39:13.091236+00	t	t	2026-07-17	\N	\N	\N	\N
b1a802e5-49ec-48ff-997e-ed36eea45314	e13fd5d3-8493-4b58-bb54-269993f6fba0	2026-05-10	90	5	BOQUEIRAO DO PIAUI PI	nao	2026-08-08	\N	2026-11-06	\N	2027-02-04	\N	2027-05-05	\N	2027-08-03	\N	2026-06-03 17:11:47.603534+00	t	t	2026-07-24	\N	\N	\N	\N
87313a93-7e30-419c-bce0-e49ca72f49d0	c7758861-4f49-4632-9762-19f5f495a2df	2026-05-02	90	5	CATU BA	nao	2026-07-31	\N	2026-10-29	\N	2027-01-27	\N	2027-04-27	\N	2027-07-26	\N	2026-06-03 20:29:20.360019+00	t	t	2026-07-31	\N	\N	\N	\N
e5337be9-8a0b-43da-81f0-a47d4f9215c2	40551037-bf69-4f9e-b3df-adaf6d97527d	2026-05-05	90	5	SIMÕES FILHO BA	nao	2026-08-03	\N	2026-11-01	\N	2027-01-30	\N	2027-04-30	\N	2027-07-29	\N	2026-05-28 17:49:20.742627+00	t	t	2026-07-31	\N	\N	\N	\N
8a164cf7-451d-4995-a8c6-c5ed5eb8d9cb	51a17677-07a9-4a72-91f4-292dcf48a2ee	2026-05-11	90	5	SAO JOAO DO PARAISO MG	nao	2026-08-09	\N	2026-11-07	\N	2027-02-05	\N	2027-05-06	\N	2027-08-04	\N	2026-05-28 18:04:40.032659+00	f	t	2026-07-09	\N	\N	\N	\N
6dc5fbd5-d2d9-4426-922d-60d2f8023a1e	1beb7b83-ce97-42f1-8da1-ad6c21cc682a	2026-05-05	90	5	SALVADOR BA	nao	2026-08-03	\N	2026-11-01	\N	2027-01-30	\N	2027-04-30	\N	2027-07-29	\N	2026-05-28 20:00:04.598051+00	t	t	2026-07-31	\N	\N	\N	\N
27d45ff9-829a-4115-a71c-0900d7c5c143	f234c040-0fd9-43ab-b62e-687eaaf47c1d	2026-05-05	90	5	JACAREI SP	nao	2026-08-03	\N	2026-11-01	\N	2027-01-30	\N	2027-04-30	\N	2027-07-29	\N	2026-05-28 20:44:24.190094+00	f	t	2026-07-31	\N	\N	\N	\N
cb7a80c9-dc84-411a-b71f-74a0e935aaa8	8d639c58-49c6-45bb-83cf-a13f2cf355b5	2026-05-02	90	5	CATU BA	nao	2026-07-31	\N	2026-10-29	\N	2027-01-27	\N	2027-04-27	\N	2027-07-26	\N	2026-06-03 20:14:48.202817+00	t	t	2026-07-31	\N	\N	\N	\N
4b4a9dd6-bad8-4685-abda-6b99163719d4	e387b8f9-be91-4baa-b571-1e77d9967c7c	2026-05-18	30	5	LORENA, SP	nao	2026-06-17	\N	2026-07-17	\N	2026-08-16	\N	2026-09-15	\N	2026-10-15	\N	2026-07-01 09:48:18.255686+00	f	t	\N	\N	\N	\N	\N
7e265c5f-090c-474e-b095-40714e7df104	478466ce-53df-4ebe-9291-69b4b3d29235	2026-01-14	30	5	SAO PAULO	nao	2026-02-13	\N	2026-03-15	\N	2026-04-14	\N	2026-05-14	\N	2026-06-13	\N	2026-06-19 10:47:37.768299+00	f	t	\N	\N	\N	\N	\N
a064608b-d2cf-4f35-95a6-f6a29df93173	4c291f0b-ec29-4014-8447-ff8141486133	2026-07-03	90	5	CASTRO ALVES, BA	nao	2026-10-01	\N	2026-12-30	\N	2027-03-30	\N	2027-06-28	\N	2027-09-26	\N	2026-07-01 09:50:13.820394+00	t	t	\N	\N	\N	\N	\N
2305a353-b511-4679-9e61-ef325438df4e	5868da5b-e78e-4c06-85cc-fce019066e3e	2026-05-20	90	5	CONDADO- PE	nao	2026-08-18	\N	2026-11-16	\N	2027-02-14	\N	2027-05-15	\N	2027-08-13	\N	2026-06-19 10:49:52.294828+00	t	t	\N	\N	\N	\N	\N
68569806-f957-4faa-b078-9183fcc399a7	05159e14-4a04-4b7a-9e4f-4cb43d138925	2026-04-14	90	5	TERESINA- PI	nao	2026-07-13	\N	2026-10-11	\N	2027-01-09	\N	2027-04-09	\N	2027-07-08	\N	2026-06-19 10:53:17.072263+00	t	t	\N	\N	\N	\N	\N
47a2cb47-af62-4eb9-88f7-fdc042a63f97	2ecc58b1-5066-4414-a908-97a36c08b3ec	2026-03-26	90	5	MACEIO- AL	nao	2026-06-24	2026-06-26	2026-09-22	\N	2026-12-21	\N	2027-03-21	\N	2027-06-19	\N	2026-06-19 10:46:29.685986+00	t	t	\N	\N	\N	\N	\N
79701ecb-4e0a-4125-bb02-6e8072e1c0a6	d9a91097-6b3d-4fd8-adc7-7105b2411e3a	2026-05-04	30	5	SAO PAULO SP	nao	2026-06-03	2026-06-15	2026-07-03	\N	2026-08-02	\N	2026-09-01	\N	2026-10-01	\N	2026-06-03 20:27:21.174447+00	f	t	\N	2026-07-17	\N	\N	\N
de119db1-6325-4399-b124-874cb5e97aeb	89b01666-1988-48ec-a651-f3e492c26d3b	2026-06-03	90	5	Russas CE	nao	2026-09-01	\N	2026-11-30	\N	2027-02-28	\N	2027-05-29	\N	2027-08-27	\N	2026-06-24 18:46:07.501687+00	t	t	2026-09-03	\N	\N	\N	\N
5e47de3b-f8de-4fb9-9bf5-fd50a8a8f5d2	92ce3dcb-4f7d-4cbb-99e4-4349405e77ea	2026-04-28	90	5	BONITO DE SANTA FE PB	nao	2026-07-27	\N	2026-10-25	\N	2027-01-23	\N	2027-04-23	\N	2027-07-22	\N	2026-06-03 16:48:17.710395+00	t	t	2026-08-03	\N	\N	\N	\N
c55e96bb-4fc8-42d8-a3b1-a146e9fc372f	722f93bf-64cd-44c7-87eb-6fe9b05ae777	2026-04-23	90	5	MATA DE SAO JOAO BA	nao	2026-07-22	\N	2026-10-20	\N	2027-01-18	\N	2027-04-18	\N	2027-07-17	\N	2026-06-03 20:42:01.36951+00	t	t	2026-07-10	\N	\N	\N	\N
0066e4d6-0d54-4af3-9ceb-ac27b4b3b296	cada9130-9918-4bd4-9f11-7166c5188955	2026-04-27	60	5	Ponta Grossa - PR	nao	2026-06-26	2026-06-26	2026-08-25	\N	2026-10-24	\N	2026-12-23	\N	2027-02-21	\N	2026-06-25 17:29:38.856433+00	f	t	2026-06-26	\N	\N	\N	\N
664243ac-be35-444e-9a90-6f04b89fbb16	fcd1f1f3-137d-4e51-9136-928202498461	2026-04-13	30	5	GUARATINGUETA	nao	2026-05-13	2026-05-13	2026-06-12	\N	2026-07-12	\N	2026-08-11	\N	2026-09-10	\N	2026-06-19 10:38:46.394035+00	f	t	\N	\N	\N	\N	\N
cd46fe46-1a4b-4f17-ab78-ae8def20e4f7	ca917fd7-41c6-4ea9-bb78-03f7c891d340	2026-06-07	90	5	RECIFE PE	nao	2026-09-05	\N	2026-12-04	\N	2027-03-04	\N	2027-06-02	\N	2027-08-31	\N	2026-06-30 19:22:43.458624+00	t	t	2026-09-04	\N	\N	\N	\N
ee046f1a-0052-4cf5-b2ab-c16f47db4791	6d1786b8-676c-4511-94b5-b4123162ae8d	2026-05-10	90	5	ARACAJU SE	nao	2026-08-08	\N	2026-11-06	\N	2027-02-04	\N	2027-05-05	\N	2027-08-03	\N	2026-06-30 19:21:02.121351+00	t	t	2026-08-07	\N	\N	\N	\N
b629856c-74e5-4e53-b52b-e4f5ce3393a2	06be1efc-148e-4b38-930c-96ba72b4eca1	2026-03-26	90	5	ARACAJU SE	nao	2026-06-24	2026-06-26	2026-09-22	\N	2026-12-21	\N	2027-03-21	\N	2027-06-19	\N	2026-06-30 19:31:33.261065+00	t	t	2026-06-26	\N	\N	\N	\N
e8fd4ad3-7b2b-4764-8f69-eb9fae4e7a2f	5049a328-1980-4416-9c2e-77f649cc5b60	2026-03-19	90	5	ARACAJU SE	nao	2026-06-17	2026-06-19	2026-09-15	\N	2026-12-14	\N	2027-03-14	\N	2027-06-12	\N	2026-06-30 19:32:51.442036+00	t	t	\N	\N	\N	\N	\N
9ca60de6-68c2-4c2d-85e5-a4f12dd5666e	61272d13-22cb-499f-82a2-d9f85d2fff88	2025-07-21	60	5	GETULINA, SP	nao	2025-09-19	2025-12-21	2025-11-18	2025-12-21	2026-01-17	2026-02-27	2026-03-18	2026-04-01	2026-05-17	\N	2026-07-01 09:44:22.366505+00	f	t	\N	\N	\N	\N	\N
706cfe7d-619f-4577-8d77-11feb35fc248	68fd8b3c-130b-4141-a1db-d165e4c38aaf	2026-06-11	90	5	COCOS, BA	nao	2026-09-09	\N	2026-12-08	\N	2027-03-08	\N	2027-06-06	\N	2027-09-04	\N	2026-07-01 10:44:11.388836+00	t	t	\N	\N	\N	\N	\N
044133d4-54d9-4266-9aa4-87574b3786d1	fb78102a-f3e2-4d54-835e-da3b1c1d9785	2026-05-04	90	5	CABECEIRAS DO PIAUI, PI	nao	2026-08-02	\N	2026-10-31	\N	2027-01-29	\N	2027-04-29	\N	2027-07-28	\N	2026-07-01 09:51:12.969637+00	t	t	2026-08-07	\N	\N	\N	\N
2ecb83ae-f54a-4bf1-ae97-18c52116c6ea	efa824c4-d56b-4973-b518-f3a6784a62ce	2026-03-27	30	5	SÃO JOSÉ DOS CAMPOS, SP	nao	2026-04-26	2026-04-27	2026-05-26	2026-05-11	2026-06-25	2026-06-05	2026-07-25	\N	2026-08-24	\N	2026-07-01 09:47:25.307079+00	f	t	\N	\N	\N	\N	\N
2394aa45-602e-4d0a-816f-0e286867b9fc	149426d3-e92e-49aa-95ae-cfbf4c3e79eb	2026-05-05	90	5	INGAZEIRA, PE	nao	2026-08-03	\N	2026-11-01	\N	2027-01-30	\N	2027-04-30	\N	2027-07-29	\N	2026-07-01 10:42:02.260692+00	t	t	2026-08-20	\N	\N	\N	\N
a38e499f-dbeb-44d8-9ba0-d14014fb0e8f	2176ab2e-1917-4251-a2a1-2c3534905aad	2026-05-08	90	5	SANTO ESTEVÃO, BA	nao	2026-08-06	\N	2026-11-04	\N	2027-02-02	\N	2027-05-03	\N	2027-08-01	\N	2026-07-01 09:48:54.414989+00	t	t	2026-07-24	\N	\N	\N	\N
3d70e8e7-9e9d-48c3-a79e-a35fc382b106	14300a3f-d1ae-41f3-a4c4-adcfca696717	2026-06-25	60	5	AURORA, CE	nao	2026-08-24	\N	2026-10-23	\N	2026-12-22	\N	2027-02-20	\N	2027-04-21	\N	2026-07-01 10:43:33.468661+00	t	f	\N	\N	\N	\N	\N
bc1480e6-aa1c-46ac-88cf-bf7e0ec8e8ec	c9234c19-cf5c-418f-9a5a-7e93111437c5	2026-05-18	30	5	SAO PAULO	nao	2026-06-17	2026-06-26	2026-07-17	\N	2026-08-16	\N	2026-09-15	\N	2026-10-15	\N	2026-06-19 10:50:19.721398+00	f	t	2026-06-26	\N	\N	\N	\N
b95b55c4-45c4-4a37-876e-c6d392abd7d9	da7daf8d-03ce-4d85-8cc9-834ff097e5ac	2026-04-14	90	5	PAULO AFONSO- BA	nao	2026-07-13	\N	2026-10-11	\N	2027-01-09	\N	2027-04-09	\N	2027-07-08	\N	2026-06-19 10:50:47.547282+00	t	t	2026-07-17	\N	\N	\N	\N
35859d1f-3e45-462a-b956-1d580ae53436	525514fa-d774-4a32-94a5-daf799572396	2026-04-17	90	5	CATU	nao	2026-07-16	\N	2026-10-14	\N	2027-01-12	\N	2027-04-12	\N	2027-07-11	\N	2026-06-19 10:40:51.527297+00	t	t	2026-07-17	\N	\N	\N	\N
6dcebab2-3655-4043-b1bb-2b7560ad120e	ed412871-9102-4065-bcf9-d16a9e7bea81	2026-05-04	90	5	SÃO FELIX- BA	nao	2026-08-02	\N	2026-10-31	\N	2027-01-29	\N	2027-04-29	\N	2027-07-28	\N	2026-06-19 10:53:51.027463+00	t	t	2026-07-31	\N	\N	\N	\N
ad5dd5ac-9394-49c2-b134-73eab90c8724	02148a14-530c-4549-a5ac-80af04ce6785	2026-05-19	90	5	PAULO AFONSO	nao	2026-08-17	\N	2026-11-15	\N	2027-02-13	\N	2027-05-14	\N	2027-08-12	\N	2026-06-19 10:48:28.025568+00	t	t	2026-07-31	\N	\N	\N	\N
d999bc41-581f-4012-9673-ac2c99be8c20	89d1953b-5cff-423d-9239-12133d971027	2026-04-22	30	5	GUARATINGUETA- SP	nao	2026-05-22	2026-05-25	2026-06-21	\N	2026-07-21	\N	2026-08-20	\N	2026-09-19	\N	2026-06-19 10:54:26.917737+00	f	t	2026-05-25	\N	\N	\N	\N
82d426fe-e785-4b86-afbf-33f291f3a798	f4f5e0c6-a407-471e-9cbe-1c9411c62567	2026-06-16	45	5	JUIZ DE FORA- MG	nao	2026-07-31	\N	2026-09-14	\N	2026-10-29	\N	2026-12-13	\N	2027-01-27	\N	2026-06-19 10:49:25.008409+00	f	t	2026-07-27	\N	\N	\N	\N
0e80f617-551f-4826-8103-0110a4886914	094b876c-ba2c-4518-b30a-28dc1462c38e	2026-05-07	90	5	SALVADOR BA	nao	2026-08-05	\N	2026-11-03	\N	2027-02-01	\N	2027-05-02	\N	2027-07-31	\N	2026-07-06 13:36:05.853536+00	t	t	\N	\N	\N	\N	\N
b0ecc256-4ec4-4772-b330-6ac6af1fca16	2d46e8fa-a999-410b-a861-e7ace3cef2aa	2026-06-26	90	5	CATU, BA	nao	2026-09-24	\N	2026-12-23	\N	2027-03-23	\N	2027-06-21	\N	2027-09-19	\N	2026-07-06 20:00:42.688295+00	t	t	\N	\N	\N	\N	\N
\.


--
-- Data for Name: fornecedor_orcamentos; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.fornecedor_orcamentos (id, fornecedor_id, descricao, valor, data, arquivo_url, created_at) FROM stdin;
\.


--
-- Data for Name: fornecedores; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.fornecedores (id, razao_social, nome_fantasia, cnpj, inscricao_estadual, situacao, endereco, cidade, estado, cep, contato_nome, telefone, email, tipo_fornecimento, forma_pagamento, dados_pagamento, observacoes, cartao_cnpj_url, created_at, obra_id) FROM stdin;
bc7e7a9e-b0a2-4338-9b41-3eb3f9a7a28d	DELCARO HOTEIS LTDA	Hotel 365	05.982.547/0004-04	13.997.591-8	ativo	AV FERNANDO CORREA DA COSTA 8780 JARDIM PRESIDENTE	CUIABÁ	MT	78090-000	Cheila	65 21213300	eventos@starlis.com.br	Hospedagem	Boleto	\N	Fechamento Semanal, 1 semana de prazo	\N	2026-07-07 18:33:31.525693+00	ae387bdc-cf9e-4d3a-ad30-5a16e85801bc
54733aac-90c3-48f8-8418-cb7ecb6c2056	Moov Fretamento Ltda	Moov Transportes	64.873.787/0001-89	\N	ativo	R DEZESSEIS 191 QUADRA15 LOTE 02 SALA A ALTOS DO COXIPO CEP 78.088-530 CUIABA MT	CUIABÁ	MT	78.088-530	kAMYLA	65 9269-5654	Contato@moovtransportes.com.br	Transporte	Boleto	Banco Siccob\nAg: 4345\nconta: 493.589-6	\N	\N	2026-07-07 14:53:03.958383+00	ae387bdc-cf9e-4d3a-ad30-5a16e85801bc
\.


--
-- Data for Name: funcionarios; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.funcionarios (id, matricula, nome_completo, cpf, ctps, serie_ctps, uf_ctps, pis, data_admissao, situacao, tipo, funcao_id, empresa_id, obra_id, cidade, uf, foto_url, created_at, updated_at, transferido, data_transferencia, obra_transferencia_id, centro_custo_transferencia, data_mobilizacao, data_desmobilizacao, funcao_manual, tipo_transferencia, periodo_experiencia, efetivado, observacao_interna, alojamento_id, data_demissao, tipo_demissao, motivo_demissao, salario, tipo_pagamento, alojamento_origem_id, data_integracao_origem) FROM stdin;
82c546e3-4ba9-4ddd-a28b-c303a2ba31c2	075785	WATILA RODRIGUES MIRANDA	\N	\N	\N	\N	\N	2026-04-07	ativo	nova_admissao	ca4eb86b-d552-4ec0-9256-69e57e2cb588	4489b3ec-6774-4a13-bc24-31b77deb6ae7	0d899f11-785d-4edd-a951-bac82fae074f	CRUZEIRO	SP	https://lqggoshphakeuufibdno.supabase.co/storage/v1/object/public/funcionarios/fotos/1779978635722.png	2026-05-28 13:10:08.939279	2026-05-28 13:10:08.939279	f	\N	\N	\N	2026-04-15	\N	\N	\N	45	f	\N	7e18e7ce-a57d-4369-88de-8097c3286957	\N	\N	\N	\N	\N	\N	\N
3e252902-8f07-4b31-ad3f-9657cdd3725b	075786	GERALDO ALVES PINTO	\N	\N	\N	\N	\N	2026-04-07	ativo	nova_admissao	f510f6aa-f1d8-4fd9-b85f-dd8ff840cf76	4489b3ec-6774-4a13-bc24-31b77deb6ae7	0d899f11-785d-4edd-a951-bac82fae074f	TEODORO SAMPAIO	SP	https://lqggoshphakeuufibdno.supabase.co/storage/v1/object/public/funcionarios/fotos/1781717233724.png	2026-06-02 11:57:10.90763	2026-06-02 11:57:10.90763	f	\N	\N	\N	\N	\N	\N	\N	45	f	.	7e18e7ce-a57d-4369-88de-8097c3286957	\N	\N	\N	\N	\N	\N	\N
2c88777d-11d7-4dcc-9948-9e77d8ef9747	072362	GUSTAVO HENRIQUE CARTACHO LIMA DO NASCIMENTO	\N	\N	\N	\N	\N	2023-03-30	ativo	nova_admissao	2715e2bd-f45c-448b-8900-b1374680b947	4489b3ec-6774-4a13-bc24-31b77deb6ae7	0d899f11-785d-4edd-a951-bac82fae074f	PARANAVA	PR	\N	2026-06-02 11:58:46.60764	2026-06-02 11:58:46.60764	f	\N	\N	\N	\N	\N	\N	\N	45	t	\N	31c7f2f6-8717-4135-b04f-e1224e48ab85	\N	\N	\N	\N	\N	\N	\N
1beb7b83-ce97-42f1-8da1-ad6c21cc682a	075828	ALEX LORENZO MATOS SANTOS	\N	\N	\N	\N	\N	2026-04-28	ativo	nova_admissao	378753e1-7221-45f7-a28e-0f988d31c30b	4489b3ec-6774-4a13-bc24-31b77deb6ae7	0d899f11-785d-4edd-a951-bac82fae074f	SALVADOR 	BA	https://lqggoshphakeuufibdno.supabase.co/storage/v1/object/public/funcionarios/fotos/1779998362237.png	2026-05-28 19:59:24.434627	2026-05-28 19:59:24.434627	f	\N	\N	\N	2026-05-06	\N	\N	\N	45	f	\N	7cec8c21-12e1-491d-89fb-fd3599eae796	\N	\N	\N	\N	\N	\N	\N
40551037-bf69-4f9e-b3df-adaf6d97527d	075831	ADRIANO FERREIRA GOMES	\N	\N	\N	\N	\N	2026-04-28	ativo	nova_admissao	378753e1-7221-45f7-a28e-0f988d31c30b	4489b3ec-6774-4a13-bc24-31b77deb6ae7	0d899f11-785d-4edd-a951-bac82fae074f	SIMÕES FILHO 	BA	https://lqggoshphakeuufibdno.supabase.co/storage/v1/object/public/funcionarios/fotos/1779990513083.jpeg	2026-05-28 17:48:36.108537	2026-05-28 17:48:36.108537	f	\N	\N	\N	2026-05-06	\N	\N	\N	45	f	\N	7cec8c21-12e1-491d-89fb-fd3599eae796	\N	\N	\N	\N	\N	\N	\N
f234c040-0fd9-43ab-b62e-687eaaf47c1d	075826	ALEXSANDRO DE CAMPOS	\N	\N	\N	\N	\N	2026-04-28	ativo	nova_admissao	378753e1-7221-45f7-a28e-0f988d31c30b	4489b3ec-6774-4a13-bc24-31b77deb6ae7	0d899f11-785d-4edd-a951-bac82fae074f	JACAREI	SP	https://lqggoshphakeuufibdno.supabase.co/storage/v1/object/public/funcionarios/fotos/1779998520457.jpeg	2026-05-28 20:02:01.706726	2026-05-28 20:02:01.706726	f	\N	\N	\N	2026-05-06	\N	\N	\N	45	f	\N	7cec8c21-12e1-491d-89fb-fd3599eae796	\N	\N	\N	\N	\N	\N	\N
2eafdcdf-2226-40ed-85f6-cbf92b4257ce	075830	CLAUDIO ASTRO CARVALHO	\N	\N	\N	\N	\N	2026-04-28	ativo	nova_admissao	c5ddb144-5847-4aec-b64b-cb346f96cfad	4489b3ec-6774-4a13-bc24-31b77deb6ae7	0d899f11-785d-4edd-a951-bac82fae074f	CANDEIAS	BA	https://lqggoshphakeuufibdno.supabase.co/storage/v1/object/public/funcionarios/fotos/1781716921397.jpeg	2026-06-02 11:56:26.625017	2026-06-02 11:56:26.625017	f	\N	\N	\N	\N	\N	\N	\N	45	f	\N	7cec8c21-12e1-491d-89fb-fd3599eae796	\N	\N	\N	\N	\N	\N	\N
be927f52-9181-4a49-8b37-837311673496	075848	ANTONIO DA SILVA FREITAS	\N	\N	\N	\N	\N	2026-05-07	ativo	nova_admissao	7d9dffa9-1696-4cb1-bfda-1e2fd2fc255a	4489b3ec-6774-4a13-bc24-31b77deb6ae7	0d899f11-785d-4edd-a951-bac82fae074f	ITAITINGA	CE	https://lqggoshphakeuufibdno.supabase.co/storage/v1/object/public/funcionarios/fotos/1780001269108.jpeg	2026-05-28 20:47:58.383763	2026-05-28 20:47:58.383763	f	\N	\N	\N	2026-05-18	\N	\N	\N	45	f	\N	56f35f51-2e54-4692-82da-a1a505608111	\N	\N	\N	\N	\N	\N	\N
c56e2d32-8dfa-4636-86c9-b8a3cbcad162	071109	GILSON COELHO MESSIAS	\N	\N	\N	\N	\N	2020-09-24	ativo	nova_admissao	ea0e0abb-9679-41a1-8293-33e3adcb6fa9	4489b3ec-6774-4a13-bc24-31b77deb6ae7	0d899f11-785d-4edd-a951-bac82fae074f	BAHIA	BA	\N	2026-06-02 11:58:46.60764	2026-06-02 11:58:46.60764	f	\N	\N	\N	\N	\N	\N	\N	45	t	\N	8371894c-46f8-42bf-9673-e9b149342305	\N	\N	\N	\N	\N	\N	\N
5d32feb5-73d3-4518-8681-21ceeaa22566	074785	ALTAIR DA SILVA MARTINS	\N	\N	\N	\N	\N	2024-12-20	transferido	transferencia	0a96b9a4-ef33-4088-8d90-ca90dcffc41b	17e8550c-d196-4b45-8931-5ae1c4042e17	0d899f11-785d-4edd-a951-bac82fae074f	ITAPARICA	BA	https://lqggoshphakeuufibdno.supabase.co/storage/v1/object/public/funcionarios/fotos/1779999214293.jpg	2026-05-28 20:13:36.267371	2026-05-28 20:13:36.267371	t	2026-05-11	3bd8994a-2652-4f14-a89e-eec4edbf4b00	23959	2026-05-11	\N	\N	recebimento	45	t	\N	b7abc826-8aba-4f32-8e08-587315389657	\N	\N	\N	\N	\N	\N	\N
51a17677-07a9-4a72-91f4-292dcf48a2ee	072113	AILTON OLIVEIRA SOUSA	\N	\N	\N	\N	\N	2022-10-27	transferido	transferencia	fd98fe54-a012-49ae-8a4f-4359c7556f01	4489b3ec-6774-4a13-bc24-31b77deb6ae7	0d899f11-785d-4edd-a951-bac82fae074f	SAO JOAO DO PARAISO	MG	https://lqggoshphakeuufibdno.supabase.co/storage/v1/object/public/funcionarios/fotos/1779990833551.png	2026-05-28 17:53:56.685143	2026-05-28 17:53:56.685143	t	2026-05-11	f1b4fe50-69ba-4443-aa10-53e4d8d124c7	23698	2026-05-11	\N	\N	recebimento	45	t	\N	b7abc826-8aba-4f32-8e08-587315389657	\N	\N	\N	\N	\N	\N	\N
487b61f7-2889-4a34-b50c-9c7db75c7d5f	075813	JADSON SANTOS DOS SANTOS	\N	\N	\N	\N	\N	2026-04-23	ativo	nova_admissao	cde079dd-2d53-44c2-9054-6245d154bcf6	4489b3ec-6774-4a13-bc24-31b77deb6ae7	0d899f11-785d-4edd-a951-bac82fae074f	CATU	BA	https://lqggoshphakeuufibdno.supabase.co/storage/v1/object/public/funcionarios/fotos/1781717307522.png	2026-06-02 11:58:46.60764	2026-06-02 11:58:46.60764	f	\N	\N	\N	\N	\N	\N	\N	45	f	\N	ae89e516-b560-4cbd-9150-5d3acc49e49a	\N	\N	\N	\N	\N	\N	\N
c744692a-9152-43cb-8c92-c2dad53a6dd9	073019	JEIZIEL ALVES SILVA DE ASSIS	\N	\N	\N	\N	\N	2023-09-14	ativo	nova_admissao	\N	4489b3ec-6774-4a13-bc24-31b77deb6ae7	0d899f11-785d-4edd-a951-bac82fae074f	AGRESTINA	PE	\N	2026-06-02 11:58:46.60764	2026-06-02 11:58:46.60764	f	\N	\N	\N	\N	\N	ASSISTENTE ADMINISTRATIVO II	\N	45	t	\N	d1b9c5b6-5594-487e-b8f0-22abace46f0f	\N	\N	\N	\N	\N	\N	\N
4b9de563-0a07-458b-9319-7d3eb8bbf334	071110	DIEGO FERREIRA ALVES	\N	\N	\N	\N	\N	2020-09-24	ativo	nova_admissao	ab979acd-d194-4920-801d-82f3707d67fd	4489b3ec-6774-4a13-bc24-31b77deb6ae7	0d899f11-785d-4edd-a951-bac82fae074f	SAO PAULO	SP	\N	2026-06-02 11:56:26.625017	2026-06-02 11:56:26.625017	f	\N	\N	\N	\N	\N	\N	\N	45	t	\N	d1b9c5b6-5594-487e-b8f0-22abace46f0f	\N	\N	\N	\N	\N	\N	\N
b7f63435-5138-486e-86a2-bf6dfa450540	075836	JOELSON GONCALVES MARQUES	\N	\N	\N	\N	\N	2026-05-04	ativo	nova_admissao	c5ddb144-5847-4aec-b64b-cb346f96cfad	4489b3ec-6774-4a13-bc24-31b77deb6ae7	0d899f11-785d-4edd-a951-bac82fae074f	ABAETETUBA	PA	https://lqggoshphakeuufibdno.supabase.co/storage/v1/object/public/funcionarios/fotos/1781717357869.png	2026-06-02 11:58:46.60764	2026-06-02 11:58:46.60764	f	\N	\N	\N	\N	\N	\N	\N	45	f	\N	e42bb35b-e6c4-4db2-8c2b-4c2e8f69a2e3	\N	\N	\N	\N	\N	\N	\N
40e84c7d-2217-4c04-bb08-e3a55fc9a07e	72587	BRUNO GUSTAVO COELHO	\N	\N	\N	\N	\N	2023-06-02	ativo	efetivo	43d587ab-d22c-41ee-89e8-6d58f41c71ac	4489b3ec-6774-4a13-bc24-31b77deb6ae7	0ea37ce8-5f9d-4270-ac46-73e6c169c6d2	SÃO JOSE DOS CAMPOS	SP	https://lqggoshphakeuufibdno.supabase.co/storage/v1/object/public/funcionarios/fotos/1781790876746.png	2026-06-18 13:54:38.493502	2026-06-18 13:54:38.493502	f	\N	\N	\N	2026-01-26	\N	\N	\N	30	t	ALOJADO	f6f57e02-f34d-4586-9bc2-d32da81a6931	\N	\N	\N	\N	\N	\N	\N
dd0edc19-9be5-4f0a-969c-786fe70bee55	030670	JOAO MARCIO GUILHERMINO SILVA	\N	\N	\N	\N	\N	2012-08-09	ativo	nova_admissao	dee60c7c-2c17-413c-a1e7-d49c12e7e8e2	4489b3ec-6774-4a13-bc24-31b77deb6ae7	0d899f11-785d-4edd-a951-bac82fae074f	FERRAZ DE VASCONCELO	SP	\N	2026-06-02 11:58:46.60764	2026-06-02 11:58:46.60764	f	\N	\N	\N	\N	\N	\N	\N	45	t	\N	\N	\N	\N	\N	\N	\N	\N	\N
54cd7cc3-01d0-4d64-a31d-562d6c2d9073	030366	JOSE AUGUSTO FRANCISCO DE SOUZA	\N	\N	\N	\N	\N	2012-04-16	ativo	nova_admissao	7ccbe19e-d491-46d3-a17e-e0227d6355fc	4489b3ec-6774-4a13-bc24-31b77deb6ae7	0d899f11-785d-4edd-a951-bac82fae074f	ITAQUAQUECETUBA	SP	\N	2026-06-02 11:59:33.324033	2026-06-02 11:59:33.324033	f	\N	\N	\N	\N	\N	\N	\N	45	t	\N	c8e6e203-9c03-42cb-9a30-63fca14dc225	\N	\N	\N	\N	\N	\N	\N
1ff62657-8185-45de-928d-7f9985a94b03	075797	EVERTON CHAGAS DE QUEIROZ	\N	\N	\N	\N	\N	2026-04-15	ativo	nova_admissao	cde079dd-2d53-44c2-9054-6245d154bcf6	4489b3ec-6774-4a13-bc24-31b77deb6ae7	0d899f11-785d-4edd-a951-bac82fae074f	SANTO AMARO	BA	https://lqggoshphakeuufibdno.supabase.co/storage/v1/object/public/funcionarios/fotos/1781717066824.jpeg	2026-06-02 11:57:10.90763	2026-06-02 11:57:10.90763	f	\N	\N	\N	\N	\N	\N	\N	45	f	\N	c8e6e203-9c03-42cb-9a30-63fca14dc225	\N	\N	\N	\N	\N	\N	\N
f2d98055-bd24-4e4a-a967-55c612ebd750	075811	CRISTIAN FABIO DOS SANTOS DOS REIS	\N	\N	\N	\N	\N	2026-04-23	ativo	nova_admissao	c5ddb144-5847-4aec-b64b-cb346f96cfad	4489b3ec-6774-4a13-bc24-31b77deb6ae7	0d899f11-785d-4edd-a951-bac82fae074f	CANDEIAS	BA	https://lqggoshphakeuufibdno.supabase.co/storage/v1/object/public/funcionarios/fotos/1781716950101.png	2026-06-02 11:56:26.625017	2026-06-02 11:56:26.625017	f	\N	\N	\N	\N	\N	\N	\N	45	f	\N	5e1a3306-b40c-4277-8c03-5e317063af3b	\N	\N	\N	\N	\N	\N	\N
4ec450a6-7046-4326-ba4d-30682e19f928	073944	ANDRE LUIS CASTELO BRANCO	\N	\N	\N	\N	\N	2024-06-17	ativo	transferencia	c9e71c1f-6fda-4087-9815-9198f7130ce5	4489b3ec-6774-4a13-bc24-31b77deb6ae7	0d899f11-785d-4edd-a951-bac82fae074f	SALGUEIRO	PE	https://lqggoshphakeuufibdno.supabase.co/storage/v1/object/public/funcionarios/fotos/1780000634881.png	2026-05-28 20:37:15.653054	2026-05-28 20:37:15.653054	f	\N	\N	\N	2026-03-17	\N	\N	\N	45	t	\N	2b753fd1-03b8-433a-a187-24f4b5ccb1de	\N	\N	\N	\N	\N	\N	\N
e9c22eeb-8b44-45ef-b301-91e65cc90d2e	075812	ESMAEL CARLOS NASCIMENTO DOS SANTOS	\N	\N	\N	\N	\N	2026-04-23	ativo	nova_admissao	b19eb87e-ab83-4460-b57f-f0302aaa1f0d	4489b3ec-6774-4a13-bc24-31b77deb6ae7	0d899f11-785d-4edd-a951-bac82fae074f	RIO DE JANEIRO	RJ	https://lqggoshphakeuufibdno.supabase.co/storage/v1/object/public/funcionarios/fotos/1781717039496.png	2026-06-02 11:57:10.90763	2026-06-02 11:57:10.90763	f	\N	\N	\N	\N	\N	\N	\N	45	f	\N	5e1a3306-b40c-4277-8c03-5e317063af3b	\N	\N	\N	\N	\N	\N	\N
535de7df-c99c-491c-9a5d-670134c0d556	075834	JERRI SANTOS DA CONCEICAO PINTO	\N	\N	\N	\N	\N	2026-05-04	ativo	nova_admissao	c5ddb144-5847-4aec-b64b-cb346f96cfad	4489b3ec-6774-4a13-bc24-31b77deb6ae7	0d899f11-785d-4edd-a951-bac82fae074f	CANDEIAS	BA	https://lqggoshphakeuufibdno.supabase.co/storage/v1/object/public/funcionarios/fotos/1781717334697.jpeg	2026-06-02 11:58:46.60764	2026-06-02 11:58:46.60764	f	\N	\N	\N	\N	\N	\N	\N	45	f	\N	e42bb35b-e6c4-4db2-8c2b-4c2e8f69a2e3	\N	\N	\N	\N	\N	\N	\N
4591a4bb-62f1-48aa-af12-082afd9a16b8	075822	JOSE MARCELO DE SOUSA	\N	\N	\N	\N	\N	2026-04-24	ativo	nova_admissao	55c090af-e003-4b88-b130-6cd81c801d33	4489b3ec-6774-4a13-bc24-31b77deb6ae7	0d899f11-785d-4edd-a951-bac82fae074f	ICO	CE	https://lqggoshphakeuufibdno.supabase.co/storage/v1/object/public/funcionarios/fotos/1781717444676.png	2026-06-02 11:59:33.324033	2026-06-02 11:59:33.324033	f	\N	\N	\N	\N	\N	\N	\N	45	f	\N	7e18e7ce-a57d-4369-88de-8097c3286957	\N	\N	\N	\N	\N	\N	\N
258bcf6b-a4cb-4fa1-b3a5-8171244ba5bb	075805	JOSE RENATO DA GLORIA SANTOS	\N	\N	\N	\N	\N	2026-04-23	ativo	nova_admissao	c5ddb144-5847-4aec-b64b-cb346f96cfad	4489b3ec-6774-4a13-bc24-31b77deb6ae7	0d899f11-785d-4edd-a951-bac82fae074f	SALVADOR	BA	https://lqggoshphakeuufibdno.supabase.co/storage/v1/object/public/funcionarios/fotos/1781717462820.png	2026-06-02 11:59:33.324033	2026-06-02 11:59:33.324033	f	\N	\N	\N	\N	\N	\N	\N	45	f	\N	5e1a3306-b40c-4277-8c03-5e317063af3b	\N	\N	\N	\N	\N	\N	\N
4ac7e8e1-f572-4fbc-970d-aeff6ba5f6d2	075550	EDMAR GUILHERMINO DA SILVA	\N	\N	\N	\N	\N	2025-06-26	ativo	nova_admissao	f5c1578b-6c06-4b0c-a7f6-165779ef8751	4489b3ec-6774-4a13-bc24-31b77deb6ae7	0d899f11-785d-4edd-a951-bac82fae074f	LIMOEIRO DO NORTE	CE	\N	2026-06-03 12:56:19.930749	2026-06-03 12:56:19.930749	f	\N	\N	\N	\N	\N	\N	\N	30	t	\N	b7abc826-8aba-4f32-8e08-587315389657	\N	\N	\N	\N	\N	\N	\N
e17ada04-7fd7-4ae1-891b-ae6ae0145abe	075829	WARLEM ALVES	\N	\N	\N	\N	\N	2026-04-28	ativo	nova_admissao	d656b2d1-ec14-4eb8-8edb-2fb325bc6234	4489b3ec-6774-4a13-bc24-31b77deb6ae7	0d899f11-785d-4edd-a951-bac82fae074f	GUARULHOS	SP	https://lqggoshphakeuufibdno.supabase.co/storage/v1/object/public/funcionarios/fotos/1781718011153.jpeg	2026-06-02 12:01:35.03519	2026-06-02 12:01:35.03519	f	\N	\N	\N	\N	\N	\N	\N	45	f	\N	7cec8c21-12e1-491d-89fb-fd3599eae796	\N	\N	\N	\N	\N	\N	\N
4e187f38-3016-46e7-ac27-22928d5338f3	075532	DENIS BARBOSA DOS SANTOS	\N	\N	\N	\N	\N	2025-06-16	ativo	nova_admissao	fb4ee1c9-e474-462a-8978-e9d53c83bc09	4489b3ec-6774-4a13-bc24-31b77deb6ae7	0d899f11-785d-4edd-a951-bac82fae074f	GRANJA	CE	\N	2026-06-03 12:56:19.930749	2026-06-03 12:56:19.930749	f	\N	\N	\N	\N	\N	\N	\N	30	t	Efetivar	e42bb35b-e6c4-4db2-8c2b-4c2e8f69a2e3	\N	\N	\N	\N	\N	\N	\N
c7758861-4f49-4632-9762-19f5f495a2df	075814	RICARDO CESAR COSTA SANTOS	\N	\N	\N	\N	\N	2026-04-23	ativo	nova_admissao	8829bd95-36aa-4565-ae5d-c4f170124b38	4489b3ec-6774-4a13-bc24-31b77deb6ae7	0d899f11-785d-4edd-a951-bac82fae074f	CATU	BA	https://lqggoshphakeuufibdno.supabase.co/storage/v1/object/public/funcionarios/fotos/1781717859000.png	2026-06-02 12:00:30.485356	2026-06-02 12:00:30.485356	f	\N	\N	\N	\N	\N	\N	\N	45	f	efetivar	c8e6e203-9c03-42cb-9a30-63fca14dc225	\N	\N	\N	\N	\N	\N	\N
a032b7df-3ea8-4faa-b17d-4f5dbbd52994	075810	PEDRO JUNIOR CELESTINO DE OLIVEIRA	\N	\N	\N	\N	\N	2026-04-23	ativo	nova_admissao	b19eb87e-ab83-4460-b57f-f0302aaa1f0d	4489b3ec-6774-4a13-bc24-31b77deb6ae7	0d899f11-785d-4edd-a951-bac82fae074f	CAMPINAS DO PIAUI	PI	https://lqggoshphakeuufibdno.supabase.co/storage/v1/object/public/funcionarios/fotos/1781717829139.png	2026-06-02 12:00:30.485356	2026-06-02 12:00:30.485356	f	\N	\N	\N	\N	\N	\N	\N	45	f	Efetivar	7cec8c21-12e1-491d-89fb-fd3599eae796	\N	\N	\N	\N	\N	\N	\N
cdd7635f-3086-47e8-a87f-3227c76f084f	075708	FRANCISCO SANTIAGO DA SILVA	\N	\N	\N	\N	\N	2025-11-10	ativo	nova_admissao	f5c1578b-6c06-4b0c-a7f6-165779ef8751	4489b3ec-6774-4a13-bc24-31b77deb6ae7	0d899f11-785d-4edd-a951-bac82fae074f	CABECEIRAS DO PIAUI	PI	\N	2026-06-03 12:56:19.930749	2026-06-03 12:56:19.930749	f	\N	\N	\N	\N	\N	\N	\N	45	t	\N	7cec8c21-12e1-491d-89fb-fd3599eae796	\N	\N	\N	\N	\N	\N	\N
da0d21d6-2889-4fea-b08a-bb5fca1c0c0c	075193	DIOGO DOS SANTOS ARAUJO	\N	\N	\N	\N	\N	2025-03-07	ativo	nova_admissao	fb4ee1c9-e474-462a-8978-e9d53c83bc09	4489b3ec-6774-4a13-bc24-31b77deb6ae7	0d899f11-785d-4edd-a951-bac82fae074f	JAGUARUANA	CE	\N	2026-06-03 12:56:19.930749	2026-06-03 12:56:19.930749	f	\N	\N	\N	\N	\N	\N	\N	30	t	Efetivar Joao	b7abc826-8aba-4f32-8e08-587315389657	\N	\N	\N	\N	\N	\N	\N
3ce155ae-16fa-4fd2-90a2-3cfa719a6867	075851	ANTONIO SANTOS PORTUGAL	\N	\N	\N	\N	\N	2026-05-07	ativo	nova_admissao	338d331e-ef03-4d94-9369-567ee922f1e9	4489b3ec-6774-4a13-bc24-31b77deb6ae7	0d899f11-785d-4edd-a951-bac82fae074f	CATU	BA	https://lqggoshphakeuufibdno.supabase.co/storage/v1/object/public/funcionarios/fotos/1781716824018.png	2026-06-03 12:56:19.930749	2026-06-03 12:56:19.930749	f	\N	\N	\N	\N	\N	\N	\N	45	f	\N	56f35f51-2e54-4692-82da-a1a505608111	\N	\N	\N	\N	\N	\N	\N
fceb40d4-e6ad-4ef6-8e1e-86a175343cf2	075847	GABRIEL OLIVEIRA DOS SANTOS	\N	\N	\N	\N	\N	2026-05-07	ativo	nova_admissao	338d331e-ef03-4d94-9369-567ee922f1e9	4489b3ec-6774-4a13-bc24-31b77deb6ae7	0d899f11-785d-4edd-a951-bac82fae074f	JAGUARUANA	CE	https://lqggoshphakeuufibdno.supabase.co/storage/v1/object/public/funcionarios/fotos/1781717214063.png	2026-06-03 12:56:19.930749	2026-06-03 12:56:19.930749	f	\N	\N	\N	\N	\N	\N	\N	45	f	\N	56f35f51-2e54-4692-82da-a1a505608111	\N	\N	\N	\N	\N	\N	\N
ebaee1a5-8c6f-4ffa-befa-0280b24d7e2b	075866	IVANILDO DE JESUS SANTOS	\N	\N	\N	\N	\N	2026-05-14	ativo	nova_admissao	338d331e-ef03-4d94-9369-567ee922f1e9	4489b3ec-6774-4a13-bc24-31b77deb6ae7	0d899f11-785d-4edd-a951-bac82fae074f	CATU	BA	https://lqggoshphakeuufibdno.supabase.co/storage/v1/object/public/funcionarios/fotos/1781717284237.png	2026-06-03 12:56:19.930749	2026-06-03 12:56:19.930749	f	\N	\N	\N	\N	\N	\N	\N	45	f	\N	56f35f51-2e54-4692-82da-a1a505608111	\N	\N	\N	\N	\N	\N	\N
41f17b9c-a715-4227-92d0-4caf7fa2d8dd	075865	KAWANN DOS SANTOS TENORIO FEITOSA	\N	\N	\N	\N	\N	2026-05-14	ativo	nova_admissao	338d331e-ef03-4d94-9369-567ee922f1e9	4489b3ec-6774-4a13-bc24-31b77deb6ae7	0d899f11-785d-4edd-a951-bac82fae074f	VENTUROSA	PE	https://lqggoshphakeuufibdno.supabase.co/storage/v1/object/public/funcionarios/fotos/1781717480962.jpg	2026-06-03 12:56:19.930749	2026-06-03 12:56:19.930749	f	\N	\N	\N	\N	\N	\N	\N	45	f	\N	56f35f51-2e54-4692-82da-a1a505608111	\N	\N	\N	\N	\N	\N	\N
ba0aa0ea-4f84-4c79-8ca0-01bf069ff89e	075849	LUIZ GABRIEL DOS SANTOS ATAIDE	\N	\N	\N	\N	\N	2026-05-07	ativo	nova_admissao	338d331e-ef03-4d94-9369-567ee922f1e9	4489b3ec-6774-4a13-bc24-31b77deb6ae7	0d899f11-785d-4edd-a951-bac82fae074f	CATU	BA	https://lqggoshphakeuufibdno.supabase.co/storage/v1/object/public/funcionarios/fotos/1781717605704.png	2026-06-03 14:25:52.840486	2026-06-03 14:25:52.840486	f	\N	\N	\N	\N	\N	\N	\N	45	f	\N	56f35f51-2e54-4692-82da-a1a505608111	\N	\N	\N	\N	\N	\N	\N
938c088b-e817-4c43-acd6-2571d19bee32	075835	LAMEQUE RODRIGUES SILVA SOARES	\N	\N	\N	\N	\N	2026-05-04	ativo	nova_admissao	55c090af-e003-4b88-b130-6cd81c801d33	4489b3ec-6774-4a13-bc24-31b77deb6ae7	0d899f11-785d-4edd-a951-bac82fae074f	BOQUEIRAO DO PIAUI	PI	https://lqggoshphakeuufibdno.supabase.co/storage/v1/object/public/funcionarios/fotos/1781717504033.png	2026-06-02 11:59:33.324033	2026-06-02 11:59:33.324033	f	\N	\N	\N	\N	\N	\N	\N	45	f	\N	e42bb35b-e6c4-4db2-8c2b-4c2e8f69a2e3	\N	\N	\N	\N	\N	\N	\N
c19914f1-62c7-4299-8ce8-ce9f35ce98f9	070252	USIEL BRAZ RIBEIRO	\N	\N	\N	\N	\N	2018-12-10	ativo	nova_admissao	050b8cd2-1116-4b81-ab1d-e69eebc8c823	4489b3ec-6774-4a13-bc24-31b77deb6ae7	0d899f11-785d-4edd-a951-bac82fae074f	SERRA	AL	\N	2026-06-03 14:53:50.827647	2026-06-03 14:53:50.827647	f	\N	\N	\N	2026-05-13	\N	\N	\N	45	t	\N	8371894c-46f8-42bf-9673-e9b149342305	\N	\N	\N	\N	\N	\N	\N
7cb832dc-023a-405c-bece-962bddd22d0c	073163	JOSE HERCULES DA SILVA	\N	\N	\N	\N	\N	2023-10-09	ativo	nova_admissao	f5c1578b-6c06-4b0c-a7f6-165779ef8751	4489b3ec-6774-4a13-bc24-31b77deb6ae7	0d899f11-785d-4edd-a951-bac82fae074f	SAO JOSE DO BELMONTE	PE	\N	2026-06-03 12:56:19.930749	2026-06-03 12:56:19.930749	f	\N	\N	\N	\N	\N	\N	\N	45	t	\N	b7abc826-8aba-4f32-8e08-587315389657	\N	\N	\N	\N	\N	\N	\N
17cbdc3e-d043-4eb5-8771-b72a7ac2297a	075864	ANTONIO DAMASCENO NOGUEIRA	\N	\N	\N	\N	\N	2026-05-14	ativo	nova_admissao	32b24cfd-b79a-4b2b-a72d-5cf2a131205c	4489b3ec-6774-4a13-bc24-31b77deb6ae7	0d899f11-785d-4edd-a951-bac82fae074f	JAGUARUANA	CE	https://lqggoshphakeuufibdno.supabase.co/storage/v1/object/public/funcionarios/fotos/1780666534267.jpg	2026-06-03 12:56:19.930749	2026-06-03 12:56:19.930749	f	\N	\N	\N	\N	\N	\N	\N	45	f	\N	ae89e516-b560-4cbd-9150-5d3acc49e49a	\N	\N	\N	\N	\N	\N	\N
709ab55a-f7ed-4e80-a404-49f293fb6447	075880	NAIRAN DOS SANTOS	\N	\N	\N	\N	\N	2026-05-25	ativo	nova_admissao	338d331e-ef03-4d94-9369-567ee922f1e9	4489b3ec-6774-4a13-bc24-31b77deb6ae7	0d899f11-785d-4edd-a951-bac82fae074f	CATU	BA	https://lqggoshphakeuufibdno.supabase.co/storage/v1/object/public/funcionarios/fotos/1781717766418.png	2026-06-03 14:34:35.253388	2026-06-03 14:34:35.253388	f	\N	\N	\N	\N	\N	\N	\N	45	f	\N	ae89e516-b560-4cbd-9150-5d3acc49e49a	\N	\N	\N	\N	\N	\N	\N
0abe8010-ac69-4277-af3d-9a00185b24cd	075888	PAULO RANGEL DE SA PACHECO	\N	\N	\N	\N	\N	2026-05-28	ativo	nova_admissao	cde079dd-2d53-44c2-9054-6245d154bcf6	4489b3ec-6774-4a13-bc24-31b77deb6ae7	0d899f11-785d-4edd-a951-bac82fae074f	PAULO AFONSO	BA	https://lqggoshphakeuufibdno.supabase.co/storage/v1/object/public/funcionarios/fotos/1781717810301.png	2026-06-03 14:44:30.37229	2026-06-03 14:44:30.37229	f	\N	\N	\N	\N	\N	\N	\N	45	f	\N	ae89e516-b560-4cbd-9150-5d3acc49e49a	\N	\N	\N	\N	\N	\N	\N
a4f56911-ea8e-4087-8328-6eee7c4a6e6e	73759	ALAN FERREIRA ALVES	\N	\N	\N	\N	\N	2024-04-11	transferido	transferencia	4a5727db-1089-4ea5-9908-b25ec46a181f	4489b3ec-6774-4a13-bc24-31b77deb6ae7	0d899f11-785d-4edd-a951-bac82fae074f	REMANSO	BA	\N	2026-06-03 14:17:45.258509	2026-06-03 14:17:45.258509	t	2026-06-15	14d12f35-cd36-4357-9b1e-2e284d11e6a7	24016	\N	\N	\N		45	t	\N	ae89e516-b560-4cbd-9150-5d3acc49e49a	\N	\N	\N	\N	\N	\N	\N
34062719-61cf-4ef3-b1cc-21bb8a2c0381	73242	RAFAEL FERREIRA ALVES	\N	\N	\N	\N	\N	2023-11-01	ativo	nova_admissao	a3d6cf77-3d10-4d60-a93d-a109ac86164a	4489b3ec-6774-4a13-bc24-31b77deb6ae7	0d899f11-785d-4edd-a951-bac82fae074f	REMANSO	SP	\N	2026-06-03 14:46:49.51767	2026-06-03 14:46:49.51767	f	\N	\N	\N	\N	\N	\N	\N	45	t	\N	ae89e516-b560-4cbd-9150-5d3acc49e49a	\N	\N	\N	\N	\N	\N	\N
d9a91097-6b3d-4fd8-adc7-7105b2411e3a	010620	RAIMUNDO NONATO DO NASCIMENTO SANTOS	\N	\N	\N	\N	\N	2005-02-14	ativo	nova_admissao	cc968949-d283-47c4-9fd3-d6057d0db40f	4489b3ec-6774-4a13-bc24-31b77deb6ae7	0d899f11-785d-4edd-a951-bac82fae074f	SAO PAULO	SP	\N	2026-06-02 12:00:30.485356	2026-06-02 12:00:30.485356	f	\N	\N	\N	\N	\N	\N	\N	45	t	\N	7e18e7ce-a57d-4369-88de-8097c3286957	\N	\N	\N	\N	\N	\N	\N
450ab820-1b2e-484e-ad36-c5e5eab184f9	75693	DAVID MAKLIN DOS ANJOS OLIVEIRA	\N	\N	\N	\N	\N	2025-11-04	ativo	efetivo	\N	4489b3ec-6774-4a13-bc24-31b77deb6ae7	0ea37ce8-5f9d-4270-ac46-73e6c169c6d2	\N	\N	https://lqggoshphakeuufibdno.supabase.co/storage/v1/object/public/funcionarios/fotos/1781866401336.jpeg	2026-06-19 10:53:23.510675	2026-06-19 10:53:23.510675	f	\N	\N	\N	2026-06-09	\N	SOLDADOR	\N	30	t	\N	\N	\N	\N	\N	\N	\N	\N	\N
7c2b7107-4bfa-4a19-9d26-060dbfc1924c	075867	ROSEMEIRE DE SOUZA MACHADO	\N	\N	\N	\N	\N	2026-05-18	ativo	nova_admissao	2aa35742-5a21-4e8c-be75-f9dbd6254ec9	4489b3ec-6774-4a13-bc24-31b77deb6ae7	0d899f11-785d-4edd-a951-bac82fae074f	SALTO	SP	https://lqggoshphakeuufibdno.supabase.co/storage/v1/object/public/funcionarios/fotos/1781717911277.png	2026-06-02 12:00:30.485356	2026-06-02 12:00:30.485356	f	\N	\N	\N	\N	\N	\N	\N	45	f	\N	\N	\N	\N	\N	\N	\N	\N	\N
8d639c58-49c6-45bb-83cf-a13f2cf355b5	075808	MARCOS BISPO ASSUNCAO	\N	\N	\N	\N	\N	2026-04-23	ativo	nova_admissao	55c090af-e003-4b88-b130-6cd81c801d33	4489b3ec-6774-4a13-bc24-31b77deb6ae7	0d899f11-785d-4edd-a951-bac82fae074f	CATU	BA	https://lqggoshphakeuufibdno.supabase.co/storage/v1/object/public/funcionarios/fotos/1781717665910.png	2026-06-02 11:59:33.324033	2026-06-02 11:59:33.324033	f	\N	\N	\N	\N	\N	\N	\N	45	f	\N	5e1a3306-b40c-4277-8c03-5e317063af3b	\N	\N	\N	\N	\N	\N	\N
c8a7bf35-ee8a-46e6-8fcb-9d101bed387c	075850	MARIA DAS GRACAS DOS SANTOS E SILVA	\N	\N	\N	\N	\N	2026-05-07	ativo	nova_admissao	d698cd65-a9cd-4419-9e23-7b9df75cfe37	4489b3ec-6774-4a13-bc24-31b77deb6ae7	0d899f11-785d-4edd-a951-bac82fae074f	SALTO	SP	https://lqggoshphakeuufibdno.supabase.co/storage/v1/object/public/funcionarios/fotos/1781717706932.png	2026-06-02 12:00:30.485356	2026-06-02 12:00:30.485356	f	\N	\N	\N	\N	\N	\N	\N	45	f	\N	\N	\N	\N	\N	\N	\N	\N	\N
beaa74bb-c384-406f-9b10-5a1b33565e53	075846	SIRLEI DA SILVA GILBERTO	\N	\N	\N	\N	\N	2026-05-07	ativo	nova_admissao	d698cd65-a9cd-4419-9e23-7b9df75cfe37	4489b3ec-6774-4a13-bc24-31b77deb6ae7	0d899f11-785d-4edd-a951-bac82fae074f	SALTO	SP	https://lqggoshphakeuufibdno.supabase.co/storage/v1/object/public/funcionarios/fotos/1781717949717.png	2026-06-02 12:00:30.485356	2026-06-02 12:00:30.485356	f	\N	\N	\N	\N	\N	\N	\N	45	f	\N	\N	\N	\N	\N	\N	\N	\N	\N
01c0146c-1416-4271-b9d9-eabd6fcd528e	75728	ANDRESSA PEREIRA SAMPAIO GARCIA	\N	\N	\N	\N	\N	2025-11-26	ativo	nova_admissao	96b3bf34-1ff8-498a-8d79-8b58e6c0d27e	4489b3ec-6774-4a13-bc24-31b77deb6ae7	0ea37ce8-5f9d-4270-ac46-73e6c169c6d2	AMERICANA	SP	https://lqggoshphakeuufibdno.supabase.co/storage/v1/object/public/funcionarios/fotos/1781527445961.png	2026-06-15 12:44:07.882552	2026-06-15 12:44:07.882552	f	\N	\N	\N	2025-11-27	\N	\N	\N	30	t	\N	\N	\N	\N	\N	\N	\N	\N	\N
e3975bc7-b7a1-417c-bc6c-7d4a71e4714d	75734	ADRIANA VELOSO ROSA	\N	\N	\N	\N	\N	2025-12-22	ativo	nova_admissao	dd1a458e-5a2a-40ed-8dc8-982a57e5e5d4	4489b3ec-6774-4a13-bc24-31b77deb6ae7	0ea37ce8-5f9d-4270-ac46-73e6c169c6d2	paulinia	SP	https://lqggoshphakeuufibdno.supabase.co/storage/v1/object/public/funcionarios/fotos/1781525994050.jpg	2026-06-15 12:19:54.542111	2026-06-15 12:19:54.542111	f	\N	\N	\N	2025-12-23	\N	\N	\N	30	t	\N	\N	\N	\N	\N	\N	\N	\N	\N
ccab107c-e256-4d35-a7ce-253c8a108154	75896	NAILTON RODRIGUES DE BRITO	\N	\N	\N	\N	\N	2026-06-10	ativo	nova_admissao	fb4ee1c9-e474-462a-8978-e9d53c83bc09	4489b3ec-6774-4a13-bc24-31b77deb6ae7	0d899f11-785d-4edd-a951-bac82fae074f	NOSSA SENHORA DE NAZARE	PI	\N	2026-06-10 21:33:50.134175	2026-06-10 21:33:50.134175	f	\N	\N	\N	\N	\N	\N	\N	45	f	\N	02800faf-0e3a-40c5-b354-4e64d8a6f5ad	\N	\N	\N	\N	\N	\N	\N
7673456e-e717-47ae-8b74-482af33078d9	75727	SUELLEN MICHAELA DE MOURA UEMOTO	\N	\N	\N	\N	\N	2025-11-26	ativo	nova_admissao	96b3bf34-1ff8-498a-8d79-8b58e6c0d27e	4489b3ec-6774-4a13-bc24-31b77deb6ae7	c2096d7c-a212-4365-9d85-3151167e0436	PAULINIA	SP	\N	2026-06-09 21:22:42.808108	2026-06-09 21:22:42.808108	f	\N	\N	\N	\N	\N	\N	\N	30	t	\N	\N	\N	\N	\N	\N	\N	\N	\N
3f70dc11-dc10-41e9-b573-0c962936d7f6	10044	ADILSON DOS SANTOS	\N	\N	\N	\N	\N	1997-02-17	ativo	efetivo	\N	4489b3ec-6774-4a13-bc24-31b77deb6ae7	0ea37ce8-5f9d-4270-ac46-73e6c169c6d2	SÃO PAULO	SP	https://lqggoshphakeuufibdno.supabase.co/storage/v1/object/public/funcionarios/fotos/1781525911879.png	2026-06-15 12:18:21.013825	2026-06-15 12:18:21.013825	f	\N	\N	\N	2025-12-23	\N	ENCARREGADO DE TUBULAÇÃO	\N	30	t	ALOJADO	326e50c1-0ebc-4674-8bf9-a9cac9ea998d	\N	\N	\N	\N	\N	\N	\N
e6629df2-78e5-4dfb-8c0a-9dc259cdfce8	074296	ECRISOVALDO ROCHA PIMENTA	\N	\N	\N	\N	\N	2024-09-13	inativo	efetivo	9c2c3f89-a31b-4557-b82a-987b45e84546	4489b3ec-6774-4a13-bc24-31b77deb6ae7	c2096d7c-a212-4365-9d85-3151167e0436	PAULÍNIA	SP	https://lqggoshphakeuufibdno.supabase.co/storage/v1/object/public/funcionarios/fotos/1781619985133.png	2026-06-16 14:26:27.292506	2026-06-16 14:26:27.292506	f	\N	\N	\N	2024-09-23	\N	\N	\N	30	t	\N	\N	2026-07-01	aviso_previo_indenizado	Desmobilização obra.	\N	\N	\N	\N
cbc8e27d-503d-4447-9e54-2b774c012b66	73557	ANTONIO JOSE DOS SANTOS	\N	\N	\N	\N	\N	2024-02-08	ativo	efetivo	c5ddb144-5847-4aec-b64b-cb346f96cfad	4489b3ec-6774-4a13-bc24-31b77deb6ae7	0ea37ce8-5f9d-4270-ac46-73e6c169c6d2	CANDEIAS	BA	https://lqggoshphakeuufibdno.supabase.co/storage/v1/object/public/funcionarios/fotos/1781527574095.jpg	2026-06-15 12:46:14.851001	2026-06-15 12:46:14.851001	f	\N	\N	\N	2026-02-05	\N	\N	\N	30	t	ALOJADO	8492df23-4608-4b03-a3dc-7e25f361909f	\N	\N	\N	\N	\N	\N	\N
05f825a2-192a-43d1-8fbe-0279b2c9b178	50187	SANDRO ALMADA COSTA	\N	\N	\N	\N	\N	2014-06-30	transferido	transferencia	90d001ce-a035-470c-b477-de26e0779131	4489b3ec-6774-4a13-bc24-31b77deb6ae7	0d899f11-785d-4edd-a951-bac82fae074f	VOLTA REDONDA	GO	\N	2026-06-03 15:09:34.245242	2026-06-03 15:09:34.245242	t	2026-03-28	25341e31-cd60-4743-ad1b-658397ec5d72	23403	\N	\N	\N		45	t	\N	51afffdb-a64b-4305-8aaf-46c187b33639	\N	\N	\N	\N	\N	\N	\N
1ec8fda0-fe03-4578-97d4-04670f7e1091	75803	EMILY VITORIA CARDOSO DA SILVA	\N	\N	\N	\N	\N	2026-04-17	ativo	efetivo	\N	4489b3ec-6774-4a13-bc24-31b77deb6ae7	0ea37ce8-5f9d-4270-ac46-73e6c169c6d2	COSMOPOLIS	SP	https://lqggoshphakeuufibdno.supabase.co/storage/v1/object/public/funcionarios/fotos/1781867095352.jpeg	2026-06-19 11:04:57.548326	2026-06-19 11:04:57.548326	f	\N	\N	\N	2026-04-23	\N	SOLDADOR	\N	30	t	\N	\N	\N	\N	\N	\N	\N	\N	\N
1773291d-0948-4de1-ab12-5787fc1d75e8	75621	ALAN DOMINGUES BARBOSA	\N	\N	\N	\N	\N	2025-08-20	ativo	nova_admissao	7d9dffa9-1696-4cb1-bfda-1e2fd2fc255a	4489b3ec-6774-4a13-bc24-31b77deb6ae7	0ea37ce8-5f9d-4270-ac46-73e6c169c6d2	paulinia	SP	\N	2026-06-15 12:35:20.775476	2026-06-15 12:35:20.775476	f	\N	\N	\N	2026-01-26	\N	\N	\N	30	t	\N	\N	\N	\N	\N	\N	\N	\N	\N
fcd1f1f3-137d-4e51-9136-928202498461	060853	ALAN CRISTIAN BATISTA MOREIRA	\N	\N	\N	\N	\N	2018-02-09	ativo	efetivo	\N	4489b3ec-6774-4a13-bc24-31b77deb6ae7	c2096d7c-a212-4365-9d85-3151167e0436	PAULÍNIA	SP	https://lqggoshphakeuufibdno.supabase.co/storage/v1/object/public/funcionarios/fotos/1781614259416.jpg	2026-06-16 12:51:00.453229	2026-06-16 12:51:00.453229	f	\N	\N	\N	2024-08-05	\N	SOLDADOR TIG III	\N	30	t	\N	a0f063aa-df41-4780-ab24-82be52000892	\N	\N	\N	\N	\N	\N	\N
04509dd6-4ec3-45fa-9fec-7a5577c0ba5e	070768	ANAILTON DOS SANTOS CHAGAS	\N	\N	\N	\N	\N	2019-11-11	ativo	efetivo	\N	4489b3ec-6774-4a13-bc24-31b77deb6ae7	c2096d7c-a212-4365-9d85-3151167e0436	Americana	SP	https://lqggoshphakeuufibdno.supabase.co/storage/v1/object/public/funcionarios/fotos/1781618126691.jpeg	2026-06-16 13:55:28.575052	2026-06-16 13:55:28.575052	f	\N	\N	\N	2024-08-05	\N	ENCARREGADO DE HIDRAULICA	\N	30	t	\N	\N	\N	\N	\N	\N	\N	\N	\N
525514fa-d774-4a32-94a5-daf799572396	075207	ANTONIO DE JESUS DA CONCEICAO	\N	\N	\N	\N	\N	2025-03-13	ativo	efetivo	250ccfab-916a-4371-9b83-1c3c1aad4822	4489b3ec-6774-4a13-bc24-31b77deb6ae7	ae387bdc-cf9e-4d3a-ad30-5a16e85801bc	CUIABÁ	MT	https://lqggoshphakeuufibdno.supabase.co/storage/v1/object/public/funcionarios/fotos/1781619741068.png	2026-06-16 14:22:22.82631	2026-06-16 14:22:22.82631	t	2026-07-02	c2096d7c-a212-4365-9d85-3151167e0436	24314	2026-07-06	\N	\N	envio	30	t	\N	6def14ab-7549-47b2-b268-e0775a28a51f	\N	\N	\N	12.43	horista	a0f063aa-df41-4780-ab24-82be52000892	\N
b8231d04-f70c-4818-95da-8103d8c937a3	074351	ALEXANDRE YASUO E GUSHIKEM	\N	\N	\N	\N	\N	2024-09-23	ativo	efetivo	\N	4489b3ec-6774-4a13-bc24-31b77deb6ae7	c2096d7c-a212-4365-9d85-3151167e0436	PAULÍNIA	SP	https://lqggoshphakeuufibdno.supabase.co/storage/v1/object/public/funcionarios/fotos/1781617850831.png	2026-06-16 13:50:53.970543	2026-06-16 13:50:53.970543	f	\N	\N	\N	2024-10-02	\N	1/2 OFICIAL ENCANADOR	\N	30	t	\N	\N	\N	\N	\N	\N	\N	\N	\N
2ecc58b1-5066-4414-a908-97a36c08b3ec	050930	ARTHUR VINICIUS LISBOA DA SILVA	\N	\N	\N	\N	\N	2015-03-25	ativo	efetivo	02a9da83-895c-4439-adff-aa33c7465e2f	4489b3ec-6774-4a13-bc24-31b77deb6ae7	c2096d7c-a212-4365-9d85-3151167e0436	PAULÍNIA	SP	https://lqggoshphakeuufibdno.supabase.co/storage/v1/object/public/funcionarios/fotos/1781619852512.jpg	2026-06-16 14:24:14.184024	2026-06-16 14:24:14.184024	f	\N	\N	\N	2025-07-02	\N	\N	\N	30	t	\N	7eca1a31-eb4e-4e6e-b853-57bc6c9ac091	\N	\N	\N	\N	\N	\N	\N
b732b7dc-fb35-4a83-8592-79b587d6f5fd	75816	CARLITO FLORENCIO DOS SANTOS	\N	\N	\N	\N	\N	2026-04-23	ativo	efetivo	\N	4489b3ec-6774-4a13-bc24-31b77deb6ae7	0ea37ce8-5f9d-4270-ac46-73e6c169c6d2	COSMOPOLIS	SP	https://lqggoshphakeuufibdno.supabase.co/storage/v1/object/public/funcionarios/fotos/1781865064936.jpg	2026-06-19 10:31:07.759788	2026-06-19 10:31:07.759788	f	\N	\N	\N	0206-04-29	\N	SOLDADOR	\N	30	t	\N	\N	\N	\N	\N	\N	\N	\N	\N
478466ce-53df-4ebe-9291-69b4b3d29235	040638	EDENILTON MACEDO SANTOS	\N	\N	\N	\N	\N	2013-09-12	ativo	efetivo	\N	4489b3ec-6774-4a13-bc24-31b77deb6ae7	c2096d7c-a212-4365-9d85-3151167e0436	PAULÍNIA	SP	https://lqggoshphakeuufibdno.supabase.co/storage/v1/object/public/funcionarios/fotos/1781620127432.png	2026-06-16 14:28:49.07179	2026-06-16 14:28:49.07179	f	\N	\N	\N	2024-11-18	\N	ENCANADOR INDUSTRIAL III	\N	30	t	\N	a0f063aa-df41-4780-ab24-82be52000892	\N	\N	\N	\N	\N	\N	\N
02148a14-530c-4549-a5ac-80af04ce6785	075252	EDSON ALVES BARBOSA	\N	\N	\N	\N	\N	2025-03-27	ativo	efetivo	\N	4489b3ec-6774-4a13-bc24-31b77deb6ae7	c2096d7c-a212-4365-9d85-3151167e0436	PAULÍNIA	SP	https://lqggoshphakeuufibdno.supabase.co/storage/v1/object/public/funcionarios/fotos/1781620241748.png	2026-06-16 14:30:42.999056	2026-06-16 14:30:42.999056	f	\N	\N	\N	2025-08-20	\N	MONTADOR DE ANDAIME	\N	30	t	\N	7eca1a31-eb4e-4e6e-b853-57bc6c9ac091	\N	\N	\N	\N	\N	\N	\N
174521ea-a404-4d8d-bbc5-d9806cf45983	075765	FRANCISCA RAQUEL DA SILVA	\N	\N	\N	\N	\N	2026-02-25	ativo	efetivo	d698cd65-a9cd-4419-9e23-7b9df75cfe37	4489b3ec-6774-4a13-bc24-31b77deb6ae7	c2096d7c-a212-4365-9d85-3151167e0436	PAULÍNIA	SP	https://lqggoshphakeuufibdno.supabase.co/storage/v1/object/public/funcionarios/fotos/1781621459152.jpg	2026-06-16 14:51:01.74589	2026-06-16 14:51:01.74589	f	\N	\N	\N	2026-03-04	\N	\N	\N	30	t	\N	\N	\N	\N	\N	\N	\N	\N	\N
8dc6d6ec-427a-4a80-8175-97ce13b57c8f	075649	GUSTAVO ALCANTARA MENEZES	\N	\N	\N	\N	\N	2025-09-15	ativo	efetivo	338d331e-ef03-4d94-9369-567ee922f1e9	4489b3ec-6774-4a13-bc24-31b77deb6ae7	c2096d7c-a212-4365-9d85-3151167e0436	PAULÍNIA	SP	https://lqggoshphakeuufibdno.supabase.co/storage/v1/object/public/funcionarios/fotos/1781621754633.jpg	2026-06-16 14:55:56.353841	2026-06-16 14:55:56.353841	f	\N	\N	\N	2025-09-17	\N	\N	\N	30	t	\N	\N	\N	\N	\N	\N	\N	\N	\N
5868da5b-e78e-4c06-85cc-fce019066e3e	1073643	JOSE ADRIANO RODRIGUES DE MENDONCA	\N	\N	\N	\N	\N	2024-03-06	ativo	efetivo	\N	4489b3ec-6774-4a13-bc24-31b77deb6ae7	c2096d7c-a212-4365-9d85-3151167e0436	PAULÍNIA	SP	https://lqggoshphakeuufibdno.supabase.co/storage/v1/object/public/funcionarios/fotos/1781638016414.jpg	2026-06-16 19:26:58.965384	2026-06-16 19:26:58.965384	f	\N	\N	\N	2024-12-02	\N	PINTOR	\N	30	t	\N	a0f063aa-df41-4780-ab24-82be52000892	\N	\N	\N	\N	\N	\N	\N
06be1efc-148e-4b38-930c-96ba72b4eca1	75779	ALESSANDRO BARBIERI	\N	\N	\N	\N	\N	2026-03-19	ativo	nova_admissao	02a9da83-895c-4439-adff-aa33c7465e2f	4489b3ec-6774-4a13-bc24-31b77deb6ae7	0ea37ce8-5f9d-4270-ac46-73e6c169c6d2	ESTANCIA	SE	https://lqggoshphakeuufibdno.supabase.co/storage/v1/object/public/funcionarios/fotos/1781526967706.jpg	2026-06-15 12:36:08.439582	2026-06-15 12:36:08.439582	f	\N	\N	\N	2026-03-26	\N	\N	\N	30	t	ALOJADO	326e50c1-0ebc-4674-8bf9-a9cac9ea998d	\N	\N	\N	\N	\N	\N	\N
df4b5ed2-9c12-4911-b3ff-9ec504be50fa	75699	LUIS FERNANDO DIAS LOUZEIRO	\N	\N	\N	\N	\N	2025-11-05	ativo	nova_admissao	6bd0e213-c32c-463f-9186-af82541d0781	145e0a9b-f796-4db5-92e9-33f046f959ae	0ea37ce8-5f9d-4270-ac46-73e6c169c6d2	\N	\N	\N	2026-06-19 12:44:30.400557	2026-06-19 12:44:30.400557	f	\N	\N	\N	2026-01-26	\N	\N	\N	30	t	\N	\N	\N	\N	\N	\N	\N	\N	\N
c9234c19-cf5c-418f-9a5a-7e93111437c5	071288	JOSE GERNANDE DA SILVA	\N	\N	\N	\N	\N	2021-08-03	ativo	efetivo	c5ddb144-5847-4aec-b64b-cb346f96cfad	4489b3ec-6774-4a13-bc24-31b77deb6ae7	c2096d7c-a212-4365-9d85-3151167e0436	PAULÍNIA	SP	https://lqggoshphakeuufibdno.supabase.co/storage/v1/object/public/funcionarios/fotos/1781697691372.png	2026-06-17 12:01:32.666482	2026-06-17 12:01:32.666482	f	\N	\N	\N	2024-08-05	\N	\N	\N	30	t	\N	a0f063aa-df41-4780-ab24-82be52000892	\N	\N	\N	\N	\N	\N	\N
89d1953b-5cff-423d-9239-12133d971027	072779	VALDEIR DE JESUS JACO	\N	\N	\N	\N	\N	2023-08-03	ativo	efetivo	abbe59ac-4003-4208-8495-c87d8d73fb14	4489b3ec-6774-4a13-bc24-31b77deb6ae7	c2096d7c-a212-4365-9d85-3151167e0436	PAULÍNIA	SP	https://lqggoshphakeuufibdno.supabase.co/storage/v1/object/public/funcionarios/fotos/1781699587730.jpg	2026-06-17 12:33:08.931013	2026-06-17 12:33:08.931013	f	\N	\N	\N	2025-06-04	\N	\N	\N	30	t	\N	a0f063aa-df41-4780-ab24-82be52000892	\N	\N	\N	\N	\N	\N	\N
ed412871-9102-4065-bcf9-d16a9e7bea81	073463	WELITON BASTIAO PEREIRA DOS SANTOS	\N	\N	\N	\N	\N	2024-01-23	ativo	efetivo	\N	4489b3ec-6774-4a13-bc24-31b77deb6ae7	c2096d7c-a212-4365-9d85-3151167e0436	PAULÍNIA	SP	https://lqggoshphakeuufibdno.supabase.co/storage/v1/object/public/funcionarios/fotos/1781699771245.jpeg	2026-06-17 12:36:11.777981	2026-06-17 12:36:11.777981	f	\N	\N	\N	2024-08-05	\N	SOLDADOR	\N	30	t	\N	a0f063aa-df41-4780-ab24-82be52000892	\N	\N	\N	\N	\N	\N	\N
08df0e04-feb3-40e9-95ea-335a8cc2e69b	073489	RODRIGO DE SOUSA AMORIM	\N	\N	\N	\N	\N	2024-01-29	ativo	efetivo	b19eb87e-ab83-4460-b57f-f0302aaa1f0d	4489b3ec-6774-4a13-bc24-31b77deb6ae7	c2096d7c-a212-4365-9d85-3151167e0436	AMERICANA	SP	https://lqggoshphakeuufibdno.supabase.co/storage/v1/object/public/funcionarios/fotos/1781699311793.jpg	2026-06-17 12:28:32.505405	2026-06-17 12:28:32.505405	f	\N	\N	\N	2024-09-11	\N	\N	\N	30	t	\N	\N	\N	\N	\N	\N	\N	\N	\N
6d1786b8-676c-4511-94b5-b4123162ae8d	74869	ADAILSON DOS SANTOS MATOS	\N	\N	\N	\N	\N	2025-01-27	ativo	efetivo	\N	4489b3ec-6774-4a13-bc24-31b77deb6ae7	0ea37ce8-5f9d-4270-ac46-73e6c169c6d2	ARUANA	SE	https://lqggoshphakeuufibdno.supabase.co/storage/v1/object/public/funcionarios/fotos/1781525774003.png	2026-06-15 12:16:15.269331	2026-06-15 12:16:15.269331	f	\N	\N	\N	2026-02-04	\N	\N	\N	30s	t	ALOJADO	8492df23-4608-4b03-a3dc-7e25f361909f	\N	\N	\N	\N	\N	\N	\N
2dc15829-c805-4e47-b083-cd17a008b7a9	074116	ANTONIEL DOS SANTOS OLIVEIRA	\N	\N	\N	\N	\N	2024-08-13	ativo	efetivo	8cfe5485-e51a-407a-84a7-6cc619e29ae3	4489b3ec-6774-4a13-bc24-31b77deb6ae7	ae387bdc-cf9e-4d3a-ad30-5a16e85801bc	CUIABÁ	MT	https://lqggoshphakeuufibdno.supabase.co/storage/v1/object/public/funcionarios/fotos/1781618273759.jpg	2026-06-16 13:57:55.336964	2026-06-16 13:57:55.336964	t	2026-07-13	c2096d7c-a212-4365-9d85-3151167e0436	24314	\N	\N	\N	envio	30	t	\N	08c90ae3-d954-4510-91bc-1a0fb93c6c68	\N	\N	\N	5.20	mensalista	\N	\N
fc6858ac-ef5e-4f74-b8e2-671bba1b5fa8	073587	MARIA FATIMA DE SOUZA SILVA	\N	\N	\N	\N	\N	2024-02-15	ativo	efetivo	d698cd65-a9cd-4419-9e23-7b9df75cfe37	4489b3ec-6774-4a13-bc24-31b77deb6ae7	c2096d7c-a212-4365-9d85-3151167e0436	AMERICANA	SP	https://lqggoshphakeuufibdno.supabase.co/storage/v1/object/public/funcionarios/fotos/1781698777773.jpg	2026-06-17 12:19:38.696863	2026-06-17 12:19:38.696863	f	\N	\N	\N	2025-07-28	\N	\N	\N	30	t	\N	\N	\N	\N	\N	\N	\N	\N	\N
4594413b-1406-43f1-b3ed-5af30a6ab880	075594	JHONATAN GABRIEL LELES ARCENIO	\N	\N	\N	\N	\N	2025-07-25	inativo	efetivo	250ccfab-916a-4371-9b83-1c3c1aad4822	4489b3ec-6774-4a13-bc24-31b77deb6ae7	c2096d7c-a212-4365-9d85-3151167e0436	PAULÍNIA	SP	https://lqggoshphakeuufibdno.supabase.co/storage/v1/object/public/funcionarios/fotos/1781621877877.jpg	2026-06-16 14:57:59.36855	2026-06-16 14:57:59.36855	f	\N	\N	\N	2025-07-30	\N	\N	\N	30	t	\N	\N	2026-07-01	aviso_previo_indenizado	Desmobilização da obra.	\N	\N	\N	\N
05159e14-4a04-4b7a-9e4f-4cb43d138925	074819	PAULO RICARDO PEREIRA SANTOS	\N	\N	\N	\N	\N	2025-01-10	ativo	efetivo	cde079dd-2d53-44c2-9054-6245d154bcf6	4489b3ec-6774-4a13-bc24-31b77deb6ae7	c2096d7c-a212-4365-9d85-3151167e0436	PAULÍNIA	SP	https://lqggoshphakeuufibdno.supabase.co/storage/v1/object/public/funcionarios/fotos/1781699105821.jpg	2026-06-17 12:25:06.477284	2026-06-17 12:25:06.477284	f	\N	\N	\N	2025-06-04	\N	\N	\N	30	t	\N	a0f063aa-df41-4780-ab24-82be52000892	\N	\N	\N	\N	\N	\N	\N
da7daf8d-03ce-4d85-8cc9-834ff097e5ac	074948	JOSE SERGIO DOS SANTOS	\N	\N	\N	\N	\N	2025-02-05	ativo	efetivo	\N	4489b3ec-6774-4a13-bc24-31b77deb6ae7	c2096d7c-a212-4365-9d85-3151167e0436	PAULÍNIA	SP	https://lqggoshphakeuufibdno.supabase.co/storage/v1/object/public/funcionarios/fotos/1781698406797.jpg	2026-06-17 12:13:28.545241	2026-06-17 12:13:28.545241	f	\N	\N	\N	2025-08-20	\N	MONTADOR DE ANDAIME	\N	30	t	\N	7eca1a31-eb4e-4e6e-b853-57bc6c9ac091	\N	\N	\N	\N	\N	\N	\N
cf3d40a3-3ecc-47a3-8392-0d6e6b7dbe28	075442	PAULO CESAR FELISBINO	\N	\N	\N	\N	\N	2025-04-30	ativo	efetivo	\N	4489b3ec-6774-4a13-bc24-31b77deb6ae7	c2096d7c-a212-4365-9d85-3151167e0436	PAULÍNIA	SP	https://lqggoshphakeuufibdno.supabase.co/storage/v1/object/public/funcionarios/fotos/1781698997817.jpg	2026-06-17 12:23:18.69213	2026-06-17 12:23:18.69213	f	\N	\N	\N	2025-05-12	\N	SOLDADOR	\N	30	t	\N	\N	\N	\N	\N	\N	\N	\N	\N
9b1db7a4-3854-4992-b915-1047c364fa46	075620	LUIZ HENRIQUE FELISBINO	\N	\N	\N	\N	\N	2025-08-20	ativo	efetivo	338d331e-ef03-4d94-9369-567ee922f1e9	4489b3ec-6774-4a13-bc24-31b77deb6ae7	c2096d7c-a212-4365-9d85-3151167e0436	PAULÍNIA	SP	https://lqggoshphakeuufibdno.supabase.co/storage/v1/object/public/funcionarios/fotos/1781698660378.jpg	2026-06-17 12:17:41.170255	2026-06-17 12:17:41.170255	f	\N	\N	\N	2025-08-25	\N	\N	\N	30	t	\N	\N	\N	\N	\N	\N	\N	\N	\N
aa9c3270-d2e3-46fe-950e-0f9647077ff8	075618	UEIDRISSON ANDREI PEREIRA GOMES	\N	\N	\N	\N	\N	2025-08-20	ativo	efetivo	914d6d69-7338-4197-be53-ac04a5216eba	4489b3ec-6774-4a13-bc24-31b77deb6ae7	c2096d7c-a212-4365-9d85-3151167e0436	PAULÍNIA	SP	https://lqggoshphakeuufibdno.supabase.co/storage/v1/object/public/funcionarios/fotos/1781699420135.jpg	2026-06-17 12:30:21.274518	2026-06-17 12:30:21.274518	f	\N	\N	\N	2025-08-25	\N	\N	\N	30	t	\N	\N	\N	\N	\N	\N	\N	\N	\N
4785ec97-ef57-4960-a515-ca79b0a31cee	075627	WESLEY BESSA DE OLIVEIRA	\N	\N	\N	\N	\N	2025-09-02	ativo	efetivo	\N	4489b3ec-6774-4a13-bc24-31b77deb6ae7	c2096d7c-a212-4365-9d85-3151167e0436	PAULÍNIA	SP	https://lqggoshphakeuufibdno.supabase.co/storage/v1/object/public/funcionarios/fotos/1781699864209.jpg	2026-06-17 12:37:44.804814	2026-06-17 12:37:44.804814	f	\N	\N	\N	2025-09-10	\N	1/2 OFICIAL SOLDADOR	\N	30	t	\N	\N	\N	\N	\N	\N	\N	\N	\N
18e1524c-4a41-43d2-a70e-aaaa81c6d634	075651	KAUA RODRIGUES CARDOSO	\N	\N	\N	\N	\N	2025-09-15	ativo	efetivo	338d331e-ef03-4d94-9369-567ee922f1e9	4489b3ec-6774-4a13-bc24-31b77deb6ae7	c2096d7c-a212-4365-9d85-3151167e0436	PAULÍNIA	SP	https://lqggoshphakeuufibdno.supabase.co/storage/v1/object/public/funcionarios/fotos/1781698553281.jpeg	2026-06-17 12:15:54.344354	2026-06-17 12:15:54.344354	f	\N	\N	\N	2025-09-17	\N	\N	\N	30	t	\N	\N	\N	\N	\N	\N	\N	\N	\N
aa46cb9c-89c3-4c1d-91de-3c58ad9efed2	075650	MIKAEL DE LIMA BRITO	\N	\N	\N	\N	\N	2025-09-15	ativo	efetivo	338d331e-ef03-4d94-9369-567ee922f1e9	4489b3ec-6774-4a13-bc24-31b77deb6ae7	c2096d7c-a212-4365-9d85-3151167e0436	PAULÍNIA	SP	https://lqggoshphakeuufibdno.supabase.co/storage/v1/object/public/funcionarios/fotos/1781698886569.jpg	2026-06-17 12:21:27.247876	2026-06-17 12:21:27.247876	f	\N	\N	\N	2025-09-17	\N	\N	\N	30	t	\N	\N	\N	\N	\N	\N	\N	\N	\N
13b60718-123b-4059-b99f-c9c2d6cea63a	075809	JONAS DE OLIVEIRA	\N	\N	\N	\N	\N	2026-04-23	ativo	nova_admissao	b19eb87e-ab83-4460-b57f-f0302aaa1f0d	4489b3ec-6774-4a13-bc24-31b77deb6ae7	0d899f11-785d-4edd-a951-bac82fae074f	PILAR	AL	https://lqggoshphakeuufibdno.supabase.co/storage/v1/object/public/funcionarios/fotos/1781717384863.png	2026-06-02 11:59:33.324033	2026-06-02 11:59:33.324033	f	\N	\N	\N	\N	\N	\N	\N	45	f	Efetivar Joao	7cec8c21-12e1-491d-89fb-fd3599eae796	\N	\N	\N	\N	\N	\N	\N
ceb4dc7d-3dd1-46d6-a566-14a381a4c7e6	075887	NIVALDO MANUEL DOS SANTOS	\N	\N	\N	\N	\N	2026-05-28	ativo	nova_admissao	55c090af-e003-4b88-b130-6cd81c801d33	4489b3ec-6774-4a13-bc24-31b77deb6ae7	0d899f11-785d-4edd-a951-bac82fae074f	ARARAQUARA	SP	https://lqggoshphakeuufibdno.supabase.co/storage/v1/object/public/funcionarios/fotos/1781717789495.png	2026-06-03 14:41:58.991168	2026-06-03 14:41:58.991168	f	\N	\N	\N	\N	\N	\N	\N	45	f	\N	02800faf-0e3a-40c5-b354-4e64d8a6f5ad	\N	\N	\N	\N	\N	\N	\N
cab0afc8-2ced-4941-b1e1-e9521af4cbd3	71687	CICERO ROMAO MONTEIRO	\N	\N	\N	\N	\N	2022-03-24	ativo	efetivo	02a9da83-895c-4439-adff-aa33c7465e2f	145e0a9b-f796-4db5-92e9-33f046f959ae	0ea37ce8-5f9d-4270-ac46-73e6c169c6d2	Jaboatão dos Guararapes	PE	https://lqggoshphakeuufibdno.supabase.co/storage/v1/object/public/funcionarios/fotos/1781865692126.jpg	2026-06-19 10:39:27.856054	2026-06-19 10:39:27.856054	f	\N	\N	\N	2026-01-06	\N	\N	\N	30	t	\N	\N	\N	\N	\N	\N	\N	\N	\N
0118ef0a-337e-44e1-9eaf-b6e65959576c	074131	JOSE AMILTON DA SILVA	\N	\N	\N	\N	\N	2024-08-19	inativo	efetivo	914d6d69-7338-4197-be53-ac04a5216eba	4489b3ec-6774-4a13-bc24-31b77deb6ae7	c2096d7c-a212-4365-9d85-3151167e0436	COSMÓPOLIS	SP	https://lqggoshphakeuufibdno.supabase.co/storage/v1/object/public/funcionarios/fotos/1781697347017.jpg	2026-06-17 11:55:48.189998	2026-06-17 11:55:48.189998	f	\N	\N	\N	2024-08-26	\N	\N	\N	30	t	\N	\N	2026-07-01	aviso_previo_indenizado	Desmobilização da obra.	\N	\N	\N	\N
1e97ede4-5066-4ac3-b4b3-09ae236f5caa	075841	MARCELO SILVA	\N	\N	\N	\N	\N	2026-05-05	ativo	nova_admissao	02a9da83-895c-4439-adff-aa33c7465e2f	4489b3ec-6774-4a13-bc24-31b77deb6ae7	0d899f11-785d-4edd-a951-bac82fae074f	PIRAI	RJ	https://lqggoshphakeuufibdno.supabase.co/storage/v1/object/public/funcionarios/fotos/1781717627830.png	2026-06-03 14:29:36.246529	2026-06-03 14:29:36.246529	f	\N	\N	\N	2026-05-27	\N	\N	\N	45	f	\N	e42bb35b-e6c4-4db2-8c2b-4c2e8f69a2e3	\N	\N	\N	\N	\N	\N	\N
e13fd5d3-8493-4b58-bb54-269993f6fba0	075837	GERSONIEL SOUSA RODRIGUES	\N	\N	\N	\N	\N	2026-05-04	ativo	nova_admissao	abbe59ac-4003-4208-8495-c87d8d73fb14	4489b3ec-6774-4a13-bc24-31b77deb6ae7	0d899f11-785d-4edd-a951-bac82fae074f	BOQUEIRAO DO PIAUI	PI	https://lqggoshphakeuufibdno.supabase.co/storage/v1/object/public/funcionarios/fotos/1781717260352.png	2026-06-02 11:57:10.90763	2026-06-02 11:57:10.90763	f	\N	\N	\N	\N	\N	\N	\N	45	f	\N	e42bb35b-e6c4-4db2-8c2b-4c2e8f69a2e3	\N	\N	\N	\N	\N	\N	\N
1543bea5-f3b5-4289-8136-24338f4042be	075868	MARCUS VINICIUS SILVA DE OLIVEIRA	\N	\N	\N	\N	\N	2026-05-18	ativo	nova_admissao	02a9da83-895c-4439-adff-aa33c7465e2f	4489b3ec-6774-4a13-bc24-31b77deb6ae7	0d899f11-785d-4edd-a951-bac82fae074f	CACHOEIRA	BA	https://lqggoshphakeuufibdno.supabase.co/storage/v1/object/public/funcionarios/fotos/1781717685750.jpeg	2026-06-03 14:31:49.46955	2026-06-03 14:31:49.46955	f	\N	\N	\N	\N	\N	\N	\N	45	f	\N	\N	\N	\N	\N	\N	\N	\N	\N
beff7969-13aa-4ad0-acb3-b178bee25629	075815	RONALDO BARBOSA DE OLIVEIRA	\N	\N	\N	\N	\N	2026-04-23	ativo	nova_admissao	f510f6aa-f1d8-4fd9-b85f-dd8ff840cf76	4489b3ec-6774-4a13-bc24-31b77deb6ae7	0d899f11-785d-4edd-a951-bac82fae074f	LINHARES	ES	https://lqggoshphakeuufibdno.supabase.co/storage/v1/object/public/funcionarios/fotos/1781717889359.jpeg	2026-06-02 12:00:30.485356	2026-06-02 12:00:30.485356	f	\N	\N	\N	\N	\N	\N	\N	45	f	\N	7e18e7ce-a57d-4369-88de-8097c3286957	\N	\N	\N	\N	\N	\N	\N
75eacd3d-5c0f-432a-839f-803d5eca0d12	075854	JORGE HUGO BARBOSA DUARTE	\N	\N	\N	\N	\N	2026-05-08	ativo	nova_admissao	cde079dd-2d53-44c2-9054-6245d154bcf6	4489b3ec-6774-4a13-bc24-31b77deb6ae7	0d899f11-785d-4edd-a951-bac82fae074f	ICO	CE	https://lqggoshphakeuufibdno.supabase.co/storage/v1/object/public/funcionarios/fotos/1781717411466.png	2026-06-03 12:56:19.930749	2026-06-03 12:56:19.930749	f	\N	\N	\N	\N	\N	\N	\N	45	f	\N	e42bb35b-e6c4-4db2-8c2b-4c2e8f69a2e3	\N	\N	\N	\N	\N	\N	\N
ca917fd7-41c6-4ea9-bb78-03f7c891d340	74846	JOSE EDUARDO DA SILVA SIQUEIRA	\N	\N	\N	\N	\N	2025-01-15	ativo	efetivo	c5ddb144-5847-4aec-b64b-cb346f96cfad	4489b3ec-6774-4a13-bc24-31b77deb6ae7	0ea37ce8-5f9d-4270-ac46-73e6c169c6d2	\N	\N	https://lqggoshphakeuufibdno.supabase.co/storage/v1/object/public/funcionarios/fotos/1781871803561.png	2026-06-19 12:23:24.923264	2026-06-19 12:23:24.923264	f	\N	\N	\N	2026-02-04	\N	\N	\N	30	t	\N	\N	\N	\N	\N	\N	\N	\N	\N
19d7cb2c-e21c-4863-aa70-f426d028d88c	075787	DEJAILTON JESUS DOS SANTOS	\N	\N	\N	\N	\N	2026-04-09	ativo	nova_admissao	c5ddb144-5847-4aec-b64b-cb346f96cfad	4489b3ec-6774-4a13-bc24-31b77deb6ae7	0d899f11-785d-4edd-a951-bac82fae074f	NAZARE	BA	https://lqggoshphakeuufibdno.supabase.co/storage/v1/object/public/funcionarios/fotos/1781716984239.jpeg	2026-06-02 11:56:26.625017	2026-06-02 11:56:26.625017	f	\N	\N	\N	\N	\N	\N	\N	45	f	\N	c8e6e203-9c03-42cb-9a30-63fca14dc225	\N	\N	\N	\N	\N	\N	\N
722f93bf-64cd-44c7-87eb-6fe9b05ae777	075799	WILLIAM SIDNEY SANTOS	\N	\N	\N	\N	\N	2026-04-15	ativo	nova_admissao	914d6d69-7338-4197-be53-ac04a5216eba	4489b3ec-6774-4a13-bc24-31b77deb6ae7	0d899f11-785d-4edd-a951-bac82fae074f	MATA DE SAO JOAO	BA	https://lqggoshphakeuufibdno.supabase.co/storage/v1/object/public/funcionarios/fotos/1781718098599.png	2026-06-02 12:01:35.03519	2026-06-02 12:01:35.03519	f	\N	\N	\N	\N	\N	\N	\N	45	f	\N	c8e6e203-9c03-42cb-9a30-63fca14dc225	\N	\N	\N	\N	\N	\N	\N
917fec59-ab61-45db-8f81-9beab2195f1b	075821	MARCILIO NUNES DE SOUSA	\N	\N	\N	\N	\N	2026-04-24	ativo	nova_admissao	c5ddb144-5847-4aec-b64b-cb346f96cfad	4489b3ec-6774-4a13-bc24-31b77deb6ae7	0d899f11-785d-4edd-a951-bac82fae074f	ICO	CE	https://lqggoshphakeuufibdno.supabase.co/storage/v1/object/public/funcionarios/fotos/1781717648784.png	2026-06-02 11:59:33.324033	2026-06-02 11:59:33.324033	f	\N	\N	\N	\N	\N	\N	\N	45	f	\N	7e18e7ce-a57d-4369-88de-8097c3286957	\N	\N	\N	\N	\N	\N	\N
6923c92f-fed0-4de4-a0d1-ec7390e85e78	72216	MARCOS SALLES FERREIRA	\N	\N	\N	\N	\N	2023-01-23	ativo	efetivo	c5ddb144-5847-4aec-b64b-cb346f96cfad	4489b3ec-6774-4a13-bc24-31b77deb6ae7	0ea37ce8-5f9d-4270-ac46-73e6c169c6d2	\N	\N	https://lqggoshphakeuufibdno.supabase.co/storage/v1/object/public/funcionarios/fotos/1781875052389.jpg	2026-06-19 13:17:34.23205	2026-06-19 13:17:34.23205	f	\N	\N	\N	2026-02-20	\N	\N	\N	30	t	\N	\N	\N	\N	\N	\N	\N	\N	\N
51ffaf0c-00fe-4d5d-821a-40c34a8203d8	73332	BRUNO DA CRUZ RODRIGUES	\N	\N	\N	\N	\N	2023-12-01	ativo	efetivo	b19eb87e-ab83-4460-b57f-f0302aaa1f0d	4489b3ec-6774-4a13-bc24-31b77deb6ae7	0ea37ce8-5f9d-4270-ac46-73e6c169c6d2	Marilia	SP	https://lqggoshphakeuufibdno.supabase.co/storage/v1/object/public/funcionarios/fotos/1781789122259.png	2026-06-18 13:25:24.564795	2026-06-18 13:25:24.564795	f	\N	\N	\N	2025-12-13	\N	\N	\N	30	t	ALOJADO	1a02849c-86c8-40b7-920d-7f20937d758b	\N	\N	\N	\N	\N	\N	\N
23f30241-e663-4fa8-b9ca-6a02f57cc7ac	75793	LUIZ CARLOS FLORENCIO DOS SANTOS	\N	\N	\N	\N	\N	2026-04-14	ativo	nova_admissao	\N	145e0a9b-f796-4db5-92e9-33f046f959ae	0ea37ce8-5f9d-4270-ac46-73e6c169c6d2	\N	\N	https://lqggoshphakeuufibdno.supabase.co/storage/v1/object/public/funcionarios/fotos/1781873984406.png	2026-06-19 12:59:46.357094	2026-06-19 12:59:46.357094	f	\N	\N	\N	2026-04-16	\N	SOLDADOR	\N	30	t	\N	\N	\N	\N	\N	\N	\N	\N	\N
5049a328-1980-4416-9c2e-77f649cc5b60	74847	DANIEL FEITOSA DOS SANTOS	\N	\N	\N	\N	\N	2025-01-15	ativo	efetivo	b19eb87e-ab83-4460-b57f-f0302aaa1f0d	145e0a9b-f796-4db5-92e9-33f046f959ae	0ea37ce8-5f9d-4270-ac46-73e6c169c6d2	Teotonio Vilela	AL	https://lqggoshphakeuufibdno.supabase.co/storage/v1/object/public/funcionarios/fotos/1781865933848.png	2026-06-19 10:45:35.834239	2026-06-19 10:45:35.834239	f	\N	\N	\N	2026-03-05	\N	\N	\N	30	t	\N	\N	\N	\N	\N	\N	\N	\N	\N
fd74e6c6-7cf2-4930-bebd-cf003fd4ea60	616	JOÃO TAVARES SENA	\N	\N	\N	\N	\N	1992-07-01	ativo	efetivo	0f58f874-6d22-4add-99cc-d7139c8bdbba	4489b3ec-6774-4a13-bc24-31b77deb6ae7	0ea37ce8-5f9d-4270-ac46-73e6c169c6d2	SÃO JOSÉ DOS CAMPOS	SP	https://lqggoshphakeuufibdno.supabase.co/storage/v1/object/public/funcionarios/fotos/1781871418674.jpg	2026-06-19 12:17:00.196502	2026-06-19 12:17:00.196502	f	\N	\N	\N	2026-03-09	\N	\N	\N	30	t	\N	\N	\N	\N	\N	\N	\N	\N	\N
bd7de2ed-7677-412b-94a5-3cf2d9667b31	75877	JOSUE JOSE DE OLIVEIRA	\N	\N	\N	\N	\N	2026-05-25	inativo	efetivo	c5ddb144-5847-4aec-b64b-cb346f96cfad	4489b3ec-6774-4a13-bc24-31b77deb6ae7	0ea37ce8-5f9d-4270-ac46-73e6c169c6d2	AMERICANA	SP	https://lqggoshphakeuufibdno.supabase.co/storage/v1/object/public/funcionarios/fotos/1781872358722.jpeg	2026-06-19 12:32:40.610813	2026-06-19 12:32:40.610813	f	\N	\N	\N	2026-05-27	\N	\N	\N	30	f	AVALIAÇÃO INTERNA REPROVADA	\N	2026-06-23	termino_experiencia	NÃO ATENDEU AS NECESSIDADES DA OBRA	\N	\N	\N	\N
2c36e097-d770-418a-b702-b9de29ca3c62	075879	WENDEL KAIC FREITAS LOPES	\N	\N	\N	\N	\N	2026-05-25	inativo	nova_admissao	\N	4489b3ec-6774-4a13-bc24-31b77deb6ae7	0d899f11-785d-4edd-a951-bac82fae074f	JAGUARUANA	SP	https://lqggoshphakeuufibdno.supabase.co/storage/v1/object/public/funcionarios/fotos/1781718068071.png	2026-06-03 15:00:29.82925	2026-06-03 15:00:29.82925	f	\N	\N	\N	\N	\N	\N	\N	45	f	\N	\N	2026-06-25	termino_experiencia	Não compareceu na obra, não recontratar	\N	\N	\N	\N
89b01666-1988-48ec-a651-f3e492c26d3b	075088	ANTONIO EDNILSON SERAFIM DE OLIVEIRA	\N	\N	\N	\N	\N	2025-02-19	ativo	nova_admissao	02a9da83-895c-4439-adff-aa33c7465e2f	4489b3ec-6774-4a13-bc24-31b77deb6ae7	0d899f11-785d-4edd-a951-bac82fae074f	RUSSAS	CE	https://lqggoshphakeuufibdno.supabase.co/storage/v1/object/public/funcionarios/fotos/1781716768819.png	2026-06-03 12:56:19.930749	2026-06-03 12:56:19.930749	f	\N	\N	\N	\N	\N	\N	\N	30	t	Efetivar	b7abc826-8aba-4f32-8e08-587315389657	\N	\N	\N	\N	\N	\N	\N
5db6a8eb-d6da-4faa-8d00-079ae58901d2	70083	JAIRO BISPO	\N	\N	\N	\N	\N	2018-07-19	ativo	efetivo	02a9da83-895c-4439-adff-aa33c7465e2f	4489b3ec-6774-4a13-bc24-31b77deb6ae7	0ea37ce8-5f9d-4270-ac46-73e6c169c6d2	SÃO PAULO	SP	https://lqggoshphakeuufibdno.supabase.co/storage/v1/object/public/funcionarios/fotos/1781868378528.jpeg	2026-06-19 11:26:20.926611	2026-06-19 11:26:20.926611	f	\N	\N	\N	2025-12-15	\N	\N	\N	30	t	\N	\N	\N	\N	\N	\N	\N	\N	\N
2c4cfbee-7f04-419a-a859-eb65149911d8	70156	JOSE CARLOS PEREIRA DOS SANTOS	\N	\N	\N	\N	\N	2018-09-11	ativo	efetivo	c5ddb144-5847-4aec-b64b-cb346f96cfad	4489b3ec-6774-4a13-bc24-31b77deb6ae7	0ea37ce8-5f9d-4270-ac46-73e6c169c6d2	MADRE DE DEUS	BA	https://lqggoshphakeuufibdno.supabase.co/storage/v1/object/public/funcionarios/fotos/1781871655434.png	2026-06-19 12:20:56.739425	2026-06-19 12:20:56.739425	f	\N	\N	\N	2026-01-06	\N	\N	\N	30	t	\N	\N	\N	\N	\N	\N	\N	\N	\N
a9cf53c8-6a86-4609-930d-98032c3abcbb	70969	EDSON JOSE NOGUEIRA	\N	\N	\N	\N	\N	2020-03-18	ativo	efetivo	2225eb09-8b7d-4f3f-85a0-55a5e20d0c15	4489b3ec-6774-4a13-bc24-31b77deb6ae7	0ea37ce8-5f9d-4270-ac46-73e6c169c6d2	Pirassununga	SP	https://lqggoshphakeuufibdno.supabase.co/storage/v1/object/public/funcionarios/fotos/1781866805632.jpg	2026-06-19 10:59:30.458662	2026-06-19 10:59:30.458662	f	\N	\N	\N	2025-12-15	\N	\N	\N	30	t	\N	\N	\N	\N	\N	\N	\N	\N	\N
f0342518-bd63-4b33-8caf-5fd0609fe44a	74445	MARCOS NUNES DE SOUZA	\N	\N	\N	\N	\N	2024-10-08	ativo	efetivo	\N	145e0a9b-f796-4db5-92e9-33f046f959ae	0ea37ce8-5f9d-4270-ac46-73e6c169c6d2	GOIANA	GO	https://lqggoshphakeuufibdno.supabase.co/storage/v1/object/public/funcionarios/fotos/1781874090797.png	2026-06-19 13:01:08.351453	2026-06-19 13:01:08.351453	f	\N	\N	\N	2026-01-07	\N	SOLDADOR	\N	30	t	\N	\N	\N	\N	\N	\N	\N	\N	\N
75d0a357-4313-4646-8ad4-a91705d2f2cf	74854	OZIEL ANDERSON DOS SANTOS	\N	\N	\N	\N	\N	2025-01-21	ativo	efetivo	02a9da83-895c-4439-adff-aa33c7465e2f	145e0a9b-f796-4db5-92e9-33f046f959ae	0ea37ce8-5f9d-4270-ac46-73e6c169c6d2	LIMEIRA	SP	https://lqggoshphakeuufibdno.supabase.co/storage/v1/object/public/funcionarios/fotos/1781875179601.jpg	2026-06-19 13:19:40.680273	2026-06-19 13:19:40.680273	f	\N	\N	\N	2025-12-22	\N	\N	\N	30	t	\N	\N	\N	\N	\N	\N	\N	\N	\N
7f3d6039-9c37-4d94-8875-0cc29bf3f232	75701	VITOR PAULINO ALVES DA SILVA	\N	\N	\N	\N	\N	2025-11-06	ativo	efetivo	338d331e-ef03-4d94-9369-567ee922f1e9	145e0a9b-f796-4db5-92e9-33f046f959ae	0ea37ce8-5f9d-4270-ac46-73e6c169c6d2	\N	\N	\N	2026-06-19 14:12:57.633042	2026-06-19 14:12:57.633042	f	\N	\N	\N	2026-06-09	\N	\N	\N	30	t	\N	\N	\N	\N	\N	\N	\N	\N	\N
ad24de67-0d79-4f4f-b164-0d4262e29bae	75763	GUSTAVO XAVIER BARBOSA	\N	\N	\N	\N	\N	2026-02-24	ativo	efetivo	338d331e-ef03-4d94-9369-567ee922f1e9	145e0a9b-f796-4db5-92e9-33f046f959ae	0ea37ce8-5f9d-4270-ac46-73e6c169c6d2	COSMOPOLIS	SP	https://lqggoshphakeuufibdno.supabase.co/storage/v1/object/public/funcionarios/fotos/1781868139690.jpg	2026-06-19 11:22:21.490816	2026-06-19 11:22:21.490816	f	\N	\N	\N	2026-03-02	\N	\N	\N	30	t	\N	\N	\N	\N	\N	\N	\N	\N	\N
549476d4-87b2-492a-8749-f1be57fb9fd2	75776	JERRY DA CONCEIÇÃO SALES	\N	\N	\N	\N	\N	2026-03-18	ativo	efetivo	b19eb87e-ab83-4460-b57f-f0302aaa1f0d	145e0a9b-f796-4db5-92e9-33f046f959ae	0ea37ce8-5f9d-4270-ac46-73e6c169c6d2	BARRAS	PI	https://lqggoshphakeuufibdno.supabase.co/storage/v1/object/public/funcionarios/fotos/1781869676239.jpg	2026-06-19 11:47:59.54979	2026-06-19 11:47:59.54979	f	\N	\N	\N	2026-03-23	\N	\N	\N	30	t	\N	\N	\N	\N	\N	\N	\N	\N	\N
8c845812-a24a-4aeb-9ab6-3669da5b915b	75845	JOÃO CARLOS ALVES DA SILVA	\N	\N	\N	\N	\N	2026-05-06	ativo	efetivo	b19eb87e-ab83-4460-b57f-f0302aaa1f0d	4489b3ec-6774-4a13-bc24-31b77deb6ae7	0ea37ce8-5f9d-4270-ac46-73e6c169c6d2	CAMPINAS	SP	https://lqggoshphakeuufibdno.supabase.co/storage/v1/object/public/funcionarios/fotos/1781871038242.png	2026-06-19 12:10:40.159091	2026-06-19 12:10:40.159091	f	\N	\N	\N	2026-05-06	\N	\N	\N	30	t	\N	\N	\N	\N	\N	\N	\N	\N	\N
1295cbeb-8ac0-4b58-8614-589dd7ff655b	75839	ERIKA SANTOS DE LIMA	\N	\N	\N	\N	\N	2026-05-04	ativo	efetivo	3f3c38f4-59ec-404c-9d32-b8f0976f7f36	4489b3ec-6774-4a13-bc24-31b77deb6ae7	0ea37ce8-5f9d-4270-ac46-73e6c169c6d2	SUMARÉ	SP	https://lqggoshphakeuufibdno.supabase.co/storage/v1/object/public/funcionarios/fotos/1781867316721.jpeg	2026-06-19 11:08:39.361687	2026-06-19 11:08:39.361687	f	\N	\N	\N	2026-05-04	\N	\N	\N	30	t	\N	\N	\N	\N	\N	\N	\N	\N	\N
82947628-c1c4-45e2-bf35-963cd4ec4d12	73244	VINICIUS ASTORINO BIZELLI	\N	\N	\N	\N	\N	2023-11-01	ativo	nova_admissao	\N	17e8550c-d196-4b45-8931-5ae1c4042e17	0ea37ce8-5f9d-4270-ac46-73e6c169c6d2	ARARAQUARA	SP	https://lqggoshphakeuufibdno.supabase.co/storage/v1/object/public/funcionarios/fotos/1781876192057.png	2026-06-19 13:36:33.377129	2026-06-19 13:36:33.377129	f	\N	\N	\N	2026-01-05	\N	ANALISTA DE PLANEJAMENTO II	\N	30	t	\N	\N	\N	\N	\N	\N	\N	\N	\N
7d775bd7-515c-4a33-b524-03c09c467b23	74857	PAULO RODRIGO PEREIRA PACHECO	\N	\N	\N	\N	\N	2025-01-22	ativo	efetivo	c5ddb144-5847-4aec-b64b-cb346f96cfad	4489b3ec-6774-4a13-bc24-31b77deb6ae7	0ea37ce8-5f9d-4270-ac46-73e6c169c6d2	PAULO AFONSO	BA	https://lqggoshphakeuufibdno.supabase.co/storage/v1/object/public/funcionarios/fotos/1781875382426.png	2026-06-19 13:23:03.816271	2026-06-19 13:23:03.816271	f	\N	\N	\N	2026-01-06	\N	\N	\N	30	t	\N	\N	\N	\N	\N	\N	\N	\N	\N
15dca725-12b8-4198-8816-223ffa666037	73489	THIAGO RODRIGUES DE BRITO	\N	\N	\N	\N	\N	2025-02-25	ativo	efetivo	b19eb87e-ab83-4460-b57f-f0302aaa1f0d	4489b3ec-6774-4a13-bc24-31b77deb6ae7	0ea37ce8-5f9d-4270-ac46-73e6c169c6d2	SAO MATHEUS	MA	https://lqggoshphakeuufibdno.supabase.co/storage/v1/object/public/funcionarios/fotos/1781875919497.jpg	2026-06-19 13:32:01.350606	2026-06-19 13:32:01.350606	f	\N	\N	\N	2025-12-15	\N	\N	\N	30	t	\N	\N	\N	\N	\N	\N	\N	\N	\N
022e764f-d223-4747-9960-83f18373028f	75740	UEDINER ALCIDES MARTINS	\N	\N	\N	\N	\N	2026-01-05	ativo	efetivo	\N	145e0a9b-f796-4db5-92e9-33f046f959ae	0ea37ce8-5f9d-4270-ac46-73e6c169c6d2	PAULÍNIA	SP	https://lqggoshphakeuufibdno.supabase.co/storage/v1/object/public/funcionarios/fotos/1781876030405.jpg	2026-06-19 13:33:51.152436	2026-06-19 13:33:51.152436	f	\N	\N	\N	2026-01-07	\N	TECNICO DE SEGURANÇA	\N	30	t	\N	\N	\N	\N	\N	\N	\N	\N	\N
c78775ac-815b-4fae-8534-cb72b04eb579	75788	RAIMUNDO DIAS	\N	\N	\N	\N	\N	2026-04-16	ativo	efetivo	\N	4489b3ec-6774-4a13-bc24-31b77deb6ae7	0ea37ce8-5f9d-4270-ac46-73e6c169c6d2	COSMOPOLIS	SP	https://lqggoshphakeuufibdno.supabase.co/storage/v1/object/public/funcionarios/fotos/1781875750749.png	2026-06-19 13:29:12.745931	2026-06-19 13:29:12.745931	f	\N	\N	\N	2026-04-14	\N	SOLDADOR	\N	30	t	\N	\N	\N	\N	\N	\N	\N	\N	\N
92ce3dcb-4f7d-4cbb-99e4-4349405e77ea	075800	CARLOS HENRIQUE AUGUSTO ARAUJO	\N	\N	\N	\N	\N	2026-04-15	ativo	nova_admissao	b19eb87e-ab83-4460-b57f-f0302aaa1f0d	4489b3ec-6774-4a13-bc24-31b77deb6ae7	0d899f11-785d-4edd-a951-bac82fae074f	BONITO DE SANTA FE	PB	https://lqggoshphakeuufibdno.supabase.co/storage/v1/object/public/funcionarios/fotos/1781716888194.png	2026-06-02 11:56:26.625017	2026-06-02 11:56:26.625017	f	\N	\N	\N	\N	\N	\N	\N	45	f	Efetivar	c8e6e203-9c03-42cb-9a30-63fca14dc225	\N	\N	\N	\N	\N	\N	\N
8a34f64c-b0af-4a24-a75e-949668c8697f	075798	FABIO LUIZ DE FARIAS	\N	\N	\N	\N	\N	2026-04-15	ativo	nova_admissao	b19eb87e-ab83-4460-b57f-f0302aaa1f0d	4489b3ec-6774-4a13-bc24-31b77deb6ae7	0d899f11-785d-4edd-a951-bac82fae074f	CAMPESTRE	AL	https://lqggoshphakeuufibdno.supabase.co/storage/v1/object/public/funcionarios/fotos/1781717084764.jpeg	2026-06-02 11:57:10.90763	2026-06-02 11:57:10.90763	f	\N	\N	\N	\N	\N	\N	\N	45	f	Efetivar Joao	c8e6e203-9c03-42cb-9a30-63fca14dc225	\N	\N	\N	\N	\N	\N	\N
f09fc646-1a8f-4a6e-8849-d237631a8849	075853	ARGEL QUEIROZ SANTANA	\N	\N	\N	\N	\N	2026-05-07	ativo	nova_admissao	6bd0e213-c32c-463f-9186-af82541d0781	4489b3ec-6774-4a13-bc24-31b77deb6ae7	0d899f11-785d-4edd-a951-bac82fae074f	RIBEIRAO BONITO	SP	https://lqggoshphakeuufibdno.supabase.co/storage/v1/object/public/funcionarios/fotos/1781716848305.png	2026-06-03 12:56:19.930749	2026-06-03 12:56:19.930749	f	\N	\N	\N	\N	\N	\N	\N	45	f	Verificar com João	e42bb35b-e6c4-4db2-8c2b-4c2e8f69a2e3	\N	\N	\N	\N	\N	\N	\N
a1aebbf0-c987-4a62-82ab-941ed4e7e7b1	75855	WASHINGTON LUIS BARBOSA VENTURA JUNIOR	\N	\N	\N	\N	\N	2026-05-11	inativo	nova_admissao	55c090af-e003-4b88-b130-6cd81c801d33	4489b3ec-6774-4a13-bc24-31b77deb6ae7	0d899f11-785d-4edd-a951-bac82fae074f	SERTAOZINHO	SP	https://lqggoshphakeuufibdno.supabase.co/storage/v1/object/public/funcionarios/fotos/1781718041475.jpeg	2026-06-03 14:58:31.564419	2026-06-03 14:58:31.564419	f	\N	\N	\N	2026-05-12	\N	\N	\N	45	f	verificar com Diego	\N	2026-06-24	termino_experiencia	Funcionário, com faltas no periodo de experiencia, não recontratar Supervisor Diego Ferreira	\N	\N	\N	\N
146f363f-134a-46bf-91fe-dd87e52c8f88	73240	LUCAS COSTA DA SILVA	\N	\N	\N	\N	\N	2023-11-01	inativo	efetivo	c5ddb144-5847-4aec-b64b-cb346f96cfad	4489b3ec-6774-4a13-bc24-31b77deb6ae7	0ea37ce8-5f9d-4270-ac46-73e6c169c6d2	CAMPINAS	SP	https://lqggoshphakeuufibdno.supabase.co/storage/v1/object/public/funcionarios/fotos/1781872847197.jpg	2026-06-19 12:40:48.890595	2026-06-19 12:40:48.890595	f	\N	\N	\N	2026-06-09	\N	\N	\N	30	f	FALTA DE COMPROMISSO COM AS FRENTES DE TRABALHO	\N	2026-06-24	aviso_previo_indenizado	NÃO ATENDEU AS NECESSIDADES DA OBRA	\N	\N	\N	\N
c5d1d552-ab3c-4e7b-aba3-4c26973e7310	075904	FRANCISCO LIMA RODRIGUES	\N	\N	\N	\N	\N	2026-06-15	ativo	nova_admissao	be64e377-6fe4-4fc3-a897-b7cfe18a0ba8	4489b3ec-6774-4a13-bc24-31b77deb6ae7	0d899f11-785d-4edd-a951-bac82fae074f	COREMAS	PB	https://lqggoshphakeuufibdno.supabase.co/storage/v1/object/public/funcionarios/fotos/1782565941373.jpg	2026-06-27 13:12:22.43139	2026-06-27 13:12:22.43139	f	\N	\N	\N	\N	\N	\N	\N	45	f	\N	02800faf-0e3a-40c5-b354-4e64d8a6f5ad	\N	\N	\N	\N	\N	\N	\N
1a7f8265-24e3-4ead-bcd0-747192c5cd30	075833	UBIRAJARA MENDONCA DOS SANTOS	\N	\N	\N	\N	\N	2026-04-28	ativo	nova_admissao	02a9da83-895c-4439-adff-aa33c7465e2f	4489b3ec-6774-4a13-bc24-31b77deb6ae7	0d899f11-785d-4edd-a951-bac82fae074f	ESCADA	PE	https://lqggoshphakeuufibdno.supabase.co/storage/v1/object/public/funcionarios/fotos/1781717973720.png	2026-06-02 12:01:35.03519	2026-06-02 12:01:35.03519	f	\N	\N	\N	\N	\N	\N	\N	45	f	Efetivar joao	7cec8c21-12e1-491d-89fb-fd3599eae796	\N	\N	\N	\N	\N	\N	\N
61272d13-22cb-499f-82a2-d9f85d2fff88	073254	CAUAN DE AQUINO	\N	\N	\N	\N	\N	2023-11-01	ativo	efetivo	0b9d58cf-e14b-4bfb-b6f9-70259cc30c2c	4489b3ec-6774-4a13-bc24-31b77deb6ae7	25341e31-cd60-4743-ad1b-658397ec5d72	BARUERI	SP	https://lqggoshphakeuufibdno.supabase.co/storage/v1/object/public/funcionarios/fotos/1782577971565.png	2026-06-27 16:32:52.85398	2026-06-27 16:32:52.85398	f	\N	\N	\N	\N	\N	\N	\N	45	t	\N	cdb01167-5280-41c1-9fe4-882d20e951a5	\N	\N	\N	\N	\N	\N	\N
2176ab2e-1917-4251-a2a1-2c3534905aad	073504	JURANDIR DA SILVA BARAUNA	\N	\N	\N	\N	\N	2024-02-01	ativo	efetivo	1fce97e3-ac38-4fa2-9aaf-678df518daec	4489b3ec-6774-4a13-bc24-31b77deb6ae7	25341e31-cd60-4743-ad1b-658397ec5d72	BARUERI	SP	https://lqggoshphakeuufibdno.supabase.co/storage/v1/object/public/funcionarios/fotos/1782579413837.png	2026-06-27 16:56:55.27749	2026-06-27 16:56:55.27749	f	\N	\N	\N	\N	\N	\N	\N	45	t	\N	d717dbdf-5fba-40c2-ad9f-bc9a4579027a	\N	\N	\N	\N	\N	\N	\N
68fd8b3c-130b-4141-a1db-d165e4c38aaf	073929	JOAO PAULO BALIZA MUNDIM	\N	\N	\N	\N	\N	2024-06-13	ativo	efetivo	a235f765-cc0a-45e5-8ad9-a2c8410e1295	4489b3ec-6774-4a13-bc24-31b77deb6ae7	25341e31-cd60-4743-ad1b-658397ec5d72	BARUERI	SP	\N	2026-06-27 16:52:59.777438	2026-06-27 16:52:59.777438	f	\N	\N	\N	\N	\N	\N	\N	45	t	\N	8d6ff09c-6e94-4f27-9e84-d6561a87ca74	\N	\N	\N	\N	\N	\N	\N
fb78102a-f3e2-4d54-835e-da3b1c1d9785	074250	ALDAIR DA SILVA OLIVEIRA	\N	\N	\N	\N	\N	2024-09-05	ativo	efetivo	0ab5cb66-4350-49a2-b5b6-acbbb4a0f0f3	4489b3ec-6774-4a13-bc24-31b77deb6ae7	25341e31-cd60-4743-ad1b-658397ec5d72	BARUERI	SP	https://lqggoshphakeuufibdno.supabase.co/storage/v1/object/public/funcionarios/fotos/1782568010319.png	2026-06-27 13:46:51.425084	2026-06-27 13:46:51.425084	f	\N	\N	\N	\N	\N	\N	\N	45	t	\N	8d6ff09c-6e94-4f27-9e84-d6561a87ca74	\N	\N	\N	\N	\N	\N	\N
4c291f0b-ec29-4014-8447-ff8141486133	074475	GLEIDSON COSTA CERQUEIRA	\N	\N	\N	\N	\N	2024-10-14	ativo	efetivo	1fce97e3-ac38-4fa2-9aaf-678df518daec	4489b3ec-6774-4a13-bc24-31b77deb6ae7	25341e31-cd60-4743-ad1b-658397ec5d72	BARUERI	SP	https://lqggoshphakeuufibdno.supabase.co/storage/v1/object/public/funcionarios/fotos/1782578646385.png	2026-06-27 16:44:06.913207	2026-06-27 16:44:06.913207	f	\N	\N	\N	\N	\N	\N	\N	45	t	\N	d717dbdf-5fba-40c2-ad9f-bc9a4579027a	\N	\N	\N	\N	\N	\N	\N
149426d3-e92e-49aa-95ae-cfbf4c3e79eb	075172	JOSE MARQUES FERREIRA NETO	\N	\N	\N	\N	\N	2025-03-03	ativo	efetivo	5008202f-4b1f-4f3f-9629-ff6978a8555a	4489b3ec-6774-4a13-bc24-31b77deb6ae7	25341e31-cd60-4743-ad1b-658397ec5d72	BARUERI	SP	https://lqggoshphakeuufibdno.supabase.co/storage/v1/object/public/funcionarios/fotos/1782579264211.png	2026-06-27 16:54:25.639191	2026-06-27 16:54:25.639191	f	\N	\N	\N	\N	\N	\N	\N	45	t	\N	8d6ff09c-6e94-4f27-9e84-d6561a87ca74	\N	\N	\N	\N	\N	\N	\N
b9e896d8-adaa-4e9b-9f5c-a8a9293c2898	075467	DENNYS HENRIQUE JOSE DA SILVA	\N	\N	\N	\N	\N	2025-05-06	ativo	efetivo	4ebb91fd-bf97-407b-bd01-b1238a7c3cc4	4489b3ec-6774-4a13-bc24-31b77deb6ae7	25341e31-cd60-4743-ad1b-658397ec5d72	BARUERI	SP	https://lqggoshphakeuufibdno.supabase.co/storage/v1/object/public/funcionarios/fotos/1782578377452.jpeg	2026-06-27 16:39:38.428745	2026-06-27 16:39:38.428745	f	\N	\N	\N	\N	\N	\N	\N	45	t	\N	\N	\N	\N	\N	\N	\N	\N	\N
97a4b2be-e75f-4345-b6cb-e2a485f681d9	075502	ANDRESA PINTO	\N	\N	\N	\N	\N	2025-05-21	ativo	efetivo	be29d15e-cb1d-494b-9ae9-ff2f5f791cb1	4489b3ec-6774-4a13-bc24-31b77deb6ae7	25341e31-cd60-4743-ad1b-658397ec5d72	BARUERI	SP	https://lqggoshphakeuufibdno.supabase.co/storage/v1/object/public/funcionarios/fotos/1782577833822.jpg	2026-06-27 16:30:35.305718	2026-06-27 16:30:35.305718	f	\N	\N	\N	\N	\N	\N	\N	45	t	\N	\N	\N	\N	\N	\N	\N	\N	\N
60ec1e4b-02fb-4960-885c-df2115df65ed	075592	HUELBERT MOISES DE OLIVEIRA	\N	\N	\N	\N	\N	2025-07-24	ativo	efetivo	eae884b1-38d5-4406-8815-b2e981c1fb58	4489b3ec-6774-4a13-bc24-31b77deb6ae7	25341e31-cd60-4743-ad1b-658397ec5d72	BARUERI	SP	https://lqggoshphakeuufibdno.supabase.co/storage/v1/object/public/funcionarios/fotos/1782579025471.jpeg	2026-06-27 16:50:26.809484	2026-06-27 16:50:26.809484	f	\N	\N	\N	\N	\N	\N	\N	45	t	\N	\N	\N	\N	\N	\N	\N	\N	\N
503eb3ca-27d6-426c-84ba-044969dc62f7	075891	JOAO PAULO DO CARMO	\N	\N	\N	\N	\N	2026-06-08	ativo	nova_admissao	8b7f7f1e-3df7-437e-be19-2c21deb9a278	4489b3ec-6774-4a13-bc24-31b77deb6ae7	0d899f11-785d-4edd-a951-bac82fae074f	MOGI DAS CRUZES	SP	https://lqggoshphakeuufibdno.supabase.co/storage/v1/object/public/funcionarios/fotos/1782565757406.png	2026-06-27 13:09:19.03036	2026-06-27 13:09:19.03036	f	\N	\N	\N	\N	\N	\N	\N	45	f	\N	5e1a3306-b40c-4277-8c03-5e317063af3b	\N	\N	\N	\N	\N	\N	\N
889b3979-f279-4693-92a5-2f9b6dfc1936	071466	LEANDRO PEREIRA DA SILVA	\N	\N	\N	\N	\N	2012-04-27	ativo	transferencia	502057ed-d5a0-4ae8-8110-36b0b90c3bb6	4489b3ec-6774-4a13-bc24-31b77deb6ae7	0d899f11-785d-4edd-a951-bac82fae074f	JUNDIA	AL	https://lqggoshphakeuufibdno.supabase.co/storage/v1/object/public/funcionarios/fotos/1782477189137.png	2026-06-26 12:33:11.246039	2026-06-26 12:33:11.246039	f	\N	\N	\N	\N	\N	\N	\N	45	t	\N	8371894c-46f8-42bf-9673-e9b149342305	\N	\N	\N	\N	\N	\N	\N
f9c553cc-bebf-4f36-b246-90b784ead557	072786	JOSUEL DA SILVA ROCHA	\N	\N	\N	\N	\N	2023-08-03	ativo	transferencia	91dc41a5-8374-4431-84e8-f6fa26b7d02e	4489b3ec-6774-4a13-bc24-31b77deb6ae7	0d899f11-785d-4edd-a951-bac82fae074f	GOIANA	PE	https://lqggoshphakeuufibdno.supabase.co/storage/v1/object/public/funcionarios/fotos/1782564172847.jpeg	2026-06-27 12:42:54.198591	2026-06-27 12:42:54.198591	f	\N	\N	\N	\N	\N	\N	\N	45	t	\N	5e1a3306-b40c-4277-8c03-5e317063af3b	\N	\N	\N	\N	\N	\N	\N
0c146680-e6c5-4a86-8707-fc7185d20631	073569	EMILLE MARIANE CARDOSO RAMOS	\N	\N	\N	\N	\N	2024-02-12	ativo	transferencia	6d670a8d-ed40-495b-9db2-18935fdd8aa9	4489b3ec-6774-4a13-bc24-31b77deb6ae7	0d899f11-785d-4edd-a951-bac82fae074f	MONTES CLAROS	MG	https://lqggoshphakeuufibdno.supabase.co/storage/v1/object/public/funcionarios/fotos/1782564442799.png	2026-06-27 12:47:24.747523	2026-06-27 12:47:24.747523	f	\N	\N	\N	\N	\N	\N	\N	45	t	\N	60c169d2-c301-454c-8f5a-cea1a2be53d5	\N	\N	\N	\N	\N	\N	\N
2643d90b-d363-471d-8a18-02139ddf4fde	075251	ARTHUR HENRIQUE NICACIO DA SILVA	\N	\N	\N	\N	\N	2025-03-27	ativo	transferencia	9c2c3f89-a31b-4557-b82a-987b45e84546	4489b3ec-6774-4a13-bc24-31b77deb6ae7	0d899f11-785d-4edd-a951-bac82fae074f	DELMIRO GOUVEIA	AL	https://lqggoshphakeuufibdno.supabase.co/storage/v1/object/public/funcionarios/fotos/1782565381720.png	2026-06-27 12:51:22.620541	2026-06-27 12:51:22.620541	f	\N	\N	\N	\N	\N	\N	\N	45	t	\N	02800faf-0e3a-40c5-b354-4e64d8a6f5ad	\N	\N	\N	\N	\N	\N	\N
12783ba4-0452-4220-8429-c7c8070473d4	075909	VINICIUS APASSITE BITENCOURT	\N	\N	\N	\N	\N	2026-06-26	ativo	nova_admissao	0ddf03a1-08bc-4970-8ced-87ea7f2e51da	4489b3ec-6774-4a13-bc24-31b77deb6ae7	25341e31-cd60-4743-ad1b-658397ec5d72	BARUERI	SP	https://lqggoshphakeuufibdno.supabase.co/storage/v1/object/public/funcionarios/fotos/1782580148579.jpeg	2026-06-27 17:09:09.580878	2026-06-27 17:09:09.580878	f	\N	\N	\N	2026-06-29	\N	\N	\N	45	f	\N	\N	\N	\N	\N	\N	\N	\N	\N
db4f7478-c942-49f4-a173-2a635aa782ae	075889	FRANCISCO WELLINGTON SILVA LEITE	\N	\N	\N	\N	\N	2026-06-01	ativo	nova_admissao	338d331e-ef03-4d94-9369-567ee922f1e9	4489b3ec-6774-4a13-bc24-31b77deb6ae7	0d899f11-785d-4edd-a951-bac82fae074f	JAGUARUANA	CE	https://lqggoshphakeuufibdno.supabase.co/storage/v1/object/public/funcionarios/fotos/1781717157467.png	2026-06-03 12:56:19.930749	2026-06-03 12:56:19.930749	f	\N	\N	\N	\N	\N	\N	\N	45	f	\N	ae89e516-b560-4cbd-9150-5d3acc49e49a	\N	\N	\N	\N	\N	\N	\N
8eda57ec-d586-4d0d-af4e-e087142dec04	010615	PAULO GILSON DA SILVA	\N	\N	\N	\N	\N	2005-01-27	ativo	efetivo	a203b010-2a07-4aae-bc3b-59b76c346cce	4489b3ec-6774-4a13-bc24-31b77deb6ae7	25341e31-cd60-4743-ad1b-658397ec5d72	BARUERI	SP	https://lqggoshphakeuufibdno.supabase.co/storage/v1/object/public/funcionarios/fotos/1782579753622.jpg	2026-06-27 17:02:34.915455	2026-06-27 17:02:34.915455	f	\N	\N	\N	\N	\N	\N	\N	45	t	\N	f2c322ef-2125-4052-88f7-58d45ba5135f	\N	\N	\N	\N	\N	\N	\N
e387b8f9-be91-4baa-b571-1e77d9967c7c	070201	CARLOS JOSE RODRIGUES	\N	\N	\N	\N	\N	2018-11-23	ativo	efetivo	f3be3192-7549-4fa7-b800-304270e25b57	4489b3ec-6774-4a13-bc24-31b77deb6ae7	25341e31-cd60-4743-ad1b-658397ec5d72	BARUERI	SP	https://lqggoshphakeuufibdno.supabase.co/storage/v1/object/public/funcionarios/fotos/1782577913569.jpg	2026-06-27 16:31:54.264949	2026-06-27 16:31:54.264949	f	\N	\N	\N	\N	\N	\N	\N	45	t	\N	d717dbdf-5fba-40c2-ad9f-bc9a4579027a	\N	\N	\N	\N	\N	\N	\N
9d249fdb-c48d-4208-a046-4288d5a6b389	071144	CARLOS HENRIQUE FERREIRA SOUZA	\N	\N	\N	\N	\N	2020-11-03	ativo	efetivo	f0d8f6f3-3ad5-4ba0-8713-f94dbfab6789	4489b3ec-6774-4a13-bc24-31b77deb6ae7	25341e31-cd60-4743-ad1b-658397ec5d72	BARUERI	SP	\N	2026-06-27 17:51:45.953044	2026-06-27 17:51:45.953044	f	\N	\N	\N	\N	\N	\N	\N	45	t	\N	\N	\N	\N	\N	\N	\N	\N	\N
14300a3f-d1ae-41f3-a4c4-adcfca696717	074207	LUIZ CARLOS SARAIVA CALIXTO	\N	\N	\N	\N	\N	2024-08-29	ativo	efetivo	8d808fac-f78d-4509-8d13-973a415a6421	4489b3ec-6774-4a13-bc24-31b77deb6ae7	25341e31-cd60-4743-ad1b-658397ec5d72	BARUERI	SP	https://lqggoshphakeuufibdno.supabase.co/storage/v1/object/public/funcionarios/fotos/1782579651187.png	2026-06-27 17:00:52.158427	2026-06-27 17:00:52.158427	f	\N	\N	\N	\N	\N	\N	\N	45	t	\N	f2c322ef-2125-4052-88f7-58d45ba5135f	\N	\N	\N	\N	\N	\N	\N
cada9130-9918-4bd4-9f11-7166c5188955	70924	Admar Cesar Cola	\N	\N	\N	\N	\N	2020-02-17	ativo	transferencia	d3e9070c-4e16-499e-ad29-68ce6b0c7233	4489b3ec-6774-4a13-bc24-31b77deb6ae7	fecd46b3-7f55-4fa2-b0f6-02e351793a4f	Ponta Grossa	PR	https://lqggoshphakeuufibdno.supabase.co/storage/v1/object/public/funcionarios/fotos/1782408392167.png	2026-06-25 17:26:33.796929	2026-06-25 17:26:33.796929	f	\N	\N	\N	2026-04-02	\N	\N	\N	45	t	\N	a2004f54-f73c-4e26-9661-7d5a42e160cb	\N	\N	\N	\N	\N	\N	\N
efa824c4-d56b-4973-b518-f3a6784a62ce	075385	IGLESSE ALMEIDA DO NASCIMENTO	\N	\N	\N	\N	\N	2025-04-15	ativo	efetivo	5008202f-4b1f-4f3f-9629-ff6978a8555a	4489b3ec-6774-4a13-bc24-31b77deb6ae7	25341e31-cd60-4743-ad1b-658397ec5d72	BARUERI	SP	https://lqggoshphakeuufibdno.supabase.co/storage/v1/object/public/funcionarios/fotos/1782579113177.png	2026-06-27 16:51:53.964179	2026-06-27 16:51:53.964179	f	\N	\N	\N	\N	\N	\N	\N	45	t	\N	d717dbdf-5fba-40c2-ad9f-bc9a4579027a	\N	\N	\N	\N	\N	\N	\N
ccab729b-5d81-49ca-a18c-b62922aa7eb4	075687	ROZILMA DE SOUZA CESAR	\N	\N	\N	\N	\N	2025-10-24	ativo	efetivo	ca4eb86b-d552-4ec0-9256-69e57e2cb588	4489b3ec-6774-4a13-bc24-31b77deb6ae7	25341e31-cd60-4743-ad1b-658397ec5d72	BARUERI	SP	https://lqggoshphakeuufibdno.supabase.co/storage/v1/object/public/funcionarios/fotos/1782580052796.png	2026-06-27 17:07:36.050456	2026-06-27 17:07:36.050456	f	\N	\N	\N	\N	\N	\N	\N	45	t	\N	\N	\N	\N	\N	\N	\N	\N	\N
2d45ed01-cb9f-49aa-b781-a69ed90fe642	75878	LUIS HENRIQUE RIBEIRO	\N	\N	\N	\N	\N	2026-05-25	inativo	efetivo	\N	4489b3ec-6774-4a13-bc24-31b77deb6ae7	0ea37ce8-5f9d-4270-ac46-73e6c169c6d2	COSMOPOLIS	SP	https://lqggoshphakeuufibdno.supabase.co/storage/v1/object/public/funcionarios/fotos/1781873305606.png	2026-06-19 12:48:27.846447	2026-06-19 12:48:27.846447	f	\N	\N	\N	2026-05-27	\N	\N	\N	30	f	AVALIAÇÃO INTERNA REPROVADA	\N	2026-06-23	termino_experiencia	MUITAS FALTAS NO PERIODO DE EXPERIENCIA E SEM COMPROMETIMENTO COM A OBRA E LIDERANÇA.	\N	\N	\N	\N
2d46e8fa-a999-410b-a861-e7ace3cef2aa	075908	AUDIMIR DOS SANTOS	\N	\N	\N	\N	\N	2026-06-26	ativo	nova_admissao	5008202f-4b1f-4f3f-9629-ff6978a8555a	4489b3ec-6774-4a13-bc24-31b77deb6ae7	25341e31-cd60-4743-ad1b-658397ec5d72	BARUERI	SP	https://lqggoshphakeuufibdno.supabase.co/storage/v1/object/public/funcionarios/fotos/1782580348796.png	2026-06-27 17:12:29.971389	2026-06-27 17:12:29.971389	f	\N	\N	\N	2026-07-01	\N	\N	\N	45	f	\N	8d6ff09c-6e94-4f27-9e84-d6561a87ca74	\N	\N	\N	\N	\N	\N	\N
45c95f63-f01a-40d2-be78-0957b27917d1	72683	CLAYTON HENRIQUE DE SOUZA	\N	\N	\N	\N	\N	2023-07-04	ativo	efetivo	82ad4b82-9ce3-4675-ab70-1301fdf6308c	4489b3ec-6774-4a13-bc24-31b77deb6ae7	0ea37ce8-5f9d-4270-ac46-73e6c169c6d2	SÃO JOSE DOS CAMPOS	SP	https://lqggoshphakeuufibdno.supabase.co/storage/v1/object/public/funcionarios/fotos/1782990641779.png	2026-07-02 11:10:42.882778	2026-07-02 11:10:42.882778	f	\N	\N	\N	2025-12-08	\N	\N	\N	30	t	\N	326e50c1-0ebc-4674-8bf9-a9cac9ea998d	\N	\N	\N	7120.29	mensalista	\N	\N
403c2366-9d20-48d2-8e2b-787a194ec54f	073358	EDNARTE CASTELO BRANCO JUNIOR	\N	\N	\N	\N	\N	2023-12-08	ativo	efetivo	51c831c0-3baa-498c-b48d-c415fe6cfa0b	4489b3ec-6774-4a13-bc24-31b77deb6ae7	ae387bdc-cf9e-4d3a-ad30-5a16e85801bc	JUNDIA	AL	https://lqggoshphakeuufibdno.supabase.co/storage/v1/object/public/funcionarios/fotos/1783457279470.png	2026-07-07 20:48:05.229642	2026-07-07 20:48:05.229642	t	2026-07-22	f1b4fe50-69ba-4443-aa10-53e4d8d124c7	23698	\N	\N	\N	recebimento	45	f	\N	\N	\N	\N	\N	5169.21	mensalista	\N	\N
b2c73325-35a7-4b8c-8c53-06e6e4719eb3	75906	JEFFERSON GERSON MENDES DA SILVA	\N	\N	\N	\N	\N	2026-06-23	ativo	nova_admissao	\N	4489b3ec-6774-4a13-bc24-31b77deb6ae7	0ea37ce8-5f9d-4270-ac46-73e6c169c6d2	SUMARE	SP	https://lqggoshphakeuufibdno.supabase.co/storage/v1/object/public/funcionarios/fotos/1782395807073.jpeg	2026-06-25 13:56:49.1872	2026-06-25 13:56:49.1872	f	\N	\N	\N	0206-06-25	\N	\N	\N	30s	f	\N	\N	\N	\N	\N	3447.40	\N	\N	\N
f4f5e0c6-a407-471e-9cbe-1c9411c62567	071040	ELIZIER JOSUE DE OLIVEIRA	\N	\N	\N	\N	\N	2020-06-17	ativo	efetivo	ca4eb86b-d552-4ec0-9256-69e57e2cb588	4489b3ec-6774-4a13-bc24-31b77deb6ae7	ae387bdc-cf9e-4d3a-ad30-5a16e85801bc	CUIABÁ	MT	https://lqggoshphakeuufibdno.supabase.co/storage/v1/object/public/funcionarios/fotos/1781620737437.jpg	2026-06-16 14:38:58.828596	2026-06-16 14:38:58.828596	t	2026-06-29	\N	24314	\N	\N	\N		30	t	\N	08c90ae3-d954-4510-91bc-1a0fb93c6c68	\N	\N	\N	5467.68	mensalista	7eca1a31-eb4e-4e6e-b853-57bc6c9ac091	2024-10-14
094b876c-ba2c-4518-b30a-28dc1462c38e	75186	ALVARO SALDANHA LIMA	\N	\N	\N	\N	\N	2025-03-07	ativo	efetivo	522b51eb-a006-45b9-a295-ba6c04471afd	4489b3ec-6774-4a13-bc24-31b77deb6ae7	ae387bdc-cf9e-4d3a-ad30-5a16e85801bc	SALVADOR	BA	https://lqggoshphakeuufibdno.supabase.co/storage/v1/object/public/funcionarios/fotos/1781527371578.png	2026-06-15 12:42:53.374996	2026-06-15 12:42:53.374996	t	2026-07-02	0ea37ce8-5f9d-4270-ac46-73e6c169c6d2	24314	2026-07-06	\N	\N	envio	30	t	ALOJADO	6def14ab-7549-47b2-b268-e0775a28a51f	\N	\N	\N	15.66	horista	\N	\N
519005c1-dfd6-4952-be33-a68aa37640a6	60868	FABIO DE SOUZA	\N	\N	\N	\N	\N	2018-03-14	ativo	efetivo	6967d7ed-0955-4360-b2d5-771e554968c2	4489b3ec-6774-4a13-bc24-31b77deb6ae7	ae387bdc-cf9e-4d3a-ad30-5a16e85801bc	SAO JOSÉ DOS CAMPOS	SP	https://lqggoshphakeuufibdno.supabase.co/storage/v1/object/public/funcionarios/fotos/1783457564349.png	2026-06-19 11:17:14.858409	2026-06-19 11:17:14.858409	t	2026-06-29	0ea37ce8-5f9d-4270-ac46-73e6c169c6d2	24314	\N	\N	\N	envio	30	t	\N	08c90ae3-d954-4510-91bc-1a0fb93c6c68	\N	\N	\N	10075.90	mensalista	\N	\N
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
ca4eb86b-d552-4ec0-9256-69e57e2cb588	TÉCNICO DE SEGURANÇA DO TRABALHO	2026-06-25 17:35:09.233768
9c2c3f89-a31b-4557-b82a-987b45e84546	MONTADOR DE ANDAIME	2026-06-27 12:51:22.338832
4ebb91fd-bf97-407b-bd01-b1238a7c3cc4	ELETRICISTA LIDER	2026-06-27 16:39:37.205815
1fce97e3-ac38-4fa2-9aaf-678df518daec	SOLDADOR	2026-06-27 16:44:06.083591
8d808fac-f78d-4509-8d13-973a415a6421	SUPERVISOR DE TUBULAÇÃO	2026-06-27 17:00:50.943286
f0d8f6f3-3ad5-4ba0-8713-f94dbfab6789	SUPERVISOR DE PLANEJAMENTO II	2026-06-27 17:51:45.629361
3f3c38f4-59ec-404c-9d32-b8f0976f7f36	AUXILIAR DE PLANEJAMENTO	2026-07-01 17:12:45.396396
250ccfab-916a-4371-9b83-1c3c1aad4822	1/2 OFICIAL ENCANADOR	2026-07-02 17:27:42.882428
522b51eb-a006-45b9-a295-ba6c04471afd	MECÂNICO MONTADOR	2026-07-06 13:29:34.702651
8cfe5485-e51a-407a-84a7-6cc619e29ae3	ENCARREGADO DE TUBULACAO	2026-07-07 20:42:09.949959
6967d7ed-0955-4360-b2d5-771e554968c2	SUPERVISOR DE PLANEJAMENTO	2026-07-07 20:52:44.807959
\.


--
-- Data for Name: matriz_contatos; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.matriz_contatos (id, obra, crd, nome, cargo, setor, email, contato, lider_imediato, gestor_obra, responsavel_contrato, cidade, estado, tipo_obra, endereco, foto_url, created_at) FROM stdin;
9851c312-265f-48de-ab8d-cdef7c3bf913	COAMO_Et.Milho_Gr 1-2-3	24128	Renato Bartsch	Gestor de Contrato	Obras	renato.bartsch@gtel-sp.com.br	11 95317-2661	Heber Vidal	Renato Bartsch	Heber Vidal	Campo Mourão	PR	Industria	\N	https://uploaddeimagens.com.br/images/004/780/267/thumb/Renato_Barstch.jpg	2026-06-30 20:32:06.228876+00
8dcada20-b1df-41e2-af2f-fe4774bdcc74	COAMO_Et.Milho_Gr 1-2-3	24128	Admar Cola	Encarregado Administrativo	Obras	admar.cola@gtel-sp.com.br	11 95770-4705	Murilo Evangelista	Renato Bartsch	Heber Vidal	Campo Mourão	PR	Industria	\N	https://uploaddeimagens.com.br/images/004/780/133/thumb/Admar.jpg	2026-06-30 20:32:06.228876+00
d09c290a-82cb-4f45-ac8a-2d945c5b922f	COAMO_Et.Milho_Gr 1-2-3	24128	Levy Amorim	Assistente Administrativo	Obras	levy.amorim@gtel-sp.com.br	37 99669-7874	Murilo Evangelista	Renato Bartsch	Heber Vidal	Campo Mourão	PR	Industria	\N	\N	2026-06-30 20:32:06.228876+00
b3b6c31a-df28-4a9f-9d5f-1cc2907d27b3	Daiichi Sankyo	23403	Fabio Santana	Gestor de Contrato	Obras	fabio.santana@gtel-sp.com.br	11 95317-2661	Heber Vidal	Fabio Santana	Heber Vidal	Barueri	SP	Industria	\N	https://uploaddeimagens.com.br/images/004/780/267/thumb/Renato_Barstch.jpg	2026-06-30 20:32:06.228876+00
e5aa07b0-c3d8-44c5-9422-7afd7c74406f	Daiichi Sankyo	23403	Cauan Aquino	Assistente Administrativo	Obras	caua.aquino@gtelsa.com.br	14 99649-1222	Murilo Evangelista	Renato Bartsch	Heber Vidal	Barueri	SP	Industria	\N	\N	2026-06-30 20:32:06.228876+00
f51fb93a-280e-4988-86ef-fd875d9c6f76	Embraer Caçapava	1940525E	Felix Santos	Assistente Administrativo	Obras	felix.santos@gtel-sp.com.br	11 91255-9620	Murilo Evangelista	Laedson Souza	Heber Vidal	Caçapava	SP	Industria	\N	https://uploaddeimagens.com.br/images/004/774/603/thumb/Felix_Santos.jpg	2026-06-30 20:32:06.228876+00
ec8af2aa-90d4-44e8-bc87-030c0c67c746	Embraer Caçapava	1940525E	Laedson Souza	Gestor de Contrato	Obras	laedson.sousa@gtel-sp.com.br	12 98892-2745	Heber Vidal	Laedson Souza	Heber Vidal	Caçapava	SP	Industria	\N	https://uploaddeimagens.com.br/images/004/772/007/thumb/Laedson.jpg	2026-06-30 20:32:06.228876+00
eaeb0198-3273-497f-902c-01472efa5c70	Embraer Botucatu Demanda	194050203E	Karen Alves	Auxiliar Administrativo	Obras	karen.alves@gtelsa.com.br	11 91822-6705	Murilo Evangelista	Luiz Odair	Heber Vidal	Botucatu	SP	Industria	Av. Alcides Cagliari, 2281 - CEP: 18606-855 -Botucatu - SP	https://uploaddeimagens.com.br/images/004/772/002/thumb/Karen_Alves.jpg	2026-06-30 20:32:06.228876+00
ea04e52e-0c29-46c8-88c7-a2378cdf75d3	Embraer Botucatu Demanda	194050203E	Ana Bittencourt	Auxiliar Administrativo	Obras	ana.bittencourt@gtelsa.com.br	11 91822-6705	Murilo Evangelista	Luiz Odair	Heber Vidal	Botucatu	SP	Industria	Av. Alcides Cagliari, 2281 - CEP: 18606-855 -Botucatu - SP	\N	2026-06-30 20:32:06.228876+00
4a6348b8-7405-4671-9564-bfe4d1f92924	Embraer Botucatu Demanda	194050203E	Hysslawanya Lopes	Auxiliar Administrativo	Obras	hysslawanya.lopes@gtelsa.com.br	11 91822-6705	Murilo Evangelista	Luiz Odair	Heber Vidal	Botucatu	SP	Industria	Av. Alcides Cagliari, 2281 - CEP: 18606-855 -Botucatu - SP	\N	2026-06-30 20:32:06.228876+00
dda0fbe6-5dbe-42fe-ac1b-0497d4586257	Embraer Botucatu Demanda	194050203E	Luiz Odair	Gestor de Contrato	obras	luiz.alves@gtel-sp.com.br	12 98892-2445	Heber Vidal	Luiz Odair	Heber Vidal	Botucatu	SP	Industria	Av. Alcides Cagliari, 2281 - CEP: 18606-855 -Botucatu - SP	\N	2026-06-30 20:32:06.228876+00
059f2608-a6e6-4473-9865-992e1ce9cd54	Embraer Botucatu Demanda	194050203E	Jeferson Fraga	Gestor de Contrato	obras	jeferson.fraga@gtel-sp.com.br	12 98892-2445	Heber Vidal	Jeferson Fraga	Heber Vidal	Botucatu	SP	Industria	Av. Alcides Cagliari, 2281 - CEP: 18606-855 -Botucatu - SP	\N	2026-06-30 20:32:06.228876+00
6374650d-c017-4926-bc03-3ac33530a0f4	EMBRAER CAMPINAS TI	1940524E	Jeferson Fraga	Gestor de Contrato	obras	jeferson.fraga@gtel-sp.com.br	12 98892-2445	Heber Vidal	Jeferson Fraga	Heber Vidal	Campinas	SP	Industria	\N	\N	2026-06-30 20:32:06.228876+00
37c5705f-8250-467e-a569-2a9a8441bbb5	EMBRAER CAMPINAS TI	1940524E	Karen Alves	Auxiliar Administrativo	Obras	karen.alves@gtelsa.com.br	11 91822-6705	Murilo Evangelista	Jeferson Fraga	Heber Vidal	Campinas	SP	Industria	\N	\N	2026-06-30 20:32:06.228876+00
6fa7662f-a85d-4341-bad2-72df98a4ad49	EMBRAER SOROCABA TI	1940514E	Jeferson Fraga	Gestor de Contrato	obras	jeferson.fraga@gtel-sp.com.br	12 98892-2445	Heber Vidal	Jeferson Fraga	Heber Vidal	Sorocaba	SP	Industria	\N	\N	2026-06-30 20:32:06.228876+00
a667b0a3-8c6f-46f5-a8ec-433ed357495d	EMBRAER SOROCABA TI	1940514E	Karen Alves	Auxiliar Administrativo	Obras	karen.alves@gtelsa.com.br	11 91822-6705	Murilo Evangelista	Jeferson Fraga	Heber Vidal	Sorocaba	SP	Industria	\N	\N	2026-06-30 20:32:06.228876+00
23951891-2cb5-4130-84ab-ef2c1572150e	EMBRAER BOTUCATU TI	1940508E	Jeferson Fraga	Gestor de Contrato	obras	jeferson.fraga@gtel-sp.com.br	12 98892-2445	Heber Vidal	Jeferson Fraga	Heber Vidal	Botucatu	SP	Industria	\N	\N	2026-06-30 20:32:06.228876+00
c4cc594e-0f59-4f44-8dc8-5248b33d0a10	EMBRAER BOTUCATU TI	1940508E	Karen Alves	Auxiliar Administrativo	Obras	karen.alves@gtelsa.com.br	11 91822-6705	Murilo Evangelista	Jeferson Fraga	Heber Vidal	Botucatu	SP	Industria	\N	\N	2026-06-30 20:32:06.228876+00
98af0d7c-12ca-49bb-b3da-f54bee0de857	Embraer SJC	19405-02E	Daniel Sousa	Encarregado Administrativo	Obras	daniel.sousa@gtel-sp.com.br	12 98892-6085	Murilo Evangelista	Laedson Souza	Heber Vidal	São José dos Campos	SP	Industria	Av. Brig. Faria Lima, 2170 CEP: 12227-901 - Putim São José dos Campos - SP	https://uploaddeimagens.com.br/images/004/772/004/thumb/Daniel_Souza.jpg	2026-06-30 20:32:06.228876+00
5245bf67-3e5f-4832-b3ab-186f3ea6eab0	Embraer SJC	19405-02E	Laedson Souza	Gestor de Contrato	Obras	laedson.sousa@gtel-sp.com.br	12 98892-2745	Heber Vidal	Laedson Souza	Heber Vidal	São José dos Campos	SP	Industria	Av. Brig. Faria Lima, 2170 CEP: 12227-901 - Putim São José dos Campos - SP	https://uploaddeimagens.com.br/images/004/772/007/thumb/Laedson.jpg	2026-06-30 20:32:06.228876+00
f94bba9b-87bf-47dc-b3da-794bd20c8691	Embraer SJC	19405-02E	Rebeca Sousa	Auxiliar Administrativo	Obras	rebeca.sousa@gtel-sp.com.br	12 98892-6085	Murilo Evangelista	Laedson Souza	Heber Vidal	São José dos Campos	SP	Industria	Av. Brig. Faria Lima, 2170 CEP: 12227-901 - Putim São José dos Campos - SP	https://uploaddeimagens.com.br/images/004/772/008/thumb/Rebeca_Souza.jpg	2026-06-30 20:32:06.228876+00
d1b98c00-6924-47e5-8760-00fd90dcd13f	Embraer SJC	19405-02E	Giovana Vieira	AUXILIAR DE ESCRITORIO I	Obras	giovana.vieira@gtelsa.com.br	\N	Murilo Evangelista	Laedson Souza	Heber Vidal	São José dos Campos	SP	Industria	Av. Brig. Faria Lima, 2170 CEP: 12227-901 - Putim São José dos Campos - SP	https://uploaddeimagens.com.br/images/004/772/008/thumb/Rebeca_Souza.jpg	2026-06-30 20:32:06.228876+00
a8dd1b27-b321-49a5-bf0c-77691f731a33	Sede	100	Heber Vidal	Diretor de Obras e Operações	Sede	heber.vidal@gtelsa.com.br	11 97180-7243	\N	\N	\N	São Paulo	SP	\N	Rua Acurui 531 - Vila Formosa - São Paulo SP - CEP 03355-000	\N	2026-06-30 20:32:06.228876+00
060663c6-cbfe-4e85-9fc2-80962bc38c00	Embraer GPX Demanda	1940501E	Fabio Gullo	Técnico de Segurança do Trabalho	Obras	<fabio.gullo@gtel-sp.com.br>	16 99786-4644	Vitor Ribeiro	Reginado Soares	Heber Vidal	Gavião Peixoto	SP	Industria	Est.Mun. Euclides Martins, 2170 CEP: 14813-000 -GAVIAO PEIXOTO - SP	https://uploaddeimagens.com.br/images/004/772/011/thumb/Fabio_Gullo.jpg	2026-06-30 20:32:06.228876+00
96158635-21cf-4678-8cb2-62610ff8bfe0	Embraer GPX Demanda	1940501E	Tiago Silva	Assistente Administrativo	Obras	tiago.silva@gtelsa.com.br	11 97192-8966	Murilo Evangelista	Reginado Soares	Heber Vidal	Gavião Peixoto	SP	Industria	Est.Mun. Euclides Martins, 2170 CEP: 14813-000 -GAVIAO PEIXOTO - SP	https://uploaddeimagens.com.br/images/004/775/597/thumb/Tiago_silva.jpg	2026-06-30 20:32:06.228876+00
5130a298-3320-49c0-ba37-e68b283f3a96	Embraer GPX Demanda	1940501E	Salatiel Marcondes	Auxiliar de Escritorio I	Obras	salatiel.marcondes@gtelsa.com.br	11 97192-8966	Murilo Evangelista	Reginado Soares	Heber Vidal	Gavião Peixoto	SP	Industria	Est.Mun. Euclides Martins, 2170 CEP: 14813-000 -GAVIAO PEIXOTO - SP	\N	2026-06-30 20:32:06.228876+00
71070b93-ce54-4a10-8779-d072dfc0dd3b	Embraer GPX Demanda	1940501E	Reginaldo Soares	Gestor do Contrato	Obras	reginaldo.soares@gtelsa.com.br	11 93442-0666	Heber Vidal	Reginado Soares	Heber Vidal	Gavião Peixoto	SP	Industria	Est.Mun. Euclides Martins, 2170 CEP: 14813-000 -GAVIAO PEIXOTO - SP	\N	2026-06-30 20:32:06.228876+00
1bf466e3-6433-4254-bded-7a2c599c7342	GS E&C BRAZIL LTDA - LG	23958	Admar Cola	Encarregado Administrativo	Obras	admar.cola@gtel-sp.com.br	11 95770-4705	Murilo Evangelista	Renato Bartsch	Heber Vidal	Curitiba	PR	Industria	\N	https://uploaddeimagens.com.br/images/004/780/133/thumb/Admar.jpg	2026-06-30 20:32:06.228876+00
1be0a54f-2293-4171-9428-6f3a3089e3c6	GS E&C BRAZIL LTDA - LG	23958	Renato Bartsch	Gestor de Contrato	Obras	renato.bartsch@gtel-sp.com.br	11 95317-2661	Heber Vidal	Renato Bartsch	Heber Vidal	Curitiba	PR	Industria	\N	https://uploaddeimagens.com.br/images/004/780/267/thumb/Renato_Barstch.jpg	2026-06-30 20:32:06.228876+00
e5b0f4d3-4419-4b46-8e50-84eda3419862	ICTSI Rio Brasil Terminal	24122	Biontino Pereira	Gestor de Contrato	Obras	biontino.pereira@gtelsa.com.br	11 96840-5794	Fabio Santana	Biontino Pereira	Heber Vidal	Rio de Janeiro	RJ	Industria	\N	\N	2026-06-30 20:32:06.228876+00
e0cee7f0-08b1-4c6e-a50b-d5d24230400b	ICTSI Rio Brasil Terminal	24122	Adário Santos	Encarregado Administrativo	Obras	adario.santos@gtelsa.com.br	12 98891-6678	Murilo Evangelista	Biontino Pereira	Heber Vidal	Rio de Janeiro	RJ	Industria	\N	https://uploaddeimagens.com.br/images/004/780/101/thumb/Adario_Santos.jpg	2026-06-30 20:32:06.228876+00
fbb0a2d5-869d-49d2-92a1-8126a4f795f4	Meiwa	202 fixa	Valter Ribeiro	Gestor de Contrato	Obras	valter.ribeiro@gtel-sp.com.br	11 93135-5332	Heber Vidal	Valter Ribeiro	Heber Vidal	Arujá	SP	Industria	Km 203,6, Rod. Pres. Dutra, Bairro - Bairro do Portão, Arujá - SP	https://uploaddeimagens.com.br/images/004/771/984/thumb/Valter_Ribeiro.jpg	2026-06-30 20:32:06.228876+00
67f820bd-1a45-43b5-afdd-be235767402f	Cosan S.A - POLI USP	23985	Valter Ribeiro	Gestor de Contrato	Obras	valter.ribeiro@gtel-sp.com.br	11 93135-5332	Heber Vidal	Valter Ribeiro	Heber Vidal	São Paulo	SP	Industria	\N	https://uploaddeimagens.com.br/images/004/771/984/thumb/Valter_Ribeiro.jpg	2026-06-30 20:32:06.228876+00
3cd31218-10c1-4eb1-bec1-26d0416ff111	UFV AMARANTE I E II	23959	Francisco Araujo	Encarregado Administrativo	Obras	francisco.araujo@gtelsa.com.br	11 97185-5052	Murilo Evangelista	Leticia Petian	Fabio Santana	Amarante	PI	UFV	\N	\N	2026-06-30 20:32:06.228876+00
2daa7df0-42ae-456a-a111-48263e209f95	UFV AMARANTE I E II	23959	Leticia Petian	Gestor de Contrato	Obras	leticia.petian@gtelsa.com.br	17 99216-7989	Fabio Santana	Leticia Petian	Fabio Santana	Amarante	PI	UFV	\N	\N	2026-06-30 20:32:06.228876+00
d5e2ae0d-8bff-4e37-bfc5-5e2d6d6f9320	UFV - ARAPUÁ KROMA	23,698	Ednarte Junior	Encarregado Administrativo	Obras	ednarte.junior@gtelsa.com.br	81 9198-8898	Murilo Evangelista	Jose Garcia	Fabio Santana	Jaguaruana	CE	UFV	\N	https://uploaddeimagens.com.br/images/004/771/995/thumb/ednart.jpg	2026-06-30 20:32:06.228876+00
62c68211-a486-4450-a384-33f7c023e0e0	UFV - ARAPUÁ KROMA	23,698	Jose Garcia	Gestor de Contrato	Obras	jose.garcia@gtel-sp.com.br	\N	Fabio Santana	Jose Garcia	Fabio Santana	Jaguaruana	CE	UFV	\N	\N	2026-06-30 20:32:06.228876+00
af973c98-d7ef-46da-9fe0-554fb407b468	UFV - ARAPUÁ KROMA	23,698	Antonio Neto	Supervisor de  Técnico de Segurança do Trabalho	Obras	antonio.neto@gtel-sp.com.br	92 8436-3235	Vitor Ribeiro	Jose Garcia	Fabio Santana	Jaguaruana	CE	UFV	\N	\N	2026-06-30 20:32:06.228876+00
1d321ad3-436a-4b2a-83bf-ce9100043d87	Rhodia Solvay – Projeto Atlantis	23,558	Carlos Gotard	Gestor de Contrato	Obras	carlos.gotardi@gtelsa.com.br	19 99282-4485	Heber Vidal	Carlos Gotard	Heber Vidal	Paulinia	SP	Industria	\N	\N	2026-06-30 20:32:06.228876+00
62d12dca-8ed7-43f1-b906-c83ff652a3d2	Rhodia Solvay – Projeto Atlantis	23,558	Suellen Uemoto	Auxiliar Administrativo	Obras	Suellen.Uemoto@gtelsa.com.br	11 94135-1897	Murilo Evangelista	Carlos Gotard	Heber Vidal	Paulinia	SP	Industria	\N	\N	2026-06-30 20:32:06.228876+00
40768849-8fef-4c71-a1ad-24eb28bc4d08	UFV Santa Rita de Caldas I e II	24016	Endrio Nascimento	Gestor de Contrato	Obras	endrio.nascimento@gtel-sp.com.br	11 99808-9218	Fabio Santana	Endrio Nascimento	Fabio Santana	Santa Rita de Caldas	MG	UFV	\N	\N	2026-06-30 20:32:06.228876+00
eb4cc9db-d839-40e5-9c62-b9092c259343	UFV Santa Rita de Caldas I e II	24016	Girlan Lacerda	Auxiliar Administrativo	Obras	girlan.lacerda@gtelsa.com.br	11 95554-0382	Murilo Evangelista	Endrio Nascimento	Fabio Santana	Santa Rita de Caldas	MG	UFV	\N	\N	2026-06-30 20:32:06.228876+00
a86f54df-7f46-4600-a626-1b5ef679d1fc	UFV Santa Rita de Caldas I e II	24016	Adário Santos	Encarregado Administrativo	Obras	adario.santos@gtelsa.com.br	12 98891-6678	Murilo Evangelista	Endrio Nascimento	Fabio Santana	Santa Rita de Caldas	MG	UFV	\N	https://uploaddeimagens.com.br/images/004/780/101/thumb/Adario_Santos.jpg	2026-06-30 20:32:06.228876+00
cdb2e6c1-0b95-430e-a2bf-cddb973fe89b	UTE Cuiabá II - Ambar	24314	Fabio Souza	Gestor de Contrato	Obras	fabio.souza@gtel-sp.com.br	11 94216-4789	Heber Vidal	Fabio Souza	Heber Vidal	Cuiabá	MT	Industria	\N	\N	2026-06-30 20:32:06.228876+00
2f0e44dc-5fef-4405-92a5-21113f1d83f5	UTE Cuiabá II - Ambar	24314	Ednarte Junior	Encarregado Administrativo	Obras	ednarte.junior@gtelsa.com.br	81 9198-8898	Murilo Evangelista	Fabio Souza	Heber Vidal	Cuiabá	MT	Industria	\N	https://uploaddeimagens.com.br/images/004/771/995/thumb/ednart.jpg	2026-06-30 20:32:06.228876+00
09c64002-4f07-4e3f-a6c9-28287c673712	Syngenta - Guarda Chuva	23898	Fabio Souza	Gestor de Contrato	Obras	fabio.souza@gtel-sp.com.br	11 94216-4789	Heber Vidal	Fabio Souza	Heber Vidal	Paulinia	SP	Industria	\N	\N	2026-06-30 20:32:06.228876+00
dd0f4663-20a2-4a48-b5bc-76fe974dcc5c	Syngenta - Guarda Chuva	23898	Andressa Garcia	Assistente Administrativo	Obras	andressa.garcia@gtelsa.com.br	11 99687-1646	Murilo Evangelista	Fabio Souza	Heber Vidal	Paulinia	SP	Industria	\N	\N	2026-06-30 20:32:06.228876+00
d71d203c-4085-429e-8ec7-da16e50880dd	Syngenta - Guarda Chuva	23898	Vinicius  Bizelli	Engenheiro	Obras	vinicius.bizelli@gtelsa.com.br	11 94255-6124	Heber Vidal	Fabio Souza	Heber Vidal	Paulinia	SP	Industria	\N	\N	2026-06-30 20:32:06.228876+00
0a695278-a893-4008-be17-0f0cccab5b5d	YPE Salto FabrLiq	24,104	Andre Branco	Encarregado Administrativo	Obras	andre.branco@gtelsa.com.br	11 91255-8556	Murilo Evangelista	Sandro Costa	Heber Vidal	Salto	SP	Industria	\N	\N	2026-06-30 20:32:06.228876+00
75cd1ab7-9ed0-4bae-b0a3-564123ad5657	YPE Salto FabrLiq	24,104	Jeziel Assis	Assistente Administrativo	Obras	jeziel.assis@gtelsa.com.br	11 912560016	Murilo Evangelista	Sandro Costa	Heber Vidal	Salto	SP	Industria	\N	https://uploaddeimagens.com.br/images/004/774/633/thumb/jeziel.jpg	2026-06-30 20:32:06.228876+00
27104d15-fb5b-43b9-8f22-22e4e0313451	YPE Salto FabrLiq	24,104	Sandro Costa	Gestor de Contrato	Obras	sandro.costa@gtel-sp.com.br	24 99211-6868	Heber Vidal	Sandro Costa	Heber Vidal	Salto	SP	Industria	\N	https://uploaddeimagens.com.br/images/004/780/103/thumb/Sandro_Costa.jpg	2026-06-30 20:32:06.228876+00
0f57ae94-0649-4949-a44f-2e5d90d8d038	Sede	100	Berenice M Silva	Controller / Responsável RH / DP / Contabilidade / Financeiro / Fiscal / Faturamento	Sede	berenice.mazetto@gtelsa.com.br	11 97341-2350	Saulo Honma	\N	\N	São Paulo	SP	\N	Rua Acurui 531 - Vila Formosa - São Paulo SP - CEP 03355-000	\N	2026-06-30 20:32:06.228876+00
16ee1fdc-6b18-429d-ac86-26a161b99c4c	Sede	100	Vitor Ribeiro	Coordenador de Segurança do Trabalho	Sede	vitor.ribeiro@gtel-sp.com.br	11 93135-0593	Heber Vidal	\N	\N	São Paulo	SP	\N	Rua Acurui 531 - Vila Formosa - São Paulo SP - CEP 03355-000	\N	2026-06-30 20:32:06.228876+00
0a193792-8b2d-4b90-8810-68402175a2b8	Sede	100	Murilo Evangelista	Coordenador Administrativo	Sede	murilo.evangelista@gtel-sp.com.br	11 99687-1701	Heber Vidal	\N	\N	São Paulo	SP	\N	Rua Acurui 531 - Vila Formosa - São Paulo SP - CEP 03355-000	https://uploaddeimagens.com.br/images/004/771/895/thumb/Murilo_Germano.jpg	2026-06-30 20:32:06.228876+00
186f6b51-a0b3-47a5-98bd-0791927eebd6	sede	100	Fabio Santana	Gerente de Contratos	Obras	fabio.santana@gtel-sp.com.br	77 9812-4112	Heber Vidal	\N	\N	São Paulo	SP	\N	Rua Acurui 531 - Vila Formosa - São Paulo SP - CEP 03355-000	\N	2026-06-30 20:32:06.228876+00
8ac92842-d99e-452e-a639-62a247e302f6	sede	100	Marcelo Santana	Encarregado de DP / Folha de Pagamento	Sede	marcelo.santana@gtelsa.com.br	11 94121-5771	Berenice M Silva	\N	\N	São Paulo	SP	\N	Rua Acurui 531 - Vila Formosa - São Paulo SP - CEP 03355-000	\N	2026-06-30 20:32:06.228876+00
1837198a-d78c-4927-a694-93d41baf928c	sede	100	Leonardo Brito	DP /Responsável Ponto / Demissão / Férias	Sede	leonardo.brito@gtelsa.com.br	11 94121-5771	Berenice M Silva	\N	\N	São Paulo	SP	\N	Rua Acurui 531 - Vila Formosa - São Paulo SP - CEP 03355-000	\N	2026-06-30 20:32:06.228876+00
75df37c8-0ba7-453a-8ff8-2d31dead0657	sede	100	Vitória Amaral	RH / Responsavel Recrutamento e Seleção de Talentos	Sede	vitória.amaral@gtelsa.com.br	11 94121-5771	Berenice M Silva	\N	\N	São Paulo	SP	\N	Rua Acurui 531 - Vila Formosa - São Paulo SP - CEP 03355-000	\N	2026-06-30 20:32:06.228876+00
74ca86fa-6051-4a44-a58c-7a40a9c9b598	sede	100	David Pereira	Encarregado de Compras	sede	david.pereira@gtelsa.com.br	11 97179-0206	Heber Vidal	\N	\N	São Paulo	SP	\N	Rua Acurui 531 - Vila Formosa - São Paulo SP - CEP 03355-000	\N	2026-06-30 20:32:06.228876+00
ea1d8c70-aca3-45f8-8894-64c5d05487fb	sede	100	Paula Batista	Compras / Responsável por Elaboração de pedido de Compras /Contratos de Locação de Imóveis	sede	paula.batista@gtelsa.com.br	11 97179-0206	David Pereira	\N	\N	São Paulo	SP	\N	Rua Acurui 531 - Vila Formosa - São Paulo SP - CEP 03355-000	\N	2026-06-30 20:32:06.228876+00
d27e5ad8-16ad-4ecc-b678-ec191c5a6c43	sede	100	Talita Costa	Compras / Responsável por Elaboração de pedido de Compras	sede	talita.costa@gtel-sp.com.br	11 97179-0206	David Pereira	\N	\N	São Paulo	SP	\N	Rua Acurui 531 - Vila Formosa - São Paulo SP - CEP 03355-000	\N	2026-06-30 20:32:06.228876+00
2dac2f1c-8b7a-413b-8605-6ca0c6ec0e24	sede	100	Gisele Oliveira	Compras / Responsável por Elaboração de pedido de Compras	sede	giselle.oliveira@gtel-sp.com.br	11 97179-0206	David Pereira	\N	\N	São Paulo	SP	\N	Rua Acurui 531 - Vila Formosa - São Paulo SP - CEP 03355-000	\N	2026-06-30 20:32:06.228876+00
d520dfda-fc4b-4922-a3d8-6477e5765249	sede	100	Carlos Souza	Planejamento / Planejamento e Controle de Projetos	sede	carlos.souza@gtelsa.com.br	11 99885-4684	Heber Vidal	\N	\N	São Paulo	SP	\N	Rua Acurui 531 - Vila Formosa - São Paulo SP - CEP 03355-000	\N	2026-06-30 20:32:06.228876+00
1c3791ac-3dcb-4c93-b8b9-9c9f9cd63418	sede	100	Roberto Junior	Planejamento / Planejamento e Controle de Projetos	sede	roberto.junior@gtelsa.com.br	11 98588-9881	Heber Vidal	\N	\N	São Paulo	SP	\N	Rua Acurui 531 - Vila Formosa - São Paulo SP - CEP 03355-000	\N	2026-06-30 20:32:06.228876+00
dffa70c2-9492-40bd-b8d3-7eb8d467faa9	sede	100	Amanda  Gainete	Passagens / Hospedagens / Locação de Veículo	sede	amanda.gainete@gtelsa.com.br	11 2672-6440	Heber Vidal	\N	\N	São Paulo	SP	\N	Rua Acurui 531 - Vila Formosa - São Paulo SP - CEP 03355-000	\N	2026-06-30 20:32:06.228876+00
da5a6c16-25d4-4404-bc60-0842027aa2ab	sede	100	Sandro Alves	Gestor SGI / Qualidade	sede	sandro.alves@gtel-sp.com.br	11 98773-7594	Heber Vidal	\N	\N	São Paulo	SP	\N	Rua Acurui 531 - Vila Formosa - São Paulo SP - CEP 03355-000	\N	2026-06-30 20:32:06.228876+00
8407816c-eaa6-45b5-8a71-9a30258e986d	sede	100	Suporte T.I	Tecnologia da Informação	sede	suporte.ti@gtel-sp.com.br	11 2672-6400	Antonio Padovani	\N	\N	São Paulo	SP	\N	Rua Acurui 531 - Vila Formosa - São Paulo SP - CEP 03355-000	\N	2026-06-30 20:32:06.228876+00
d274f847-0413-4e92-8606-4ec7f5cf6592	sede	100	Antonio Padovani	Diretor de Orçamentos e Custos	sede	antonio.padovani@gtel-sp.com.br	11 9 9628-6071	\N	\N	\N	São Paulo	SP	\N	Rua Acurui 531 - Vila Formosa - São Paulo SP - CEP 03355-000	\N	2026-06-30 20:32:06.228876+00
b43b2fd3-bdf5-4f78-b29b-ee2d39819748	sede	100	Vitor Oliveira	Tecnologia da Informação	sede	vitor.oliveira@gtelsa.com.br	11 95772-0764	Antonio Padovani	\N	\N	São Paulo	SP	\N	Rua Acurui 531 - Vila Formosa - São Paulo SP - CEP 03355-000	\N	2026-06-30 20:32:06.228876+00
e9d6a1cb-3623-481c-a0a6-f86d8e2280c4	sede	100	Rivânia Silva	Financeiro	Sede	rivania.silva@gtelsa.com.br	11 97341-2350	Berenice M Silva	\N	\N	São Paulo	SP	\N	Rua Acurui 531 - Vila Formosa - São Paulo SP - CEP 03355-000	\N	2026-06-30 20:32:06.228876+00
a08f14a4-b413-4f08-8dca-7bb53801e4ae	sede	100	Marcelo Carvalho	Controladoria	Sede	marcelo.carvalho@gtelsa.com.br	11 97341-2350	Berenice M Silva	\N	\N	São Paulo	SP	\N	Rua Acurui 531 - Vila Formosa - São Paulo SP - CEP 03355-000	\N	2026-06-30 20:32:06.228876+00
cad78cc8-1c6f-4076-b51e-705b5acee9da	sede	100	Jose Junior	Departamento Fiscal	Sede	jose.junior@gtelsa.com.br	11 97341-2350	Berenice M Silva	\N	\N	São Paulo	SP	\N	Rua Acurui 531 - Vila Formosa - São Paulo SP - CEP 03355-000	\N	2026-06-30 20:32:06.228876+00
bc797f52-68f8-4c65-bccc-36b486eb5041	sede	100	Vinicius Rissi	Projetos	Sede	vinicius.rissi@gtelsa.com.br	11 97341-2350	Antonio Padovani	\N	\N	São Paulo	SP	\N	Rua Acurui 531 - Vila Formosa - São Paulo SP - CEP 03355-000	\N	2026-06-30 20:32:06.228876+00
8a2ea3c2-58ed-44bf-b6d1-1bd42781ed84	sede	100	Vinicius Costa	Departamento Contábil	Sede	vinicius.costa@gtelsa.com.br	11 97341-2350	Berenice M Silva	\N	\N	São Paulo	SP	\N	Rua Acurui 531 - Vila Formosa - São Paulo SP - CEP 03355-000	\N	2026-06-30 20:32:06.228876+00
ebdcf54d-3637-457f-9fc5-212110e2da8a	sede	100	Poliana Santos	Departamento Contábil	Sede	poliana.santos@gtelsa.com.br	11 97341-2350	Berenice M Silva	\N	\N	São Paulo	SP	\N	Rua Acurui 531 - Vila Formosa - São Paulo SP - CEP 03355-000	\N	2026-06-30 20:32:06.228876+00
ae0be637-c5b0-448d-a3f3-f1de2796e83d	sede	100	Mariana Cardona	Departamento Fiscal	Sede	mariana.cardona@gtelsa.com.br	11 97341-2350	Berenice M Silva	\N	\N	São Paulo	SP	\N	Rua Acurui 531 - Vila Formosa - São Paulo SP - CEP 03355-000	\N	2026-06-30 20:32:06.228876+00
3dfdbe3f-8ac4-43df-9bd6-5ad2b11f270b	sede	100	Drielly Pinheiro	Departamento Contábil	Sede	drielly.pinheiro@gtelsa.com.br	11 97341-2350	Berenice M Silva	\N	\N	São Paulo	SP	\N	Rua Acurui 531 - Vila Formosa - São Paulo SP - CEP 03355-000	\N	2026-06-30 20:32:06.228876+00
1217ea7b-f529-41b9-bb2c-7f5f7cd75a79	sede	100	Saulo Honma	Sócio Diretor / Diretoria Administrativa & Financeira	Sede	saulo.honma@gtelsa.com.br	11 2672 6400	\N	\N	\N	São Paulo	SP	\N	Rua Acurui 531 - Vila Formosa - São Paulo SP - CEP 03355-000	\N	2026-06-30 20:32:06.228876+00
d271c38d-8519-4bf1-bfbb-78257a5c7195	sede	100	Rafael Perrella	Sócio Diretor / Gerencia de Contratos	Sede	rafael.perrella@gtelsa.com.br	11 2672 6400	\N	\N	\N	São Paulo	SP	\N	Rua Acurui 531 - Vila Formosa - São Paulo SP - CEP 03355-000	\N	2026-06-30 20:32:06.228876+00
6df89f90-18bd-44e3-ae46-3cb48a04861f	sede	100	Talita Fernandes	Financeiro	Sede	talita.fernandes@gtelsa.com.br	11 97341-2350	Berenice M Silva	\N	\N	São Paulo	SP	\N	Rua Acurui 531 - Vila Formosa - São Paulo SP - CEP 03355-000	\N	2026-06-30 20:32:06.228876+00
55ef204a-fa9b-47a6-97dc-e18964df5230	sede	100	Roberto Sousa	Orçamentos e Projetos	Sede	roberto.sousa@gtelsa.com.br	11 2672-6423	Antonio Padovani	\N	\N	São Paulo	SP	\N	Rua Acurui 531 - Vila Formosa - São Paulo SP - CEP 03355-000	\N	2026-06-30 20:32:06.228876+00
e0610747-01c8-461d-9a98-533c9d827234	sede	101	Stives Silva	Almoxarifado Central	Sede	almoxarifado@gtel-sp.com.br	11 93135 0850	Rafael Perrella	\N	\N	São Paulo	SP	\N	Rua Tres Martelos, 161 – Chácara California - São Paulo – SP Cep 03406-110	\N	2026-06-30 20:32:06.228876+00
c6fdc3a0-de33-4731-a1b8-e623c5a60e09	sede	100	Monica Santos	Apoio Orçamentos	sede	monica.santos@gtelsa.com.br	11 2672 6400	Antonio Padovani	\N	\N	São Paulo	SP	\N	Rua Acurui 531 - Vila Formosa - São Paulo SP - CEP 03355-000	\N	2026-06-30 20:32:06.228876+00
91b2840d-c567-4390-b1f6-3dd43562f1e3	sede	100	Rogerio Candido	Orçamentos e Projetos	sede	rogério.candido@gtelsa.com.br	11 2672 6400	Antonio Padovani	\N	\N	São Paulo	SP	\N	Rua Acurui 531 - Vila Formosa - São Paulo SP - CEP 03355-000	\N	2026-06-30 20:32:06.228876+00
785c2b0e-a8f3-47a0-9bd6-b791660292ce	sede	100	Luciana Nasorri	Orçamentos e Projetos	sede	luciana.nasorri@gtelsa.com.br	11 2672 6400	Antonio Padovani	\N	\N	São Paulo	SP	\N	Rua Acurui 531 - Vila Formosa - São Paulo SP - CEP 03355-000	\N	2026-06-30 20:32:06.228876+00
b3b56d65-fbbf-4fe4-9314-2ac75f3672b6	sede	100	Wilson Shinoda	Orçamentos e Projetos	sede	wilson.shinoda@gtelsa.com.br	11 2672 6400	Antonio Padovani	\N	\N	São Paulo	SP	\N	Rua Acurui 531 - Vila Formosa - São Paulo SP - CEP 03355-000	\N	2026-06-30 20:32:06.228876+00
9972e0de-b52e-4855-85c4-cfbd9a0d1145	sede	100	Ronald Freitas	Orçamentos e Projetos	sede	ronald.freitas@gtelsa.com.br	11 2672 6400	Antonio Padovani	\N	\N	São Paulo	SP	\N	Rua Acurui 531 - Vila Formosa - São Paulo SP - CEP 03355-000	\N	2026-06-30 20:32:06.228876+00
e96e9ccf-0d7b-4578-8a7c-2efb947e68b5	sede	100	Fernando Oliveira	Projetista	sede	fernando.oliveira@gtelsa.com.br	11 2672 6400	\N	\N	\N	São Paulo	SP	\N	Rua Acurui 531 - Vila Formosa - São Paulo SP - CEP 03355-000	\N	2026-06-30 20:32:06.228876+00
a157b6d6-58c5-4b35-91a8-55b648c66839	sede	100	Igor Fidelis	Compras	Sede	igor.fidelis@gtelsa.com.br	11 2672 6458	David Pereira	\N	\N	São Paulo	SP	\N	Rua Acurui 531 - Vila Formosa - São Paulo SP - CEP 03355-000	\N	2026-06-30 20:32:06.228876+00
2b6f6cfe-6f3c-4a98-89bc-bc120b7b9bf7	sede	100	Alex Carvalho	Compras	Sede	alex.carvalho@gtel-sp.com.br	11 97452-0043	David Pereira	\N	\N	São Paulo	SP	\N	Rua Acurui 531 - Vila Formosa - São Paulo SP - CEP 03355-000	\N	2026-06-30 20:32:06.228876+00
efc91b39-0f90-4810-a961-d2264019291c	sede	100	Leticia Prado	Técnico de Segurança do trabalho	Sede	leticia.oliveira@gtelsa.com.br	(11) 93713-9363	Vitor Ribeiro	\N	\N	São Paulo	SP	\N	Rua Acurui 531 - Vila Formosa - São Paulo SP - CEP 03355-000	\N	2026-06-30 20:32:06.228876+00
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
a999f677-cd94-426b-859d-7f6b9f64bc66	24178	SYNGENTA PROTECAO DE CULTIVOS LTDA	\N	\N	4489b3ec-6774-4a13-bc24-31b77deb6ae7	2026-06-03 12:54:08.276	24178
fecd46b3-7f55-4fa2-b0f6-02e351793a4f	24128	COAMO AGROINDUSTRIAL COOPERATIVA	Campo Mourão	PR	4489b3ec-6774-4a13-bc24-31b77deb6ae7	2026-06-03 12:54:08.276	24128
ae387bdc-cf9e-4d3a-ad30-5a16e85801bc	24314	UTE Cuiabá II - Ambar	Cuiabá	MT	4489b3ec-6774-4a13-bc24-31b77deb6ae7	2026-06-30 19:45:27.045831	24314
\.


--
-- Data for Name: passagens; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.passagens (id, seq, crd, funcionario_id, nome_completo, data_nascimento, funcao, rg, cpf, tipo_viagem, folga_a_cada_dias, aereo_data_solicitacao, aereo_data_ida, aereo_hora_ida_entre, aereo_data_volta, aereo_hora_volta_entre, aereo_origem_ida, aereo_destino_ida, aereo_bagagem, aereo_origem_volta, aereo_destino_volta, aereo_observacoes, terr_data_solicitacao, terr_data_ida, terr_data_volta, terr_observacoes, terr_origem_ida_1, terr_hora_ida_1, terr_destino_ida_1a, terr_hora_destino_ida_1a, terr_destino_ida_1b, terr_hora_destino_ida_1b, terr_origem_ida_2, terr_hora_ida_2, terr_destino_ida_2a, terr_hora_destino_ida_2a, terr_destino_ida_2b, terr_hora_destino_ida_2b, terr_origem_volta_1, terr_hora_volta_1, terr_destino_volta_1a, terr_hora_destino_volta_1a, terr_destino_volta_1b, terr_hora_destino_volta_1b, terr_origem_volta_2, terr_hora_volta_2, terr_destino_volta_2a, terr_hora_destino_volta_2a, terr_destino_volta_2b, terr_hora_destino_volta_2b, loc_data_retirada, loc_hora_retirada_entre, loc_cidade_retirada, loc_observacoes, loc_data_entrega, loc_hora_entrega_entre, loc_km, loc_tipo_locacao, loc_tipo_veiculo, hosp_data_checkin, hosp_hora_checkin_entre, hosp_cidade, hosp_data_checkout, hosp_hora_checkout_entre, hosp_hotel_referencia, hosp_faturar_1, hosp_faturar_2, hosp_faturar_3, hosp_tipo_quarto, observacoes_gerais, status, obra_id, created_at, updated_at) FROM stdin;
28306871-3877-4d83-a27a-7dfcfe98a97c	3	24104	e3975bc7-b7a1-417c-bc6c-7d4a71e4714d	ADRIANA VELOSO ROSA	\N	AUXILIAR DE SERVICOS GERAIS	\N	\N	folga	90	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	pendente	0ea37ce8-5f9d-4270-ac46-73e6c169c6d2	2026-06-25 20:17:32.203703+00	2026-06-25 20:17:32.083+00
\.


--
-- Data for Name: prestadores; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.prestadores (id, obra_id, razao_social, cnpj, nome_fantasia, nome_completo, funcao, data_mobilizacao, data_integracao, alojamento_id, situacao, observacao, created_at, foto_url) FROM stdin;
86225441-5b33-4b23-9f6a-02b022db2cb9	0d899f11-785d-4edd-a951-bac82fae074f	EDES ANTONIO RICIERI JUNIOR	52.649.722/0001-75	EDES ANTONIO RICIERI JUNIOR	EDES ANTONIO RICIERI JUNIOR	TÈCNICO DE QUALIDADE	\N	\N	\N	ativo	\N	2026-06-18 21:46:05.998067+00	https://lqggoshphakeuufibdno.supabase.co/storage/v1/object/public/funcionarios/prestadores/1781819839920.png
a9be3556-e9e7-4e7f-8cbc-f13d97d998d6	25341e31-cd60-4743-ad1b-658397ec5d72	DANIEL COSTA FREIRE	31941961000124	N1 PROJETOS	DANIEL COSTA FREIRE	ENGENHEIRO MECANICO	2025-04-01	\N	\N	ativo	\N	2026-06-27 16:37:17.780488+00	\N
71e16ba7-05af-48a1-b162-57f974b3f022	25341e31-cd60-4743-ad1b-658397ec5d72	GK NUNES INSTALAÇÕES ELETRICAS LTDA	49823903000161	GK NUNES	ANTONIO LUIZ ALVES DE BARROS	ELETRICISTA MONTADOR	2026-04-10	\N	\N	ativo	\N	2026-06-27 17:15:18.083731+00	\N
b9957e6c-d19a-4ff3-9ea9-e0f5273894e0	25341e31-cd60-4743-ad1b-658397ec5d72	GK NUNES INSTALAÇÕES ELETRICAS LTDA	49823903000161	GK NUNES	ARLAN NUNES SANTOS	ELETRICISTA MONTADOR	2026-05-11	\N	\N	ativo	\N	2026-06-27 17:19:05.841387+00	\N
46c052e2-b2a5-4af9-9416-43fc48963650	25341e31-cd60-4743-ad1b-658397ec5d72	GK NUNES INSTALAÇÕES ELETRICAS LTDA	49823903000161	GK NUNES	CARLOS HENRIQUE SILVA SANTOS	ELETRICISTA MONTADOR	2025-06-10	\N	\N	ativo	\N	2026-06-27 17:20:15.519575+00	\N
98ab34fb-7147-489d-8dae-b138cd3cda6b	25341e31-cd60-4743-ad1b-658397ec5d72	GK NUNES INSTALAÇÕES ELETRICAS LTDA	49823903000161	GK NUNES	CELSO MAURO DOS SANTOS BENTES	ELETRICISTA MONTADOR	2026-04-07	\N	\N	ativo	\N	2026-06-27 17:21:02.564034+00	\N
74f0c687-e006-4d46-9e5c-55075408231e	25341e31-cd60-4743-ad1b-658397ec5d72	GK NUNES INSTALAÇÕES ELETRICAS LTDA	49823903000161	GK NUNES	DOMINGOS EMERSON LUCAS DA SILVA	ELETRICISTA MONTADOR	2026-06-29	\N	\N	ativo	\N	2026-06-27 17:21:47.864484+00	\N
ccc503bd-7061-4b7e-8bfb-16dec9ed8b39	25341e31-cd60-4743-ad1b-658397ec5d72	GK NUNES INSTALAÇÕES ELETRICAS LTDA	49823903000161	GK NUNES	GUSTAVO KUCHMA NUNES	ELETRICISTA ENCARREGADO	2025-06-09	\N	\N	ativo	\N	2026-06-27 17:24:00.594863+00	\N
94373901-b862-4f14-80f7-96ca8ffbbb12	25341e31-cd60-4743-ad1b-658397ec5d72	GK NUNES INSTALAÇÕES ELETRICAS LTDA	49823903000161	GK NUNES	KARLOS RYAN NUNES DOS SANTOS	ELETRICISTA MONTADOR	2026-05-08	\N	\N	ativo	\N	2026-06-27 17:24:53.488783+00	\N
2ca5175a-d7c0-47e8-94dc-c939fbbd0ac7	25341e31-cd60-4743-ad1b-658397ec5d72	GK NUNES INSTALAÇÕES ELETRICAS LTDA	49823903000161	GK NUNES	LEANDRO ANTONIO COLAÇO	ELETRICISTA MONTADOR	2026-06-19	\N	\N	ativo	\N	2026-06-27 17:25:37.101969+00	\N
2c63095f-191c-4cb3-9d93-912113a74512	25341e31-cd60-4743-ad1b-658397ec5d72	GK NUNES INSTALAÇÕES ELETRICAS LTDA	49823903000161	GK NUNES	RANIEL PEDRO CIRIACO DA SILVA	ELETRICISTA MONTADOR	2025-09-17	\N	\N	ativo	\N	2026-06-27 17:26:22.823839+00	\N
2abfec7d-d822-4ad0-b9bb-38a92d37e157	25341e31-cd60-4743-ad1b-658397ec5d72	GK NUNES INSTALAÇÕES ELETRICAS LTDA	49823903000161	GK NUNES	RONALDO ANTONIO DA SILVA JUNIOR	ELETRICISTA MONTADOR	2025-08-04	\N	\N	ativo	\N	2026-06-27 17:27:02.03101+00	\N
1f3676e6-80fd-458f-8ee7-bb8795fb33a4	25341e31-cd60-4743-ad1b-658397ec5d72	GK NUNES INSTALAÇÕES ELETRICAS LTDA	49823903000161	GK NUNES	VALDICH FERREIRA NUNES	ELETRICISTA MONTADOR	2024-03-25	\N	\N	ativo	\N	2026-06-27 17:27:41.036436+00	\N
b2b28535-2d74-41b1-9e03-65cdc5e7a958	25341e31-cd60-4743-ad1b-658397ec5d72	FABIO SANTANA	95290451315	FABIO SANTANA	FABIO SANTANA	GESTOR DE CONTRATO	2026-03-24	\N	\N	ativo	\N	2026-06-27 17:53:53.639865+00	\N
f1686c76-aa3f-46b1-88ad-61e4e29db4ab	25341e31-cd60-4743-ad1b-658397ec5d72	GK NUNES INSTALAÇÕES ELETRICAS LTDA	49823903000161	GK NUNES	EVERTON AUGUSTO COLAÇO	ELETRICISTA MONTADOR	2026-06-10	\N	\N	ativo	\N	2026-07-06 11:56:18.42387+00	\N
f91e82e2-5290-4f4a-b069-91fafdede2d6	25341e31-cd60-4743-ad1b-658397ec5d72	GK NUNES INSTALAÇÕES ELETRICAS LTDA	49823903000161	GK NUNES	ALECIO FARIA BENTO	ELETRICISTA MONTADOR	2026-07-06	2026-07-07	\N	ativo	\N	2026-07-07 09:46:23.157006+00	\N
\.


--
-- Data for Name: prestadores_presenca; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.prestadores_presenca (id, prestador_id, data, situacao) FROM stdin;
a97818d4-5cd4-491a-b414-cd7f7dc7f886	74f0c687-e006-4d46-9e5c-55075408231e	2026-06-18	AUSENTE
88e97822-b87b-4ca4-8e1b-ea2ee2c75061	71e16ba7-05af-48a1-b162-57f974b3f022	2026-06-18	AUSENTE
4462324f-e516-4424-a81e-dfd82045dc1f	98ab34fb-7147-489d-8dae-b138cd3cda6b	2026-06-18	AUSENTE
76a0f90c-ca24-4fd6-8f9f-fcb706ee3199	a9be3556-e9e7-4e7f-8cbc-f13d97d998d6	2026-06-18	AUSENTE
de15dd1e-b2c8-4a30-b00e-7aed59993d0f	2ca5175a-d7c0-47e8-94dc-c939fbbd0ac7	2026-06-18	AUSENTE
4bd69bb7-1e43-4d2d-a957-d431e3e8ea51	b2b28535-2d74-41b1-9e03-65cdc5e7a958	2026-06-18	AUSENTE
dc332bbd-e954-4a4d-951f-85fe5ae199a8	2ca5175a-d7c0-47e8-94dc-c939fbbd0ac7	2026-06-27	AUSENTE
b2739eeb-12d6-485b-800c-3251526771a0	b2b28535-2d74-41b1-9e03-65cdc5e7a958	2026-06-27	AUSENTE
7b296a13-9264-4525-bd5d-8bb121940b76	74f0c687-e006-4d46-9e5c-55075408231e	2026-06-27	AUSENTE
53a4a1b5-7c37-4c81-9f58-0f6f7b5eb7b6	a9be3556-e9e7-4e7f-8cbc-f13d97d998d6	2026-06-27	AUSENTE
ea5252ec-5198-423f-9fa9-d10f3586b2b0	98ab34fb-7147-489d-8dae-b138cd3cda6b	2026-06-27	AUSENTE
4e432a46-47e5-41fa-92fb-70e160b87e56	71e16ba7-05af-48a1-b162-57f974b3f022	2026-06-27	AUSENTE
864b0c00-f779-4e70-90eb-391eba2bb962	ccc503bd-7061-4b7e-8bfb-16dec9ed8b39	2026-07-06	AUSENTE
4285d1c1-ad7d-402c-81ff-17c502734863	98ab34fb-7147-489d-8dae-b138cd3cda6b	2026-07-06	AUSENTE
3d6a9eee-9a50-4096-b882-48fc928508d2	71e16ba7-05af-48a1-b162-57f974b3f022	2026-07-06	AUSENTE
e458e436-3521-4374-b605-3cef69019460	f91e82e2-5290-4f4a-b069-91fafdede2d6	2026-07-07	AUSENTE
78ba820a-7d74-491c-abf3-b66b7bd39e06	71e16ba7-05af-48a1-b162-57f974b3f022	2026-07-07	AUSENTE
cf5e5416-bdf1-4a09-a342-a29166bfcec9	98ab34fb-7147-489d-8dae-b138cd3cda6b	2026-07-07	AUSENTE
\.


--
-- Data for Name: treinamentos; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.treinamentos (id, funcionario_id, tipo, nr_codigo, categoria_cnh, nome_treinamento, data_realizacao, periodicidade_meses, vencimento_manual, data_vencimento, observacao, created_at) FROM stdin;
7b503020-d5f0-4c4a-8124-e42ad6b0f751	f4f5e0c6-a407-471e-9cbe-1c9411c62567	NR	NR-06	\N	\N	2025-02-27	24	f	2027-02-27	\N	2026-07-03 01:42:55.891168+00
5eaf302e-eb45-4487-acac-f8ef406ce321	f4f5e0c6-a407-471e-9cbe-1c9411c62567	NR	NR-18	\N	\N	2025-02-28	24	f	2027-02-28	\N	2026-07-03 01:43:51.894738+00
08c40273-7aea-4256-add3-6c4e42daf443	f4f5e0c6-a407-471e-9cbe-1c9411c62567	ASO	\N	\N	Peródico	2026-02-25	\N	t	2027-02-25	\N	2026-07-03 01:47:50.603853+00
1e6ceb6f-83b0-4ccf-af5e-9b0f01e33cb4	f4f5e0c6-a407-471e-9cbe-1c9411c62567	CNH	\N	AD	\N	2024-01-12	\N	t	2034-01-10	\N	2026-07-03 01:49:29.064543+00
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
d2c09876-6641-45f8-88cc-776e35744711	Cauan Aquino	Cauan Aquino	234030	usuario	{}	t	2026-06-25 11:58:55.758549+00	["25341e31-cd60-4743-ad1b-658397ec5d72"]
3e986fa4-e0bf-4870-b2e4-3070d562484e	Levy Amorim	Levy Amorim	241280	usuario	{}	t	2026-06-25 12:00:13.992275+00	["fecd46b3-7f55-4fa2-b0f6-02e351793a4f"]
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
20260616120000	2026-07-08 01:10:01
20260624120000	2026-07-08 01:10:01
20260626120000	2026-07-08 01:10:02
20260706120000	2026-07-08 01:10:02
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
fornecedores	fornecedores	\N	2026-07-07 14:47:18.491237+00	2026-07-07 14:47:18.491237+00	t	f	\N	\N	\N	STANDARD
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
23b3e6d6-9bde-4fc1-ad2c-a7e6d6a22d52	alojamentos	fotos/1782570107865_foto.zip	\N	2026-06-27 14:22:32.195567+00	2026-06-27 14:22:32.195567+00	2026-06-27 14:22:32.195567+00	{"eTag": "\\"b42f53fa7e3fc8ac327461ac60bc7d4f-2\\"", "size": 25304516, "mimetype": "application/x-zip-compressed", "cacheControl": "max-age=3600", "lastModified": "2026-06-27T14:22:32.000Z", "contentLength": 25304516, "httpStatusCode": 200}	3914af3e-24e3-44ba-97b6-712583df9c2f	\N	{}
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
25757b30-7196-47ba-a2a3-c14b5018df72	alojamentos	fotos/1782570125450_foto.zip	\N	2026-06-27 14:22:43.026049+00	2026-06-27 14:22:43.026049+00	2026-06-27 14:22:43.026049+00	{"eTag": "\\"b42f53fa7e3fc8ac327461ac60bc7d4f-2\\"", "size": 25304516, "mimetype": "application/x-zip-compressed", "cacheControl": "max-age=3600", "lastModified": "2026-06-27T14:22:43.000Z", "contentLength": 25304516, "httpStatusCode": 200}	317697ae-7b7f-490e-bf68-39712e66c7ed	\N	{}
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
26901275-5f38-4dee-b727-ffa7f2565e4d	alojamentos	fotos/1782570125883_foto.zip	\N	2026-06-27 14:22:46.247901+00	2026-06-27 14:22:46.247901+00	2026-06-27 14:22:46.247901+00	{"eTag": "\\"b42f53fa7e3fc8ac327461ac60bc7d4f-2\\"", "size": 25304516, "mimetype": "application/x-zip-compressed", "cacheControl": "max-age=3600", "lastModified": "2026-06-27T14:22:45.000Z", "contentLength": 25304516, "httpStatusCode": 200}	a1c29c89-78e5-42bb-b522-df037bc1d868	\N	{}
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
8fc6d46c-9847-41a7-be80-451a0a321daf	alojamentos	contratos/1782570570288_24104-011_-_JULIANA_CRISTINA_X_GTEL_-_RUA_PAU_BRASIL,_132.pdf	\N	2026-06-27 14:29:33.924053+00	2026-06-27 14:29:33.924053+00	2026-06-27 14:29:33.924053+00	{"eTag": "\\"793dd76cc12e7bce10d6f62b6edb96b3\\"", "size": 2296826, "mimetype": "application/pdf", "cacheControl": "max-age=3600", "lastModified": "2026-06-27T14:29:34.000Z", "contentLength": 2296826, "httpStatusCode": 200}	cb155610-f8a6-4946-9ddb-df87501e171b	\N	{}
d717b596-9fc0-42d1-acce-06ba57507a73	funcionarios	fotos/1781698997817.jpg	\N	2026-06-17 12:23:18.136903+00	2026-06-17 12:23:18.136903+00	2026-06-17 12:23:18.136903+00	{"eTag": "\\"6d5b6bd4d130c70a63c604d50fb17e4b\\"", "size": 41531, "mimetype": "image/jpeg", "cacheControl": "max-age=3600", "lastModified": "2026-06-17T12:23:19.000Z", "contentLength": 41531, "httpStatusCode": 200}	c579e0c4-3c3b-4837-a650-9ebaadd4f4d6	\N	{}
737e2804-e6e5-455c-9c10-71462a27b5cb	alojamentos	contratos/1781784551934_24104-004_-_CONTRATO_COSTA_ROCHAXGTEL_-_RUA_COSTA_RICA,_604.pdf	\N	2026-06-18 12:09:17.172248+00	2026-06-18 12:09:17.172248+00	2026-06-18 12:09:17.172248+00	{"eTag": "\\"c1d7539d31c0e8bb49223c1f02a74a3e\\"", "size": 6549634, "mimetype": "application/pdf", "cacheControl": "max-age=3600", "lastModified": "2026-06-18T12:09:18.000Z", "contentLength": 6549634, "httpStatusCode": 200}	7716f0d2-ea50-4599-9859-f60e56e1cf3b	\N	{}
40c0f3c4-ffa9-4d71-9b7e-5f8afa8c2f63	funcionarios	fotos/1781699105821.jpg	\N	2026-06-17 12:25:06.222575+00	2026-06-17 12:25:06.222575+00	2026-06-17 12:25:06.222575+00	{"eTag": "\\"b2c578c1bf2ac94b8b947af35de3897c\\"", "size": 5768, "mimetype": "image/jpeg", "cacheControl": "max-age=3600", "lastModified": "2026-06-17T12:25:07.000Z", "contentLength": 5768, "httpStatusCode": 200}	2c9613f7-20e6-463b-a401-f23852e206e1	\N	{}
47d02aeb-8a65-4ae7-8216-d8ecc319cc06	funcionarios	fotos/1781699311793.jpg	\N	2026-06-17 12:28:32.234805+00	2026-06-17 12:28:32.234805+00	2026-06-17 12:28:32.234805+00	{"eTag": "\\"ee8b95146e8c847793381a6d3dde9e43\\"", "size": 21692, "mimetype": "image/jpeg", "cacheControl": "max-age=3600", "lastModified": "2026-06-17T12:28:33.000Z", "contentLength": 21692, "httpStatusCode": 200}	6c04ff99-c90c-430c-9822-a93481860d2e	\N	{}
7991edca-e94a-40a7-8be6-f948e2b4061a	funcionarios	fotos/1781865064936.jpg	\N	2026-06-19 10:31:07.443932+00	2026-06-19 10:31:07.443932+00	2026-06-19 10:31:07.443932+00	{"eTag": "\\"f3ae977424b479ed6ff08f5fc219930b\\"", "size": 1006231, "mimetype": "image/jpeg", "cacheControl": "max-age=3600", "lastModified": "2026-06-19T10:31:08.000Z", "contentLength": 1006231, "httpStatusCode": 200}	62acd761-4e32-4c14-9ccc-02b4ca19a30a	\N	{}
5a0afe70-a8db-4a0e-a578-f4e2fffd1f74	funcionarios	fotos/1781699420135.jpg	\N	2026-06-17 12:30:20.946203+00	2026-06-17 12:30:20.946203+00	2026-06-17 12:30:20.946203+00	{"eTag": "\\"e416bab16e25036304b9d1896e9581da\\"", "size": 32990, "mimetype": "image/jpeg", "cacheControl": "max-age=3600", "lastModified": "2026-06-17T12:30:21.000Z", "contentLength": 32990, "httpStatusCode": 200}	cf1363ee-2114-43db-aac5-1bdbc66fb645	\N	{}
7e1f5de4-3f64-4547-a4c4-60e48b7025fa	funcionarios	fotos/1781865692126.jpg	\N	2026-06-19 10:41:32.915239+00	2026-06-19 10:41:32.915239+00	2026-06-19 10:41:32.915239+00	{"eTag": "\\"d682769ef897c218ff894bd2f2ac32bb\\"", "size": 72441, "mimetype": "image/jpeg", "cacheControl": "max-age=3600", "lastModified": "2026-06-19T10:41:33.000Z", "contentLength": 72441, "httpStatusCode": 200}	a702ecaf-170e-47d5-9f2b-def9d23bdc72	\N	{}
422f9dfc-d8ed-4561-a8a2-fb433b32646a	funcionarios	fotos/1781865933848.png	\N	2026-06-19 10:45:34.865572+00	2026-06-19 10:45:34.865572+00	2026-06-19 10:45:34.865572+00	{"eTag": "\\"f63f6cc314bea80a83fcb2261302919f\\"", "size": 55692, "mimetype": "image/png", "cacheControl": "max-age=3600", "lastModified": "2026-06-19T10:45:35.000Z", "contentLength": 55692, "httpStatusCode": 200}	aad7e8c5-cae8-41c1-99d4-2d4b15218129	\N	{}
c54b00b6-6f27-4485-afa2-489bc219fe53	funcionarios	fotos/1781699587730.jpg	\N	2026-06-17 12:33:08.362814+00	2026-06-17 12:33:08.362814+00	2026-06-17 12:33:08.362814+00	{"eTag": "\\"3a6445efa668c182001911549b2e8079\\"", "size": 2979, "mimetype": "image/jpeg", "cacheControl": "max-age=3600", "lastModified": "2026-06-17T12:33:09.000Z", "contentLength": 2979, "httpStatusCode": 200}	a2b907c1-1aa8-417d-8909-8c255521685b	\N	{}
ea793a08-dcc9-43ba-b672-d897c481848f	alojamentos	laudos/1782570574361_RELATORIO_ESTRUTURAL_16.pdf	\N	2026-06-27 14:29:35.006336+00	2026-06-27 14:29:35.006336+00	2026-06-27 14:29:35.006336+00	{"eTag": "\\"ac90186455bc129240db73b1c8de7d9d\\"", "size": 508441, "mimetype": "application/pdf", "cacheControl": "max-age=3600", "lastModified": "2026-06-27T14:29:35.000Z", "contentLength": 508441, "httpStatusCode": 200}	5b1e41ff-3ccc-4739-ae69-9bd5ea55094e	\N	{}
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
caae451e-0e16-4a9f-8fe8-e2a7148463f1	alojamentos	fotos/1782570575442_FOTO.zip	\N	2026-06-27 14:29:36.750439+00	2026-06-27 14:29:36.750439+00	2026-06-27 14:29:36.750439+00	{"eTag": "\\"d470c72e86cae83443883531ae0b5e1d\\"", "size": 1120601, "mimetype": "application/x-zip-compressed", "cacheControl": "max-age=3600", "lastModified": "2026-06-27T14:29:37.000Z", "contentLength": 1120601, "httpStatusCode": 200}	216d80af-180b-482d-9b7a-49a91a5a6d4e	\N	{}
6c06cad7-6318-4187-87e5-17b862432945	funcionarios	fotos/1781717233724.png	\N	2026-06-17 17:27:14.335476+00	2026-06-17 17:27:14.335476+00	2026-06-17 17:27:14.335476+00	{"eTag": "\\"0f07b68d9c0b961f8eb9dd15a35500e2\\"", "size": 57065, "mimetype": "image/png", "cacheControl": "max-age=3600", "lastModified": "2026-06-17T17:27:15.000Z", "contentLength": 57065, "httpStatusCode": 200}	0c9ba086-5494-4381-bf24-3d124852107a	\N	{}
db741a65-6646-46a3-a135-5ef6108b00db	funcionarios	fotos/1781789122259.png	\N	2026-06-18 13:25:23.91948+00	2026-06-18 13:25:23.91948+00	2026-06-18 13:25:23.91948+00	{"eTag": "\\"a24101afa197ad1211591b4405eaf06b\\"", "size": 441573, "mimetype": "image/png", "cacheControl": "max-age=3600", "lastModified": "2026-06-18T13:25:24.000Z", "contentLength": 441573, "httpStatusCode": 200}	3dfcde95-19a8-4068-852c-1783444b8719	\N	{}
00b40bec-d7c5-41e8-9407-8110c9c94e71	funcionarios	fotos/1781717284237.png	\N	2026-06-17 17:28:05.499865+00	2026-06-17 17:28:05.499865+00	2026-06-17 17:28:05.499865+00	{"eTag": "\\"285b6c6e71966650947364ded5416277\\"", "size": 416772, "mimetype": "image/png", "cacheControl": "max-age=3600", "lastModified": "2026-06-17T17:28:06.000Z", "contentLength": 416772, "httpStatusCode": 200}	c3a10e92-42cc-481b-a41e-589800cfbb64	\N	{}
8c4c6b78-97ee-4ee6-acde-87179a753e31	funcionarios	fotos/1781717334697.jpeg	\N	2026-06-17 17:28:54.845683+00	2026-06-17 17:28:54.845683+00	2026-06-17 17:28:54.845683+00	{"eTag": "\\"7fd1e523aba9e9a8d1e3ea02d1a17907\\"", "size": 63014, "mimetype": "image/jpeg", "cacheControl": "max-age=3600", "lastModified": "2026-06-17T17:28:55.000Z", "contentLength": 63014, "httpStatusCode": 200}	fb7c438f-676f-4cf4-8daf-d30ce3b96f32	\N	{}
bd6ef791-7842-4390-9d72-e936a6b07432	alojamentos	laudos/1781789424205_LAUDO_DE_VISTORIA_DE_ENTRADA_-_ASSINADO.pdf	\N	2026-06-18 13:30:49.602746+00	2026-06-18 13:30:49.602746+00	2026-06-18 13:30:49.602746+00	{"eTag": "\\"b907070817ec2895d359081626d7fe12\\"", "size": 16250593, "mimetype": "application/pdf", "cacheControl": "max-age=3600", "lastModified": "2026-06-18T13:30:50.000Z", "contentLength": 16250593, "httpStatusCode": 200}	d87e498f-d22e-4d07-a4e1-72f5f210acdb	\N	{}
466e2ee0-eac2-41d3-b7d7-74cfa440db76	funcionarios	fotos/1781717384863.png	\N	2026-06-17 17:29:45.710509+00	2026-06-17 17:29:45.710509+00	2026-06-17 17:29:45.710509+00	{"eTag": "\\"a8ad88b01a172f147f1971bf5ff13a96\\"", "size": 147259, "mimetype": "image/png", "cacheControl": "max-age=3600", "lastModified": "2026-06-17T17:29:46.000Z", "contentLength": 147259, "httpStatusCode": 200}	a1f0feb0-b0e2-45dc-8efd-2e8e65062ac8	\N	{}
73ebe8a2-ca5e-4519-a958-59cb513ecde8	alojamentos	contratos/1782570903815_24104-011_-_JULIANA_CRISTINA_X_GTEL_-_RUA_PAU_BRASIL,_132.pdf	\N	2026-06-27 14:35:09.05126+00	2026-06-27 14:35:09.05126+00	2026-06-27 14:35:09.05126+00	{"eTag": "\\"793dd76cc12e7bce10d6f62b6edb96b3\\"", "size": 2296826, "mimetype": "application/pdf", "cacheControl": "max-age=3600", "lastModified": "2026-06-27T14:35:10.000Z", "contentLength": 2296826, "httpStatusCode": 200}	923fed51-6d94-4c6c-9370-5b9088ff7bf6	\N	{}
4701f034-3c2c-4d32-be8b-05719c4d7fa1	funcionarios	fotos/1781717444676.png	\N	2026-06-17 17:30:45.399754+00	2026-06-17 17:30:45.399754+00	2026-06-17 17:30:45.399754+00	{"eTag": "\\"26855f5e48967cd588703360190bf82b\\"", "size": 86696, "mimetype": "image/png", "cacheControl": "max-age=3600", "lastModified": "2026-06-17T17:30:46.000Z", "contentLength": 86696, "httpStatusCode": 200}	07706771-dfa2-497f-ae75-6b80675bb737	\N	{}
45f8497a-8895-43c4-b91a-394897e1dbaf	alojamentos	laudos/1781789439244_LAUDO_DE_VISTORIA_DE_ENTRADA_-_ASSINADO.pdf	\N	2026-06-18 13:30:59.56591+00	2026-06-18 13:30:59.56591+00	2026-06-18 13:30:59.56591+00	{"eTag": "\\"b907070817ec2895d359081626d7fe12\\"", "size": 16250593, "mimetype": "application/pdf", "cacheControl": "max-age=3600", "lastModified": "2026-06-18T13:31:00.000Z", "contentLength": 16250593, "httpStatusCode": 200}	1c401b43-6151-420a-ab63-b1c7dea261d7	\N	{}
71f6f853-d6a3-444d-abc0-ab0392b48071	funcionarios	fotos/1781717480962.jpg	\N	2026-06-17 17:31:21.094021+00	2026-06-17 17:31:21.094021+00	2026-06-17 17:31:21.094021+00	{"eTag": "\\"93871d524cc7de31424379e1e87b2c6c\\"", "size": 49722, "mimetype": "image/jpeg", "cacheControl": "max-age=3600", "lastModified": "2026-06-17T17:31:22.000Z", "contentLength": 49722, "httpStatusCode": 200}	ff8bf924-c879-4a18-bf30-f9cfac4e6b6e	\N	{}
fbf75397-c288-4e7e-be2d-42851a506adf	alojamentos	contratos/1781789562876_Contrato_Rua_Avelino_Beraldo_115_-_Vila_Monte_Alegre_-_Paulinia_-_Assinado.pdf	\N	2026-06-18 13:32:45.599538+00	2026-06-18 13:32:45.599538+00	2026-06-18 13:32:45.599538+00	{"eTag": "\\"d7bc384247ab30aa0f24bf464bde3589\\"", "size": 2222332, "mimetype": "application/pdf", "cacheControl": "max-age=3600", "lastModified": "2026-06-18T13:32:46.000Z", "contentLength": 2222332, "httpStatusCode": 200}	445e0665-017f-4371-b8da-2ae568ea5341	\N	{}
2b1fa282-4ab2-43de-b6f4-a1ea3d845da7	funcionarios	fotos/1782990641779.png	\N	2026-07-02 11:10:42.433755+00	2026-07-02 11:10:42.433755+00	2026-07-02 11:10:42.433755+00	{"eTag": "\\"4966310d88df49ccf3d8b5a2f6d63aeb\\"", "size": 77601, "mimetype": "image/png", "cacheControl": "max-age=3600", "lastModified": "2026-07-02T11:10:43.000Z", "contentLength": 77601, "httpStatusCode": 200}	54f8c8da-60a9-464e-92b6-cb1ed508198f	\N	{}
5a6dbd6a-dec9-4045-8ef0-ab7bacb8aef6	alojamentos	laudos/1781789565509_Vistoria_de_Entrada.pdf	\N	2026-06-18 13:32:48.320403+00	2026-06-18 13:32:48.320403+00	2026-06-18 13:32:48.320403+00	{"eTag": "\\"fec2a6c4f607b4ca359f94c4a9aea10d\\"", "size": 2124472, "mimetype": "application/pdf", "cacheControl": "max-age=3600", "lastModified": "2026-06-18T13:32:49.000Z", "contentLength": 2124472, "httpStatusCode": 200}	2e7d1aad-197b-4f04-b3ce-bae54a2fed4b	\N	{}
0b9ef8b4-99e7-4040-a65c-1e4005f20300	funcionarios	fotos/1781717084764.jpeg	\N	2026-06-17 17:24:46.734578+00	2026-06-17 17:24:46.734578+00	2026-06-17 17:24:46.734578+00	{"eTag": "\\"bb4d1f9d46e78245b61711ba17cd6de5\\"", "size": 244835, "mimetype": "image/jpeg", "cacheControl": "max-age=3600", "lastModified": "2026-06-17T17:24:47.000Z", "contentLength": 244835, "httpStatusCode": 200}	72e1f1f3-af5a-4891-96ec-3f5943786188	\N	{}
1288295a-672c-43a0-864a-63075d407621	alojamentos	fotos/1781789568234_ADM_31_-_01-2026_AVELINO_BERALDO,_115_-_supervisores.pdf	\N	2026-06-18 13:32:49.87988+00	2026-06-18 13:32:49.87988+00	2026-06-18 13:32:49.87988+00	{"eTag": "\\"eeac1171e1538e2923ff253f6921dda4\\"", "size": 1308143, "mimetype": "application/pdf", "cacheControl": "max-age=3600", "lastModified": "2026-06-18T13:32:50.000Z", "contentLength": 1308143, "httpStatusCode": 200}	e7139a0a-505b-412a-b993-4e5f3145d778	\N	{}
d46c3352-c816-4df3-be12-6be433e27475	funcionarios	fotos/1781717157467.png	\N	2026-06-17 17:25:59.051859+00	2026-06-17 17:25:59.051859+00	2026-06-17 17:25:59.051859+00	{"eTag": "\\"c359bd6fcb5ff63b390c3f1103db20c6\\"", "size": 551447, "mimetype": "image/png", "cacheControl": "max-age=3600", "lastModified": "2026-06-17T17:26:00.000Z", "contentLength": 551447, "httpStatusCode": 200}	6376dd51-db35-4ff5-8c9d-2f0259c7caf5	\N	{}
e9f03a06-fd48-4920-9df9-bac969bff06f	alojamentos	laudos/1782570909464_RELATORIO_ESTRUTURAL_16.pdf	\N	2026-06-27 14:35:10.970411+00	2026-06-27 14:35:10.970411+00	2026-06-27 14:35:10.970411+00	{"eTag": "\\"ac90186455bc129240db73b1c8de7d9d\\"", "size": 508441, "mimetype": "application/pdf", "cacheControl": "max-age=3600", "lastModified": "2026-06-27T14:35:11.000Z", "contentLength": 508441, "httpStatusCode": 200}	4a7a4fc5-a7dd-439f-8a6e-7b62a9718d71	\N	{}
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
8c18f5d2-9ffe-482d-a4be-be02c89de687	alojamentos	fotos/1782570911379_FOTO.zip	\N	2026-06-27 14:35:14.366996+00	2026-06-27 14:35:14.366996+00	2026-06-27 14:35:14.366996+00	{"eTag": "\\"d470c72e86cae83443883531ae0b5e1d\\"", "size": 1120601, "mimetype": "application/x-zip-compressed", "cacheControl": "max-age=3600", "lastModified": "2026-06-27T14:35:15.000Z", "contentLength": 1120601, "httpStatusCode": 200}	a107a3cc-a395-4f98-93fb-86d74959804f	\N	{}
ec986e38-9a14-4d39-ac59-a1054e1471b0	funcionarios	fotos/1781717789495.png	\N	2026-06-17 17:36:29.889+00	2026-06-17 17:36:29.889+00	2026-06-17 17:36:29.889+00	{"eTag": "\\"6a76ae5fc08484f6c5b21e27a3e8662c\\"", "size": 191206, "mimetype": "image/png", "cacheControl": "max-age=3600", "lastModified": "2026-06-17T17:36:30.000Z", "contentLength": 191206, "httpStatusCode": 200}	5b632b7f-a6cf-4242-a575-f32a7df46630	\N	{}
1e821ace-82b6-426b-adcd-49956afe5999	funcionarios	fotos/1781717829139.png	\N	2026-06-17 17:37:09.920335+00	2026-06-17 17:37:09.920335+00	2026-06-17 17:37:09.920335+00	{"eTag": "\\"f272d7a21d49048b014445e1b588f4a6\\"", "size": 164871, "mimetype": "image/png", "cacheControl": "max-age=3600", "lastModified": "2026-06-17T17:37:10.000Z", "contentLength": 164871, "httpStatusCode": 200}	ed1b2ceb-99b0-4e11-9440-7d5f7a270a94	\N	{}
1cbb8223-50ed-4a6c-ba5c-6a56d531544d	alojamentos	fotos/1781789757321_ADM_31_-_02-2026_-_SERRA_AZUL.pdf	\N	2026-06-18 13:36:01.184767+00	2026-06-18 13:36:01.184767+00	2026-06-18 13:36:01.184767+00	{"eTag": "\\"d2363db85c57ee5763c19cc11b17e7cd\\"", "size": 1178086, "mimetype": "application/pdf", "cacheControl": "max-age=3600", "lastModified": "2026-06-18T13:36:02.000Z", "contentLength": 1178086, "httpStatusCode": 200}	16578f43-8354-486e-8109-374cce31c4da	\N	{}
fec3abfc-7c78-4af6-bd96-dec2f5f1a92d	funcionarios	fotos/1781717889359.jpeg	\N	2026-06-17 17:38:09.921448+00	2026-06-17 17:38:09.921448+00	2026-06-17 17:38:09.921448+00	{"eTag": "\\"7278aa6b07a6e770d3b5faecb9d4adbd\\"", "size": 19133, "mimetype": "image/jpeg", "cacheControl": "max-age=3600", "lastModified": "2026-06-17T17:38:10.000Z", "contentLength": 19133, "httpStatusCode": 200}	fc440736-ec4e-4e11-b242-e9f87be5ffcf	\N	{}
eae591d0-05c8-4eff-9605-1eab428613d6	alojamentos	laudos/1781789743484_LAUDO_DE_VISTORIA_DE_ENTRADA_-_ASSINADO.pdf	\N	2026-06-18 13:36:01.399823+00	2026-06-18 13:36:01.399823+00	2026-06-18 13:36:01.399823+00	{"eTag": "\\"c887b9ab11fc9f0392ead57285641984\\"", "size": 11257542, "mimetype": "application/pdf", "cacheControl": "max-age=3600", "lastModified": "2026-06-18T13:36:02.000Z", "contentLength": 11257542, "httpStatusCode": 200}	949c7f62-1a10-4b3a-bad1-b2dccff2b0ce	\N	{}
5aa4180b-9735-4c18-8b07-48aa8537f265	funcionarios	fotos/1781717949717.png	\N	2026-06-17 17:39:12.291438+00	2026-06-17 17:39:12.291438+00	2026-06-17 17:39:12.291438+00	{"eTag": "\\"3c1443709f44d13d8f6028d2656b359c\\"", "size": 79696, "mimetype": "image/png", "cacheControl": "max-age=3600", "lastModified": "2026-06-17T17:39:13.000Z", "contentLength": 79696, "httpStatusCode": 200}	8b5584e6-9f8e-4e19-8e35-aea163e424af	\N	{}
1f37ba0e-a74a-47ec-a11b-0e45e9ef0b92	alojamentos	fotos/1782571368164_FOTO.zip	\N	2026-06-27 14:42:49.165262+00	2026-06-27 14:42:49.165262+00	2026-06-27 14:42:49.165262+00	{"eTag": "\\"b7fd78c5721af9a6e26654c36850638e\\"", "size": 1201352, "mimetype": "application/x-zip-compressed", "cacheControl": "max-age=3600", "lastModified": "2026-06-27T14:42:50.000Z", "contentLength": 1201352, "httpStatusCode": 200}	6ec095d0-72cc-4f1b-a74b-ac4c360c99f5	\N	{}
84f2bad6-5eac-4e30-8185-c3ea37562655	alojamentos	fotos/1781789761414_ADM_31_-_02-2026_-_SERRA_AZUL.pdf	\N	2026-06-18 13:36:03.386597+00	2026-06-18 13:36:03.386597+00	2026-06-18 13:36:03.386597+00	{"eTag": "\\"d2363db85c57ee5763c19cc11b17e7cd\\"", "size": 1178086, "mimetype": "application/pdf", "cacheControl": "max-age=3600", "lastModified": "2026-06-18T13:36:04.000Z", "contentLength": 1178086, "httpStatusCode": 200}	ca95a1e4-11f6-4d4f-bb45-b33ec584050e	\N	{}
779d6d78-81aa-4160-b232-7ef6e3f8e877	alojamentos	laudos/1781790108558_Laudo_de_Vistoria_Inicial.pdf	\N	2026-06-18 13:41:55.582284+00	2026-06-18 13:41:55.582284+00	2026-06-18 13:41:55.582284+00	{"eTag": "\\"2c6fc8ecbdd1df1e6518b6523aa6431a\\"", "size": 582223, "mimetype": "application/pdf", "cacheControl": "max-age=3600", "lastModified": "2026-06-18T13:41:56.000Z", "contentLength": 582223, "httpStatusCode": 200}	d6ff315a-a932-4994-a78d-51926e66cbab	\N	{}
8fc5d948-c74c-4999-82c9-013a59d9b9bd	alojamentos	fotos/1782571529563_FOTO.zip	\N	2026-06-27 14:45:31.406792+00	2026-06-27 14:45:31.406792+00	2026-06-27 14:45:31.406792+00	{"eTag": "\\"b7fd78c5721af9a6e26654c36850638e\\"", "size": 1201352, "mimetype": "application/x-zip-compressed", "cacheControl": "max-age=3600", "lastModified": "2026-06-27T14:45:32.000Z", "contentLength": 1201352, "httpStatusCode": 200}	d06a301a-7ddf-4c2e-b4f5-592c837ee19f	\N	{}
3431765a-f61b-486b-806b-7b53431d70bd	alojamentos	fotos/1781790115749_ADM_31_-_03-2026_BRISA_DA_MATA_APTO.pdf	\N	2026-06-18 13:41:58.436791+00	2026-06-18 13:41:58.436791+00	2026-06-18 13:41:58.436791+00	{"eTag": "\\"73f3d1a6cfe3d127ad30e5888a857bc6\\"", "size": 623091, "mimetype": "application/pdf", "cacheControl": "max-age=3600", "lastModified": "2026-06-18T13:41:59.000Z", "contentLength": 623091, "httpStatusCode": 200}	413ed1b5-8851-4b02-90e5-c6a48f89944f	\N	{}
ce9bdc64-787c-4a9b-af2d-a80c3d8fbee0	funcionarios	fotos/1781717665910.png	\N	2026-06-17 17:34:26.178137+00	2026-06-17 17:34:26.178137+00	2026-06-17 17:34:26.178137+00	{"eTag": "\\"5717ff0fd16371215d27418207aef5be\\"", "size": 74169, "mimetype": "image/png", "cacheControl": "max-age=3600", "lastModified": "2026-06-17T17:34:27.000Z", "contentLength": 74169, "httpStatusCode": 200}	980c942f-31cc-4150-bba0-5121ea4d3651	\N	{}
51035a20-296b-47c7-b767-bc3be8c4e894	alojamentos	laudos/1781790116808_Laudo_de_Vistoria_Inicial.pdf	\N	2026-06-18 13:42:00.419268+00	2026-06-18 13:42:00.419268+00	2026-06-18 13:42:00.419268+00	{"eTag": "\\"2c6fc8ecbdd1df1e6518b6523aa6431a\\"", "size": 582223, "mimetype": "application/pdf", "cacheControl": "max-age=3600", "lastModified": "2026-06-18T13:42:01.000Z", "contentLength": 582223, "httpStatusCode": 200}	2675624f-6ad9-48a1-8bdd-80411fa26baa	\N	{}
2ad4853b-ec22-415c-b653-413caea00ec8	funcionarios	fotos/1781717706932.png	\N	2026-06-17 17:35:08.27043+00	2026-06-17 17:35:08.27043+00	2026-06-17 17:35:08.27043+00	{"eTag": "\\"bd39dff7ab09cb09663a7765cb12c657\\"", "size": 945453, "mimetype": "image/png", "cacheControl": "max-age=3600", "lastModified": "2026-06-17T17:35:09.000Z", "contentLength": 945453, "httpStatusCode": 200}	ce4f746f-dad4-4937-a1f1-ca135ffa54dc	\N	{}
70a8d33d-3181-493f-bde4-45c54e565f07	funcionarios	fotos/1781866804285.jpg	\N	2026-06-19 11:00:06.395842+00	2026-06-19 11:00:06.395842+00	2026-06-19 11:00:06.395842+00	{"eTag": "\\"7764d5df738c7aeaef750b6f246e6b6d\\"", "size": 85953, "mimetype": "image/jpeg", "cacheControl": "max-age=3600", "lastModified": "2026-06-19T11:00:07.000Z", "contentLength": 85953, "httpStatusCode": 200}	a341ccf1-0ae9-4bc8-a199-e869a871ee9e	\N	{}
a9d1b5ab-da48-41b7-abdc-d82f34b1fda3	funcionarios	fotos/1781717766418.png	\N	2026-06-17 17:36:07.24569+00	2026-06-17 17:36:07.24569+00	2026-06-17 17:36:07.24569+00	{"eTag": "\\"313b83f868d2558fa2877202e31fb612\\"", "size": 447575, "mimetype": "image/png", "cacheControl": "max-age=3600", "lastModified": "2026-06-17T17:36:08.000Z", "contentLength": 447575, "httpStatusCode": 200}	37d8e36e-c9df-458b-99de-7f9c880b99a8	\N	{}
4c821c08-fc52-490b-a63d-e2a64332a0af	funcionarios	fotos/1781717810301.png	\N	2026-06-17 17:36:50.63664+00	2026-06-17 17:36:50.63664+00	2026-06-17 17:36:50.63664+00	{"eTag": "\\"7d0689300cf73ef2b73a0da6864fd1f8\\"", "size": 205404, "mimetype": "image/png", "cacheControl": "max-age=3600", "lastModified": "2026-06-17T17:36:51.000Z", "contentLength": 205404, "httpStatusCode": 200}	34fdd6ca-415e-4968-a12a-d4e7c36575aa	\N	{}
e93cea72-074c-4ba6-82b2-be83bf8d096b	funcionarios	fotos/1781866805632.jpg	\N	2026-06-19 11:00:07.038362+00	2026-06-19 11:00:07.038362+00	2026-06-19 11:00:07.038362+00	{"eTag": "\\"7764d5df738c7aeaef750b6f246e6b6d\\"", "size": 85953, "mimetype": "image/jpeg", "cacheControl": "max-age=3600", "lastModified": "2026-06-19T11:00:08.000Z", "contentLength": 85953, "httpStatusCode": 200}	615aedae-90aa-47a4-af81-46e4f15a1f0f	\N	{}
3abcd3e1-37ab-4dc7-a8f6-da55028b5675	funcionarios	fotos/1781717859000.png	\N	2026-06-17 17:37:39.328467+00	2026-06-17 17:37:39.328467+00	2026-06-17 17:37:39.328467+00	{"eTag": "\\"cfc6d0f6b9f0bf9f61412675e4c5d1d6\\"", "size": 55116, "mimetype": "image/png", "cacheControl": "max-age=3600", "lastModified": "2026-06-17T17:37:40.000Z", "contentLength": 55116, "httpStatusCode": 200}	28f2a12a-1cbf-49eb-86c5-24ab3acabb94	\N	{}
55b38f44-c79f-4bbb-a8a8-5dc593c8fd63	funcionarios	fotos/1782577833822.jpg	\N	2026-06-27 16:30:34.514094+00	2026-06-27 16:30:34.514094+00	2026-06-27 16:30:34.514094+00	{"eTag": "\\"df6842047b57f1fb324a584b763f3e29\\"", "size": 26452, "mimetype": "image/jpeg", "cacheControl": "max-age=3600", "lastModified": "2026-06-27T16:30:35.000Z", "contentLength": 26452, "httpStatusCode": 200}	f15d169e-29a8-42cc-a591-d152a5de04c2	\N	{}
973531b8-9168-41da-ab4a-399ef58af0b3	funcionarios	fotos/1781717911277.png	\N	2026-06-17 17:38:41.127078+00	2026-06-17 17:38:41.127078+00	2026-06-17 17:38:41.127078+00	{"eTag": "\\"d18527d0b2e51bd1a67068330d885aba\\"", "size": 347713, "mimetype": "image/png", "cacheControl": "max-age=3600", "lastModified": "2026-06-17T17:38:42.000Z", "contentLength": 347713, "httpStatusCode": 200}	33d2607e-794e-4482-8191-4640ebaa2b61	\N	{}
c43c3c52-b8c8-4f25-b644-da110e862e27	funcionarios	fotos/1781867095352.jpeg	\N	2026-06-19 11:04:56.87127+00	2026-06-19 11:04:56.87127+00	2026-06-19 11:04:56.87127+00	{"eTag": "\\"1ca1f4d9fe6f35ddc8ec60295c360df0\\"", "size": 204413, "mimetype": "image/jpeg", "cacheControl": "max-age=3600", "lastModified": "2026-06-19T11:04:57.000Z", "contentLength": 204413, "httpStatusCode": 200}	9aa62512-55eb-49fe-9e4e-6602c0c0c2a3	\N	{}
483af474-527b-4a4a-a1fb-91ed67a0ea90	funcionarios	fotos/1781717973720.png	\N	2026-06-17 17:39:34.155814+00	2026-06-17 17:39:34.155814+00	2026-06-17 17:39:34.155814+00	{"eTag": "\\"b066d79fb5a00fb0bfcc38edd39a3f2b\\"", "size": 57080, "mimetype": "image/png", "cacheControl": "max-age=3600", "lastModified": "2026-06-17T17:39:35.000Z", "contentLength": 57080, "httpStatusCode": 200}	ebbd0d69-13d1-4d71-9fe2-5b2c127c84a1	\N	{}
73f2c7be-8d29-4afc-b91a-3e0269e96385	funcionarios	fotos/1781867316721.jpeg	\N	2026-06-19 11:08:38.927019+00	2026-06-19 11:08:38.927019+00	2026-06-19 11:08:38.927019+00	{"eTag": "\\"51a447b089eb17bf67a1795a97d7fa69\\"", "size": 160428, "mimetype": "image/jpeg", "cacheControl": "max-age=3600", "lastModified": "2026-06-19T11:08:39.000Z", "contentLength": 160428, "httpStatusCode": 200}	469f0af1-e290-4bfd-80b9-435fba5d7bcf	\N	{}
7c7e66be-66ae-4bcd-8660-3f5058637126	funcionarios	fotos/1781868378528.jpeg	\N	2026-06-19 11:26:20.13781+00	2026-06-19 11:26:20.13781+00	2026-06-19 11:26:20.13781+00	{"eTag": "\\"41731c32e9e9e4af12bbf6f451f0963d\\"", "size": 110534, "mimetype": "image/jpeg", "cacheControl": "max-age=3600", "lastModified": "2026-06-19T11:26:20.000Z", "contentLength": 110534, "httpStatusCode": 200}	809f4beb-32a8-42c4-8933-5bf60a44a60f	\N	{}
59a58925-e861-4984-b721-107247e5282b	funcionarios	fotos/1782577913569.jpg	\N	2026-06-27 16:31:53.84021+00	2026-06-27 16:31:53.84021+00	2026-06-27 16:31:53.84021+00	{"eTag": "\\"964ec96a6879ef5006d8a853aa3a04b1\\"", "size": 336271, "mimetype": "image/jpeg", "cacheControl": "max-age=3600", "lastModified": "2026-06-27T16:31:54.000Z", "contentLength": 336271, "httpStatusCode": 200}	27bf1e46-afdb-4cf5-8ad5-dd1c5c0d7c0c	\N	{}
f8ef22ec-fe6b-4559-bf49-f252c712b0b4	funcionarios	fotos/1781869676239.jpg	\N	2026-06-19 11:47:58.759405+00	2026-06-19 11:47:58.759405+00	2026-06-19 11:47:58.759405+00	{"eTag": "\\"78c908201d2b1fb3269c2c28d3473524\\"", "size": 1031302, "mimetype": "image/jpeg", "cacheControl": "max-age=3600", "lastModified": "2026-06-19T11:47:59.000Z", "contentLength": 1031302, "httpStatusCode": 200}	f5f7bb9b-a99f-489e-931e-01a807fa6d66	\N	{}
0af8b1b5-0292-4e5b-bb2e-0173e5194787	funcionarios	fotos/1781869679380.jpg	\N	2026-06-19 11:48:01.4288+00	2026-06-19 11:48:01.4288+00	2026-06-19 11:48:01.4288+00	{"eTag": "\\"78c908201d2b1fb3269c2c28d3473524\\"", "size": 1031302, "mimetype": "image/jpeg", "cacheControl": "max-age=3600", "lastModified": "2026-06-19T11:48:02.000Z", "contentLength": 1031302, "httpStatusCode": 200}	0ee551be-a689-47ab-bb03-b864fdf08dc2	\N	{}
294b7eb0-267f-47a8-8b6e-0902ce66434a	funcionarios	fotos/1782577971565.png	\N	2026-06-27 16:32:52.458239+00	2026-06-27 16:32:52.458239+00	2026-06-27 16:32:52.458239+00	{"eTag": "\\"ff5aee5f091fea5166aa247b9f782198\\"", "size": 159851, "mimetype": "image/png", "cacheControl": "max-age=3600", "lastModified": "2026-06-27T16:32:53.000Z", "contentLength": 159851, "httpStatusCode": 200}	02d8fd48-1242-4fca-9c90-3d1858d83b37	\N	{}
dd7347b4-a7dd-48ac-bcb8-a04eae2f6570	funcionarios	fotos/1782578377452.jpeg	\N	2026-06-27 16:39:38.212643+00	2026-06-27 16:39:38.212643+00	2026-06-27 16:39:38.212643+00	{"eTag": "\\"748e7d4a7e7cc232d5f06e1b2ab48183\\"", "size": 252190, "mimetype": "image/jpeg", "cacheControl": "max-age=3600", "lastModified": "2026-06-27T16:39:39.000Z", "contentLength": 252190, "httpStatusCode": 200}	52fadf57-42b1-4762-bd78-0ce8de38f287	\N	{}
6ab6cfc1-c5c5-4c2b-8004-118cbbf4ff53	funcionarios	fotos/1782578646385.png	\N	2026-06-27 16:44:06.679806+00	2026-06-27 16:44:06.679806+00	2026-06-27 16:44:06.679806+00	{"eTag": "\\"649eb570c56ef664a1138b28b01131ec\\"", "size": 230424, "mimetype": "image/png", "cacheControl": "max-age=3600", "lastModified": "2026-06-27T16:44:07.000Z", "contentLength": 230424, "httpStatusCode": 200}	3f0d8f03-72ca-4067-9ba8-79b753505312	\N	{}
40f90c92-8131-4762-ba4f-21a897e7b0d6	funcionarios	fotos/1782579025471.jpeg	\N	2026-06-27 16:50:26.181268+00	2026-06-27 16:50:26.181268+00	2026-06-27 16:50:26.181268+00	{"eTag": "\\"d542b13898b337df5c3774346149b576\\"", "size": 153248, "mimetype": "image/jpeg", "cacheControl": "max-age=3600", "lastModified": "2026-06-27T16:50:27.000Z", "contentLength": 153248, "httpStatusCode": 200}	20cb36e2-7f99-481c-925e-8d971ae08695	\N	{}
6e65dbec-e7dc-4bda-87d6-6093339023b6	funcionarios	fotos/1782579113177.png	\N	2026-06-27 16:51:53.456267+00	2026-06-27 16:51:53.456267+00	2026-06-27 16:51:53.456267+00	{"eTag": "\\"a95961ab2b38fc219c90ee4101e30e16\\"", "size": 124151, "mimetype": "image/png", "cacheControl": "max-age=3600", "lastModified": "2026-06-27T16:51:54.000Z", "contentLength": 124151, "httpStatusCode": 200}	e8f218ed-b998-4d11-b977-ddf9f32649a5	\N	{}
44dc8ac4-8e54-4bf5-b534-16297d874935	funcionarios	fotos/1782579264211.png	\N	2026-06-27 16:54:24.879727+00	2026-06-27 16:54:24.879727+00	2026-06-27 16:54:24.879727+00	{"eTag": "\\"27e817048d0c1e434356f1283358a4da\\"", "size": 63230, "mimetype": "image/png", "cacheControl": "max-age=3600", "lastModified": "2026-06-27T16:54:25.000Z", "contentLength": 63230, "httpStatusCode": 200}	96e00348-8826-471e-9626-1b3f42ea122e	\N	{}
a5ab0535-a422-4ad6-baf5-b918e0ccaa82	funcionarios	fotos/1782579413837.png	\N	2026-06-27 16:56:54.817659+00	2026-06-27 16:56:54.817659+00	2026-06-27 16:56:54.817659+00	{"eTag": "\\"b65af8170f26b0ab7deead3b36f74869\\"", "size": 71497, "mimetype": "image/png", "cacheControl": "max-age=3600", "lastModified": "2026-06-27T16:56:55.000Z", "contentLength": 71497, "httpStatusCode": 200}	3a31ed93-e3cd-46c4-abaf-b7403f5c31b9	\N	{}
b2d016f4-0803-4abc-81d1-ff87b46eb584	funcionarios	fotos/1782579651187.png	\N	2026-06-27 17:00:51.899548+00	2026-06-27 17:00:51.899548+00	2026-06-27 17:00:51.899548+00	{"eTag": "\\"3f0c048150b326b794aea9e16423632b\\"", "size": 166981, "mimetype": "image/png", "cacheControl": "max-age=3600", "lastModified": "2026-06-27T17:00:52.000Z", "contentLength": 166981, "httpStatusCode": 200}	ef82e301-4aa3-4a8a-b671-0e1484b11e81	\N	{}
41c479c8-48b9-4c64-9a2e-62424897ab01	funcionarios	fotos/1782579753622.jpg	\N	2026-06-27 17:02:34.464603+00	2026-06-27 17:02:34.464603+00	2026-06-27 17:02:34.464603+00	{"eTag": "\\"0e21748a2af86aa55b612c0004fe9b1b\\"", "size": 104993, "mimetype": "image/jpeg", "cacheControl": "max-age=3600", "lastModified": "2026-06-27T17:02:35.000Z", "contentLength": 104993, "httpStatusCode": 200}	418fdbc2-5105-4ab7-bb81-7ff34c1dc2a4	\N	{}
5d271c1d-2986-410c-b400-0ba948d625d1	funcionarios	fotos/1782580052796.png	\N	2026-06-27 17:07:35.187243+00	2026-06-27 17:07:35.187243+00	2026-06-27 17:07:35.187243+00	{"eTag": "\\"45ab88b31015e30042b92898da7c7a63\\"", "size": 619600, "mimetype": "image/png", "cacheControl": "max-age=3600", "lastModified": "2026-06-27T17:07:36.000Z", "contentLength": 619600, "httpStatusCode": 200}	01c0a732-174b-41af-ad46-92e63f3d49bb	\N	{}
710d4f01-2089-4559-953d-e25cb0dad069	funcionarios	fotos/1782580148579.jpeg	\N	2026-06-27 17:09:09.174622+00	2026-06-27 17:09:09.174622+00	2026-06-27 17:09:09.174622+00	{"eTag": "\\"d8654986e5df10ef48ce1b4ada635e7b\\"", "size": 70428, "mimetype": "image/jpeg", "cacheControl": "max-age=3600", "lastModified": "2026-06-27T17:09:10.000Z", "contentLength": 70428, "httpStatusCode": 200}	09b64659-8893-4808-b28b-0cb47ba0c97a	\N	{}
d6d556fa-8859-4152-96c5-78dbd44e1dca	funcionarios	fotos/1781871038242.png	\N	2026-06-19 12:10:39.251763+00	2026-06-19 12:10:39.251763+00	2026-06-19 12:10:39.251763+00	{"eTag": "\\"7c28c7bc865d7f7b58eb52a0eb6f7b9a\\"", "size": 48196, "mimetype": "image/png", "cacheControl": "max-age=3600", "lastModified": "2026-06-19T12:10:40.000Z", "contentLength": 48196, "httpStatusCode": 200}	4717a947-f312-42f4-b9da-420fe36929b4	\N	{}
6ca371ba-62e6-4232-93f3-a4736ed22f11	funcionarios	fotos/1781871418674.jpg	\N	2026-06-19 12:16:59.539521+00	2026-06-19 12:16:59.539521+00	2026-06-19 12:16:59.539521+00	{"eTag": "\\"231408aefaf19b34c4b777e7f1eced17\\"", "size": 20988, "mimetype": "image/jpeg", "cacheControl": "max-age=3600", "lastModified": "2026-06-19T12:17:00.000Z", "contentLength": 20988, "httpStatusCode": 200}	be239729-9a79-49c0-b5f7-ae6393809f33	\N	{}
dd66dba1-3fda-4ba0-9ca8-5dce6e3b6054	funcionarios	fotos/1782580348796.png	\N	2026-06-27 17:12:29.449511+00	2026-06-27 17:12:29.449511+00	2026-06-27 17:12:29.449511+00	{"eTag": "\\"9f7084e8f0c7919cc01133e8bfc35263\\"", "size": 112296, "mimetype": "image/png", "cacheControl": "max-age=3600", "lastModified": "2026-06-27T17:12:30.000Z", "contentLength": 112296, "httpStatusCode": 200}	221dbec3-4657-432e-ac20-c68ac21045b3	\N	{}
afb26cbd-1b4f-46c1-a3cd-c2879d87bbd3	funcionarios	fotos/1781871420138.jpg	\N	2026-06-19 12:17:00.415614+00	2026-06-19 12:17:00.415614+00	2026-06-19 12:17:00.415614+00	{"eTag": "\\"231408aefaf19b34c4b777e7f1eced17\\"", "size": 20988, "mimetype": "image/jpeg", "cacheControl": "max-age=3600", "lastModified": "2026-06-19T12:17:01.000Z", "contentLength": 20988, "httpStatusCode": 200}	7fd2b49e-b342-4a99-b64b-3afc9ceb5ccb	\N	{}
1815c3c3-787b-4f42-9379-5d806de952bc	funcionarios	fotos/1781871655434.png	\N	2026-06-19 12:20:56.210729+00	2026-06-19 12:20:56.210729+00	2026-06-19 12:20:56.210729+00	{"eTag": "\\"db1ae0134f757229ba9e11cf45db7d1f\\"", "size": 137451, "mimetype": "image/png", "cacheControl": "max-age=3600", "lastModified": "2026-06-19T12:20:57.000Z", "contentLength": 137451, "httpStatusCode": 200}	3b084ad1-ec06-4159-8ef7-944b2204261e	\N	{}
29801462-c0a0-4718-b72d-b22283dc5173	alojamentos	laudos/1782580704554_RELATORIO_ESTRUTURAL_19.pdf	\N	2026-06-27 17:18:26.098023+00	2026-06-27 17:18:26.098023+00	2026-06-27 17:18:26.098023+00	{"eTag": "\\"fadcaf13f62ddf9b1015147ab0170111\\"", "size": 1618591, "mimetype": "application/pdf", "cacheControl": "max-age=3600", "lastModified": "2026-06-27T17:18:27.000Z", "contentLength": 1618591, "httpStatusCode": 200}	ed427271-8861-4226-9e9c-0c3f33c66808	\N	{}
fefcb790-24aa-4615-a249-78c424f343c6	funcionarios	fotos/1781871803561.png	\N	2026-06-19 12:23:24.351626+00	2026-06-19 12:23:24.351626+00	2026-06-19 12:23:24.351626+00	{"eTag": "\\"5614b24ce7d5535d0c5f93481329093a\\"", "size": 27603, "mimetype": "image/png", "cacheControl": "max-age=3600", "lastModified": "2026-06-19T12:23:25.000Z", "contentLength": 27603, "httpStatusCode": 200}	e1e0b85e-19dc-4eb7-9f03-71d6d0c6561f	\N	{}
e550ff26-2b48-4c37-9768-9e55b78b7b68	funcionarios	fotos/1781872358722.jpeg	\N	2026-06-19 12:32:39.768393+00	2026-06-19 12:32:39.768393+00	2026-06-19 12:32:39.768393+00	{"eTag": "\\"8f229264e69b1dc7c7125365a14840d4\\"", "size": 91534, "mimetype": "image/jpeg", "cacheControl": "max-age=3600", "lastModified": "2026-06-19T12:32:40.000Z", "contentLength": 91534, "httpStatusCode": 200}	484b5b81-cca1-402c-88f0-6a33bc97c09f	\N	{}
3696f115-f155-412e-b784-3f1bc99416a9	alojamentos	fotos/1782580706597_FOTO.zip	\N	2026-06-27 17:18:27.272458+00	2026-06-27 17:18:27.272458+00	2026-06-27 17:18:27.272458+00	{"eTag": "\\"76b96eed2e71585432a017e98a4050dc\\"", "size": 823843, "mimetype": "application/x-zip-compressed", "cacheControl": "max-age=3600", "lastModified": "2026-06-27T17:18:28.000Z", "contentLength": 823843, "httpStatusCode": 200}	c08d65c3-9e96-49bd-9b25-1e2e4f8e9dad	\N	{}
96137f7d-6857-4288-9bef-7b83a0967e47	funcionarios	fotos/1781872847197.jpg	\N	2026-06-19 12:40:48.137524+00	2026-06-19 12:40:48.137524+00	2026-06-19 12:40:48.137524+00	{"eTag": "\\"b104b26eae4788a57c58317faea2734b\\"", "size": 13112, "mimetype": "image/jpeg", "cacheControl": "max-age=3600", "lastModified": "2026-06-19T12:40:49.000Z", "contentLength": 13112, "httpStatusCode": 200}	685ad989-d6aa-4359-93ae-8292d816aa8f	\N	{}
cfff4758-c889-46c2-8d36-424b98752074	funcionarios	fotos/1781873305606.png	\N	2026-06-19 12:48:27.184087+00	2026-06-19 12:48:27.184087+00	2026-06-19 12:48:27.184087+00	{"eTag": "\\"383d38298b55a4a5503f7535b4519708\\"", "size": 316082, "mimetype": "image/png", "cacheControl": "max-age=3600", "lastModified": "2026-06-19T12:48:28.000Z", "contentLength": 316082, "httpStatusCode": 200}	34827419-86a6-40c3-ac6d-bb32e521282b	\N	{}
a0d14ab6-1fc0-4ffe-8051-1d5af18c3228	alojamentos	laudos/1782580797663_RELATORIO_ESTRUTURAL_19.pdf	\N	2026-06-27 17:20:00.245711+00	2026-06-27 17:20:00.245711+00	2026-06-27 17:20:00.245711+00	{"eTag": "\\"fadcaf13f62ddf9b1015147ab0170111\\"", "size": 1618591, "mimetype": "application/pdf", "cacheControl": "max-age=3600", "lastModified": "2026-06-27T17:20:01.000Z", "contentLength": 1618591, "httpStatusCode": 200}	e980078f-b4b1-4421-b956-b9a3d00ef2d1	\N	{}
331b080c-3924-44b8-9270-fb0fc592f63e	funcionarios	fotos/1781873984406.png	\N	2026-06-19 12:59:45.426694+00	2026-06-19 12:59:45.426694+00	2026-06-19 12:59:45.426694+00	{"eTag": "\\"1e6fc4a87f4fa402ad33d4352110aed9\\"", "size": 33604, "mimetype": "image/png", "cacheControl": "max-age=3600", "lastModified": "2026-06-19T12:59:46.000Z", "contentLength": 33604, "httpStatusCode": 200}	797e9ba1-6df8-44b7-a8fa-fa819463d13b	\N	{}
534dc931-3b56-4376-975d-571340ab7f77	funcionarios	fotos/1781874090797.png	\N	2026-06-19 13:01:31.695731+00	2026-06-19 13:01:31.695731+00	2026-06-19 13:01:31.695731+00	{"eTag": "\\"a9e3f08ffa2a5f131eb675e763882a59\\"", "size": 162991, "mimetype": "image/png", "cacheControl": "max-age=3600", "lastModified": "2026-06-19T13:01:32.000Z", "contentLength": 162991, "httpStatusCode": 200}	8b372bfa-afe2-45eb-a709-846b661e81f1	\N	{}
f22a95dd-ed0b-4fba-a4bb-4d0222e8d36f	funcionarios	fotos/1781875052389.jpg	\N	2026-06-19 13:17:33.382665+00	2026-06-19 13:17:33.382665+00	2026-06-19 13:17:33.382665+00	{"eTag": "\\"d337358c51bb44e04e1c9217407f4cda\\"", "size": 14195, "mimetype": "image/jpeg", "cacheControl": "max-age=3600", "lastModified": "2026-06-19T13:17:34.000Z", "contentLength": 14195, "httpStatusCode": 200}	221c9e48-24e7-4318-9430-61d810d5d2bf	\N	{}
bf492bf2-d96b-4d44-80cc-b96447fa6fb6	funcionarios	fotos/1781875054273.jpg	\N	2026-06-19 13:17:34.602623+00	2026-06-19 13:17:34.602623+00	2026-06-19 13:17:34.602623+00	{"eTag": "\\"d337358c51bb44e04e1c9217407f4cda\\"", "size": 14195, "mimetype": "image/jpeg", "cacheControl": "max-age=3600", "lastModified": "2026-06-19T13:17:35.000Z", "contentLength": 14195, "httpStatusCode": 200}	ab1062eb-7cab-4145-980f-6a3b2a1c7c29	\N	{}
bd0c0186-6b39-4499-abe6-6d105b3ca73f	funcionarios	fotos/1781875179601.jpg	\N	2026-06-19 13:19:40.186122+00	2026-06-19 13:19:40.186122+00	2026-06-19 13:19:40.186122+00	{"eTag": "\\"75598c3c0cb44c1b8e84ea8a86e64d1d\\"", "size": 59654, "mimetype": "image/jpeg", "cacheControl": "max-age=3600", "lastModified": "2026-06-19T13:19:41.000Z", "contentLength": 59654, "httpStatusCode": 200}	93c89c19-6d21-4af0-b4c7-d3623cf608c7	\N	{}
0a5fd9c2-587a-4fde-bb98-9c26ac96651f	alojamentos	fotos/1782580800852_FOTO.zip	\N	2026-06-27 17:20:01.966273+00	2026-06-27 17:20:01.966273+00	2026-06-27 17:20:01.966273+00	{"eTag": "\\"76b96eed2e71585432a017e98a4050dc\\"", "size": 823843, "mimetype": "application/x-zip-compressed", "cacheControl": "max-age=3600", "lastModified": "2026-06-27T17:20:02.000Z", "contentLength": 823843, "httpStatusCode": 200}	3692f381-d2f2-440b-bdda-30943160e54a	\N	{}
f7cea29a-86cc-4fa7-a035-5c54d8b1600c	funcionarios	fotos/1781875382426.png	\N	2026-06-19 13:23:03.440068+00	2026-06-19 13:23:03.440068+00	2026-06-19 13:23:03.440068+00	{"eTag": "\\"bbe82ff08e053e7a724af43f9b26e75c\\"", "size": 133986, "mimetype": "image/png", "cacheControl": "max-age=3600", "lastModified": "2026-06-19T13:23:04.000Z", "contentLength": 133986, "httpStatusCode": 200}	5fced484-38c9-49fa-9a96-134940a617ca	\N	{}
ae856148-7696-43ce-824a-73360f4e0da5	alojamentos	fotos/1782584527375_FOTO.zip	\N	2026-06-27 18:22:08.003822+00	2026-06-27 18:22:08.003822+00	2026-06-27 18:22:08.003822+00	{"eTag": "\\"8ecf1575aada0bdfa9148abd3bf73976\\"", "size": 814705, "mimetype": "application/x-zip-compressed", "cacheControl": "max-age=3600", "lastModified": "2026-06-27T18:22:08.000Z", "contentLength": 814705, "httpStatusCode": 200}	47e284d0-3095-4c51-bb71-71dace33cbf0	\N	{}
4f6e82e2-0d5b-422f-8bdd-068301c7aaeb	funcionarios	fotos/1781875750749.png	\N	2026-06-19 13:29:12.226712+00	2026-06-19 13:29:12.226712+00	2026-06-19 13:29:12.226712+00	{"eTag": "\\"97640e0f39bcd7633fe33199b8064506\\"", "size": 253078, "mimetype": "image/png", "cacheControl": "max-age=3600", "lastModified": "2026-06-19T13:29:13.000Z", "contentLength": 253078, "httpStatusCode": 200}	12c852f4-ffbc-4bd9-8014-0dd98d2e71c5	\N	{}
fb65e278-bb81-4de0-98aa-e9030191ff3d	alojamentos	fotos/1782736358687_foto.zip	\N	2026-06-29 12:32:40.487451+00	2026-06-29 12:32:40.487451+00	2026-06-29 12:32:40.487451+00	{"eTag": "\\"03e779c0d1efd80db64b39c6e2730220\\"", "size": 1369955, "mimetype": "application/x-zip-compressed", "cacheControl": "max-age=3600", "lastModified": "2026-06-29T12:32:41.000Z", "contentLength": 1369955, "httpStatusCode": 200}	fcb50285-652f-4428-aa3b-f4a2e90d047f	\N	{}
40639059-48be-424e-9d9d-ad86bdc0af21	funcionarios	fotos/1781875919497.jpg	\N	2026-06-19 13:32:00.807498+00	2026-06-19 13:32:00.807498+00	2026-06-19 13:32:00.807498+00	{"eTag": "\\"81d8a9a9e6761a8212f7fef19f4a1b29\\"", "size": 85195, "mimetype": "image/jpeg", "cacheControl": "max-age=3600", "lastModified": "2026-06-19T13:32:01.000Z", "contentLength": 85195, "httpStatusCode": 200}	7c63a75b-7bbe-409f-9820-dea6e697ae50	\N	{}
d9a0abef-1dd1-477e-a7c1-8dac39e0c222	alojamentos	contas/1783346006565_ENEL_-_R_DA_PRATA__336_-_06.2026_-_R__32_27.pdf	\N	2026-07-06 13:53:27.037168+00	2026-07-06 13:53:27.037168+00	2026-07-06 13:53:27.037168+00	{"eTag": "\\"aa0fcc103d55b08ef3b3a88a5c2b51d3\\"", "size": 927892, "mimetype": "application/pdf", "cacheControl": "max-age=3600", "lastModified": "2026-07-06T13:53:27.000Z", "contentLength": 927892, "httpStatusCode": 200}	6a8eb9f0-ebc0-451c-8eac-a1016af43462	\N	{}
9367ef70-b1db-47e5-95bc-af8cfae8ff53	funcionarios	fotos/1781876030405.jpg	\N	2026-06-19 13:33:50.811874+00	2026-06-19 13:33:50.811874+00	2026-06-19 13:33:50.811874+00	{"eTag": "\\"b0760ec235f4851b957d9e407f46959f\\"", "size": 10074, "mimetype": "image/jpeg", "cacheControl": "max-age=3600", "lastModified": "2026-06-19T13:33:51.000Z", "contentLength": 10074, "httpStatusCode": 200}	e0df990b-4807-4680-83e1-d9c1d267525c	\N	{}
0e77cd08-3dce-4424-8a58-f69cb570a167	funcionarios	fotos/1781876192057.png	\N	2026-06-19 13:36:32.698761+00	2026-06-19 13:36:32.698761+00	2026-06-19 13:36:32.698761+00	{"eTag": "\\"57bee9509d2465df58248b9e8f11aa4c\\"", "size": 42734, "mimetype": "image/png", "cacheControl": "max-age=3600", "lastModified": "2026-06-19T13:36:33.000Z", "contentLength": 42734, "httpStatusCode": 200}	8d530739-5052-47df-aa9b-8b5a60921f7e	\N	{}
4aff3317-be14-4dd8-9362-846f612542e4	funcionarios	fotos/1782395807073.jpeg	\N	2026-06-25 13:56:48.77659+00	2026-06-25 13:56:48.77659+00	2026-06-25 13:56:48.77659+00	{"eTag": "\\"ec3d1b5681bd3cfb8c852a5de311a66e\\"", "size": 178145, "mimetype": "image/jpeg", "cacheControl": "max-age=3600", "lastModified": "2026-06-25T13:56:49.000Z", "contentLength": 178145, "httpStatusCode": 200}	aa1aa746-1784-4ff7-9a3d-b7f0cad34500	\N	{}
d4d6d77a-8c4a-47bc-8b1a-ed60659cd416	funcionarios	fotos/1782408392167.png	\N	2026-06-25 17:26:32.994577+00	2026-06-25 17:26:32.994577+00	2026-06-25 17:26:32.994577+00	{"eTag": "\\"ac59d1867e0418e5559bb289d81f5285\\"", "size": 68043, "mimetype": "image/png", "cacheControl": "max-age=3600", "lastModified": "2026-06-25T17:26:33.000Z", "contentLength": 68043, "httpStatusCode": 200}	0d678981-40b9-441f-9688-b8b01f5866c7	\N	{}
c5c9983f-4531-4b8c-b3c2-3277cecb9983	alojamentos	contratos/1782417486377_24128-006_-_CONTRATO_-_FABRI_X_GTEL_-_CASA_-_RUA_ADALBERTO_MACHADO-assinado.pdf	\N	2026-06-25 19:58:09.012082+00	2026-06-25 19:58:09.012082+00	2026-06-25 19:58:09.012082+00	{"eTag": "\\"68d6ba250392b2d086b8a80fec93b755\\"", "size": 274903, "mimetype": "application/pdf", "cacheControl": "max-age=3600", "lastModified": "2026-06-25T19:58:09.000Z", "contentLength": 274903, "httpStatusCode": 200}	f442ac05-c1e9-455e-8b9c-bc9f10af54c8	\N	{}
2b7c6b0a-7c2b-4270-bc9f-c6bbe0494c78	funcionarios	fotos/1782477189137.png	\N	2026-06-26 12:33:10.306196+00	2026-06-26 12:33:10.306196+00	2026-06-26 12:33:10.306196+00	{"eTag": "\\"8804f86c62c7a9d7ed8665b0777d4367\\"", "size": 492391, "mimetype": "image/png", "cacheControl": "max-age=3600", "lastModified": "2026-06-26T12:33:11.000Z", "contentLength": 492391, "httpStatusCode": 200}	92347ac3-28b5-445c-970f-c3b2951300bc	\N	{}
a74aeb3b-4e6a-4c0a-8325-e70c8facb8e2	funcionarios	fotos/1782564172847.jpeg	\N	2026-06-27 12:42:53.461776+00	2026-06-27 12:42:53.461776+00	2026-06-27 12:42:53.461776+00	{"eTag": "\\"f36ab99a128867d73c06ef76d59b8b15\\"", "size": 30469, "mimetype": "image/jpeg", "cacheControl": "max-age=3600", "lastModified": "2026-06-27T12:42:54.000Z", "contentLength": 30469, "httpStatusCode": 200}	b547b969-c801-45d3-896e-d476e109a3d8	\N	{}
c1d5cf06-50dc-4dd9-b320-8b16e6ce56ff	funcionarios	fotos/1782564442799.png	\N	2026-06-27 12:47:23.840118+00	2026-06-27 12:47:23.840118+00	2026-06-27 12:47:23.840118+00	{"eTag": "\\"3191a2ed11581125c0d51ce176da353f\\"", "size": 162262, "mimetype": "image/png", "cacheControl": "max-age=3600", "lastModified": "2026-06-27T12:47:24.000Z", "contentLength": 162262, "httpStatusCode": 200}	290b6ff0-aac4-4f0c-91eb-4c36ff1f4209	\N	{}
f8b527ce-3a64-4db9-b413-ce8f276ee0c0	alojamentos	fotos/1782581285551_FOTOS.zip	\N	2026-06-27 17:28:07.372292+00	2026-06-27 17:28:07.372292+00	2026-06-27 17:28:07.372292+00	{"eTag": "\\"93ad219351673728aa8ac7f2e8ae2507\\"", "size": 751069, "mimetype": "application/x-zip-compressed", "cacheControl": "max-age=3600", "lastModified": "2026-06-27T17:28:08.000Z", "contentLength": 751069, "httpStatusCode": 200}	36f9f0ff-9492-48cc-9748-cc1216203244	\N	{}
5f1f34b2-4988-4887-92be-d34a2f9851d3	funcionarios	fotos/1782565381720.png	\N	2026-06-27 13:03:02.733152+00	2026-06-27 13:03:02.733152+00	2026-06-27 13:03:02.733152+00	{"eTag": "\\"e1290c4d3d8ca87f0a5760964d84c296\\"", "size": 237247, "mimetype": "image/png", "cacheControl": "max-age=3600", "lastModified": "2026-06-27T13:03:03.000Z", "contentLength": 237247, "httpStatusCode": 200}	60112fbb-be78-46fd-9314-34f717954a8a	\N	{}
a00427ce-4034-49ac-bdc7-a5a1f209dd25	funcionarios	fotos/1782565757406.png	\N	2026-06-27 13:09:18.448934+00	2026-06-27 13:09:18.448934+00	2026-06-27 13:09:18.448934+00	{"eTag": "\\"8d3f902f982ed5aaf7e7029d175436da\\"", "size": 151118, "mimetype": "image/png", "cacheControl": "max-age=3600", "lastModified": "2026-06-27T13:09:19.000Z", "contentLength": 151118, "httpStatusCode": 200}	0b9780b5-493e-43c0-bd90-78ce0411ffba	\N	{}
8e18dd72-6741-4fcd-8486-223d79cfa4f1	alojamentos	fotos/1782581639876_FOTO.zip	\N	2026-06-27 17:34:01.054284+00	2026-06-27 17:34:01.054284+00	2026-06-27 17:34:01.054284+00	{"eTag": "\\"7df5297ca1f9d6427dbdf502180c2f1b\\"", "size": 767771, "mimetype": "application/x-zip-compressed", "cacheControl": "max-age=3600", "lastModified": "2026-06-27T17:34:02.000Z", "contentLength": 767771, "httpStatusCode": 200}	ba2cff60-d754-47da-9c41-c0b23de89c31	\N	{}
d9e19e26-8bde-43d6-95f9-17ce3cff62af	funcionarios	fotos/1782565941373.jpg	\N	2026-06-27 13:12:21.665376+00	2026-06-27 13:12:21.665376+00	2026-06-27 13:12:21.665376+00	{"eTag": "\\"d3c6ed08658d66d996351b84ed4b4ee8\\"", "size": 11894, "mimetype": "image/jpeg", "cacheControl": "max-age=3600", "lastModified": "2026-06-27T13:12:22.000Z", "contentLength": 11894, "httpStatusCode": 200}	e96d5615-3385-4926-a65f-7d5d25a5750b	\N	{}
8f91c95f-6b1e-4ab1-843f-7a124e6b681e	alojamentos	contratos/1782567540620_I135-A1368675-alfredo-tarossi-junior-x-gtel-grupo-tecnico-eletromecanica-s_RUI_BARBOSA.pdf	\N	2026-06-27 13:39:02.142959+00	2026-06-27 13:39:02.142959+00	2026-06-27 13:39:02.142959+00	{"eTag": "\\"fcd978ad0b2439f73596895303d19bb7\\"", "size": 298346, "mimetype": "application/pdf", "cacheControl": "max-age=3600", "lastModified": "2026-06-27T13:39:03.000Z", "contentLength": 298346, "httpStatusCode": 200}	9fa0facc-4660-4778-9991-bc97cbec6660	\N	{}
58a32224-6f99-4beb-a33b-72cae99e330e	alojamentos	contratos/1782734772683_24104-015_-_FERNANDA_MARIA_BUSELLI_X_GTEL_-_RUA_RUSSIA_837.pdf	\N	2026-06-29 12:06:16.390123+00	2026-06-29 12:06:16.390123+00	2026-06-29 12:06:16.390123+00	{"eTag": "\\"f52161befc825e80d4702806cce46692\\"", "size": 2611916, "mimetype": "application/pdf", "cacheControl": "max-age=3600", "lastModified": "2026-06-29T12:06:17.000Z", "contentLength": 2611916, "httpStatusCode": 200}	ac3db79f-616b-4a49-b5ac-9068eca7f449	\N	{}
f550e9e7-72b8-45fa-b2fd-5a62e308d08f	alojamentos	laudos/1782567542555_RELATORIO_ESTRUTURAL_10.pdf	\N	2026-06-27 13:39:04.445573+00	2026-06-27 13:39:04.445573+00	2026-06-27 13:39:04.445573+00	{"eTag": "\\"6539f0b2410fe4e35ab1be5b00fac8dc\\"", "size": 1101607, "mimetype": "application/pdf", "cacheControl": "max-age=3600", "lastModified": "2026-06-27T13:39:05.000Z", "contentLength": 1101607, "httpStatusCode": 200}	f14fee3c-bcc6-4814-b0b5-c8b3906f0727	\N	{}
11250443-08ec-4a5f-9109-c8d59f85186c	alojamentos	fotos/1782567544834_foto.zip	\N	2026-06-27 13:39:07.731208+00	2026-06-27 13:39:07.731208+00	2026-06-27 13:39:07.731208+00	{"eTag": "\\"7a8ae60bd3149db6446030ef862fe5f9\\"", "size": 2374016, "mimetype": "application/x-zip-compressed", "cacheControl": "max-age=3600", "lastModified": "2026-06-27T13:39:08.000Z", "contentLength": 2374016, "httpStatusCode": 200}	66ecde1a-92d1-47ec-ad82-ee610579ecb7	\N	{}
4dbc1cfa-97ff-494b-aa79-677c6e20dc8a	alojamentos	contratos/1782567549086_I135-A1368675-alfredo-tarossi-junior-x-gtel-grupo-tecnico-eletromecanica-s_RUI_BARBOSA.pdf	\N	2026-06-27 13:39:09.713097+00	2026-06-27 13:39:09.713097+00	2026-06-27 13:39:09.713097+00	{"eTag": "\\"fcd978ad0b2439f73596895303d19bb7\\"", "size": 298346, "mimetype": "application/pdf", "cacheControl": "max-age=3600", "lastModified": "2026-06-27T13:39:10.000Z", "contentLength": 298346, "httpStatusCode": 200}	00b01c0f-0a9b-4517-b745-b517b20f0453	\N	{}
22f47cc2-7f2b-4fe2-856f-43c1622d7430	funcionarios	fotos/1782568010319.png	\N	2026-06-27 13:46:50.89928+00	2026-06-27 13:46:50.89928+00	2026-06-27 13:46:50.89928+00	{"eTag": "\\"1070a75a79f83370ac9698e6e7a0f5d1\\"", "size": 383224, "mimetype": "image/png", "cacheControl": "max-age=3600", "lastModified": "2026-06-27T13:46:51.000Z", "contentLength": 383224, "httpStatusCode": 200}	345dcb09-202d-441b-8bac-21ec728c0ad1	\N	{}
82a2737a-e152-4540-bb88-db573dabb484	alojamentos	laudos/1782568710692_RELATORIO_ESTRUTURAL_13.pdf	\N	2026-06-27 13:58:32.672781+00	2026-06-27 13:58:32.672781+00	2026-06-27 13:58:32.672781+00	{"eTag": "\\"93245061b313a2ea27911b8a5772f576\\"", "size": 2062910, "mimetype": "application/pdf", "cacheControl": "max-age=3600", "lastModified": "2026-06-27T13:58:33.000Z", "contentLength": 2062910, "httpStatusCode": 200}	7f275e3a-cbbd-47ab-aa2a-f1b611ea656d	\N	{}
5c46472f-5fc1-4bd9-b1a5-d57fb5370786	alojamentos	fotos/1782568713103_FOTOS.zip	\N	2026-06-27 13:58:36.041826+00	2026-06-27 13:58:36.041826+00	2026-06-27 13:58:36.041826+00	{"eTag": "\\"3061100a96efb216e0b0b64c17a8d768\\"", "size": 1738760, "mimetype": "application/x-zip-compressed", "cacheControl": "max-age=3600", "lastModified": "2026-06-27T13:58:36.000Z", "contentLength": 1738760, "httpStatusCode": 200}	f26952dc-93dd-4e18-b8f6-8ed787ff487c	\N	{}
5c8a08e3-1f67-4a87-b44c-5dd8aaad8265	alojamentos	laudos/1782582527554_RELATORIO_ESTRUTURAL_13.docx	\N	2026-06-27 17:48:56.193077+00	2026-06-27 17:48:56.193077+00	2026-06-27 17:48:56.193077+00	{"eTag": "\\"489859ba37f8f8ee3c906ee5887c2030\\"", "size": 8578238, "mimetype": "application/vnd.openxmlformats-officedocument.wordprocessingml.document", "cacheControl": "max-age=3600", "lastModified": "2026-06-27T17:48:57.000Z", "contentLength": 8578238, "httpStatusCode": 200}	bf90634c-6e74-4af8-903f-df2672cc7f91	\N	{}
b7c5abef-e230-42be-b262-4f4efc9cc806	alojamentos	fotos/1782569588538_LAUDO_DE_VISTORIA_-_ICONNE_X_GTEL_-_RUA_DA_PRATA_.pdf_-_Alude.pdf	\N	2026-06-27 14:13:09.923628+00	2026-06-27 14:13:09.923628+00	2026-06-27 14:13:09.923628+00	{"eTag": "\\"50446add1d04cf65c0f593c7366c9e06\\"", "size": 3122119, "mimetype": "application/pdf", "cacheControl": "max-age=3600", "lastModified": "2026-06-27T14:13:10.000Z", "contentLength": 3122119, "httpStatusCode": 200}	af8b420f-299d-4a03-8533-ad409a766a21	\N	{}
414994c1-909d-4a0a-8746-bc7591eb01fe	alojamentos	laudos/1782569643321_RELATORIO_ESTRUTURAL_14.pdf	\N	2026-06-27 14:14:05.440211+00	2026-06-27 14:14:05.440211+00	2026-06-27 14:14:05.440211+00	{"eTag": "\\"33ecaf504d8ae49a6a65d3c943cb90c9\\"", "size": 1580901, "mimetype": "application/pdf", "cacheControl": "max-age=3600", "lastModified": "2026-06-27T14:14:06.000Z", "contentLength": 1580901, "httpStatusCode": 200}	fe869331-b668-4491-8e09-d7afb62d9b9c	\N	{}
ab6808d3-d4cc-4c37-b65b-27512110366a	alojamentos	fotos/1782582536811_foto.zip	\N	2026-06-27 17:48:58.88479+00	2026-06-27 17:48:58.88479+00	2026-06-27 17:48:58.88479+00	{"eTag": "\\"d0e69650889937fb92bf20b1e6c6c4e9\\"", "size": 1654444, "mimetype": "application/x-zip-compressed", "cacheControl": "max-age=3600", "lastModified": "2026-06-27T17:48:59.000Z", "contentLength": 1654444, "httpStatusCode": 200}	3c8ec557-e933-41ee-9edd-e07c40181830	\N	{}
36338a99-c9fa-40e0-889e-d09f43d8ddae	alojamentos	fotos/1782569645867_I135-A1377533-rafael-rogerio-moraes-x-gtel-grupo-tecnico-eletromecanica-s_-_SAO_TOME.pdf	\N	2026-06-27 14:14:09.935144+00	2026-06-27 14:14:09.935144+00	2026-06-27 14:14:09.935144+00	{"eTag": "\\"6e3696a464e5cd0696b69f58abd12b50\\"", "size": 2575629, "mimetype": "application/pdf", "cacheControl": "max-age=3600", "lastModified": "2026-06-27T14:14:10.000Z", "contentLength": 2575629, "httpStatusCode": 200}	2935b755-a4c5-41d8-bee5-50e2953713dd	\N	{}
66dddb09-5e2f-41b9-ad6d-ff5cffcb0c3c	alojamentos	contratos/1782570085692_I135-A1377533-rafael-rogerio-moraes-x-gtel-grupo-tecnico-eletromecanica-s_-_SAO_TOME.pdf	\N	2026-06-27 14:21:28.966941+00	2026-06-27 14:21:28.966941+00	2026-06-27 14:21:28.966941+00	{"eTag": "\\"6e3696a464e5cd0696b69f58abd12b50\\"", "size": 2575629, "mimetype": "application/pdf", "cacheControl": "max-age=3600", "lastModified": "2026-06-27T14:21:29.000Z", "contentLength": 2575629, "httpStatusCode": 200}	d5819d10-e46a-4e34-9f4e-da314e1f495d	\N	{}
d3041486-cea0-45f0-a66f-00321281d0de	alojamentos	laudos/1782736357195_RELATORIO_ESTRUTURAL_20.pdf	\N	2026-06-29 12:32:38.377881+00	2026-06-29 12:32:38.377881+00	2026-06-29 12:32:38.377881+00	{"eTag": "\\"cdcc6ea62599a278edf87b9d8e37294d\\"", "size": 1489319, "mimetype": "application/pdf", "cacheControl": "max-age=3600", "lastModified": "2026-06-29T12:32:39.000Z", "contentLength": 1489319, "httpStatusCode": 200}	fd750a91-d0ae-4698-98a0-ee95e5a6fbb8	\N	{}
32ea1fd0-8690-48ac-a27a-b8f5046f7452	alojamentos	laudos/1782570089405_RELATORIO_ESTRUTURAL_14.pdf	\N	2026-06-27 14:21:30.599926+00	2026-06-27 14:21:30.599926+00	2026-06-27 14:21:30.599926+00	{"eTag": "\\"33ecaf504d8ae49a6a65d3c943cb90c9\\"", "size": 1580901, "mimetype": "application/pdf", "cacheControl": "max-age=3600", "lastModified": "2026-06-27T14:21:31.000Z", "contentLength": 1580901, "httpStatusCode": 200}	483b1d5e-3b6a-4d5e-a74a-b8479978467e	\N	{}
2977317c-e67a-415e-a26f-e3591690794a	alojamentos	contratos/1782570099017_I135-A1377533-rafael-rogerio-moraes-x-gtel-grupo-tecnico-eletromecanica-s_-_SAO_TOME.pdf	\N	2026-06-27 14:21:42.671452+00	2026-06-27 14:21:42.671452+00	2026-06-27 14:21:42.671452+00	{"eTag": "\\"6e3696a464e5cd0696b69f58abd12b50\\"", "size": 2575629, "mimetype": "application/pdf", "cacheControl": "max-age=3600", "lastModified": "2026-06-27T14:21:43.000Z", "contentLength": 2575629, "httpStatusCode": 200}	06faa0c2-73b5-44e2-b511-8dc8e95e545c	\N	{}
de7fb1a5-4cd6-497f-82eb-877ca6fda381	alojamentos	laudos/1782570103118_RELATORIO_ESTRUTURAL_14.pdf	\N	2026-06-27 14:21:47.431623+00	2026-06-27 14:21:47.431623+00	2026-06-27 14:21:47.431623+00	{"eTag": "\\"33ecaf504d8ae49a6a65d3c943cb90c9\\"", "size": 1580901, "mimetype": "application/pdf", "cacheControl": "max-age=3600", "lastModified": "2026-06-27T14:21:48.000Z", "contentLength": 1580901, "httpStatusCode": 200}	2aec7492-0d8a-40be-9f98-10f3610235ef	\N	{}
10520466-d86e-4b9c-87b3-a74334657759	alojamentos	contratos/1782570116481_I135-A1377533-rafael-rogerio-moraes-x-gtel-grupo-tecnico-eletromecanica-s_-_SAO_TOME.pdf	\N	2026-06-27 14:22:02.592958+00	2026-06-27 14:22:02.592958+00	2026-06-27 14:22:02.592958+00	{"eTag": "\\"6e3696a464e5cd0696b69f58abd12b50\\"", "size": 2575629, "mimetype": "application/pdf", "cacheControl": "max-age=3600", "lastModified": "2026-06-27T14:22:03.000Z", "contentLength": 2575629, "httpStatusCode": 200}	b17a58be-3314-4427-9a56-1056172f3ca8	\N	{}
8df92bbe-4b92-4cde-aed3-8a679e46a793	alojamentos	contratos/1782583874409_24104-001_-_Silvana_Carvalho_x_Gtel_-_Rua_Adolfo_Rodrigues_de_Arruda,_86_.pdf	\N	2026-06-27 18:11:17.728968+00	2026-06-27 18:11:17.728968+00	2026-06-27 18:11:17.728968+00	{"eTag": "\\"80753a8520f013e5ea8d1e79a4b01ba0\\"", "size": 3646136, "mimetype": "application/pdf", "cacheControl": "max-age=3600", "lastModified": "2026-06-27T18:11:18.000Z", "contentLength": 3646136, "httpStatusCode": 200}	3836e362-2871-4deb-9f85-f36daeb56d63	\N	{}
b21c977a-5ab9-4c0f-a629-d83a15d6c905	alojamentos	contratos/1782570117797_I135-A1377533-rafael-rogerio-moraes-x-gtel-grupo-tecnico-eletromecanica-s_-_SAO_TOME.pdf	\N	2026-06-27 14:22:03.071189+00	2026-06-27 14:22:03.071189+00	2026-06-27 14:22:03.071189+00	{"eTag": "\\"6e3696a464e5cd0696b69f58abd12b50\\"", "size": 2575629, "mimetype": "application/pdf", "cacheControl": "max-age=3600", "lastModified": "2026-06-27T14:22:04.000Z", "contentLength": 2575629, "httpStatusCode": 200}	e4ab2dff-224c-417d-83fa-94fccc2f1c8c	\N	{}
5137e2b9-7a00-48f4-b2fd-0d4fc030da98	alojamentos	fotos/1782570091032_foto.zip	\N	2026-06-27 14:22:04.776409+00	2026-06-27 14:22:04.776409+00	2026-06-27 14:22:04.776409+00	{"eTag": "\\"b42f53fa7e3fc8ac327461ac60bc7d4f-2\\"", "size": 25304516, "mimetype": "application/x-zip-compressed", "cacheControl": "max-age=3600", "lastModified": "2026-06-27T14:22:05.000Z", "contentLength": 25304516, "httpStatusCode": 200}	97514680-793e-44bc-ac75-6bd20ed33f32	\N	{}
6e2a5ff3-86fe-4234-b791-73b655865882	alojamentos	laudos/1782583878296_RELATORIO_ESTRUTURAL_06.pdf	\N	2026-06-27 18:11:19.496959+00	2026-06-27 18:11:19.496959+00	2026-06-27 18:11:19.496959+00	{"eTag": "\\"d35881def83a4c16b0fbe863729a9909\\"", "size": 1637326, "mimetype": "application/pdf", "cacheControl": "max-age=3600", "lastModified": "2026-06-27T18:11:20.000Z", "contentLength": 1637326, "httpStatusCode": 200}	66d874d9-b1e6-4339-850b-5e6850588684	\N	{}
e82c6d74-253a-4e08-8e1c-82a859ab3bb0	alojamentos	laudos/1782570123020_RELATORIO_ESTRUTURAL_14.pdf	\N	2026-06-27 14:22:05.00934+00	2026-06-27 14:22:05.00934+00	2026-06-27 14:22:05.00934+00	{"eTag": "\\"33ecaf504d8ae49a6a65d3c943cb90c9\\"", "size": 1580901, "mimetype": "application/pdf", "cacheControl": "max-age=3600", "lastModified": "2026-06-27T14:22:05.000Z", "contentLength": 1580901, "httpStatusCode": 200}	cd1ecb89-1454-4f35-b4c0-9db626e8ccb3	\N	{}
1ef50040-b799-45dd-8f62-6d618dc7f5c0	alojamentos	laudos/1782570123522_RELATORIO_ESTRUTURAL_14.pdf	\N	2026-06-27 14:22:05.450666+00	2026-06-27 14:22:05.450666+00	2026-06-27 14:22:05.450666+00	{"eTag": "\\"33ecaf504d8ae49a6a65d3c943cb90c9\\"", "size": 1580901, "mimetype": "application/pdf", "cacheControl": "max-age=3600", "lastModified": "2026-06-27T14:22:06.000Z", "contentLength": 1580901, "httpStatusCode": 200}	bb944b26-92d0-458b-8ba8-5295d5e5af1b	\N	{}
ef194c7c-8e78-4d63-91d1-85bf533d50be	alojamentos	laudos/1782584222425_RELATORIO_ESTRUTURAL_07_at.pdf	\N	2026-06-27 18:17:03.556053+00	2026-06-27 18:17:03.556053+00	2026-06-27 18:17:03.556053+00	{"eTag": "\\"d02f9491cfade1d320d9db955407eb8b\\"", "size": 750715, "mimetype": "application/pdf", "cacheControl": "max-age=3600", "lastModified": "2026-06-27T18:17:04.000Z", "contentLength": 750715, "httpStatusCode": 200}	4ecb208c-1c47-4d1f-a7eb-0fd60260ac81	\N	{}
4339bd70-dba3-4afb-b864-736ae47d8448	alojamentos	fotos/1782570141552_Termo_de_Vistoria__Cruz_Preta_GLR01_-_Alude.pdf	\N	2026-06-27 14:22:22.846953+00	2026-06-27 14:22:22.846953+00	2026-06-27 14:22:22.846953+00	{"eTag": "\\"cbca06e584ca00de9cf79ece062901f6\\"", "size": 2512298, "mimetype": "application/pdf", "cacheControl": "max-age=3600", "lastModified": "2026-06-27T14:22:23.000Z", "contentLength": 2512298, "httpStatusCode": 200}	06e1b983-04ca-4f53-8774-eda75d144c88	\N	{}
58749af7-a560-4355-b35c-3127b59ed801	alojamentos	fotos/1782584224117_FOTO.zip	\N	2026-06-27 18:17:05.241694+00	2026-06-27 18:17:05.241694+00	2026-06-27 18:17:05.241694+00	{"eTag": "\\"157cdd03f9896dca6388732cc0d92f4b\\"", "size": 1295288, "mimetype": "application/x-zip-compressed", "cacheControl": "max-age=3600", "lastModified": "2026-06-27T18:17:06.000Z", "contentLength": 1295288, "httpStatusCode": 200}	10de90ac-0af8-47cc-82dd-335f01a44b9e	\N	{}
5c1ee1ad-e70a-43d9-90cc-290f74a732d7	alojamentos	laudos/1782584524350_RELATORIO_ESTRUTURAL_11.pdf	\N	2026-06-27 18:22:06.80802+00	2026-06-27 18:22:06.80802+00	2026-06-27 18:22:06.80802+00	{"eTag": "\\"2d2ea5f674038c9e1f140fdde2ad8ead\\"", "size": 1545812, "mimetype": "application/pdf", "cacheControl": "max-age=3600", "lastModified": "2026-06-27T18:22:07.000Z", "contentLength": 1545812, "httpStatusCode": 200}	3965aabb-d7fd-4810-9470-6c84e0bf933f	\N	{}
1a0e43fc-4afc-4c24-90bc-e951f97d7b51	alojamentos	contas/1783346071312_ENEL_-_R_DAS_ORQUIDEAS__71_-_07.2026_-_R__166_97.pdf	\N	2026-07-06 13:54:49.788538+00	2026-07-06 13:54:49.788538+00	2026-07-06 13:54:49.788538+00	{"eTag": "\\"71ef6864a2a742af553871130aa6007c\\"", "size": 936505, "mimetype": "application/pdf", "cacheControl": "max-age=3600", "lastModified": "2026-07-06T13:54:50.000Z", "contentLength": 936505, "httpStatusCode": 200}	46fb71a2-dd23-4692-b5c7-b5821f09142e	\N	{}
28e2112b-d389-458e-bf37-483f31d0b10a	alojamentos	contas/1783346266752_ENEL_-_R_DR_FAUSTO__49_-_06.2026_-_R__165_61.pdf	\N	2026-07-06 13:57:48.037538+00	2026-07-06 13:57:48.037538+00	2026-07-06 13:57:48.037538+00	{"eTag": "\\"73d8bf75a1a1c2af880f53faa02b593c\\"", "size": 927947, "mimetype": "application/pdf", "cacheControl": "max-age=3600", "lastModified": "2026-07-06T13:57:48.000Z", "contentLength": 927947, "httpStatusCode": 200}	b3984708-ee82-45fb-a996-8dddfeab30fe	\N	{}
cf7ef992-3720-432e-a77d-d7be6e5bd235	alojamentos	contas/1783346309981_ENEL_-_R_PROF_ELVIRA__388_-_07.2026_-_R__137_97.pdf	\N	2026-07-06 13:58:31.45571+00	2026-07-06 13:58:31.45571+00	2026-07-06 13:58:31.45571+00	{"eTag": "\\"f3c8bf14327c1939de2206c2cb9716df\\"", "size": 935944, "mimetype": "application/pdf", "cacheControl": "max-age=3600", "lastModified": "2026-07-06T13:58:32.000Z", "contentLength": 935944, "httpStatusCode": 200}	f0c6b97b-98f6-41fa-9324-3e5e0cf4a9aa	\N	{}
6ac0187c-0acb-44e9-97ef-710178cc8168	alojamentos	contas/1783346353806_ENEL_-_R_SAO_FRANCISCO__20B_-_07.2026_-_R__43_97.pdf	\N	2026-07-06 13:59:14.465447+00	2026-07-06 13:59:14.465447+00	2026-07-06 13:59:14.465447+00	{"eTag": "\\"7530569d2a469bab48e6edb3e5a5e12b\\"", "size": 927266, "mimetype": "application/pdf", "cacheControl": "max-age=3600", "lastModified": "2026-07-06T13:59:15.000Z", "contentLength": 927266, "httpStatusCode": 200}	89ac162f-5035-4c39-baa2-62e7f748831f	\N	{}
78052bf1-b15d-4fd6-80c8-3a7cd0448926	alojamentos	contas/1783346394974_SABESP_-_R_PROF_ELVIRA__338_-_06.2026_-_R__188_75.pdf	\N	2026-07-06 13:59:55.331488+00	2026-07-06 13:59:55.331488+00	2026-07-06 13:59:55.331488+00	{"eTag": "\\"f362e4f3ae8f001ac5d443f9d85ff5e4\\"", "size": 133899, "mimetype": "application/pdf", "cacheControl": "max-age=3600", "lastModified": "2026-07-06T13:59:56.000Z", "contentLength": 133899, "httpStatusCode": 200}	501dba4a-1b4e-47b5-a38b-a9913aff2e64	\N	{}
0fe4b839-f6f5-4b44-8c16-e1a292cd3131	alojamentos	contas/1783346566892_ENEL_-_R_DA_PRATA__336_-_05.2026_-_R__183_16.pdf	\N	2026-07-06 14:02:47.922255+00	2026-07-06 14:02:47.922255+00	2026-07-06 14:02:47.922255+00	{"eTag": "\\"fdc90cb7cba401a080dc88d33fa10d5c\\"", "size": 929341, "mimetype": "application/pdf", "cacheControl": "max-age=3600", "lastModified": "2026-07-06T14:02:48.000Z", "contentLength": 929341, "httpStatusCode": 200}	2bc8571c-c6b8-4a3d-891e-6c0dbaa7b3b4	\N	{}
1438c407-3664-4996-8653-2bdbcd32a731	funcionarios	fotos/1783457279470.png	\N	2026-07-07 20:48:04.782895+00	2026-07-07 20:48:04.782895+00	2026-07-07 20:48:04.782895+00	{"eTag": "\\"d472b6304f91355f6ba02994a21ce4c3\\"", "size": 32072, "mimetype": "image/png", "cacheControl": "max-age=3600", "lastModified": "2026-07-07T20:48:05.000Z", "contentLength": 32072, "httpStatusCode": 200}	b83fd549-e6ca-4a58-9e15-32ee2f723491	\N	{}
8153af50-5525-47d5-9713-4c55448aaaef	funcionarios	fotos/1783457282064.png	\N	2026-07-07 20:48:04.786101+00	2026-07-07 20:48:04.786101+00	2026-07-07 20:48:04.786101+00	{"eTag": "\\"d472b6304f91355f6ba02994a21ce4c3\\"", "size": 32072, "mimetype": "image/png", "cacheControl": "max-age=3600", "lastModified": "2026-07-07T20:48:05.000Z", "contentLength": 32072, "httpStatusCode": 200}	97979f61-5653-4657-b050-5eab1e9d62ac	\N	{}
2c260d46-1c77-4eda-91d6-0d61af939e8b	funcionarios	fotos/1783457564349.png	\N	2026-07-07 20:52:45.388392+00	2026-07-07 20:52:45.388392+00	2026-07-07 20:52:45.388392+00	{"eTag": "\\"c46054144a205277dcc50c6e2d3d44d0\\"", "size": 41467, "mimetype": "image/png", "cacheControl": "max-age=3600", "lastModified": "2026-07-07T20:52:46.000Z", "contentLength": 41467, "httpStatusCode": 200}	96e9ac71-0863-4345-94cd-1b2fc88d5e14	\N	{}
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
-- Name: passagens_seq_number; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.passagens_seq_number', 3, true);


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
-- Name: fornecedor_orcamentos fornecedor_orcamentos_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.fornecedor_orcamentos
    ADD CONSTRAINT fornecedor_orcamentos_pkey PRIMARY KEY (id);


--
-- Name: fornecedores fornecedores_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.fornecedores
    ADD CONSTRAINT fornecedores_pkey PRIMARY KEY (id);


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
-- Name: matriz_contatos matriz_contatos_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.matriz_contatos
    ADD CONSTRAINT matriz_contatos_pkey PRIMARY KEY (id);


--
-- Name: obras obras_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.obras
    ADD CONSTRAINT obras_pkey PRIMARY KEY (id);


--
-- Name: passagens passagens_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.passagens
    ADD CONSTRAINT passagens_pkey PRIMARY KEY (id);


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
-- Name: treinamentos treinamentos_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.treinamentos
    ADD CONSTRAINT treinamentos_pkey PRIMARY KEY (id);


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
-- Name: idx_passagens_funcionario; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_passagens_funcionario ON public.passagens USING btree (funcionario_id);


--
-- Name: idx_passagens_obra; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_passagens_obra ON public.passagens USING btree (obra_id);


--
-- Name: idx_passagens_seq; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_passagens_seq ON public.passagens USING btree (seq);


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
-- Name: fornecedor_orcamentos fornecedor_orcamentos_fornecedor_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.fornecedor_orcamentos
    ADD CONSTRAINT fornecedor_orcamentos_fornecedor_id_fkey FOREIGN KEY (fornecedor_id) REFERENCES public.fornecedores(id) ON DELETE CASCADE;


--
-- Name: fornecedores fornecedores_obra_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.fornecedores
    ADD CONSTRAINT fornecedores_obra_id_fkey FOREIGN KEY (obra_id) REFERENCES public.obras(id);


--
-- Name: funcionarios funcionarios_alojamento_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.funcionarios
    ADD CONSTRAINT funcionarios_alojamento_id_fkey FOREIGN KEY (alojamento_id) REFERENCES public.alojamentos(id) ON DELETE SET NULL;


--
-- Name: funcionarios funcionarios_alojamento_origem_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.funcionarios
    ADD CONSTRAINT funcionarios_alojamento_origem_id_fkey FOREIGN KEY (alojamento_origem_id) REFERENCES public.alojamentos(id);


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
-- Name: passagens passagens_funcionario_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.passagens
    ADD CONSTRAINT passagens_funcionario_id_fkey FOREIGN KEY (funcionario_id) REFERENCES public.funcionarios(id);


--
-- Name: passagens passagens_obra_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.passagens
    ADD CONSTRAINT passagens_obra_id_fkey FOREIGN KEY (obra_id) REFERENCES public.obras(id);


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
-- Name: treinamentos treinamentos_funcionario_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.treinamentos
    ADD CONSTRAINT treinamentos_funcionario_id_fkey FOREIGN KEY (funcionario_id) REFERENCES public.funcionarios(id) ON DELETE CASCADE;


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
-- Name: passagens Permitir tudo - passagens; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Permitir tudo - passagens" ON public.passagens USING (true) WITH CHECK (true);


--
-- Name: usuarios_acesso acesso_publico_usuarios; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY acesso_publico_usuarios ON public.usuarios_acesso TO authenticated, anon USING (true) WITH CHECK (true);


--
-- Name: treinamentos allow all; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "allow all" ON public.treinamentos USING (true);


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
-- Name: alojamentos_relatorios alojamentos_relatorios_all; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY alojamentos_relatorios_all ON public.alojamentos_relatorios USING (true) WITH CHECK (true);


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
-- Name: fornecedor_orcamentos; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.fornecedor_orcamentos ENABLE ROW LEVEL SECURITY;

--
-- Name: fornecedor_orcamentos fornecedor_orcamentos_all; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY fornecedor_orcamentos_all ON public.fornecedor_orcamentos USING (true) WITH CHECK (true);


--
-- Name: fornecedores; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.fornecedores ENABLE ROW LEVEL SECURITY;

--
-- Name: fornecedores fornecedores_all; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY fornecedores_all ON public.fornecedores USING (true) WITH CHECK (true);


--
-- Name: funcionarios; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.funcionarios ENABLE ROW LEVEL SECURITY;

--
-- Name: funcoes; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.funcoes ENABLE ROW LEVEL SECURITY;

--
-- Name: matriz_contatos; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.matriz_contatos ENABLE ROW LEVEL SECURITY;

--
-- Name: matriz_contatos matriz_contatos_anon_all; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY matriz_contatos_anon_all ON public.matriz_contatos USING (true) WITH CHECK (true);


--
-- Name: obras; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.obras ENABLE ROW LEVEL SECURITY;

--
-- Name: passagens; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.passagens ENABLE ROW LEVEL SECURITY;

--
-- Name: prestadores; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.prestadores ENABLE ROW LEVEL SECURITY;

--
-- Name: prestadores_presenca; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.prestadores_presenca ENABLE ROW LEVEL SECURITY;

--
-- Name: treinamentos; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.treinamentos ENABLE ROW LEVEL SECURITY;

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
-- Name: objects fornecedores_storage_delete; Type: POLICY; Schema: storage; Owner: -
--

CREATE POLICY fornecedores_storage_delete ON storage.objects FOR DELETE USING ((bucket_id = 'fornecedores'::text));


--
-- Name: objects fornecedores_storage_read; Type: POLICY; Schema: storage; Owner: -
--

CREATE POLICY fornecedores_storage_read ON storage.objects FOR SELECT USING ((bucket_id = 'fornecedores'::text));


--
-- Name: objects fornecedores_storage_update; Type: POLICY; Schema: storage; Owner: -
--

CREATE POLICY fornecedores_storage_update ON storage.objects FOR UPDATE USING ((bucket_id = 'fornecedores'::text));


--
-- Name: objects fornecedores_storage_write; Type: POLICY; Schema: storage; Owner: -
--

CREATE POLICY fornecedores_storage_write ON storage.objects FOR INSERT WITH CHECK ((bucket_id = 'fornecedores'::text));


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

\unrestrict IgbrIEp1p93anfUa3PZfqcGk6NPJLV8IhPRGEEgRBel6b3TEd3W2gygno57eaDv

