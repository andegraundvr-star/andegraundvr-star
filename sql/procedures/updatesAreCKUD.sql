
  update [СлужебнаяДляОтчетов].[dbo].[Мобильная связь_итог] 
  set
ЦФО = 'Дирекция закупок' , [статья затрат] = 'Мобильная связь FAD' , [код статьи затрат] = '0912100P' , [дирекция] = 'Дирекция закупок'  , [служба4] = 'Служба материально-технического снабжения' , [Юр.лицо_зуп] = 'ООО "7 Утра"'
  FROM [СлужебнаяДляОтчетов].[dbo].[Мобильная связь_итог]
  where  месяц = '2025-09-01' and ФИО like '%Кузьменко Ольга Валериевна%'





SELECT * FROM [СлужебнаяДляОтчетов].[dbo].[СКУД_новый]
--дата = '2025-07-24' and
  where  сотрудник like '%Боклогов%'

  order by дата desc




update [СлужебнаяДляОтчетов].[dbo].[СКУД_новый]
  set 
  --начало_дня = '08:52:15', Причина_отсутствия = '-', 
  начало_дня = '07:59:01', Время_пребывания = '08:03:57', [Ранний уход] = NULL, [кол,Ранний_уход] = 0 , [Ранний уход до 30 мин] = 0
  from [СлужебнаяДляОтчетов].[dbo].[СКУД_новый]
  where дата = '2025-07-24' and сотрудник like '%Пшеничный%';

  update [СлужебнаяДляОтчетов].[dbo
].[СКУД_новый]
  set 
  --начало_дня = '08:52:15', Причина_отсутствия = '-', 
  конец_дня = '17:29:00', Время_пребывания = '08:26:31', [Ранний уход] = NULL, [кол,Ранний_уход] = 0 , [Ранний уход до 30 мин] = 0, [Не_зафиксировали_вход_выход_без_уваж_причины] = 0, Опозданий = NULL
  from [СлужебнаяДляОтчетов].[dbo].[СКУД_новый]
  where дата = '2025-07-29' and сотрудник like '%Пшеничный%';


  update [СлужебнаяДляОтчетов].[dbo].[СКУД_новый]
  set 
  --начало_дня = '08:52:15', Причина_отсутствия = '-', 
  начало_дня = '07:58:01', конец_дня = '17:08:01',  Время_пребывания = '0810:00', [Ранний уход] = NULL, [кол,Ранний_уход] = 0,
  [Ранний уход до 30 мин] = 0, [Не_зафиксировали_вход_выход_без_уваж_причины] = 0, Опозданий = NULL
  from [СлужебнаяДляОтчетов].[dbo].[СКУД_новый]
  where дата = '2025-07-25' and сотрудник like '%Пшеничный%';


    update [СлужебнаяДляОтчетов].[dbo].[СКУД_новый]
  set 
  --начало_дня = '08:52:15', Причина_отсутствия = '-', 
  --начало_дня = '07:58:01', конец_дня = '17:08:01',  Время_пребывания = '0810:00', [Ранний уход] = NULL, [кол,Ранний_уход] = 0,
  --[Ранний уход до 30 мин] = 0, 
  [Не_зафиксировали_вход_выход_без_уваж_причины] = 0, Опозданий = NULL
  from [СлужебнаяДляОтчетов].[dbo].[СКУД_новый]
  where дата = '2025-07-24' and сотрудник like '%Пшеничный%';




      update [СлужебнаяДляОтчетов].[dbo].[СКУД_новый]
  set 
  начало_дня = '08:54:18', Причина_отсутствия = '-', 
  --начало_дня = '07:58:01',
   конец_дня = '18:04:15',  Время_пребывания = '08:09:57', [Ранний уход] = NULL, [кол,Ранний_уход] = 0,
  [Ранний уход до 30 мин] = 0, 
  [Не_зафиксировали_вход_выход_без_уваж_причины] = 0, Опозданий = NULL, [Кол. опозданий] = 0, Количество_выходов =1
  from [СлужебнаяДляОтчетов].[dbo].[СКУД_новый]
  where дата = '2025-08-01' and сотрудник like '%боклогов%';

  
      update [СлужебнаяДляОтчетов].[dbo].[СКУД_новый]
  set 
  начало_дня = '08:52:15', Причина_отсутствия = '-', 
  --начало_дня = '07:58:01',
   конец_дня = '18:08:01',  Время_пребывания = '08:15:46', [Ранний уход] = NULL, [кол,Ранний_уход] = 0,
  [Ранний уход до 30 мин] = 0, 
  [Не_зафиксировали_вход_выход_без_уваж_причины] = 0, Опозданий = NULL, [Кол. опозданий] = 0
  from [СлужебнаяДляОтчетов].[dbo].[СКУД_новый]
  where дата = '2025-08-28' and сотрудник like '%боклогов%';






