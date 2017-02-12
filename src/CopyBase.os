#Использовать cmdline
#Использовать logos
#Использовать json
#Использовать v8runner

#Использовать "."

Перем _Лог;
Перем _Замер;

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
		
		_Лог.УстановитьУровень(УровниЛога.Отладка);
		
	КонецЕсли;
	
	текстНастроек = ОбщегоНазначения.ПолучитьТекстИзФайла(Параметры["ПутьКФайлу"]);
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
		
		_Лог.Отладка( "Прочитан параметр " + цЭлемент.Ключ + ": " + цЭлемент.Значение );
		
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

	_Замер = Новый Замер();
	
	_Лог.УстановитьРаскладку(_Замер);

	_Замер.НачатьЗамер();
	
	_Замер.НачатьЗамер( "Начат разбор параметров", "РазборПараметров" );
	
	параметры = ПолучитьПараметры( пАргументы );
	
	_Замер.СообщитьЗамер( "Параметры получены" );

	Возврат параметры;
	
КонецФункции

Процедура ВыполнитьБекап( Знач пПараметры )
	
	Если Не пПараметры["Source_SQL.UseBackup"] = Истина Тогда
		Возврат;
	КонецЕсли;
	
	_Замер.НачатьЗамер( "Начат бекап", "Бекап" );
	
	выполнениеБекапа = Новый РаботаСSQL();
	
	выполнениеБекапа.ИнициализироватьЛог( _Лог.Уровень(), _Замер.ПолучитьПотомка() );

	выполнениеБекапа.УстановитьСервер(       пПараметры["Source_SQL.Server"] );
	выполнениеБекапа.УстановитьПользователя( пПараметры["Source_SQL.User"] );
	выполнениеБекапа.УстановитьПароль(       пПараметры["Source_SQL.Password"] );
	выполнениеБекапа.УстановитьИмяБазы(      пПараметры["Source_SQL.Base"] );
	
	результат = выполнениеБекапа.ВыполнитьБекап( пПараметры["FileBackup"] );
	
	Если Не результат Тогда
		ЗавершитьРаботу(1);
	КонецЕсли;
	
	_Замер.СообщитьЗамер( "Выполнен бекап");

КонецПроцедуры

Процедура ПроверитьСоединения( Знач пПараметры )
	
	Если Не пПараметры["Current_SQL.UseRestore"] = Истина Тогда
		Возврат;
	КонецЕсли;
	
	_Замер.НачатьЗамер( "Начало проверки количества соединений", "ПроверкаСоединения" );
	
	проверкаСоединения = Новый РаботаСSQL();
	
	проверкаСоединения.ИнициализироватьЛог( _Лог.Уровень(), _Замер.ПолучитьПотомка() );

	проверкаСоединения.УстановитьСервер(       пПараметры["Current_SQL.Server"] );
	проверкаСоединения.УстановитьПользователя( пПараметры["Current_SQL.User"] );
	проверкаСоединения.УстановитьПароль(       пПараметры["Current_SQL.Password"] );
	проверкаСоединения.УстановитьИмяБазы(      пПараметры["Current_SQL.Base"] );
	
	количествоСоединений = проверкаСоединения.ПолучитьКоличествоСоединений();
	
	_Лог.Отладка( "Количество соединений: " + количествоСоединений );

	Если количествоСоединений < 0 Тогда
		ЗавершитьРаботу(1);
	КонецЕсли;

	_Замер.СообщитьЗамер( "Проверены активные соединения. Соединений: " + количествоСоединений);
	
	Если количествоСоединений > 0 Тогда 
		
		_Лог.Ошибка( "Есть активные соединения. Выполнение скрипта прервано." );
		ЗавершитьРаботу(1);
		
	КонецЕсли;

КонецПроцедуры

Процедура ВыполнитьВосстановление( Знач пПараметры )
	
	Если Не пПараметры["Current_SQL.UseRestore"] = Истина Тогда
		Возврат;
	КонецЕсли;
	
	_Замер.НачатьЗамер( "Начало восстановления", "Восстановление" );
	
	выполнениеВосстановления = Новый РаботаСSQL();
	
	выполнениеВосстановления.ИнициализироватьЛог( _Лог.Уровень(), _Замер.ПолучитьПотомка() );

	выполнениеВосстановления.УстановитьСервер(       пПараметры["Current_SQL.Server"] );
	выполнениеВосстановления.УстановитьПользователя( пПараметры["Current_SQL.User"] );
	выполнениеВосстановления.УстановитьПароль(       пПараметры["Current_SQL.Password"] );
	выполнениеВосстановления.УстановитьИмяБазы(      пПараметры["Current_SQL.Base"] );
	
	результат = выполнениеВосстановления.ВыполнитьСкрипт( пПараметры["Script_Restore"] );
	
	Если Не результат Тогда
		ЗавершитьРаботу(1);
	КонецЕсли;
	
	_Замер.СообщитьЗамер( "Выполнено восстановление");
	
КонецПроцедуры

