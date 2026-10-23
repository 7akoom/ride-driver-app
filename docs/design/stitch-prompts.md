# تطبيق الكابتن — برومبتات Google Stitch

آخر تحديث: 21 تشرين الأول 2026

## طريقة الاستخدام

متل تطبيق الراكب بالظبط:

1. افتح مشروع **جديد** بـ Stitch، نوع **Mobile App**. ما تكمّل بمشروع الراكب، لحتى ما يخلط الشاشات.
2. بأول رسالة الصق **Design Brief** و**الدفعة 1** مع بعض.
3. لكل دفعة جديدة بنفس المشروع، الصق **الدفعة** لحالها. إذا بلّش يخرب الألوان أو الخط، الصق الـ brief مرة تانية قبلها.
4. كل التصميم **عربي RTL ووضع فاتح** أول شي. بعد الدفعات السبعة:
   - **الوضع الغامق** على 5 شاشات بس. الكابتن بيسوق بالليل، فهون الغامق أهم من تطبيق الراكب.
   - **فحص LTR** على 3 شاشات بس.
5. صدّر كل دفعة وابعتلي ياها، وأنا بنفّذها بـ Flutter.

البرومبتات بالإنكليزي لأنو Stitch بيفهمها أدق، والنصوص جوّا الشاشات بالعربي.

**الدفعة 7** (الدردشة، الاتصال، تعديل الوجهة) بتتصمم هلق مع الراكب، بس باك إندها بينعمل بعدين (B4، B5، B8). منصممها هلق لحتى ينبنوا الطرفين على نفس الشكل.

---

## Design Brief (الصقه بأول جلسة)

