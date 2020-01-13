module Station.HTTP (
	log, respond_200, respond_400, respond_401, respond_403, respond_404, respond_405, respond_409, respond_422,
	respond_redirect, respond_301, respond_303, respond_XML,
	auth_user
) where

import Prelude ()
import Data.Bool (Bool (True, False))
import Data.Maybe (Maybe, maybe)
import Data.Tuple (fst)
import Data.List ((++), lookup)
import Data.String (String, fromString)
import Data.Function ((.))
import Data.Functor ((<$>))
import Control.Monad ((=<<))
import Text.Show (show)
import Data.Time (getZonedTime, formatTime, defaultTimeLocale)
import System.IO (putChar, putStr)
import qualified Data.ByteString as BS
import qualified Data.ByteString.Char8 as BS.C8
import qualified Data.ByteString.UTF8 as BS.U8
import qualified Data.ByteString.Lazy as BS.L
import qualified Data.ByteString.Lazy.UTF8 as BS.L.U8
import qualified Network.HTTP.Types as HTTP
import qualified Network.Wai as Wai
import qualified Network.Wai.Middleware.HttpAuth as HttpAuth

log :: Bool -> Wai.Middleware
log False next request respond = next request respond
log True  next request respond =
	do
		putStr . formatTime defaultTimeLocale "%FT%T%z" =<< getZonedTime
		putStr " HTTP "
		putStr (show (Wai.remoteHost request))
		putChar ' '
		BS.C8.putStr (Wai.requestMethod request)
		putChar ' '
		putStr
			(maybe
				"()"
				(show . BS.U8.toString . fst)
				(HttpAuth.extractBasicAuth =<< lookup HTTP.hAuthorization (Wai.requestHeaders request)))
		putChar ' '
		BS.C8.putStrLn (Wai.rawPathInfo request)
		next request respond

respond_200 :: Wai.Application
respond_200 _ respond =
	respond (Wai.responseLBS HTTP.status200 [("Content-Type", "text/plain; charset=ASCII")] "OK")

respond_400 :: String -> Wai.Application
respond_400 message _ respond =
	respond (Wai.responseLBS HTTP.status400 [("Content-Type", "text/plain; charset=ASCII")] (BS.L.U8.fromString message))

respond_401 :: String -> Wai.Application
respond_401 realm _ respond =
	respond
		(Wai.responseLBS
			HTTP.status401
			[
				("Content-Type", "text/plain; charset=ASCII"),
				("WWW-Authenticate", fromString ("Basic realm=\"" ++ realm ++ "\", charset=\"UTF-8\""))]
			"UNAUTHORIZED")

respond_403 :: Wai.Application
respond_403 _ respond =
	respond (Wai.responseLBS HTTP.status403 [("Content-Type", "text/plain; charset=ASCII")] "FORBIDDEN")

respond_404 :: Wai.Application
respond_404 _ respond =
	respond (Wai.responseLBS HTTP.status404 [("Content-Type", "text/plain; charset=ASCII")] "NOT FOUND")

respond_405 :: Wai.Application
respond_405 _ respond =
	respond (Wai.responseLBS HTTP.status405 [("Content-Type", "text/plain; charset=ASCII")] "METHOD NOT ALLOWED")

respond_409 :: String -> Wai.Application
respond_409 message _ respond =
	respond (Wai.responseLBS HTTP.status409 [("Content-Type", "text/plain; charset=ASCII")] (BS.L.U8.fromString message))

respond_422 :: String -> Wai.Application
respond_422 message _ respond =
	respond (Wai.responseLBS HTTP.status422 [("Content-Type", "text/plain; charset=ASCII")] (BS.L.U8.fromString message))

respond_redirect :: HTTP.Status -> BS.L.ByteString -> BS.ByteString -> Wai.Application
respond_redirect status text location _ respond =
	respond (Wai.responseLBS status [("Content-Type", "text/plain; charset=ASCII"), ("Location", location)] text)

respond_301 :: BS.ByteString -> Wai.Application
respond_301 = respond_redirect HTTP.status301 "MOVED PERMANENTLY"

respond_303 :: BS.ByteString -> Wai.Application
respond_303 = respond_redirect HTTP.status303 "SEE OTHER"

respond_XML :: String -> Wai.Application
respond_XML body _ respond =
	respond
		(Wai.responseLBS
			HTTP.status200
			[("Content-Type", "text/xml; charset=UTF-8")]
			(BS.L.U8.fromString body))

auth_user :: Wai.Request -> Maybe BS.ByteString
auth_user request = fst <$> (HttpAuth.extractBasicAuth =<< lookup HTTP.hAuthorization (Wai.requestHeaders request))
