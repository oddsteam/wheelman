# Events & Roles

เอกสารนี้อธิบายฟีเจอร์ event (สร้าง / เข้าร่วม / ดูรายการ) และระบบ role/permission

## Roles

ผู้ใช้ทุกคนมี `role` (แยกจากธง `admin` ที่ใช้คุมสิทธิ์เข้า `/avo`)
ผู้ใช้ที่ login ผ่าน LINE LIFF ครั้งแรกจะได้ role เป็น **guest** โดยอัตโนมัติ
admin เป็นคนกำหนด role ให้ผู้ใช้ในหน้า Avo

มี 4 roles:

| Role | ดูรายการ event | ดูรายละเอียด | เข้าร่วม (join/leave) | สร้าง event |
|------|:--:|:--:|:--:|:--:|
| **guest** (ค่าเริ่มต้น) | ✓ | ✗ | ✗ | ✗ |
| **athlete** | ✓ | ✓ | ✓ | ✗ |
| **supporter** | ✓ | ✓ | ✓ | ✓ |
| **coach** | ✓ | ✓ | ✓ | ✓ |

หมายเหตุ: user ที่มี `admin: true` ทำได้ทุกอย่าง (admin ⇒ ทุกสิทธิ์)

### กำหนด role ให้ user

1. เข้า `/avo` (ดูวิธี login ที่ [development.md](./development.md#admin-avo))
2. เมนู **Users** → เลือก user → แก้ช่อง **Role** → Save

หรือผ่าน console:

```ruby
User.find_by(display_name: "...").update!(role: "athlete")
```

## ฟีเจอร์ Event

### ดูรายการ (ทุก role)
หน้า `/events` แสดง event ได้ทั้งแบบ **list** และ **calendar** (สลับด้วยปุ่มไอคอนมุมขวาบน)
guest เห็นรายการได้แต่กดเข้าไปดูรายละเอียดไม่ได้ (การ์ด/ชิปจะกดไม่ได้)

### สร้าง event (supporter / coach)
ปุ่มสร้าง (ไอคอน +) จะแสดงเฉพาะ role ที่สร้างได้ → หน้า `/events/new`
event ที่สร้างจะบันทึก **ผู้สร้าง (creator)** ไว้ → ผู้สร้าง (หรือ admin) ลบ event นั้นได้

### เข้าร่วม / ออกจาก event (athlete / supporter / coach)
ในหน้ารายละเอียด event มีปุ่ม **Confirm & Join!** → กดแล้วเข้าร่วม, ปุ่มจะเปลี่ยนเป็น **Joined · Leave**
หน้ารายละเอียดแสดงจำนวนคนที่เข้าร่วมด้วย
เข้าร่วม event เดิมซ้ำไม่ได้ (unique ต่อ user+event)

### My Events
หน้า `/events/me` แสดง event ที่ "เราเข้าร่วม" พร้อมปุ่ม **Leave** สำหรับออกจาก event

## โครงสร้างข้อมูล (data model)

- `users.role` — enum: guest / supporter / coach / athlete (default guest)
- `events.user_id` — creator (nullable; event เก่าไม่มี creator)
- `event_participations` — ตาราง join ระหว่าง user ↔ event (unique index บน `[user_id, event_id]`)

associations:
- `User has_many :joined_events` (ผ่าน event_participations), `has_many :created_events`
- `Event belongs_to :user` (creator), `has_many :participants`

## Permission ทำงานที่ไหน

การเช็คสิทธิ์อยู่ที่ [events_controller.rb](../app/controllers/events_controller.rb) ผ่าน
`before_action` ที่เรียก capability methods บน [User](../app/models/user.rb):
`can_view_event_details?`, `can_join_events?`, `can_create_events?`
ถ้าไม่มีสิทธิ์จะถูก redirect กลับหน้า `/events` พร้อมข้อความ alert
ฝั่ง view ก็ซ่อนปุ่ม/ลิงก์ตาม capability เดียวกัน (ปุ่มสร้าง, ลิงก์เข้า detail, ปุ่ม join/delete)
