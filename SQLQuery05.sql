CREATE TABLE ChuNha (
    ID_ChuNha INT PRIMARY KEY IDENTITY(1,1),
    TenChuNha VARCHAR(100) NOT NULL,
    DiaChi VARCHAR(255) NOT NULL,
    SoDienThoai VARCHAR(15) NOT NULL
);
CREATE TABLE PhongTro (
    ID_Phong INT PRIMARY KEY IDENTITY(1,1),
    TenPhong VARCHAR(100) NOT NULL,
    GiaThue DECIMAL(10,2) NOT NULL,
    DienTich FLOAT NOT NULL,
    TinhTrang BIT NOT NULL, -- 1: Đã thuê, 0: Chưa thuê
    SoNguoiToiDa INT NOT NULL,
    DacDiem VARCHAR(255),
   
);
CREATE TABLE KhachHang (
    ID_KhachHang INT PRIMARY KEY IDENTITY(1,1),
    TenKhachHang VARCHAR(100) NOT NULL,
    GioiTinh VARCHAR(10) NOT NULL,
    NgaySinh DATE NOT NULL,
    DiaChi VARCHAR(255) NOT NULL,
    SoDienThoai VARCHAR(15) NOT NULL,
    DaThuePhong BIT NOT NULL DEFAULT 0,
    ID_Phong INT NULL,
    FOREIGN KEY (ID_Phong) REFERENCES PhongTro(ID_Phong)
);
CREATE TABLE DichVu (
    ID_DichVu INT PRIMARY KEY IDENTITY(1,1),
    TenDichVu VARCHAR(100) NOT NULL,
    GiaDichVu DECIMAL(10,2) NOT NULL
);
CREATE TABLE ChiTietDichVu (
    ID_ChiTietDichVu INT PRIMARY KEY IDENTITY(1,1),
    ID_Phong INT,
    ThangNam VARCHAR(7) NOT NULL,
    SoDien DECIMAL(10,2) NULL, -- Số lượng sử dụng Điện (kWh)
    SoNuoc DECIMAL(10,2) NULL, -- Số lượng sử dụng Nước (m3)
    ID_Internet INT NOT NULL, -- ID dịch vụ Internet
    ID_VeSinh INT NOT NULL, -- ID dịch vụ Vệ sinh
    ID_BaoVe INT NOT NULL, -- ID dịch vụ Bảo vệ
	TongTienDichVu DECIMAL(10,2),
    FOREIGN KEY (ID_Phong) REFERENCES PhongTro(ID_Phong),
    FOREIGN KEY (ID_Internet) REFERENCES DichVu(ID_DichVu),
    FOREIGN KEY (ID_VeSinh) REFERENCES DichVu(ID_DichVu),
    FOREIGN KEY (ID_BaoVe) REFERENCES DichVu(ID_DichVu)
);
CREATE TABLE HopDongThue (
    ID_HopDong INT PRIMARY KEY IDENTITY(1,1),
    NgayBatDau DATE NOT NULL,
    NgayKetThuc DATE NOT NULL,
    TienDatCoc DECIMAL(10,2) NOT NULL,
    TrangThai VARCHAR(50) NOT NULL,
    ID_Phong INT,
    ID_KhachHang INT,
    FOREIGN KEY (ID_Phong) REFERENCES PhongTro(ID_Phong),
    FOREIGN KEY (ID_KhachHang) REFERENCES KhachHang(ID_KhachHang)
);
CREATE TABLE HoaDon (
    ID_HoaDon INT PRIMARY KEY IDENTITY(1,1),
    ID_HopDong INT,
    NgayTao DATE NOT NULL,
    ThangNam VARCHAR(7) NOT NULL,
    SoTien DECIMAL(10,2) NOT NULL,
    TrangThaiThanhToan VARCHAR(50) NOT NULL,
    ChiTietDichVu VARCHAR(255),
	 ID_ChiTietDichVu INT,

	  TongSoTien DECIMAL(10,2) ,
	 	FOREIGN KEY (ID_ChiTietDichVu) REFERENCES ChiTietDichVu(ID_ChiTietDichVu),
    FOREIGN KEY (ID_HopDong) REFERENCES HopDongThue(ID_HopDong)
);

CREATE TABLE ThanhToan (
    ID_ThanhToan INT PRIMARY KEY IDENTITY(1,1),
    ID_HoaDon INT,
    NgayThanhToan DATE NOT NULL,
    SoTien DECIMAL(10,2) NOT NULL,
    PhuongThuc VARCHAR(50) NOT NULL,
    FOREIGN KEY (ID_HoaDon) REFERENCES HoaDon(ID_HoaDon),
	SoTienConLai DECIMAL(10,2) NOT NULL DEFAULT 0
);

