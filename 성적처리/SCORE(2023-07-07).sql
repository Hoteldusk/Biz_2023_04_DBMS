-- ScoreDB 화면

USE scoreDB;

-- 일반(엑셀)성적표를 저장하기 위한 Table 생성
CREATE TABLE tbl_scoreV1 (
sc_stnum	VARCHAR(5)		PRIMARY KEY,
sc_kor		INT,
sc_eng		INT,		
sc_math		INT,		
sc_music	INT,		
sc_art		INT,		
sc_software	INT,		
sc_database	INT
);
SHOW TABLES;
DESC tbl_scoreV1;

SELECT * FROM tbl_scoreV1 ORDER BY sc_stnum;

CREATE VIEW view_scoreV1 AS
(
	SELECT *, 
	sc_kor + sc_eng + sc_math + sc_music + sc_art + sc_software + sc_database AS 총점,
	(sc_kor + sc_eng + sc_math + sc_music + sc_art + sc_software + sc_database) / 7 AS 평균
	FROM tbl_scoreV1
);

SELECT *FROM view_scoreV1;

-- 국어성적이 50점 이상인 학생들 리스트
-- WHERE SELECTION
SELECT * FROM view_scoreV1
WHERE sc_kor >= 50;

-- 평균점수가 60점 미만인 학생들
SELECT * FROM view_scoreV1
WHERE 평균 < 70;

-- SQL 을 사용한 간이 통계
-- 전체학생의 각 과목별 성적총점계산
-- 국어성적의 총점
-- SUM() : ANSI SQL 의 총합계를 계산하는 통계함수
-- AVG() : ANSI SQL 의 평균을 계산하는 통계함수
-- MAX(), MIN() : ANSI SQL 의 최대값, 최소값을 계산하는 통계함수
-- COUNT() : ANSI SQL 의 개수를 계산하는 통계함수
SELECT SUM(sc_kor), AVG(sc_kor)
FROM view_scoreV1;

SELECT SUM(sc_kor) AS 국어,
SUM(sc_eng) AS 영어,
SUM(sc_math) AS 수학,
SUM(sc_music) AS 음악,
SUM(sc_art) AS 미술
FROM view_scoreV1;

SELECT AVG(sc_kor) AS 국어,
AVG(sc_eng) AS 영어,
AVG(sc_math) AS 수학,
AVG(sc_music) AS 음악,
AVG(sc_art) AS 미술
FROM view_scoreV1;

-- MySQL8 의 전용함수
SELECT * FROM view_scoreV1
ORDER BY 평균 DESC;

-- OVER ( ORDER BY 평균 DESC ) : 평균을 오름차순 한 것을 기준으로
-- RANK() 순위를 계산하라
SELECT *,
RANK() OVER ( ORDER BY 평균 DESC ) 랭킹
FROM view_scoreV1
ORDER BY 평균 DESC;

-- DENSE_RANK() : 동점자 처리를 하되 석차를 건너뜀 없이 
SELECT *,
DENSE_RANK() OVER ( ORDER BY 평균 DESC ) 랭킹
FROM view_scoreV1
ORDER BY 평균 DESC;

-- Sub Query : SQL 결과를 사용하여 다른 SQL 을 실행하는 것
SELECT * FROM
(
SELECT *,
RANK() OVER ( ORDER BY 평균 DESC ) 랭킹
FROM view_scoreV1
) AS SUB
WHERE SUB.랭킹 < 5;

SELECT sc_stnum, 'B001', '국어',sc_kor FROM tbl_scoreV1
UNION ALL
SELECT sc_stnum, 'B002','영어',sc_eng FROM tbl_scoreV1
UNION ALL
SELECT sc_stnum, 'B003','수학',sc_math FROM tbl_scoreV1
UNION ALL
SELECT sc_stnum, 'B004','음악',sc_music FROM tbl_scoreV1
UNION ALL
SELECT sc_stnum, 'B005','미술',sc_art FROM tbl_scoreV1
UNION ALL
SELECT sc_stnum, 'B006','소프트웨어',sc_software FROM tbl_scoreV1
UNION ALL
SELECT sc_stnum, 'B007','데이터베이스',sc_database FROM tbl_scoreV1;

