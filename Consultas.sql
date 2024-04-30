#1. Desplegar para cada elección el país y el partido político que obtuvo mayor
#porcentaje de votos en su país. Debe desplegar el nombre de la elección, el
#año de la elección, el país, el nombre del partido político y el porcentaje que
#obtuvo de votos en su país.

SELECT 
	E.NOMBRE_ELECCION
    ,E.AÑO
    ,PA.NOMBRE 'NOMBRE PAIS'
    ,PP.NOMBRE_PARTIDO
    ,(SUM(V.VOTOS_OBTENIDOS)/(SELECT SUM(VOTOS_OBTENIDOS) FROM votacion))* 100  'VOTOS' 
FROM votacion V 
	INNER JOIN eleccion E ON V.ID_ELECCION = E.ID_ELECCION
    INNER JOIN poblacion P ON P.ID_POBLACION = V.ID_POBLACION
    INNER JOIN partido_politico PP ON PP.ID_PARTIDO = V.ID_PARTIDO
    INNER JOIN municipio M ON M.ID_MUNICIPIO = E.ID_MUNICIPIO 
    INNER JOIN departamento D ON D.ID_DEPARTAMENTO = M.ID_DEPARTAMENTO
    INNER JOIN region R ON R.ID_REGION = D.ID_REGION
    INNER JOIN pais PA ON PA.ID_PAIS = R.ID_PAIS
GROUP BY E.NOMBRE_ELECCION
    ,E.AÑO
    ,PA.NOMBRE 
    ,PP.NOMBRE_PARTIDO
ORDER BY 2,3;



#2. Desplegar total de votos y porcentaje de votos de mujeres por departamento
#y país. El ciento por ciento es el total de votos de mujeres por país. (Tip:
#Todos los porcentajes por departamento de un país deben sumar el 100%)
CREATE TEMPORARY TABLE TEMPVOTOS
SELECT 
	P.SEXO
    ,PA.NOMBRE 'PAIS'
    ,SUM(P.ALFABETOS + P.ANALFABETOS) 'VOTOS'
FROM votacion V 
	INNER JOIN eleccion E ON V.ID_ELECCION = E.ID_ELECCION
    INNER JOIN poblacion P ON P.ID_POBLACION = V.ID_POBLACION
    INNER JOIN municipio M ON M.ID_MUNICIPIO = E.ID_MUNICIPIO 
    INNER JOIN departamento D ON D.ID_DEPARTAMENTO = M.ID_DEPARTAMENTO
    INNER JOIN region R ON R.ID_REGION = D.ID_REGION
    INNER JOIN pais PA ON PA.ID_PAIS = R.ID_PAIS
WHERE P.SEXO = 'mujeres'
GROUP BY P.SEXO
    ,PA.NOMBRE;

SELECT 
	P.SEXO
    ,D.NOMBRE 'DEPARTAMENTO'
    ,SUM(P.ALFABETOS + ANALFABETOS) 'VOTOS POR DEPARTAMENTO'
    ,(SUM(P.ALFABETOS + ANALFABETOS)/T.VOTOS) * 100 'PORCENTAJE'
    ,T.PAIS 'PAIS'
    ,T.VOTOS 
FROM votacion V 
	INNER JOIN eleccion E ON V.ID_ELECCION = E.ID_ELECCION
    INNER JOIN poblacion P ON P.ID_POBLACION = V.ID_POBLACION
    INNER JOIN municipio M ON M.ID_MUNICIPIO = E.ID_MUNICIPIO 
    INNER JOIN departamento D ON D.ID_DEPARTAMENTO = M.ID_DEPARTAMENTO
    INNER JOIN region R ON R.ID_REGION = D.ID_REGION
    INNER JOIN pais PA ON PA.ID_PAIS = R.ID_PAIS
    INNER JOIN TEMPVOTOS T ON T.PAIS = PA.NOMBRE
WHERE P.SEXO = 'mujeres'
GROUP BY P.SEXO
    ,D.NOMBRE
	,T.PAIS
    ,T.VOTOS;
    
