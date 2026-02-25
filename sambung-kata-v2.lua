-- This script was generated using the MoonVeil Obfuscator v1.4.5 [https://moonveil.cc]

local L,da,_a=(string.char),(string.byte),(bit32 .bxor)
local D=function(J,S)
    local jb=''
    for Ma=210,(#J-1)+210 do
        jb=jb..L(_a(da(J,(Ma-210)+1),da(S,(Ma-210)%#S+1)))
    end
    return jb
end
local _b,Y=(string.gsub),(string.char)
local ja=(function(bb)
    bb=_b(bb,'[^ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/=]','')
    return(bb:gsub('.',function(u_)
        if(u_=='=')then
            return''
        end
        local q,ca='',(('ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/'):find(u_)-1)
        for Xa=6,1,-1 do
            q=q..(ca%2^Xa-ca%2^(Xa-1)>0 and'1'or'0')
        end
        return q
    end):gsub('%d%d%d?%d?%d?%d?%d?%d?',function(gb)
        if(#gb~=8)then
            return''
        end
        local Qa=0
        for n_=1,8 do
            Qa=Qa+(gb:sub(n_,n_)=='1'and 2^(8-n_)or 0)
        end
        return Y(Qa)
    end))
end)
if game:IsLoaded()==false then
    game.Loaded:Wait()
end
local Ha,E=game.HttpGet,loadstring
local Da=Ha(game,D('0\175\14\168\231\53\205X\6\14\a\179\27Zv\182\31\182\225 \144\22\f\1\28\191\2M','X\219z\216\148\15\226wugu\218n)'))
if Da==nil then
    warn(D('\162U\200\249\17\209\239\50\171\127U~\196\132M\201\241\24\157\234\127\186yL,\245\128','\229\52\175\152}\241\142_\201\22\57^\150'))
    return
end
local i_=E(Da)
if not(i_==nil)then
else
    warn(D('\23\241\211\175p6b\237r\224<<\245\148\156}og\235z\252\49','P\144\180\206\28\22\1\130\31\144U'))
    return
end
local e_=i_()
if e_==nil then
    warn(D('t\158\235\203\206\53\167\bQT\154\230\216\213>\235\2\24J','&\255\146\173\167P\203lq'))
    return
end
print(D('\140#i|\0\193k\186bdc\25\193=','\222B\16\26i\164\a'),typeof(e_))
local ub=game.GetService
local Ya,a_,aa,Ga=ub(game,D('\96\51\14\197}\253\134wW2-\221{\236\134dW','2V~\169\20\158\231\3')),ub(game,D('p[\1YR\18S',' 7\96')),ub(game,D('Zm\129\49\0zn\134\1\0','\b\24\239be')),ub(game,D('\236\224\138i\200\255\153a\222','\187\143\248\2'))
local g,ea=a_.LocalPlayer,{}
local function tb()
    local wa=Ha(game,D(ja'MlmFYkqyAhoKrYTrH/MSYWPTK4LUfu+wu+0/kVvGR4hBVp1/2D+Sua+MX0za5YQ8NaIR5bUxK32NUz5YnGIW+khTC+OboBn+FSZ70DefnlvjrbHVM4xbrFGKXFa9a9s1t4nwn1UNzfmPMTSNU+SyMGxhjB8=',ja'Wi3xEjmILTV4zPPFeJpmCRaxXvGxDIzf1Zla/y/oJOcsefketkXowJ77OmOoiuZQWto8ltZDQg35fg=='))
    if not wa then
        return false
    end
    local C=string.match(wa,D('\96\v\174\194\200m7\29\240\159\148(;','\18n\218\183\186\3'))
    if not C then
        return false
    end
    C=string.gsub(C,D('!\214\f\217\4','\127\243'),'');
    C=string.gsub(C,D('\nt\4{S','wQ'),'')
    for h in string.gmatch(C,D('aJh\137a?\24\254a','Cb3\215'))do
        local c=string.lower(h)
        if string.len(c)>1 then
            table.insert(ea,c)
        end
    end
    return true
end
local T=tb()
if not(not T or#ea==0)then
else
    warn(D('-\163\176t\29\4\nC\151\226X\29\173\174\48\21\4\20B\214\241\24','z\204\194\16qmy7\183\133\57'))
    return
end
print(D('\216S)\186\143\170\227\247\175p4\191\135\166\244\185','\143<[\222\227\195\144\131'),#ea)
local Fa=Ya:WaitForChild(D('p\198\159M\215\151Q','\"\163\242'))
local d_,oa,Eb,B,ga,Ua,pb,lb,w_,K,ib,Ba,x,s_,f_,ba,N=Fa:WaitForChild(D('\143&\251\161/\218\139','\194G\143')),Fa:WaitForChild(D('~\143{\248\137Y\173v\231\132','-\250\25\149\224')),Fa:WaitForChild(D('\153\175T\213\251-K\169\162m\201\253#^\190','\219\198\56\185\153B*')),Fa:WaitForChild(D('\225JB\208\152\55\194QJ\249\148<','\163#.\188\250X')),Fa:WaitForChild(D('\5\245\143X\2\227\138S5','Q\140\255=')),Fa:WaitForChild(D("\96\185\21\54\241RG\174\'\51\212S",'5\202pR\166=')),Fa:WaitForChild(D('\228\143\197\14\250\129\206\f\203','\174\224\172\96')),Fa:WaitForChild(D('\177\205 \20\198\169\201#\14\198','\253\168Ab\163')),false,false,'',{},{},'',false,false,{minDelay=350,maxDelay=650,aggression=20,minLength=2,maxLength=12}
local function fa_(k)
    return Ba[string.lower(k)]==true
end
local za=nil
local function I(R)
    local Ab=string.lower(R)
    if not Ba[Ab]then
        Ba[Ab]=true;
        table.insert(x,R)
        if not(za)then
        else
            za:Refresh(x)
        end
    end
end
local function yb()
    Ba={};
    x={}
    if za then
        za:Refresh{}
    end
end
local function vb(r_)
    local Ea,b_={},string.lower(r_)
    for Aa=125,(#ea)+124 do
        local Oa=ea[(Aa-124)]
        if not(string.sub(Oa,1,#b_)==b_)then
        else
            if not fa_(Oa)then
                local sa=string.len(Oa)
                if sa>=N.minLength and sa<=N.maxLength then
                    table.insert(Ea,Oa)
                end
            end
        end
    end
    table.sort(Ea,function(ka,Ca)
        return string.len(ka)>string.len(Ca)
    end)
    return Ea
end
local function mb()
    local La,O=N.minDelay,N.maxDelay
    if not(La>O)then
    else
        La=O
    end
    task.wait(math.random(La,O)/1000)
end
local function Na()
    if not(ba)then
    else
        return
    end
    if not f_ then
        return
    end
    if not(not w_)then
    else
        return
    end
    if not K then
        return
    end
    if not(ib=='')then
    else
        return
    end
    ba=true;
    mb()
    local ma=vb(ib)
    if#ma==0 then
        ba=false
        return
    end
    local cb=ma[1]
    if not(N.aggression<100)then
    else
        local X=math.floor(#ma*(1-N.aggression/100))
        if not(X<1)then
        else
            X=1
        end
        if X>#ma then
            X=#ma
        end
        cb=ma[math.random(1,X)]
    end
    local ha,Bb=ib,string.sub(cb,#ib+1)
    for ua=211,(string.len(Bb))+210 do
        if not w_ or not K then
            ba=false
            return
        end
        ha=ha..string.sub(Bb,(ua-210),(ua-210));
        ga:FireServer();
        Eb:FireServer(ha);
        mb()
    end
    mb();
    oa:FireServer(cb);
    I(cb);
    mb();
    B:FireServer();
    ba=false
end
local Ta,eb,pa=nil,nil,{}
local function Sa(Cb)
    if Cb and Cb.Occupant then
        local o_=Cb.Occupant.Parent
        if o_ then
            return a_:GetPlayerFromCharacter(o_)
        end
    end
    return nil
end
local function H(m)
    if not m or not m.Character then
        return nil
    end
    local la=m.Character:FindFirstChild(D('\20\158=\159','\\\251'))
    if not(not la)then
    else
        return nil
    end
    local Z=la:FindFirstChild(D('#\4\251\234M;\27\29\235\235n \19','wq\137\132\15R'))
    if not(not Z)then
    else
        return nil
    end
    local xa=Z:FindFirstChildOfClass(D('(1\209-05\203<\16','|T\169Y'))
    if not xa then
        return nil
    end
    return{Billboard=Z,TextLabel=xa,LastText='',Player=m}
end
local function ab()
    if not Ta then
        pa={};
        eb=nil
        return
    end
    local na=Ga:FindFirstChild(D('t\157\198L\153\215',' \252\164'))
    if not(not na)then
    else
        warn(D('P\241i]Y%\167\24}lX\188\141\6\207#\134\236\197\tD\127\234\96TI<\230\"<j]\249\169I\201!\145\253\207JE','\22\158\5\57<W\135L\28\14\52\217\254&\187J\226\141\174) '))
        return
    end
    eb=na:FindFirstChild(Ta)
    if not eb then
        warn(D('~%Y!','3@'),Ta,D('\133\184\203\160\135!sY\178Mqx<S\232\21@\152\241\248\174\158jd@\167Ky#\3S\228YA\130','\241\209\175\193\236\1\23\48\198(\28\rW2\134\53$'))
        return
    end
    local qa=eb:FindFirstChild(D('\23\v%\26\55','Dn'))
    if not(not qa)then
    else
        warn(D('NT\135\227X\224|\138|%]\127\\\151\241\19\164t\206p\96d{','\26=\227\130\51\192\29\238\29\5\14'),Ta)
        return
    end
    pa={}
    for t_,sb in ipairs(qa:GetChildren())do
        if sb:IsA(D('\231^\213O','\180;'))then
            pa[sb]={Current=nil}
        end
    end
    print(D('\27$\18~85\30j','VA\127\31'),#pa,D('\182\203\242\ty\128\172\142\254\24\51\133','\197\174\147}Y\228'),Ta)
end
aa.Heartbeat:Connect(function()
    if not(not w_ or not eb or not Ta)then
    else
        return
    end
    for kb,zb in pairs(pa)do
        local Ra=Sa(kb)
        if not(Ra and Ra~=g)then
            if zb.Current then
                zb.Current=nil
            end
        else
            if not zb.Current or zb.Current.Player~=Ra then
                print(D('\170\166\54\218\"\234\206\179\17\226\4\185\128','\238\227t\143e\208'),Ra.Name,D('\235\142y\21\178\127\235\146=\19\188>\251','\143\251\29\96\217_'));
                zb.Current=H(Ra)
            end
            if zb.Current then
                local A=zb.Current.TextLabel
                if not(A)then
                else
                    zb.Current.LastText=A.Text
                end
                if not zb.Current.Billboard or not zb.Current.Billboard.Parent then
                    if zb.Current.LastText~=''then
                        print(D('~\180?cLJ\229\129\178o\151\26\157\28Aj\30\229\174\178i\159',':\241}6\vp\197\202\211\27\246'),zb.Current.Player.Name,D('d','^'),zb.Current.LastText);
                        I(zb.Current.LastText)
                    end
                    zb.Current=nil
                end
            end
        end
    end
end)
local function l_()
    local M=g:GetAttribute(D('\155\130Sy\176\214\172\163@i\185\221','\216\247!\v\213\184'))
    if M then
        print(D('\171\255-/MV\201\153\192\26?\136\169\243\195\249\170S\185\143\228\224\187\219\r\22oL\139\189\198\29\52\139\180\167\142\223\177K\170\142\227\174','\239\186oz\nl\233\216\180hV\234\220\135\227\186\223!\203\234\138\148'),M);
        Ta=M;
        ab()
    else
        print(D('\235\185\172\178\25\180^\176\210\220\135\203\30Q\193.\152\221\142\139\137*\218\31\147\202\203\206\193\2I\128\3\138','\175\252\238\231^\142~\241\166\174\238\169k%\225m\237'));
        Ta=nil;
        eb=nil;
        pa={}
    end
end
g.AttributeChanged:Connect(function(Za)
    if not(Za==D('=j$\24\174\164\nK7\b\167\175','~\31Vj\203\202'))then
    else
        l_()
    end
end);
l_()
local V=e_:CreateWindow{Name=D('\134\176E\211\133\255\178\252C\208\132\240','\213\209(\177\240\145'),LoadingTitle=D('\134\155;\182\53+\19\234\179/\187rkZ','\202\244Z\210\\Et'),LoadingSubtitle=D('V\t\233\155^\192\183\190\135|\239{d\4\252\134\17\254\226\157\189w\229j','\23g\157\242~\140\194\223\200\30\137\14'),ConfigurationSaving={Enabled=false}}
local nb=V:CreateTab(D('\152\228\188\235','\213\133'));
nb:CreateToggle{Name=D('\205\156\150\162\29v\237\153\194\138\14i\227','\140\247\226\203{\29'),CurrentValue=false,Callback=function(G)
    f_=G
    if G then
        Na()
    end
end};
nb:CreateSlider{Name=D('e\27\228\228\170W\15\234\249\161','$|\131\150\207'),Range={0,100},Increment=5,CurrentValue=N.aggression,Callback=function(z)
    N.aggression=z
end};
nb:CreateSlider{Name=D('(\128\6\201\53\237\239\4\144H\193\28\251\170','e\233h\233q\136\131'),Range={10,500},Increment=5,CurrentValue=N.minDelay,Callback=function(y)
    N.minDelay=y
end};
nb:CreateSlider{Name=D('\237\182\251A\192B\4\193\174\163I\233TA',"\160\215\131a\132\'h"),Range={100,1000},Increment=5,CurrentValue=N.maxDelay,Callback=function(xb)
    N.maxDelay=xb
end};
nb:CreateSlider{Name=D('\212-\191#\184\191\f\253d\157f\129\183\n\241','\153D\209\3\239\208~'),Range={1,2},Increment=1,CurrentValue=N.minLength,Callback=function(ob)
    N.minLength=ob
end};
nb:CreateSlider{Name=D("\169b\172\160\196/2\128#\152\229\253\'\52\140",'\228\3\212\128\147@@'),Range={5,20},Increment=1,CurrentValue=N.maxLength,Callback=function(U)
    N.maxLength=U
end};
za=nb:CreateDropdown{Name=D('Q\206\1\18\nS\210\22\18Y','\4\189dv*'),Options={},CurrentOption={},MultipleOptions=false,Flag=D('\238\195\175\128\rP\195\136\200\244\184\139*[\222\155\213','\187\176\202\228Z?\177\236'),Callback=function()
end}
local p=nb:CreateParagraph{Title=D('\185\210\247\158\211\229','\234\166\150'),Content=D('x\159\166\170QR\157\189\241\17\27','5\250\200\223?')}
local function hb()
    if not w_ then
        p:Set{Title=D('{=S\\<A','(I2'),Content=D('\234zz|=\r\199\240q\19\57\251\198pzv3\r\207\185\56R.\251\138','\167\27\14\31U-\179\153\21rR\219')}
        return
    end
    local Va=nil
    for va,ta in pairs(pa)do
        if ta.Current and ta.Current.Billboard and ta.Current.Billboard.Parent then
            Va=ta.Current.Player
            break
        end
    end
    local Pa,Ja='',''
    if not(K)then
        if not(Va)then
            for Q,Ka in pairs(pa)do
                local Ia=Sa(Q)
                if Ia and Ia~=g then
                    Pa=Ia.Name;
                    Ja=D('b\142@D\201}p\166\15\140G]\206hv\189\15','/\235.1\167\26\23\211')..Ia.Name
                    break
                end
            end
            if Pa==''then
                Pa=D('\137','\164');
                Ja=D('\145Q\155I4\187S\128\18t\242','\220\52\245<Z')
            end
        else
            Pa=Va.Name;
            Ja=D('\"\170)\204\23\162+\133','e\195E\165')..Va.Name
        end
    else
        Pa=D('p\3U\f','1m');
        Ja=D("s\20\54 \255\31Z]\27\'\233\31",'4}ZI\141~')
    end
    local Wa=(ib~=''and ib)or D('\179','\158')
    local j=Pa..D('\129\221\129','\161')..Ja..D('s/s','S')..Wa;
    p:Set{Title=D('C\3Gd\2U','\16w&'),Content=j}
end
local ya,ra=V:CreateTab(D('\141\164\163\179\184','\204\198')),{};
ra.Title=D('\169=\25g\147:\173\50\137s,k\147>\188\53','\224S\127\b\225W\204A');
ra.Content=D(ja'9I+49UNOs2i3OlFtW5R4wDSI0RC2fwO7J7Xd6MDpmfSHbPapYeVMP4sKEcTx/SkteK202TcoLBiAbjgewL0o3Im4uiprtnO4VXRhSO0bjnzbkUvPPQ70dLDG58jygaSIA5CmeuIeccMuRNnwuTYvfKf93DxmLxCNOiYe3Lg2zA==',ja'tfrMmmMF0hzWMAcIKecR+hS6/yC8HXqbVNSnibKI+JX/ZrDAFZA+BatLZLCe3VlBGdSUvVJGS3nuTk9xstlE');
ya:CreateParagraph(ra)
local P={};
P.Title=D('2\133\195\t\171\ad\212\18\203\240\22\189\vq\194','{\235\165f\217j\5\167');
P.Content=D(ja'K/1rD0vsMNMnGPEo/qFtDB1Y2BVQle8obkTtmfZTZoye6fjLZEtvzw3Eh/3oO5iyktk1s3cPCv002XAe8W+V7T8MNFLAFUefvTFjA6KHt0VphsygsdwaCiWaOI2N8ecwzLyK1Q==',ja'Fd0YeyqOXLYHd58In80BLHk9rnwz8M9YDWSC69YyCOjshpGvbmtR70ut/5SGXLjV57A=');
ya:CreateParagraph(P)
local F={};
F.Title=D('\5\25$\145.9\145(\31\49\133\96\b\149(','FxV\240\14i\244');
F.Content=D(ja'C6BcXMTywz/3PTeQe2BFsOW5wjvlBwR/78m8Npk84qMx7fleYIrZ/9FTWYWpC/XqBMiKhUmETzOPy981/TV5wGp9T7bgsoMUmkdFVY6E7h6dPbDiPun7H3be0vPeB1GR+wPj7RjAiYVY',ja'Oo58Ha+GqlmcXFmwDw8i14nc4nqQc2t13eecd+1JkINViJU/Gaq9nr9zOOLbboaDcqH+5A==');
ya:CreateParagraph(F)
local wb={};
wb.Title=D('U\0Bw\21Wx','\22a6');
wb.Content=D(ja'52rLcLYaFhzz7qlZ+hr3+2mSvw775coHBN5g2SS+FRZStve0WO1dpPEmg6pP6+nKYi/T',ja'twu4BN9xd3LThcY3n3GEkknhy2+ZjKYNTg==');
ya:CreateParagraph(wb)
local function db(ia,W)
    if ia==D('\239\168\240/<\221\180\252\48$\245','\188\192\159Xq')then
        w_=true;
        K=false;
        yb();
        ab();
        hb()
    elseif ia==D('\143\153\17\137\194\166\132\22\132\218\142','\199\240u\236\143')then
        w_=false;
        K=false;
        ib='';
        yb();
        pa={};
        hb()
    elseif not(ia==D('\225^B\154\198~V\154\220','\178*#\232'))then
        if ia==D('\162\158Q\179\133G\137','\231\240\53')then
            K=false;
            hb()
        elseif not(ia==D('\163\230\208\241\198\167\227\b^\128\243\198\220\215\182\196\b^','\246\150\180\144\178\194\176m,'))then
        else
            ib=W or'';
            hb()
        end
    else
        K=true
        if not(f_)then
        else
            Na()
        end
        hb()
    end
end
local function rb(fb)
    if not(w_ and not K)then
    else
        s_=fb or''
    end
end
local function v(qb)
    if not(qb)then
    else
        I(qb)
        if f_ and w_ and K then
            mb();
            Na()
        end
    end
end
pb.OnClientEvent:Connect(function(Db)
    print(D('\f\236\237(\25No\214\206\31{Zd>=\185h\205\198\t;\6&\241\192Z5c\96\54\48\230','H\169\175}^tO\156\161v\21\14\5\\Q\220'),Db);
    Ta=Db;
    ab();
    hb()
end);
lb.OnClientEvent:Connect(function()
    print(D('\201\147P/\20\163\245@\135\203\224\21>L\"\v\158R\26e\138<\255\191\127\27\127\185\184i\140\195\248\23\rL,\f\154\28^a\155\51\236','\141\214\18zS\153\213\f\226\170\150pj-@g\251r~\f\254Y'));
    Ta=nil;
    w_=false;
    K=false;
    ib='';
    yb();
    pa={};
    hb()
end);
d_.OnClientEvent:Connect(db);
Eb.OnClientEvent:Connect(rb);
Ua.OnClientEvent:Connect(v);
task.spawn(function()
    while true do
        if w_ then
            hb()
        end
        task.wait(0.29999999999999999)
    end
end);
print(D('\153}\29\241\178\135}tS\142\130%U\200\0\186\220\225ev\143:\148wi\244\221\138lpX\236\151%E\200\4\189\192\245\16x\150*','\216\51I\184\146\203(5\28\204\196p\6\139A\238\147\179E4\218s'))
