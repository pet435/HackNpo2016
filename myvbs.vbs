
	'��������� ��� �������� "�� ���������"
	SYSCODE = "TEHXXXXPO"			'��� ������� ������
	WorkRefName = "���"
  
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
	
	'PhoneNumber = +7950XXXX505
	PhoneNumber = "+7912XXXX443"
	'PhoneNumber = "+7-912-XXX-7X43"
	
	
	res = getUserLoginByPhone(PhoneNumber)
	msgbox res

'Set objArgs = Wscript.Arguments
'filename = objArgs(0)
'command = objArgs(1)

'dim fso, MyFile
'Set fso = CreateObject("Scripting.FileSystemObject")
'Set MyFile = fso.OpenTextFile(filename, 2, True)

'if command = 1 then
'	msgbox(1)
'	MyFile.WriteLine "1"
'else
	'msgbox(2)
	'MyFile.WriteLine "2"
'end if

'MyFile.Close


