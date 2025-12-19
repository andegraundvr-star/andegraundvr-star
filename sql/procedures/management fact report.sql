USE [СлужебнаяДляОтчетов]
GO
/****** Object:  StoredProcedure [dbo].[ЗначениеБонусаДляПодразделений]    Script Date: 18.12.2025 9:20:47 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================

ALTER PROCEDURE [dbo].[ЗначениеБонусаДляПодразделений]
as
BEGIN


if object_id (N'tempdb..#ЗначениеБонусаДляПодразделений') is not null drop table #ЗначениеБонусаДляПодразделений;

select 

datefromparts(year(ФактТабель._Date_time)-2000, month(ФактТабель._Date_time), 1) as Дата
,ОВнер._description as Служба
,Родитель._description as Отдел
,подразделениеОрганизаций._description as Участок
,СправочникДолжности._description as Должность
,СотрудникиДляПодразд._description as Сотрудник

,case 
	when KPI._description is not null 
	then KPI._description 
	else ПоказателиРасчетаЗарплаты._description 
end	as Показатель
,  ISNULL((
        SELECT TOP 1 _fld50227 
        FROM serv5.hrm_dev.dbo._InfoRg50219 
        WHERE _fld50221_rrref = ДляПодразделений._fld49592_rrref
            AND _fld50227 > 0  -- Только вес > 0
        ORDER BY _fld50227 DESC  -- Берем максимальный вес
    ), 0) AS Вес,
    
    -- ПЛАНОВОЕ ЗНАЧЕНИЕ: берем ПЕРВОЕ не нулевое значение
    ISNULL((
        SELECT TOP 1 _fld50228 
        FROM serv5.hrm_dev.dbo._InfoRg50219 
        WHERE _fld50221_rrref = ДляПодразделений._fld49592_rrref
            AND _fld50227 > 0  -- Только если вес > 0
        ORDER BY _fld50227 DESC  -- Сортировка по весу
    ), 0) AS ПлановоеЗначение
,ДляПодразделений._fld49593 as ФактическоеЗначение


into #ЗначениеБонусаДляПодразделений
from serv5.hrm_dev.dbo._Document49318_VT49502 as ДляПодразделений

inner join serv5.hrm_dev.dbo._Document49318 as ФактТабель
	on ДляПодразделений._document49318_idrref = ФактТабель._IDRref
inner join serv5.hrm_dev.dbo._Reference525 as СотрудникиДляПодразд
	on СотрудникиДляПодразд._idrref = ДляПодразделений._fld49591rref
left join serv5.hrm_dev.dbo._Reference49534 as KPI
	on KPI._idrref = ДляПодразделений._fld49592_rrref
left join serv5.hrm_dev.dbo._Reference397 as ПоказателиДляПодразделений
	on ПоказателиДляПодразделений._idrref = ДляПодразделений._fld49592_rrref
	and KPI._idrref is null
left join serv5.hrm_dev.dbo._Document49318_VT49332 as данныеОвремени
	on данныеОвремени._document49318_idrref = ФактТабель._IDRref
	and данныеОвремени._fld49334rref = СотрудникиДляПодразд._idrref
left join serv5.hrm_dev.dbo._Reference148 as СправочникДолжности
	on СправочникДолжности._idrref = данныеОвремени._fld49520rref
left join serv5.hrm_dev.dbo._Reference397 as ПоказателиРасчетаЗарплаты
	on ПоказателиРасчетаЗарплаты._idrref = ДляПодразделений._fld49592_rrref
left join serv5.hrm_dev.dbo._Reference390 as подразделениеОрганизаций
	on подразделениеОрганизаций._idrref = ФактТабель._fld49321rref

left join serv5.hrm_dev.dbo._Reference390 as Родитель
	on Родитель._idrref = подразделениеОрганизаций._Parentidrref
left join serv5.hrm_dev.dbo._Reference390 as Овнер
	on Овнер._idrref = Родитель._Parentidrref
--left join serv5.hrm_dev.dbo._Reference302 as Организации
--	on Организации._idrref = ФактТабель._fld49320rref
left join serv5.hrm_dev.dbo._Document49318_VT49498 as Переработки
	on Переработки._document49318_idrref = ФактТабель._IDRref
	and Переработки._fld49578rref = ДляПодразделений._fld49591rref
--left join serv5.hrm_dev.dbo._Document49318_VT49500 as перемЧасть
--	on перемЧасть._document49318_idrref = ФактТабель._IDRref
--	and перемЧасть._fld49587rref = ДляПодразделений._fld49591rref



WHERE YEAR(ФактТабель._Date_time)-2000 = YEAR(GETDATE())
--and СотрудникиДляПодразд._description like 'Савицкая Виктория Викторовна'


order by дата desc


--select * from #ЗначениеБонусаДляПодразделений
--where (сотрудникдляподразделений like '%бондарева%' and дата = '2025-11-01')
 --or (сотрудникдляподразделений like '%букреева%'  and дата = '2025-10-01') 
 --order by дата
--where	KPIперемЧ._description = 0x85D200155D007AB511E4CD45F188DC5D
--where ПокПеремчасти._fld49589_rrref is not null


--select * from serv5.hrm_dev.dbo._Document49318 ---ФактТабель
--select * from serv5.hrm_dev.dbo._Document49318_VT49332 --данныеОвремени
--select * from serv5.hrm_dev.dbo._Document49318_VT49500 -- ПокПеремчасти
--select * from serv5.hrm_dev.dbo._Document49318_VT49502 -- ДляПодразделений
--select * from serv5.hrm_dev.dbo._Document49318_VT49498 -- Переработки
--where _fld49578rref = 0x80EC00155D037F0711EEFCA423DC9D73
--select * from serv5.hrm_dev.dbo._Reference302 -- организации
--select * from serv5.hrm_dev.dbo._Reference390 -- ПодразделенияОрганизации
--select * from serv5.hrm_dev.dbo._Reference525 -- сотрудники
--select * from serv5.hrm_dev.dbo._Reference148 ---справочник должности
--select * from serv5.hrm_dev.dbo._Reference56513 ---сотрудники доп персонал
--select * from serv5.hrm_dev.dbo._Reference397 ---Справочник.ПоказателиРасчетаЗарплаты
--select * from serv5.hrm_dev.dbo._Reference49534 ---KPI
--select * from serv5.hrm_dev.dbo._InfoRg50219 -- РегистрСведений.ВРА_ПоказателиПеременнойЧасти


-- шаг 2 добавление средневзвешенного бонуса

IF OBJECT_ID(N'tempdb..#ДобавлениеСредневзвешенногоБонуса') IS NOT NULL 
    DROP TABLE #ДобавлениеСредневзвешенногоБонуса;

SELECT 
    Дата,
    Служба,
    Отдел,
    Участок,
    Должность,
    Сотрудник,
    Показатель,
    Вес,    
    ПлановоеЗначение,
    ФактическоеЗначение,
    SUM(Вес) OVER (PARTITION BY Сотрудник, Дата) as Общий_вес,
    CASE 
        WHEN SUM(Вес) OVER (PARTITION BY Сотрудник, Дата) = 0 THEN 0
        ELSE SUM(
            CASE 
                WHEN ISNULL(ПлановоеЗначение, 0) = 0 THEN 0
                ELSE Вес * (ФактическоеЗначение / ПлановоеЗначение * 100)
            END
        ) OVER (PARTITION BY Сотрудник, Дата) 
        / SUM(Вес) OVER (PARTITION BY Сотрудник, Дата)
    END as Средневзвешенный_процент_выполнения
INTO #ДобавлениеСредневзвешенногоБонуса 
FROM #ЗначениеБонусаДляПодразделений;

--SELECT COUNT(*) as ИтогоСтрок FROM #ДобавлениеСредневзвешенногоБонуса;



--select * from #ДобавлениеСредневзвешенногоБонуса


-- шаг 3 добавление УпрФакта

if object_id (N'tempdb..#Средневзвешанный_бонус') is not null drop table #Средневзвешанный_бонус;
select 
datefromparts(year(упрФакт._Date_time)-2000, month(упрФакт._Date_time), 1) as дата
,ОВнер._description as Служба
,Родитель._description as Отдел
,подразделениеОрганизаций._description as Участок
,СправочникДолжности._Description as Должность
,СправочникФизлица._Description as Сотрудник
,COALESCE(KPIссылкаНаименование._Description, ЗадачиНаМесяц._fld50134_S) AS Показатель
 ,ЗадачиНаМесяц._fld50136 as вес
,ЗадачиНаМесяц._fld50143 as плановоеЗначение
,ЗадачиНаМесяц._fld50144 as фактическоеЗначение
 --,KPI._Description as показатель1

 --,ЗадачиНаМесяц._fld50134_S as наименованиеСтрока
 --,KPIссылкаНаименование._Description as наименованиеСсылка
 ,ЗадачиНаМесяц._fld50140 as процентВыполнения

 ,SUM(ЗадачиНаМесяц._fld50136) OVER (PARTITION BY СправочникФизлица._Description, datefromparts(year(упрФакт._Date_time)-2000, month(упрФакт._Date_time), 1)) as Общий_вес
 ,SUM(ЗадачиНаМесяц._fld50136 * ЗадачиНаМесяц._fld50140) OVER (PARTITION BY СправочникФизлица._Description, datefromparts(year(упрФакт._Date_time)-2000, month(упрФакт._Date_time), 1)) / 
 SUM(ЗадачиНаМесяц._fld50136) OVER (PARTITION BY СправочникФизлица._Description, datefromparts(year(упрФакт._Date_time)-2000, month(упрФакт._Date_time), 1)) as Средневзвешенный_процент_выполнения



 into #Средневзвешанный_бонус
from serv5.hrm_dev.dbo._Document50064 as упрФакт
left join serv5.hrm_dev.dbo._Document50064_VT50148 as ВходБонус
	on ВходБонус._document50064_idrref = упрФакт._idrref
left join serv5.hrm_dev.dbo._Document50064_VT50132 as ЗадачиНаМесяц
	on ЗадачиНаМесяц._document50064_idrref = упрФакт._idrref
left join serv5.hrm_dev.dbo._Reference626 as СправочникФизлица
	on СправочникФизлица._idrref = упрФакт._fld50110Rref
left join serv5.hrm_dev.dbo._Reference148 as СправочникДолжности
	on СправочникДолжности._idrref = упрФакт._fld50120rref
left join serv5.hrm_dev.dbo._Reference49535 as КлассификаторЕдиницИзмерения
	on КлассификаторЕдиницИзмерения._idrref = ЗадачиНаМесяц._fld50146rref
left join serv5.hrm_dev.dbo._Reference49534 as KPI
	on KPI._idrref = ВходБонус._fld50150rref
left join serv5.hrm_dev.dbo._Reference49534 as KPIссылкаНаименование
	on KPIссылкаНаименование._idrref = ЗадачиНаМесяц._fld50134_RRRef
left join serv5.hrm_dev.dbo._Reference390 as подразделениеОрганизаций
	on подразделениеОрганизаций._idrref = упрФакт._fld50121rref
left join serv5.hrm_dev.dbo._Reference390 as Родитель
	on Родитель._idrref = подразделениеОрганизаций._Parentidrref
left join serv5.hrm_dev.dbo._Reference390 as Овнер
	on Овнер._idrref = Родитель._Parentidrref


WHERE YEAR(упрФакт._Date_time)-2000 = YEAR(GETDATE())

order by дата desc

---select * from #Средневзвешанный_бонус


--where СправочникСотрудники._Description is not null


---select * from serv5.hrm_dev.dbo._Document50064_VT50148
--select * from serv5.hrm_dev.dbo._Document50064
--select * from serv5.hrm_dev.dbo._Document50064_VT50132 --- ЗадачиНаМесяц
--select * from serv5.hrm_dev.dbo._Reference626 ---справочник физлица
--select * from serv5.hrm_dev.dbo._Reference148 ---справочник должности
--select * from serv5.hrm_dev.dbo._Reference49535 ---классификатор единиц измерения
--select * from serv5.hrm_dev.dbo._Reference49534 ---KPI
--select * from serv5.hrm_dev.dbo._Reference49534 ---СправочникСсылка.ВРА_KPI


-----шаг итоговый создание таблицы в базе данных




--- шаг 4 третий сцепка фактТабеля и упрФакта


if object_id (N'tempdb..#Сцепка') is not null drop table #Сцепка;

select
Дата
,FORMAT(Дата, 'MMMM yyyy', 'ru-ru') AS Период
,Служба
,Отдел
,Участок
,Должность
,Сотрудник
,LEFT(Показатель, 255) asПоказатель
,Вес    
,ПлановоеЗначение
,ФактическоеЗначение
,Общий_вес
,Средневзвешенный_процент_выполнения


into #Сцепка
from #ДобавлениеСредневзвешенногоБонуса

union all

select
Дата
,FORMAT(Дата, 'MMMM yyyy', 'ru-ru') AS Период
,Служба
,Отдел
,Участок
,Должность
,Сотрудник
,LEFT(Показатель, 255) as Показатель
,Вес    
,ПлановоеЗначение
,ФактическоеЗначение
,Общий_вес
,Средневзвешенный_процент_выполнения
from #Средневзвешанный_бонус
order by дата desc

---select * from #Сцепка
--where (сотрудник like '%бондарева%' and дата = '2025-11-01')
 --or (сотрудник like '%букреева%'  and дата = '2025-10-01') 
--order by дата



-----шаг 5 создание итоговый создание таблицы в базе данных



delete  from [СлужебнаяДляОтчетов].[dbo].[БонусДляПодразделений];
insert into [СлужебнаяДляОтчетов].[dbo].[БонусДляПодразделений]
select * from #Сцепка





--drop table [СлужебнаяДляОтчетов].[dbo].[БонусДляПодразделений]
--Временно закомментируйте DELETE и INSERT и раскомментируйте эту строку:
--SELECT * 
--INTO [СлужебнаяДляОтчетов].[dbo].[БонусДляПодразделений]
--FROM #ЗначениеБонусаДляПодразделений


--CREATE TABLE [СлужебнаяДляОтчетов].[dbo].[БонусДляПодразделений] (
--Дата DATE
--,Период NVARCHAR(100)
--,Служба NVARCHAR(255)
--,Отдел NVARCHAR(255)
--,Участок NVARCHAR(255)
--,Должность NVARCHAR(255)
--,Сотрудник NVARCHAR(255)
--,Показатель NVARCHAR(255)
--,Вес DECIMAL(18,5)   
--,ПлановоеЗначение DECIMAL(18,5)
--,ФактическоеЗначение DECIMAL(18,5)
--,Общий_вес DECIMAL(18,5)
--,Средневзвешенный_процент_выполнения DECIMAL(18,5)
--);

end