```
DESIGN BRIEF — Captain (driver) app for a ride-hailing platform (white-label)

PRODUCT
The app drivers ("captains", كابتن) use to take trips, in Iraq (Erbil first). It is the twin of an existing Rider app and shares its design system exactly. Single country, single currency per deployment: Iraqi Dinar, written "د.ع" after the number (e.g. "6,000 د.ع"). Sold to different operators under their own brand: the gold accent is a swappable brand token; everything else is fixed.

WHO USES IT AND WHERE
A driver in a car, phone in a dashboard holder, often at night, glancing for a second. So: big type for the one number that matters on each screen, high contrast, tap targets at least 56 high for anything used while driving, one primary action per screen, nothing that needs reading while moving. Actions that cannot be undone while driving (start trip, end trip, no-show) are "slide to confirm" bars, not buttons.

LANGUAGES & DIRECTION
Arabic (default, RTL), Kurdish Sorani (RTL), English (LTR). Design every screen in Arabic RTL: text right-aligned, back arrow on the RIGHT pointing right (→), list chevrons point LEFT (‹), slide-to-confirm bars slide from RIGHT to LEFT. Numbers, prices, distances, times, plate numbers and phone numbers stay Western digits (0-9) and LTR inside RTL text. The map and turn arrows never mirror.

VISUAL DIRECTION
Same as the Rider app: premium, calm, "night drive" — not playful. Map-first: the map is the canvas; content lives in rounded bottom sheets. Generous whitespace. No gradients except a subtle gold glow on the earnings/wallet hero card. No stock photos; vehicle images are clean 3D-style side views of generic cars without brand logos.

COLOUR TOKENS — LIGHT MODE (design in this first)
- background #F7F6F2, surface #FFFFFF, surface-2 #F1EFE9, border #E6E2D8
- text-primary #05070F, text-secondary #4A5060, text-tertiary #8A90A0
- brand #F3D59A (gold, fills only: primary buttons, the online toggle when online, selected chip, active tab, slide-to-confirm track). Text/icons on gold are always #05070F.
- brand-strong #8A6A2B (gold for text, links, icons on light backgrounds)
- ink #05070F (dark navy: bottom navigation, offer card header, "online" status bar, secondary filled buttons with white text)
- info / route #2563EB (route line, links, info badges)
- success #15803D, warning #B45309, danger #DC2626 (10% tint backgrounds for banners)
- pickup marker = ink circle with white person icon; drop-off marker = gold square with ink flag; stop marker = white circle with ink number.
- driver's own car on the map = top-down car icon in ink with a gold outline, rotating with heading.

COLOUR TOKENS — DARK MODE (later)
background #05070F, surface #0D1220, surface-2 #151B2C, border rgba(255,255,255,0.08), text-primary #FFFFFF, text-secondary #9BA1B0, text-tertiary #6B7280, brand #F3D59A (text on it #05070F), brand-strong #F3D59A, info #60A5FA, success #4ADE80, warning #FBBF24, danger #F87171. Dark map style.

TYPOGRAPHY
IBM Plex Sans Arabic for Arabic/Kurdish, IBM Plex Sans for Latin.
Display 40/48 bold (the one number that matters: earnings today, fare to collect, offer countdown), Display-S 32/40 bold, H1 24/32 bold, H2 20/28 semibold, H3 17/24 semibold, Body 15/22, Caption 13/18, Micro 11/14 medium. Money uses tabular figures.

SHAPE & SPACING
4-pt grid; side padding 16; card padding 16; section gap 24.
Radius: buttons 14, cards 16, bottom sheets 24 (top corners), chips full pill, inputs 12, icon buttons 12.
Elevation: only bottom sheets, the offer card and floating map buttons get a soft shadow (0 8 24 rgba(5,7,15,0.10)); cards are flat with a 1px border.

COMPONENTS
- Primary button: full width, 56 high, gold fill, ink text, semibold 17.
- Secondary button: full width, 56 high, surface with 1px border, ink text.
- Destructive: danger text, or danger-outline button.
- Slide to confirm: 64 high pill, gold track with ink label ("اسحب لبدء الرحلة"), a round ink knob with a white arrow on the RIGHT end that slides left; a "done" state turns the whole bar success green with a check.
- Online toggle: a large pill at the bottom of Home. Offline = ink fill, white text "اتصل الآن". Online = gold fill, ink text "متصل" with a small pulsing dot. While switching: three hopping dots.
- Top bar: 44×44 back button (→ on the right), title right-aligned, optional action on the left.
- Bottom navigation (4 tabs, ink background, white icons, active = gold icon + label): الرئيسية، الأرباح، المحفظة، الحساب. Hidden during a trip and on pushed screens.
- List row: 56-64 high, icon in a 40×40 surface-2 square on the right, title + caption, chevron ‹ on the left.
- Chips: pill, surface-2; selected = ink fill, white text.
- Status pills: tinted background + coloured text: "قيد المراجعة" (warning), "مقبول" (success), "مرفوض" (danger), "ينتهي قريباً" (warning), "منتهي" (danger), "ناقص" (neutral).
- Rider card (during a trip): initials avatar circle 48 in surface-2, first name, ★ rating, payment chip ("نقداً" / "المحفظة"), round 52×52 buttons: call and chat.
- Plate badge: one style everywhere — number + city in a bordered rectangle (ink border, bold).
- Amount entry: huge centred number (Display 48) with small "د.ع", numeric keypad 1 2 3 left-to-right (keypads never mirror).
- Banners: tinted background + icon + one line + optional action.
- Skeleton shimmer for loading (never spinners); buttons waiting on an action show three hopping dots.
- Icons: Phosphor-style outline 24px, 1.5 stroke; filled only for the active tab.

MAP
Self-hosted OpenStreetMap vector style (light grey roads, minimal POIs, Arabic labels). No Google logo. Floating 44×44 white rounded controls: recentre, zoom to route, and "open in navigation app" (an arrow-turn icon). Route line 6px info blue; the part already driven fades to grey. A small next-turn card at the top during navigation: turn arrow, distance "350 م", street name.

STATES TO SHOW WHERE RELEVANT
loading (skeleton), empty, error with retry, disabled (surface-2 + text-tertiary), offline from the internet (a thin danger bar at the top: "لا يوجد اتصال بالإنترنت").

DEVICE
Android phone, 390×844, status bar visible, gesture nav bar at the bottom.

DO NOT
No English titles inside Arabic screens, no invented statistics or slogans ("دعم 24/7", "أفضل سائق", acceptance-rate badges, levels like "Gold captain"), no heat-map of demand, no ads. The app name "كابتن" and the logo are placeholders that come from the operator's settings.
```

---

## الدفعة 1 — الدخول والتسجيل والوثائق

