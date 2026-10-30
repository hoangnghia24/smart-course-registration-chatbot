BEGIN;

--
-- ACTION CREATE TABLE
--
CREATE TABLE "app_curriculum_item" (
    "id" bigserial PRIMARY KEY,
    "curriculumVersionId" bigint NOT NULL,
    "courseId" bigint NOT NULL,
    "semester" bigint NOT NULL,
    "isRequired" boolean NOT NULL
);

-- Indexes
CREATE UNIQUE INDEX "app_curriculum_item_unique" ON "app_curriculum_item" USING btree ("curriculumVersionId", "courseId");

--
-- ACTION CREATE FOREIGN KEY
--
ALTER TABLE ONLY "app_curriculum_item"
    ADD CONSTRAINT "app_curriculum_item_fk_0"
    FOREIGN KEY("curriculumVersionId")
    REFERENCES "app_curriculum_version"("id")
    ON DELETE NO ACTION
    ON UPDATE NO ACTION;
ALTER TABLE ONLY "app_curriculum_item"
    ADD CONSTRAINT "app_curriculum_item_fk_1"
    FOREIGN KEY("courseId")
    REFERENCES "app_course"("id")
    ON DELETE NO ACTION
    ON UPDATE NO ACTION;


--
-- MIGRATION VERSION FOR smart_course_registration_chatbot
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('smart_course_registration_chatbot', '20261030081442424', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20261030081442424', "timestamp" = now();

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
