module Station.XML (Element, Content, text, element, output, xslt) where

import Prelude ()
import Data.Maybe (Maybe (Nothing))
import Data.List ((++), map)
import Data.String (String)
import Text.XML.Light (
	Content (Elem, Text), Element, Attr (Attr),
	CData (CData), CDataKind (CDataText),
	node, unqual,
	xml_header, showContent, showAttr)

text :: String -> Content
text value = Text (CData CDataText value Nothing)

makeAttr :: (String, String) -> Attr
makeAttr (k, v) = Attr (unqual k) v

element :: String -> [(String, String)] -> [Content] -> Content
element name attributes body = Elem (node (unqual name) (map makeAttr attributes, body))

output :: Content -> String
output content = xml_header ++ showContent content

xslt :: String -> Content -> String
xslt stylesheet content =
	let href = showAttr (Attr (unqual "href") stylesheet) in
		xml_header ++ "<?xml-stylesheet type=\"text/xsl\" " ++ href ++ " ?>" ++ showContent content
