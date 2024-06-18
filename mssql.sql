create database MSSQL
create table monhoc
(
	id_mon_hoc nvarchar(13) not null,
	constraint pk_monhoc
	primary key (id_mon_hoc),
	ten nvarchar(max) null,
	so_tin_chi int null,
)

create table sv
(
	masv nvarchar(13) not null,
	constraint pk_sv
	primary key (masv),
	gioi_tinh bit,
	lop_sv nvarchar(30) null,
)

create table gv
(
	id_gv nvarchar(13) not null,
	constraint pk_gv
	primary key(id_gv),
	ten nvarchar(max) null,
	bo_mon nvarchar(max) null
)

create table lophp
(
	id_lop_hoc nvarchar(13) not null,
	constraint pk_lophp
	primary key(id_lop_hoc),
	id_mon_hoc nvarchar(13) null,
	hoc_ky int null,
	ten_lop_hoc nvarchar(15) null,
	id_gv nvarchar(15) null,
	foreign key (id_mon_hoc) references monhoc(id_mon_hoc),
	foreign key (id_gv) references gv(id_gv)
)

create table dkmh
(
	id nvarchar(13) not null,
	constraint pk_dkmh
	primary key(id),
	id_lop_hoc nvarchar(13) not null,
	masv nvarchar(13) not null,
	diemkt float,
	diemthi float,
	foreign key (id_lop_hoc) references lophp(id_lop_hoc),
	foreign key (masv) references sv(masv)
)

insert into monhoc (id_mon_hoc, ten, so_tin_chi)
values ('mh10', N'Lập trình trong môi trường Windows', 3),
		('mh11', N'Đồ án hệ thống nhúng', 2),
		('mh12', N'Hệ thống nhúng', 3),
		('mh13', N'Tiếng Anh', 3),
		('mh14', N'Kỹ thuật điện tử', 4);
insert into sv(masv, gioi_tinh, lop_sv)
values ('sv1', N'Nguyễn Văn A', N'Nam', N'123'),
		('sv2', N'Nguyễn Thị B', N'Nữ', N'124'),
		('sv3', N'Hoàng Văn C', N'Nam', N'123'),
		('sv4', N' Nguyễn Thị Lmao', N'Nữ', N'124'),
		('svnn1', N'Trần Văn Lfao', N'Nam', N'125');
insert into gv(id_gv,ten,bo_mon)
values ('gv1', N'Đỗ Văn C', N'Toán'),
		('gv2', N'Lê Văn B', N'Tiếng Anh'),
		('gv3', N'Đỗ Văn E', N'Toán').
		('gv4', N'Hoàng Minh D', N'Nhúng'),
		('gv5', N'Nông Thị LV', N'Tiếng Anh');
insert into lophp(id_lop_hoc,id_mon_hoc,hoc_ky,ten_lop_hoc,id_gv)
values ('lop1', 'mh1', 32023, N'Ctruc1', 'gv1'),
		('lop2', 'mh11', 22022, N'Anh1', 'gv2'),
		('lop3', 'mh12', 32024, N'Nhung4', 'gv4'),
		('lop4', 'mh14', 32024, N'DA_Nhung1', 'gv4'),
		('lop5', 'mh10', 22022, N'KTDT2', 'gv1');
insert into dkmh(id, id_lop_hoc, masv,diemkt,diemthi)
values ('111','lop1','svnn1',4,4),
		('112','lop1','sv1',7,8),
		('113','lop4','sv2',9,9),
		('114','lop5','sv2',7,9),
		('115','lop2','sv4',9,6);

--bai1
go
create function fn_diem
(
	@hoc_ky int,
	@masv nvarchar(30)
)
returns float as
begin
 declare @diemtb float
 --Hàm tính điểm trung bình
 select @diemtb=AVG(diemkt+diemthi) from dkmh
 return @diemtb
 end

 --bai2
 go
 create function fn_diem_lopsv
 (
	@hk int,
	@lopsv nvarchar(30)
 )
 returns @kq table
 (
 masv nvarchar(30),
 ten nvarchar(max),
 gioi_tinh bit,
 diem_tb float
 )
 begin
  declare @diemtblop float
  select @diemtblop=AVG(diemkt+diemthi) from dkmh where id_lop_hoc='12345' 
 return
 end

--bai3
go reate procedure sp_danh_muc
(
	@hk int
)
as
begin
 select
 (
	select id_mon_hoc as 'id_mon_hoc' from lophp
	where hoc_ky=@hk
	for json path
 ) as 'monhoc',
 --a
 (
	select id_lop_hoc as 'id_lop_hoc' from lophp
	where hoc_ky=@hk
	for json path
 ) as 'lophp'
 --a
 (
	select id_gv as 'id_gv' from lophp
	where id_gv in (select distinct id_gv from lophp where hoc_ky=@hk)
	for json patch
 ) as 'giao_vien'
end

--bai4
go create procedure lop_hp
(
	@id_lop_hp nvarchar(13)
)
as
begin
	select sv, masv as 'sinh_vien.masv' from sv 
	inner join dkmh on sv.masv=dkmh.masv
	where dkmh.id_lop_hoc=@id_lop_hp
	for json path;
end