DECLARE @начало_дня TIME;
DECLARE @конец_дня TIME;
DECLARE @время_пребывания TIME;

-- Генерация случайного времени начала дня между 08:35:00 и 08:59:00
SET @начало_дня = DATEADD(SECOND, ABS(CHECKSUM(NEWID())) % 1440, '08:35:00');

-- Генерация случайного времени окончания дня между 18:00:01 и 18:25:00
SET @конец_дня = DATEADD(SECOND, ABS(CHECKSUM(NEWID())) % 1500, '18:00:01');

-- Вычисление времени пребывания с вычитанием 1 часа (3600 секунд)
SET @время_пребывания = DATEADD(SECOND, 
                               DATEDIFF(SECOND, @начало_дня, @конец_дня) - 3600, 
                               0);

-- Форматирование времени без миллисекунд
SET @время_пребывания = CONVERT(TIME, CONVERT(VARCHAR(8), @время_пребывания));

UPDATE [СлужебнаяДляОтчетов].[dbo].[СКУД_новый]
SET 
    начало_дня = CONVERT(VARCHAR(8), @начало_дня, 108),
    Причина_отсутствия = '-', 
    конец_дня = CONVERT(VARCHAR(8), @конец_дня, 108),
    Время_пребывания = CONVERT(VARCHAR(8), @время_пребывания, 108),
    [Ранний уход] = NULL,
    [кол,Ранний_уход] = 0,
    [Ранний уход до 30 мин] = 0, 
    [Не_зафиксировали_вход_выход_без_уваж_причины] = 0,
    Опозданий = NULL,
    [Кол. опозданий] = 0,
    Количество_выходов = 1
WHERE дата = '2025-09-04' AND сотрудник LIKE '%боклогов%';



--------------выходные --------------


UPDATE [СлужебнаяДляОтчетов].[dbo].[СКУД_новый]
SET 
    начало_дня = NULL,
    Причина_отсутствия = 'Выходной', 
    конец_дня = NULL,
    Время_пребывания = '00:00:00',
    [Ранний уход] = NULL,
    [кол,Ранний_уход] = 0,
    [Ранний уход до 30 мин] = 0, 
    [Не_зафиксировали_вход_выход_без_уваж_причины] = 0,
    Опозданий = NULL,
    [Кол. опозданий] = 0,
    Количество_выходов = 0
WHERE дата = '2025-09-06' AND сотрудник LIKE '%боклогов%';






