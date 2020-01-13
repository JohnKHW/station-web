{-# LANGUAGE QuasiQuotes #-}

module Station.Database.Subject (
	Identifier,
	Type (Record, identifier, title, description),
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
import System.IO (IO)
import Text.Show (Show, show)
import Text.Read (Read, readsPrec)
import qualified Database.PostgreSQL.Simple as DB
import qualified Database.PostgreSQL.Simple.ToField as DB
import qualified Database.PostgreSQL.Simple.FromField as DB
import qualified Database.PostgreSQL.Simple.ToRow as DB
import qualified Database.PostgreSQL.Simple.FromRow as DB
import Database.PostgreSQL.Simple.SqlQQ (sql)

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
		title :: String,
		description :: String}

instance DB.ToRow Type where
	toRow subject =
		[
			DB.toField (identifier subject),
			DB.toField (title subject),
			DB.toField (description subject)]

instance DB.FromRow Type where
	fromRow = Record <$> DB.field <*> DB.field <*> DB.field

get :: Identifier -> DB.Connection -> IO [Type]
get subject_identifier db =
	DB.query
		db
		[sql| SELECT "IDENTIFIER","TITLE","DESCRIPTION" FROM "SUBJECT" WHERE "IDENTIFIER"=? |]
		(DB.Only subject_identifier)

list :: DB.Connection -> IO [Type]
list db = DB.query_ db [sql| SELECT "IDENTIFIER","TITLE","DESCRIPTION" FROM "SUBJECT" |]

delete :: Identifier -> DB.Connection -> IO Bool
delete subject_identifier db =
	(1 ==)
		<$>
			DB.execute
				db
				[sql| DELETE FROM "SUBJECT" WHERE "IDENTIFIER"=? |]
				(DB.Only subject_identifier)

add :: String -> String -> DB.Connection -> IO (Maybe Int32)
add subject_title subject_description db =
	(\case
		[DB.Only result] -> (Just result)
		_ -> Nothing)
		<$>
			DB.query
				db
				[sql| INSERT INTO "SUBJECT"("TITLE","DESCRIPTION") VALUES (?,?) RETURNING "IDENTIFIER" |]
				(subject_title, subject_description)

set :: Type -> DB.Connection -> IO Bool
set subject db =
	(1 ==)
		<$>
			DB.execute
				db
				[sql| UPDATE "SUBJECT" SET "TITLE"=?,"DESCRIPTION"=? WHERE "IDENTIFIER"=? |]
				(title subject, description subject, identifier subject)