Процедура УдалитьФайлБекапа( Знач пПараметры )
	
	Если Не пПараметры["Current_SQL.DelBackup"] = Истина Тогда
		Возврат;
	КонецЕсли;
	
	_Замер.НачатьЗамер( "Удаление файла бекапа", "УдалениеБекапа" );
	
	Если ОбщегоНазначения.ФайлСуществует( пПараметры["FileBackup"] ) Тогда
		
		УдалитьФайлы( пПараметры["FileBackup"] );
		
	КонецЕсли;
	
	_Замер.СообщитьЗамер( "Удален бекап" );
	
КонецПроцедуры

Процедура ПереподключитьХранилище( Знач пПараметры)
	
	Если Не пПараметры["Current_Repo.Blind"] = Истина Тогда
		Возврат;
	КонецЕсли;
	
	_Замер.НачатьЗамер( "ОтключениеОтХранилища" );
	
	Конфигуратор = Новый УправлениеКонфигуратором;
	
	логРаннер = Логирование.ПолучитьЛог("oscript.lib.v8runner");
	логРаннер.УстановитьУровень( _Лог.Уровень() );
	замерПотомок = _Замер.ПолучитьПотомка();
	логРаннер.УстановитьРаскладку( замерПотомок );

	Конфигуратор.УстановитьКонтекст(пПараметры["Current_Base.Connect"], пПараметры["Current_Base.User"], пПараметры["Current_Base.Password"]);
	Конфигуратор.ПутьКПлатформе1С( пПараметры["EXE1CV8"] );
	
	Если ЗначениеЗаполнено( пПараметры["Current_Base.EPF"] )
		И ОбщегоНазначения.ФайлСуществует( пПараметры["Current_Base.EPF"] ) Тогда
		
		_Замер.НачатьЗамер( "Выполнение обработки перед переподключением", "ВыполнениеОбработки" );
		
		ДополнительныеКлючи = "/Execute" + ОбщегоНазначения.ОбернутьВКавычки( пПараметры["Current_Base.EPF"] );
		
		Конфигуратор.ЗапуститьВРежимеПредприятия("", Неопределено, ДополнительныеКлючи);
		Текст = Конфигуратор.ВыводКоманды();
		Если Не ПустаяСтрока(Текст) Тогда
			_Лог.Информация(Текст);
		КонецЕсли;
		
		_Замер.СообщитьЗамер( "Выполнена обработка" );
		
	КонецЕсли;
	
	_Замер.НачатьЗамер( "Начало отключения от хранилища", "ОтключениеОтХранилища" );
	
	Конфигуратор.ОтключитьсяОтХранилища();
	Текст = Конфигуратор.ВыводКоманды();
	Если Не ПустаяСтрока(Текст) Тогда
		_Лог.Информация(Текст);
	КонецЕсли;
	
	_Замер.СообщитьЗамер( "Отключено от хранилища" );
	
	_Замер.НачатьЗамер( "Подключение к хранилищу", "ПодключениеКХранилищу" );
	
	Конфигуратор.ПодключитьсяКХранилищу(пПараметры["Current_Repo.Connect"], пПараметры["Current_Repo.User"], пПараметры["Current_Repo.Password"], Истина );
	Текст = Конфигуратор.ВыводКоманды();
	Если Не ПустаяСтрока(Текст) Тогда
		_Лог.Информация(Текст);
	КонецЕсли;
	
	_Замер.СообщитьЗамер( "Подключено к хранилищу" );
	
	Если пПараметры["Current_Repo.UpdateCfg"] Тогда
		
		_Замер.НачатьЗамер( "Начало обновления конфигурации", "ОбновлениеКонфигурации" );
		
		Конфигуратор.ОбновитьКонфигурациюБазыДанныхИзХранилища(пПараметры["Current_Repo.Connect"], пПараметры["Current_Repo.User"], пПараметры["Current_Repo.Password"] );
		Текст = Конфигуратор.ВыводКоманды();
		Если Не ПустаяСтрока(Текст) Тогда
			_Лог.Информация(Текст);
		КонецЕсли;
		
		_Замер.СообщитьЗамер( "Конфигурация обновлена" );
		
	КонецЕсли;
	
	файлИнформаци = Конфигуратор.ФайлИнформации();
	
	Если ОбщегоНазначения.ФайлСуществует( файлИнформаци ) Тогда
		УдалитьФайлы( файлИнформаци );
	КонецЕсли;
	
КонецПроцедуры

Процедура ВыполнитьКоманду(Знач пАргументы)
	
	параметры = Инициализация( пАргументы );
	
	ВыполнитьБекап( параметры );
	
	ПроверитьСоединения( параметры );

	ВыполнитьВосстановление( параметры );
	
	УдалитьФайлБекапа( параметры );
	
	ПереподключитьХранилище( параметры );
	
	_Замер.СообщитьЗавершение();
	
КонецПроцедуры

_Лог = Логирование.ПолучитьЛог(ИмяЛога());

ВыполнитьКоманду(АргументыКоманднойСтроки);