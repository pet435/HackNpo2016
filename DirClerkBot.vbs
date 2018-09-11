	'Константы или значения "по умолчанию"
	SYSCODE = "TEHKASNPO"			'Код системы ТЕХКАС
	WorkRefName = "РАБ"
	RefName = "ПДД"				'Имя справочника "Обращения"
  
	'Создать подключение
	DIM Login, App, ReferenceFactory, DS, ServiceFactory, List 
	SET Login = CreateObject("SBLogon.LoginPoint")
	SET App = Login.GetApplication("SystemCode=" & SYSCODE)
  
  
	function getUserLoginByPhone(byVal PhoneNumber)		
		' Получить работника
		SET WorkRef = App.ReferencesFactory.ReferenceFactory("РАБ").GetComponent
		AddWhere1 = "MBAnalit.dop5 = '" & PhoneNumber & "'" 'TODO надо сделать проверку строки на корректность, т.к. бывают и без + и в таком формате 8-995-55.. 
		AddWhereID = WorkRef.AddWhere(AddWhere1)
		WorkRef.Open
		if WorkRef.RecordCount = 0 then
			if len(PhoneNumber) = 12 then
				PhoneNumber2 = left(PhoneNumber, 2) & "-" & right(left(PhoneNumber, 5), 3) & "-" & right(left(PhoneNumber, 8), 3) & "-" & right(PhoneNumber, 4)
			end if
			WorkRef.DelWhere(AddWhereID)
			AddWhere1 = "MBAnalit.dop5 = '" & PhoneNumber2 & "'" 'TODO надо сделать проверку строки на корректность, т.к. бывают и без + и в таком формате 8-995-55.. 
			AddWhereID = WorkRef.AddWhere(AddWhere1)
			WorkRef.Refresh
		end if
		'WorkRef.ComponentForm.Show ' ОТЛАДКА	
		WorkRef.OpenRecord
		'getUserIdByPhone = WorkRef.Requisites("ИД").Value
		getUserLoginByPhone = ltrim(WorkRef.Requisites("Реквизит").Value)
		WorkRef.Close
	end function
	
	
	function getUserFIObyPhone(byVal PhoneNumber)
		'Получить ФИ работника по телефону
		SET WorkRef = App.ReferencesFactory.ReferenceFactory(WorkRefName).GetComponent
		AddWhere1 = "MBAnalit.dop5 = '" & PhoneNumber & "'" 'TODO надо сделать проверку строки на корректность, т.к. бывают и без + и в таком формате 8-995-55.. 
		WorkRef.AddWhere(AddWhere1)
		WorkRef.Open
		WorkRef.OpenRecord
		getUserFIObyPhone = ltrim(WorkRef.Requisites("Наименование").Value)
		WorkRef.Close
	end function
	
	
	function getUserChiefLogin(byVal PhoneNumber)
		'Получить Руководителя работника по телефону
		SET WorkRef = App.ReferencesFactory.ReferenceFactory(WorkRefName).GetComponent
		AddWhere1 = "MBAnalit.dop5 = '" & PhoneNumber & "'" 'TODO надо сделать проверку строки на корректность, т.к. бывают и без + и в таком формате 8-995-55.. 
		WorkRef.AddWhere(AddWhere1)
		WorkRef.Open
		WorkRef.OpenRecord
		DepartmentRefName =	WorkRef.Requisites("Подразделение").ReferenceName 
		DepartmentID = WorkRef.Requisites("Подразделение").ValueID
		SET DepartmentRef = App.ReferencesFactory.ReferenceFactory(DepartmentRefName).GetObjectByID(DepartmentID)	
		ChiefID = DepartmentRef.Requisites("Работник").ValueID
		
		WorkRef.Close
		AddWhere2 = "MBAnalit.Analit = " & ChiefID 
		WorkRef.AddWhere(AddWhere2)
		WorkRef.Open
		WorkRef.OpenRecord
		getUserChiefLogin = ltrim(WorkRef.Requisites("Реквизит").Value)
		WorkRef.Close
	end function
	
	
	' 1. Контакты
	function getContacts(byVal UserName)
		' Получить сводку по работнику по ФИО
		SET WorkRef = App.ReferencesFactory.ReferenceFactory(WorkRefName).GetComponent
		'TODO прикрутить анализ по словоформам
		AddWhere1 = "MBAnalit.NameAn like '%" & UserName & "%'" 
		AddWhere2 = "MBAnalit.Sost = 'Д'" 
		WorkRef.AddWhere(AddWhere1)
		WorkRef.AddWhere(AddWhere2)
		WorkRef.Open
		'WorkRef.ComponentForm.Show ' ОТЛАДКА	
		WorkRef.OpenRecord
		FIO = WorkRef.Requisites("Строка").AsString
		division = WorkRef.Requisites("Подразделение").DisplayText
		position = WorkRef.Requisites("Должность").DisplayText
		'chief = 
		number = WorkRef.Requisites("Дополнение5").AsString
		email = WorkRef.Requisites("Строка2").AsString
		getContacts = FIO &  vbCr  & division & vbCr & position &  vbCr  & "тел: " & number &  vbCr  & "email: " & email & vbCr 
		WorkRef.Close	 
    end function
  
  
	' Старт задачи
	sub sendTask(subject, receiver, jobtype, deadline, text)
		' jobtype 0 - задание, 1 - уведомление
		' Отправить задачу
		RouteCode = "ReqProc"
		SET TaskFactory = App.TaskFactory
		SET Task = TaskFactory.CreateNew()
		SET User = App.ServiceFactory.GetUserByName(receiver)
		SET RouteStep = TaskFactory.CreateRouteStep(Task.Route.Count, User, jobtype, "", "", "")
        Task.Route.Add(RouteStep)
        Task.Requisites("Subject").AsString = subject
		Task.FinalDate = deadline
        Task.ActiveText = text
		'Task.Form.ShowModal
		Task.Start
	end sub
  
  
	' 2. Задержусь
	sub absence(byVal PhoneNumber, newTime)
		ab_employeeName = getUserFIObyPhone(PhoneNumber)
		ab_subject = "Уведомление об отсутствии. " & ab_employeeName & " задерживается"
		ab_receiver = getUserLoginByPhone(PhoneNumber) 'getUserChiefLogin(PhoneNumber)
		ab_jobtype = 1 'Уведомление
		newTime = ltrim(rtrim(newTime))
		cometime = DateAdd("h", newTime, now) 
		if newTime = 1 then
			ab_text = "Задание для пользователя " & getUserChiefLogin(PhoneNumber) & ". Сотрудник задерживается на " & newTime & " час. Выход на работу: " & cometime
		end if
		if newTime >= 2 or newTime <= 4 then
			ab_text = "Задание для пользователя " & getUserChiefLogin(PhoneNumber) & ". Сотрудник задерживается на " & newTime & " часа. Выход на работу: " & cometime
		else 
			ab_text = "Задание для пользователя " & getUserChiefLogin(PhoneNumber) & ". Сотрудник задерживается на " & newTime & " часов. Выход на работу: " & cometime
		end if
		
		sendTask ab_subject, ab_receiver, ab_jobtype, "", ab_text
	end sub

	' Заболел
	
	' Задания на сегодня
	'getInbox()
	
	
	' поиск документа
	'searchEDoc()
	

	

	' РАЗБОР ПАРАМЕТРОВ
	Set objArgs = Wscript.Arguments
	filename = objArgs(0)
	command = objArgs(1)	
	argument3 = objArgs(2)	
	
	'Работа с файлом. через который будем передавать данные
	dim fso, MyFile
	Set fso = CreateObject("Scripting.FileSystemObject")
	Set MyFile = fso.OpenTextFile(filename, 2, True)
	
	select case command
		case "getUserLoginByPhone"
			MyFile.WriteLine getUserLoginByPhone(argument3)
			
		case "getUserFIObyPhone"
			MyFile.WriteLine getUserFIObyPhone(argument3)
			
		case "getUserChiefLogin"
			MyFile.WriteLine getUserChiefLogin(argument3)
			
		case "getContacts"
			str = split(getContacts(argument3), vbCr)
			for each index in str
				MyFile.WriteLine index & vbCr 
			next
		
		case "sendTask"
			'SET MyFile = fso.OpenTextFile (filename, 1)
			'argument3 = MyFile.Readline
			'	msgbox (argument3)
			'arr = split(argument3, ";")
			'subject = arr(0)
			'receiver = arr(1)
			'jobtype = arr(2)
			'deadline = arr(3)
			'text = arr(4)
			'sendTask subject, receiver, jobtype, deadline, text 
			'MyFile.WriteLine "задача отправлена"
			'MyFile.Close
			
			argument4 = objArgs(3)
			absence argument3, argument4
		
		'case getInbox
		'case searchEDoc
	end select

		
	'ОТЛАДКА
	'PhoneNumber = +79501609505
	'res = getUserLoginByPhone(PhoneNumber)
	'res = getContacts("Питомцева")
    'msgbox(res)
	'UserLoging = getUserLoginByPhone(PhoneNumber)
	'sendTask "тема", UserLoging, 1, "01.01.2017", "текст"
	'absence PhoneNumber, "10.11.2016 13:00"
  
  


  

