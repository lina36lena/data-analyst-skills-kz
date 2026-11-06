-- Частоты упоминаний навыков в требованиях вакансий Казахстана.
-- Срез на 2026-11-06. Включены записи с selection_status = 'Да'.
-- Анализируются required_skills и preferred_skills, включая альтернативы.
-- Инструменты, указанные только в обязанностях, сохранены в notes и сюда не включены.
-- Одна вакансия учитывается один раз по каждому навыку и разделу.
-- any_mentions объединяет разделы без повторного счёта одной вакансии.
-- SQL включает явные названия SQL, PostgreSQL, MySQL и MSSQL; NoSQL не включается.
-- Проценты округлены до одного знака после запятой.

WITH skill_dictionary (sort_order, skill, pattern) AS (
    VALUES
        (1, 'SQL', '\m(sql|postgresql|mysql|mssql)\M'),
        (2, 'Python', '\mpython\M'),
        (3, 'Excel', '\mexcel\M'),
        (4, 'Power BI', '\mpower[[:space:]]*bi\M'),
        (5, 'Tableau', '\mtableau\M'),
        (6, 'Looker', '\mlooker\M'),
        (7, 'DataLens', '\mdata[[:space:]]*lens\M'),
        (8, 'Qlik Sense', '\mqlik[[:space:]]*sense\M'),
        (9, 'Superset', '\msuperset\M')
), matched AS (
    SELECT
        d.sort_order,
        d.skill,
        v.source_row,
        v.title,
        v.company,
        v.required_skills,
        v.preferred_skills,
        COALESCE(v.required_skills ~* d.pattern, FALSE) AS required_mention,
        COALESCE(v.preferred_skills ~* d.pattern, FALSE) AS preferred_mention
    FROM analyst_project.vacancies AS v
    CROSS JOIN skill_dictionary AS d
    WHERE v.selection_status = 'Да'
)
SELECT
    skill,
    COUNT(*) AS total_vacancies,
    SUM(CASE WHEN required_mention THEN 1 ELSE 0 END) AS required_mentions,
    SUM(CASE WHEN preferred_mention THEN 1 ELSE 0 END) AS preferred_mentions,
    SUM(CASE WHEN required_mention OR preferred_mention THEN 1 ELSE 0 END) AS any_mentions,
    ROUND(100.0 * AVG(
        CASE WHEN required_mention THEN 1 ELSE 0 END
    ), 1) AS required_pct,
    ROUND(100.0 * AVG(
        CASE WHEN preferred_mention THEN 1 ELSE 0 END
    ), 1) AS preferred_pct,
    ROUND(100.0 * AVG(
        CASE WHEN required_mention OR preferred_mention THEN 1 ELSE 0 END
    ), 1) AS any_pct
FROM matched
GROUP BY sort_order, skill
ORDER BY any_mentions DESC, required_mentions DESC, skill;