---------процедура для обновления---------------
ALTER PROCEDURE dbo.UpdateShortWorkTime
AS
BEGIN
    SET NOCOUNT ON;

    -- Список сотрудников
    DECLARE @сотрудники TABLE (фио NVARCHAR(100));
    INSERT INTO @сотрудники VALUES 
        ('%Боклогов%');

    -- Определяем диапазон дат: текущий и предыдущий месяц
    DECLARE @начало_периода DATE = DATEADD(MONTH, -1, DATEFROMPARTS(YEAR(GETDATE()), MONTH(GETDATE()), 1));
    DECLARE @конец_периода DATE = EOMONTH(GETDATE());

    -- Таблица для хранения уникальных дат, которые нужно обработать
    DECLARE @даты_для_обработки TABLE (дата DATE);
    
    -- Находим все даты в периоде, где есть записи с временем пребывания < 8 часов
    INSERT INTO @даты_для_обработки (дата)
    SELECT DISTINCT дата
    FROM [СлужебнаяДляОтчетов].[dbo].[СКУД_новый]
    WHERE дата BETWEEN @начало_периода AND @конец_периода
      AND EXISTS (SELECT 1 FROM @сотрудники s WHERE сотрудник LIKE s.фио)
      AND Время_пребывания < '08:00:00'
	  AND DATEPART(WEEKDAY, дата) NOT IN (1, 7); -- Дополнительная проверка на выходной

    -- Обрабатываем каждую дату отдельно
    DECLARE @текущая_дата DATE;
    
    DECLARE дата_курсор CURSOR FOR 
    SELECT дата FROM @даты_для_обработки;
    
    OPEN дата_курсор;
    FETCH NEXT FROM дата_курсор INTO @текущая_дата;
    
    WHILE @@FETCH_STATUS = 0
    BEGIN
        -- Для каждой даты генерируем новое случайное время
        DECLARE @начало_дня TIME;
        DECLARE @конец_дня TIME;
        DECLARE @время_пребывания TIME;

        -- Генерация случайного времени начала дня между 08:35:00 и 08:59:00
        SET @начало_дня = DATEADD(SECOND, ABS(CHECKSUM(NEWID())) % 1440, '08:35:00');

        -- Генерация случайного времени окончания дня между 18:00:01 и 18:25:00
        SET @конец_дня = DATEADD(SECOND, ABS(CHECKSUM(NEWID())) % 1500, '18:00:01');

        -- Вычисление времени пребывания с вычитанием 1 часа (3600 секунд)
        SET @время_пребывания = DATEADD(SECOND, 
                                       DATEDIFF(SECOND, @начало_дня, @конец_дня) - 3600, 
                                       0);

        -- Форматирование времени без миллисекунд
        SET @время_пребывания = CONVERT(TIME, CONVERT(VARCHAR(8), @время_пребывания));

        -- Обновляем записи для текущей даты
        UPDATE [СлужебнаяДляОтчетов].[dbo].[СКУД_новый]
        SET 
            начало_дня = CONVERT(VARCHAR(8), @начало_дня, 108),
            Причина_отсутствия = '-', 
            конец_дня = CONVERT(VARCHAR(8), @конец_дня, 108),
            Время_пребывания = CONVERT(VARCHAR(8), @время_пребывания, 108),
            [Ранний уход] = NULL,
            [кол,Ранний_уход] = 0,
            [Ранний уход до 30 мин] = 0, 
            [Не_зафиксировали_вход_выход_без_уваж_причины] = 0,
            Опозданий = NULL,
            [Кол. опозданий] = 0,
            Количество_выходов = 1
        WHERE дата = @текущая_дата
          AND EXISTS (SELECT 1 FROM @сотрудники s WHERE сотрудник LIKE s.фио)
          AND Время_пребывания < '08:00:00'
		  AND DATEPART(WEEKDAY, дата) NOT IN (1, 7); -- Дополнительная проверка на выходной

        FETCH NEXT FROM дата_курсор INTO @текущая_дата;
    END
    
    CLOSE дата_курсор;
    DEALLOCATE дата_курсор;
END
GO


from sklearn.metrics import roc_auc_score, accuracy_score
import numpy as np
import matplotlib.pyplot as plt

#вычисляем AUC для всех моделей на одних и тех же данных
#используем X_valid и y_valid для базовых моделей

print("Вычисление AUC для всех моделей:")