```
Using the design brief, create these 9 screens (Arabic, RTL, light mode):

1. Splash — ink background, centred logo placeholder (gold rounded mark + wordmark "كابتن"), a small gold glow, nothing else.

2. Phone number — back button. Title "أدخل رقم هاتفك", subtitle "سنرسل لك رمز تحقق عبر واتساب". Phone field with a fixed, non-editable "+964" part (Iraq flag) and "7XX XXX XXXX". Checkbox line "أوافق على الشروط وسياسة الخصوصية" (links in brand-strong). Primary "إرسال الرمز", disabled until valid. Numeric keypad open. (Language is picked on a small sheet from a globe button at the top-left, not a separate screen.)

3. OTP — "أدخل رمز التحقق", "أرسلنا رمزاً من 6 أرقام إلى +964 750 123 4567" with a "تعديل" link, six digit boxes (LTR order), active box gold border, "إعادة الإرسال بعد 0:45" turning into a link. Plus an error variant: danger borders + "الرمز غير صحيح، حاول مرة أخرى".

4. Join as a captain — a short intro: 3D car illustration, H1 "انضم ككابتن", three short rows with icons: "سجّل بياناتك وبيانات سيارتك"، "ارفع صور الوثائق"، "ننتظر موافقة فريقنا ثم تبدأ". Primary "ابدأ التسجيل".

5. Registration — step 1 of 3 "بياناتك": stepper at the top (3 dots, first gold). Inputs: "الاسم كما في البطاقة الوطنية", gender segmented "ذكر / أنثى", "تاريخ الميلاد" (date field), "الجنسية" (select, "العراق"). Caption "الاسم يُقفل بعد الموافقة على حسابك". Primary "التالي".

6. Registration — step 2 of 3 "سيارتك": inputs "الشركة المصنّعة" (e.g. تويوتا), "الموديل" (كورولا), "سنة الصنع" (2019), "اللون" (a row of colour dots + name), "رقم اللوحة" (formatted plate badge preview updates as you type: "22 A 25626 أربيل"), class radio cards "اقتصادي" / "مريح" with a caption "قد يغيّرها فريق المراجعة حسب السيارة". Primary "التالي".

7. Registration — step 3 of 3 "الوثائق": a checklist of required documents, each row: icon, name, status pill on the left, chevron:
   "الصورة الشخصية" (مقبول — not yet, show "ناقص"), "البطاقة الوطنية (الوجه)" (قيد المراجعة), "البطاقة الوطنية (الظهر)" (ناقص), "إجازة السوق (الوجه)" (ناقص), "إجازة السوق (الظهر)" (ناقص), "سنوية السيارة (الوجه)" (مرفوض, with one line under it in danger: "الصورة غير واضحة"), "سنوية السيارة (الظهر)", "صورة السيارة (من الأمام)", "صورة السيارة (من الخلف)".
   A progress line at the top: "3 من 9 مرفوعة". Primary "إرسال للمراجعة" disabled until all are uploaded.

8. Upload a document (opened from a row) — title "إجازة السوق (الوجه)". A large photo frame with a dashed border and an ID-card shaped guide, buttons "التقاط صورة" (camera) and "اختيار من المعرض". After a photo: the image with "إعادة التقاط". Inputs that appear only for documents that need them: "رقم الإجازة" and "تاريخ الانتهاء" (date). Caption "تأكد أن كل الكتابة واضحة وبدون انعكاس ضوء". Primary "رفع الوثيقة" (with hopping dots while uploading, and a thin progress bar on the image).

9. Account status — three variants side by side:
   a) Under review: hourglass line illustration, H2 "حسابك قيد المراجعة", body "سنرسل لك إشعاراً عند الموافقة. يمكنك تعديل وثائقك في هذه الأثناء.", secondary "عرض الوثائق".
   b) Rejected: danger-tint card "تم رفض طلبك" + the reason from the team "رقم اللوحة لا يطابق السنوية", primary "تعديل البيانات وإعادة الإرسال", text link "تواصل مع الدعم".
   c) Approved: success check, H2 "أهلاً بك كابتن!", body "حسابك جاهز. اتصل لتبدأ باستقبال الرحلات.", primary "ابدأ".
```

---

## الدفعة 2 — الرئيسية والاتصال وعرض الرحلة

```
Using the design brief, create these 8 screens (Arabic, RTL, light mode):

1. Home — offline: full-screen map around the driver's car icon. Top: a slim ink status bar "غير متصل" with a grey dot; floating buttons: notifications bell with an unread dot (top-left), recentre. Bottom sheet (small): row of two compact stats "أرباح اليوم 24,500 د.ع" and "رحلات اليوم 6" (tapping opens Earnings); under it the big online toggle in its offline state "اتصل الآن". Bottom navigation: الرئيسية active.

2. Home — online, waiting: same map, the status bar turns gold "متصل — نبحث لك عن رحلات" with a pulsing dot; a soft gold radar pulse around the car. Sheet: the same two stats, and the toggle in its online state "متصل" with a small caption under it "اضغط لقطع الاتصال".

3. Cannot go online — the toggle was pressed but the account is blocked. Bottom sheet with one of these cards (show three variants stacked as separate frames):
   a) Documents: warning icon, "لا يمكنك الاتصال الآن", "انتهت صلاحية إجازة السوق في 18 تشرين الأول"، primary "تحديث الوثيقة".
   b) Wallet: danger icon, "حسابك موقوف مؤقتاً", "رصيد محفظتك ‎-26,000 د.ع وتجاوز الحد المسموح. اشحن 6,000 د.ع على الأقل لتعود."، primary "شحن المحفظة", secondary "الدفع نقداً في المكتب".
   c) Location: "اسمح بالوصول إلى موقعك طوال الوقت" with body "نحتاج موقعك حتى والتطبيق في الخلفية، لنرسل لك الرحلات القريبة ونُظهر للراكب أين أنت."، primary "فتح الإعدادات".

4. Incoming trip offer — the most important screen. The map shows the driver's car, a dotted line to the pickup marker, and the trip route to the drop-off in blue. A large card fills the lower 60%:
   - Top of the card (ink background, white text): a circular 15-second countdown ring in gold on the left with "12" inside; on the right "رحلة جديدة" and class chip "اقتصادي".
   - Display "6,000 د.ع" with a payment chip "نقداً" next to it.
   - Pickup block: ink dot icon, "يبعد 4 دقائق · 1.2 كم" (H3), address "شارع 60، قرب فاميلي مول" (Body, 2 lines max).
   - Drop-off block: gold square icon, "الرحلة 18 دقيقة · 9.4 كم", address "مطار أربيل الدولي".
   - A chip row when relevant: "محطة واحدة", "لشخص آخر".
   - Primary button (gold, 64 high) "قبول", and under it a text button "رفض".

5. Incoming offer — after your current trip: same card, plus a gold-tint banner at the top of the card: "بعد رحلتك الحالية · تصل للراكب بعد حوالي 11 دقيقة" with a small link icon. Pickup line reads "من نقطة نزول راكبك الحالي · 1.8 كم".

6. Offer missed — small toast-like card over the map: "فاتتك الرحلة" (text-secondary), "تُرسل الرحلات لكابتن واحد في كل مرة لمدة 15 ثانية". Auto-dismiss.

7. Notifications — list with type icons (trip, wallet, documents, account), title, body, time; unread ones with a gold dot and slight tint; "تعليم الكل كمقروء" at the top-left. Rows: "تمت الموافقة على وثيقتك: إجازة السوق"، "وثيقة تنتهي قريباً: سنوية السيارة · 12 تشرين الثاني"، "وصلتك إكرامية 1,000 د.ع"، "تم تحويل أرباحك 150,000 د.ع"، "مكافأة الأسبوع: ربحت 25,000 د.ع". Empty-state variant.

8. Language sheet — "اللغة": العربية / کوردی / English with radios, and appearance "فاتح / داكن / تلقائي".
```

