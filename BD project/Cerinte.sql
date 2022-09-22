select * from angajat;
select * from job;
select * from pacient;
select * from departament;
select * from diagnostic;
select * from tratament;

--12

--1
--Sa se afiseze numele si prenumele medicilor, id-ul managerilor lor
--sau mesajul "Este manager", in cazul in care respecticul nu are un manager alocat.
--Ordonati dupa nume.
-- NVL, ordonare, filtrare pe linii

Select nume, prenume, NVL(to_char(manager_id), 'Este manager')
from angajat
where id_job='Med'
order by nume;

--2
--Scrieti o cerere pentru a afisa numele departamentului, etajul, cladirea si 
-- si salariul mediu pentru angajatii ce lucreaza in departamentele de Urgente
-- si de terapie intensiva.
--join pe 4 tabele, grup?ri de date, func?ii grup, filtrare la nivel de grupuri

Select d.dept_descr, e.id_etaj, c.id_cladire, AVG(j.salariu)
from angajat a
join job j on a.id_job=j.id_job
join departament d on a.id_dept=d.id_dept
join etaj e on d.id_etaj=e.id_etaj
join cladire c on d.id_cladire= c.id_cladire
group by d.dept_descr, e.id_etaj, c.id_cladire
having d.dept_descr = 'Urgente';

--3
--S? se afi?eze codul, numele departamentului ?i suma salariilor pe departamente. 
--subcereri nesincronizate în care intervin cel pu?in 3 tabele

SELECT d.id_dept, d.dept_descr, c.suma 
FROM departament d, (SELECT a.id_dept, SUM(j.salariu) suma 
                    FROM angajat a
                    join job j on a.id_job=j.id_job
                    GROUP BY a.id_dept) c
WHERE d.id_dept = c.id_dept;


--OBS am adauat subcerere nesincronizata
--Folosind subcereri nesincronizate, s? se afi?eze numele ?i salariul angaja?ilor condu?i direct de Stanescu Paul
SELECT nume, prenume, salariu
FROM angajat
Join job using (id_job)
WHERE manager_id in (SELECT id_angajat 
                    FROM angajat
                    WHERE lower(nume) = 'stanescu' and lower(prenume) = 'paul');
                    



--S? se afi?eze codul, numele ?i prenumele si sala in care au birou pentru angaja?ii care au cel pu?in un subaltern.
--CERERE SINCRONIZATA ce implica 3 tabele
SELECT a.id_angajat, a.nume, a.prenume, j.salariu, s.id_sala
FROM angajat a
Join job j on a.id_job =j.id_job
join sala s on a.id_sala=s.id_sala
WHERE (SELECT count(manager_id) 
        FROM angajat 
        Where id_angajat != a.id_angajat and manager_id=a.id_angajat)>0;


--4

--Folosind clauza with, sa se afiseze numele pacientilor al caror oras de provenienta este Bucuresti , data (sub forma de string) a diagnosticului,
--sau data nestabilita daca acceasta este nula
--medicamentul prescris precum si valoarea true daca medicamentul trebuie administrat imediat sau false daca tratamentul trebuie administrat zilnic.
--Ultima coloana va fi numita Trebuie_administrat
--subcereri sincronizate în care intervin cel pu?in 3 tabele
--nvl, case, with,

With pacOras as
(SELECT id_pac
FROM pacient
WHERE oras='Bucuresti')
SELECT p.nume, p.prenume, NVL(TO_CHAR(d.data_diagnostic),'data nestabilita'), t.medicament, (CASE when t.administrare='zilnica' THEN 'true'
                                                                                                    else 'false' end ) as Trebuie_administrat
FROM pacient p
join diagnostic d on p.id_pac=d.id_pac
join implica i on d.id_diagnostic = i. id_diagnostic
join tratament t on i.plan_tratament=t.plan_tratament
where p.id_pac in (Select id_pac from pacOras);

--5
--Sa se scrie o cerere care sa returneze numele pacientilor si daca data la care le-a foat stabilit diagnosticul este data curenta sau nu


SELECT p.nume, p.prenume, DECODE(SYSDATE, d.data_diagnostic, 'A fost stabilit astazi', 'nu a fost stabilit azi') as Diagnostic
FROM pacient p
join diagnostic d on p.id_pac=d.id_pac;

--13
--realizat cu subcereri nesincronizate

--1
--Sa se modifice numele pacientului al carui diagnostic este de fractura  in Constantin.
--actualizare
UPDATE pacient
set nume = 'Constantin'
Where id_pac = (Select id_pac from diagnostic where id_diagnostic='frac');
rollback;

--2
--Sa se stearga pacientul numit Badea Marian
--suprimare
DELETE FROM pacient
WHERE id_pac = (Select id_pac from pacient where nume='Badea' and prenume='Marian');

--3
--Sa se creassca salariul medicilor rezidenticu 200 de lei.
--actualizare
UPDATE JOB
set salariu = salariu+200
Where id_job = (Select id_job from JOB where titlu_job='Medic Rezident');
rollback;