CREATE TABLE KPI (
    ID_KPI INT PRIMARY KEY IDENTITY(1,1),
    ThoiGian DATE NOT NULL,
    TongDoanhThu DECIMAL(10,2) NOT NULL,
    TongChiPhi DECIMAL(10,2) NOT NULL,
    TyLeLapDay DECIMAL(5,2) NOT NULL,
    SoHopDongMoi INT NOT NULL,
    SoHopDongGiaHan DECIMAL(5,2) NOT NULL,
    SoPhongTrong INT NOT NULL,
  
    SoYeuCauBaoTri INT NOT NULL DEFAULT 0
);


CREATE TRIGGER trg_CapNhatTongTienDichVu1
ON ChiTietDichVu
AFTER INSERT
AS
BEGIN
    DECLARE @GiaDien DECIMAL(10,2) = 3000; -- giá điện cố định
    DECLARE @GiaNuoc DECIMAL(10,2) = 15000; -- giá nước cố định

    -- Cập nhật tổng tiền dịch vụ cho các bản ghi mới chèn
    UPDATE ctdv
    SET TongTienDichVu = ISNULL(i.SoDien, 0) * @GiaDien + ISNULL(i.SoNuoc, 0) * @GiaNuoc + 
                          ISNULL(dv1.GiaDichVu, 0) + ISNULL(dv2.GiaDichVu, 0) + ISNULL(dv3.GiaDichVu, 0)
    FROM ChiTietDichVu ctdv
    JOIN inserted i ON ctdv.ID_Phong = i.ID_Phong 
    JOIN DichVu dv1 ON i.ID_Internet = dv1.ID_DichVu
    JOIN DichVu dv2 ON i.ID_VeSinh = dv2.ID_DichVu
    JOIN DichVu dv3 ON i.ID_BaoVe = dv3.ID_DichVu;
END;



INSERT INTO ChuNha (TenChuNha, DiaChi, SoDienThoai)
VALUES 
('Nguyen Van A', '123 Nguyen Trai, Hanoi', '0123456789'),
('Le Thi B', '456 Tran Hung Dao, Hanoi', '0987654321'),
('Tran Van C', '789 Le Loi, Ho Chi Minh', '0345678912'),
('Pham Thi D', '321 Le Duan, Da Nang', '0567891234'),
('Hoang Van E', '654 Hai Ba Trung, Hue', '0789123456')