---

## الدفعة 3 — أثناء الرحلة

```
Using the design brief, create these 10 screens (Arabic, RTL, light mode). Bottom navigation is hidden on all of them.

1. Heading to pickup — map 60% with navigation: next-turn card at the top ("↰ بعد 350 م · شارع الإسكان"), blue route from the car to the pickup marker, floating buttons on the left: recentre, "فتح في تطبيق الملاحة". Bottom sheet:
   - Caption "في الطريق إلى الراكب", Display-S "4 دقائق · 1.2 كم".
   - Rider card: initials "أ" avatar, "أحمد ★ 4.8", chip "نقداً", round buttons call + chat.
   - Pickup block: address, and when the rider saved details: "بناية النور، الطابق 3" + a note in a surface-2 box "البوابة الخلفية جنب الصيدلية" + a thumbnail "صورة المدخل" that opens full screen.
   - Ride for someone else variant: a small info-tint line "الراكب: سارة · +964 770 123 4567" with a call icon.
   - Primary (56) "وصلت" — enabled only near the pickup; disabled state caption "اقترب من نقطة الانطلاق (أقل من 200 م)".
   - Text danger button "إلغاء الرحلة".

2. Waiting at pickup — sheet header turns ink: "بانتظار الراكب", a big circular timer in gold "2:41" with caption "الانتظار المجاني". After the free time: a warning-tint line "بدأ احتساب الانتظار". After the no-show time: a secondary danger-outline button appears "الراكب لم يحضر". Rider card and pickup note stay visible. Slide to confirm at the bottom: "اسحب لبدء الرحلة".

3. Rider didn't come — confirm sheet: H2 "الراكب لم يحضر؟", body "انتظرت 6 دقائق. ستُلغى الرحلة ويدفع الراكب رسوم عدم الحضور 2,000 د.ع، تُضاف إلى أرباحك بعد العمولة." Slide to confirm in danger "اسحب للتأكيد", text button "متابعة الانتظار".

4. On trip — map with navigation to the destination (or the next stop). Sheet (small, glanceable): Display-S "18 دقيقة · 9.4 كم" and caption "إلى مطار أربيل الدولي"; stop chips "محطة 1 ✓" "محطة 2"; when near a stop: secondary button "وصلت إلى المحطة 2". Rider mini-row with call/chat. Slide to confirm at the bottom: "اسحب لإنهاء الرحلة". A small round danger "SOS" button floating on the map (top-left).

5. On trip — with a next trip waiting: same as 4, plus a compact gold-tint card above the slide bar: "رحلتك التالية · محمد · شارع 100 · 1.8 كم بعد النزول" with a chevron to see it.

6. Collect payment — after ending the trip. Large centred block: caption "اجمع من الراكب", Display "6,000 د.ع", chip "نقداً". Variants:
   a) Cash only (as above).
   b) Split: "دفع الراكب 2,000 د.ع من محفظته — اجمع 4,000 د.ع نقداً".
   c) Wallet: success check, "تم الدفع من محفظة الراكب 6,000 د.ع — لا تجمع شيئاً".
   Below: a text button "أعطاني الراكب مبلغاً أكبر ولا يوجد باقي". Primary "تم الاستلام".

7. No change to give — amount entry: title "كم استلمت من الراكب؟", huge "10,000" د.ع, caption "المطلوب 6,000 د.ع · سنضيف الفرق 4,000 د.ع إلى محفظة الراكب، لا يُخصم منك شيء". Note "الحد الأعلى للفرق 2,000 د.ع" shown as a warning variant when exceeded. Keypad. Primary "تأكيد".

8. Rate the rider — "كيف كان الراكب أحمد؟", 5 large stars (4 selected, gold), chips that appear after rating: "ملتزم بالوقت"، "محترم". Text area "ملاحظة لفريقنا (اختياري) — لا يراها الراكب". Primary "إرسال", text button "تخطي".

9. Cancel trip — sheet: "ليش بدك تلغي؟" radio list: "الراكب طلب الإلغاء"، "العنوان غير صحيح"، "مشكلة في السيارة"، "حالة طارئة"، "سبب آخر" (with a text field). Warning-tint note "الإلغاء يُحسب في نسبة الإلغاء التي تشترطها بعض المكافآت". Danger "إلغاء الرحلة", secondary "الرجوع للرحلة".

10. SOS — confirm dialog over the trip: "هل تريد إرسال تنبيه طوارئ؟", body "سنبلغ فريق الأمان ونشاركه موقعك وتفاصيل الرحلة.", danger "إرسال التنبيه", secondary "إلغاء". And a sent state: "تم إرسال التنبيه — فريق الأمان على علم" with the operator's emergency numbers as call rows ("الشرطة 104"، "الإسعاف 122").
```