SELECT SUB.과목코드, SUB.과목명 FROM
(
	SELECT sc_stnum, 'B001' AS 과목코드, '국어' AS 과목명,sc_kor FROM tbl_scoreV1
	UNION ALL
	SELECT sc_stnum, 'B002','영어',sc_eng FROM tbl_scoreV1
	UNION ALL
	SELECT sc_stnum, 'B003','수학',sc_math FROM tbl_scoreV1
	UNION ALL
	SELECT sc_stnum, 'B004','음악',sc_music FROM tbl_scoreV1
	UNION ALL
	SELECT sc_stnum, 'B005','미술',sc_art FROM tbl_scoreV1
	UNION ALL
	SELECT sc_stnum, 'B006','소프트웨어',sc_software FROM tbl_scoreV1
	UNION ALL
	SELECT sc_stnum, 'B007','데이터베이스',sc_database FROM tbl_scoreV1
) AS SUB
GROUP BY SUB.과목코드, SUB.과목명;



-- 학생정보 제3 정규화 데이터 테이블
-- 학번과 과목코드를 복합키(슈퍼키) PK 생성
CREATE TABLE tbl_score (
sc_stnum	VARCHAR(5)	NOT NULL,
sc_bcode	VARCHAR(4)	NOT NULL,
sc_score	INT			NOT NULL,
PRIMARY KEY(sc_stnum, sc_bcode)	
);

DROP TABLE tbl_score;

-- 과목정보 테이블 
CREATE TABLE tbl_subject (
b_code	VARCHAR(4)		PRIMARY KEY,
b_name	VARCHAR(20)		
);
-- 과목정보 Excel 데이터를 tbl_subject 에 insert 해보기
-- import wizard 사용했음
SELECT * FROM tbl_subject;
SELECT COUNT(*) FROM tbl_subject;

SELECT * FROM tbl_score;
SELECT COUNT(*) FROM tbl_score;

-- 성적표와 과목정보를 JOIN 하여
-- 학번, 과목코드, 과목명, 점수를 Projection 하여 출력
SELECT sc_stnum, sc_bcode, b_name, sc_score
	FROM tbl_score
		LEFT JOIN tbl_subject
			ON sc_bcode = b_code;
            
-- 성적표와 과목정보가 완전 참조 관계일떄는 EQ JOIN 을 사용할 수 있다
SELECT sc_stnum, sc_bcode, b_name, sc_score
	FROM tbl_score, tbl_subject
		WHERE sc_bcode = b_code;


-- 여기에서 결과가 하나도 없어야 한다
-- 검증 코드
SELECT sc_stnum, sc_bcode, b_name, sc_score
	FROM tbl_score
		LEFT JOIN tbl_subject
			ON sc_bcode = b_code
WHERE b_name IS NULL;

-- 성적표와 과목정보가 앞으로도 계속 완전참조 관계가 되도록 하기 위해서 FK 설정(완전참조 무결성 관계 설정)
-- ANSI SQL 표준
alter table tbl_score
add constraint f_subject
foreign key (sc_bcode)
references tbl_subject(b_code);

--  mySQL
-- foreign key 이름 설정하는데 어려움
alter table tbl_score
add foreign key f_subject(sc_bcode)
references tbl_subject(b_code);

alter table tbl_score
drop foreign key tbl_score_ibfk_1;

-- ON DELETE, ON UPDATE
-- ON DELETE : Master(tbl_subject) table의 키가 삭제될때
/*
CASCADE : Master 삭제 -> Sub도 모두 삭제
SET NULL : Master 삭제 -> Sub는 NULL, 만약 sub 칼럼이 not null 이면 오류 발생
NO ACTION : Master 삭제 -> Sub 에는 변화 없이
SET DEFAULT : Master 삭제 -> Sub Table 생성할때 DEFAULT 옵션으로 지정한 값으로 세팅
RESTRICT : 아무 것도 하지마, 삭제하지마
*/
-- ON UPDATE : Master(tbl_subject) table의 키가 변경될때
alter table tbl_score 
add constraint f_subject foreign key (sc_bcode) references tbl_subject(b_code)
on delete cascade;

