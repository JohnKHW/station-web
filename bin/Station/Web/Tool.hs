module Station.Web.Tool (user_XML) where

import Prelude ()
import Text.Show (show)

import qualified Station.XML as XML
import qualified Station.Database.User as DB.User

user_XML :: DB.User.Type -> XML.Content
user_XML user =
	XML.element "session" [] [
		XML.element "name" [] [XML.text (DB.User.name user)],
		XML.element "role" [] [XML.text (show (DB.User.role user))],
		XML.element "mark" [] [XML.text (show (DB.User.mark user))]]
