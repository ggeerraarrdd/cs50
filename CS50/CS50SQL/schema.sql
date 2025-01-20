-- In this SQL file, write (and comment!) the schema of your database, including the CREATE TABLE, CREATE INDEX, CREATE VIEW, etc. statements that compose it

-- Exceute the queries in the order that they appear here

DROP TABLE IF EXISTS "objects";
CREATE TABLE "objects" (
    "id" SERIAL PRIMARY KEY,
    "api_id" VARCHAR(13) NOT NULL,
    "title" VARCHAR(256) NOT NULL,
    "title_display" VARCHAR(256),
    "title_alt" VARCHAR(256),
    "date_display" DATE,
    "medium" TEXT,
    "dimensions" VARCHAR(256),
    "has_inscriptions" BOOL DEFAULT FALSE,
    "description" TEXT,
    "date_commission" DATE,
    "date_fabrication_start" DATE,
    "date_fabrication_end" DATE,
    "record_remarks" TEXT,
    "record_date_created" TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    "record_date_updated" TIMESTAMP,
    CONSTRAINT CHECK_DATEAFTER1 CHECK ("date_fabrication_end" >= "date_fabrication_start")
);


DROP TABLE IF EXISTS "agents";
CREATE TABLE "agents" (
    "id" SERIAL PRIMARY KEY,
    "agent_type" VARCHAR(16) NOT NULL DEFAULT 'Tbd',
    "name_display" VARCHAR(128) NOT NULL,
    "name_first" VARCHAR(128),
    "name_middle" VARCHAR(128),
    "name_last" VARCHAR(128),
    "name_alt" VARCHAR(128),
    "nationality" VARCHAR(128),
    "city" VARCHAR(128),
    "country" VARCHAR(128),
    "address" VARCHAR(128),
    "date_begin" DATE,
    "date_end" DATE,
    "record_remarks" TEXT,
    "record_date_created" TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    "record_date_updated" TIMESTAMP,
    CONSTRAINT CHECK_AGENT_TYPE CHECK ("agent_type" IN ('Anonymous', 'Individual', 'Couple', 'Group', 'Tbd')),
    CONSTRAINT CHECK_DATEAFTER CHECK ("date_end" >= "date_begin")
);

DROP TABLE IF EXISTS "role_types";
CREATE TABLE "role_types" (
    "id" SERIAL PRIMARY KEY,
    "name" VARCHAR(32) NOT NULL,
    "description" VARCHAR(128) NOT NULL,
    "record_remarks" TEXT,
    "record_date_created" TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    "record_date_updated" TIMESTAMP
);

DROP TABLE IF EXISTS "r_objects_agents";

CREATE TABLE "r_objects_agents" (
    "id" SERIAL PRIMARY KEY,
    "object_id" INTEGER NOT NULL,
    "agent_id" INTEGER NOT NULL,
    "role_id" INTEGER NOT NULL,
    "record_remarks" TEXT,
    "record_date_created" TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    "record_date_updated" TIMESTAMP,
    CONSTRAINT FK_OBJECT_ID FOREIGN KEY ("object_id") REFERENCES "objects"("id"),
    CONSTRAINT FK_AGENT_ID FOREIGN KEY ("agent_id") REFERENCES "agents"("id"),
    CONSTRAINT FK_ROLE_ID FOREIGN KEY ("role_id") REFERENCES "role_types"("id")
);

DROP TABLE IF EXISTS "asset_types";
CREATE TABLE "asset_types" (
    "id" SERIAL PRIMARY KEY,
    "name" VARCHAR(128) NOT NULL,
    "description" VARCHAR(128) NOT NULL,
    "is_subtype_of" INTEGER NOT NULL,
    "record_remarks" TEXT,
    "record_date_created" TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    "record_date_updated" TIMESTAMP,
    CONSTRAINT FK_IS_SUBTYPE_OF FOREIGN KEY ("is_subtype_of") REFERENCES "asset_types"("id")
);

