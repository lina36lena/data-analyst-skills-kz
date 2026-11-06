-- Упоминания навыков по группам опыта в основной выборке.
-- Группа определяется по experience_card, а не по названию Junior/Middle/Senior.
-- Для каждого навыка знаменатель — число вакансий внутри соответствующей группы.
-- Учитываются разделы required_skills и preferred_skills, включая альтернативы.
-- Инструменты только из обязанностей сохранены в notes и сюда не включены.
-- Малая целевая выборка: результаты описывают собранные объявления.

WITH vacancies_in_scope AS (
    SELECT
        CASE
            WHEN experience_card = 'Без опыта' THEN 'Без опыта'
            WHEN experience_card IN ('1–3 года', '3–6 лет', 'Более 6 лет') THEN 'С опытом'
            ELSE 'Не указан'
        END AS experience_cohort,
        required_skills,
        preferred_skills
    FROM analyst_project.vacancies
    WHERE selection_status = 'Да'
), skill_dictionary (sort_order, skill, pattern) AS (
    VALUES
        (1, 'SQL', '\m(sql|postgresql|mysql|mssql)\M'),
        (2, 'Python', '\mpython\M'),
        (3, 'Excel', '\mexcel\M'),
        (4, 'Power BI', '\mpower[[:space:]]*bi\M')
), matched AS (
    SELECT
        v.experience_cohort,
        d.sort_order,
        d.skill,
        COALESCE(v.required_skills ~* d.pattern, FALSE) AS required_mention,
        COALESCE(v.preferred_skills ~* d.pattern, FALSE) AS preferred_mention
    FROM vacancies_in_scope AS v
    CROSS JOIN skill_dictionary AS d
)
SELECT
    experience_cohort,
    skill,
    COUNT(*) AS total_vacancies,
    SUM(CASE WHEN required_mention THEN 1 ELSE 0 END) AS required_mentions,
    SUM(CASE WHEN preferred_mention THEN 1 ELSE 0 END) AS preferred_mentions,
    SUM(CASE WHEN required_mention OR preferred_mention THEN 1 ELSE 0 END) AS any_mentions,
    ROUND(100.0 * AVG(CASE WHEN required_mention THEN 1 ELSE 0 END), 1) AS required_pct,
    ROUND(100.0 * AVG(CASE WHEN preferred_mention THEN 1 ELSE 0 END), 1) AS preferred_pct,
    ROUND(100.0 * AVG(CASE WHEN required_mention OR preferred_mention THEN 1 ELSE 0 END), 1) AS any_pct
FROM matched
GROUP BY experience_cohort, sort_order, skill
ORDER BY
    CASE experience_cohort WHEN 'Без опыта' THEN 0 WHEN 'С опытом' THEN 1 ELSE 2 END,
    sort_order;
