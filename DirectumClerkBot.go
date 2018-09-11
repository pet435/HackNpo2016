package main

import (
	"gopkg.in/telegram-bot-api.v4"
	"log"
//	"github.com/BurntSushi/toml"
	"net/http"
	"bytes"
	"fmt"
	"io/ioutil"
	"encoding/json"
	"net/http/cookiejar"
	"strings"
	"os/exec"
)

type Config struct {
	DirectumUrl string
	Username string
	Password string
	ProviderName string
	Realm string
	RememberMe bool
}

type LoginResponseData struct {
	ResType		string `json:"ResType"`
	ContextID	string `json:"ContexID"`
	Result		int `json:"Result"`
	Success		bool `json:"Success"`
	Error		string `json:"Error"`
	Warning		string `json:"Warning"`
}

type LoginResponse struct {
	Data	LoginResponseData `json:"d"`
}

type Job struct {
	Id int64
	Subject string
	Content string
}

type Requisite struct {
	Name		string
	Value		string
	DisplayValue	string
}

type Employee struct {
	ID	int32 `json:"ID"`
	Requisites	[]Requisite `json:"Requisites"`
}

type EmployeesResponseData struct {
	Employees	[]Employee `json:"Result"`
}

type EmployeesResponse struct {
	Data	EmployeesResponseData `json:"d"`
}

var cookieJar, _ = cookiejar.New(nil)
var client = &http.Client{Jar: cookieJar}
var chatId int64
var bot *tgbotapi.BotAPI
var phone string

type Contact struct {
	Phone string
	Name string
	Email string
}

func main()  {
	bot, _ = tgbotapi.NewBotAPI("253781324:AAFT9STBzloBTGuUF67kmodJGwL988j3CH4")

	//config := readConfig()

//	loginResponse := LoginResponse{}
//	login(config, &loginResponse)

	bot.Debug = true

	log.Printf("Authorized on account %s", bot.Self.UserName)

	u := tgbotapi.NewUpdate(0)
	u.Timeout = 60

	updates, _ := bot.GetUpdatesChan(u)

	for update := range updates {
		if update.Message == nil {
			continue
		}

		chatId = update.Message.Chat.ID

		if update.Message.Contact != nil {
			phone = update.Message.Contact.PhoneNumber
		}
		log.Printf("[%s] %s", update.Message.From.UserName, phone)

		log.Printf("[%s] %s", update.Message.From.UserName, update.Message.Text)

		loweredMessageText := strings.ToLower(update.Message.Text)

		//min30 := "30 мин"
		min60 := "1 час"
		min120 := "2 часа"
		min240 := "4 часа"

		if strings.Contains(loweredMessageText , "start") {
			msg := tgbotapi.NewMessage(update.Message.Chat.ID, "Подскажешь свой номер телефона?")
			var row []tgbotapi.KeyboardButton
			row = append(row, tgbotapi.NewKeyboardButtonContact("Конечно!"))
			msg.ReplyMarkup = tgbotapi.NewReplyKeyboard(row)
			bot.Send(msg)

		} else if strings.Contains(loweredMessageText , "задержусь") || strings.Contains(loweredMessageText , "опаздываю") {
			msg := tgbotapi.NewMessage(update.Message.Chat.ID, "Сильно задержишься?")

			var row []tgbotapi.KeyboardButton
			//row = append(row, tgbotapi.KeyboardButton{min30, false, false})
			row = append(row, tgbotapi.KeyboardButton{min60, false, false})
			row = append(row, tgbotapi.KeyboardButton{min120, false, false})
			row = append(row, tgbotapi.KeyboardButton{min240, false, false})

			msg.ReplyMarkup = tgbotapi.NewReplyKeyboard(row)
			bot.Send(msg)
		} else if /*strings.Contains(loweredMessageText, min30) ||*/
			strings.Contains(loweredMessageText, min60) ||
			strings.Contains(loweredMessageText, min120) ||
			strings.Contains(loweredMessageText, min240) {

			msg := tgbotapi.NewMessage(update.Message.Chat.ID, "Предупрежу руководителя")
			if phone != "" {
				sendJob(phone, loweredMessageText, msg)
			} else {
				fmt.Println("Что-то пошло не так")
				msg.Text = "Не смог предупредить :("
				bot.Send(msg)
			}
		} else if strings.Contains(loweredMessageText, "контакт") {
			//parts := strings.Split(loweredMessageText, " ")
			//var employees EmployeesResponse
			//getContactInfo(config, &employees, parts[len(parts) - 1])

			//for _, employee := range employees.Data.Employees {
			//	fmt.Fprintln(employee.Requisites[0].DisplayValue)
			//}
			//
			//for _, employee := range employees.Data.Employees {
			//	bot.Send(tgbotapi.NewMessage(update.Message.Chat.ID, bytes.Buffer{employee.Requisites[3].DisplayValue}))
			//}
		}
	}
}

