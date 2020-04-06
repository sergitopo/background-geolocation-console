-- please create DB
--
-- CREATE DATABASE geolocation;
-- \connect geolocation
CREATE EXTENSION POSTGIS;

CREATE TABLE if not exists coronatrack.companies (
    id integer NOT NULL,
    company_token text,
    created_at timestamp with time zone,
    updated_at timestamp with time zone
);

CREATE SEQUENCE if not exists coronatrack.companies_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE coronatrack.companies_id_seq OWNED BY coronatrack.companies.id;

CREATE TABLE if not exists coronatrack.devices (
    id integer NOT NULL,
    company_id integer,
    company_token text,
    device_id text,
    device_model text,
    created_at timestamp with time zone,
    framework text,
    version text,
    updated_at timestamp with time zone
);


CREATE SEQUENCE if not exists coronatrack.devices_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;



ALTER SEQUENCE coronatrack.devices_id_seq OWNED BY coronatrack.devices.id;

CREATE SEQUENCE if not exists coronatrack.locations_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

CREATE TABLE if not exists coronatrack.locations (
    id integer DEFAULT nextval('coronatrack.locations_id_seq'::regclass) NOT NULL,
    latitude double precision,
    longitude double precision,
    the_geom geometry,
    recorded_at timestamp with time zone,
    created_at timestamp with time zone,
    company_id integer,
    device_id integer,
    data jsonb,
    uuid text
);


ALTER TABLE ONLY coronatrack.companies ALTER COLUMN id SET DEFAULT nextval('coronatrack.companies_id_seq'::regclass);
ALTER TABLE ONLY coronatrack.devices ALTER COLUMN id SET DEFAULT nextval('coronatrack.devices_id_seq'::regclass);

DO $$
BEGIN

  BEGIN
    ALTER TABLE ONLY coronatrack.companies ADD CONSTRAINT companies_pkey PRIMARY KEY (id);
  EXCEPTION
    WHEN others THEN RAISE NOTICE 'Table constraint coronatrack.companies already exists';
  END;

END $$;


DO $$
BEGIN

  BEGIN
    ALTER TABLE ONLY coronatrack.devices ADD CONSTRAINT devices_pkey PRIMARY KEY (id);
  EXCEPTION
    WHEN others THEN RAISE NOTICE 'Table constraint coronatrack.devices already exists';
  END;

END $$;


DO $$
BEGIN

  BEGIN
    ALTER TABLE ONLY coronatrack.locations ADD CONSTRAINT locations_pkey PRIMARY KEY (id);
  EXCEPTION
    WHEN others THEN RAISE NOTICE 'Table constraint coronatrack.locations already exists';
  END;

END $$;



CREATE INDEX if not exists devices_company_id ON coronatrack.devices USING btree (company_id);
CREATE INDEX if not exists devices_company_token ON coronatrack.devices USING btree (company_token);
CREATE INDEX if not exists devices_device_id ON coronatrack.devices USING btree (device_id);
CREATE INDEX if not exists locations_company_id_device_id_recorded_at ON coronatrack.locations USING btree (company_id, device_id, recorded_at);
CREATE INDEX if not exists locations_company_id_device_ref_id_recorded_at ON coronatrack.locations USING btree (company_id, device_id, recorded_at);
CREATE INDEX if not exists locations_device_id ON coronatrack.locations USING btree (device_id);
CREATE INDEX if not exists locations_recorded_at ON coronatrack.locations USING btree (recorded_at);

DO $$
BEGIN

  BEGIN
    ALTER TABLE ONLY coronatrack.devices
       ADD CONSTRAINT devices_company_id_fkey FOREIGN KEY (company_id) REFERENCES coronatrack.companies(id) ON UPDATE CASCADE ON DELETE CASCADE;
  EXCEPTION
    WHEN others THEN RAISE NOTICE 'Table fk constraint coronatrack.devices already exists';
  END;

END $$;

