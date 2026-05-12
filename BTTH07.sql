create database btth;
use btth;

create table courses (
    course_id int primary key auto_increment,
    course_name varchar(100),
    duration varchar(50),
    status enum('active', 'inactive')
);

create table subjects (
    subject_id char(4) primary key check(subject_id like ('MH__')),
    subject_name varchar(100),
    credits int check (credits > 0),
    status enum('active', 'inactive'),
    course_id int,
    foreign key (course_id) references courses(course_id)
);

create table students (
    student_id char(5) primary key check (student_id like 'SV___'),
    student_name varchar(100),
    birth_year int,
    gender bit default(1),
    phone char(10),
    address varchar(200),
    status enum('studying', 'on hold', 'suspended', 'graduated')
);

create table enrollments (
    enrollment_id int primary key auto_increment,
    subject_id char(4),
    student_id char(5),
    grade decimal(3,1) check (grade >= 0 and grade <= 10),
    enrollment_date date,
    foreign key (subject_id) references subjects(subject_id),
    foreign key (student_id) references students(student_id)
);

create table citizen_id_card (
    card_id int primary key auto_increment,
    id_number varchar(12) unique,
    issue_date date,
    issue_place varchar(100),
    student_id varchar(20) unique,
    foreign key (student_id) references students(student_id)
);

-- Thêm dữ liệu vào mỗi bảng tối thiểu 5 dữ liệu
insert into courses(course_name, duration, status)
values
('Java Web', '6 months', 'active'),
('Python Basic', '3 months', 'active'),
('Data Science', '8 months', 'inactive'),
('Mobile Development', '5 months', 'active'),
('Database Design', '4 months', 'active');

insert into subjects(subject_id, subject_name, credits, status, course_id)
values
('MH01', 'Java Core', 3, 'active', 1),
('MH02', 'Spring MVC', 4, 'active', null),
('MH03', 'Python Intro', 3, 'active', 2),
('MH04', 'Machine Learning', 4, 'inactive', 3),
('MH05', 'SQL Server', 3, 'active', 5);

insert into students(student_id, student_name, birth_year, gender, phone, address, status)
values
('SV001', 'Nguyen Van A', 2003, 1, '0911111111', 'Ha Noi', 'studying'),
('SV002', 'Tran Thi B', 2002, 0, '0922222222', 'Hai Phong', 'studying'),
('SV003', 'Le Van C', 2001, 1, '0933333333', 'Da Nang', 'on hold'),
('SV004', 'Pham Thi D', 2003, 0, '0944444444', 'Ho Chi Minh', 'graduated'),
('SV005', 'Hoang Van E', 2004, 1, '0955555555', 'Can Tho', 'suspended');

insert into enrollments(subject_id, student_id, grade, enrollment_date)
values
('MH01', 'SV001', 8.5, '2025-01-10'),
('MH02', 'SV001', 7.5, '2025-02-15'),
('MH03', 'SV002', 9.0, '2025-03-12'),
('MH04', 'SV003', 6.5, '2025-01-20'),
('MH05', 'SV004', 8.0, '2025-04-05');

insert into citizen_id_card(id_number, issue_date, issue_place, student_id)
values
('001234567890', '2021-05-20', 'Ha Noi', 'SV001'),
('001234567891', '2021-06-15', 'Hai Phong', 'SV002'),
('001234567892', '2020-08-10', 'Da Nang', 'SV003'),
('001234567893', '2022-01-25', 'Ho Chi Minh', 'SV004'),
('001234567894', '2023-03-18', 'Can Tho', 'SV005');

-- Cập nhật môn học có mã là MH01 thành tên ‘Toán cao cấp’ và có số tín chỉ là 3
update subjects
set subject_name = 'Toán cao cấp', credits = 3
where subject_id = 'MH01';

--  Thực hiện xóa các môn học có trạng thái là Không hoạt động. Hãy phân tích khi nào xóa được các môn học này khi nào không xóa được và vì sao?
delete from subjects
where status = 'inactive';
/*
Xóa được môn học khi mà nó không có liên kết với bảng enrollments 

Không xóa được môn học khi mà subjects đang được tham chiếu bởi bảng enrollment do subjects là bảng cha và enrollments là bảng con 
và mySQL không cho phép xóa dữ liệu ở bảng cha khi mà đang có bảng con tham chiếu tới nó để đảm bảo tính vẹn toàn dữ liệu
*/