func sendJob(phone string, lateness string, msg tgbotapi.MessageConfig) {
	filename := "D:/Hack2016/test1.txt"
	//commandTemplate := "\"D:/Hack2016/DirClerkBot.vbs\" \"%s\" %s %s"
	commandTemplate := "D:/Hack2016/DirClerkBot.vbs %s %s %s"
	cmdexe := "cmd.exe"

	var phoneNumber string = "+" + phone

	hour := strings.Split(lateness, " ")[0]

	cmd := fmt.Sprintf(commandTemplate, filename, "sendTask", phoneNumber) + " " + hour
	fmt.Printf(cmd + "\n")
	err := exec.Command(cmdexe, "/c", cmd).Run()
	if err != nil {
		fmt.Println(err)
		msg.Text = "Не смог предупредить :("
		bot.Send(msg)
	} else {
		// отправить задачу
		bot.Send(msg)
	}

	//// Создать файл, выполнить cmd команду, сохранить результат из файла, удалить файл
	//f, err := os.Create(filename)
	//if err != nil {
	//	fmt.Println("1 не удалось создать файл")
	//	fmt.Println(err)
	//}
	//f.Close()
	//cmd := fmt.Sprintf(commandTemplate, filename, "getUserChiefLogin", phoneNumber)
	//fmt.Printf(cmd + "\n")
	//err = exec.Command(cmdexe, "/c", cmd).Run()
	//if err != nil {
	//	fmt.Println(err)
	//	msg.Text = "1 Не смог предупредить :("
	//	bot.Send(msg)
	//} else {
	//	bytes, err := ioutil.ReadFile(filename)
	//	if err != nil {
	//		fmt.Println(err)
	//		msg.Text = "2 Не смог предупредить :("
	//		bot.Send(msg)
	//	} else {
	//		os.Remove(filename)
	//		chief := string(bytes)
	//		fmt.Println("chief: " + chief)
	//
	//
	//		// Создать файл, выполнить cmd команду, сохранить результат из файла, удалить файл
	//		f, err := os.Create(filename)
	//		if err != nil {
	//			fmt.Println("2 не удалось создать файл")
	//			fmt.Println(err)
	//		}
	//		f.Close()
	//		cmd := fmt.Sprintf(commandTemplate, filename, "getUserFIObyPhone", phoneNumber)
	//		fmt.Printf(cmd + "\n")
	//		err = exec.Command(cmdexe, "/c", cmd).Run()
	//		if err != nil {
	//			fmt.Println(err)
	//			msg.Text = "3 Не смог предупредить :("
	//			bot.Send(msg)
	//		} else {
	//			bytes, err := ioutil.ReadFile(filename)
	//			if err != nil {
	//				fmt.Println(err)
	//				msg.Text = "4 Не смог предупредить :("
	//				bot.Send(msg)
	//			} else {
	//				os.Remove(filename)
	//				fio := string(bytes)
	//				fmt.Println("fio: " + fio)
	//
	//				// Формирование реквизитов задачи
	//				args := "" // "тема;получатель;тип;срок;текст"
	//				args += fmt.Sprintf("%s задерживается;", fio)
	//				args += chief + ";"
	//				args += "0;" // задание (0 - уведомление, 1 - задание)
	//				args += ";"
	//				args += fmt.Sprintf("%s задерживается на %s;", fio, lateness)
	//
	//
	//				// передаем параметры через файл
	//				f, err := os.Create(filename)
	//				if err != nil {
	//					fmt.Println("3 не удалось создать файл")
	//					fmt.Println(err)
	//				}
	//				writer := bufio.NewWriter(f)
	//				defer f.Close()
	//				fmt.Fprintln(writer, args)
	//				writer.Flush()
	//				//err := exec.Command("cscript", fmt.Sprintf(commandTemplate, filename, "sendTask", args)).Run()
	//				cmd := fmt.Sprintf(commandTemplate, filename, "sendTask")
	//				fmt.Printf(cmd + "\n")
	//				err = exec.Command(cmdexe, "/c", cmd).Run()
	//				if err != nil {
	//					fmt.Println(err)
	//					msg.Text = "5 Не смог предупредить :("
	//					bot.Send(msg)
	//				} else {
	//					// отправить задачу
	//					bot.Send(msg)
	//				}
	//				os.Remove(filename)
	//			}
	//		}
	//	}
	//}
}

