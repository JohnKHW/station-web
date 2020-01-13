{-# LANGUAGE QuasiQuotes #-}

module Station.Database.Answer (
	Identifier,
	Type (Record, identifier, question, text, mark),
	get, list, delete, add, set
) where

import Prelude ()
import Data.Bool (Bool)
import Data.Eq ((==))
import Data.Maybe (Maybe (Nothing, Just))
import Data.List (map)
import Data.Int (Int32)
import Data.String (String)
import Control.Applicative ((<$>), (<*>))
import Text.Show (Show, show)
import Text.Read (Read, readsPrec)
import System.IO (IO)
import qualified Database.PostgreSQL.Simple as DB
import qualified Database.PostgreSQL.Simple.ToField as DB
import qualified Database.PostgreSQL.Simple.FromField as DB
import qualified Database.PostgreSQL.Simple.ToRow as DB
import qualified Database.PostgreSQL.Simple.FromRow as DB
import Database.PostgreSQL.Simple.SqlQQ (sql)

import qualified Station.Database
import qualified Station.Database.Question as DB.Question

newtype Identifier = Identifier Int32

instance Show Identifier where
	show (Identifier i) = show i

instance Read Identifier where
	readsPrec i s = map (\ (x, r) -> (Identifier x, r)) (readsPrec i s)

instance DB.ToField Identifier where
	toField (Identifier i) = DB.toField i

instance DB.FromField Identifier where
	fromField f x = Identifier <$> DB.fromField f x

data Type =
	Record{
		identifier :: Identifier,
		question :: DB.Question.Identifier,
		text :: String,
		mark :: Station.Database.Mark}

instance DB.ToRow Type where
	toRow answer =
		[
			DB.toField (identifier answer),
			DB.toField (question answer),
			DB.toField (text answer),
			DB.toField (mark answer)]

instance DB.FromRow Type where
	fromRow =
		Record
			<$> DB.field
			<*> DB.field
			<*> DB.field
			<*> DB.field

get :: Identifier -> DB.Connection -> IO [Type]
get answer_identifier db =
	DB.query
		db
		[sql| SELECT "IDENTIFIER","QUESTION","TEXT","MARK" FROM "ANSWER" WHERE "IDENTIFIER"=? |]
		(DB.Only answer_identifier)

list :: DB.Question.Identifier -> DB.Connection -> IO [Type]
list question_identifier db =
	DB.query
		db
		[sql| SELECT "IDENTIFIER","QUESTION","TEXT","MARK" FROM "ANSWER" WHERE "QUESTION"=? |]
		(DB.Only question_identifier)

delete :: Identifier -> DB.Connection -> IO Bool
delete answer_identifier db =
	(1 ==)
		<$>
			DB.execute
				db
				[sql| DELETE FROM "ANSWER" WHERE "IDENTIFIER"=? |]
				(DB.Only answer_identifier)

add :: DB.Question.Identifier -> String -> Int32 -> DB.Connection -> IO (Maybe Identifier)
add answer_question answer_text answer_mark db =
	(\case
		[DB.Only result] -> (Just result)
		_ -> Nothing)
		<$>
			DB.query
				db
				[sql| INSERT INTO "ANSWER"("QUESTION","TEXT","MARK") VALUES (?,?,?) RETURNING "IDENTIFIER" |]
				(answer_question, answer_text, answer_mark)

set :: Type -> DB.Connection -> IO Bool
set answer db =
	(1 ==)
		<$>
			DB.execute
				db
				[sql| UPDATE "ANSWER" SET "QUESTION"=?,"TEXT"=?,"MARK"=? WHERE "IDENTIFIER"=? |]
				(question answer, text answer, mark answer, identifier answer)