-- Truy vấn cơ bản

-- Lấy thông tin các sinh viên gồm: mã sinh viên, tên sinh viên, số điện thoại, địa chỉ
select student_id, student_name, phone, address
from students;

-- Lấy thông tin các môn học chưa thuộc khóa học gồm: mã khóa học, tên khóa học, số tín chỉ
select subject_id, subject_name, credits
from subjects 
where course_id is null;

-- Lấy các mã khóa học đã có môn học
select course_id
from subjects
where course_id is not null;

-- Lấy thông tin các đăng ký gồm: mã sinh viên, tên sinh viên, ngày đăng ký, tên môn học đăng ký, điểm môn học, số căn cước công dân sắp xếp theo năm sinh giảm dần
select st.student_id, st.student_name, e.enrollment_date, sj.subject_name, e.grade, c.id_number
from students st
join enrollments e
on st.student_id = e.student_id
join subjects sj
on e.subject_id = sj.subject_id
join citizen_id_card c
on st.student_id = c.student_id
order by st.birth_year desc;

-- Truy vấn nâng cao

-- Tính tổng số lần đăng ký của từng môn học
/*
Phép truy vấn thực hiện trên bảng subjects và bảng enrollments
Sử dụng hàm count()
Nhóm theo subject_id
*/
select s.subject_id, count(e.enrollment_id) 
from subjects s
left join enrollments e
on s.subject_id = e.subject_id
group by s.subject_id, e.subject_id;

-- Thống kê số môn học của từng khóa học
/*
Phép truy vấn thực hiện trên bảng courses và subjects
sử dụng hàm count()
nhóm theo course_id
*/
select c.course_id, count(s.course_id)
from courses c
left join subjects s
on c.course_id = s.course_id
group by c.course_id, s.course_id;

-- Tính điểm trung bình của sinh viên (điểm trung bình của tất cả các đăng ký)
/*
Phép truy vấn thực hiện trên bảng students và enrollment
sử dụng hàm avg()
nhóm theo student_id
*/
select s.student_id, s.student_name, avg(e.grade)
from students s
join enrollments e
on s.student_id = e.student_id
group by s.student_id, e.student_id;


-- Lấy thông tin các môn học có điểm trung bình lớn hơn 5 gồm: mã môn học, tên môn học, tên khóa học
/*
Phép truy vấn thực hiện trên bảng subjects, enrollments, courses
sử dụng hàm avg()
nhóm theo subject_id
*/
select s.subject_id, s.subject_name, c.course_name, avg(e.grade)
from subjects s
join courses c
on s.course_id = c.course_id
join enrollments e
on s.subject_id = e.subject_id
group by s.subject_id
having avg(e.grade) > 5;

-- Lấy thông tin các đăng ký có điểm lớn nhất gồm: mã sinh viên, tên sinh viên, tên môn học, điểm môn học
/*
Phép truy vấn thực hiện trên bảng subjects, students, enrollments
sử dụng hàm max()
truy vấn con: TÌm điểm lớn nhất
truy vấn cha: Lấy các đăng ký có  điểm bằng điểm lớn nhất
*/
select 
    s.student_id,
    s.student_name,
    sj.subject_name,
    e.grade
from students s
join enrollments e
on s.student_id = e.student_id
join subjects sj
on e.subject_id = sj.subject_id
where e.grade = (
	select max(grade)
	from enrollments
);

-- Lấy thông tin sinh viên đã đăng ký môn học có điểm trung bình lớn nhất gồm: mã sinh viên, tên sinh viên, tuổi, tên môn học, tên khóa học
/*
Phép truy vấn thực hiện trên bảng students, subjects, enrollments và courses
sử dụng hàm avg() và max()
truy vấn 1: Tính điểm trung bình của từng môn học
truy vấn 2: Tìm môn học có điểm trung bình cao nhấtable
truy vấn 3: Lấy thông tin sinh viễn đã đăng ký môn học đó
*/
select 
    st.student_id,
    st.student_name,
	st.birth_year,
    sj.subject_name,
    c.course_name
from students st
join enrollments e
on st.student_id = e.student_id
join subjects sj
on e.subject_id = sj.subject_id
join courses c
on sj.course_id = c.course_id
where sj.subject_id = (
    select subject_id
    from enrollments
    group by subject_id
    order by avg(grade) desc
    limit 1
);