DO $$
BEGIN

  BEGIN
  ALTER TABLE ONLY coronatrack.locations
       ADD CONSTRAINT locations_company_id_fkey FOREIGN KEY (company_id) REFERENCES coronatrack.companies(id) ON UPDATE CASCADE ON DELETE CASCADE;
  EXCEPTION
    WHEN others THEN RAISE NOTICE 'Table fk constraint coronatrack.locations:company already exists';
  END;

END $$;


DO $$
BEGIN

  BEGIN
    ALTER TABLE ONLY coronatrack.locations
       ADD CONSTRAINT locations_device_id_fkey FOREIGN KEY (device_id) REFERENCES coronatrack.devices(id) ON UPDATE CASCADE ON DELETE CASCADE;
  EXCEPTION
    WHEN others THEN RAISE NOTICE 'Table fk constraint coronatrack.locations:device already exists';
  END;

END $$;
CREATE OR REPLACE FUNCTION coronatrack.fnc_setLocationGeometry() RETURNS trigger AS $fn_test_table_geo_update_event$
  BEGIN  
  -- as this is an after trigger, NEW contains all the information we need even for INSERT
  UPDATE coronatrack.locations SET 
  the_geom = ST_SetSRID(ST_MakePoint(NEW.longitude,NEW.latitude), 4326) WHERE id=NEW.id;

  RAISE NOTICE 'UPDATING geo data for %, [%,%]' , NEW.id, NEW.latitude, NEW.longitude;  
    RETURN NULL; -- result is ignored since this is an AFTER trigger
  END;
$fn_test_table_geo_update_event$ LANGUAGE plpgsql;

ALTER FUNCTION coronatrack.fnc_setLocationGeometry()
    OWNER TO local_space_cartagena;

-- INSERT trigger
DROP TRIGGER IF EXISTS locations_inserted ON locations;
CREATE TRIGGER locations_inserted
  AFTER INSERT ON coronatrack.locations
  FOR EACH ROW
  EXECUTE PROCEDURE coronatrack.fnc_setLocationGeometry();


 --  UPDATE trigger
DROP TRIGGER IF EXISTS locations_updated ON locations;
CREATE TRIGGER locations_updated
  AFTER UPDATE OF 
  latitude,
  longitude
  ON coronatrack.locations
  FOR EACH ROW
  EXECUTE PROCEDURE coronatrack.fnc_setLocationGeometry();


GRANT SELECT,USAGE ON SEQUENCE coronatrack.companies_id_seq TO main;
GRANT SELECT,USAGE ON SEQUENCE coronatrack.devices_id_seq TO main;
GRANT SELECT,USAGE ON SEQUENCE coronatrack.locations_id_seq TO main;

CREATE VIEW coronatrack.v_last_device_location AS WITH last_device_location AS 
(
SELECT st_astext(the_geom),l.*, rank() over (partition by device_id
                        ORDER BY recorded_at DESC) AS last_location FROM coronatrack.locations l
)
SELECT device_id, company_id, st_asText(the_geom), the_geom, created_at, recorded_at, id, data, uuid FROM last_device_location WHERE last_location = 1;

ALTER TABLE coronatrack.companies ADD COLUMN name text;
ALTER TABLE coronatrack.companies ADD COLUMN first_name text;
ALTER TABLE coronatrack.companies ADD COLUMN phone_number text;
ALTER TABLE coronatrack.companies ADD COLUMN id_number text;
ALTER TABLE coronatrack.companies ADD COLUMN trip_reason text;
ALTER TABLE coronatrack.companies ADD COLUMN accomodation text;
ALTER TABLE coronatrack.companies ADD COLUMN recently_visited_countries text;
ALTER TABLE coronatrack.companies ADD COLUMN form_info jsonb;
ALTER TABLE coronatrack.companies ADD COLUMN has_symtoms integer;
ALTER TABLE coronatrack.companies ADD COLUMN accomodation_lat double precision;
ALTER TABLE coronatrack.companies ADD COLUMN accomodation_lon double precision;
ALTER TABLE coronatrack.companies ADD COLUMN accomodation_geom geometry;