---

## الدفعة 4 — الأرباح والمكافآت

```
Using the design brief, create these 6 screens (Arabic, RTL, light mode):

1. Earnings — tab الأرباح active. Segmented control at the top: "اليوم" (selected), "الأسبوع", "الشهر", with ‹ › arrows to move between days/weeks and the period label "الثلاثاء 21 تشرين الأول". Hero card (ink with subtle gold glow): caption "صافي الأرباح", Display "24,500 د.ع", under it "6 رحلات". Breakdown card rows: "أجور الرحلات" 30,000، "عمولة المنصة" ‎-4,500 (text-secondary), "رسوم إلغاء وعدم حضور" 1,500، "إكراميات" 1,000، "مكافآت" 0، "تعديلات" 0؛ a divider; "الصافي" bold. A second small card: "استلمت نقداً 22,000 د.ع" and "دُفع من المحافظ 8,000 د.ع". Then "رحلات اليوم" list: time, destination, class, net amount on the left; each opens the trip.

2. Earnings — week: same layout, the hero shows the week total, plus a 7-bar chart (Mon→Sun shown right-to-left, today's bar gold, others ink at 20%), tapping a bar shows that day. Days list under it with totals.

3. Trip earning details — static map with the route, date/time, pickup → drop-off, distance/duration, rider first name and the rating you gave. Card "كيف توزّع المبلغ": "أجرة الرحلة 6,000"، "دفع نقداً 4,000"، "من محفظة الراكب 2,000"، "عمولة المنصة ‎-900"، "إكرامية 500"، "ربحك 5,600" (bold). Row "تحتاج مساعدة بهذه الرحلة؟" ‹.

4. Incentives — title "المكافآت". Card per campaign: name "مكافأة نهاية الأسبوع", dates "الجمعة 6 م – الأحد 11 م", a tier progress bar with markers at 10 / 20 / 30 trips and amounts under them (10,000 / 25,000 / 45,000 د.ع), current "14 رحلة" with "باقي 6 رحلات لـ 25,000 د.ع". Conditions as small rows with a check or a warning: "نسبة القبول 85% على الأقل — أنت 91% ✓"، "نسبة الإلغاء أقل من 10% — أنت 12% ⚠". Sections "جارية"، "قادمة"، "انتهت" (ended ones show "ربحت 25,000 د.ع" in success or "لم تتحقق الشروط").

5. Incentive details — the campaign's full rules: description, the hours each day, the area ("أربيل — كل المناطق"), the class, the tier table, and the conditions. Caption "تُحسب الرحلات المكتملة فقط، وتُضاف المكافأة لمحفظتك بعد انتهاء الحملة".

6. Empty and loading — earnings for a day with no trips ("ما في رحلات بهاليوم" + primary "اتصل الآن"), and a skeleton of screen 1.
```

---

## الدفعة 5 — المحفظة