INSERT INTO PhongTro (TenPhong, GiaThue, DienTich, TinhTrang, SoNguoiToiDa, DacDiem)
VALUES 
-- Chủ nhà 1
('Phong 101', 1245000, 20, 0, 2, 'Co ban cong'),
('Phong 102', 3500000, 22, 1, 2, 'Gan cua so'),
('Phong 103', 4000000, 25, 0, 3, 'Co may lanh'),
('Phong 104', 4500000, 30, 1, 3, 'Gan san thuong'),
('Phong 105', 5000000, 35, 0, 4, 'Co bep'),
-- Chủ nhà 2
('Phong 201', 3000000, 20, 0, 2, 'Co ban cong'),
('Phong 202', 3500000, 22, 1, 2, 'Gan cua so'),
('Phong 203', 4000000, 25, 0, 3, 'Co may lanh'),
('Phong 204', 4500000, 30, 1, 3, 'Gan san thuong'),
('Phong 205', 5000000, 35, 0, 4, 'Co bep'),
-- Chủ nhà 3
('Phong 301', 3000000, 20, 0, 2, 'Co ban cong'),
('Phong 302', 3500000, 22, 1, 2, 'Gan cua so'),
('Phong 303', 4000000, 25, 0, 3, 'Co may lanh'),
('Phong 304', 4500000, 30, 1, 3, 'Gan san thuong'),
('Phong 305', 5000000, 35, 0, 4, 'Co bep'),
-- Chủ nhà 4
('Phong 401', 3000000, 20, 0, 2, 'Co ban cong'),
('Phong 402', 3500000, 22, 1, 2, 'Gan cua so'),
('Phong 403', 4000000, 25, 0, 3, 'Co may lanh'),
('Phong 404', 4500000, 30, 1, 3, 'Gan san thuong'),
('Phong 405', 5000000, 35, 0, 4, 'Co bep'),
-- Chủ nhà 5
('Phong 501', 3000000, 20, 0, 2, 'Co ban cong'),
('Phong 502', 3500000, 22, 1, 2, 'Gan cua so'),
('Phong 503', 4000000, 25, 0, 3, 'Co may lanh'),
('Phong 504', 4500000, 30, 1, 3, 'Gan san thuong'),
('Phong 505', 5000000, 35, 0, 4, 'Co bep'),
('Phong 601', 3000000, 20, 0, 2, 'Co ban cong'),
('Phong 602', 3500000, 22, 1, 2, 'Gan cua so'),
('Phong 603', 4000000, 25, 0, 3, 'Co may lanh'),
('Phong 604', 4500000, 30, 1, 3, 'Gan san thuong'),
('Phong 605', 5000000, 35, 0, 4, 'Co bep');
INSERT INTO KhachHang (TenKhachHang, GioiTinh, NgaySinh, DiaChi, SoDienThoai, DaThuePhong, ID_Phong)
VALUES 
-- Khách hàng chưa thuê phòng (DaThuePhong = 0, ID_Phong = NULL)
('Nguyen Minh An', 'Nam', '1990-01-01', '111 Ly Thuong Kiet, Hanoi', '0901234567', 0, NULL),
('Le Thi Bao', 'Nu', '1992-02-02', '222 Phan Boi Chau, Hanoi', '0912345678', 0, NULL),
('Tran Hoang Long', 'Nam', '1988-03-03', '333 Ba Trieu, Hanoi', '0923456789', 0, NULL),
('Pham Thi Mai', 'Nu', '1995-04-04', '444 Nguyen Du, Ho Chi Minh', '0934567890', 0, NULL),
('Hoang Tuan Kiet', 'Nam', '1985-05-05', '555 Nguyen Hue, Da Nang', '0945678901', 0, NULL),
-- Khách hàng đã thuê phòng (DaThuePhong = 1, ID_Phong = số phòng đã thuê)
('Nguyen Van Binh', 'Nam', '1989-06-06', '666 Le Hong Phong, Hanoi', '0965432109', 1, 1),
('Le Thi Canh', 'Nu', '1993-07-07', '777 Hoang Dieu, Hanoi', '0976543210', 1, 2),
('Tran Van Dong', 'Nam', '1987-08-08', '888 Ngo Quyen, Hanoi', '0987654321', 1, 3),
('Pham Thi Ha', 'Nu', '1991-09-09', '999 Bach Dang, Ho Chi Minh', '0998765432', 1, 4),
('Hoang Van Hoa', 'Nam', '1986-10-10', '1010 Hai Phong, Da Nang', '0910987654', 1, 5),
('Tran Van Phuc', 'Nam', '1990-11-11', '1111 Hai Ba Trung, Hanoi', '0965432111', 1, 6),
('Nguyen Thi Quynh', 'Nu', '1992-12-12', '2222 Hang Bai, Hanoi', '0976543222', 1, 7),
('Le Van Sang', 'Nam', '1989-01-01', '3333 Hai Phong, Ho Chi Minh', '0987654333', 1, 8),
('Pham Thi Tam', 'Nu', '1994-02-02', '4444 Le Thanh Ton, Da Nang', '0998765444', 1, 9),
('Hoang Van Uyen', 'Nam', '1987-03-03', '5555 Le Hong Phong, Hue', '0910987656', 1, 10),
('Tran Van A', 'Nam', '1990-01-01', '1 Le Loi, Hue', '0912345670', 1, 11),
('Le Thi B', 'Nu', '1991-02-02', '2 Phan Dinh Phung, Hue', '0912345671', 1, 12),
('Nguyen Van C', 'Nam', '1992-03-03', '3 Ngo Gia Tu, Hue', '0912345672', 1, 13),
('Pham Thi D', 'Nu', '1993-04-04', '4 Hai Ba Trung, Hue', '0912345673', 1, 14),
('Hoang Van E', 'Nam', '1994-05-05', '5 Le Duan, Hue', '0912345674', 1, 15);
INSERT INTO DichVu (TenDichVu, GiaDichVu)
VALUES 
('Dien', 5000),   -- Giá dịch vụ mẫu cho mỗi kWh
('Nuoc', 3000),   -- Giá dịch vụ mẫu cho mỗi m3
('Internet', 100000), -- Giá dịch vụ mẫu cho mỗi tháng
('Ve sinh', 20000),   -- Giá dịch vụ mẫu hàng tháng
('Bao ve', 15000);    

