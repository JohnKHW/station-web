module Main (main) where

import Prelude (fromEnum)
import Data.Bool (Bool (True, False), not, (&&))
import Data.Maybe (Maybe (Nothing, Just), maybe, fromMaybe)
import Data.List ((++), (\\), sort)
import Data.Function (id, ($))
import Data.Functor ((<$>))
import Control.Monad (return, (>>=), (=<<))
import Text.Show (show)
import Text.Read (readMaybe)
import System.Exit (exitSuccess, exitFailure)
import System.FilePath (FilePath, (</>))
import System.IO (IO, stdout, putStrLn, BufferMode (LineBuffering), hSetBuffering)
import System.Environment (getArgs, lookupEnv)
import System.Directory (listDirectory)
import qualified Data.ByteString as BS
import qualified Data.ByteString.Char8 as BS.C8
import qualified Crypto.Scrypt
import qualified Network.Wai as Wai
import qualified Network.Wai.Middleware.HttpAuth as HttpAuth
import qualified Network.Wai.Application.Static as Wai.Static
import qualified Network.Wai.Handler.Warp as Warp
import qualified Database.PostgreSQL.LibPQ
import qualified Database.PostgreSQL.Simple as DB
import qualified Database.PostgreSQL.Simple.Internal as DB (exec)

import qualified Station.Constant as Constant
import qualified Station.Constant.Role as Constant.Role
import qualified Station.Database.User as DB.User
import qualified Station.HTTP as HTTP
import qualified Station.Web as Web
import qualified Station.Web.Session as Session

{- -------------------------------------------------------------------------------------------------------------------------- -}

default_port :: Warp.Port
default_port = 8000

static_path :: FilePath
static_path = "www"

migration_path :: FilePath
migration_path = "sql/migration"

{- -------------------------------------------------------------------------------------------------------------------------- -}

handle_home :: Wai.Middleware
handle_home next request =
	case Wai.pathInfo request of
		[] -> HTTP.respond_301 Constant.public_home request
		_ -> next request

get_user :: DB.Connection -> Wai.Request -> IO (Maybe DB.User.Type)
get_user db request =
	case HTTP.auth_user request of
		Nothing -> return Nothing
		Just name ->
			DB.User.get (BS.C8.unpack name) db >>= \case
				[user] -> return (Just user)
				_ -> return Nothing

auth_check :: Maybe DB.User.Type -> Wai.Middleware
auth_check user' =
	let
		protect :: Wai.Request -> IO Bool
		protect request =
			case Wai.pathInfo request of
				"bin" : "logout" : [] -> return False
				"public" : _ : _ -> return False
				"favicon.ico" : [] -> return False
				_ -> return True
		check :: HttpAuth.CheckCreds
		check _ password =
			return
				(maybe
					False
					(\ user ->
						not (DB.User.lock user) &&
							(Crypto.Scrypt.verifyPass' (Crypto.Scrypt.Pass password)
								$ Crypto.Scrypt.EncryptedPass
								$ BS.C8.pack
								$ DB.User.password user))
					user')
		realm :: HttpAuth.AuthSettings
		realm = Constant.auth_realm{HttpAuth.authIsProtected = protect}
		in HttpAuth.basicAuth check realm

migrate :: DB.Connection -> IO ()
migrate db =
	do
		files <- listDirectory migration_path
		only_done <- DB.query_ db "SELECT \"FILE\" FROM \"MIGRATION\" ORDER BY \"FILE\""
		let
			done = DB.fromOnly <$> only_done
			todo = sort (files \\ done)
			loop [] = return ()
			loop (f : fs) =
				do
					putStrLn ("migrate: " ++ f)
					sql <- BS.readFile (migration_path </> f)
					result <- DB.exec db sql
					status <- Database.PostgreSQL.LibPQ.resultStatus result
					let migrated =
						DB.execute db "INSERT INTO \"MIGRATION\" (\"FILE\") VALUES (?)" (DB.Only f) >>= \case
							1 -> loop fs
							_ -> putStrLn "ERROR: unable modify migration record"
					case status of
						Database.PostgreSQL.LibPQ.CommandOk -> migrated
						Database.PostgreSQL.LibPQ.TuplesOk -> migrated
						_ -> putStrLn ("ERROR: fail to run migration: " ++ show status)
		loop todo

main :: IO ()
main =
	do
		hSetBuffering stdout LineBuffering
		port <- fromMaybe default_port <$> (readMaybe =<<) <$> lookupEnv "PORT"
		dburl <- fromMaybe "" <$> lookupEnv "DATABASE_URL"
		log <- fromMaybe True <$> (readMaybe =<<) <$> lookupEnv "LOG"
		putStrLn "Configuration"
		putStrLn ("\tport: " ++ show port)
		putStrLn ("\tdatabase: " ++ show dburl)
		putStrLn ("\tlog: " ++ show log)
		getArgs >>= \case
			[] ->
				do
					db <- DB.connectPostgreSQL (BS.C8.pack dburl)
					let handle request respond =
						do
							user' <- get_user db request
							let application =
								HTTP.log log
									$ handle_home
									$ auth_check user'
									$ case user' of
										Nothing -> id
										Just user ->
											Web.handle
												Session.Record{
													Session.log = log,
													Session.database = db,
													Session.user = user}
									$ Wai.Static.staticApp (Wai.Static.defaultWebAppSettings static_path)
							application request respond
					Warp.run port handle
			["adduser", username@(_:_), password@(_:_), role's@(_:_)] ->
				case readMaybe role's of
					Just role ->
						do
							db <- DB.connectPostgreSQL (BS.C8.pack dburl)
							encrypted <- Crypto.Scrypt.encryptPassIO' (Crypto.Scrypt.Pass (BS.C8.pack password))
							n <-
								DB.execute
									db
									"INSERT INTO \"USER\"(\"NAME\",\"PASSWORD\") VALUES(?,?,?)"
									(username, Crypto.Scrypt.getEncryptedPass encrypted, fromEnum (role :: Constant.Role.Type))
							case n of
								1 ->
									do
										putStrLn "OK"
										exitSuccess
								_ ->
									do
										putStrLn "Fail"
										exitFailure
					_ ->
						do
							putStrLn "Unknown role"
							exitFailure
			["migrate"] ->
				do
					db <- DB.connectPostgreSQL (BS.C8.pack dburl)
					migrate db
					DB.close db
			_ ->
				do
					putStrLn "Commands:"
					putStrLn "\t(no argument): start server"
					putStrLn "\tadduser {username} {password} {role}: add a new user"

{- -------------------------------------------------------------------------------------------------------------------------- -}
