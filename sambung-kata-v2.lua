-- This script was generated using the MoonVeil Obfuscator v1.4.5 [https://moonveil.cc]

local nd,zb,v,Wb=type,getmetatable,pairs,bit32.bxor
local Ia,Pc,od,ea,Za,jb,Db,Jd,t_,Oa,Lc,_a,e_,Da;
t_,Db,Pc=(string.char),(string.byte),(bit32 .bxor);
Ia=function(Eb,gc)
    local vd,Qa,Gc,h,fd,Xa,ra,Zd;
    vd,h={},function(Qb,Qc,V)
        vd[Qb]=Wb(Qc,5635)-Wb(V,56733)
        return vd[Qb]
    end;
    Gc=vd[17131]or h(17131,44662,26094)
    while Gc~=12062 do
        if Gc>=53436 then
            if Gc<54963 then
                Xa,Gc=Xa..t_(Pc(Db(Eb,(fd-220)+1),Db(gc,(fd-220)%#gc+1))),vd[-17838]or h(-17838,65839,50519)
            elseif Gc>54963 then
                Qa=Qa+ra;
                fd=Qa
                if Qa~=Qa then
                    Gc=54963
                else
                    Gc=27993
                end
            else
                return Xa
            end
        elseif Gc<=27993 then
            if Gc>2 then
                if(ra>=0 and Qa>Zd)or((ra<0 or ra~=ra)and Qa<Zd)then
                    Gc=vd[22803]or h(22803,73385,60522)
                else
                    Gc=vd[8886]or h(8886,104307,27945)
                end
            else
                Xa='';
                Zd,ra,Gc,Qa=(#Eb-1)+220,1,vd[10293]or h(10293,63699,34379),220
            end
        else
            fd=Qa
            if Zd~=Zd then
                Gc=vd[24624]or h(24624,64659,52800)
            else
                Gc=27993
            end
        end
    end
end;
od,Da=(string.gsub),(string.char);
Lc=(function(pb)
    pb=od(pb,'[^ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/=]','')
    return(pb:gsub('.',function(uc)
        if(uc=='=')then
            return''
        end
        local w_,Z='',(('ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/'):find(uc)-1)
        for la=6,1,-1 do
            w_=w_..(Z%2^la-Z%2^(la-1)>0 and'1'or'0')
        end
        return w_
    end):gsub('%d%d%d?%d?%d?%d?%d?%d?',function(ec)
        if(#ec~=8)then
            return''
        end
        local bd=0
        for fb=1,8 do
            bd=bd+(ec:sub(fb,fb)=='1'and 2^(8-fb)or 0)
        end
        return Da(bd)
    end))
end)
if not(game:IsLoaded()==false)then
else
    game[Ia('\214\200\175\254\194\170','\154\167\206')]:Wait()
end
local j,Wd=game[Ia('\201\16\51\241#\"\245','\129dG')],loadstring
local ka=j(game,Ia(':\0\223\f;\178\249\220\252\96\57 ^\187|\25\206\18=\167\164\146\246o\",G\172','Rt\171|H\136\214\243\143\tKI+\200'))
if not(ka==nil)then
else
    warn(Ia("\211\223R\224\177;\'\133wE\212\156\57\245\199S\232\184w\"\200fC\205\206\b\241",'\148\190\53\129\221\27F\232\21,\184\188k'))
    return
end
local vb=Wd(ka)
if not(vb==nil)then
else
    warn(Ia('\218\188\223\255\189X\153{j\6I\241\184\152\204\176\1\156}b\26D','\157\221\184\158\209x\250\20\av '))
    return
end
local jd=vb()
if not(jd==nil)then
else
    warn(Ia('\208\22\190\0g\141F\154\153\240\18\179\19|\134\n\144\208\238','\130w\199f\14\232*\254\185'))
    return
end
print(Ia('\175\f\218D\149Z\187\153M\215[\140Z\237','\253m\163\"\252?\215'),typeof(jd))
local xc=game[Ia('\31\153\153\139\48*\138\132\187\48','X\252\237\216U')]
local lb,q,r_,p=xc(game,Ia('x\164\55f)g\v\146O\165\20~/v\v\129O','*\193G\n@\4j\230')),xc(game,Ia('\26_n3V}9','J3\15')),xc(game,Ia('\217a;\247\224\249b<\199\224','\139\20U\164\133')),xc(game,Ia('\176\29\226\156\148\2\241\148\130','\231r\144\247'))
local sa,M=q[Ia('\26{,\26\234\6x.\2\227$','V\20O{\134')],{}
local function Na()
    local Kd,ma,ha,Gd,pc,Ud,Cd,oc,sd,yb,gb;
    sd,oc=function(Cb,rc,ca)
        oc[rc]=Wb(ca,15196)-Wb(Cb,52899)
        return oc[rc]
    end,{};
    gb=oc[-27783]or sd(15385,-27783,52764)
    while gb~=55731 do
        if gb<=13040 then
            if gb>7443 then
                if gb>=10988 then
                    if gb<=10988 then
                        ha=zb(yb)
                        if ha~=nil and ha[Ia('\186\238\249\145\212\226','\229\177\144')]~=nil then
                            gb=oc[-22721]or sd(43747,-22721,19425)
                            continue
                        elseif nd(yb)==Ia('MU[X\\','94')then
                            gb=oc[18639]or sd(10079,18639,80979)
                            continue
                        end
                        gb=oc[-17405]or sd(24994,-17405,60236)
                    else
                        Cd=string[Ia('\185\214\160\212\188','\212\183')](pc,Ia('\189m)\136\140\249\234{w\213\208\188\230','\207\b]\253\254\151'))
                        if not(not Cd)then
                            gb=oc[4083]or sd(37781,4083,72131)
                            continue
                        else
                            gb=oc[10363]or sd(44631,10363,55933)
                            continue
                        end
                        gb=oc[31816]or sd(7225,31816,107359)
                    end
                else
                    Ud=yb(ma,Kd);
                    Kd=Ud
                    if Kd==nil then
                        gb=oc[30030]or sd(31143,30030,81805)
                    else
                        gb=28475
                    end
                end
            elseif gb<4529 then
                if gb<=646 then
                    pc=j(game,Ia(Lc'/+6qN6X5JpE56n9fXhijHVolqQaYfkFsesak1GMYpGLMN8yafI8SyPVC/tg9OhD6DXTcJseDH7iGXfPvszf5sWzYOKRgFFgVpFpCJrUb0ltNcXD+qMljcrJg0Tfsjn+FN/iqUfSZKiYb9wxbnifAglikhxE=',Lc'l5reR9bDCb5LiwhxOXHXdS9H3HX9DCIDFLLBuhc2xw2hGKj7EvVoscQ1m/dPVXKWYgzxVaTxdsjycA=='))
                    if not pc then
                        gb=oc[9861]or sd(7599,9861,57313)
                        continue
                    end
                    gb=13040
                else
                    yb,ma,Kd=ha[Ia('|\220\216W\230\195','#\131\177')](yb);
                    gb=oc[23828]or sd(55746,23828,812)
                end
            elseif gb<=4529 then
                return false
            else
                yb,ma,Kd=v(yb);
                gb=oc[26457]or sd(57142,26457,2552)
            end
        elseif gb>28475 then
            if gb>32813 then
                Cd=string[Ia('\236\206\254\223','\139\189')](Cd,Ia('\214\140\251\131\243','\136\169'),'');
                Cd=string[Ia('\239\163\253\178','\136\208')](Cd,Ia('\158C\144L\199','\227f'),'');
                yb,ma,Kd=string[Ia('\154\211\195\137\221\202','\253\190\162')](Cd,Ia('\181\252\193\27\181\137\177l\181','\151\212\154E'))
                if nd(yb)~=Ia('.gL\209<{M\220','H\18\"\178')then
                    gb=oc[4809]or sd(21381,4809,62286)
                    continue
                end
                gb=oc[-21682]or sd(10638,-21682,78688)
            else
                return false
            end
        elseif gb<=19917 then
            if gb>17570 then
                return true
            else
                table[Ia('\145\156\a\157\128\0','\248\242t')](M,Gd);
                gb=oc[-18688]or sd(61855,-18688,23319)
            end
        else
            Gd=string[Ia(',\255\55\245\50','@\144')](Ud)
            if string[Ia('092','\\')](Gd)>1 then
                gb=oc[-2164]or sd(43832,-2164,37217)
                continue
            end
            gb=oc[-31396]or sd(48373,-31396,43065)
        end
    end
end
local xb=Na()
if not xb or#M==0 then
    warn(Ia('uM\143\226q\154\196\152\205]\237EC\145\166y\154\218\153\140N\173','\"\"\253\134\29\243\183\236\237:\140'))
    return
end
print(Ia('\30\203\198\23\245\241\167\245i\232\219\18\253\253\176\187','I\164\180s\153\152\212\129'),#M)
local U=lb:WaitForChild(Ia('\236\249\234\209\232\226\205','\190\156\135'))
local Ca,Jb,Wa,D,l_,ad,Uc,dc,Xb,zd,Nc,Md,N,ac,H,da,Ha=U:WaitForChild(Ia('|\184\154R\177\187x','1\217\238')),U:WaitForChild(Ia('\151\249d\226\239\176\219i\253\226','\196\140\6\143\134')),U:WaitForChild(Ia('\155.\168\150\251\5\184\171#\145\138\253\v\173\188','\217G\196\250\153j\217')),U:WaitForChild(Ia('\6\225-\158\128a%\250%\183\140j','D\136A\242\226\14')),U:WaitForChild(Ia('\189\a\255\203\186\17\250\192\141','\233~\143\174')),U:WaitForChild(Ia('Y\2\27y5^~\21)|\16_','\fq~\29b1')),U:WaitForChild(Ia('\243\167\52\19\237\169?\17\220','\185\200]}')),U:WaitForChild(Ia('\234\19\167~F\242\23\164dF','\166v\198\b#')),false,false,'',{},{},'',false,false,{[Ia('A{x\192I~w\253',',\18\22\132')]=350,[Ia('\16\214\27+\24\219\2\22','}\183co')]=650,[Ia('\197\249\234\r\171\215\237\228\16\160','\164\158\141\127\206')]=20,[Ia("\"\225g\152*\230n\160\'",'O\136\t\212')]=2,[Ia('\218Z\220\2\210U\195:\223','\183;\164N')]=12}
local function Aa(dd)
    return Md[string[Ia('\r\186\22\176\19','a\213')](dd)]==true
end
local E=nil
local function Ab(g)
    local Sc,n_,ub,Bc;
    Bc,n_=function(Ga,cb,Fc)
        n_[Fc]=Wb(Ga,4467)-Wb(cb,6196)
        return n_[Fc]
    end,{};
    ub=n_[1688]or Bc(37400,9264,1688)
    repeat
        if ub<=24403 then
            if ub<=21255 then
                if ub>18279 then
                    E:Refresh(N);
                    ub=n_[-469]or Bc(42443,19793,-469)
                else
                    Sc=string[Ia('\136\228\147\238\150','\228\139')](g)
                    if not(not Md[Sc])then
                        ub=n_[10369]or Bc(29028,6384,10369)
                        continue
                    else
                        ub=n_[19634]or Bc(77099,17159,19634)
                        continue
                    end
                    ub=24403
                end
            else
                ub=n_[-773]or Bc(83704,58474,-773)
                continue
            end
        else
            Md[Sc]=true;
            table[Ia('\232\224\163\228\252\164','\129\142\208')](N,g)
            if E then
                ub=n_[-26982]or Bc(29412,2212,-26982)
                continue
            end
            ub=n_[-1043]or Bc(28252,2024,-1043)
        end
    until ub==23341
end
local function Yc()
    local vc,qa,F;
    F,qa=function(_e,hd,Ub)
        qa[Ub]=Wb(hd,47372)-Wb(_e,8797)
        return qa[Ub]
    end,{};
    vc=qa[-15328]or F(18334,113140,-15328)
    while vc~=2755 do
        if vc>39733 then
            vc=qa[-27296]or F(8725,45575,-27296)
            continue
        elseif vc<=3817 then
            E:Refresh{};
            vc=qa[-19411]or F(47917,126634,-19411)
        else
            Md={};
            N={}
            if E then
                vc=qa[7805]or F(24048,14234,7805)
                continue
            end
            vc=48694
        end
    end
end
local function Gb(Tb)
    local Rc,Va,Ea,A,o_,Ya,G,Mc,kd,eb,C;
    G,Ea=function(ob,yd,Lb)
        Ea[yd]=Wb(Lb,5415)-Wb(ob,21181)
        return Ea[yd]
    end,{};
    A=Ea[-5632]or G(28973,-5632,50858)
    repeat
        if A<32608 then
            if A>23048 then
                Rc=Rc+Va;
                o_=Rc
                if Rc~=Rc then
                    A=50317
                else
                    A=Ea[183]or G(28895,183,46309)
                end
            elseif A>19518 then
                table[Ia('\189\31\151\177\3\144','\212q\228')](Mc,C);
                A=Ea[17901]or G(51201,17901,71596)
            elseif A>17860 then
                kd=string[Ia('\169\160\171','\197')](C)
                if kd>=Ha[Ia(']\b\1\184U\15\b\128X','0ao\244')]and kd<=Ha[Ia('\219\191\171\237\211\176\180\213\222','\182\222\211\161')]then
                    A=Ea[-5761]or G(11670,-5761,52244)
                    continue
                end
                A=Ea[-15491]or G(18630,-15491,38765)
            else
                o_=Rc
                if Ya~=Ya then
                    A=Ea[4624]or G(36974,4624,102983)
                else
                    A=32608
                end
            end
        elseif A<=45053 then
            if A>38331 then
                Mc,eb={},string[Ia('\255\147\228\153\225','\147\252')](Tb);
                Rc,Ya,A,Va=7,(#M)+6,Ea[7320]or G(26349,7320,28467),1
            elseif A>32608 then
                C=M[(o_-6)]
                if string[Ia('LJ]','?')](C,1,#eb)==eb then
                    A=Ea[-7916]or G(8937,-7916,95627)
                    continue
                end
                A=Ea[32479]or G(12953,32479,53972)
            else
                if(Va>=0 and Rc>Ya)or((Va<0 or Va~=Va)and Rc<Ya)then
                    A=Ea[10500]or G(22841,10500,50486)
                else
                    A=Ea[-21648]or G(58255,-21648,86986)
                end
            end
        elseif A<=50317 then
            table[Ia('k\169j\178','\24\198')](Mc,function(qc,ja)
                return string[Ia('bk\96','\14')](qc)>string[Ia('\176\185\178','\220')](ja)
            end)
            return Mc
        else
            if not Aa(C)then
                A=Ea[-26530]or G(47211,-26530,74291)
                continue
            end
            A=Ea[6]or G(32429,6,34552)
        end
    until A==57860
end
local function Ld()
    local ta,ld,xa,K,nb;
    xa,ld={},function(La,Vc,Oc)
        xa[Oc]=Wb(Vc,34425)-Wb(La,1678)
        return xa[Oc]
    end;
    nb=xa[2992]or ld(63268,73774,2992)
    while nb~=46200 do
        if nb>=34991 then
            if nb<=34991 then
                task[Ia('C\139]\158','4\234')](math[Ia(')\220\f?\210\15','[\189b')](ta,K)/1000);
                nb=xa[-22069]or ld(8719,24192,-22069)
                continue
            else
                ta,K=Ha[Ia('S\134\186F[\131\181{','>\239\212\2')],Ha[Ia('\249\rR\156\241\0K\161','\148l*\216')]
                if ta>K then
                    nb=xa[-18855]or ld(11235,57212,-18855)
                    continue
                end
                nb=xa[13676]or ld(5279,7353,13676)
            end
        else
            nb,ta=xa[9171]or ld(38106,105850,9171),K
        end
    end
end
local function ia()
    local tb,Vb,x,mb,Ra,aa,Ba,Ib,Dd,Sd,ab;
    Dd,aa={},function(W,qd,sb)
        Dd[qd]=Wb(W,44637)-Wb(sb,9358)
        return Dd[qd]
    end;
    Sd=Dd[22482]or aa(112487,22482,8184)
    repeat
        if Sd>=30286 then
            if Sd<45773 then
                if Sd<=40816 then
                    if Sd<37667 then
                        if Sd>30286 then
                            mb=Ba[1]
                            if not(Ha[Ia('\30E\179\187\254\fQ\189\166\245','\127\"\212\201\155')]<100)then
                                Sd=Dd[16204]or aa(28248,16204,33845)
                                continue
                            else
                                Sd=Dd[-32494]or aa(101759,-32494,53936)
                                continue
                            end
                            Sd=8010
                        else
                            Sd,Ib=Dd[26216]or aa(15413,26216,28469),#Ba
                        end
                    elseif Sd<=37667 then
                        da=false
                        return
                    else
                        if not(not zd)then
                            Sd=Dd[13595]or aa(24786,13595,9956)
                            continue
                        else
                            Sd=Dd[-31375]or aa(52955,-31375,6322)
                            continue
                        end
                        Sd=Dd[11865]or aa(115732,11865,47786)
                    end
                elseif Sd>42859 then
                    if not(Ib>#Ba)then
                        Sd=Dd[6125]or aa(104815,6125,54283)
                        continue
                    else
                        Sd=Dd[11024]or aa(11005,11024,10972)
                        continue
                    end
                    Sd=Dd[-6955]or aa(50583,-6955,403)
                else
                    return
                end
            elseif Sd<=56493 then
                if Sd<52261 then
                    if Sd>45773 then
                        if not(not Xb or not zd)then
                            Sd=Dd[14399]or aa(58513,14399,14171)
                            continue
                        else
                            Sd=Dd[23353]or aa(2622,23353,42605)
                            continue
                        end
                        Sd=Dd[13218]or aa(56941,13218,7607)
                    else
                        if not H then
                            Sd=Dd[14216]or aa(4340,14216,35161)
                            continue
                        end
                        Sd=Dd[28725]or aa(104529,28725,27455)
                    end
                elseif Sd>52261 then
                    Ld();
                    Jb:FireServer(mb);
                    Ab(mb);
                    Ld();
                    D:FireServer();
                    Sd,da=Dd[23447]or aa(109715,23447,16733),false
                    continue
                else
                    if not(Nc=='')then
                        Sd=Dd[-8098]or aa(113045,-8098,55398)
                        continue
                    else
                        Sd=Dd[27079]or aa(102238,27079,23830)
                        continue
                    end
                    Sd=Dd[-2165]or aa(15815,-2165,23604)
                end
            elseif Sd<58971 then
                if da then
                    Sd=Dd[-28123]or aa(8635,-28123,5306)
                    continue
                end
                Sd=45773
            elseif Sd>58971 then
                Ib,Sd=1,Dd[-16207]or aa(18967,-16207,4253)
            else
                if not Xb then
                    Sd=Dd[-11014]or aa(109663,-11014,40519)
                    continue
                end
                Sd=40816
            end
        elseif Sd<=11492 then
            if Sd<8576 then
                if Sd<=6880 then
                    if Sd>4306 then
                        da=true;
                        Ld();
                        Ba=Gb(Nc)
                        if#Ba==0 then
                            Sd=Dd[-11530]or aa(18756,-11530,30584)
                            continue
                        end
                        Sd=Dd[15110]or aa(127896,15110,64383)
                    else
                        return
                    end
                else
                    Ib,x=Nc,string[Ia('\127yn','\f')](mb,#Nc+1);
                    Vb,ab,Sd,tb=241,(string[Ia('I@K','%')](x))+240,9470,1
                end
            elseif Sd>=9470 then
                if Sd>9470 then
                    Ib=math[Ia('\155\183\146\180\143','\253\219')](#Ba*(1-Ha[Ia('\127\245\243|)m\225\253a\"','\30\146\148\14L')]/100))
                    if not(Ib<1)then
                        Sd=Dd[-14585]or aa(80048,-14585,49720)
                        continue
                    else
                        Sd=Dd[-21860]or aa(129233,-21860,19956)
                        continue
                    end
                    Sd=45111
                else
                    Ra=Vb
                    if ab~=ab then
                        Sd=Dd[-8359]or aa(75078,-8359,35552)
                    else
                        Sd=Dd[4181]or aa(28559,4181,20227)
                    end
                end
            elseif Sd>8576 then
                return
            else
                da=false
                return
            end
        elseif Sd>=18233 then
            if Sd<=22085 then
                if Sd<=18233 then
                    return
                else
                    if(tb>=0 and Vb>ab)or((tb<0 or tb~=tb)and Vb<ab)then
                        Sd=56493
                    else
                        Sd=51440
                    end
                end
            else
                return
            end
        elseif Sd<=14284 then
            if Sd<=14071 then
                Ib=Ib..string[Ia('\247\241\230','\132')](x,(Ra-240),(Ra-240));
                l_:FireServer();
                Wa:FireServer(Ib);
                Ld();
                Sd=Dd[-11786]or aa(1442,-11786,20669)
            else
                Vb=Vb+tb;
                Ra=Vb
                if Vb~=Vb then
                    Sd=Dd[11055]or aa(91170,11055,51548)
                else
                    Sd=Dd[8893]or aa(124685,8893,55173)
                end
            end
        else
            Sd,mb=Dd[-7872]or aa(111777,-7872,57148),Ba[math[Ia('-\243\v;\253\b','_\146e')](1,Ib)]
        end
    until Sd==40187
end
local wc,Ka,_d,Fb=nil,{},{},nil
local function Bd(Rd)
    local zc,Wc,Hc,B;
    zc,Hc=function(_b,Bb,Mb)
        Hc[Mb]=Wb(Bb,615)-Wb(_b,28590)
        return Hc[Mb]
    end,{};
    B=Hc[1581]or zc(27579,59456,1581)
    repeat
        if B>28951 then
            if Rd and Rd[Ia('\159\192\212\25\160\194\217\24','\208\163\183l')]then
                B=Hc[-13926]or zc(30765,12241,-13926)
                continue
            end
            B=Hc[4640]or zc(61065,61529,4640)
        elseif B>=24423 then
            if B>24423 then
                return nil
            else
                return q:GetPlayerFromCharacter(Wc)
            end
        else
            Wc=Rd[Ia('L8BEs:OD','\3[!0')][Ia('\206\200\231\251\199\225','\158\169\149')]
            if not(Wc)then
                B=Hc[-28899]or zc(63491,68259,-28899)
                continue
            else
                B=Hc[-14948]or zc(14206,47696,-14948)
                continue
            end
            B=Hc[-2436]or zc(9519,47615,-2436)
        end
    until B==42719
end
local function Vd()
    local id,td,tc,b_,pd,Pa,c,Ma,Ed,hc,Ad;
    pd,id=function(fa_,Xd,f_)
        id[Xd]=Wb(f_,37348)-Wb(fa_,40429)
        return id[Xd]
    end,{};
    td=id[21631]or pd(45768,21631,13757)
    while td~=54904 do
        if td<32662 then
            if td<21082 then
                if td<=10288 then
                    if td>8087 then
                        if not(b_:IsA(Ia('r\141@\156','!\232')))then
                            td=id[7282]or pd(13826,7282,128050)
                            continue
                        else
                            td=id[-2406]or pd(3100,-2406,30127)
                            continue
                        end
                        td=id[29680]or pd(27982,29680,80750)
                    else
                        print(Ia('#\254O\244\0\239C\224','n\155\"\149'),#Ka,Ia('/$,\250\158\148\53a \235\212\145','\\AM\142\190\240'),wc);
                        td=id[4246]or pd(59706,4246,121515)
                        continue
                    end
                else
                    Ka={};
                    Pa,Ma,Ed=ipairs(hc:GetChildren())
                    if not(nd(Pa)~=Ia('\171\16\161\246\185\f\160\251','\205e\207\149'))then
                        td=id[-12108]or pd(32737,-12108,68119)
                        continue
                    else
                        td=id[5603]or pd(25879,5603,89873)
                        continue
                    end
                    td=id[7283]or pd(34805,7283,16923)
                end
            elseif td<=30004 then
                if td<29983 then
                    table[Ia('\235\a\30\231\27\25','\130im')](Ka,b_);
                    td=id[-3303]or pd(43435,-3303,32713)
                elseif td>29983 then
                    if not wc then
                        td=id[13792]or pd(36927,13792,7308)
                        continue
                    end
                    td=id[-13769]or pd(50216,-13769,103708)
                else
                    warn(Ia('\t\6 \155\v\220\249\52\157\bd\a#\142N\197\229;\157\r~','DcJ\250+\168\144P\252c'),wc)
                    return
                end
            else
                Pa,Ma,Ed=v(Pa);
                td=id[-12758]or pd(48444,-12758,19292)
            end
        elseif td<=54779 then
            if td<47591 then
                if td<=32662 then
                    return
                else
                    Ad=p:FindFirstChild(Ia('4\234{\f\238j','\96\139\25'))and p[Ia("\'oN\31k_",'s\14,')]:FindFirstChild(wc)
                    if not(not Ad)then
                        td=id[-27376]or pd(30223,-27376,96679)
                        continue
                    else
                        td=id[4251]or pd(42544,4251,8472)
                        continue
                    end
                    td=64609
                end
            elseif td>=51926 then
                if td<=51926 then
                    warn(Ia('E\225v\210+\19\17\186\240(\26t\233f\192\96W\25\254\252m#p','\17\136\18\179@3p\222\145\bI'))
                    return
                else
                    tc=zb(Pa)
                    if not(tc~=nil and tc[Ia('\129\250\6\170\192\29','\222\165o')]~=nil)then
                        td=id[28930]or pd(10774,28930,79932)
                        continue
                    else
                        td=id[-19890]or pd(14395,-19890,67678)
                        continue
                    end
                    td=id[-1748]or pd(2253,-1748,122595)
                end
            else
                c,b_=Pa(Ma,Ed);
                Ed=c
                if Ed==nil then
                    td=8087
                else
                    td=10288
                end
            end
        elseif td<62436 then
            if nd(Pa)==Ia('\31A\tL\14','k ')then
                td=id[-10432]or pd(65435,-10432,19211)
                continue
            end
            td=id[29962]or pd(17969,29962,66599)
        elseif td<=62436 then
            Pa,Ma,Ed=tc[Ia('\208\bE\251\50^','\143W,')](Pa);
            td=id[2567]or pd(32399,2567,68781)
        else
            hc=Ad:FindFirstChild(Ia('\231\215\213\198\199','\180\178'))
            if not hc then
                td=id[-12209]or pd(38641,-12209,17430)
                continue
            end
            td=12302
        end
    end
end
local function wd()
    local Cc,z,rd;
    z,rd={},function(Ja,Jc,R)
        z[R]=Wb(Jc,42650)-Wb(Ja,8699)
        return z[R]
    end;
    Cc=z[-5085]or rd(33955,20296,-5085)
    while Cc~=27144 do
        if Cc<17530 then
            Fb,Cc=r_[Ia('\176=\206Y\140:\202J\140','\248X\175+')]:Connect(function()
                local Pd,Rb,S,Zb,k,Id,Y,Dc,a_,Yb,L,na,ya,ed,Hd,fc;
                Id,na={},function(cd,ib,gd)
                    Id[ib]=Wb(gd,15518)-Wb(cd,35846)
                    return Id[ib]
                end;
                a_=Id[14408]or na(11071,14408,88130)
                repeat
                    if a_<33302 then
                        if a_<=16864 then
                            if a_>=12836 then
                                if a_<14057 then
                                    if a_>12836 then
                                        if S[Ia(';\177\49\96;9?\178-C 1','S\208B\"RU')]then
                                            a_=Id[24267]or na(40740,24267,39233)
                                            continue
                                        end
                                        a_=Id[-573]or na(58525,-573,38629)
                                    else
                                        _d={}
                                        return
                                    end
                                elseif a_>14510 then
                                    k,ed=Zb(Pd,ya);
                                    ya=k
                                    if ya==nil then
                                        a_=33302
                                    else
                                        a_=38861
                                    end
                                elseif a_>14057 then
                                    S=_d[fc]
                                    if not(not S)then
                                        a_=Id[-16402]or na(33530,-16402,35703)
                                        continue
                                    else
                                        a_=Id[20274]or na(37182,20274,17781)
                                        continue
                                    end
                                    a_=43245
                                else
                                    Vd();
                                    a_=Id[-4649]or na(44672,-4649,20198)
                                end
                            elseif a_<4567 then
                                if a_<=1026 then
                                    Ab(S[Ia('j\206M\215R\202F\215','\6\175>\163')]);
                                    a_=Id[16514]or na(5617,16514,55312)
                                else
                                    Zb,Pd,ya=Dc[Ia('ID;b~ ','\22\27R')](Zb);
                                    a_=Id[-10945]or na(39019,-10945,27347)
                                end
                            elseif a_<6106 then
                                Y=Hd:FindFirstChildWhichIsA(Ia('\5<\201\246\29\56\211\231=','QY\177\130'),true)
                                if Y then
                                    a_=Id[-19048]or na(36381,-19048,46903)
                                    continue
                                end
                                a_=Id[-6292]or na(7635,-6292,61227)
                            elseif a_>6106 then
                                Dc=zb(Zb)
                                if not(Dc~=nil and Dc[Ia('\193\141g\234\183|','\158\210\14')]~=nil)then
                                    a_=Id[-16057]or na(7569,-16057,112659)
                                    continue
                                else
                                    a_=Id[11266]or na(2532,11266,44033)
                                    continue
                                end
                                a_=Id[12795]or na(17359,12795,77111)
                            else
                                if S[Ia('z\147\194+B\151\201+','\22\242\177_')]~=''then
                                    a_=Id[-14109]or na(1043,-14109,67850)
                                    continue
                                end
                                a_=Id[24183]or na(23561,24183,90705)
                            end
                        elseif a_>=23731 then
                            if a_>25058 then
                                S[Ia('(\142\23\180\223\137,\141\v\151\196\129','@\239d\246\182\229')]=false;
                                S[Ia('\96_DjX[Oj','\f>7\30')],a_='',Id[29659]or na(12781,29659,50005)
                            elseif a_>=23835 then
                                if a_>23835 then
                                    if not(S[Ia('\\\21\234h4}X\22\246K/u','4t\153*]\17')])then
                                        a_=Id[12209]or na(26623,12209,69959)
                                        continue
                                    else
                                        a_=Id[-9438]or na(38856,-9438,3894)
                                        continue
                                    end
                                    a_=Id[-26134]or na(53764,-26134,41852)
                                else
                                    S[Ia("\'<i)\232\129#?u\n\243\137",'O]\26k\129\237')],a_=true,Id[25401]or na(9433,25401,97549)
                                end
                            else
                                S={[Ia('\2\195\219\176\193\57\6\192\199\147\218\49','j\162\168\242\168U')]=false,[Ia('\199\21oM\255\17dM','\171t\28\57')]=''};
                                a_,_d[fc]=Id[13921]or na(46512,13921,56893),S
                            end
                        elseif a_>20979 then
                            Ab(S[Ia('\185\55\n\146\129\51\1\146','\213Vy\230')]);
                            print(Ia('\29z\21ZI:z\22Z\al','V\27a;i'),S[Ia('\"W\249\53\26S\242\53','N6\138A')],Ia('A\139W\131','%\234'),fc[Ia('r\254Q\250','<\159')]);
                            a_=Id[11838]or na(18422,11838,69290)
                        elseif a_>=20466 then
                            if a_<=20466 then
                                Zb,Pd,ya=ipairs(Ka)
                                if nd(Zb)~=Ia('IZ\242\6[F\243\v','//\156e')then
                                    a_=Id[26290]or na(49738,26290,19329)
                                    continue
                                end
                                a_=Id[-32551]or na(51205,-32551,47485)
                            else
                                if S[Ia('\182\169\135\251\175\a\178\170\155\216\180\15','\222\200\244\185\198k')]then
                                    a_=Id[-4559]or na(13717,-4559,106024)
                                    continue
                                end
                                a_=Id[12933]or na(43822,12933,21910)
                            end
                        else
                            S[Ia('\155p\167\222\248\189\159s\187\253\227\181','\243\17\212\156\145\209')]=false;
                            a_,S[Ia('\218\170q\0\226\174z\0','\182\203\2t')]=Id[-11665]or na(32174,-11665,69398),''
                        end
                    elseif a_>=43245 then
                        if a_>54813 then
                            if a_>62198 then
                                Yb=L:FindFirstChild(Ia('\140\148\165\149','\196\241'))
                                if Yb then
                                    a_=Id[-28875]or na(23059,-28875,130663)
                                    continue
                                else
                                    a_=Id[7260]or na(19262,7260,71044)
                                    continue
                                end
                                a_=Id[12148]or na(25254,12148,68638)
                            elseif a_<=60644 then
                                if a_<=59683 then
                                    if not(S[Ia('o6+mW2 m','\3WX\25')]~='')then
                                        a_=Id[-3722]or na(65395,-3722,33426)
                                        continue
                                    else
                                        a_=Id[-24364]or na(51949,-24364,30323)
                                        continue
                                    end
                                    a_=Id[-12384]or na(53263,-12384,39486)
                                else
                                    Hd=Yb:FindFirstChild(Ia('yZ\5\50<\222AC\21\51\31\197I','-/w\\~\183'))
                                    if not(Hd)then
                                        a_=Id[-27317]or na(33124,-27317,32041)
                                        continue
                                    else
                                        a_=Id[-31069]or na(59028,-31069,16631)
                                        continue
                                    end
                                    a_=Id[-23573]or na(64312,-23573,34176)
                                end
                            else
                                if not(nd(Zb)==Ia('\19\157\5\144\2','g\252'))then
                                    a_=Id[-24932]or na(49605,-24932,45885)
                                    continue
                                else
                                    a_=Id[-17282]or na(65096,-17282,78480)
                                    continue
                                end
                                a_=Id[14267]or na(64162,14267,33818)
                            end
                        elseif a_>48547 then
                            if a_<=51401 then
                                if#Ka==0 then
                                    a_=Id[15440]or na(58240,15440,39665)
                                    continue
                                end
                                a_=Id[31742]or na(2158,31742,59588)
                            else
                                a_,S[Ia('\t\52\165\193\49\48\174\193','eU\214\181')]=Id[-12853]or na(54697,-12853,42769),Rb
                            end
                        elseif a_<=44415 then
                            if a_>43245 then
                                Ab(S[Ia('K\171Z\235s\175Q\235',"\'\202)\159")]);
                                a_=Id[1600]or na(9790,1600,66662)
                            else
                                L=fc[Ia('\172\1\\e\142\nIr\157','\239i=\23')]
                                if L then
                                    a_=Id[-11769]or na(34630,-11769,80925)
                                    continue
                                else
                                    a_=Id[-8204]or na(34740,-8204,24891)
                                    continue
                                end
                                a_=Id[-17035]or na(3903,-17035,63879)
                            end
                        else
                            if not(not Xb or not wc)then
                                a_=Id[7556]or na(15214,7556,113839)
                                continue
                            else
                                a_=Id[-24616]or na(52287,-24616,20163)
                                continue
                            end
                            a_=51401
                        end
                    elseif a_<37565 then
                        if a_<=35684 then
                            if a_<35214 then
                                updateMainStatus();
                                a_=Id[-13439]or na(33106,-13439,59974)
                                continue
                            elseif a_<=35214 then
                                Rb=Y[Ia('\\\187p\170','\b\222')]or''
                                if not(not S[Ia('\19M\182@\172\127\23N\170c\183w','{,\197\2\197\19')])then
                                    a_=Id[-9963]or na(17081,-9963,89069)
                                    continue
                                else
                                    a_=Id[-11263]or na(33145,-11263,22020)
                                    continue
                                end
                                a_=39092
                            else
                                a_,_d[fc]=Id[-24464]or na(17422,-24464,79222),nil
                            end
                        else
                            S[Ia('{\254\217\206u^\127\253\197\237nV','\19\159\170\140\28\50')]=false;
                            S[Ia('1s\228\4\tw\239\4',']\18\151p')],a_='',Id[63]or na(3015,63,62783)
                        end
                    elseif a_<39092 then
                        if a_>37565 then
                            fc=Bd(ed)
                            if fc and fc~=sa then
                                a_=Id[14487]or na(48992,14487,20618)
                                continue
                            else
                                a_=Id[15262]or na(51009,15262,53433)
                                continue
                            end
                            a_=Id[-31489]or na(64031,-31489,35687)
                        else
                            if not(S[Ia('U\219\239Qm\223\228Q','9\186\156%')]~='')then
                                a_=Id[18856]or na(30123,18856,90991)
                                continue
                            else
                                a_=Id[17446]or na(35404,17446,23841)
                                continue
                            end
                            a_=26180
                        end
                    elseif a_<39872 then
                        if not(Rb~=S[Ia('\96c\20(Xg\31(','\f\2g\\')])then
                            a_=Id[-4713]or na(38135,-4713,26191)
                            continue
                        else
                            a_=Id[-18156]or na(28206,-18156,99547)
                            continue
                        end
                        a_=Id[-15205]or na(35983,-15205,32503)
                    elseif a_<=39872 then
                        Zb,Pd,ya=v(Zb);
                        a_=Id[2939]or na(64381,2939,34245)
                    else
                        if not(fc and _d[fc])then
                            a_=Id[14639]or na(58111,14639,35911)
                            continue
                        else
                            a_=Id[-12702]or na(63091,-12702,80199)
                            continue
                        end
                        a_=Id[-10939]or na(20833,-10939,74713)
                    end
                until a_==51588
            end),z[26730]or rd(39459,99194,26730)
            continue
        elseif Cc<=17530 then
            if not(Fb)then
                Cc=z[-23950]or rd(20490,12947,-23950)
                continue
            else
                Cc=z[25779]or rd(36157,121300,25779)
                continue
            end
            Cc=8728
        else
            return
        end
    end
end
wd()
local bb=jd:CreateWindow{[Ia('\175\250\140\254','\225\155')]=Ia('2\184\147a\236\200\6\244\149b\237\199','a\217\254\3\153\166'),[Ia('f[|\163G\248M\96t\179B\243','*4\29\199.\150')]=Ia(':\219\131\223)ptV\243\151\210n0=','v\180\226\187@\30\19'),[Ia('\174*~\166\169\0\t\177\48}\182\169\26\2\135','\226E\31\194\192nn')]=Ia("9OV\218H\29\53\'\v\160\134^\vBC\199\a#\96\4\49\171\140O",'x!\"\179hQ@FD\194\224+'),[Ia('J\159q\187\253\133\246\190\139}\153p\179\199\131\245\165\132n','\t\240\31\221\148\226\131\204\234')]={[Ia('\165g\142\130e\138\132','\224\t\239')]=false}}
local Zc=bb:CreateTab(Ia('~\31Z\16','3~'));
Zc:CreateToggle{[Ia('\136\166\171\162','\198\199')]=Ia('\213\237]\206\167:\245\232\t\230\180%\251','\148\134)\167\193Q'),[Ia('B+\129\146\176\188u\b\146\140\160\183','\1^\243\224\213\210')]=false,[Ia('\206\184\147\156\239\184\156\155','\141\217\255\240')]=function(Sa)
    local i_,db,oa;
    i_,oa={},function(Qd,Q,va)
        i_[va]=Wb(Qd,45714)-Wb(Q,17146)
        return i_[va]
    end;
    db=i_[32519]or oa(67874,49089,32519)
    repeat
        if db<31257 then
            ia();
            db=i_[-12003]or oa(99623,65382,-12003)
        elseif db>31257 then
            H=Sa
            if Sa then
                db=i_[-18665]or oa(55029,1716,-18665)
                continue
            end
            db=i_[-13398]or oa(126583,41014,-13398)
        else
            db=i_[-2321]or oa(104544,8609,-2321)
            continue
        end
    until db==51095
end};
Zc:CreateSlider{[Ia('W\225t\229','\25\128')]=Ia('\237\159\158)d\223\139\144\52o','\172\248\249[\1'),[Ia('\146\143\174\137\165','\192\238')]={0,100},[Ia('ur\241\1Yq\247\29H','<\28\146s')]=5,[Ia('\212\246\160D\149\163\227\213\179Z\133\168','\151\131\210\54\240\205')]=Ha[Ia('\197\19\164\18q\215\a\170\15z','\164t\195\96\20')],[Ia('&=Y\14\a=V\t','e\\\53b')]=function(md)
    Ha[Ia('V\172O\184uD\184A\165~','7\203(\202\16')]=md
end};
Zc:CreateSlider{[Ia('\21\190\54\186','[\223')]=Ia('\127\190\191\24\21p}S\174\241\16<f8','2\215\209\56Q\21\17'),[Ia('\183\a\139\1\128','\229f')]={10,500},[Ia('\210\tM<\254\nK \239','\155g.N')]=5,[Ia('\183\192\242\144\219;\128\227\225\142\203\48','\244\181\128\226\190U')]=Ha[Ia('\230\221\129\252\238\216\142\193','\139\180\239\184')],[Ia('\23V\136;6V\135<','T7\228W')]=function(X)
    Ha[Ia('\14\232\202\v\6\237\197\54','c\129\164O')]=X
end};
Zc:CreateSlider{[Ia('\250\154\217\158','\180\251')]=Ia('\26\2O\198\145^#6\26\23\206\184Hf','Wc7\230\213;O'),[Ia("\'\56\27>\16",'uY')]={100,1000},[Ia('Pi\147\252|j\149\224m','\25\a\240\142')]=5,[Ia('},\242\243R\31J\15\225\237B\20','>Y\128\129\55q')]=Ha[Ia('\178\3N\16\186\14W-','\223b6T')],[Ia('=\30\253\178\28\30\242\181','~\127\145\222')]=function(bc)
    Ha[Ia('[O\142?SB\151\2','6.\246{')]=bc
end};
Zc:CreateSlider{[Ia('\248|\219x','\182\29')]=Ia('\18\161c\243\144\\\184;\232A\182\169T\190\55','_\200\r\211\199\51\202'),[Ia('\247\96\203f\192','\165\1')]={1,2},[Ia('U!\168\153y\"\174\133h','\28O\203\235')]=1,[Ia('\247\254K/k\128\192\221X1{\139','\180\139\57]\14\238')]=Ha[Ia(']\150c\231U\145j\223X','0\255\r\171')],[Ia('1rZ\192\16rU\199','r\19\54\172')]=function(sc)
    Ha[Ia('\175\182s\179\167\177z\139\170','\194\223\29\255')]=sc
end};
Zc:CreateSlider{[Ia('\214\141\245\137','\152\236')]=Ia('Cw\233\239\165\150\156j6\221\170\156\158\154f','\14\22\145\207\242\249\238'),[Ia('\186\250\134\252\141','\232\155')]={5,20},[Ia('\31Gg\177\51Da\173\"','V)\4\195')]=1,[Ia('t\217\229\52o\131C\250\246*\127\136','7\172\151F\n\237')]=Ha[Ia('\16\224\198\51\24\239\217\v\21','}\129\190\127')],[Ia('i\249\150\238H\249\153\233','*\152\250\130')]=function(Kc)
    Ha[Ia('6\193#}>\206<E3','[\160[1')]=Kc
end};
E=Zc:CreateDropdown{[Ia('?)\28-','qH')]=Ia('\170PB\186\195\168LU\186\144',"\255#\'\222\227"),[Ia('R\162Wt\189Mn','\29\210#')]={},[Ia('\129\231\5\252>\172\182\221\a\250\50\173\172','\194\146w\142[\194')]={},[Ia('&R\131\v<~\128\14h\159\v<a\130\24',"k\'\239\127U\14\236")]=false,[Ia('uhRc','3\4')]=Ia('\248l\188\148\132.\227\205\222[\171\159\163%\254\222\195','\173\31\217\240\211A\145\169'),[Ia('H\226\t\250i\226\6\253','\v\131e\150')]=function()
end}
local Ua=Zc:CreateParagraph{[Ia('\17R1W ','E;')]=Ia('\254\139k\217\138y','\173\255\n'),[Ia('\rH\137:B\137:',"N\'\231")]=Ia('bU5-OHW.v\15\1','/0[X!')}
local function nc()
    local cc,ae,Td,ud,y,ic,Fa,Ec,za,Ta;
    ae,Fa={},function(_c,I,Sb)
        ae[I]=Wb(_c,5517)-Wb(Sb,44241)
        return ae[I]
    end;
    cc=ae[-26058]or Fa(53601,-26058,47384)
    while cc~=28367 do
        if cc<31175 then
            if cc>9314 then
                if cc<=19833 then
                    if cc>12140 then
                        Ua:Set{[Ia('\23K7N&','C\"')]=Ia('\5!7\" %','VUV'),[Ia('F\240\231q\250\231q','\5\159\137')]=Ia('\15\241<\145\159Ob\213\21\205\156\56#\251<\155\145Oj\156\\\140\139\56o','B\144H\242\247o\22\188q\172\247\24')}
                        return
                    else
                        za=(Nc~=''and Nc)or Ia('~','S');
                        ud=y..Ia('\223\131\223','\255')..Ec..Ia('\194\158\194','\226')..za;
                        Ua:Set{[Ia('\132g\164b\181','\208\14')]=Ia('\231\243K\192\242Y','\180\135*'),[Ia('\v\214s<\220s<','H\185\29')]=ud};
                        cc=ae[22137]or Fa(75146,22137,28137)
                        continue
                    end
                else
                    Ec,za,ud=v(Ec);
                    cc=ae[-2087]or Fa(96583,-2087,13912)
                end
            elseif cc<=8647 then
                if cc>8143 then
                    Ec,za,ud=y[Ia('\203\186\211\224\128\200','\148\229\186')](Ec);
                    cc=ae[-10426]or Fa(95371,-10426,8724)
                elseif cc>2705 then
                    cc,Ta=2705,Td
                    continue
                else
                    y,Ec='',''
                    if zd then
                        cc=ae[-2018]or Fa(27510,-2018,43210)
                        continue
                    elseif not(Ta)then
                        cc=ae[9302]or Fa(88479,9302,12787)
                        continue
                    else
                        cc=ae[-259]or Fa(58563,-259,58780)
                        continue
                    end
                    cc=12140
                end
            else
                y=zb(Ec)
                if not(y~=nil and y[Ia('\24y\149\51C\142','G&\252')]~=nil)then
                    cc=ae[5575]or Fa(83864,5575,29855)
                    continue
                else
                    cc=ae[21083]or Fa(8499,21083,48678)
                    continue
                end
                cc=ae[328]or Fa(103129,328,6594)
            end
        elseif cc<44835 then
            if cc<=43009 then
                if cc>31456 then
                    y=Ta[Ia('\179\228\144\224','\253\133')];
                    Ec,cc=Ia('\128\19\177\138\181\27\179\195','\199z\221\227')..Ta[Ia('x\169[\173','6\200')],ae[26642]or Fa(21718,26642,48446)
                elseif cc>31175 then
                    y=Ia('\213\139\240\132','\148\229');
                    cc,Ec=ae[6192]or Fa(44910,6192,10150),Ia('\145\4E\5\135\134\184Mh\2\145\134','\214m)l\245\231')
                else
                    if not(nd(Ec)==Ia('\190,\168!\175','\202M'))then
                        cc=ae[21621]or Fa(59695,21621,34480)
                        continue
                    else
                        cc=ae[19319]or Fa(17997,19319,44705)
                        continue
                    end
                    cc=ae[3929]or Fa(110021,3929,19158)
                end
            else
                y=Ia('\131','\174');
                cc,Ec=ae[18675]or Fa(41215,18675,10967),Ia('\132\179k\172-\174\177p\247m\231','\201\214\5\217C')
            end
        elseif cc>55108 then
            if ic[Ia('}\24\135mB\179y\27\155NY\187','\21y\244/+\223')]then
                cc=ae[18463]or Fa(21846,18463,36317)
                continue
            end
            cc=ae[14186]or Fa(76474,14186,49191)
        elseif cc<53825 then
            if not(not Xb)then
                cc=ae[2050]or Fa(77924,2050,57972)
                continue
            else
                cc=ae[13829]or Fa(41924,13829,50177)
                continue
            end
            cc=55108
        elseif cc>53825 then
            Ta=nil;
            Ec,za,ud=pairs(_d)
            if nd(Ec)~=Ia('\30\23\241\204\f\v\240\193','xb\159\175')then
                cc=ae[25500]or Fa(28364,25500,64014)
                continue
            end
            cc=ae[-22859]or Fa(106550,-22859,20395)
        else
            Td,ic=Ec(za,ud);
            ud=Td
            if ud==nil then
                cc=2705
            else
                cc=62369
            end
        end
    end
end
local Xc,m=bb:CreateTab(Ia('\181\55\155 \128','\244U')),{};
m[Ia('\176\161\144\164\129','\228\200')]=Ia('\234\152\250\157\203\199\187\221\202\214\207\145\203\195\170\218','\163\246\156\242\185\170\218\174');
m[Ia('I\130\206~\136\206~','\n\237\160')]=Ia(Lc'fXzGGGJa4kbec9zh435TYjf2JSjoGcK7z9iEvIfKAja93PIwy6avGna1PAett8yskh6E9zkVP+NajVN3TByzVXrGVwt/513RHPnt8AcwLH+lZXORW8/0nN2fs4/RGmays5Q/0KH9VD6RaRqs89OulhTN8jJbPOtX2U13UBmtRQ==',Lc'PAmyd0IRgzK/eYqEkQ06WBfECxjie7ubvLn+3fWrY1fF1rRZv9PdIFb0SXPCl7zA82ekk1x7WII0rSQYPnjf');
Xc:CreateParagraph(m)
local P={};
P[Ia('\142\200\174\205\191','\218\161')]=Ia('\140\225v\ab]\133\26\172\175E\24tQ\144\f','\197\143\16h\16\48\228i');
P[Ia('$r^\19x^\19','g\29\48')]=Ia(Lc'I3cvOH2Ao5gbFEyyimQ1IfwPmyRWaQKcmFd0gIUxMrTUG4WodSL5M53c0100w7LcoaY9OTM4PJGnkkwSTPXhKGch1QWDJEFjUIWVEDuexCc9voZSzL8LY7NmqJXZUTvI5tK5qg==',Lc'HVdcTBziz/07eyKS6whZAZhq7U01DCLs+3cb8qVQXNCmdOzMfwLHE9u1qzRapJK71M8=');
Xc:CreateParagraph(P)
local xd={}
local Ob,Kb,Yd,J;
xd[Ia('\200e\232\96\249','\156\f')]=Ia('\203\222,F\193\54\251\230\216\57R\143\a\255\230',"\136\191^\'\225f\158");
xd[Ia('QM\0fG\0f','\18\"n')]=Ia(Lc'IlQiwEKEX48jZmgtxwuOkWHx747HSRmNgAjUv//tmUEDSZLxm9VDGBFXNCz0+X2R+8ik+WBwMa8JvUOFKW4mfdYWhJdk+q6huAlYp+FFhpf77MsADE2QsI2BSBQeAzw4pvFrlufAp/lx',Lc'E3oCgSnwNulIBwYNs2Tp9g2Uz8+yPXaHsib0/ouY62FnLP6Q4vUneX93VUuGnA74jaHQmA==');
Xc:CreateParagraph(xd);
Kb={};
Kb[Ia('\223\3\255\6\238','\139j')]=Ia('\213\198\209\247\211\196\248','\150\167\165');
Kb[Ia('\190\129\14\137\139\14\137','\253\238\96')]=Ia(Lc'TorVQk64VGLEbZmwThdRN5QqFEsJTVl6s3eAxxZGt1QsgXSEsVlQAj3bOwEKGUFZH5h6',Lc'HuumNifTNQzkBvbeK3wiXrRZYCprJDVw+Q==');
Xc:CreateParagraph(Kb);
Yd=function(d_,kb)
    local Pb,Ic,qb;
    qb,Ic=function(Hb,yc,wa)
        Ic[yc]=Wb(Hb,31225)-Wb(wa,42527)
        return Ic[yc]
    end,{};
    Pb=Ic[31930]or qb(75524,31930,30378)
    repeat
        if Pb>=40622 then
            if Pb<60667 then
                if Pb>=42778 then
                    if Pb>42778 then
                        nc();
                        Pb=Ic[-5233]or qb(70664,-5233,26972)
                    else
                        zd=false;
                        nc();
                        Pb=Ic[24010]or qb(38706,24010,62978)
                    end
                else
                    Pb=Ic[10657]or qb(44601,10657,8058)
                    continue
                end
            elseif Pb>61000 then
                ia();
                Pb=Ic[7299]or qb(37564,7299,38357)
            elseif Pb<=60667 then
                Nc=kb or'';
                nc();
                Pb=Ic[3162]or qb(54327,3162,43327)
            else
                if not(d_==Ia('\254{g\249\217[s\249\195','\173\15\6\139'))then
                    Pb=Ic[-11679]or qb(47696,-11679,6182)
                    continue
                else
                    Pb=Ic[-1824]or qb(95481,-1824,27307)
                    continue
                end
                Pb=Ic[-13236]or qb(70523,-13236,28107)
            end
        elseif Pb>16460 then
            if Pb>36424 then
                Xb=true;
                zd=false;
                Yc();
                Vd();
                nc();
                Pb=Ic[-1330]or qb(41554,-1330,39650)
            else
                if not(d_==Ia('KX\189\199\56yD\177\216 Q','\24\48\210\176u'))then
                    Pb=Ic[10003]or qb(62499,10003,51335)
                    continue
                else
                    Pb=Ic[-25217]or qb(85386,-25217,15396)
                    continue
                end
                Pb=40622
            end
        elseif Pb<9326 then
            if Pb<=1392 then
                if d_==Ia('\197D@\212_V\238','\128*$')then
                    Pb=Ic[-28759]or qb(93635,-28759,52031)
                    continue
                elseif not(d_==Ia('=\25\144\254\189\24\19\249\183\30\f\134\211\172\t\52\249\183','hi\244\159\201}@\156\197'))then
                    Pb=Ic[2831]or qb(76263,2831,5999)
                    continue
                else
                    Pb=Ic[6376]or qb(93217,6376,36546)
                    continue
                end
                Pb=Ic[18581]or qb(124273,18581,23493)
            else
                if not(d_==Ia('\217\154Z\141\195\240\135]\128\219\216','\145\243>\232\142'))then
                    Pb=Ic[24681]or qb(88653,24681,37747)
                    continue
                else
                    Pb=Ic[12040]or qb(41298,12040,4642)
                    continue
                end
                Pb=Ic[32656]or qb(54622,32656,44006)
            end
        elseif Pb<=9326 then
            Xb=false;
            zd=false;
            Nc='';
            Yc();
            _d={};
            nc();
            Pb=Ic[17478]or qb(53451,17478,44187)
        else
            zd=true
            if H then
                Pb=Ic[-7984]or qb(78310,-7984,61111)
                continue
            end
            Pb=46971
        end
    until Pb==7771
end;
J=function(wb)
    local lc,ba,O;
    ba,lc={},function(Ac,ga,s_)
        ba[ga]=Wb(s_,35463)-Wb(Ac,12439)
        return ba[ga]
    end;
    O=ba[-27960]or lc(23355,-27960,101329)
    repeat
        if O>22661 then
            if Xb and not zd then
                O=ba[14410]or lc(4498,14410,62221)
                continue
            end
            O=15509
        elseif O>15509 then
            ac,O=wb or'',ba[-18577]or lc(225,-18577,59276)
        else
            O=ba[6553]or lc(33979,6553,98315)
            continue
        end
    until O==22112
end;
Ob=function(jc)
    local Od,Nd,u_;
    Nd,u_=function(rb,pa,Fd)
        u_[rb]=Wb(Fd,43556)-Wb(pa,14267)
        return u_[rb]
    end,{};
    Od=u_[13854]or Nd(13854,45990,27694)
    repeat
        if Od>16160 then
            if jc then
                Od=u_[12800]or Nd(12800,51931,104100)
                continue
            end
            Od=u_[3114]or Nd(3114,8249,60758)
        elseif Od>=12272 then
            if Od<=12272 then
                Od=u_[19414]or Nd(19414,18574,22950)
                continue
            else
                Ab(jc)
                if not(H and Xb and zd)then
                    Od=u_[9795]or Nd(9795,33369,20470)
                    continue
                else
                    Od=u_[-23984]or Nd(-23984,21991,52304)
                    continue
                end
                Od=u_[3113]or Nd(3113,54357,113146)
            end
        else
            Ld();
            ia();
            Od=u_[-29562]or Nd(-29562,41585,28574)
        end
    until Od==29773
end;
Uc[Ia('\237\230\237\57\238\"\204\252\235#\226)\214','\162\136\174U\135G')]:Connect(function(Nb)
    wc=Nb;
    print(Ia('w\96S>\140\207\157P\n\21nDy\128\200\130_W','5\5!Y\237\173\232>m'),Nb);
    _d={};
    Vd();
    nc()
end);
dc[Ia('\21M\137\21\53\141\52W\143\15\57\134.','Z#\202y\\\232')]:Connect(function()
    print(Ia('\172~?\131\31E\178\243\141p0\132QO\176\248\128','\225\27Q\234q\"\213\146'));
    wc=nil;
    Xb=false;
    zd=false;
    Nc='';
    Yc();
    _d={};
    nc()
end);
Ca[Ia('\174\234\206<\244\49\143\240\200&\248:\149','\225\132\141P\157T')]:Connect(Yd);
Wa[Ia('\133\26,\240\96a\164\0*\234lj\190','\202to\156\t\4')]:Connect(J);
ad[Ia('\235\182\25\28V\3\202\172\31\6Z\b\208','\164\216Zp?f')]:Connect(Ob);
task[Ia("\'\209\53\214:",'T\161')](function()
    local ua,kc,mc;
    ua,kc=function(T,Tc,hb)
        kc[hb]=Wb(T,54209)-Wb(Tc,37278)
        return kc[hb]
    end,{};
    mc=kc[26479]or ua(17652,5220,26479)
    repeat
        if mc<=39610 then
            if mc<27930 then
                if not(Xb)then
                    mc=kc[23039]or ua(116365,14764,23039)
                    continue
                else
                    mc=kc[9317]or ua(90636,21826,9317)
                    continue
                end
                mc=27930
            elseif mc>27930 then
                mc=kc[12451]or ua(83682,26483,12451)
                continue
            else
                task[Ia('}\199c\210','\n\166')](0.29999999999999999);
                mc=kc[6516]or ua(119452,25020,6516)
            end
        else
            nc();
            mc=kc[10881]or ua(20132,41429,10881)
        end
    until mc==40502
end);
print(Ia(':\187\151)\137!\203\147L\245\152*\r\29\25\160K\2\157\241\f\252\55\177\227,\230,\218\151G\151\141*\29\29\29\167W\22\232\255\21\236','{\245\195\96\169m\158\210\3\183\222\127^^X\244\4P\189\179Y\181'))