INSERT INTO ChiTietDichVu (ID_Phong, ThangNam, SoDien, SoNuoc, ID_Internet, ID_VeSinh, ID_BaoVe)
VALUES 
    (1, '2024-01', 150.0, 20.0, 3, 4, 5),
    (2, '2024-01', 130.0, 18.0, 3, 4, 5),
    (3, '2024-01', 140.0, 19.0, 3, 4, 5),
    (4, '2024-01', 160, 21, 3, 4, 5),
    (5, '2024-01', 110.0, 17.0, 3, 4, 5),
    (6, '2024-01', 120.0, 16.0, 3, 4, 5),
    (7, '2024-01', 170.0, 22.0, 3, 4, 5),
    (8, '2024-01', 180.0, 23.0, 3, 4, 5),
    (9, '2024-01', 190.0, 24.0, 3, 4, 5),
    (10, '2024-01', 100.0, 15.0, 3, 4, 5),
    (11, '2024-01', 105.0, 16.5, 3, 4, 5),
    (12, '2024-01', 115.0, 17.5, 3, 4, 5),
    (13, '2024-01', 125.0, 18.5, 3, 4, 5),
    (14, '2024-01', 135.0, 19.5, 3, 4, 5),
    (15, '2024-01', 145.0, 20.5, 3, 4, 5),
    (1, '2024-02', 150.0, 20.0, 3, 4, 5),
    (2, '2024-02', 130.0, 18.0, 3, 4, 5),
    (3, '2024-02', 140.0, 19.0, 3, 4, 5),
    (4, '2024-02', 160.0, 21.0, 3, 4, 5),
    (5, '2024-02', 110.0, 17.0, 3, 4, 5),
    (6, '2024-02', 120.0, 16.0, 3, 4, 5),
    (7, '2024-02', 170.0, 22.0, 3, 4, 5),
    (8, '2024-02', 180.0, 23.0, 3, 4, 5),
    (9, '2024-02', 190.0, 24.0, 3, 4, 5),
    (10, '2024-02', 100.0, 15.0, 3, 4, 5),
    (11, '2024-02', 105.0, 16.5, 3, 4, 5),
    (12, '2024-02', 115.0, 17.5, 3, 4, 5),
    (13, '2024-02', 125.0, 18.5, 3, 4, 5),
    (14, '2024-02', 135.0, 19.5, 3, 4, 5),
    (15, '2024-02', 145.0, 20.5, 3, 4, 5),
    (21, '2024-02', 155.0, 21.5, 3, 4, 5),
    (23, '2024-02', 165.0, 22.5, 3, 4, 5);





DECLARE @GiaDien DECIMAL(10,2) = 3000; 
DECLARE @GiaNuoc DECIMAL(10,2) = 15000; 
UPDATE ctdv
SET TongTienDichVu = ISNULL(SoDien, 0) * @GiaDien + ISNULL(SoNuoc, 0) * @GiaNuoc + 
                      ISNULL(dv1.GiaDichVu, 0) + ISNULL(dv2.GiaDichVu, 0) + ISNULL(dv3.GiaDichVu, 0)
FROM ChiTietDichVu ctdv
JOIN DichVu dv1 ON ctdv.ID_Internet = dv1.ID_DichVu
JOIN DichVu dv2 ON ctdv.ID_VeSinh = dv2.ID_DichVu
JOIN DichVu dv3 ON ctdv.ID_BaoVe = dv3.ID_DichVu;





CREATE TRIGGER trg_TaoHoaDonTuDong
ON ChiTietDichVu
AFTER INSERT
AS
BEGIN
    -- Định nghĩa các giá trị cố định của giá dịch vụ
    DECLARE @GiaDien DECIMAL(10,2) = 3000; -- giá điện cố định
    DECLARE @GiaNuoc DECIMAL(10,2) = 15000; -- giá nước cố định

    -- Tạo hóa đơn mới cho từng dòng mới chèn vào bảng ChiTietDichVu
    INSERT INTO HoaDon (ID_HopDong, NgayTao, ThangNam, SoTien, TrangThaiThanhToan, ChiTietDichVu, ID_ChiTietDichVu)
    SELECT 
        h.ID_HopDong, 
        EOMONTH(CAST(i.ThangNam + '-01' AS DATE)) AS NgayTao, 
        i.ThangNam, 
        pt.GiaThue, 
        'Chưa thanh toán' AS TrangThaiThanhToan, 
        CAST(i.TongTienDichVu AS VARCHAR(50)) AS ChiTietDichVu, 
        i.ID_ChiTietDichVu
    FROM inserted i
    JOIN HopDongThue h ON h.ID_Phong = i.ID_Phong
    JOIN PhongTro pt ON pt.ID_Phong = i.ID_Phong
    JOIN DichVu dv1 ON i.ID_Internet = dv1.ID_DichVu
    JOIN DichVu dv2 ON i.ID_VeSinh = dv2.ID_DichVu
    JOIN DichVu dv3 ON i.ID_BaoVe = dv3.ID_DichVu;
END;


-- Định nghĩa các giá trị cố định của giá dịch vụ
DECLARE @GiaDien DECIMAL(10,2) = 3000; -- giá điện cố định
DECLARE @GiaNuoc DECIMAL(10,2) = 15000; -- giá nước cố định
INSERT INTO HoaDon (ID_HopDong, NgayTao, ThangNam, SoTien, TrangThaiThanhToan, ChiTietDichVu, ID_ChiTietDichVu)
SELECT 
    h.ID_HopDong, 
    EOMONTH(CAST(ctdv.ThangNam + '-01' AS DATE)) AS NgayTao, 
    ctdv.ThangNam, 
    pt.GiaThue, 
    'Chưa thanh toán' AS TrangThaiThanhToan, 
     CAST(ctdv.TongTienDichVu AS VARCHAR(50)) AS ChiTietDichVu, 
    ctdv.ID_ChiTietDichVu
