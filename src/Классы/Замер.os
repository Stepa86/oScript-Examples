#Использовать logos

Перем _Замеры;
Перем _ОбщееВремяНачала;
Перем _ПоследнийЗамер;

Перем _Отступ;

Процедура НачатьЗамер( Знач пСообщение = "", Знач пКлючЗамера = "" ) Экспорт
	Если Не ТипЗнч( _Замеры ) = Тип("Структура") Тогда
		_Замеры = Новый Структура;
		_ОбщееВремяНачала = ТекущаяДата();
	КонецЕсли;
	Если Не пСообщение = "" Тогда
		Сообщить( СтрШаблон("%1. %2", Отсечка(), пСообщение), СтатусСообщения.Внимание );
	КонецЕсли;
	Если Не пКлючЗамера = "" Тогда
		_Замеры.Вставить( пКлючЗамера, ТекущаяУниверсальнаяДатаВМиллисекундах() );
		_ПоследнийЗамер = пКлючЗамера;
	КонецЕсли;
КонецПроцедуры

Процедура СообщитьЗамер(Знач пСообщение, Знач пКлючЗамера = "", Знач пВывестиОбщееВремяПрефиксом = Истина ) Экспорт
	
	Если пКлючЗамера = ""
		И Не _ПоследнийЗамер = "" Тогда
		затрачено = Окр( ТекущаяУниверсальнаяДатаВМиллисекундах() - _Замеры[_ПоследнийЗамер] );
	ИначеЕсли Не пКлючЗамера = "" Тогда
		затрачено = Окр( ТекущаяУниверсальнаяДатаВМиллисекундах() - _Замеры[пКлючЗамера] );
	Иначе
		затрачено = 0;
	КонецЕсли;
	
	Если пВывестиОбщееВремяПрефиксом Тогда
		
		Сообщить( СтрШаблон("%1. %2 - %3мс", Отсечка(), пСообщение, затрачено), СтатусСообщения.Информация  );
		
	Иначе
		
		Сообщить( СтрШаблон("%1 - %2мс", пСообщение, затрачено), СтатусСообщения.Информация  );
		
	КонецЕсли
	
КонецПроцедуры

Функция Отсечка()

	секундПрошло = ТекущаяДата() - _ОбщееВремяНачала;

	Если секундПрошло < 30*60 Тогда
		Возврат Формат(Дата(1,1,1) + секундПрошло, "ДФ=mm:ss" );
	Иначе
		Возврат Формат(Дата(1,1,1) + секундПрошло, "ДФ=HH:mm:ss" );
	КонецЕсли;

КонецФункции

Процедура СообщитьЗавершение() Экспорт

	затраченоВсего = Формат(Дата(1,1,1) + (ТекущаяДата() - _ОбщееВремяНачала), "ДФ=HH:mm:ss" );
	
	Сообщить( СтрШаблон("%1. Завершено", Отсечка()), СтатусСообщения.Информация  );

КонецПроцедуры

Функция ПолучитьОбщееВремяНачала() Экспорт
	Возврат _ОбщееВремяНачала;
КонецФункции

Функция ПолучитьОтступ() Экспорт
	
	Если Не ЗначениеЗаполнено( _Отступ ) Тогда
		_Отступ = 0;
	КонецЕсли;
	
	Возврат _Отступ;

КонецФункции

Функция ПолучитьПотомка() Экспорт
	
	потомок = Новый Замер();
	потомок.Инициализировать( ПолучитьОбщееВремяНачала(), ПолучитьОтступ() );

	Возврат потомок;

КонецФункции

Процедура Инициализировать( Знач пОбщееВремяНачала, Знач пОтступ ) Экспорт
	
	_ОбщееВремяНачала = пОбщееВремяНачала;
	_Отступ = пОтступ + 1;

КонецПроцедуры

Функция Форматировать(Знач Уровень, Знач Сообщение) Экспорт
	
	наименованиеУровня = УровниЛога.НаименованиеУровня (Уровень );

	Если Уровень = 0 Тогда // ОТЛАДКА
		наименованиеУровня = ">";
	ИначеЕсли Уровень = 1 Тогда // ИНФОРМАЦИЯ
		наименованиеУровня = "!";
	КонецЕсли;

	шаблонСтроки = "%1. ";

	Для ц = 0 По ПолучитьОтступ() Цикл
		шаблонСтроки = шаблонСтроки + "	";
	КонецЦикла;

	шаблонСтроки = шаблонСтроки + "%2 %3";

	Возврат СтрШаблон(шаблонСтроки, Отсечка(), наименованиеУровня , Сообщение);
	
КонецФункции