DROP TABLE IF EXISTS "assets";
CREATE TABLE "assets" (
    "id" SERIAL PRIMARY KEY,
    "asset_name" VARCHAR(128) NOT NULL,
    "asset_name_display" VARCHAR(128),
    "asset_label" TEXT,
    "asset_type" INTEGER NOT NULL,
    "asset_type_sub" INTEGER NOT NULL,
    "asset_description" TEXT,
    "asset_content" TEXT,
    "asset_agent_id" INTEGER,
    "asset_copyright" VARCHAR(128) DEFAULT 'Tbd',
    "asset_date_created" DATE,
    "asset_date_acquired" DATE,
    "asset_size" VARCHAR(16),
    "record_remarks" TEXT,
    "record_date_created" TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    "record_date_updated" TIMESTAMP,
    CONSTRAINT FK_ASSET_TYPE FOREIGN KEY ("asset_type") REFERENCES "asset_types"("id"),
    CONSTRAINT FK_ASSET_TYPE_SUB FOREIGN KEY ("asset_type_sub") REFERENCES "asset_types"("id"),
    CONSTRAINT FK_AGENT_ID FOREIGN KEY ("asset_agent_id") REFERENCES "agents"("id")
);

DROP TABLE IF EXISTS "r_assets_objects";

CREATE TABLE "r_assets_objects" (
    "id" SERIAL PRIMARY KEY,
    "asset_id" INTEGER NOT NULL,
    "object_id" INTEGER NOT NULL,
    "record_remarks" TEXT,
    "record_date_created" TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    "record_date_updated" TIMESTAMP,
    CONSTRAINT FK_ASSET_ID FOREIGN KEY ("asset_id") REFERENCES "assets"("id"),
    CONSTRAINT FK_OBJECT_ID FOREIGN KEY ("object_id") REFERENCES "objects"("id")
);

DROP TABLE IF EXISTS "inscriptions";
CREATE TABLE "inscriptions" (
    "id" SERIAL PRIMARY KEY,
    "object_id" INTEGER NOT NULL,
    "inscription" TEXT NOT NULL,
    "inscription_visual" INTEGER,
    "is_signature" VARCHAR(8) DEFAULT 'Tbd',
    "dimension_width" INTEGER,
    "dimension_height" INTEGER,
    "dimension_label" VARCHAR(16),
    "location" TEXT,
    "record_remarks" TEXT,
    "record_date_created" TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    "record_date_updated" TIMESTAMP,
    CONSTRAINT FK_OBJECT_ID FOREIGN KEY ("object_id") REFERENCES "objects"("id"),
    CONSTRAINT FK_INSCRIPTION_VISUAL FOREIGN KEY ("inscription_visual") REFERENCES "assets"("id"),
    CONSTRAINT CHECK_IS_SIGNATURE CHECK ("is_signature" IN ('Yes', 'No', 'Tbd'))
);

DROP TABLE IF EXISTS "locations";

CREATE TABLE "locations" (
    "id" SERIAL PRIMARY KEY,
    "name" VARCHAR(128) NOT NULL,
    "name_display" VARCHAR(128) NOT NULL,
    "name_alt" VARCHAR(128),
    "centroid_lat" NUMERIC,
    "centroid_lng" NUMERIC,
    "city" VARCHAR(128),
    "country" VARCHAR(128),
    "address" VARCHAR(128),
    "owner_id" INTEGER,
    "record_remarks" TEXT,
    "record_date_created" TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    "record_date_updated" TIMESTAMP,
    CONSTRAINT FK_OWNER_ID FOREIGN KEY ("owner_id") REFERENCES "agents"("id")
);

DROP TABLE IF EXISTS "installations";
CREATE TABLE "installations" (
    "id" SERIAL PRIMARY KEY,
    "object_id" INTEGER NOT NULL,
    "latitude" NUMERIC,
    "longitude" NUMERIC,
    "location_id" INTEGER NOT NULL,
    "is_permanent" VARCHAR(8) DEFAULT 'Tbd',
    "description" TEXT,
    "commissioning_entity" INTEGER,
    "date_assembly_start" DATE,
    "data_assembly_end" DATE,
    "date_display_start_official" DATE,
    "date_display_end_official" DATE,
    "installation_pre" INTEGER,
    "installation_post" INTEGER,
    "record_remarks" TEXT,
    "record_date_created" TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    "record_date_updated" TIMESTAMP,
    CONSTRAINT FK_OBJECT_ID FOREIGN KEY ("object_id") REFERENCES "objects"("id"),
    CONSTRAINT FK_LOCATION_ID FOREIGN KEY ("location_id") REFERENCES "locations"("id"),
    CONSTRAINT FK_COMMISSIONING_ENTITY FOREIGN KEY ("commissioning_entity") REFERENCES "agents"("id"),
    CONSTRAINT FK_INSTALLATION_PRE FOREIGN KEY ("installation_pre") REFERENCES "installations"("id"),
    CONSTRAINT FK_INSTALLATION_POST FOREIGN KEY ("installation_post") REFERENCES "installations"("id"),
    CONSTRAINT CHECK_IS_PERMANENT CHECK ("is_permanent" IN ('Yes', 'No', 'Tbd'))
);