FROM ChiTietDichVu ctdv
JOIN HopDongThue h ON h.ID_Phong = ctdv.ID_Phong
JOIN PhongTro pt ON pt.ID_Phong = ctdv.ID_Phong
JOIN DichVu dv1 ON ctdv.ID_Internet = dv1.ID_DichVu
JOIN DichVu dv2 ON ctdv.ID_VeSinh = dv2.ID_DichVu
JOIN DichVu dv3 ON ctdv.ID_BaoVe = dv3.ID_DichVu;


CREATE PROCEDURE CapNhatTinhTrangPhongTro
AS
BEGIN
    -- Cập nhật trạng thái phòng thành 'Đã có người thuê' (true) khi có hợp đồng thuê
    UPDATE pt
    SET pt.TinhTrang = 1
    FROM PhongTro pt
    WHERE EXISTS (SELECT 1 FROM HopDongThue h WHERE h.ID_Phong = pt.ID_Phong);

    -- Cập nhật trạng thái phòng thành 'Chưa ai thuê' (false) khi không có hợp đồng thuê
    UPDATE pt
    SET pt.TinhTrang = 0
    FROM PhongTro pt
    WHERE NOT EXISTS (SELECT 1 FROM HopDongThue h WHERE h.ID_Phong = pt.ID_Phong);
END;
EXEC CapNhatTinhTrangPhongTro;

CREATE TRIGGER trg_UpdatePhongTroStatus
ON HopDongThue
AFTER INSERT, UPDATE
AS
BEGIN
    -- Cập nhật trạng thái phòng thành 'Đã có người thuê' (true) khi có hợp đồng thuê mới
    UPDATE pt
    SET pt.TinhTrang = 1
    FROM PhongTro pt
    JOIN inserted i ON pt.ID_Phong = i.ID_Phong;
END;

 CREATE TRIGGER trg_UpdatePhongTroStatusOnDelete
   ON HopDongThue
   AFTER DELETE
   AS
   BEGIN
    -- Cập nhật trạng thái phòng thành 'Chưa ai thuê' (false) khi hợp đồng thuê bị xóa
    UPDATE pt
    SET pt.TinhTrang = 0
    FROM PhongTro pt
    LEFT JOIN HopDongThue h ON pt.ID_Phong = h.ID_Phong
    WHERE h.ID_HopDong IS NULL;
  END;




CREATE TRIGGER trg_UpdateTongSoTien
ON HoaDon
AFTER INSERT, UPDATE
AS
BEGIN
    UPDATE HoaDon
    SET TongSoTien = SoTien + CAST(ChiTietDichVu AS DECIMAL(10,2))
    WHERE ID_HoaDon IN (SELECT ID_HoaDon FROM inserted);
END;



CREATE TRIGGER trg_CheckDaThuePhong
ON KhachHang
AFTER INSERT, UPDATE
AS
BEGIN
    DECLARE @ID_KhachHang INT;
    DECLARE @ID_Phong INT;
    DECLARE @DaThuePhong BIT;
    DECLARE @NgayBatDau DATE;
    DECLARE @NgayKetThuc DATE;

    -- Lấy giá trị từ bảng inserted
    SELECT @ID_KhachHang = ID_KhachHang, @ID_Phong = ID_Phong, @DaThuePhong = DaThuePhong
    FROM inserted;

    -- Kiểm tra nếu DaThuePhong là True
    IF @DaThuePhong = 1
    BEGIN
        -- Cập nhật TinhTrang trong bảng PhongTro thành True
        UPDATE PhongTro
        SET TinhTrang = 1
        WHERE ID_Phong = @ID_Phong;

        -- Tính NgayBatDau và NgayKetThuc
        SET @NgayBatDau = GETDATE();
        SET @NgayKetThuc = DATEADD(month, 6, @NgayBatDau);

        -- Thêm một dòng dữ liệu mới vào bảng HopDong
        INSERT INTO HopDongThue (NgayBatDau, NgayKetThuc, TienDatCoc, TrangThai, ID_Phong, ID_KhachHang)
        VALUES (@NgayBatDau, @NgayKetThuc, 500000, 1, @ID_Phong, @ID_KhachHang);
    END
END;


