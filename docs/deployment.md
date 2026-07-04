# Deployment

Wheelman แยก environment เป็น **dev** และ **production** ด้วย Kamal destinations
โดยไฟล์ config แบ่งเป็น:

| ไฟล์ | หน้าที่ |
|---|---|
| `config/deploy.yml` | ค่าที่ใช้ร่วมกัน (image, registry, ssh, volume, env) — **ไม่มี server** |
| `config/deploy.dev.yml` | dev VM (ไม่มี SSL — ทดสอบ HTTPS ผ่าน quick tunnel) |
| `config/deploy.production.yml` | prod VM + โดเมน + SSL |

ทุกคำสั่งต้องระบุ destination เสมอ — สั่ง `bin/kamal deploy` เฉย ๆ จะ error ทันที
เพื่อป้องกันการ deploy ขึ้น production โดยไม่ตั้งใจ:

```bash
bin/kamal deploy -d dev          # ขึ้น dev
bin/kamal deploy -d production   # ขึ้น production
```

สถาปัตยกรรมเป้าหมาย (production): **Cloudflare (free) → GCP e2-micro VM → Kamal**

**ค่าใช้จ่ายโดยประมาณ:** e2-micro ตัวแรกฟรี (always-free tier — จำกัด 1 ตัว/บัญชี ถ้ามีทั้ง dev
และ prod ตัวที่สองจะ ~$7/เดือน), external IPv4 ~$3–4/เดือน/ตัว, โดเมน ~$10/ปี,
Cloudflare / GHCR / GitHub Actions ฟรี

---

## Dev environment (ทำก่อน — ไว้ทดสอบทุกอย่างบน server จริง)

### 1. สร้าง dev VM บน GCP

1. **Compute Engine → Create Instance:**
   - Machine type: **e2-micro**
   - Region: **us-central1** (หรือ us-west1 / us-east1 — free tier จำกัดแค่ 3 region นี้)
   - Boot disk: **Ubuntu 24.04 LTS**, Standard persistent disk **30 GB**
   - Firewall: ติ๊ก **Allow HTTP** และ **Allow HTTPS**
2. จด **External IP** แล้วใส่ใน `config/deploy.dev.yml` แทนที่ `<DEV_VM_IP>`
3. สร้าง SSH key สำหรับ deploy:

   ```bash
   ssh-keygen -t ed25519 -f ~/.ssh/wheelman_deploy -C "deploy"
   ```

   เอา public key ไปใส่ใน VM → Edit → SSH Keys (บรรทัดต้องขึ้นต้นด้วย `deploy:`
   เพื่อให้ GCP สร้าง user ชื่อ `deploy`)
4. เตรียม Docker บน VM (ครั้งเดียว):

   ```bash
   ssh -i ~/.ssh/wheelman_deploy deploy@<DEV_VM_IP>
   curl -fsSL https://get.docker.com | sudo sh
   sudo usermod -aG docker deploy
   exit
   ```

### 2. Deploy ขึ้น dev (จากเครื่องตัวเอง)

ต้องมีใน `.env` (หรือ export ใน shell): `KAMAL_REGISTRY_PASSWORD` (GitHub PAT ที่มี
`write:packages`) และ `LINE_CHANNEL_SECRET` — ส่วน `RAILS_MASTER_KEY` อ่านจาก
`config/master.key` ให้อัตโนมัติ

```bash
set -a && source .env && set +a
bin/kamal setup -d dev      # ครั้งแรก (ติดตั้ง kamal-proxy + deploy)
bin/kamal deploy -d dev     # ครั้งถัด ๆ ไป
```

หมายเหตุ: เครื่อง Mac (arm64) ต้อง cross-build เป็น amd64 — build ครั้งแรกช้า (~10–20 นาที)
และต้องเปิด Docker Desktop ไว้

เช็คว่าขึ้นแล้ว: `curl http://<DEV_VM_IP>/up` ต้องได้ 200
(หน้าอื่นเข้าผ่าน IP ตรง ๆ ไม่ได้เพราะ `force_ssl` จะ redirect ไป https — ให้ใช้ tunnel ตามข้อถัดไป)

### 3. ทดสอบ HTTPS + LINE login จริง ด้วย Quick Tunnel (ฟรี)

