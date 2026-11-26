BEGIN;

--
-- ACTION CREATE TABLE
--
CREATE TABLE "app_chatbot_conversation" (
    "id" bigserial PRIMARY KEY,
    "studentId" bigint NOT NULL,
    "title" text NOT NULL,
    "createdAt" timestamp without time zone NOT NULL,
    "updatedAt" timestamp without time zone NOT NULL
);

-- Indexes
CREATE INDEX "chatbot_conversation_student_updated_idx" ON "app_chatbot_conversation" USING btree ("studentId", "updatedAt");

--
-- ACTION CREATE TABLE
--
CREATE TABLE "app_chatbot_message" (
    "id" bigserial PRIMARY KEY,
    "conversationId" bigint NOT NULL,
    "role" text NOT NULL,
    "content" text NOT NULL,
    "createdAt" timestamp without time zone NOT NULL
);

-- Indexes
CREATE INDEX "chatbot_message_conversation_created_idx" ON "app_chatbot_message" USING btree ("conversationId", "createdAt");

--
-- ACTION CREATE FOREIGN KEY
--
ALTER TABLE ONLY "app_chatbot_conversation"
    ADD CONSTRAINT "app_chatbot_conversation_fk_0"
    FOREIGN KEY("studentId")
    REFERENCES "app_student"("id")
    ON DELETE CASCADE
    ON UPDATE NO ACTION;

--
-- ACTION CREATE FOREIGN KEY
--
ALTER TABLE ONLY "app_chatbot_message"
    ADD CONSTRAINT "app_chatbot_message_fk_0"
    FOREIGN KEY("conversationId")
    REFERENCES "app_chatbot_conversation"("id")
    ON DELETE CASCADE
    ON UPDATE NO ACTION;


--
-- MIGRATION VERSION FOR smart_course_registration_chatbot
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('smart_course_registration_chatbot', '20261125162330357-chatbot-conversations', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20261125162330357-chatbot-conversations', "timestamp" = now();

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
