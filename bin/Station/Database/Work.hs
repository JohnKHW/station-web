{-# LANGUAGE QuasiQuotes #-}

module Station.Database.Work (
	Type (Record, user, answer),
	get, delete, add,
	get_lesson
) where

import Prelude ()
import Data.Bool (Bool)
import Data.List (map)
import Data.Function ((.))
import Data.String (String)
import Control.Applicative ((<$>), (<*>))
import Control.Monad ((=<<), void, mapM)
import System.IO (IO)
import qualified Database.PostgreSQL.Simple as DB
import qualified Database.PostgreSQL.Simple.ToField as DB
import qualified Database.PostgreSQL.Simple.ToRow as DB
import qualified Database.PostgreSQL.Simple.FromRow as DB
import qualified Database.PostgreSQL.Simple.Transaction as DB
import Database.PostgreSQL.Simple.SqlQQ (sql)

import qualified Station.Database.Lesson as DB.Lesson
import qualified Station.Database.Question as DB.Question
import qualified Station.Database.Answer as DB.Answer

data Type =
	Record{
		user :: String,
		answer :: DB.Answer.Identifier}

instance DB.ToRow Type where
	toRow work =
		[
			DB.toField (user work),
			DB.toField (answer work)]

instance DB.FromRow Type where
	fromRow =
		Record
			<$> DB.field
			<*> DB.field

get :: String -> DB.Question.Identifier -> DB.Connection -> IO [Type]
get user_name question_identifier db =
	DB.query
		db
		[sql|
			SELECT "WORK"."USER","WORK"."ANSWER"
				FROM "WORK"
				INNER JOIN "ANSWER"
					ON "ANSWER"."IDENTIFIER"="WORK"."ANSWER"
				WHERE "WORK"."USER"=? AND "ANSWER"."QUESTION"=? |]
		(user_name, question_identifier)

delete_ :: String -> DB.Lesson.Identifier -> DB.Connection -> IO ()
delete_ user_name lesson_identifier db =
	do
		void
			(DB.execute
				db
				[sql|
					UPDATE "USER"
						SET "MARK" =
							"MARK" -
								(SELECT COALESCE(SUM("ANSWER"."MARK"),0)
									FROM "QUESTION"
									INNER JOIN "ANSWER"
										ON "QUESTION"."IDENTIFIER"="ANSWER"."QUESTION"
									INNER JOIN "WORK"
										ON "ANSWER"."IDENTIFIER"="WORK"."ANSWER"
									WHERE "QUESTION"."LESSON"=? AND "WORK"."USER"=?)
						WHERE "NAME"=? |]
				(lesson_identifier, user_name, user_name))
		void
			(DB.execute
				db
				[sql|
					DELETE FROM "WORK"
						USING "QUESTION","ANSWER"
						WHERE "WORK"."USER"=?
							AND "QUESTION"."LESSON"=?
							AND "QUESTION"."IDENTIFIER"="ANSWER"."QUESTION"
							AND "ANSWER"."IDENTIFIER"="WORK"."ANSWER" |]
				(user_name, lesson_identifier))

delete :: String -> DB.Lesson.Identifier -> DB.Connection -> IO ()
delete user_name lesson_identifier db = DB.withTransactionSerializable db (delete_ user_name lesson_identifier db)

add :: String -> DB.Lesson.Identifier -> [DB.Answer.Identifier] -> DB.Connection -> IO ()
add user_name lesson_identifier list_answer_identifier db =
	DB.withTransactionSerializable
		db
		(do
			delete_ user_name lesson_identifier db
			void
				(DB.executeMany
					db
					[sql| INSERT INTO "WORK" VALUES (?,?) |]
					(map (\ a -> (user_name, a)) list_answer_identifier))
			void
				(DB.execute
					db
					[sql|
						UPDATE "USER"
							SET "MARK" =
								"MARK" +
									(SELECT COALESCE(SUM("MARK"),0)
										FROM "ANSWER"
										WHERE "IDENTIFIER" IN ?)
							WHERE "NAME"=? |]
					(DB.In list_answer_identifier, user_name)))

get_lesson ::
	String ->
	DB.Lesson.Identifier ->
	DB.Connection ->
	IO [(DB.Lesson.Type, [(DB.Question.Type, [(DB.Answer.Type, Bool)])])]
get_lesson user_name lesson_identifier db =
	DB.withTransactionMode
		(DB.TransactionMode DB.ReadCommitted DB.ReadOnly)
		db
		(mapM
			(\ lesson ->
				(,) lesson <$>
					(mapM
						(\ question ->
							((,) question . map (\ (a DB.:. DB.Only m) -> (a, m))) <$>
								DB.query
									db
									[sql|
										SELECT "IDENTIFIER", "QUESTION", "TEXT", "MARK", "WORK"."ANSWER" IS NOT NULL
											FROM "ANSWER"
											LEFT OUTER JOIN "WORK"
												ON "ANSWER"."IDENTIFIER"="WORK"."ANSWER" AND "WORK"."USER"=?
											WHERE "QUESTION"=?
											ORDER BY RANDOM() |]
									(user_name, DB.Question.identifier question))
						=<< DB.Question.list lesson_identifier db))
			=<< DB.Lesson.get lesson_identifier db)