CREATE PROCEDURE AddMissingContracts
AS
BEGIN
    -- Khai báo biến để lưu trữ giá trị
    DECLARE @ID_KhachHang INT;
    DECLARE @ID_Phong INT;
    DECLARE @NgayBatDau DATETIME;
    DECLARE @NgayKetThuc DATE;
    DECLARE @LastContractDate DATETIME;

    -- Lấy `NgayBatDau` cuối cùng từ bảng HopDongThue
    SELECT @LastContractDate = MAX(NgayBatDau)
    FROM HopDongThue;

    -- Nếu `LastContractDate` là NULL, đặt `NgayBatDau` là ngày đầu tiên của quý tiếp theo
    IF @LastContractDate IS NULL
    BEGIN
        SELECT @LastContractDate = DATEADD(QUARTER, DATEDIFF(QUARTER, 0, GETDATE()) + 1, 0);
    END
    ELSE
    BEGIN
        -- Lấy ngày đầu tiên của quý tiếp theo so với `LastContractDate`
        SELECT @LastContractDate = DATEADD(QUARTER, DATEDIFF(QUARTER, 0, @LastContractDate) + 1, 0);
    END

    -- Con trỏ để duyệt qua các khách hàng đã thuê phòng nhưng chưa có hợp đồng
    DECLARE missingContracts CURSOR FOR
    SELECT ID_KhachHang, ID_Phong
    FROM KhachHang
    WHERE DaThuePhong = 1
    

    -- Mở con trỏ
    OPEN missingContracts;

    -- Đọc bản ghi đầu tiên
    FETCH NEXT FROM missingContracts INTO @ID_KhachHang, @ID_Phong;

    -- Lặp qua tất cả các bản ghi
    WHILE @@FETCH_STATUS = 0
    BEGIN
        -- Tính NgayBatDau và NgayKetThuc
        SET @NgayBatDau = @LastContractDate;
        SET @NgayKetThuc = DATEADD(MONTH, 3, @NgayBatDau);

        -- Thêm một dòng dữ liệu mới vào bảng HopDongThue
        INSERT INTO HopDongThue (NgayBatDau, NgayKetThuc, TienDatCoc, TrangThai, ID_Phong, ID_KhachHang)
        VALUES (@NgayBatDau, @NgayKetThuc, 500000, 'Active', @ID_Phong, @ID_KhachHang);

        -- Cập nhật @LastContractDate để thêm 1 phút
        SET @LastContractDate = DATEADD(MINUTE, 1, @LastContractDate);

        -- Cập nhật TinhTrang trong bảng PhongTro thành True
        UPDATE PhongTro
        SET TinhTrang = 1
        WHERE ID_Phong = @ID_Phong;

        -- Đọc bản ghi tiếp theo
        FETCH NEXT FROM missingContracts INTO @ID_KhachHang, @ID_Phong;
    END;

    -- Đóng con trỏ
    CLOSE missingContracts;

    -- Giải phóng con trỏ
    DEALLOCATE missingContracts;
END;


/*
DROP PROCEDURE IF EXISTS AddMissingContracts;
SELECT * FROM HopDongThue;
*/
EXEC AddMissingContracts;

CREATE TRIGGER trg_UpdateHoaDon
ON ChiTietDichVu
AFTER INSERT, UPDATE
AS
BEGIN
    DECLARE @ID_ChiTietDichVu INT;
    DECLARE @ID_Phong INT;
    DECLARE @ThangNam VARCHAR(7);
    DECLARE @TongTienDichVu DECIMAL(10,2);
    DECLARE @SoTien DECIMAL(10,2);
    DECLARE @NgayTao DATE;
    DECLARE @ID_HopDong INT;

    -- Lấy giá trị từ bảng inserted
    SELECT @ID_ChiTietDichVu = ID_ChiTietDichVu, @ID_Phong = ID_Phong, @ThangNam = ThangNam, @TongTienDichVu = TongTienDichVu
    FROM inserted;

    -- Lấy giá trị thuê phòng từ bảng PhongTro
    SELECT @SoTien = GiaThue
    FROM PhongTro
    WHERE ID_Phong = @ID_Phong;

    -- Lấy ID_HopDong từ bảng HopDongThue
    SELECT @ID_HopDong = ID_HopDong
    FROM HopDongThue
    WHERE ID_Phong = @ID_Phong;

    -- Tính ngày cuối cùng của ThangNam
    SET @NgayTao = EOMONTH(CAST(@ThangNam + '-01' AS DATE));

    -- Cập nhật bảng HoaDon
    UPDATE HoaDon
    SET 
        SoTien = @SoTien,
        ChiTietDichVu = @TongTienDichVu,
        TongSoTien = @SoTien + @TongTienDichVu,
        NgayTao = @NgayTao,
        TrangThaiThanhToan = 0,
        ID_HopDong = @ID_HopDong,
        ID_ChiTietDichVu = @ID_ChiTietDichVu
    WHERE ID_ChiTietDichVu = @ID_ChiTietDichVu;
END;

INSERT INTO HoaDon (ID_HopDong, NgayTao, ThangNam, SoTien, ChiTietDichVu, TongSoTien, TrangThaiThanhToan, ID_ChiTietDichVu)
SELECT 
    ht.ID_HopDong,
    EOMONTH(CAST(ctdv.ThangNam + '-01' AS DATE)) AS NgayTao,
    ctdv.ThangNam,
    pt.GiaThue AS SoTien,
    ctdv.TongTienDichVu AS ChiTietDichVu,
    pt.GiaThue + ctdv.TongTienDichVu AS TongSoTien,
    0 AS TrangThaiThanhToan,
    ctdv.ID_ChiTietDichVu
