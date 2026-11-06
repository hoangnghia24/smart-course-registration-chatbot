BEGIN;

--
-- ACTION CREATE TABLE
--
CREATE TABLE "app_academic_term" (
    "id" bigserial PRIMARY KEY,
    "academicYear" text NOT NULL,
    "termName" text NOT NULL,
    "status" text NOT NULL,
    "maxCreditsPerTerm" double precision NOT NULL
);

-- Indexes
CREATE UNIQUE INDEX "academic_term_year_name_unique_idx" ON "app_academic_term" USING btree ("academicYear", "termName");

--
-- ACTION CREATE TABLE
--
CREATE TABLE "app_course_section" (
    "id" bigserial PRIMARY KEY,
    "courseId" bigint NOT NULL,
    "termId" bigint NOT NULL,
    "lecturerId" bigint NOT NULL,
    "sectionCode" text NOT NULL,
    "capacity" bigint NOT NULL,
    "minimumEnrollment" bigint,
    "status" text NOT NULL,
    "createdAt" timestamp without time zone NOT NULL
);

-- Indexes
CREATE UNIQUE INDEX "course_section_term_code_unique_idx" ON "app_course_section" USING btree ("termId", "sectionCode");
CREATE INDEX "course_section_course_term_idx" ON "app_course_section" USING btree ("courseId", "termId");
CREATE INDEX "course_section_lecturer_term_idx" ON "app_course_section" USING btree ("lecturerId", "termId");

--
-- ACTION CREATE TABLE
--
CREATE TABLE "app_enrollment" (
    "id" bigserial PRIMARY KEY,
    "studentId" bigint NOT NULL,
    "sectionId" bigint NOT NULL,
    "enrollmentType" text NOT NULL,
    "status" text NOT NULL,
    "registeredAt" timestamp without time zone NOT NULL,
    "cancelledAt" timestamp without time zone,
    "score" double precision,
    "gradeStatus" text NOT NULL,
    "resultStatus" text NOT NULL,
    "publishedAt" timestamp without time zone,
    "enteredByLecturerId" bigint
);

-- Indexes
CREATE INDEX "enrollment_student_status_idx" ON "app_enrollment" USING btree ("studentId", "status");
CREATE INDEX "enrollment_section_status_idx" ON "app_enrollment" USING btree ("sectionId", "status");
CREATE INDEX "enrollment_student_section_idx" ON "app_enrollment" USING btree ("studentId", "sectionId");
CREATE INDEX "enrollment_student_grade_idx" ON "app_enrollment" USING btree ("studentId", "gradeStatus", "publishedAt");

--
-- ACTION CREATE FOREIGN KEY
--
ALTER TABLE ONLY "app_course_section"
    ADD CONSTRAINT "app_course_section_fk_0"
    FOREIGN KEY("courseId")
    REFERENCES "app_course"("id")
    ON DELETE NO ACTION
    ON UPDATE NO ACTION;
ALTER TABLE ONLY "app_course_section"
    ADD CONSTRAINT "app_course_section_fk_1"
    FOREIGN KEY("termId")
    REFERENCES "app_academic_term"("id")
    ON DELETE NO ACTION
    ON UPDATE NO ACTION;
ALTER TABLE ONLY "app_course_section"
    ADD CONSTRAINT "app_course_section_fk_2"
    FOREIGN KEY("lecturerId")
    REFERENCES "app_lecturer"("id")
    ON DELETE NO ACTION
    ON UPDATE NO ACTION;

--
-- ACTION CREATE FOREIGN KEY
--
ALTER TABLE ONLY "app_enrollment"
    ADD CONSTRAINT "app_enrollment_fk_0"
    FOREIGN KEY("studentId")
    REFERENCES "app_student"("id")
    ON DELETE RESTRICT
    ON UPDATE NO ACTION;
ALTER TABLE ONLY "app_enrollment"
    ADD CONSTRAINT "app_enrollment_fk_1"
    FOREIGN KEY("sectionId")
    REFERENCES "app_course_section"("id")
    ON DELETE RESTRICT
    ON UPDATE NO ACTION;
ALTER TABLE ONLY "app_enrollment"
    ADD CONSTRAINT "app_enrollment_fk_2"
    FOREIGN KEY("enteredByLecturerId")
    REFERENCES "app_lecturer"("id")
    ON DELETE RESTRICT
    ON UPDATE NO ACTION;


--
-- MIGRATION VERSION FOR smart_course_registration_chatbot
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('smart_course_registration_chatbot', '20261105223810723', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20261105223810723', "timestamp" = now();

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
