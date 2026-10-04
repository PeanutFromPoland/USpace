"""Transparent themed vector scenes for KindSpot introduction. Run with repository root."""
from pathlib import Path
import sys
from xml.etree import ElementTree as ET
root=Path(sys.argv[1] if len(sys.argv)>1 else '.')
assets=root/'frontend/mobile/assets/graphics'
A='#445566'; S='#778899'; W='#AABBCC'
def path(d,fill=S,stroke='none',width=3,opacity=1):
    return f'<path d="{d}" fill="{fill}" stroke="{stroke}" stroke-width="{width}" opacity="{opacity}" stroke-linecap="round" stroke-linejoin="round"/>'
def circle(x,y,r,fill=A,opacity=1):return f'<circle cx="{x}" cy="{y}" r="{r}" fill="{fill}" opacity="{opacity}"/>'
def rect(x,y,w,h,rx,fill=W,stroke=A):return f'<rect x="{x}" y="{y}" width="{w}" height="{h}" rx="{rx}" fill="{fill}" stroke="{stroke}" stroke-width="4"/>'
def foliage(x,y):
    return f'<g transform="translate({x} {y})">'+path('M0 0C-28-8-28-44-12-42 0-39 3-11 0 0z',S)+path('M0 0C-3-35 23-55 31-40 40-22 10-6 0 0z',A,opacity=.22)+path('M0-2-4-26 M0-2 19-29','none',A,2,.45)+'</g>'
def tree(x,y):
    return circle(x,y-14,13,S)+path(f'M{x} {y+9}v-24','none',A,2,.5)
ground=path('M30 182Q40 164 83 169L259 167Q295 171 288 190Q263 210 66 200Q27 199 30 182z',S,opacity=.38)
env=foliage(51,173)+foliage(260,173)+tree(61,119)+tree(267,114)
cloud=path('M47 60c-13 0-12-14-3-15 4-22 30-24 38-4 18-5 24 17 7 19z',S,opacity=.55)
mapback=path('M45 142 63 83 131 64 190 72 256 56 280 146 219 136 146 155 95 136z',S,opacity=.6)+path('M69 88 100 133 M126 71 151 145 M195 75 215 131 M52 116 265 98','none',W,8)
pin=path('M101 70c-24-25-17-45 0-45s24 20 0 45z',A,opacity=.5)+circle(101,41,6,W)
main_places=rect(120,102,80,81,20,W,A)+path('M141 124h38v43l-19-12-19 12z','none',A,5)
main_reviews=rect(111,60,103,122,18,W,A)+rect(136,51,53,17,8,S,A)+path('M133 89h54 M133 102h39 M133 145h24','none',A,4,.75)+path('M127 119 133 125 143 113','none',A,4)+path('M194 151 232 113 242 123 204 161 189 166z',S,A,3)+path('M232 113 238 107q4-4 8 0l6 6q4 4 0 8l-10 10',W,A,3)
star=lambda x,y: path(f'M{x} {y-10}l3 7 8 1-6 5 2 8-7-4-7 4 2-8-6-5 8-1z',A,opacity=.6)
main_reward=rect(119,108,84,69,10,S,A)+rect(111,94,100,23,7,W,A)+path('M161 96v78','none',A,4)+path('M161 94c-29 0-42-27-25-30 17-3 25 30 25 30z',S,A,4)+path('M161 94c29 0 42-27 25-30-17-3-25 30-25 30z',S,A,4)+circle(232,146,18,S)+circle(232,146,13,W)+path('M225 146 230 151 239 140','none',A,3)+circle(92,127,13,S)+path('M92 119v16 M85 127h14','none',A,3)
scenes={
'onboarding_places':('onboarding',main_places,mapback+pin+env+cloud),
'onboarding_reviews':('onboarding',main_reviews,env+cloud+path('M53 93h38q10 0 10 10v18H82l-14 11v-11H53q-9 0-9-10v-8q0-10 9-10z',S)+star(238,65)),
'illustration_reward_received':('illustrations',main_reward,env+cloud+star(237,69)+star(90,77)),
}
def svg(body):return '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 320 220">'+body+'</svg>\n'
ET.register_namespace('', 'http://www.w3.org/2000/svg')
for id,(category,main,details) in scenes.items():
    full=svg(ground+details+main)
    (assets/category/(id+'.svg')).write_text(full,encoding='utf-8')
    calm=assets/'variants/calm'/(id+'_calm.svg')
    if calm.exists():calm.write_text(svg(ground+main),encoding='utf-8')
    tree=ET.fromstring(svg(main))
    for el in tree.iter():
        if el.get('fill','none')!='none':el.set('fill','none');el.set('stroke','#112233');el.set('stroke-width','2')
        if el.get('stroke','none')!='none':el.set('stroke','#112233')
        if 'opacity' in el.attrib:del el.attrib['opacity']
    (assets/'variants/mono'/(id+'_mono.svg')).write_text(ET.tostring(tree,encoding='unicode'),encoding='utf-8')
print('Updated three transparent scenes and their calm/mono variants.')