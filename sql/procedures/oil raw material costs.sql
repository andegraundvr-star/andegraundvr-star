USE [upp_2012]
GO
/****** Object:  StoredProcedure [dbo].[План-факт расхода сырья _ГП_масло]    Script Date: 21.11.2025 13:33:07 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================

ALTER PROCEDURE [dbo].[План-факт расхода сырья _ГП_масло]
as
BEGIN



---- первый шаг по плану
if object_id (N'tempdb..#план_продаж_ГП_масло') is not null drop table #план_продаж_ГП_масло;
select 

	datefromparts(year(_Date_time)-2000, month(_Date_time), 1) as [Дата план]
	--,_fld12270rref as сценарий --- зачем это прикручивать?
	--,_number as номер
	--,PPVT._fld12279_rrref as [Наименование ГП]
	,KontrAgents._description as [контрагент]
	, GP._Fld2719 as артикул
	, GP._Description as [наименование ГП план]
	, vetis._code as [контролируется в Меркурии код]
	, vetis._Description as [контролируется в Меркурии]
	, svoistvaObyektov._Description as [значение свойств]
	, svoistvaObyektov1._Description as [группа аналитики]
	, GP._idrref as [ИД ГП по плану]
	,PPVT._fld12283 as [количество план]
	,_Fld12271 as [сумма документа план]
	,PPVT._Fld12284 as [цена план]
	--,PPVT._Fld12285 as [сумма мбПланпродаж]
	--,PPVT._Fld12287 as [сумма с НДС]
	,Mercury._Fld55328 as [расход по Меркурию]
	,sum(PPVT._Fld12283) over (partition by GP._Description) as сумм_кг_План_по_ГП
	,CASE
		when (GP._Description like '%72,5%') THEN (sum(PPVT._Fld12283) over (partition by GP._Description))/1000*Mercury._Fld55328		
	end as [Плановый расход 72]
	,CASE
		when (GP._Description like '%82,5%') THEN (sum(PPVT._Fld12283) over (partition by GP._Description))/1000*Mercury._Fld55328
	end as [Плановый расход 82]
into #план_продаж_ГП_масло
from [onec-9].upp_2012.dbo._Document493 as planProd
inner join [onec-9].upp_2012.dbo._Document493_VT12277 as PPVT
	on PPVT._Document493_Idrref=planProd._Idrref
inner join [onec-9].upp_2012.dbo._Reference124 as KontrAgents
	on KontrAgents._Idrref=PPVT._fld12290rref
inner join [onec-9].upp_2012.dbo._Reference154 as GP
	on  GP._IDRRef = PPVT._Fld12279_RRRef
inner join [onec-9].upp_2012.dbo._InfoRg55325 as Mercury --- не план выпуска ГП, а план сырья
	on  Mercury._Fld55326RRef = GP._IDRRef
left join [onec-9].upp_2012.dbo._Reference49113 as vetis
	on  vetis._idrref = GP._fld49888rref
left join [onec-9].upp_2012.dbo._inforg19780 as svoistvo
	on  svoistvo._fld19781_rrref = GP._idrref
left join [onec-9].upp_2012.dbo._Reference97 as svoistvaObyektov
	on  svoistvaObyektov._idrref = svoistvo._fld19783_rrref
left join [onec-9].upp_2012.dbo._chrc1140 as svoistvaObyektov1
	on  svoistvaObyektov1._idrref = svoistvo._fld19782rref

--where (GP._Description like '%82,5%' or GP._Description like '%72,5%')
where vetis._code <> 000000003
and svoistvaObyektov1._Description = 'группа аналитики'
and (svoistvaObyektov._Description like '%82,5%' or svoistvaObyektov._Description like '%72,5%')
and KontrAgents._description not like '%@%'
	--- добавляем условие вывода за прошлый месяц
and datefromparts(year(planProd._Date_time)-2000, month(planProd._Date_time), 1) = 
    CASE 
        WHEN MONTH(GETDATE()) = 1 
            THEN DATEFROMPARTS(YEAR(GETDATE())-1, 12, 1)
        ELSE DATEFROMPARTS(YEAR(GETDATE()), MONTH(GETDATE())-1, 1)
    END

--select distinct top 10000 * from #план_продаж_ГП_масло

--order by дата desc
--where наименование like '%82%'
--select  count(distinct[наименование ГП план]) from #план_продаж_ГП_масло
---select * from [onec-9].upp_2012.dbo._Reference154
---select * from [onec-9].upp_2012.dbo._Reference49113
---select * from [onec-9].upp_2012.dbo._inforg19780
---select * from [onec-9].upp_2012.dbo._chrc1140
---select * from [onec-9].upp_2012.dbo._chrc1137
---select * from [onec-9].upp_2012.dbo._Reference97
---select * from [onec-9].upp_2012.dbo._Document493_VT12277


------шаг 0.1 по продажам оставляем только артикул, наименование ГП, количество кг
if object_id (N'tempdb..#план_продаж_ГП_масло_1') is not null drop table #план_продаж_ГП_масло_1;
--select object_id ('tempdb..#..#mytemptable'); 
select [Дата план]
	,[контрагент]
	,артикул
	,[наименование ГП план]
	,[количество план]
	,[расход по Меркурию]
	,сумм_кг_План_по_ГП
	,[Плановый расход 72]
	,[Плановый расход 82]

into #план_продаж_ГП_масло_1
from #план_продаж_ГП_масло as vypuskProduktNakoplenie1
group by [Дата план]
	,[контрагент]
	,артикул
	,[наименование ГП план]
	,[количество план]
	,[расход по Меркурию]
	,сумм_кг_План_по_ГП
	,[Плановый расход 72]
	,[Плановый расход 82]

--select distinct top 10000 * from #план_продаж_ГП_масло_1


--- шаг 1 нач. выборка регист ракопления выпуск
if object_id (N'tempdb..#выпускПродукцииМасло_0') is not null drop table #выпускПродукцииМасло_0;
--select object_id ('tempdb..#..#mytemptable'); 
select datefromparts(year(_Period)-2000, month(_Period), 1) as Дата_0
	,nomenklatura._Description as [Продукция]
	,e._Description as [вид продукции]
	,b._Description as [Спецификация]
	, vetis._code as [контролируется в Меркурии код]
	, vetis._Description as [контролируется в Меркурии]
	, svoistvaObyektov._Description as [значение свойств]
	, svoistvaObyektov1._Description as [группа аналитики]
	,sum([_fld22700] * d._fld2139) as [ВыпускСумм] -- выпуск каждой продукции
	,[_fld22700] * d._fld2139 as [Выпуск]  
	,d._Description as [единицы измерения]
	--,nomenklatura._Idrref as [дляСцепки ИД продукции]
	,_Fld22693RRef as [дляСцепки ИД продукции]
	,коды._EnumOrder as [какой-то порядок операций]
	,DokVypuska._number as [документ вып]
	,Podrazdel._description as [подразделение выпуска]
into #выпускПродукцииМасло_0
from upp_2012.dbo._AccumRg22689 as vypuskProduktNakoplenie --- регистр накоплений выпуск
inner join upp_2012.dbo._Reference154 as nomenklatura
	on nomenklatura._Idrref=vypuskProduktNakoplenie._fld22693rref -- это продукция
left join upp_2012.dbo._Reference227 as b
	on b._Idrref=vypuskProduktNakoplenie._fld22696rref -- это спецификация
left join upp_2012.dbo._Reference91 as d
	on d._idrref=nomenklatura._fld2731rref  -- это единицы измерения
left join upp_2012.dbo._Reference51 as e
	on nomenklatura._fld2729rref=e._idrref -- это вид номенклатуры
left join  upp_2012.dbo._Enum884 as коды -- Перечисление.КодыОперацийВыпускПродукции (порядок)
	on коды._Idrref=vypuskProduktNakoplenie._fld22703rref
left join upp_2012.dbo._Document463 as DokVypuska -- документ выпуска
	on vypuskProduktNakoplenie._fld22698_rrref=DokVypuska._idrref
left join upp_2012.dbo._Reference154 as NazvanieRod -- номенклатура
	on nomenklatura._ParentIDRRef=NazvanieRod._idrref -- продукция
left join upp_2012.dbo._Reference182 as Podrazdel -- подразделения
	on DokVypuska._Fld11203RRef=Podrazdel._idrref
left join [onec-9].upp_2012.dbo._Reference49113 as vetis
	on  vetis._idrref = nomenklatura._fld49888rref
left join [onec-9].upp_2012.dbo._inforg19780 as svoistvo
	on  svoistvo._fld19781_rrref = nomenklatura._idrref
left join [onec-9].upp_2012.dbo._Reference97 as svoistvaObyektov
	on  svoistvaObyektov._idrref = svoistvo._fld19783_rrref
left join [onec-9].upp_2012.dbo._chrc1140 as svoistvaObyektov1
	on  svoistvaObyektov1._idrref = svoistvo._fld19782rref
--left join [onec-9].upp_2012.dbo._chrc1137 as kategorOb
--	on  kategorOb._idrref = svoistvaObyektov._fld25011rref	
	where datefromparts(year(vypuskProduktNakoplenie._Period)-2000, month(vypuskProduktNakoplenie._Period), 1) = 
    CASE 
        WHEN MONTH(GETDATE()) = 1 
            THEN DATEFROMPARTS(YEAR(GETDATE())-1, 12, 1)
        ELSE DATEFROMPARTS(YEAR(GETDATE()), MONTH(GETDATE())-1, 1)
    END

--and (nomenklatura._Description like '%82,5%' or nomenklatura._Description like '%72,5%')
--AND ([_fld22700] * d._fld2139) > 0 
--and vetis._code <> 000000003
--and svoistvaObyektov1._Description = 'группа аналитики'
--and (svoistvaObyektov._Description like '%82,5%' or svoistvaObyektov._Description like '%72,5%')
--and _enumorder not in (0,1, 7,9,10,13, 11)
--and vypuskProduktNakoplenie._recorderrref  in (select ОтчетПроизводстваЗасмену._idrref
 --from upp_2012.dbo._document463 ОтчетПроизводстваЗасмену 
	--inner join upp_2012.dbo._Document463_VT11275 ПоискСтатьиЗатрат on 
	--ОтчетПроизводстваЗасмену._IDRRef= ПоискСтатьиЗатрат._Document463_idrref
	--left join  upp_2012.dbo._Reference236 as ПризнакДопРабот on 
	--ПризнакДопРабот._idrref= _fld11286rref
	--where  ПризнакДопРабот._Description not like '%Доп%' and e._Description <> 'Сырье')

--- комментирование группировки из-за отключения суммы выпуска
group by datefromparts(year(_Period)-2000, month(_Period), 1),
  nomenklatura._Description, e._Description,
   _Fld22700,
   _Fld2139,
   b._Description, d._Description
   ,nomenklatura._Idrref
   ,коды._EnumOrder
   ,DokVypuska._number
   ,Podrazdel._description
   ,_Fld22693RRef
   ,vetis._code
   ,vetis._Description
   ,svoistvo._fld19782rref
   ,svoistvaObyektov._Description
   ,svoistvaObyektov1._Description 


     --select distinct  * from #выпускПродукцииМасло_0
	-- where [дляСцепки ИД продукции] = 0x995E00155D007AB511E4EDB5C7409020
	--where [Выпуск] <> [ВыпускСумм]
--select * from upp_2012.dbo._AccumRg22689 where _Fld22693RRef  = 0x80EE00155D007A2611E9252BD0184403
--where [дляСцепки ИД продукции] = 0x80EE00155D007A2611E9252BD0184403








------шаг 1.1 оставляем только уникалтьные строчки с суммой выпуска по ИД ПФ
if object_id (N'tempdb..#выпускПродукцииМасло_1') is not null drop table #выпускПродукцииМасло_1;
--select object_id ('tempdb..#..#mytemptable'); 
select Дата_0
	,[Продукция]
	,[вид продукции]
	,[Спецификация]
	,[контролируется в Меркурии код]
	,[контролируется в Меркурии]
	,[значение свойств]
	,[группа аналитики]
	,sum([Выпуск]) as [Выпуск]  
	,[единицы измерения]
	,[дляСцепки ИД продукции]
	,[какой-то порядок операций]
	,[подразделение выпуска]
into #выпускПродукцииМасло_1
from #выпускПродукцииМасло_0 as vypuskProduktNakoplenie1
group by Дата_0
	,[Продукция]
	,[вид продукции]
	,[Спецификация]
	,[единицы измерения]
	,[дляСцепки ИД продукции]
	,[какой-то порядок операций]
	,[подразделение выпуска]
	,[контролируется в Меркурии код]
	,[контролируется в Меркурии]
	,[значение свойств]
	,[группа аналитики]


--select distinct top 1000 * from #выпускПродукцииМасло_1
--where [выпуск] is null
--where [дляСцепки ИД продукции] = 0x80EE00155D007A2611E9252BD0184403

---- шаг 2 выборка суммы затрат по 

  if object_id (N'tempdb..#ЗатратыНаВыпускПродукции_масло') is not null drop table #ЗатратыНаВыпускПродукции_масло;
 WITH АгрегированныеДанные AS (
select ROW_NUMBER() OVER (ORDER BY datefromparts(year(_Period)-2000, month(_Period), 1), g._IDRRef) AS UniqueID
	,datefromparts(year(_Period)-2000, month(_Period), 1) as Дата,
	f._Description as [Вид_номенклатуры] -- название номенклатуры затраты
	, g._Description as [Затрата название]  --- это полуфабрикаты,  из которых делается ГП
	--, vetis._code as [контролируется в Меркурии код]
	--, vetis._Description as [контролируется в Меркурии]
	--, svoistvaObyektov._Description as [значение свойств]
	--, svoistvaObyektov1._Description as [группа аналитики]
	, g._IDRRef as [ИД ПФ]
	, NazvanieRod._Description as [название родителя]
	--,sum([_fld23184] * h._fld2139) as [ЗатратыСумм]  -- сумма не нужна.т.к. нужно считать окна
	,sum([_fld23184] * h._fld2139) as [Затраты]
	--, sum(m._fld23185) as Сумма  -- сумма из регистра накоплений
	,JoinVypusk.[Выпуск]  -- джойним выпуск из регистра выпуска
	--,cast( sum(m.[_fld23184] * h._fld2139) as decimal(18,5))/cast(sum(JoinVypusk.[Выпуск]) as decimal(18,5)) as КоэффициентЭтапа
	,cast( sum(m.[_fld23184] * h._fld2139) as decimal(18,5))/cast(sum(JoinVypusk.[Выпуск]) as decimal(18,5)) as [факт расхода сырья]
	--, m._fld23185 as Сумма
	,m._fld23171rref as дляСцепки2
	--,p._description as номенклатура_предрод  -- не надо 
	--,r._description as номенклатура_род -- не надо 
	,SpetsNomenkl._description as [название спецификации]
	,DokVypuska._number as [документ выпуска]
	,Podrazdel._description as [подразделение]
		-- Сумма затрат по ГП
    --,SUM([_fld23184] * h._fld2139) OVER(PARTITION BY JoinVypusk.Продукция,g._Description) AS СуммаЗатратСырьяПоГП
	--,ROW_NUMBER() OVER (PARTITION BY [наименование ГП план] ORDER BY (SELECT NULL)) as ПланНомер
	--,dense_rank () OVER(PARTITION BY JoinVypusk.Продукция,g._Description order by [_fld23184] * h._fld2139) AS УникСуммаЗатратСырьяПоГП
	--,case when (dense_rank () OVER(PARTITION BY JoinVypusk.Продукция,g._Description order by [_fld23184] * h._fld2139)) = 1 then SUM([_fld23184] * h._fld2139) OVER(PARTITION BY JoinVypusk.Продукция,g._Description) else 0 end as ЗначениеЗатратыПоГП


from upp_2012.dbo._AccumRg23166 as m
inner join upp_2012.dbo._Reference154 as g -- номенклатура
	on g._Idrref=m._fld23178_rrref -- название номенклатуры-затраты
left join upp_2012.dbo._Reference51 as f -- вид номенклатуры
	on g._fld2729rref=f._idrref
left join upp_2012.dbo._Reference91 as h -- единицы измерения
	on g._fld2731rref=h._idrref
left join upp_2012.dbo._Reference154 as p -- номенклатура
	on m._fld23171rref=p._idrref -- продукция
inner join upp_2012.dbo._Reference154 as r -- номенклатура
	on p._parentIdrref=r._Idrref -- у номенклатуры  родитель или предрод
left join upp_2012.dbo._Reference227 as SpetsNomenkl -- номенклатура
	on m._fld23174rref=SpetsNomenkl._idrref -- спецификация номенклатуры
left join upp_2012.dbo._Document463 as DokVypuska -- документ выпуска
	on m._fld23176_rrref=DokVypuska._idrref
left join upp_2012.dbo._Reference154 as NazvanieRod -- номенклатура
	on g._ParentIDRRef=NazvanieRod._idrref -- продукция
left join upp_2012.dbo._Reference182 as Podrazdel -- подразделения
	on DokVypuska._Fld11203RRef=Podrazdel._idrref


left join (
    SELECT 
        продукция,
		[дляСцепки ИД продукции],
        SUM([Выпуск]) as [Выпуск]
    FROM #выпускПродукцииМасло_1
    GROUP BY [дляСцепки ИД продукции], продукция
) as JoinVypusk on m._fld23171rref = JoinVypusk.[дляСцепки ИД продукции]


where f._Description not like '%Тароупаковочный материал%' 
and Podrazdel._description like '%масла%' ----- ОГРАНИЧЕНИЕ ПО МАСЛУ ТУТ - участок производства масла
and datefromparts(year(m._Period)-2000, month(m._Period), 1) = 
    CASE 
        WHEN MONTH(GETDATE()) = 1 
            THEN DATEFROMPARTS(YEAR(GETDATE())-1, 12, 1)
        ELSE DATEFROMPARTS(YEAR(GETDATE()), MONTH(GETDATE())-1, 1)
    END
--and vetis._code <> 000000003
--and svoistvaObyektov1._Description = 'группа аналитики'
--and (svoistvaObyektov._Description like '%82,5%' or svoistvaObyektov._Description like '%72,5%')
and f._Description not like '%тароупаковочный%'
--and JoinVypusk.[дляСцепки ИД продукции] = 0x811500155D03A15C11EAABB37113DB64
--- пока суммирования нет группировку отключаю
group by m._Period 	,f._Description  ,g._Description  ,g._IDRRef  ,NazvanieRod._Description  ,m._fld23171rref  ,p._description  ,r._description  ,SpetsNomenkl._description  ,DokVypuska._number, Podrazdel._description
,[_fld23184] , h._fld2139
,JoinVypusk.[Выпуск]
,JoinVypusk.Продукция
--   ,vetis._code
--   ,vetis._Description
--   ,svoistvo._fld19782rref
--   ,svoistvaObyektov._Description
--  ,svoistvaObyektov1._Description 
)
SELECT 
    *,
    ROW_NUMBER() OVER (ORDER BY [факт расхода сырья], UniqueID) as УникальныйИД

into #ЗатратыНаВыпускПродукции_масло
FROM АгрегированныеДанные;




--select  * from #ЗатратыНаВыпускПродукции_масло order by [факт расхода сырья] desc
--where [ИД ПФ] = 0x811500155D03A15C11EAABB37113DB64
--where [факт расхода сырья] is null
--where [документ выпуска] = 'ВРА00015359'
--where uniqueid = '1178'
--where uniqueid = '16'
--where выпуск is null
--where uniqueid = '2363'
--where [Затраты] = 0
--select  [затрата название] as сырье, sum([факт расхода сырья]) as [сумма расхода каждого сырья] from #ЗатратыНаВыпускПродукции_масло group by [затрата название] 
--select * from upp_2012.dbo._AccumRg23166 where
--_fld23171rref = 0xA80000155D03E22B11E53C142372FB49
--upp_2012.dbo._AccumRg23166


--select count([ИД ПФ]) from #ЗатратыНаВыпускПродукции_масло



--- шаг 2.1. отделяем сырье от ПФ

if object_id (N'tempdb..#ЗатратыНаВыпускПФ21') is not null drop table #ЗатратыНаВыпускПФ21;
select UniqueID
	,дата
	,[Вид_номенклатуры]
	,[Затрата название]
	,[ИД ПФ]
	,[название родителя]
	,[Затраты]
	,[Выпуск]
	--,КоэффициентЭтапа
	,[факт расхода сырья]
	,[документ выпуска]
	,[название спецификации]
	--,СуммаЗатратСырьяПоГП
	--,УникСуммаЗатратСырьяПоГП
	--,ЗначениеЗатратыПоГП
	into #ЗатратыНаВыпускПФ21
from #ЗатратыНаВыпускПродукции_масло
 where 
[Вид_номенклатуры] like '%Полуфабрикат%'
and 
дата = 
    CASE 
        WHEN MONTH(GETDATE()) = 1 
            THEN DATEFROMPARTS(YEAR(GETDATE())-1, 12, 1)
        ELSE DATEFROMPARTS(YEAR(GETDATE()), MONTH(GETDATE())-1, 1)
    END


--select  * from #ЗатратыНаВыпускПродукции_масло21


-- шаг 2.2. выводим список сырья после первого этапа


if object_id (N'tempdb..#ЗатратыНаВыпускПФСырье0') is not null drop table #ЗатратыНаВыпускПФСырье0;
select UniqueID as UniqueID_2_2
	,дата
	,[Вид_номенклатуры]
	,[Затрата название]
	,[ИД ПФ]
	,[название родителя]
	,[Затраты]
	,[Выпуск]
	--,КоэффициентЭтапа
	,[факт расхода сырья]
	--,[документ выпуска]
	,[название спецификации]
	--,СуммаЗатратСырьяПоГП
	--,УникСуммаЗатратСырьяПоГП
	--,ЗначениеЗатратыПоГП
	into #ЗатратыНаВыпускПФСырье0
from #ЗатратыНаВыпускПродукции_масло
 where 
[Вид_номенклатуры] not like '%Полуфабрикат%' and [Вид_номенклатуры] not like '%тароупаковочный%'
and 
дата = 
    CASE 
        WHEN MONTH(GETDATE()) = 1 
            THEN DATEFROMPARTS(YEAR(GETDATE())-1, 12, 1)
        ELSE DATEFROMPARTS(YEAR(GETDATE()), MONTH(GETDATE())-1, 1)
    END


--select  * from #ЗатратыНаВыпускПФСырье0
--select  [затрата название] as сырье, sum([факт расхода сырья]) as [сумма расхода каждого сырья] from #ЗатратыНаВыпускПФСырье0 group by [затрата название] 


--- шаг 3 -- затраты ПФ для дальнейшей рекурсии
      if object_id (N'tempdb..#ЗатратыНаВыпускПФ') is not null drop table #ЗатратыНаВыпускПФ;
WITH АгрегированныеДанные AS (
select IZPF.UniqueID
	,IZPF.дата 
	,f._Description as [Вид_номенклатуры] 
	,gZ._Description as [промежуточный полуфабрикат]
	,IZPF.[ИД ПФ]
	,g1._Description as [Затрата название сырья]
	,g1._IDRRef as [ИД ПФ1]
	,sum(ZatratyNakoplen.[_fld23184] * h._fld2139) as [Затраты]
	,IZPF.дляСцепки2
	--,JoinVypusk.дляСцепки2 as [ИД от ПФ 2 шага]
	,JoinVypusk.[Выпуск]
	--,cast( sum(ZatratyNakoplen.[_fld23184] * h._fld2139) as decimal(18,5))/cast(sum(JoinVypusk.[Выпуск])*IZPF.Выпуск as decimal(18,5)) as КоэффициентЭтапа
--	,cast( sum(ZatratyNakoplen.[_fld23184] * h._fld2139) as decimal(18,5)) --затраты эти
 --       * inGP.[факт расхода сырья]
--		/ NULLIF(cast( JoinVypusk.[Выпуск] as decimal(18,5)), 0) as [факт расхода сырья]  -- выпуск этот
	,cast( sum(ZatratyNakoplen.[_fld23184] * h._fld2139) as decimal(18,5)) --затраты эти
        * inGP.[Затраты]
		/ NULLIF(cast( JoinVypusk.[Выпуск] as decimal(18,5)), 0) as [факт расхода сырья]
	,cast( sum(ZatratyNakoplen.[_fld23184] * h._fld2139) as decimal(18,5)) 
        * IZPF.Затраты --затраты верхние
        / NULLIF(cast( JoinVypusk.[Выпуск] as decimal(18,5)), 0) as [факт расхода сырья от ГП ]
	,OPZS._number as [ссылка на ОПЗС]
	,SpetsNomenkl._description as [название конечной продукции]
	

	--,SUM(ZatratyNakoplen.[_fld23184] * h._fld2139) OVER(PARTITION BY JoinVypusk.Продукция, gZ._Description) AS СуммаЗатратСырьяПоГП
	--,dense_rank () OVER(PARTITION BY JoinVypusk.Продукция, gZ._Description order by [_fld23184] * h._fld2139) AS УникСуммаЗатратСырьяПоГП
	--,case when (dense_rank () OVER(PARTITION BY JoinVypusk.Продукция, gZ._Description order by ZatratyNakoplen.[_fld23184] * h._fld2139)) = 1 then SUM(ZatratyNakoplen.[_fld23184] * h._fld2139) OVER(PARTITION BY JoinVypusk.Продукция, gZ._Description) else 0 end as ЗначениеЗатратыПоГП



from #ЗатратыНаВыпускПродукции_масло as IZPF
inner join upp_2012.dbo._AccumRg23166 as ZatratyNakoplen
	on ZatratyNakoplen._Fld23171RRef = IZPF.[ИД ПФ] --- сцепка с продукцией!!!
inner join upp_2012.dbo._Reference154 as g1 -- номенклатура - для продукции
	on g1._Idrref=ZatratyNakoplen._Fld23178_rRRef
inner join upp_2012.dbo._Reference154 as gZ -- номенклатура для затраты
	on gZ._Idrref=ZatratyNakoplen._Fld23178_rRRef
left join upp_2012.dbo._Reference51 as f -- вид номенклатуры затраты
	on gZ._fld2729rref=f._idrref
left join upp_2012.dbo._Reference91 as h -- единицы измерения
	on g1._fld2731rref=h._idrref
inner join [onec-9].upp_2012.dbo._Document463 as OPZS
	on ZatratyNakoplen._RecorderRRef = OPZS._idrref
left join upp_2012.dbo._Reference227 as SpetsNomenkl -- номенклатура
	on ZatratyNakoplen._fld23174rref=SpetsNomenkl._idrref -- спецификация номенклатуры
left join upp_2012.dbo._Document463 as DokVypuska -- документ выпуска
	on ZatratyNakoplen._fld23176_rrref=DokVypuska._idrref



left join (
    SELECT 
        продукция,
		[дляСцепки ИД продукции],
        SUM([Выпуск]) as [Выпуск]
    FROM #выпускПродукцииМасло_1
    GROUP BY [дляСцепки ИД продукции], продукция
) as JoinVypusk on IZPF.[ИД ПФ] = JoinVypusk.[дляСцепки ИД продукции]

left join (
    SELECT 
        УникальныйИД,
        [Затраты]
    FROM #ЗатратыНаВыпускПродукции_масло
) as inGP on IZPF.[УникальныйИД] = inGP.[УникальныйИД]

where datefromparts(year(ZatratyNakoplen._period)-2000, month(ZatratyNakoplen._period), 1) =
    CASE 
        WHEN MONTH(GETDATE()) = 1 
            THEN DATEFROMPARTS(YEAR(GETDATE())-1, 12, 1)
        ELSE DATEFROMPARTS(YEAR(GETDATE()), MONTH(GETDATE())-1, 1)
    END
and f._Description not like '%тароупаковочный%'
--and JoinVypusk.продукция = 'ПФМас.7Утра.72,5%.180г.фол.8шт' and JoinVypusk.[дляСцепки ИД продукции] = 0x812000155D03A15C11EBFA74015BF2B4
--and [ИД ПФ]	= 0x80D700155D007A0A11E78EFE48FB12FD
group by 
        IZPF.UniqueID, IZPF.дата, f._Description, gZ._Description, 
        IZPF.[ИД ПФ], g1._Description, g1._IDRRef, OPZS._number, 
        SpetsNomenkl._description, IZPF.дляСцепки2, JoinVypusk.[Выпуск],
         IZPF.Затраты , inGP.[Затраты]
)
SELECT 
    *,
    ROW_NUMBER() OVER (ORDER BY [факт расхода сырья], UniqueID) as УникальныйИД

into #ЗатратыНаВыпускПФ
FROM АгрегированныеДанные;




--select * from #ЗатратыНаВыпускПФ order by [факт расхода сырья] desc
--where uniqueid = '1178'
--where [ИД ПФ1] = 0x811700155D03A15C11EACD727570810C
--where [ИД ПФ] = 0x810F00155D03A15C11EA863C0919B864
--where [факт расхода сырья] > 0
--select count([промежуточный полуфабрикат]) from #ЗатратыНаВыпускПФ
--select  [промежуточный полуфабрикат] as сырье, sum([факт расхода сырья]) as [сумма расхода каждого сырья] from #ЗатратыНаВыпускПФ group by [промежуточный полуфабрикат]
--SELECT     [название конечной продукции] as [Главная продукция],    [промежуточный полуфабрикат] as сырье,    SUM([факт расхода сырья]) as [сумма расхода сырья] FROM #ЗатратыНаВыпускПФ GROUP BY [название конечной продукции], [промежуточный полуфабрикат] ORDER BY [название конечной продукции], [сумма расхода сырья] DESC



--- шаг 3.1. создаем две таблицы с ПФ и сырьем из таблицы #ЗатратыНаВыпускПФ

if object_id (N'tempdb..#ЗатратыНаВыпускПФ31') is not null drop table #ЗатратыНаВыпускПФ31;
select UniqueID
	,дата
	,[Вид_номенклатуры]
	,[промежуточный полуфабрикат]
	,[ИД ПФ]
	,[Затрата название сырья]
	,[ИД ПФ1]
	,[Затраты]
	,[Выпуск]
	--,КоэффициентЭтапа
	,[факт расхода сырья]
	,[ссылка на ОПЗС]
	,[название конечной продукции]
	--,СуммаЗатратСырьяПоГП
	--,УникСуммаЗатратСырьяПоГП
	--,ЗначениеЗатратыПоГП
	into #ЗатратыНаВыпускПФ31
from #ЗатратыНаВыпускПФ
 where 
[Вид_номенклатуры] like '%Полуфабрикат%'
and 
дата = 
    CASE 
        WHEN MONTH(GETDATE()) = 1 
            THEN DATEFROMPARTS(YEAR(GETDATE())-1, 12, 1)
        ELSE DATEFROMPARTS(YEAR(GETDATE()), MONTH(GETDATE())-1, 1)
    END

--select  * from #ЗатратыНаВыпускПФ31

--select count([промежуточный полуфабрикат]) from #ЗатратыНаВыпускПФ31



--- шаг 3.2 -- сырье за первого ПФ

if object_id (N'tempdb..#ЗатратыНаВыпускСырье1') is not null drop table #ЗатратыНаВыпускСырье1;
select UniqueID as UniqueID_3_2 
	,дата
	,[Вид_номенклатуры] 
	,[промежуточный полуфабрикат]
	,[ИД ПФ]
	,[Затрата название сырья]
	,[ИД ПФ1]
	,[Затраты]
	,[Выпуск]
	--,КоэффициентЭтапа
	,[факт расхода сырья]
	,[ссылка на ОПЗС]
	,[название конечной продукции]
	--,СуммаЗатратСырьяПоГП
	--,УникСуммаЗатратСырьяПоГП
	--,ЗначениеЗатратыПоГП
	into #ЗатратыНаВыпускСырье1
from #ЗатратыНаВыпускПФ
 where 
[Вид_номенклатуры] not like '%Полуфабрикат%' and [Вид_номенклатуры] not like '%тароупаковочный%'
and 
дата = 
    CASE 
        WHEN MONTH(GETDATE()) = 1 
            THEN DATEFROMPARTS(YEAR(GETDATE())-1, 12, 1)
        ELSE DATEFROMPARTS(YEAR(GETDATE()), MONTH(GETDATE())-1, 1)
    END

--select  * from #ЗатратыНаВыпускСырье1
--where [ИД ПФ1] = 0x828000155D03A15C11EFFE540141AA82


--select count([промежуточный полуфабрикат]) from #ЗатратыНаВыпускПФ31
--select count([промежуточный полуфабрикат]) from #ЗатратыНаВыпускПФ31
 





--- шаг 4  -- еще раз полуфабрикат раскладываем
   if object_id (N'tempdb..#ПФвторойРаз') is not null drop table #ПФвторойРаз;
WITH АгрегированныеДанные AS (  
select distinct IZPF.UniqueID
	,IZPF.дата
	,CASE 
        WHEN IZPF.[ИД ПФ1] = g1._IDRRef THEN 'Сырье-ГП' 
        ELSE f._Description 
    END AS [Вид_номенклатуры]
	,gZ._Description as [промежуточный полуфабрикат]
	,IZPF.[ИД ПФ1]
	,g1._Description as [Затрата название сырья]
	,g1._IDRRef as [ИД ПФ2]
	,sum(ZatratyNakoplen1.[_fld23184] * h._fld2139) as [Затраты]
	,IZPF.дляСцепки2
	,JoinVypusk.[Выпуск]
	--,cast( sum(ZatratyNakoplen1.[_fld23184] * h._fld2139) as decimal(18,5))/cast(sum(JoinVypusk.[Выпуск])*IZPF.Выпуск as decimal(18,5)) as КоэффициентЭтапа
	,cast( sum(ZatratyNakoplen1.[_fld23184] * h._fld2139) as decimal(18,5)) 
        * inGP.[Затраты]
        / NULLIF(cast( JoinVypusk.[Выпуск] as decimal(18,5)), 0) as [факт расхода сырья]
	,cast( sum(ZatratyNakoplen1.[_fld23184] * h._fld2139) as decimal(18,5)) 
        * IZPF.Затраты --затраты верхние
        / NULLIF(cast( JoinVypusk.[Выпуск] as decimal(18,5)), 0) as [факт расхода сырья от ГП ]

	,OPZS._number as [ссылка на ОПЗС]
	,SpetsNomenkl._description as [название конечной продукции]
	,IZPF.УникальныйИД
	--,SUM(ZatratyNakoplen1.[_fld23184] * h._fld2139) OVER(PARTITION BY JoinVypusk.Продукция, gZ._Description) AS СуммаЗатратСырьяПоГП
	--,dense_rank () OVER(PARTITION BY JoinVypusk.Продукция, gZ._Description order by [_fld23184] * h._fld2139) AS УникСуммаЗатратСырьяПоГП
	--,case when (dense_rank () OVER(PARTITION BY JoinVypusk.Продукция, gZ._Description order by ZatratyNakoplen1.[_fld23184] * h._fld2139)) = 1 then SUM(ZatratyNakoplen1.[_fld23184] * h._fld2139) OVER(PARTITION BY JoinVypusk.Продукция, gZ._Description) else 0 end as ЗначениеЗатратыПоГП


from #ЗатратыНаВыпускПФ as IZPF
left join upp_2012.dbo._AccumRg23166 as ZatratyNakoplen1
	on ZatratyNakoplen1._Fld23171RRef = IZPF.[ИД ПФ1] --- сцепка с продукцией!!!
inner join upp_2012.dbo._Reference154 as g1 -- номенклатура - для продукции
	on g1._Idrref=ZatratyNakoplen1._Fld23178_rRRef
inner join upp_2012.dbo._Reference154 as gZ -- номенклатура для затраты
	on gZ._Idrref=ZatratyNakoplen1._Fld23178_rRRef
left join upp_2012.dbo._Reference51 as f -- вид номенклатуры затраты
	on gZ._fld2729rref=f._idrref
left join upp_2012.dbo._Reference91 as h -- единицы измерения
	on g1._fld2731rref=h._idrref
inner join [onec-9].upp_2012.dbo._Document463 as OPZS
	on ZatratyNakoplen1._RecorderRRef = OPZS._idrref
left join upp_2012.dbo._Reference227 as SpetsNomenkl -- номенклатура
	on ZatratyNakoplen1._fld23174rref=SpetsNomenkl._idrref -- спецификация номенклатуры
left join upp_2012.dbo._Document463 as DokVypuska -- документ выпуска
	on ZatratyNakoplen1._fld23176_rrref=DokVypuska._idrref
--left join #выпускПродукцииМасло_1 as JoinVypusk
--	on IZPF.дляСцепки2=JoinVypusk.[дляСцепки ИД продукции]
left join (
    SELECT 
        продукция,
		[дляСцепки ИД продукции],
        SUM([Выпуск]) as [Выпуск]
    FROM #выпускПродукцииМасло_1
    GROUP BY [дляСцепки ИД продукции], продукция
) as JoinVypusk on IZPF.[ИД ПФ1] = JoinVypusk.[дляСцепки ИД продукции]



left join (
    SELECT 
        УникальныйИД,
        [Затраты]
    FROM #ЗатратыНаВыпускПФ
) as inGP on IZPF.[УникальныйИД] = inGP.[УникальныйИД]


where 
datefromparts(year(ZatratyNakoplen1._period)-2000, month(ZatratyNakoplen1._period), 1) = 
    CASE 
        WHEN MONTH(GETDATE()) = 1 
            THEN DATEFROMPARTS(YEAR(GETDATE())-1, 12, 1)
        ELSE DATEFROMPARTS(YEAR(GETDATE()), MONTH(GETDATE())-1, 1)
    END
and f._Description not like '%тароупаковочный%'
--and OPZS._number = 'ВРА00005617'	
group by 
        IZPF.UniqueID, IZPF.дата, f._Description, gZ._Description, 
        IZPF.[ИД ПФ1], g1._Description, g1._IDRRef, OPZS._number, 
        SpetsNomenkl._description, IZPF.дляСцепки2, JoinVypusk.[Выпуск],
        inGP.[Затраты], IZPF.Затраты, IZPF.УникальныйИД
)
SELECT 
    *,
    ROW_NUMBER() OVER (ORDER BY [факт расхода сырья], УникальныйИД) as УникальныйИДотПФ

into #ПФвторойРаз
FROM АгрегированныеДанные;

--select top 5000 * from #ПФвторойРаз  order by [факт расхода сырья] desc
--where [ИД ПФ1] = 0x811700155D03A15C11EACD727570810C
--where uniqueid = '2736'
--where uniqueid = '1301'
--select count(дляСцепки2) from #ПФвторойРаз
--where дляСцепки2 is null
--select  [промежуточный полуфабрикат] as сырье, sum([факт расхода сырья]) as [сумма расхода каждого сырья] from #ЗатратыНаВыпускПФ group by [промежуточный полуфабрикат]
--SELECT     [название конечной продукции] as [Главная продукция],    [промежуточный полуфабрикат] as сырье,    SUM([факт расхода сырья]) as [сумма расхода сырья] FROM #ЗатратыНаВыпускПФ GROUP BY [название конечной продукции], [промежуточный полуфабрикат] ORDER BY [название конечной продукции], [сумма расхода сырья] DESC




--- шаг 4.1  -- еще раз полуфабрикат раскладываем
   if object_id (N'tempdb..#ПФвторойРаз41') is not null drop table #ПФвторойРаз41;
  
select UniqueID
	,дата
	,[Вид_номенклатуры]
	,[промежуточный полуфабрикат]
	,[ИД ПФ1]
	,[Затрата название сырья]
	,[ИД ПФ2]
	,[Затраты]
	,[Выпуск]
	--,КоэффициентЭтапа
	,[факт расхода сырья]
	,[ссылка на ОПЗС]
	,[название конечной продукции]
	--,СуммаЗатратСырьяПоГП
	--,УникСуммаЗатратСырьяПоГП
	--,ЗначениеЗатратыПоГП
into #ПФвторойРаз41
from #ПФвторойРаз as IZPF

where 
[Вид_номенклатуры] like '%Полуфабрикат%'
and 
дата = 
    CASE 
        WHEN MONTH(GETDATE()) = 1 
            THEN DATEFROMPARTS(YEAR(GETDATE())-1, 12, 1)
        ELSE DATEFROMPARTS(YEAR(GETDATE()), MONTH(GETDATE())-1, 1)
    END



--select  * from #ПФвторойРаз41



--- шаг 4.2  -- еще раз полуфабрикат раскладываем получаем сырье
   if object_id (N'tempdb..#ПФвторойРазСырье') is not null drop table #ПФвторойРазСырье;
  
select UniqueID as UniqueID_4_2
	,дата
	,[Вид_номенклатуры]
	,[промежуточный полуфабрикат]
	,[ИД ПФ1]
	,[Затрата название сырья]
	,[ИД ПФ2]
	,[Затраты]
	,[Выпуск]
	--,КоэффициентЭтапа
	,[факт расхода сырья]
	,[ссылка на ОПЗС]
	,[название конечной продукции]
	--,СуммаЗатратСырьяПоГП
	--,УникСуммаЗатратСырьяПоГП
	--,ЗначениеЗатратыПоГП
into #ПФвторойРазСырье
from #ПФвторойРаз as IZPF


where 
[Вид_номенклатуры] not like '%Полуфабрикат%' and [Вид_номенклатуры] not like '%тароупаковочный%'
and 
дата = 
    CASE 
        WHEN MONTH(GETDATE()) = 1 
            THEN DATEFROMPARTS(YEAR(GETDATE())-1, 12, 1)
        ELSE DATEFROMPARTS(YEAR(GETDATE()), MONTH(GETDATE())-1, 1)
    END
--and OPZS._number = 'ВРА00005617'	
--group by	дата	,f._Description	,gZ._Description	,[ИД ПФ]	,g1._Description	,g1._IDRRef	,OPZS._number	,SpetsNomenkl._description




--select   * from #ПФвторойРазСырье




--- шаг 5  -- еще раз полуфабрикат раскладываем
   if object_id (N'tempdb..#ПФтретийРаз') is not null drop table #ПФтретийРаз;
WITH АгрегированныеДанные AS (   
select IZPF.UniqueID
	,IZPF.дата
	,CASE 
        WHEN IZPF.[ИД ПФ2] = g1._IDRRef THEN 'Сырье-ГП' 
        ELSE f._Description 
    END AS [Вид_номенклатуры]
	,gZ._Description as [промежуточный полуфабрикат]
	,IZPF.[ИД ПФ2]
	,g1._Description as [Затрата название сырья]
	,g1._IDRRef as [ИД ПФ3]
	,sum(ZatratyNakoplen1.[_fld23184] * h._fld2139) as [Затраты]
	,IZPF.дляСцепки2
	,JoinVypusk.[Выпуск]
	--,cast( sum(ZatratyNakoplen1.[_fld23184] * h._fld2139) as decimal(18,5))/cast(sum(JoinVypusk.[Выпуск])*IZPF.Выпуск as decimal(18,5)) as КоэффициентЭтапа
	,cast( sum(ZatratyNakoplen1.[_fld23184] * h._fld2139) as decimal(18,5)) 
        * inGP.[Затраты]
        / NULLIF(cast(JoinVypusk.[Выпуск] as decimal(18,5)), 0) as [факт расхода сырья]
	,cast( sum(ZatratyNakoplen1.[_fld23184] * h._fld2139) as decimal(18,5)) 
        * IZPF.Затраты 
        / NULLIF(cast(JoinVypusk.[Выпуск] as decimal(18,5)), 0) as [факт расхода сырья от ПФ]
	
	,OPZS._number as [ссылка на ОПЗС]
	,SpetsNomenkl._description as [название конечной продукции]
	,IZPF.УникальныйИДотПФ
	--,SUM(ZatratyNakoplen1.[_fld23184] * h._fld2139) OVER(PARTITION BY JoinVypusk.Продукция, gZ._Description) AS СуммаЗатратСырьяПоГП
	--,dense_rank () OVER(PARTITION BY JoinVypusk.Продукция, gZ._Description order by [_fld23184] * h._fld2139) AS УникСуммаЗатратСырьяПоГП
	--,case when (dense_rank () OVER(PARTITION BY JoinVypusk.Продукция, gZ._Description order by ZatratyNakoplen1.[_fld23184] * h._fld2139)) = 1 then SUM(ZatratyNakoplen1.[_fld23184] * h._fld2139) OVER(PARTITION BY JoinVypusk.Продукция, gZ._Description) else 0 end as ЗначениеЗатратыПоГП


from #ПФвторойРаз as IZPF
left join upp_2012.dbo._AccumRg23166 as ZatratyNakoplen1
	on ZatratyNakoplen1._Fld23171RRef = IZPF.[ИД ПФ2] --- сцепка с продукцией!!!
inner join upp_2012.dbo._Reference154 as g1 -- номенклатура - для продукции
	on g1._Idrref=ZatratyNakoplen1._Fld23178_rRRef
inner join upp_2012.dbo._Reference154 as gZ -- номенклатура для затраты
	on gZ._Idrref=ZatratyNakoplen1._Fld23178_rRRef
left join upp_2012.dbo._Reference51 as f -- вид номенклатуры затраты
	on gZ._fld2729rref=f._idrref
left join upp_2012.dbo._Reference91 as h -- единицы измерения
	on g1._fld2731rref=h._idrref
inner join [onec-9].upp_2012.dbo._Document463 as OPZS
	on ZatratyNakoplen1._RecorderRRef = OPZS._idrref
left join upp_2012.dbo._Reference227 as SpetsNomenkl -- номенклатура
	on ZatratyNakoplen1._fld23174rref=SpetsNomenkl._idrref -- спецификация номенклатуры
left join upp_2012.dbo._Document463 as DokVypuska -- документ выпуска
	on ZatratyNakoplen1._fld23176_rrref=DokVypuska._idrref
--left join #выпускПродукцииМасло_1 as JoinVypusk
--	on IZPF.дляСцепки2=JoinVypusk.[дляСцепки ИД продукции]
left join (
    SELECT 
        продукция,
		[дляСцепки ИД продукции],
        SUM([Выпуск]) as [Выпуск]
    FROM #выпускПродукцииМасло_1
    GROUP BY [дляСцепки ИД продукции], продукция
) as JoinVypusk on IZPF.[ИД ПФ2] = JoinVypusk.[дляСцепки ИД продукции]


left join (
    SELECT 
        УникальныйИДотПФ,
        [Затраты]
    FROM #ПФвторойРаз
) as inGP on IZPF.[УникальныйИДотПФ] = inGP.[УникальныйИДотПФ]



where 
datefromparts(year(ZatratyNakoplen1._period)-2000, month(ZatratyNakoplen1._period), 1) = 
    CASE 
        WHEN MONTH(GETDATE()) = 1 
            THEN DATEFROMPARTS(YEAR(GETDATE())-1, 12, 1)
        ELSE DATEFROMPARTS(YEAR(GETDATE()), MONTH(GETDATE())-1, 1)
    END
and f._Description not like '%тароупаковочный%'
--and OPZS._number = 'ВРА00005617'	
group by 
        IZPF.UniqueID, IZPF.дата, f._Description, gZ._Description, 
        IZPF.[ИД ПФ2], g1._Description, g1._IDRRef, OPZS._number, 
        SpetsNomenkl._description, IZPF.дляСцепки2, JoinVypusk.[Выпуск],
        inGP.[Затраты], IZPF.Затраты, IZPF.УникальныйИДотПФ

)
SELECT 
    *,
    ROW_NUMBER() OVER (ORDER BY [факт расхода сырья], УникальныйИДотПФ) as УникальныйИДотПФ2

into #ПФтретийРаз
FROM АгрегированныеДанные;


--select  * from #ПФтретийРаз  order by [факт расхода сырья] desc
--where Вид_номенклатуры like '%тароупаковочный%'
--where uniqueid = '2689'


--- шаг 5.1  -- еще раз полуфабрикат раскладываем
   if object_id (N'tempdb..#ПФтретийРаз51') is not null drop table #ПФтретийРаз51;
  
select UniqueID
	,дата
	,[Вид_номенклатуры]
	,[промежуточный полуфабрикат]
	,[ИД ПФ2]
	,[Затрата название сырья]
	,[ИД ПФ3]
	,[Затраты]
	,[Выпуск]
	--,КоэффициентЭтапа
	,[факт расхода сырья]
	,[ссылка на ОПЗС]
	,[название конечной продукции]
	--,СуммаЗатратСырьяПоГП
	--,УникСуммаЗатратСырьяПоГП
	--,ЗначениеЗатратыПоГП
into #ПФтретийРаз51
from #ПФтретийРаз as IZPF

where 
[Вид_номенклатуры] like '%Полуфабрикат%'
and 
дата = 
    CASE 
        WHEN MONTH(GETDATE()) = 1 
            THEN DATEFROMPARTS(YEAR(GETDATE())-1, 12, 1)
        ELSE DATEFROMPARTS(YEAR(GETDATE()), MONTH(GETDATE())-1, 1)
    END



--select   * from #ПФтретийРаз51



--- шаг 5.2  -- еще раз полуфабрикат раскладываем получаем сырье
   if object_id (N'tempdb..#ПФтретийРазСырье') is not null drop table #ПФтретийРазСырье;
  
select UniqueID as UniqueID_5_2
	,дата
	,[Вид_номенклатуры]
	,[промежуточный полуфабрикат]
	,[ИД ПФ2]
	,[Затрата название сырья]
	,[ИД ПФ3]
	,[Затраты]
	,[Выпуск]
	--,КоэффициентЭтапа
	,[факт расхода сырья]
	,[ссылка на ОПЗС]
	,[название конечной продукции]
	--,СуммаЗатратСырьяПоГП
	--,УникСуммаЗатратСырьяПоГП
	--,ЗначениеЗатратыПоГП
into #ПФтретийРазСырье
from #ПФтретийРаз as IZPF


where 
[Вид_номенклатуры] not like '%Полуфабрикат%' and [Вид_номенклатуры] not like '%тароупаковочный%'
and 
дата = 
    CASE 
        WHEN MONTH(GETDATE()) = 1 
            THEN DATEFROMPARTS(YEAR(GETDATE())-1, 12, 1)
        ELSE DATEFROMPARTS(YEAR(GETDATE()), MONTH(GETDATE())-1, 1)
    END
--and OPZS._number = 'ВРА00005617'	
--group by	дата	,f._Description	,gZ._Description	,[ИД ПФ]	,g1._Description	,g1._IDRRef	,OPZS._number	,SpetsNomenkl._description




--select top 1000  * from #ПФтретийРазСырье
--select  [промежуточный полуфабрикат] as сырье, sum([факт расхода сырья]) as [сумма расхода каждого сырья] from #ПФтретийРазСырье group by [промежуточный полуфабрикат]




--- шаг 6  -- еще раз полуфабрикат раскладываем
   if object_id (N'tempdb..#ПФчетвертыйРаз') is not null drop table #ПФчетвертыйРаз;
  
select IZPF.UniqueID
	,IZPF.дата
	,CASE 
        WHEN IZPF.[ИД ПФ3] = g1._IDRRef THEN 'Сырье-ГП' 
        ELSE f._Description 
    END AS [Вид_номенклатуры]
	,gZ._Description as [промежуточный полуфабрикат]
	,IZPF.[ИД ПФ3]
	,g1._Description as [Затрата название сырья]
	,g1._IDRRef as [ИД ПФ4]
	,sum(ZatratyNakoplen1.[_fld23184] * h._fld2139) as [Затраты]
	,IZPF.дляСцепки2
	,JoinVypusk.[Выпуск]
	--,cast( sum(ZatratyNakoplen1.[_fld23184] * h._fld2139) as decimal(18,5))/cast(sum(JoinVypusk.[Выпуск])*IZPF.Выпуск as decimal(18,5)) as КоэффициентЭтапа
	,cast( sum(ZatratyNakoplen1.[_fld23184] * h._fld2139) as decimal(18,5)) 
        * inGP.[Затраты]
        / NULLIF(cast(JoinVypusk.[Выпуск] as decimal(18,5)), 0) as [факт расхода сырья]
	,cast( sum(ZatratyNakoplen1.[_fld23184] * h._fld2139) as decimal(18,5)) 
        * IZPF.Затраты 
        / NULLIF(cast(JoinVypusk.[Выпуск] as decimal(18,5)), 0) as [факт расхода сырья от ГП ]
	,OPZS._number as [ссылка на ОПЗС]
	,SpetsNomenkl._description as [название конечной продукции]
	,IZPF.УникальныйИДотПФ2
	
	
	--,SUM(ZatratyNakoplen1.[_fld23184] * h._fld2139) OVER(PARTITION BY JoinVypusk.Продукция, gZ._Description) AS СуммаЗатратСырьяПоГП
	--,dense_rank () OVER(PARTITION BY JoinVypusk.Продукция, gZ._Description order by [_fld23184] * h._fld2139) AS УникСуммаЗатратСырьяПоГП
	--,case when (dense_rank () OVER(PARTITION BY JoinVypusk.Продукция, gZ._Description order by ZatratyNakoplen1.[_fld23184] * h._fld2139)) = 1 then SUM(ZatratyNakoplen1.[_fld23184] * h._fld2139) OVER(PARTITION BY JoinVypusk.Продукция, gZ._Description) else 0 end as ЗначениеЗатратыПоГП


into #ПФчетвертыйРаз
from #ПФтретийРаз as IZPF
left join upp_2012.dbo._AccumRg23166 as ZatratyNakoplen1
	on ZatratyNakoplen1._Fld23171RRef = IZPF.[ИД ПФ3] --- сцепка с продукцией!!!
inner join upp_2012.dbo._Reference154 as g1 -- номенклатура - для продукции
	on g1._Idrref=ZatratyNakoplen1._Fld23178_rRRef
inner join upp_2012.dbo._Reference154 as gZ -- номенклатура для затраты
	on gZ._Idrref=ZatratyNakoplen1._Fld23178_rRRef
left join upp_2012.dbo._Reference51 as f -- вид номенклатуры затраты
	on gZ._fld2729rref=f._idrref
left join upp_2012.dbo._Reference91 as h -- единицы измерения
	on g1._fld2731rref=h._idrref
inner join [onec-9].upp_2012.dbo._Document463 as OPZS
	on ZatratyNakoplen1._RecorderRRef = OPZS._idrref
left join upp_2012.dbo._Reference227 as SpetsNomenkl -- номенклатура
	on ZatratyNakoplen1._fld23174rref=SpetsNomenkl._idrref -- спецификация номенклатуры
left join upp_2012.dbo._Document463 as DokVypuska -- документ выпуска
	on ZatratyNakoplen1._fld23176_rrref=DokVypuska._idrref
--left join #выпускПродукцииМасло_1 as JoinVypusk
--	on IZPF.дляСцепки2=JoinVypusk.[дляСцепки ИД продукции]
left join (
    SELECT 
        продукция,
		[дляСцепки ИД продукции],
        SUM([Выпуск]) as [Выпуск]
    FROM #выпускПродукцииМасло_1
    GROUP BY [дляСцепки ИД продукции], продукция
) as JoinVypusk on IZPF.дляСцепки2 = JoinVypusk.[дляСцепки ИД продукции]

left join (
    SELECT 
        УникальныйИДотПФ2,
        [Затраты]
    FROM #ПФтретийРаз
) as inGP on inGP.[УникальныйИДотПФ2]=IZPF.[УникальныйИДотПФ2]



where 
datefromparts(year(ZatratyNakoplen1._period)-2000, month(ZatratyNakoplen1._period), 1) = 
    CASE 
        WHEN MONTH(GETDATE()) = 1 
            THEN DATEFROMPARTS(YEAR(GETDATE())-1, 12, 1)
        ELSE DATEFROMPARTS(YEAR(GETDATE()), MONTH(GETDATE())-1, 1)
    END
and f._Description not like '%тароупаковочный%'
--and OPZS._number = 'ВРА00005617'	
group by 
        IZPF.UniqueID, IZPF.дата, f._Description, gZ._Description, 
        IZPF.[ИД ПФ3], g1._Description, g1._IDRRef, OPZS._number, 
        SpetsNomenkl._description, IZPF.дляСцепки2, JoinVypusk.[Выпуск],
        inGP.[Затраты], IZPF.Затраты, IZPF.УникальныйИДотПФ2


--select top 1000  * from #ПФчетвертыйРаз


--- шаг 6.1  -- еще раз полуфабрикат раскладываем
   if object_id (N'tempdb..#ПФчетвертыйРаз61') is not null drop table #ПФчетвертыйРаз61;
  
select UniqueID
	,дата
	,[Вид_номенклатуры]
	,[промежуточный полуфабрикат]
	,[ИД ПФ3]
	,[Затрата название сырья]
	,[ИД ПФ4]
	,[Затраты]
	,[Выпуск]
	--,КоэффициентЭтапа
	,[факт расхода сырья]
	,[ссылка на ОПЗС]
	,[название конечной продукции]
	--,СуммаЗатратСырьяПоГП
	--,УникСуммаЗатратСырьяПоГП
	--,ЗначениеЗатратыПоГП
into #ПФчетвертыйРаз61
from #ПФчетвертыйРаз as IZPF

where 
[Вид_номенклатуры] like '%Полуфабрикат%'
and 
дата = 
    CASE 
        WHEN MONTH(GETDATE()) = 1 
            THEN DATEFROMPARTS(YEAR(GETDATE())-1, 12, 1)
        ELSE DATEFROMPARTS(YEAR(GETDATE()), MONTH(GETDATE())-1, 1)
    END



--select top 1000  * from #ПФчетвертыйРаз61
--where [Вид_номенклатуры] = 'Сырье-ГП'


--- шаг 6.2  -- еще раз полуфабрикат раскладываем получаем сырье
   if object_id (N'tempdb..#ПФчетвертыйРазСырье') is not null drop table #ПФчетвертыйРазСырье;
  
select UniqueID as UniqueID_6_2
	,дата
	,[Вид_номенклатуры]
	,[промежуточный полуфабрикат]
	,[ИД ПФ3]
	,[Затрата название сырья]
	,[ИД ПФ4]
	,[Затраты]
	,[Выпуск]
	--,КоэффициентЭтапа
	,[факт расхода сырья]
	,[ссылка на ОПЗС]
	,[название конечной продукции]
	--,СуммаЗатратСырьяПоГП
	--,УникСуммаЗатратСырьяПоГП
	--,ЗначениеЗатратыПоГП
into #ПФчетвертыйРазСырье
from #ПФчетвертыйРаз as IZPF


where 
[Вид_номенклатуры] not like '%Полуфабрикат%' and [Вид_номенклатуры] not like '%тароупаковочный%'
and 
дата = 
    CASE 
        WHEN MONTH(GETDATE()) = 1 
            THEN DATEFROMPARTS(YEAR(GETDATE())-1, 12, 1)
        ELSE DATEFROMPARTS(YEAR(GETDATE()), MONTH(GETDATE())-1, 1)
    END
--and OPZS._number = 'ВРА00005617'	
--group by	дата	,f._Description	,gZ._Description	,[ИД ПФ]	,g1._Description	,g1._IDRRef	,OPZS._number	,SpetsNomenkl._description




--select top 1000  * from #ПФчетвертыйРазСырье
--select  [промежуточный полуфабрикат] as сырье, sum([факт расхода сырья]) as [сумма расхода каждого сырья] from #ПФчетвертыйРазСырье group by [промежуточный полуфабрикат]




-- шаг 777 сбор сырья в одну таблицу
IF OBJECT_ID (N'tempdb..#СборСырья') IS NOT NULL DROP TABLE #СборСырья;

-- Сначала создаем таблицу с нужной структурой

SELECT 
    UniqueID_2_2 
	,дата
	,[Вид_номенклатуры] 
	,[Затрата название] as [промежуточный полуфабрикат]
	,[ИД ПФ]
	,[название родителя] as [Затрата название сырья]
	,[Затраты]
	,[Выпуск]
	--,КоэффициентЭтапа
	,[факт расхода сырья]
	--,[название конечной продукции]
	--,СуммаЗатратСырьяПоГП
	--,УникСуммаЗатратСырьяПоГП
	--,ЗначениеЗатратыПоГП
INTO #СборСырья 
FROM #ЗатратыНаВыпускПФСырье0

UNION ALL

SELECT	
	UniqueID_3_2
	,дата
	,[Вид_номенклатуры] 
	,[промежуточный полуфабрикат]
	,[ИД ПФ]
	,[Затрата название сырья]
	,[Затраты]
	,[Выпуск]
	--,КоэффициентЭтапа
	,[факт расхода сырья]
	--,[название конечной продукции]
	--,СуммаЗатратСырьяПоГП
	--,УникСуммаЗатратСырьяПоГП
	--,ЗначениеЗатратыПоГП
FROM #ЗатратыНаВыпускСырье1

UNION ALL

SELECT 
    UniqueID_4_2 
	,дата
	,[Вид_номенклатуры] 
	,[промежуточный полуфабрикат]
	,[ИД ПФ1]
	,[Затрата название сырья]
	,[Затраты]
	,[Выпуск]
	--,КоэффициентЭтапа
	,[факт расхода сырья]
	--,[название конечной продукции]
	--,СуммаЗатратСырьяПоГП
	--,УникСуммаЗатратСырьяПоГП
	--,ЗначениеЗатратыПоГП
FROM #ПФвторойРазСырье

UNION ALL

SELECT 
    UniqueID_5_2 
	,дата
	,[Вид_номенклатуры] 
	,[промежуточный полуфабрикат]
	,[ИД ПФ2]
	,[Затрата название сырья]
	,[Затраты]
	,[Выпуск]
	--,КоэффициентЭтапа
	,[факт расхода сырья]
	--,[название конечной продукции]
	--,СуммаЗатратСырьяПоГП
	--,УникСуммаЗатратСырьяПоГП
	--,ЗначениеЗатратыПоГП
FROM #ПФтретийРазСырье

UNION ALL

SELECT 
    UniqueID_6_2 
	,дата
	,[Вид_номенклатуры] 
	,[промежуточный полуфабрикат]
	,[ИД ПФ3]
	,[Затрата название сырья]
	,[Затраты]
	,[Выпуск]
	--,КоэффициентЭтапа
	,[факт расхода сырья]
	--,[название конечной продукции]
	--,СуммаЗатратСырьяПоГП
	--,УникСуммаЗатратСырьяПоГП
	--,ЗначениеЗатратыПоГП
FROM #ПФчетвертыйРазСырье

UNION ALL

SELECT 
    UniqueID
	,Дата
	,[Вид_номенклатуры] -- название номенклатуры затраты
	,[Затрата название]  --- это полуфабрикаты,  из которых делается ГП
	,[ИД ПФ]
	,[название родителя]
	,[Затраты]
	,[Выпуск]
	--,КоэффициентЭтапа
	,[факт расхода сырья] -- сумма из регистра накоплений
	--,[название конечной продукции]
	--,СуммаЗатратСырьяПоГП
	--,УникСуммаЗатратСырьяПоГП
	--,ЗначениеЗатратыПоГП
FROM #ЗатратыНаВыпускПродукции_масло
where [Вид_номенклатуры] = 'сырье'



--select distinct top 1000 * from #СборСырья

--select  [промежуточный полуфабрикат] as сырье, sum([факт расхода сырья]) as [сумма расхода каждого сырья] from #СборСырья group by [промежуточный полуфабрикат]
--select count(distinct[промежуточный полуфабрикат])  from #СборСырья
--select count([промежуточный полуфабрикат])  from #СборСырья
--where [Вид_номенклатуры] = 'Сырье-ГП'
--where UniqueID = '1212'
--where [документ выпуска] = 'ВРА00005617'


--- шаг по подсчету оконных сумм и выведение в отдельную колонку (оконные суммы не понадобились - закомментировано)

--IF OBJECT_ID (N'tempdb..#СуммаСырья') IS NOT NULL DROP TABLE #СуммаСырья;

--SELECT     *,
    -- Сумма затрат по промежуточному полуфабрикату
 --   SUM([Затраты]) OVER(PARTITION BY [промежуточный полуфабрикат]) AS СуммаЗатратПоСырью,
	-- Сумма затрат по промежуточному полуфабрикату и UniqueID_3_2
--    SUM([Затраты]) OVER(PARTITION BY [промежуточный полуфабрикат], UniqueID_2_2) AS СуммаЗатратПоСырьюИID
--	,dense_rank () OVER(PARTITION BY [промежуточный полуфабрикат], UniqueID_2_2 order by [Затраты]) AS УникСуммаЗатратПоСырьюИID
--	,case when (dense_rank () over (partition by [промежуточный полуфабрикат], UniqueID_2_2 order by [Затраты])) = 1 then SUM([Затраты]) OVER(PARTITION BY [промежуточный полуфабрикат], UniqueID_2_2) else 0 end as ЗначениеЗатратыПоГПизВыпуска

--INTO #СуммаСырья
--FROM #СборСырья;

--select distinct top 1000 * from #СуммаСырья
--select count([промежуточный полуфабрикат])  from #СуммаСырья
--order by UniqueID_2_2 




--шаг предпоследний джоин данных по сырью к затратам
IF OBJECT_ID (N'tempdb..#ДжоинСырья') IS NOT NULL DROP TABLE #ДжоинСырья;
select UniqueID
	,Zatraty.Дата
	,Zatraty.[Вид_номенклатуры] -- название номенклатуры затраты
	,[Затрата название]  --- это полуфабрикаты,  из которых делается ГП
	,Zatraty.[ИД ПФ]
	,[название родителя]
	,Zatraty.[Затраты]  -- сумма не нужна.т.к. нужно считать окна
	--,Zatraty.Сумма  -- сумма из регистра накоплений
	,дляСцепки2
	--,Zatraty.[название конечной продукции]
	,Zatraty.[документ выпуска]
	--,oknaS.КоэффициентЭтапа
	,oknaS.[факт расхода сырья]
	--,oknaS.СуммаЗатратСырьяПоГП
	--,oknaS.УникСуммаЗатратСырьяПоГП
	--,oknaS.ЗначениеЗатратыПоГП
	,Zatraty.[подразделение]
	,oknaS.[промежуточный полуфабрикат]
	--,oknaS.СуммаЗатратПоСырью
	--,oknaS.СуммаЗатратПоСырьюИID as [Сумма Затрат по ГП]
	--,oknaS.УникСуммаЗатратПоСырьюИID
	--,oknaS.ЗначениеЗатратыПоГПизВыпуска
into #ДжоинСырья 
from #ЗатратыНаВыпускПродукции_масло as Zatraty
left join #СборСырья as oknaS
	on oknaS.UniqueID_2_2 = Zatraty.UniqueID

--- проверки соответвия строчек из двух таблиц
--SELECT 
 --  план.UniqueID,
--    COUNT(зат.UniqueID_2_2) as КоличествоСтрокВЗатратах
--FROM #ЗатратыНаВыпускПродукции_масло план
--LEFT JOIN #СуммаСырья зат
---    ON план.UniqueID = зат.UniqueID_2_2
--GROUP BY план.UniqueID
--ORDER BY КоличествоСтрокВЗатратах DESC



  -- select  * from #ДжоинСырья
 --select  [промежуточный полуфабрикат] as сырье, sum([факт расхода сырья]) as [сумма расхода каждого сырья] from #ДжоинСырья group by [промежуточный полуфабрикат]

  --select count(distinct[UniqueID])  from #ДжоинСырья 
  --select count(distinct[UniqueID_2_2])  from #СуммаСырья
  --select count(distinct[UniqueID])  from #ЗатратыНаВыпускПродукции_масло
    --select count([UniqueID_2_2])  from #СуммаСырья
  --select count([UniqueID])  from #ЗатратыНаВыпускПродукции_масло
    --select count([UniqueID])  from #ДжоинСырья 

--select count([промежуточный полуфабрикат])  from #СборСырья



   ---select top 100 * from [onec-9].upp_2012.dbo._Reference51 -- виды номенклатуры
    ---select top 100 * from [onec-9].upp_2012.dbo._Reference236  -- признак доп работ
	--select top 100 * from [onec-9].upp_2012.dbo._AccumRg22689
	--select top 100 * from [onec-9].upp_2012.dbo._Reference274  --- характеристики номенклатуры названия готовой продукции



-- шаг последний джоин к накоплению выпуска продукции бух учет без декартового произведения (сто не верно, т.к. ИД продукции соотносится ко множеству ИД сырья)
--if object_id (N'tempdb..#ЗатратыНаВыпускПродукцииБухУчет') is not null drop table #ЗатратыНаВыпускПродукцииБухУчет;
--WITH ПланСНомерами AS (
--    SELECT *,
--           ROW_NUMBER() OVER (PARTITION BY [дляСцепки ИД продукции] ORDER BY (SELECT NULL)) as ПланНомер
--    FROM #выпускПродукцииМасло_1),
--ЗатратыСНомерами AS (
--    SELECT *,           ROW_NUMBER() OVER (PARTITION BY дляСцепки2 ORDER BY (SELECT NULL)) as ЗатратыНомер    FROM #ДжоинСырья)
--SELECT 
--    план.*,
--    зат.*
--into #ЗатратыНаВыпускПродукцииБухУчет
--FROM ПланСНомерами план
--FULL JOIN ЗатратыСНомерами зат 
--    ON план.[дляСцепки ИД продукции] = зат.дляСцепки2 
--    AND план.ПланНомер = зат.ЗатратыНомер


-- select top 5000 * from #ЗатратыНаВыпускПродукцииБухУчет
--where дата_0 is not null
--	order by UniqueID
--select  count(distinct[продукция]) from #ЗатратыНаВыпускПродукцииБухУчет
--77



	-- шаг последний джоин к накоплению выпуска продукции бух учет
	if object_id (N'tempdb..#ЗатратыНаВыпускПродукцииБухУчет') is not null drop table #ЗатратыНаВыпускПродукцииБухУчет;
select j.Дата_0
,j.Продукция
,j.[вид продукции]
,j.Спецификация
,j.[выпуск]
,j.[единицы измерения]
,j.[контролируется в Меркурии код]
,j.[контролируется в Меркурии]
,j.[значение свойств]
,j.[группа аналитики]
,j.[дляСцепки ИД продукции]
, j1.*
into #ЗатратыНаВыпускПродукцииБухУчет 
from #выпускПродукцииМасло_1 as j
 inner join #ДжоинСырья as j1
	on j.[дляСцепки ИД продукции]=j1.дляСцепки2
--AND [Выпуск] > 0 
where [контролируется в Меркурии код] <> 000000003
and [группа аналитики] = 'группа аналитики'
and ([значение свойств] like '%82,5%' or [значение свойств] like '%72,5%')
and [факт расхода сырья] > 0

-- select top 5000 * from #ЗатратыНаВыпускПродукцииБухУчет order by [факт расхода сырья] desc




	-- шаг последний джоин к накоплению выпуска продукции бух учет
	if object_id (N'tempdb..#НулевойФактРасходаСырья') is not null drop table #НулевойФактРасходаСырья;
select j.*, j1.*
into #НулевойФактРасходаСырья 
from #выпускПродукцииМасло_1 as j
 inner join #ДжоинСырья as j1
	on j.[дляСцепки ИД продукции]=j1.дляСцепки2
--AND [Выпуск] > 0 
where [контролируется в Меркурии код] <> 000000003
and [группа аналитики] = 'группа аналитики'
and ([значение свойств] like '%82,5%' or [значение свойств] like '%72,5%')
and [факт расхода сырья] <= 0



-- select top 5000 * from #НулевойФактРасходаСырья 

--SELECT 
--    план.[дляСцепки ИД продукции],
--    COUNT(зат.дляСцепки2) as КоличествоСтрокВЗатратах
--FROM #выпускПродукцииМасло_1 план
--LEFT JOIN #ДжоинСырья зат 
--    ON план.[дляСцепки ИД продукции] = зат.дляСцепки2
--GROUP BY план.[дляСцепки ИД продукции]
--ORDER BY КоличествоСтрокВЗатратах DESC



	-- select top 5000 * from #ЗатратыНаВыпускПродукцииБухУчет

	--order by UniqueID
--select  count(distinct[продукция]) from #ЗатратыНаВыпускПродукцииБухУчет
--77



--- шаг обработка итоговой таблицы, добавление коэф и уникальных значений затрат сырья

if object_id (N'tempdb..#ЗатратыНаВыпускПродукцииКоэфициэнты') is not null drop table #ЗатратыНаВыпускПродукцииКоэфициэнты;
select Дата_0 as Дата
	,Продукция
	,[вид продукции] as [Вид продукции]
	--,[дляСцепки ИД продукции]
	,спецификация as Спецификация
	,[контролируется в Меркурии код] as [Контролируется в Меркурии код]
	,[контролируется в Меркурии]
	,[группа аналитики] as [Группа аналитики]
	,[значение свойств] as [Значение свойств]
	,[единицы измерения] as [Единицы измерения]
	,UniqueID as [Идентификатор выпущенной продукции]
	,[Затраты]
	,[Выпуск]
	--,КоэффициентЭтапа
	,[факт расхода сырья] as [Факт расхода сырья]
	--,СуммаЗатратСырьяПоГП
	--,УникСуммаЗатратСырьяПоГП
	--,ЗначениеЗатратыПоГП
	,[документ выпуска] as [Документ выпуска сырья]
	,подразделение as [Подразделение выпуска сырья]
	,[промежуточный полуфабрикат] as [Промежуточный полуфабрикат]
	--,СуммаЗатратПоСырью
	--,[Сумма Затрат по ГП]
	--,УникСуммаЗатратПоСырьюИID
	--,ЗначениеЗатратыПоГПизВыпуска
	--,cast( [ЗначениеЗатратыПоГП] as decimal(18,5))/cast(sum([Выпуск]) as decimal(18,5)) as Коэффициент
	--,cast( sum([Выпуск]) as decimal(18,5))/cast(sum([Выпуск]) as decimal(18,5)) as Коэффициент_выпуска

into #ЗатратыНаВыпускПродукцииКоэфициэнты
from #ЗатратыНаВыпускПродукцииБухУчет
group by
	Дата_0 
	,Продукция
	,[вид продукции] 
	,спецификация 
	,Выпуск
	,[единицы измерения] 
	,UniqueID 
	,[Затраты]
	,[документ выпуска] 
	,подразделение 
	,[промежуточный полуфабрикат] 
	--,СуммаЗатратПоСырью
	--,[Сумма Затрат по ГП]
	--,КоэффициентЭтапа
	,[факт расхода сырья]
	--,УникСуммаЗатратПоСырьюИID
	--,ЗначениеЗатратыПоГПизВыпуска
	--,СуммаЗатратСырьяПоГП
	--,УникСуммаЗатратСырьяПоГП
	--,ЗначениеЗатратыПоГП
	--,[дляСцепки ИД продукции]
	,[контролируется в Меркурии код]
	,[контролируется в Меркурии]
	,[значение свойств]
	,[группа аналитики]
	
	
	
	
	-- select top 2000 * from #ЗатратыНаВыпускПродукцииКоэфициэнты


--select  [промежуточный полуфабрикат] as сырье, sum([факт расхода сырья]) as [сумма расхода каждого сырья] from #ЗатратыНаВыпускПродукцииКоэфициэнты group by [промежуточный полуфабрикат]



	--order by [Идентификатор выпущенной продукции]
	--select  count(distinct[продукция]) from #ЗатратыНаВыпускПродукцииБухУчет
--77


-- Продукты, которые есть в затратах, но нет в плане
--SELECT DISTINCT продукция FROM #ЗатратыНаВыпускПродукцииКоэфициэнты зат WHERE продукция NOT IN (SELECT [наименование ГП план] FROM #план_продаж_ГП_масло)

-- Продукты, которые есть в плане, но нет в затратах  
--SELECT DISTINCT [наименование ГП план] FROM #план_продаж_ГП_масло план WHERE [наименование ГП план] NOT IN (SELECT продукция FROM #ЗатратыНаВыпускПродукцииКоэфициэнты)




--select  count([продукция]) from #ЗатратыНаВыпускПродукцииКоэфициэнты where продукция = 'Спр.ДМ.72,5%.500г.фол.8шт'  -- 51 строка

--select  count([наименование ГП план]) from #план_продаж_ГП_масло where [наименование ГП план] = 'Спр.ДМ.72,5%.500г.фол.8шт' -- 120564 строки



	-- шаг сцепка плана и факта через уникальную нумерацию строк из плана с фактом (отменяется, т.к. план не соответствует затратам и выпуску)
--	if object_id (N'tempdb..#Сцепка_Плана_Факта') is not null drop table #Сцепка_Плана_Факта;
--WITH ПланСНомерами AS (
 --   SELECT *,           ROW_NUMBER() OVER (PARTITION BY [наименование ГП план] ORDER BY (SELECT NULL)) as ПланНомер   FROM #план_продаж_ГП_масло),
--ЗатратыСНомерами AS (    SELECT *,           ROW_NUMBER() OVER (PARTITION BY продукция ORDER BY (SELECT NULL)) as ЗатратыНомер    FROM #ЗатратыНаВыпускПродукцииКоэфициэнты)
----     план.*,    зат.*into #Сцепка_Плана_Факта
--FROM ПланСНомерами план
--FULL JOIN ЗатратыСНомерами зат     ON план.[наименование ГП план] = зат.продукция     AND план.ПланНомер = зат.ЗатратыНомер
--where [факт расхода сырья] > 0




--select top 10000 * from #Сцепка_Плана_Факта




--select  count([дата план]) from #Сцепка_Плана_Факта


--- сколько строчек из плана продаж соответствует строчкам из факта производства
--SELECT 
 --  план.[наименование ГП план],
--    COUNT(зат.продукция) as КоличествоСтрокВЗатратах
--FROM #план_продаж_ГП_масло план
--LEFT JOIN #ЗатратыНаВыпускПродукцииКоэфициэнты зат 
--    ON план.[наименование ГП план] = зат.продукция
--GROUP BY план.[наименование ГП план]
--ORDER BY КоличествоСтрокВЗатратах DESC


-----шаг итоговый создание таблицы в базе данных

--delete  from [Мониторинг].[dbo].[План-факт расхода сырья _ГП_масло];
--insert into [Мониторинг].[dbo].[План-факт расхода сырья _ГП_масло]
--select * from #ЗатратыНаВыпускПродукцииКоэфициэнты

--delete  from [Мониторинг].[dbo].[План-факт продаж _ГП_масло для сырья];
--insert into [Мониторинг].[dbo].[План-факт продаж _ГП_масло для сырья]
--select * from #план_продаж_ГП_масло_1


--- добавляем условие вывода за прошлый месяц
--where дата=case when month(getdate())=1 then datefromparts(year(getdate())-1,12,1)  else
--datefromparts(year(getdate()), month(getdate())-1,1) end
--order by дата desc

--drop table [Мониторинг].[dbo].[План-факт расхода сырья _ГП_масло]
--Временно закомментируйте DELETE и INSERT и раскомментируйте эту строку:
--SELECT * 
--INTO [Мониторинг].[dbo].[План-факт расхода сырья _ГП_масло]
--FROM #ЗатратыНаВыпускПродукцииКоэфициэнты


--drop table [Мониторинг].[dbo].[План-факт продаж _ГП_масло для сырья]
--SELECT * 
--INTO [Мониторинг].[dbo].[План-факт продаж _ГП_масло для сырья]
--FROM #план_продаж_ГП_масло_1


--------НАСТРОЙКА СОХРАНЕНИЯ ТАБЛИЦ ЗА КАЖДЫЙ МЕСЯЦ


-- Добавляем недостающие столбцы в первую таблицу
--ALTER TABLE [Мониторинг].[dbo].[План-факт расхода сырья _ГП_масло_ОСНОВНАЯ]
--ADD 
--    Дата_загрузки DATETIME,
--    Месяц_данных DATE,
--    Источник NVARCHAR(255);

-- Добавляем недостающие столбцы во вторую таблицу
--ALTER TABLE [Мониторинг].[dbo].[План-факт продаж _ГП_масло для сырья_ОСНОВНАЯ]
--ADD 
--    Дата_загрузки DATETIME,
--    Месяц_данных DATE,
--    Источник2 NVARCHAR(255);


-----------создание таблиц

--DROP TABLE IF EXISTS [Мониторинг].[dbo].[План-факт расхода сырья _ГП_масло_ОСНОВНАЯ];
--DROP TABLE IF EXISTS [Мониторинг].[dbo].[План-факт продаж _ГП_масло для сырья_ОСНОВНАЯ];


--CREATE TABLE [Мониторинг].[dbo].[План-факт расхода сырья _ГП_масло_ОСНОВНАЯ] (
--    Дата DATE,
--    Продукция NVARCHAR(255),
--    [Вид продукции] NVARCHAR(255),
--    Спецификация NVARCHAR(255),
--    [Контролируется в Меркурии код] NVARCHAR(255),
--    [контролируется в Меркурии] NVARCHAR(255),
--    [Группа аналитики] NVARCHAR(255),
--    [Значение свойств] NVARCHAR(255),
--    [Единицы измерения] NVARCHAR(255),
--    [Идентификатор выпущенной продукции] VARBINARY(255),
--    Затраты DECIMAL(18,5),
--    Выпуск DECIMAL(18,5),
--    [Факт расхода сырья] DECIMAL(18,5),
--    [Документ выпуска сырья] NVARCHAR(255),
--    [Подразделение выпуска сырья] NVARCHAR(255),
--    [Промежуточный полуфабрикат] NVARCHAR(255),
--    Дата_загрузки DATETIME,
--    Месяц_данных DATE,
--    Источник NVARCHAR(255)
--);

---- Создаем вторую таблицу с правильной структурой
--CREATE TABLE [Мониторинг].[dbo].[План-факт продаж _ГП_масло для сырья_ОСНОВНАЯ] (
--    [Дата план] DATE,
--    [контрагент] NVARCHAR(255),
--    артикул NVARCHAR(255),
--    [наименование ГП план] NVARCHAR(255),
--    [количество план] DECIMAL(18,5),
--    [расход по Меркурию] DECIMAL(18,5),
--    сумм_кг_План_по_ГП DECIMAL(18,5),
--    [Плановый расход 72] DECIMAL(18,5),
--    [Плановый расход 82] DECIMAL(18,5),
--    Дата_загрузки DATETIME,
--    Месяц_данных DATE,
--    Источник2 NVARCHAR(255)
--);

--BEGIN TRANSACTION

---- Вставляем данные в первую таблицу
--INSERT INTO [Мониторинг].[dbo].[План-факт расхода сырья _ГП_масло_ОСНОВНАЯ] (
--    Дата, Продукция, [Вид продукции], Спецификация, [Контролируется в Меркурии код], 
--    [контролируется в Меркурии], [Группа аналитики], [Значение свойств], [Единицы измерения],
--    [Идентификатор выпущенной продукции], Затраты, Выпуск, [Факт расхода сырья], 
--    [Документ выпуска сырья], [Подразделение выпуска сырья], [Промежуточный полуфабрикат],
--    Дата_загрузки, Месяц_данных, Источник
--)
--SELECT 
--    Дата, Продукция, [Вид продукции], Спецификация, [Контролируется в Меркурии код],
--    [контролируется в Меркурии], [Группа аналитики], [Значение свойств], [Единицы измерения],
--    [Идентификатор выпущенной продукции], Затраты, Выпуск, [Факт расхода сырья],
--    [Документ выпуска сырья], [Подразделение выпуска сырья], [Промежуточный полуфабрикат],
--    GETDATE() as Дата_загрузки,
--    DATEFROMPARTS(YEAR(GETDATE()), MONTH(GETDATE()), 1) as Месяц_данных,
--    'Ежемесячная выгрузка' as Источник
--FROM #ЗатратыНаВыпускПродукцииКоэфициэнты;

---- Вставляем данные во вторую таблицу
--INSERT INTO [Мониторинг].[dbo].[План-факт продаж _ГП_масло для сырья_ОСНОВНАЯ] (
--    [Дата план], [контрагент], артикул, [наименование ГП план], [количество план],
--    [расход по Меркурию], сумм_кг_План_по_ГП, [Плановый расход 72], [Плановый расход 82],
--    Дата_загрузки, Месяц_данных, Источник2
--)
--SELECT 
--    [Дата план], [контрагент], артикул, [наименование ГП план], [количество план],
--    [расход по Меркурию], сумм_кг_План_по_ГП, [Плановый расход 72], [Плановый расход 82],
--    GETDATE() as Дата_загрузки,
--    DATEFROMPARTS(YEAR(GETDATE()), MONTH(GETDATE()), 1) as Месяц_данных,
--    'Ежемесячная выгрузка' as Источник2
--FROM #план_продаж_ГП_масло_1;

--COMMIT TRANSACTION



----------Для следующих запусков - обновление данных за текущий месяц

BEGIN TRANSACTION

-- Удаляем данные за текущий месяц
DELETE FROM [Мониторинг].[dbo].[План-факт расхода сырья _ГП_масло_ОСНОВНАЯ]
WHERE Месяц_данных = DATEFROMPARTS(YEAR(GETDATE()), MONTH(GETDATE()), 1);

DELETE FROM [Мониторинг].[dbo].[План-факт продаж _ГП_масло для сырья_ОСНОВНАЯ]
WHERE Месяц_данных = DATEFROMPARTS(YEAR(GETDATE()), MONTH(GETDATE()), 1);

-- Добавляем новые данные за текущий месяц
INSERT INTO [Мониторинг].[dbo].[План-факт расхода сырья _ГП_масло_ОСНОВНАЯ] (
    Дата, Продукция, [Вид продукции], Спецификация, [Контролируется в Меркурии код], 
    [контролируется в Меркурии], [Группа аналитики], [Значение свойств], [Единицы измерения],
    [Идентификатор выпущенной продукции], Затраты, Выпуск, [Факт расхода сырья], 
    [Документ выпуска сырья], [Подразделение выпуска сырья], [Промежуточный полуфабрикат],
    Дата_загрузки, Месяц_данных, Источник
)
SELECT 
    Дата, Продукция, [Вид продукции], Спецификация, [Контролируется в Меркурии код],
    [контролируется в Меркурии], [Группа аналитики], [Значение свойств], [Единицы измерения],
    [Идентификатор выпущенной продукции], Затраты, Выпуск, [Факт расхода сырья],
    [Документ выпуска сырья], [Подразделение выпуска сырья], [Промежуточный полуфабрикат],
    GETDATE() as Дата_загрузки,
    DATEFROMPARTS(YEAR(GETDATE()), MONTH(GETDATE()), 1) as Месяц_данных,
    'Ежемесячная выгрузка' as Источник
FROM #ЗатратыНаВыпускПродукцииКоэфициэнты;

INSERT INTO [Мониторинг].[dbo].[План-факт продаж _ГП_масло для сырья_ОСНОВНАЯ] (
    [Дата план], [контрагент], артикул, [наименование ГП план], [количество план],
    [расход по Меркурию], сумм_кг_План_по_ГП, [Плановый расход 72], [Плановый расход 82],
    Дата_загрузки, Месяц_данных, Источник2
)
SELECT 
    [Дата план], [контрагент], артикул, [наименование ГП план], [количество план],
    [расход по Меркурию], сумм_кг_План_по_ГП, [Плановый расход 72], [Плановый расход 82],
    GETDATE() as Дата_загрузки,
    DATEFROMPARTS(YEAR(GETDATE()), MONTH(GETDATE()), 1) as Месяц_данных,
    'Ежемесячная выгрузка' as Источник2
FROM #план_продаж_ГП_масло_1;

COMMIT TRANSACTION

end



