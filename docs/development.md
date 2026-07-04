## Development

### Setting up

```bash
mise install            # ติดตั้ง Ruby ตามเวอร์ชันใน mise.toml
cp env.example .env     # ใส่ค่า LINE LIFF credentials (dev ใช้ mock ได้ ไม่ต้องมีค่าจริง)
bin/setup               # bundle install + เตรียม database + start server
```

รันแอปแบบวันต่อวันด้วย `bin/dev` (รัน Rails server + Tailwind watcher)

### Authentication

- ผู้ใช้ทั่วไป login ผ่าน LINE LIFF เท่านั้น (หน้า `/login`)
- บน localhost ระบบจะ mock LINE ให้อัตโนมัติ (ได้ user ชื่อ "Mock User") ไม่ต้องมี LINE account จริง
- ทุกหน้า events ต้อง login ก่อน ไม่งั้นจะถูก redirect ไป `/login`

### Admin (Avo)

หน้า admin อยู่ที่ `/avo` เข้าได้เฉพาะ user ที่มี `admin: true` โดย login ได้ 2 ทาง:

1. **ผ่าน LINE** — login ปกติ แล้วให้ admin คนอื่นติ๊ก admin ให้ใน Avo (หรือใช้ console)
2. **ผ่าน email/password** — ที่หน้า `/admin/login` (เหมาะกับ desktop นอกแอป LINE)

สร้าง admin คนแรกผ่าน console:

```bash
bin/rails console
```

```ruby
# แบบ email/password (password อย่างน้อย 8 ตัวอักษร)
User.create!(email: "admin@example.com", password: "changeme123", admin: true)

# หรือ promote user ที่ login ผ่าน LINE อยู่แล้ว
User.find_by(display_name: "Mock User").update!(admin: true)
```
