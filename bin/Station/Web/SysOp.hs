module Station.Web.SysOp (handle) where

import Prelude ()
import Data.Bool (Bool (True, False), otherwise)
import Data.Eq ((==))
import Data.Maybe (Maybe (Nothing, Just), isJust)
import Data.Tuple (fst)
import Data.Monoid ((<>))
import Data.List (map, lookup)
import Data.String (IsString)
import Data.Function (id, (.), flip)
import Data.Functor ((<$>))
import Control.Monad ((>>=), (=<<))
import Text.Show (show)
import Text.Read (readMaybe)
import qualified Data.ByteString.Char8 as BS.C8
import qualified Data.ByteString.UTF8 as BS.U8
import qualified Data.Text (Text, unpack)
import qualified Network.HTTP.Types
import qualified Network.Wai as Wai
import qualified Network.Wai.Parse as Wai.Parse

import qualified Station.Constant.Role as Constant.Role
import qualified Station.XML as XML
import qualified Station.Database as DB
import qualified Station.Database.User as DB.User
import qualified Station.Database.Subject as DB.Subject
import qualified Station.Database.Course as DB.Course
import qualified Station.Database.Lesson as DB.Lesson
import qualified Station.Database.Question as DB.Question
import qualified Station.Database.Answer as DB.Answer
import qualified Station.HTTP as HTTP
import qualified Station.Web.Tool as Web.Tool
import qualified Station.Web.Session as Session

path_prefix :: IsString s => s
path_prefix = "/sysop/"

handle_account :: Session.Type -> Wai.Application
handle_account session request respond
	| Wai.requestMethod request == Network.HTTP.Types.methodGet =
		do
			users <- DB.User.list (Session.database session)
			HTTP.respond_XML
				(XML.xslt
					(path_prefix <> "account.xsl")
					(XML.element "account" []
						(Web.Tool.user_XML (Session.user session) :
							map
								(\ user ->
									XML.element
										"user"
										((if DB.User.lock user then (("lock", "") :) else id)
											[("role", show (DB.User.role user)), ("mark", show (DB.User.mark user))])
										[XML.text (DB.User.name user)])
								users)))
				request
				respond
	| Wai.requestMethod request == Network.HTTP.Types.methodPost =
		do
			parameters <- fst <$> Wai.Parse.parseRequestBody Wai.Parse.lbsBackEnd request
			case map (flip lookup parameters) ["delete", "user", "name", "role", "password", "mark", "lock"] of
				[Nothing, Nothing, Just name, Just role', Just password, Just mark', lock] ->
					case (readMaybe (BS.U8.toString role'), readMaybe (BS.U8.toString mark')) of
						(Just role, Just mark) ->
							let new =
								DB.User.Record{
									DB.User.name = BS.U8.toString name,
									DB.User.role = role,
									DB.User.password = BS.U8.toString password,
									DB.User.mark = mark,
									DB.User.lock = isJust lock}
								in redirect_result =<< DB.User.add new (Session.database session)
						_ ->
							do
								BS.C8.putStr "Incorrect role: "
								BS.C8.putStrLn role'
								HTTP.respond_404 request respond
				[Nothing, Just user, Just name, Just role', Just password, Just mark', lock] ->
					case (readMaybe (BS.U8.toString role'), readMaybe (BS.U8.toString mark')) of
						(Just role, Just mark) ->
							let new =
								DB.User.Record{
									DB.User.name = BS.U8.toString name,
									DB.User.role = role,
									DB.User.password = BS.U8.toString password,
									DB.User.mark = mark,
									DB.User.lock = isJust lock}
								in redirect_result =<< DB.User.set (BS.U8.toString user) new (Session.database session)
						_ ->
							do
								BS.C8.putStr "Incorrect role: "
								BS.C8.putStrLn role'
								HTTP.respond_404 request respond
				Just _ : Just user : _ ->
					redirect_result =<< DB.User.delete (BS.U8.toString user) (Session.database session)
				_ -> HTTP.respond_400 "Incorrect form field" request respond
	| otherwise =
		HTTP.respond_405 request respond
	where
		redirect_result True = HTTP.respond_303 (path_prefix <> "account") request respond
		redirect_result False = HTTP.respond_404 request respond