```
Using the design brief, create these 8 screens (Arabic, RTL, light mode):

1. Wallet — tab المحفظة active. Hero card (ink, gold glow): caption "رصيد المحفظة", Display "38,000 د.ع". Under it a one-line explanation in text-secondary: "أرباح رحلات المحفظة تُضاف هنا، وعمولة الرحلات النقدية تُخصم منها". Three action tiles: "شحن"، "سحب الأرباح"، "كشف الحساب". Section "آخر الحركات" + "الكل ←": rows "أرباح رحلة" +5,600، "عمولة رحلة نقدية" ‎-900، "إكرامية" +500، "شحن نقدي — المكتب" +20,000، "سحب أرباح" ‎-150,000، "مكافأة" +25,000.

2. Wallet — negative balance: hero shows "‎-12,000 د.ع" in danger, and a danger-tint banner "عليك 12,000 د.ع عمولات. عند ‎-25,000 د.ع يتوقف استقبال الرحلات حتى تشحن." with "شحن الآن". A suspended variant: "حسابك موقوف — اشحن 6,000 د.ع على الأقل".

3. Top up — "شحن المحفظة": two option cards: "زين كاش" (selected, caption "ادفع من تطبيق زين كاش") and "نقداً في مكتب الشركة" (caption "ادفع لأمين الصندوق واحصل على إيصال"). For زين كاش: amount entry with chips 10,000 / 25,000 / 50,000, keypad, primary "متابعة", note "الحد الأدنى 1,000 د.ع".

4. Pay cash at the office — info screen: office illustration, H2 "الشحن نقداً", steps: "1. توجّه إلى مكتب الشركة"، "2. أعطِ أمين الصندوق رقم هاتفك والمبلغ"، "3. احتفظ بالإيصال — يصلك إشعار فور إضافة المبلغ". (Office address and hours come from the operator; show a card with placeholder "العنوان وأوقات الدوام".)

5. Top-up result — success ("تم شحن 25,000 د.ع" + new balance) and failed ("فشل الدفع" + reason + "حاول مرة أخرى") variants.

6. Withdraw earnings — "سحب الأرباح": available "38,000 د.ع", amount entry, input "إلى أين نرسل المبلغ؟" (e.g. "زين كاش 0750 123 4567"), caption "الحد الأدنى للسحب 10,000 د.ع · يُحجز المبلغ فوراً حتى يرسله فريقنا". Primary "طلب السحب". Below: "طلباتك" list with status pills: "قيد الانتظار" (warning), "موافق عليه" (info), "تم التحويل" (success, with reference "مرجع ZC-88231"), "مرفوض" (danger, with reason, "عاد المبلغ لمحفظتك").

7. Transactions — filter chips "الكل" "أرباح" "عمولات" "شحن" "سحب" "إكراميات" "مكافآت"; grouped by day with the day-end balance; row types as in screen 1 plus "استرداد" and "تعديل من الإدارة".

8. Statement — period chips "30 يوم" "3 أشهر" "مخصص", summary card: رصيد أول الفترة، مجموع الداخل، مجموع الخارج، رصيد آخر الفترة, and the list.
```

---

## الدفعة 6 — الحساب والسيارات والدعم

```
Using the design brief, create these 9 screens (Arabic, RTL, light mode):

1. Account — tab الحساب active. Header: profile photo (from the approved document), name "سالم سليمان", "★ 4.9 · 1,240 تقييم", phone, active car line with a plate badge "تويوتا كورولا · بيج · 22 A 25626". Groups:
   "حسابي": المعلومات الشخصية، سياراتي، الوثائق (with a warning badge "1" when something expires soon), الإشعارات (unread count).
   "الدعم": مركز المساعدة، تذاكري، مركز الأمان.
   "التفضيلات": اللغة، المظهر، تطبيق الملاحة (Google Maps / Waze / داخل التطبيق)، أصوات العروض.
   "الخصوصية": تحميل بياناتي، حذف الحساب (danger).
   Footer: terms link + app version. And a "تسجيل الخروج" row.

2. Personal info — rows: الاسم (locked icon + caption "لتغيير الاسم أرسل طلباً"), رقم الهاتف, البريد الإلكتروني (＋ أضف), الجنس, تاريخ الميلاد, الجنسية. A sheet "طلب تغيير الاسم": "الاسم الجديد", "السبب", primary "إرسال الطلب", and a pending state "طلبك قيد المراجعة".

3. My cars — list of cars as cards: 3D car image, make/model/year/colour, plate badge, class chip, status pill ("نشطة" success / "قيد المراجعة" / "مرفوضة" + reason / "متوقفة"). The active one has a gold border and "السيارة الحالية". Each non-active approved car has "استخدام هذه السيارة". Primary "إضافة سيارة". Caption "لا يمكن تغيير السيارة أثناء رحلة".

4. Add a car — the same form as registration step 2, then the car's documents checklist (سنوية الوجه/الظهر، صور السيارة) with statuses, primary "إرسال للمراجعة".

5. Documents — two sections "وثائقك" and "وثائق السيارة الحالية". Each row: name, number masked "••••5626", expiry "تنتهي 12 تشرين الثاني 2026", status pill. States to show: approved, expiring soon (warning + "تجديد"), expired (danger + "تحديث الآن"), pending renewal ("التجديد قيد المراجعة" with the old one still valid), rejected with reason. A top banner when something blocks going online.

6. Help center (captain) — search, categories as tiles: "الرحلات"، "الأرباح والمحفظة"، "الوثائق والحساب"، "السيارة"، "الأمان"، "المفقودات"; card "مساعدة بخصوص آخر رحلة"; row "تذاكري".

7. My tickets — list with status pills ("مفتوحة"، "بانتظار ردك"، "محلولة"، "مغلقة"); a lost-item ticket from a rider shows a tag "غرض مفقود في رحلتك" so the captain knows they were added to it.

8. Ticket conversation — agent bubbles on the right (surface-2, "فريق الدعم"), the captain's on the left (ink); in a lost-item ticket the rider's messages show with "الراكب" label; attachments; input with paperclip and send; resolved state with the 1-5 rating.

9. Safety center (captain) — rows: "تنبيه الطوارئ (SOS)" with explanation "يصل لفريق الأمان مع موقعك"، "أرقام الطوارئ" (the operator's list: الشرطة 104، الإسعاف 122، الدفاع المدني 115) as call rows, "الإبلاغ عن مشكلة أمان" (opens a ticket).
```