DROP TABLE TEMPVOTOS;

# 3. Desplegar el nombre del país, nombre del partido político y número de
#alcaldías de los partidos políticos que ganaron más alcaldías por país.}}

SELECT 
	pa.NOMBRE 'pais'
    ,pp.NOMBRE_PARTIDO 
    ,count(E.ID_ELECCION) 'ALCALDIAS'
FROM votacion V 
	INNER JOIN eleccion E ON V.ID_ELECCION = E.ID_ELECCION
    INNER JOIN poblacion P ON P.ID_POBLACION = V.ID_POBLACION
    INNER JOIN partido_politico PP ON PP.ID_PARTIDO = V.ID_PARTIDO
    INNER JOIN municipio M ON M.ID_MUNICIPIO = E.ID_MUNICIPIO 
    INNER JOIN departamento D ON D.ID_DEPARTAMENTO = M.ID_DEPARTAMENTO
    INNER JOIN region R ON R.ID_REGION = D.ID_REGION
    INNER JOIN pais PA ON PA.ID_PAIS = R.ID_PAIS
GROUP BY pa.NOMBRE 
    ,pp.NOMBRE_PARTIDO 
ORDER BY 1,2;
    
# 4. Desplegar todas las regiones por país en las que predomina la raza indígena.
#Es decir, hay más votos que las otras razas

SELECT 
	pa.NOMBRE 'pais'
    ,pp.NOMBRE_PARTIDO 
    ,count(E.ID_ELECCION) 'ALCALDIAS'
FROM votacion V 
	INNER JOIN eleccion E ON V.ID_ELECCION = E.ID_ELECCION
    INNER JOIN poblacion P ON P.ID_POBLACION = V.ID_POBLACION
    INNER JOIN partido_politico PP ON PP.ID_PARTIDO = V.ID_PARTIDO
    INNER JOIN municipio M ON M.ID_MUNICIPIO = E.ID_MUNICIPIO 
    INNER JOIN departamento D ON D.ID_DEPARTAMENTO = M.ID_DEPARTAMENTO
    INNER JOIN region R ON R.ID_REGION = D.ID_REGION
    INNER JOIN pais PA ON PA.ID_PAIS = R.ID_PAIS
GROUP BY pa.NOMBRE 
    ,pp.NOMBRE_PARTIDO 
ORDER BY 1,2;

#5. Desplegar el porcentaje de mujeres universitarias y hombres universitarios
#que votaron por departamento, donde las mujeres universitarias que votaron
#fueron más que los hombres universitarios que votaron.

WITH votos_universitarios AS (
    SELECT
        d.NOMBRE AS Departamento,
        p.SEXO AS Sexo,
        COUNT(*) AS Votos_Universitarios
    FROM DEPARTAMENTO d
    JOIN MUNICIPIO m ON d.ID_DEPARTAMENTO = m.ID_DEPARTAMENTO
    JOIN ELECCION e ON m.ID_MUNICIPIO = e.ID_MUNICIPIO
    JOIN VOTACION v ON e.ID_ELECCION = v.ID_ELECCION
    JOIN POBLACION p ON v.ID_POBLACION = p.ID_POBLACION
    GROUP BY d.NOMBRE, p.SEXO
)


SELECT
    Departamento,
    Sexo,
    Votos_Universitarios,
    ROUND(((Votos_Universitarios_Mujeres - Votos_Universitarios_Hombres) / Votos_Universitarios_Totales) * 100, 2) AS Porcentaje_Diferencia
FROM votos_universitarios vu
CROSS JOIN (
    SELECT
        Departamento as depto,
        SUM(Votos_Universitarios) AS Votos_Universitarios_Totales,
        SUM(CASE WHEN Sexo = 'mujeres' THEN Votos_Universitarios ELSE 0 END) AS Votos_Universitarios_Mujeres,
        SUM(CASE WHEN Sexo = 'hombres' THEN Votos_Universitarios ELSE 0 END) AS Votos_Universitarios_Hombres
    FROM votos_universitarios
    GROUP BY Departamento
) AS totales
WHERE Votos_Universitarios_Mujeres > Votos_Universitarios_Hombres;




