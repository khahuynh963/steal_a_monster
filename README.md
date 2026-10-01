# 🦖 STEAL A MONSTER HUB - BẢN TINH GỌN (LITE & SPEED EDITION) V2.2

Script tối ưu hóa chuyên biệt cho tựa game **[🦖] Ăn cắp một con quái vật! (Steal a Monster!)** trên Roblox (nhóm phát triển **Oops Again**).

Được tinh gọn 100% theo yêu cầu, sửa triệt để lỗi giật lùi (rubberbanding) khi chạy nhanh và lỗi không nhặt được quái:
* **⚡ Tốc Độ Chạy Siêu Mượt (Smooth Physics Speed Boost - Chống Giật Lùi 100%)**: Sử dụng động cơ đẩy `AssemblyLinearVelocity` chuẩn hệ thống vật lý Roblox replication. Loại bỏ hoàn toàn CFrame offset thô, chấm dứt triệt để hiện tượng bị giật ngược ra sau (rubberbanding / rollback)!
* **🥷 Cướp quái 1 chạm (Auto-Hold 1-Tap)**: Script tự động thay bạn giữ nút đúng thời lượng server yêu cầu (1.2s), bạn chỉ cần chạm 1 lần mà không cần giữ tay!
* **Nút nổi ⚡ Cướp Nhanh**: Chạm nút ⚡ trên màn hình là tự động bế ngay quái vật gần nhất.
* **Chống Phát Hiện Tốc Độ An Toàn**: Ngụy trang WalkSpeed = 16, không can thiệp __newindex tránh lỗi kẹt trạng thái bế quái vật.
* **Chống Treo Máy 24/7**: Chống bị văng game sau 20 phút.

Tương thích mượt mà 100% cho **Delta Executor (Android & PC)**, Codex, Wave, Hydrogen, Fluxus và Solara.

---

## 🚀 Cách Sử Dụng (Script Execution Command)

Chỉ cần sao chép lệnh loader bên dưới và dán vào Executor của bạn (Delta / Codex / Wave / Fluxus):

```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/khahuynh963/steal_a_monster/main/loader.lua"))()
```

Hoặc nạp trực tiếp file script chính:

```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/khahuynh963/steal_a_monster/main/script.lua"))()
```

---

## 🌟 4 Tính Năng Cốt Lõi Duy Nhất

| Tính Năng | Chi Tiết Hoạt Động |
|---|---|
| 🥷 **1 Nhấn Lấy Quái Vật (Auto-Hold 1-Tap)** | • **Tự Động Giữ Nút Chuẩn Server**: Server yêu cầu giữ nút 1.2s để bế quái. Script sẽ tự động duy trì giữ nút thay bạn, bạn **chỉ cần bấm/chạm 1 lần duy nhất** là thả tay ra được ngay!<br>• **Ghim Đứng Yên Chống Trượt**: Tự động triệt tiêu quán tính và khóa vị trí cạnh quái vật trong 1.2s để không bị trượt ra xa làm hủy cướp.<br>• **Nút Nổi "⚡ CƯỚP NHANH" Trên Màn Hình**: Chạy vào căn cứ đối thủ chỉ cần ấn nút ⚡ là tự động nhặt quái vật gần nhất, không cần chạm trúng nút nhỏ trên màn hình! |
| ⚡ **Tăng Tốc Độ Chạy Siêu Mượt (Smooth Physics Speed Boost)** | • **Hệ thống 6 cấp độ tốc độ tùy chọn**: `Speed 35 (Êm Ái)` ➔ `Speed 60 (Siêu Tốc)` ➔ `Speed 90 (Cuồng Phong)` ➔ `Speed 125 (Tia Chớp)` ➔ `Speed 165 (Thần Tốc)` ➔ `Speed 220 (Max Sonic)`.<br>• **Chuẩn Vật Lý Chống Giật Lùi (Anti-Rubberband)**: Sử dụng vận tốc vật lý `AssemblyLinearVelocity` đồng bộ 100% với replication server của Roblox, loại bỏ CFrame thô giúp không bao giờ bị giật lùi về sau.<br>• **Khóa Chống Vấp Ngã (Anti-Fall/Ragdoll)**: Tự động vô hiệu hóa trạng thái vấp ngã khi lướt qua các khe địa hình, bậc thang hay gờ dốc.<br>• **Hãm Phanh Mượt Mà (Smooth Deceleration)**: Khi nhả tay khỏi phím di chuyển, nhân vật hãm phanh êm ái, không bị trượt dốc.<br>• **Tự động khôi phục khi hồi sinh**: Không bao giờ bị mất tốc độ khi chết hoặc respawn. |
| 🛡️ **Chống Phát Hiện Tốc Độ (Safe Anti-Speed Spoofer)** | • **Metatable Hooking (__index an toàn)**: Khi bất kỳ script kiểm tra hay anti-cheat nào của game đọc `Humanoid.WalkSpeed`, hệ thống luôn ngụy trang và trả về `16`.<br>• Cho phép game tự do áp dụng hiệu ứng vác quái mà không gây lỗi script nội bộ của game. |
| 💤 **Chống Treo Máy AFK 24/7 (Anti-AFK)** | • Tự động chặn sự kiện ngắt kết nối sau 20 phút không hoạt động của Roblox, giúp bạn an tâm treo máy cả ngày. |

---

## 🎨 2 Nút Nổi Tiện Lợi Trên Màn Hình Cảm Ứng

* **Nút 🦖 (Màu Xanh Ngọc)**: Chạm để ẩn / hiện Bảng Điều Khiển Cài Đặt.
* **Nút ⚡ (Màu Vàng Cam)**: Chạm 1 lần để Tự Động Cướp Quái Vật Gần Nhất ngay lập tức!
* Cả 2 nút đều có thể **kéo thả tự do** đến bất kỳ vị trí nào trên màn hình bạn muốn.

---

## 🌐 Thông Tin Repository
* **GitHub Repository**: `https://github.com/khahuynh963/steal_a_monster.git`
* **Tác giả**: `khahuynh963`
