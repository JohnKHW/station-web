module Station.Constant.Role (Type (SysOp, User)) where

import Prelude (Enum (toEnum, fromEnum), undefined)

import Text.Show
import Text.Read

data Type = SysOp | User
	deriving (Show, Read)

instance Enum Type where
	toEnum 0 = SysOp
	toEnum 1 = User
	toEnum _ = undefined
	fromEnum SysOp = 0
	fromEnum User  = 1
