sc = {
 "Conservative": dict(dl=[3000,1500,1500,1700,1800,2000,2100,2200,2400,2500,2600,2800,2900,3000,3000,3100,3200,3300], conv=0.020, ann=39.99, mon=5.99, amix=0.60, churn=0.14, renew=0.30),
 "Base":         dict(dl=[9000,4000,4000,4500,5000,5500,6000,6500,7000,7500,8000,8500,9000,9000,9500,9500,10000,10000], conv=0.035, ann=49.99, mon=7.99, amix=0.65, churn=0.11, renew=0.40),
 "Optimistic":   dict(dl=[20000,10000,11000,12000,13000,14000,15000,16000,17000,18000,19000,20000,21000,22000,23000,24000,25000,25000], conv=0.055, ann=69.99, mon=9.99, amix=0.70, churn=0.09, renew=0.50),
}
REFUND=0.03; APPLE=0.15
for name,s in sc.items():
    mon_active=0.0; ann_cohorts=[]; rows=[]; cum=0; tot_dl=0
    for m in range(18):
        dl=s["dl"][m]; tot_dl+=dl
        newpaid=dl*s["conv"]
        new_ann=newpaid*s["amix"]; new_mon=newpaid*(1-s["amix"])
        mon_active=mon_active*(1-s["churn"])+new_mon
        gross=new_ann*s["ann"]+mon_active*s["mon"]
        if m>=12:
            ren=ann_cohorts[m-12]*s["renew"]; gross+=ren*s["ann"]
        else: ren=0
        ann_cohorts.append(new_ann)
        net=gross*(1-REFUND)*(1-APPLE)
        cum+=net
        active_ann=sum(ann_cohorts[max(0,m-11):m+1]) + (sum(ann_cohorts[i]*s["renew"] for i in range(0,m-11)) if m>=12 else 0)
        rows.append((m+1,dl,round(newpaid),round(mon_active),round(active_ann),round(net),round(cum)))
    print(name, "total downloads",tot_dl)
    for r in rows:
        if r[0] in (1,3,6,9,12,15,18): print(r)
    last=rows[-1]
    mrr_eq = last[3]*s["mon"]+last[4]*s["ann"]/12
    print("payers m18",last[3]+last[4],"ARR run-rate gross",round(mrr_eq*12),"net",round(mrr_eq*12*0.85*0.97))
    print("Y1 net",sum(r[5] for r in rows[:12]))
