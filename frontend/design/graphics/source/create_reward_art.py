"""KindSpot rewards assets. Run with repository root as argument."""
from pathlib import Path
import json,csv,sys
root=Path(sys.argv[1]); base=root/'frontend/mobile/assets/graphics'
S='#778899';A='#445566';F='#112233';W='#AABBCC'
def svg(body):return '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 128 128">'+body+'</svg>\n'
def p(d,fill='none',stroke=A,width=3):return f'<path d="{d}" fill="{fill}" stroke="{stroke}" stroke-width="{width}" stroke-linecap="round" stroke-linejoin="round"/>'
def c(x,y,r,fill=F):return f'<circle cx="{x}" cy="{y}" r="{r}" fill="{fill}"/>'
cat=p('M30 55 29 27 49 40Q64 34 79 40L99 27 98 55Q104 96 64 100 24 96 30 55z',S,A)+p('M35 46 35 35 44 42 M85 42 93 35v11',W,'none')+p('M42 65q5-6 10 0 M76 65q5-6 10 0','none',F)+p('M60 76h8l-4 5z',F,'none')+p('M64 81v5 M56 85q8 9 16 0 M42 78 27 75 M42 85 27 89 M86 78l15-3 M86 85l15 4','none',F,2)
lemur=c(32,48,16,S)+c(96,48,16,S)+c(32,48,8,W)+c(96,48,8,W)+p('M37 41Q64 25 91 41L97 67Q94 96 64 102 34 96 31 67z',S,A)+p('M40 55Q51 43 60 60L54 77Q31 74 40 55z',A,'none')+p('M88 55Q77 43 68 60L74 77Q97 74 88 55z',A,'none')+c(49,62,5,W)+c(79,62,5,W)+c(49,62,2,F)+c(79,62,2,F)+p('M56 84q8-8 16 0l-8 7z',W,A,2)+p('M60 84h8l-4 4z',F,'none')+p('M58 94q6 4 12 0','none',A,2)
bow='<circle cx="64" cy="61" r="51" fill="none" stroke="'+A+'" stroke-width="4"/>'+p('M64 108 50 94 49 120 64 112 79 120 78 94z',S,A,2)+p('M60 107q-24-20-27-4-3 17 27 7 M68 107q24-20 27-4 3 17-27 7',S,A,3)+p('M60 104h8v9h-8z',W,A,2)
explorer=p('M19 31 47 19 80 32 110 21v77L80 109 47 97 19 109z',S,A,4)+p('M47 19v78 M80 32v77','none',A,3)+c(80,59,15,W)+p('M90 70 104 85','none',A,5)+p('M75 58h10 M80 53v10','none',A,2)
gardener=p('M64 95Q23 84 25 37 71 31 64 95z',S,A,3)+p('M64 95q-2-54 44-51 3 44-44 51z',S,A,3)+p('M64 112V65 M64 93 43 59 M64 99l27-39','none',A,3)+c(66,31,14,S)+c(48,35,14,S)+c(84,35,14,S)+c(66,48,14,S)+c(66,36,9,A)
items=[('avatar_cat','avatars',cat,'Awatar — minimalistyczny kot'),('avatar_lemur','avatars',lemur,'Awatar — minimalistyczny lemur'),('frame_bow','frames',bow,'Ramka profilu — obręcz z małą kokardą'),('thumbnail_explorer','thumbnails',explorer,'Motyw Odkrywca — mapa i lupa'),('thumbnail_gardener','thumbnails',gardener,'Motyw Ogrodnik — liście i kwiaty')]
rows=json.loads((base/'manifest.json').read_text(encoding='utf-8'))
for id,folder,body,label in items:
    (base/folder/(id+'.svg')).write_text(svg(body),encoding='utf-8')
    existing=next((r for r in rows if r['id']==id),None)
    if existing is None:
        existing=dict(next(r for r in rows if r['id']=='avatar_leaf'));rows.append(existing)
    existing.update(id=id,plik=f'{folder}/{id}.svg',kategoria=folder,znaczenie_pl=label,
        wariant='themed',role_kolorow='foreground/accent/accentSoft/surface',wspoldzielone_uzycie='',
        priorytet='P1',zrodlo_licencja='Nowy własny wektor KindSpot, 2026-10-04',pakiet='personalizacja_PoC')
(base/'manifest.json').write_text(json.dumps(rows,ensure_ascii=False,indent=2),encoding='utf-8')
with (root/'frontend/design/graphics/manifest.csv').open('w',encoding='utf-8-sig',newline='') as f:
    w=csv.DictWriter(f,fieldnames=list(rows[0]));w.writeheader();w.writerows(rows)
registry=root/'frontend/mobile/lib/ui/graphics_catalog.dart'
registry.write_text('// Generated from the corrected asset manifest.\nconst kindSpotGraphics = <String, String>{\n'+''.join(f"  '{r['id']}': 'assets/graphics/{r['plik']}',\n" for r in rows)+'};\n',encoding='utf-8')
print('Registry:',len(rows),'SVG. New rewards artwork is available.')