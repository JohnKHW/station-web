module Station.Web.Learn (handle) where

import Prelude ()
import Data.Bool (otherwise)
import Data.Eq ((==))
import Data.Maybe (Maybe (Just), catMaybes)
import Data.Tuple (fst, snd)
import Data.Monoid ((<>))
import Data.Function ((.))
import Data.Functor ((<$>))
import Data.Foldable (maximum)
import Data.List (map)
import Data.String (IsString)
import Control.Monad ((>>=))
import Text.Show (show)
import Text.Read (readMaybe)
import qualified Data.ByteString.UTF8 as BS.U8
import qualified Data.Text (Text, unpack)
import qualified Network.HTTP.Types
import qualified Network.Wai as Wai
import qualified Network.Wai.Parse as Wai.Parse

import qualified Station.XML as XML
import qualified Station.Database.User as DB.User
import qualified Station.Database.Subject as DB.Subject
import qualified Station.Database.Course as DB.Course
import qualified Station.Database.Lesson as DB.Lesson
import qualified Station.Database.Question as DB.Question
import qualified Station.Database.Answer as DB.Answer
import qualified Station.Database.Work as DB.Work
import qualified Station.HTTP as HTTP
import qualified Station.Web.Tool as Web.Tool
import qualified Station.Web.Session as Session

path_prefix :: IsString s => s
path_prefix = "/learn/"

handle_subject :: Session.Type -> DB.Subject.Identifier -> Wai.Application
handle_subject session identifier request respond =
	DB.Subject.get identifier (Session.database session) >>= \case
		[subject] ->
			do
				courses <- DB.Course.list identifier (Session.database session)
				HTTP.respond_XML
					(XML.xslt
						(path_prefix <> "subject.xsl")
						(XML.element "subject" [] [
							Web.Tool.user_XML (Session.user session),
							XML.element "identifier" [] [XML.text (show identifier)],
							XML.element "title" [] [XML.text (DB.Subject.title subject)],
							XML.element "description" [] [XML.text (DB.Subject.description subject)],
							XML.element "courses" []
								(map
									(\ course ->
										XML.element "course" [] [
											XML.element "identifier" [] [XML.text (show (DB.Course.identifier course))],
											XML.element "title" [] [XML.text (DB.Course.title course)],
											XML.element "description" [] [XML.text (DB.Course.description course)]])
									courses)]))
					request
					respond
		_ -> HTTP.respond_404 request respond

handle_course :: Session.Type -> DB.Course.Identifier -> Wai.Application
handle_course session identifier request respond =
	DB.Course.get identifier (Session.database session) >>= \case
		[course] ->
			do
				lessons <- DB.Lesson.list identifier (Session.database session)
				HTTP.respond_XML
					(XML.xslt
						(path_prefix <> "course.xsl")
						(XML.element "course" [] [
							Web.Tool.user_XML (Session.user session),
							XML.element "identifier" [] [XML.text (show identifier)],
							XML.element "subject" [] [XML.text (show (DB.Course.subject course))],
							XML.element "title" [] [XML.text (DB.Course.title course)],
							XML.element "description" [] [XML.text (DB.Course.description course)],
							XML.element "lessons" []
								(map
									(\ (lesson_identifier, lesson_number, lesson_title) ->
										XML.element "lesson" [] [
											XML.element "identifier" [] [XML.text (show lesson_identifier)],
											XML.element "number" [] [XML.text (show lesson_number)],
											XML.element "title" [] [XML.text lesson_title]])
									lessons)]))
					request
					respond
		_ -> HTTP.respond_404 request respond

handle_lesson :: Session.Type -> DB.Lesson.Identifier -> Wai.Application
handle_lesson session lesson_identifier request respond
	| Wai.requestMethod request == Network.HTTP.Types.methodGet =
		DB.Work.get_lesson (DB.User.name (Session.user session)) lesson_identifier (Session.database session) >>= \case
			[(lesson, questions)] ->
				HTTP.respond_XML
					(XML.xslt
						(path_prefix <> "lesson.xsl")
						(XML.element "lesson" [] [
							Web.Tool.user_XML (Session.user session),
							XML.element "identifier" [] [XML.text (show lesson_identifier)],
							XML.element "course" [] [XML.text (show (DB.Lesson.course lesson))],
							XML.element "number" [] [XML.text (show (DB.Lesson.number lesson))],
							XML.element "title" [] [XML.text (DB.Lesson.title lesson)],
							XML.element "content" [] [XML.text (DB.Lesson.content lesson)],
							XML.element "questions" []
								(map
									(\ (question, answers) ->
										XML.element "question" [] [
											XML.element "identifier" [] [XML.text (show (DB.Question.identifier question))],
											XML.element "number" [] [XML.text (show (DB.Question.number question))],
											XML.element "text" [] [XML.text (DB.Question.text question)],
											XML.element "mark" [] [XML.text (show (maximum (0 : map (DB.Answer.mark . fst) answers)))],
											XML.element "answers" []
												(map
													(\ (answer, answered) ->
														XML.element "answer"
															(if answered
																then [("answered", show (DB.Answer.mark answer))]
																else [])
															[
																XML.element "identifier" [] [XML.text (show (DB.Answer.identifier answer))],
																XML.element "text" [] [XML.text (DB.Answer.text answer)]])
													answers)])
									questions)]))
					request
					respond
			_ -> HTTP.respond_404 request respond
	| Wai.requestMethod request == Network.HTTP.Types.methodPost =
		do
			parameters <- fst <$> Wai.Parse.parseRequestBody Wai.Parse.lbsBackEnd request
			DB.Work.add
				(DB.User.name (Session.user session))
				lesson_identifier
				(catMaybes (map (readMaybe . BS.U8.toString . snd) parameters))
				(Session.database session)
			HTTP.respond_303 "" request respond
	| otherwise =
		HTTP.respond_405 request respond

handle :: Session.Type -> [Data.Text.Text] -> Wai.Middleware
handle session path next request respond =
	case path of
		["subject", subject'] ->
			case readMaybe (Data.Text.unpack subject') of
				Just subject -> handle_subject session subject request respond
				_ -> HTTP.respond_404 request respond
		["course", course'] ->
			case readMaybe (Data.Text.unpack course') of
				Just course -> handle_course session course request respond
				_ -> HTTP.respond_404 request respond
		["lesson", lesson'] ->
			case readMaybe (Data.Text.unpack lesson') of
				Just lesson -> handle_lesson session lesson request respond
				_ -> HTTP.respond_404 request respond
		_ -> next request respond
