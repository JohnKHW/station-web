CREATE TABLE "MIGRATION"(
	"FILE" TEXT NOT NULL,
	PRIMARY KEY("FILE")
);

CREATE TABLE "USER"(
	"NAME" TEXT NOT NULL,
	"PASSWORD" TEXT NOT NULL,
	"ROLE" SMALLINT NOT NULL,
	"MARK" INTEGER NOT NULL DEFAULT 0,
	"LOCK" BOOLEAN NOT NULL DEFAULT FALSE,
	PRIMARY KEY("NAME")
);

-- CREATE SEQUENCE "SUBJECT_IDENTIFIER_seq" AS INTEGER;
CREATE TABLE "SUBJECT"(
	-- "IDENTIFIER" INTEGER NOT NULL DEFAULT nextval('"SUBJECT_IDENTIFIER_seq"'),
	"IDENTIFIER" SERIAL NOT NULL,
	"TITLE" TEXT NOT NULL,
	"DESCRIPTION" TEXT NOT NULL,
	PRIMARY KEY("IDENTIFIER")
);
-- ALTER SEQUENCE "SUBJECT_IDENTIFIER_seq" OWNED BY "SUBJECT"."IDENTIFIER";

CREATE TABLE "COURSE"(
	"IDENTIFIER" SERIAL NOT NULL,
	"SUBJECT" INTEGER NOT NULL,
	"TITLE" TEXT NOT NULL,
	"DESCRIPTION" TEXT NOT NULL,
	PRIMARY KEY("IDENTIFIER"),
	FOREIGN KEY("SUBJECT")
		REFERENCES "SUBJECT"("IDENTIFIER")
		ON DELETE CASCADE
		ON UPDATE CASCADE
);

CREATE TABLE "LESSON"(
	"IDENTIFIER" SERIAL NOT NULL,
	"COURSE" INTEGER NOT NULL,
	"NUMBER" SMALLINT NOT NULL,
	"TITLE" TEXT NOT NULL,
	"CONTENT" TEXT NOT NULL,
	PRIMARY KEY("IDENTIFIER"),
	FOREIGN KEY("COURSE")
		REFERENCES "COURSE"("IDENTIFIER")
		ON DELETE CASCADE
		ON UPDATE CASCADE
);

CREATE TABLE "QUESTION"(
	"IDENTIFIER" SERIAL NOT NULL,
	"LESSON" INTEGER NOT NULL,
	"NUMBER" SMALLINT NOT NULL,
	"TEXT" TEXT NOT NULL,
	PRIMARY KEY("IDENTIFIER"),
	FOREIGN KEY("LESSON")
		REFERENCES "LESSON"("IDENTIFIER")
		ON DELETE CASCADE
		ON UPDATE CASCADE
);

CREATE TABLE "ANSWER"(
	"IDENTIFIER" SERIAL NOT NULL,
	"QUESTION" INTEGER NOT NULL,
	"TEXT" TEXT NOT NULL,
	"MARK" INTEGER NOT NULL DEFAULT 0,
	PRIMARY KEY("IDENTIFIER"),
	FOREIGN KEY("QUESTION")
		REFERENCES "QUESTION"("IDENTIFIER")
		ON DELETE CASCADE
		ON UPDATE CASCADE
);

CREATE TABLE "WORK"(
	"USER" TEXT NOT NULL,
	"ANSWER" INTEGER NOT NULL,
	FOREIGN KEY("USER")
		REFERENCES "USER"("NAME")
		ON DELETE CASCADE
		ON UPDATE CASCADE,
	FOREIGN KEY("ANSWER")
		REFERENCES "ANSWER"("IDENTIFIER")
		ON DELETE CASCADE
		ON UPDATE CASCADE
);
