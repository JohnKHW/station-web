{-# LANGUAGE QuasiQuotes #-}

module Station.Database.User (
	Type (Record, name, password, role, mark, lock),
	get, list, delete, add, set, set_password
) where

import Prelude (fromEnum, toEnum)
import Data.Bool (Bool)
import Data.Eq ((==))
import Data.List (any)
import Data.String (String)
import Data.Function ((.))
import Control.Applicative ((<$>), (<*>))
import Control.Monad (return)
import System.IO (IO)
import qualified Data.ByteString as BS
import qualified Data.ByteString.UTF8 as BS.U8
import qualified Crypto.Scrypt
import qualified Database.PostgreSQL.Simple as DB
import qualified Database.PostgreSQL.Simple.ToField as DB
import qualified Database.PostgreSQL.Simple.ToRow as DB
import qualified Database.PostgreSQL.Simple.FromRow as DB
import Database.PostgreSQL.Simple.SqlQQ (sql)

import qualified Station.Database
import qualified Station.Constant as Constant

data Type =
	Record{
		name :: String,
		password :: String,
		role :: Constant.Role,
		mark :: Station.Database.Mark,
		lock :: Bool}

instance DB.ToRow Type where
	toRow user =
		[
			DB.toField (name user),
			DB.toField (password user),
			DB.toField (fromEnum (role user)),
			DB.toField (mark user),
			DB.toField (lock user)]

instance DB.FromRow Type where
	fromRow = Record <$> DB.field <*> DB.field <*> (toEnum <$> DB.field) <*> DB.field <*> DB.field

get :: String -> DB.Connection -> IO [Type]
get user_name db =
	DB.query
		db
		[sql| SELECT "NAME","PASSWORD","ROLE","MARK","LOCK" FROM "USER" WHERE "NAME"=? |]
		(DB.Only user_name)

list :: DB.Connection -> IO [Type]
list db = DB.query_ db [sql| SELECT "NAME","PASSWORD","ROLE","MARK","LOCK" FROM "USER" |]

hash_password :: String -> IO BS.ByteString
hash_password word =
	Crypto.Scrypt.getEncryptedPass <$> Crypto.Scrypt.encryptPassIO' (Crypto.Scrypt.Pass (BS.U8.fromString word))

delete :: String -> DB.Connection -> IO Bool
delete user db = (1 ==) <$> DB.execute db [sql| DELETE FROM "USER" WHERE "NAME"=? |] (DB.Only user)

add :: Type -> DB.Connection -> IO Bool
add user db =
	do
		hash <- hash_password (password user)
		n <-
			DB.execute
				db
				[sql| INSERT INTO "USER" ("NAME","PASSWORD","ROLE","MARK","LOCK") VALUES (?,?,?,?,?) |]
				(name user, hash, fromEnum (role user), lock user)
		return (n == 1)

set :: String -> Type -> DB.Connection -> IO Bool
set old new db =
	case password new of
		"" ->
			do
				n <-
					DB.execute
						db
						[sql| UPDATE "USER" SET "NAME"=?,"ROLE"=?,"LOCK"=? WHERE "NAME"=? |]
						(name new, fromEnum (role new), lock new, old)
				return (n == 1)
		new_password ->
			do
				hash <- hash_password new_password
				n <-
					DB.execute
						db
						[sql| UPDATE "USER" SET "NAME"=?,"PASSWORD"=?,"ROLE"=?,"LOCK"=? WHERE "NAME"=? |]
						(name new, hash, fromEnum (role new), lock new, old)
				return (n == 1)

set_password :: String -> String -> DB.Connection -> IO Bool
set_password user_name new_password db =
	do
		hash <- hash_password new_password
		n <-
			DB.execute
				db
				[sql| UPDATE "USER" SET "PASSWORD"=? WHERE "NAME"=? |]
				(hash, user_name)
		return (n == 1)
