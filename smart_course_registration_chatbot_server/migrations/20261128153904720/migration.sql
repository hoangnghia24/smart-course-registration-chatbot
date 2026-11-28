BEGIN;

--
-- ACTION CREATE TABLE
--
CREATE TABLE "app_chatbot_request" (
    "id" bigserial PRIMARY KEY,
    "studentId" bigint NOT NULL,
    "conversationId" bigint NOT NULL,
    "clientRequestId" text NOT NULL,
    "requestedConversationId" bigint,
    "question" text NOT NULL,
    "answer" text NOT NULL,
    "createdAt" timestamp without time zone NOT NULL
);

-- Indexes
CREATE UNIQUE INDEX "chatbot_request_student_request_idx" ON "app_chatbot_request" USING btree ("studentId", "clientRequestId");

--
-- ACTION CREATE FOREIGN KEY
--
ALTER TABLE ONLY "app_chatbot_request"
    ADD CONSTRAINT "app_chatbot_request_fk_0"
    FOREIGN KEY("studentId")
    REFERENCES "app_student"("id")
    ON DELETE CASCADE
    ON UPDATE NO ACTION;
ALTER TABLE ONLY "app_chatbot_request"
    ADD CONSTRAINT "app_chatbot_request_fk_1"
    FOREIGN KEY("conversationId")
    REFERENCES "app_chatbot_conversation"("id")
    ON DELETE CASCADE
    ON UPDATE NO ACTION;


--
-- MIGRATION VERSION FOR smart_course_registration_chatbot
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('smart_course_registration_chatbot', '20261128153904720', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20261128153904720', "timestamp" = now();

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