#6. Desplegar el nombre del país, la región y el promedio de votos por
#departamento. Por ejemplo: si la región tiene tres departamentos, se debe
#sumar todos los votos de la región y dividirlo dentro de tres (número de
#departamentos de la región).

WITH votos_por_departamento AS (
    SELECT
        p.NOMBRE AS Pais,
        r.NOMBRE AS Region,
        d.NOMBRE AS Departamento,
        AVG(v.VOTOS_OBTENIDOS) AS Promedio_Votos
    FROM PAIS p
    JOIN REGION r ON p.ID_PAIS = r.ID_PAIS
    JOIN DEPARTAMENTO d ON r.ID_REGION = d.ID_REGION
    JOIN MUNICIPIO m ON d.ID_DEPARTAMENTO = m.ID_DEPARTAMENTO
    JOIN ELECCION e ON m.ID_MUNICIPIO = e.ID_MUNICIPIO
    JOIN VOTACION v ON e.ID_ELECCION = v.ID_ELECCION
    GROUP BY p.NOMBRE, r.NOMBRE, d.NOMBRE
)

SELECT
    Pais,
    Region,
    Departamento,
    ROUND(Promedio_Votos, 2) AS Promedio_Votos_Redondeado
FROM votos_por_departamento;


#7. Desplegar el nombre del país y el porcentaje de votos por raza.
WITH votos_por_raza AS (
    SELECT
        p.NOMBRE AS Pais,
        ra.NOMBRE AS Raza,
        COUNT(*) AS Votos,
        (COUNT(*) / (SELECT COUNT(*) FROM POBLACION)) * 100 AS Porcentaje_Votos
    FROM PAIS p
    JOIN REGION r ON p.ID_PAIS = r.ID_PAIS
    JOIN DEPARTAMENTO d ON r.ID_REGION = d.ID_REGION
    JOIN MUNICIPIO m ON d.ID_DEPARTAMENTO = m.ID_DEPARTAMENTO
    JOIN ELECCION e ON m.ID_MUNICIPIO = e.ID_MUNICIPIO
    JOIN VOTACION v ON e.ID_ELECCION = v.ID_ELECCION
    JOIN POBLACION pob ON v.ID_POBLACION = pob.ID_POBLACION
    JOIN RAZA ra ON ra.ID_RAZA = pob.ID_RAZA
    GROUP BY p.NOMBRE, ra.NOMBRE
)

SELECT Pais, Raza, ROUND(Porcentaje_Votos, 2) AS Porcentaje_Votos_Redondeado
FROM votos_por_raza;


#Desplegar el nombre del país en el cual las elecciones han sido más
#peleadas. Para determinar esto se debe calcular la diferencia de porcentajes
#de votos entre el partido que obtuvo más votos y el partido que obtuvo menos
#votos.


WITH votos_por_eleccion_partido AS (
    SELECT
        p.NOMBRE AS Pais,
        e.NOMBRE_ELECCION AS Eleccion,
        pp.NOMBRE_PARTIDO AS Partido,
        COUNT(*) AS Votos_Obtenidos
    FROM PAIS p
    JOIN REGION r ON p.ID_PAIS = r.ID_PAIS
    JOIN DEPARTAMENTO d ON r.ID_REGION = d.ID_REGION
    JOIN MUNICIPIO m ON d.ID_DEPARTAMENTO = m.ID_DEPARTAMENTO
    JOIN ELECCION e ON m.ID_MUNICIPIO = e.ID_MUNICIPIO
    JOIN VOTACION v ON e.ID_ELECCION = v.ID_ELECCION
    JOIN PARTIDO_POLITICO pp ON v.ID_PARTIDO = pp.ID_PARTIDO
    GROUP BY p.NOMBRE, e.NOMBRE_ELECCION, pp.NOMBRE_PARTIDO
)