DROP TABLE IF EXISTS "databases";
CREATE TABLE "databases" (
    "id" SERIAL PRIMARY KEY,
    "name" VARCHAR(32) NOT NULL,
    "host" VARCHAR(32) NOT NULL,
    "type" VARCHAR(32) NOT NULL,
    "type_sub" VARCHAR(32) NOT NULL,
    "record_remarks" TEXT,
    "record_date_created" TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    "record_date_updated" TIMESTAMP
);

DROP TABLE IF EXISTS "r_assets_databases";

CREATE TABLE "r_assets_databases" (
    "id" SERIAL PRIMARY KEY,
    "document_id" INTEGER NOT NULL,
    "database_id" INTEGER NOT NULL,
    "record_remarks" TEXT,
    "record_date_created" TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    "record_date_updated" TIMESTAMP,
    CONSTRAINT FK_DOCUMENT_ID FOREIGN KEY ("document_id") REFERENCES "assets"("id"),
    CONSTRAINT FK_DATABASE_ID FOREIGN KEY ("database_id") REFERENCES "databases"("id")
);

DROP TABLE IF EXISTS "rows";
CREATE TABLE "rows" (
    "id" SERIAL PRIMARY KEY,
    "table" VARCHAR(32) NOT NULL,
    "table_row" INTEGER NOT NULL,
    "record_date_created" TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    "record_date_updated" TIMESTAMP
);

DROP TABLE IF EXISTS "attributes";
CREATE TABLE "attributes" (
    "id" SERIAL PRIMARY KEY,
    "row_id" INTEGER NOT NULL,
    "column_name" VARCHAR(32) NOT NULL,
    "column_type" VARCHAR(32) NOT NULL,
    "column_value" TEXT NOT NULL,
    "record_date_created" TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    "record_date_updated" TIMESTAMP,
    CONSTRAINT FK_ROW_ID FOREIGN KEY ("row_id") REFERENCES "rows"("id")
);

DROP TABLE IF EXISTS "references";
CREATE TABLE "references" (
    "id" SERIAL PRIMARY KEY,
    "citation" TEXT NOT NULL,
    "isbn" VARCHAR(16),
    "asset_id" INTEGER,
    "record_remarks" TEXT,
    "record_date_created" TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    "record_date_updated" TIMESTAMP,
    CONSTRAINT FK_ASSET_ID FOREIGN KEY ("asset_id") REFERENCES "assets"("id")
);

DROP TABLE IF EXISTS "users";
CREATE TABLE "users" (
    "id" SERIAL PRIMARY KEY,
    "name_first" VARCHAR(64),
    "name_last" VARCHAR(64),
    "username" VARCHAR(16) NOT NULL,
    "hash" VARCHAR(128) NOT NULL,
    "role" VARCHAR(16) DEFAULT 'default',
    "agent_id" INTEGER,
    "record_date_created" TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    "record_date_updated" TIMESTAMP,
    CONSTRAINT FK_AGENT_ID FOREIGN KEY ("agent_id") REFERENCES "agents"("id"),
    CONSTRAINT CHECK_ROLE CHECK ("role" IN ('admin', 'curator', 'default'))
);

DROP TABLE IF EXISTS "verifications";
CREATE TABLE "verifications" (
    "id" SERIAL PRIMARY KEY,
    "attribute_id" INTEGER NOT NULL,
    "reference_id" INTEGER NOT NULL,
    "reference_page" VARCHAR(16),
    "user_id" INTEGER NOT NULL,
    "date_verification" TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    "record_remarks" TEXT,
    "record_date_created" TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    "record_date_updated" TIMESTAMP,
    CONSTRAINT FK_ATTRIBUTE_ID FOREIGN KEY ("attribute_id") REFERENCES "attributes"("id"),
    CONSTRAINT FK_REFERENCE_ID FOREIGN KEY ("reference_id") REFERENCES "references"("id"),
    CONSTRAINT FK_USER_ID FOREIGN KEY ("user_id") REFERENCES "users"("id")
);


-- The following creates indices per design document

CREATE INDEX indx_obj_title ON "objects"("title");
CREATE INDEX indx_obj_title_display ON "objects"("title_display");
CREATE INDEX indx_obj_title_alt ON "objects"("title_alt");

CREATE INDEX indx_loc_name ON "locations"("name");
CREATE INDEX indx_loc_name_display ON "locations"("name_display");
CREATE INDEX indx_loc_name_alt ON "locations"("name_alt");