func getContactInfo(config Config, contact *EmployeesResponse, query string) {
	referenceUrl := config.DirectumUrl + "/reference.asmx/GetRecords"
	filterExpression := fmt.Sprintf("{ " +
		"\"ReferenceCode\": \"РАБ\",  " +
		"\"FilterExpression\": \"[Наименование] like \"%v\"\", " +
		"\"FilterValue\": \"\", " +
		"\"Requisites\": [\"ИД\", \"Наименование\", \"Реквизит\", \"Дополнение5\"], " +
		"\"RecordsCount\": 100, " +
		"\"StartFromRecord\": 0, " +
		"\"SortIndex\": 3, " +
		"\"SortDirection\": \"desc\"}", query)

	resp, err := client.Post(referenceUrl, "application/json; charset=UTF-8",
		bytes.NewBufferString(filterExpression))

	if err != nil {
		log.Fatal(err)
		return
	}

	body, _ := ioutil.ReadAll(resp.Body)
	json.Unmarshal(body, &contact)
}

func getInbox(config Config, inboxResponse *[]Job) {
	getNewJobsUrl := config.DirectumUrl + "/Job.asmx/GetNewJobs"
	req, err := http.NewRequest("POST", getNewJobsUrl, bytes.NewBufferString(""))
	req.Header.Add("Content-Type", "application/json; charset=utf-8")

	resp, err := client.Do(req)
	if err != nil {
		fmt.Println(err)
	}
	defer resp.Body.Close()

	body, _ := ioutil.ReadAll(resp.Body)
	log.Printf(string(body))

	err = json.Unmarshal(body, &inboxResponse)

	if err != nil {
		fmt.Println(err)
		return
	}

	log.Printf("Total new jobs: %s", len(*inboxResponse))
}

func login(config Config, loginResponse *LoginResponse) {
	loginUrl := config.DirectumUrl + "/Authentication.asmx/Login"
	req, err := http.NewRequest("POST", loginUrl,
		bytes.NewBufferString(fmt.Sprintf("{ " +
			"\"UserName\": \"%v\", " +
			"\"Password\": \"%v\", " +
			"\"ProviderName\": \"%v\", " +
			"\"Realm\": \"%v\", " +
			"\"RememberMe\": %v }",
		config.Username, config.Password, config.ProviderName, config.Realm, config.RememberMe)))
	req.Header.Set("Content-Type", "application/json; charset=UTF-8")

	resp, err := client.Do(req)
	if err != nil {
		fmt.Println(err)
	}
	defer resp.Body.Close()

	body, _ := ioutil.ReadAll(resp.Body)
	log.Printf(string(body))

	err = json.Unmarshal(body, &loginResponse)

	if err != nil {
		log.Println(err)
		return
	}

	log.Println("Login success")
}

//func readConfig() Config {
//	//var configfile = "D:/External projects/DirectumClerkBot/src/config.debug.toml"
//	//_, err := os.Stat(configfile)
//	//if err != nil {
//	//	configfile = "D:/External projects/DirectumClerkBot/src/config.toml"
//	//	_, err = os.Stat(configfile)
//	//	if err != nil {
//	//		log.Fatal("Config file is missing: ", configfile)
//	//	}
//	//}
//
//	//var config Config
//	//if _, err := toml.DecodeFile(configfile, &config); err != nil {
//	//	log.Fatal(err)
//	//}
//	//
//	//log.Printf("Address: %s", config.DirectumUrl)
//	//log.Printf("User account: %s", config.Username)
//	//
//	//return config
//}