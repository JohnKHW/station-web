module Station.Web.Bin (handle) where

import Prelude ()
import Data.Bool (otherwise)
import Data.Eq ((==), (/=))
import Data.Maybe (Maybe (Just))
import Data.Tuple (fst)
import Data.List (lookup)
import Control.Monad ((=<<))
import qualified Data.Text (Text)
import qualified Network.HTTP.Types
import qualified Network.Wai as Wai
import qualified Network.Wai.Middleware.HttpAuth as HttpAuth

import qualified Station.Constant as Constant
import qualified Station.HTTP as HTTP

handle_login :: Wai.Application
handle_login request respond
	| Wai.requestMethod request == Network.HTTP.Types.methodPost =
		HTTP.respond_303 Constant.private_home request respond
	| otherwise =
		HTTP.respond_405 request respond

handle_logout :: Wai.Application
handle_logout request respond
	| Wai.requestMethod request == Network.HTTP.Types.methodPost =
		case HttpAuth.extractBasicAuth =<< lookup Network.HTTP.Types.hAuthorization (Wai.requestHeaders request) of
			Just auth
				| fst auth /= "" ->
					HTTP.respond_401 "Empty user name to logout" request respond
			_ -> HTTP.respond_303 Constant.public_home request respond
	| otherwise =
		HTTP.respond_405 request respond

handle :: [Data.Text.Text] -> Wai.Middleware
handle path next =
	case path of
		["login"] -> handle_login
		["logout"] -> handle_logout
		_ -> next