handle_subjects :: Session.Type -> Wai.Application
handle_subjects session request respond
	| Wai.requestMethod request == Network.HTTP.Types.methodGet =
		do
			subjects <- DB.Subject.list (Session.database session)
			HTTP.respond_XML
				(XML.xslt
					(path_prefix <> "subjects.xsl")
					(XML.element "subjects" []
						(Web.Tool.user_XML (Session.user session) :
							map
								(\ subject ->
									XML.element "item" [] [
										XML.element "identifier" [] [XML.text (show (DB.Subject.identifier subject))],
										XML.element "title" [] [XML.text (DB.Subject.title subject)],
										XML.element "description" [] [XML.text (DB.Subject.description subject)]])
								subjects)))
				request
				respond
	| Wai.requestMethod request == Network.HTTP.Types.methodPost =
		do
			parameters <- fst <$> Wai.Parse.parseRequestBody Wai.Parse.lbsBackEnd request
			case
				(
					BS.U8.toString <$> lookup "title" parameters,
					BS.U8.toString <$> lookup "description" parameters)
				of
					(Just title, Just description) ->
						DB.Subject.add title description (Session.database session) >>= \case
							Nothing ->
								HTTP.respond_404 request respond
							Just identifier ->
								HTTP.respond_303 ("subject/" <> BS.U8.fromString (show identifier)) request respond
					_ -> HTTP.respond_400 "Incorrect form field" request respond
	| otherwise =
		HTTP.respond_405 request respond

handle_subject :: Session.Type -> DB.Subject.Identifier -> Wai.Application
handle_subject session identifier request respond
	| Wai.requestMethod request == Network.HTTP.Types.methodGet =
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
	| Wai.requestMethod request == Network.HTTP.Types.methodPost =
		do
			parameters <- fst <$> Wai.Parse.parseRequestBody Wai.Parse.lbsBackEnd request
			case
				(
					BS.U8.toString <$> lookup "title" parameters,
					BS.U8.toString <$> lookup "description" parameters,
					BS.U8.toString <$> lookup "delete" parameters)
				of
					(_, _, Just _) ->
						do
							_ <- DB.Subject.delete identifier (Session.database session)
							HTTP.respond_303 "../subjects" request respond
					(Just title, Just description, Nothing) ->
						let
							subject =
								DB.Subject.Record{
									DB.Subject.identifier = identifier,
									DB.Subject.title = title,
									DB.Subject.description = description}
							redirect_result True = HTTP.respond_303 "" request respond
							redirect_result False = HTTP.respond_404 request respond
							in redirect_result =<< DB.Subject.set subject (Session.database session)
					_ -> HTTP.respond_400 "Incorrect form field" request respond
	| otherwise =
		HTTP.respond_405 request respond

handle_course_new :: DB.Type -> DB.Subject.Identifier -> Wai.Application
handle_course_new db subject request respond
	| Wai.requestMethod request == Network.HTTP.Types.methodPost =
		do
			parameters <- fst <$> Wai.Parse.parseRequestBody Wai.Parse.lbsBackEnd request
			case map (flip lookup parameters) ["title", "description"] of
				[Just title, Just description] ->
					DB.Course.add subject (BS.U8.toString title) (BS.U8.toString description) db >>= \case
						Nothing ->
							HTTP.respond_404 request respond
						Just identifier ->
							HTTP.respond_303 ("../" <> BS.U8.fromString (show identifier)) request respond
				_ -> HTTP.respond_400 "Incorrect form field" request respond
	| otherwise =
		HTTP.respond_405 request respond

