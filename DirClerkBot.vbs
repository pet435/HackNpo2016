	'��������� ��� �������� "�� ���������"
	SYSCODE = "TEHKASNPO"			'��� ������� ������
	WorkRefName = "���"
	RefName = "���"				'��� ����������� "���������"
  
	'������� �����������
	DIM Login, App, ReferenceFactory, DS, ServiceFactory, List 
	SET Login = CreateObject("SBLogon.LoginPoint")
	SET App = Login.GetApplication("SystemCode=" & SYSCODE)
  
  
	function getUserLoginByPhone(byVal PhoneNumber)		
		' �������� ���������
		SET WorkRef = App.ReferencesFactory.ReferenceFactory("���").GetComponent
		AddWhere1 = "MBAnalit.dop5 = '" & PhoneNumber & "'" 'TODO ���� ������� �������� ������ �� ������������, �.�. ������ � ��� + � � ����� ������� 8-995-55.. 
		AddWhereID = WorkRef.AddWhere(AddWhere1)
		WorkRef.Open
		if WorkRef.RecordCount = 0 then
			if len(PhoneNumber) = 12 then
				PhoneNumber2 = left(PhoneNumber, 2) & "-" & right(left(PhoneNumber, 5), 3) & "-" & right(left(PhoneNumber, 8), 3) & "-" & right(PhoneNumber, 4)
			end if
			WorkRef.DelWhere(AddWhereID)
			AddWhere1 = "MBAnalit.dop5 = '" & PhoneNumber2 & "'" 'TODO ���� ������� �������� ������ �� ������������, �.�. ������ � ��� + � � ����� ������� 8-995-55.. 
			AddWhereID = WorkRef.AddWhere(AddWhere1)
			WorkRef.Refresh
		end if
		'WorkRef.ComponentForm.Show ' �������	
		WorkRef.OpenRecord
		'getUserIdByPhone = WorkRef.Requisites("��").Value
		getUserLoginByPhone = ltrim(WorkRef.Requisites("��������").Value)
		WorkRef.Close
	end function
	
	
	function getUserFIObyPhone(byVal PhoneNumber)
		'�������� �� ��������� �� ��������
		SET WorkRef = App.ReferencesFactory.ReferenceFactory(WorkRefName).GetComponent
		AddWhere1 = "MBAnalit.dop5 = '" & PhoneNumber & "'" 'TODO ���� ������� �������� ������ �� ������������, �.�. ������ � ��� + � � ����� ������� 8-995-55.. 
		WorkRef.AddWhere(AddWhere1)
		WorkRef.Open
		WorkRef.OpenRecord
		getUserFIObyPhone = ltrim(WorkRef.Requisites("������������").Value)
		WorkRef.Close
	end function
	
	
	function getUserChiefLogin(byVal PhoneNumber)
		'�������� ������������ ��������� �� ��������
		SET WorkRef = App.ReferencesFactory.ReferenceFactory(WorkRefName).GetComponent
		AddWhere1 = "MBAnalit.dop5 = '" & PhoneNumber & "'" 'TODO ���� ������� �������� ������ �� ������������, �.�. ������ � ��� + � � ����� ������� 8-995-55.. 
		WorkRef.AddWhere(AddWhere1)
		WorkRef.Open
		WorkRef.OpenRecord
		DepartmentRefName =	WorkRef.Requisites("�������������").ReferenceName 
		DepartmentID = WorkRef.Requisites("�������������").ValueID
		SET DepartmentRef = App.ReferencesFactory.ReferenceFactory(DepartmentRefName).GetObjectByID(DepartmentID)	
		ChiefID = DepartmentRef.Requisites("��������").ValueID
		
		WorkRef.Close
		AddWhere2 = "MBAnalit.Analit = " & ChiefID 
		WorkRef.AddWhere(AddWhere2)
		WorkRef.Open
		WorkRef.OpenRecord
		getUserChiefLogin = ltrim(WorkRef.Requisites("��������").Value)
		WorkRef.Close
	end function
	
	
	' 1. ��������
	function getContacts(byVal UserName)
		' �������� ������ �� ��������� �� ���
		SET WorkRef = App.ReferencesFactory.ReferenceFactory(WorkRefName).GetComponent
		'TODO ���������� ������ �� �����������
		AddWhere1 = "MBAnalit.NameAn like '%" & UserName & "%'" 
		AddWhere2 = "MBAnalit.Sost = '�'" 
		WorkRef.AddWhere(AddWhere1)
		WorkRef.AddWhere(AddWhere2)
		WorkRef.Open
		'WorkRef.ComponentForm.Show ' �������	
		WorkRef.OpenRecord
		FIO = WorkRef.Requisites("������").AsString
		division = WorkRef.Requisites("�������������").DisplayText
		position = WorkRef.Requisites("���������").DisplayText
		'chief = 
		number = WorkRef.Requisites("����������5").AsString
		email = WorkRef.Requisites("������2").AsString
		getContacts = FIO &  vbCr  & division & vbCr & position &  vbCr  & "���: " & number &  vbCr  & "email: " & email & vbCr 
		WorkRef.Close	 
    end function
  
  
	' ����� ������
	sub sendTask(subject, receiver, jobtype, deadline, text)
		' jobtype 0 - �������, 1 - �����������
		' ��������� ������
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
  
  
	' 2. ���������
	sub absence(byVal PhoneNumber, newTime)
		ab_employeeName = getUserFIObyPhone(PhoneNumber)
		ab_subject = "����������� �� ����������. " & ab_employeeName & " �������������"
		ab_receiver = getUserLoginByPhone(PhoneNumber) 'getUserChiefLogin(PhoneNumber)
		ab_jobtype = 1 '�����������
		newTime = ltrim(rtrim(newTime))
		cometime = DateAdd("h", newTime, now) 
		if newTime = 1 then
			ab_text = "������� ��� ������������ " & getUserChiefLogin(PhoneNumber) & ". ��������� ������������� �� " & newTime & " ���. ����� �� ������: " & cometime
		end if
		if newTime >= 2 or newTime <= 4 then
			ab_text = "������� ��� ������������ " & getUserChiefLogin(PhoneNumber) & ". ��������� ������������� �� " & newTime & " ����. ����� �� ������: " & cometime
		else 
			ab_text = "������� ��� ������������ " & getUserChiefLogin(PhoneNumber) & ". ��������� ������������� �� " & newTime & " �����. ����� �� ������: " & cometime
		end if
		
		sendTask ab_subject, ab_receiver, ab_jobtype, "", ab_text
	end sub

	' �������
	
	' ������� �� �������
	'getInbox()
	
	
	' ����� ���������
	'searchEDoc()
	

	

	' ������ ����������
	Set objArgs = Wscript.Arguments
	filename = objArgs(0)
	command = objArgs(1)	
	argument3 = objArgs(2)	
	
	'������ � ������. ����� ������� ����� ���������� ������
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
			'MyFile.WriteLine "������ ����������"
			'MyFile.Close
			
			argument4 = objArgs(3)
			absence argument3, argument4
		
		'case getInbox
		'case searchEDoc
	end select

		
	'�������
	'PhoneNumber = +79501609505
	'res = getUserLoginByPhone(PhoneNumber)
	'res = getContacts("���������")
    'msgbox(res)
	'UserLoging = getUserLoginByPhone(PhoneNumber)
	'sendTask "����", UserLoging, 1, "01.01.2017", "�����"
	'absence PhoneNumber, "10.11.2016 13:00"
  
  


  

