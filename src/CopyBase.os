#Использовать cmdline
#Использовать 1commands
#Использовать logos
#Использовать json
#Использовать v8runner

Перем фЛог;

// Получить имя лога продукта
//
// Возвращаемое значение:
//  Строка   - имя лога продукта
//
Функция ИмяЛога() Экспорт
	Возврат "oscript.app.CopyBase";
КонецФункции

Функция ПолучитьТекстИзФайла( Знач пИмяФайла )
	
	файлОбмена = Новый Файл(пИмяФайла);
	Данные = "";
	Если файлОбмена.Существует() Тогда
		чтениеТекста = Новый ЧтениеТекста(пИмяФайла, КодировкаТекста.UTF8);
		данные = чтениеТекста.Прочитать();
		чтениеТекста.Закрыть();
	Иначе
		Возврат Ложь;
	КонецЕсли;
	возврат данные;
КонецФункции

Функция ПолучитьПараметры( Знач пАргументы )
	
	Парсер = Новый ПарсерАргументовКоманднойСтроки();
	
	Парсер.ДобавитьПараметр("ПутьКФайлу");
	
	Параметры = Парсер.Разобрать(пАргументы);
	
	Если Не Параметры.Количество() = 1 Тогда
		
		Сообщить("Должен быть передан 1 параметр - файл настроек.");
		Сообщить("Например,");
		Сообщить("oscript CopyBase.os g:\git\oScript-Examples\Configs\db111.base_config");
		
		ЗавершитьРаботу(1);
		
	КонецЕсли;
	
	текстНастроек = ПолучитьТекстИзФайла(Параметры["ПутьКФайлу"]);
	Если текстНастроек = Ложь Тогда
		
		Сообщить("Переданный файл не найден или не является файлом настроек.");
		Сообщить("Для создания файла воспользуйтесь обработкой _ПодготовкаНастроекДляБазы.epf");
		
		ЗавершитьРаботу(1);
		
	КонецЕсли;
	
	ЧтениеJSON = Новый ПарсерJSON;
	параметрыИзФайла = ЧтениеJSON.ПрочитатьJSON(текстНастроек,,,Истина);
	
	прочитанныеПараметры = Новый Соответствие;
	
	ПрочитатьПараметрыРекурсивно( параметрыИзФайла, прочитанныеПараметры );
	
	Для каждого цЭлемент Из прочитанныеПараметры Цикл
		
		фЛог.Отладка( "Прочитан параметр " + цЭлемент.Ключ + ": " + цЭлемент.Значение );
		
	КонецЦикла;
	
	Возврат прочитанныеПараметры;
	
КонецФункции

Процедура ПрочитатьПараметрыРекурсивно( Знач пПараметры, пПрочитенныеПараметры )
	
	Для каждого цЭлемент Из пПараметры Цикл
		
		Если ТипЗнч( цЭлемент.Значение ) = Тип("Структура")
			ИЛИ ТипЗнч( цЭлемент.Значение ) = Тип("Соответствие") Тогда
			
			ПрочитатьПараметрыРекурсивно( цЭлемент.Значение, пПрочитенныеПараметры );
			
		Иначе
			
			пПрочитенныеПараметры.Вставить( цЭлемент.Ключ, цЭлемент.Значение );
			
		КонецЕсли;
		
	КонецЦикла;
	
КонецПроцедуры

Процедура ВыполнитьКоманду(Знач пАргументы)
	
	замер = ЗагрузитьСценарий(ОбъединитьПути(ТекущийСценарий().Каталог, "Замеры.os"));
	
	замер.НачатьЗамер();
	
	замер.НачатьЗамер( "РазборПараметров" );
	
	параметры = ПолучитьПараметры( пАргументы );
	
	замер.СообщитьЗамер( "Параметры получены" );
	
	замер.НачатьЗамер( "ПодключениеСценария" );
	
	работаСSQL = ЗагрузитьСценарий(ОбъединитьПути(ТекущийСценарий().Каталог, "ExecQuery_SQLCMD.os"));
	
	замер.СообщитьЗамер( "Подключен сценарий по работе с SQL");
	
	Если параметры["Source_SQL.UseBackup"] = Истина Тогда
		
		замер.НачатьЗамер( "Бекап" );
		
		результат = работаСSQL.ВыполнитьБекап( параметры["Source_SQL.Server"], параметры["Source_SQL.User"], параметры["Source_SQL.Password"], параметры["Source_SQL.Base"], параметры["FileBackup"] );
		
		Если Не результат Тогда
			ЗавершитьРаботу(1);
		КонецЕсли;
		
		замер.СообщитьЗамер( "Выполнен бекап");
		
	КонецЕсли;
	
	Если параметры["Current_SQL.UseRestore"] = Истина Тогда
		
		замер.НачатьЗамер( "Восстановление" );
		
		результат = работаСSQL.ВыполнитьСкрипт( параметры["Current_SQL.Server"], параметры["Current_SQL.User"], параметры["Current_SQL.Password"], параметры["Current_SQL.Base"], параметры["Script_Restore"] );
		
		Если Не результат Тогда
			ЗавершитьРаботу(1);
		КонецЕсли;
		
		замер.СообщитьЗамер( "Выполнено восстановление");
		
	КонецЕсли;
	
	Если параметры["Current_SQL.DelBackup"] = Истина Тогда
		
		замер.НачатьЗамер( "УдалениеБекапа" );
		
		файлБекапа = Новый Файл( параметры["FileBackup"] );
		
		Если файлБекапа.Существует() Тогда
			
			УдалитьФайлы( параметры["FileBackup"] );
			
		КонецЕсли;
		
		замер.СообщитьЗамер( "Удален бекап" );
		
	КонецЕсли;
	
	Если параметры["Current_Repo.Blind"] = Истина Тогда
		
		замер.НачатьЗамер( "ОтключениеОтХранилища" );

		Конфигуратор = Новый УправлениеКонфигуратором;
		Конфигуратор.УстановитьКонтекст(параметры["Current_Base.Connect"], параметры["Current_Base.User"], параметры["Current_Base.Password"]);
		Конфигуратор.ПутьКПлатформе1С( параметры["EXE1CV8"] );
		Конфигуратор.ОтключитьсяОтХранилища();

		замер.СообщитьЗамер( "Отключено от хранилища" );

		замер.НачатьЗамер( "ПодключениеКХранилищу" );

		Конфигуратор.ПодключитьсяКХранилищу(параметры["Current_Repo.Connect"], параметры["Current_Repo.User"], параметры["Current_Repo.Password"], Истина );

		замер.СообщитьЗамер( "Подключено к хранилищу" );

	КонецЕсли;
	
	замер.СообщитьЗавершение();

КонецПроцедуры

фЛог = Логирование.ПолучитьЛог(ИмяЛога());
//фЛог.УстановитьУровень(УровниЛога.Предупреждение);
фЛог.УстановитьУровень(УровниЛога.Отладка);

ВыполнитьКоманду(АргументыКоманднойСтроки);