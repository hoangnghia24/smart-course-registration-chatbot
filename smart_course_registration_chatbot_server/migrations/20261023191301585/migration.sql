BEGIN;

--
-- ACTION CREATE TABLE
--
CREATE TABLE "app_audit_log" (
    "id" bigserial PRIMARY KEY,
    "actorUserAccountId" bigint NOT NULL,
    "targetUserAccountId" bigint,
    "action" text NOT NULL,
    "createdAt" timestamp without time zone NOT NULL,
    "details" text
);

--
-- ACTION CREATE TABLE
--
CREATE TABLE "app_course" (
    "id" bigserial PRIMARY KEY,
    "code" text NOT NULL,
    "name" text NOT NULL,
    "credits" bigint NOT NULL,
    "description" text,
    "isActive" boolean NOT NULL
);

-- Indexes
CREATE UNIQUE INDEX "app_course_code_unique" ON "app_course" USING btree ("code");

--
-- ACTION CREATE TABLE
--
CREATE TABLE "app_curriculum" (
    "id" bigserial PRIMARY KEY,
    "code" text NOT NULL,
    "name" text NOT NULL,
    "majorCode" text NOT NULL,
    "status" text NOT NULL
);

-- Indexes
CREATE UNIQUE INDEX "app_curriculum_code_unique" ON "app_curriculum" USING btree ("code");

--
-- ACTION CREATE TABLE
--
CREATE TABLE "app_curriculum_version" (
    "id" bigserial PRIMARY KEY,
    "curriculumId" bigint NOT NULL,
    "versionCode" text NOT NULL,
    "effectiveYear" bigint NOT NULL,
    "status" text NOT NULL
);

-- Indexes
CREATE UNIQUE INDEX "app_curriculum_version_unique" ON "app_curriculum_version" USING btree ("curriculumId", "versionCode");

--
-- ACTION CREATE TABLE
--
CREATE TABLE "app_lecturer" (
    "id" bigserial PRIMARY KEY,
    "userAccountId" bigint NOT NULL,
    "lecturerCode" text NOT NULL,
    "teachingStatus" text NOT NULL
);

-- Indexes
CREATE UNIQUE INDEX "app_lecturer_account_unique" ON "app_lecturer" USING btree ("userAccountId");
CREATE UNIQUE INDEX "app_lecturer_code_unique" ON "app_lecturer" USING btree ("lecturerCode");

--
-- ACTION CREATE TABLE
--
CREATE TABLE "app_student" (
    "id" bigserial PRIMARY KEY,
    "userAccountId" bigint NOT NULL,
    "studentCode" text NOT NULL,
    "curriculumVersionId" bigint NOT NULL,
    "academicStatus" text NOT NULL
);

-- Indexes
CREATE UNIQUE INDEX "app_student_account_unique" ON "app_student" USING btree ("userAccountId");
CREATE UNIQUE INDEX "app_student_code_unique" ON "app_student" USING btree ("studentCode");

--
-- ACTION CREATE TABLE
--
CREATE TABLE "app_user_account" (
    "id" bigserial PRIMARY KEY,
    "authUserId" text NOT NULL,
    "schoolEmail" text NOT NULL,
    "role" text NOT NULL,
    "status" text NOT NULL,
    "createdAt" timestamp without time zone NOT NULL,
    "updatedAt" timestamp without time zone NOT NULL,
    "statusChangedAt" timestamp without time zone
);

-- Indexes
CREATE UNIQUE INDEX "app_user_account_auth_user_unique" ON "app_user_account" USING btree ("authUserId");
CREATE UNIQUE INDEX "app_user_account_email_unique" ON "app_user_account" USING btree ("schoolEmail");

--
-- ACTION CREATE FOREIGN KEY
--
ALTER TABLE ONLY "app_audit_log"
    ADD CONSTRAINT "app_audit_log_fk_0"
    FOREIGN KEY("actorUserAccountId")
    REFERENCES "app_user_account"("id")
    ON DELETE NO ACTION
    ON UPDATE NO ACTION;
ALTER TABLE ONLY "app_audit_log"
    ADD CONSTRAINT "app_audit_log_fk_1"
    FOREIGN KEY("targetUserAccountId")
    REFERENCES "app_user_account"("id")
    ON DELETE NO ACTION
    ON UPDATE NO ACTION;

--
-- ACTION CREATE FOREIGN KEY
--
ALTER TABLE ONLY "app_curriculum_version"
    ADD CONSTRAINT "app_curriculum_version_fk_0"
    FOREIGN KEY("curriculumId")
    REFERENCES "app_curriculum"("id")
    ON DELETE NO ACTION
    ON UPDATE NO ACTION;

--
-- ACTION CREATE FOREIGN KEY
--
ALTER TABLE ONLY "app_lecturer"
    ADD CONSTRAINT "app_lecturer_fk_0"
    FOREIGN KEY("userAccountId")
    REFERENCES "app_user_account"("id")
    ON DELETE NO ACTION
    ON UPDATE NO ACTION;

--
-- ACTION CREATE FOREIGN KEY
--
ALTER TABLE ONLY "app_student"
    ADD CONSTRAINT "app_student_fk_0"
    FOREIGN KEY("userAccountId")
    REFERENCES "app_user_account"("id")
    ON DELETE NO ACTION
    ON UPDATE NO ACTION;
ALTER TABLE ONLY "app_student"
    ADD CONSTRAINT "app_student_fk_1"
    FOREIGN KEY("curriculumVersionId")
    REFERENCES "app_curriculum_version"("id")
    ON DELETE NO ACTION
    ON UPDATE NO ACTION;


--
-- MIGRATION VERSION FOR smart_course_registration_chatbot
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('smart_course_registration_chatbot', '20261023191301585', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20261023191301585', "timestamp" = now();

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
