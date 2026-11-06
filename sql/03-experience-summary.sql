-- Распределение основной выборки по опыту, указанному в карточке вакансии.
-- Срез на 2026-11-06. experience_card соответствует столбцу F исходной таблицы.
-- experience_description хранит требования из описания; они могут отличаться.
-- Диапазон опыта в карточке не определяет название уровня Junior/Middle/Senior.

SELECT
    experience_card,
    COUNT(*) AS vacancy_count
FROM analyst_project.vacancies
WHERE selection_status = 'Да'
GROUP BY experience_card
ORDER BY vacancy_count DESC, experience_card;