handle_course :: Session.Type -> DB.Course.Identifier -> Wai.Application
handle_course session identifier request respond
	| Wai.requestMethod request == Network.HTTP.Types.methodGet =
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
			_ -> HTTP.respond_400 "Incorrect identifier" request respond
	| Wai.requestMethod request == Network.HTTP.Types.methodPost =
		do
			parameters <- fst <$> Wai.Parse.parseRequestBody Wai.Parse.lbsBackEnd request
			case map (flip lookup parameters) ["subject", "title", "description", "delete"] of
				[Just subject, _, _, Just _] ->
					do
						_ <- DB.Course.delete identifier (Session.database session)
						HTTP.respond_303 ("../subject/" <> subject) request respond
				[Just subject', Just title, Just description, Nothing] ->
					case readMaybe (BS.U8.toString subject') of
						Just subject ->
							let
								new =
									DB.Course.Record{
										DB.Course.identifier = identifier,
										DB.Course.subject = subject,
										DB.Course.title = BS.U8.toString title,
										DB.Course.description = BS.U8.toString description}
								in
									DB.Course.set new (Session.database session) >>= \case
										True -> HTTP.respond_303 "" request respond
										False -> HTTP.respond_404 request respond
						_ -> HTTP.respond_400 "Incorrect subject" request respond
				_ -> HTTP.respond_400 "Incorrect form field" request respond
	| otherwise =
		HTTP.respond_405 request respond

handle_lesson_new :: DB.Type -> DB.Course.Identifier -> Wai.Application
handle_lesson_new db course request respond
	| Wai.requestMethod request == Network.HTTP.Types.methodPost =
		do
			parameters <- fst <$> Wai.Parse.parseRequestBody Wai.Parse.lbsBackEnd request
			case (lookup "title" parameters, lookup "content" parameters) of
				(Just title, Just content) ->
					DB.Lesson.add course (BS.U8.toString title) (BS.U8.toString content) db >>= \case
						Nothing ->
							HTTP.respond_404 request respond
						Just identifier ->
							HTTP.respond_303 ("../" <> BS.U8.fromString (show identifier)) request respond
				_ -> HTTP.respond_400 "Incorrect form field" request respond
	| otherwise =
		HTTP.respond_405 request respond

handle_lesson_exchange :: DB.Type -> DB.Course.Identifier -> Wai.Application
handle_lesson_exchange db course request respond
	| Wai.requestMethod request == Network.HTTP.Types.methodPost =
		do
			parameters <- fst <$> Wai.Parse.parseRequestBody Wai.Parse.lbsBackEnd request
			case (lookup "0" parameters, lookup "1" parameters) of
				(Just a', Just b') ->
					case (readMaybe (BS.U8.toString a'), readMaybe (BS.U8.toString b')) of
						(Just a, Just b) ->
							DB.Lesson.exchange a b db >>= \case
								True -> HTTP.respond_303 ("../../course/" <> BS.U8.fromString (show course)) request respond
								False -> HTTP.respond_409 "Fail to re-order" request respond
						_ -> HTTP.respond_400 "Incorrect identifiers" request respond
				_ -> HTTP.respond_400 "Incorrect form field" request respond
	| otherwise =
		HTTP.respond_405 request respond

handle_lesson :: Session.Type -> DB.Lesson.Identifier -> Wai.Application
handle_lesson session identifier request respond
	| Wai.requestMethod request == Network.HTTP.Types.methodGet =
		DB.Lesson.get identifier (Session.database session) >>= \case
			[lesson] ->
				do
					questions <- DB.Question.list identifier (Session.database session)
					HTTP.respond_XML
						(XML.xslt
							(path_prefix <> "lesson.xsl")
							(XML.element "lesson" [] [
								Web.Tool.user_XML (Session.user session),
								XML.element "identifier" [] [XML.text (show identifier)],
								XML.element "number" [] [XML.text (show (DB.Lesson.number lesson))],
								XML.element "course" [] [XML.text (show (DB.Lesson.course lesson))],
								XML.element "title" [] [XML.text (DB.Lesson.title lesson)],
								XML.element "content" [] [XML.text (DB.Lesson.content lesson)],
								XML.element "questions" []
									(map
										(\ question ->
											XML.element "question" [] [
												XML.element "identifier" [] [XML.text (show (DB.Question.identifier question))],
												XML.element "number" [] [XML.text (show (DB.Question.number question))],
												XML.element "text" [] [XML.text (DB.Question.text question)]])
										questions)]))
						request
						respond
			_ -> HTTP.respond_400 "Incorrect identifier" request respond
	| Wai.requestMethod request == Network.HTTP.Types.methodPost =
		do
			parameters <- fst <$> Wai.Parse.parseRequestBody Wai.Parse.lbsBackEnd request
			case map (flip lookup parameters) ["course", "number", "title", "content", "delete"] of
				[Just course, _, _, _, Just _] ->
					do
						_ <- DB.Lesson.delete identifier (Session.database session)
						HTTP.respond_303 ("../course/" <> course) request respond
				[Just course', Just number', Just title, Just content, Nothing] ->
					case (readMaybe (BS.U8.toString course'), readMaybe (BS.U8.toString number')) of
						(Just course, Just number) ->
							let
								new =
									DB.Lesson.Record{
										DB.Lesson.identifier = identifier,
										DB.Lesson.course = course,
										DB.Lesson.number = number,
										DB.Lesson.title = BS.U8.toString title,
										DB.Lesson.content = BS.U8.toString content}
								in
									DB.Lesson.set new (Session.database session) >>= \case
										True -> HTTP.respond_303 "" request respond
										False -> HTTP.respond_409 "Fail to modify" request respond
						_ -> HTTP.respond_400 "Incorrect course or number" request respond
				_ -> HTTP.respond_400 "Incorrect form field" request respond
	| otherwise =
		HTTP.respond_405 request respond

handle_question_new :: DB.Type -> DB.Lesson.Identifier -> Wai.Application
handle_question_new db lesson request respond
	| Wai.requestMethod request == Network.HTTP.Types.methodPost =
		do
			parameters <- fst <$> Wai.Parse.parseRequestBody Wai.Parse.lbsBackEnd request
			case lookup "text" parameters of
				Just text ->
					DB.Question.add lesson (BS.U8.toString text) db >>= \case
						Nothing ->
							HTTP.respond_404 request respond
						Just identifier ->
							HTTP.respond_303 ("../" <> BS.U8.fromString (show identifier)) request respond
				_ -> HTTP.respond_400 "Incorrect form field" request respond
	| otherwise =
		HTTP.respond_405 request respond

handle_question_exchange :: DB.Type -> DB.Question.Identifier -> Wai.Application
handle_question_exchange db lesson request respond
	| Wai.requestMethod request == Network.HTTP.Types.methodPost =
		do
			parameters <- fst <$> Wai.Parse.parseRequestBody Wai.Parse.lbsBackEnd request
			case (lookup "0" parameters, lookup "1" parameters) of
				(Just a', Just b') ->
					case (readMaybe (BS.U8.toString a'), readMaybe (BS.U8.toString b')) of
						(Just a, Just b) ->
							DB.Question.exchange a b db >>= \case
								True -> HTTP.respond_303 ("../../lesson/" <> BS.U8.fromString (show lesson)) request respond
								False -> HTTP.respond_409 "Fail to re-order" request respond
						_ -> HTTP.respond_400 "Incorrect identifiers" request respond
				_ -> HTTP.respond_400 "Incorrect form field" request respond
	| otherwise =
		HTTP.respond_405 request respond

handle_question :: Session.Type -> DB.Question.Identifier -> Wai.Application
handle_question session identifier request respond
	| Wai.requestMethod request == Network.HTTP.Types.methodGet =
		DB.Question.get identifier (Session.database session) >>= \case
			[question] ->
				do
					answers <- DB.Answer.list identifier (Session.database session)
					HTTP.respond_XML
						(XML.xslt
							(path_prefix <> "question.xsl")
							(XML.element "question" [] [
								Web.Tool.user_XML (Session.user session),
								XML.element "identifier" [] [XML.text (show identifier)],
								XML.element "lesson" [] [XML.text (show (DB.Question.lesson question))],
								XML.element "number" [] [XML.text (show (DB.Question.number question))],
								XML.element "text" [] [XML.text (DB.Question.text question)],
								XML.element "answers" []
									(map
										(\ answer ->
											XML.element "answer" [] [
												XML.element "identifier" [] [XML.text (show (DB.Answer.identifier answer))],
												XML.element "text" [] [XML.text (DB.Answer.text answer)],
												XML.element "mark" [] [XML.text (show (DB.Answer.mark answer))]])
										answers)]))
						request
						respond
			_ -> HTTP.respond_400 "Incorrect identifier" request respond
	| Wai.requestMethod request == Network.HTTP.Types.methodPost =
		do
			parameters <- fst <$> Wai.Parse.parseRequestBody Wai.Parse.lbsBackEnd request
			case map (flip lookup parameters) ["lesson", "text", "delete"] of
				[Just lesson, _, Just _] ->
					do
						_ <- DB.Question.delete identifier (Session.database session)
						HTTP.respond_303 ("../lesson/" <> lesson) request respond
				[_, Just text, Nothing] ->
					DB.Question.set identifier (BS.U8.toString text) (Session.database session) >>= \case
						True -> HTTP.respond_303 "" request respond
						False -> HTTP.respond_409 "Fail to modify" request respond
				_ -> HTTP.respond_400 "Incorrect form field" request respond
	| otherwise =
		HTTP.respond_405 request respond

handle_answer_new :: DB.Type -> DB.Question.Identifier -> Wai.Application
handle_answer_new db question request respond
	| Wai.requestMethod request == Network.HTTP.Types.methodPost =
		do
			parameters <- fst <$> Wai.Parse.parseRequestBody Wai.Parse.lbsBackEnd request
			case (lookup "text" parameters, (readMaybe . BS.U8.toString) =<< lookup "mark" parameters) of
				(Just text, Just mark) ->
					DB.Answer.add question (BS.U8.toString text) mark db >>= \case
						Nothing ->
							HTTP.respond_404 request respond
						Just _ ->
							HTTP.respond_303 ("../../question/" <> BS.U8.fromString (show question)) request respond
				_ -> HTTP.respond_400 "Incorrect form field" request respond
	| otherwise =
		HTTP.respond_405 request respond

handle_answer :: Session.Type -> DB.Answer.Identifier -> Wai.Application
handle_answer session identifier request respond
	| Wai.requestMethod request == Network.HTTP.Types.methodPost =
		do
			parameters <- fst <$> Wai.Parse.parseRequestBody Wai.Parse.lbsBackEnd request
			case map (flip lookup parameters) ["question", "text", "mark", "delete"] of
				[Just question, _, _, Just _] ->
					do
						_ <- DB.Answer.delete identifier (Session.database session)
						HTTP.respond_303 ("../question/" <> question) request respond
				[Just question', Just text, Just mark', Nothing] ->
					case (readMaybe (BS.U8.toString question'), readMaybe (BS.U8.toString mark')) of
						(Just question, Just mark) ->
							let
								new =
									DB.Answer.Record{
										DB.Answer.identifier = identifier,
										DB.Answer.question = question,
										DB.Answer.text = BS.U8.toString text,
										DB.Answer.mark = mark}
								in
									DB.Answer.set new (Session.database session) >>= \case
										True -> HTTP.respond_303 ("../question/" <> question') request respond
										False -> HTTP.respond_404 request respond
						_ -> HTTP.respond_400 "Incorrect question" request respond
				_ -> HTTP.respond_400 "Incorrect form field" request respond
	| otherwise =
		HTTP.respond_405 request respond

handle :: Session.Type -> [Data.Text.Text] -> Wai.Middleware
handle session path next request respond =
	case session of
		Session.Record{Session.user = DB.User.Record{DB.User.role = Constant.Role.SysOp}, Session.database = db} ->
			case path of
				["account"] -> handle_account session request respond
				["subjects"] -> handle_subjects session request respond
				["subject", subject'] ->
					case readMaybe (Data.Text.unpack subject') of
						Just subject -> handle_subject session subject request respond
						_ -> next request respond
				["course", "new", subject'] ->
					case readMaybe (Data.Text.unpack subject') of
						Just subject -> handle_course_new db subject request respond
						_ -> next request respond
				["course", course'] ->
					case readMaybe (Data.Text.unpack course') of
						Just course -> handle_course session course request respond
						_ -> next request respond
				["lesson", "new", course'] ->
					case readMaybe (Data.Text.unpack course') of
						Just course -> handle_lesson_new db course request respond
						_ -> next request respond
				["lesson", "exchange", course'] ->
					case readMaybe (Data.Text.unpack course') of
						Just course -> handle_lesson_exchange db course request respond
						_ -> next request respond
				["lesson", lesson'] ->
					case readMaybe (Data.Text.unpack lesson') of
						Just lesson -> handle_lesson session lesson request respond
						_ -> next request respond
				["question", "new", lesson'] ->
					case readMaybe (Data.Text.unpack lesson') of
						Just lesson -> handle_question_new db lesson request respond
						_ -> next request respond
				["question", "exchange", lesson'] ->
					case readMaybe (Data.Text.unpack lesson') of
						Just lesson -> handle_question_exchange db lesson request respond
						_ -> next request respond
				["question", question'] ->
					case readMaybe (Data.Text.unpack question') of
						Just question -> handle_question session question request respond
						_ -> next request respond
				["answer", "new", question'] ->
					case readMaybe (Data.Text.unpack question') of
						Just question -> handle_answer_new db question request respond
						_ -> next request respond
				["answer", answer'] ->
					case readMaybe (Data.Text.unpack answer') of
						Just answer -> handle_answer session answer request respond
						_ -> next request respond
				_ -> next request respond
		_ -> HTTP.respond_403 request respond