FROM ChiTietDichVu ctdv
JOIN PhongTro pt ON ctdv.ID_Phong = pt.ID_Phong
JOIN HopDongThue ht ON ctdv.ID_Phong = ht.ID_Phong;


CREATE PROCEDURE ThanhToanHoaDon
    @ID_HoaDon INT,
    @SoTien DECIMAL(10,2),
    @PhuongThuc INT
AS
BEGIN
    DECLARE @TongSoTien DECIMAL(10,2);
    DECLARE @SoTienConLai DECIMAL(10,2);

    -- Kiểm tra xem ID_HoaDon có tồn tại trong bảng ThanhToan hay không
    IF EXISTS (SELECT 1 FROM ThanhToan WHERE ID_HoaDon = @ID_HoaDon)
    BEGIN
        -- Lấy SoTienConLai hiện tại từ bản ghi gần nhất trong bảng ThanhToan
        SELECT TOP 1 @SoTienConLai = SoTienConLai
        FROM ThanhToan
        WHERE ID_HoaDon = @ID_HoaDon
        ORDER BY NgayThanhToan DESC;

        -- Tính số tiền còn lại
        SET @SoTienConLai = @SoTienConLai - @SoTien;
    END
    ELSE
    BEGIN
        -- Lấy tổng số tiền của hóa đơn từ bảng HoaDon
        SELECT @TongSoTien = TongSoTien
        FROM HoaDon
        WHERE ID_HoaDon = @ID_HoaDon;

        -- Tính số tiền còn lại
        SET @SoTienConLai = @TongSoTien - @SoTien;
    END

    -- Chèn bản ghi mới vào bảng ThanhToan
    INSERT INTO ThanhToan (ID_HoaDon, NgayThanhToan, SoTien, PhuongThuc, SoTienConLai)
    VALUES (@ID_HoaDon, GETDATE(), @SoTien, @PhuongThuc, @SoTienConLai);

    -- Cập nhật trạng thái thanh toán trong bảng HoaDon
    IF @SoTienConLai <= 0
    BEGIN
        UPDATE HoaDon
        SET TrangThaiThanhToan = 'Da Thanh Toan'
        WHERE ID_HoaDon = @ID_HoaDon;
    END
    ELSE
    BEGIN
        UPDATE HoaDon
        SET TrangThaiThanhToan = 'Chua Thanh Toan Het'
        WHERE ID_HoaDon = @ID_HoaDon;
    END
END;


INSERT INTO ThanhToan (ID_HoaDon, NgayThanhToan, SoTien, PhuongThuc)
VALUES (2, '2024-06-30', 296000, 1);

INSERT INTO ThanhToan (ID_HoaDon, NgayThanhToan, SoTien, PhuongThuc)
VALUES (3, '2024-06-30', 500000, 0);

INSERT INTO ThanhToan (ID_HoaDon, NgayThanhToan, SoTien, PhuongThuc)
VALUES (4, '2024-06-30', 750000, 1);

INSERT INTO ThanhToan (ID_HoaDon, NgayThanhToan, SoTien, PhuongThuc)
VALUES (5, '2024-06-30', 1000000, 0);

INSERT INTO ThanhToan (ID_HoaDon, NgayThanhToan, SoTien, PhuongThuc)
VALUES (6, '2024-06-30', 1250000, 1);

INSERT INTO ThanhToan (ID_HoaDon, NgayThanhToan, SoTien, PhuongThuc)
VALUES (7, '2024-06-30', 1500000, 0);

INSERT INTO ThanhToan (ID_HoaDon, NgayThanhToan, SoTien, PhuongThuc)
VALUES (8, '2024-06-30', 1750000, 1);

INSERT INTO ThanhToan (ID_HoaDon, NgayThanhToan, SoTien, PhuongThuc)
VALUES (9, '2024-06-30', 2000000, 0);

INSERT INTO ThanhToan (ID_HoaDon, NgayThanhToan, SoTien, PhuongThuc)
VALUES (10, '2024-06-30', 2250000, 1);

INSERT INTO ThanhToan (ID_HoaDon, NgayThanhToan, SoTien, PhuongThuc)
VALUES (11, '2024-06-30', 2500000, 0);



