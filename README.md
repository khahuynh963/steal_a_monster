# 🦖 STEAL A MONSTER HUB - ĂN CẮP MỘT CON QUÁI VẬT! V1.0

Script hỗ trợ tự động hóa toàn diện cho tựa game **[🦖] Ăn cắp một con quái vật! (Steal a Monster!)** trên Roblox, phát triển bởi nhóm **Oops Again**.

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

## 🎮 Cơ Chế Cốt Lõi Của Game "Ăn Cắp Một Con Quái Vật!"

1. **Băng Chuyền Quái Vật (Conveyor Belt)**:
   * Các loại quái vật từ cấp thấp đến thần thoại liên tục chạy trên băng chuyền trung tâm. Người chơi đứng cạnh để mua quái vật đưa về căn cứ.
   * Quái vật cấp cao (như *Celestial Emperor*) có thể sinh tới **$61,000,000,000/s**!
2. **Căn Cứ & Sinh Tiền (Base Income)**:
   * Quái vật nuôi trong căn cứ tự động tạo tiền vàng (Coins) theo thời gian thực.
3. **Cơ Chế Ăn Cắp Đối Thủ (Stealing Mechanics - Điểm Nhấn PvP)**:
   * Người chơi có thể đột nhập vào căn cứ đối thủ, bế quái vật lên đầu và chạy về căn cứ của mình để biến nó thành của riêng.
   * Nếu bị đối thủ tấn công hoặc dính bẫy khi đang mang quái vật, bạn sẽ bị rơi quái vật.
4. **Hệ Thống Phòng Thủ & Khóa Căn Cứ (Base Defense & Lockdown)**:
   * **Lockdown**: Khiên chắn tạm thời khóa hoàn toàn căn cứ, ngăn chặn mọi kẻ trộm đột nhập.
   * **Rebirth (Tái sinh)**: Reset tiền và quái vật để nhận vĩnh viễn thời lượng bật Lockdown lâu hơn và tăng tốc độ di chuyển.

---

## 🌟 Tổng Hợp Các Tính Năng Đã Tích Hợp

| Nhóm Tính Năng | Mô Tả Chi Tiết |
|---|---|
| 🥷 **Auto Steal Monsters** | • Tự động quét toàn bộ căn cứ của người chơi khác trong server.<br>• Ưu tiên chọn quái vật giá trị cao nhất.<br>• Tự động dịch chuyển tiếp cận, bế quái vật lên đầu và tẩu thoát về căn cứ an toàn.<br>• **Avoid Lockdown**: Tự động né các căn cứ đang bật khiên bảo vệ. |
| 🛒 **Auto Buy Conveyor** | • Tự động quét và mua quái vật trên băng chuyền trung tâm ngay khi xuất hiện.<br>• Hỗ trợ bộ lọc độ hiếm tối thiểu (`Rare+`, `Epic+`, `Legendary+`, `Celestial+`). |
| 💰 **Auto Collect Coins** | • Tự động thu thập toàn bộ tiền vàng do quái vật trong căn cứ sinh ra mà không cần chạy bộ giẫm ô. |
| 🚨 **Auto Base Defense** | • Tự động phát hiện khi có kẻ lạ bước vào bán kính căn cứ của bạn.<br>• Tự động kích hoạt **Lockdown** ngay lập tức để bảo vệ đàn quái vật khỏi bị cướp. |
| 🔄 **Auto Rebirth** | • Tự động kích hoạt Tái sinh khi đạt đủ số tiền để tăng thời gian Lockdown vĩnh viễn. |
| ⚡ **Tiện Ích Tẩu Thoát & PvP** | • **Super Speed Boost**: Hệ thống 6 cấp độ tốc độ (`Speed 40` ➔ `Speed 75` ➔ `Speed 120` ➔ `Speed 180` ➔ `Speed 250` ➔ `Speed 350 Max Flash God`) giúp tẩu thoát thần tốc khi bế quái vật.<br>• **Gia Tốc CFrame**: Bỏ qua cơ chế game làm chậm khi mang vác quái vật, lướt siêu êm trên mọi địa hình.<br>• **Infinite Jump**: Nhảy liên tục trên không để vượt tường rào căn cứ.<br>• **Noclip**: Đi xuyên tường rút ngắn quãng đường tẩu thoát. |
| 🛡️ **Anti-AFK & FPS Booster** | • **Anti-AFK 24/7**: Chống bị văng game sau 20 phút khi treo máy cày tiền.<br>• **FPS Booster 60 FPS**: Tối ưu đồ họa siêu mượt cho điện thoại Android chạy Delta. |
| 🦖 **Giao Diện Di Động** | • Nút tròn thu nhỏ hình chú khủng long 🦖 kéo thả tự do, ẩn/hiện menu chỉ với 1 chạm. |

---

## 🌐 Thông Tin Repository
* **GitHub Repository**: `https://github.com/khahuynh963/steal_a_monster.git`
* **Tác giả**: `khahuynh963`