---

## الدفعة 7 — للتصميم الآن، التنفيذ بعدين (B4، B5، B8)

```
Using the design brief, create these 5 screens (Arabic, RTL, light mode). They pair with screens already designed in the Rider app (chat, call, change destination), so keep the same bubble styles.

1. Chat with the rider — top bar: rider initials avatar, "أحمد", trip line "إلى مطار أربيل", call button. Captain's bubbles on the LEFT in ink with white text, the rider's on the RIGHT in surface-2. Quick replies above the input, sized for one tap while parked: "وصلت"، "أنا في الطريق"، "دقيقتين وبوصل"، "ما لقيتك، وين أنت؟". Input "اكتب رسالة…" + gold send. A note at the top: "المحادثة متاحة أثناء الرحلة فقط". Show a new-message toast over the navigation screen ("أحمد: أنا عند البوابة") with "رد".

2. Calling — a full-screen calling state: rider initials, "أحمد", "جاري الاتصال…", caption "رقمك مخفي عن الراكب ورقمه مخفي عنك", buttons: speaker, mute, end (danger).

3. Destination change request — a sheet that appears during a trip: H2 "الراكب يريد تغيير الوجهة", old → new destination rows (old one struck through), "الأجرة الجديدة 8,500 د.ع (كانت 6,000)", "الوقت الإضافي 7 دقائق". A 30-second ring like the offer. Buttons "قبول" (gold) and "رفض".

4. Stop added — same pattern for "الراكب أضاف محطة: صيدلية النور" with the new fare, accept / reject.

5. Change accepted — the navigation screen with the new route and a success toast "تم تحديث الوجهة — الأجرة الجديدة 8,500 د.ع".
```

---

## بعد الدفعات

### الوضع الغامق (على 5 شاشات)

```
Create dark-mode versions of these screens using the DARK MODE tokens from the brief (same layout, nothing else changes): Home online, Incoming trip offer, Heading to pickup, On trip, Earnings today. Dark map style. Gold stays #F3D59A with #05070F text on it; the countdown ring and slide-to-confirm keep the gold.
```

### فحص الاتجاه LTR (على 3 شاشات)

```
Create English LTR versions of: Incoming trip offer, Waiting at pickup, Wallet. Mirror the layout: back arrow on the LEFT, chevrons point right, text left-aligned, slide-to-confirm slides left-to-right with the knob starting on the LEFT. Prices stay "6,000 IQD". Same tokens and components.
```

---

## ملاحظات للتنفيذ (لـ Claude)

### كل شاشة وين باك إندها

