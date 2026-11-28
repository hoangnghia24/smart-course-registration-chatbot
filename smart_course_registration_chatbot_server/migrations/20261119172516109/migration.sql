BEGIN;

--
-- ACTION CREATE TABLE
--
CREATE TABLE "app_curriculum_cohort" (
    "id" bigserial PRIMARY KEY,
    "curriculumVersionId" bigint NOT NULL,
    "majorCode" text NOT NULL,
    "admissionYear" bigint NOT NULL
);

-- Indexes
CREATE UNIQUE INDEX "app_curriculum_cohort_unique" ON "app_curriculum_cohort" USING btree ("majorCode", "admissionYear");
CREATE INDEX "app_curriculum_cohort_version_idx" ON "app_curriculum_cohort" USING btree ("curriculumVersionId");

--
-- ACTION ALTER TABLE
--
ALTER TABLE "app_curriculum_item" ADD COLUMN "credits" bigint;
--
-- ACTION ALTER TABLE
--
ALTER TABLE "app_curriculum_version" ADD COLUMN "totalCreditsRequired" bigint;
ALTER TABLE "app_curriculum_version" ADD COLUMN "revision" bigint NOT NULL DEFAULT 1;
ALTER TABLE "app_curriculum_version" ADD COLUMN "publishedAt" timestamp without time zone;
CREATE INDEX "app_curriculum_version_lookup_idx" ON "app_curriculum_version" USING btree ("curriculumId", "status", "effectiveYear");
--
-- ACTION ALTER TABLE
--
ALTER TABLE "app_student" ADD COLUMN "admissionYear" bigint;
--
-- ACTION CREATE FOREIGN KEY
--
ALTER TABLE ONLY "app_curriculum_cohort"
    ADD CONSTRAINT "app_curriculum_cohort_fk_0"
    FOREIGN KEY("curriculumVersionId")
    REFERENCES "app_curriculum_version"("id")
    ON DELETE RESTRICT
    ON UPDATE NO ACTION;


--
-- MIGRATION VERSION FOR smart_course_registration_chatbot
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('smart_course_registration_chatbot', '20261119172516109', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20261119172516109', "timestamp" = now();

--
-- MIGRATION VERSION FOR serverpod
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('serverpod', '20260129180959368', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20260129180959368', "timestamp" = now();

--
-- MIGRATION VERSION FOR serverpod_auth_idp
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('serverpod_auth_idp', '20260213194423028', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20260213194423028', "timestamp" = now();

--
-- MIGRATION VERSION FOR serverpod_auth_core
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('serverpod_auth_core', '20260129181112269', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20260129181112269', "timestamp" = now();


COMMIT;
