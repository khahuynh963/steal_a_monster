# 🦖 STEAL A MONSTER HUB - BẢN TINH GỌN (LITE & SPEED EDITION) V2.0

Script tối ưu hóa chuyên biệt cho tựa game **[🦖] Ăn cắp một con quái vật! (Steal a Monster!)** trên Roblox (nhóm phát triển **Oops Again**).

Được tinh gọn 100% theo yêu cầu: Loại bỏ hoàn toàn các tính năng dư thừa, chỉ tập trung tối đa vào **Tốc Độ Thần Tốc**, **Cướp Quái 1 Chạm Tức Thì**, **Chống Phát Hiện Tốc Độ** và **Chống Treo Máy 24/7**.

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
| 🥷 **1 Nhấn Lấy Quái Vật (Instant 1-Click Steal)** | • **Xóa thời gian giữ (HoldDuration = 0s)**: Không còn phải đứng yên nhấn giữ 1.0s – 1.5s như bình thường.<br>• **Mở rộng tầm với (Range 35 studs)**: Tầm tương tác xa hơn, không yêu cầu góc nhìn thẳng (lấy xuyên góc kẹt).<br>• **Chạm 1 lần là bế ngay**: Chỉ cần lướt qua hoặc chạm nhẹ 1 cái vào nút là bế ngay quái vật lên đầu lập tức! |
| ⚡ **Tăng Tốc Độ Chạy (Super Speed Boost)** | • **Hệ thống 6 cấp độ tốc độ tùy chọn**: `Speed 40 (Nhanh)` ➔ `Speed 70 (Siêu Tốc)` ➔ `Speed 110 (Cuồng Phong)` ➔ `Speed 160 (Tia Chớp)` ➔ `Speed 220 (Thần Tốc)` ➔ `Speed 300 (Max Flash God)`.<br>• **Gia tốc CFrame mượt mà**: Lướt êm ái trên mọi địa hình, bỏ qua cơ chế game làm chậm khi đang bế quái vật nặng.<br>• **Tự động khôi phục khi hồi sinh**: Không bao giờ bị mất tốc độ khi chết hoặc respawn. |
| 🛡️ **Chống Phát Hiện Tốc Độ (Anti-Speed Detect Spoofer)** | • **Metatable Hooking (__index & __newindex)**: Khi bất kỳ script kiểm tra hay anti-cheat nào của game đọc `Humanoid.WalkSpeed`, hệ thống luôn trả về `16` (giá trị bình thường an toàn).<br>• Chống tình trạng game tự động hạ tốc độ hoặc kick khỏi phòng chơi khi di chuyển quá nhanh. |
| 💤 **Chống Treo Máy AFK 24/7 (Anti-AFK)** | • Tự động chặn sự kiện ngắt kết nối sau 20 phút không hoạt động của Roblox, giúp bạn an tâm treo máy cả ngày. |

---

## 🎨 Giao Diện Tinh Gọn & Thân Thiện Cho Điện Thoại

* **Nút Tròn Thu Nhỏ (Floating Button 🦖)**: Dễ dàng kéo thả bất kỳ vị trí nào trên màn hình cảm ứng, chạm 1 cái để mở/đóng bảng điều khiển.
* **Menu 4 Tùy Chọn Tinh Gọn**: Giao diện tối giản, nhẹ nhàng, không chiếm tài nguyên máy.
* **Thanh Trạng Thái (Live Status Banner)**: Báo cáo số lần cướp quái vật và trạng thái tốc độ theo thời gian thực.

---

## 🌐 Thông Tin Repository
* **GitHub Repository**: `https://github.com/khahuynh963/steal_a_monster.git`
* **Tác giả**: `khahuynh963`
