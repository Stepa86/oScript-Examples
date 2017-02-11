#Использовать cmdline
#Использовать logos
#Использовать json
#Использовать v8runner

#Использовать "."

Перем фЛог;
Перем фЗамер;

// Получить имя лога продукта
//
// Возвращаемое значение:
//  Строка   - имя лога продукта
//
Функция ИмяЛога() Экспорт
	Возврат "oscript.app.CopyBase";
КонецФункции

Функция ПолучитьПараметры( Знач пАргументы )
	
	Парсер = Новый ПарсерАргументовКоманднойСтроки();
	
	Парсер.ДобавитьПараметр("ПутьКФайлу");
	Парсер.ДобавитьПараметрФлаг("-debug");
	
	Параметры = Парсер.Разобрать(пАргументы);
	
	Если Не Параметры.Количество() > 0 Тогда
		
		Сообщить("Должен быть передан 1 параметр - файл настроек.");
		Сообщить("Например,");
		Сообщить("oscript CopyBase.os g:\git\oScript-Examples\Configs\db111.base_config");
		
		ЗавершитьРаботу(1);
		
	КонецЕсли;
	
	Если Параметры["-debug"] Тогда
		
		фЛог.УстановитьУровень(УровниЛога.Отладка);
		
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

Функция Инициализация( Знач пАргументы )

	фЗамер = Новый Замер();
	
	фЗамер.НачатьЗамер();
	
	фЗамер.НачатьЗамер( "РазборПараметров" );
	
	параметры = ПолучитьПараметры( пАргументы );
	
	фЗамер.СообщитьЗамер( "Параметры получены" );

	Возврат параметры;
	
КонецФункции

Процедура ВыполнитьБекап( Знач пПараметры )
	
	Если Не пПараметры["Source_SQL.UseBackup"] = Истина Тогда
		Возврат;
	КонецЕсли;
	
	фЗамер.НачатьЗамер( "Бекап" );
	
	выполнениеБекапа = Новый РаботаСSQL();
	
	Если фЛог.Уровень() = УровниЛога.Отладка Тогда
		
		логSQL = Логирование.ПолучитьЛог(выполнениеБекапа.ИмяЛога());
		логSQL.УстановитьУровень( УровниЛога.Отладка );
		
	КонецЕсли;
	
	выполнениеБекапа.УстановитьСервер(       пПараметры["Source_SQL.Server"] );
	выполнениеБекапа.УстановитьПользователя( пПараметры["Source_SQL.User"] );
	выполнениеБекапа.УстановитьПароль(       пПараметры["Source_SQL.Password"] );
	выполнениеБекапа.УстановитьИмяБазы(      пПараметры["Source_SQL.Base"] );
	
	результат = выполнениеБекапа.ВыполнитьБекап( пПараметры["FileBackup"] );
	
	Если Не результат Тогда
		ЗавершитьРаботу(1);
	КонецЕсли;
	
	фЗамер.СообщитьЗамер( "Выполнен бекап");

КонецПроцедуры

Процедура ВыполнитьВосстановление( Знач пПараметры )
	
	Если Не пПараметры["Current_SQL.UseRestore"] = Истина Тогда
		Возврат;
	КонецЕсли;
	
	фЗамер.НачатьЗамер( "Восстановление" );
	
	выполнениеВосстановления = Новый РаботаСSQL();
	
	Если фЛог.Уровень() = УровниЛога.Отладка Тогда
		
		логSQL = Логирование.ПолучитьЛог(выполнениеВосстановления.ИмяЛога());
		логSQL.УстановитьУровень( УровниЛога.Отладка );
		
	КонецЕсли;

	выполнениеВосстановления.УстановитьСервер(       пПараметры["Current_SQL.Server"] );
	выполнениеВосстановления.УстановитьПользователя( пПараметры["Current_SQL.User"] );
	выполнениеВосстановления.УстановитьПароль(       пПараметры["Current_SQL.Password"] );
	выполнениеВосстановления.УстановитьИмяБазы(      пПараметры["Current_SQL.Base"] );
	
	результат = выполнениеВосстановления.ВыполнитьСкрипт( пПараметры["Script_Restore"] );
	
	Если Не результат Тогда
		ЗавершитьРаботу(1);
	КонецЕсли;
	
	фЗамер.СообщитьЗамер( "Выполнено восстановление");
	
КонецПроцедуры