HTTPS บน IP เปล่า ๆ ใช้ไม่ได้ (CA ไม่ออก cert ให้ IP และ LIFF ไม่รับ endpoint ที่เป็น IP)
ให้รัน tunnel บน VM:

```bash
ssh -i ~/.ssh/wheelman_deploy deploy@<DEV_VM_IP>
sudo apt install -y cloudflared || (curl -L https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64.deb -o /tmp/cf.deb && sudo dpkg -i /tmp/cf.deb)
tmux new -s tunnel
cloudflared tunnel --url http://localhost:80
```

จะได้ URL แบบ `https://xxx.trycloudflare.com` — เอาไปตั้งเป็น **LIFF Endpoint URL**
(`https://xxx.trycloudflare.com/login`) ใน LINE Developers console แล้วเปิด
`https://liff.line.me/<LIFF_ID>` ในแอป LINE เพื่อทดสอบ login จริง
(บน server เป็น RAILS_ENV=production จึงตรวจ token กับ LINE จริง ไม่ใช้ mock)

URL ของ quick tunnel เปลี่ยนทุกครั้งที่รันใหม่ — ใช้สำหรับทดสอบเท่านั้น

### 4. สร้าง admin คนแรกบน dev

```bash
bin/kamal console -d dev
# User.create!(email: "admin@example.com", password: "...", admin: true)
```

แล้วเข้า `https://<tunnel>/avo` เพื่อทดสอบหน้า admin

### คำสั่งที่ใช้บ่อย

```bash
bin/kamal app logs -d dev      # ดู log (หรือ bin/kamal logs -d dev tail สด)
bin/kamal console -d dev       # Rails console บน server
bin/kamal shell -d dev         # bash ใน container
bin/kamal remove -d dev        # รื้อทั้งหมดออกจาก VM (ล้าง state ทดสอบ)
```

ข้อมูล (SQLite + รูป) อยู่ใน Docker volume `wheelman_storage` — รอดข้าม deploy
แต่จะหายถ้าสั่ง `remove` หรือลบ VM

---

## Production (ทำทีหลัง เมื่อ dev ผ่านหมดแล้ว)

1. **VM:** สร้าง prod VM แบบเดียวกับ dev (หรือ promote dev VM เป็น prod) แล้วใส่ IP ใน
   `config/deploy.production.yml` แทนที่ `<PROD_VM_IP>` + เตรียม Docker เหมือนเดิม
2. **Cloudflare:** สมัคร free plan → ซื้อโดเมนผ่าน Registrar (~$10/ปี) → ใส่โดเมนแทน
   `<YOUR_DOMAIN>` ใน `config/deploy.production.yml`
   - DNS: `A @ → <PROD_VM_IP>` และ `A www → <PROD_VM_IP>` (Proxied — เมฆส้ม)
   - SSL/TLS mode: เริ่มที่ **Full** พอเว็บขึ้นแล้วเปลี่ยนเป็น **Full (strict)**
3. **LINE:** เปลี่ยน LIFF Endpoint URL เป็น `https://<โดเมน>/login`
4. **GitHub secrets** (Settings → Secrets → Actions): `SSH_PRIVATE_KEY`
   (ไฟล์ `~/.ssh/wheelman_deploy`), `RAILS_MASTER_KEY` (ไฟล์ `config/master.key`),
   `LINE_CHANNEL_SECRET`
5. **Deploy แรก:** `bin/kamal setup -d production` จากเครื่องตัวเอง แล้วสร้าง admin
   ผ่าน `bin/kamal console -d production`
6. **เปิด auto-deploy:** เอา comment ของ `workflow_run` trigger ใน
   [.github/workflows/deploy.yml](../.github/workflows/deploy.yml) ออก
   — หลังจากนั้นทุก push ขึ้น `main` ที่ CI ผ่าน จะ deploy production ให้อัตโนมัติ

## Troubleshooting

- เว็บขึ้น 502 หลัง deploy แรก: เช็คว่า Cloudflare SSL mode เป็น **Full** (ไม่ใช่ Flexible)
- Build ค้าง/ช้ามากบน Mac: ปกติสำหรับ cross-build ครั้งแรก ถ้าอยากเร็วขึ้นใช้
  remote builder บน VM (ดู `builder.remote` ใน deploy.yml)
- Backup ข้อมูล: `bin/kamal shell -d <dest>` แล้ว copy ไฟล์จาก `/rails/storage`
