BEGIN;

--
-- ACTION CREATE TABLE
--
CREATE TABLE "app_curriculum_group" (
    "id" bigserial PRIMARY KEY,
    "curriculumVersionId" bigint NOT NULL,
    "groupCode" text NOT NULL,
    "groupName" text NOT NULL,
    "groupOrder" bigint NOT NULL
);

-- Indexes
CREATE UNIQUE INDEX "curriculum_group_version_code_unique_idx" ON "app_curriculum_group" USING btree ("curriculumVersionId", "groupCode");
CREATE INDEX "curriculum_group_version_order_idx" ON "app_curriculum_group" USING btree ("curriculumVersionId", "groupOrder");

--
-- ACTION ALTER TABLE
--
ALTER TABLE "app_curriculum_item" ADD COLUMN "groupId" bigint;
ALTER TABLE "app_curriculum_item" ADD COLUMN "itemOrder" bigint;
--
-- ACTION CREATE FOREIGN KEY
--
ALTER TABLE ONLY "app_curriculum_group"
    ADD CONSTRAINT "app_curriculum_group_fk_0"
    FOREIGN KEY("curriculumVersionId")
    REFERENCES "app_curriculum_version"("id")
    ON DELETE NO ACTION
    ON UPDATE NO ACTION;

--
-- ACTION CREATE FOREIGN KEY
--
ALTER TABLE ONLY "app_curriculum_item"
    ADD CONSTRAINT "app_curriculum_item_fk_2"
    FOREIGN KEY("groupId")
    REFERENCES "app_curriculum_group"("id")
    ON DELETE NO ACTION
    ON UPDATE NO ACTION;

--
-- MIGRATION VERSION FOR smart_course_registration_chatbot
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('smart_course_registration_chatbot', '20261105220933927', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20261105220933927', "timestamp" = now();

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