CREATE PROCEDURE UpdateKPI
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @currentDate DATE = GETDATE();
    DECLARE @startDate DATE = DATEADD(MONTH, -3, @currentDate);
    DECLARE @previousStartDate DATE = DATEADD(MONTH, -6, @currentDate);
    DECLARE @previousEndDate DATE = DATEADD(MONTH, -3, @currentDate);

    -- Tính toán các giá trị KPI
    DECLARE @TongDoanhThu DECIMAL(10,2);
    DECLARE @TongChiPhi DECIMAL(10,2);
    DECLARE @TyLeLapDay DECIMAL(5,2);
    DECLARE @SoHopDongMoi INT;
    DECLARE @SoHopDongGiaHan DECIMAL(5,2);
    DECLARE @SoPhongTrong INT;
    DECLARE @SoThanhToanCham DECIMAL(10,2);
    DECLARE @SoYeuCauBaoTri INT = 0; -- Giả định không có bảng bảo trì

    -- Tính toán tổng doanh thu của quý trước
    SELECT @TongDoanhThu = SUM(TongSoTien)
    FROM HoaDon
    WHERE NgayTao BETWEEN @previousStartDate AND @previousEndDate;

    -- Tính toán tổng chi phí (5% của tổng doanh thu)
    SET @TongChiPhi = @TongDoanhThu * 0.05;

    -- Tính toán tỷ lệ lấp đầy
    DECLARE @SoPhongDaThue INT;
    SELECT @SoPhongDaThue = COUNT(DISTINCT ht.ID_Phong)
    FROM HoaDon h
    JOIN HopDongThue ht ON h.ID_HopDong = ht.ID_HopDong
    WHERE h.NgayTao BETWEEN @startDate AND @currentDate;

    DECLARE @TongSoPhong INT;
    SELECT @TongSoPhong = COUNT(*)
    FROM PhongTro;

    IF @TongSoPhong = 0
        SET @TyLeLapDay = 0;
    ELSE
        SET @TyLeLapDay = (CAST(@SoPhongDaThue AS DECIMAL(5,2)) / @TongSoPhong) * 100;

    -- Tính toán số hợp đồng mới
    SELECT @SoHopDongMoi = COUNT(*)
    FROM HopDongThue
    WHERE NgayBatDau BETWEEN @startDate AND @currentDate;

    -- Tính toán số hợp đồng gia hạn
    DECLARE @SoKhachHangTruoc INT;
    DECLARE @SoKhachHangHienTai INT;
    SELECT @SoKhachHangTruoc = COUNT(DISTINCT ID_KhachHang)
    FROM HopDongThue
    WHERE NgayBatDau BETWEEN @previousStartDate AND @previousEndDate;

    SELECT @SoKhachHangHienTai = COUNT(DISTINCT ID_KhachHang)
    FROM HopDongThue
    WHERE NgayBatDau BETWEEN @startDate AND @currentDate;

    IF @SoKhachHangTruoc = 0
        SET @SoHopDongGiaHan = 0;
    ELSE
        SET @SoHopDongGiaHan = (CAST(@SoKhachHangHienTai AS DECIMAL(5,2)) / @SoKhachHangTruoc) * 100;

    -- Tính toán số phòng trống
    SET @SoPhongTrong = @TongSoPhong - @SoPhongDaThue;

    -- Tính toán số thanh toán chậm
    SELECT @SoThanhToanCham = SUM(TongSoTien)
    FROM HoaDon
    WHERE TrangThaiThanhToan = 'Chua Thanh Toan Het' AND NgayTao BETWEEN @previousStartDate AND @previousEndDate;

    SELECT @SoThanhToanCham = @SoThanhToanCham + ISNULL(SUM(SoTienConLai), 0)
    FROM ThanhToan
    WHERE NgayThanhToan BETWEEN @previousStartDate AND @previousEndDate;

    -- Chèn dữ liệu vào bảng KPI
    INSERT INTO KPI (ThoiGian, TongDoanhThu, TongChiPhi, TyLeLapDay, SoHopDongMoi, SoHopDongGiaHan, SoPhongTrong, SoThanhToanCham, SoYeuCauBaoTri)
    VALUES (@currentDate, @TongDoanhThu, @TongChiPhi, @TyLeLapDay, @SoHopDongMoi, @SoHopDongGiaHan, @SoPhongTrong, @SoThanhToanCham, @SoYeuCauBaoTri);
END;

CREATE TRIGGER trg_UpdateKPI_HoaDon
ON HoaDon
AFTER INSERT
AS
BEGIN
    -- Gọi thủ tục lưu trữ để cập nhật KPI
    EXEC UpdateKPI;
END;



SELECT * FROM KPI;
/*
INSERT INTO ThanhToan (ID_HoaDon, NgayThanhToan, SoTien, PhuongThuc)
VALUES (2, '2024-06-30', 490000, 1);

-- Kiểm tra bảng ThanhToan
SELECT * FROM ThanhToan;

-- Kiểm tra bảng HoaDon để xác nhận trạng thái thanh toán đã được cập nhật
SELECT * FROM HoaDon;

DROP PROCEDURE IF EXISTS AddMissingContracts;

ALTER TABLE KPI
DROP COLUMN SoThanhToanCham;


DELETE FROM ThanhToan;
DBCC CHECKIDENT ('ThanhToan', RESEED, 0);
DELETE FROM HoaDon;
DBCC CHECKIDENT ('HoaDon', RESEED, 0);
DELETE FROM HopDongThue;
DBCC CHECKIDENT ('HopDongThue', RESEED, 0);
/*


