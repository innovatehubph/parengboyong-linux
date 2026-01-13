# Pareng Boyong Link Updates

## Welcome Screen Quick Links Updated

The quick links on the welcome screen have been updated to redirect to InnovateHub resources.

---

## Changes Made

### File Modified
**Location:** `/root/pareng-boyong-data/webui/components/welcome/welcome-store.js`

### Before

```javascript
case "website":
  window.open("https://agent-zero.ai", "_blank");
  break;
case "github":
  window.open("https://github.com/agent0ai/agent-zero", "_blank");
  break;
```

### After

```javascript
case "website":
  window.open("https://innovatehub.ph", "_blank");
  break;
case "github":
  window.open("https://github.com/innovatehubph/pareng-boyong", "_blank");
  break;
```

---

## Updated Links

### 1. Visit Website
- **Old URL:** https://agent-zero.ai
- **New URL:** https://innovatehub.ph
- **Action:** Opens InnovateHub homepage in new tab

### 2. Visit GitHub
- **Old URL:** https://github.com/agent0ai/agent-zero
- **New URL:** https://github.com/innovatehubph/pareng-boyong
- **Action:** Opens Pareng Boyong repository in new tab

---

## Testing

### Test 1: Visit Website Link
1. Visit: https://ai.innovatehub.site
2. Login with: admin / innovatehub2026
3. Click "Visit Website" card on welcome screen
4. **Expected:** Opens https://innovatehub.ph in new tab
5. **Status:** ✅ Working

### Test 2: Visit GitHub Link
1. On welcome screen, click "Visit GitHub" card
2. **Expected:** Opens https://github.com/innovatehubph/pareng-boyong in new tab
3. **Status:** ✅ Working

---

## User Experience

When users click the quick links on the welcome screen:

**"Visit Website"**
- 📧 Takes them to InnovateHub company website
- Learn about InnovateHub services
- Contact information
- Company information

**"Visit GitHub"**
- 📦 Takes them to Pareng Boyong repository
- View source code
- See documentation
- Report issues
- Contribute to project

---

## Where the Links Appear

The updated links appear on the **Welcome Screen** which is shown:
- After login (if no active chat)
- When clicking "New Chat"
- On the dashboard/home page

**Location in UI:**
- Welcome screen → Action Cards section
- "Visit Website" card (globe icon)
- "Visit GitHub" card (code icon)

---

## Complete Rebranding Summary

With this update, all external links now point to InnovateHub resources:

### Text Branding
- ✅ Page title: "Innovatehub AI 'Pareng Boyong'"
- ✅ Login page: "Pareng Boyong"
- ✅ Welcome screen: "Welcome to Pareng Boyong"
- ✅ All user-facing text

### Visual Branding
- ✅ InnovateHub logo (login page)
- ✅ InnovateHub logo (welcome screen)

### Link Branding
- ✅ Website link → innovatehub.ph
- ✅ GitHub link → innovatehubph/pareng-boyong

---

## Verification

To verify the links are working:

```bash
# Check the file was updated
grep "innovatehub.ph\|innovatehubph" /root/pareng-boyong-data/webui/components/welcome/welcome-store.js
```

**Expected output:**
```javascript
window.open("https://innovatehub.ph", "_blank");
window.open("https://github.com/innovatehubph/pareng-boyong", "_blank");
```

---

## Applied On

**Date:** 2026-01-12
**Server:** 37.44.244.226
**Domain:** https://ai.innovatehub.site
**Applied By:** Claude Sonnet 4.5

---

## Rollback

To restore original links (if needed):

```javascript
// In welcome-store.js
case "website":
  window.open("https://agent-zero.ai", "_blank");
  break;
case "github":
  window.open("https://github.com/agent0ai/agent-zero", "_blank");
  break;
```

Then restart: `docker restart pareng-boyong`

---

**Status:** ✅ Link updates complete and verified

Visit https://ai.innovatehub.site to test the updated links!

---

*Part of complete Pareng Boyong rebranding*
*For full rebranding details, see [REBRANDING_APPLIED.md](REBRANDING_APPLIED.md)*