Процедура УдалитьФайлБекапа( Знач пПараметры )
	
	Если Не пПараметры["Current_SQL.DelBackup"] = Истина Тогда
		Возврат;
	КонецЕсли;
	
	фЗамер.НачатьЗамер( "УдалениеБекапа" );
	
	Если ФайлСуществует( пПараметры["FileBackup"] ) Тогда
		
		УдалитьФайлы( пПараметры["FileBackup"] );
		
	КонецЕсли;
	
	фЗамер.СообщитьЗамер( "Удален бекап" );
	
КонецПроцедуры

Процедура ПереподключитьХранилище( Знач пПараметры)
	
	Если Не пПараметры["Current_Repo.Blind"] = Истина Тогда
		Возврат;
	КонецЕсли;
	
	фЗамер.НачатьЗамер( "ОтключениеОтХранилища" );
	
	Конфигуратор = Новый УправлениеКонфигуратором;
	
	Если фЛог.Уровень() = УровниЛога.Отладка Тогда
		
		логSQL = Логирование.ПолучитьЛог(Конфигуратор.ИмяЛога());
		логSQL.УстановитьУровень( УровниЛога.Отладка );
		
	КонецЕсли;

	Конфигуратор.УстановитьКонтекст(пПараметры["Current_Base.Connect"], пПараметры["Current_Base.User"], пПараметры["Current_Base.Password"]);
	Конфигуратор.ПутьКПлатформе1С( пПараметры["EXE1CV8"] );
	
	Если ЗначениеЗаполнено( пПараметры["Current_Base.EPF"] )
		И ФайлСуществует( пПараметры["Current_Base.EPF"] ) Тогда
		
		фЗамер.НачатьЗамер( "ВыполнениеОбработки" );
		
		ДополнительныеКлючи = "/Execute" + ОбщегоНазначения.ОбернутьВКавычки( пПараметры["Current_Base.EPF"] );
		
		Конфигуратор.ЗапуститьВРежимеПредприятия("", Неопределено, ДополнительныеКлючи);
		Текст = Конфигуратор.ВыводКоманды();
		Если Не ПустаяСтрока(Текст) Тогда
			фЛог.Информация(Текст);
		КонецЕсли;
		
		замер.СообщитьЗамер( "Выполнена обработка" );
		
	КонецЕсли;
	
	фЗамер.НачатьЗамер( "ОтключениеОтХранилища" );
	
	Конфигуратор.ОтключитьсяОтХранилища();
	Текст = Конфигуратор.ВыводКоманды();
	Если Не ПустаяСтрока(Текст) Тогда
		фЛог.Информация(Текст);
	КонецЕсли;
	
	фЗамер.СообщитьЗамер( "Отключено от хранилища" );
	
	фЗамер.НачатьЗамер( "ПодключениеКХранилищу" );
	
	Конфигуратор.ПодключитьсяКХранилищу(пПараметры["Current_Repo.Connect"], пПараметры["Current_Repo.User"], пПараметры["Current_Repo.Password"], Истина );
	Текст = Конфигуратор.ВыводКоманды();
	Если Не ПустаяСтрока(Текст) Тогда
		фЛог.Информация(Текст);
	КонецЕсли;
	
	замер.СообщитьЗамер( "Подключено к хранилищу" );
	
	Если пПараметры["Current_Repo.UpdateCfg"] Тогда
		
		замер.НачатьЗамер( "ОбновлениеКонфигурации" );
		
		Конфигуратор.ОбновитьКонфигурациюБазыДанныхИзХранилища(пПараметры["Current_Repo.Connect"], пПараметры["Current_Repo.User"], пПараметры["Current_Repo.Password"] );
		Текст = Конфигуратор.ВыводКоманды();
		Если Не ПустаяСтрока(Текст) Тогда
			фЛог.Информация(Текст);
		КонецЕсли;
		
		замер.СообщитьЗамер( "Конфигурация обновлена" );
		
	КонецЕсли;
	
	файлИнформаци = Конфигуратор.ФайлИнформации();
	
	Если ФайлСуществует( файлИнформаци ) Тогда
		УдалитьФайлы( файлИнформаци );
	КонецЕсли;
	
КонецПроцедуры

Процедура ВыполнитьКоманду(Знач пАргументы)
	
	параметры = Инициализация( пАргументы );
	
	ВыполнитьБекап( параметры );
	
	ВыполнитьВосстановление( параметры );
	
	УдалитьФайлБекапа( параметры );
	
	ПереподключитьХранилище( параметры );
	
	фЗамер.СообщитьЗавершение();
	
КонецПроцедуры

фЛог = Логирование.ПолучитьЛог(ИмяЛога());

ВыполнитьКоманду(АргументыКоманднойСтроки);