| الشاشة | الباك إند |
|---|---|
| الدخول | `/v1/auth/otp:request` و`:verify` (نفس الراكب، `clientId` تبع تطبيق الكابتن) |
| التسجيل | `POST /v1/drivers` (الاسم والسيارة)، `PATCH /v1/drivers/{id}/details` (الجنس والميلاد والجنسية، بينقفلوا بعد الموافقة) |
| الوثائق | `GET /v1/drivers/{id}/documents` (`requirements` بحالاتها السبعة، `compliant`)، `GET /v1/driver-document-types` (الأسماء بالـ 3 لغات، `requires_number`، `requires_expiry`)، الرفع: `media:upload` ثم PUT ثم `:complete` ثم `POST /v1/drivers/{id}/documents` |
| حالة الحساب | `Driver.status` (PENDING، REJECTED + `rejectionReason`، ACTIVE، SUSPENDED) وإشعارات `driver.account_*` |
| الاتصال | `PUT /v1/drivers/{id}/availability`؛ الرفض بيرجع FAILED_PRECONDITION: وثائق (`documents` → `compliant`)، محفظة (`GET /v1/drivers/{id}/standing`: `amountDue`)، موقع (التطبيق) |
| الموقع | `PUT /v1/locations/{driverId}` كل كم ثانية، و`:waypoint` أثناء الرحلة |
| العرض | `GET /v1/drivers/{id}/offer` كل 2 ث (`expiresAt`، `quotedFare`، `paymentMethod`، `stops`، `afterCurrentTrip`، `pickupEtaSeconds`)، `:accept-offer` / `:reject-offer`. مسافة وطول الرحلة من `POST /v1/routes:compute` |
| الرحلة | `GET /v1/trips:active?driver_id=` (فيه `nextTrip`)، `GET /v1/trips/{id}` (`pickupDetails`، `pickupNote`، `hasPickupPhoto`، `passengerName/Phone`، `stops`، `arrivedAt`)، `/pickup-photo`، `:arrived` (200 م)، `:reach-stop`، `:start`، `:complete`، `:cancel` (و`riderNoShow`)، `:sos` |
| الدفع بآخر الرحلة | `GET /v1/wallets/{driverId}/trips/{tripId}/settlement?owner_type=OWNER_TYPE_DRIVER` (`cashAmount`، `walletAmount`، `commissionAmount`، `driverEarning`، `tipAmount`)، الباقي: `POST /v1/drivers/{id}/trips/{tripId}/change` (`cashReceived`؛ حد `max_change_credit` 2,000 افتراضي) |
| تقييم الراكب | `POST /v1/trips/{id}:rate` (`RATED_BY_DRIVER`، الشارات ON_TIME وPOLITE)، `GET /v1/trips/{id}/rating` |
| الأرباح | `GET /v1/drivers/{id}/earnings?period=&date=` (`totals` + `days`)، رحلات اليوم من `GET /v1/activity?driver_id=` |
| المكافآت | `GET /v1/drivers/{id}/incentives` (الدرجات، التقدّم، الشروط الناقصة `unmet`، النتيجة) |
| المحفظة | `GET /v1/wallets/{id}?owner_type=OWNER_TYPE_DRIVER`، الحركات، الكشف، `standing`، زين كاش `POST /v1/wallets/{id}/topups`، السحب `POST/GET /v1/drivers/{id}/payouts`. الشحن النقدي بيبين كحركة `TRANSACTION_TYPE_CASH_TOP_UP` "شحن نقدي" (B16) |
| السيارات | `GET/POST /v1/drivers/{id}/vehicles`، `PATCH …/{vehicleId}`، `:activate`، `:retire` |
| الاسم | `POST/GET /v1/drivers/{id}/name-changes` |
| الإشعارات | `/v1/notifications?recipient_type=…DRIVER`، الأحداث: `trip.offer_received`، `driver.*` (الموافقة، الوثائق، الانتهاء، الإيقاف…)، `wallet.tip_received`، `wallet.payout_*`، `driver.incentive_earned` |
| الدعم | نفس support-service بدور الكابتن، ومنو تذاكر المفقودات يلي بينضاف إلها |
| الخصوصية | `/v1/me/data-exports`، `/v1/me/deletion…` |

### نواقص باك إند طلعت من هالتصميم (بتنعمل قبل أو مع تنفيذ التطبيق)

- **B30، الراكب للكابتن:** ما في API بيعطي الكابتن اسم الراكب الأول وتقييمه وهو بالرحلة. بدنا `GET /v1/trips/{tripId}/rider` للكابتن: الاسم الأول وتقييم الراكب بس، بدون رقم. الرقم مع B4.
- **B31، مواعيد الانتظار للكابتن:** شروط الرحلة (`terms`) للراكب بس. الكابتن بدو يعرف وقت ما بيخلص الانتظار المجاني، ووقت ما بيقدر يبلّغ "ما إجا"، وكم رسوم عدم الحضور وقديش بيوصلو منها بعد العمولة. بدنا نسخة للكابتن من `terms`.
- **B32، عنوان المكتب وأوقات الدوام:** للشحن النقدي. حقلين بـ `GET /v1/support/instance-info` (`SUPPORT_OFFICE_ADDRESS`، `SUPPORT_OFFICE_HOURS`).
- **تقييم الكابتن:** `ratingCount` موجود بـ `Driver`، فـ "1,240 تقييم" بالحساب صحيح. عدد الرحلات الكلي ما في، وما بينحط بالشاشة.
- **تطبيق الملاحة والأصوات:** إعدادات بالموبايل بس، ما بدها باك إند.

### قرارات وقواعد

- الشاشات الأساسية وقت السواقة (العرض، الطريق للراكب، الانتظار، الرحلة) لازم تنقرا بلمحة. الأرقام الكبيرة هي الوقت والمسافة والمبلغ.
- بدء الرحلة وإنهاؤها و"الراكب ما إجا" بالسحب، مش بالكبس، لحتى ما تصير بالغلط.
- الكابتن ما بيشوف رقم الراكب أبداً، إلا رقم "الراكب الآخر" لما الرحلة لشخص تاني (الباك إند بيعطيه بس وقت الرحلة شغالة). الاتصال الطبيعي مع B4.
- كل الحدود من الباك إند: 15 ث للعرض، 200 م للوصول، وقت الانتظار من بطاقة الأسعار، أقل سحب، حد الباقي، حد الإيقاف.
- نفس قواعد تطبيق الراكب: لا نصوص ثابتة (كلها مفاتيح ترجمة)، أرقام إنكليزية، shimmer للتحميل ونقاط للأزرار، أخطاء مفهومة بلغة المستخدم، ملفات صغيرة بدون تكرار.
