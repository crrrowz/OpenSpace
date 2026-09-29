# OpenSpace MCP Guide & Reference

دليل استخدام وتشغيل خادم OpenSpace MCP والتعامل مع المهارات (Skills) وتطويرها ذاتياً.

---

## 1. البنية التحتية والتشغيل (Infrastructure)

- **نوع الخادم:** FastMCP Server (SSE Transport)
- **الحاوية:** `openspace-mcp` (Docker)
- **نقطة الوصول (Endpoint):** `http://192.168.85.129:8080/sse`
- **مسار المشروع:** `D:\files\Contracted projects\IdeaProjects\OpenSpace`

### أوامر التحكم السريع:
```powershell
# فحص حالة الحاوية
docker compose ps

# عرض السجلات اللحظية
docker compose logs -f

# إعادة تشغيل الخادم
docker compose restart

# إيقاف أو تشغيل الحاوية
docker compose down
docker compose up -d
```

---

## 2. أدوات OpenSpace MCP المتاحة

| الأداة | الوصف والغرض |
| :--- | :--- |
| `openspace_search_skills` | البحث السريع في سجل المهارات المحلي (Local Skills Registry). |
| `openspace_cloud_browse_skills` | تصفح واستكشاف المهارات وحزم السحابة وتحميلها خطوة بخطوة. |
| `openspace_execute_task` | تنفيذ مهمة برمجية/أتمتة كاملة عبر OpenSpace مع الاستفادة من المهارات وتطوير مهارات جديدة ذاتياً. |
| `openspace_upload_skill` | رفع مهارة موثوقة إلى السحابة ومشاركتها (عامة أو خاصة). |
| `openspace_fix_skill` | تشغيل دورة إصلاح وتطوير تلقائي (`FIX`) لمهارة معطلة. |
| `openspace_cloud_auth_flow` | تسجيل الدخول / إدارة مفاتيح الـ API للمزامنة السحابية. |

---

## 3. دورة حياة المهارات (Skill Evolution Lifecycle)

يقوم محرك OpenSpace بإدارة المهارات عبر 3 أنماط رئيسية:
1. **`CAPTURED`**: استخراج خطوات الحل الناجحة لمهمة جديدة لم تكن لها مهارة سابقة وتخزينها كمهارة قابلة لإعادة الاستخدام.
2. **`DERIVED`**: اشتقاق مهارة جديدة أو تحسين مهارة حالية لتغطية حالات استخدام أوسع.
3. **`FIX`**: تصحيح تلقائي للمهارات المعطلة أو التي تواجه أخطاء عند التنفيذ.

---

## 4. سيناريوهات الاستخدام والتكامل

### أ. البحث عن مهارة محلية
```json
{
  "query": "git commit helper"
}
```

### ب. تنفيذ مهمة ذكية وحفظ المهارة المستنتجة
```json
{
  "task": "Create a python script to analyze CSV logs and detect anomalies",
  "search_scope": "all"
}
```

### ج. تصفح وتحميل مهارة سحابية
1. الخطوة 1: استدعاء `openspace_cloud_browse_skills` مع `action: "search_skills"`, `query: "docker helper"`.
2. الخطوة 2: استدعاء `openspace_cloud_browse_skills` مع `action: "import_skill"`, `cloud_skill_id: "<id>"`.

---

## 5. مجلدات ومواقع التخزين الدائمة (Persistent Volumes)

- **`openspace_data`**: قواعد البيانات الداخلية وحالة التقييم (`/root/.openspace`).
- **`openspace_skills`**: مستودع المهارات المخزنة والمطورة (`/root/.agents/skills`).
- **`openspace_workspace`**: مساحة عمل تنفيذ المهام (`/workspace`).