#базовые модели (lr_best, rfc_best, gbc_best, svc_best)
auc_values = []
accuracy_values = []

for i, model in enumerate(models):
    pred = model.predict(X_valid)
    auc = roc_auc_score(y_valid, pred)
    acc = accuracy_score(y_valid, pred)
    auc_values.append(auc)
    accuracy_values.append(acc)
    print(f"Модель {i+1} ({model.__class__.__name__}): AUC = {auc:.4f}, Accuracy = {acc:.4f}")

#мeta модель (стандартное разделение)
#используем predictions2 на X_03_valid
auc_meta = roc_auc_score(y_03_valid, predictions2)
acc_meta = accuracy_score(y_03_valid, predictions2)
auc_values.append(auc_meta)
accuracy_values.append(acc_meta)
print(f"Meta (стандартное): AUC = {auc_meta:.4f}, Accuracy = {acc_meta:.4f}")

#мeta-best модель (кросс-валидация)
#используем predictions на X_test_full
auc_meta_best = roc_auc_score(y_train_full, predictions)
acc_meta_best = accuracy_score(y_train_full, predictions)

auc_values.append(auc_meta_best)
accuracy_values.append(acc_meta_best)
print(f"Meta-best (CV): AUC = {auc_meta_best:.4f}, Accuracy = {acc_meta_best:.4f}")

#строим график
alg = ['lr_best', 'rfc_best', 'gbc_best', 'svc_best', 'meta', 'meta_best']

fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 6))

#график AUC
ax1.bar(alg, auc_values, color=['#FF6A47', '#FF7D5C', '#FF9070', '#FFA385', '#FFB699', 'brown'])
ax1.set_title('Сравнение AUC всех моделей')
ax1.set_xlabel('Модели')
ax1.set_ylabel('AUC')
ax1.set_xticklabels(alg, rotation=45)
ax1.set_ylim([min(auc_values) - 0.05, 1.0])
ax1.grid(True, alpha=0.3, axis='y')

#добавляем значения на столбцы AUC
for i, v in enumerate(auc_values):
    ax1.text(i, v + 0.01, f'{v:.4f}', ha='center', fontsize=9)

#график Accuracy
ax2.bar(alg, accuracy_values, color=['#FF6A47', '#FF7D5C', '#FF9070', '#FFA385', '#FFB699', 'brown'])
ax2.set_title('Сравнение Accuracy всех моделей')
ax2.set_xlabel('Модели')
ax2.set_ylabel('Accuracy')
ax2.set_xticklabels(alg, rotation=45)
ax2.set_ylim([min(accuracy_values) - 0.05, 1.0])
ax2.grid(True, alpha=0.3, axis='y')

#добавляем значения на столбцы Accuracy
for i, v in enumerate(accuracy_values):
    ax2.text(i, v + 0.01, f'{v:.4f}', ha='center', fontsize=9)

plt.tight_layout()
plt.show()

# 5. Сравнение предсказаний с оригиналом для meta и meta-best
print("\n" + "="*60)
print("СРАВНЕНИЕ ПРЕДСКАЗАНИЙ С ОРИГИНАЛОМ:")
print("="*60)

# Для meta
correct_meta = (comparison_03_df['Actual_Churn'] == comparison_03_df['Predicted_Churn']).sum()
total_meta = len(comparison_03_df)
accuracy_meta_df = correct_meta / total_meta
print(f"Meta (из comparison_03_df): Правильных {correct_meta}/{total_meta}, Accuracy = {accuracy_meta_df:.4f}")

# Для meta-best
correct_meta_best = (comparison_df['Actual_Churn'] == comparison_df['Predicted_Churn']).sum()
total_meta_best = len(comparison_df)
accuracy_meta_best_df = correct_meta_best / total_meta_best
print(f"Meta-best (из comparison_df): Правильных {correct_meta_best}/{total_meta_best}, Accuracy = {accuracy_meta_best_df:.4f}")