select sc_stnum, sc_bcode, sc_score
from  tbl_score, tbl_subject
where sc_bcode = b_code AND sc_stnum = 'S0001';


select sc_stnum, sc_bcode, sc_score
from  tbl_score, tbl_subject
where sc_bcode = b_code AND b_name = '국어';

-- 학생별 총점 계산하기
SELECT sc_stnum, SUM(sc_score) 총점
FROM tbl_score
GROUP BY sc_stnum;

-- 과목별 총점 계산하기
select sc_bcode AS 과목코드, SUM(sc_score) 총점, AVG(sc_score) 평균
from tbl_score
group by sc_bcode;

-- 제 3정규화 된 데이터를 PIVOT 펼쳐서 보고서 형식으로 출력
-- 세로방향으로 펼쳐진 데이터를 가로방향으로 펼쳐서 보기
SELECT
	SUM(IF(sc_bcode = 'B001',sc_score,0)) AS 국어,
    SUM(IF(sc_bcode = 'B002',sc_score,0)) AS 영어,
    SUM(IF(sc_bcode = 'B003',sc_score,0)) AS 수학,
    SUM(IF(sc_bcode = 'B004',sc_score,0)) AS 음악,
    SUM(IF(sc_bcode = 'B005',sc_score,0)) AS 미술,
    SUM(IF(sc_bcode = 'B006',sc_score,0)) AS 소프트웨어,
    SUM(IF(sc_bcode = 'B007',sc_score,0)) AS 데이터베이스
FROM tbl_score;

-- 제3정규화가 되어 있는 데이터를 PIVOT 보고서 형식으로 출력
SELECT sc_stnum,
	SUM(IF(sc_bcode = 'B001',sc_score,0)) AS 국어,
    SUM(IF(sc_bcode = 'B002',sc_score,0)) AS 영어,
    SUM(IF(sc_bcode = 'B003',sc_score,0)) AS 수학,
    SUM(IF(sc_bcode = 'B004',sc_score,0)) AS 음악,
    SUM(IF(sc_bcode = 'B005',sc_score,0)) AS 미술,
    SUM(IF(sc_bcode = 'B006',sc_score,0)) AS 소프트웨어,
    SUM(IF(sc_bcode = 'B007',sc_score,0)) AS 데이터베이스,
    SUM(sc_score) AS 총점,
    AVG(sc_score) AS 평균
FROM tbl_score
GROUP BY sc_stnum;

SELECT sc_stnum, SUM(sc_score)
FROM tbl_score
GROUP BY sc_stnum;

-- 통계함수로 학생별 총점을 계산하고 계산된 총점에 대하여 조건을 부여하여 SELECTION 하기
SELECT sc_stnum, SUM(sc_score) AS 총점
FROM tbl_score
GROUP BY sc_stnum
HAVING 총점 > 500;

-- 학번이 S0010 보다 작은 학생들의 총점 계산
SELECT sc_stnum AS 학번, SUM(sc_score) AS 총점
FROM tbl_score
WHERE sc_stnum < 'S0010'
GROUP BY sc_stnum ;

-- S0001학번 학생의 총점보다 총점이 작은 학생들 총점 리스트
-- 조건절(WHERE, HAVING)에 SUB Query 적용하기
-- 조건절에 적용하는 SUB Query 는 결과가 반드시 한 개 이하여야 한다
select sum(sc_score) from tbl_score where sc_stnum = 'S0001';

select sc_stnum as 학번, sum(sc_score) as 총점
from tbl_score
group by sc_stnum
having 총점 < (select sum(sc_score) from tbl_score where sc_stnum = 'S0001');

/*
Oracle
   1. table space 만들기 ***
   2. User 생성하기 ***

mySQL
   3. 권한부여하기 ***

공통
   4. 주요 SELECT 문장
		(SUM(), AVG 함수 - GROUP BY 사용)
   5. CREATE TABLE : 테이블 명세를 보고 빈칸 채우기 후 테이블 만들기
   6. INSERT
   7. UPDATE
		주소록에서 홍길동인 사람의 전화번호가 010-111-... 이다
		이 전화번호를 010-222 으로 바꾸어라 (*****PK 사용*****)
*/