{-# LANGUAGE QuasiQuotes #-}

module Station.Database.Course (
	Identifier,
	Type (Record, identifier, subject, title, description),
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

import qualified Station.Database.Subject as DB.Subject

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
		subject :: DB.Subject.Identifier,
		title :: String,
		description :: String}

instance DB.ToRow Type where
	toRow course =
		[
			DB.toField (identifier course),
			DB.toField (subject course),
			DB.toField (title course),
			DB.toField (description course)]

instance DB.FromRow Type where
	fromRow =
		Record
			<$> DB.field
			<*> DB.field
			<*> DB.field
			<*> DB.field

get :: Identifier -> DB.Connection -> IO [Type]
get course_identifier db =
	DB.query
		db
		[sql| SELECT "IDENTIFIER","SUBJECT","TITLE","DESCRIPTION" FROM "COURSE" WHERE "IDENTIFIER"=? |]
		(DB.Only course_identifier)

list :: DB.Subject.Identifier -> DB.Connection -> IO [Type]
list subject_identifier db =
	DB.query
		db
		[sql| SELECT "IDENTIFIER","SUBJECT","TITLE","DESCRIPTION" FROM "COURSE" WHERE "SUBJECT"=? |]
		(DB.Only subject_identifier)

delete :: Identifier -> DB.Connection -> IO Bool
delete course_identifier db =
	(1 ==)
		<$>
			DB.execute
				db
				[sql| DELETE FROM "COURSE" WHERE "IDENTIFIER"=? |]
				(DB.Only course_identifier)

add :: DB.Subject.Identifier -> String -> String -> DB.Connection -> IO (Maybe Identifier)
add course_subject course_title course_description db =
	(\case
		[DB.Only result] -> (Just result)
		_ -> Nothing)
		<$>
			DB.query
				db
				[sql| INSERT INTO "COURSE"("SUBJECT","TITLE","DESCRIPTION") VALUES (?,?,?) RETURNING "IDENTIFIER" |]
				(course_subject, course_title, course_description)

set :: Type -> DB.Connection -> IO Bool
set course db =
	(1 ==)
		<$>
			DB.execute
				db
				[sql| UPDATE "COURSE" SET "SUBJECT"=?,"TITLE"=?,"DESCRIPTION"=? WHERE "IDENTIFIER"=? |]
				(subject course, title course, description course, identifier course)