SELECT
    Pais,
    Eleccion,
    MAX(Votos_Obtenidos) OVER (PARTITION BY Pais, Eleccion) AS Votos_Ganador,
    MIN(Votos_Obtenidos) OVER (PARTITION BY Pais, Eleccion) AS Votos_Perdedor,
    ROUND(((MAX(Votos_Obtenidos) OVER (PARTITION BY Pais, Eleccion) - MIN(Votos_Obtenidos) OVER (PARTITION BY Pais, Eleccion)) / MAX(Votos_Obtenidos) OVER (PARTITION BY Pais, Eleccion)) * 100, 2) AS Diferencia_Porcentajes
FROM votos_por_eleccion_partido
ORDER BY Pais, Diferencia_Porcentajes DESC
LIMIT 1;

#9. Desplegar el nombre del país, el porcentaje de votos de ese país en el que
#han votado mayor porcentaje de analfabetas. (tip: solo desplegar un nombre
#de país, el de mayor porcentaje)
WITH votos_por_alfabetizacion AS (
    SELECT
        p.NOMBRE AS Pais,
        ((ALFABETOS + PRIMARIA + NIVEL_MEDIO + UNIVERTSITARIOS) / CAST(COUNT(*) AS DECIMAL)) * 100 AS Porcentaje_Alfabetizacion,
        COUNT(*) AS Votos_Totales,
        COUNT(CASE WHEN ANALFABETOS = 1 THEN 1 ELSE NULL END) AS Votos_Analfabetos
    FROM PAIS p
    JOIN REGION r ON p.ID_PAIS = r.ID_PAIS
    JOIN DEPARTAMENTO d ON r.ID_REGION = d.ID_REGION
    JOIN MUNICIPIO m ON d.ID_DEPARTAMENTO = m.ID_DEPARTAMENTO
    JOIN ELECCION e ON m.ID_MUNICIPIO = e.ID_MUNICIPIO
    JOIN VOTACION v ON e.ID_ELECCION = v.ID_ELECCION
    JOIN POBLACION pob ON v.ID_POBLACION = pob.ID_POBLACION
    GROUP BY p.NOMBRE
), porcentaje_votos_analfabetos AS (
    SELECT Pais, MAX(Porcentaje_Votos_Analfabetos) OVER (PARTITION BY Pais) AS Porcentaje_Votos_Analfabetos_Maximo
    FROM votos_por_alfabetizacion
)

SELECT Pais, ROUND(Porcentaje_Votos_Analfabetos_Maximo, 2) AS Porcentaje_Votos_Analfabetos_Redondeado
FROM porcentaje_votos_analfabetos
ORDER BY Porcentaje_Votos_Analfabetos_Maximo DESC
LIMIT 1;

#10.Desplegar la lista de departamentos de Guatemala y número de votos
#obtenidos, para los departamentos que obtuvieron más votos que el
#departamento de Guatemala.
WITH votos_por_departamento AS (
    SELECT
        d.NOMBRE AS Departamento,
        COUNT(*) AS Votos_Obtenidos
    FROM DEPARTAMENTO d
    JOIN MUNICIPIO m ON d.ID_DEPARTAMENTO = m.ID_DEPARTAMENTO
    JOIN ELECCION e ON m.ID_MUNICIPIO = e.ID_MUNICIPIO
    JOIN VOTACION v ON e.ID_ELECCION = v.ID_ELECCION
    JOIN POBLACION pob ON v.ID_POBLACION = pob.ID_POBLACION
    GROUP BY d.NOMBRE
)


SELECT Departamento, Votos_Obtenidos
FROM votos_por_departamento
WHERE Votos_Obtenidos > (
    SELECT Votos_Obtenidos
    FROM votos_por_departamento
    WHERE Departamento = 'Guatemala'
)
ORDER BY Votos_Obtenidos DESC;










