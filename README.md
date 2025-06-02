# data--warehouse---SQL---project
🏗️ Kiến Trúc Dữ Liệu
Dự án này trình bày một giải pháp toàn diện về kho dữ liệu và phân tích, từ việc xây dựng kho dữ liệu đến việc tạo ra các thông tin phân tích có giá trị.  

Kiến trúc dữ liệu trong dự án này tuân theo mô hình kiến trúc Medallion với ba lớp: Bronze, Silver, và Gold:

Lớp Bronze: Lưu trữ dữ liệu thô nguyên bản từ hệ thống nguồn. Dữ liệu được nhập từ các tệp CSV vào cơ sở dữ liệu SQL Server.

Lớp Silver: Bao gồm các bước làm sạch, chuẩn hóa và biến đổi dữ liệu để sẵn sàng cho phân tích.

Lớp Gold: Chứa dữ liệu đã được xử lý, sẵn sàng sử dụng trong kinh doanh và được mô hình hóa theo dạng star schema phục vụ cho báo cáo và phân tích.
## Tổng Quan Dự Án
Dự án này bao gồm:

Kiến trúc Dữ liệu: Thiết kế kho dữ liệu hiện đại theo kiến trúc Medallion với các lớp Bronze, Silver, và Gold.

Quy trình ETL: Trích xuất, biến đổi và tải dữ liệu từ hệ thống nguồn vào kho dữ liệu.

Mô hình hóa Dữ liệu: Phát triển các bảng fact và dimension được tối ưu cho các truy vấn phân tích.

Phân tích & Báo cáo: Tạo báo cáo và dashboard dựa trên SQL để đưa ra thông tin có thể hành động.

## Yêu Cầu Dự Án
Xây Dựng Kho Dữ Liệu (Kỹ Thuật Dữ Liệu)
Mục Tiêu
Phát triển một kho dữ liệu hiện đại sử dụng SQL Server để tập hợp dữ liệu bán hàng, phục vụ cho phân tích và ra quyết định.

Yêu Cầu Chi Tiết
Nguồn Dữ Liệu: Nhập dữ liệu từ hai hệ thống nguồn (ERP và CRM) dưới dạng tệp CSV.

Chất Lượng Dữ Liệu: Làm sạch và xử lý các vấn đề chất lượng dữ liệu trước khi phân tích.

Tích Hợp: Kết hợp hai nguồn dữ liệu thành một mô hình thân thiện với người dùng, tối ưu cho các truy vấn phân tích.

Phạm Vi: Tập trung vào tập dữ liệu mới nhất; không yêu cầu lưu trữ lịch sử.

Tài Liệu: Cung cấp tài liệu rõ ràng về mô hình dữ liệu cho cả người dùng doanh nghiệp và nhóm phân tích.

## BI: Phân Tích & Báo Cáo (Phân Tích Dữ Liệu)
Mục Tiêu
Xây dựng các truy vấn SQL để cung cấp thông tin chi tiết về:

Hành vi Khách hàng

Hiệu suất Sản phẩm

Xu hướng Doanh số

Những phân tích này giúp các bên liên quan nắm bắt các chỉ số kinh doanh quan trọng, từ đó ra quyết định chiến lược.
