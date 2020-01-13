{-# LANGUAGE QuasiQuotes #-}

module Station.Database.Question (
	Identifier, Number,
	Type (Record, identifier, lesson, number, text),
	get, list, delete, add, set, exchange
) where

import Prelude ()
import Data.Bool (Bool (True, False))
import Data.Eq ((==))
import Data.Maybe (Maybe (Nothing, Just))
import Data.List (map)
import Data.Int (Int16, Int32)
import Data.String (String)
import Data.Functor (fmap, (<$>))
import Control.Applicative ((<*>))
import Control.Monad (return)
import Text.Show (Show, show)
import Text.Read (Read, readsPrec)
import System.IO (IO)
import qualified Database.PostgreSQL.Simple as DB
import qualified Database.PostgreSQL.Simple.ToField as DB
import qualified Database.PostgreSQL.Simple.FromField as DB
import qualified Database.PostgreSQL.Simple.ToRow as DB
import qualified Database.PostgreSQL.Simple.FromRow as DB
import qualified Database.PostgreSQL.Simple.Transaction as DB
import Database.PostgreSQL.Simple.SqlQQ (sql)

import qualified Station.Database.Lesson as DB.Lesson

newtype Identifier = Identifier Int32

instance Show Identifier where
	show (Identifier i) = show i

instance Read Identifier where
	readsPrec i s = map (\ (x, r) -> (Identifier x, r)) (readsPrec i s)

instance DB.ToField Identifier where
	toField (Identifier i) = DB.toField i

instance DB.FromField Identifier where
	fromField f x = Identifier <$> DB.fromField f x

type Number = Int16

data Type =
	Record{
		identifier :: Identifier,
		lesson :: DB.Lesson.Identifier,
		number :: Number,
		text :: String}

instance DB.ToRow Type where
	toRow question =
		[
			DB.toField (identifier question),
			DB.toField (lesson question),
			DB.toField (number question),
			DB.toField (text question)]

instance DB.FromRow Type where
	fromRow =
		Record
			<$> DB.field
			<*> DB.field
			<*> DB.field
			<*> DB.field

get :: Identifier -> DB.Connection -> IO [Type]
get question_identifier db =
	DB.query
		db
		[sql| SELECT "IDENTIFIER","LESSON","NUMBER","TEXT" FROM "QUESTION" WHERE "IDENTIFIER"=? |]
		(DB.Only question_identifier)

list :: DB.Lesson.Identifier -> DB.Connection -> IO [Type]
list lesson_identifier db =
	DB.query
		db
		[sql|
			SELECT "IDENTIFIER","LESSON","NUMBER","TEXT"
				FROM "QUESTION"
				WHERE "LESSON"=?
				ORDER BY "NUMBER" ASC |]
		(DB.Only lesson_identifier)

delete :: Identifier -> DB.Connection -> IO Bool
delete question_identifier db =
	DB.withTransactionSerializable
		db
		(do
			delete_result <-
				DB.query
					db
					[sql| DELETE FROM "QUESTION" WHERE "IDENTIFIER"=? RETURNING "LESSON" |]
					(DB.Only question_identifier)
					:: IO [DB.Only DB.Lesson.Identifier]
			case delete_result of
				DB.Only lesson_identifier : [] ->
					do
						_ <-
							DB.execute
								db
								[sql|
									WITH
										"Q" AS
											(SELECT "IDENTIFIER", ROW_NUMBER() OVER(ORDER BY "NUMBER" ASC) AS "N"
												FROM "QUESTION"
												WHERE "LESSON"=?)
										UPDATE "QUESTION"
											SET "NUMBER"="Q"."N"
											FROM "Q"
											WHERE "QUESTION"."IDENTIFIER"="Q"."IDENTIFIER"
												AND "QUESTION"."NUMBER"<>"Q"."N" |]
								(DB.Only lesson_identifier)
						return True
				_ ->
					do
						DB.rollback db
						return False)

add :: DB.Lesson.Identifier -> String -> DB.Connection -> IO (Maybe Identifier)
add question_lesson question_text db =
	DB.withTransactionSerializable
		db
		(fmap
			(\case
				[DB.Only result] -> (Just result)
				_ -> Nothing)
			(DB.query
				db
				[sql|
					INSERT INTO "QUESTION"("LESSON","NUMBER","TEXT")
						VALUES (?, (SELECT COUNT(*)+1 FROM "QUESTION" WHERE "LESSON"=?), ?)
						RETURNING "IDENTIFIER" |]
				(question_lesson, question_lesson, question_text)))

set :: Identifier -> String -> DB.Connection -> IO Bool
set question_identifier question_text db =
	(1 ==)
		<$>
			DB.execute
				db
				[sql| UPDATE "QUESTION" SET "TEXT"=? WHERE "IDENTIFIER"=? |]
				(question_text, question_identifier)

exchange :: Identifier -> Identifier -> DB.Connection -> IO Bool
exchange question_1 question_2 db =
	(2 ==)
		<$>
			DB.execute
				db
				[sql|
					WITH "Q" AS (SELECT * FROM "QUESTION" WHERE "IDENTIFIER" IN (?,?))
						UPDATE "QUESTION"
							SET "NUMBER"="Q2"."NUMBER"
							FROM "Q" AS "Q1", "Q" AS "Q2"
							WHERE "QUESTION"."IDENTIFIER"="Q1"."IDENTIFIER"
								AND "Q1"."IDENTIFIER"<>"Q2"."IDENTIFIER" |]
				(question_1, question_2)
