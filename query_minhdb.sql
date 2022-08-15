USE minhdb;

-- Find the family and given names of academics who have authored at least one paper with the word “database” in the paper’s title
SELECT AC.famname, AC.givename
FROM academic AC, author AU, paper P
WHERE AC.acnum = AU.acnum AND
      P.panum = AU.panum AND
      P.title LIKE '%database%';

-- Find the family and given names of academics who are working for the “University of Canberra” who have not authored any paper
SELECT DISTINCT AC.famname, AC.givename
FROM academic AC, department D
WHERE AC.deptnum = D.deptnum AND
      D.instname = 'University of Canberra' AND
      NOT EXISTS (SELECT *
                  FROM author AU, paper P
                  WHERE AC.acnum = AU.acnum AND
                        AU.panum = P.panum);


-- Find the total number of academics who have an interest in 'databases'
SELECT DISTINCT COUNT(*)
FROM academic AC, interest I, field F
WHERE AC.acnum = I.acnum AND
      I.fieldnum = F.fieldnum AND
      (F.title LIKE '%database%' OR I.descrip LIKE '%database%');


-- Find the field number of the most popular field(s)
SELECT I.fieldnum, COUNT(I.acnum) AS total
FROM interest I
GROUP BY I.fieldnum
HAVING total = (SELECT MAX(R.total)
                FROM (SELECT I1.fieldnum, COUNT(*) AS total
                      FROM interest I1
                      GROUP BY I1.fieldnum) AS R);


-- Find the family and given names of the academics who are interested in the most popular field(s)
SELECT AC.famname, AC.givename
FROM academic AC, interest I
WHERE AC.acnum = I.acnum AND
      I.fieldnum IN (SELECT fieldnum
                     FROM interest
                     GROUP BY fieldnum
                     HAVING COUNT(acnum) = (SELECT MAX(countacnum) 
                                            FROM (SELECT fieldnum, COUNT(acnum) as countacnum
                                                  FROM interest
                                                  GROUP BY fieldnum) as fieldcount));


-- Find the number of papers authored by each academic
SELECT AC.acnum, AC.famname, AC.givename, COUNT(*) AS total
FROM academic AC, author AU
WHERE AC.acnum = AU.acnum
GROUP BY AC.acnum, AC.famname, AC.givename
UNION
SELECT DISTINCT AC.acnum, AC.famname, AC.givename, 0
FROM academic AC
WHERE AC.acnum NOT IN (SELECT acnum FROM author)
ORDER BY total DESC;


-- Find the family and given names of the academics who are interested in less than 2 fields
-- Approach 1: Using GROUP BY
SELECT AC.famname, AC.givename
FROM academic AC
WHERE AC.acnum IN (SELECT acnum
                   FROM academic
                   WHERE acnum NOT IN (SELECT acnum FROM interest)
                   UNION
                   SELECT acnum
                   FROM interest
                   GROUP BY acnum
                   HAVING count(fieldnum) < 2);

-- Approach 2: Not using GROUP BY
SELECT AC.famname, AC.givename
FROM academic AC
WHERE AC.acnum NOT IN (SELECT I1.acnum
                       FROM interest I1, interest I2
                       WHERE I1.acnum = I2.acnum AND
                             I1.fieldnum <> I2.fieldnum);