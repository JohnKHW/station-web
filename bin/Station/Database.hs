module Station.Database (Type, Mark) where

import Prelude ()
import Data.Int (Int32)
import qualified Database.PostgreSQL.Simple

type Type = Database.PostgreSQL.Simple.Connection

type Mark = Int32
